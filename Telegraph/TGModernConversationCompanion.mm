/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationCompanion.h"

#import "TGModernConversationController.h"

#import "ActionStage.h"
#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TGAppDelegate.h"
#import "TGInterfaceManager.h"

#import "TGMessage.h"
#import "TGMessageModernConversationItem.h"

#import "TGImageUtils.h"
#import "TGPhoneUtils.h"

#import "TGModernConversationViewContext.h"
#import "TGModernTemporaryView.h"

#import "TGModernViewStorage.h"
#import "TGModernImageView.h"
#import "TGModernImageViewModel.h"
#import "TGModernViewContext.h"
#import "TGModernConversationViewLayout.h"
#import "TGModernDateHeaderView.h"
#import "TGModernUnreadHeaderView.h"

#import "TGModernConversationGenericEmptyListView.h"

#import "TGIndexSet.h"

#import "TGApplication.h"
#import "TGWallpaperManager.h"

#import "TGTelegraph.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 // iOS 6.0 or later
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else                                         // iOS 5.X or earlier
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif

static const char *messageQueueName = "com.telegraph.modernmessagequeue";

static dispatch_queue_t messageQueue()
{
    static dispatch_queue_t queue = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = dispatch_queue_create(messageQueueName, 0);
        dispatch_queue_set_specific(queue, messageQueueName, (void *)messageQueueName, NULL);
    });
    
    return queue;
}

static bool isMessageQueue()
{
    return dispatch_get_specific(messageQueueName) == messageQueueName;
}

static void dispatchOnMessageQueue(dispatch_block_t block, bool synchronous)
{
    if (block == NULL)
        return;
    
    if (dispatch_get_specific(messageQueueName) == messageQueueName)
        block();
    else
    {
        if (synchronous)
            dispatch_sync(messageQueue(), block);
        else
            dispatch_async(messageQueue(), block);
    }
}

@interface TGModernConversationCompanion ()
{
    bool _hasStarted;
    
    TGModernViewStorage *_tempViewStorage;
    void *_tempMemory;
    NSIndexSet *_tempVisibleItemsIndices;
    
    CGFloat _controllerWidthForItemCalculation;
    
    dispatch_semaphore_t _sendMessageSemaphore;
    
    int32_t _initialPositionedMessageId;
    TGInitialScrollPosition _initialScrollPosition;
    
    TGMessageRange _unreadMessageRange;
    
    std::set<int32_t> _checkedMessages;
    
    std::map<int32_t, int> _messageFlags;
    std::map<int32_t, NSTimeInterval> _messageViewDate;
    
    TGMessageModernConversationItem * (*_updateMediaStatusDataImpl)(id, SEL, TGMessageModernConversationItem *);
    
    bool _controllerShowingEmptyState; // Main Thread
}

@end

@implementation TGModernConversationCompanion

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        _items = [[NSMutableArray alloc] init];
        _tempViewStorage = [[TGModernViewStorage alloc] init];
        
        TGModernConversationViewContext *viewContext = [[TGModernConversationViewContext alloc] init];
        viewContext.companion = self;
        viewContext.companionHandle = _actionHandle;
        _viewContext = viewContext;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
#if NEEDS_DISPATCH_RETAIN_RELEASE
    if (_sendMessageSemaphore != nil)
        dispatch_release(_sendMessageSemaphore);
#endif
    _sendMessageSemaphore = nil;
    
    if (_tempMemory != NULL)
    {
        free(_tempMemory);
        _tempMemory = nil;
    }
}

+ (void)warmupResources
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        TGMessage *message = [[TGMessage alloc] init];
        message.text = @"abcdefghijklmnopqrstuvwxyz1234567890";
        TGMessageModernConversationItem *messageItem = [[TGMessageModernConversationItem alloc] initWithMessage:message context:nil];
        [messageItem sizeForContainerSize:CGSizeMake(320.0f, 0.0f)];
        
        [[TGWallpaperManager instance] currentWallpaperImage];
    });
}

+ (bool)isMessageQueue
{
    return isMessageQueue();
}

+ (void)dispatchOnMessageQueue:(dispatch_block_t)block
{
    dispatchOnMessageQueue(block, false);
}

- (void)lockSendMessageSemaphore
{
    return;
    
#if NEEDS_DISPATCH_RETAIN_RELEASE
    if (_sendMessageSemaphore != nil)
        dispatch_release(_sendMessageSemaphore);
#endif
    
    _sendMessageSemaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(_sendMessageSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.07 * NSEC_PER_SEC)));
    
#if NEEDS_DISPATCH_RETAIN_RELEASE
    if (_sendMessageSemaphore != nil)
        dispatch_release(_sendMessageSemaphore);
#endif
    _sendMessageSemaphore = nil;
}

- (void)unlockSendMessageSemaphore
{
    if (_sendMessageSemaphore != nil)
        dispatch_semaphore_signal(_sendMessageSemaphore);
}

- (void)setInitialMessagePositioning:(int32_t)initialPositionedMessageId position:(TGInitialScrollPosition)position
{
    _initialPositionedMessageId = initialPositionedMessageId;
    _initialScrollPosition = position;
}

- (int32_t)initialPositioningMessageId
{
    return _initialPositionedMessageId;
}

- (TGInitialScrollPosition)initialPositioningScrollPosition
{
    return _initialScrollPosition;
}

- (void)setUnreadMessageRange:(TGMessageRange)unreadMessageRange
{
    _unreadMessageRange = unreadMessageRange;
}

- (TGMessageRange)unreadMessageRange
{
    return _unreadMessageRange;
}

- (CGFloat)initialPositioningOverflowForScrollPosition:(TGInitialScrollPosition)scrollPosition
{
    if (scrollPosition == TGInitialScrollPositionTop)
        return 28.0f;
    
    return 1.0f;
}

- (void)bindController:(TGModernConversationController *)controller
{
    self.controller = controller;
    
    [self loadInitialState];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [self subscribeToUpdates];
    }];
}

- (void)_ensureReferenceMethod
{
}

- (void)unbindController
{
    self.controller = nil;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [self _ensureReferenceMethod];
    }];
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [self _ensureReferenceMethod];
    }];
}

- (void)loadInitialState
{
}

- (void)subscribeToUpdates
{
}

- (void)_controllerWillAppearAnimated:(bool)animated firstTime:(bool)firstTime
{
    if (firstTime)
    {
        if (animated && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self _createInitialSnapshot];
        else
        {
            for (TGMessageModernConversationItem *item in _items)
            {
                [self _updateImportantMediaStatusDataInplace:item];
            }
            
            TGModernConversationController *controller = _controller;
            [controller setInitialSnapshot:NULL backgroundView:nil viewStorage:_tempViewStorage];
        }
        
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            [self _updateMediaStatusDataForItemsInIndexSet:_tempVisibleItemsIndices animated:false];
        }];
    }
}

- (void)_controllerDidAppear:(bool)firstTime
{
    TGModernConversationController *controller = _controller;
    if (firstTime)
    {
#if TARGET_IPHONE_SIMULATOR
        //sleep(1);
#endif
        
        [_tempViewStorage allowResurrectionForOperations:^
        {
            [controller setInitialSnapshot:NULL backgroundView:nil viewStorage:_tempViewStorage];
        }];
        
        if (_tempMemory != NULL)
        {
            free(_tempMemory);
            _tempMemory = nil;
        }
        
        _tempViewStorage = nil;
        
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            [self _updateMediaStatusDataForCurrentItems];
        }];
    }
}

- (void)_controllerAvatarPressed
{
}

- (void)_dismissController
{
    [[TGInterfaceManager instance] dismissConversation];
}

- (void)_setControllerWidthForItemCalculation:(CGFloat)width
{
    _controllerWidthForItemCalculation = width;
}

- (void)_loadControllerPrimaryTitlePanel
{
}

- (TGModernConversationEmptyListPlaceholderView *)_conversationEmptyListPlaceholder
{
    TGModernConversationGenericEmptyListView *placeholder = [[TGModernConversationGenericEmptyListView alloc] init];
    placeholder.delegate = self.controller;
    
    return placeholder;
}

- (UIView *)_controllerInputTextPanelAccessoryView
{
    return nil;
}

- (NSString *)_controllerInfoButtonText
{
    return nil;
}

- (void)updateControllerInputText:(NSString *)__unused inputText
{
}

- (void)controllerDidUpdateTypingActivity
{
}

- (void)controllerWantsToSendTextMessage:(NSString *)__unused text
{
}

- (void)controllerWantsToSendMapWithLatitude:(double)__unused latitude longitude:(double)__unused longitude
{
}

- (NSURL *)fileUrlForDocumentMedia:(TGDocumentMediaAttachment *)__unused documentMedia
{
    return nil;
}

- (NSDictionary *)imageDescriptionFromImage:(UIImage *)__unused image optionalAssetUrl:(NSString *)__unused assetUrl
{
    return nil;
}

- (NSDictionary *)imageDescriptionFromBingSearchResult:(TGBingSearchResultItem *)__unused item
{
    return nil;
}

- (NSDictionary *)documentDescriptionFromGiphySearchResult:(TGGiphySearchResultItem *)__unused item
{
    return nil;
}

- (NSDictionary *)imageDescriptionFromInternalSearchImageResult:(TGWebSearchInternalImageResult *)__unused item
{
    return nil;
}

- (NSDictionary *)documentDescriptionFromInternalSearchResult:(TGWebSearchInternalGifResult *)__unused item
{
    return nil;
}

- (void)controllerWantsToSendImagesWithDescriptions:(NSArray *)__unused imageDescriptions
{
}

- (void)controllerWantsToSendLocalVideoWithTempFilePath:(NSString *)__unused tempVideoFilePath fileSize:(int32_t)__unused fileSize previewImage:(UIImage *)__unused previewImage duration:(NSTimeInterval)__unused duration dimensions:(CGSize)__unused dimenstions assetUrl:(NSString *)__unused assetUrl liveUploadData:(TGLiveUploadActorData *)__unused liveUploadData
{
}

- (TGVideoMediaAttachment *)serverCachedAssetWithId:(NSString *)__unused assetId
{
    return nil;
}

- (void)controllerWantsToSendDocumentWithTempFileUrl:(NSURL *)__unused tempFileUrl fileName:(NSString *)__unused fileName mimeType:(NSString *)__unused mimeType
{
}

- (void)controllerWantsToSendLocalAudioWithTempFileUrl:(NSURL *)__unused tempFileUrl duration:(NSTimeInterval)__unused duration liveData:(TGLiveUploadActorData *)__unused liveData
{
}

- (void)controllerWantsToSendRemoteVideoWithMedia:(TGVideoMediaAttachment *)__unused media
{
}

- (void)controllerWantsToSendContact:(TGUser *)__unused contactUser
{
}

- (void)controllerWantsToResendMessages:(NSArray *)__unused messageIds
{
}

- (void)controllerWantsToForwardMessages:(NSArray *)__unused messageIds
{
}

- (void)controllerWantsToCreateContact:(int32_t)__unused uid firstName:(NSString *)__unused firstName lastName:(NSString *)__unused lastName phoneNumber:(NSString *)__unused phoneNumber
{
}

- (void)controllerWantsToAddContactToExisting:(int32_t)__unused uid phoneNumber:(NSString *)__unused phoneNumber
{
}

- (void)controllerWantsToApplyLocalization:(NSString *)__unused filePath
{
}

- (void)controllerClearedConversation
{
}

- (void)systemClearedConversation
{
}

- (void)controllerDeletedMessages:(NSArray *)__unused messageIds
{
}

- (void)controllerCanReadHistoryUpdated
{
}

- (void)controllerRequestedNavigationToConversationWithUser:(int32_t)__unused uid
{
}

- (bool)controllerShouldStoreCapturedAssets
{
    return true;
}

- (bool)controllerShouldCacheServerAssets
{
    return true;
}

- (bool)controllerShouldLiveUploadVideo
{
    return true;
}

- (bool)imageDownloadsShouldAutosavePhotos
{
    return false;
}

- (bool)shouldAutomaticallyDownloadPhotos
{
    return false;
}

- (bool)shouldAutomaticallyDownloadAudios
{
    return false;
}

- (bool)allowMessageForwarding
{
    return true;
}

- (bool)allowContactSharing
{
    return true;
}

- (bool)encryptUploads
{
    return false;
}

#pragma mark -

- (void)updateControllerEmptyState
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [self _updateControllerEmptyState:_items.count == 0];
    }];
}

- (void)_updateControllerEmptyState:(bool)empty
{
    TGDispatchOnMainThread(^
    {
        if (_controllerShowingEmptyState != empty)
        {
            _controllerShowingEmptyState = empty;
            
            TGModernConversationController *controller = self.controller;
            
            if (_controllerShowingEmptyState)
                [controller setEmptyListPlaceholder:[self _conversationEmptyListPlaceholder]];
            else
                [controller setEmptyListPlaceholder:nil];
        }
    });
}

- (void)clearCheckedMessages
{
    _checkedMessages.clear();
}

- (void)setMessageChecked:(int32_t)messageId checked:(bool)checked
{
    if (messageId != 0)
    {
        if (checked)
            _checkedMessages.insert(messageId);
        else
            _checkedMessages.erase(messageId);
    }
}

- (int)checkedMessageCount
{
    return _checkedMessages.size();
}

- (NSArray *)checkedMessageIds
{
    NSMutableArray *messageIds = [[NSMutableArray alloc] initWithCapacity:_checkedMessages.size()];
    for (int32_t mid : _checkedMessages)
    {
        [messageIds addObject:[[NSNumber alloc] initWithInt:mid]];
    }
    return messageIds;
}

- (bool)_isMessageChecked:(int32_t)messageId
{
    return _checkedMessages.find(messageId) != _checkedMessages.end();
}

- (void)_setMessageFlags:(int32_t)messageId flags:(int)flags
{
    TGDispatchOnMainThread(^
    {
        _messageFlags[messageId] = _messageFlags[messageId] | flags;
        
        TGModernConversationController *controller = _controller;
        [controller updateMessageAttributes:messageId];
    });
}

- (void)_setMessageViewDate:(int32_t)messageId viewDate:(NSTimeInterval)viewDate
{
    TGDispatchOnMainThread(^
    {
        _messageViewDate[messageId] = viewDate;
        
        TGModernConversationController *controller = _controller;
        [controller updateMessageAttributes:messageId];
    });
}

- (void)_setMessageFlagsAndViewDate:(int32_t)messageId flags:(int)flags viewDate:(NSTimeInterval)viewDate
{
    TGDispatchOnMainThread(^
    {
        _messageFlags[messageId] = _messageFlags[messageId] | flags;
        _messageViewDate[messageId] = viewDate;
        
        TGModernConversationController *controller = _controller;
        [controller updateMessageAttributes:messageId];
    });
}

- (bool)_isSecretMessageViewed:(int32_t)messageId
{
    auto it = _messageFlags.find(messageId);
    if (it != _messageFlags.end())
        return it->second & TGSecretMessageFlagViewed;
    return false;
}

- (bool)_isSecretMessageScreenshotted:(int32_t)messageId
{
    auto it = _messageFlags.find(messageId);
    if (it != _messageFlags.end())
        return it->second & TGSecretMessageFlagScreenshot;
    return false;
}

- (NSTimeInterval)_secretMessageViewDate:(int32_t)messageId
{
    auto it = _messageViewDate.find(messageId);
    if (it != _messageViewDate.end())
        return it->second;
    return 0.0;
}

- (TGModernViewInlineMediaContext *)_inlineMediaContext:(int32_t)messageId
{
    TGModernConversationController *controller = self.controller;
    return [controller inlineMediaContext:messageId];
}

#pragma mark -

- (void)_setTitle:(NSString *)title
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        [controller setTitle:title];
    });
}

- (void)_setAvatarConversationId:(int64_t)conversationId title:(NSString *)title icon:(UIImage *)icon
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        [controller setAvatarConversationId:conversationId title:title icon:icon];
    });
}

- (void)_setAvatarConversationId:(int64_t)conversationId firstName:(NSString *)firstName lastName:(NSString *)lastName
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        [controller setAvatarConversationId:conversationId firstName:firstName lastName:lastName];
    });
}

- (void)_setTitleIcons:(NSArray *)titleIcons
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        [controller setTitleIcons:titleIcons];
    });
}

- (void)_setAvatarUrl:(NSString *)avatarUrl
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        [controller setAvatarUrl:avatarUrl];
    });
}

- (void)_setStatus:(NSString *)status accentColored:(bool)accentColored allowAnimation:(bool)allowAnimation
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        [controller setStatus:status accentColored:accentColored allowAnimation:allowAnimation];
    });
}

- (void)_setTitle:(NSString *)title andStatus:(NSString *)status accentColored:(bool)accentColored allowAnimatioon:(bool)allowAnimation
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        [controller setTitle:title];
        [controller setStatus:status accentColored:accentColored allowAnimation:allowAnimation];
    });
}

- (void)_setTypingStatus:(NSString *)typingStatus activity:(int)activity
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        [controller setTypingStatus:typingStatus activity:activity];
    });
}

#define TG_AUTOMATIC_CONTEXT true

+ (CGContextRef)_createSnapshotContext:(CGSize)screenSize memoryToRelease:(void **)memoryToRelease
{
    if (TG_AUTOMATIC_CONTEXT)
    {
        CGFloat contextScale = TGIsRetina() ? 2.0f : 1.0f;
        UIGraphicsBeginImageContextWithOptions(screenSize, false, contextScale);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(context, screenSize.width / 2.0f, screenSize.height / 2.0f);
        //CGContextScaleCTM(context, -1.0f, -1.0f);
        CGContextRotateCTM(context, (CGFloat)M_PI);
        CGContextTranslateCTM(context, -screenSize.width / 2.0f, -screenSize.height / 2.0f);
        
        return context;
    }
    else
    {
        CGSize contextSize = screenSize;
        if (TGIsRetina())
        {
            contextSize.width *= 2.0f;
            contextSize.height *= 2.0f;
        }
        
        size_t bytesPerRow = 4 * (int)contextSize.width;
        bytesPerRow = (bytesPerRow + 15) & ~15;
        
        static void *memory = NULL;
        if (memoryToRelease != NULL)
        {
            memory = malloc((int)(bytesPerRow * contextSize.height));
            *memoryToRelease = memory;
        }
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        
        CGContextRef context = CGBitmapContextCreate(memory,
                                                     (int)contextSize.width,
                                                     (int)contextSize.height,
                                                     8,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     bitmapInfo);
        CGColorSpaceRelease(colorSpace);
        
        if (TGIsRetina())
            CGContextScaleCTM(context, 2.0, 2.0f);
        
        UIGraphicsPushContext(context);
        
        CGContextTranslateCTM(context, screenSize.width / 2.0f, screenSize.height / 2.0f);
        CGContextRotateCTM(context, (float)M_PI);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, -screenSize.width / 2.0f, -screenSize.height / 2.0f);
        
        return context;
    }
}

+ (CGImageRef)createSnapshotFromContextAndRelease:(CGContextRef)context
{
    if (TG_AUTOMATIC_CONTEXT)
    {
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return CGImageRetain(image.CGImage);
    }
    else
    {
        UIGraphicsPopContext();
        
        CGImageRef contextImageRef = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        
        return contextImageRef;
    }
}

- (void)_createInitialSnapshot
{
#undef TG_TIMESTAMP_DEFINE
#define TG_TIMESTAMP_DEFINE(x)
#undef TG_TIMESTAMP_MEASURE
#define TG_TIMESTAMP_MEASURE(x)
    
    TG_TIMESTAMP_DEFINE(_createInitialSnapshot);
    
    const bool useViews = false;
    
    TGModernConversationController *controller = _controller;
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:controller.interfaceOrientation];
    screenSize.height -= 45;
    
    if (_tempMemory != NULL)
    {
        free(_tempMemory);
        _tempMemory = NULL;
    }
    
    CGContextRef context = NULL;
    
    if (!useViews)
    {
        context = [TGModernConversationCompanion _createSnapshotContext:screenSize memoryToRelease:&_tempMemory];
        
        CGContextSetAllowsFontSubpixelQuantization(context, false);
        CGContextSetShouldSubpixelQuantizeFonts(context, false);
        CGContextSetAllowsFontSubpixelPositioning(context, true);
        CGContextSetShouldSubpixelPositionFonts(context, true);
    }
    
    TG_TIMESTAMP_MEASURE(_createInitialSnapshot);
    
    if (context != NULL || useViews)
    {
        TGModernTemporaryView *backgroundViewContainer = [[TGModernTemporaryView alloc] init];
        backgroundViewContainer.viewStorage = _tempViewStorage;
        backgroundViewContainer.userInteractionEnabled = false;
        
        NSMutableArray *boundItems = [[NSMutableArray alloc] init];
        
        int scrollItemIndex = 0;
        if (_initialPositionedMessageId != 0)
        {
            int index = -1;
            for (TGMessageModernConversationItem *item in _items)
            {
                index++;
                if (item->_message.mid == _initialPositionedMessageId)
                {
                    scrollItemIndex = index;
                    break;
                }
            }
        }
        
        CGFloat topContentInset = controller.controllerInset.top;
        CGFloat contentHeight = 0.0f;
        
        std::vector<TGDecorationViewAttrubutes> visibleDecorationViewAttributes;
        NSArray *visibleItemsAttributes = [TGModernConversationViewLayout layoutAttributesForItems:_items containerWidth:screenSize.width maxHeight:scrollItemIndex == 0 ? screenSize.height : FLT_MAX dateOffset:(int)[[TGTelegramNetworking instance] timeOffset] decorationViewAttributes:&visibleDecorationViewAttributes contentHeight:&contentHeight unreadMessageRange:_unreadMessageRange];
        
        CGFloat contentOffsetY = 0.0f;
        if (scrollItemIndex != 0)
        {
            for (UICollectionViewLayoutAttributes *attributes in visibleItemsAttributes)
            {
                int index = attributes.indexPath.row;
                if (index == scrollItemIndex)
                {
                    switch (_initialScrollPosition)
                    {
                        case TGInitialScrollPositionTop:
                            contentOffsetY = CGRectGetMaxY(attributes.frame) + topContentInset - screenSize.height + [self initialPositioningOverflowForScrollPosition:_initialScrollPosition];
                            break;
                        case TGInitialScrollPositionCenter:
                        {
                            CGFloat visibleHeight = screenSize.height - topContentInset;
                            contentOffsetY = floorf(CGRectGetMidY(attributes.frame) - visibleHeight / 2.0f);
                            break;
                        }
                        case TGInitialScrollPositionBottom:
                            contentOffsetY = attributes.frame.origin.y - [self initialPositioningOverflowForScrollPosition:_initialScrollPosition];
                            break;
                        default:
                            break;
                    }
                    
                    break;
                }
            }
            
            if (contentOffsetY > contentHeight + topContentInset - screenSize.height)
                contentOffsetY = contentHeight + topContentInset - screenSize.height;
            if (contentOffsetY < 0.0f)
                contentOffsetY = 0.0f;
        }
        
        if (contentOffsetY < 0.0f + FLT_EPSILON && _initialPositionedMessageId != 0)
        {
            _initialPositionedMessageId = 0;
            [self setUnreadMessageRange:TGMessageRangeEmpty()];
            
            visibleDecorationViewAttributes.clear();
            visibleItemsAttributes = [TGModernConversationViewLayout layoutAttributesForItems:_items containerWidth:screenSize.width maxHeight:scrollItemIndex == 0 ? screenSize.height : FLT_MAX dateOffset:(int)[[TGTelegramNetworking instance] timeOffset] decorationViewAttributes:&visibleDecorationViewAttributes contentHeight:&contentHeight unreadMessageRange:_unreadMessageRange];
        }
        
        TG_TIMESTAMP_MEASURE(_createInitialSnapshot);
        
        NSMutableIndexSet *visibleIndices = [[NSMutableIndexSet alloc] init];
        
        CGRect visibleBounds = CGRectMake(0.0f, contentOffsetY, screenSize.width, screenSize.height);
        for (UICollectionViewLayoutAttributes *attributes in visibleItemsAttributes)
        {
            int index = attributes.indexPath.row;
            
            TGMessageModernConversationItem *item = _items[index];
            CGRect itemFrame = attributes.frame;
            
            if (!CGRectIntersectsRect(visibleBounds, itemFrame))
                continue;
            
            [self _updateImportantMediaStatusDataInplace:item];
            
            [visibleIndices addIndex:index];
            
            CGFloat currentVerticalPosition = screenSize.height - itemFrame.origin.y - itemFrame.size.height + contentOffsetY;
            
            if (useViews)
            {
                [item.viewModel bindViewToContainer:backgroundViewContainer viewStorage:_tempViewStorage];
                [item.viewModel _offsetBoundViews:CGSizeMake(0.0f, currentVerticalPosition)];
            }
            else
            {
                CGContextTranslateCTM(context, itemFrame.origin.x, currentVerticalPosition);
                [item drawInContext:context];
                CGContextTranslateCTM(context, -itemFrame.origin.x, -currentVerticalPosition);
                
                [item bindSpecialViewsToContainer:backgroundViewContainer viewStorage:_tempViewStorage atItemPosition:CGPointMake(0, currentVerticalPosition)];
            }
            
            [boundItems addObject:item];
        }
        
        for (auto it = visibleDecorationViewAttributes.begin(); it != visibleDecorationViewAttributes.end(); it++)
        {
            if (!CGRectIntersectsRect(visibleBounds, it->frame))
                continue;
        
            CGFloat currentVerticalPosition = screenSize.height - it->frame.origin.y - it->frame.size.height + contentOffsetY;
            
            if (!useViews)
            {
                CGContextTranslateCTM(context, 0.0f, currentVerticalPosition);
                
                if (it->index != INT_MIN)
                {
                    [TGModernDateHeaderView drawDate:it->index forContainerWidth:screenSize.width inContext:context andBindBackgroundToContainer:backgroundViewContainer atPosition:CGPointMake(0, currentVerticalPosition)];
                }
                else
                {
                    [TGModernUnreadHeaderView drawHeaderForContainerWidth:screenSize.width inContext:context andBindBackgroundToContainer:backgroundViewContainer atPosition:CGPointMake(0, currentVerticalPosition)];
                }
                
                CGContextTranslateCTM(context, 0.0f, -currentVerticalPosition);
            }
        }
        
        TG_TIMESTAMP_MEASURE(_createInitialSnapshot);
        
        backgroundViewContainer.boundItems = boundItems;

        CGImageRef contextImageRef = NULL;
        if (useViews)
        {
            static CGImageRef emptyImage = NULL;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                emptyImage = CGImageRetain(TGScaleImageToPixelSize([UIImage imageNamed:@"Transparent.png"], CGSizeMake(2, 2)).CGImage);
            });
            contextImageRef = CGImageRetain(emptyImage);
        }
        else
            contextImageRef = [TGModernConversationCompanion createSnapshotFromContextAndRelease:context];
        
        [controller setInitialSnapshot:contextImageRef backgroundView:backgroundViewContainer viewStorage:nil];
        
        CGImageRelease(contextImageRef);
        
        TG_TIMESTAMP_MEASURE(_createInitialSnapshot);
        
        _tempVisibleItemsIndices = visibleIndices;
    }
    else
        [controller setInitialSnapshot:NULL backgroundView:nil viewStorage:nil];
}

#pragma mark -

- (void)_updateMessageItemsWithData:(NSArray *)__unused items
{
}

- (void)_updateMediaStatusDataForCurrentItems
{
    [self _updateMediaStatusDataForItemsInIndexSet:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _items.count)] animated:false];
}

- (void)_updateMediaStatusDataForItemsWithMessageIdsInSet:(NSMutableSet *)messageIds
{
    if (messageIds.count == 0)
        return;
    
#ifdef DEBUG
    NSAssert([TGModernConversationCompanion isMessageQueue], @"Should be on message queue");
#endif
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    NSInteger index = -1;
    for (TGMessageModernConversationItem *item in _items)
    {
        index++;
        
        if ([messageIds containsObject:@(item->_message.mid)])
            [indexSet addIndex:index];
    }
    
    if (indexSet.count != 0)
        [self _updateMediaStatusDataForItemsInIndexSet:indexSet animated:false];
}

- (void)_updateMediaStatusDataForItemsInIndexSet:(NSIndexSet *)indexSet animated:(bool)animated
{
    if (indexSet.count == 0)
        return;
    
#ifdef DEBUG
    NSAssert([TGModernConversationCompanion isMessageQueue], @"Should be on message queue");
#endif
    
    if (_updateMediaStatusDataImpl == nil)
        _updateMediaStatusDataImpl = (TGMessageModernConversationItem * (*)(id, SEL, TGMessageModernConversationItem *))[self methodForSelector:@selector(_updateMediaStatusData:)];
    SEL selector = @selector(_updateMediaStatusData:);
    
    NSMutableArray *updatedItems = nil;
    NSMutableArray *atIndices = nil;
    
    NSMutableArray *highPriorityDownloads = [[NSMutableArray alloc] init];
    NSMutableArray *regularDownloads = [[NSMutableArray alloc] init];
    NSMutableArray *requestMessages = [[NSMutableArray alloc] init];
    
    if (_updateMediaStatusDataImpl != NULL)
    {
        int indexCount = indexSet.count;
        NSUInteger indices[indexCount];
        [indexSet getIndexes:indices maxCount:indexSet.count inIndexRange:nil];
        
        for (int i = 0; i < indexCount; i++)
        {
            TGMessageModernConversationItem *updatedItem = _updateMediaStatusDataImpl(self, selector, _items[indices[i]]);
            if (updatedItem != nil)
            {
                if (!updatedItem->_mediaAvailabilityStatus)
                {
                    if (!TGMessageRangeIsEmpty(_unreadMessageRange) && TGMessageRangeContains(_unreadMessageRange, updatedItem->_message.mid, (int)updatedItem->_message.date))
                        [highPriorityDownloads addObject:updatedItem->_message];
                    else
                        [regularDownloads addObject:updatedItem->_message];
                }
                
                [_items replaceObjectAtIndex:indices[i] withObject:updatedItem];
                
                if (updatedItems == nil)
                    updatedItems = [[NSMutableArray alloc] init];
                if (atIndices == nil)
                    atIndices = [[NSMutableArray alloc] init];
                
                [updatedItems addObject:updatedItem];
                [atIndices addObject:@(indices[i])];
            }
            
            TGMessageModernConversationItem *messageItem = _items[indices[i]];
            if (messageItem->_message.mid < TGMessageLocalMidBaseline)
            {
                for (TGMediaAttachment *attachment in messageItem->_message.mediaAttachments)
                {
                    if (attachment.type == TGUnsupportedMediaAttachmentType)
                    {
                        [requestMessages addObject:[[NSNumber alloc] initWithInt:messageItem->_message.mid]];
                        break;
                    }
                }
            }
        }
    }
    
    if (updatedItems != nil)
    {
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = _controller;
            int index = -1;
            for (TGMessageModernConversationItem *messageItem in updatedItems)
            {
                index++;
                [controller updateItemAtIndex:[atIndices[index] unsignedIntegerValue] toItem:messageItem];
            }
        });
    }
    
    [self _updateProgressForItemsInIndexSet:indexSet animated:animated];
    
    if (highPriorityDownloads.count != 0 || regularDownloads.count != 0)
    {
        bool automaticallyDownloadPhotos = [self shouldAutomaticallyDownloadPhotos];
        bool automaticallyDownloadAudios = [self shouldAutomaticallyDownloadAudios];
        
        NSMutableArray *downloadList = [[NSMutableArray alloc] init];
        for (id message in [highPriorityDownloads reverseObjectEnumerator])
            [downloadList addObject:message];
        [downloadList addObjectsFromArray:regularDownloads];
    
        for (TGMessage *message in downloadList)
        {
            for (TGMediaAttachment *attachment in message.mediaAttachments)
            {
                switch (attachment.type)
                {
                    case TGImageMediaAttachmentType:
                    {
                        if (automaticallyDownloadPhotos)
                            [self _downloadMediaInMessage:message highPriority:false];
                        
                        break;
                    }
                    case TGAudioMediaAttachmentType:
                    {
                        if (automaticallyDownloadAudios)
                            [self _downloadMediaInMessage:message highPriority:false];
                        
                        break;
                    }
                    default:
                        break;
                }
            }
        }
    }
    
    if (requestMessages.count != 0)
    {
        static NSMutableDictionary *requestedMessageAccounts = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            requestedMessageAccounts = [[NSMutableDictionary alloc] init];
        });
        
        NSMutableSet *messageSet = requestedMessageAccounts[@(TGTelegraphInstance.clientUserId)];
        if (messageSet == nil)
        {
            messageSet = [[NSMutableSet alloc] init];
            requestedMessageAccounts[@(TGTelegraphInstance.clientUserId)] = messageSet;
        }
        
        NSMutableArray *requestMids = [[NSMutableArray alloc] init];
        for (NSNumber *nMid in requestMessages)
        {
            if (![messageSet containsObject:nMid])
            {
                [messageSet addObject:nMid];
                [requestMids addObject:nMid];
            }
        }
        
        if (requestMids.count != 0)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                for (NSNumber *nMid in requestMids)
                {
                    NSString *action = [[NSString alloc] initWithFormat:@"/tg/downloadMessages/(%d)", [nMid intValue]];
                    NSDictionary *options = @{@"mids": @[nMid]};

                    [ActionStageInstance() requestActor:action options:options flags:0 watcher:self];
                    [ActionStageInstance() requestActor:action options:options flags:0 watcher:TGTelegraphInstance];
                }
            }];
        }
    }
}

- (void)_updateProgressForItemsInIndexSet:(NSIndexSet *)__unused indexSet animated:(bool)__unused animated
{
}

- (TGMessageModernConversationItem *)_updateMediaStatusData:(TGMessageModernConversationItem *)__unused item
{
    return nil;
}

- (void)_updateImportantMediaStatusDataInplace:(TGMessageModernConversationItem *)__unused item
{
}

#pragma mark -

- (void)loadMoreMessagesAbove
{
}

- (void)loadMoreMessagesBelow
{
}

- (void)unloadMessagesAbove
{
}

- (void)unloadMessagesBelow
{
}

#pragma mark -

- (void)_performFastScrollDown:(bool)__unused becauseOfSendTextAction
{
}

- (void)_replaceMessages:(NSArray *)newMessages
{
    [_items removeAllObjects];
    
    for (TGMessage *message in newMessages)
    {
        TGMessageModernConversationItem *messageItem = [[TGMessageModernConversationItem alloc] initWithMessage:message context:_viewContext];
        [_items addObject:messageItem];
    }
    
    [self _updateMessageItemsWithData:_items];
    
    NSArray *itemsCopy = [[NSArray alloc] initWithArray:_items];
    
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        [controller replaceItems:itemsCopy];
    });
    
    [self _updateControllerEmptyState:_items.count == 0];
}

- (void)_replaceMessagesWithFastScroll:(NSArray *)newMessages intent:(TGModernConversationAddMessageIntent)intent
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [_items removeAllObjects];
        
        for (TGMessage *message in newMessages)
        {
            TGMessageModernConversationItem *messageItem = [[TGMessageModernConversationItem alloc] initWithMessage:message context:_viewContext];
            [_items addObject:messageItem];
        }
        
        [self _updateMessageItemsWithData:_items];
        
        NSArray *itemsCopy = [[NSArray alloc] initWithArray:_items];
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationInsertItemIntent insertIntent = TGModernConversationInsertItemIntentGeneric;
            switch (intent)
            {
                case TGModernConversationAddMessageIntentSendTextMessage:
                    insertIntent = TGModernConversationInsertItemIntentSendTextMessage;
                    break;
                case TGModernConversationAddMessageIntentSendOtherMessage:
                    insertIntent = TGModernConversationInsertItemIntentSendOtherMessage;
                    break;
                default:
                    break;
            }
            
            TGModernConversationController *controller = _controller;
            if (insertIntent == TGModernConversationInsertItemIntentSendTextMessage)
                [controller setEnableSendButton:true];
            [controller replaceItemsWithFastScroll:itemsCopy intent:insertIntent];
            
            [controller setEnableBelowHistoryRequests:false];
            [controller setEnableAboveHistoryRequests:true];
        });
        
        [self _updateMediaStatusDataForCurrentItems];
        [self _updateControllerEmptyState:_items.count == 0];
    }];
}

- (void)_addMessages:(NSArray *)addedMessages animated:(bool)animated intent:(TGModernConversationAddMessageIntent)intent
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {   
        std::set<int32_t> existingMids;
        for (TGMessageModernConversationItem *messageItem in _items)
        {
            int32_t mid = messageItem->_message.mid;
            existingMids.insert(mid);
        }
        
        TGMutableArrayWithIndices *insertArray = [[TGMutableArrayWithIndices alloc] initWithArray:_items];
        
        for (TGMessage *message in addedMessages)
        {
            if (existingMids.find(message.mid) != existingMids.end())
                continue;
            
            int date = (int)message.date;
            int32_t mid = message.mid;
            bool inserted = false;
            
            int index = -1;
            for (TGMessageModernConversationItem *messageItem in _items)
            {
                index++;
                
                int itemDate = (int)messageItem->_message.date;
                if (itemDate < date || (itemDate == date && messageItem->_message.mid < mid))
                {
                    [insertArray insertObject:[[TGMessageModernConversationItem alloc] initWithMessage:message context:_viewContext] atIndex:index];
                    inserted = true;
                    break;
                }
            }
            if (!inserted)
                [insertArray insertObject:[[TGMessageModernConversationItem alloc] initWithMessage:message context:_viewContext] atIndex:_items.count];
        }
        
        NSIndexSet *insertAtIndices = nil;
        NSArray *insertItems = [insertArray objectsForInsertOperations:&insertAtIndices];
        
        [self _updateMessageItemsWithData:insertItems];
        
        for (TGModernConversationItem *item in insertItems)
        {
            [item sizeForContainerSize:CGSizeMake(_controllerWidthForItemCalculation, 0.0f)];
        }
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = _controller;
            
            TGModernConversationInsertItemIntent insertIntent = TGModernConversationInsertItemIntentGeneric;
            switch (intent)
            {
                case TGModernConversationAddMessageIntentLoadMoreMessagesAbove:
                    insertIntent = TGModernConversationInsertItemIntentLoadMoreMessagesAbove;
                    break;
                case TGModernConversationAddMessageIntentLoadMoreMessagesBelow:
                    insertIntent = TGModernConversationInsertItemIntentLoadMoreMessagesBelow;
                    break;
                case TGModernConversationAddMessageIntentSendTextMessage:
                    insertIntent = TGModernConversationInsertItemIntentSendTextMessage;
                    break;
                case TGModernConversationAddMessageIntentSendOtherMessage:
                    insertIntent = TGModernConversationInsertItemIntentSendOtherMessage;
                    break;
                default:
                    break;
            }
            
            [controller insertItems:insertItems atIndices:insertAtIndices animated:animated intent:insertIntent];
            if (intent == TGModernConversationAddMessageIntentSendTextMessage)
                [controller setEnableSendButton:true];
        });
        
        [self _updateMediaStatusDataForItemsInIndexSet:insertAtIndices animated:false];
        [self _updateControllerEmptyState:_items.count == 0];
    }];
}

- (void)_deleteMessages:(NSArray *)messageIds animated:(bool)animated
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        std::set<int32_t> removedMids;
        for (NSNumber *nMid in messageIds)
        {
            removedMids.insert([nMid intValue]);
        }
        
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        int index = -1;
        for (TGMessageModernConversationItem *item in _items)
        {
            index++;
            
            if (removedMids.find(item->_message.mid) != removedMids.end())
            {
                [indexSet addIndex:index];
            }
        }
        
        [_items removeObjectsAtIndexes:indexSet];
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = _controller;
            [controller deleteItemsAtIndices:indexSet animated:animated];
            
            if (!_checkedMessages.empty())
            {
                bool haveChanges = false;
                for (NSNumber *nMid in messageIds)
                {
                    if (_checkedMessages.find([nMid intValue]) != _checkedMessages.end())
                    {
                        _checkedMessages.erase([nMid intValue]);
                        haveChanges = true;
                    }
                }
                
                if (haveChanges)
                    [controller updateCheckedMessages];
            }
        });
        
        [self _updateControllerEmptyState:_items.count == 0];
    }];
}

- (void)_updateMessagesRead:(NSArray *)messageIds
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        std::set<int32_t> readMids;
        for (NSNumber *nMid in messageIds)
        {
            readMids.insert([nMid intValue]);
        }
        
        NSMutableArray *itemUpdates = [[NSMutableArray alloc] init];
        
        int count = _items.count;
        for (int index = 0; index < count; index++)
        {
            TGMessageModernConversationItem *messageItem = _items[index];
            if (readMids.find(messageItem->_message.mid) != readMids.end())
            {
                TGMessageModernConversationItem *updatedItem = [messageItem deepCopy];
                updatedItem->_message.unread = false;
                [_items replaceObjectAtIndex:index withObject:updatedItem];
                
                [itemUpdates addObject:[[NSNumber alloc] initWithInt:index]];
                [itemUpdates addObject:updatedItem];
            }
        }
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = _controller;
            
            int updatedItemsCount = itemUpdates.count;
            for (int i = 0; i < updatedItemsCount; i += 2)
            {
                [controller updateItemAtIndex:[itemUpdates[i + 0] intValue] toItem:itemUpdates[i + 1]];
            }
        });
    }];
}

- (void)_updateMessageDelivered:(int32_t)previousMid
{
    [self _updateMessageDelivered:previousMid mid:0 date:0 message:nil];
}

- (void)_updateMessageDelivered:(int32_t)previousMid mid:(int32_t)mid date:(int32_t)date message:(TGMessage *)message
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        int index = -1;
        for (TGMessageModernConversationItem *messageItem in _items)
        {
            index++;
            
            if (messageItem->_message.mid == previousMid)
            {
                TGMessageModernConversationItem *updatedItem = [messageItem deepCopy];
                
                TGMessage *updatedMessage = updatedItem->_message;
                if (message != nil)
                    updatedMessage.mediaAttachments = message.mediaAttachments;
                
                if (mid != 0)
                    updatedMessage.mid = mid;
                if (date != 0)
                    updatedItem->_additionalDate = date;
                updatedMessage.deliveryState = TGMessageDeliveryStateDelivered;
                
                updatedItem->_message = updatedMessage;
                
                TGMessageModernConversationItem *statusItem = [self _updateMediaStatusData:updatedItem];
                bool updateMediaAvailability = false;
                if (statusItem != nil)
                {
                    updatedItem = statusItem;
                    updateMediaAvailability = true;
                }
                
                [_items replaceObjectAtIndex:index withObject:updatedItem];
                
                if (messageItem->_message.deliveryState != TGMessageDeliveryStateDelivered && TGAppDelegateInstance.soundEnabled)
                    [TGAppDelegateInstance playSound:@"sent.caf" vibrate:false];
                
                TGDispatchOnMainThread(^
                {
                    if (mid != 0 && _mediaHiddenMessageId == previousMid)
                        _mediaHiddenMessageId = mid;
                    
                    TGModernConversationController *controller = _controller;
                    [controller updateItemAtIndex:index toItem:updatedItem];
                });
                
                break;
            }
        }
        
        TGDispatchOnMainThread(^
        {
            if (mid != 0 && _checkedMessages.find(previousMid) != _checkedMessages.end())
            {
                _checkedMessages.erase(previousMid);
                _checkedMessages.insert(mid);
            }
        });
    }];
}

- (void)_updateMessageDeliveryFailed:(int32_t)previousMid
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        int index = -1;
        for (TGMessageModernConversationItem *messageItem in _items)
        {
            index++;
            
            if (messageItem->_message.mid == previousMid)
            {
                TGMessageModernConversationItem *updatedItem = [messageItem deepCopy];
                updatedItem->_message.deliveryState = TGMessageDeliveryStateFailed;
                [_items replaceObjectAtIndex:index withObject:updatedItem];
                
                TGDispatchOnMainThread(^
                {
                    TGModernConversationController *controller = _controller;
                    [controller updateItemAtIndex:index toItem:updatedItem];
                });
                
                break;
            }
        }
    }];
}

- (void)_downloadMediaInMessage:(TGMessage *)__unused message highPriority:(bool)__unused highPriority
{
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"messageSelectionRequested"])
    {   
        TGModernConversationController *controller = _controller;
        [controller highlightAndShowActionsMenuForMessage:[options[@"mid"] int32Value]];
    }
    else if ([action isEqualToString:@"messageSelectionChanged"])
    {
        int32_t mid = [options[@"mid"] int32Value];
        if (mid != 0)
        {
            if ([options[@"selected"] boolValue])
                _checkedMessages.insert(mid);
            else
                _checkedMessages.erase(mid);
            TGModernConversationController *controller = _controller;
            [controller updateCheckedMessages];
        }
    }
    else if ([action isEqualToString:@"openLinkWithOptionsRequested"])
    {
        TGModernConversationController *controller = _controller;
        [controller showActionsMenuForLink:options[@"url"]];
    }
    else if ([action isEqualToString:@"openLinkRequested"])
    {
        if ([options[@"url"] hasPrefix:@"tel:"])
        {
            NSString *rawPhone = [options[@"url"] substringFromIndex:4];
            rawPhone = [TGPhoneUtils cleanInternationalPhone:rawPhone forceInternational:false];
            [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:[@"tel:" stringByAppendingString:rawPhone]]];
        }
        else
            [(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:options[@"url"]] forceNative:true];
    }
    else if ([action isEqualToString:@"openMediaRequested"])
    {
        TGModernConversationController *controller = _controller;
        [controller openMediaFromMessage:[options[@"mid"] intValue] instant:[options[@"instant"] boolValue]];
    }
    else if ([action isEqualToString:@"closeMediaRequested"])
    {
        TGModernConversationController *controller = _controller;
        [controller closeMediaFromMessage:[options[@"mid"] intValue] instant:[options[@"instant"] boolValue]];
    }
    else if ([action isEqualToString:@"showUnsentMessageMenu"])
    {
        TGModernConversationController *controller = _controller;
        [controller showActionsMenuForUnsentMessage:[options[@"mid"] intValue]];
    }
}

- (void)actionStageResourceDispatched:(NSString *)__unused path resource:(id)__unused resource arguments:(id)__unused arguments
{
}

- (void)actorMessageReceived:(NSString *)__unused path messageType:(NSString *)__unused messageType message:(id)__unused message
{
}

- (void)actorCompleted:(int)__unused status path:(NSString *)__unused path result:(id)__unused result
{
    if ([path hasPrefix:@"/tg/downloadMessages/"])
    {
        if (status == ASStatusSuccess)
        {
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
                NSMutableArray *replacedItems = [[NSMutableArray alloc] init];
                
                [result[@"messagesByConversation"] enumerateKeysAndObjectsUsingBlock:^(__unused id key, NSArray *updatedMessages, __unused BOOL *stop)
                {
                    std::map<int, TGMessage *> updatedMessagesWithMids;
                    for (TGMessage *message in updatedMessages)
                    {
                        updatedMessagesWithMids[message.mid] = message;
                    }
                    
                    int index = -1;
                    for (TGMessageModernConversationItem *messageItem in _items)
                    {
                        index++;
                        auto it = updatedMessagesWithMids.find(messageItem->_message.mid);
                        if (it != updatedMessagesWithMids.end())
                        {
                            TGMessageModernConversationItem *updatedItem = [[TGMessageModernConversationItem alloc] initWithMessage:it->second context:_viewContext];
                            
                            [indexSet addIndex:index];
                            [replacedItems addObject:updatedItem];
                        }
                    }
                }];
                
                [_items replaceObjectsAtIndexes:indexSet withObjects:replacedItems];
                
                TGDispatchOnMainThread(^
                {
                    TGModernConversationController *controller = self.controller;
                    [controller replaceItems:replacedItems atIndices:indexSet];
                });
                
                [self _updateMediaStatusDataForItemsInIndexSet:indexSet animated:false];
            }];
        }
    }
}

- (void)updateMediaAccessTimeForMessageId:(int32_t)__unused messageId
{
}

- (id)acquireAudioRecordingActivityHolder
{
    return nil;
}

- (id)acquireLocationPickingActivityHolder
{
    return nil;
}

- (void)serviceNotificationsForMessageIds:(NSArray *)__unused messageIds
{
}

- (void)markMessagesAsViewed:(NSArray *)__unused messageIds
{
}

@end
