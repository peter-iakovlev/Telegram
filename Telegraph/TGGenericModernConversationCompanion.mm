#import "TGGenericModernConversationCompanion.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"
#import "TGSharedPtrWrapper.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGPhoneUtils.h"

#import "TGAppDelegate.h"
#import "TGDownloadManager.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGViewController.h"
#import "TGInterfaceManager.h"
#import "TGDialogListController.h"

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

#import <map>
#import <vector>

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
    int32_t _preferredInitialPositionedMessageId;
    int _initialUnreadCount;
    
    NSArray *_initialForwardMessagePayload;
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
    
    id _dynamicTypeObserver;
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
        
        __weak TGGenericModernConversationCompanion *weakSelf = self;
        TGDispatchOnMainThread(^
        {
            if (iosMajorVersion() >= 7)
            {
                _dynamicTypeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:nil usingBlock:^(__unused NSNotification *notification)
                {
                    __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                    [strongSelf _dynamicTypeUpdated];
                }];
            }
        });
    }
    return self;
}

- (void)dealloc
{
    if (_dynamicTypeObserver != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:_dynamicTypeObserver];
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
    _initialForwardMessagePayload = initialForwardMessagePayload;
    _initialSendMessagePayload = initialSendMessagePayload;
    _initialSendFilePayload = initialSendFilePayload;
}

- (int64_t)conversationId
{
    return _conversationId;
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

- (NSDictionary *)_optionsForMessageActions
{
    return nil;
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
        [self _sendPreparedMessages:[self _createPreparedMessagesFromFiles:files] automaticallyAddToList:false withIntent:TGSendMessageIntentOther];
    }];
}

- (void)shareVCard
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        TGUser *user = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
        if (user != nil)
        {
            TGPreparedContactMessage *contactMessage = [[TGPreparedContactMessage alloc] initWithUid:user.uid firstName:user.firstName lastName:user.lastName phoneNumber:user.phoneNumber];
            [self _sendPreparedMessages:@[contactMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentOther];
        }
    }];
}

- (void)standaloneForwardMessages:(NSArray *)messages
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [self _sendPreparedMessages:[self _createPreparedForwardMessagesFromMessages:messages] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)loadInitialState
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
                [self _sendPreparedMessages:[self _createPreparedMessagesFromFiles:_initialSendFilePayload] automaticallyAddToList:false withIntent:TGSendMessageIntentOther];
            }
            _initialSendFilePayload = nil;
            
            if (_initialForwardMessagePayload.count != 0)
            {
                [self _sendPreparedMessages:[self _createPreparedForwardMessagesFromMessages:_initialForwardMessagePayload] automaticallyAddToList:false withIntent:TGSendMessageIntentOther];
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
            [TGDatabaseInstance() loadUnreadMessagesHeadFromConversation:_conversationId limit:initialMessageCount completion:^(NSArray *messages, bool isAtBottom)
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
        int index = sortedTopMessages.count;
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
    
    if (_initialUnreadCount != 0)
    {
        TGModernConversationController *controller = self.controller;
        [controller setGlobalUnreadCount:_initialUnreadCount];
    }
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
        
        NSString *inputText = [TGDatabaseInstance() loadConversationState:_conversationId];
        if (inputText.length != 0)
        {
            TGModernConversationController *controller = self.controller;
            [controller setInputText:inputText replace:true];
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
        
        [TGConversationReadHistoryActor executeStandalone:_conversationId];
    }
}

- (void)updateControllerInputText:(NSString *)inputText
{
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        [TGDatabaseInstance() storeConversationState:_conversationId state:inputText];
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

#pragma mark -

- (void)_dynamicTypeUpdated
{
    TGDispatchOnMainThread(^
    {
        TGUpdateMessageViewModelLayoutConstants();
        
        TGModernConversationController *controller = self.controller;
        [controller refreshMetrics];
    });
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
    [ActionStageInstance() watchForPaths:@[
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]],
        @"/tg/conversation/*/readmessages",
        @"/tg/conversation/*/failmessages",
        [[NSString alloc] initWithFormat:@"/tg/conversationReadApplied/(%@)", [self _conversationIdPathComponent]],
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesDeleted", [self _conversationIdPathComponent]],
        @"/tg/userdatachanges",
        @"/tg/userpresencechanges",
        @"/tg/contactlist",
        @"/as/updateRelativeTimestamps",
        @"downloadManagerStateChanged",
        @"/as/media/imageThumbnailUpdated",
        @"/tg/service/synchronizationstate",
        @"/tg/unreadCount",
        @"/tg/assets/currentWallpaperInfo",
        @"/tg/conversation/historyCleared"
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
                            requiredUsers.push_back(((TGForwardedMessageMediaAttachment *)attachment).forwardUid);
                            
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
    
    for (int itemIndex : requiredUsersItemIndices)
    {
        TGMessageModernConversationItem *messageItem = items[itemIndex];
        auto it = pUsers->end();
        
        bool needsAuthor = needsAuthors;
        
        if (messageItem->_message.mediaAttachments.count != 0)
        {
            NSMutableArray *additionalUsers = [[NSMutableArray alloc] initWithCapacity:1];
            
            for (TGMediaAttachment *attachment in messageItem->_message.mediaAttachments)
            {
                switch (attachment.type)
                {
                    case TGForwardedMessageMediaAttachmentType:
                    {
                        it = pUsers->find(((TGForwardedMessageMediaAttachment *)attachment).forwardUid);
                        if (it != pUsers->end())
                            [additionalUsers addObject:it->second];
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
        }
        
        if (needsAuthor)
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
                    
                    NSString *path = [cache pathForCachedData:url];
                    if (path != nil)
                    {
                        bool imageDownloaded = ([url hasPrefix:@"upload/"] || [url hasPrefix:@"file://"]) ? true : [fileManager fileExistsAtPath:path];
                        
                        if (item->_mediaAvailabilityStatus != imageDownloaded)
                        {
                            TGMessageModernConversationItem *updatedItem = [item copy];
                            updatedItem->_mediaAvailabilityStatus = imageDownloaded;
                            return updatedItem;
                        }
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
                        
                        [item updateToItem:updatedItem viewStorage:nil];
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

- (void)controllerWantsToSendTextMessage:(NSString *)text
{
    static const NSInteger messagePartLimit = 4096;
    NSMutableArray *preparedMessages = [[NSMutableArray alloc] init];
    
    if (text.length <= messagePartLimit)
        [preparedMessages addObject:[[TGPreparedTextMessage alloc] initWithText:text]];
    else
    {
        for (NSUInteger i = 0; i < text.length; i += messagePartLimit)
        {
            NSString *substring = [text substringWithRange:NSMakeRange(i, MIN(messagePartLimit, text.length - i))];
            if (substring.length != 0)
                [preparedMessages addObject:[[TGPreparedTextMessage alloc] initWithText:substring]];
        }
    }
    
    TGModernConversationController *controller = self.controller;
    [controller setEnableSendButton:false];
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [self _sendPreparedMessages:preparedMessages automaticallyAddToList:true withIntent:TGSendMessageIntentSendText];
        
        [TGDatabaseInstance() storeConversationState:_conversationId state:nil];
    }];
}

- (void)controllerWantsToSendMapWithLatitude:(double)latitude longitude:(double)longitude
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [self _sendPreparedMessages:@[[[TGPreparedMapMessage alloc] initWithLatitude:latitude longitude:longitude]] automaticallyAddToList:true withIntent:TGSendMessageIntentOther];
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

- (NSDictionary *)imageDescriptionFromImage:(UIImage *)image optionalAssetUrl:(NSString *)assetUrl
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
                return @{
                    @"remoteImage": @{
                        @"imageId": @(imageAttachment.imageId),
                        @"accessHash": @(imageAttachment.accessHash),
                        @"imageInfo": imageAttachment.imageInfo
                    }
                };
            }
        }
    }
    else
    {
        CGSize originalSize = image.size;
        originalSize.width *= image.scale;
        originalSize.height *= image.scale;
        
        CGSize imageSize = TGFitSize(originalSize, CGSizeMake(800, 800));
        CGSize thumbnailSize = TGFitSize(originalSize, CGSizeMake(90, 90));
        
        UIImage *fullImage = TGScaleImageToPixelSize(image, imageSize);
        NSData *imageData = UIImageJPEGRepresentation(fullImage, 0.8f);
        
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
            
            if (assetUrl != nil)
                dict[@"assetUrl"] = assetUrl;
            
            return @{@"localImage": dict};
        }
    }
    
    return nil;
}

- (void)controllerWantsToSendImagesWithDescriptions:(NSArray *)imageDescriptions
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        NSMutableArray *preparedMessages = [[NSMutableArray alloc] init];
        
        for (NSDictionary *imageDescription in imageDescriptions)
        {
            if (imageDescription[@"localImage"] != nil)
            {
                NSDictionary *localImage = imageDescription[@"localImage"];
                TGPreparedLocalImageMessage *imageMessage = [TGPreparedLocalImageMessage messageWithImageData:localImage[@"imageData"] imageSize:[localImage[@"imageSize"] CGSizeValue] thumbnailData:localImage[@"thumbnailData"] thumbnailSize:[localImage[@"thumbnailSize"] CGSizeValue] assetUrl:localImage[@"assetUrl"]];
                
                [preparedMessages addObject:imageMessage];
            }
            else if (imageDescription[@"remoteImage"] != nil)
            {
                NSDictionary *remoteImage = imageDescription[@"remoteImage"];
                TGPreparedRemoteImageMessage *imageMessage = [[TGPreparedRemoteImageMessage alloc] initWithImageId:[remoteImage[@"imageId"] longLongValue] accessHash:[remoteImage[@"accessHash"] longLongValue] imageInfo:remoteImage[@"imageInfo"]];
                
                [preparedMessages addObject:imageMessage];
            }
        }
        
        if (preparedMessages != nil)
            [self _sendPreparedMessages:preparedMessages automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)controllerWantsToSendLocalVideoWithTempFilePath:(NSString *)tempVideoFilePath fileSize:(int32_t)fileSize previewImage:(UIImage *)previewImage duration:(NSTimeInterval)duration dimensions:(CGSize)dimenstions assetUrl:(NSString *)assetUrl liveUploadData:(TGLiveUploadActorData *)liveUploadData
{
    TGPreparedLocalVideoMessage *videoMessage = [TGPreparedLocalVideoMessage messageWithTempVideoPath:tempVideoFilePath videoSize:dimenstions size:fileSize duration:duration previewImage:previewImage thumbnailSize:TGFitSize(CGSizeMake(previewImage.size.width * previewImage.scale, previewImage.size.height * previewImage.scale), [TGGenericModernConversationCompanion preferredInlineThumbnailSize]) assetUrl:assetUrl];
    videoMessage.liveData = liveUploadData;
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        [self _sendPreparedMessages:@[videoMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (TGVideoMediaAttachment *)serverCachedAssetWithId:(NSString *)assetId
{
    return [TGImageDownloadActor serverMediaDataForAssetUrl:assetId][@"videoAttachment"];
}

- (void)controllerWantsToSendDocumentWithTempFileUrl:(NSURL *)tempFileUrl fileName:(NSString *)fileName mimeType:(NSString *)mimeType
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        NSMutableDictionary *desc = [[NSMutableDictionary alloc] init];
        desc[@"url"] = tempFileUrl;
        if (fileName.length != 0)
            desc[@"fileName"] = fileName;
        
        if (mimeType.length != 0)
            desc[@"mimeType"] = mimeType;
        
        [self _sendPreparedMessages:[self _createPreparedMessagesFromFiles:@[desc]] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
    }];
}

- (void)controllerWantsToSendLocalAudioWithTempFileUrl:(NSURL *)tempFileUrl duration:(NSTimeInterval)duration liveData:(TGLiveUploadActorData *)liveData
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        NSString *filePath = [tempFileUrl path];
        
        TGPreparedLocalAudioMessage *audioMessage = [TGPreparedLocalAudioMessage messageWithTempAudioPath:filePath duration:(int32_t)duration];
        if (audioMessage != nil)
        {
            audioMessage.liveData = liveData;
            [self _sendPreparedMessages:@[audioMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
        }
    }];
}

- (void)controllerWantsToSendRemoteVideoWithMedia:(TGVideoMediaAttachment *)media
{
    if (media.videoId != 0)
    {
        int32_t fileSize = 0;
        if ([media.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:&fileSize] != nil)
        {
            TGPreparedRemoteVideoMessage *videoMessage = [[TGPreparedRemoteVideoMessage alloc] initWithVideoId:media.videoId accessHash:media.accessHash videoSize:media.dimensions size:fileSize duration:media.duration videoInfo:media.videoInfo thumbnailInfo:media.thumbnailInfo];
            
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                [self _sendPreparedMessages:@[videoMessage] automaticallyAddToList:true withIntent:TGSendMessageIntentSendOther];
            }];
        }
    }
}

- (void)controllerWantsToSendContact:(TGUser *)contactUser
{
    if (contactUser.phoneNumber.length == 0)
        return;
    
    TGPreparedContactMessage *contactMessage = nil;
    
    if (contactUser.uid > 0)
    {
        contactMessage = [[TGPreparedContactMessage alloc] initWithUid:contactUser.uid firstName:contactUser.firstName lastName:contactUser.lastName phoneNumber:[TGPhoneUtils cleanInternationalPhone:contactUser.phoneNumber forceInternational:false]];
    }
    else
    {
        contactMessage = [[TGPreparedContactMessage alloc] initWithFirstName:contactUser.firstName lastName:contactUser.lastName phoneNumber:[TGPhoneUtils cleanInternationalPhone:contactUser.phoneNumber forceInternational:false]];
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
            NSUInteger arrayIndex = [_items indexOfObject:messageItem];
#ifdef DEBUG
            NSAssert(arrayIndex != NSNotFound, @"Item should be present in array");
#endif
            [updatedItemIndices addObject:@(arrayIndex)];
            [_items replaceObjectAtIndex:arrayIndex withObject:updatedItem];
            [movingItems replaceObjectAtIndex:index withObject:updatedItem];
        }
        
        int index = -1;
        for (id item in movingItems.reverseObjectEnumerator)
        {
            index++;
            [_items insertObject:item atIndex:index];
            [moveIndexToIndex insertObject:@(index) atIndex:0];
        }
        
        [removeAtIndices shiftIndexesStartingAtIndex:[removeAtIndices firstIndex] by:movingItems.count];
        [_items removeObjectsAtIndexes:removeAtIndices];
        
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
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:mid];
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
            TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:messages sendMessages:nil];
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
        
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            switch (attachment.type)
            {
                case TGLocationMediaAttachmentType:
                {
                    TGLocationMediaAttachment *locationAttachment = (TGLocationMediaAttachment *)attachment;
                    TGPreparedMapMessage *mapMessage = [[TGPreparedMapMessage alloc] initWithLatitude:locationAttachment.latitude longitude:locationAttachment.longitude];
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
                        TGPreparedRemoteImageMessage *remoteImageMessage = [[TGPreparedRemoteImageMessage alloc] initWithImageId:imageAttachment.imageId accessHash:imageAttachment.accessHash imageInfo:imageAttachment.imageInfo];
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
                            
                            if (thumbnailUrl != nil && imageUrl != nil)
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
                                        TGPreparedLocalImageMessage *localImageMessage = [TGPreparedLocalImageMessage messageWithImageData:imageData imageSize:imageSize thumbnailData:thumbnailData thumbnailSize:thumbnailSize assetUrl:nil];
                                        if (!copyAssetsData)
                                            localImageMessage.replacingMid = message.mid;
                                        [preparedMessages addObject:localImageMessage];
                                    }
                                }
                                else
                                {
                                    TGPreparedLocalImageMessage *localImageMessage = [TGPreparedLocalImageMessage messageWithLocalImageDataPath:imageUrl imageSize:imageSize localThumbnailDataPath:thumbnailUrl thumbnailSize:thumbnailSize assetUrl:nil];
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
                            TGPreparedRemoteVideoMessage *remoteVideoMessage = [[TGPreparedRemoteVideoMessage alloc] initWithVideoId:videoAttachment.videoId accessHash:videoAttachment.accessHash videoSize:videoAttachment.dimensions size:fileSize duration:videoAttachment.duration videoInfo:videoAttachment.videoInfo thumbnailInfo:videoAttachment.thumbnailInfo];
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
                                TGPreparedLocalVideoMessage *localVideoMessage = [TGPreparedLocalVideoMessage messageByCopyingDataFromMedia:videoAttachment];
                                if (!copyAssetsData)
                                    localVideoMessage.replacingMid = message.mid;
                                [preparedMessages addObject:localVideoMessage];
                            }
                            else
                            {
                                TGPreparedLocalVideoMessage *localVideoMessage = [TGPreparedLocalVideoMessage messageWithLocalVideoId:videoAttachment.localVideoId videoSize:videoAttachment.dimensions size:fileSize duration:videoAttachment.duration localThumbnailDataPath:thumbnailUrl thumbnailSize:thumbnailSize assetUrl:nil];
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
                        TGPreparedRemoteDocumentMessage *remoteDocumentMessage = [[TGPreparedRemoteDocumentMessage alloc] initWithDocumentMedia:documentAttachment];
                        if (!copyAssetsData)
                            remoteDocumentMessage.replacingMid = message.mid;
                        [preparedMessages addObject:documentAttachment];
                    }
                    else if (documentAttachment.localDocumentId != 0)
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
                                TGPreparedLocalDocumentMessage *localDocumentMessage = [TGPreparedLocalDocumentMessage messageByCopyingDataFromMedia:documentAttachment];
                                if (!copyAssetsData)
                                    localDocumentMessage.replacingMid = message.mid;
                                [preparedMessages addObject:localDocumentMessage];
                            }
                            else
                            {
                                TGPreparedLocalDocumentMessage *localDocumentMessage = [TGPreparedLocalDocumentMessage messageWithLocalDocumentId:documentAttachment.localDocumentId size:documentAttachment.size fileName:documentAttachment.fileName mimeType:documentAttachment.mimeType localThumbnailDataPath:thumbnailUrl thumbnailSize:thumbnailSize];
                                if (!copyAssetsData)
                                    localDocumentMessage.replacingMid = message.mid;
                                [preparedMessages addObject:localDocumentMessage];
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
                            TGPreparedLocalAudioMessage *localAudioMessage = [TGPreparedLocalAudioMessage messageByCopyingDataFromMedia:audioAttachment];
                            if (!copyAssetsData)
                                localAudioMessage.replacingMid = message.mid;
                            [preparedMessages addObject:localAudioMessage];
                        }
                        else
                        {
                            TGPreparedLocalAudioMessage *localAudioMessage = [TGPreparedLocalAudioMessage messageWithLocalAudioId:audioAttachment.localAudioId duration:audioAttachment.duration fileSize:audioAttachment.fileSize];
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
                    
                    TGPreparedContactMessage *contactMessage = [[TGPreparedContactMessage alloc] initWithUid:contactAttachment.uid firstName:contactAttachment.firstName lastName:contactAttachment.lastName phoneNumber:contactAttachment.phoneNumber];
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
            TGPreparedTextMessage *textMessage = [[TGPreparedTextMessage alloc] initWithText:message.text];
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
            TGPreparedForwardedMessage *preparedMessage = [[TGPreparedForwardedMessage alloc] initWithInnerMessage:message];
            [preparedMessages addObject:preparedMessage];
        }
        else
            [preparedMessages addObjectsFromArray:[self _createPreparedMessagesFromMessages:@[message] copyAssetsData:true]];
    }
    
    return preparedMessages;
}

- (bool)isFileImage:(NSString *)fileName mimeType:(NSString *)mimeType
{
    NSArray *imageFileExtensions = @[@"gif", @"png", @"jpg", @"jpeg"];
    NSArray *imageMimeTypes = @[@"image/gif"];
    
    NSString *extension = [fileName pathExtension];
    for (NSString *sampleExtension in imageFileExtensions)
    {
        if ([[extension lowercaseString] isEqualToString:sampleExtension])
            return true;
    }
    
    for (NSString *sampleMimeType in imageMimeTypes)
    {
        if ([mimeType isEqualToString:sampleMimeType])
            return true;
    }
    
    return false;
}

- (NSArray *)_createPreparedMessagesFromFiles:(NSArray *)files
{
    NSMutableArray *preparedMessages = [[NSMutableArray alloc] init];
    
    for (NSDictionary *desc in files)
    {
        NSURL *fileUrl = desc[@"url"];
        if (fileUrl == nil)
            continue;
        
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileUrl path] error:nil];
        if (attributes[NSFileSize] == nil)
            continue;
        
        NSString *fileName = desc[@"fileName"];
        if (fileName == nil)
            fileName = [[fileUrl lastPathComponent] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        
        int size = [attributes[NSFileSize] intValue];
        
        UIImage *thumbnailImage = nil;
        CGSize thumbnailSize = CGSizeZero;
        
        if ([self isFileImage:fileName mimeType:desc[@"mimeType"]])
        {
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:[fileUrl path]];
            if (image != nil && image.size.width * image.size.height <= 8096 * 8096)
            {
                thumbnailSize = TGFitSize(image.size, [TGGenericModernConversationCompanion preferredInlineThumbnailSize]);
                thumbnailImage = TGScaleImageToPixelSize(image, thumbnailSize);
            }
        }
        
        TGPreparedLocalDocumentMessage *preparedMessage = [TGPreparedLocalDocumentMessage messageWithTempDocumentPath:[fileUrl path] size:(int32_t)size fileName:fileName mimeType:desc[@"mimeType"] thumbnailImage:thumbnailImage thumbnailSize:thumbnailSize];
        [preparedMessages addObject:preparedMessage];
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
    
    for (TGPreparedMessage *preparedMessage in preparedMessages)
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
        
        message.messageLifetime = [self messageLifetime];
        
        message.outgoing = true;
        message.unread = true;
        message.fromUid = TGTelegraphInstance.clientUserId;
        message.toUid = self.conversationId;
        message.deliveryState = TGMessageDeliveryStatePending;
        
        if ([self _messagesNeedRandomId])
            message.randomId = preparedMessage.randomId;
        
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
        [TGDatabaseInstance() addMessagesToConversation:addToDatabaseMessages conversationId:_conversationId updateConversation:nil dispatch:true countUnread:false];
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
                
                [TGDatabaseInstance() updateMessage:[pair[0] intValue] flags:flags media:nil dispatch:true];
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
                
                [self _replaceMessagesWithFastScroll:sortedTopMessages intent:becauseOfSendTextAction ? TGModernConversationAddMessageIntentSendTextMessage : TGModernConversationAddMessageIntentSendOtherMessage];
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
        
        [_items removeAllObjects];
        
        [self updateControllerEmptyState];
    }];
}

- (void)systemClearedConversation
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        _moreMessagesAvailableAbove = false;
        _moreMessagesAvailableBelow = false;
        
        _messageUploadProgress.clear();
        
        [_items removeAllObjects];
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = self.controller;
            [controller replaceItems:@[]];
        });
        
        [self updateControllerEmptyState];
    }];
}

- (void)controllerDeletedMessages:(NSArray *)messageIds
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
        
        [_items removeObjectsAtIndexes:indexSet];
        
        static int uniqueId = 0;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/deleteMessages/(%s%d)", _conversationId, __PRETTY_FUNCTION__, uniqueId++] options:@{@"mids": messageIds} watcher:TGTelegraphInstance];
    }];
}

- (void)controllerRequestedNavigationToConversationWithUser:(int32_t)uid
{
    [[TGInterfaceManager instance] navigateToConversationWithId:uid conversation:nil];
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
                [TGConversationReadHistoryActor executeStandalone:_conversationId];
            }
        }];
    }
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
            
            NSMutableArray *items = _items;
            for (int i = items.count - 1; i >= 0; i--)
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
            
            int count = _items.count;
            
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
                [_items removeObjectsAtIndexes:indexSet];
                
                TGLog(@"Unloaded %d items above (%d now)", indexSet.count, _items.count);
                
                _moreMessagesAvailableAbove = true;
            }
            else
            {
                indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _items.count - TGModernConversationControllerUnloadHistoryLimit)];
                [_items removeObjectsAtIndexes:indexSet];
                
                TGLog(@"Unloaded %d items below (%d now)", indexSet.count, _items.count);
                
                _moreMessagesAvailableBelow = true;
            }
            
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
                    [self controllerDeletedMessages:@[@(mid)]];
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
    
    [super actionStageActionRequested:action options:options];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]]])
    {
        NSArray *messages = ((SGraphObjectNode *)resource).object;
        bool hadIncomingUnread = false;
        
        for (TGMessage *message in messages)
        {
            if (!message.outgoing && message.unread)
            {
                hadIncomingUnread = true;
                
                TGDispatchOnMainThread(^
                {
                    TGModernConversationController *controller = self.controller;
                    if ([controller canReadHistory])
                    {
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
                
                break;
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
            [self _addMessages:messages animated:true intent:TGModernConversationAddMessageIntentGeneric];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesDeleted", [self _conversationIdPathComponent]]])
    {
        NSArray *messageIds = ((SGraphObjectNode *)resource).object;
        [self _deleteMessages:messageIds animated:true];
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
                
                int itemCount = _items.count;
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
                                [_items replaceObjectAtIndex:index withObject:messageItem];
                                
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
    
    int indexCount = indexSet.count;
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
                [self _updateItemProgress:previousMid animated:true];
                
                [self _updateMessageDelivered:previousMid mid:[result[@"mid"] intValue] date:[result[@"date"] intValue] message:result[@"message"]];
            }
        }];
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

@end
