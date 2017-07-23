#import "TGGenericModernConversationCompanion.h"

#import "ASCommon.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"
#import "TGSharedPtrWrapper.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGPhoneUtils.h"
#import "TGPeerIdAdapter.h"

#import "TGAppDelegate.h"
#import "TGDownloadManager.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGDatabaseMessageDraft.h"

#import "TGStringUtils.h"

#import "TGViewController.h"
#import "TGInterfaceManager.h"
#import "TGDialogListController.h"
#import "TGAlertView.h"

#import "TGMessageModernConversationItem.h"

#import "TGModernConversationController.h"

#import "TGMessageViewModel.h"

#import "TGPreparedMessage.h"
#import "TGPreparedTextMessage.h"
#import "TGPreparedMapMessage.h"
#import "TGPreparedLocalImageMessage.h"
#import "TGPreparedRemoteImageMessage.h"
#import "TGPreparedLocalVideoMessage.h"
#import "TGPreparedRemoteVideoMessage.h"
#import "TGPreparedForwardedMessage.h"
#import "TGPreparedContactMessage.h"
#import "TGPreparedLocalDocumentMessage.h"
#import "TGPreparedRemoteDocumentMessage.h"
#import "TGPreparedDownloadImageMessage.h"
#import "TGPreparedDownloadDocumentMessage.h"
#import "TGPreparedCloudDocumentMessage.h"
#import "TGPreparedDownloadExternalGifMessage.h"
#import "TGPreparedDownloadExternalImageMessage.h"
#import "TGPreparedAssetImageMessage.h"
#import "TGPreparedAssetVideoMessage.h"
#import "TGPreparedDownloadExternalDocumentMessage.h"

#import "TGForwardTargetController.h"

#import "TGModernSendMessageActor.h"
#import "TGVideoDownloadActor.h"
#import "TGRemoteImageView.h"
#import "TGImageDownloadActor.h"
#import "TGCreateContactController.h"
#import "TGAddToExistingContactController.h"

#import "TGWallpaperManager.h"
#import "TGWallpaperInfo.h"
#import "TGTelegraphConversationMessageAssetsSource.h"

#import "NSObject+TGLock.h"

#import "TGProgressWindow.h"

#import "TGBingSearchResultItem.h"
#import "TGGiphySearchResultItem.h"
#import "TGWebSearchInternalImageResult.h"
#import "TGWebSearchInternalGifResult.h"
#import "TGExternalGifSearchResult.h"
#import "TGInternalGifSearchResult.h"

#import "TGMediaStoreContext.h"
#import "TGModernSendCommonMessageActor.h"
#import "TGWebSearchController.h"
#import "TGWebSearchInternalImageResult.h"

#import "TGHashtagSearchController.h"
#import "TGRecentHashtagsSignal.h"
#import "TGTextCheckingResult.h"

#import "TGICloudItem.h"
#import "TGDropboxItem.h"
#import "TGGoogleDriveItem.h"
#import "TGFileUtils.h"

#import "TGRecentHashtagsSignal.h"

#import "TGLinkPreviewsContentProperty.h"

#import "TGModernConversationInputTextPanel.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGMessageViewedContentProperty.h"

#import "TGStickersSignals.h"
#import "TGStickerAssociation.h"

#import <map>
#import <vector>

#import <WebP/decode.h>

#import "TGChatSearchController.h"

#import "TGModernViewContext.h"

#import "TGChannelManagementSignals.h"

#import "PSKeyValueEncoder.h"

#import "TGDocumentHttpFileReference.h"

#import "TGBotContextResultAttachment.h"

#import "TGPeerInfoSignals.h"
#import "TGBotSignals.h"

#import "TGExternalImageSearchResult.h"

#import "TGMediaAsset.h"
#import "TGVideoEditAdjustments.h"

#import <AVFoundation/AVFoundation.h>

#import "TGDataItem.h"

#import "TGAudioWaveformSignal.h"

#import <MTProtoKit/MTProtoKit.h>

#import "TGLocationSignals.h"

#import "TGModernConversationTitlePanel.h"
#import "TGToastTitlePanel.h"

#import "TGBotContextExternalResult.h"

#import "TGMimeTypeMap.h"

#import "TGGroupManagementSignals.h"

#import "TGDownloadMessagesSignal.h"

#import "TGWebAppController.h"

#import "TGPreparedGameMessage.h"

#import "TGInstantPageController.h"

#import "TGApplication.h"

#import "TGPaymentCheckoutController.h"
#import "TGPaymentReceiptController.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 // iOS 6.0 or later
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else                                         // iOS 5.X or earlier
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif

#ifdef DEBUG
#   define DEBUG_DONOTREAD
#endif

typedef enum {
    TGSendMessageIntentSendText = 0,
    TGSendMessageIntentSendOther = 1,
    TGSendMessageIntentOther = 2
} TGSendMessageIntent;

static NSString *addGameShareHash(NSString *url, NSString *addHash) {
    NSRange hashRange = [url rangeOfString:@"#"];
    if (hashRange.location == NSNotFound) {
        return [url stringByAppendingFormat:@"#%@", addHash];
    }
    
    NSString *curHash = [url substringFromIndex:hashRange.location + hashRange.length];
    if ([curHash rangeOfString:@"="].location != NSNotFound || [curHash rangeOfString:@"?"].location != NSNotFound) {
        return [url stringByAppendingFormat:@"&%@", addHash];
    }
    
    if (curHash.length > 0) {
        return [url stringByAppendingFormat:@"?%@", addHash];
    }
    
    return [url stringByAppendingFormat:@"%@", addHash];
}

@interface TGGenericModernConversationCompanion () <TGCreateContactControllerDelegate, TGAddToExistingContactControllerDelegate>
{
    SAtomic *_conversationAtomic;
    TGConversation *_initialConversation;
    
    int _initialUnreadCount;
    
    NSArray *_initialForwardMessagePayload;
    NSArray *_initialAttachMessagePayload;
    NSArray *_initialSendMessagePayload;
    NSArray *_initialSendFilePayload;
    
    bool _moreMessagesAvailableAbove;
    bool _loadingMoreMessagesAbove;
    
    bool _moreMessagesAvailableBelow;
    bool _loadingMoreMessagesBelow;
    
    bool _needsToReadHistory;
    
    NSString *_conversationIdPathComponent;
    
    std::map<int32_t, float> _messageUploadProgress;
    
    std::set<int32_t> _processingDownloadMids;
    TG_SYNCHRONIZED_DEFINE(_processingDownloadMids);
    
    NSUInteger _layer;
    
    SMetaDisposable *_stickerPacksDisposable;
    SMetaDisposable *_botCallbackDisposable;
    
    TGProgressWindow *_progressWindow;
    int32_t _loadingMessageForSearch;
    int32_t _sourceMessageForSearch;
    bool _animatedTransitionInSearch;
    
    id<SDisposable> _botReplyMarkupDisposable;
    id<SDisposable> _primaryPanelDisposable;
    SVariable *_toastPanel;
    SVariable *_callbackInProgressPanel;
    
    int32_t _callbackInProgressMessageId;
    
    TGToastTitlePanel *_callbackInProgressToastPanel;
    
    int32_t _initialReplyMessageId;
    NSArray *_initialForwardMessageDescs;
    TGMessageEditingContext *_initialMessageEditingContext;
    NSString *_initialInputText;
    NSArray *_initialInputEntities;
    
    SMetaDisposable *_getMessageForMentionDisposable;
}

@end

@implementation TGGenericModernConversationCompanion

- (instancetype)initWithConversation:(TGConversation *)conversation mayHaveUnreadMessages:(bool)mayHaveUnreadMessages
{
    self = [super init];
    if (self != nil)
    {
        _conversationId = conversation.conversationId;
        self.viewContext.conversationForUnreadCalculations = conversation;
        
        _conversationAtomic = [[SAtomic alloc] initWithValue:conversation];
        _initialConversation = conversation;
        
        _getMessageForMentionDisposable = [[SMetaDisposable alloc] init];
        
        TGMessageModernConversationItemLocalUserId = TGTelegraphInstance.clientUserId;
        
        _moreMessagesAvailableAbove = true;
        _initialMayHaveUnreadMessages = mayHaveUnreadMessages;
        
        TGWallpaperInfo *wallpaper = [[TGWallpaperManager instance] currentWallpaperInfo];
        [[TGTelegraphConversationMessageAssetsSource instance] setMonochromeColor:wallpaper.tintColor];
        [[TGTelegraphConversationMessageAssetsSource instance] setSystemAlpha:wallpaper.systemAlpha];
        [[TGTelegraphConversationMessageAssetsSource instance] setButtonsAlpha:wallpaper.buttonsAlpha];
        [[TGTelegraphConversationMessageAssetsSource instance] setHighlighteButtonAlpha:wallpaper.highlightedButtonAlpha];
        [[TGTelegraphConversationMessageAssetsSource instance] setProgressAlpha:wallpaper.progressAlpha];
        
        TG_SYNCHRONIZED_INIT(_processingDownloadMids);
        
        __weak TGGenericModernConversationCompanion *weakSelf = self;
        
        _toastPanel = [[SVariable alloc] init];
        [_toastPanel set:[SSignal single:nil]];
        
        _callbackInProgressPanel = [[SVariable alloc] init];
        [_callbackInProgressPanel set:[SSignal single:nil]];
        
        SSignal *combinedPanelSignal = [SSignal combineSignals:@[
            [[_callbackInProgressPanel.signal deliverOn:[SQueue mainQueue]] map:^(id next) { return next == nil ? [NSNull null] : next; }],
            [_toastPanel.signal map:^(id next) { return next == nil ? [NSNull null] : next; }],
            [[self primaryTitlePanel] map:^(id next) { return next == nil ? [NSNull null] : next; }],
        ]];
        
        SSignal *panelSignal = [combinedPanelSignal map:^id(NSArray *panels) {
            //TGLog(@"panels: %@", panels);
            for (id panel in panels) {
                if ([panel isKindOfClass:[TGModernConversationTitlePanel class]]) {
                    return panel;
                }
            }
            return nil;
        }];
        
        _primaryPanelDisposable = [[panelSignal deliverOn:[SQueue mainQueue]] startWithNext:^(TGModernConversationTitlePanel *panel) {
            __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                TGModernConversationController *controller = strongSelf.controller;
                [controller setSecondaryTitlePanel:panel animated:true];
            }
        }];
        
        [_callbackInProgressPanel set:[[self.callbackInProgress.signal delay:0.2 onQueue:[SQueue mainQueue]] map:^id(id next) {
            __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (next != nil) {
                    if (strongSelf->_callbackInProgressToastPanel == nil) {
                        strongSelf->_callbackInProgressToastPanel = [[TGToastTitlePanel alloc] initWithText:TGLocalized(@"Channel.NotificationLoading")];
                        /*strongSelf->_callbackInProgressToastPanel.dismiss = ^{
                            __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                //[strongSelf->_callbackInProgressPanel set:[SSignal single:nil]];
                            }
                        };*/
                    }
                    return strongSelf->_callbackInProgressToastPanel;
                }
            }
            return nil;
        }]];
        
        _botCallbackDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc
{
    TGProgressWindow *progressWindow = _progressWindow;
    TGDispatchOnMainThread(^
    {
        [progressWindow dismiss:false];
    });
    
    [_stickerPacksDisposable dispose];
    [_botReplyMarkupDisposable dispose];
    [_getMessageForMentionDisposable dispose];
    [_botCallbackDisposable dispose];
}

- (void)setOthersUnreadCount:(int)unreadCount
{
    _initialUnreadCount = unreadCount;
}

- (void)setPreferredInitialMessagePositioning:(int32_t)messageId pipLocation:(TGPIPSourceLocation *)pipLocation
{
    _preferredInitialPositionedMessageId = messageId;
    _openPIPLocation = pipLocation;
}

- (void)setInitialMessagePayloadWithForwardMessages:(NSArray *)initialForwardMessagePayload sendMessages:(NSArray *)initialSendMessagePayload sendFiles:(NSArray *)initialSendFilePayload
{
    //_initialForwardMessagePayload = initialForwardMessagePayload;
    _initialAttachMessagePayload = initialForwardMessagePayload;
    _initialSendMessagePayload = initialSendMessagePayload;
    _initialSendFilePayload = initialSendFilePayload;
}

- (int64_t)conversationId
{
    return _conversationId;
}

- (int64_t)messageAuthorPeerId
{
    return TGTelegraphInstance.clientUserId;
}

- (bool)imageDownloadsShouldAutosavePhotos
{
    return true;
}

- (bool)_shouldCacheRemoteAssetUris
{
    return true;
}

- (bool)_shouldDisplayProcessUnreadCount
{
    return true;
}

+ (CGSize)preferredInlineThumbnailSize
{
    return [TGViewController isWidescreen] ? CGSizeMake(220, 220) : CGSizeMake(180, 180);
}

- (int)messageLifetime
{
    return 0;
}

- (NSUInteger)layer
{
    if (_layer < 1)
        return 1;
    return _layer;
}

- (void)setLayer:(NSUInteger)layer
{
    _layer = layer;
}

- (NSDictionary *)_optionsForMessageActions
{
    return nil;
}

- (void)_setupOutgoingMessage:(TGMessage *)__unused message {
    
}

- (bool)_messagesNeedRandomId
{
    return false;
}

- (bool)canSendStickers {
    return true;
}

- (bool)canSendMedia {
    return true;
}

- (bool)canSendGifs {
    return true;
}

- (bool)canSendGames {
    return true;
}

- (bool)canSendInline {
    return true;
}

- (void)standaloneSendMessages:(NSArray *)messages
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [self _sendPreparedMessages:[self _createPreparedMessagesFromMessages:messages copyAssetsData:true] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)standaloneSendFiles:(NSArray *)files
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [self _sendPreparedMessages:[self _createPreparedMessagesFromFiles:files asReplyToMessageId:0] automaticallyAddToList:false withIntent:TGSendMessageIntentOther];
    }];
}

- (void)shareVCard
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        TGUser *user = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
        if (user != nil)
        {
            TGPreparedContactMessage *contactMessage = [[TGPreparedContactMessage alloc] initWithUid:user.uid firstName:user.firstName lastName:user.lastName phoneNumber:user.phoneNumber replyMessage:nil replyMarkup:nil];
            [self _sendPreparedMessages:@[contactMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentOther];
        }
    }];
}

- (void)_addMediaRecentsFromMessages:(NSArray *)messages
{
    for (TGMessage *message in messages)
    {
        if (message.outgoing)
            continue;
        
        for (id attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
            {
                TGImageMediaAttachment *imageAttachment = attachment;
                if (imageAttachment.imageId != 0)
                {
                    [TGWebSearchController addRecentSelectedItems:@[[[TGWebSearchInternalImageResult alloc] initWithImageId:imageAttachment.imageId accessHash:imageAttachment.accessHash imageInfo:imageAttachment.imageInfo]]];
                }
            }
            else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
            {
                TGDocumentMediaAttachment *documentAttachment = attachment;
                if ([documentAttachment.mimeType isEqualToString:@"image/gif"] && documentAttachment.thumbnailInfo != nil && documentAttachment.documentId != 0)
                {
                    [TGWebSearchController addRecentSelectedItems:@[[[TGWebSearchInternalGifResult alloc] initWithDocumentId:documentAttachment.documentId accessHash:documentAttachment.accessHash size:documentAttachment.size fileName:documentAttachment.fileName mimeType:documentAttachment.mimeType thumbnailInfo:documentAttachment.thumbnailInfo]]];
                }
            }
        }
    }
}

- (void)standaloneForwardMessages:(NSArray *)messages
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = self.controller;
            [controller setForwardMessages:messages animated:false];
        });
        
        /*[self _sendPreparedMessages:[self _createPreparedForwardMessagesFromMessages:messages] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
        
        [self _addMediaRecentsFromMessages:messages];*/
    }];
}

- (void)loadInitialState
{
    [self loadInitialState:true];
}

- (void)loadInitialState:(bool)loadMessages
{
    __autoreleasing NSArray *forwardMessageDescs = nil;
    __autoreleasing TGMessageEditingContext *messageEditingContext = nil;
    __autoreleasing TGConversationScrollState *scrollState = nil;
    __autoreleasing NSArray *entities = nil;
    
    TGDatabaseMessageDraft *draft = [TGDatabaseInstance() _peerDraft:_conversationId];
    _initialInputText = draft.text;
    entities = draft.entities;
    _initialReplyMessageId = draft.replyToMessageId;
    
    [TGDatabaseInstance() loadConversationState:_conversationId forwardMessageDescs:&forwardMessageDescs messageEditingContext:&messageEditingContext scrollState:&scrollState];
    _initialForwardMessageDescs = forwardMessageDescs;
    _initialMessageEditingContext = messageEditingContext;
    _initialScrollState = scrollState;
    _initialInputEntities = entities;
    
    if (scrollState != nil && scrollState.messageId != 0 && _preferredInitialPositionedMessageId == 0 && !_initialMayHaveUnreadMessages) {
        [self setInitialMessagePositioning:scrollState.messageId position:TGInitialScrollPositionBottom offset:scrollState.messageOffset];
        [self setPreferredInitialMessagePositioning:scrollState.messageId pipLocation:nil];
    } else {
        _initialScrollState = nil;
        scrollState = nil;
    }
    
    if (_initialScrollState != nil) {
        self.useInitialSnapshot = false;
    }
    
    if (_initialForwardMessagePayload != 0 || _initialSendMessagePayload.count != 0 || _initialSendFilePayload.count != 0)
    {
        dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
        
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            if (_initialSendMessagePayload.count != 0)
            {
                [self _sendPreparedMessages:[self _createPreparedMessagesFromMessages:_initialSendMessagePayload copyAssetsData:true] automaticallyAddToList:false withIntent:TGSendMessageIntentOther];
            }
            _initialSendMessagePayload = nil;
            
            if (_initialSendFilePayload.count != 0)
            {
                [self _sendPreparedMessages:[self _createPreparedMessagesFromFiles:_initialSendFilePayload asReplyToMessageId:0] automaticallyAddToList:false withIntent:TGSendMessageIntentOther];
            }
            _initialSendFilePayload = nil;
            
            if (_initialForwardMessagePayload.count != 0)
            {
                [self _sendPreparedMessages:[self _createPreparedForwardMessagesFromMessages:_initialForwardMessagePayload] automaticallyAddToList:false withIntent:TGSendMessageIntentOther];
                
                [self _addMediaRecentsFromMessages:_initialForwardMessagePayload];
            }
            _initialForwardMessagePayload = nil;
            
            dispatch_semaphore_signal(waitSemaphore);
        }];
        
        dispatch_semaphore_wait(waitSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)));
        
#if NEEDS_DISPATCH_RETAIN_RELEASE
        if (waitSemaphore != nil)
            dispatch_release(waitSemaphore);
#endif
    }
    
    if (loadMessages)
    {
        __block NSArray *topMessages = nil;
        __block bool blockIsAtBottom = true;
        
        NSUInteger initialMessageCount = 24;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            initialMessageCount = [TGViewController isWidescreen] ? 20 : 14;
        else
            initialMessageCount = 34;
        
        [TGDatabaseInstance() dispatchOnDatabaseThread:^
        {
            if (_preferredInitialPositionedMessageId != 0)
            {
                [TGDatabaseInstance() loadMessagesFromConversation:_conversationId maxMid:INT_MAX maxDate:INT_MAX maxLocalMid:INT_MAX atMessageId:_preferredInitialPositionedMessageId limit:20 extraUnread:false completion:^(NSArray *messages, bool historyExistsBelow)
                {
                    topMessages = messages;
                    blockIsAtBottom = !historyExistsBelow;
                }];
            }
            else if (_initialMayHaveUnreadMessages)
            {
                [TGDatabaseInstance() loadUnreadMessagesHeadFromConversation:_conversationId limit:(int)initialMessageCount completion:^(NSArray *messages, bool isAtBottom)
                {
                    topMessages = messages;
                    blockIsAtBottom = isAtBottom;
                }];
            }
            else
            {
                [TGDatabaseInstance() loadMessagesFromConversation:_conversationId maxMid:INT_MAX maxDate:INT_MAX maxLocalMid:INT_MAX atMessageId:0 limit:[TGViewController isWidescreen] ? 20 : 14 extraUnread:false completion:^(NSArray *messages, __unused bool historyExistsBelow)
                {
                    topMessages = messages;
                }];
            }
            
            int minRemoteMid = INT_MAX;
            int maxRemoteMid = INT_MIN;
            for (TGMessage *message in topMessages)
            {
                if (message.mid < TGMessageLocalMidBaseline)
                {
                    minRemoteMid = MIN(message.mid, minRemoteMid);
                    maxRemoteMid = MAX(message.mid, maxRemoteMid);
                }
            }
            
            if (minRemoteMid <= maxRemoteMid)
            {
                topMessages = [TGDatabaseInstance() excludeMessagesWithHolesFromArray:topMessages peerId:_conversationId aroundMessageId:_preferredInitialPositionedMessageId];
            }
        } synchronous:true];
        
        NSMutableArray *sortedTopMessages = [[NSMutableArray alloc] initWithArray:topMessages];
        [sortedTopMessages sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
        {
            NSTimeInterval date1 = message1.date;
            NSTimeInterval date2 = message2.date;
            
            if (ABS(date1 - date2) < DBL_EPSILON)
            {
                if (message1.mid > message2.mid)
                    return NSOrderedAscending;
                else
                    return NSOrderedDescending;
            }
            
            return date1 > date2 ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        if ((scrollState == nil || scrollState.messageId == 0) && _preferredInitialPositionedMessageId != 0)
        {
            for (TGMessage *message in sortedTopMessages.reverseObjectEnumerator)
            {
                if (message.mid == _preferredInitialPositionedMessageId)
                {
                    [self setInitialMessagePositioning:message.mid position:TGInitialScrollPositionCenter offset:0.0f];
                    break;
                }
            }
        }
        else
        {
            int lastUnreadIndex = -1;
            int index = (int)sortedTopMessages.count;
            for (TGMessage *message in sortedTopMessages.reverseObjectEnumerator)
            {
                index--;
                
                if (!message.outgoing && [_initialConversation isMessageUnread:message])
                {
                    lastUnreadIndex = index;
                    [self setInitialMessagePositioning:message.mid position:TGInitialScrollPositionTop offset:0.0f];
                    break;
                }
            }
            
            if (lastUnreadIndex != -1)
            {
                TGMessageRange unreadRange = TGMessageRangeEmpty();
                
                unreadRange.firstDate = (int)((TGMessage *)sortedTopMessages[lastUnreadIndex]).date;
                unreadRange.lastDate = (int)((TGMessage *)sortedTopMessages[0]).date;
                
                bool setFirstMessageId = false;
                bool setFirstLocalMessageId = false;
                for (int i = lastUnreadIndex; i >= 0 && (!setFirstMessageId || !setFirstLocalMessageId); i--)
                {
                    TGMessage *message = sortedTopMessages[i];
                    
                    if (message.mid < TGMessageLocalMidBaseline)
                    {
                        if (!setFirstMessageId)
                        {
                            unreadRange.firstMessageId = message.mid;
                            setFirstMessageId = true;
                        }
                    }
                    else
                    {
                        if (!setFirstLocalMessageId)
                        {
                            unreadRange.firstLocalMessageId = message.mid;
                            setFirstLocalMessageId = true;
                        }
                    }
                }
                
                bool setLastMessageId = false;
                bool setLastLocalMessageId = false;
                for (int i = 0; i <= lastUnreadIndex && (!setLastMessageId || !setLastLocalMessageId); i++)
                {
                    TGMessage *message = sortedTopMessages[i];
                    
                    if (message.mid < TGMessageLocalMidBaseline)
                    {
                        if (!setLastMessageId)
                        {
                            unreadRange.lastMessageId = message.mid;
                            setLastMessageId = true;
                        }
                    }
                    else
                    {
                        if (!setLastLocalMessageId)
                        {
                            unreadRange.lastLocalMessageId = message.mid;
                            setLastLocalMessageId = true;
                        }
                    }
                }
                
                [self setUnreadMessageRange:unreadRange];
            }
        }
        
        _moreMessagesAvailableBelow = !blockIsAtBottom;
        
/*#ifdef DEBUG
        for (TGMessage *message in sortedTopMessages) {
            for (id attachment in message.mediaAttachments) {
                if ([attachment isKindOfClass:[TGWebPageMediaAttachment class]]) {
                    TGWebPageMediaAttachment *webPage = attachment;
                    TGWebPageMediaAttachment *pendingWebPage = [[TGWebPageMediaAttachment alloc] init];
                    pendingWebPage.pendingDate = 1000;
                    pendingWebPage.webPageId = webPage.webPageId;
                    NSMutableArray *attachments = [[NSMutableArray alloc] initWithArray:message.mediaAttachments];
                    attachments[[attachments indexOfObject:attachment]] = pendingWebPage;
                    message.mediaAttachments = attachments;
                    break;
                }
            }
        }
#endif*/
        
        [self _replaceMessages:sortedTopMessages];
    }

    TGModernConversationController *controller = self.controller;
    
    if (_initialUnreadCount != 0)
        [controller setGlobalUnreadCount:_initialUnreadCount];
    
    if (_initialAttachMessagePayload.count != 0)
        [controller setForwardMessages:_initialAttachMessagePayload animated:false];
    
    [self _updateInputPanel];
    
    __weak TGGenericModernConversationCompanion *weakSelf = self;
    _botReplyMarkupDisposable = [[[TGDatabaseInstance() signalBotReplyMarkupForPeerId:_conversationId] deliverOn:[SQueue mainQueue]] startWithNext:^(TGBotReplyMarkup *markup)
    {
        __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGModernConversationController *controller = strongSelf.controller;
            [controller setReplyMarkup:markup];
        }
    }];
}

- (void)_controllerWillAppearAnimated:(bool)animated firstTime:(bool)firstTime
{
    TGModernConversationController *controller = self.controller;
    
    [super _controllerWillAppearAnimated:animated firstTime:firstTime];
    
    [TGDialogListController setLastAppearedConversationId:_conversationId];
    
    if (firstTime)
    {
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            bool remoteMediaVisible = false;
            
            for (TGMessageModernConversationItem *item in _items)
            {
                if (mediaIdForMessage(item->_message) != nil)
                {
                    if (!item->_mediaAvailabilityStatus)
                        remoteMediaVisible = true;
                }
            }
            
            if (remoteMediaVisible)
                [[TGDownloadManager instance] requestState:self.actionHandle];
        }];
        
        
        if (_initialMessageEditingContext != nil) {
            [controller setMessageEditingContext:_initialMessageEditingContext];
        } else if (_replaceInitialText.length != 0) {
            [controller setInputText:_replaceInitialText replace:true selectRange:NSMakeRange(0, 0)];
        } else if (_initialInputText.length != 0)
        {
            [controller setInputText:_initialInputText entities:_initialInputEntities replace:true replaceIfPrefix:false selectRange:NSMakeRange(0, 0)];
        }
        if (_initialReplyMessageId != 0)
        {
            TGMessage *replyMessage = [TGDatabaseInstance() loadMessageWithMid:_initialReplyMessageId peerId:_conversationId];
            if (replyMessage != nil)
            {
                [controller setReplyMessage:replyMessage animated:false];
            }
        }
        else if (_initialForwardMessageDescs.count != 0)
        {
            NSMutableArray *forwardMessages = [[NSMutableArray alloc] init];
            for (NSDictionary *desc in _initialForwardMessageDescs)
            {
                TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[desc[@"messageId"] intValue] peerId:[desc[@"peerId"] longLongValue]];
                if (message != nil)
                    [forwardMessages addObject:message];
            }
            TGModernConversationController *controller = self.controller;
            if (forwardMessages.count != 0)
                [controller setForwardMessages:forwardMessages animated:false];
        }
        
        if ((_initialScrollState == nil || _initialScrollState.messageId == 0) && _preferredInitialPositionedMessageId != 0) {
            [controller temporaryHighlightMessage:_preferredInitialPositionedMessageId automatically:false];
        }
    }
}

- (void)_controllerDidAppear:(bool)firstTime
{
    [super _controllerDidAppear:firstTime];
    
    if (firstTime)
    {   
        if (_moreMessagesAvailableBelow)
            [self loadMoreMessagesBelow];
        if (_moreMessagesAvailableAbove)
            [self loadMoreMessagesAbove];
        
        [[TGDownloadManager instance] requestState:self.actionHandle];
        
        TGModernConversationController *controller = self.controller;
        if (!self.previewMode && [controller canReadHistory])
        {
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                [self _markIncomingMessagesAsReadSilent];
            }];
            
            [TGDatabaseInstance() transactionReadHistoryForPeerIds:[[NSSet alloc] initWithArray:@[@(_conversationId)]]];
        }
        
        if ((_initialScrollState == nil || _initialScrollState.messageId == 0) && _preferredInitialPositionedMessageId != 0) {
            if (_openPIPLocation == nil) {
                [controller temporaryHighlightMessage:_preferredInitialPositionedMessageId automatically:true];
            }
            else {
                [controller openPIPSourceLocation:_openPIPLocation];
            }
        }
    }
}

- (void)updateControllerInputText:(NSString *)inputText entities:(NSArray *)entities messageEditingContext:(TGMessageEditingContext *)messageEditingContext
{
    TGModernConversationController *controller = self.controller;
    int32_t currentReplyMessageId = [controller _currentReplyMessageId];
    NSArray *currentForwardMessageDescs = [controller _currentForwardMessageDescs];
    TGConversationScrollState *scrollState = [controller _currentScrollState];
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        TGDatabaseMessageDraft *draft = nil;
        if (messageEditingContext == nil && (inputText.length != 0)) {
            draft = [[TGDatabaseMessageDraft alloc] initWithText:inputText entities:entities disableLinkPreview:false replyToMessageId:currentReplyMessageId date:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]];
        }
        [TGDatabaseInstance() updatePeerDraftInteractive:_conversationId draft:draft];
         
        [TGDatabaseInstance() storeConversationState:_conversationId messageEditingContext:messageEditingContext forwardMessageDescs:currentForwardMessageDescs scrollState:scrollState];
    } synchronous:false];
}

- (void)_updateNetworkState:(NSString *)stateString
{
    TGDispatchOnMainThread(^
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            TGModernConversationController *controller = self.controller;
            [controller setTitleModalProgressStatus:stateString];
        }
    });
}

- (void)controllerDidChangeInputText:(NSString *)inputText
{
    if (![self canSendStickers]) {
        TGModernConversationController *controller = self.controller;
        [controller setInlineStickerList:nil];
        return;
    }
    
    if (![inputText containsSingleEmoji])
    {
        TGModernConversationController *controller = self.controller;
        [controller setInlineStickerList:nil];
    }
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (![inputText containsSingleEmoji] || TGAppDelegateInstance.alwaysShowStickersMode == 1)
        {
            [_stickerPacksDisposable setDisposable:nil];
            TGDispatchOnMainThread(^
            {
                TGModernConversationController *controller = self.controller;
                if ([controller.inputText isEqualToString:inputText])
                    [controller setInlineStickerList:nil];
            });
        }
        else
        {
            NSString *keyString = [inputText getEmojiFromString:true checkString:nil].firstObject;
            __weak TGGenericModernConversationCompanion *weakSelf = self;
            [_stickerPacksDisposable setDisposable:[[[[[[TGStickersSignals stickerPacks] filter:^bool(NSDictionary *dict)
            {
                return ((NSArray *)dict[@"packs"]).count != 0;
            }] take:1] mapToSignal:^SSignal *(NSDictionary *dict)
            {
                NSMutableArray *matchedDocuments = [[NSMutableArray alloc] init];
                NSMutableDictionary *associations = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *stickerPacks = [[NSMutableDictionary alloc] init];
                
                NSArray *sortedStickerPacks = dict[@"packs"];
                
                for (TGStickerPack *stickerPack in sortedStickerPacks)
                {
                    if (stickerPack.hidden) {
                        continue;
                    }
                    
                    NSMutableArray *documentIds = [[NSMutableArray alloc] init];
                    for (TGStickerAssociation *association in stickerPack.stickerAssociations)
                    {
                        if ([association.key isEqual:keyString])
                        {
                            [documentIds addObjectsFromArray:association.documentIds];
                            for (NSNumber *documentId in association.documentIds)
                            {
                                associations[documentId] = stickerPack.stickerAssociations;
                                stickerPacks[documentId] = stickerPack;
                            }
                        }
                    }
                    
                    for (NSNumber *nDocumentId in documentIds)
                    {
                        for (TGDocumentMediaAttachment *document in stickerPack.documents)
                        {
                            if (document.documentId == [nDocumentId longLongValue])
                            {
                                [matchedDocuments addObject:document];
                                break;
                            }
                        }
                    }
                }
                
                return [TGStickersSignals preloadedStickerPreviews:@{ @"documents": matchedDocuments, @"associations": associations, @"stickerPacks": stickerPacks } count:6];
            }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dictionary)
            {
                __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    TGModernConversationController *controller = strongSelf.controller;
                    if ([controller.inputText isEqualToString:inputText])
                        [controller setInlineStickerList:dictionary];
                }
            }]];
        }
    }];
}

#pragma mark -

- (NSString *)_conversationIdPathComponent
{
    if (_conversationIdPathComponent == nil)
        _conversationIdPathComponent = [[NSString alloc] initWithFormat:@"%lld", _conversationId];
    
    return _conversationIdPathComponent;
}

- (NSString *)_sendMessagePathForMessageId:(int32_t)__unused mid
{
    return nil;
}

- (NSString *)_sendMessagePathPrefix
{
    return nil;
}

- (void)subscribeToUpdates
{
    [super subscribeToUpdates];
    
    [ActionStageInstance() watchForPaths:@[
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/conversation", [self _conversationIdPathComponent]],
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]],
        @"/tg/conversation/*/failmessages",
        [[NSString alloc] initWithFormat:@"/tg/conversationReadApplied/(%@)", [self _conversationIdPathComponent]],
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesDeleted", [self _conversationIdPathComponent]],
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesChanged", [self _conversationIdPathComponent]],
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messageViews", [self _conversationIdPathComponent]],
        @"/tg/userdatachanges",
        @"/tg/userpresencechanges",
        @"/tg/contactlist",
        @"/as/updateRelativeTimestamps",
        @"downloadManagerStateChanged",
        @"/as/media/imageThumbnailUpdated",
        @"/tg/service/synchronizationstate",
        @"/tg/unreadCount",
        @"/tg/assets/currentWallpaperInfo",
        @"/tg/conversation/historyCleared",
        @"/tg/removedMediasForMessageIds",
        @"/tg/conversation/*/readmessageContents",
        @"/tg/calls/enabled",
        [NSString stringWithFormat:@"/messagesEditedInConversation/(%lld)", _conversationId],
        [NSString stringWithFormat:@"/tg/peerDraft/%lld", _conversationId],
    ] watcher:self];
    
    int networkState = [ActionStageInstance() requestActorStateNow:@"/tg/service/updatestate"] ? 1 : 0;
    if ([[TGTelegramNetworking instance] isUpdating])
        networkState |= 1;
    if ([[TGTelegramNetworking instance] isConnecting])
        networkState |= 2;
    if (![[TGTelegramNetworking instance] isNetworkAvailable])
        networkState |= 4;
    
    [self actionStageResourceDispatched:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:@(networkState)] arguments:nil];
    
    NSMutableDictionary *actorProgresses = [[NSMutableDictionary alloc] init];
    
    NSArray *sendMessageActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:[ActionStageInstance() genericStringForParametrizedPath:[self _sendMessagePathForMessageId:0]] prefix:[self _sendMessagePathPrefix] watcher:self];
    for (NSString *action in sendMessageActions)
    {
        TGModernSendMessageActor *actor = (TGModernSendMessageActor *)[ActionStageInstance() executingActorWithPath:action];
        if (actor.uploadProgress > -FLT_EPSILON)
        {
            actorProgresses[@(actor.preparedMessage.mid)] = @(actor.uploadProgress);
        }
    }
    
    if (actorProgresses.count != 0)
    {
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            [actorProgresses enumerateKeysAndObjectsUsingBlock:^(NSNumber *nMid, NSNumber *nProgress, __unused BOOL *stop)
            {
                _messageUploadProgress[(int32_t)[nMid intValue]] = [nProgress floatValue];
            }];
            
            [self _updateProgressForItemsInIndexSet:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, _items.count)] animated:false];
        }];
    }
}

- (void)_updateMessageItemsWithData:(NSArray *)items
{
    bool needsAuthors = _everyMessageNeedsAuthor;
    
    std::vector<int> requiredUsers;
    std::vector<int> requiredUsersItemIndices;
    
    NSMutableArray *requiredChannelPeerIds = [[NSMutableArray alloc] init];
    
    Class TGMessageModernConversationItemClass = [TGMessageModernConversationItem class];
    int index = -1;
    for (id item in items)
    {
        index++;
        
        if ([item isKindOfClass:TGMessageModernConversationItemClass])
        {
            TGMessageModernConversationItem *messageItem = item;
            
            bool didAddToQueue = false;
            bool needsAuthor = needsAuthors;
            
            if (messageItem->_message.mediaAttachments.count != 0)
            {
                for (TGMediaAttachment *attachment in messageItem->_message.mediaAttachments)
                {
                    switch (attachment.type)
                    {
                        case TGForwardedMessageMediaAttachmentType:
                        {
                            int64_t forwardPeerId = ((TGForwardedMessageMediaAttachment *)attachment).forwardPeerId;
                            if (TGPeerIdIsChannel(forwardPeerId)) {
                                [requiredChannelPeerIds addObject:@(forwardPeerId)];
                            } else {
                                requiredUsers.push_back((int32_t)forwardPeerId);
                            }
                            int32_t authorId = ((TGForwardedMessageMediaAttachment *)attachment).forwardAuthorUserId;
                            if (authorId != 0) {
                                requiredUsers.push_back(authorId);
                            }
                            
                            if (!didAddToQueue) {
                                requiredUsersItemIndices.push_back(index);
                                didAddToQueue = true;
                            }
                            
                            break;
                        }
                        case TGReplyMessageMediaAttachmentType:
                        {
                            TGMessage *replyMessage = ((TGReplyMessageMediaAttachment *)attachment).replyMessage;
                            int64_t replyPeerId = replyMessage.fromUid;
                            
                            if (TGPeerIdIsChannel(replyMessage.cid) && TGMessageSortKeySpace(replyMessage.sortKey) == TGMessageSpaceImportant) {
                                replyPeerId = replyMessage.cid;
                            }
                            
                            if (TGPeerIdIsChannel(replyPeerId)) {
                                [requiredChannelPeerIds addObject:@(replyPeerId)];
                            } else {
                                requiredUsers.push_back((int32_t)replyPeerId);
                            }
                            
                            if (!didAddToQueue)
                            {
                                requiredUsersItemIndices.push_back(index);
                                didAddToQueue = true;
                            }
                            
                            break;
                        }
                        case TGContactMediaAttachmentType:
                        {
                            if (((TGContactMediaAttachment *)attachment).uid != 0)
                                requiredUsers.push_back(((TGContactMediaAttachment *)attachment).uid);
                            
                            if (!didAddToQueue)
                            {
                                requiredUsersItemIndices.push_back(index);
                                didAddToQueue = true;
                            }
                            
                            break;
                        }
                        case TGActionMediaAttachmentType:
                        {
                            switch (((TGActionMediaAttachment *)attachment).actionType)
                            {
                                case TGMessageActionChatAddMember:
                                case TGMessageActionChatDeleteMember:
                                case TGMessageActionChannelInviter:
                                case TGMessageActionCustom:
                                {
                                    needsAuthor = true;
                                    
                                    NSArray *uids = ((TGActionMediaAttachment *)attachment).actionData[@"uids"];
                                    if (uids != nil) {
                                        for (NSNumber *nUid in uids) {
                                            requiredUsers.push_back([nUid intValue]);
                                            
                                            if (!didAddToQueue) {
                                                requiredUsersItemIndices.push_back(index);
                                                didAddToQueue = true;
                                            }
                                        }
                                    } else {
                                        int uid = [((TGActionMediaAttachment *)attachment).actionData[@"uid"] intValue];
                                        if (uid != 0)
                                        {
                                            requiredUsers.push_back(uid);
                                            
                                            if (!didAddToQueue)
                                            {
                                                requiredUsersItemIndices.push_back(index);
                                                didAddToQueue = true;
                                            }
                                        }
                                    }
                                    
                                    break;
                                }
                                case TGMessageActionChatEditTitle:
                                case TGMessageActionCreateChat:
                                case TGMessageActionChannelCreated:
                                case TGMessageActionCreateBroadcastList:
                                case TGMessageActionChatEditPhoto:
                                case TGMessageActionContactRegistered:
                                case TGMessageActionUserChangedPhoto:
                                case TGMessageActionEncryptedChatMessageLifetime:
                                case TGMessageActionEncryptedChatScreenshot:
                                case TGMessageActionEncryptedChatMessageScreenshot:
                                case TGMessageActionGameScore:
                                case TGMessageActionPhoneCall:
                                {
                                    needsAuthor = true;
                                    break;
                                }
                                default:
                                    break;
                            }
                            break;
                        }
                        case TGViaUserAttachmentType:
                        {
                            int32_t userId = ((TGViaUserAttachment *)attachment).userId;
                                if (userId != 0) {
                                requiredUsers.push_back(userId);
                                
                                if (!didAddToQueue) {
                                    requiredUsersItemIndices.push_back(index);
                                    didAddToQueue = true;
                                }
                            }
                            
                            break;
                        }
                        
                        default:
                            break;
                    }
                }
            }
            
            if (needsAuthor && messageItem->_author == nil)
            {
                int uid = (int)messageItem->_message.fromUid;
                if (uid != 0)
                {
                    requiredUsers.push_back(uid);
                    requiredUsersItemIndices.push_back(index);
                    didAddToQueue = true;
                }
            }
        }
    }
    
    std::shared_ptr<std::map<int, TGUser *> > pUsers = [TGDatabaseInstance() loadUsers:requiredUsers];
    NSDictionary *channels = requiredChannelPeerIds.count == 0 ? nil : [TGDatabaseInstance() loadChannels:requiredChannelPeerIds];
    
    for (int itemIndex : requiredUsersItemIndices)
    {
        TGMessageModernConversationItem *messageItem = items[itemIndex];
        auto it = pUsers->end();
        
        bool needsAuthor = needsAuthors;
        
        if (messageItem->_message.mediaAttachments.count != 0)
        {
            NSMutableArray *additionalUsers = [[NSMutableArray alloc] initWithCapacity:1];
            NSMutableArray *additionalConversations = [[NSMutableArray alloc] init];
            
            for (TGMediaAttachment *attachment in messageItem->_message.mediaAttachments)
            {
                switch (attachment.type)
                {
                    case TGForwardedMessageMediaAttachmentType:
                    {
                        int64_t forwardPeerId = ((TGForwardedMessageMediaAttachment *)attachment).forwardPeerId;
                        if (TGPeerIdIsChannel(forwardPeerId)) {
                            TGConversation *conversation = channels[@(forwardPeerId)];
                            if (conversation != nil) {
                                [additionalConversations addObject:conversation];
                            }
                        } else {
                            it = pUsers->find((int32_t)forwardPeerId);
                            if (it != pUsers->end())
                                [additionalUsers addObject:it->second];
                        }
                        int32_t authorId = ((TGForwardedMessageMediaAttachment *)attachment).forwardAuthorUserId;
                        if (authorId != 0) {
                            it = pUsers->find(authorId);
                            if (it != pUsers->end())
                                [additionalUsers addObject:it->second];
                        }
                        break;
                    }
                    case TGReplyMessageMediaAttachmentType:
                    {
                        TGMessage *replyMessage = ((TGReplyMessageMediaAttachment *)attachment).replyMessage;
                        int64_t replyPeerId = replyMessage.fromUid;
                        
                        if (TGPeerIdIsChannel(replyMessage.cid) && TGMessageSortKeySpace(replyMessage.sortKey) == TGMessageSpaceImportant) {
                            replyPeerId = replyMessage.cid;
                        }
                        
                        if (TGPeerIdIsChannel(replyPeerId)) {
                            TGConversation *conversation = channels[@(replyPeerId)];
                            if (conversation != nil) {
                                [additionalConversations addObject:conversation];
                            }
                        } else {
                            it = pUsers->find((int32_t)replyPeerId);
                            if (it != pUsers->end())
                                [additionalUsers addObject:it->second];
                        }
                        break;
                    }
                    case TGContactMediaAttachmentType:
                    {
                        int32_t contactUid = ((TGContactMediaAttachment *)attachment).uid;
                        if (contactUid == 0)
                        {
                            TGUser *contactUser = [[TGUser alloc] init];
                            contactUser.firstName = ((TGContactMediaAttachment *)attachment).firstName;
                            contactUser.lastName = ((TGContactMediaAttachment *)attachment).lastName;
                            contactUser.phoneNumber = ((TGContactMediaAttachment *)attachment).phoneNumber;
                            [additionalUsers addObject:contactUser];
                        }
                        else
                        {
                            TGUser *contactUser = [[TGUser alloc] init];
                            contactUser.firstName = ((TGContactMediaAttachment *)attachment).firstName;
                            contactUser.lastName = ((TGContactMediaAttachment *)attachment).lastName;
                            contactUser.phoneNumber = ((TGContactMediaAttachment *)attachment).phoneNumber;
                            contactUser.uid = contactUid;
                            
                            it = pUsers->find(contactUid);
                            if (it != pUsers->end())
                            {
                                contactUser.photoUrlSmall = it->second.photoUrlSmall;
                                contactUser.photoUrlMedium = it->second.photoUrlMedium;
                                contactUser.photoUrlBig = it->second.photoUrlBig;
                            }
                            
                            [additionalUsers addObject:contactUser];
                        }
                        
                        break;
                    }
                    case TGActionMediaAttachmentType:
                    {
                        switch (((TGActionMediaAttachment *)attachment).actionType)
                        {
                            case TGMessageActionChatAddMember:
                            case TGMessageActionChatDeleteMember:
                            case TGMessageActionChannelInviter:
                            case TGMessageActionCustom:
                            {
                                needsAuthor = true;
                                
                                NSArray *uids = ((TGActionMediaAttachment *)attachment).actionData[@"uids"];
                                if (uids != nil) {
                                    for (NSNumber *nUid in uids) {
                                        it = pUsers->find([nUid intValue]);
                                        if (it != pUsers->end()) {
                                            [additionalUsers addObject:it->second];
                                        }
                                    }
                                }
                                
                                int uid = [((TGActionMediaAttachment *)attachment).actionData[@"uid"] intValue];
                                it = pUsers->find(uid);
                                if (it != pUsers->end())
                                    [additionalUsers addObject:it->second];
                                break;
                            }
                            case TGMessageActionChatEditTitle:
                            case TGMessageActionChannelCreated:
                            case TGMessageActionCreateChat:
                            case TGMessageActionCreateBroadcastList:
                            case TGMessageActionChatEditPhoto:
                            case TGMessageActionContactRegistered:
                            case TGMessageActionUserChangedPhoto:
                            case TGMessageActionEncryptedChatMessageLifetime:
                            case TGMessageActionEncryptedChatScreenshot:
                            case TGMessageActionEncryptedChatMessageScreenshot:
                            case TGMessageActionGameScore:
                            {
                                needsAuthor = true;
                                break;
                            }
                            default:
                                break;
                        }
                        break;
                    }
                    case TGViaUserAttachmentType:
                    {
                        int32_t userId = ((TGViaUserAttachment *)attachment).userId;
                        if (userId != 0) {
                            it = pUsers->find(userId);
                            if (it != pUsers->end()) {
                                [additionalUsers addObject:it->second];
                            }
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
        
            if (additionalUsers.count != 0)
                messageItem->_additionalUsers = additionalUsers;
            if (additionalConversations.count != 0)
                messageItem->_additionalConversations = additionalConversations;
        }
        
        if (needsAuthor && messageItem->_message.fromUid != 0)
        {
            it = pUsers->find((int)messageItem->_message.fromUid);
            if (it != pUsers->end())
                messageItem->_author = it->second;
        }
    }
}

- (TGMessageModernConversationItem *)_updateMediaStatusData:(TGMessageModernConversationItem *)item
{
    static NSFileManager *fileManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        fileManager = [[NSFileManager alloc] init];
    });
    
    if (item->_message.mediaAttachments.count != 0)
    {
        for (TGMediaAttachment *attachment in item->_message.mediaAttachments)
        {
            switch (attachment.type)
            {
                case TGImageMediaAttachmentType:
                {
                    static TGCache *cache = nil;
                    
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^
                    {
                        cache = [TGRemoteImageView sharedCache];
                    });
                    
                    TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                    
                    NSString *url = [imageAttachment.imageInfo closestImageUrlWithSize:(CGSizeMake(1136, 1136)) resultingSize:NULL pickLargest:true];
                    
                    bool imageDownloaded = false;
                    
                    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
                    {
                        imageDownloaded = [[[TGMediaStoreContext instance] temporaryFilesCache] containsValueForKey:[url dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    else
                    {
                        if (imageAttachment.imageId != 0)
                        {
                            NSString *path = [TGPreparedRemoteImageMessage filePathForRemoteImageId:imageAttachment.imageId];
                            imageDownloaded = [fileManager fileExistsAtPath:path];
                        }
                        
                        if (!imageDownloaded)
                        {
                            NSString *path = [cache pathForCachedData:url];
                            if (path != nil)
                            {
                                imageDownloaded = ([url hasPrefix:@"upload/"] || [url hasPrefix:@"file://"]) ? true : [fileManager fileExistsAtPath:path];
                            }
                        }
                    }
                    
                    if (item->_mediaAvailabilityStatus != imageDownloaded)
                    {
                        TGMessageModernConversationItem *updatedItem = [item copy];
                        updatedItem->_mediaAvailabilityStatus = imageDownloaded;
                        return updatedItem;
                    }
                    
                    break;
                }
                case TGVideoMediaAttachmentType:
                {
                    TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                    
                    NSString *url = [videoAttachment.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL];
                    bool videoDownloaded = [TGVideoDownloadActor isVideoDownloaded:fileManager url:url];
                    
                    if (item->_mediaAvailabilityStatus != videoDownloaded)
                    {
                        TGMessageModernConversationItem *updatedItem = [item copy];
                        updatedItem->_mediaAvailabilityStatus = videoDownloaded;
                        return updatedItem;
                    }
                    
                    break;
                }
                case TGDocumentMediaAttachmentType:
                case TGWebPageMediaAttachmentType:
                case TGGameAttachmentType:
                {
                    TGDocumentMediaAttachment *documentAttachment = nil;
                    TGImageMediaAttachment *imageAttachment = nil;
                    
                    if (attachment.type == TGDocumentMediaAttachmentType) {
                        documentAttachment = (TGDocumentMediaAttachment *)attachment;
                    } else if (attachment.type == TGWebPageMediaAttachmentType) {
                        documentAttachment = ((TGWebPageMediaAttachment *)attachment).document;
                        imageAttachment = ((TGWebPageMediaAttachment *)attachment).photo;
                    } else if (attachment.type == TGGameAttachmentType) {
                        documentAttachment = ((TGGameMediaAttachment *)attachment).document;
                        imageAttachment = ((TGGameMediaAttachment *)attachment).photo;
                    } else if (attachment.type == TGInvoiceMediaAttachmentType) {
                        imageAttachment = [((TGInvoiceMediaAttachment *)attachment) webpage].photo;
                    }
                    
                    bool fileDownloaded = true;
                    
                    if (documentAttachment != nil) {
                        if (documentAttachment.localDocumentId != 0)
                        {
                            NSString *documentPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:documentAttachment.localDocumentId version:documentAttachment.version] stringByAppendingPathComponent:[documentAttachment safeFileName]];
                            fileDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:documentPath];
                        }
                        else
                        {
                            NSString *documentPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId version:documentAttachment.version] stringByAppendingPathComponent:[documentAttachment safeFileName]];
                            fileDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:documentPath];
                        }
                    } else if (imageAttachment != nil) {
                        static TGCache *cache = nil;
                        
                        static dispatch_once_t onceToken;
                        dispatch_once(&onceToken, ^
                        {
                            cache = [TGRemoteImageView sharedCache];
                        });
                        
                        NSString *url = [imageAttachment.imageInfo closestImageUrlWithSize:(CGSizeMake(1136, 1136)) resultingSize:NULL pickLargest:true];
                        
                        if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
                        {
                            fileDownloaded = [[[TGMediaStoreContext instance] temporaryFilesCache] containsValueForKey:[url dataUsingEncoding:NSUTF8StringEncoding]];
                        }
                        else
                        {
                            if (imageAttachment.imageId != 0)
                            {
                                NSString *path = [TGPreparedRemoteImageMessage filePathForRemoteImageId:imageAttachment.imageId];
                                fileDownloaded = [fileManager fileExistsAtPath:path];
                            }
                            
                            if (!fileDownloaded)
                            {
                                NSString *path = [cache pathForCachedData:url];
                                if (path != nil)
                                {
                                    fileDownloaded = ([url hasPrefix:@"upload/"] || [url hasPrefix:@"file://"]) ? true : [fileManager fileExistsAtPath:path];
                                }
                            }
                        }
                    }
                    
                    if (item->_mediaAvailabilityStatus != fileDownloaded)
                    {
                        TGMessageModernConversationItem *updatedItem = [item copy];
                        updatedItem->_mediaAvailabilityStatus = fileDownloaded;
                        return updatedItem;
                    }
                    
                    break;
                }
                case TGAudioMediaAttachmentType:
                {
                    TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                    
                    bool audioDownloaded = false;
                    if (audioAttachment.localAudioId != 0)
                    {
                        NSString *audioPath = [TGAudioMediaAttachment localAudioFilePathForLocalAudioId:audioAttachment.localAudioId];
                        audioDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:audioPath];
                    }
                    else
                    {
                        NSString *audioPath = [TGAudioMediaAttachment localAudioFilePathForRemoteAudioId:audioAttachment.audioId];
                        audioDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:audioPath];
                    }
                    
                    if (item->_mediaAvailabilityStatus != audioDownloaded)
                    {
                        TGMessageModernConversationItem *updatedItem = [item copy];
                        updatedItem->_mediaAvailabilityStatus = audioDownloaded;
                        return updatedItem;
                    }
                    
                    break;
                }
                case TGContactMediaAttachmentType:
                {
                    TGContactMediaAttachment *contactAttachment = (TGContactMediaAttachment *)attachment;
                    bool isContact = (contactAttachment.uid != 0 && [TGDatabaseInstance() uidIsRemoteContact:contactAttachment.uid]) || [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(contactAttachment.phoneNumber)] != nil;
                    
                    if (item->_mediaAvailabilityStatus != isContact)
                    {
                        TGMessageModernConversationItem *updatedItem = [item copy];
                        updatedItem->_mediaAvailabilityStatus = isContact;
                        return updatedItem;
                    }
                    
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    return nil;
}

- (void)_updateImportantMediaStatusDataInplace:(TGMessageModernConversationItem *)item
{
    if (item->_message.mediaAttachments.count != 0)
    {
        for (TGMediaAttachment *attachment in item->_message.mediaAttachments)
        {
            switch (attachment.type)
            {
                case TGContactMediaAttachmentType:
                {
                    TGContactMediaAttachment *contactAttachment = (TGContactMediaAttachment *)attachment;
                    bool isContact = (contactAttachment.uid != 0 && [TGDatabaseInstance() uidIsRemoteContact:contactAttachment.uid]) || [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(contactAttachment.phoneNumber)] != nil;
                    
                    if (item->_mediaAvailabilityStatus != isContact)
                    {
                        TGMessageModernConversationItem *updatedItem = [item copy];
                        updatedItem->_mediaAvailabilityStatus = isContact;
                        
                        [item updateToItem:updatedItem viewStorage:nil sizeChanged:NULL delayAvailability:false containerSize:CGSizeZero];
                    }
                    
                    break;
                }
                default:
                    break;
            }
        }
    }
}

#pragma mark -

- (void)controllerWantsToSendTextMessage:(NSString *)text entities:(NSArray *)entities asReplyToMessageId:(int32_t)replyMessageId withAttachedMessages:(NSArray *)withAttachedMessages disableLinkPreviews:(bool)disableLinkPreviews botContextResult:(TGBotContextResultAttachment *)botContextResult botReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup
{
    static const NSInteger messagePartLimit = 4096;
    NSMutableArray *preparedMessages = [[NSMutableArray alloc] init];
    
    TGMessage *replyMessage = nil;
    if (replyMessageId != 0)
        replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
    
    TGReplyMarkupAttachment *replyMarkup = nil;
    if (botReplyMarkup != nil) {
        replyMarkup = [[TGReplyMarkupAttachment alloc] init];
        replyMarkup.replyMarkup = botReplyMarkup;
    }
    
    TGWebPageMediaAttachment *parsedWebpage = nil;
    if ([self canAttachLinkPreviews] && !disableLinkPreviews && [self allowExternalContent] && ([self allowMessageForwarding] || TGAppDelegateInstance.allowSecretWebpages))
    {
        NSString *webpageLink = [TGModernConversationInputTextPanel linkCandidateInText:text];
        if (webpageLink != nil) {
            parsedWebpage = [TGUpdateStateRequestBuilder webPageWithLink:webpageLink];
            if (parsedWebpage == nil && [self encryptUploads]) {
                parsedWebpage = [[TGWebPageMediaAttachment alloc] init];
                int64_t randomId = 0;
                arc4random_buf(&randomId, 8);
                parsedWebpage.webPageLocalId = randomId;
                parsedWebpage.url = webpageLink;
            }
        }
    }
    
    if (entities.count == 0) {
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if (text.length != 0)
    {
        if (text.length <= messagePartLimit)
        {
            NSString *resultingText = text;
            NSArray *parsedEntities = entities == nil ? [TGMessage entitiesForMarkedUpText:text resultingText:&resultingText] : entities;
            TGPreparedTextMessage *preparedMessage = [[TGPreparedTextMessage alloc] initWithText:resultingText replyMessage:replyMessage disableLinkPreviews:disableLinkPreviews parsedWebpage:parsedWebpage entities:parsedEntities botContextResult:botContextResult replyMarkup:replyMarkup];
            preparedMessage.messageLifetime = [self messageLifetime];
            [preparedMessages addObject:preparedMessage];
        }
        else
        {
            for (NSUInteger i = 0; i < text.length; i += messagePartLimit)
            {
                NSString *substring = [text substringWithRange:NSMakeRange(i, MIN(messagePartLimit, text.length - i))];
                if (substring.length != 0)
                {
                    NSString *resultingText = substring;
                    NSArray *parsedEntities = entities == nil ? [TGMessage entitiesForMarkedUpText:substring resultingText:&resultingText] : entities;
                    TGPreparedTextMessage *preparedMessage = [[TGPreparedTextMessage alloc] initWithText:resultingText replyMessage:replyMessage disableLinkPreviews:disableLinkPreviews parsedWebpage:i == 0 ? parsedWebpage : nil entities:parsedEntities botContextResult:i == 0 ? botContextResult : nil replyMarkup:i == 0 ? replyMarkup : nil];
                    preparedMessage.messageLifetime = [self messageLifetime];
                    [preparedMessages addObject:preparedMessage];
                }
            }
        }
    }
    
    TGModernConversationController *controller = self.controller;
    [controller setEnableSendButton:false];
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        if (withAttachedMessages.count != 0)
        {
            [preparedMessages addObjectsFromArray:[self _createPreparedForwardMessagesFromMessages:withAttachedMessages]];
        }
        
        [self _sendPreparedMessages:preparedMessages automaticallyAddToList:true withIntent:TGSendMessageIntentSendText];
        
        
        [TGDatabaseInstance() updatePeerDraftInteractive:_conversationId draft:nil];
        [TGDatabaseInstance() storeConversationState:_conversationId messageEditingContext:nil forwardMessageDescs:@[] scrollState:nil];
        
        TGDispatchOnMainThread(^
        {
            [TGRecentHashtagsSignal addRecentHashtagsFromText:text space:TGHashtagSpaceEntered];
        });
    }];
}

- (void)controllerWantsToSendMapWithLatitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue asReplyToMessageId:(int32_t)replyMessageId botContextResult:(TGBotContextResultAttachment *)botContextResult botReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        TGMessage *replyMessage = nil;
        if (replyMessageId != 0)
            replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
        
        TGPreparedMapMessage *preparedMessage = [[TGPreparedMapMessage alloc] initWithLatitude:latitude longitude:longitude venue:venue replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
        preparedMessage.botContextResult = botContextResult;
        preparedMessage.messageLifetime = [self messageLifetime];
        [self _sendPreparedMessages:@[preparedMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (NSURL *)fileUrlForDocumentMedia:(TGDocumentMediaAttachment *)documentMedia
{
    if (documentMedia.localDocumentId != 0)
    {
        NSString *path = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:documentMedia.localDocumentId version:documentMedia.version] stringByAppendingPathComponent:documentMedia.safeFileName];
        return [NSURL fileURLWithPath:path];
    }
    
    NSString *path = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentMedia.documentId version:documentMedia.version] stringByAppendingPathComponent:documentMedia.safeFileName];
    return [NSURL fileURLWithPath:path];
}

- (NSDictionary *)imageDescriptionFromImage:(UIImage *)image stickers:(NSArray *)stickers caption:(NSString *)caption optionalAssetUrl:(NSString *)assetUrl allowRemoteCache:(bool)allowRemoteCache timer:(int32_t)timer
{
    if (image == nil)
        return nil;
    
    if (timer > 0) {
        allowRemoteCache = false;
    }
    
    NSDictionary *serverData = [self _shouldCacheRemoteAssetUris] ? [TGImageDownloadActor serverMediaDataForAssetUrl:assetUrl] : nil;
    if (serverData != nil && allowRemoteCache)
    {
        if ([serverData objectForKey:@"imageId"] != nil && [serverData objectForKey:@"imageAttachment"] != nil)
        {
            TGImageMediaAttachment *imageAttachment = [serverData objectForKey:@"imageAttachment"];
            if (imageAttachment != nil && imageAttachment.imageInfo != nil)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@
                {
                    @"imageId": @(imageAttachment.imageId),
                    @"accessHash": @(imageAttachment.accessHash),
                    @"imageInfo": imageAttachment.imageInfo
                }];
                
                if (caption != nil) {
                    dict[@"caption"] = caption;
                } else {
                    [dict removeObjectForKey:@"caption"];
                }
                
                if (timer != 0) {
                    dict[@"timer"] = @(timer);
                }
                
                return @{@"remoteImage": dict};
            }
        }
    }
    else
    {
        CGSize originalSize = image.size;
        originalSize.width *= image.scale;
        originalSize.height *= image.scale;
        
        CGSize imageSize = TGFitSize(originalSize, CGSizeMake(1280, 1280));
        CGSize thumbnailSize = TGFitSize(originalSize, CGSizeMake(90, 90));
        
        UIImage *fullImage = MAX(image.size.width, image.size.height) > 1280.0f ? TGScaleImageToPixelSize(image, imageSize) : image;
        NSData *imageData = UIImageJPEGRepresentation(fullImage, 0.52f);
        
        UIImage *previewImage = TGScaleImageToPixelSize(fullImage, TGFitSize(originalSize, [TGGenericModernConversationCompanion preferredInlineThumbnailSize]));
        NSData *thumbnailData = UIImageJPEGRepresentation(previewImage, 0.9f);
        
        previewImage = nil;
        fullImage = nil;
        
        if (imageData != nil && thumbnailData != nil)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@
            {
                @"imageSize": [NSValue valueWithCGSize:imageSize],
                @"thumbnailSize": [NSValue valueWithCGSize:thumbnailSize],
                @"imageData": imageData,
                @"thumbnailData": thumbnailData
            }];
            
            if (stickers != nil)
                dict[@"stickerDocuments"] = stickers;
            
            if (caption != nil)
                dict[@"caption"] = caption;
            
            if (assetUrl != nil)
                dict[@"assetUrl"] = assetUrl;
            
            if (timer != 0) {
                dict[@"timer"] = @(timer);
            }
            
            return @{@"localImage": dict};
        }
    }
    
    return nil;
}

- (NSDictionary *)imageDescriptionFromBingSearchResult:(TGBingSearchResultItem *)item caption:(NSString *)caption
{
    if (item != nil)
    {
        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
        [imageInfo addImageWithSize:item.imageSize url:item.imageUrl];
        [imageInfo addImageWithSize:item.previewSize url:item.previewUrl];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{@"imageInfo": imageInfo}];
        if (caption != nil)
            dict[@"caption"] = caption;
        
        return @{@"downloadImage": dict};
    }
    
    return nil;
}

- (NSDictionary *)imageDescriptionFromExternalImageSearchResult:(TGExternalImageSearchResult *)item text:(NSString *)text botContextResult:(TGBotContextResultAttachment *)botContextResult {
    if (item != nil && item.originalUrl.length != 0 && item.size.width > FLT_EPSILON && item.size.height > FLT_EPSILON)
    {
        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
        [imageInfo addImageWithSize:item.size url:item.originalUrl];
        if (item.thumbnailUrl.length != 0) {
            [imageInfo addImageWithSize:TGFitSize(item.size, CGSizeMake(90.0f, 90.0f)) url:item.thumbnailUrl];
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{
            @"searchResult": item,
            @"imageInfo": imageInfo,
            @"caption": text.length == 0 ? @"" : text
        }];
        
        if (botContextResult != nil) {
            dict[@"botContextResult"] = botContextResult;
        }
        
        return @{@"downloadExternalImage": dict};
    }
    
    return nil;
}

- (NSDictionary *)documentDescriptionFromGiphySearchResult:(TGGiphySearchResultItem *)item caption:(NSString *)caption
{
    if (item != nil && item.gifId.length != 0)
    {
        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
        [imageInfo addImageWithSize:item.previewSize url:item.previewUrl];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@
        {
            @"id": item.gifId,
            @"thumbnailInfo": imageInfo,
            @"url": item.gifUrl,
            @"fileSize": @(item.gifFileSize),
            @"attributes": @[[[TGDocumentAttributeFilename alloc] initWithFilename:@"animation.gif"], [[TGDocumentAttributeAnimated alloc] init]]
        }];
        
        if (caption.length > 0)
            dict[@"caption"] = caption;
        
        return @{ @"downloadDocument": dict };
    }
    
    return nil;
}

- (NSDictionary *)documentDescriptionFromExternalGifSearchResult:(TGExternalGifSearchResult *)item text:(NSString *)text botContextResult:(TGBotContextResultAttachment *)botContextResult {
    if (item != nil && item.originalUrl.length != 0)
    {
        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
        [imageInfo addImageWithSize:item.size url:item.thumbnailUrl];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{
            @"searchResult": item,
            @"thumbnailInfo": imageInfo,
            @"attributes": @[[[TGDocumentAttributeFilename alloc] initWithFilename:@"animation.mp4"], [[TGDocumentAttributeAnimated alloc] init]]
        }];
        if (text.length != 0) {
            dict[@"caption"] = text;
        }
        
        if (botContextResult != nil) {
            dict[@"botContextResult"] = botContextResult;
        }
        return @{@"downloadExternalGif": dict};
    }
    
    return nil;
}

- (NSDictionary *)documentDescriptionFromBotContextResult:(TGBotContextResult *)result text:(NSString *)text botContextResult:(TGBotContextResultAttachment *)botContextResult {
    if ([result isKindOfClass:[TGBotContextExternalResult class]]) {
        TGBotContextExternalResult *externalResult = (TGBotContextExternalResult *)result;
        if (externalResult.originalUrl.length != 0) {
            TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
            [imageInfo addImageWithSize:externalResult.size url:externalResult.thumbUrl];
            
            NSMutableArray *attributes = [[NSMutableArray alloc] init];
            NSString *fileName = nil;
            NSURL *url = [NSURL URLWithString:externalResult.originalUrl];
            if (url != nil) {
                fileName = [url lastPathComponent];
            }
            if (fileName.length == 0) {
                fileName = @"file";
                NSString *extension = [TGMimeTypeMap extensionForMimeType:externalResult.contentType];
                if (extension.length != 0) {
                    fileName = [fileName stringByAppendingPathExtension:extension];
                }
            }
            
            [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:fileName]];
            
            if ([externalResult.type isEqualToString:@"audio"] || [externalResult.type isEqualToString:@"voice"]) {
                [attributes addObject:[[TGDocumentAttributeAudio alloc] initWithIsVoice:[externalResult.type isEqualToString:@"voice"] title:externalResult.title performer:externalResult.pageDescription duration:externalResult.duration waveform:nil]];
            }
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{
                @"attributes": attributes,
                @"thumbnailInfo": imageInfo,
            }];
            
            if (text.length != 0) {
                dict[@"caption"] = text;
            }
            
            dict[@"result"] = result;
            
            if (botContextResult != nil) {
                dict[@"botContextResult"] = botContextResult;
            }
            return @{@"downloadExternalDocument": dict};
        }
    }
    return nil;
}

- (NSDictionary *)imageDescriptionFromMediaAsset:(TGMediaAsset *)asset previewImage:(UIImage *)previewImage document:(bool)document fileName:(NSString *)fileName caption:(NSString *)caption allowRemoteCache:(bool)__unused allowRemoteCache
{
    if (asset == nil)
        return nil;
    
    NSData *thumbnailData = UIImageJPEGRepresentation(previewImage, 0.54f);
    CGSize dimensions = asset.dimensions;
    if (CGSizeEqualToSize(dimensions, CGSizeZero))
        dimensions = previewImage.size;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@
    {
        @"assetIdentifier": asset.uniqueIdentifier,
        @"thumbnailData": thumbnailData,
        @"thumbnailSize": [NSValue valueWithCGSize:dimensions],
        @"document": @(document)
    }];
    
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    if (fileName.length > 0)
        [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:fileName]];
    
    if (document && attributes.count > 0)
        dict[@"attributes"] = attributes;
    
    if (caption != nil)
        dict[@"caption"] = caption;
    
    return @{@"assetImage": dict};
}

- (NSDictionary *)videoDescriptionFromMediaAsset:(TGMediaAsset *)asset previewImage:(UIImage *)previewImage adjustments:(TGVideoEditAdjustments *)adjustments document:(bool)document fileName:(NSString *)fileName stickers:(NSArray *)stickers caption:(NSString *)caption timer:(int32_t)timer
{
    if (asset == nil)
        return nil;
    
    NSData *thumbnailData = UIImageJPEGRepresentation(previewImage, 0.54f);
    
    NSTimeInterval duration = asset.videoDuration;
    CGSize dimensions = asset.dimensions;
    if (!CGSizeEqualToSize(dimensions, CGSizeZero))
        dimensions = TGFitSize(dimensions, CGSizeMake(640, 640));
    else
        dimensions = TGFitSize(previewImage.size, CGSizeMake(640, 640));

    if (adjustments != nil)
    {
        if (adjustments.trimApplied)
            duration = adjustments.trimEndValue - adjustments.trimStartValue;
        if ([adjustments cropAppliedForAvatar:false])
        {
            CGSize size = adjustments.cropRect.size;
            if (adjustments.cropOrientation != UIImageOrientationUp && adjustments.cropOrientation != UIImageOrientationDown)
                size = CGSizeMake(size.height, size.width);
            dimensions = TGFitSize(size, CGSizeMake(640, 640));
        }
    }
    
    bool isAnimation = adjustments.sendAsGif;
    
    if (timer > 0 && timer <= 60) {
        isAnimation = false;
        document = false;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@
    {
        @"assetIdentifier": asset.uniqueIdentifier,
        @"duration": @(duration),
        @"dimensions": [NSValue valueWithCGSize:dimensions],
        @"thumbnailData": thumbnailData,
        @"thumbnailSize": [NSValue valueWithCGSize:dimensions],
        @"document": @((document || isAnimation))
    }];
    
    if (adjustments != nil)
        dict[@"adjustments"] = adjustments;
    
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    if (isAnimation)
    {
        dict[@"mimeType"] = @"video/mp4";
        [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:@"animation.mp4"]];
        [attributes addObject:[[TGDocumentAttributeAnimated alloc] init]];
    }
    else
    {
        if (fileName.length > 0)
            [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:fileName]];
    }
    
    if (!document)
        [attributes addObject:[[TGDocumentAttributeVideo alloc] initWithRoundMessage:false size:dimensions duration:(int32_t)duration]];
    
    if ((document || isAnimation) && attributes.count > 0)
        dict[@"attributes"] = attributes;
    
    if (caption != nil)
        dict[@"caption"] = caption;
    
    if (stickers != nil)
        dict[@"stickerDocuments"] = stickers;
    
    if (timer != 0) {
        dict[@"timer"] = @(timer);
    }
    
    return @{@"assetVideo": dict};
}

- (NSDictionary *)videoDescriptionFromVideoURL:(NSURL *)videoURL previewImage:(UIImage *)previewImage dimensions:(CGSize)dimensions duration:(NSTimeInterval)duration adjustments:(TGVideoEditAdjustments *)adjustments stickers:(NSArray *)stickers caption:(NSString *)caption roundMessage:(bool)roundMessage liveUploadData:(id)liveUploadData timer:(int32_t)timer
{
    if (videoURL == nil)
        return nil;
    
    NSData *thumbnailData = UIImageJPEGRepresentation(previewImage, 0.54f);
    
    NSTimeInterval finalDuration = duration;
    CGSize finalDimensions = dimensions;
    if (!CGSizeEqualToSize(dimensions, CGSizeZero))
        finalDimensions = TGFitSize(dimensions, CGSizeMake(640, 640));
    else
        finalDimensions = TGFitSize(previewImage.size, CGSizeMake(640, 640));
    
    if (adjustments != nil)
    {
        if (adjustments.trimApplied)
            finalDuration = adjustments.trimEndValue - adjustments.trimStartValue;
        if ([adjustments cropAppliedForAvatar:false])
        {
            CGSize size = adjustments.cropRect.size;
            if (adjustments.cropOrientation != UIImageOrientationUp && adjustments.cropOrientation != UIImageOrientationDown)
                size = CGSizeMake(size.height, size.width);
            finalDimensions = TGFitSize(size, CGSizeMake(640, 640));
        }
    }
    
    bool isAnimation = adjustments.sendAsGif;
    if (timer > 0 && timer <= 60) {
        isAnimation = false;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@
    {
        @"videoURL": videoURL,
        @"duration": @(finalDuration),
        @"dimensions": [NSValue valueWithCGSize:finalDimensions],
        @"thumbnailData": thumbnailData,
        @"thumbnailSize": [NSValue valueWithCGSize:finalDimensions],
        @"document": @(isAnimation),
        @"roundMessage": @(roundMessage)
    }];
    
    if (adjustments != nil)
        dict[@"adjustments"] = adjustments;
    
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    if (isAnimation)
    {
        dict[@"mimeType"] = @"video/mp4";
        [attributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:@"animation.mp4"]];
        [attributes addObject:[[TGDocumentAttributeAnimated alloc] init]];
        
        dict[@"attributes"] = attributes;
    }
    
    [attributes addObject:[[TGDocumentAttributeVideo alloc] initWithRoundMessage:roundMessage size:dimensions duration:(int32_t)duration]];
    
    if (caption != nil)
        dict[@"caption"] = caption;
    
    if (stickers != nil)
        dict[@"stickerDocuments"] = stickers;
    
    if (liveUploadData != nil)
        dict[@"liveUploadData"] = liveUploadData;
    
    if (timer != 0) {
        dict[@"timer"] = @(timer);
    }
    
    return @{@"cameraVideo": dict};
}

- (NSDictionary *)documentDescriptionFromICloudDriveItem:(TGICloudItem *)item
{
    if (item == nil || item.fileUrl == nil)
        return nil;
    
    NSMutableArray *documentAttributes = [[NSMutableArray alloc] init];
    [documentAttributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:item.fileName]];
    
    //if ([item.fileName hasSuffix:@".webp"])
    //    [documentAttributes addObject:[[TGDocumentAttributeSticker alloc] init]];
    
    NSDictionary *description =
    @{
      @"cloudDocument": @{
        @"id": item.fileId,
        @"url": item.fileUrl,
        @"fileSize": @(item.fileSize),
        @"mimeType": TGMimeTypeForFileExtension(item.fileName.pathExtension),
        @"attributes": documentAttributes
        }
    };
    
    return description;
}

- (NSDictionary *)documentDescriptionFromDropboxItem:(TGDropboxItem *)item
{
    if (item == nil || item.fileUrl == nil)
        return nil;
    
    NSMutableArray *documentAttributes = [[NSMutableArray alloc] init];
    [documentAttributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:item.fileName]];
    
    //if ([item.fileName hasSuffix:@".webp"])
    //    [documentAttributes addObject:[[TGDocumentAttributeSticker alloc] init]];
    
    NSMutableDictionary *downloadDocument = [NSMutableDictionary dictionaryWithDictionary:@
    {
        @"id": @"", //item.fileId,
        @"url": [item.fileUrl absoluteString],
        @"fileSize": @(item.fileSize),
        @"mimeType": TGMimeTypeForFileExtension(item.fileName.pathExtension),
        @"attributes": documentAttributes
    }];
    
    if (item.previewUrl != nil)
    {
        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
        [imageInfo addImageWithSize:item.previewSize url:item.previewUrl.absoluteString];
        downloadDocument[@"thumbnailInfo"] = imageInfo;
    }
    
    return @{ @"downloadDocument": downloadDocument };
}

- (NSDictionary *)documentDescriptionFromGoogleDriveItem:(TGGoogleDriveItem *)item
{
    if (item == nil || item.fileUrl == nil)
        return nil;
    
    NSMutableArray *documentAttributes = [[NSMutableArray alloc] init];
    [documentAttributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:item.fileName]];
    
//    if ([item.fileName hasSuffix:@".webp"] && !CGSizeEqualToSize(item.imageSize, CGSizeZero))
//    {
//        [documentAttributes addObject:[[TGDocumentAttributeSticker alloc] init]];
//        [documentAttributes addObject:[[TGDocumentAttributeImageSize alloc] initWithSize:item.imageSize]];
//    }
    
    NSMutableDictionary *downloadDocument = [NSMutableDictionary dictionaryWithDictionary:@
    {
        @"id": item.fileId,
        @"url": [item.fileUrl absoluteString],
        @"fileSize": @(item.fileSize),
        @"mimeType": item.mimeType.length > 0 ? item.mimeType : TGMimeTypeForFileExtension(item.fileName.pathExtension),
        @"attributes": documentAttributes
    }];
    
    if (item.previewUrl != nil)
    {
        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
        [imageInfo addImageWithSize:item.previewSize url:item.previewUrl.absoluteString];
        downloadDocument[@"thumbnailInfo"] = imageInfo;
    }
    
    return @{ @"downloadDocument": downloadDocument };
}

- (NSDictionary *)imageDescriptionFromInternalSearchImageResult:(TGWebSearchInternalImageResult *)item caption:(NSString *)caption
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{ @"imageId": @(item.imageId),
                                                                                   @"accessHash": @(item.accessHash),
                                                                                   @"imageInfo": item.imageInfo}];
    if (caption != nil)
        dict[@"caption"] = caption;
    
    return @{ @"remoteImage": dict };
}

- (NSDictionary *)documentDescriptionFromInternalSearchResult:(TGWebSearchInternalGifResult *)item caption:(NSString *)caption
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@
    {
        @"documentId": @(item.documentId),
        @"accessHash": @(item.accessHash),
        @"size": @(item.size),
        @"attributes": @[[[TGDocumentAttributeFilename alloc] initWithFilename:item.fileName]],
        @"mimeType": item.mimeType,
        @"thumbnailInfo": item.thumbnailInfo
    }];
    
    if (caption != nil)
        dict[@"caption"] = caption;
    
    return @{ @"remoteDocument": dict };
}

- (NSDictionary *)documentDescriptionFromRemoteDocument:(TGDocumentMediaAttachment *)document {
    return @{@"remoteCachedDocument": document};
}

- (NSDictionary *)documentDescriptionFromFileAtTempUrl:(NSURL *)url fileName:(NSString *)fileName mimeType:(NSString *)mimeType isAnimation:(bool)isAnimation caption:(NSString *)caption
{
    NSMutableDictionary *desc = [[NSMutableDictionary alloc] init];
    desc[@"url"] = url;
    if (fileName.length != 0)
        desc[@"fileName"] = fileName;
    
    if (mimeType.length != 0)
        desc[@"mimeType"] = mimeType;
    
    desc[@"isAnimation"] = @(isAnimation);
    
    if (caption != nil)
        desc[@"caption"] = caption;
    
    desc[@"forceAsFile"] = @true;
    
    return desc;
}

- (void)_addRecentHashtagsFromText:(NSString *)text
{
    if (text.length == 0)
        return;
    
    TGDispatchOnMainThread(^
    {
        [TGRecentHashtagsSignal addRecentHashtagsFromText:text space:TGHashtagSpaceEntered];
    });
}

- (void)controllerWantsToSendImagesWithDescriptions:(NSArray *)imageDescriptions asReplyToMessageId:(int32_t)replyMessageId botReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        TGMessage *replyMessage = nil;
        if (replyMessageId != 0)
            replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
        
        NSMutableArray *preparedMessages = [[NSMutableArray alloc] init];
        
        for (NSDictionary *imageDescription in imageDescriptions)
        {
            if (imageDescription[@"localImage"] != nil)
            {
                NSDictionary *localImage = imageDescription[@"localImage"];
                TGPreparedLocalImageMessage *imageMessage = [TGPreparedLocalImageMessage messageWithImageData:localImage[@"imageData"] imageSize:[localImage[@"imageSize"] CGSizeValue] thumbnailData:localImage[@"thumbnailData"] thumbnailSize:[localImage[@"thumbnailSize"] CGSizeValue] assetUrl:localImage[@"assetUrl"] caption:localImage[@"caption"] replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup] stickerDocuments:localImage[@"stickerDocuments"] messageLifetime:[self messageLifetime]];
                imageMessage.messageLifetime = localImage[@"timer"] != nil ? [localImage[@"timer"] intValue] : [self messageLifetime];
                
                [preparedMessages addObject:imageMessage];
                
                [self _addRecentHashtagsFromText:localImage[@"caption"]];
            }
            else if (imageDescription[@"remoteImage"] != nil)
            {
                NSDictionary *remoteImage = imageDescription[@"remoteImage"];
                TGPreparedRemoteImageMessage *imageMessage = [[TGPreparedRemoteImageMessage alloc] initWithImageId:[remoteImage[@"imageId"] longLongValue] accessHash:[remoteImage[@"accessHash"] longLongValue] imageInfo:remoteImage[@"imageInfo"] caption:remoteImage[@"caption"] replyMessage:replyMessage botContextResult:imageDescription[@"botContextResult"] replyMarkup: botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
                
                [preparedMessages addObject:imageMessage];
                
                [self _addRecentHashtagsFromText:remoteImage[@"caption"]];
            }
            else if (imageDescription[@"downloadImage"] != nil)
            {
                NSDictionary *downloadImage = imageDescription[@"downloadImage"];
                TGImageInfo *imageInfo = downloadImage[@"imageInfo"];
                
                TGImageMediaAttachment *imageAttachment = [TGModernSendCommonMessageActor remoteImageByRemoteUrl:[imageInfo imageUrlForLargestSize:NULL]];
                if ([self controllerShouldCacheServerAssets] && imageAttachment != nil)
                {
                    TGPreparedRemoteImageMessage *remoteImageMessage = [[TGPreparedRemoteImageMessage alloc] initWithImageId:imageAttachment.imageId accessHash:imageAttachment.accessHash imageInfo:imageAttachment.imageInfo caption:downloadImage[@"caption"] replyMessage:replyMessage botContextResult:imageDescription[@"botContextResult"] replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
                    
                    [preparedMessages addObject:remoteImageMessage];
                }
                else
                {
                    TGPreparedDownloadImageMessage *downloadImageMessage = [[TGPreparedDownloadImageMessage alloc] initWithImageInfo:imageInfo caption:downloadImage[@"caption"] replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
                    
                    [preparedMessages addObject:downloadImageMessage];
                }
                
                [self _addRecentHashtagsFromText:downloadImage[@"caption"]];
            }
            else if (imageDescription[@"downloadDocument"] != nil)
            {
                NSDictionary *downloadDocument = imageDescription[@"downloadDocument"];
                
                TGDocumentMediaAttachment *documentAttachment = [TGModernSendCommonMessageActor remoteDocumentByGiphyId:downloadDocument[@"id"]];
                if ([self controllerShouldCacheServerAssets] && documentAttachment != nil)
                {
                    TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment replyMessage:replyMessage botContextResult:imageDescription[@"botContextResult"] replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
                    [preparedMessages addObject:remoteDocumentMessage];
                }
                else
                {
                    int64_t localDocumentId = 0;
                    arc4random_buf(&localDocumentId, 8);
                    TGPreparedDownloadDocumentMessage *downloadDocumentMessage = [[TGPreparedDownloadDocumentMessage alloc] initWithGiphyId:downloadDocument[@"id"] documentUrl:downloadDocument[@"url"] localDocumentId:localDocumentId mimeType:@"image/gif" size:[downloadDocument[@"fileSize"] intValue] thumbnailInfo:downloadDocument[@"thumbnailInfo"] attributes:downloadDocument[@"attributes"] replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
                    
                    [preparedMessages addObject:downloadDocumentMessage];
                }
            }
            else if (imageDescription[@"downloadExternalGif"] != nil) {
                NSDictionary *desc = imageDescription[@"downloadExternalGif"];
                
                int64_t localDocumentId = 0;
                arc4random_buf(&localDocumentId, 8);
                TGPreparedDownloadExternalGifMessage *downloadExternalGifMessage = [[TGPreparedDownloadExternalGifMessage alloc] initWithSearchResult:desc[@"searchResult"] localDocumentId:localDocumentId mimeType:@"video/mp4" thumbnailInfo:desc[@"thumbnailInfo"] attributes:desc[@"attributes"] caption:desc[@"caption"] replyMessage:replyMessage botContextResult:desc[@"botContextResult"] replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
                
                [preparedMessages addObject:downloadExternalGifMessage];
            }
            else if (imageDescription[@"downloadExternalImage"] != nil) {
                NSDictionary *desc = imageDescription[@"downloadExternalImage"];
                
                TGPreparedDownloadExternalImageMessage *downloadExternalImageMessage = [[TGPreparedDownloadExternalImageMessage alloc] initWithSearchResult:desc[@"searchResult"] imageInfo:desc[@"imageInfo"] caption:desc[@"caption"] replyMessage:replyMessage botContextResult:desc[@"botContextResult"] replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
                
                [preparedMessages addObject:downloadExternalImageMessage];
            }
            else if (imageDescription[@"downloadExternalDocument"] != nil) {
                NSDictionary *desc = imageDescription[@"downloadExternalDocument"];
                TGBotContextResult *botContextResult = desc[@"result"];
                
                if ([botContextResult isKindOfClass:[TGBotContextExternalResult class]]) {
                    TGBotContextExternalResult *externalResult = (TGBotContextExternalResult *)botContextResult;
                    int64_t localDocumentId = 0;
                    arc4random_buf(&localDocumentId, 8);
                    TGPreparedDownloadExternalDocumentMessage *downloadExternalDocumentMessage = [[TGPreparedDownloadExternalDocumentMessage alloc] initWithLocalDocumentId:localDocumentId documentUrl:externalResult.originalUrl mimeType:externalResult.contentType thumbnailInfo:desc[@"thumbnailInfo"] attributes:desc[@"attributes"] caption:desc[@"caption"] replyMessage:replyMessage botContextResult:desc[@"botContextResult"] replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
                    [preparedMessages addObject:downloadExternalDocumentMessage];
                }
            }
            else if (imageDescription[@"remoteDocument"] != nil)
            {
                NSDictionary *remoteDocument = imageDescription[@"remoteDocument"];
                TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
                documentAttachment.documentId = [remoteDocument[@"documentId"] longLongValue];
                documentAttachment.accessHash = [remoteDocument[@"accessHash"] longLongValue];
                documentAttachment.size = [remoteDocument[@"size"] intValue];
                documentAttachment.attributes = remoteDocument[@"attributes"];
                documentAttachment.mimeType = remoteDocument[@"mimeType"];
                documentAttachment.thumbnailInfo = remoteDocument[@"thumbnailInfo"];
                
                TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment replyMessage:replyMessage botContextResult:imageDescription[@"botContextResult"] replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
                [preparedMessages addObject:remoteDocumentMessage];
            }
            else if (imageDescription[@"remoteCachedDocument"] != nil) {
                TGDocumentMediaAttachment *documentAttachment = imageDescription[@"remoteCachedDocument"];
                TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment replyMessage:replyMessage botContextResult:imageDescription[@"botContextResult"] replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
                [preparedMessages addObject:remoteDocumentMessage];
            }
            else if (imageDescription[@"assetImage"] != nil)
            {
                NSDictionary *assetImage = imageDescription[@"assetImage"];
                
                bool asDocument = [assetImage[@"document"] boolValue];
                int64_t localDocumentId = 0;
                if (asDocument)
                    arc4random_buf(&localDocumentId, 8);
                
                int32_t timer = [imageDescription[@"timer"] intValue];

                TGPreparedAssetImageMessage *assetImageMessage = [[TGPreparedAssetImageMessage alloc] initWithAssetIdentifier:assetImage[@"assetIdentifier"] imageInfo:nil caption:assetImage[@"caption"] useMediaCache:[self controllerShouldCacheServerAssets] && timer <= 0 isCloud:[assetImage[@"cloud"] boolValue] document:asDocument localDocumentId:localDocumentId fileSize:INT_MAX mimeType:assetImage[@"mimeType"] attributes:assetImage[@"attributes"] replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup] messageLifetime:timer != 0 ? timer : [self messageLifetime]];
                assetImageMessage.uploadQueue = [self mediaUploadQueue];
                [assetImageMessage setImageInfoWithThumbnailData:assetImage[@"thumbnailData"] thumbnailSize:[assetImage[@"thumbnailSize"] CGSizeValue]];
                [preparedMessages addObject:assetImageMessage];
            }
            else if (imageDescription[@"assetVideo"] != nil)
            {
                NSDictionary *assetVideo = imageDescription[@"assetVideo"];
                
                bool asDocument = [assetVideo[@"document"] boolValue];
                int64_t localId = 0;
                arc4random_buf(&localId, 8);
                int64_t localVideoId = asDocument ? 0 : localId;
                int64_t localDocumentId = asDocument ? localId : 0;
                
                TGPreparedAssetVideoMessage *assetVideoMessage = [[TGPreparedAssetVideoMessage alloc] initWithAssetIdentifier:assetVideo[@"assetIdentifier"] assetURL:nil localVideoId:localVideoId imageInfo:nil duration:[assetVideo[@"duration"] doubleValue] dimensions:[assetVideo[@"dimensions"] CGSizeValue] adjustments:[assetVideo[@"adjustments"] dictionary] useMediaCache:[self controllerShouldCacheServerAssets] liveUpload:[self controllerShouldLiveUploadVideo] passthrough:false caption:assetVideo[@"caption"] isCloud:[assetVideo[@"cloud"] boolValue] document:asDocument localDocumentId:localDocumentId fileSize:INT_MAX mimeType:assetVideo[@"mimeType"] attributes:assetVideo[@"attributes"] replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup] stickerDocuments:assetVideo[@"stickerDocuments"] roundMessage:false];
                assetVideoMessage.messageLifetime = assetVideo[@"timer"] != nil ? [assetVideo[@"timer"] intValue] : [self messageLifetime];
                assetVideoMessage.uploadQueue = [self mediaUploadQueue];
                [assetVideoMessage setImageInfoWithThumbnailData:assetVideo[@"thumbnailData"] thumbnailSize:[assetVideo[@"thumbnailSize"] CGSizeValue]];
                [preparedMessages addObject:assetVideoMessage];
            }
            else if (imageDescription[@"cameraVideo"] != nil)
            {
                NSDictionary *cameraVideo = imageDescription[@"cameraVideo"];
                
                bool asDocument = [cameraVideo[@"document"] boolValue];
                int64_t localId = 0;
                arc4random_buf(&localId, 8);
                int64_t localVideoId = asDocument ? 0 : localId;
                int64_t localDocumentId = asDocument ? localId : 0;
                
                TGPreparedAssetVideoMessage *assetVideoMessage = [[TGPreparedAssetVideoMessage alloc] initWithAssetIdentifier:nil assetURL:cameraVideo[@"videoURL"] localVideoId:localVideoId imageInfo:nil duration:[cameraVideo[@"duration"] doubleValue] dimensions:[cameraVideo[@"dimensions"] CGSizeValue] adjustments:[cameraVideo[@"adjustments"] dictionary] useMediaCache:[self controllerShouldCacheServerAssets] liveUpload:[self controllerShouldLiveUploadVideo] passthrough:false caption:cameraVideo[@"caption"] isCloud:false document:asDocument localDocumentId:localDocumentId fileSize:INT_MAX mimeType:cameraVideo[@"mimeType"] attributes:cameraVideo[@"attributes"] replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup] stickerDocuments:cameraVideo[@"stickerDocuments"] roundMessage:[cameraVideo[@"roundMessage"] boolValue]];
                assetVideoMessage.messageLifetime = cameraVideo[@"timer"] != nil ? [cameraVideo[@"timer"] intValue] : [self messageLifetime];
                assetVideoMessage.uploadQueue = [self mediaUploadQueue];
                [assetVideoMessage setImageInfoWithThumbnailData:cameraVideo[@"thumbnailData"] thumbnailSize:[cameraVideo[@"thumbnailSize"] CGSizeValue]];
                assetVideoMessage.liveData = cameraVideo[@"liveUploadData"];
                [preparedMessages addObject:assetVideoMessage];
            }
        }
        
        if (preparedMessages != nil)
            [self _sendPreparedMessages:preparedMessages automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)controllerWantsToSendLocalVideoWithTempFilePath:(NSString *)tempVideoFilePath fileSize:(int32_t)fileSize previewImage:(UIImage *)previewImage duration:(NSTimeInterval)duration dimensions:(CGSize)dimenstions caption:(NSString *)caption assetUrl:(NSString *)assetUrl liveUploadData:(TGLiveUploadActorData *)liveUploadData asReplyToMessageId:(int32_t)replyMessageId botReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup
{
    TGMessage *replyMessage = nil;
    if (replyMessageId != 0)
        replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
    
    TGPreparedLocalVideoMessage *videoMessage = [TGPreparedLocalVideoMessage messageWithTempVideoPath:tempVideoFilePath videoSize:dimenstions size:fileSize duration:duration previewImage:previewImage thumbnailSize:TGFitSize(CGSizeMake(previewImage.size.width * previewImage.scale, previewImage.size.height * previewImage.scale), [TGGenericModernConversationCompanion preferredInlineThumbnailSize]) assetUrl:assetUrl caption:caption replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
    videoMessage.liveData = liveUploadData;
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [self _sendPreparedMessages:@[videoMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
        
        [self _addRecentHashtagsFromText:caption];
    }];
}

- (TGVideoMediaAttachment *)serverCachedAssetWithId:(NSString *)assetId
{
    return [TGImageDownloadActor serverMediaDataForAssetUrl:assetId][@"videoAttachment"];
}

- (void)controllerWantsToSendDocumentWithTempFileUrl:(NSURL *)tempFileUrl fileName:(NSString *)fileName mimeType:(NSString *)mimeType asReplyToMessageId:(int32_t)replyMessageId
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        NSMutableDictionary *desc = [[NSMutableDictionary alloc] init];
        desc[@"url"] = tempFileUrl;
        if (fileName.length != 0)
            desc[@"fileName"] = fileName;
        
        if (mimeType.length != 0)
            desc[@"mimeType"] = mimeType;
        
        desc[@"forceAsFile"] = @true;
        
        [self _sendPreparedMessages:[self _createPreparedMessagesFromFiles:@[desc] asReplyToMessageId:replyMessageId] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)controllerWantsToSendDocumentsWithDescriptions:(NSArray *)descriptions asReplyToMessageId:(int32_t)replyMessageId
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [self _sendPreparedMessages:[self _createPreparedMessagesFromFiles:descriptions asReplyToMessageId:replyMessageId] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)controllerWantsToSendRemoteDocument:(TGDocumentMediaAttachment *)document asReplyToMessageId:(int32_t)replyMessageId text:(NSString *)text botContextResult:(TGBotContextResultAttachment *)botContextResult botReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        
        TGMessage *replyMessage = nil;
        if (replyMessageId != 0)
            replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
        if (replyMessage != nil)
        {
            TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
            replyMedia.replyMessageId = replyMessage.mid;
            replyMedia.replyMessage = replyMessage;
            [attachments addObject:replyMedia];
        }
        
        TGDocumentMediaAttachment *documentWithCaption = [document copy];
        documentWithCaption.caption = text;
        
        [attachments addObject:documentWithCaption];
        
        if (botContextResult != nil) {
            [attachments addObject:botContextResult];
        }
        
        if (botReplyMarkup != nil) {
            [attachments addObject:[[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
        }
        
        TGMessage *message = [[TGMessage alloc] init];
        message.mediaAttachments = attachments;
        [self _sendPreparedMessages:[self _createPreparedMessagesFromMessages:@[message] copyAssetsData:true] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)controllerWantsToSendRemoteImage:(TGImageMediaAttachment *)image text:(NSString *)text asReplyToMessageId:(int32_t)replyMessageId botContextResult:(TGBotContextResultAttachment *)botContextResult botReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup {
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        
        TGMessage *replyMessage = nil;
        if (replyMessageId != 0)
            replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
        if (replyMessage != nil)
        {
            TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
            replyMedia.replyMessageId = replyMessage.mid;
            replyMedia.replyMessage = replyMessage;
            [attachments addObject:replyMedia];
        }
        
        if (botContextResult != nil) {
            [attachments addObject:botContextResult];
        }
        
        if (botReplyMarkup != nil) {
            [attachments addObject:[[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
        }
        
        TGImageMediaAttachment *imageWithCaption = [image copy];
        imageWithCaption.caption = text;
        [attachments addObject:imageWithCaption];
        
        TGMessage *message = [[TGMessage alloc] init];
        message.mediaAttachments = attachments;
        [self _sendPreparedMessages:[self _createPreparedMessagesFromMessages:@[message] copyAssetsData:true] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)controllerWantsToSendCloudDocumentsWithDescriptions:(NSArray *)descriptions asReplyToMessageId:(int32_t)replyMessageId
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        TGMessage *replyMessage = nil;
        if (replyMessageId != 0)
            replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
        
        NSMutableArray *preparedMessages = [[NSMutableArray alloc] init];
        
        for (NSDictionary *documentDescription in descriptions)
        {
            if (documentDescription[@"downloadDocument"] != nil)
            {
                NSDictionary *downloadDocument = documentDescription[@"downloadDocument"];
                
                TGDocumentMediaAttachment *documentAttachment = [TGModernSendCommonMessageActor remoteDocumentByGiphyId:downloadDocument[@"id"]];
                if ([self controllerShouldCacheServerAssets] && documentAttachment != nil)
                {
                    TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment replyMessage:replyMessage botContextResult:downloadDocument[@"botContextResult"] replyMarkup:nil];
                    [preparedMessages addObject:remoteDocumentMessage];
                }
                else
                {
                    int64_t localDocumentId = 0;
                    arc4random_buf(&localDocumentId, 8);
                    
                    TGPreparedDownloadDocumentMessage *downloadDocumentMessage = [[TGPreparedDownloadDocumentMessage alloc] initWithGiphyId:downloadDocument[@"id"] documentUrl:downloadDocument[@"url"] localDocumentId:localDocumentId mimeType:downloadDocument[@"mimeType"] size:[downloadDocument[@"fileSize"] intValue] thumbnailInfo:downloadDocument[@"thumbnailInfo"] attributes:downloadDocument[@"attributes"] replyMessage:replyMessage replyMarkup:nil];
                    
                    [preparedMessages addObject:downloadDocumentMessage];
                }
            }
            else if (documentDescription[@"cloudDocument"] != nil)
            {
                NSDictionary *cloudDocument = documentDescription[@"cloudDocument"];
                
                TGDocumentMediaAttachment *documentAttachment = [TGModernSendCommonMessageActor remoteDocumentByGiphyId:cloudDocument[@"id"]];
                if ([self controllerShouldCacheServerAssets] && documentAttachment != nil)
                {
                    TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment replyMessage:replyMessage botContextResult:cloudDocument[@"botContextResult"] replyMarkup:nil];
                    [preparedMessages addObject:remoteDocumentMessage];
                }
                else
                {
                    int64_t localDocumentId = 0;
                    arc4random_buf(&localDocumentId, 8);
                    
                    TGPreparedCloudDocumentMessage *cloudDocumentMessage = [[TGPreparedCloudDocumentMessage alloc] initWithDocumentUrl:cloudDocument[@"url"] localDocumentId:localDocumentId mimeType:cloudDocument[@"mimeType"] size:[cloudDocument[@"fileSize"] intValue] thumbnailInfo:cloudDocument[@"thumbnailInfo"] attributes:cloudDocument[@"attributes"] replyMessage:replyMessage replyMarkup:nil];
                    
                    [preparedMessages addObject:cloudDocumentMessage];
                }
            }
        }
        
        [self _sendPreparedMessages:preparedMessages automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)controllerWantsToSendLocalAudioWithDataItem:(TGDataItem *)dataItem duration:(NSTimeInterval)duration liveData:(TGLiveUploadActorData *)liveData waveform:(TGAudioWaveform *)waveform asReplyToMessageId:(int32_t)replyMessageId botReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        TGMessage *replyMessage = nil;
        if (replyMessageId != 0)
            replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
        
        TGAudioWaveform *resultWaveform = waveform;
        if (resultWaveform == nil) {
            resultWaveform = [TGAudioWaveformSignal waveformForPath:[dataItem path]];;
        }
        
        TGPreparedLocalDocumentMessage *localDocumentMessage = [TGPreparedLocalDocumentMessage messageWithTempDataItem:dataItem size:(int32_t)dataItem.length mimeType:@"audio/ogg" thumbnailImage:nil thumbnailSize:CGSizeZero attributes:@[[[TGDocumentAttributeAudio alloc] initWithIsVoice:true title:nil performer:nil duration:(int32_t)duration waveform:resultWaveform]] caption:nil replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
        if (localDocumentMessage != nil) {
            localDocumentMessage.liveUploadData = liveData;
            [self _sendPreparedMessages:@[localDocumentMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
        }
    }];
}

- (void)controllerWantsToSendRemoteVideoWithMedia:(TGVideoMediaAttachment *)media asReplyToMessageId:(int32_t)replyMessageId text:(NSString *)text botContextResult:(TGBotContextResultAttachment *)botContextResult botReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup
{
    if (media.videoId != 0)
    {
        TGMessage *replyMessage = nil;
        if (replyMessageId != 0)
            replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
        
        int32_t fileSize = 0;
        if ([media.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:&fileSize] != nil)
        {
            TGPreparedRemoteVideoMessage *videoMessage = [[TGPreparedRemoteVideoMessage alloc] initWithVideoId:media.videoId accessHash:media.accessHash videoSize:media.dimensions size:fileSize duration:media.duration videoInfo:media.videoInfo thumbnailInfo:media.thumbnailInfo caption:media.caption replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
            videoMessage.caption = text;
            videoMessage.botContextResult = botContextResult;
            
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                [self _sendPreparedMessages:@[videoMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
            }];
        }
    }
}

- (void)controllerWantsToSendContact:(TGUser *)contactUser asReplyToMessageId:(int32_t)replyMessageId botContextResult:(TGBotContextResultAttachment *)botContextResult botReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup
{
    if (contactUser.phoneNumber.length == 0)
        return;
    
    TGMessage *replyMessage = nil;
    if (replyMessageId != 0)
        replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
    
    TGPreparedContactMessage *contactMessage = nil;
    
    if (contactUser.uid > 0)
    {
        contactMessage = [[TGPreparedContactMessage alloc] initWithUid:contactUser.uid firstName:contactUser.firstName lastName:contactUser.lastName phoneNumber:[TGPhoneUtils cleanInternationalPhone:contactUser.phoneNumber forceInternational:false] replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
    }
    else
    {
        contactMessage = [[TGPreparedContactMessage alloc] initWithFirstName:contactUser.firstName lastName:contactUser.lastName phoneNumber:[TGPhoneUtils cleanInternationalPhone:contactUser.phoneNumber forceInternational:false] replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
    }
    contactMessage.botContextResult = botContextResult;
    
    if (contactMessage != nil)
    {
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            [self _sendPreparedMessages:@[contactMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
        }];
    }
}

- (void)controllerWantsToSendGame:(TGGameMediaAttachment *)gameMedia asReplyToMessageId:(int32_t)replyMessageId botContextResult:(TGBotContextResultAttachment *)botContextResult botReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup {
    if (gameMedia == nil) {
        return;
    }
    
    TGMessage *replyMessage = nil;
    if (replyMessageId != 0) {
        replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
    }
    
    TGPreparedGameMessage *gameMessage = [[TGPreparedGameMessage alloc] initWithGame:gameMedia replyMessage:replyMessage replyMarkup:botReplyMarkup == nil ? nil : [[TGReplyMarkupAttachment alloc] initWithReplyMarkup:botReplyMarkup]];
    gameMessage.botContextResult = botContextResult;
    
    if (gameMessage != nil) {
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            [self _sendPreparedMessages:@[gameMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
        }];
    }
}

- (void)controllerWantsToResendMessages:(NSArray *)messageIds
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        NSMutableIndexSet *removeAtIndices = [[NSMutableIndexSet alloc] init];
        NSMutableArray *moveIndexFromIndex = [[NSMutableArray alloc] init];
        NSMutableArray *moveIndexToIndex = [[NSMutableArray alloc] init];
        
        NSMutableArray *movingItems = [[NSMutableArray alloc] init];
        
        for (NSNumber *nMid in messageIds)
        {
            int mid = [nMid intValue];
            
            int index = -1;
            for (TGMessageModernConversationItem *messageItem in _items)
            {
                index++;
                
                if (messageItem->_message.mid == mid)
                {
                    TGMessageModernConversationItem *currentItem = _items[index];
                    [movingItems addObject:currentItem];
                    [moveIndexFromIndex addObject:@(index)];
                    [removeAtIndices addIndex:index];
                    
                    break;
                }
            }
        }
        
        NSMutableArray *messagesToResend = [[NSMutableArray alloc] init];
        for (TGMessageModernConversationItem *messageItem in movingItems)
        {
            [messagesToResend addObject:messageItem->_message];
        }
        
        NSArray *resentMessages = [self _sendPreparedMessages:[self _createPreparedMessagesFromMessages:messagesToResend copyAssetsData:false] automaticallyAddToList:false withIntent:TGSendMessageIntentOther];
        
        NSMutableArray *updatedItemIndices = [[NSMutableArray alloc] init];
        NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
        for (int index = 0; index < (int)movingItems.count; index++)
        {
            TGMessageModernConversationItem *messageItem = movingItems[index];
            
            TGMessageModernConversationItem *updatedItem = [messageItem deepCopy];
            if (index < (int)resentMessages.count)
                updatedItem->_message = resentMessages[index];
            [updatedItems addObject:updatedItem];
            
            NSUInteger arrayIndex = NSNotFound;
            for (NSUInteger i = 0; i < _items.count; i++) {
                if (((TGMessageModernConversationItem *)_items[i])->_message.mid == messageItem->_message.mid) {
                    arrayIndex = i;
                    break;
                }
            }
            
#ifdef DEBUG
            NSAssert(arrayIndex != NSNotFound, @"Item should be present in array");
#endif
            if (arrayIndex != NSNotFound) {
                [updatedItemIndices addObject:@(arrayIndex)];
                [(NSMutableArray *)_items replaceObjectAtIndex:arrayIndex withObject:updatedItem];
                [movingItems replaceObjectAtIndex:index withObject:updatedItem];
            }
        }
        
        int index = -1;
        for (id item in movingItems.reverseObjectEnumerator)
        {
            index++;
            [(NSMutableArray *)_items insertObject:item atIndex:index];
            [moveIndexToIndex insertObject:@(index) atIndex:0];
        }
        
        [removeAtIndices shiftIndexesStartingAtIndex:[removeAtIndices firstIndex] by:movingItems.count];
        [(NSMutableArray *)_items removeObjectsAtIndexes:removeAtIndices];
        
        NSMutableArray *indexPairs = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < moveIndexFromIndex.count; i++)
        {
            [indexPairs addObject:@[moveIndexFromIndex[i], moveIndexToIndex[i]]];
        }
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = self.controller;
            
            int index = -1;
            for (NSNumber *nIndex in updatedItemIndices)
            {
                index++;
                [controller updateItemAtIndex:[nIndex intValue] toItem:updatedItems[index] delayAvailability:false];
            }
            
            [controller moveItems:indexPairs];
        });
    }];
}

- (void)controllerWantsToForwardMessages:(NSArray *)messageIds
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        
        std::set<int32_t> messageIdSet;
        for (NSNumber *nMid in messageIds)
        {
            messageIdSet.insert([nMid intValue]);
        }
        
        for (TGMessageModernConversationItem *messageItem in _items)
        {
            if (messageIdSet.find(messageItem->_message.mid) != messageIdSet.end())
            {
                messageIdSet.erase(messageItem->_message.mid);
                
                if (messageItem->_message.cid == _conversationId) {
                    [messages addObject:messageItem->_message];
                } else {
                    TGMessage *message = [messageItem->_message copy];
                    message.mid -= migratedMessageIdOffset;
                    [messages addObject:message];
                }
            }
        }
        
        for (int32_t mid : messageIdSet)
        {
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:mid peerId:_conversationId];
            if (message != nil)
            {
                [messages addObject:message];
            }
        }
        
        [messages sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
        {
            NSTimeInterval date1 = message1.date;
            NSTimeInterval date2 = message2.date;
            
            if (ABS(date1 - date2) < DBL_EPSILON)
            {
                if (message1.mid < message2.mid)
                    return NSOrderedAscending;
                else
                    return NSOrderedDescending;
            }
            
            return date1 < date2 ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        TGDispatchOnMainThread(^
        {
            TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:messages sendMessages:nil shareLink:nil showSecretChats:true];
            forwardController.skipConfirmation = true;
            forwardController.watcherHandle = self.actionHandle;
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:forwardController];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            
            TGModernConversationController *controller = self.controller;
            [controller presentViewController:navigationController animated:true completion:nil];
        });
    }];
}

- (NSArray *)_createPreparedMessagesFromMessages:(NSArray *)messages copyAssetsData:(bool)copyAssetsData
{
#ifdef DEBUG
    NSAssert([TGGenericModernConversationCompanion isMessageQueue], @"Should be called on message queue");
#endif
    
    NSMutableArray *preparedMessages = [[NSMutableArray alloc] initWithCapacity:messages.count];
    
    for (TGMessage *message in messages)
    {
        bool messageAdded = false;
        
        TGBotContextResultAttachment *botContextResult = nil;
        TGReplyMarkupAttachment *replyMarkup = nil;
        TGWebPageMediaAttachment *parsedWebpage = nil;
        
        for (id attachment in message.mediaAttachments) {
            if ([attachment isKindOfClass:[TGWebPageMediaAttachment class]]) {
                parsedWebpage = attachment;
            } else if ([attachment isKindOfClass:[TGBotContextResultAttachment class]]) {
                botContextResult = attachment;
            } else if ([attachment isKindOfClass:[TGReplyMarkupAttachment class]]) {
                replyMarkup = attachment;
            }
        }
        
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            if (attachment.type == TGForwardedMessageMediaAttachmentType)
            {
                TGPreparedForwardedMessage *forwardedMessage = [[TGPreparedForwardedMessage alloc] initWithInnerMessage:message];
                if (!copyAssetsData)
                    forwardedMessage.replacingMid = message.mid;
                [preparedMessages addObject:forwardedMessage];
                
                messageAdded = true;
                break;
            }
        }
        if (messageAdded)
            continue;

        TGMessage *replyMessage = nil;
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
            {
                replyMessage = ((TGReplyMessageMediaAttachment *)attachment).replyMessage;
                break;
            }
        }
        
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            switch (attachment.type)
            {
                case TGLocationMediaAttachmentType:
                {
                    TGLocationMediaAttachment *locationAttachment = (TGLocationMediaAttachment *)attachment;
                    TGPreparedMapMessage *mapMessage = [[TGPreparedMapMessage alloc] initWithLatitude:locationAttachment.latitude longitude:locationAttachment.longitude venue:locationAttachment.venue replyMessage:replyMessage replyMarkup:replyMarkup];
                    if (!copyAssetsData)
                        mapMessage.replacingMid = message.mid;
                    [preparedMessages addObject:mapMessage];
                    messageAdded = true;
                    break;
                }
                case TGImageMediaAttachmentType:
                {
                    TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                    if (imageAttachment.imageId != 0)
                    {
                        TGPreparedRemoteImageMessage *remoteImageMessage = [[TGPreparedRemoteImageMessage alloc] initWithImageId:imageAttachment.imageId accessHash:imageAttachment.accessHash imageInfo:imageAttachment.imageInfo caption:imageAttachment.caption replyMessage:replyMessage botContextResult:botContextResult replyMarkup:replyMarkup];
                        if (!copyAssetsData)
                            remoteImageMessage.replacingMid = message.mid;
                        [preparedMessages addObject:remoteImageMessage];
                    }
                    else
                    {
                        if (message.contentProperties[@"downloadExternalImageInfo"] != nil)
                        {
                            TGDownloadExternalImageInfo *info = message.contentProperties[@"downloadExternalImageInfo"];
                            TGPreparedDownloadExternalImageMessage *downloadImageMessage = [[TGPreparedDownloadExternalImageMessage alloc] initWithSearchResult:info.searchResult imageInfo:imageAttachment.imageInfo caption:imageAttachment.caption replyMessage:replyMessage botContextResult:botContextResult replyMarkup:replyMarkup];
                            if (!copyAssetsData)
                                downloadImageMessage.replacingMid = message.mid;
                            [preparedMessages addObject:downloadImageMessage];
                        }
                        else if (message.contentProperties[@"mediaAsset"] != nil)
                        {
                            TGMediaAssetContentProperty *info = message.contentProperties[@"mediaAsset"];
                            TGPreparedAssetImageMessage *assetImageMessage = [[TGPreparedAssetImageMessage alloc] initWithAssetIdentifier:info.assetIdentifier imageInfo:imageAttachment.imageInfo caption:imageAttachment.caption useMediaCache:info.useMediaCache isCloud:info.isCloud document:false localDocumentId:0 fileSize:INT_MAX mimeType:nil attributes:nil replyMessage:replyMessage replyMarkup:replyMarkup messageLifetime:[self messageLifetime]];
                            assetImageMessage.uploadQueue = [self mediaUploadQueue];
                            if (!copyAssetsData)
                                assetImageMessage.replacingMid = message.mid;
                            [preparedMessages addObject:assetImageMessage];
                        }
                        else
                        {
                            CGSize largestSize = CGSizeZero;
                            if ([imageAttachment.imageInfo imageUrlForLargestSize:&largestSize] != nil)
                            {
                                CGSize thumbnailSize = TGFitSize(largestSize, CGSizeMake(90, 90));
                                NSString *thumbnailUrl = [imageAttachment.imageInfo closestImageUrlWithSize:thumbnailSize resultingSize:&thumbnailSize];
                                CGSize imageSize = CGSizeZero;
                                NSString *imageUrl = [imageAttachment.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1146) resultingSize:&imageSize];
                             
                                if ([imageUrl hasPrefix:@"http://"] || [imageUrl hasPrefix:@"https://"])
                                {
                                    TGPreparedDownloadImageMessage *downloadImageMessage = [[TGPreparedDownloadImageMessage alloc] initWithImageInfo:imageAttachment.imageInfo caption:imageAttachment.caption replyMessage:replyMessage replyMarkup:replyMarkup];
                                    if (!copyAssetsData)
                                        downloadImageMessage.replacingMid = message.mid;
                                    [preparedMessages addObject:downloadImageMessage];
                                }
                                else if (thumbnailUrl != nil && imageUrl != nil)
                                {
                                    if (copyAssetsData)
                                    {
                                        NSData *imageData = nil;
                                        if ([imageUrl hasPrefix:@"file://"])
                                            imageData = [[NSData alloc] initWithContentsOfFile:[imageUrl substringFromIndex:@"file://".length]];
                                        else
                                            imageData = [[NSData alloc] initWithContentsOfFile:[[TGRemoteImageView sharedCache] pathForCachedData:imageUrl]];
                                        
                                        NSData *thumbnailData = nil;
                                        if ([thumbnailUrl hasPrefix:@"file://"])
                                            thumbnailData = [[NSData alloc] initWithContentsOfFile:[thumbnailUrl substringFromIndex:@"file://".length]];
                                        else
                                            thumbnailData = [[NSData alloc] initWithContentsOfFile:[[TGRemoteImageView sharedCache] pathForCachedData:thumbnailUrl]];
                                        
                                        if (imageData != nil && thumbnailData != nil)
                                        {
                                            TGPreparedLocalImageMessage *localImageMessage = [TGPreparedLocalImageMessage messageWithImageData:imageData imageSize:imageSize thumbnailData:thumbnailData thumbnailSize:thumbnailSize assetUrl:nil caption:imageAttachment.caption replyMessage:replyMessage replyMarkup:replyMarkup stickerDocuments:imageAttachment.embeddedStickerDocuments messageLifetime:[self messageLifetime]];
                                            if (!copyAssetsData)
                                                localImageMessage.replacingMid = message.mid;
                                            [preparedMessages addObject:localImageMessage];
                                        }
                                    }
                                    else
                                    {
                                        TGPreparedLocalImageMessage *localImageMessage = [TGPreparedLocalImageMessage messageWithLocalImageDataPath:imageUrl imageSize:imageSize localThumbnailDataPath:thumbnailUrl thumbnailSize:thumbnailSize assetUrl:nil caption:imageAttachment.caption replyMessage:replyMessage replyMarkup:replyMarkup stickerDocuments:imageAttachment.embeddedStickerDocuments messageLifetime:[self messageLifetime]];
                                        if (!copyAssetsData)
                                            localImageMessage.replacingMid = message.mid;
                                        [preparedMessages addObject:localImageMessage];
                                    }
                                }
                            }
                        }
                    }
                    
                    messageAdded = true;
                    break;
                }
                case TGVideoMediaAttachmentType:
                {
                    TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                    if (videoAttachment.videoId != 0)
                    {
                        int32_t fileSize = 0;
                        if ([videoAttachment.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:&fileSize] != nil)
                        {
                            TGPreparedRemoteVideoMessage *remoteVideoMessage = [[TGPreparedRemoteVideoMessage alloc] initWithVideoId:videoAttachment.videoId accessHash:videoAttachment.accessHash videoSize:videoAttachment.dimensions size:fileSize duration:videoAttachment.duration videoInfo:videoAttachment.videoInfo thumbnailInfo:videoAttachment.thumbnailInfo caption:videoAttachment.caption replyMessage:replyMessage replyMarkup:replyMarkup];
                            if (!copyAssetsData)
                                remoteVideoMessage.replacingMid = message.mid;
                            [preparedMessages addObject:remoteVideoMessage];
                        }
                    }
                    else if (videoAttachment.localVideoId != 0)
                    {
                        if (message.contentProperties[@"mediaAsset"] != nil)
                        {
                            int fileSize = INT_MAX;
                            [videoAttachment.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:&fileSize];
                            TGMediaAssetContentProperty *info = message.contentProperties[@"mediaAsset"];
                            TGPreparedAssetVideoMessage *assetVideoMessage = [[TGPreparedAssetVideoMessage alloc] initWithAssetIdentifier:info.assetIdentifier assetURL:info.assetURL localVideoId:videoAttachment.localVideoId imageInfo:videoAttachment.thumbnailInfo duration:videoAttachment.duration dimensions:videoAttachment.dimensions adjustments:info.editAdjustments useMediaCache:info.useMediaCache liveUpload:info.liveUpload passthrough:info.passthrough caption:videoAttachment.caption isCloud:info.isCloud document:false localDocumentId:0 fileSize:fileSize mimeType:nil attributes:nil replyMessage:replyMessage replyMarkup:replyMarkup stickerDocuments:videoAttachment.embeddedStickerDocuments roundMessage:info.roundMessage];
                            assetVideoMessage.uploadQueue = [self mediaUploadQueue];
                            if (!copyAssetsData)
                                assetVideoMessage.replacingMid = message.mid;
                            [preparedMessages addObject:assetVideoMessage];
                        }
                        else
                        {
                            int fileSize = 0;
                            NSString *videoUrl = [videoAttachment.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:&fileSize];
                            
                            CGSize thumbnailSize = CGSizeZero;
                            NSString *thumbnailUrl = nil;
                            CGSize largestSize = CGSizeZero;
                            if ([videoAttachment.thumbnailInfo imageUrlForLargestSize:&largestSize] != nil)
                            {
                                thumbnailSize = TGFitSize(largestSize, CGSizeMake(90, 90));
                                thumbnailUrl = [videoAttachment.thumbnailInfo closestImageUrlWithSize:thumbnailSize resultingSize:&thumbnailSize];
                            }
                            
                            if (videoUrl != nil && thumbnailUrl != nil)
                            {
                                if (copyAssetsData)
                                {
                                    TGPreparedLocalVideoMessage *localVideoMessage = [TGPreparedLocalVideoMessage messageByCopyingDataFromMedia:videoAttachment replyMessage:replyMessage replyMarkup:replyMarkup];
                                    localVideoMessage.caption = videoAttachment.caption;
                                    if (!copyAssetsData)
                                        localVideoMessage.replacingMid = message.mid;
                                    [preparedMessages addObject:localVideoMessage];
                                }
                                else
                                {
                                    TGPreparedLocalVideoMessage *localVideoMessage = [TGPreparedLocalVideoMessage messageWithLocalVideoId:videoAttachment.localVideoId videoSize:videoAttachment.dimensions size:fileSize duration:videoAttachment.duration localThumbnailDataPath:thumbnailUrl thumbnailSize:thumbnailSize assetUrl:nil caption:videoAttachment.caption replyMessage:replyMessage replyMarkup:replyMarkup];
                                    localVideoMessage.caption = videoAttachment.caption;
                                    if (!copyAssetsData)
                                        localVideoMessage.replacingMid = message.mid;
                                    [preparedMessages addObject:localVideoMessage];
                                }
                            }
                        }
                    }
                    messageAdded = true;
                    break;
                }
                case TGDocumentMediaAttachmentType:
                {
                    TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                    if (documentAttachment.documentId != 0)
                    {
                        TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment replyMessage:replyMessage botContextResult:botContextResult replyMarkup:replyMarkup];
                        if (!copyAssetsData)
                            remoteDocumentMessage.replacingMid = message.mid;
                        [preparedMessages addObject:remoteDocumentMessage];
                    }
                    else if (documentAttachment.localDocumentId != 0)
                    {
                        if (message.contentProperties[@"downloadDocumentUrl"] != nil)
                        {                            
                            TGDownloadDocumentUrl *documentUrl = message.contentProperties[@"downloadDocumentUrl"];
                            TGPreparedDownloadDocumentMessage *downloadDocumentMessage = [[TGPreparedDownloadDocumentMessage alloc] initWithGiphyId:documentUrl.giphyId documentUrl:documentUrl.documentUrl localDocumentId:documentAttachment.localDocumentId mimeType:documentAttachment.mimeType size:documentAttachment.size thumbnailInfo:documentAttachment.thumbnailInfo attributes:documentAttachment.attributes replyMessage:replyMessage replyMarkup:replyMarkup];
                            if (!copyAssetsData)
                                downloadDocumentMessage.replacingMid = message.mid;
                            [preparedMessages addObject:downloadDocumentMessage];
                        }
                        else if (message.contentProperties[@"cloudDocumentUrl"] != nil)
                        {
                            TGCloudDocumentUrlBookmark *documentUrlBookmark = message.contentProperties[@"cloudDocumentUrl"];
                            TGPreparedCloudDocumentMessage *cloudDocumentMessage = [[TGPreparedCloudDocumentMessage alloc] initWithDocumentUrl:documentUrlBookmark.documentUrl localDocumentId:documentAttachment.localDocumentId mimeType:documentAttachment.mimeType size:documentAttachment.size thumbnailInfo:documentAttachment.thumbnailInfo attributes:documentAttachment.attributes replyMessage:replyMessage replyMarkup:replyMarkup];
                            if (!copyAssetsData)
                                cloudDocumentMessage.replacingMid = message.mid;
                            [preparedMessages addObject:cloudDocumentMessage];
                        }
                        else if (message.contentProperties[@"downloadExternalGifInfo"] != nil) {
                            TGDownloadExternalGifInfo *info = message.contentProperties[@"downloadExternalGifInfo"];
                            TGPreparedDownloadExternalGifMessage *downloadGifMessage = [[TGPreparedDownloadExternalGifMessage alloc] initWithSearchResult:info.searchResult localDocumentId:documentAttachment.localDocumentId mimeType:documentAttachment.mimeType thumbnailInfo:documentAttachment.thumbnailInfo attributes:documentAttachment.attributes caption:documentAttachment.caption replyMessage:replyMessage botContextResult:botContextResult replyMarkup:replyMarkup];
                            if (!copyAssetsData)
                                downloadGifMessage.replacingMid = message.mid;
                            [preparedMessages addObject:downloadGifMessage];
                        }
                        else if (message.contentProperties[@"mediaAsset"] != nil) {
                            TGMediaAssetContentProperty *info = message.contentProperties[@"mediaAsset"];
                            
                            TGPreparedMessage *preparedAssetMessage = nil;
                            if (!info.isVideo)
                            {
                                TGPreparedAssetImageMessage *assetImageMessage = [[TGPreparedAssetImageMessage alloc] initWithAssetIdentifier:info.assetIdentifier imageInfo:documentAttachment.thumbnailInfo caption:documentAttachment.caption useMediaCache:false isCloud:info.isCloud document:true localDocumentId:documentAttachment.localDocumentId fileSize:documentAttachment.size mimeType:documentAttachment.mimeType attributes:documentAttachment.attributes replyMessage:replyMessage replyMarkup:replyMarkup messageLifetime:[self messageLifetime]];
                                assetImageMessage.uploadQueue = [self mediaUploadQueue];
                                preparedAssetMessage = assetImageMessage;
                            }
                            else
                            {
                                TGPreparedAssetVideoMessage *assetVideoMessage = [[TGPreparedAssetVideoMessage alloc] initWithAssetIdentifier:info.assetIdentifier assetURL:info.assetURL localVideoId:0 imageInfo:documentAttachment.thumbnailInfo duration:0 dimensions:CGSizeZero adjustments:nil useMediaCache:false liveUpload:false passthrough:false caption:documentAttachment.caption isCloud:info.isCloud document:true localDocumentId:documentAttachment.localDocumentId fileSize:documentAttachment.size mimeType:documentAttachment.mimeType attributes:documentAttachment.attributes replyMessage:replyMessage replyMarkup:replyMarkup stickerDocuments:nil roundMessage:info.roundMessage];
                                assetVideoMessage.uploadQueue = [self mediaUploadQueue];
                                preparedAssetMessage = assetVideoMessage;
                            }
                            if (!copyAssetsData)
                                preparedAssetMessage.replacingMid = message.mid;
                            [preparedMessages addObject:preparedAssetMessage];
                        }
                        else
                        {
                            CGSize thumbnailSize = CGSizeZero;
                            NSString *thumbnailUrl = nil;
                            CGSize largestSize = CGSizeZero;
                            if ([documentAttachment.thumbnailInfo imageUrlForLargestSize:&largestSize] != nil)
                            {
                                thumbnailSize = TGFitSize(largestSize, CGSizeMake(90, 90));
                                thumbnailUrl = [documentAttachment.thumbnailInfo closestImageUrlWithSize:thumbnailSize resultingSize:&thumbnailSize];
                            }
                            
                            if (documentAttachment.thumbnailInfo == nil || thumbnailUrl != nil)
                            {
                                if (copyAssetsData)
                                {
                                    TGPreparedLocalDocumentMessage *localDocumentMessage = [TGPreparedLocalDocumentMessage messageByCopyingDataFromMedia:documentAttachment replyMessage:replyMessage  replyMarkup:replyMarkup];
                                    if (!copyAssetsData)
                                        localDocumentMessage.replacingMid = message.mid;
                                    [preparedMessages addObject:localDocumentMessage];
                                }
                                else
                                {
                                    TGPreparedLocalDocumentMessage *localDocumentMessage = [TGPreparedLocalDocumentMessage messageWithLocalDocumentId:documentAttachment.localDocumentId size:documentAttachment.size mimeType:documentAttachment.mimeType localThumbnailDataPath:thumbnailUrl thumbnailSize:thumbnailSize attributes:documentAttachment.attributes replyMarkup:replyMarkup];
                                    if (!copyAssetsData)
                                        localDocumentMessage.replacingMid = message.mid;
                                    [preparedMessages addObject:localDocumentMessage];
                                }
                            }
                        }
                    }
                    
                    messageAdded = true;
                    break;
                }
                case TGAudioMediaAttachmentType:
                {
                    break;
                }
                case TGContactMediaAttachmentType:
                {
                    TGContactMediaAttachment *contactAttachment = (TGContactMediaAttachment *)attachment;
                    
                    TGPreparedContactMessage *contactMessage = [[TGPreparedContactMessage alloc] initWithUid:contactAttachment.uid firstName:contactAttachment.firstName lastName:contactAttachment.lastName phoneNumber:contactAttachment.phoneNumber replyMessage:replyMessage replyMarkup:replyMarkup];
                    if (!copyAssetsData)
                        contactMessage.replacingMid = message.mid;
                    [preparedMessages addObject:contactMessage];

                    messageAdded = true;
                    break;
                }
                default:
                    break;
            }
            
            if (messageAdded)
                break;
        }
        
        if (message.text.length != 0)
        {
            TGPreparedTextMessage *textMessage = [[TGPreparedTextMessage alloc] initWithText:message.text replyMessage:replyMessage disableLinkPreviews:((TGLinkPreviewsContentProperty *)message.contentProperties[@"linkPreviews"]).disableLinkPreviews parsedWebpage:parsedWebpage entities:message.entities botContextResult:botContextResult replyMarkup:replyMarkup];
            textMessage.messageLifetime = [self messageLifetime];
            if (!copyAssetsData)
                textMessage.replacingMid = message.mid;
            [preparedMessages addObject:textMessage];
        }
    }
    
    return preparedMessages;
}

- (NSArray *)_createPreparedForwardMessagesFromMessages:(NSArray *)messages
{
    NSMutableArray *preparedMessages = [[NSMutableArray alloc] init];
    
    for (TGMessage *message in messages)
    {
        if (message.mid < TGMessageLocalMidBaseline)
        {
            TGMessage *innerMessage = [message copy];
            if (innerMessage.contentProperties != nil)
            {
                NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:innerMessage.contentProperties];
                [contentProperties removeObjectForKey:@"contentsRead"];
                innerMessage.contentProperties = contentProperties;
            }
            NSMutableArray *mediaAttachments = [[NSMutableArray alloc] init];
            bool isForward = false;
            for (id attachment in innerMessage.mediaAttachments)
            {
                if (![self allowCaptionedMedia])
                {
                    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                    {
                        TGImageMediaAttachment *imageAttachment = [attachment copy];
                        imageAttachment.caption = nil;
                        [mediaAttachments addObject:imageAttachment];
                        continue;
                    }
                    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                    {
                        TGVideoMediaAttachment *videoAttachment = [attachment copy];
                        videoAttachment.caption = nil;
                        [mediaAttachments addObject:videoAttachment];
                        continue;
                    }
                }
                if ([attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]])
                {
                    isForward = true;
                }
                [mediaAttachments addObject:attachment];
            }
            innerMessage.mediaAttachments = mediaAttachments;
            
            bool isOwnMessage = innerMessage.cid == TGTelegraphInstance.clientUserId && !isForward;
            bool keepForwarded = [self allowMessageForwarding] && !isOwnMessage;
            TGPreparedForwardedMessage *preparedMessage = [[TGPreparedForwardedMessage alloc] initWithInnerMessage:innerMessage keepForwarded:keepForwarded];
            [preparedMessages addObject:preparedMessage];
        }
        else
            [preparedMessages addObjectsFromArray:[self _createPreparedMessagesFromMessages:@[message] copyAssetsData:true]];
    }
    
    return preparedMessages;
}

- (bool)isFileImage:(NSString *)fileName mimeType:(NSString *)mimeType outAnimated:(bool *)outAnimated
{
    NSArray *imageFileExtensions = @[@"gif", @"png", @"jpg", @"jpeg"];
    NSArray *imageMimeTypes = @[@"image/gif"];
    
    NSString *extension = [fileName pathExtension];
    for (NSString *sampleExtension in imageFileExtensions)
    {
        if ([[extension lowercaseString] isEqualToString:sampleExtension])
        {
            if ([sampleExtension isEqualToString:@"gif"])
            {
                if (outAnimated)
                    *outAnimated = true;
            }
            return true;
        }
    }
    
    for (NSString *sampleMimeType in imageMimeTypes)
    {
        if ([mimeType isEqualToString:sampleMimeType])
        {
            if ([sampleMimeType isEqualToString:@"image/gif"])
            {
                if (outAnimated)
                    *outAnimated = true;
            }
            return true;
        }
    }
    
    return false;
}

- (NSArray *)_createPreparedMessagesFromFiles:(NSArray *)files asReplyToMessageId:(int32_t)replyMessageId
{
    TGMessage *replyMessage = nil;
    if (replyMessageId != 0)
        replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
    
    NSMutableArray *preparedMessages = [[NSMutableArray alloc] init];
    
    for (NSDictionary *desc in files)
    {
        NSURL *fileUrl = desc[@"url"];
        if (fileUrl == nil)
            continue;
        
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileUrl path] error:nil];
        if (attributes[NSFileSize] == nil)
            continue;
        
        if ([desc[@"type"] isEqualToString:@"image"])
        {
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:[fileUrl path]];
            if (image != nil)
            {
                CGSize originalSize = image.size;
                originalSize.width *= image.scale;
                originalSize.height *= image.scale;
                
                CGSize imageSize = TGFitSize(originalSize, CGSizeMake(1280, 1280));
                CGSize thumbnailSize = TGFitSize(originalSize, CGSizeMake(90, 90));
                
                UIImage *fullImage = TGScaleImageToPixelSize(image, imageSize);
                NSData *imageData = UIImageJPEGRepresentation(fullImage, 0.54f);
                
                UIImage *previewImage = TGScaleImageToPixelSize(fullImage, TGFitSize(originalSize, [TGGenericModernConversationCompanion preferredInlineThumbnailSize]));
                NSData *thumbnailData = UIImageJPEGRepresentation(previewImage, 0.9f);
                
                previewImage = nil;
                fullImage = nil;
                
                TGPreparedLocalImageMessage *imageMessage = [TGPreparedLocalImageMessage messageWithImageData:imageData imageSize:imageSize thumbnailData:thumbnailData thumbnailSize:thumbnailSize assetUrl:nil caption:nil replyMessage:replyMessage replyMarkup:nil stickerDocuments:nil messageLifetime:[self messageLifetime]];
                [preparedMessages addObject:imageMessage];
            }
        }
        else if ([desc[@"type"] isEqualToString:@"video"])
        {
            
            
            /*TGPreparedLocalVideoMessage *videoMessage = [TGPreparedLocalVideoMessage messageWithTempVideoPath:[fileUrl pathExtension] videoSize:dimenstions size:fileSize duration:duration previewImage:previewImage thumbnailSize:TGFitSize(CGSizeMake(previewImage.size.width * previewImage.scale, previewImage.size.height * previewImage.scale), [TGGenericModernConversationCompanion preferredInlineThumbnailSize]) assetUrl:assetUrl];
            [preparedMessages addObject:videoMessage];*/
        }
        else
        {
            NSString *fileName = desc[@"fileName"];
            if (fileName == nil)
                fileName = [[fileUrl lastPathComponent] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
            
            int size = [attributes[NSFileSize] intValue];
            
            UIImage *thumbnailImage = nil;
            CGSize thumbnailSize = CGSizeZero;
            CGSize imageSize = CGSizeZero;
            bool sendAsFile = true;
            
            NSNumber *videoDuration = nil;
        
            bool isAnimatedImage = false;
            if ([self isFileImage:fileName mimeType:desc[@"mimeType"] outAnimated:&isAnimatedImage])
            {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:[fileUrl path]];
                imageSize = image.size;
                if (image != nil && image.size.width * image.size.height <= 8096 * 8096)
                {
                    thumbnailSize = TGFitSize(image.size, [TGGenericModernConversationCompanion preferredInlineThumbnailSize]);
                    thumbnailImage = TGScaleImageToPixelSize(image, thumbnailSize);
                }
                
                if (isAnimatedImage)
                {
                }
                else
                {
                    if (![desc[@"forceAsFile"] boolValue])
                    {
                        sendAsFile = false;
                        
                        NSData *imageData = UIImageJPEGRepresentation(image, 0.54f);
                        UIImage *previewImage = TGScaleImageToPixelSize(image, TGFitSize(imageSize, [TGGenericModernConversationCompanion preferredInlineThumbnailSize]));
                        NSData *thumbnailData = UIImageJPEGRepresentation(previewImage, 0.9f);
                        
                        TGPreparedLocalImageMessage *imageMessage = [TGPreparedLocalImageMessage messageWithImageData:imageData imageSize:imageSize thumbnailData:thumbnailData thumbnailSize:thumbnailSize assetUrl:nil caption:nil replyMessage:replyMessage replyMarkup:nil stickerDocuments:nil messageLifetime:[self messageLifetime]];
                        [preparedMessages addObject:imageMessage];
                    }
                }
            } else if ([desc[@"mimeType"] isEqualToString:@"video/mp4"]) {
                AVAsset *asset = [AVAsset assetWithURL:fileUrl];
                
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                imageGenerator.maximumSize = CGSizeMake(640.0f, 640.0f);
                imageGenerator.appliesPreferredTrackTransform = true;
                NSError *imageError = nil;
                CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, asset.duration.timescale) actualTime:NULL error:&imageError];
                UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
                if (imageRef != NULL) {
                    CGImageRelease(imageRef);
                }
                
                if (image != nil) {
                    imageSize = image.size;
                    videoDuration = @(CMTimeGetSeconds(asset.duration));
                    
                    thumbnailSize = TGFitSize(image.size, [TGGenericModernConversationCompanion preferredInlineThumbnailSize]);
                    thumbnailImage = TGScaleImageToPixelSize(image, thumbnailSize);
                }
            }
            
            if (sendAsFile)
            {
                if ([fileName hasSuffix:@".webp"])
                {
                    NSError *dataError = nil;;
                    NSData *imgData = [NSData dataWithContentsOfFile:[fileUrl path] options:NSDataReadingMappedIfSafe error:&dataError];
                    if(dataError != nil) {
                        NSLog(@"imageFromWebP: error: %@", dataError.localizedDescription);
                    }
                    else
                    {
                        // `WebPGetInfo` weill return image width and height
                        int width = 0, height = 0;
                        if(WebPGetInfo((uint8_t const *)[imgData bytes], [imgData length], &width, &height))
                        {
                            imageSize = CGSizeMake(width, height);
                        }
                    }
                }
                
                NSMutableArray *documentAttributes = [[NSMutableArray alloc] init];
                NSString *documentFileName = fileName;
                if (documentFileName.length == 0)
                    documentFileName = @"file";
                NSString *documentMimeType = desc[@"mimeType"];
                if (isAnimatedImage && documentFileName.pathExtension.length == 0)
                    documentFileName = [documentFileName stringByAppendingString:@".gif"];
                if (isAnimatedImage && documentMimeType.length == 0)
                    documentMimeType = @"image/gif";
                
                if ([desc[@"isAnimation"] isEqualToNumber:@true])
                    isAnimatedImage = true;
                
                if (videoDuration) {
                    [documentAttributes addObject:[[TGDocumentAttributeVideo alloc] initWithRoundMessage:false size:imageSize duration:[videoDuration intValue]]];
                }
                
                [documentAttributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:documentFileName]];
                if (imageSize.width > FLT_EPSILON && imageSize.height > FLT_EPSILON)
                    [documentAttributes addObject:[[TGDocumentAttributeImageSize alloc] initWithSize:imageSize]];
                if (isAnimatedImage)
                    [documentAttributes addObject:[[TGDocumentAttributeAnimated alloc] init]];
                if ([fileName hasSuffix:@".webp"])
                {
                    [documentAttributes addObject:[[TGDocumentAttributeSticker alloc] init]];
                }
                TGPreparedLocalDocumentMessage *preparedMessage = [TGPreparedLocalDocumentMessage messageWithTempDocumentPath:[fileUrl path] size:(int32_t)size mimeType:documentMimeType thumbnailImage:thumbnailImage thumbnailSize:thumbnailSize attributes:documentAttributes caption:desc[@"caption"] replyMessage:replyMessage replyMarkup:nil];
                [preparedMessages addObject:preparedMessage];
            }
        }
    }
    
    return preparedMessages;
}

- (NSArray *)_sendPreparedMessages:(NSArray *)preparedMessages automaticallyAddToList:(bool)automaticallyAddToList withIntent:(TGSendMessageIntent)intent
{
#ifdef DEBUG
    NSAssert([TGGenericModernConversationCompanion isMessageQueue], @"Should be called on message queue");
#endif
    
    NSMutableArray *preparedActions = [[NSMutableArray alloc] init];
    NSMutableArray *addedMessages = [[NSMutableArray alloc] init];
    
    NSMutableArray *addToDatabaseMessages = [[NSMutableArray alloc] init];
    NSMutableArray *replaceInDatabaseMessages = [[NSMutableArray alloc] init];
    
    NSMutableArray *forwardedMessages = [[NSMutableArray alloc] init];
    
    bool showStickersRestrictedAlert = false;
    bool showMediaRestrictedAlert = false;
    
    for (TGPreparedMessage *preparedMessage in preparedMessages)
    {
        int32_t minLifetime = 0;
        
        if ([preparedMessage isKindOfClass:[TGPreparedLocalDocumentMessage class]]) {
            for (id attribute in ((TGPreparedLocalDocumentMessage *)preparedMessage).attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]] && ((TGDocumentAttributeAudio *)attribute).isVoice) {
                        minLifetime = ((TGDocumentAttributeAudio *)attribute).duration + 1;
                    break;
                }
            }
        }
        else if ([preparedMessage isKindOfClass:[TGPreparedRemoteDocumentMessage class]]) {
            for (id attribute in ((TGPreparedRemoteDocumentMessage *)preparedMessage).attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]] && ((TGDocumentAttributeAudio *)attribute).isVoice) {
                    minLifetime = ((TGDocumentAttributeAudio *)attribute).duration + 1;
                    break;
                }
            }
        }
        else if ([preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
            minLifetime = (int32_t)ceil(((TGPreparedLocalVideoMessage *)preparedMessage).duration);
        else if ([preparedMessage isKindOfClass:[TGPreparedRemoteVideoMessage class]])
            minLifetime = (int32_t)ceil(((TGPreparedRemoteVideoMessage *)preparedMessage).duration);
        else if ([preparedMessage isKindOfClass:[TGPreparedAssetVideoMessage class]])
            minLifetime = (int32_t)ceil(((TGPreparedAssetVideoMessage *)preparedMessage).duration);
        
        {
            preparedMessage.messageLifetime = MAX(preparedMessage.messageLifetime, [self messageLifetime] == 0 ? 0 : MAX([self messageLifetime], minLifetime));
            
            if (preparedMessage.randomId == 0)
            {
                int64_t randomId = 0;
                arc4random_buf(&randomId, sizeof(randomId));
                preparedMessage.randomId = randomId;
            }
            
            if (preparedMessage.mid == 0)
                preparedMessage.mid = [[TGDatabaseInstance() generateLocalMids:1][0] intValue];
            
            preparedMessage.date = (int)[[TGTelegramNetworking instance] approximateRemoteTime];
            //TGLog(@"send time: %f + %f", [[NSDate date] timeIntervalSince1970] + [[TGTelegramNetworking instance].context globalTimeDifference]);
            
            TGMessage *message = [preparedMessage message];
            if (message == nil)
            {
                TGLog(@"***** Failed to generate message from prepared message");
                continue;
            }
            
            if (![self allowMessageEntities]) {
                TGMessageEntitiesAttachment *entities = nil;
                NSMutableArray *attachments = [[NSMutableArray alloc] initWithArray:message.mediaAttachments];
                for (NSInteger index = 0; index < (NSInteger)attachments.count; index++) {
                    if ([attachments[index] isKindOfClass:[TGBotContextResultAttachment class]]) {
                        [attachments removeObjectAtIndex:index];
                        index--;
                    } else if ([attachments[index] isKindOfClass:[TGViaUserAttachment class]]) {
                        [attachments removeObjectAtIndex:index];
                        index--;
                    } else if ([attachments[index] isKindOfClass:[TGMessageEntitiesAttachment class]]) {
                        entities = attachments[index];
                        [attachments removeObjectAtIndex:index];
                        index--;
                    }
                }
                
                message.mediaAttachments = attachments;
                
                if (message.text.length != 0) {
                    NSMutableArray *inlineLinkEntities = [[NSMutableArray alloc] init];
                    for (id entity in entities.entities) {
                        if ([entity isKindOfClass:[TGMessageEntityTextUrl class]]) {
                            [inlineLinkEntities addObject:entity];
                        }
                    }
                    
                    [inlineLinkEntities sortUsingComparator:^NSComparisonResult(TGMessageEntityTextUrl *url1, TGMessageEntityTextUrl *url2) {
                        return (url1.range.location + url1.range.length) < (url2.range.location + url2.range.length) ? NSOrderedAscending : NSOrderedDescending;
                    }];
                    
                    NSMutableString *text = [[NSMutableString alloc] initWithString:message.text];
                    
                    for (NSInteger index = 0; index < (NSInteger)inlineLinkEntities.count; index++) {
                        TGMessageEntityTextUrl *url = inlineLinkEntities[index];
                        
                        NSInteger rangeEnd = url.range.location + url.range.length;
                        
                        NSString *insertString = [[NSString alloc] initWithFormat:@" (%@)", url.url];
                        
                        [text insertString:insertString atIndex:rangeEnd];
                        
                        for (NSInteger k = index + 1; k < (NSInteger)inlineLinkEntities.count; k++) {
                            TGMessageEntityTextUrl *nextUrl = inlineLinkEntities[k];
                            NSInteger nextRangeEnd = nextUrl.range.location + nextUrl.range.length;
                            if (nextRangeEnd >= rangeEnd) {
                                [inlineLinkEntities replaceObjectAtIndex:k withObject:[[TGMessageEntityTextUrl alloc] initWithRange:NSMakeRange(nextUrl.range.location + insertString.length, nextUrl.range.length) url:nextUrl.url]];
                            }
                        }
                    }
                    
                    message.text = text;
                }
            }
            
            if (![self allowMessageForwarding]) {
                NSMutableArray *attachments = [[NSMutableArray alloc] initWithArray:message.mediaAttachments];
                for (NSInteger index = 0; index < (NSInteger)attachments.count; index++) {
                    if ([attachments[index] isKindOfClass:[TGReplyMarkupAttachment class]]) {
                        [attachments removeObjectAtIndex:index];
                        index--;
                    }
                }
                
                message.mediaAttachments = attachments;
            }
            
            message.layer = [self layer];
            
            message.outgoing = true;
            message.fromUid = self.messageAuthorPeerId;
            message.toUid = self.conversationId;
            message.deliveryState = TGMessageDeliveryStatePending;
            message.sortKey = TGMessageSortKeyMake(_conversationId, TGMessageSpaceImportant, (int32_t)message.date, message.mid);
            message.cid = _conversationId;
            [self _setupOutgoingMessage:message];
            
            bool isMedia = false;
            bool isSticker = false;
            bool isGif = false;
            bool isGame = false;
            bool isInline = false;
            for (id media in message.mediaAttachments) {
                if ([media isKindOfClass:[TGImageMediaAttachment class]]) {
                    isMedia = true;
                } else if ([media isKindOfClass:[TGLocationMediaAttachment class]]) {
                } else if ([media isKindOfClass:[TGContactMediaAttachment class]]) {
                } else if ([media isKindOfClass:[TGDocumentMediaAttachment class]]) {
                    if (((TGDocumentMediaAttachment *)media).isSticker) {
                        isSticker = true;
                    } else if (((TGDocumentMediaAttachment *)media).isAnimated) {
                        isGif = true;
                    } else {
                        isMedia = true;
                    }
                } else if ([media isKindOfClass:[TGAudioMediaAttachment class]]) {
                    isMedia = true;
                } else if ([media isKindOfClass:[TGVideoMediaAttachment class]]) {
                    isMedia = true;
                } else if ([media isKindOfClass:[TGBotContextResultAttachment class]]) {
                    isInline = true;
                } else if ([media isKindOfClass:[TGGameMediaAttachment class]]) {
                    isGame = true;
                } else if ([media isKindOfClass:[TGInvoiceMediaAttachment class]]) {
                    isMedia = true;
                }
            }
            
            if (isSticker && ![self canSendStickers]) {
                showStickersRestrictedAlert = true;
                continue;
            } else if (isMedia && ![self canSendMedia]) {
                showMediaRestrictedAlert = true;
                continue;
            } else if (isGif && ![self canSendGifs]) {
                showMediaRestrictedAlert = true;
                continue;
            } else if (isGame && ![self canSendGames]) {
                showMediaRestrictedAlert = true;
                continue;
            } else if (isInline && ![self canSendInline]) {
                showMediaRestrictedAlert = true;
                continue;
            }
            
            if ([self _messagesNeedRandomId])
                message.randomId = preparedMessage.randomId;
            
            if (TGPeerIdIsChannel(_conversationId)) {
                NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:message.contentProperties];
                contentProperties[@"contentsRead"] = [[TGMessageViewedContentProperty alloc] init];
                message.contentProperties = contentProperties;
            }
            
            NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:@{
                @"preparedMessage": preparedMessage
            }];
            [options addEntriesFromDictionary:[self _optionsForMessageActions]];
            
            [preparedActions addObject:@{
                @"action": [self _sendMessagePathForMessageId:preparedMessage.mid],
                @"options": options
            }];
            
            [addedMessages addObject:message];
            
            if (preparedMessage.replacingMid != 0)
                [replaceInDatabaseMessages addObject:@[@(preparedMessage.replacingMid), message]];
            else
                [addToDatabaseMessages addObject:message];
            
            if (preparedMessage.executeOnAdd) {
                preparedMessage.executeOnAdd();
            }
        }
    }
    
    for (TGPreparedMessage *preparedMessage in forwardedMessages)
    {
        if (preparedMessage.randomId == 0)
        {
            int64_t randomId = 0;
            arc4random_buf(&randomId, sizeof(randomId));
            preparedMessage.randomId = randomId;
        }
        
        if (preparedMessage.mid == 0)
            preparedMessage.mid = [[TGDatabaseInstance() generateLocalMids:1][0] intValue];
        
        preparedMessage.date = (int)[[TGTelegramNetworking instance] approximateRemoteTime];
        
        TGMessage *message = [preparedMessage message];
        if (message == nil)
        {
            TGLog(@"***** Failed to generate message from prepared message");
            continue;
        }
        
        message.layer = [self layer];
        
        message.outgoing = true;
        message.fromUid = self.messageAuthorPeerId;
        message.toUid = self.conversationId;
        message.deliveryState = TGMessageDeliveryStatePending;
        message.sortKey = TGMessageSortKeyMake(_conversationId, TGMessageSpaceImportant, (int32_t)message.date, message.mid);
        message.cid = _conversationId;
        [self _setupOutgoingMessage:message];
        
        if ([self _messagesNeedRandomId])
            message.randomId = preparedMessage.randomId;
        
        if (TGPeerIdIsChannel(_conversationId)) {
            NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:message.contentProperties];
            contentProperties[@"contentsRead"] = [[TGMessageViewedContentProperty alloc] init];
            message.contentProperties = contentProperties;
        }
        
        NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                         @"preparedMessage": preparedMessage
                                                                                         }];
        [options addEntriesFromDictionary:[self _optionsForMessageActions]];
        
        [preparedActions addObject:@{
                                     @"action": [self _sendMessagePathForMessageId:preparedMessage.mid],
                                     @"options": options
                                     }];
        
        [addedMessages addObject:message];
        
        if (preparedMessage.replacingMid != 0)
            [replaceInDatabaseMessages addObject:@[@(preparedMessage.replacingMid), message]];
        else
            [addToDatabaseMessages addObject:message];
    }
    
    if (addToDatabaseMessages.count != 0)
    {
        if (TGPeerIdIsChannel(_conversationId)) {
            [TGDatabaseInstance() addMessagesToChannel:_conversationId messages:addToDatabaseMessages deleteMessages:nil unimportantGroups:nil addedHoles:nil removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:nil keepUnreadCounters:false changedMessages:nil];
        } else {
            [TGDatabaseInstance() transactionAddMessages:addToDatabaseMessages updateConversationDatas:nil notifyAdded:false];
        }
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]] resource:[[SGraphObjectNode alloc] initWithObject:addToDatabaseMessages]];
    }
    
    if (replaceInDatabaseMessages.count != 0)
    {
        [TGDatabaseInstance() dispatchOnDatabaseThread:^
        {
            NSMutableArray<TGDatabaseUpdateMessage *> *messageUpdates = [[NSMutableArray alloc] init];
            
            for (NSArray *pair in replaceInDatabaseMessages)
            {
                TGMessage *updatedMessage = pair[1];
                
                std::vector<TGDatabaseMessageFlagValue> flags;
                flags.push_back((TGDatabaseMessageFlagValue){ .flag = TGDatabaseMessageFlagMid, .value = updatedMessage.mid });
                flags.push_back((TGDatabaseMessageFlagValue){ .flag = TGDatabaseMessageFlagDeliveryState, .value = updatedMessage.deliveryState });
                flags.push_back((TGDatabaseMessageFlagValue){ .flag = TGDatabaseMessageFlagDate, .value = (int)updatedMessage.date });
                
                TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[pair[0] intValue] peerId:_conversationId];
                if (message != nil) {
                    message.mid = updatedMessage.mid;
                    message.deliveryState = updatedMessage.deliveryState;
                    message.date = updatedMessage.date;
                    [messageUpdates addObject:[[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:_conversationId messageId:[pair[0] intValue] message:message dispatchEdited:false]];
                }
            }
            
            [TGDatabaseInstance() transactionUpdateMessages:messageUpdates updateConversationDatas:nil];
        } synchronous:false];
    }
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        for (NSDictionary *action in preparedActions)
        {
            [ActionStageInstance() requestActor:action[@"action"] options:action[@"options"] watcher:self];
            if ([ActionStageInstance() executingActorWithPath:action[@"action"]] != nil) // in case of instantaneous error
                [ActionStageInstance() requestActor:action[@"action"] options:action[@"options"] watcher:TGTelegraphInstance];
        }
    }];
    
    if (automaticallyAddToList)
    {
        if (intent == TGSendMessageIntentSendText)
            [self lockSendMessageSemaphore];
        
        TGModernConversationAddMessageIntent addIntent = TGModernConversationAddMessageIntentGeneric;
        switch (intent)
        {
            case TGSendMessageIntentSendText:
                addIntent = TGModernConversationAddMessageIntentSendTextMessage;
                break;
            case TGSendMessageIntentSendOther:
                addIntent = TGModernConversationAddMessageIntentSendOtherMessage;
                break;
            default:
                break;
        }
        
        if ((_manualMessageManagement && [self shouldFastScrollDown]) || _moreMessagesAvailableBelow)
        {
            if (addIntent == TGModernConversationAddMessageIntentSendTextMessage || addIntent == TGModernConversationAddMessageIntentSendOtherMessage)
                [self _performFastScrollDown:addIntent == TGModernConversationAddMessageIntentSendTextMessage becauseOfNavigation:false];
        }
        else
            [self _addMessages:addedMessages animated:true intent:addIntent];
    }
    
    if (showStickersRestrictedAlert || showMediaRestrictedAlert) {
        TGDispatchOnMainThread(^{
            if (showStickersRestrictedAlert) {
                [TGAlertView presentAlertWithTitle:nil message:TGLocalized(@"Group.ErrorSendRestrictedStickers") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
            } else if (showMediaRestrictedAlert) {
                [TGAlertView presentAlertWithTitle:nil message:TGLocalized(@"Group.ErrorSendRestrictedMedia") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
            }
        });
    }
    
    return addedMessages;
}

- (void)_performFastScrollDown:(bool)becauseOfSendTextAction becauseOfNavigation:(bool)becauseOfNavigation
{
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        [TGDatabaseInstance() loadMessagesFromConversation:_conversationId maxMid:INT_MAX maxDate:INT_MAX maxLocalMid:INT_MAX atMessageId:0 limit:50 extraUnread:false completion:^(NSArray *messages, __unused bool historyExistsBelow)
        {
            NSMutableArray *sortedTopMessages = [[NSMutableArray alloc] initWithArray:messages];
            [sortedTopMessages sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
            {
                NSTimeInterval date1 = message1.date;
                NSTimeInterval date2 = message2.date;
                
                if (ABS(date1 - date2) < DBL_EPSILON)
                {
                    if (message1.mid > message2.mid)
                        return NSOrderedAscending;
                    else
                        return NSOrderedDescending;
                }
                
                return date1 > date2 ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                _moreMessagesAvailableBelow = false;
                _moreMessagesAvailableAbove = true;
                
                [self _replaceMessagesWithFastScroll:sortedTopMessages intent:becauseOfNavigation ? TGModernConversationAddMessageIntentGeneric : (becauseOfSendTextAction ? TGModernConversationAddMessageIntentSendTextMessage : TGModernConversationAddMessageIntentSendOtherMessage) scrollToMessageId:0 scrollBackMessageId:0 animated:true];
            }];
        }];
    } synchronous:false];
}

- (void)controllerClearedConversation
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = self.controller;
        [controller setEnableAboveHistoryRequests:false];
        [controller setEnableBelowHistoryRequests:false];
    });
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        _moreMessagesAvailableAbove = false;
        _moreMessagesAvailableBelow = false;
        
        _messageUploadProgress.clear();
        
        static int uniqueId = 0;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/clearHistory/(%s%d)", _conversationId, __PRETTY_FUNCTION__, uniqueId++] options:@{@"conversationId": @(_conversationId)} watcher:TGTelegraphInstance];
        
        NSIndexSet *indexSet = _items.count == 0 ? [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _items.count)] : [NSIndexSet indexSet];
        
        [(NSMutableArray *)_items removeAllObjects];
        
        [self updateControllerEmptyState:false];
        [self _itemsUpdated];
        
        TGDispatchOnMainThread(^{
            TGModernConversationController *controller = self.controller;
            [controller deleteItemsAtIndices:indexSet animated:true];
        });
    }];
}

- (void)systemClearedConversation
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        _moreMessagesAvailableAbove = false;
        _moreMessagesAvailableBelow = false;
        
        _messageUploadProgress.clear();
        
        [(NSMutableArray *)_items removeAllObjects];
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = self.controller;
            [controller replaceItems:@[] messageIdForVisibleHoleDirection:0];
        });
        
        [self updateControllerEmptyState:false];
        [self _itemsUpdated];
    }];
}

- (void)controllerDeletedMessages:(NSArray *)messageIds forEveryone:(bool)forEveryone completion:(void (^)())completion
{
    if (messageIds.count == 0)
        return;
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        NSMutableArray *currentMessageIds = [[NSMutableArray alloc] init];
        NSMutableArray *attachedMessageIds = [[NSMutableArray alloc] init];
        
        std::set<int> messageIdSet;
        for (NSNumber *nMid in messageIds)
        {
            messageIdSet.insert([nMid intValue]);
            if ([self attachedPeerId] != 0 && [nMid intValue] < TGMessageLocalMidBaseline && [nMid intValue] >= migratedMessageIdOffset) {
                [attachedMessageIds addObject:@([nMid intValue] - migratedMessageIdOffset)];
            } else {
                [currentMessageIds addObject:nMid];
            }
        }
        
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        int index = -1;
        for (TGMessageModernConversationItem *messageItem in _items)
        {
            index++;
            
            if (messageIdSet.find(messageItem->_message.mid) != messageIdSet.end())
            {
                [indexSet addIndex:index];
            }
        }
        
        [(NSMutableArray *)_items removeObjectsAtIndexes:indexSet];
        [self _itemsUpdated];
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = self.controller;
            [controller deleteItemsAtIndices:indexSet animated:true];
            if (completion)
                completion();
        });
        
        static int uniqueId = 0;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/deleteMessages/(%s%d)", _conversationId, __PRETTY_FUNCTION__, uniqueId++] options:@{@"mids": currentMessageIds, @"forEveryone": @(forEveryone)} watcher:TGTelegraphInstance];
        
        if (attachedMessageIds.count != 0 && [self attachedPeerId] != 0) {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/deleteMessages/(%s%d)", [self attachedPeerId], __PRETTY_FUNCTION__, uniqueId++] options:@{@"mids": attachedMessageIds, @"forEveryone": @(forEveryone)} watcher:TGTelegraphInstance];
        }
    }];
}

- (void)controllerRequestedNavigationToConversationWithUser:(int32_t)uid
{
    [[TGInterfaceManager instance] navigateToConversationWithId:uid conversation:nil];
}

- (void)_markIncomingMessagesAsReadSilent
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        int32_t maxMessageId = 0;
        int32_t maxDate = 0;
        for (TGMessageModernConversationItem *item in _items) {
            if (!item->_message.outgoing) {
                maxMessageId = MAX(maxMessageId, item->_message.mid);
                maxDate = MAX(maxDate, (int32_t)item->_message.date);
            }
        }
        
        [_conversationAtomic modify:^id(TGConversation *conversation) {
            TGConversation *updatedConversation = [conversation copy];
            updatedConversation.maxReadMessageId = MAX(maxMessageId, updatedConversation.maxReadMessageId);
            updatedConversation.maxReadDate = MAX(maxDate, updatedConversation.maxReadDate);
            return updatedConversation;
        }];
        
     }];
}

- (void)controllerCanReadHistoryUpdated
{
    if (!self.previewMode) {
        TGModernConversationController *controller = self.controller;
        bool canReadHistory = [controller canReadHistory];
        if (canReadHistory)
        {
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                if (_needsToReadHistory)
                {
                    _needsToReadHistory = false;
                    
                    [self _markIncomingMessagesAsReadSilent];
                    
                    [TGDatabaseInstance() transactionReadHistoryForPeerIds:[[NSSet alloc] initWithArray:@[@(_conversationId)]]];
                }
            }];
        }
    }
}

- (void)controllerCanRegroupUnreadIncomingMessages
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        __block TGMessageRange unreadRange = TGMessageRangeEmpty();
        
        [_conversationAtomic with:^id(TGConversation *conversation) {
            for (TGMessageModernConversationItem *item in _items) {
                if (!item->_message.outgoing && [conversation isMessageUnread:item->_message]) {
                    if (unreadRange.firstMessageId == INT32_MAX || unreadRange.firstMessageId > item->_message.mid) {
                        unreadRange.firstMessageId = item->_message.mid;
                        unreadRange.firstDate = (int32_t)item->_message.date;
                    } if (unreadRange.lastMessageId == INT32_MAX || unreadRange.lastMessageId < item->_message.mid) {
                        unreadRange.lastMessageId = item->_message.mid;
                        unreadRange.lastDate = (int32_t)item->_message.date;
                    }
                }
            }
            
            return nil;
        }];
        
        if (unreadRange.firstMessageId != INT32_MAX && unreadRange.lastMessageId != INT32_MAX)
        {
            TGDispatchOnMainThread(^
            {
                TGModernConversationController *controller = self.controller;
                [controller setUnreadMessageRangeIfAppropriate:unreadRange];
            });
        }
    }];
}

#pragma mark -

- (void)controllerWantsToCreateContact:(int32_t)uid firstName:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber
{
    TGCreateContactController *createContactController = nil;
    if (uid > 0)
        createContactController = [[TGCreateContactController alloc] initWithUid:uid firstName:firstName lastName:lastName phoneNumber:phoneNumber];
    else
        createContactController = [[TGCreateContactController alloc] initWithFirstName:firstName lastName:lastName phoneNumber:phoneNumber];
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[createContactController]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    TGModernConversationController *controller = self.controller;
    [controller presentViewController:navigationController animated:true completion:nil];
}

- (void)controllerWantsToAddContactToExisting:(int32_t)uid phoneNumber:(NSString *)phoneNumber
{
    TGAddToExistingContactController *addToExistingController = [[TGAddToExistingContactController alloc] initWithUid:uid phoneNumber:phoneNumber];
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[addToExistingController]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    TGModernConversationController *controller = self.controller;
    [controller presentViewController:navigationController animated:true completion:nil];
}

- (void)controllerWantsToApplyLocalization:(NSString *)filePath
{
    TGSetLocalizationFromFile(filePath);
    [TGAppDelegateInstance resetLocalization];
    
    [TGAppDelegateInstance resetControllerStack];
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:false];
    [progressWindow dismissWithSuccess];
}

#pragma mark -

- (void)loadMoreMessagesAbove
{
    if (_manualMessageManagement)
        return;
    
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = self.controller;
        [controller setEnableAboveHistoryRequests:false];
    });
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        if (_moreMessagesAvailableAbove && !_loadingMoreMessagesAbove)
        {
            _loadingMoreMessagesAbove = true;
            
            int minMid = INT_MAX;
            int minLocalMid = INT_MAX;
            int index = 0;
            int minDate = INT_MAX;
            
            NSArray *items = _items;
            for (int i = (int)items.count - 1; i >= 0; i--)
            {
                TGModernConversationItem *item = items[i];
                if ([item isKindOfClass:[TGMessageModernConversationItem class]])
                {
                    TGMessage *message = ((TGMessageModernConversationItem *)item)->_message;
                    if (message.mid < TGMessageLocalMidBaseline)
                    {
                        if (message.mid < minMid)
                            minMid = message.mid;
                        index++;
                    }
                    else
                    {
                        if (message.mid < minLocalMid)
                            minLocalMid = message.mid;
                    }
                    
                    if ((int)message.date < minDate)
                        minDate = (int)message.date;
                }
            }
            
            if (minMid == INT_MAX)
                minMid = 0;
            if (minLocalMid == INT_MAX)
                minLocalMid = 0;
            if (minDate == INT_MAX)
                minDate = 0;
            
            NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:@{
                @"maxMid": @(minMid),
                @"maxLocalMid": @(minLocalMid),
                @"offset": @(index),
                @"maxDate": @(minDate)
            }];
            
            [options addEntriesFromDictionary:[self _optionsForMessageActions]];
            
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/conversations/(%lld)/history/(up%d)", _conversationId, minMid] options:options watcher:self];
        }
    }];
}


- (void)loadMoreMessagesBelow
{
    if (_manualMessageManagement)
        return;
    
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = self.controller;
        [controller setEnableBelowHistoryRequests:false];
    });
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        if (_moreMessagesAvailableBelow && !_loadingMoreMessagesBelow)
        {
            _loadingMoreMessagesBelow = true;
            
            int maxMid = INT_MIN;
            int maxLocalMid = INT_MIN;
            int maxDate = INT_MIN;
            
            int count = (int)_items.count;
            
            for (int i = 0; i < count; i++)
            {
                TGMessageModernConversationItem *messageItem = _items[i];
                
                if (messageItem->_message.mid < TGMessageLocalMidBaseline)
                {
                    if (messageItem->_message.mid > maxMid)
                        maxMid = messageItem->_message.mid;
                }
                else
                {
                    if (messageItem->_message.mid > maxLocalMid)
                        maxLocalMid = messageItem->_message.mid;
                }
                
                if ((int)messageItem->_message.date > maxDate)
                    maxDate = (int)messageItem->_message.date;
            }
            
            if (maxMid == INT_MIN)
                maxMid = 0;
            if (maxLocalMid == INT_MIN)
                maxLocalMid = 0;
            if (maxDate == INT_MIN)
                maxDate = 0;
            
            NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:@{
                @"maxMid": @(maxMid),
                @"maxLocalMid": @(maxLocalMid),
                @"maxDate": @(maxDate),
                @"downwards": @(true)
            }];
            
            [options addEntriesFromDictionary:[self _optionsForMessageActions]];
            
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversations/(%lld)/history/(down%d)", _conversationId, maxMid] options:options watcher:self];
        }
    }];
}

- (void)unloadMessagesAbove
{
    [self _unloadMessages:true];
}

- (void)unloadMessagesBelow
{
    [self _unloadMessages:false];
}

- (void)_unloadMessages:(bool)above
{
    TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = self.controller;
        [controller setEnableUnloadHistoryRequests:false];
    });
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        if ((int)_items.count >= TGModernConversationControllerUnloadHistoryLimit)
        {
            NSIndexSet *indexSet = nil;
            
            if (above)
            {
                indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(TGModernConversationControllerUnloadHistoryLimit, _items.count - TGModernConversationControllerUnloadHistoryLimit)];
                [(NSMutableArray *)_items removeObjectsAtIndexes:indexSet];
                
                TGLog(@"Unloaded %d items above (%d now)", indexSet.count, _items.count);
                
                _moreMessagesAvailableAbove = true;
            }
            else
            {
                indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _items.count - TGModernConversationControllerUnloadHistoryLimit)];
                [(NSMutableArray *)_items removeObjectsAtIndexes:indexSet];
                
                TGLog(@"Unloaded %d items below (%d now)", indexSet.count, _items.count);
                
                _moreMessagesAvailableBelow = true;
            }
            
            [self _itemsUpdated];
            
            TGDispatchOnMainThread(^
            {
                TGModernConversationController *controller = self.controller;
                [controller deleteItemsAtIndices:indexSet animated:false];
                [controller setEnableUnloadHistoryRequests:true];
                if (above)
                    [controller setEnableAboveHistoryRequests:true];
                else
                    [controller setEnableBelowHistoryRequests:true];
            });
        }
        else
        {
            TGDispatchOnMainThread(^
            {
                TGModernConversationController *controller = self.controller;
                [controller setEnableUnloadHistoryRequests:true];
            });
        }
    }];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    TGModernConversationController *controller = self.controller;
    if ([controller maybeShowDiscardRecordingAlert])
        return;
    
    if ([action isEqualToString:@"userAvatarTapped"])
    {
        if ([options[@"uid"] intValue] > 0) {
            [self actionStageActionRequested:@"openLinkRequested" options:@{@"url": [NSString stringWithFormat:@"tg-user://%d", [options[@"uid"] intValue]], @"mid": @([options[@"mid"] intValue])}];
            //[[TGInterfaceManager instance] navigateToProfileOfUser:[options[@"uid"] intValue]];
        }
        else {
            [self _controllerAvatarPressed];
        }
    }
    else if ([action isEqualToString:@"peerAvatarTapped"])
    {
        int64_t peerId = [options[@"peerId"] longLongValue];
        int32_t messageId = [options[@"messageId"] intValue];
        if (peerId != 0) {
            if (TGPeerIdIsChannel(peerId)) {
                if (peerId == _conversationId) {
                    [self _controllerAvatarPressed];
                } else {
                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    [progressWindow show:true];
                    [[[[TGChannelManagementSignals preloadedChannelAtMessage:peerId messageId:messageId] deliverOn:[SQueue mainQueue]] onDispose:^{
                        TGDispatchOnMainThread(^{
                            [progressWindow dismiss:true];
                        });
                    }] startWithNext:^(TGConversation *conversation) {
                        [[TGInterfaceManager instance] navigateToConversationWithId:peerId conversation:conversation performActions:@{} atMessage:@{@"mid": @(messageId)} clearStack:false openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
                    } error:^(id error) {
                        NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                        if ([errorType isEqualToString:@"PEER_ID_INVALID"] || [errorType isEqualToString:@"CHANNEL_PRIVATE"]) {
                            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Channel.ErrorAccessDenied") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                        }
                    } completed:nil];
                }
            }
        }
    }
    else if ([action isEqualToString:@"openContact"])
    {
        TGContactMediaAttachment *contactAttachment = options[@"contactAttachment"];
        if (contactAttachment.uid != 0)
            [[TGInterfaceManager instance] navigateToProfileOfUser:contactAttachment.uid];
    }
    else if ([action isEqualToString:@"openLinkRequested"])
    {
        if ([options[@"url"] hasPrefix:@"tg-user://"])
        {
            int32_t uid = (int32_t)[[options[@"url"] substringFromIndex:@"tg-user://".length] intValue];
            if (uid != 0) {
                TGUser *user = [TGDatabaseInstance() loadUser:uid];
                int32_t messageId = [options[@"mid"] intValue];

                if (user.phoneNumberHash != 0 || user.phoneNumber.length != 0 || messageId == 0) {
                    [[TGInterfaceManager instance] navigateToProfileOfUser:uid];
                } else {
                    TGDownloadMessage *downloadMessage = [[TGDownloadMessage alloc] initWithPeerId:[self requestPeerId] accessHash:[self requestAccessHash] messageId:messageId];
                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                    [progressWindow showWithDelay:0.2];
                    [_getMessageForMentionDisposable setDisposable:[[[[TGDownloadMessagesSignal downloadMessages:@[downloadMessage]] onDispose:^{
                        TGDispatchOnMainThread(^{
                            [progressWindow dismiss:true];
                        });
                    }] deliverOn:[SQueue mainQueue]] startWithNext:nil completed:^{
                        [[TGInterfaceManager instance] navigateToProfileOfUser:uid];
                    }]];
                }
            }
            
            return;
        }
        else if ([options[@"url"] hasPrefix:@"mention://"])
        {   
            NSString *domain = [options[@"url"] substringFromIndex:@"mention://".length];
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/resolveDomain/(%@,profile)", domain] options:@{@"domain": domain, @"profile": @true, @"keepStack": @true} flags:0 watcher:TGTelegraphInstance];
            return;
        }
        else if ([options[@"url"] hasPrefix:@"hashtag://"])
        {
            NSString *hashtag = [options[@"url"] substringFromIndex:@"hashtag://".length];
            
            TGHashtagSearchController *hashtagController = [[TGHashtagSearchController alloc] initWithQuery:[@"#" stringByAppendingString:hashtag] peerId:[self requestPeerId] accessHash:[self requestAccessHash]];
            __weak TGGenericModernConversationCompanion *weakSelf = self;
            hashtagController.customResultBlockPeerId = _conversationId;
            hashtagController.customResultBlock = ^(int32_t messageId) {
                __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf navigateToMessageId:messageId scrollBackMessageId:0 animated:true];
                    TGModernConversationController *controller = strongSelf.controller;
                    [controller.navigationController popToViewController:controller animated:true];
                }
            };
            
            TGModernConversationController *controller = self.controller;
            [controller.navigationController pushViewController:hashtagController animated:true];
            
            return;
        }
        else if ([options[@"url"] hasPrefix:@"command://"])
        {
            int32_t mid = [options[@"mid"] intValue];
            NSString *command = [options[@"url"] substringFromIndex:@"command://".length];
            
            if ([command rangeOfString:@"@"].location == NSNotFound)
            {
                TGModernConversationController *controller = self.controller;
                for (TGMessageModernConversationItem *item in [controller _items])
                {
                    if (item->_message.mid == mid)
                    {
                        TGUser *user = [TGDatabaseInstance() loadUser:(int)(item->_message.fromUid)];
                        if (![self isASingleBotGroup] && user.uid != self.conversationId && user.userName.length != 0 && (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot))
                        {
                            command = [command stringByAppendingFormat:@"@%@", user.userName];
                        }
                        break;
                    }
                }
            }
            
            [self controllerWantsToSendTextMessage:command entities:nil asReplyToMessageId:0 withAttachedMessages:nil disableLinkPreviews:false botContextResult:nil botReplyMarkup:nil];
            
            //TGModernConversationController *controller = self.controller;
            //[controller appendCommand:command];
            
            return;
        } else if ([options[@"url"] hasPrefix:@"activate-app://"]) {
            int64_t peerId = _conversationId;
            __weak TGGenericModernConversationCompanion *weakSelf = self;
            [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                int32_t messageId = [[options[@"url"] substringFromIndex:@"activate-app://".length] intValue];
                if (messageId != 0) {
                    TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:peerId];
                    TGMessage *replyMessage = nil;
                    for (id attachment in message.mediaAttachments) {
                        if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]]) {
                            replyMessage = ((TGReplyMessageMediaAttachment *)attachment).replyMessage;
                            break;
                        }
                    }
                    for (id attachment in message.mediaAttachments) {
                        if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
                            replyMessage = message;
                            break;
                        }
                    }
                    if (replyMessage != nil) {
                        for (TGBotReplyMarkupRow *row in replyMessage.replyMarkup.rows) {
                            for (TGBotReplyMarkupButton *button in row.buttons) {
                                if ([button.action isKindOfClass:[TGBotReplyMarkupButtonActionGame class]]) {
                                    TGDispatchOnMainThread(^{
                                        __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                                        if (strongSelf != nil) {
                                            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{@"mid": @(replyMessage.mid), @"command": button.text}];
                                            if (button.action != nil) {
                                                dict[@"action"] = button.action;
                                            }
                                            dict[@"index"] = @(0);
                                            [strongSelf.actionHandle requestAction:@"activateCommand" options:dict];
                                        }
                                    });
                                    
                                    break;
                                }
                            }
                        }
                    }
                }
            } synchronous:false];
            return;
        }
    }
    else if ([action isEqualToString:@"showContactMessageMenu"])
    {
        TGModernConversationController *controller = self.controller;
        
        TGUser *contact = options[@"contact"];
        if (contact != nil)
        {
            if ([options[@"addMode"] boolValue])
                [controller showAddContactMenu:contact];
            else
                [controller showActionsMenuForContact:contact isContact:(contact.uid != 0 && [TGDatabaseInstance() uidIsRemoteContact:contact.uid]) || [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(contact.phoneNumber)] != nil];
        }
    }
    else if ([action isEqualToString:@"mediaDownloadRequested"])
    {
        int32_t mid = (int32_t)[options[@"mid"] intValue];
        
        bool alreadyProcessing = false;
        TG_SYNCHRONIZED_BEGIN(_processingDownloadMids);
        alreadyProcessing = _processingDownloadMids.find(mid) != _processingDownloadMids.end();
        if (!alreadyProcessing)
            _processingDownloadMids.insert(mid);
        TG_SYNCHRONIZED_END(_processingDownloadMids);
        
        if (!alreadyProcessing)
        {
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                int index = -1;
                
                for (TGMessageModernConversationItem *messageItem in _items)
                {
                    index++;
                    
                    if (messageItem->_message.mid == mid)
                    {
                        if (!messageItem->_mediaAvailabilityStatus)
                        {
                            TGDispatchOnMainThread(^
                            {
                                //TGModernConversationController *controller = self.controller;
                                //[controller updateItemProgressAtIndex:index toProgress:0.0f];
                            });
                            
                            [self _downloadMediaInMessage:messageItem->_message highPriority:true];
                        }
                        
                        break;
                    }
                }
                
                TG_SYNCHRONIZED_BEGIN(_processingDownloadMids);
                _processingDownloadMids.erase(mid);
                TG_SYNCHRONIZED_END(_processingDownloadMids);
            }];
        }
    }
    else if ([action isEqualToString:@"mediaProgressCancelRequested"])
    {
        int32_t mid = (int32_t)[options[@"mid"] intValue];
        
        bool alreadyProcessing = false;
        TG_SYNCHRONIZED_BEGIN(_processingDownloadMids);
        alreadyProcessing = _processingDownloadMids.find(mid) != _processingDownloadMids.end();
        if (!alreadyProcessing)
            _processingDownloadMids.insert(mid);
        TG_SYNCHRONIZED_END(_processingDownloadMids);
        
        if (!alreadyProcessing)
        {
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                int index = -1;
                
                bool deleteMessage = false;
                
                for (TGMessageModernConversationItem *messageItem in _items)
                {
                    index++;
                    
                    if (messageItem->_message.mid == mid)
                    {
                        TGDispatchOnMainThread(^
                        {
                            //TGModernConversationController *controller = self.controller;
                            //[controller updateItemProgressAtIndex:index toProgress:0.0f];
                        });
                        
                        id itemId = mediaIdForMessage(messageItem->_message);
                        [[TGDownloadManager instance] cancelItem:itemId];
                        
                        deleteMessage = messageItem->_message.deliveryState == TGMessageDeliveryStatePending;
                        
                        break;
                    }
                }
                
                if (_messageUploadProgress.find(mid) != _messageUploadProgress.end() || deleteMessage)
                {
                    [self _deleteMessages:@[@(mid)] animated:true];
                    [self controllerDeletedMessages:@[@(mid)] forEveryone:true completion:nil];
                }
                
                TG_SYNCHRONIZED_BEGIN(_processingDownloadMids);
                _processingDownloadMids.erase(mid);
                TG_SYNCHRONIZED_END(_processingDownloadMids);
            }];
        }
    }
    else if ([action isEqualToString:@"mapViewForward"])
    {
        if (options[@"message"] != nil)
        {
            TGMessage *message = options[@"message"];
            [self controllerWantsToForwardMessages:@[@(message.mid)]];
        }
    }
    else if ([action isEqualToString:@"willForwardMessages"])
    {
        int64_t targetConversationId = 0;
        if ([options[@"target"] isKindOfClass:[TGUser class]])
            targetConversationId = ((TGUser *)options[@"target"]).uid;
        else if ([options[@"target"] isKindOfClass:[TGConversation class]])
            targetConversationId = ((TGConversation *)options[@"target"]).conversationId;
        
        if (targetConversationId == _conversationId)
        {
            TGModernConversationController *controller = self.controller;
            [controller leaveEditingMode];
        }
        
        TGModernConversationController *controller = self.controller;
        [controller dismissViewControllerAnimated:true completion:nil];
    }
    else if ([action isEqualToString:@"navigateToMessage"])
    {
        [self navigateToMessageId:[options[@"mid"] intValue] scrollBackMessageId:[options[@"sourceMid"] intValue] animated:true];
    }
    else if ([action isEqualToString:@"fastForwardMessage"])
    {
        TGModernConversationController *controller = self.controller;
        [controller forwardMessages:@[options[@"mid"]] fastForward:true];
    }
    else if ([action isEqualToString:@"useContextBot"]) {
        TGModernConversationController *controller = self.controller;
        NSString *username = options[@"username"];
        if (username.length == 0) {
            TGUser *user = [TGDatabaseInstance() loadUser:[options[@"uid"] intValue]];
            if (user != nil && user.userName.length != 0) {
                username = user.userName;
            }
        }

        if (username.length != 0) {
            if (![controller hasNonTextInputPanel]) {
                [controller setInputText:[[NSString alloc] initWithFormat:@"@%@ ", username] replace:true selectRange:NSMakeRange(0, 0)];
                [controller openKeyboard];
            }
        }
    }
    else if ([action isEqualToString:@"activateCommand"]) {
        NSString *command = options[@"command"];
        id action = options[@"action"];
        int32_t messageId = [options[@"mid"] intValue];
        NSInteger index = [options[@"index"] intValue];
        
        int32_t replyMessageId = 0;
        if (_conversationId < 0) {
            replyMessageId = messageId;
        }
        
        if ([action isKindOfClass:[TGBotReplyMarkupButtonActionUrl class]]) {
            NSString *url = ((TGBotReplyMarkupButtonActionUrl *)action).url;
            if (url.length != 0) {
                bool hiddenLink = true;
                if (TGPeerIdIsUser(_conversationId)) {
                    TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)_conversationId];
                    if (user.isVerified) {
                        hiddenLink = false;
                    }
                }
                if (hiddenLink && ([url hasPrefix:@"http://telegram.me/"] || [url hasPrefix:@"http://t.me/"] || [url hasPrefix:@"https://telegram.me/"] || [url hasPrefix:@"https://t.me/"])) {
                    hiddenLink = false;
                }
                [self actionStageActionRequested:@"openLinkRequested" options:@{@"url": url, @"hidden": @(hiddenLink)}];
            }
        } else if ([action isKindOfClass:[TGBotReplyMarkupButtonActionRequestLocation class]]) {
            SVariable *location = [[SVariable alloc] init];
            SVariable *locationRequired = [[SVariable alloc] init];
            SSignal *signal = [[[TGLocationSignals userLocation:locationRequired] timeout:5.0 onQueue:[SQueue mainQueue] orSignal:[SSignal fail:nil]] catch:^SSignal *(__unused id error) {
                return [SSignal single:nil];
            }];
            [location set:signal];
            
            __weak TGGenericModernConversationCompanion *weakSelf = self;
            [TGAlertView presentAlertWithTitle:TGLocalized(@"Conversation.ShareBotLocationConfirmationTitle") message:TGLocalized(@"Conversation.ShareBotLocationConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed) {
                if (okButtonPressed) {
                    __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [locationRequired set:[SSignal single:@true]];
                        
                        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                        [progressWindow showWithDelay:0.1];
                        
                        [[[[[location signal] take:1] deliverOn:[SQueue mainQueue]] onDispose:^{
                            [progressWindow dismiss:true];
                        }] startWithNext:^(CLLocation *location) {
                            __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                [strongSelf controllerWantsToSendMapWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude venue:nil asReplyToMessageId:replyMessageId botContextResult:nil botReplyMarkup:nil];
                            }
                        } error:^(__unused id error) {
                            
                        } completed:nil];
                    }
                }
            }];
        } else if ([action isKindOfClass:[TGBotReplyMarkupButtonActionRequestPhone class]]) {
            __weak TGGenericModernConversationCompanion *weakSelf = self;
            [TGAlertView presentAlertWithTitle:TGLocalized(@"Conversation.ShareBotContactConfirmationTitle") message:TGLocalized(@"Conversation.ShareBotContactConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed) {
                if (okButtonPressed) {
                    __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf shareVCard];
                    }
                }
            }];
        } else if ([action isKindOfClass:[TGBotReplyMarkupButtonActionSwitchInline class]]) {
            NSString *query = ((TGBotReplyMarkupButtonActionSwitchInline *)action).query;
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:_conversationId];
            int32_t userId = (int)message.fromUid;
            for (id attachment in message.mediaAttachments) {
                if ([attachment isKindOfClass:[TGViaUserAttachment class]]) {
                    userId = ((TGViaUserAttachment *)attachment).userId;
                }
            }
            TGUser *user = [TGDatabaseInstance() loadUser:userId];
            if (user.userName.length != 0) {
                NSString *text = [[NSString alloc] initWithFormat:@"@%@ %@", user.userName, query];
                if (((TGBotReplyMarkupButtonActionSwitchInline *)action).samePeer) {
                    [self.controller setInputText:text replace:true selectRange:NSMakeRange(0, 0)];
                    [self.controller openKeyboard];
                } else {
                    if (_botContextPeerId != nil && [_botContextPeerId longLongValue] != 0) {
                        [[TGInterfaceManager instance] navigateToConversationWithId:[_botContextPeerId longLongValue] conversation:nil performActions:@{@"replaceInitialText": text} atMessage:@{} clearStack:true openKeyboard:true canOpenKeyboardWhileInTransition:false animated:true];
                    } else {
                        NSMutableDictionary *linkInfo = [[NSMutableDictionary alloc] init];
                        linkInfo[@"text"] = text;
                        linkInfo[@"replace"] = @true;
                        
                        TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:nil sendMessages:nil shareLink:linkInfo showSecretChats:true];
                        forwardController.skipConfirmation = true;
                        
                        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[forwardController]];
                        
                        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                        {
                            navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                        }
                        
                        [self.controller presentViewController:navigationController animated:true completion:nil];
                    }
                }
            }
        } else if ([action isKindOfClass:[TGBotReplyMarkupButtonActionCallback class]] || [action isKindOfClass:[TGBotReplyMarkupButtonActionGame class]]) {
            int64_t peerId = _conversationId;
            int64_t accessHash = _accessHash;
            if (messageId < TGMessageLocalMidBaseline) {
                __weak TGGenericModernConversationCompanion *weakSelf = self;
                void (^accessAllowedBlock)() = ^{
                    __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf == nil) {
                        return;
                    }
                    
                    NSData *actionData = nil;
                    bool isGame = false;
                    if ([action isKindOfClass:[TGBotReplyMarkupButtonActionCallback class]]) {
                        actionData = ((TGBotReplyMarkupButtonActionCallback *)action).data;
                    } else if ([action isKindOfClass:[TGBotReplyMarkupButtonActionGame class]]) {
                        isGame = true;
                    }
                    
                    SSignal *signal = [TGBotSignals botCallback:strongSelf->_conversationId accessHash:[strongSelf requestAccessHash] messageId:messageId data:actionData isGame:isGame];
                    
                    signal = [[signal onStart:^{
                        __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            strongSelf->_callbackInProgressMessageId = messageId;
                            [strongSelf.callbackInProgress set:[SSignal single:@{@"mid": @(messageId), @"buttonIndex": @(index)}]];
                        }
                    }] onDispose:^{
                        __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            strongSelf->_callbackInProgressMessageId = 0;
                            [strongSelf.callbackInProgress set:[SSignal single:nil]];
                        }
                    }];
                    
                    [strongSelf->_botCallbackDisposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *result) {
                        __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            NSString *url = result[@"url"];
                            if (url.length != 0) {
                                if ([action isKindOfClass:[TGBotReplyMarkupButtonActionGame class]]) {
                                    int64_t peerId = _conversationId;
                                    [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                                        TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:peerId];
                                        int32_t userId = (int32_t)message.fromUid;
                                        NSString *gameTitle = nil;
                                        NSString *shareName = nil;
                                        for (id attachment in message.mediaAttachments) {
                                            if ([attachment isKindOfClass:[TGViaUserAttachment class]]) {
                                                userId = ((TGViaUserAttachment *)attachment).userId;
                                            } else if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
                                                gameTitle = ((TGGameMediaAttachment *)attachment).title;
                                                shareName = ((TGGameMediaAttachment *)attachment).shortName;
                                            }
                                        }
                                        TGUser *author = [TGDatabaseInstance() loadUser:userId];
                                        TGDispatchOnMainThread(^{
                                            if (message != nil) {
                                                int64_t randomId = 0;
                                                arc4random_buf(&randomId, 8);
                                                ((TGApplication *)[UIApplication sharedApplication]).gameShareDict[@(randomId)] = [[TGWebAppControllerShareGameData alloc] initWithPeerId:peerId messageId:messageId botName:author.userName shareName:shareName];
                                                NSString *shareString = [NSString stringWithFormat:@"tgShareScoreUrl=%@%lld", [TGStringUtils stringByEscapingForURL:@"tg://gshare?h="], randomId];
                                                NSString *finalUrl = addGameShareHash(url, shareString);
                                                
                                                [(TGApplication *)[UIApplication sharedApplication] nativeOpenURL:[NSURL URLWithString:finalUrl]];
                                                
                                                /*TGWebAppController *controller = [[TGWebAppController alloc] initWithUrl:[NSURL URLWithString:url] title:gameTitle botName:author.userName peerIdForActivityUpdates:peerId peerAccessHashForActivityUpdates:accessHash];
                                                controller.shareGameData = [[TGWebAppControllerShareGameData alloc] initWithPeerId:peerId messageId:messageId botName:author.userName shareName:shareName];
                                                
                                                if (TGIsPad())
                                                {
                                                    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
                                                    
                                                    TGModernConversationController *conversationController = self.controller;
                                                    [conversationController presentViewController:navigationController animated:true completion:nil];
                                                }
                                                else
                                                {
                                                    [TGAppDelegateInstance.rootController pushContentController:controller];
                                                }*/
                                            }
                                        });
                                    } synchronous:false];
                                } else {
                                    bool hiddenLink = true;
                                    if (TGPeerIdIsUser(_conversationId)) {
                                        TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)strongSelf->_conversationId];
                                        if (user.isVerified) {
                                            hiddenLink = false;
                                        }
                                    }
                                    [self actionStageActionRequested:@"openLinkRequested" options:@{@"url": url, @"hidden": @(hiddenLink)}];
                                }
                            } else {
                                NSString *text = result[@"text"];
                                if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 0) {
                                    if ([result[@"alert"] boolValue]) {
                                        [[[TGAlertView alloc] initWithTitle:nil message:text cancelButtonTitle:nil okButtonTitle:TGLocalized(@"Common.OK") completionBlock:nil] show];
                                    } else {
                                        TGToastTitlePanel *panel = [[TGToastTitlePanel alloc] initWithText:text];
                                        panel.dismiss = ^{
                                            __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                                            if (strongSelf != nil) {
                                                [strongSelf->_toastPanel set:[SSignal single:nil]];
                                            }
                                        };
                                        [strongSelf->_toastPanel set:[[SSignal single:panel] then:[[SSignal single:nil] delay:2.0 onQueue:[SQueue mainQueue]]]];
                                    }
                                }
                            }
                        }
                    } error:^(__unused id error) {
                        
                    } completed:nil]];
                };
                
                if ([action isKindOfClass:[TGBotReplyMarkupButtonActionGame class]]) {
                    TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:_conversationId];
                    int32_t userId = (int32_t)message.fromUid;
                    for (id attachment in message.mediaAttachments) {
                        if ([attachment isKindOfClass:[TGViaUserAttachment class]]) {
                            userId = ((TGViaUserAttachment *)attachment).userId;
                            break;
                        }
                    }
                    TGUser *author = [TGDatabaseInstance() loadUser:userId];
                    
                    NSData *data = [TGDatabaseInstance() conversationCustomPropertySync:userId name:murMurHash32(@"botWebAccessAllowed")];

                    if (data.length != 0 || author.isVerified) {
                        accessAllowedBlock();
                    } else {
                        [TGAlertView presentAlertWithTitle:nil message:[NSString stringWithFormat:TGLocalized(@"Conversation.BotInteractiveUrlAlert"), author.displayName] cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed) {
                            if (okButtonPressed) {
                                int8_t one = 1;
                                [TGDatabaseInstance() setConversationCustomProperty:userId name:murMurHash32(@"botWebAccessAllowed") value:[NSData dataWithBytes:&one length:1]];
                                accessAllowedBlock();
                            }
                        }];
                    }
                } else {
                    accessAllowedBlock();
                }
            }
        } else if ([action isKindOfClass:[TGBotReplyMarkupButtonActionPurchase class]]) {
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:_conversationId];
            if (message != nil) {
                bool hasReceipt = false;
                int32_t receiptMessageId = 0;
                for (TGMediaAttachment *media in message.mediaAttachments) {
                    if (media.type == TGInvoiceMediaAttachmentType) {
                        hasReceipt = ((TGInvoiceMediaAttachment *)media).receiptMessageId != 0;
                        receiptMessageId = ((TGInvoiceMediaAttachment *)media).receiptMessageId;
                        break;
                    }
                }
                
                if (hasReceipt) {
                    TGPaymentReceiptController *receiptController = [[TGPaymentReceiptController alloc] initWithMessage:message receiptMessageId:receiptMessageId];
                    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:receiptController];
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleDefault;
                        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
                    }
                    [self.controller presentViewController:navigationController animated:true completion:nil];
                } else {
                    TGPaymentCheckoutController *checkoutController = [[TGPaymentCheckoutController alloc] initWithMessage:message];
                    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:checkoutController];
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleDefault;
                        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
                    }
                    [self.controller presentViewController:navigationController animated:true completion:nil];
                }
            }
        } else {
            [self controllerWantsToSendTextMessage:[[NSString alloc] initWithFormat:@"%@%@", @"", command] entities:nil asReplyToMessageId:replyMessageId withAttachedMessages:@[] disableLinkPreviews:false botContextResult:nil botReplyMarkup:nil];
        }
    } else if ([action isEqualToString:@"activateInstantPage"]) {
        int32_t messageId = [options[@"mid"] intValue];
        TGWebPageMediaAttachment *webpage = options[@"webpage"];
        NSString *fragment = options[@"fragment"];
        TGInstantPageController *pageController = [[TGInstantPageController alloc] initWithWebPage:webpage anchor:fragment.length == 0 ? nil : fragment peerId:_conversationId messageId:messageId];
        [self.controller.navigationController pushViewController:pageController animated:true];
    } else if ([action isEqualToString:@"stopInlineMedia"]) {
        int32_t mid = (int32_t)[options[@"mid"] intValue];
        TGModernConversationController *controller = self.controller;
        [controller stopInlineMedia:mid];
    } else if ([action isEqualToString:@"resumeInlineMedia"]) {
        TGModernConversationController *controller = self.controller;
        [controller resumeInlineMedia];
    } else if ([action isEqualToString:@"replyRequested"]) {
        int32_t mid = [options[@"mid"] intValue];
        TGMessage *replyMessage = [TGDatabaseInstance() loadMessageWithMid:mid peerId:_conversationId];
        if (replyMessage != nil)
            [controller setReplyMessage:replyMessage openKeyboard:true animated:true];
    }
    [super actionStageActionRequested:action options:options];
}

- (void)navigateToMessageId:(int32_t)messageId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        bool found = false;
        for (TGMessageModernConversationItem *item in _items)
        {
            if (item->_message.mid == messageId)
            {
                found = true;
                break;
            }
        }
        
        int32_t sourceMid = scrollBackMessageId;
        
        if (found)
        {
            TGDispatchOnMainThread(^
            {
                TGModernConversationController *controller = self.controller;
                [controller scrollToMessage:messageId sourceMessageId:sourceMid animated:animated];
            });
        }
        else
        {
            if (![self _tryToScrollToMessageId:messageId scrollBackMessageId:sourceMid animated:animated])
            {
                TGDispatchOnMainThread(^{
                    _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    [_progressWindow show:true];
                });
                _loadingMessageForSearch = messageId;
                _sourceMessageForSearch = sourceMid;
                _animatedTransitionInSearch = animated;
                
                [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/loadConversationAndMessageForSearch/(%" PRId64 ", %" PRId32 ")", _conversationId, messageId] options:@{@"peerId": @(_conversationId), @"messageId": @(messageId)} flags:0 watcher:self];
            }
        }
    }];
}

- (bool)_tryToScrollToMessageId:(int32_t)messageId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated
{
    if ([TGDatabaseInstance() loadMessageWithMid:messageId peerId:_conversationId] != 0)
    {
        [TGDatabaseInstance() loadMessagesFromConversation:_conversationId maxMid:INT_MAX maxDate:INT_MAX maxLocalMid:INT_MAX atMessageId:messageId limit:20 extraUnread:false completion:^(NSArray *messages, bool historyExistsBelow)
        {
            NSMutableArray *sortedTopMessages = [[NSMutableArray alloc] initWithArray:messages];
            [sortedTopMessages sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
            {
                NSTimeInterval date1 = message1.date;
                NSTimeInterval date2 = message2.date;
                
                if (ABS(date1 - date2) < DBL_EPSILON)
                {
                    if (message1.mid > message2.mid)
                        return NSOrderedAscending;
                    else
                        return NSOrderedDescending;
                }
                
                return date1 > date2 ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                _moreMessagesAvailableBelow = historyExistsBelow;
                [self _replaceMessagesWithFastScroll:sortedTopMessages intent:TGModernConversationAddMessageIntentGeneric scrollToMessageId:messageId scrollBackMessageId:scrollBackMessageId animated:animated];
                
                TGDispatchOnMainThread(^
                {
                    TGModernConversationController *controller = self.controller;
                    [controller setEnableBelowHistoryRequests:true];
                });
            }];
        }];
        
        return true;
    }
    
    return false;
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/conversation", [self _conversationIdPathComponent]]]) {
        [TGModernConversationCompanion dispatchOnMessageQueue:^{
            TGConversation *updatedConversation = ((SGraphObjectNode *)resource).object;
            
            __block TGConversation *conversationForUnreadCalculations = nil;
            
            [_conversationAtomic modify:^id(TGConversation *conversation) {
                if (conversation.maxOutgoingReadMessageId < updatedConversation.maxOutgoingReadMessageId
                    || conversation.maxOutgoingReadDate < updatedConversation.maxOutgoingReadDate
                    || conversation.maxReadMessageId < updatedConversation.maxReadMessageId
                    || conversation.maxReadDate < updatedConversation.maxReadDate) {
                    conversation.maxOutgoingReadMessageId = updatedConversation.maxOutgoingReadMessageId;
                    conversation.maxOutgoingReadDate = updatedConversation.maxOutgoingReadDate;
                    conversation.maxReadMessageId = MAX(updatedConversation.maxReadMessageId, conversation.maxReadMessageId);
                    conversation.maxReadDate = MAX(updatedConversation.maxReadDate, conversation.maxReadDate);
                    
                    conversationForUnreadCalculations = [conversation copy];
                }
                
                return conversation;
            }];
            
            if (conversationForUnreadCalculations != nil) {
                TGDispatchOnMainThread(^{
                    self.viewContext.conversationForUnreadCalculations = conversationForUnreadCalculations;
                    TGModernConversationController *controller = self.controller;
                    [controller updateAllMessageAttributes];
                });
            }
        }];
    } else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]]])
    {
        [TGModernConversationCompanion dispatchOnMessageQueue:^{
            NSArray *messages = ((SGraphObjectNode *)resource).object;
            __block bool hadIncomingUnread = false;
            __block NSInteger incomingUnreadCount = 0;
            bool treatIncomingAsUnread = [arguments[@"treatIncomingAsUnread"] boolValue];
            NSMutableSet<NSNumber *> *incomingUnreadMessageIds = [[NSMutableSet alloc] init];
            
            [_conversationAtomic with:^id(TGConversation *conversation) {
                for (TGMessage *message in messages) {
                    if (!message.outgoing && ((treatIncomingAsUnread && message.mid < TGMessageLocalMidBaseline) || [conversation isMessageUnread:message])) {
                        hadIncomingUnread = true;
                        incomingUnreadCount++;
                        [incomingUnreadMessageIds addObject:@(message.mid)];
                    }
                    
                    if (treatIncomingAsUnread && message.group != nil) {
                        hadIncomingUnread = true;
                    }
                }
                
                return nil;
            }];
            
            if (![self canAddNewMessagesToTop])
            {
                 if (hadIncomingUnread)
                 {
                     TGDispatchOnMainThread(^
                     {
                         TGModernConversationController *controller = self.controller;
                         [controller setHasUnseenMessagesBelow:true];
                         [controller incrementScrollDownUnreadCount:incomingUnreadCount];
                     });
                }
            }
            else
            {
                TGModernConversationAddMessageIntent intent = TGModernConversationAddMessageIntentGeneric;
                bool animated = true;
                if (arguments[@"animated"] != nil && ![arguments[@"animated"] boolValue]) {
                    intent = TGModernConversationAddMessageIntentLoadMoreMessagesAbove;
                    animated = false;
                }
                
                NSMutableSet *filteredIncomingUnreadMessageIds = [[NSMutableSet alloc] initWithSet:incomingUnreadMessageIds];
                for (TGMessageModernConversationItem *item in _items) {
                    [filteredIncomingUnreadMessageIds removeObject:@(item->_message.mid)];
                }
                NSInteger filteredIncomingUnreadCount = filteredIncomingUnreadMessageIds.count;
                
                [self _addMessages:messages animated:animated intent:intent];
                [self _addedMessages:messages];
                TGDispatchOnMainThread(^{
                    TGModernConversationController *controller = self.controller;
                    if (hadIncomingUnread) {
                        [controller incrementScrollDownUnreadCount:filteredIncomingUnreadCount];
                    }
                });
            }
            
            [self scheduleReadHistory];
        }];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesDeleted", [self _conversationIdPathComponent]]])
    {
        NSArray *messageIds = ((SGraphObjectNode *)resource).object;
        bool animated = true;
        if (arguments[@"animated"] != nil && ![arguments[@"animated"] boolValue]) {
            animated = false;
        }
        [self _deleteMessages:messageIds animated:animated];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesChanged", [self _conversationIdPathComponent]]])
    {
        NSArray *midMessagePairs = ((SGraphObjectNode *)resource).object;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSUInteger i = 0; i < midMessagePairs.count; i += 2) {
            dict[midMessagePairs[i]] = midMessagePairs[i + 1];
        }
        
        [self _updateMessages:dict];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messageViews", [self _conversationIdPathComponent]]]) {
        [self updateMessageViews:resource markAsSeen:false];
    }
    else if ([path isEqualToString:@"downloadManagerStateChanged"])
    {
        bool animated = ![arguments[@"requested"] boolValue];
        
        NSDictionary *mediaList = resource;
        
        NSMutableDictionary *messageDownloadProgress = [[NSMutableDictionary alloc] init];
        
        if (mediaList == nil || mediaList.count == 0)
        {
            [messageDownloadProgress removeAllObjects];
        }
        else
        {
            [mediaList enumerateKeysAndObjectsUsingBlock:^(__unused NSString *path, TGDownloadItem *item, __unused BOOL *stop)
             {
                 if (item.itemId != nil)
                     [messageDownloadProgress setObject:[[NSNumber alloc] initWithFloat:item.progress] forKey:item.itemId];
             }];
        }
        
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            NSMutableArray *changedProgresses = [[NSMutableArray alloc] init];
            NSMutableArray *atIndices = [[NSMutableArray alloc] init];
            
            int index = -1;
            for (TGMessageModernConversationItem *messageItem in _items)
            {
                index++;
             
                if (messageItem->_message.mid < TGMessageLocalMidBaseline || messageItem->_message.deliveryState != TGMessageDeliveryStatePending)
                {
                    id mediaId = mediaIdForMessage(messageItem->_message);
                    if (mediaId != nil)
                    {
                        NSNumber *nProgress = messageDownloadProgress[mediaId];
                        if (nProgress != nil)
                        {
                            [changedProgresses addObject:nProgress];
                            [atIndices addObject:[[NSNumber alloc] initWithInt:index]];
                        }
                    }
                }
            }
            
            if (changedProgresses.count != 0)
            {
                TGDispatchOnMainThread(^
                {
                    TGModernConversationController *controller = self.controller;
                    int index = -1;
                    for (NSNumber *nProgress in changedProgresses)
                    {
                        index++;
                        [controller updateItemProgressAtIndex:[atIndices[index] intValue] toProgress:[nProgress floatValue] animated:animated];
                    }
                });
            }
            
            if (arguments != nil)
            {
                NSMutableDictionary *completedItemStatuses = [[NSMutableDictionary alloc] init];
                
                for (id mediaId in [arguments objectForKey:@"completedItemIds"])
                {
                    [completedItemStatuses setObject:@(true) forKey:mediaId];
                }
                
                for (id mediaId in [arguments objectForKey:@"failedItemIds"])
                {
                    [completedItemStatuses setObject:@(false) forKey:mediaId];
                }
                
                NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
                NSMutableArray *updatedItemIndices = [[NSMutableArray alloc] init];
                NSMutableArray *resetProgressIndices = [[NSMutableArray alloc] init];
                
                int itemCount = (int)_items.count;
                for (int index = 0; index < itemCount; index++)
                {
                    TGMessageModernConversationItem *messageItem = _items[index];
                    
                    id mediaId = mediaIdForMessage(messageItem->_message);
                    if (mediaId != nil)
                    {
                        NSNumber *nStatus = completedItemStatuses[mediaId];
                        if (nStatus != nil)
                        {
                            if ([nStatus boolValue] != messageItem->_mediaAvailabilityStatus)
                            {
                                messageItem = [messageItem copy];
                                messageItem->_mediaAvailabilityStatus = [nStatus boolValue];
                                [(NSMutableArray *)_items replaceObjectAtIndex:index withObject:messageItem];
                                
                                [updatedItems addObject:messageItem];
                                [updatedItemIndices addObject:@(index)];
                            }
                            
                            if (messageItem->_message.mid < TGMessageLocalMidBaseline || messageItem->_message.deliveryState != TGMessageDeliveryStatePending)
                            {
                                [resetProgressIndices addObject:@(index)];
                            }
                        }
                    }
                }
                
                if (updatedItems.count != 0 || resetProgressIndices.count != 0)
                {
                    TGDispatchOnMainThread(^
                    {
                        TGModernConversationController *controller = self.controller;
                        int index = -1;
                        for (TGMessageModernConversationItem *updatedItem in updatedItems)
                        {
                            index++;
                            [controller updateItemAtIndex:[updatedItemIndices[index] unsignedIntegerValue] toItem:updatedItem delayAvailability:false];
                        }
                        
                        for (NSNumber *nIndex in resetProgressIndices)
                        {
                            [controller updateItemProgressAtIndex:[nIndex unsignedIntegerValue] toProgress:-1.0f animated:animated];
                        }
                    });
                }
            }
        }];
    }
    else if ([path isEqualToString:@"/as/media/imageThumbnailUpdated"])
    {
        NSString *imageUrl = resource;
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = self.controller;
            [controller imageDataInvalidated:imageUrl];
        });
    }
    else if ([path isEqualToString:@"/tg/contactlist"])
    {
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            
            int index = -1;
            for (TGMessageModernConversationItem *messageItem in _items)
            {
                index++;

                if (messageItem->_message.mediaAttachments != nil)
                {
                    for (TGMediaAttachment *attachment in messageItem->_message.mediaAttachments)
                    {
                        if (attachment.type == TGContactMediaAttachmentType)
                        {
                            [indexSet addIndex:index];
                            break;
                        }
                    }
                }
            }
            
            if (indexSet.count != 0)
                [self _updateMediaStatusDataForItemsInIndexSet:indexSet animated:false forceforceCheckDownload:false];
        }];
    }
    else if ([path isEqualToString:@"/tg/service/synchronizationstate"])
    {
        int state = [((SGraphObjectNode *)resource).object intValue];
        
        NSString *stateString = nil;
        if (state & 2)
        {
            if (state & 4)
                stateString = TGLocalized(@"State.WaitingForNetwork");
            else {
                if (state & 8) {
                    stateString = TGLocalized(@"State.ConnectingToProxy");
                } else {
                    stateString = TGLocalized(@"State.Connecting");
                }
            }
        }
        else if (state & 1)
            stateString = TGLocalized(@"State.Updating");
        
        [self _updateNetworkState:stateString];
    }
    else if ([path isEqualToString:@"/tg/unreadCount"])
    {
        if ([self _shouldDisplayProcessUnreadCount])
        {
            dispatch_async(dispatch_get_main_queue(), ^ // request to controller
            {
                [TGDatabaseInstance() dispatchOnDatabaseThread:^ // request to database
                {
                    int unreadCount = [TGDatabaseInstance() databaseState].unreadCount;
                    TGDispatchOnMainThread(^
                    {
                        TGModernConversationController *controller = self.controller;
                        [controller setGlobalUnreadCount:unreadCount];
                    });
                } synchronous:false];
            });
        }
    }
    else if ([path isEqualToString:@"/tg/assets/currentWallpaperInfo"])
    {
        TGDispatchOnMainThread(^
        {
            TGWallpaperInfo *wallpaper = [[TGWallpaperManager instance] currentWallpaperInfo];
            [[TGTelegraphConversationMessageAssetsSource instance] setMonochromeColor:wallpaper.tintColor];
            [[TGTelegraphConversationMessageAssetsSource instance] setSystemAlpha:wallpaper.systemAlpha];
            [[TGTelegraphConversationMessageAssetsSource instance] setButtonsAlpha:wallpaper.buttonsAlpha];
            [[TGTelegraphConversationMessageAssetsSource instance] setHighlighteButtonAlpha:wallpaper.highlightedButtonAlpha];
            [[TGTelegraphConversationMessageAssetsSource instance] setProgressAlpha:wallpaper.progressAlpha];
            
            TGModernConversationController *controller = self.controller;
            [controller reloadBackground];
        });
    }
    else if ([path isEqualToString:@"/tg/conversation/historyCleared"])
    {
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            if (_conversationId == [resource longLongValue])
            {
                [self systemClearedConversation];
            }
        }];
    }
    else if ([path isEqualToString:@"/tg/removedMediasForMessageIds"])
    {
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            [self _updateMediaStatusDataForItemsWithMessageIdsInSet:resource];
        }];
    }
    else if ([path isEqualToString:@"/tg/conversation/*/readmessageContents"])
    {
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            std::set<int32_t> messageIds;
            for (NSNumber *nMessageId in resource[@"messageIds"])
            {
                messageIds.insert((int32_t)[nMessageId intValue]);
            }
            
            NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
            NSMutableArray *updatedIndices = [[NSMutableArray alloc] init];
            
            NSUInteger count = _items.count;
            for (NSUInteger i = 0; i < count; i++)
            {
                TGMessageModernConversationItem *item = _items[i];
                if (messageIds.find(item->_message.mid) != messageIds.end())
                {
                    if (item->_message.contentProperties[@"contentsRead"] == nil)
                    {
                        item = [item deepCopy];
                        NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:item->_message.contentProperties];
                        contentProperties[@"contentsRead"] = [[TGMessageViewedContentProperty alloc] init];
                        item->_message.contentProperties = contentProperties;
                        [(NSMutableArray *)_items replaceObjectAtIndex:i withObject:item];
                        [updatedItems addObject:item];
                        [updatedIndices addObject:@(i)];
                    }
                }
            }
            
            if (updatedItems.count != 0)
            {
                TGDispatchOnMainThread(^
                {
                    TGModernConversationController *controller = self.controller;
                    int index = -1;
                    for (NSNumber *nIndex in updatedIndices)
                    {
                        index++;
                        [controller updateItemAtIndex:[nIndex intValue] toItem:updatedItems[index] delayAvailability:false];
                    }
                });
            }
        }];
    }
    else if ([path isEqualToString:[NSString stringWithFormat:@"/messagesEditedInConversation/(%lld)", _conversationId]]) {
        [TGModernConversationCompanion dispatchOnMessageQueue:^{
            NSMutableDictionary *messageIdToMessage = [[NSMutableDictionary alloc] init];
            for (TGMessage *message in resource) {
                messageIdToMessage[@(message.mid)] = message;
            }
            [self updateMessagesLive:messageIdToMessage animated:false];
        }];
    } else if ([path isEqualToString:[NSString stringWithFormat:@"/tg/peerDraft/%lld", _conversationId]]) {
        TGDispatchOnMainThread(^{
            TGModernConversationController *controller = self.controller;
            TGDatabaseMessageDraft *draft = resource;
            if ([draft isKindOfClass:[TGDatabaseMessageDraft class]]) {
                [controller setInputText:draft.text entities:draft.entities replace:false replaceIfPrefix:true selectRange:NSMakeRange(0, 0)];
            }
        });
    }
    
    [super actionStageResourceDispatched:path resource:resource arguments:arguments];
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:[self _sendMessagePathPrefix]])
    {
        if ([messageType isEqualToString:@"messageAlmostDelivered"])
        {
            [self unlockSendMessageSemaphore];
            
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                [self _updateMessageDelivered:[message[@"previousMid"] intValue]];
            }];
        }
        else if ([messageType isEqualToString:@"messageDeliveryFailed"])
        {
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                int32_t mid = [message[@"previousMid"] intValue];
                
                [self _updateMessageDeliveryFailed:mid];
                
                _messageUploadProgress.erase(mid);
                [self _updateItemProgress:mid animated:false];
            }];
        }
        else if ([messageType isEqualToString:@"messageProgress"])
        {
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                int32_t mid = (int32_t)[message[@"mid"] intValue];
                float progress = [message[@"progress"] floatValue];
                
                _messageUploadProgress[mid] = progress;
                [self _updateItemProgress:mid animated:true];
            }];
        }
    }
}

- (void)_updateItemProgress:(int32_t)mid animated:(bool)animated
{
#ifdef DEBUG
    NSAssert([TGModernConversationCompanion isMessageQueue], @"Should be called on message queue");
#endif
    
    int index = -1;
    for (TGMessageModernConversationItem *item in _items)
    {
        index++;
        
        if (item->_message.mid == mid)
        {
            float progress = -1.0f;
            auto it = _messageUploadProgress.find(mid);
            if (it != _messageUploadProgress.end())
                progress = it->second;
            
            TGDispatchOnMainThread(^
            {
                TGModernConversationController *controller = self.controller;
                [controller updateItemProgressAtIndex:index toProgress:progress animated:animated];
            });
            
            break;
        }
    }
}

- (void)_updateProgressForItemsInIndexSet:(NSIndexSet *)indexSet animated:(bool)animated
{
    if (_messageUploadProgress.empty() || indexSet.count == 0)
        return;
    
    NSMutableArray *updatedProgresses = [[NSMutableArray alloc] init];
    NSMutableArray *updatedIndices = [[NSMutableArray alloc] init];
    
    int indexCount = (int)indexSet.count;
    NSUInteger indices[indexCount];
    [indexSet getIndexes:indices maxCount:indexSet.count inIndexRange:nil];
    
    for (int i = 0; i < indexCount; i++)
    {
        TGMessageModernConversationItem *item = _items[indices[i]];
        
        auto it = _messageUploadProgress.find(item->_message.mid);
        if (it != _messageUploadProgress.end())
        {
            [updatedProgresses addObject:@(it->second)];
            [updatedIndices addObject:@(indices[i])];
        }
    }
    
    if (updatedProgresses.count != 0)
    {
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = self.controller;
            
            int index = -1;
            for (NSNumber *nProgress in updatedProgresses)
            {
                index++;
                [controller updateItemProgressAtIndex:[updatedIndices[index] unsignedIntegerValue] toProgress:[nProgress floatValue] animated:animated];
            }
        });
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/conversations/(%@)/history/", [self _conversationIdPathComponent]]])
    {
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            if (status == ASStatusSuccess)
            {
                NSArray *messages = result[@"messages"];
                
                enum {
                    TGHistoryRequestAbove = 0,
                    TGHistoryRequestBelow = 1
                } historyRequestType = TGHistoryRequestAbove;
                bool moreAvailable = false;
                
                if ([path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/conversations/(%@)/history/(up", [self _conversationIdPathComponent]]])
                {
                    historyRequestType = TGHistoryRequestAbove;
                    _loadingMoreMessagesAbove = false;
                    _moreMessagesAvailableAbove = messages.count != 0;
                    moreAvailable = _moreMessagesAvailableAbove;
                }
                else if ([path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/conversations/(%@)/history/(down", [self _conversationIdPathComponent]]])
                {
                    historyRequestType = TGHistoryRequestBelow;
                    _loadingMoreMessagesBelow = false;
                    _moreMessagesAvailableBelow = messages.count != 0;
                    moreAvailable = _moreMessagesAvailableBelow;
                }

                [self _addMessages:messages animated:false intent:historyRequestType == TGHistoryRequestBelow ? TGModernConversationAddMessageIntentLoadMoreMessagesBelow : TGModernConversationAddMessageIntentLoadMoreMessagesAbove];
                
                TGDispatchOnMainThread(^
                {
                    TGModernConversationController *controller = self.controller;
                    
                    if (historyRequestType == TGHistoryRequestAbove)
                        [controller setEnableAboveHistoryRequests:moreAvailable];
                    else if (historyRequestType == TGHistoryRequestBelow)
                        [controller setEnableBelowHistoryRequests:moreAvailable];
                });
            }
        }];
    }
    else if ([path hasPrefix:[self _sendMessagePathPrefix]])
    {
        [self unlockSendMessageSemaphore];
        
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            if (status == ASStatusSuccess)
            {
                int32_t previousMid = (int32_t)[result[@"previousMid"] intValue];
                _messageUploadProgress.erase(previousMid);
                
                [self _updateMessageDelivered:previousMid mid:[result[@"mid"] intValue] date:[result[@"date"] intValue] message:result[@"message"] pts:[result[@"pts"] intValue]];
                
                [self _updateItemProgress:[result[@"mid"] intValue] animated:true];
            }
        }];
    }
    else if ([path hasPrefix:@"/tg/loadConversationAndMessageForSearch/"])
    {
        TGDispatchOnMainThread(^
        {
            [_progressWindow dismiss:true];
            
            int32_t messageId = _loadingMessageForSearch;
            int32_t scrollBackMessageId = _sourceMessageForSearch;
            _loadingMessageForSearch = 0;
            _sourceMessageForSearch = 0;
            
            [self _tryToScrollToMessageId:messageId scrollBackMessageId:scrollBackMessageId animated:_animatedTransitionInSearch];
        });
    }
    
    [super actorCompleted:status path:path result:result];
}

#pragma mark -

static id mediaIdForMessage(TGMessage *message)
{
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if (attachment.type == TGVideoMediaAttachmentType)
        {
            if (((TGVideoMediaAttachment *)attachment).videoId == 0)
                return nil;
            
            return [[TGMediaId alloc] initWithType:1 itemId:((TGVideoMediaAttachment *)attachment).videoId];
        }
        else if (attachment.type == TGImageMediaAttachmentType)
        {
            if (((TGImageMediaAttachment *)attachment).imageId == 0)
                return nil;
            
            return [[TGMediaId alloc] initWithType:2 itemId:((TGImageMediaAttachment *)attachment).imageId];
        }
        else if (attachment.type == TGDocumentMediaAttachmentType)
        {
            if (((TGDocumentMediaAttachment *)attachment).documentId != 0)
                return [[TGMediaId alloc] initWithType:3 itemId:((TGDocumentMediaAttachment *)attachment).documentId];
            else if (((TGDocumentMediaAttachment *)attachment).localDocumentId != 0 && ((TGDocumentMediaAttachment *)attachment).documentUri.length != 0)
                return [[TGMediaId alloc] initWithType:3 itemId:((TGDocumentMediaAttachment *)attachment).localDocumentId];
            
            return nil;
        }
        else if (attachment.type == TGAudioMediaAttachmentType)
        {
            if (((TGAudioMediaAttachment *)attachment).audioId != 0)
                return [[TGMediaId alloc] initWithType:4 itemId:((TGAudioMediaAttachment *)attachment).audioId];
            else if (((TGAudioMediaAttachment *)attachment).localAudioId != 0)
                return [[TGMediaId alloc] initWithType:4 itemId:((TGAudioMediaAttachment *)attachment).localAudioId];
            
            return nil;
        }
        else if (attachment.type == TGWebPageMediaAttachmentType) {
            TGDocumentMediaAttachment *documentAttachment = ((TGWebPageMediaAttachment *)attachment).document;
            TGImageMediaAttachment *imageAttachment = ((TGWebPageMediaAttachment *)attachment).photo;
            
            if (documentAttachment != nil) {
                if (documentAttachment.documentId != 0) {
                    return [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.documentId];
                } else if (documentAttachment.localDocumentId != 0 && documentAttachment.documentUri.length != 0) {
                    return [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.localDocumentId];
                }
            } else if (imageAttachment != nil) {
                if (imageAttachment.imageId == 0)
                    return nil;
                
                return [[TGMediaId alloc] initWithType:2 itemId:imageAttachment.imageId];
            }
        }
        else if (attachment.type == TGGameAttachmentType) {
            TGDocumentMediaAttachment *documentAttachment = ((TGGameMediaAttachment *)attachment).document;
            TGImageMediaAttachment *imageAttachment = ((TGGameMediaAttachment *)attachment).photo;
            
            if (documentAttachment != nil) {
                if (documentAttachment.documentId != 0) {
                    return [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.documentId];
                } else if (documentAttachment.localDocumentId != 0 && documentAttachment.documentUri.length != 0) {
                    return [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.localDocumentId];
                }
            } else if (imageAttachment != nil) {
                if (imageAttachment.imageId == 0)
                    return nil;
                
                return [[TGMediaId alloc] initWithType:2 itemId:imageAttachment.imageId];
            }
        } else if (attachment.type == TGInvoiceMediaAttachmentType) {
            TGImageMediaAttachment *imageAttachment = [((TGInvoiceMediaAttachment *)attachment) webpage].photo;
            
            if (imageAttachment != nil) {
                if (imageAttachment.imageId == 0)
                    return nil;
                
                return [[TGMediaId alloc] initWithType:5 itemId:imageAttachment.localImageId];
            }
        }
    }
    
    return nil;
}

- (void)_downloadMediaInMessage:(TGMessage *)message highPriority:(bool)highPriority
{
    int64_t conversationId = _conversationId;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            if (attachment.type == TGVideoMediaAttachmentType)
            {
                TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                id mediaId = [[TGMediaId alloc] initWithType:1 itemId:videoAttachment.videoId];
                
                NSString *url = [videoAttachment.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL];
                
                if (url != nil)
                {
                    [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/as/media/video/(%@)", url] options:[[NSDictionary alloc] initWithObjectsAndKeys:videoAttachment, @"videoAttachment", nil] changePriority:highPriority messageId:message.mid itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassVideo];
                }
                
                break;
            }
            else if (attachment.type == TGImageMediaAttachmentType)
            {
                TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                id mediaId = [[TGMediaId alloc] initWithType:2 itemId:imageAttachment.imageId];
                
                NSString *url = [[imageAttachment imageInfo] closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
                
                if (url != nil)
                {
                    int contentHints = TGRemoteImageContentHintLargeFile;
                    if ([self imageDownloadsShouldAutosavePhotos] && !message.outgoing)
                        contentHints |= TGRemoteImageContentHintSaveToGallery;
                    
                    NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0], @"cancelTimeout", [TGRemoteImageView sharedCache], @"cache", [NSNumber numberWithBool:false], @"useCache", [NSNumber numberWithBool:false], @"allowThumbnailCache", [[NSNumber alloc] initWithInt:contentHints], @"contentHints", nil];
                    [options setObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                                        [[NSNumber alloc] initWithInt:message.mid], @"messageId",
                                        [[NSNumber alloc] initWithLongLong:message.cid], @"conversationId",
                                        [[NSNumber alloc] initWithBool:false], @"forceSave",
                                        mediaId, @"mediaId", imageAttachment.imageInfo, @"imageInfo",
                                        [[NSNumber alloc] initWithBool:!message.outgoing && [self imageDownloadsShouldAutosavePhotos]], @"storeAsAsset",
                                        nil] forKey:@"userProperties"];
                    
                    [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/img/(download:{filter:%@}%@)", @"maybeScale", url] options:options changePriority:highPriority messageId:message.mid itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassImage];
                }
                
                break;
            }
            else if (attachment.type == TGDocumentMediaAttachmentType)
            {
                TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                if (documentAttachment.documentId != 0 || documentAttachment.documentUri.length != 0)
                {
                    NSString *downloadUri = documentAttachment.documentUri;
                    
                    if ([documentAttachment.documentUri hasPrefix:@"http"]) {
                        return;
                    }
                    
                    id mediaId = [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.documentId != 0 ? documentAttachment.documentId : documentAttachment.localDocumentId];
                    [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", documentAttachment.datacenterId, documentAttachment.documentId, downloadUri.length != 0 ? downloadUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:documentAttachment, @"documentAttachment", nil] changePriority:highPriority messageId:message.mid itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassDocument];
                }
            }
            else if (attachment.type == TGWebPageMediaAttachmentType || attachment.type == TGGameAttachmentType) {
                TGDocumentMediaAttachment *documentAttachment = ((TGWebPageMediaAttachment *)attachment).document;
                TGImageMediaAttachment *imageAttachment = ((TGWebPageMediaAttachment *)attachment).photo;
                
                if (documentAttachment != nil) {
                    if (documentAttachment.documentId != 0 || documentAttachment.documentUri.length != 0)
                    {
                        NSString *downloadUri = documentAttachment.documentUri;
                        
                        id mediaId = [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.documentId != 0 ? documentAttachment.documentId : documentAttachment.localDocumentId];
                        [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", documentAttachment.datacenterId, documentAttachment.documentId, downloadUri.length != 0 ? downloadUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:documentAttachment, @"documentAttachment", nil] changePriority:highPriority messageId:message.mid itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassDocument];
                    }
                } else if (imageAttachment != nil) {
                    id mediaId = [[TGMediaId alloc] initWithType:2 itemId:imageAttachment.imageId];
                    
                    NSString *url = [[imageAttachment imageInfo] closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
                    
                    if (url != nil)
                    {
                        int contentHints = TGRemoteImageContentHintLargeFile;
                        if ([self imageDownloadsShouldAutosavePhotos] && !message.outgoing)
                            contentHints |= TGRemoteImageContentHintSaveToGallery;
                        
                        NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0], @"cancelTimeout", [TGRemoteImageView sharedCache], @"cache", [NSNumber numberWithBool:false], @"useCache", [NSNumber numberWithBool:false], @"allowThumbnailCache", [[NSNumber alloc] initWithInt:contentHints], @"contentHints", nil];
                        [options setObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                                            [[NSNumber alloc] initWithInt:message.mid], @"messageId",
                                            [[NSNumber alloc] initWithLongLong:message.cid], @"conversationId",
                                            [[NSNumber alloc] initWithBool:false], @"forceSave",
                                            mediaId, @"mediaId", imageAttachment.imageInfo, @"imageInfo",
                                            [[NSNumber alloc] initWithBool:false], @"storeAsAsset",
                                            nil] forKey:@"userProperties"];
                        
                        [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/img/(download:{filter:%@}%@)", @"maybeScale", url] options:options changePriority:highPriority messageId:message.mid itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassImage];
                    }
                }
            }
            else if (attachment.type == TGInvoiceMediaAttachmentType) {
                TGImageMediaAttachment *imageAttachment = [((TGInvoiceMediaAttachment *)attachment) webpage].photo;
                
                if (imageAttachment != nil) {
                    id mediaId = [[TGMediaId alloc] initWithType:5 itemId:imageAttachment.localImageId];
                    
                    NSString *url = [[imageAttachment imageInfo] closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
                    
                    if (url != nil)
                    {
                        int contentHints = TGRemoteImageContentHintLargeFile;
                        //if ([self imageDownloadsShouldAutosavePhotos] && !message.outgoing)
                        //    contentHints |= TGRemoteImageContentHintSaveToGallery;
                        
                        NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0], @"cancelTimeout", [TGRemoteImageView sharedCache], @"cache", [NSNumber numberWithBool:false], @"useCache", [NSNumber numberWithBool:false], @"allowThumbnailCache", [[NSNumber alloc] initWithInt:contentHints], @"contentHints", nil];
                        [options setObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                                            [[NSNumber alloc] initWithInt:message.mid], @"messageId",
                                            [[NSNumber alloc] initWithLongLong:message.cid], @"conversationId",
                                            [[NSNumber alloc] initWithBool:false], @"forceSave",
                                            mediaId, @"mediaId", imageAttachment.imageInfo, @"imageInfo",
                                            [[NSNumber alloc] initWithBool:false], @"storeAsAsset",
                                            nil] forKey:@"userProperties"];
                        
                        [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/img/(download:{filter:%@}%@)", @"maybeScale", url] options:options changePriority:highPriority messageId:message.mid itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassImage];
                    }
                }
            }
            else if (attachment.type == TGAudioMediaAttachmentType)
            {
                TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                if (audioAttachment.audioId != 0 || audioAttachment.audioUri.length != 0)
                {
                    id mediaId = [[TGMediaId alloc] initWithType:4 itemId:audioAttachment.audioId != 0 ? audioAttachment.audioId : audioAttachment.localAudioId];
                    [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/audio/(%" PRId32 ":%" PRId64 ":%@)", audioAttachment.datacenterId, audioAttachment.audioId, audioAttachment.audioUri.length != 0 ? audioAttachment.audioUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:audioAttachment, @"audioAttachment", nil] changePriority:highPriority messageId:message.mid itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassAudio];
                }
            }
        }
    }];
}

- (void)updateMediaAccessTimeForMessageId:(int32_t)messageId
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        for (NSUInteger index = 0; index < _items.count; index++)
        {
            TGMessageModernConversationItem *item = _items[index];
            
            if (item->_message.mid == messageId)
            {
                TGMediaId *mediaId = mediaIdForMessage(item->_message);
                if (mediaId != 0)
                {
                    [TGDatabaseInstance() updateLastUseDateForMediaType:mediaId.type mediaId:mediaId.itemId messageId:messageId];
                }
                
                bool maybeReadContents = false;
                for (id attachment in item->_message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
                    {
                        maybeReadContents = true;
                        break;
                    } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                    {
                        if (((TGVideoMediaAttachment *)attachment).roundMessage)
                        {
                            maybeReadContents = true;
                        }
                        break;
                    }
                    else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                        for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes) {
                            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                                if (((TGDocumentAttributeAudio *)attribute).isVoice) {
                                    maybeReadContents = true;
                                }
                                break;
                            }
                        }
                        break;
                    }
                }
                
                if (maybeReadContents && [self allowMessageForwarding] && !TGPeerIdIsChannel(_conversationId))
                {
                    if (!item->_message.outgoing)
                    {
                        bool found = item->_message.contentProperties[@"contentsRead"] != nil;
                        
                        if (!found)
                        {
                            NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:item->_message.contentProperties];
                            contentProperties[@"contentsRead"] = [[TGMessageViewedContentProperty alloc] init];
                            TGMessageModernConversationItem *updatedItem = [item deepCopy];
                            updatedItem->_message.contentProperties = contentProperties;
                            ((NSMutableArray *)_items)[index] = updatedItem;
                            
                            TGDatabaseAction action = { .type = TGDatabaseActionReadMessageContents, .subject = item->_message.mid, .arg0 = 0, .arg1 = 0};
                            [TGDatabaseInstance() storeQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]]];
                            [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(global)" options:nil watcher:TGTelegraphInstance];
                            
                            [TGDatabaseInstance() transactionUpdateMessages:@[[[TGDatabaseUpdateContentsRead alloc] initWithPeerId:item->_message.cid messageId:item->_message.mid]] updateConversationDatas:nil];
                            
                            TGDispatchOnMainThread(^
                            {
                                TGModernConversationController *controller = self.controller;
                                [controller updateItemAtIndex:index toItem:updatedItem delayAvailability:false];
                            });
                        }
                    }
                }
                
                break;
            }
        }
    }];
}

- (id)acquireAudioRecordingActivityHolder
{
    return [[TGTelegraphInstance activityManagerForConversationId:_conversationId accessHash:[self requestAccessHash]] addActivityWithType:@"recordingAudio" priority:0];
}

- (id)acquireVideoMessageRecordingActivityHolder
{
    return [[TGTelegraphInstance activityManagerForConversationId:_conversationId accessHash:[self requestAccessHash]] addActivityWithType:@"recordingVideoMessage" priority:0];
}

- (id)acquireLocationPickingActivityHolder
{
    if (TGPeerIdIsChannel(_conversationId)) {
        return nil;
    }
    return [[TGTelegraphInstance activityManagerForConversationId:_conversationId accessHash:[self requestAccessHash]] addActivityWithType:@"pickingLocation" priority:0];
}

- (SSignal *)hashtagListForHashtag:(NSString *)hashtag
{
    //TGModernConversationController *controller = self.controller;
    
    NSMutableArray *hashtagsFromCurrentMessages = [[NSMutableArray alloc] init];
    /*for (TGMessageModernConversationItem *item in [controller _items])
    {
        for (id result in [item->_message textCheckingResults])
        {
            if ([result isKindOfClass:[TGTextCheckingResult class]] && ((TGTextCheckingResult *)result).type == TGTextCheckingResultTypeHashtag)
            {
                if (![hashtagsFromCurrentMessages containsObject:((TGTextCheckingResult *)result).contents])
                    [hashtagsFromCurrentMessages addObject:((TGTextCheckingResult *)result).contents];
            }
        }
    }*/
    
    return [[TGRecentHashtagsSignal recentHashtagsFromSpaces:TGHashtagSpaceEntered | TGHashtagSpaceSearchedBy] map:^id (NSArray *recentHashtags)
    {
        [hashtagsFromCurrentMessages removeObjectsInArray:recentHashtags];
        NSArray *combinedHashtags = [recentHashtags arrayByAddingObjectsFromArray:hashtagsFromCurrentMessages];
        
        if (hashtag.length == 0)
            return combinedHashtags;
        
        NSMutableArray *filteredHashtags = [[NSMutableArray alloc] init];
        for (NSString *listHashtag in combinedHashtags)
        {
            if ([listHashtag hasPrefix:hashtag])
                [filteredHashtags addObject:listHashtag];
        }
        
        return filteredHashtags;
    }];
}

- (void)navigateToMessageSearch
{
    TGModernConversationController *controller = self.controller;
    [controller activateSearch];
    
    /*__weak TGGenericModernConversationCompanion *weakSelf = self;
    TGChatSearchController *searchController = [[TGChatSearchController alloc] initWithPeerId:_conversationId messageSelected:^(int32_t messageId, NSString *query, NSArray *messageIds)
    {
        __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf navigateToMessageId:messageId scrollBackMessageId:0 animated:false];
            TGModernConversationController *controller = strongSelf.controller;
            [controller dismissViewControllerAnimated:true completion:nil];
        }
    }];
    TGModernConversationController *controller = self.controller;
    [controller hideTitlePanel];
    [controller presentViewController:searchController animated:true completion:nil];*/
    
}

- (void)_replaceMessages:(NSArray *)newMessages atMessageId:(int32_t)atMessageId expandFrom:(int32_t)expandMessageId jump:(bool)jump top:(bool)top messageIdForVisibleHoleDirection:(int32_t)messageIdForVisibleHoleDirection scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated {
    [super _replaceMessages:newMessages atMessageId:atMessageId expandFrom:expandMessageId jump:jump top:top messageIdForVisibleHoleDirection:messageIdForVisibleHoleDirection scrollBackMessageId:scrollBackMessageId animated:animated];
    
    [[TGDownloadManager instance] requestState:self.actionHandle];
}

- (int64_t)requestPeerId {
    return _conversationId;
}

- (int64_t)requestAccessHash {
    return 0;
}

- (void)scheduleReadHistory {
    if (!self.previewMode) {
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = self.controller;
            if ([controller canReadHistory])
            {
                [TGModernConversationCompanion dispatchOnMessageQueue:^
                {
                    [self _markIncomingMessagesAsReadSilent];
                }];
                
                [TGDatabaseInstance() dispatchOnDatabaseThread:^
                {
                    [TGDatabaseInstance() transactionReadHistoryForPeerIds:[[NSSet alloc] initWithArray:@[@(_conversationId)]]];
                } synchronous:false];
            }
            else
            {
                [TGModernConversationCompanion dispatchOnMessageQueue:^
                {
                    _needsToReadHistory = true;
                }];
            }
        });
    }
}
            
- (bool)shouldFastScrollDown {
    return false;
}

- (SSignal *)inlineResultForMentionText:(NSString *)mention text:(NSString *)text {
    __weak TGGenericModernConversationCompanion *weakSelf = self;
    int64_t peerId = [self requestPeerId];
    int64_t accessHash = [self requestAccessHash];
    return [[TGPeerInfoSignals resolveBotDomain:mention] mapToSignal:^SSignal *(id peer) {
        if ([peer isKindOfClass:[TGUser class]]) {
            return [[[SSignal single:@true] then:[TGBotSignals botContextResultForUserId:((TGUser *)peer).uid peerId:peerId accessHash:accessHash query:text geoPoint:nil offset:@""]] onNext:^(id next) {
                if (next != nil) {
                    __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf != nil && ![strongSelf allowMessageForwarding]) {
                        [weakSelf maybeAskForInlineBots];
                    }
                }
            }];
        } else {
            return [SSignal fail:nil];
        }
    }];
}

- (SSignal *)contextBotInfoForText:(NSString *)text {
    if ([text hasPrefix:@"@"]) {
        NSRange spaceRange = [text rangeOfString:@" "];
        if (spaceRange.location != NSNotFound) {
            NSString *query = [[text substringToIndex:spaceRange.location] substringFromIndex:1];
            if (query.length >= 2) {
                return [[TGPeerInfoSignals resolveBotDomain:query] map:^id(TGUser *user) {
                    if (user.contextBotPlaceholder.length != 0) {
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                        dict[@"placeholder"] = (spaceRange.location == text.length - 1) ? user.contextBotPlaceholder : @"";
                        dict[@"contextBotMode"] = @true;
                        if (user != nil) {
                            dict[@"user"] = user;
                        }
                        return dict;
                    } else {
                        return @{};
                    }
                }];
            }
        } else if ([text hasSuffix:@"bot"]) {
            bool matches = true;
            for (int i = 1; i < (int)text.length; i++) {
                unichar c = [text characterAtIndex:i];
                if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_')) {
                    matches = false;
                    break;
                }
            }
            
            if (matches) {
                NSString *query = [text substringFromIndex:1];
                if (query.length >= 2) {
                    return [[TGPeerInfoSignals resolveBotDomain:query] map:^id(TGUser *user) {
                        if (user.contextBotPlaceholder.length != 0) {
                            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                            dict[@"placeholder"] = [@" " stringByAppendingString:user.contextBotPlaceholder];
                            dict[@"contextBotMode"] = @true;
                            if (user != nil) {
                                dict[@"user"] = user;
                            }
                            return dict;
                        } else {
                            return @{};
                        }
                    }];
                }
            }
        }
    }
    
    return [SSignal single:@{}];
}

- (id)playlistMetadata:(bool)voice {
    return @{@"peerId": @(_conversationId), @"voice": @(voice)};
}

- (bool)canAddNewMessagesToTop {
    return !_moreMessagesAvailableBelow;
}

- (void)updateMessagesLive:(NSDictionary *)messageIdToMessage animated:(bool)animated {
    NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
    NSMutableArray *atIndices = [[NSMutableArray alloc] init];
    
    NSMutableSet *forceAnimated = nil;
    
    NSInteger itemIndex = -1;
    for (TGMessageModernConversationItem *item in _items)
    {
        itemIndex++;
        
        TGMessage *message = messageIdToMessage[@(item->_message.mid)];
        if (message != nil) {
            TGMessageModernConversationItem *updatedItem = [item copy];
            updatedItem->_message = [updatedItem->_message copy];
            updatedItem->_message.mediaAttachments = message.mediaAttachments;
            updatedItem->_message.text = message.text;
            updatedItem->_message.flags = message.flags;
            
            bool animateExpiration = [item->_message hasExpiredMedia] != [updatedItem->_message hasExpiredMedia];
            if (animateExpiration) {
                if (forceAnimated == nil) {
                    forceAnimated = [[NSMutableSet alloc] init];
                }
                [forceAnimated addObject:@(message.mid)];
            }
            
            [updatedItems addObject:updatedItem];
            [atIndices addObject:@(itemIndex)];
        }
    }
    
    if (updatedItems.count != 0)
    {
        for (NSUInteger i = 0; i < updatedItems.count; i++)
        {
            [((NSMutableArray *)_items) replaceObjectAtIndex:[atIndices[i] unsignedIntegerValue] withObject:updatedItems[i]];
        }
        
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (NSNumber *nIndex in atIndices) {
            [indexSet addIndex:[nIndex intValue]];
        }
        
        TGDispatchOnMainThread(^{
            TGModernConversationController *controller = self.controller;
            int index = -1;
            for (TGMessageModernConversationItem *messageItem in updatedItems)
            {
                index++;
                bool animateExpiration = [forceAnimated containsObject:@(messageItem->_message.mid)];
                [controller updateItemAtIndex:[atIndices[index] unsignedIntegerValue] toItem:messageItem delayAvailability:false animated:animated || animateExpiration animateTransition:animateExpiration];
            }
        });
        
        [self _updateMediaStatusDataForItemsInIndexSet:indexSet animated:false forceforceCheckDownload:true];
    }
    
    if (_callbackInProgressMessageId != 0 && messageIdToMessage[@(_callbackInProgressMessageId)] != nil) {
        _callbackInProgressMessageId = 0;
        [self.callbackInProgress set:[SSignal single:nil]];
    }
}

- (SSignal *)primaryTitlePanel {
    return [SSignal single:nil];
}

- (SSignal *)editingContextForMessageWithId:(int32_t)messageId {
    return [[TGGroupManagementSignals messageEditData:_conversationId accessHash:_accessHash messageId:messageId] catch:^SSignal *(__unused id error) {
        return [SSignal single:nil];
    }];
}

- (SSignal *)saveEditedMessageWithId:(int32_t)messageId text:(NSString *)text entities:(NSArray *)entities disableLinkPreviews:(bool)disableLinkPreviews {
    __weak TGGenericModernConversationCompanion *weakSelf = self;
    int64_t peerId = _conversationId;
    SSignal *notModified = [[TGDatabaseInstance() modify:^id{
        TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:peerId];
        NSString *messageText = message.text;
        for (id attachment in message.mediaAttachments) {
            if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
                messageText = ((TGImageMediaAttachment *)attachment).caption;
            } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]) {
                messageText = ((TGVideoMediaAttachment *)attachment).caption;
            } else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                messageText = ((TGDocumentMediaAttachment *)attachment).caption;
            }
        }
        
        if (TGStringCompare(text, messageText) && !disableLinkPreviews) {
            return [SSignal complete];
        } else {
            return [SSignal fail:nil];
        }
    }] switchToLatest];
    
    notModified = [SSignal fail:nil];
    
    return [notModified catch:^SSignal *(__unused id error) {
        return [[[[TGGroupManagementSignals editMessage:[self requestPeerId] accessHash:[self requestAccessHash] messageId:messageId text:text entities:entities disableLinksPreview:disableLinkPreviews] mapToSignal:^SSignal *(TGMessage *updatedMessage) {
            __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                TGMessage *message = updatedMessage;
                if (message == nil) {
                    return [SSignal fail:nil];
                } else {
                    return [SSignal single:message];
                }
            }
            
            return [SSignal complete];
        }] deliverOn:[TGModernConversationCompanion messageQueue]] onNext:^(TGMessage *message) {
            __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf updateMessagesLive:@{@(message.mid): message} animated:false];
            }
        }];
    }];
}

+ (bool)canDeleteMessageForEveryone:(TGMessage *)message peerId:(int64_t)peerId isPeerAdmin:(bool)isPeerAdmin {
    int32_t maxChannelMessageEditTime = 60 * 60 * 24 * 2;
    NSData *data = [TGDatabaseInstance() customProperty:@"maxChannelMessageEditTime"];
    if (data.length >= 4) {
        [data getBytes:&maxChannelMessageEditTime length:4];
    }
    
    if (peerId != TGTelegraphInstance.clientUserId) {
        if ([TGTelegramNetworking instance].approximateRemoteTime > message.date + maxChannelMessageEditTime) {
            return false;
        }
    }
    
    if (message.outgoing) {
        return true;
    }
    
    if (isPeerAdmin) {
        return true;
    }
    
    return false;
}

- (bool)canDeleteMessageForEveryone:(TGMessage *)message {
    return [TGGenericModernConversationCompanion canDeleteMessageForEveryone:message peerId:_conversationId isPeerAdmin:[self isPeerAdmin]];
}

- (bool)canEditMessage:(TGMessage *)message {
    if (message.mid >= TGMessageLocalMidBaseline) {
        return false;
    }
    
    bool editable = true;
    bool hasEditableContent = message.text.length != 0;
    for (id attachment in message.mediaAttachments) {
        if ([attachment isKindOfClass:[TGBotContextResultAttachment class]]) {
            editable = false;
            break;
        } else if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
            hasEditableContent = true;
        } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]] && !((TGVideoMediaAttachment *)attachment).roundMessage) {
            hasEditableContent = true;
        } else if ([attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]]) {
            editable = false;
            break;
        } else if ([attachment isKindOfClass:[TGViaUserAttachment class]]) {
            editable = false;
            break;
        } else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
            hasEditableContent = ![((TGDocumentMediaAttachment *)attachment) isSticker];
            break;
        }
    }
    
    if (!editable || !hasEditableContent) {
        return false;
    }
    
    int32_t maxChannelMessageEditTime = 60 * 60 * 24 * 2;
    NSData *data = [TGDatabaseInstance() customProperty:@"maxChannelMessageEditTime"];
    if (data.length >= 4) {
        [data getBytes:&maxChannelMessageEditTime length:4];
    }
    
    if (_conversationId != TGTelegraphInstance.clientUserId) {
        if ([TGTelegramNetworking instance].approximateRemoteTime > message.date + maxChannelMessageEditTime) {
            return false;
        }
    }
    
    if (message.outgoing) {
        return true;
    }
    
    return false;
}


@end
