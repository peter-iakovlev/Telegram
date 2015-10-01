#import "TGGenericModernConversationCompanion.h"

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
#import "TGPreparedLocalAudioMessage.h"
#import "TGPreparedRemoteAudioMessage.h"
#import "TGPreparedDownloadImageMessage.h"
#import "TGPreparedDownloadDocumentMessage.h"
#import "TGPreparedCloudDocumentMessage.h"

#import "TGForwardTargetController.h"

#import "TGModernSendMessageActor.h"
#import "TGConversationReadHistoryActor.h"
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

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 // iOS 6.0 or later
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else                                         // iOS 5.X or earlier
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif

typedef enum {
    TGSendMessageIntentSendText = 0,
    TGSendMessageIntentSendOther = 1,
    TGSendMessageIntentOther = 2
} TGSendMessageIntent;

@interface TGGenericModernConversationCompanion () <TGCreateContactControllerDelegate, TGAddToExistingContactControllerDelegate>
{
    bool _initialMayHaveUnreadMessages;
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
    
    TGProgressWindow *_progressWindow;
    int32_t _loadingMessageForSearch;
    int32_t _sourceMessageForSearch;
    bool _animatedTransitionInSearch;
    
    id<SDisposable> _botReplyMarkupDisposable;
}

@end

@implementation TGGenericModernConversationCompanion

- (instancetype)initWithConversationId:(int64_t)conversationId mayHaveUnreadMessages:(bool)mayHaveUnreadMessages
{
    self = [super init];
    if (self != nil)
    {        
        _conversationId = conversationId;
        
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
}

- (void)setOthersUnreadCount:(int)unreadCount
{
    _initialUnreadCount = unreadCount;
}

- (void)setPreferredInitialMessagePositioning:(int32_t)messageId
{
    _preferredInitialPositionedMessageId = messageId;
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
            TGPreparedContactMessage *contactMessage = [[TGPreparedContactMessage alloc] initWithUid:user.uid firstName:user.firstName lastName:user.lastName phoneNumber:user.phoneNumber replyMessage:nil];
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
        
        if (_preferredInitialPositionedMessageId != 0)
        {
            for (TGMessage *message in sortedTopMessages.reverseObjectEnumerator)
            {
                if (message.mid == _preferredInitialPositionedMessageId)
                {
                    [self setInitialMessagePositioning:message.mid position:TGInitialScrollPositionCenter];
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
                
                if (!message.outgoing && message.unread)
                {
                    lastUnreadIndex = index;
                    [self setInitialMessagePositioning:message.mid position:TGInitialScrollPositionTop];
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
        
        TGModernConversationController *controller = self.controller;
        
        int32_t replyMessageId = 0;
        __autoreleasing NSArray *forwardMessageDescs = nil;
        NSString *inputText = [TGDatabaseInstance() loadConversationState:_conversationId replyMessageId:&replyMessageId forwardMessageDescs:&forwardMessageDescs];
        if (inputText.length != 0)
        {
            [controller setInputText:inputText replace:true];
        }
        if (replyMessageId != 0)
        {
            TGMessage *replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
            if (replyMessage != nil)
            {
                [controller setReplyMessage:replyMessage animated:false];
            }
        }
        else if (forwardMessageDescs.count != 0)
        {
            NSMutableArray *forwardMessages = [[NSMutableArray alloc] init];
            for (NSDictionary *desc in forwardMessageDescs)
            {
                TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[desc[@"messageId"] intValue] peerId:[desc[@"peerId"] longLongValue]];
                if (message != nil)
                    [forwardMessages addObject:message];
            }
            TGModernConversationController *controller = self.controller;
            if (forwardMessages.count != 0)
                [controller setForwardMessages:forwardMessages animated:false];
        }
        
        if (_preferredInitialPositionedMessageId != 0)
            [controller temporaryHighlightMessage:_preferredInitialPositionedMessageId automatically:false];
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
        if ([controller canReadHistory])
        {
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                [self _markIncomingMessagesAsReadSilent];
            }];
            
            [TGConversationReadHistoryActor executeStandalone:_conversationId];
        }
        
        if (_preferredInitialPositionedMessageId != 0)
            [controller temporaryHighlightMessage:_preferredInitialPositionedMessageId automatically:true];
    }
}

- (void)updateControllerInputText:(NSString *)inputText
{
    TGModernConversationController *controller = self.controller;
    int32_t currentReplyMessageId = [controller _currentReplyMessageId];
    NSArray *currentForwardMessageDescs = [controller _currentForwardMessageDescs];
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        [TGDatabaseInstance() storeConversationState:_conversationId state:inputText replyMessageId:currentReplyMessageId forwardMessageDescs:currentForwardMessageDescs];
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
    if (![inputText containsSingleEmoji])
    {
        TGModernConversationController *controller = self.controller;
        [controller setInlineStickerList:nil];
    }
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (![inputText containsSingleEmoji])
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
            NSString *keyString = [inputText getEmojiFromString:true].firstObject;
            __weak TGGenericModernConversationCompanion *weakSelf = self;
            [_stickerPacksDisposable setDisposable:[[[[[[TGStickersSignals stickerPacks] filter:^bool(NSDictionary *dict)
            {
                return ((NSArray *)dict[@"packs"]).count != 0;
            }] take:1] mapToSignal:^SSignal *(NSDictionary *dict)
            {
                NSMutableArray *matchedDocuments = [[NSMutableArray alloc] init];
                
                NSDictionary *packUseCount = dict[@"packUseCount"];
                
                NSArray *sortedStickerPacks = [dict[@"packs"] sortedArrayUsingComparator:^NSComparisonResult(TGStickerPack *pack1, TGStickerPack *pack2)
                {
                    NSNumber *id1 = @(((TGStickerPackIdReference *)pack1.packReference).packId);
                    NSNumber *id2 = @(((TGStickerPackIdReference *)pack2.packReference).packId);
                    NSNumber *useCount1 = packUseCount[id1];
                    NSNumber *useCount2 = packUseCount[id2];
                    if (useCount1 != nil && useCount2 != nil)
                    {
                        NSComparisonResult result = [useCount1 compare:useCount2];
                        if (result == NSOrderedSame)
                            return [id1 compare:id2];
                        return result;
                    }
                    else if (useCount1 != nil)
                        return NSOrderedDescending;
                    else if (useCount2 != nil)
                        return NSOrderedAscending;
                    else
                        return [id1 compare:id2];
                }];
                
                for (TGStickerPack *stickerPack in sortedStickerPacks.reverseObjectEnumerator)
                {
                    NSMutableArray *documentIds = [[NSMutableArray alloc] init];
                    for (TGStickerAssociation *association in stickerPack.stickerAssociations)
                    {
                        if ([association.key isEqual:keyString])
                            [documentIds addObjectsFromArray:association.documentIds];
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
                
                return [TGStickersSignals preloadedStickerPreviews:matchedDocuments count:6];
            }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *matchedDocuments)
            {
                __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    TGModernConversationController *controller = strongSelf.controller;
                    if ([controller.inputText isEqualToString:inputText])
                        [controller setInlineStickerList:matchedDocuments];
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
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]],
        @"/tg/conversation/*/readmessages",
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/readmessages", [self _conversationIdPathComponent]],
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
        @"/tg/conversation/*/readmessageContents"
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
                            
                            if (!didAddToQueue) {
                                requiredUsersItemIndices.push_back(index);
                                didAddToQueue = true;
                            }
                            
                            break;
                        }
                        case TGReplyMessageMediaAttachmentType:
                        {
                            int64_t replyPeerId = ((TGReplyMessageMediaAttachment *)attachment).replyMessage.fromUid;
                            
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
                                {
                                    needsAuthor = true;
                                    
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
                                {
                                    needsAuthor = true;
                                    break;
                                }
                                default:
                                    break;
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
    
    std::tr1::shared_ptr<std::map<int, TGUser *> > pUsers = [TGDatabaseInstance() loadUsers:requiredUsers];
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
                        break;
                    }
                    case TGReplyMessageMediaAttachmentType:
                    {
                        int64_t replyPeerId = ((TGReplyMessageMediaAttachment *)attachment).replyMessage.fromUid;
                        
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
                            {
                                needsAuthor = true;
                                
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
                            {
                                needsAuthor = true;
                                break;
                            }
                            default:
                                break;
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
                {
                    TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                    
                    bool documentDownloaded = false;
                    if (documentAttachment.localDocumentId != 0)
                    {
                        NSString *documentPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:documentAttachment.localDocumentId] stringByAppendingPathComponent:[documentAttachment safeFileName]];
                        documentDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:documentPath];
                    }
                    else
                    {
                        NSString *documentPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId] stringByAppendingPathComponent:[documentAttachment safeFileName]];
                        documentDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:documentPath];
                    }
                    
                    if (item->_mediaAvailabilityStatus != documentDownloaded)
                    {
                        TGMessageModernConversationItem *updatedItem = [item copy];
                        updatedItem->_mediaAvailabilityStatus = documentDownloaded;
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
                        NSString *audioPath = [TGPreparedLocalAudioMessage localAudioFilePathForLocalAudioId1:audioAttachment.localAudioId];
                        audioDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:audioPath];
                    }
                    else
                    {
                        NSString *audioPath = [TGPreparedLocalAudioMessage localAudioFilePathForRemoteAudioId1:audioAttachment.audioId];
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
                        
                        [item updateToItem:updatedItem viewStorage:nil sizeChanged:NULL];
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

- (void)controllerWantsToSendTextMessage:(NSString *)text asReplyToMessageId:(int32_t)replyMessageId withAttachedMessages:(NSArray *)withAttachedMessages disableLinkPreviews:(bool)disableLinkPreviews
{
    static const NSInteger messagePartLimit = 4096;
    NSMutableArray *preparedMessages = [[NSMutableArray alloc] init];
    
    TGMessage *replyMessage = nil;
    if (replyMessageId != 0)
        replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
    
    TGWebPageMediaAttachment *parsedWebpage = nil;
    if (!disableLinkPreviews && [self allowMessageForwarding])
    {
        NSString *link = [TGModernConversationInputTextPanel linkCandidateInText:text];
        if (link != nil)
            parsedWebpage = [TGUpdateStateRequestBuilder webPageWithLink:link];
    }
    
    if (text.length != 0)
    {
        if (text.length <= messagePartLimit)
        {
            TGPreparedTextMessage *preparedMessage = [[TGPreparedTextMessage alloc] initWithText:text replyMessage:replyMessage disableLinkPreviews:disableLinkPreviews parsedWebpage:parsedWebpage];
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
                    TGPreparedTextMessage *preparedMessage = [[TGPreparedTextMessage alloc] initWithText:substring replyMessage:replyMessage disableLinkPreviews:disableLinkPreviews parsedWebpage:i == 0 ?parsedWebpage : nil];
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
        
        [TGDatabaseInstance() storeConversationState:_conversationId state:nil replyMessageId:0 forwardMessageDescs:@[]];
        
        TGDispatchOnMainThread(^
        {
            [TGRecentHashtagsSignal addRecentHashtagsFromText:text space:TGHashtagSpaceEntered];
        });
    }];
}

- (void)controllerWantsToSendMapWithLatitude:(double)latitude longitude:(double)longitude venue:(TGVenueAttachment *)venue asReplyToMessageId:(int32_t)replyMessageId
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        TGMessage *replyMessage = nil;
        if (replyMessageId != 0)
            replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
        
        TGPreparedMapMessage *preparedMessage = [[TGPreparedMapMessage alloc] initWithLatitude:latitude longitude:longitude venue:venue replyMessage:replyMessage];
        preparedMessage.messageLifetime = [self messageLifetime];
        [self _sendPreparedMessages:@[preparedMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (NSURL *)fileUrlForDocumentMedia:(TGDocumentMediaAttachment *)documentMedia
{
    if (documentMedia.localDocumentId != 0)
    {
        NSString *path = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:documentMedia.localDocumentId] stringByAppendingPathComponent:documentMedia.safeFileName];
        return [NSURL fileURLWithPath:path];
    }
    
    NSString *path = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentMedia.documentId] stringByAppendingPathComponent:documentMedia.safeFileName];
    return [NSURL fileURLWithPath:path];
}

- (NSDictionary *)imageDescriptionFromImage:(UIImage *)image caption:(NSString *)caption optionalAssetUrl:(NSString *)assetUrl
{
    if (image == nil)
        return nil;
    
    NSDictionary *serverData = [self _shouldCacheRemoteAssetUris] ? [TGImageDownloadActor serverMediaDataForAssetUrl:assetUrl] : nil;
    if (serverData != nil)
    {
        if ([serverData objectForKey:@"imageId"] != nil && [serverData objectForKey:@"imageAttachment"] != nil)
        {
            TGImageMediaAttachment *imageAttachment = [serverData objectForKey:@"imageAttachment"];
            if (imageAttachment != nil && imageAttachment.imageInfo != nil)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{
                    @"imageId": @(imageAttachment.imageId),
                    @"accessHash": @(imageAttachment.accessHash),
                    @"imageInfo": imageAttachment.imageInfo
                }];
                
                if (caption != nil)
                    dict[@"caption"] = caption;
                
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
        
        UIImage *fullImage = TGScaleImageToPixelSize(image, imageSize);
        NSData *imageData = UIImageJPEGRepresentation(fullImage, 0.52f);
        
        UIImage *previewImage = TGScaleImageToPixelSize(fullImage, TGFitSize(originalSize, [TGGenericModernConversationCompanion preferredInlineThumbnailSize]));
        NSData *thumbnailData = UIImageJPEGRepresentation(previewImage, 0.9f);
        
        previewImage = nil;
        fullImage = nil;
        
        if (imageData != nil && thumbnailData != nil)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{
                @"imageSize": [NSValue valueWithCGSize:imageSize],
                @"thumbnailSize": [NSValue valueWithCGSize:thumbnailSize],
                @"imageData": imageData,
                @"thumbnailData": thumbnailData
            }];
            
            if (caption != nil)
                dict[@"caption"] = caption;
            
            if (assetUrl != nil)
                dict[@"assetUrl"] = assetUrl;
            
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

- (NSDictionary *)documentDescriptionFromGiphySearchResult:(TGGiphySearchResultItem *)item
{
    if (item != nil && item.gifId.length != 0)
    {
        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
        [imageInfo addImageWithSize:item.previewSize url:item.previewUrl];
        return @{@"downloadDocument": @{
                @"id": item.gifId,
                @"thumbnailInfo": imageInfo,
                @"url": item.gifUrl,
                @"fileSize": @(item.gifFileSize),
                @"attributes": @[[[TGDocumentAttributeFilename alloc] initWithFilename:@"animation.gif"]]
            }
        };
    }
    
    return nil;
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

- (NSDictionary *)documentDescriptionFromInternalSearchResult:(TGWebSearchInternalGifResult *)item
{
    return @{
        @"remoteDocument": @{
            @"documentId": @(item.documentId),
            @"accessHash": @(item.accessHash),
            @"size": @(item.size),
            @"attributes": @[[[TGDocumentAttributeFilename alloc] initWithFilename:item.fileName]],
            @"mimeType": item.mimeType,
            @"thumbnailInfo": item.thumbnailInfo
        }
    };
}

- (NSDictionary *)documentDescriptionFromFileAtTempUrl:(NSURL *)url fileName:(NSString *)fileName mimeType:(NSString *)mimeType
{
    NSMutableDictionary *desc = [[NSMutableDictionary alloc] init];
    desc[@"url"] = url;
    if (fileName.length != 0)
        desc[@"fileName"] = fileName;
    
    if (mimeType.length != 0)
        desc[@"mimeType"] = mimeType;
    
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

- (void)controllerWantsToSendImagesWithDescriptions:(NSArray *)imageDescriptions asReplyToMessageId:(int32_t)replyMessageId
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
                TGPreparedLocalImageMessage *imageMessage = [TGPreparedLocalImageMessage messageWithImageData:localImage[@"imageData"] imageSize:[localImage[@"imageSize"] CGSizeValue] thumbnailData:localImage[@"thumbnailData"] thumbnailSize:[localImage[@"thumbnailSize"] CGSizeValue] assetUrl:localImage[@"assetUrl"] caption:localImage[@"caption"] replyMessage:replyMessage];
                
                [preparedMessages addObject:imageMessage];
                
                [self _addRecentHashtagsFromText:localImage[@"caption"]];
            }
            else if (imageDescription[@"remoteImage"] != nil)
            {
                NSDictionary *remoteImage = imageDescription[@"remoteImage"];
                TGPreparedRemoteImageMessage *imageMessage = [[TGPreparedRemoteImageMessage alloc] initWithImageId:[remoteImage[@"imageId"] longLongValue] accessHash:[remoteImage[@"accessHash"] longLongValue] imageInfo:remoteImage[@"imageInfo"] caption:remoteImage[@"caption"] replyMessage:replyMessage];
                
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
                    TGPreparedRemoteImageMessage *remoteImageMessage = [[TGPreparedRemoteImageMessage alloc] initWithImageId:imageAttachment.imageId accessHash:imageAttachment.accessHash imageInfo:imageAttachment.imageInfo caption:downloadImage[@"caption"] replyMessage:replyMessage];
                    
                    [preparedMessages addObject:remoteImageMessage];
                }
                else
                {
                    TGPreparedDownloadImageMessage *downloadImageMessage = [[TGPreparedDownloadImageMessage alloc] initWithImageInfo:imageInfo caption:downloadImage[@"caption"] replyMessage:replyMessage];
                    
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
                    TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment replyMessage:replyMessage];
                    [preparedMessages addObject:remoteDocumentMessage];
                }
                else
                {
                    int64_t localDocumentId = 0;
                    arc4random_buf(&localDocumentId, 8);
                    TGPreparedDownloadDocumentMessage *downloadDocumentMessage = [[TGPreparedDownloadDocumentMessage alloc] initWithGiphyId:downloadDocument[@"id"] documentUrl:downloadDocument[@"url"] localDocumentId:localDocumentId mimeType:@"image/gif" size:[downloadDocument[@"fileSize"] intValue] thumbnailInfo:downloadDocument[@"thumbnailInfo"] attributes:downloadDocument[@"attributes"] replyMessage:replyMessage];
                    
                    [preparedMessages addObject:downloadDocumentMessage];
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
                
                TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment replyMessage:replyMessage];
                [preparedMessages addObject:remoteDocumentMessage];
            }
        }
        
        if (preparedMessages != nil)
            [self _sendPreparedMessages:preparedMessages automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)controllerWantsToSendLocalVideoWithTempFilePath:(NSString *)tempVideoFilePath fileSize:(int32_t)fileSize previewImage:(UIImage *)previewImage duration:(NSTimeInterval)duration dimensions:(CGSize)dimenstions caption:(NSString *)caption assetUrl:(NSString *)assetUrl liveUploadData:(TGLiveUploadActorData *)liveUploadData asReplyToMessageId:(int32_t)replyMessageId
{
    TGMessage *replyMessage = nil;
    if (replyMessageId != 0)
        replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
    
    TGPreparedLocalVideoMessage *videoMessage = [TGPreparedLocalVideoMessage messageWithTempVideoPath:tempVideoFilePath videoSize:dimenstions size:fileSize duration:duration previewImage:previewImage thumbnailSize:TGFitSize(CGSizeMake(previewImage.size.width * previewImage.scale, previewImage.size.height * previewImage.scale), [TGGenericModernConversationCompanion preferredInlineThumbnailSize]) assetUrl:assetUrl caption:caption replyMessage:replyMessage];
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

- (void)controllerWantsToSendRemoteDocument:(TGDocumentMediaAttachment *)document asReplyToMessageId:(int32_t)replyMessageId
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
        
        [attachments addObject:document];
        
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
                    TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment replyMessage:replyMessage];
                    [preparedMessages addObject:remoteDocumentMessage];
                }
                else
                {
                    int64_t localDocumentId = 0;
                    arc4random_buf(&localDocumentId, 8);
                    
                    TGPreparedDownloadDocumentMessage *downloadDocumentMessage = [[TGPreparedDownloadDocumentMessage alloc] initWithGiphyId:downloadDocument[@"id"] documentUrl:downloadDocument[@"url"] localDocumentId:localDocumentId mimeType:downloadDocument[@"mimeType"] size:[downloadDocument[@"fileSize"] intValue] thumbnailInfo:downloadDocument[@"thumbnailInfo"] attributes:downloadDocument[@"attributes"] replyMessage:replyMessage];
                    
                    [preparedMessages addObject:downloadDocumentMessage];
                }
            }
            else if (documentDescription[@"cloudDocument"] != nil)
            {
                NSDictionary *cloudDocument = documentDescription[@"cloudDocument"];
                
                TGDocumentMediaAttachment *documentAttachment = [TGModernSendCommonMessageActor remoteDocumentByGiphyId:cloudDocument[@"id"]];
                if ([self controllerShouldCacheServerAssets] && documentAttachment != nil)
                {
                    TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment replyMessage:replyMessage];
                    [preparedMessages addObject:remoteDocumentMessage];
                }
                else
                {
                    int64_t localDocumentId = 0;
                    arc4random_buf(&localDocumentId, 8);
                    
                    TGPreparedCloudDocumentMessage *cloudDocumentMessage = [[TGPreparedCloudDocumentMessage alloc] initWithDocumentUrl:cloudDocument[@"url"] localDocumentId:localDocumentId mimeType:cloudDocument[@"mimeType"] size:[cloudDocument[@"fileSize"] intValue] thumbnailInfo:cloudDocument[@"thumbnailInfo"] attributes:cloudDocument[@"attributes"] replyMessage:replyMessage];
                    
                    [preparedMessages addObject:cloudDocumentMessage];
                }
            }
        }
        
        [self _sendPreparedMessages:preparedMessages automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)controllerWantsToSendLocalAudioWithDataItem:(TGDataItem *)dataItem duration:(NSTimeInterval)duration liveData:(TGLiveUploadActorData *)liveData asReplyToMessageId:(int32_t)replyMessageId
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        TGMessage *replyMessage = nil;
        if (replyMessageId != 0)
            replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
        
        TGPreparedLocalAudioMessage *audioMessage = [TGPreparedLocalAudioMessage messageWithTempDataItem:dataItem duration:(int32_t)duration replyMessage:replyMessage];
        if (audioMessage != nil)
        {
            audioMessage.liveData = liveData;
            [self _sendPreparedMessages:@[audioMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
        }
    }];
}

- (void)controllerWantsToSendRemoteVideoWithMedia:(TGVideoMediaAttachment *)media asReplyToMessageId:(int32_t)replyMessageId
{
    if (media.videoId != 0)
    {
        TGMessage *replyMessage = nil;
        if (replyMessageId != 0)
            replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
        
        int32_t fileSize = 0;
        if ([media.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:&fileSize] != nil)
        {
            TGPreparedRemoteVideoMessage *videoMessage = [[TGPreparedRemoteVideoMessage alloc] initWithVideoId:media.videoId accessHash:media.accessHash videoSize:media.dimensions size:fileSize duration:media.duration videoInfo:media.videoInfo thumbnailInfo:media.thumbnailInfo caption:media.caption replyMessage:replyMessage];
            
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                [self _sendPreparedMessages:@[videoMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
            }];
        }
    }
}

- (void)controllerWantsToSendContact:(TGUser *)contactUser asReplyToMessageId:(int32_t)replyMessageId
{
    if (contactUser.phoneNumber.length == 0)
        return;
    
    TGMessage *replyMessage = nil;
    if (replyMessageId != 0)
        replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyMessageId peerId:_conversationId];
    
    TGPreparedContactMessage *contactMessage = nil;
    
    if (contactUser.uid > 0)
    {
        contactMessage = [[TGPreparedContactMessage alloc] initWithUid:contactUser.uid firstName:contactUser.firstName lastName:contactUser.lastName phoneNumber:[TGPhoneUtils cleanInternationalPhone:contactUser.phoneNumber forceInternational:false] replyMessage:replyMessage];
    }
    else
    {
        contactMessage = [[TGPreparedContactMessage alloc] initWithFirstName:contactUser.firstName lastName:contactUser.lastName phoneNumber:[TGPhoneUtils cleanInternationalPhone:contactUser.phoneNumber forceInternational:false] replyMessage:replyMessage];
    }
    
    if (contactMessage != nil)
    {
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            [self _sendPreparedMessages:@[contactMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
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
                [controller updateItemAtIndex:[nIndex intValue] toItem:updatedItems[index]];
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
                
                [messages addObject:messageItem->_message];
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
            TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:messages sendMessages:nil showSecretChats:true];
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
                    TGPreparedMapMessage *mapMessage = [[TGPreparedMapMessage alloc] initWithLatitude:locationAttachment.latitude longitude:locationAttachment.longitude venue:locationAttachment.venue replyMessage:replyMessage];
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
                        TGPreparedRemoteImageMessage *remoteImageMessage = [[TGPreparedRemoteImageMessage alloc] initWithImageId:imageAttachment.imageId accessHash:imageAttachment.accessHash imageInfo:imageAttachment.imageInfo caption:imageAttachment.caption replyMessage:replyMessage];
                        if (!copyAssetsData)
                            remoteImageMessage.replacingMid = message.mid;
                        [preparedMessages addObject:remoteImageMessage];
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
                                TGPreparedDownloadImageMessage *downloadImageMessage = [[TGPreparedDownloadImageMessage alloc] initWithImageInfo:imageAttachment.imageInfo caption:imageAttachment.caption replyMessage:replyMessage];
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
                                        TGPreparedLocalImageMessage *localImageMessage = [TGPreparedLocalImageMessage messageWithImageData:imageData imageSize:imageSize thumbnailData:thumbnailData thumbnailSize:thumbnailSize assetUrl:nil caption:imageAttachment.caption replyMessage:replyMessage];
                                        if (!copyAssetsData)
                                            localImageMessage.replacingMid = message.mid;
                                        [preparedMessages addObject:localImageMessage];
                                    }
                                }
                                else
                                {
                                    TGPreparedLocalImageMessage *localImageMessage = [TGPreparedLocalImageMessage messageWithLocalImageDataPath:imageUrl imageSize:imageSize localThumbnailDataPath:thumbnailUrl thumbnailSize:thumbnailSize assetUrl:nil caption:imageAttachment.caption replyMessage:replyMessage];
                                    if (!copyAssetsData)
                                        localImageMessage.replacingMid = message.mid;
                                    [preparedMessages addObject:localImageMessage];
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
                            TGPreparedRemoteVideoMessage *remoteVideoMessage = [[TGPreparedRemoteVideoMessage alloc] initWithVideoId:videoAttachment.videoId accessHash:videoAttachment.accessHash videoSize:videoAttachment.dimensions size:fileSize duration:videoAttachment.duration videoInfo:videoAttachment.videoInfo thumbnailInfo:videoAttachment.thumbnailInfo caption:videoAttachment.caption replyMessage:replyMessage];
                            if (!copyAssetsData)
                                remoteVideoMessage.replacingMid = message.mid;
                            [preparedMessages addObject:remoteVideoMessage];
                        }
                    }
                    else if (videoAttachment.localVideoId != 0)
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
                                TGPreparedLocalVideoMessage *localVideoMessage = [TGPreparedLocalVideoMessage messageByCopyingDataFromMedia:videoAttachment replyMessage:replyMessage];
                                localVideoMessage.caption = videoAttachment.caption;
                                if (!copyAssetsData)
                                    localVideoMessage.replacingMid = message.mid;
                                [preparedMessages addObject:localVideoMessage];
                            }
                            else
                            {
                                TGPreparedLocalVideoMessage *localVideoMessage = [TGPreparedLocalVideoMessage messageWithLocalVideoId:videoAttachment.localVideoId videoSize:videoAttachment.dimensions size:fileSize duration:videoAttachment.duration localThumbnailDataPath:thumbnailUrl thumbnailSize:thumbnailSize assetUrl:nil caption:videoAttachment.caption replyMessage:replyMessage];
                                localVideoMessage.caption = videoAttachment.caption;
                                if (!copyAssetsData)
                                    localVideoMessage.replacingMid = message.mid;
                                [preparedMessages addObject:localVideoMessage];
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
                        TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment replyMessage:replyMessage];
                        if (!copyAssetsData)
                            remoteDocumentMessage.replacingMid = message.mid;
                        [preparedMessages addObject:remoteDocumentMessage];
                    }
                    else if (documentAttachment.localDocumentId != 0)
                    {
                        if (message.contentProperties[@"downloadDocumentUrl"] != nil)
                        {                            
                            TGDownloadDocumentUrl *documentUrl = message.contentProperties[@"downloadDocumentUrl"];
                            TGPreparedDownloadDocumentMessage *downloadDocumentMessage = [[TGPreparedDownloadDocumentMessage alloc] initWithGiphyId:documentUrl.giphyId documentUrl:documentUrl.documentUrl localDocumentId:documentAttachment.localDocumentId mimeType:documentAttachment.mimeType size:documentAttachment.size thumbnailInfo:documentAttachment.thumbnailInfo attributes:documentAttachment.attributes replyMessage:replyMessage];
                            if (!copyAssetsData)
                                downloadDocumentMessage.replacingMid = message.mid;
                            [preparedMessages addObject:downloadDocumentMessage];
                        }
                        else if (message.contentProperties[@"cloudDocumentUrl"] != nil)
                        {
                            TGCloudDocumentUrlBookmark *documentUrlBookmark = message.contentProperties[@"cloudDocumentUrl"];
                            TGPreparedCloudDocumentMessage *cloudDocumentMessage = [[TGPreparedCloudDocumentMessage alloc] initWithDocumentUrl:documentUrlBookmark.documentUrl localDocumentId:documentAttachment.localDocumentId mimeType:documentAttachment.mimeType size:documentAttachment.size thumbnailInfo:documentAttachment.thumbnailInfo attributes:documentAttachment.attributes replyMessage:replyMessage];
                            if (!copyAssetsData)
                                cloudDocumentMessage.replacingMid = message.mid;
                            [preparedMessages addObject:cloudDocumentMessage];
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
                                    TGPreparedLocalDocumentMessage *localDocumentMessage = [TGPreparedLocalDocumentMessage messageByCopyingDataFromMedia:documentAttachment replyMessage: replyMessage];
                                    if (!copyAssetsData)
                                        localDocumentMessage.replacingMid = message.mid;
                                    [preparedMessages addObject:localDocumentMessage];
                                }
                                else
                                {
                                    TGPreparedLocalDocumentMessage *localDocumentMessage = [TGPreparedLocalDocumentMessage messageWithLocalDocumentId:documentAttachment.localDocumentId size:documentAttachment.size mimeType:documentAttachment.mimeType localThumbnailDataPath:thumbnailUrl thumbnailSize:thumbnailSize attributes:documentAttachment.attributes];
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
                    TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                    
                    if (audioAttachment.audioId != 0)
                    {
                        TGPreparedRemoteAudioMessage *remoteAudioMessage = [[TGPreparedRemoteAudioMessage alloc] initWithAudioMedia:audioAttachment];
                        if (!copyAssetsData)
                            remoteAudioMessage.replacingMid = message.mid;
                        [preparedMessages addObject:remoteAudioMessage];
                    }
                    else if (audioAttachment.localAudioId != 0)
                    {
                        if (copyAssetsData)
                        {
                            TGPreparedLocalAudioMessage *localAudioMessage = [TGPreparedLocalAudioMessage messageByCopyingDataFromMedia:audioAttachment replyMessage:replyMessage];
                            if (!copyAssetsData)
                                localAudioMessage.replacingMid = message.mid;
                            [preparedMessages addObject:localAudioMessage];
                        }
                        else
                        {
                            TGPreparedLocalAudioMessage *localAudioMessage = [TGPreparedLocalAudioMessage messageWithLocalAudioId:audioAttachment.localAudioId duration:audioAttachment.duration fileSize:audioAttachment.fileSize replyMessage:replyMessage];
                            if (!copyAssetsData)
                                localAudioMessage.replacingMid = message.mid;
                            [preparedMessages addObject:localAudioMessage];
                        }
                    }
                    
                    messageAdded = true;
                    break;
                }
                case TGContactMediaAttachmentType:
                {
                    TGContactMediaAttachment *contactAttachment = (TGContactMediaAttachment *)attachment;
                    
                    TGPreparedContactMessage *contactMessage = [[TGPreparedContactMessage alloc] initWithUid:contactAttachment.uid firstName:contactAttachment.firstName lastName:contactAttachment.lastName phoneNumber:contactAttachment.phoneNumber replyMessage:replyMessage];
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
            TGPreparedTextMessage *textMessage = [[TGPreparedTextMessage alloc] initWithText:message.text replyMessage:replyMessage disableLinkPreviews:((TGLinkPreviewsContentProperty *)message.contentProperties[@"linkPreviews"]).disableLinkPreviews parsedWebpage:nil];
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
            for (id attachment in innerMessage.mediaAttachments)
            {
                if (![self allowMessageForwarding])
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
                [mediaAttachments addObject:attachment];
            }
            innerMessage.mediaAttachments = mediaAttachments;
            TGPreparedForwardedMessage *preparedMessage = [[TGPreparedForwardedMessage alloc] initWithInnerMessage:innerMessage keepForwarded:[self allowMessageForwarding]];
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
                
                TGPreparedLocalImageMessage *imageMessage = [TGPreparedLocalImageMessage messageWithImageData:imageData imageSize:imageSize thumbnailData:thumbnailData thumbnailSize:thumbnailSize assetUrl:nil caption:nil replyMessage:replyMessage];
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
                        
                        TGPreparedLocalImageMessage *imageMessage = [TGPreparedLocalImageMessage messageWithImageData:imageData imageSize:imageSize thumbnailData:thumbnailData thumbnailSize:thumbnailSize assetUrl:nil caption:nil replyMessage:replyMessage];
                        [preparedMessages addObject:imageMessage];
                    }
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
                
                [documentAttributes addObject:[[TGDocumentAttributeFilename alloc] initWithFilename:documentFileName]];
                if (imageSize.width > FLT_EPSILON && imageSize.height > FLT_EPSILON)
                    [documentAttributes addObject:[[TGDocumentAttributeImageSize alloc] initWithSize:imageSize]];
                if (isAnimatedImage)
                    [documentAttributes addObject:[[TGDocumentAttributeAnimated alloc] init]];
                if ([fileName hasSuffix:@".webp"])
                {
                    [documentAttributes addObject:[[TGDocumentAttributeSticker alloc] init]];
                }
                TGPreparedLocalDocumentMessage *preparedMessage = [TGPreparedLocalDocumentMessage messageWithTempDocumentPath:[fileUrl path] size:(int32_t)size mimeType:documentMimeType thumbnailImage:thumbnailImage thumbnailSize:thumbnailSize attributes:documentAttributes replyMessage:replyMessage];
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
    
    for (TGPreparedMessage *preparedMessage in preparedMessages)
    {
        int32_t minLifetime = 0;
        
        if ([preparedMessage isKindOfClass:[TGPreparedLocalAudioMessage class]])
            minLifetime = ((TGPreparedLocalAudioMessage *)preparedMessage).duration;
        else if ([preparedMessage isKindOfClass:[TGPreparedRemoteAudioMessage class]])
            minLifetime = ((TGPreparedRemoteAudioMessage *)preparedMessage).duration;
        else if ([preparedMessage isKindOfClass:[TGPreparedLocalVideoMessage class]])
            minLifetime = (int32_t)((TGPreparedLocalVideoMessage *)preparedMessage).duration;
        else if ([preparedMessage isKindOfClass:[TGPreparedRemoteVideoMessage class]])
            minLifetime = (int32_t)((TGPreparedRemoteVideoMessage *)preparedMessage).duration;
        
        if (false && [preparedMessage isKindOfClass:[TGPreparedForwardedMessage class]] && ((TGPreparedForwardedMessage *)preparedMessage).forwardMid > 0 && ((TGPreparedForwardedMessage *)preparedMessage).forwardMid < TGMessageLocalMidBaseline)
        {
            [forwardedMessages addObject:preparedMessage];
        }
        else
        {
            preparedMessage.messageLifetime = [self messageLifetime] == 0 ? 0 : MAX([self messageLifetime], minLifetime);
            
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
            message.unread = true;
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
        message.unread = true;
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
            [TGDatabaseInstance() addMessagesToChannel:_conversationId messages:addToDatabaseMessages deleteMessages:nil unimportantGroups:nil addedHoles:nil removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:nil changedMessages:nil];
        } else {
            [TGDatabaseInstance() addMessagesToConversation:addToDatabaseMessages conversationId:_conversationId updateConversation:nil dispatch:true countUnread:false];
        }
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]] resource:[[SGraphObjectNode alloc] initWithObject:addToDatabaseMessages]];
    }
    
    if (replaceInDatabaseMessages.count != 0)
    {
        [TGDatabaseInstance() dispatchOnDatabaseThread:^
        {
            for (NSArray *pair in replaceInDatabaseMessages)
            {
                TGMessage *updatedMessage = pair[1];
                
                std::vector<TGDatabaseMessageFlagValue> flags;
                flags.push_back((TGDatabaseMessageFlagValue){ .flag = TGDatabaseMessageFlagMid, .value = updatedMessage.mid });
                flags.push_back((TGDatabaseMessageFlagValue){ .flag = TGDatabaseMessageFlagUnread, .value = updatedMessage.unread });
                flags.push_back((TGDatabaseMessageFlagValue){ .flag = TGDatabaseMessageFlagDeliveryState, .value = updatedMessage.deliveryState });
                flags.push_back((TGDatabaseMessageFlagValue){ .flag = TGDatabaseMessageFlagDate, .value = (int)updatedMessage.date });
                
                [TGDatabaseInstance() updateMessage:[pair[0] intValue] peerId:_conversationId flags:flags media:nil dispatch:true];
            }
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
        
        if (_moreMessagesAvailableBelow)
        {
            if (addIntent == TGModernConversationAddMessageIntentSendTextMessage || addIntent == TGModernConversationAddMessageIntentSendOtherMessage)
                [self _performFastScrollDown:addIntent == TGModernConversationAddMessageIntentSendTextMessage];
        }
        else
            [self _addMessages:addedMessages animated:true intent:addIntent];
    }
    
    return addedMessages;
}

- (void)_performFastScrollDown:(bool)becauseOfSendTextAction
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
                
                [self _replaceMessagesWithFastScroll:sortedTopMessages intent:becauseOfSendTextAction ? TGModernConversationAddMessageIntentSendTextMessage : TGModernConversationAddMessageIntentSendOtherMessage scrollToMessageId:0 scrollBackMessageId:0 animated:true];
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
        
        [(NSMutableArray *)_items removeAllObjects];
        
        [self updateControllerEmptyState];
        [self _itemsUpdated];
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
            [controller replaceItems:@[]];
        });
        
        [self updateControllerEmptyState];
        [self _itemsUpdated];
    }];
}

- (void)controllerDeletedMessages:(NSArray *)messageIds completion:(void (^)())completion
{
    if (messageIds.count == 0)
        return;
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        std::set<int> messageIdSet;
        for (NSNumber *nMid in messageIds)
        {
            messageIdSet.insert([nMid intValue]);
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
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/deleteMessages/(%s%d)", _conversationId, __PRETTY_FUNCTION__, uniqueId++] options:@{@"mids": messageIds} watcher:TGTelegraphInstance];
    }];
}

- (void)controllerRequestedNavigationToConversationWithUser:(int32_t)uid
{
    [[TGInterfaceManager instance] navigateToConversationWithId:uid conversation:nil];
}

- (void)_markIncomingMessagesAsReadSilent
{
    NSUInteger count = _items.count;
    for (NSUInteger i = 0; i < count; i++)
    {
        TGMessageModernConversationItem *item = _items[i];
        if (!item->_message.outgoing && item->_message.unread)
        {
            item = [item deepCopy];
            item->_message.unread = false;
            [(NSMutableArray *)_items replaceObjectAtIndex:i withObject:item];
        }
    }
}

- (void)controllerCanReadHistoryUpdated
{
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
                
                [TGConversationReadHistoryActor executeStandalone:_conversationId];
            }
        }];
    }
}

- (void)controllerCanRegroupUnreadIncomingMessages
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        TGMessageRange unreadRange = TGMessageRangeEmpty();
        
        for (TGMessageModernConversationItem *item in _items)
        {
            if (!item->_message.outgoing && item->_message.unread)
            {
                if (unreadRange.firstMessageId == INT32_MAX || unreadRange.firstMessageId > item->_message.mid)
                {
                    unreadRange.firstMessageId = item->_message.mid;
                    unreadRange.firstDate = (int32_t)item->_message.date;
                }
                if (unreadRange.lastMessageId == INT32_MAX || unreadRange.lastMessageId < item->_message.mid)
                {
                    unreadRange.lastMessageId = item->_message.mid;
                    unreadRange.lastDate = (int32_t)item->_message.date;
                }
            }
        }
        
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
    if ([action isEqualToString:@"userAvatarTapped"])
    {
        if ([options[@"uid"] intValue] > 0)
            [[TGInterfaceManager instance] navigateToProfileOfUser:[options[@"uid"] intValue]];
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
                        [[TGInterfaceManager instance] navigateToConversationWithId:peerId conversation:conversation performActions:@{} atMessage:@{@"mid": @(messageId)} clearStack:true openKeyboard:false animated:true];
                    } error:^(id error) {
                        NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                        if ([errorType isEqualToString:@"PEER_ID_INVALID"]) {
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
            if (uid != 0)
                [[TGInterfaceManager instance] navigateToProfileOfUser:uid];
            
            return;
        }
        else if ([options[@"url"] hasPrefix:@"mention://"])
        {   
            NSString *domain = [options[@"url"] substringFromIndex:@"mention://".length];
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/resolveDomain/(%@,profile)", domain] options:@{@"domain": domain, @"profile": @true} flags:0 watcher:TGTelegraphInstance];
            return;
        }
        else if ([options[@"url"] hasPrefix:@"hashtag://"])
        {
            NSString *hashtag = [options[@"url"] substringFromIndex:@"hashtag://".length];
            
            TGHashtagSearchController *hashtagController = [[TGHashtagSearchController alloc] initWithQuery:[@"#" stringByAppendingString:hashtag] peerId:[self requestPeerId] accessHash:[self requestAccessHash]];
            __weak TGGenericModernConversationCompanion *weakSelf = self;
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
            
            [self controllerWantsToSendTextMessage:command asReplyToMessageId:0 withAttachedMessages:nil disableLinkPreviews:false];
            
            //TGModernConversationController *controller = self.controller;
            //[controller appendCommand:command];
            
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
                        
                        break;
                    }
                }
                
                if (_messageUploadProgress.find(mid) != _messageUploadProgress.end())
                {
                    [self _deleteMessages:@[@(mid)] animated:true];
                    [self controllerDeletedMessages:@[@(mid)] completion:nil];
                }
                
                TG_SYNCHRONIZED_BEGIN(_processingDownloadMids);
                _processingDownloadMids.erase(mid);
                TG_SYNCHRONIZED_END(_processingDownloadMids);
            }];
        }
    }
    else if ([action isEqualToString:@"stopInlineMedia"])
    {
        TGModernConversationController *controller = self.controller;
        [controller stopInlineMedia];
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
                _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [_progressWindow show:true];
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
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]]])
    {
        NSArray *messages = ((SGraphObjectNode *)resource).object;
        bool hadIncomingUnread = false;
        bool treatIncomingAsUnread = [arguments[@"treatIncomingAsUnread"] boolValue];
        
        for (TGMessage *message in messages)
        {
            if (!message.outgoing && (treatIncomingAsUnread || message.unread))
            {
                hadIncomingUnread = true;
                
                break;
            }
            
            if (treatIncomingAsUnread && message.group != nil) {
                hadIncomingUnread = true;
            }
        }
        
        if (_moreMessagesAvailableBelow)
        {
            if (hadIncomingUnread)
            {
                TGDispatchOnMainThread(^
                {
                    TGModernConversationController *controller = self.controller;
                    [controller setHasUnseenMessagesBelow:true];
                });
            }
        }
        else
        {
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                TGModernConversationAddMessageIntent intent = TGModernConversationAddMessageIntentGeneric;
                bool animated = true;
                if (arguments[@"animated"] != nil && ![arguments[@"animated"] boolValue]) {
                    intent = TGModernConversationAddMessageIntentLoadMoreMessagesAbove;
                    animated = false;
                }
                [self _addMessages:messages animated:animated intent:intent];
            }];
        }
        
        [self scheduleReadHistory];
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
        for (NSUInteger i = 0; i < midMessagePairs.count; i += 2)
        {
            dict[midMessagePairs[0]] = midMessagePairs[1];
        }
        
        [self _updateMessages:dict];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messageViews", [self _conversationIdPathComponent]]]) {
        [self updateMessageViews:resource markAsSeen:false];
    }
    else if ([path isEqualToString:@"/tg/conversation/*/readmessages"])
    {
        TGSharedPtrWrapper *ptrWrapper = ((SGraphObjectNode *)resource).object;
        if (ptrWrapper == nil)
            return;
        
        std::tr1::shared_ptr<std::set<int> > mids = std::tr1::static_pointer_cast<std::set<int> >([ptrWrapper ptr]);
        
        if (mids != NULL)
        {
            NSMutableArray *messageIds = [[NSMutableArray alloc] initWithCapacity:mids->size()];
            for (int mid : *(mids.get()))
            {
                [messageIds addObject:[[NSNumber alloc] initWithInt:mid]];
            }
            
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                [self _updateMessagesRead:messageIds];
            }];
        }
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/readmessages", [self _conversationIdPathComponent]]])
    {
        bool isOutbox = [resource[@"outbox"] boolValue];
        int32_t maxMessageId = [resource[@"maxMessageId"] intValue];
        
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            NSMutableArray *markedMessageIds = [[NSMutableArray alloc] init];
            
            for (TGMessageModernConversationItem *item in _items)
            {
                if (item->_message.outgoing == isOutbox)
                {
                    if (item->_message.mid <= maxMessageId)
                    {
                        [markedMessageIds addObject:@(item->_message.mid)];
                    }
                }
            }
            
            [self _updateMessagesRead:markedMessageIds];
        }];
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
                            [controller updateItemAtIndex:[updatedItemIndices[index] unsignedIntegerValue] toItem:updatedItem];
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
                [self _updateMediaStatusDataForItemsInIndexSet:indexSet animated:false];
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
            else
                stateString = TGLocalized(@"State.Connecting");
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
                        [controller updateItemAtIndex:[nIndex intValue] toItem:updatedItems[index]];
                    }
                });
            }
        }];
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
                
                [self _updateMessageDelivered:previousMid mid:[result[@"mid"] intValue] date:[result[@"date"] intValue] message:result[@"message"] unread:result[@"unread"]];
                
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
                                        [[NSNumber alloc] initWithBool:message.unread], @"forceSave",
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
                    id mediaId = [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.documentId != 0 ? documentAttachment.documentId : documentAttachment.localDocumentId];
                    [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", documentAttachment.datacenterId, documentAttachment.documentId, documentAttachment.documentUri.length != 0 ? documentAttachment.documentUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:documentAttachment, @"documentAttachment", nil] changePriority:highPriority messageId:message.mid itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassDocument];
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
                            
                            [TGDatabaseInstance() updateMessage:updatedItem->_message.mid peerId:_conversationId withMessage:updatedItem->_message];
                            
                            TGDispatchOnMainThread(^
                            {
                                TGModernConversationController *controller = self.controller;
                                [controller updateItemAtIndex:index toItem:updatedItem];
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
    return [[TGTelegraphInstance activityManagerForConversationId:_conversationId] addActivityWithType:@"recordingAudio" priority:0];
}

- (id)acquireLocationPickingActivityHolder
{
    return [[TGTelegraphInstance activityManagerForConversationId:_conversationId] addActivityWithType:@"pickingLocation" priority:0];
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

- (void)_replaceMessages:(NSArray *)newMessages atMessageId:(int32_t)atMessageId expandFrom:(int32_t)expandMessageId jump:(bool)jump {
    [super _replaceMessages:newMessages atMessageId:atMessageId expandFrom:expandMessageId jump:jump];
    
    [[TGDownloadManager instance] requestState:self.actionHandle];
}

- (int64_t)requestPeerId {
    return _conversationId;
}

- (int64_t)requestAccessHash {
    return 0;
}

- (void)scheduleReadHistory {
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
                [TGConversationReadHistoryActor executeStandalone:_conversationId];
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

@end
