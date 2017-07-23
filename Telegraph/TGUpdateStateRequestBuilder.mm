#import "TGUpdateStateRequestBuilder.h"

#import <SSignalKit/SSignalKit.h>

#import "TGCommon.h"
#import "ASCommon.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"
#import "SGraphListNode.h"

#import "TGPeerIdAdapter.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTDatacenterAddress.h>

#import "TGAppDelegate.h"

#import "TGInterfaceManager.h"

#import "TGUserDataRequestBuilder.h"
#import "TGApplyStateRequestBuilder.h"
#import "TGConversationAddMessagesActor.h"

#import "TGSynchronizeActionQueueActor.h"

#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"
#import "TGDatabase.h"

#import "TGImageInfo+Telegraph.h"

#import "TGTimelineItem.h"

#import "TGUser+Telegraph.h"

#import "TGStringUtils.h"
#import "TGDateUtils.h"
#import <MTProtoKit/MTEncryption.h>

#import "TGUpdate.h"

#import "TGRequestEncryptedChatActor.h"

#import "TLMetaClassStore.h"

#import "TGModernSendSecretMessageActor.h"

#import "TGAlertView.h"

#import "SecretLayer1.h"
#import "SecretLayer17.h"

#import "TGAlertView.h"

#import "TGDownloadMessagesSignal.h"

#import "TGWebPageMediaAttachment+Telegraph.h"

#import <set>

#import <libkern/OSAtomic.h>

#import "TGMessageViewedContentProperty.h"
#import "TGStickersSignals.h"
#import "TGMaskStickersSignals.h"

#import "TLDcOption$modernDcOption.h"

#import "TLMessage$modernMessage.h"
#import "TLMessage$modernMessageService.h"

#import "TGChannelStateSignals.h"
#import "TGChannelManagementSignals.h"

#import "TGServiceSignals.h"

#import "TGStickerAssociation.h"

#import "TGDocumentMediaAttachment+Telegraph.h"

#import "TGRecentGifsSignal.h"
#import "TGRecentStickersSignal.h"

#import "TLUpdate$updateChannelTooLong.h"

#import "TGCallContext.h"
#import "TGCallSession.h"

#import "TGGroupManagementSignals.h"

#import "TGCallSignals.h"

#import "TGLocalizationSignals.h"
#import "TGLocalization.h"

#import "TGSuggestedLocalizationController.h"
#import "TGLocalizationSelectionController.h"

static int stateVersion = 0;
static bool didRequestUpdates = false;

static std::map<int, std::set<int64_t> > _ignoredConversationIds;

static NSMutableDictionary *delayedMessagesInConversations()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

static OSSpinLock webPagesByIdLock = 0;
static NSMutableDictionary *webPagesById()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

static OSSpinLock webPagesByLinkLock = 0;
static NSMutableDictionary *webPagesByLink()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

static OSSpinLock awaitingWebPageListenersByIdLock = 0;
static NSMutableDictionary *awaitingWebPageListenersById()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

static id<SDisposable> addAwaitingWebPageListener(int64_t webPageId, void (^completion)(TGWebPageMediaAttachment *))
{
    OSSpinLockLock(&awaitingWebPageListenersByIdLock);
    SBag *bag = awaitingWebPageListenersById()[@(webPageId)];
    if (bag == nil)
    {
        bag = [[SBag alloc] init];
        awaitingWebPageListenersById()[@(webPageId)] = bag;
    }
    NSUInteger index = [bag addItem:[completion copy]];
    OSSpinLockUnlock(&awaitingWebPageListenersByIdLock);
    
    return [[SBlockDisposable alloc] initWithBlock:^
    {
        OSSpinLockLock(&awaitingWebPageListenersByIdLock);
        SBag *bag = awaitingWebPageListenersById()[@(webPageId)];
        if (bag != nil)
        {
            [bag removeItem:index];
            if ([bag isEmpty])
                [awaitingWebPageListenersById() removeObjectForKey:@(webPageId)];
        }
        OSSpinLockUnlock(&awaitingWebPageListenersByIdLock);
    }];
}

static void notifyAwaitingWebPageListeners(TGWebPageMediaAttachment *webPage)
{
    NSArray *completions = nil;
    OSSpinLockLock(&awaitingWebPageListenersByIdLock);
    SBag *bag = awaitingWebPageListenersById()[@(webPage.webPageId)];
    if (bag != nil)
    {
        completions = [bag copyItems];
        [awaitingWebPageListenersById() removeObjectForKey:@(webPage.webPageId)];
    }
    OSSpinLockUnlock(&awaitingWebPageListenersByIdLock);
    
    for (void (^completion)(TGWebPageMediaAttachment *) in completions)
    {
        completion(webPage);
    }
}

static bool _initialUpdatesScheduled = false;

@interface TGUpdateStateRequestBuilder ()

@property (nonatomic, strong) TGSynchronizeActionQueueActor *synchronizeActionQueueActor;

@property (nonatomic, strong) TLupdates_State *state;
@property (nonatomic, strong) SGraphNode *dialogListNode;

@end

@implementation TGUpdateStateRequestBuilder

+ (NSString *)genericPath
{
    return @"/tg/service/updatestate";
}

+ (void)scheduleInitialUpdates
{
    _initialUpdatesScheduled = true;
}

+ (void)clearStateHistory
{
    stateVersion = 0;
    didRequestUpdates = false;
    
    [delayedMessagesInConversations() removeAllObjects];
    
    OSSpinLockLock(&webPagesByIdLock);
    [webPagesById() removeAllObjects];
    OSSpinLockUnlock(&webPagesByIdLock);
}

+ (int)stateVersion
{
    return stateVersion;
}

+ (void)invalidateStateVersion
{
    stateVersion++;
    
    [TGDatabaseInstance() upgradeUserLinks];
}

+ (void)addIgnoreConversationId:(int64_t)conversationId
{
    _ignoredConversationIds[TGTelegraphInstance.clientUserId].insert(conversationId);
}

+ (bool)ignoringConversationId:(int64_t)conversationId
{
    return _ignoredConversationIds[TGTelegraphInstance.clientUserId].find(conversationId) != _ignoredConversationIds[TGTelegraphInstance.clientUserId].end();
}

+ (void)removeIgnoreConversationId:(int64_t)conversationId
{
    _ignoredConversationIds[TGTelegraphInstance.clientUserId].erase(conversationId);
}

+ (TGWebPageMediaAttachment *)webPageWithId:(int64_t)webPageId
{
    OSSpinLockLock(&webPagesByIdLock);
    TGWebPageMediaAttachment *webPage = webPagesById()[@(webPageId)];
    OSSpinLockUnlock(&webPagesByIdLock);
    
    return webPage;
}

+ (TGWebPageMediaAttachment *)webPageWithLink:(NSString *)link
{
    if (link == nil)
        return nil;
    
    OSSpinLockLock(&webPagesByLinkLock);
    TGWebPageMediaAttachment *webPage = webPagesByLink()[link];
    OSSpinLockUnlock(&webPagesByLinkLock);
    
    return webPage;
}

+ (void)addWebPageWithLink:(NSString *)link webPage:(TGWebPageMediaAttachment *)webPage
{
    if (link != nil && webPage != nil)
    {
        OSSpinLockLock(&webPagesByLinkLock);
        webPagesByLink()[link] = webPage;
        OSSpinLockUnlock(&webPagesByLinkLock);
    }
}

+ (void)addWebPage:(TGWebPageMediaAttachment *)webPage
{
    if (webPage.webPageId != 0)
    {
        OSSpinLockLock(&webPagesByIdLock);
        webPagesById()[@(webPage.webPageId)] = webPage;
        OSSpinLockUnlock(&webPagesByIdLock);
        OSSpinLockLock(&webPagesByLinkLock);
        __block NSString *linkKey = nil;
        [webPagesByLink() enumerateKeysAndObjectsUsingBlock:^(NSString *link, TGWebPageMediaAttachment *currentWebPage, BOOL *stop) {
            if (currentWebPage.webPageId == webPage.webPageId) {
                linkKey = link;
                *stop = true;
            }
        }];
        if (linkKey != nil) {
            webPagesByLink()[linkKey] = webPage;
        }
        OSSpinLockUnlock(&webPagesByLinkLock);
    }
}

+ (SSignal *)webPageByTextRequest:(NSString *)text
{
    TLRPCmessages_getWebPagePreview$messages_getWebPagePreview *getWebPagePreview = [[TLRPCmessages_getWebPagePreview$messages_getWebPagePreview alloc] init];
    getWebPagePreview.message = text;
    return [[[TGTelegramNetworking instance] requestSignal:getWebPagePreview] mapToSignal:^SSignal *(TLMessageMedia *media)
    {
        TGWebPageMediaAttachment *webPage = nil;
        for (id attachment in [TGMessage parseTelegraphMedia:media mediaLifetime:nil])
        {
            if ([attachment isKindOfClass:[TGWebPageMediaAttachment class]])
            {
                webPage = attachment;
                break;
            }
        }
        
        return webPage == nil ? [SSignal fail:nil] : [SSignal single:webPage];
    }];
}

+ (SSignal *)requestWebPageByText:(NSString *)text
{
    SSignal *cacheSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGWebPageMediaAttachment *webPage = [self webPageWithLink:text];
        if (webPage != nil)
        {
            [subscriber putNext:webPage];
            [subscriber putCompletion];
        }
        else
            [subscriber putError:nil];
        
        return nil;
    }];
    
    return [cacheSignal catch:^SSignal *(__unused id error)
    {
        return [[self webPageByTextRequest:text] mapToSignal:^SSignal *(TGWebPageMediaAttachment *webPage)
        {
            if (webPage != nil)
            {
                if (webPage.url == nil && webPage.pendingDate == -1)
                    return [SSignal fail:nil];
                else if (webPage.url == nil)
                {
                    NSTimeInterval remoteTime = [[TGTelegramNetworking instance] globalTime];
                    NSTimeInterval delay = MAX(1.0, webPage.pendingDate - remoteTime);
                    
                    return [[SSignal single:webPage] then:[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
                    {
                        return addAwaitingWebPageListener(webPage.webPageId, ^(TGWebPageMediaAttachment *updatedWebPage)
                        {
                            if (updatedWebPage.url != nil)
                                [self addWebPageWithLink:text webPage:updatedWebPage];
                            
                            [subscriber putNext:updatedWebPage];
                            [subscriber putCompletion];
                        });
                    }] timeout:delay onQueue:[SQueue concurrentDefaultQueue] orSignal:[[self webPageByTextRequest:text] mapToSignal:^SSignal *(TGWebPageMediaAttachment *updatedWebPage)
                    {
                        if (updatedWebPage.url == nil)
                            return [SSignal complete];
                        else
                        {
                            [self addWebPageWithLink:text webPage:updatedWebPage];
                            
                            return [SSignal single:updatedWebPage];
                        }
                    }]]];
                }
                else
                {
                    [self addWebPageWithLink:text webPage:webPage];
                    return [SSignal single:webPage];
                }
            }
        
            return [SSignal fail:nil];
        }];
    }];
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)prepare:(NSDictionary *)__unused options
{
    self.requestQueueName = @"messages";
    
    [TGUpdateStateRequestBuilder invalidateStateVersion];
    
    int state = 1;
    if ([[TGTelegramNetworking instance] isUpdating])
        state |= 1;
    if ([[TGTelegramNetworking instance] isConnecting])
        state |= 2;
    if (![[TGTelegramNetworking instance] isNetworkAvailable])
        state |= 4;
    
    [ActionStageInstance() dispatchResource:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:state]]];
    
    [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(other)" options:nil watcher:TGTelegraphInstance];
}

- (void)execute:(NSDictionary *)__unused options
{
    TGDatabaseState state = [[TGDatabase instance] databaseState];
/*#ifdef DEBUG
    if (state.pts == 0)
    {
        state.pts = 1;
        state.seq = 1;
        state.date = 1;
        state.qts = 0;
        
        [TGDatabaseInstance() applyPts:state.pts date:state.date seq:state.seq qts:state.qts unreadCount:0];
    }
#endif*/
    if (state.pts != 0)
    {
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(bypass)" options:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:true], @"bypassQueue", nil] watcher:self];
    }
    else
    {
        self.cancelToken = [TGTelegraphInstance doRequestState:self];
    }
}

- (void)actorCompleted:(int)__unused resultCode path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/tg/service/synchronizeactionqueue"])
    {
        TGDatabaseState state = [[TGDatabase instance] databaseState];
        int32_t date = state.date;
        TGLog(@"requesting difference with pts: %d, seq: %d, date: %d, qts %d", state.pts, state.seq, date, state.qts);
        self.cancelToken = [TGTelegraphInstance doRequestStateDelta:state.pts date:date qts:state.qts requestBuilder:self];
        
        _synchronizeActionQueueActor = nil;
    }
    else if ([path hasPrefix:@"/tg/dialoglist"])
    {
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%d,cached)", INT_MAX - 1] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:INT_MAX - 1] forKey:@"peerId"] watcher:TGTelegraphInstance];
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%d,cached)", INT_MAX - 2] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:INT_MAX - 2] forKey:@"peerId"] watcher:TGTelegraphInstance];
        
        NSMutableArray *dialogList = [((SGraphListNode *)result).items mutableCopy];
        [dialogList sortUsingComparator:^NSComparisonResult(TGConversation *conversation1, TGConversation *conversation2)
        {
            int date1 = conversation1.date;
            int date2 = conversation2.date;
            
            if (date1 > date2)
                return NSOrderedAscending;
            else if (date1 < date2)
                return NSOrderedDescending;
            else
                return NSOrderedSame;
        }];
        
        const int maxDialogs = 50;
        if (dialogList.count > maxDialogs)
            [dialogList removeObjectsInRange:NSMakeRange(maxDialogs, dialogList.count - maxDialogs)];
        
        int connectionState = 0;
        if ([[TGTelegramNetworking instance] isUpdating])
            connectionState |= 1;
        if ([[TGTelegramNetworking instance] isConnecting])
            connectionState |= 2;
        if (![[TGTelegramNetworking instance] isNetworkAvailable])
            connectionState |= 4;
        
        [ActionStageInstance() dispatchResource:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:connectionState]]];
        
        TLupdates_State *state = _state;
        
        [[[TGApplyStateRequestBuilder alloc] initWithPath:[NSString stringWithFormat:@"/tg/service/applystate/(%d,%d,%d,%d,%d)", state.pts, state.date, state.seq, state.qts, state.unread_count]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:state.pts], @"pts", [NSNumber numberWithInt:state.date], @"date", [NSNumber numberWithInt:state.seq], @"seq", @(state.qts), @"qts", [NSNumber numberWithInt:state.unread_count], @"unreadCount", nil]];
        
        [ActionStageInstance() dispatchResource:path resource:[[SGraphListNode alloc] initWithItems:dialogList]];
        
        [self completeDifferenceUpdate:true];
        
        [ActionStageInstance() dispatchResource:@"/tg/service/stateUpdated" resource:nil];
        
        [TGDatabaseInstance() readDeactivatedConversations];
        
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
    }
}

+ (void)updateNotifiedVersionUpdate
{
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *versionKey = [[NSString alloc] initWithFormat:@"NotifiedVersionUpdate_%@", currentVersion];
    [[NSUserDefaults standardUserDefaults] setObject:@true forKey:versionKey];
}

- (void)completeDifferenceUpdate:(bool)initial
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *versionKey = [[NSString alloc] initWithFormat:@"NotifiedVersionUpdate_%@", currentVersion];
#ifdef DEBUG
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:versionKey];
#endif
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:versionKey] boolValue]) {
            NSString *previousVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"UpdateChangelog_PreviousVersion"];
            if (previousVersion == nil) {
                previousVersion = @"3.16";
            }
            
            bool skipUpdate = initial;
#ifdef DEBUG
#elif defined(INTERNAL_RELEASE)
            skipUpdate = true;
#endif
            if (skipUpdate) {
                [[NSUserDefaults standardUserDefaults] setObject:@true forKey:versionKey];
            } else {
                [TGTelegraphInstance.disposeOnLogout add:[[TGServiceSignals appChangelogMessages:previousVersion] startWithNext:^(NSArray *updates) {
                    [ActionStageInstance() dispatchOnStageQueue:^{
                        NSMutableArray *messages = [[NSMutableArray alloc] init];
                        for (id update in updates) {
                            if ([update isKindOfClass:[TLUpdate$updateServiceNotificationMeta class]])
                            {
                                TLUpdate$updateServiceNotificationMeta *updateServiceNotification = (TLUpdate$updateServiceNotificationMeta *)update;
                                if (updateServiceNotification.flags & (1 << 0))
                                {
                                    TGDispatchOnMainThread(^
                                    {
                                        [TGAlertView presentAlertWithTitle:@"" message:updateServiceNotification.message cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                    });
                                }
                                else if (updateServiceNotification.inbox_date != 0)
                                {
                                    int uid = [TGTelegraphInstance createServiceUserIfNeeded];
                                    
                                    TGMessage *message = [[TGMessage alloc] init];
                                    message.mid = [[[TGDatabaseInstance() generateLocalMids:1] objectAtIndex:0] intValue];
                                    
                                    message.fromUid = uid;
                                    message.toUid = TGTelegraphInstance.clientUserId;
                                    message.date = updateServiceNotification.inbox_date;
                                    message.outgoing = false;
                                    message.cid = uid;
                                    
                                    TGUser *selfUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
                                    
                                    NSString *displayName = selfUser.firstName;
                                    if (displayName.length == 0)
                                        displayName = selfUser.lastName;
                                    
                                    message.text = updateServiceNotification.message;
                                    
                                    NSMutableArray *mediaAttachments = [[NSMutableArray alloc] init];
                                    
                                    if (updateServiceNotification.entities.count != 0) {
                                        NSArray *entities = [TGMessage parseTelegraphEntities:updateServiceNotification.entities];
                                        if (entities.count != 0) {
                                            TGMessageEntitiesAttachment *attachment = [[TGMessageEntitiesAttachment alloc] init];
                                            attachment.entities = entities;
                                            [mediaAttachments addObject:attachment];
                                        }
                                    }
                                    
                                    if (updateServiceNotification.media != nil) {
                                        NSArray *medias = [TGMessage parseTelegraphMedia:updateServiceNotification.media mediaLifetime:nil];
                                        if (medias.count != 0) {
                                            [mediaAttachments addObjectsFromArray:medias];
                                        }
                                    }
                                    
                                    message.mediaAttachments = mediaAttachments;
                                    
                                    [messages addObject:message];
                                }
                            }
                        }
                        
                        if (messages.count != 0) {
                            [TGDatabaseInstance() transactionAddMessages:messages updateConversationDatas:nil notifyAdded:true];
                        }
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@true forKey:versionKey];
                        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"UpdateChangelog_PreviousVersion"];
                    }];
                }]];
            }
        }
    });
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
    
    if (_initialUpdatesScheduled)
    {
        _initialUpdatesScheduled = false;
     
        [[TGTelegramNetworking instance] performDeferredServiceTasks];
        
        [ActionStageInstance() requestActor:@"/tg/service/settings/push/(subscribe)" options:nil watcher:TGTelegraphInstance];
        
        [ActionStageInstance() requestActor:@"/tg/service/updateConfig/(background)" options:nil flags:0 watcher:TGTelegraphInstance];
        
        [TGTelegraphInstance.disposeOnLogout add:[[TGCallSignals serverCallsConfig] startWithNext:^(NSString *next) {
            [TGCallSession applyCallsConfig:next];
        }]];
    }
    
    [TGTelegraphInstance updatePresenceNow];
    
    [[[TGTelegramNetworking instance] mtProto] requestTimeResync];
    
    [TGDatabaseInstance() customProperty:@"polledPinnedConversations" completion:^(NSData *value) {
        if (value == nil) {
            [TGGroupManagementSignals beginPullPinnedConversations];
        }
    }];
}

+ (void)applyUpdates:(NSArray *)addedMessagesDesc otherUpdates:(NSArray *)otherUpdates usersDesc:(NSArray *)usersDesc chatsDesc:(NSArray *)chatsDesc chatParticipantsDesc:(NSArray *)chatParticipantsDesc updatesWithDates:(NSArray *)updatesWithDates addedEncryptedActionsByPeerId:(NSDictionary *)addedEncryptedActionsByPeerId addedEncryptedUnparsedActionsByPeerId:(NSDictionary *)addedEncryptedUnparsedActionsByPeerId completion:(void (^)(bool))completion
{
#ifdef DEBUG
    if (addedMessagesDesc.count != 0)
        TGLog(@"addedMessages: %d", (int)addedMessagesDesc.count);
    if (otherUpdates.count != 0)
        TGLog(@"%@", otherUpdates);
    if (updatesWithDates.count != 0)
        TGLog(@"%@", updatesWithDates);
    if (addedEncryptedActionsByPeerId.count != 0)
        TGLog(@"%d", (int)addedEncryptedActionsByPeerId.count);
    if (addedEncryptedUnparsedActionsByPeerId.count != 0)
        TGLog(@"%d", (int)addedEncryptedUnparsedActionsByPeerId.count);
#endif
    
    static Class updateDeleteMessagesClass = [TLUpdate$updateDeleteMessages class];
    static Class updateContactLinkClass = [TLUpdate$updateContactLink class];
    static Class updateActivationClass = [TLUpdate$updateActivation class];
    static Class updateContactRegisteredClass = [TLUpdate$updateContactRegistered class];
    static Class updateUserTypingClass = [TLUpdate$updateUserTyping class];
    static Class updateChatUserTypingClass = [TLUpdate$updateChatUserTyping class];
    static Class updateUserStatusClass = [TLUpdate$updateUserStatus class];
    static Class updateUserPhotoClass = [TLUpdate$updateUserPhoto class];
    static Class updateUserNameClass = [TLUpdate$updateUserName class];
    static Class updateChatParticipantsClass = [TLUpdate$updateChatParticipants class];
    static Class updateChatParticipantAddClass = [TLUpdate$updateChatParticipantAdd class];
    static Class updateChatParticipantDeleteClass = [TLUpdate$updateChatParticipantDelete class];
    static Class updateMessageIdClass = [TLUpdate$updateMessageID class];
    static Class updateEncryptedChatTypingClass = [TLUpdate$updateEncryptedChatTyping class];
    static Class updateEncryptedMessagesReadClass = [TLUpdate$updateEncryptedMessagesRead class];
    
    [TGUserDataRequestBuilder executeUserDataUpdate:usersDesc];
    
    NSMutableDictionary *chatItems = [[NSMutableDictionary alloc] init];
    for (TLChat *chatDesc in chatsDesc)
    {
        TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
        if (conversation.conversationId != 0)
        {
            [chatItems setObject:conversation forKey:[NSNumber numberWithLongLong:conversation.conversationId]];
        }
    }
    
    NSMutableArray *addedMessages = [[NSMutableArray alloc] init];
    NSMutableArray *editedMessages = [[NSMutableArray alloc] init];
    NSMutableDictionary *updatedEncryptedChats = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSNumber *, TGDatabaseMessageDraft *> *updatePeerDrafts = [[NSMutableDictionary alloc] init];
    
    std::set<int64_t> &ignoredConversationsForCurrentUser = _ignoredConversationIds[TGTelegraphInstance.clientUserId];
    
    std::map<int64_t, int64_t> cachedPeerIds;
    std::map<int64_t, std::pair<int64_t, NSData *> > cachedKeys;
    std::map<int64_t, int32_t> cachedParticipantIds;
    
    std::map<int64_t, int32_t> maxInboxReadMessageIdByPeerId;
    std::map<int64_t, int32_t> maxOutboxReadMessageIdByPeerId;
    std::set<int> deleteMessageIds;
    std::map<int64_t, std::pair<int32_t, int32_t> > maxReadDateInEncryptedConversation;
    std::set<int> readContentsMessageIds;
    
    std::set<int64_t> addingRandomIds;
    
    std::vector<std::pair<int64_t, int> > messageIdUpdates;
    NSMutableArray *filteredMessageIdUpdates = [[NSMutableArray alloc] init];
    
    std::set<int64_t> acceptEncryptedChats;
    std::set<int64_t> updatePeerLayers;
    
    std::map<int, std::vector<id> > chatParticipantUpdateArrays;
    
    NSMutableArray *userPhotoUpdates = nil;
    
    NSMutableArray *userTypingUpdates = [[NSMutableArray alloc] init];
    
    bool dispatchBlocked = false;
    
    NSMutableDictionary *encryptedActionsByPeerId = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *encryptedUnparsedActionsByPeerId = [[NSMutableDictionary alloc] init];
    if (addedEncryptedActionsByPeerId != nil)
        [encryptedActionsByPeerId addEntriesFromDictionary:addedEncryptedActionsByPeerId];
    if (addedEncryptedUnparsedActionsByPeerId != nil)
        [encryptedUnparsedActionsByPeerId addEntriesFromDictionary:addedEncryptedUnparsedActionsByPeerId];
    
    NSMutableDictionary *channelUpdatesByPeerId = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *messageViewsUpdatesByPeerId = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *updatedWebpages = [[NSMutableArray alloc] init];
    
    __block bool requestPinnedDialogs = false;
    NSMutableDictionary *updatedPinnedDialogs = [[NSMutableDictionary alloc] init];
    NSMutableArray *updatedPinnedDialogsKeyOrder = [[NSMutableArray alloc] init];
    NSArray *replacedPinnedDialogs = nil;
    
    for (TLUpdate *update in otherUpdates)
    {
        if ([update respondsToSelector:@selector(pts)] && [update respondsToSelector:@selector(pts_count)]) {
            TGLog(@"update: %@, pts: %d, ptsCount: %d", update, [(TLUpdate$updateNewMessage *)update pts], [(TLUpdate$updateNewMessage *)update pts_count]);
        } else {
            TGLog(@"update: %@", update);
        }
        if ([update isKindOfClass:[TLUpdate$updateReadHistoryInbox class]])
        {
            TLUpdate$updateReadHistoryInbox *concreteUpdate = (TLUpdate$updateReadHistoryInbox *)update;
            
            int64_t peerId = 0;
            if ([concreteUpdate.peer isKindOfClass:[TLPeer$peerUser class]])
                peerId = ((TLPeer$peerUser *)concreteUpdate.peer).user_id;
            else if ([concreteUpdate.peer isKindOfClass:[TLPeer$peerChat class]])
                peerId = -((TLPeer$peerChat *)concreteUpdate.peer).chat_id;
            
            TGLog(@"updateReadHistoryInbox peerId: %lld, max_id: %d", peerId, concreteUpdate.max_id);
            
            auto it = maxInboxReadMessageIdByPeerId.find(peerId);
            if (it == maxInboxReadMessageIdByPeerId.end())
                maxInboxReadMessageIdByPeerId[peerId] = concreteUpdate.max_id;
            else
                maxInboxReadMessageIdByPeerId[peerId] = MAX(it->second, concreteUpdate.max_id);
        }
        else if ([update isKindOfClass:[TLUpdate$updateReadHistoryOutbox class]])
        {
            TLUpdate$updateReadHistoryOutbox *concreteUpdate = (TLUpdate$updateReadHistoryOutbox *)update;
            
            int64_t peerId = 0;
            if ([concreteUpdate.peer isKindOfClass:[TLPeer$peerUser class]])
                peerId = ((TLPeer$peerUser *)concreteUpdate.peer).user_id;
            else if ([concreteUpdate.peer isKindOfClass:[TLPeer$peerChat class]])
                peerId = -((TLPeer$peerChat *)concreteUpdate.peer).chat_id;
            
            auto it = maxOutboxReadMessageIdByPeerId.find(peerId);
            if (it == maxOutboxReadMessageIdByPeerId.end())
                maxOutboxReadMessageIdByPeerId[peerId] = concreteUpdate.max_id;
            else
                maxOutboxReadMessageIdByPeerId[peerId] = MAX(it->second, concreteUpdate.max_id);
        }
        else if ([update isKindOfClass:updateEncryptedMessagesReadClass])
        {
            TLUpdate$updateEncryptedMessagesRead *concreteUpdate = (TLUpdate$updateEncryptedMessagesRead *)update;
            
            int64_t peerId = [TGDatabaseInstance() peerIdForEncryptedConversationId:concreteUpdate.chat_id createIfNecessary:false];
            
            if (maxReadDateInEncryptedConversation[peerId].first < concreteUpdate.max_date)
            {
                maxReadDateInEncryptedConversation[peerId].first = concreteUpdate.max_date;
                maxReadDateInEncryptedConversation[peerId].second = concreteUpdate.date;
            }
        }
        else if ([update isKindOfClass:updateDeleteMessagesClass])
        {
            TLUpdate$updateDeleteMessages *deleteMessages = (TLUpdate$updateDeleteMessages *)update;
            
            for (NSNumber *nMid in deleteMessages.messages)
            {
                deleteMessageIds.insert([nMid intValue]);
            }
        }
        else if ([update isKindOfClass:updateMessageIdClass])
        {
            TLUpdate$updateMessageID *updateMessageId = (TLUpdate$updateMessageID *)update;
            
            messageIdUpdates.push_back(std::pair<int64_t, int>(updateMessageId.random_id, updateMessageId.n_id));
            [filteredMessageIdUpdates addObject:update];
        }
        else if ([update isKindOfClass:[TLUpdate$updateEditMessage class]]) {
            TLUpdate$updateEditMessage *updateEditMessage = (TLUpdate$updateEditMessage *)update;
            TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:updateEditMessage.message];
            if (message.mid != 0) {
                [editedMessages addObject:message];
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateNewChannelMessage class]])
        {
            TLUpdate$updateNewChannelMessage *channelMessage = (TLUpdate$updateNewChannelMessage *)update;
            TLPeer *toId = nil;
            if ([channelMessage.message isKindOfClass:[TLMessage$modernMessage class]]) {
                toId = ((TLMessage$modernMessage *)channelMessage.message).to_id;
            } else if ([channelMessage.message isKindOfClass:[TLMessage$modernMessageService class]]) {
                toId = ((TLMessage$modernMessageService *)channelMessage.message).to_id;
            }
            
            if ([toId isKindOfClass:[TLPeer$peerChannel class]]) {
                int64_t peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)toId).channel_id);
                NSMutableArray *channelUpdates = channelUpdatesByPeerId[@(peerId)];
                if (channelUpdates == nil) {
                    channelUpdates = [[NSMutableArray alloc] init];
                    channelUpdatesByPeerId[@(peerId)] = channelUpdates;
                }
                [channelUpdates addObject:update];
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateChannelTooLong class]]) {
            TLUpdate$updateChannelTooLong *channelTooLong = (TLUpdate$updateChannelTooLong *)update;
            int64_t peerId = TGPeerIdFromChannelId(channelTooLong.channel_id);
            NSMutableArray *channelUpdates = channelUpdatesByPeerId[@(peerId)];
            if (channelUpdates == nil) {
                channelUpdates = [[NSMutableArray alloc] init];
                channelUpdatesByPeerId[@(peerId)] = channelUpdates;
            }
            [channelUpdates addObject:update];
        }
        else if ([update isKindOfClass:[TLUpdate$updateEditChannelMessage class]]) {
            TLUpdate$updateEditChannelMessage *editMessage = ((TLUpdate$updateEditChannelMessage *)update);
            TLPeer *toId = nil;
            if ([editMessage.message isKindOfClass:[TLMessage$modernMessage class]]) {
                toId = ((TLMessage$modernMessage *)editMessage.message).to_id;
            } else if ([editMessage.message isKindOfClass:[TLMessage$modernMessageService class]]) {
                toId = ((TLMessage$modernMessageService *)editMessage.message).to_id;
            }
            
            if ([toId isKindOfClass:[TLPeer$peerChannel class]]) {
                int64_t peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)toId).channel_id);
                NSMutableArray *channelUpdates = channelUpdatesByPeerId[@(peerId)];
                if (channelUpdates == nil) {
                    channelUpdates = [[NSMutableArray alloc] init];
                    channelUpdatesByPeerId[@(peerId)] = channelUpdates;
                }
                [channelUpdates addObject:update];
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]])
        {
            TLUpdate$updateDeleteChannelMessages *deleteChannelMessages = (TLUpdate$updateDeleteChannelMessages *)update;
            int64_t peerId = TGPeerIdFromChannelId(deleteChannelMessages.channel_id);
            NSMutableArray *channelUpdates = channelUpdatesByPeerId[@(peerId)];
            if (channelUpdates == nil) {
                channelUpdates = [[NSMutableArray alloc] init];
                channelUpdatesByPeerId[@(peerId)] = channelUpdates;
            }
            [channelUpdates addObject:update];
        }
        else if ([update isKindOfClass:[TLUpdate$updateReadChannelInbox class]]) {
            TLUpdate$updateReadChannelInbox *readChannelInbox = (TLUpdate$updateReadChannelInbox *)update;
            int64_t peerId = TGPeerIdFromChannelId(readChannelInbox.channel_id);
            NSMutableArray *channelUpdates = channelUpdatesByPeerId[@(peerId)];
            if (channelUpdates == nil) {
                channelUpdates = [[NSMutableArray alloc] init];
                channelUpdatesByPeerId[@(peerId)] = channelUpdates;
            }
            [channelUpdates addObject:update];
        }
        else if ([update isKindOfClass:[TLUpdate$updateReadChannelOutbox class]]) {
            TLUpdate$updateReadChannelOutbox *readChannelOutbox = (TLUpdate$updateReadChannelOutbox *)update;
            int64_t peerId = TGPeerIdFromChannelId(readChannelOutbox.channel_id);
            NSMutableArray *channelUpdates = channelUpdatesByPeerId[@(peerId)];
            if (channelUpdates == nil) {
                channelUpdates = [[NSMutableArray alloc] init];
                channelUpdatesByPeerId[@(peerId)] = channelUpdates;
            }
            [channelUpdates addObject:update];
        }
        else if ([update isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]])
        {
            TLUpdate$updateDeleteChannelMessages *deleteChannelMessages = (TLUpdate$updateDeleteChannelMessages *)update;
            int64_t peerId = TGPeerIdFromChannelId(deleteChannelMessages.channel_id);
            NSMutableArray *channelUpdates = channelUpdatesByPeerId[@(peerId)];
            if (channelUpdates == nil) {
                channelUpdates = [[NSMutableArray alloc] init];
                channelUpdatesByPeerId[@(peerId)] = channelUpdates;
            }
            [channelUpdates addObject:update];
        }
        else if ([update isKindOfClass:[TLUpdate$updateChannelWebPage class]]) {
            TLUpdate$updateChannelWebPage *updateWebPage = (TLUpdate$updateChannelWebPage *)update;
            TGWebPageMediaAttachment *webPage = [[TGWebPageMediaAttachment alloc] initWithTelegraphWebPageDesc:updateWebPage.webpage];
            
            int64_t peerId = TGPeerIdFromChannelId(updateWebPage.channel_id);
            NSMutableArray *channelUpdates = channelUpdatesByPeerId[@(peerId)];
            if (channelUpdates == nil) {
                channelUpdates = [[NSMutableArray alloc] init];
                channelUpdatesByPeerId[@(peerId)] = channelUpdates;
            }
            [channelUpdates addObject:update];
            
            [updatedWebpages addObject:webPage];
        }
        else if ([update isKindOfClass:[TLUpdate$updateChannelPinnedMessage class]]) {
            TLUpdate$updateChannelPinnedMessage *pinnedMessage = (TLUpdate$updateChannelPinnedMessage *)update;
            int64_t peerId = TGPeerIdFromChannelId(pinnedMessage.channel_id);
            NSMutableArray *channelUpdates = channelUpdatesByPeerId[@(peerId)];
            if (channelUpdates == nil) {
                channelUpdates = [[NSMutableArray alloc] init];
                channelUpdatesByPeerId[@(peerId)] = channelUpdates;
            }
            [channelUpdates addObject:update];
        }
        else if ([update isKindOfClass:[TLUpdate$updateChannelMessageViews class]]) {
            TLUpdate$updateChannelMessageViews *updateViews = (TLUpdate$updateChannelMessageViews *)update;
            int64_t peerId = TGPeerIdFromChannelId(updateViews.channel_id);
            
            NSMutableDictionary *messageViews = messageViewsUpdatesByPeerId[@(peerId)];
            if (messageViews == nil) {
                messageViews = [[NSMutableDictionary alloc] init];
                messageViewsUpdatesByPeerId[@(peerId)] = messageViews;
            }
            
            messageViews[@(updateViews.n_id)] = @(updateViews.views);
        }
        else if ([update isKindOfClass:updateChatParticipantsClass])
        {
            TLUpdate$updateChatParticipants *updateChatParticipants = (TLUpdate$updateChatParticipants *)update;
            
            chatParticipantUpdateArrays[updateChatParticipants.participants.chat_id].push_back(updateChatParticipants.participants);
        }
        else if ([update isKindOfClass:updateChatParticipantAddClass])
        {
            TLUpdate$updateChatParticipantAdd *updateChatParticipantAdd = (TLUpdate$updateChatParticipantAdd *)update;
            chatParticipantUpdateArrays[updateChatParticipantAdd.chat_id].push_back(update);
        }
        else if ([update isKindOfClass:updateChatParticipantDeleteClass])
        {
            TLUpdate$updateChatParticipantDelete *updateChatParticipantDelete = (TLUpdate$updateChatParticipantDelete *)update;
            chatParticipantUpdateArrays[updateChatParticipantDelete.chat_id].push_back(update);
        }
        else if ([update isKindOfClass:[TLUpdate$updateChatParticipantAdmin class]]) {
            TLUpdate$updateChatParticipantAdmin *concreteUpdate = (TLUpdate$updateChatParticipantAdmin *)update;
            chatParticipantUpdateArrays[concreteUpdate.chat_id].push_back(update);
        }
        else if ([update isKindOfClass:[TLUpdate$updateChatAdmins class]]) {
            TLUpdate$updateChatAdmins *concreteUpdate = (TLUpdate$updateChatAdmins *)update;
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:TGPeerIdFromGroupId(concreteUpdate.chat_id)];
            if (conversation != nil && conversation.chatParticipants.version < concreteUpdate.version) {
                conversation.hasAdmins = concreteUpdate.enabled;
                chatItems[@(conversation.conversationId)] = conversation;
            }
        }
        else if ([update isKindOfClass:updateContactLinkClass])
        {
            TLUpdate$updateContactLink *contactLinkUpdate = (TLUpdate$updateContactLink *)update;
            
            if (contactLinkUpdate.user_id != 0)
            {   
                int userLink = extractUserLinkFromUpdate(contactLinkUpdate);
                [TGUserDataRequestBuilder executeUserLinkUpdates:[[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:contactLinkUpdate.user_id], [[NSNumber alloc] initWithInt:userLink], nil], nil]];
            }
        }
        else if ([update isKindOfClass:updateActivationClass])
        {
            TGTelegraphInstance.clientIsActivated = true;
            [TGAppDelegateInstance saveSettings];
            
            [ActionStageInstance() dispatchResource:@"/tg/activation" resource:[[SGraphObjectNode alloc] initWithObject:[[NSNumber alloc] initWithBool:true]]];
        }
        else if ([update isKindOfClass:updateContactRegisteredClass])
        {
            TLUpdate$updateContactRegistered *contactRegistered = (TLUpdate$updateContactRegistered *)update;
            
            if ([TGDatabaseInstance() messagesWithDateInConversation:contactRegistered.user_id date:contactRegistered.date].count == 0) {
                TGMessage *message = [[TGMessage alloc] init];
                message.mid = [[[TGDatabaseInstance() generateLocalMids:1] objectAtIndex:0] intValue];
                
                message.fromUid = contactRegistered.user_id;
                message.toUid = TGTelegraphInstance.clientUserId;
                message.date = contactRegistered.date;
                //message.unread = false;
                message.outgoing = false;
                message.cid = contactRegistered.user_id;
                
                TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
                actionAttachment.actionType = TGMessageActionContactRegistered;
                message.mediaAttachments = [[NSArray alloc] initWithObjects:actionAttachment, nil];
                
                [addedMessages addObject:message];
            }
        }
        else if ([update isKindOfClass:updateUserTypingClass])
        {
            [userTypingUpdates addObject:update];
        }
        else if ([update isKindOfClass:updateChatUserTypingClass])
        {
            [userTypingUpdates addObject:update];
        }
        else if ([update isKindOfClass:updateEncryptedChatTypingClass])
        {
            [userTypingUpdates addObject:update];
        }
        else if ([update isKindOfClass:updateUserStatusClass])
        {
            TLUpdate$updateUserStatus *userStatus = (TLUpdate$updateUserStatus *)update;
            
            TGUserPresence presence = extractUserPresence(userStatus.status);
            TGLog(@"(updateUserStatus user %d status (online: %d, lastSeen: %d))", (int)userStatus.user_id, presence.online ? 1 : 0, (int)presence.lastSeen);
            
            [TGTelegraphInstance dispatchUserPresenceChanges:userStatus.user_id presence:presence];
        }
        else if ([update isKindOfClass:updateUserPhotoClass])
        {
            TLUpdate$updateUserPhoto *photoUpdate = (TLUpdate$updateUserPhoto *)update;
            
            TGUser *originalUser = [[TGDatabase instance] loadUser:photoUpdate.user_id];
            if (originalUser != nil)
            {
                TGUser *user = [originalUser copy];
                TLUserProfilePhoto *photo = photoUpdate.photo;
                if ([photo isKindOfClass:[TLUserProfilePhoto$userProfilePhoto class]])
                {
                    extractUserPhoto(photo, user);
                }
                else
                {
                    user.photoUrlBig = nil;
                    user.photoUrlMedium = nil;
                    user.photoUrlSmall = nil;
                }
                
                if (!photoUpdate.previous)
                {
                    if (userPhotoUpdates == nil)
                        userPhotoUpdates = [[NSMutableArray alloc] init];
                    
                    [userPhotoUpdates addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:user.uid], @"uid", photo, @"photo", [[NSNumber alloc] initWithInt:photoUpdate.date], @"date", nil]];
                }
                
                [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:user]];
            }
        }
        else if ([update isKindOfClass:updateUserNameClass])
        {
            TLUpdate$updateUserName *userNameUpdate = (TLUpdate$updateUserName *)update;
            
            TGUser *originalUser = [[TGDatabase instance] loadUser:userNameUpdate.user_id];
            if (originalUser != nil)
            {
                TGUser *user = [originalUser copy];
                
                user.firstName = userNameUpdate.first_name;
                user.lastName = userNameUpdate.last_name;
                user.userName = userNameUpdate.username;
                
                if (![user isEqualToUser:originalUser])
                {
                    [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:user]];
                }
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateUserPhone class]])
        {
            TLUpdate$updateUserPhone *userPhoneUpdate = (TLUpdate$updateUserPhone *)update;
            
            TGUser *originalUser = [[TGDatabase instance] loadUser:userPhoneUpdate.user_id];
            if (originalUser != nil)
            {
                TGUser *user = [originalUser copy];
                
                NSString *phoneNumber = userPhoneUpdate.phone;
                if (phoneNumber.length != 0 && ![phoneNumber hasPrefix:@"+"])
                    phoneNumber = [@"+" stringByAppendingString:phoneNumber];
                user.phoneNumber = phoneNumber;
                
                if (![user isEqualToUser:originalUser])
                {
                    [TGUserDataRequestBuilder executeUserObjectsUpdate:[NSArray arrayWithObject:user]];
                }
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateEncryption class]])
        {
            TLUpdate$updateEncryption *updateEncryption = (TLUpdate$updateEncryption *)update;
            
            TGConversation *conversation = nil;
            conversation = [[TGConversation alloc] initWithTelegraphEncryptedChatDesc:updateEncryption.chat];
            if (conversation != nil)
            {
                conversation.messageDate = updateEncryption.date;
                
                if ([updateEncryption.chat isKindOfClass:[TLEncryptedChat$encryptedChatWaiting class]])
                {
                }
                else if ([updateEncryption.chat isKindOfClass:[TLEncryptedChat$encryptedChatRequested class]])
                {
                    updatedEncryptedChats[@(conversation.conversationId)] = conversation;
                    
                    TLEncryptedChat$encryptedChatRequested *concreteChat = (TLEncryptedChat$encryptedChatRequested *)updateEncryption.chat;

                    conversation.encryptedData.handshakeState = 2;
                    
                    [TGDatabaseInstance() setConversationCustomProperty:conversation.conversationId name:murMurHash32(@"a") value:concreteChat.g_a];
                    
                    acceptEncryptedChats.insert(concreteChat.n_id);
                    updatePeerLayers.insert(conversation.conversationId);
                }
                else if ([updateEncryption.chat isKindOfClass:[TLEncryptedChat$encryptedChat class]])
                {
                    if ([TGDatabaseInstance() loadConversationWithId:conversation.conversationId].encryptedData.handshakeState != 4)
                    {
                        updatedEncryptedChats[@(conversation.conversationId)] = conversation;
                        updatePeerLayers.insert(conversation.conversationId);
                        
                        TLEncryptedChat$encryptedChat *concreteChat = (TLEncryptedChat$encryptedChat *)updateEncryption.chat;
                        NSData *aBytes = [TGDatabaseInstance() conversationCustomPropertySync:conversation.conversationId name:murMurHash32(@"a")];
                        
                        TLmessages_DhConfig$messages_dhConfig *config = [TGRequestEncryptedChatActor cachedEncryptionConfig];
                        
                        NSMutableData *key = [MTExp(concreteChat.g_a_or_b, aBytes, config.p) mutableCopy];
                        
                        if (key.length > 256)
                            [key replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
                        while (key.length < 256)
                        {
                            uint8_t zero = 0;
                            [key replaceBytesInRange:NSMakeRange(0, 0) withBytes:&zero length:1];
                            TGLog(@"(adding key padding)");
                        }
                        
                        NSData *keyHash = MTSha1(key);
                        NSData *nKeyId = [[NSData alloc] initWithBytes:(((uint8_t *)keyHash.bytes) + keyHash.length - 8) length:8];
                        int64_t keyId = 0;
                        [nKeyId getBytes:&keyId length:8];
                        
                        if (keyId == concreteChat.key_fingerprint)
                        {
                            conversation.encryptedData.handshakeState = 4;
                            
                            [TGDatabaseInstance() storeEncryptionKeyForConversationId:conversation.conversationId key:key keyFingerprint:keyId firstSeqOut:0];
                            
                            conversation.encryptedData.keyFingerprint = keyId;
                        }
                        else
                        {
                            conversation.encryptedData.handshakeState = 3;
                            
                            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/encrypted/discardEncryptedChat/(%" PRId64 ")", (int64_t)concreteChat.n_id] options:@{@"encryptedConversationId": @((int64_t)concreteChat.n_id)} flags:0 watcher:TGTelegraphInstance];
                        }
                    }
                }
                else if ([updateEncryption.chat isKindOfClass:[TLEncryptedChat$encryptedChatDiscarded class]])
                {
                    if ([TGDatabaseInstance() loadConversationWithId:conversation.conversationId] != nil)
                    {
                        updatedEncryptedChats[@(conversation.conversationId)] = conversation;
                        
                        conversation.encryptedData.handshakeState = 3;
                    }
                    else
                        TGLog(@"***** ignoring discarded encryption in chat %lld", updateEncryption.chat.n_id);
                }
                else if ([updateEncryption.chat isKindOfClass:[TLEncryptedChat$encryptedChatEmpty class]])
                {
                    TGLog(@"***** empty chat %lld in updateEncryption", updateEncryption.chat.n_id);
                }
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateNewEncryptedMessage class]])
        {
            TLEncryptedMessage *encryptedMessage = ((TLUpdate$updateNewEncryptedMessage *)update).message;
            
            int64_t conversationId = 0;
            int64_t keyId = 0;
            int32_t seqIn = 0;
            int32_t seqOut = 0;
            NSUInteger decryptedLayer = 1;
            NSData *decryptedMessageData = [TGUpdateStateRequestBuilder decryptEncryptedMessageData:encryptedMessage decryptedLayer:&decryptedLayer cachedPeerIds:&cachedPeerIds cachedParticipantIds:&cachedParticipantIds outConversationId:&conversationId outKeyId:&keyId outSeqIn:&seqIn outSeqOut:&seqOut];
            TGStoredIncomingMessageFileInfo *fileInfo = nil;
            if ([encryptedMessage isKindOfClass:[TLEncryptedMessage$encryptedMessage class]])
            {
                id encryptedFile = ((TLEncryptedMessage$encryptedMessage *)encryptedMessage).file;
                if ([encryptedFile isKindOfClass:[TLEncryptedFile$encryptedFile class]])
                {
                    TLEncryptedFile$encryptedFile *concreteFile = encryptedFile;
                    fileInfo = [[TGStoredIncomingMessageFileInfo alloc] initWithId:concreteFile.n_id accessHash:concreteFile.access_hash size:concreteFile.size datacenterId:concreteFile.dc_id keyFingerprint:concreteFile.key_fingerprint];
                }
            }
            if (decryptedMessageData != nil)
            {
                NSMutableArray *encryptedActions = encryptedActionsByPeerId[@(conversationId)];
                if (encryptedActions == nil)
                {
                    encryptedActions = [[NSMutableArray alloc] init];
                    encryptedActionsByPeerId[@(conversationId)] = encryptedActions;
                }
                
                [encryptedActions addObject:[[TGStoredSecretIncomingActionWithSeq alloc] initWithAction:[[TGStoredIncomingMessageSecretAction alloc] initWithLayer:decryptedLayer data:decryptedMessageData date:encryptedMessage.date fileInfo:fileInfo] seqIn:seqIn seqOut:seqOut layer:decryptedLayer]];
            }
            else if (conversationId != 0)
            {
                NSMutableArray *encryptedUnparsedActions = encryptedUnparsedActionsByPeerId[@(conversationId)];
                if (encryptedUnparsedActions == nil)
                {
                    encryptedUnparsedActions = [[NSMutableArray alloc] init];
                    encryptedUnparsedActionsByPeerId[@(conversationId)] = encryptedUnparsedActions;
                }
                
                [encryptedUnparsedActions addObject:[[TGStoredIncomingEncryptedDataSecretAction alloc] initWithKeyId:keyId randomId:encryptedMessage.random_id chatId:encryptedMessage.chat_id date:encryptedMessage.date encryptedData:encryptedMessage.bytes fileInfo:fileInfo]];
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateDcOptions class]])
        {
            TLUpdate$updateDcOptions *datacenterOptionsUpdate = (TLUpdate$updateDcOptions *)update;
            
            for (TLDcOption$modernDcOption *datacenterOption in datacenterOptionsUpdate.dc_options)
            {
                if (datacenterOption.ip_address.length == 0)
                    continue;
                
                [[TGTelegramNetworking instance] mergeDatacenterAddress:datacenterOption.n_id address:[[MTDatacenterAddress alloc] initWithIp:datacenterOption.ip_address port:(uint16_t)(datacenterOption.port == 0 ? 443 : datacenterOption.port) preferForMedia:false restrictToTcp:datacenterOption.flags & (1 << 2) cdn:datacenterOption.flags & (1 << 3) preferForProxy:datacenterOption.flags & (1 << 4)]];
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateUserBlocked class]])
        {
            TLUpdate$updateUserBlocked *userBlocked = (TLUpdate$updateUserBlocked *)update;
            
            if ([TGDatabaseInstance() loadUser:userBlocked.user_id] != nil)
            {
                [TGDatabaseInstance() setPeerIsBlocked:userBlocked.user_id blocked:userBlocked.blocked writeToActionQueue:false];
                dispatchBlocked = true;
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateNotifySettings class]])
        {
            TLUpdate$updateNotifySettings *notifySettings = (TLUpdate$updateNotifySettings *)update;
            
            int64_t peerId = 0;
            if ([notifySettings.peer isKindOfClass:[TLNotifyPeer$notifyPeer class]])
            {
                TLNotifyPeer$notifyPeer *concretePeer = (TLNotifyPeer$notifyPeer *)notifySettings.peer;
                if ([concretePeer.peer isKindOfClass:[TLPeer$peerUser class]])
                    peerId = ((TLPeer$peerUser *)concretePeer.peer).user_id;
                else if ([concretePeer.peer isKindOfClass:[TLPeer$peerChat class]])
                    peerId = -((TLPeer$peerChat *)concretePeer.peer).chat_id;
                else if ([concretePeer.peer isKindOfClass:[TLPeer$peerChannel class]])
                    peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)concretePeer.peer).channel_id);
            }
            else if ([notifySettings.peer isKindOfClass:[TLNotifyPeer$notifyAll class]])
            {
            }
            else if ([notifySettings.peer isKindOfClass:[TLNotifyPeer$notifyChats class]])
                peerId = INT_MAX - 2;
            else if ([notifySettings.peer isKindOfClass:[TLNotifyPeer$notifyUsers class]])
                peerId = INT_MAX - 1;
            
            if (peerId != 0)
            {
                int peerSoundId = 0;
                int peerMuteUntil = 0;
                bool peerPreviewText = true;
                bool messagesMuted = false;
                
                if ([notifySettings.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                {
                    TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)notifySettings.notify_settings;
                    
                    peerMuteUntil = concreteSettings.mute_until;
                    if (peerMuteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
                        peerMuteUntil = 0;
                    
                    if (concreteSettings.sound.length == 0)
                        peerSoundId = 0;
                    else if ([concreteSettings.sound isEqualToString:@"default"])
                        peerSoundId = 1;
                    else
                        peerSoundId = [concreteSettings.sound intValue];
                    
                    peerPreviewText = concreteSettings.flags & (1 << 0);
                    messagesMuted = concreteSettings.flags & (1 << 1);
                    
                    [TGDatabaseInstance() storePeerNotificationSettings:peerId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:^(bool changed)
                    {
                        if (changed)
                        {
                            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:peerMuteUntil], @"muteUntil", [NSNumber numberWithInt:peerSoundId], @"soundId", [[NSNumber alloc] initWithBool:peerPreviewText], @"previewText", [[NSNumber alloc] initWithBool:messagesMuted], @"messagesMuted", nil];
                            
                            [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/peerSettings/(%lld)", peerId] resource:[[SGraphObjectNode alloc] initWithObject:dict]];
                        }
                    }];
                }
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updatePrivacy class]])
        {
        }
        else if ([update isKindOfClass:[TLUpdate$updateServiceNotificationMeta class]])
        {
            TLUpdate$updateServiceNotificationMeta *updateServiceNotification = (TLUpdate$updateServiceNotificationMeta *)update;
            if (updateServiceNotification.flags & (1 << 0))
            {
                TGDispatchOnMainThread(^
                {
                    [TGAlertView presentAlertWithTitle:@"" message:updateServiceNotification.message cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                });
            }
            else if (updateServiceNotification.inbox_date != 0)
            {
                int uid = [TGTelegraphInstance createServiceUserIfNeeded];
                
                TGMessage *message = [[TGMessage alloc] init];
                message.mid = [[[TGDatabaseInstance() generateLocalMids:1] objectAtIndex:0] intValue];
                
                message.fromUid = uid;
                message.toUid = TGTelegraphInstance.clientUserId;
                message.date = updateServiceNotification.inbox_date;
                message.outgoing = false;
                message.cid = uid;
                
                TGUser *selfUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
                
                NSString *displayName = selfUser.firstName;
                if (displayName.length == 0)
                    displayName = selfUser.lastName;
                
                message.text = updateServiceNotification.message;
                
                if (updateServiceNotification.entities.count != 0) {
                    NSArray *entities = [TGMessage parseTelegraphEntities:updateServiceNotification.entities];
                    if (entities.count != 0) {
                        TGMessageEntitiesAttachment *attachment = [[TGMessageEntitiesAttachment alloc] init];
                        attachment.entities = entities;
                        message.mediaAttachments = @[attachment];
                    }
                }
                
                [addedMessages addObject:message];
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateWebPage class]])
        {
            TGWebPageMediaAttachment *webPage = [[TGWebPageMediaAttachment alloc] initWithTelegraphWebPageDesc:((TLUpdate$updateWebPage *)update).webpage];
            TGLog(@"updateWebPage: %lld %@", webPage.webPageId, webPage.url);
            [updatedWebpages addObject:webPage];
        }
        else if ([update isKindOfClass:[TLUpdate$updateReadMessagesContents class]])
        {
            TLUpdate$updateReadMessagesContents *readMessageContents = (TLUpdate$updateReadMessagesContents *)update;
            for (NSNumber *nMessageId in readMessageContents.messages)
            {
                readContentsMessageIds.insert([nMessageId intValue]);
            }
        }
        else if ([update isKindOfClass:[TLUpdate$updateNewStickerSet class]]) {
            TLUpdate$updateNewStickerSet *concreteUpdate = (TLUpdate$updateNewStickerSet *)update;
            
            TGStickerPackIdReference *resultPackReference = [[TGStickerPackIdReference alloc] initWithPackId:concreteUpdate.stickerset.set.n_id packAccessHash:concreteUpdate.stickerset.set.access_hash shortName:concreteUpdate.stickerset.set.short_name];
            
            NSMutableArray *stickerAssociations = [[NSMutableArray alloc] init];
            for (TLStickerPack *resultAssociation in concreteUpdate.stickerset.packs)
            {
                TGStickerAssociation *association = [[TGStickerAssociation alloc] initWithKey:resultAssociation.emoticon documentIds:resultAssociation.documents];
                [stickerAssociations addObject:association];
            }
            
            NSMutableArray *documents = [[NSMutableArray alloc] init];
            for (TLDocument *resultDocument in concreteUpdate.stickerset.documents)
            {
                TGDocumentMediaAttachment *document = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:resultDocument];
                if (document.documentId != 0)
                {
                    [documents addObject:document];
                }
            }
            
            TGStickerPack *stickerPack = [[TGStickerPack alloc] initWithPackReference:resultPackReference title:concreteUpdate.stickerset.set.title stickerAssociations:stickerAssociations documents:documents packHash:concreteUpdate.stickerset.set.n_hash hidden:concreteUpdate.stickerset.set.flags & (1 << 1) isMask:concreteUpdate.stickerset.set.flags & (1 << 3)];
            
            if (stickerPack.isMask) {
                [TGMaskStickersSignals remoteAddedStickerPack:stickerPack];
            } else {
                [TGStickersSignals remoteAddedStickerPack:stickerPack];
            }
        } else if ([update isKindOfClass:[TLUpdate$updateStickerSets class]]) {
            [TGStickersSignals forceUpdateStickers];
            [TGMaskStickersSignals forceUpdateStickers];
        } else if ([update isKindOfClass:[TLUpdate$updateStickerSetsOrder class]]) {
            if (((TLUpdate$updateStickerSetsOrder *)update).flags & (1 << 0)) {
                [TGMaskStickersSignals remoteReorderedStickerPacks:((TLUpdate$updateStickerSetsOrder *)update).order];
            } else {
                [TGStickersSignals remoteReorderedStickerPacks:((TLUpdate$updateStickerSetsOrder *)update).order];
            }
        } else if ([update isKindOfClass:[TLUpdate$updateSavedGifs class]]) {
            [TGRecentGifsSignal sync];
        } else if ([update isKindOfClass:[TLUpdate$updateDraftMessage class]]) {
            TLUpdate$updateDraftMessage *draftUpdate = (TLUpdate$updateDraftMessage *)update;
            
            int64_t peerId = 0;
            if ([draftUpdate.peer isKindOfClass:[TLPeer$peerUser class]]) {
                peerId = ((TLPeer$peerUser *)draftUpdate.peer).user_id;
            } else if ([draftUpdate.peer isKindOfClass:[TLPeer$peerChat class]]) {
                peerId = -((TLPeer$peerChat *)draftUpdate.peer).chat_id;
            } else if ([draftUpdate.peer isKindOfClass:[TLPeer$peerChannel class]]) {
                peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)draftUpdate.peer).channel_id);
            }
            
            TGDatabaseMessageDraft *draft = nil;
            if ([draftUpdate.draft isKindOfClass:[TLDraftMessage$draftMessageMeta class]]) {
                TLDraftMessage$draftMessageMeta *concreteDraft = (TLDraftMessage$draftMessageMeta *)draftUpdate.draft;
                draft = [[TGDatabaseMessageDraft alloc] initWithText:concreteDraft.message entities:[TGMessage parseTelegraphEntities:concreteDraft.entities] disableLinkPreview:concreteDraft.flags & (1 << 1) replyToMessageId:concreteDraft.reply_to_msg_id date:concreteDraft.date];
            }
            
            updatePeerDrafts[@(peerId)] = draft == nil ? (id)[NSNull null] : draft;
        } else if ([update isKindOfClass:[TLUpdate$updateReadFeaturedStickers class]]) {
        } else if ([update isKindOfClass:[TLUpdate$updatePhoneCall class]]) {
            TLUpdate$updatePhoneCall *updatePhoneCall = (TLUpdate$updatePhoneCall *)update;
            if ([updatePhoneCall.phone_call isKindOfClass:[TLPhoneCall$phoneCallRequested class]]) {
                TLPhoneCall$phoneCallRequested *concreteCall = (TLPhoneCall$phoneCallRequested *)updatePhoneCall.phone_call;
                
                if ([[TGTelegramNetworking instance] approximateRemoteTime] < concreteCall.date + [TGCallSession callReceiveTimeout])
                {
                    TGCallRequestedContext *callContext = [[TGCallRequestedContext alloc] initWithCallId:concreteCall.n_id accessHash:concreteCall.access_hash date:concreteCall.date adminId:concreteCall.admin_id participantId:concreteCall.participant_id gAHash:concreteCall.g_a_hash declined:false];
                    [TGTelegraphInstance.callManager updateCallContextWithCallId:concreteCall.n_id callContext:callContext];
                }
            } else if ([updatePhoneCall.phone_call isKindOfClass:[TLPhoneCall$phoneCall class]]) {
                TLPhoneCall$phoneCall *concreteCall = (TLPhoneCall$phoneCall *)updatePhoneCall.phone_call;
                
                TGCallConnectionDescription *(^deserializeConnection)(id) = ^TGCallConnectionDescription *(id connection) {
                    if ([connection isKindOfClass:[TLPhoneConnection$phoneConnection class]]) {
                        TLPhoneConnection$phoneConnection *concreteConnection = (TLPhoneConnection$phoneConnection *)connection;
                        return [[TGCallConnectionDescription alloc] initWithIdentifier:concreteConnection.n_id ipv4:concreteConnection.ip ipv6:concreteConnection.ipv6 port:concreteConnection.port peerTag:concreteConnection.peer_tag];
                    }
                    return nil;
                };
                
                TGCallConnectionDescription *defaultConnection = deserializeConnection(concreteCall.connection);
                NSMutableArray<TGCallConnectionDescription *> *alternativeConnections = [[NSMutableArray alloc] init];
                for (id connection in concreteCall.alternative_connections) {
                    TGCallConnectionDescription *callConnection = deserializeConnection(connection);
                    if (callConnection != nil)
                        [alternativeConnections addObject:callConnection];
                }
                
                TGCallConfirmedContext *callContext = [[TGCallConfirmedContext alloc] initWithCallId:concreteCall.n_id accessHash:concreteCall.access_hash date:concreteCall.date adminId:concreteCall.admin_id participantId:concreteCall.participant_id gA:concreteCall.g_a_or_b keyFingerprint:concreteCall.key_fingerprint defaultConnection:defaultConnection alternativeConnections:alternativeConnections];
                [TGTelegraphInstance.callManager updateCallContextWithCallId:concreteCall.n_id callContext:callContext];
            } else if ([updatePhoneCall.phone_call isKindOfClass:[TLPhoneCall$phoneCallDiscardedMeta class]]) {
                TLPhoneCall$phoneCallDiscardedMeta *concreteCall = (TLPhoneCall$phoneCallDiscardedMeta *)updatePhoneCall.phone_call;
                TGCallDiscardReason reason = TGCallDiscardReasonUnknown;
                if ([concreteCall.reason isKindOfClass:[TLPhoneCallDiscardReason$phoneCallDiscardReasonMissed class]])
                    reason = TGCallDiscardReasonMissed;
                else if ([concreteCall.reason isKindOfClass:[TLPhoneCallDiscardReason$phoneCallDiscardReasonDisconnect class]])
                    reason = TGCallDiscardReasonDisconnect;
                else if ([concreteCall.reason isKindOfClass:[TLPhoneCallDiscardReason$phoneCallDiscardReasonHangup class]])
                    reason = TGCallDiscardReasonHangup;
                else if([concreteCall.reason isKindOfClass:[TLPhoneCallDiscardReason$phoneCallDiscardReasonBusy class]])
                    reason = TGCallDiscardReasonBusy;
                bool needsRating = concreteCall.flags & (1 << 2);
                bool needsDebug = concreteCall.flags & (1 << 3);
                TGCallDiscardedContext *callContext = [[TGCallDiscardedContext alloc] initWithCallId:concreteCall.n_id reason:reason outside:true needsRating:needsRating needsDebug:needsDebug error:nil];
                [TGTelegraphInstance.callManager updateCallContextWithCallId:concreteCall.n_id callContext:callContext];
            } else if ([updatePhoneCall.phone_call isKindOfClass:[TLPhoneCall$phoneCallWaitingMeta class]]) {
                TLPhoneCall$phoneCallWaitingMeta *concreteCall = (TLPhoneCall$phoneCallWaitingMeta *)updatePhoneCall.phone_call;
                TGCallWaitingContext *callContext = [[TGCallWaitingContext alloc] initWithCallId:concreteCall.n_id accessHash:concreteCall.access_hash date:concreteCall.date adminId:concreteCall.admin_id participantId:concreteCall.participant_id a:nil gA:nil dhConfig:nil receiveDate:concreteCall.receive_date];
                [TGTelegraphInstance.callManager updateCallContextWithCallId:concreteCall.n_id callContext:callContext];
            } else if([updatePhoneCall.phone_call isKindOfClass:[TLPhoneCall$phoneCallAccepted class]]) {
                TLPhoneCall$phoneCallAccepted *concreteCall = (TLPhoneCall$phoneCallAccepted *)updatePhoneCall.phone_call;
                TGCallAcceptedContext *callContext = [[TGCallAcceptedContext alloc] initWithCallId:concreteCall.n_id accessHash:concreteCall.access_hash date:concreteCall.date adminId:concreteCall.admin_id participantId:concreteCall.participant_id gA:nil gB:concreteCall.g_b];
                [TGTelegraphInstance.callManager updateCallContextWithCallId:concreteCall.n_id callContext:callContext];
            }
        } else if ([update isKindOfClass:[TLUpdate$updatePinnedDialogsMeta class]]) {
            TLUpdate$updatePinnedDialogsMeta *updatePinnedDialogs = (TLUpdate$updatePinnedDialogsMeta *)update;
            if (updatePinnedDialogs.order != nil) {
                NSMutableArray *peerIds = [[NSMutableArray alloc] init];
                for (TLPeer *peer in updatePinnedDialogs.order) {
                    int64_t peerId = 0;
                    if ([peer isKindOfClass:[TLPeer$peerChat class]]) {
                        peerId = TGPeerIdFromGroupId(((TLPeer$peerChat *)peer).chat_id);
                    } else if ([peer isKindOfClass:[TLPeer$peerUser class]]) {
                        peerId = ((TLPeer$peerUser *)peer).user_id;
                    } else if ([peer isKindOfClass:[TLPeer$peerChannel class]]) {
                        peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)peer).channel_id);
                    }
                    [peerIds addObject:@(peerId)];
                }
                replacedPinnedDialogs = peerIds;
            } else {
                requestPinnedDialogs = true;
            }
        } else if ([update isKindOfClass:[TLUpdate$updateDialogPinned class]]) {
            TLUpdate$updateDialogPinned *updateDialogPinned = (TLUpdate$updateDialogPinned *)update;
            int64_t peerId = 0;
            if ([updateDialogPinned.peer isKindOfClass:[TLPeer$peerChat class]]) {
                peerId = TGPeerIdFromGroupId(((TLPeer$peerChat *)updateDialogPinned.peer).chat_id);
            } else if ([updateDialogPinned.peer isKindOfClass:[TLPeer$peerUser class]]) {
                peerId = ((TLPeer$peerUser *)updateDialogPinned.peer).user_id;
            } else if ([updateDialogPinned.peer isKindOfClass:[TLPeer$peerChannel class]]) {
                peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)updateDialogPinned.peer).channel_id);
            }
            updatedPinnedDialogs[@(peerId)] = @((updateDialogPinned.flags & (1 << 0)) != 0);
            [updatedPinnedDialogsKeyOrder removeObject:@(peerId)];
            [updatedPinnedDialogsKeyOrder addObject:@(peerId)];
        } else if ([update isKindOfClass:[TLUpdate$updateConfig class]]) {
            [ActionStageInstance() requestActor:@"/tg/service/updateConfig/(task)" options:nil flags:0 watcher:TGTelegraphInstance];
        } else if ([update isKindOfClass:[TLUpdate$updateLangPack class]]) {
            TLUpdate$updateLangPack *updateLangPack = (TLUpdate$updateLangPack *)update;
            if (updateLangPack.difference.from_version == currentNativeLocalization().version) {
                [TGLocalizationSignals mergeLocalization:updateLangPack.difference replace:false];
            } else {
                [TGTelegraphInstance.disposeOnLogout add:[[TGLocalizationSignals pollLocalization] startWithNext:nil]];
            }
        } else if ([update isKindOfClass:[TLUpdate$updateLangPackTooLong class]]) {
            [TGTelegraphInstance.disposeOnLogout add:[[TGLocalizationSignals pollLocalization] startWithNext:nil]];
        }
    }
    
    NSMutableArray *dispatchPeerPhotoListUpdatesArray = nil;
    
    if (userPhotoUpdates != nil)
    {
        std::vector<int> uidsList;
        
        for (NSDictionary *dict in userPhotoUpdates)
        {
            uidsList.push_back([dict[@"uid"] intValue]);
        }
        
        std::set<int> uidsWithEnabledNotifications = [TGDatabaseInstance() filterPeerPhotoNotificationsEnabled:uidsList];
        
        dispatchPeerPhotoListUpdatesArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in userPhotoUpdates)
        {
            int64_t conversationId = [dict[@"uid"] intValue];
            if (uidsWithEnabledNotifications.find((int)conversationId) != uidsWithEnabledNotifications.end())
            {
                [dispatchPeerPhotoListUpdatesArray addObject:[[NSNumber alloc] initWithLongLong:conversationId]];
            }
        }
    }
    
    std::set<int> addedMessageIds;
    
    for (TLMessage *messageDesc in addedMessagesDesc)
    {
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
        if (message != nil && message.mid != 0 && ignoredConversationsForCurrentUser.find(message.cid) == ignoredConversationsForCurrentUser.end())
        {
            addedMessageIds.insert(message.mid);
            
            if (readContentsMessageIds.find(message.mid) != readContentsMessageIds.end())
            {
                if (message.contentProperties[@"contentsRead"] == nil)
                {
                    NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:message.contentProperties];
                    contentProperties[@"contentsRead"] = [[TGMessageViewedContentProperty alloc] init];
                    message.contentProperties = contentProperties;
                }
                if (message.messageLifetime != 0) {
                    [message filterOutExpiredMedia];
                }
            }
            
            [addedMessages addObject:message];
        }
    }
    
    if (!addingRandomIds.empty())
        [TGDatabaseInstance() filterExistingRandomIds:&addingRandomIds];
    
    for (int64_t encryptedConversationId : acceptEncryptedChats)
    {
        [TGDatabaseInstance() storeFutureActions:@[[[TGAcceptEncryptionFutureAction alloc] initWithEncryptedConversationId:encryptedConversationId]]];
    }
    
    NSMutableArray<TGDatabaseUpdateMessage *> *messageUpdates = [[NSMutableArray alloc] init];
    
    if (!messageIdUpdates.empty())
    {
        NSMutableArray *tempMessageIds = [[NSMutableArray alloc] init];
        
        for (auto it : messageIdUpdates)
        {
            [tempMessageIds addObject:[[NSNumber alloc] initWithLongLong:it.first]];
        }
        
        std::map<int64_t, int> messageIdMap;
        [TGDatabaseInstance() messageIdsForTempIds:tempMessageIds mapping:&messageIdMap];
        
        for (auto it : messageIdUpdates)
        {
            auto clientIt = messageIdMap.find(it.first);
            if (clientIt != messageIdMap.end() && it.second != clientIt->second)
            {
                [messageUpdates addObject:[[TGDatabaseUpdateMessageDeliveredInBackground alloc] initWithPeerId:0 messageId:clientIt->second updatedMessageId:it.second]];
            }
            
            [TGDatabaseInstance() setTempIdForMessageId:it.second peerId:0 tempId:it.first];
        }
    }
    
    if (addedMessages.count != 0)
    {
        if ([ActionStageInstance() isExecutingActorsWithGenericPath:@"/tg/sendCommonMessage/@/@"] || [ActionStageInstance() isExecutingActorsWithGenericPath:@"/tg/sendSecretMessage/@/@"])
        {
            std::map<int64_t, bool> checkedConversations;
            
            int count = (int)addedMessages.count;
            for (int i = 0; i < count; i++)
            {
                TGMessage *message = [addedMessages objectAtIndex:i];
                
                if (message.outgoing)
                {
                    bool isSendingMessages = false;
                    
                    std::map<int64_t, bool>::iterator it = checkedConversations.find(message.cid);
                    if (it == checkedConversations.end())
                    {
                        isSendingMessages = [ActionStageInstance() isExecutingActorsWithPathPrefix:[[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%" PRId64 ")/", message.cid]];
                        if (!isSendingMessages)
                        {
                            isSendingMessages = [ActionStageInstance() isExecutingActorsWithPathPrefix:[[NSString alloc] initWithFormat:@"/tg/sendSecretMessage/(%" PRId64 ")/", message.cid]];
                        }
                        checkedConversations.insert(std::pair<int64_t, bool>(message.cid, isSendingMessages));
                    }
                    else
                        isSendingMessages = it->second;
                    
                    if (isSendingMessages)
                    {
                        id key = [[NSNumber alloc] initWithLongLong:message.cid];
                        NSArray *delayedMessagesDesc = [delayedMessagesInConversations() objectForKey:key];
                        if (delayedMessagesDesc == nil)
                        {
                            delayedMessagesDesc = [[NSArray alloc] initWithObjects:[[NSMutableArray alloc] init], [[NSMutableDictionary alloc] init], nil];
                            [delayedMessagesInConversations() setObject:delayedMessagesDesc forKey:key];
                        }
                        
                        NSMutableArray *delayedMessages = [delayedMessagesDesc objectAtIndex:0];
                        NSMutableDictionary *delayedMessagesChats = [delayedMessagesDesc objectAtIndex:1];
                        [delayedMessages addObject:message];
                        [delayedMessagesChats addEntriesFromDictionary:chatItems];
                        
                        [addedMessages removeObjectAtIndex:i];
                        i--;
                        count--;
                    }
                }
            }
        }
    }
    
    NSMutableSet *requiredMessages = [[NSMutableSet alloc] init];
    
    for (TGMessage *message in addedMessages)
    {
        if (message.mediaAttachments.count != 0)
        {
            for (id attachment in message.mediaAttachments)
            {
                if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
                {
                    TGReplyMessageMediaAttachment *replyAttachment = attachment;
                    if (replyAttachment.replyMessage == nil && replyAttachment.replyMessageId != 0)
                        [requiredMessages addObject:message];
                }
            }
        }
    }
    
    void (^continueBlock)() = ^
    {
        NSMutableArray *channelChats = [[NSMutableArray alloc] init];
        for (TGConversation *conversation in [chatItems.allValues copy]) {
            if (TGPeerIdIsChannel(conversation.conversationId)) {
                [channelChats addObject:conversation];
                [chatItems removeObjectForKey:@(conversation.conversationId)];
            }
        }
        
        if (channelChats.count != 0) {
            [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                NSMutableArray *knownChannels = [[NSMutableArray alloc] init];
                NSMutableArray *unknownChannels = [[NSMutableArray alloc] init];
                
                for (TGConversation *conversation in channelChats) {
                    if ((conversation.isMin || (!conversation.leftChat && !conversation.kickedFromChat)) && [TGDatabaseInstance() loadChannels:@[@(conversation.conversationId)]].count == 0) {
                        [unknownChannels addObject:conversation];
                    } else {
                        [knownChannels addObject:conversation];
                    }
                }
                
                if (knownChannels.count != 0) {
                    [TGDatabaseInstance() updateChannels:knownChannels];
                }
                
                for (TGConversation *conversation in unknownChannels) {
                    [TGDatabaseInstance() updateChannels:@[conversation]];
                    
                    SMetaDisposable *metaDisposable = [[SMetaDisposable alloc] init];
                    __weak SMetaDisposable *weakMetaDisposable = metaDisposable;
                    id<SDisposable> disposable = [[[TGChannelStateSignals pollOnce:conversation.conversationId] then:[SSignal mergeSignals:@[[TGChannelStateSignals addInviterMessage:conversation.conversationId accessHash:conversation.accessHash], [TGChannelManagementSignals updateChannelExtendedInfo:conversation.conversationId accessHash:conversation.accessHash updateUnread:true]]]] startWithNext:nil error:^(__unused id error) {
                        __strong SMetaDisposable *strongMetaDisposable = weakMetaDisposable;
                        if (strongMetaDisposable != nil) {
                            [TGTelegraphInstance.disposeOnLogout remove:strongMetaDisposable];
                        }
                    } completed:^{
                        __strong SMetaDisposable *strongMetaDisposable = weakMetaDisposable;
                        if (strongMetaDisposable != nil) {
                            [TGTelegraphInstance.disposeOnLogout remove:strongMetaDisposable];
                        }
                    }];
                    [metaDisposable setDisposable:disposable];
                    [TGTelegraphInstance.disposeOnLogout add:metaDisposable];
                }
            } synchronous:false];
        }
        
        if (updatedEncryptedChats.count != 0) {
            [chatItems addEntriesFromDictionary:updatedEncryptedChats];
        }
        
        if (!updatePeerLayers.empty())
        {
            NSMutableArray *futureActions = [[NSMutableArray alloc] init];
            
            for (int64_t peerId : updatePeerLayers)
            {
                int64_t randomId = 0;
                arc4random_buf(&randomId, 8);
                [futureActions addObject:[[TGUpdatePeerLayerFutureAction alloc] initWithEncryptedConversationId:[TGDatabaseInstance() encryptedConversationIdForPeerId:peerId] messageRandomId:randomId]];
            }
            
            [TGDatabaseInstance() storeFutureActions:futureActions];
        }
        
        if (editedMessages.count != 0) {
            for (TGMessage *message in editedMessages) {
                [messageUpdates addObject:[[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:message.cid messageId:message.mid message:message dispatchEdited:true]];
            }
        }
        
        [channelUpdatesByPeerId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nPeerId, NSMutableArray *updates, __unused BOOL *stop) {
            [updates addObjectsFromArray:filteredMessageIdUpdates];
            [TGChannelStateSignals addChannelUpdates:[nPeerId longLongValue] updates:updates];
        }];
        
        [TGDatabaseInstance() dispatchOnDatabaseThread:^{
            [messageViewsUpdatesByPeerId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nPeerId, NSDictionary *messageViews, __unused BOOL *stop) {
                [TGDatabaseInstance() updateMessageViews:[nPeerId longLongValue] messageIdToViews:messageViews];
                
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messageViews", [nPeerId longLongValue]] resource:messageViews];
            }];
        } synchronous:false];
        
        if (encryptedActionsByPeerId.count != 0)
            [TGModernSendSecretMessageActor enqueueIncomingMessagesByPeerId:encryptedActionsByPeerId];
        if (encryptedUnparsedActionsByPeerId.count != 0)
            [TGModernSendSecretMessageActor enqueueIncomingEncryptedMessagesByPeerId:encryptedUnparsedActionsByPeerId];
        
        NSMutableDictionary *maxIncomingReadIds = [[NSMutableDictionary alloc] init];
        for (auto it : maxInboxReadMessageIdByPeerId)
        {
            maxIncomingReadIds[@(it.first)] = @(it.second);
        }
        
        NSMutableDictionary *maxOutgoingReadIds = [[NSMutableDictionary alloc] init];
        for (auto it : maxOutboxReadMessageIdByPeerId)
        {
            maxOutgoingReadIds[@(it.first)] = @(it.second);
        }
        
        NSMutableDictionary<NSNumber *, TGDatabaseReadMessagesByDate *> *maxOutgoingReadDates = [[NSMutableDictionary alloc] init];
        
        if (!readContentsMessageIds.empty())
        {
            NSMutableArray *nReadContentsMessageIds = [[NSMutableArray alloc] init];
            for (auto it : readContentsMessageIds)
            {
                [nReadContentsMessageIds addObject:@(it)];
                
                [messageUpdates addObject:[[TGDatabaseUpdateContentsRead alloc] initWithPeerId:0 messageId:it]];
            }
            
            [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/*/readmessageContents"] resource:@{@"messageIds": nReadContentsMessageIds}];
        }
        
        if (!maxReadDateInEncryptedConversation.empty())
        {
            for (auto it : maxReadDateInEncryptedConversation)
            {
                maxOutgoingReadDates[@(it.first)] = [[TGDatabaseReadMessagesByDate alloc] initWithDate:it.second.first referenceDateForTimers:it.second.second];
            }
        }
        
        NSMutableDictionary<NSNumber *, NSMutableArray<NSNumber *> *> *removeMessageIdsByPeerId = [[NSMutableDictionary alloc] init];
        
        for (std::set<int>::iterator it = deleteMessageIds.begin(); it != deleteMessageIds.end(); it++)
        {
            NSNumber *nPeerId = @0;
            NSMutableArray *array = removeMessageIdsByPeerId[nPeerId];
            if (array == nil) {
                array = [[NSMutableArray alloc] init];
                removeMessageIdsByPeerId[nPeerId] = array;
            }
            [array addObject:@(*it)];
        }
        
        for (TGWebPageMediaAttachment *webPage in updatedWebpages) {
            [self addWebPage:webPage];
            notifyAwaitingWebPageListeners(webPage);
        }
        if (updatedWebpages.count != 0) {
            [TGDatabaseInstance() updateWebpages:updatedWebpages];
            [ActionStageInstance() dispatchResource:@"/webpages" resource:updatedWebpages];
        }
        
        [TGDatabaseInstance() transactionAddMessages:addedMessages notifyAddedMessages:true removeMessages:removeMessageIdsByPeerId updateMessages:messageUpdates updatePeerDrafts:updatePeerDrafts removeMessagesInteractive:nil keepDates:false removeMessagesInteractiveForEveryone:false updateConversationDatas:chatItems applyMaxIncomingReadIds:maxIncomingReadIds applyMaxOutgoingReadIds:maxOutgoingReadIds applyMaxOutgoingReadDates:maxOutgoingReadDates readHistoryForPeerIds:nil resetPeerReadStates:nil clearConversationsWithPeerIds:nil removeConversationsWithPeerIds:nil updatePinnedConversations:nil synchronizePinnedConversations:false forceReplacePinnedConversations:false];
        
        NSMutableArray *chatParticipantsArray = [[NSMutableArray alloc] init];
        
        if (chatParticipantsDesc != nil)
            [chatParticipantsArray addObjectsFromArray:chatParticipantsDesc];
        
        for (auto it = chatParticipantUpdateArrays.begin(); it != chatParticipantUpdateArrays.end(); it++)
        {
            for (auto it2 = it->second.begin(); it2 != it->second.end(); it2++)
            {
                id update = *(it2);
                if ([update isKindOfClass:[TLChatParticipants class]])
                    [chatParticipantsArray addObject:update];
            }
        }
        
        for (TLChatParticipants *chatParticipants in chatParticipantsArray)
        {
            TGConversationParticipantsData *participantsData = [[TGConversationParticipantsData alloc] initWithTelegraphParticipantsDesc:chatParticipants];
            [TGDatabaseInstance() storeConversationParticipantData:-chatParticipants.chat_id participantData:participantsData];
        }
        
        for (auto it = chatParticipantUpdateArrays.begin(); it != chatParticipantUpdateArrays.end(); it++)
        {
            for (auto it2 = it->second.begin(); it2 != it->second.end(); it2++)
            {
                id update = *(it2);
                
                if ([update isKindOfClass:[TLUpdate$updateChatParticipantAdd class]] || [update isKindOfClass:[TLUpdate$updateChatParticipantDelete class]])
                {
                    int date = 0;
                    for (NSArray *item in updatesWithDates)
                    {
                        if (item == update)
                            date = [item[1] intValue];
                    }
                    
                    int64_t conversationId = 0;
                    int version = 0;
                    int32_t userId = 0;
                    
                    if ([update isKindOfClass:[TLUpdate$updateChatParticipantAdd class]])
                    {
                        conversationId = -((TLUpdate$updateChatParticipantAdd *)update).chat_id;
                        version = ((TLUpdate$updateChatParticipantAdd *)update).version;
                        userId = ((TLUpdate$updateChatParticipantAdd *)update).user_id;
                    }
                    else
                    {
                        conversationId = -((TLUpdate$updateChatParticipantDelete *)update).chat_id;
                        version = ((TLUpdate$updateChatParticipantDelete *)update).version;
                        userId = ((TLUpdate$updateChatParticipantDelete *)update).user_id;
                    }
                    
                    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
                    if (conversation != 0 && conversation.chatParticipants != nil && conversation.chatParticipants.version < version)
                    {
                        TGConversationParticipantsData *participants = [[conversation chatParticipants] copy];
                        if ([update isKindOfClass:[TLUpdate$updateChatParticipantAdd class]])
                            [participants addParticipantWithId:userId invitedBy:((TLUpdate$updateChatParticipantAdd *)update).inviter_id date:date];
                        else
                            [participants removeParticipantWithId:userId];
                        
                        participants.version = version;
                        
                        [TGDatabaseInstance() storeConversationParticipantData:conversationId participantData:participants];
                    }
                }
                else if ([update isKindOfClass:[TLUpdate$updateChatParticipantAdmin class]]) {
                    TLUpdate$updateChatParticipantAdmin *concreteUpdate = (TLUpdate$updateChatParticipantAdmin *)update;
                    
                    int64_t conversationId = TGPeerIdFromGroupId(concreteUpdate.chat_id);
                    int version = concreteUpdate.version;
                    int32_t userId = concreteUpdate.user_id;
                    
                    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
                    if (conversation != 0 && conversation.chatParticipants != nil && conversation.chatParticipants.version < version)
                    {
                        TGConversationParticipantsData *participants = [[conversation chatParticipants] copy];
                        NSMutableSet *chatAdminUids = [[NSMutableSet alloc] initWithSet:participants.chatAdminUids];
                        if (concreteUpdate.is_admin) {
                            [chatAdminUids addObject:@(userId)];
                        } else {
                            [chatAdminUids removeObject:@(userId)];
                        }
                        participants.chatAdminUids = chatAdminUids;
                        participants.version = version;
                        
                        [TGDatabaseInstance() storeConversationParticipantData:conversationId participantData:participants];
                    }
                }
            }
        }
        
        if (!acceptEncryptedChats.empty() || !updatePeerLayers.empty())
            [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
        
        for (id update in userTypingUpdates)
        {
            if ([update isKindOfClass:updateUserTypingClass])
            {
                TLUpdate$updateUserTyping *userTyping = (TLUpdate$updateUserTyping *)update;
                
                if ([TGDatabaseInstance() loadUser:userTyping.user_id] != nil)
                {
                    NSString *activity = @"typing";
                    if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageRecordVideoAction class]])
                        activity = @"recordingVideo";
                    if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageUploadVideoAction class]])
                        activity = @"uploadingVideo";
                    else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageRecordAudioAction class]])
                        activity = @"recordingAudio";
                    else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageUploadAudioAction class]])
                        activity = @"uploadingAudio";
                    else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageRecordRoundAction class]])
                        activity = @"recordingVideoMessage";
                    else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageUploadRoundAction class]])
                        activity = @"uploadingVideoMessage";
                    else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageUploadPhotoAction class]])
                        activity = @"uploadingPhoto";
                    else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageUploadDocumentAction class]])
                        activity = @"uploadingDocument";
                    else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageGeoLocationAction class]])
                        activity = @"pickingLocation";
                    else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageChooseContactAction class]])
                        activity = @"choosingContact";
                    else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageCancelAction class]])
                        activity = nil;
                    else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageGamePlayAction class]])
                        activity = @"playingGame";
                    
                    [TGTelegraphInstance dispatchUserActivity:userTyping.user_id inConversation:userTyping.user_id type:activity];
                }
            }
            else if ([update isKindOfClass:updateChatUserTypingClass])
            {
                TLUpdate$updateChatUserTyping *userTyping = (TLUpdate$updateChatUserTyping *)update;
                
                NSString *activity = @"typing";
                if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageRecordVideoAction class]])
                    activity = @"recordingVideo";
                if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageUploadVideoAction class]])
                    activity = @"uploadingVideo";
                else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageRecordAudioAction class]])
                    activity = @"recordingAudio";
                else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageUploadAudioAction class]])
                    activity = @"uploadingAudio";
                else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageRecordRoundAction class]])
                    activity = @"recordingVideoMessage";
                else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageUploadRoundAction class]])
                    activity = @"uploadingVideoMessage";
                else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageUploadPhotoAction class]])
                    activity = @"uploadingPhoto";
                else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageUploadDocumentAction class]])
                    activity = @"uploadingDocument";
                else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageGeoLocationAction class]])
                    activity = @"pickingLocation";
                else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageChooseContactAction class]])
                    activity = @"choosingContact";
                else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageCancelAction class]])
                    activity = nil;
                else if ([userTyping.action isKindOfClass:[TLSendMessageAction$sendMessageGamePlayAction class]])
                    activity = @"playingGame";
                
                if ([TGDatabaseInstance() loadUser:userTyping.user_id] != nil) {
                    [TGTelegraphInstance dispatchUserActivity:userTyping.user_id inConversation:-userTyping.chat_id type:activity];
                    [TGTelegraphInstance dispatchUserActivity:userTyping.user_id inConversation:TGPeerIdFromChannelId( userTyping.chat_id) type:activity];
                }
            }
            else if ([update isKindOfClass:updateEncryptedChatTypingClass])
            {
                TLUpdate$updateEncryptedChatTyping *updateEncryptedChatTyping = (TLUpdate$updateEncryptedChatTyping *)update;
                
                int64_t conversationId = [TGDatabaseInstance() peerIdForEncryptedConversationId:updateEncryptedChatTyping.chat_id createIfNecessary:false];
                if (conversationId != 0)
                {
                    int uid = [TGDatabaseInstance() encryptedParticipantIdForConversationId:conversationId];
                    if (uid != 0)
                    {
                        [TGTelegraphInstance dispatchUserActivity:uid inConversation:conversationId type:@"typing"];
                    }
                }
            }
        }
        
        if (dispatchPeerPhotoListUpdatesArray != nil)
        {
            for (NSNumber *nPeerId in dispatchPeerPhotoListUpdatesArray)
            {
                [TGDatabaseInstance() dispatchOnDatabaseThread:^
                {
                    [TGDatabaseInstance() loadPeerProfilePhotos:[nPeerId longLongValue] completion:^(NSArray *photosArray)
                    {
                        if (photosArray != nil)
                        {
                            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/profilePhotos/(%lld)", [nPeerId longLongValue]] resource:photosArray];
                        }
                    }];
                } synchronous:false];
            }
        }
        
        if (dispatchBlocked)
        {
            [TGDatabaseInstance() loadBlockedList:^(NSArray *blockedList)
            {
                NSMutableArray *users = [[NSMutableArray alloc] init];
                for (NSNumber *nUid in blockedList)
                {
                    TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                    if (user != nil)
                        [users addObject:user];
                }
                [ActionStageInstance() dispatchResource:@"/tg/blockedUsers" resource:[[SGraphObjectNode alloc] initWithObject:users]];
            }];
        }
        
        [TGDatabaseInstance() dispatchOnDatabaseThread:^{
            if (replacedPinnedDialogs != nil) {
                for (NSNumber *nPeerId in replacedPinnedDialogs) {
                    if (![TGDatabaseInstance() containsConversationWithId:[nPeerId longLongValue]]) {
                        requestPinnedDialogs = true;
                        break;
                    }
                }
            }
            
            if (updatedPinnedDialogs.count != 0) {
                for (NSNumber *nPeerId in updatedPinnedDialogs.allKeys) {
                    if (![TGDatabaseInstance() containsConversationWithId:[nPeerId longLongValue]]) {
                        requestPinnedDialogs = true;
                        break;
                    }
                }
            }
                     
            if (requestPinnedDialogs) {
                [TGGroupManagementSignals beginPullPinnedConversations];
            } else if (replacedPinnedDialogs != nil) {
                [TGDatabaseInstance() transactionUpdatePinnedConversations:replacedPinnedDialogs synchronizePinnedConversations:false forceReplacePinnedConversations:false];
            } else if (updatedPinnedDialogs.count != 0) {
                NSMutableArray *peerIds = [[NSMutableArray alloc] init];
                for (TGConversation *conversation in [TGDatabaseInstance() _getPinnedConversations]) {
                    NSNumber *updatedStatus = updatedPinnedDialogs[@(conversation.conversationId)];
                    if (!(updatedStatus != nil && ![updatedStatus boolValue])) {
                        [peerIds addObject:@(conversation.conversationId)];
                    }
                }
                for (NSNumber *nPeerId in updatedPinnedDialogsKeyOrder) {
                    if ([updatedPinnedDialogs[nPeerId] boolValue]) {
                        [peerIds insertObject:nPeerId atIndex:0];
                    }
                }
                [TGDatabaseInstance() transactionUpdatePinnedConversations:peerIds synchronizePinnedConversations:false forceReplacePinnedConversations:false];
            }
        } synchronous:false];
        
        if (completion)
            completion(true);
    };
    
    if (requiredMessages.count == 0)
    {
        continueBlock();
    }
    else
    {
        NSMutableSet *messageIds = [[NSMutableSet alloc] init];
        for (TGMessage *message in requiredMessages)
        {
            for (id attachment in message.mediaAttachments)
            {
                if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
                {
                    [messageIds addObject:@(((TGReplyMessageMediaAttachment *)attachment).replyMessageId)];
                    break;
                }
            }
        }
        
        NSMutableArray *downloadMessages = [[NSMutableArray alloc] init];
        for (NSNumber *nMessageId in [messageIds allObjects]) {
            [downloadMessages addObject:[[TGDownloadMessage alloc] initWithPeerId:0 accessHash:0 messageId:[nMessageId intValue]]];
        }
        
        SSignal *downloadMessagesSignal = [TGDownloadMessagesSignal downloadMessages:downloadMessages];
        
        [downloadMessagesSignal startWithNext:^(NSArray *messages)
        {
            NSMutableDictionary *messageIdToMessage = [[NSMutableDictionary alloc] init];
            for (TGMessage *message in messages)
            {
                messageIdToMessage[@(message.mid)] = message;
            }
            
            for (TGMessage *message in requiredMessages)
            {
                for (id attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
                    {
                        TGMessage *requiredMessage = messageIdToMessage[@(((TGReplyMessageMediaAttachment *)attachment).replyMessageId)];
                        if (requiredMessage != nil)
                            ((TGReplyMessageMediaAttachment *)attachment).replyMessage = requiredMessage;
                        
                        break;
                    }
                }
            }
            
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                continueBlock();
            }];
        } error:^(__unused id error)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                continueBlock();
            }];
        } completed:nil];
    }
}

+ (void)processDelayedMessagesInConversation:(int64_t)conversationId completedPath:(NSString *)path
{
    NSArray *delayedMessagesDesc = [delayedMessagesInConversations() objectForKey:[[NSNumber alloc] initWithLongLong:conversationId]];
    if (delayedMessagesDesc != nil)
    {
        bool isSendingMessages = false;
        
        for (ASActor *actor in [ActionStageInstance() executingActorsWithPathPrefix:[[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%" PRId64 ")/", conversationId]])
        {
            if (![actor.path isEqualToString:path])
            {
                isSendingMessages = true;
                break;
            }
        }
        
        if (!isSendingMessages)
        {
            for (ASActor *actor in [ActionStageInstance() executingActorsWithPathPrefix:[[NSString alloc] initWithFormat:@"/tg/sendSecretMessage/(%" PRId64 ")/", conversationId]])
            {
                if (![actor.path isEqualToString:path])
                {
                    isSendingMessages = true;
                    break;
                }
            }
        }
        
        if (!isSendingMessages)
            [TGUpdateStateRequestBuilder applyDelayedOutgoingMessages:conversationId];
    }
}

+ (void)applyDelayedOutgoingMessages:(int64_t)conversationId
{
    id key = [[NSNumber alloc] initWithLongLong:conversationId];
    NSArray *messagesDesc = [delayedMessagesInConversations() objectForKey:key];
    if (messagesDesc != nil)
    {
        NSMutableArray *messages = [messagesDesc objectAtIndex:0];
        NSMutableDictionary *chats = [messagesDesc objectAtIndex:1];
        
        [TGDatabaseInstance() transactionAddMessages:messages updateConversationDatas:chats notifyAdded:true];
        
        [delayedMessagesInConversations() removeObjectForKey:key];
    }
}

- (void)stateDeltaRequestSuccess:(TLupdates_Difference *)difference
{   
    dispatch_block_t continueBlock = ^
    {
        static int applyStateCounter = 0;
        
        if ([difference isKindOfClass:[TLupdates_Difference$updates_differenceSlice class]])
        {
            TLupdates_Difference$updates_differenceSlice *concreteDifference = (TLupdates_Difference$updates_differenceSlice *)difference;
            
            [[[TGApplyStateRequestBuilder alloc] initWithPath:[NSString stringWithFormat:@"/tg/service/applystate/(c%d)", applyStateCounter++]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:concreteDifference.intermediate_state.pts], @"pts", [NSNumber numberWithInt:concreteDifference.intermediate_state.date], @"date", [NSNumber numberWithInt:concreteDifference.intermediate_state.seq], @"seq", @(concreteDifference.intermediate_state.qts), @"qts", [NSNumber numberWithInt:-1], @"unreadCount", nil]];
            
            self.cancelToken = [TGTelegraphInstance doRequestStateDelta:concreteDifference.intermediate_state.pts date:concreteDifference.intermediate_state.date qts:concreteDifference.intermediate_state.qts requestBuilder:self];
        }
        else if ([difference isKindOfClass:[TLupdates_Difference$updates_difference class]] || [difference isKindOfClass:[TLupdates_Difference$updates_differenceEmpty class]])
        {
            int differencePts = 0;
            if ([difference isKindOfClass:[TLupdates_Difference$updates_difference class]])
                differencePts = ((TLupdates_Difference$updates_difference *)difference).state.pts;
            
            int differenceDate = 0;
            int differenceQts = 0;
            
            int differenceSeq = 0;
            if ([difference isKindOfClass:[TLupdates_Difference$updates_difference class]])
            {
                differenceSeq = ((TLupdates_Difference$updates_difference *)difference).state.seq;
                differenceDate = ((TLupdates_Difference$updates_difference *)difference).state.date;
                differenceQts = ((TLupdates_Difference$updates_difference *)difference).state.qts;
                TGLog(@"difference qts: %d", ((TLupdates_Difference$updates_difference *)difference).state.qts);
            }
            else if ([difference isKindOfClass:[TLupdates_Difference$updates_differenceEmpty class]])
            {
                differenceSeq = ((TLupdates_Difference$updates_differenceEmpty *)difference).seq;
                differenceDate = ((TLupdates_Difference$updates_differenceEmpty *)difference).date;
            }
            
            if (differenceQts > 0)
            {
                [TGDatabaseInstance() updateLatestQts:differenceQts applied:false completion:^(int greaterQtsForSynchronization)
                {
                    if (greaterQtsForSynchronization > 0)
                    {
                        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/messages/reportDelivery/(qts)"] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:differenceQts], @"qts", nil] watcher:TGTelegraphInstance];
                    }
                }];
            }
            
            int applyUnreadCount = -1;
            if ([difference isKindOfClass:[TLupdates_Difference$updates_difference class]])
            {
                NSInteger secretUnreadCount = [TGDatabaseInstance() secretUnreadCount];
                NSInteger localUnreadCount = [TGDatabaseInstance() databaseState].unreadCount;
                NSInteger remoteUnreadCount = ((TLupdates_Difference$updates_difference *)difference).state.unread_count;
                if ((localUnreadCount - secretUnreadCount) > remoteUnreadCount)
                {
                    TGLog(@"Unread count correction: %d - %d > %d", (int)localUnreadCount, (int)secretUnreadCount, (int)remoteUnreadCount);
                    applyUnreadCount = (int)(remoteUnreadCount + secretUnreadCount);
                }
                else
                {
                    TGLog(@"Unread count correct: %d + %d == %d", (int)localUnreadCount, (int)secretUnreadCount, (int)remoteUnreadCount);
                }
            }
            else
            {
                [TGTelegraphInstance.genericTasksSignalManager startStandaloneSignalIfNotRunningForKey:@"service/getState" producer:^SSignal *
                {
                    TLRPCupdates_getState$updates_getState *getState = [[TLRPCupdates_getState$updates_getState alloc] init];
                    return [[[TGTelegramNetworking instance] requestSignal:getState] map:^id(TLupdates_State *result)
                    {
                        [TGDatabaseInstance() dispatchOnDatabaseThread:^
                        {
                            NSInteger secretUnreadCount = [TGDatabaseInstance() secretUnreadCount];
                            NSInteger localUnreadCount = [TGDatabaseInstance() databaseState].unreadCount;
                            NSInteger remoteUnreadCount = result.unread_count;
                            if ((localUnreadCount - secretUnreadCount) > remoteUnreadCount)
                            {
                                TGLog(@"Unread count correction: %d - %d > %d", (int)localUnreadCount, (int)secretUnreadCount, (int)remoteUnreadCount);
                                int applyUnreadCount = (int)(remoteUnreadCount + secretUnreadCount);
                                
                                [[[TGApplyStateRequestBuilder alloc] initWithPath:[NSString stringWithFormat:@"/tg/service/applystate/(d%d)", applyStateCounter++]] execute:@{@"unreadCount": @(applyUnreadCount)}];
                            }
                        } synchronous:false];
                        
                        return nil;
                    }];
                }];
            }
            
            [[[TGApplyStateRequestBuilder alloc] initWithPath:[NSString stringWithFormat:@"/tg/service/applystate/(d%d)", applyStateCounter++]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:differencePts], @"pts", [NSNumber numberWithInt:differenceDate], @"date", [NSNumber numberWithInt:differenceSeq], @"seq", @(differenceQts), @"qts", [NSNumber numberWithInt:applyUnreadCount], @"unreadCount", nil]];
            
            [self completeDifferenceUpdate:false];

            int state = 0;
            if ([[TGTelegramNetworking instance] isUpdating])
                state |= 1;
            if ([[TGTelegramNetworking instance] isConnecting])
                state |= 2;
            if (![[TGTelegramNetworking instance] isNetworkAvailable])
                state |= 4;
            
            [ActionStageInstance() dispatchResource:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:state]]];
            
            [ActionStageInstance() dispatchResource:@"/tg/service/stateUpdated" resource:nil];
            
            [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
            
            if (!didRequestUpdates)
            {
                didRequestUpdates = true;
                [ActionStageInstance() requestActor:@"/tg/service/checkUpdates" options:nil watcher:TGTelegraphInstance];
            }
            
            [ActionStageInstance() requestActor:@"/tg/updateUserStatuses" options:nil watcher:TGTelegraphInstance];
            
            [TGDatabaseInstance() tempIdsForLocalMessages:^(std::vector<std::pair<int64_t, int> > mapping)
            {
                if (!mapping.empty())
                {
                    NSMutableArray *tempIds = [[NSMutableArray alloc] initWithCapacity:mapping.size()];
                    NSMutableArray *failMids = [[NSMutableArray alloc] initWithCapacity:mapping.size()];
                    
                    NSMutableArray<TGDatabaseUpdateMessage *> *messageUpdates = [[NSMutableArray alloc] init];
                    
                    for (auto item : mapping)
                    {
                        [tempIds addObject:[[NSNumber alloc] initWithLongLong:item.first]];
                        [failMids addObject:[[NSNumber alloc] initWithLongLong:item.second]];
                        
                        [messageUpdates addObject:[[TGDatabaseUpdateMessageFailedDeliveryInBackground alloc] initWithPeerId:0 messageId:item.second]];
                    }
                    
                    [TGDatabaseInstance() removeTempIds:tempIds];
                    
                    [TGDatabaseInstance() transactionUpdateMessages:messageUpdates updateConversationDatas:nil];
                    
                    [ActionStageInstance() dispatchResource:@"/tg/conversation/*/failmessages" resource:@{@"mids": failMids}];
                }
            }];
        }
        else
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
        }
    };
    
    if ([difference isKindOfClass:[TLupdates_Difference$updates_difference class]] || [difference isKindOfClass:[TLupdates_Difference$updates_differenceSlice class]])
    {
        NSArray *newMessages = ((TLupdates_Difference$updates_difference *)difference).n_new_messages;
        
        NSMutableDictionary *encryptedActionsByPeerId = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *encryptedUnparsedActionsByPeerId = [[NSMutableDictionary alloc] init];
        
        if (((TLupdates_Difference$updates_difference *)difference).n_new_encrypted_messages.count != 0)
        {
            std::map<int64_t, int64_t> cachedPeerIds;
            std::map<int64_t, std::pair<int64_t, NSData *> > cachedKeys;
            std::map<int64_t, int32_t> cachedParticipantIds;
            
            for (TLEncryptedMessage *encryptedMessage in ((TLupdates_Difference$updates_difference *)difference).n_new_encrypted_messages)
            {
                int64_t conversationId = 0;
                int64_t keyId = 0;
                int32_t seqIn = 0;
                int32_t seqOut = 0;
                NSUInteger decryptedLayer = 1;
                
                NSData *decryptedMessageData = [TGUpdateStateRequestBuilder decryptEncryptedMessageData:encryptedMessage decryptedLayer:&decryptedLayer cachedPeerIds:&cachedPeerIds cachedParticipantIds:&cachedParticipantIds outConversationId:&conversationId outKeyId:&keyId outSeqIn:&seqIn outSeqOut:&seqOut];
                TGStoredIncomingMessageFileInfo *fileInfo = nil;
                if ([encryptedMessage isKindOfClass:[TLEncryptedMessage$encryptedMessage class]])
                {
                    id encryptedFile = ((TLEncryptedMessage$encryptedMessage *)encryptedMessage).file;
                    if ([encryptedFile isKindOfClass:[TLEncryptedFile$encryptedFile class]])
                    {
                        TLEncryptedFile$encryptedFile *concreteFile = encryptedFile;
                        fileInfo = [[TGStoredIncomingMessageFileInfo alloc] initWithId:concreteFile.n_id accessHash:concreteFile.access_hash size:concreteFile.size datacenterId:concreteFile.dc_id keyFingerprint:concreteFile.key_fingerprint];
                    }
                }
                if (decryptedMessageData != nil)
                {
                    NSMutableArray *encryptedActions = encryptedActionsByPeerId[@(conversationId)];
                    if (encryptedActions == nil)
                    {
                        encryptedActions = [[NSMutableArray alloc] init];
                        encryptedActionsByPeerId[@(conversationId)] = encryptedActions;
                    }
                    
                    [encryptedActions addObject:[[TGStoredSecretIncomingActionWithSeq alloc] initWithAction:[[TGStoredIncomingMessageSecretAction alloc] initWithLayer:decryptedLayer data:decryptedMessageData date:encryptedMessage.date fileInfo:fileInfo] seqIn:seqIn seqOut:seqOut layer:decryptedLayer]];
                }
                else
                {
                    NSMutableArray *encryptedUnparsedActions = encryptedUnparsedActionsByPeerId[@(conversationId)];
                    if (encryptedUnparsedActions == nil)
                    {
                        encryptedUnparsedActions = [[NSMutableArray alloc] init];
                        encryptedUnparsedActionsByPeerId[@(conversationId)] = encryptedUnparsedActions;
                    }
                    
                    [encryptedUnparsedActions addObject:[[TGStoredIncomingEncryptedDataSecretAction alloc] initWithKeyId:keyId randomId:encryptedMessage.random_id chatId:encryptedMessage.chat_id date:encryptedMessage.date encryptedData:encryptedMessage.bytes fileInfo:fileInfo]];
                }
            }
        }
        
        NSArray *otherUpdates_ = ((TLupdates_Difference$updates_difference *)difference).other_updates;
        NSArray *usersDesc = ((TLupdates_Difference$updates_difference *)difference).users;
        NSArray *chatsDesc = ((TLupdates_Difference$updates_difference *)difference).chats;
        
        __block NSArray *otherUpdates = otherUpdates_;
/*#ifdef DEBUG
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableArray *mutableOtherUpdates = [[NSMutableArray alloc] initWithArray:otherUpdates_];
            TLUpdate$updateServiceNotificationMeta *updateServiceNotification = [[TLUpdate$updateServiceNotificationMeta alloc] init];
            updateServiceNotification.inbox_date = (int32_t)[[TGTelegramNetworking instance] approximateRemoteTime];
            updateServiceNotification.message = @"Test Message";
            [mutableOtherUpdates addObject:updateServiceNotification];
            otherUpdates = mutableOtherUpdates;
        });
#endif*/
        
        [TGUpdateStateRequestBuilder applyUpdates:newMessages otherUpdates:otherUpdates usersDesc:usersDesc chatsDesc:chatsDesc chatParticipantsDesc:nil updatesWithDates:nil addedEncryptedActionsByPeerId:encryptedActionsByPeerId addedEncryptedUnparsedActionsByPeerId:encryptedUnparsedActionsByPeerId completion:^(__unused bool success)
        {
            continueBlock();
        }];
    }
    else
        continueBlock();
}

- (void)stateDeltaRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
    
    int state = 0;
    if ([[TGTelegramNetworking instance] isUpdating])
        state |= 1;
    if ([[TGTelegramNetworking instance] isConnecting])
        state |= 2;
    if (![[TGTelegramNetworking instance] isNetworkAvailable])
        state |= 4;
    
    [ActionStageInstance() dispatchResource:@"/tg/service/synchronizationstate" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:state]]];
}

- (void)stateRequestSuccess:(TLupdates_State *)state
{
    _state = state;
    
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/dialoglist/(%d)", INT_MAX] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:true] forKey:@"inline"] watcher:self];
}

- (void)stateRequestFailed
{
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/dialoglist/(%d)", INT_MAX] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:true] forKey:@"inline"] watcher:self];
}

- (void)cancel
{
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        self.cancelToken = nil;
    }
    
    [super cancel];
}

+ (NSData *)decryptEncryptedMessageData:(TLEncryptedMessage *)encryptedMessage decryptedLayer:(NSUInteger *)decryptedLayer cachedPeerIds:(std::map<int64_t, int64_t> *)cachedPeerIds cachedParticipantIds:(std::map<int64_t, int> *)cachedParticipantIds outConversationId:(int64_t *)outConversationId outKeyId:(int64_t *)outKeyId outSeqIn:(int32_t *)outSeqIn outSeqOut:(int32_t *)outSeqOut
{
    int64_t conversationId = 0;
    bool peerFound = false;
    
    if (cachedPeerIds != NULL)
    {
        auto it = cachedPeerIds->find(encryptedMessage.chat_id);
        if (it != cachedPeerIds->end())
        {
            conversationId = it->second;
            peerFound = true;
        }
    }
    
    if (!peerFound)
    {
        conversationId = [TGDatabaseInstance() peerIdForEncryptedConversationId:encryptedMessage.chat_id createIfNecessary:false];
        
        if (cachedPeerIds != NULL)
            (*cachedPeerIds)[encryptedMessage.chat_id] = conversationId;
    }
    
    if (encryptedMessage.bytes.length < 8 + 16 + 16)
    {
        TGLog(@"***** Ignoring message from conversation %lld (too short)", encryptedMessage.chat_id);
    }
    else if (conversationId != 0)
    {
        if (outConversationId != NULL)
            *outConversationId = conversationId;
        
        int64_t keyId = 0;
        [encryptedMessage.bytes getBytes:&keyId range:NSMakeRange(0, 8)];
        NSData *messageKey = [encryptedMessage.bytes subdataWithRange:NSMakeRange(8, 16)];
        
        if (outKeyId)
            *outKeyId = keyId;
        
        int64_t localKeyId = 0;
        NSData *key = nil;
        key = [TGDatabaseInstance() encryptionKeyForConversationId:conversationId requestedKeyFingerprint:keyId outKeyFingerprint:&localKeyId];
        
        if (key != nil && keyId == localKeyId)
        {
            MTMessageEncryptionKey *keyData = [TGModernSendSecretMessageActor generateMessageKeyData:messageKey incoming:false key:key];
            
            NSMutableData *encryptedMessageData = [[encryptedMessage.bytes subdataWithRange:NSMakeRange(8 + 16, encryptedMessage.bytes.length - (8 + 16))] mutableCopy];
            NSData *messageData = MTAesDecrypt(encryptedMessageData, keyData.key, keyData.iv);
            
            int32_t messageLength = 0;
            [messageData getBytes:&messageLength range:NSMakeRange(0, 4)];
            
            int32_t paddingLength = (int32_t)messageData.length - (messageLength + 4);
            
            if (messageLength > (int32_t)messageData.length - 4) {
                TGLog(@"***** Ignoring message from conversation %lld with invalid message length", encryptedMessage.chat_id);
            } else if (paddingLength > 16) {
                TGLog(@"***** Ignoring message from conversation %lld with invalid message length", encryptedMessage.chat_id);
            } else {
                NSData *localMessageKeyFull = MTSubdataSha1(messageData, 0, messageLength + 4);
                NSData *localMessageKey = [[NSData alloc] initWithBytes:(((int8_t *)localMessageKeyFull.bytes) + localMessageKeyFull.length - 16) length:16];
                if (![localMessageKey isEqualToData:messageKey]) {
                    TGLog(@"***** Ignoring message from conversation with message key mismatch %lld", encryptedMessage.chat_id);
                } else {
                    NSData *messageContentData = [messageData subdataWithRange:NSMakeRange(4, messageData.length - 4)];
                    
                    if (messageContentData.length >= 4)
                    {
                        NSUInteger layer = 1;
                        int32_t seqIn = 0;
                        int32_t seqOut = 0;
                        int32_t possibleLayerSignature = 0;
                        [messageContentData getBytes:&possibleLayerSignature length:4];
                        if (possibleLayerSignature == (int32_t)0x1be31789)
                        {
                            if (messageContentData.length >= 4 + 1)
                            {
                                uint8_t randomBytesLength = 0;
                                [messageContentData getBytes:&randomBytesLength range:NSMakeRange(4, 1)];
                                while ((randomBytesLength + 1) % 4 != 0)
                                {
                                    randomBytesLength++;
                                }
                                
                                if (messageContentData.length >= 4 + 1 + randomBytesLength + 4 + 4 + 4)
                                {
                                    int32_t value = 0;
                                    [messageContentData getBytes:&value range:NSMakeRange(4 + 1 + randomBytesLength, 4)];
                                    layer = value;
                                    
                                    [messageContentData getBytes:&value range:NSMakeRange(4 + 1 + randomBytesLength + 4, 4)];
                                    if (outSeqIn)
                                        *outSeqIn = value / 2;
                                    seqIn = value;
                                    
                                    [messageContentData getBytes:&value range:NSMakeRange(4 + 1 + randomBytesLength + 4 + 4, 4)];
                                    if (outSeqOut)
                                        *outSeqOut = value / 2;
                                    seqOut = value;
                                }
                            }
                            
                            layer = MAX(1U, layer);
                        }
                        
                        if (decryptedLayer)
                            *decryptedLayer = layer;
                        
                        if (layer >= 17)
                        {
                            bool isCreator = [TGDatabaseInstance() encryptedConversationIsCreator:conversationId];
                            if (isCreator)
                            {
                                if ((seqIn & 1) == 0)
                                {
                                    TGLog(@"***** Ignoring message from conversation %lld with seq_in %d", encryptedMessage.chat_id, seqIn);
                                    return nil;
                                }
                                if (seqOut & 1)
                                {
                                    TGLog(@"***** Ignoring message from conversation %lld with seq_out %d", encryptedMessage.chat_id, seqOut);
                                    return nil;
                                }
                            }
                            else
                            {
                                if (seqIn & 1)
                                {
                                    TGLog(@"***** Ignoring message from conversation %lld with seq_in %d", encryptedMessage.chat_id, seqIn);
                                    return nil;
                                }
                                if ((seqOut & 1) == 0)
                                {
                                    TGLog(@"***** Ignoring message from conversation %lld with seq_out %d", encryptedMessage.chat_id, seqOut);
                                    return nil;
                                }
                            }
                        }
                    }
                    
                    int fromUid = 0;
                    bool fromFound = false;
                    
                    if (cachedParticipantIds != NULL)
                    {
                        auto it = cachedParticipantIds->find(encryptedMessage.chat_id);
                        if (it != cachedParticipantIds->end())
                        {
                            fromFound = true;
                            fromUid = it->second;
                        }
                    }
                    
                    if (!fromFound)
                    {
                        fromUid = [TGDatabaseInstance() encryptedParticipantIdForConversationId:conversationId];
                        
                        if (cachedParticipantIds != NULL)
                            (*cachedParticipantIds)[encryptedMessage.chat_id] = fromUid;
                    }
                    
                    if (fromUid != 0)
                    {
                        return messageContentData;
                    }
                    else
                        TGLog(@"***** Couldn't find participant uid for conversation %lld", encryptedMessage.chat_id);
                }
            }
        }
        else if (key != nil && keyId != localKeyId)
            TGLog(@"***** Ignoring message from conversation with key fingerprint mismatch %lld", encryptedMessage.chat_id);
        else
            TGLog(@"***** Not decrypting message from conversation with missing key %" PRId64 "", keyId);
    }
    else
    {
        TGLog(@"***** Ignoring message from unknown encrypted conversation %lld", encryptedMessage.chat_id);
        
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/encrypted/discardEncryptedChat/(%lld)", (int64_t)encryptedMessage.chat_id] options:@{@"encryptedConversationId": @((int64_t)encryptedMessage.chat_id)} flags:0 watcher:TGTelegraphInstance];
    }
    
    return nil;
}

@end
