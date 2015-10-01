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

#import "TGDownloadMessagesSignal.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGInstagramMediaIdSignal.h"

#import "TGProgressWindow.h"

#import "TGGenericPeerPlaylistSignals.h"

#import "TGGenericModernConversationCompanion.h"

#import "TGChannelManagementSignals.h"

#import <libkern/OSAtomic.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 // iOS 6.0 or later
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else                                         // iOS 5.X or earlier
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif

static OSSpinLock _messagesViewedLock = 0;
static NSMutableDictionary *messagesViewedByPeerId() {
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

static NSArray *filterUnseenMessageIds(int64_t peerId, NSArray *messageIds) {
    NSMutableArray *result = nil;
    OSSpinLockLock(&_messagesViewedLock);
    NSMutableSet *set = messagesViewedByPeerId()[@(peerId)];
    for (NSNumber *nMessageId in messageIds) {
        if (![set containsObject:nMessageId]) {
            if (result == nil) {
                result = [[NSMutableArray alloc] init];
            }
            [result addObject:nMessageId];
        }
    }
    OSSpinLockUnlock(&_messagesViewedLock);
    return result;
}

static void markMessagesAsSeen(int64_t peerId, NSArray *messageIds) {
    OSSpinLockLock(&_messagesViewedLock);
    NSMutableSet *set = messagesViewedByPeerId()[@(peerId)];
    if (set == nil) {
        set = [[NSMutableSet alloc] init];
    }
    [set addObjectsFromArray:messageIds];
    OSSpinLockUnlock(&_messagesViewedLock);
}

static SQueue *_messageQueue = nil;

static SQueue *messageQueue()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _messageQueue = [[SQueue alloc] init];
    });
    
    return _messageQueue;
}

static bool isMessageQueue()
{
    return [messageQueue() isCurrentQueue];
}

static void dispatchOnMessageQueue(dispatch_block_t block, bool synchronous)
{
    if (synchronous) {
        [messageQueue() dispatchSync:block];
    } else {
        [messageQueue() dispatch:block];
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
    
    NSMutableDictionary *_downloadingMessages;
    NSMutableDictionary *_downloadedMessages;
    bool _allowMessageDownloads;
    
    std::set<int32_t> _messageViewsRequested;
    NSMutableArray *_messageViewsRequestedBuffer;
    STimer *_messageViewsRequestedBufferTimer;
    
    SDisposableSet *_messageViewsDisposable;
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
        viewContext.viewStatusEnabled = [self allowMessageForwarding];
        viewContext.playingAudioMessageId = [[[[TGTelegraphInstance musicPlayer] playingStatus] map:^id(TGMusicPlayerStatus *status)
        {
            if (status.item == nil)
                return nil;
            else
            {
                int32_t mid = 0;
                if ([(NSObject *)status.item.key respondsToSelector:@selector(intValue)])
                    mid = [(NSNumber *)status.item.key intValue];
                int32_t paused = status.paused;
                int64_t packed = (((int64_t)mid) << 32) | ((int64_t)paused);
                return @(packed);
            }
        }] deliverOn:[SQueue mainQueue]];
        
        __weak TGModernViewContext *weakViewContext = viewContext;
        viewContext.playAudioMessageId = ^(int32_t mid)
        {
            TGModernViewContext *strongViewContext = weakViewContext;
            if (strongViewContext != nil) {
                TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:mid peerId:strongViewContext.conversation.conversationId];
                if (message != nil)
                {
                    [TGTelegraphInstance.musicPlayer setPlaylist:[TGGenericPeerPlaylistSignals playlistForPeerId:message.cid important:TGMessageSortKeySpace(message.sortKey) == TGMessageSpaceImportant atMessageId:message.mid] initialItemKey:@(message.mid)];
                }
            }
        };
        viewContext.pauseAudioMessage = ^
        {
            [[TGTelegraphInstance musicPlayer] controlPause];
        };
        viewContext.resumeAudioMessage = ^
        {
            [[TGTelegraphInstance musicPlayer] controlPlay];
        };
        _viewContext = viewContext;
        _downloadingMessages = [[NSMutableDictionary alloc] init];
        _downloadedMessages = [[NSMutableDictionary alloc] init];
        
        _messageViewsDisposable = [[SDisposableSet alloc] init];
        
        __weak TGModernConversationCompanion *weakSelf = self;
        _messageViewsRequestedBufferTimer = [[STimer alloc] initWithTimeout:0.5 repeat:false completion:^{
            __strong TGModernConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf consumeRequestedMessages];
            }
        } queue:[TGModernConversationCompanion messageQueue]];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [_messageViewsDisposable dispose];
    
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
    
    NSDictionary *downloadingMessages = _downloadingMessages;
    STimer *messageViewsRequestedBufferTimer = _messageViewsRequestedBufferTimer;
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [messageViewsRequestedBufferTimer invalidate];
        
        [downloadingMessages enumerateKeysAndObjectsUsingBlock:^(__unused id key, id<SDisposable> disposable, __unused BOOL *stop)
        {
            [disposable dispose];
        }];
    }];
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

+ (SQueue *)messageQueue
{
    return messageQueue();
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
    TGModernConversationController *controller = self.controller;
    [controller setConversationHeader:[self _conversationHeader]];
    [self _updateInputPanel];
}

- (void)subscribeToUpdates
{
    [ActionStageInstance() watchForPath:@"/webpages" watcher:self];
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
            [controller setInitialSnapshot:NULL backgroundView:nil viewStorage:_tempViewStorage topEdge:0.0f];
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
            [controller setInitialSnapshot:NULL backgroundView:nil viewStorage:_tempViewStorage topEdge:0.0f];
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
            
            _allowMessageDownloads = true;
            [self _itemsUpdated];
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
    
    return placeholder;
}

- (TGModernConversationInputPanel *)_conversationGenericInputPanel
{
    return nil;
}

- (TGModernConversationInputPanel *)_conversationEmptyListInputPanel
{
    return nil;
}

- (void)_updateInputPanel
{
    TGModernConversationController *controller = self.controller;
    if (_controllerShowingEmptyState)
        [controller setCustomInputPanel:[self _conversationEmptyListInputPanel]];
    else
        [controller setCustomInputPanel:[self _conversationGenericInputPanel]];
}

- (UIView *)_conversationHeader
{
    return nil;
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

- (void)controllerDidCancelTypingActivity
{
}

- (void)controllerDidChangeInputText:(NSString *)__unused inputText
{
}

- (void)controllerWantsToSendTextMessage:(NSString *)__unused text asReplyToMessageId:(int32_t)__unused replyMessageId withAttachedMessages:(NSArray *)__unused withAttachedMessages disableLinkPreviews:(bool)__unused disableLinkPreviews
{
}

- (void)controllerWantsToSendMapWithLatitude:(double)__unused latitude longitude:(double)__unused longitude venue:(TGVenueAttachment *)__unused venue asReplyToMessageId:(int32_t)__unused replyMessageId
{
}

- (NSURL *)fileUrlForDocumentMedia:(TGDocumentMediaAttachment *)__unused documentMedia
{
    return nil;
}

- (NSDictionary *)imageDescriptionFromImage:(UIImage *)__unused image caption:(NSString *)__unused caption optionalAssetUrl:(NSString *)__unused assetUrl
{
    return nil;
}

- (NSDictionary *)imageDescriptionFromBingSearchResult:(TGBingSearchResultItem *)__unused item caption:(NSString *)__unused caption
{
    return nil;
}

- (NSDictionary *)documentDescriptionFromGiphySearchResult:(TGGiphySearchResultItem *)__unused item
{
    return nil;
}

- (NSDictionary *)documentDescriptionFromICloudDriveItem:(TGICloudItem *)__unused item
{
    return nil;
}

- (NSDictionary *)documentDescriptionFromDropboxItem:(TGDropboxItem *)__unused item
{
    return nil;
}

- (NSDictionary *)documentDescriptionFromGoogleDriveItem:(TGGoogleDriveItem *)__unused item
{
    return nil;
}

- (NSDictionary *)imageDescriptionFromInternalSearchImageResult:(TGWebSearchInternalImageResult *)__unused item caption:(NSString *)__unused caption
{
    return nil;
}

- (NSDictionary *)documentDescriptionFromInternalSearchResult:(TGWebSearchInternalGifResult *)__unused item
{
    return nil;
}

- (NSDictionary *)documentDescriptionFromFileAtTempUrl:(NSURL *)__unused url fileName:(NSString *)__unused fileName mimeType:(NSString *)__unused mimeType
{
    return nil;
}

- (void)controllerWantsToSendImagesWithDescriptions:(NSArray *)__unused imageDescriptions asReplyToMessageId:(int32_t)__unused replyMessageId
{
}

- (void)controllerWantsToSendLocalVideoWithTempFilePath:(NSString *)__unused tempVideoFilePath fileSize:(int32_t)__unused fileSize previewImage:(UIImage *)__unused previewImage duration:(NSTimeInterval)__unused duration dimensions:(CGSize)__unused dimenstions caption:(NSString *)__unused caption assetUrl:(NSString *)__unused assetUrl liveUploadData:(TGLiveUploadActorData *)__unused liveUploadData asReplyToMessageId:(int32_t)__unused replyMessageId
{
}

- (TGVideoMediaAttachment *)serverCachedAssetWithId:(NSString *)__unused assetId
{
    return nil;
}

- (void)controllerWantsToSendDocumentWithTempFileUrl:(NSURL *)__unused tempFileUrl fileName:(NSString *)__unused fileName mimeType:(NSString *)__unused mimeType asReplyToMessageId:(int32_t)__unused replyMessageId
{
}

- (void)controllerWantsToSendDocumentsWithDescriptions:(NSArray *)__unused descriptions asReplyToMessageId:(int32_t)__unused replyMessageId
{
}

- (void)controllerWantsToSendRemoteDocument:(TGDocumentMediaAttachment *)__unused document asReplyToMessageId:(int32_t)__unused replyMessageId
{
}

- (void)controllerWantsToSendCloudDocumentsWithDescriptions:(NSArray *)__unused descriptions asReplyToMessageId:(int32_t)__unused replyMessageId
{
}

- (void)controllerWantsToSendLocalAudioWithDataItem:(TGDataItem *)__unused dataItem duration:(NSTimeInterval)__unused duration liveData:(TGLiveUploadActorData *)__unused liveData asReplyToMessageId:(int32_t)__unused replyMessageId
{
}

- (void)controllerWantsToSendRemoteVideoWithMedia:(TGVideoMediaAttachment *)__unused media asReplyToMessageId:(int32_t)__unused replyMessageId
{
}

- (void)controllerWantsToSendContact:(TGUser *)__unused contactUser asReplyToMessageId:(int32_t)__unused replyMessageId
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

- (void)controllerDeletedMessages:(NSArray *)__unused messageIds completion:(void (^)())__unused completion
{
}

- (void)controllerCanReadHistoryUpdated
{
}

- (void)controllerCanRegroupUnreadIncomingMessages
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

- (bool)allowReplies
{
    return false;
}

- (bool)allowContactSharing
{
    return true;
}

- (bool)allowVenueSharing
{
    return true;
}

- (bool)allowCaptionedMedia
{
    return true;
}

- (bool)encryptUploads
{
    return false;
}

- (NSDictionary *)userActivityData
{
    return nil;
}

- (TGApplicationFeaturePeerType)applicationFeaturePeerType
{
    return TGApplicationFeaturePeerPrivate;
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

            if (_controllerShowingEmptyState)
                [controller setCustomInputPanel:[self _conversationEmptyListInputPanel]];
            else
                [controller setCustomInputPanel:[self _conversationGenericInputPanel]];
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
    return (int)_checkedMessages.size();
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

- (void)_setStatus:(NSString *)status accentColored:(bool)accentColored allowAnimation:(bool)allowAnimation toggleMode:(TGModernConversationControllerTitleToggle)toggleMode
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        [controller setStatus:status accentColored:accentColored allowAnimation:allowAnimation toggleMode:toggleMode];
    });
}

- (void)_setTitle:(NSString *)title andStatus:(NSString *)status accentColored:(bool)accentColored allowAnimatioon:(bool)allowAnimation toggleMode:(TGModernConversationControllerTitleToggle)toggleMode
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        [controller setTitle:title];
        [controller setStatus:status accentColored:accentColored allowAnimation:allowAnimation toggleMode:toggleMode];
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
    if (![self _controllerShouldHideInputTextByDefault] || [controller customInputPanel] != nil) {
        screenSize.height -= 45;
    }
    
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
            for (TGMessageModernConversationItem *item in [controller _currentItems])
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
        NSArray *visibleItemsAttributes = [TGModernConversationViewLayout layoutAttributesForItems:[controller _currentItems] containerWidth:screenSize.width maxHeight:scrollItemIndex == 0 ? screenSize.height : FLT_MAX dateOffset:(int)[[TGTelegramNetworking instance] timeOffset] decorationViewAttributes:&visibleDecorationViewAttributes contentHeight:&contentHeight unreadMessageRange:_unreadMessageRange];
        
        CGFloat contentOffsetY = 0.0f;
        if (scrollItemIndex != 0)
        {
            for (UICollectionViewLayoutAttributes *attributes in visibleItemsAttributes)
            {
                int index = (int)attributes.indexPath.row;
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
                            contentOffsetY = CGFloor(CGRectGetMidY(attributes.frame) - visibleHeight / 2.0f);
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
            visibleItemsAttributes = [TGModernConversationViewLayout layoutAttributesForItems:[controller _currentItems] containerWidth:screenSize.width maxHeight:scrollItemIndex == 0 ? screenSize.height : FLT_MAX dateOffset:(int)[[TGTelegramNetworking instance] timeOffset] decorationViewAttributes:&visibleDecorationViewAttributes contentHeight:&contentHeight unreadMessageRange:_unreadMessageRange];
        }
        
        TG_TIMESTAMP_MEASURE(_createInitialSnapshot);
        
        CGFloat topEdge = 0.0f;
        
        NSMutableIndexSet *visibleIndices = [[NSMutableIndexSet alloc] init];
        
        CGRect visibleBounds = CGRectMake(0.0f, contentOffsetY, screenSize.width, screenSize.height);
        for (UICollectionViewLayoutAttributes *attributes in visibleItemsAttributes)
        {
            int index = (int)attributes.indexPath.row;
            
            TGMessageModernConversationItem *item = [controller _currentItems][index];
            CGRect itemFrame = attributes.frame;
            
            if (!CGRectIntersectsRect(visibleBounds, itemFrame))
                continue;
            
            [self _updateImportantMediaStatusDataInplace:item];
            
            [visibleIndices addIndex:index];
            
            CGFloat currentVerticalPosition = screenSize.height - itemFrame.origin.y - itemFrame.size.height + contentOffsetY;
            topEdge = MAX(topEdge, screenSize.height - currentVerticalPosition);
            
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
            topEdge = MAX(topEdge, screenSize.height - currentVerticalPosition);
            
            if (it->index == INT_MIN && !useViews)
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
            else if (it->index != INT_MIN)
            {
                TGModernDateHeaderView *headerView = [[TGModernDateHeaderView alloc] initWithFrame:CGRectMake(0.0f, currentVerticalPosition, screenSize.width, it->frame.size.height)];
                headerView.transform = CGAffineTransformMakeRotation((CGFloat)(M_PI));
                [headerView setDate:it->index];
                [backgroundViewContainer addSubview:headerView];
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
        
        [controller setInitialSnapshot:contextImageRef backgroundView:backgroundViewContainer viewStorage:nil topEdge:topEdge + 45.0f];
        
        CGImageRelease(contextImageRef);
        
        TG_TIMESTAMP_MEASURE(_createInitialSnapshot);
        
        _tempVisibleItemsIndices = visibleIndices;
    }
    else
        [controller setInitialSnapshot:NULL backgroundView:nil viewStorage:nil topEdge:0.0f];
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
        int indexCount = (int)indexSet.count;
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
                
                [(NSMutableArray *)_items replaceObjectAtIndex:indices[i] withObject:updatedItem];
                
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
        [self _itemsUpdated];
        
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
    [self _replaceMessages:newMessages atMessageId:0 expandFrom:0 jump:false];
}

- (void)_replaceMessages:(NSArray *)newMessages atMessageId:(int32_t)atMessageId expandFrom:(int32_t)expandMessageId jump:(bool)jump
{
    [(NSMutableArray *)_items removeAllObjects];
    
    for (TGMessage *message in newMessages)
    {
        TGMessageModernConversationItem *messageItem = [[TGMessageModernConversationItem alloc] initWithMessage:message context:_viewContext];
        [(NSMutableArray *)_items addObject:messageItem];
    }
    
    [self _updateMessageItemsWithData:_items];
    [self _itemsUpdated];
    
    NSArray *itemsCopy = [[NSArray alloc] initWithArray:_items];
    
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = _controller;
        if (atMessageId != 0) {
            [controller replaceItems:itemsCopy positionAtMessageId:atMessageId expandAt:expandMessageId jump:jump];
        } else {
            [controller replaceItems:itemsCopy];
        }
    });
    
    [self _updateControllerEmptyState:_items.count == 0];
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        [self _updateMediaStatusDataForCurrentItems];
    }];
}

- (void)_replaceMessagesWithFastScroll:(NSArray *)newMessages intent:(TGModernConversationAddMessageIntent)intent scrollToMessageId:(int32_t)scrollToMessageId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [(NSMutableArray *)_items removeAllObjects];
        
        for (TGMessage *message in newMessages)
        {
            TGMessageModernConversationItem *messageItem = [[TGMessageModernConversationItem alloc] initWithMessage:message context:_viewContext];
            [(NSMutableArray *)_items addObject:messageItem];
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
            [controller replaceItemsWithFastScroll:itemsCopy intent:insertIntent scrollToMessageId:scrollToMessageId scrollBackMessageId:scrollBackMessageId animated:animated];
            
            [controller setEnableBelowHistoryRequests:false];
            [controller setEnableAboveHistoryRequests:true];
        });
        
        [self _updateMediaStatusDataForCurrentItems];
        [self _updateControllerEmptyState:_items.count == 0];
        [self _itemsUpdated];
    }];
}

- (void)_addMessages:(NSArray *)addedMessages animated:(bool)animated intent:(TGModernConversationAddMessageIntent)intent
{
    [self _addMessages:addedMessages animated:animated intent:intent deletedMessageIds:nil];
}

- (void)_addMessages:(NSArray *)addedMessages animated:(bool)animated intent:(TGModernConversationAddMessageIntent)intent deletedMessageIds:(NSArray *)deletedMessageIds
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        std::set<int32_t> removedMids;
        for (NSNumber *nMid in deletedMessageIds)
        {
            removedMids.insert([nMid intValue]);
        }
        
        NSMutableIndexSet *deletedIndexSet = [[NSMutableIndexSet alloc] init];
        int index = -1;
        for (TGMessageModernConversationItem *item in _items)
        {
            index++;
            
            if (removedMids.find(item->_message.mid) != removedMids.end())
            {
                [deletedIndexSet addIndex:index];
            }
        }
        
        [(NSMutableArray *)_items removeObjectsAtIndexes:deletedIndexSet];
        
        std::set<int32_t> existingMids;
        for (TGMessageModernConversationItem *messageItem in _items)
        {
            int32_t mid = messageItem->_message.mid;
            existingMids.insert(mid);
        }
        
        TGMutableArrayWithIndices *insertArray = [[TGMutableArrayWithIndices alloc] initWithArray:(NSMutableArray *)_items];
        
        for (TGMessage *message in addedMessages)
        {
            if (existingMids.find(message.mid) != existingMids.end())
                continue;
            existingMids.insert(message.mid);
            
            int date = (int)message.date;
            int32_t mid = message.mid;
            bool inserted = false;
            
            int index = -1;
            for (TGMessageModernConversationItem *messageItem in _items)
            {
                index++;
                
                int itemDate = (int)messageItem->_message.date;
                int32_t itemMid = messageItem->_message.mid;
                bool passes = false;
                if (itemMid < 0 && mid < 0) {
                    passes = itemMid > mid;
                } else {
                    passes = itemMid < mid;
                }
                if (itemDate < date || (itemDate == date && passes))
                {
                    [insertArray insertObject:[[TGMessageModernConversationItem alloc] initWithMessage:message context:_viewContext] atIndex:index];
                    inserted = true;
                    break;
                }
            }
            if (!inserted) {
                [insertArray insertObject:[[TGMessageModernConversationItem alloc] initWithMessage:message context:_viewContext] atIndex:_items.count];
            }
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
            
            [controller insertItems:insertItems atIndices:insertAtIndices animated:animated intent:insertIntent removeAtIndices:deletedIndexSet];
            if (intent == TGModernConversationAddMessageIntentSendTextMessage)
                [controller setEnableSendButton:true];
        });
        
        [self _updateMediaStatusDataForItemsInIndexSet:insertAtIndices animated:false];
        [self _updateControllerEmptyState:_items.count == 0];
        [self _itemsUpdated];
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
        
        [(NSMutableArray *)_items removeObjectsAtIndexes:indexSet];
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = _controller;
            [controller _deleteItemsAtIndices:indexSet animated:animated animationFactor:1.0f];
            
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
        [self _itemsUpdated];
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
        
        int count = (int)_items.count;
        for (int index = 0; index < count; index++)
        {
            TGMessageModernConversationItem *messageItem = _items[index];
            if (readMids.find(messageItem->_message.mid) != readMids.end())
            {
                TGMessageModernConversationItem *updatedItem = [messageItem deepCopy];
                updatedItem->_message.unread = false;
                [(NSMutableArray *)_items replaceObjectAtIndex:index withObject:updatedItem];
                
                [itemUpdates addObject:[[NSNumber alloc] initWithInt:index]];
                [itemUpdates addObject:updatedItem];
            }
        }
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = _controller;
            
            int updatedItemsCount = (int)itemUpdates.count;
            for (int i = 0; i < updatedItemsCount; i += 2)
            {
                [controller updateItemAtIndex:[itemUpdates[i + 0] intValue] toItem:itemUpdates[i + 1]];
            }
        });
    }];
}

- (void)_updateMessageDelivered:(int32_t)previousMid
{
    [self _updateMessageDelivered:previousMid mid:0 date:0 message:nil unread:nil];
}

- (void)_updateMessageDelivered:(int32_t)previousMid mid:(int32_t)mid date:(int32_t)date message:(TGMessage *)message unread:(NSNumber *)unread
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
                if (unread != nil)
                    updatedMessage.unread = [unread boolValue];
                updatedMessage.deliveryState = TGMessageDeliveryStateDelivered;
                
                updatedItem->_message = updatedMessage;
                
                TGMessageModernConversationItem *statusItem = [self _updateMediaStatusData:updatedItem];
                bool updateMediaAvailability = false;
                if (statusItem != nil)
                {
                    updatedItem = statusItem;
                    updateMediaAvailability = true;
                }
                
                if (messageItem->_message.deliveryState != TGMessageDeliveryStateDelivered && TGAppDelegateInstance.soundEnabled)
                    [TGAppDelegateInstance playSound:@"sent.caf" vibrate:false];
                
                [(NSMutableArray *)_items replaceObjectAtIndex:index withObject:updatedItem];
                
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
        
        [self _itemsUpdated];
        
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
                [(NSMutableArray *)_items replaceObjectAtIndex:index withObject:updatedItem];
                
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

- (void)_updateMessages:(NSDictionary *)messagesByIds
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        NSMutableArray *itemUpdates = [[NSMutableArray alloc] init];

        NSUInteger count = _items.count;
        for (NSUInteger index = 0; index < count; index++)
        {
            TGMessageModernConversationItem *messageItem = _items[index];

            TGMessage *previousMessage = messageItem->_message;
            TGMessage *updatedMessage = [messagesByIds[@(previousMessage.mid)] copy];
            if (updatedMessage != nil && ![updatedMessage isEqual:previousMessage])
            {
                updatedMessage.date = previousMessage.date;
                TGMessageModernConversationItem *updatedItem = [messageItem deepCopy];
                updatedItem->_message = updatedMessage;
                [(NSMutableArray *)_items replaceObjectAtIndex:index withObject:updatedItem];

                [itemUpdates addObject:[[NSNumber alloc] initWithInt:(int)index]];
                [itemUpdates addObject:updatedItem];
            }
        }

        if (itemUpdates.count != 0)
        {
            TGDispatchOnMainThread(^
            {
                TGModernConversationController *controller = _controller;
                
                int updatedItemsCount = (int)itemUpdates.count;
                for (int i = 0; i < updatedItemsCount; i += 2)
                {
                    [controller updateItemAtIndex:[itemUpdates[i + 0] intValue] toItem:itemUpdates[i + 1]];
                }
            });
        }
    }];
}

#pragma mark -

- (NSString *)instagramShortcodeFromText:(NSString *)text
{
    if ([text hasPrefix:@"http://instagram.com/p/"] || [text hasPrefix:@"https://instagram.com/p/"])
    {
        NSString *prefix = [text hasPrefix:@"http://instagram.com/p/"] ? @"http://instagram.com/p/" : @"https://instagram.com/p/";
        int length = (int)text.length;
        bool badCharacters = false;
        int slashCount = 0;
        for (int i = (int)prefix.length; i < length; i++)
        {
            unichar c = [text characterAtIndex:i];
            if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' || c == '/' || c == '-')
            {
                if (c == '/')
                {
                    if (slashCount >= 2)
                    {
                        badCharacters = true;
                        break;
                    }
                    slashCount++;
                }
            }
            else
            {
                badCharacters = true;
                break;
            }
        }
        
        if (!badCharacters)
        {
            NSString *shortcode = [text substringFromIndex:prefix.length];
            if ([shortcode hasSuffix:@"/"])
                shortcode = [shortcode substringToIndex:shortcode.length - 1];
            
            return shortcode;
        }
    }
    
    return nil;
}

- (NSString *)youtubeVideoIdFromText:(NSString *)text
{
    if ([text hasPrefix:@"http://www.youtube.com/watch?v="] || [text hasPrefix:@"https://www.youtube.com/watch?v="] || [text hasPrefix:@"http://m.youtube.com/watch?v="] || [text hasPrefix:@"https://m.youtube.com/watch?v="])
    {
        NSRange range1 = [text rangeOfString:@"?v="];
        bool match = true;
        for (NSInteger i = range1.location + range1.length; i < (NSInteger)text.length; i++)
        {
            unichar c = [text characterAtIndex:i];
            if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' || c == '_' || c == '=' || c == '&' || c == '#'))
            {
                match = false;
                break;
            }
        }
        
        if (match)
        {
            NSString *videoId = nil;
            NSRange ampRange = [text rangeOfString:@"&"];
            NSRange hashRange = [text rangeOfString:@"#"];
            if (ampRange.location != NSNotFound || hashRange.location != NSNotFound)
            {
                NSInteger location = MIN(ampRange.location, hashRange.location);
                videoId = [text substringWithRange:NSMakeRange(range1.location + range1.length, location - range1.location - range1.length)];
            }
            else
                videoId = [text substringFromIndex:range1.location + range1.length];
            
            if (videoId.length != 0)
                return videoId;
        }
    }
    else if ([text hasPrefix:@"http://youtu.be/"] || [text hasPrefix:@"https://youtu.be/"])
    {
        NSString *suffix = [text substringFromIndex:[text hasPrefix:@"http://youtu.be/"] ? @"http://youtu.be/".length : @"https://youtu.be/".length];
        for (int i = 0; i < (int)suffix.length; i++)
        {
            unichar c = [suffix characterAtIndex:i];
            if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' || c == '_' || c == '=' || c == '&' || c == '#'))
            {
                return nil;
            }
        }
    }
    
    return nil;
}

- (NSString *)twitterPostIdFromText:(NSString *)text
{
    bool isHttps = false;
    if ([text hasPrefix:@"http://twitter.com/"] || (isHttps = [text hasPrefix:@"https://twitter.com/"]))
    {
        NSString *path = [text substringFromIndex:(isHttps ? @"https://twitter.com/" : @"http://twitter.com/").length];
        NSArray *components = [path componentsSeparatedByString:@"/"];
        if (components.count == 3 && [(NSString *)components[1] isEqualToString:@"status"])
            return (NSString *)components[2];
    }
    return nil;
}

- (NSString *)vkInternalUrlFromText:(NSString *)text
{
    NSString *pattern = @"https?:\\/\\/(vk\\.com\\/wall-?[0-9_-]+)\\/?";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    if (match != nil)
        return [text substringWithRange:[match rangeAtIndex:1]];
    return nil;
}

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
        {
            NSString *youtubeVideoId = [self youtubeVideoIdFromText:options[@"url"]];
            if (youtubeVideoId.length != 0)
            {
                NSURL *clientUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"youtube-x-callback://watch?v=%@&x-success=telegram://1&x-source=Telegram", youtubeVideoId]];
                if ([[UIApplication sharedApplication] canOpenURL:clientUrl])
                {
                    [[UIApplication sharedApplication] openURL:clientUrl];
                    return;
                }
            }
            
            NSString *twitterPostId = [self twitterPostIdFromText:options[@"url"]];
            if (twitterPostId.length != 0)
            {
                NSURL *clientUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"twitter://status?id=%@", twitterPostId]];
                if ([[UIApplication sharedApplication] canOpenURL:clientUrl])
                {
                    [[UIApplication sharedApplication] openURL:clientUrl];
                    return;
                }
            }
            
            NSString *instagramShortcode = [self instagramShortcodeFromText:options[@"url"]];
            if (instagramShortcode.length != 0)
            {
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://media?id=1"]])
                {
                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    [progressWindow show:true];
                    [[[[TGInstagramMediaIdSignal instagramMediaIdForShortcode:instagramShortcode] deliverOn:[SQueue mainQueue]] onDispose:^
                    {
                        [progressWindow dismiss:true];
                    }] startWithNext:^(NSString *mediaId)
                    {
                        NSURL *clientUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"instagram://media?id=%@", mediaId]];
                        if ([[UIApplication sharedApplication] canOpenURL:clientUrl])
                        {
                            [[UIApplication sharedApplication] openURL:clientUrl];
                            return;
                        }
                    } error:^(__unused id error)
                    {
                        [(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:options[@"url"]] forceNative:true];
                    } completed:nil];
                }
                else
                {
                    [(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:options[@"url"]] forceNative:true];
                }
                return;
            }
            
            NSString *vkUrl = [self vkInternalUrlFromText:options[@"url"]];
            if (vkUrl.length != 0)
            {
                NSURL *clientUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"vk://%@", vkUrl]];
                if ([[UIApplication sharedApplication] canOpenURL:clientUrl])
                {
                    [[UIApplication sharedApplication] openURL:clientUrl];
                    return;
                }
            }
            
            [(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:options[@"url"]] forceNative:true];
        }
    }
    else if ([action isEqualToString:@"openMediaRequested"])
    {
        TGModernConversationController *controller = _controller;
        [controller openMediaFromMessage:[options[@"mid"] intValue] instant:[options[@"instant"] boolValue]];
    }
    else if ([action isEqualToString:@"openEmbedRequested"])
    {
        TGModernConversationController *controller = _controller;
        [controller openEmbed:options[@"webPage"]];
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

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/webpages"])
    {
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            [self _webPagesUpdated:resource];
        }];
    }
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
                
                [(NSMutableArray *)_items replaceObjectsAtIndexes:indexSet withObjects:replacedItems];
                
                TGDispatchOnMainThread(^
                {
                    TGModernConversationController *controller = self.controller;
                    [controller replaceItems:replacedItems atIndices:indexSet];
                });
                
                [self _updateMediaStatusDataForItemsInIndexSet:indexSet animated:false];
                [self _itemsUpdated];
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

- (SSignal *)userListForMention:(NSString *)__unused mention
{
    return nil;
}

- (SSignal *)hashtagListForHashtag:(NSString *)__unused hashtag
{
    return nil;
}

- (SSignal *)commandListForCommand:(NSString *)__unused command
{
    return nil;
}

- (void)navigateToMessageId:(int32_t)__unused messageId scrollBackMessageId:(int32_t)__unused scrollBackMessageId animated:(bool)__unused animated
{
}

- (void)_itemsUpdated
{
    if (_allowMessageDownloads)
    {
        __weak TGModernConversationCompanion *weakSelf = self;
        NSTimeInterval remoteTime = [[TGTelegramNetworking instance] globalTime];
        NSMutableSet *webPageIds = nil;
        
        NSUInteger itemsCount = _items.count;
        for (NSUInteger itemIndex = 0; itemIndex < itemsCount; itemIndex++)
        {
            TGMessageModernConversationItem *item = _items[itemIndex];
            
            if (item->_message.mediaAttachments != nil)
            {
                for (TGMediaAttachment *attachment in item->_message.mediaAttachments)
                {
                    if (attachment.type == TGWebPageMediaAttachmentType)
                    {
                        TGWebPageMediaAttachment *webPage = (TGWebPageMediaAttachment *)attachment;
                        NSNumber *nKey = @(webPage.webPageId);
                        [webPageIds addObject:nKey];
                        
                        if (webPage.pendingDate != 0 && webPage.url.length == 0)
                        {
                            NSTimeInterval delay = MAX(1.0, webPage.pendingDate - remoteTime);

                            if (_downloadedMessages[nKey] == nil && _downloadingMessages[nKey] == nil)
                            {
                                TGWebPageMediaAttachment *cachedWebPage = [TGUpdateStateRequestBuilder webPageWithId:webPage.webPageId];
                                if (cachedWebPage != nil)
                                    [self _webPagesUpdated:@[cachedWebPage]];
                                else
                                {
                                    TGGenericModernConversationCompanion *genericSelf = (TGGenericModernConversationCompanion *)self;
                                    _downloadingMessages[nKey] = [[[TGDownloadMessagesSignal downloadMessages:@[[[TGDownloadMessage alloc] initWithPeerId:genericSelf->_conversationId accessHash:genericSelf->_accessHash messageId:item->_message.mid]]] delay:delay onQueue:[SQueue concurrentDefaultQueue]] startWithNext:^(NSArray *messages)
                                    {
                                        [TGModernConversationCompanion dispatchOnMessageQueue:^
                                        {
                                            __strong TGModernConversationCompanion *strongSelf = weakSelf;
                                            if (strongSelf != nil)
                                            {
                                                [strongSelf->_downloadingMessages removeObjectForKey:nKey];
                                                [strongSelf _messagesDownloaded:messages];
                                            }
                                        }];
                                    } error:^(__unused id error)
                                    {
                                        [TGModernConversationCompanion dispatchOnMessageQueue:^
                                        {
                                            __strong TGModernConversationCompanion *strongSelf = weakSelf;
                                            if (strongSelf != nil)
                                            {
                                                [strongSelf->_downloadingMessages removeObjectForKey:nKey];
                                                strongSelf->_downloadedMessages[nKey] = @1;
                                            }
                                        }];
                                    } completed:nil];
                                }
                            }
                        }
                        
                        break;
                    }
                }
            }
        }
        
        for (NSNumber *nPageId in webPageIds)
        {
            id<SDisposable> disposable = _downloadingMessages[nPageId];
            if (disposable != nil)
            {
                [disposable dispose];
                [_downloadingMessages removeObjectForKey:nPageId];
            }
        }
    }
}

- (void)updateMessageViews:(NSDictionary *)messageIdToViews markAsSeen:(bool)markAsSeen {
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        __strong TGModernConversationCompanion *strongSelf = self;
        if (strongSelf != nil) {
            NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
            NSMutableArray *updatedItemIndices = [[NSMutableArray alloc] init];
            
            for (NSUInteger i = 0; i < strongSelf->_items.count; i++) {
                TGMessageModernConversationItem *item = strongSelf->_items[i];
                NSNumber *nViewCount = messageIdToViews[@(item->_message.mid)];
                if (nViewCount != nil) {
                    TGMessageModernConversationItem *updatedItem = [item deepCopy];
                    updatedItem->_message.viewCount = [[TGMessageViewCountContentProperty alloc] initWithViewCount:MAX(updatedItem->_message.viewCount.viewCount, [nViewCount intValue])];
                    [updatedItems addObject:updatedItem];
                    [updatedItemIndices addObject:@(i)];
                }
            }
            
            if (markAsSeen) {
                markMessagesAsSeen([strongSelf requestPeerId], messageIdToViews.allKeys);
            }
            
            TGDispatchOnMainThread(^
            {
                TGModernConversationController *controller = strongSelf.controller;
                
                int index = -1;
                for (NSNumber *nIndex in updatedItemIndices)
                {
                    index++;
                    [controller updateItemAtIndex:[nIndex intValue] toItem:updatedItems[index]];
                }
            });
        }
    }];
}

- (void)_messagesDownloaded:(NSArray *)messages
{
    NSMutableArray *webPages = [[NSMutableArray alloc] init];
    
    for (TGMessage *message in messages)
    {
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            if (attachment.type == TGWebPageMediaAttachmentType)
            {
                [webPages addObject:attachment];
                
                break;
            }
        }
    }
    
    if (webPages.count != 0)
        [self _webPagesUpdated:webPages];
}

- (void)_webPagesUpdated:(NSArray *)webPages
{
    NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
    NSMutableArray *atIndices = [[NSMutableArray alloc] init];
    
    NSInteger itemIndex = -1;
    for (TGMessageModernConversationItem *item in _items)
    {
        itemIndex++;
        
        NSInteger index = -1;
        for (TGMediaAttachment *attachment in item->_message.mediaAttachments)
        {
            index++;
            
            if (attachment.type == TGWebPageMediaAttachmentType)
            {
                int64_t webPageId = ((TGWebPageMediaAttachment *)attachment).webPageId;
                for (TGWebPageMediaAttachment *webPage in webPages)
                {
                    if (webPage.webPageId == webPageId)
                    {
                        TGMessageModernConversationItem *updatedItem = [item copy];
                        updatedItem->_message = [updatedItem->_message copy];
                        NSMutableArray *attachments = [[NSMutableArray alloc] initWithArray:updatedItem->_message.mediaAttachments];
                        attachments[index] = webPage;
                        updatedItem->_message.mediaAttachments = attachments;
                        
                        [TGDatabaseInstance() updateMessage:item->_message.mid peerId:item->_message.cid flags:std::vector<TGDatabaseMessageFlagValue>() media:attachments dispatch:false];
                        
                        [updatedItems addObject:updatedItem];
                        [atIndices addObject:@(itemIndex)];
                        
                        break;
                    }
                }
                
                break;
            }
        }
    }
    
    if (updatedItems.count != 0)
    {
        for (NSUInteger i = 0; i < updatedItems.count; i++)
        {
            [((NSMutableArray *)_items) replaceObjectAtIndex:[atIndices[i] unsignedIntegerValue] withObject:updatedItems[i]];
        }
        
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
}

- (void)navigateToMessageSearch
{
}

- (bool)isASingleBotGroup
{
    return false;
}

- (void)_controllerDidUpdateVisibleHoles:(NSArray *)__unused holes
{
}

- (void)_controllerDidUpdateVisibleUnseenMessageIds:(NSArray *)unseenMessageIds {
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        NSMutableArray *consumeIds = [[NSMutableArray alloc] init];
        
        for (NSNumber *nMid in unseenMessageIds) {
            if (_messageViewsRequested.find([nMid intValue]) == _messageViewsRequested.end()) {
                _messageViewsRequested.insert([nMid intValue]);
                [consumeIds addObject:nMid];
            }
        }
        
        if (consumeIds.count != 0) {
            if (_messageViewsRequestedBuffer == nil) {
                _messageViewsRequestedBuffer = [[NSMutableArray alloc] init];
            }
            
            [_messageViewsRequestedBuffer addObjectsFromArray:consumeIds];
        }
        
        [_messageViewsRequestedBufferTimer invalidate];
        [_messageViewsRequestedBufferTimer start];
    }];
}

- (bool)_controllerShouldHideInputTextByDefault
{
    return false;
}

- (bool)canDeleteMessage:(TGMessage *)__unused message
{
    return true;
}

- (bool)canDeleteMessages
{
    return true;
}

- (bool)canDeleteAllMessages
{
    return true;
}
                                         
- (int64_t)requestPeerId {
    return 0;
}

- (int64_t)requestAccessHash {
    return 0;
}

- (void)_toggleBroadcastMode {
}

- (void)_toggleTitleMode {
}

- (void)consumeRequestedMessages {
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        NSArray *consumeIds = [[NSArray alloc] initWithArray:_messageViewsRequestedBuffer];
        [_messageViewsRequestedBuffer removeAllObjects];
        
        if (consumeIds.count != 0) {
            [[TGChannelManagementSignals consumeMessages:[self requestPeerId] accessHash:[self requestAccessHash] messageIds:consumeIds] startWithNext:^(NSDictionary *messageIdToViews) {
                [TGModernConversationCompanion dispatchOnMessageQueue:^{
                    __strong TGModernConversationCompanion *strongSelf = self;
                    if (strongSelf != nil) {
                        [strongSelf updateMessageViews:messageIdToViews markAsSeen:true];
                    }
                }];
            }];
        }
    }];
}

@end
