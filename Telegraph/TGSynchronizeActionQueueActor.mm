#import "TGSynchronizeActionQueueActor.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TLMetaClassStore.h"
#import "TGModernSendSecretMessageActor.h"

#import "TLUpdates+TG.h"

@interface TGSynchronizeActionQueueActor ()
{
    SMetaDisposable *_currentDisposable;
}

@property (nonatomic) bool bypassQueue;

@property (nonatomic, strong) NSArray *currentMids;

@property (nonatomic) int64_t currentReadConversationId;
@property (nonatomic) int currentReadMaxMid;

@property (nonatomic) int64_t currentDeleteConversationId;
@property (nonatomic) int32_t currentDeleteConversationTopMessageId;
@property (nonatomic) bool currentClearConversation;

@property (nonatomic, strong) NSArray *currentSecretActions;

@end

@implementation TGSynchronizeActionQueueActor

+ (NSString *)genericPath
{
    return @"/tg/service/synchronizeactionqueue/@";
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _currentDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_currentDisposable dispose];
}

- (void)prepare:(NSDictionary *)__unused options
{
    NSNumber *nBypassQueue = [options objectForKey:@"bypassQueue"];
    if (nBypassQueue == nil || ![nBypassQueue boolValue])
        self.requestQueueName = @"messages";
}

- (void)execute:(NSDictionary *)__unused options
{
    [TGDatabaseInstance() checkIfLatestMessageIdIsNotApplied:^(int midForSinchronization)
    {
        if (midForSinchronization > 0)
        {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/messages/reportDelivery/(messages)"] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:midForSinchronization], @"mid", nil] watcher:TGTelegraphInstance];
        }
    }];
    
    [TGDatabaseInstance() checkIfLatestQtsIsNotApplied:^(int qtsForSinchronization)
    {
        if (qtsForSinchronization > 0)
        {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/messages/reportDelivery/(qts)"] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:qtsForSinchronization], @"qts", nil] watcher:TGTelegraphInstance];
        }
    }];
    
    [TGDatabaseInstance() loadQueuedActions:[NSArray arrayWithObjects:[NSNumber numberWithInt:TGDatabaseActionReadConversation], [NSNumber numberWithInt:TGDatabaseActionDeleteMessage], [NSNumber numberWithInt:TGDatabaseActionClearConversation], [NSNumber numberWithInt:TGDatabaseActionDeleteConversation], @(TGDatabaseActionDeleteSecretMessage), @(TGDatabaseActionClearSecretConversation), @(TGDatabaseActionReadMessageContents), @(TGDatabaseActionScreenshotMessage), nil] completion:^(NSDictionary *actionSetsByType)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            NSArray *readConversationActions = [actionSetsByType objectForKey:[NSNumber numberWithInt:TGDatabaseActionReadConversation]];
            NSArray *deleteMessageActions = [actionSetsByType objectForKey:[NSNumber numberWithInt:TGDatabaseActionDeleteMessage]];
            NSArray *deleteSecretMessageActions = [actionSetsByType objectForKey:[NSNumber numberWithInt:TGDatabaseActionDeleteSecretMessage]];
            NSArray *deleteConversationActions = [actionSetsByType objectForKey:[NSNumber numberWithInt:TGDatabaseActionDeleteConversation]];
            NSArray *clearConversationActions = [actionSetsByType objectForKey:[NSNumber numberWithInt:TGDatabaseActionClearConversation]];
            NSArray *clearSecretConversationsActions = [actionSetsByType objectForKey:@(TGDatabaseActionClearSecretConversation)];
            NSArray *readMessageContentActions = [actionSetsByType objectForKey:@(TGDatabaseActionReadMessageContents)];
            NSArray *screenshotMessageContentActions = [actionSetsByType objectForKey:@(TGDatabaseActionScreenshotMessage)];
            
            if (readConversationActions.count != 0)
            {
                TGDatabaseAction action;
                [(NSValue *)[readConversationActions objectAtIndex:0] getValue:&action];
                _currentReadConversationId = action.subject;
                _currentReadMaxMid = action.arg0;
                
                if (_currentReadConversationId <= INT_MIN)
                {
                    int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:_currentReadConversationId];
                    int64_t accessHash = [TGDatabaseInstance() encryptedConversationAccessHash:_currentReadConversationId];
                    
                    if (encryptedConversationId != 0 && accessHash != 0)
                        self.cancelToken = [TGTelegraphInstance doReadEncrytedHistory:encryptedConversationId accessHash:accessHash maxDate:_currentReadMaxMid actor:self];
                    else
                        [self readMessagesSuccess:nil];
                }
                else
                    self.cancelToken = [TGTelegraphInstance doConversationReadHistory:action.subject accessHash:0 maxMid:action.arg0 offset:0 actor:self];
            }
            else if (deleteMessageActions.count != 0)
            {
                NSMutableArray *messageIdsForSelf = [[NSMutableArray alloc] init];
                NSMutableArray *messageIdsForEveryone = [[NSMutableArray alloc] init];
                for (NSValue *value in deleteMessageActions)
                {
                    TGDatabaseAction action;
                    [value getValue:&action];
                    
                    if (action.arg0 & 1) {
                        [messageIdsForEveryone addObject:[[NSNumber alloc] initWithInt:(int)action.subject]];
                    } else {
                        [messageIdsForSelf addObject:[[NSNumber alloc] initWithInt:(int)action.subject]];
                    }
                }
                
                SSignal *deleteForSelf = [SSignal complete];
                SSignal *deleteForEveryone = [SSignal complete];
                
                if (messageIdsForSelf.count != 0) {
                    TLRPCmessages_deleteMessages$messages_deleteMessages *deleteMessages = [[TLRPCmessages_deleteMessages$messages_deleteMessages alloc] init];
                    deleteMessages.n_id = messageIdsForSelf;
                    deleteForSelf = [[[[[TGTelegramNetworking instance] requestSignal:deleteMessages] catch:^SSignal *(__unused id error) {
                        return [SSignal complete];
                    }] onNext:^(TLmessages_AffectedMessages *result) {
                        if (result != nil)
                            [[TGTelegramNetworking instance] updatePts:result.pts ptsCount:result.pts_count seq:0];
                        
                        NSMutableArray *actions = [[NSMutableArray alloc] initWithCapacity:_currentMids.count];
                        for (NSNumber *nMid in messageIdsForSelf)
                        {
                            TGDatabaseAction action = { .type = TGDatabaseActionDeleteMessage, .subject = [nMid intValue], .arg0 = 0, .arg1 = 0 };
                            [actions addObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]];
                        }
                        [TGDatabaseInstance() confirmQueuedActions:actions requireFullMatch:false];
                    }] onError:^(__unused id error) {
                        NSMutableArray *actions = [[NSMutableArray alloc] initWithCapacity:_currentMids.count];
                        for (NSNumber *nMid in messageIdsForSelf)
                        {
                            TGDatabaseAction action = { .type = TGDatabaseActionDeleteMessage, .subject = [nMid intValue], .arg0 = 0, .arg1 = 0 };
                            [actions addObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]];
                        }
                        [TGDatabaseInstance() confirmQueuedActions:actions requireFullMatch:false];
                    }];
                }
                
                if (messageIdsForEveryone.count != 0) {
                    TLRPCmessages_deleteMessages$messages_deleteMessages *deleteMessages = [[TLRPCmessages_deleteMessages$messages_deleteMessages alloc] init];
                    deleteMessages.n_id = messageIdsForEveryone;
                    deleteMessages.flags = (1 << 0);
                    deleteForEveryone = [[[[[TGTelegramNetworking instance] requestSignal:deleteMessages] catch:^SSignal *(__unused id error) {
                        return [SSignal complete];
                    }] onNext:^(TLmessages_AffectedMessages *result) {
                        if (result != nil)
                            [[TGTelegramNetworking instance] updatePts:result.pts ptsCount:result.pts_count seq:0];
                        
                        NSMutableArray *actions = [[NSMutableArray alloc] initWithCapacity:_currentMids.count];
                        for (NSNumber *nMid in messageIdsForEveryone)
                        {
                            TGDatabaseAction action = { .type = TGDatabaseActionDeleteMessage, .subject = [nMid intValue], .arg0 = 0, .arg1 = 0 };
                            [actions addObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]];
                        }
                        [TGDatabaseInstance() confirmQueuedActions:actions requireFullMatch:false];
                    }] onError:^(__unused id error) {
                        NSMutableArray *actions = [[NSMutableArray alloc] initWithCapacity:_currentMids.count];
                        for (NSNumber *nMid in messageIdsForEveryone)
                        {
                            TGDatabaseAction action = { .type = TGDatabaseActionDeleteMessage, .subject = [nMid intValue], .arg0 = 0, .arg1 = 0 };
                            [actions addObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]];
                        }
                        [TGDatabaseInstance() confirmQueuedActions:actions requireFullMatch:false];
                    }];
                }
                
                __weak TGSynchronizeActionQueueActor *weakSelf = self;
                void (^completed)() = ^{
                    __strong TGSynchronizeActionQueueActor *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf execute:nil];
                    }
                };
                
                [_currentDisposable setDisposable:[[SSignal mergeSignals:@[deleteForSelf, deleteForEveryone]] startWithNext:nil error:^(__unused id error) {
                    completed();
                } completed:^{
                    completed();
                }]];
            }
            else if (deleteSecretMessageActions.count != 0)
            {
                int64_t currentConversationId = 0;
                
                NSMutableArray *messageIds = [[NSMutableArray alloc] init];
                NSMutableArray *currentActions = [[NSMutableArray alloc] init];
                
                for (NSValue *value in deleteSecretMessageActions)
                {
                    TGDatabaseAction action;
                    [value getValue:&action];
                    
                    int64_t conversationId = 0;
                    ((int32_t *)&conversationId)[0] = action.arg0;
                    ((int32_t *)&conversationId)[1] = action.arg1;
                    
                    if (currentConversationId == 0 || conversationId == currentConversationId)
                    {
                        currentConversationId = conversationId;
                        
                        [messageIds addObject:@((int32_t)action.subject)];
                        [currentActions addObject:value];
                    }
                }
                
                std::map<int32_t, int64_t> messageIdToRandomId;
                [TGDatabaseInstance() randomIdsForMessageIds:messageIds mapping:&messageIdToRandomId];
                NSMutableArray *randomIds = [[NSMutableArray alloc] init];
                for (auto it : messageIdToRandomId)
                {
                    [randomIds addObject:@(it.second)];
                }
                
                int64_t messageRandomId = 0;
                arc4random_buf(&messageRandomId, 8);
                
                NSUInteger peerLayer = [TGDatabaseInstance() peerLayer:currentConversationId];
                
                NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) deleteMessagesWithRandomIds:randomIds randomId:messageRandomId];
                
                if (messageData != nil)
                {
                    [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:currentConversationId layer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) keyId:0 randomId:messageRandomId messageData:messageData];
                }
                
                [TGDatabaseInstance() confirmQueuedActions:currentActions requireFullMatch:true];
                [self execute:nil];
            }
            else if (deleteConversationActions.count != 0)
            {
                for (NSValue *value in deleteConversationActions)
                {
                    TGDatabaseAction action;
                    [value getValue:&action];
                }
                
                TGDatabaseAction action;
                [(NSValue *)[deleteConversationActions objectAtIndex:0] getValue:&action];
                _currentDeleteConversationId = action.subject;
                _currentDeleteConversationTopMessageId = action.arg0;
                
                _currentClearConversation = false;
                
                if (_currentDeleteConversationId < 0)
                {
                    if (action.subject < 0)
                        [TGUpdateStateRequestBuilder addIgnoreConversationId:_currentDeleteConversationId];
                    
                    if (_currentDeleteConversationId <= INT_MIN)
                    {
                        int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:_currentDeleteConversationId];
                        
                        [ActionStageInstance() dispatchResource:@"/tg/service/cancelAcceptEncryptedChat" resource:@(encryptedConversationId)];
                        
                        if (encryptedConversationId != 0)
                            self.cancelToken = [TGTelegraphInstance doRejectEncryptedChat:encryptedConversationId actor:self];
                        else
                            [self rejectEncryptedChatSuccess];
                    }
                    else
                        self.cancelToken = [TGTelegraphInstance doDeleteConversationMember:_currentDeleteConversationId uid:TGTelegraphInstance.clientUserId actor:self];
                }
                else
                {
                    if (_currentDeleteConversationId <= INT_MIN)
                        [self deleteHistorySuccess:nil];
                    else
                        self.cancelToken = [TGTelegraphInstance doDeleteConversation:_currentDeleteConversationId onlyClear:false maxId:_currentDeleteConversationTopMessageId accessHash:0 offset:0 actor:self];
                }
            }
            else if (clearConversationActions.count != 0)
            {
                TGDatabaseAction action;
                [(NSValue *)[clearConversationActions objectAtIndex:0] getValue:&action];
                _currentDeleteConversationId = action.subject;
                _currentDeleteConversationTopMessageId = action.arg0;
                
                _currentClearConversation = true;
                
                if (_currentDeleteConversationId <= INT_MIN)
                    [self deleteHistorySuccess:nil];
                else
                    self.cancelToken = [TGTelegraphInstance doDeleteConversation:_currentDeleteConversationId onlyClear:true maxId:_currentDeleteConversationTopMessageId accessHash:0 offset:0 actor:self];
            }
            else if (clearSecretConversationsActions.count != 0)
            {
                int64_t currentConversationId = 0;
                
                TGDatabaseAction action;
                [clearSecretConversationsActions[0] getValue:&action];
                
                NSArray *currentActions = @[clearSecretConversationsActions[0]];
                currentConversationId = action.subject;
                
                int64_t messageRandomId = 0;
                arc4random_buf(&messageRandomId, 8);
                
                NSUInteger peerLayer = [TGDatabaseInstance() peerLayer:currentConversationId];
                
                NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) flushHistoryWithRandomId:messageRandomId];
                
                if (messageData != nil)
                {
                    [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:currentConversationId layer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) keyId:0 randomId:messageRandomId messageData:messageData];
                }
                
                [TGDatabaseInstance() confirmQueuedActions:currentActions requireFullMatch:true];
                [self execute:nil];
            }
            else if (readMessageContentActions.count != 0)
            {
                TLRPCmessages_readMessageContents$messages_readMessageContents *readMessageContents = [[TLRPCmessages_readMessageContents$messages_readMessageContents alloc] init];
                
                NSMutableArray *messageIds = [[NSMutableArray alloc] init];
                for (NSValue *value in readMessageContentActions)
                {
                    TGDatabaseAction action;
                    [value getValue:&action];
                    [messageIds addObject:@((int32_t)action.subject)];
                }
                readMessageContents.n_id = messageIds;
                
                __weak TGSynchronizeActionQueueActor *weakSelf = self;
                [_currentDisposable setDisposable:[[[TGTelegramNetworking instance] requestSignal:readMessageContents] startWithNext:nil error:^(__unused id error)
                {
                    __strong TGSynchronizeActionQueueActor *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [TGDatabaseInstance() confirmQueuedActions:readMessageContentActions requireFullMatch:false];
                        [strongSelf execute:nil];
                    }
                } completed:^
                {
                    __strong TGSynchronizeActionQueueActor *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [TGDatabaseInstance() confirmQueuedActions:readMessageContentActions requireFullMatch:false];
                        [strongSelf execute:nil];
                    }
                }]];
            }
            else if (screenshotMessageContentActions.count != 0) {
                TLRPCmessages_sendScreenshotNotification$messages_sendScreenshotNotification *sendScreenshotNotification = [[TLRPCmessages_sendScreenshotNotification$messages_sendScreenshotNotification alloc] init];
                
                NSValue *value = screenshotMessageContentActions.firstObject;
                TGDatabaseAction action;
                [value getValue:&action];
                
                int64_t messageRandomId = 0;
                arc4random_buf(&messageRandomId, 8);
                sendScreenshotNotification.random_id = messageRandomId;
                
                sendScreenshotNotification.reply_to_msg_id = action.arg0;
                
                sendScreenshotNotification.peer = [TGTelegraphInstance createInputPeerForConversation:action.subject accessHash:0];
                
                if (sendScreenshotNotification.peer == nil) {
                    if (screenshotMessageContentActions.count != 0) {
                        [TGDatabaseInstance() confirmQueuedActions:@[screenshotMessageContentActions.firstObject] requireFullMatch:true];
                    }
                    [self execute:nil];
                } else {
                    __weak TGSynchronizeActionQueueActor *weakSelf = self;
                    [_currentDisposable setDisposable:[[[TGTelegramNetworking instance] requestSignal:sendScreenshotNotification] startWithNext:^(TLUpdates *updates) {
                        [[TGTelegramNetworking instance] addUpdates:updates];
                    } error:^(__unused id error)
                    {
                        __strong TGSynchronizeActionQueueActor *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            if (screenshotMessageContentActions.count != 0) {
                                [TGDatabaseInstance() confirmQueuedActions:@[screenshotMessageContentActions.firstObject] requireFullMatch:true];
                            }
                            [strongSelf execute:nil];
                        }
                    } completed:^
                    {
                        __strong TGSynchronizeActionQueueActor *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            if (screenshotMessageContentActions.count != 0) {
                                [TGDatabaseInstance() confirmQueuedActions:@[screenshotMessageContentActions.firstObject] requireFullMatch:true];
                            }
                            [strongSelf execute:nil];
                        }
                    }]];
                }
            }
            else
            {
                [ActionStageInstance() actionCompleted:self.path result:nil];
            }
        }];
    }];
}

- (void)readMessagesSuccess:(TLmessages_AffectedMessages *)affectedMessages
{
    if (affectedMessages != nil)
    {
        [[TGTelegramNetworking instance] updatePts:affectedMessages.pts ptsCount:affectedMessages.pts_count seq:0];
    }
    
    TGDatabaseAction action = { .type = TGDatabaseActionReadConversation, .subject = _currentReadConversationId, .arg0 = _currentReadMaxMid, .arg1 = 0 };
    [TGDatabaseInstance() confirmQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]] requireFullMatch:false];
    
    [self execute:nil];
}

- (void)readMessagesFailed
{
    TGDatabaseAction action = { .type = TGDatabaseActionReadConversation, .subject = _currentReadConversationId, .arg0 = _currentReadMaxMid, .arg1 = 0 };
    [TGDatabaseInstance() confirmQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]] requireFullMatch:false];
    
    [self execute:nil];
}

- (void)deleteMessagesSuccess:(TLmessages_AffectedMessages *)result
{
    if (result != nil)
        [[TGTelegramNetworking instance] updatePts:result.pts ptsCount:result.pts_count seq:0];
    
    NSMutableArray *actions = [[NSMutableArray alloc] initWithCapacity:_currentMids.count];
    for (NSNumber *nMid in _currentMids)
    {
        TGDatabaseAction action = { .type = TGDatabaseActionDeleteMessage, .subject = [nMid intValue], .arg0 = 0, .arg1 = 0 };
        [actions addObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]];
    }
    [TGDatabaseInstance() confirmQueuedActions:actions requireFullMatch:false];
    
    [self execute:nil];
}

- (void)deleteMessagesFailed
{
    [self deleteHistorySuccess:nil];
}

- (void)deleteHistorySuccess:(TLmessages_AffectedHistory *)affectedHistory
{
    if (affectedHistory != nil)
        [[TGTelegramNetworking instance] updatePts:affectedHistory.pts ptsCount:affectedHistory.pts_count seq:0];
    
    if (affectedHistory.offset > 0)
    {
        self.cancelToken = [TGTelegraphInstance doDeleteConversation:_currentDeleteConversationId onlyClear:_currentClearConversation maxId:_currentDeleteConversationTopMessageId accessHash:0 offset:affectedHistory.offset actor:self];
    }
    else
    {
        TGDatabaseAction action = { .type = _currentClearConversation ? TGDatabaseActionClearConversation : TGDatabaseActionDeleteConversation, .subject = _currentDeleteConversationId, .arg0 = _currentDeleteConversationTopMessageId, .arg1 = 0 };
        [TGDatabaseInstance() confirmQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]] requireFullMatch:false];
        
        [self execute:nil];
    }
}

- (void)deleteHistoryFailed
{
    [self deleteHistorySuccess:nil];
}

- (void)deleteMemberSuccess:(TLUpdates *)updates
{
    int32_t pts = 0;
    int32_t pts_count = 0;
    if ([updates maxPtsAndCount:&pts ptsCount:&pts_count])
        [[TGTelegramNetworking instance] updatePts:pts ptsCount:pts_count seq:0];
    else
        [[TGTelegramNetworking instance] addUpdates:updates];
    
    [TGUpdateStateRequestBuilder removeIgnoreConversationId:_currentDeleteConversationId];
    
    self.cancelToken = [TGTelegraphInstance doDeleteConversation:_currentDeleteConversationId onlyClear:false maxId:0 accessHash:0 offset:0 actor:self];
}

- (void)deleteMemberFailed
{
    [TGUpdateStateRequestBuilder removeIgnoreConversationId:_currentDeleteConversationId];
    
    self.cancelToken = [TGTelegraphInstance doDeleteConversation:_currentDeleteConversationId onlyClear:false maxId:0 accessHash:0 offset:0 actor:self];
}

- (void)rejectEncryptedChatSuccess
{
    [TGUpdateStateRequestBuilder removeIgnoreConversationId:_currentDeleteConversationId];
    
    [self deleteHistorySuccess:nil];
}

- (void)rejectEncryptedChatFailed
{
    [TGUpdateStateRequestBuilder removeIgnoreConversationId:_currentDeleteConversationId];
    
    [self deleteHistorySuccess:nil];
}

- (void)readEncryptedSuccess
{
    [self readMessagesSuccess:nil];
}

- (void)readEncryptedFailed
{
    [self readMessagesSuccess:nil];
}

- (void)sendEncryptedServiceMessageSuccess:(int)__unused date
{
    [TGDatabaseInstance() confirmQueuedActions:_currentSecretActions requireFullMatch:true];
    [self execute:nil];
}

- (void)sendEncryptedServiceMessageFailed
{
    [self sendEncryptedServiceMessageSuccess:0];
}

@end
