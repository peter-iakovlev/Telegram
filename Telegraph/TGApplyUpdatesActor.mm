#import "TGApplyUpdatesActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGUser+Telegraph.h"
#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"
#import "TGUserDataRequestBuilder.h"

#import "TGUser+Telegraph.h"

#import "TGTimelineItem.h"

#import "TGConversationAddMessagesActor.h"
#import "TGConversationReadMessagesActor.h"
#import "TGApplyStateRequestBuilder.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGUpdate.h"

#import "TLUpdate$updateChangePts.h"

#import <set>
#import <map>

static inline void maybeProcessUser(TLUser *user, std::map<int, TLUser *> &processedUsers)
{    
    int uid = user.n_id;
    
    if (uid != 0)
    {
        processedUsers[uid] = user;
    }
}

static inline void maybeProcessChat(TLChat *chat, std::map<int, TLChat *> &processedChats)
{
    int chatId = chat.n_id;
    
    if (chatId != 0)
        processedChats[chatId] = chat;
}

static NSMutableArray *delayedNotifications()
{
    static NSMutableArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        array = [[NSMutableArray alloc] init];
    });
    return array;
}

@interface TGApplyUpdatesActor ()

@property (nonatomic, strong) NSMutableArray *statefulUpdates;
@property (nonatomic, strong) TGTimer *sequenceTimeoutTimer;
@property (nonatomic) NSTimeInterval accumulatedTimeout;

@end

@implementation TGApplyUpdatesActor

@synthesize statefulUpdates = _statefulUpdates;
@synthesize sequenceTimeoutTimer = _sequenceTimeoutTimer;
@synthesize accumulatedTimeout = _accumulatedTimeout;

+ (NSString *)genericPath
{
    return @"/tg/service/tryupdates/@";
}

+ (void)clearState
{
    [TGApplyUpdatesActor clearDelayedNotifications];
}

+ (void)clearDelayedNotifications
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [delayedNotifications() removeAllObjects];
    }];
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _statefulUpdates = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self cancelSequenceTimer];
}

- (void)prepare:(NSDictionary *)options
{
    bool messagesQueue = false;
    
    if ([[options objectForKey:@"stateful"] boolValue])
        messagesQueue = true;
    
    if (messagesQueue)
        self.requestQueueName = @"messages";
}

- (void)execute:(NSDictionary *)options
{
    if ([[options objectForKey:@"stateful"] boolValue])
    {
        [_statefulUpdates addObjectsFromArray:[options objectForKey:@"multipleUpdates"]];
        
        if (_statefulUpdates.count == 0)
        {
            [ActionStageInstance() actionCompleted:self.path result:nil];
            
            return;
        }
        
        [self checkStatefulUpdates];
    }
    else
        [self processUpdates:[options objectForKey:@"multipleUpdates"] stateSeq:0 completeAction:true];
}

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    if ([self.path hasSuffix:@"stateful)"])
    {
        [_statefulUpdates addObjectsFromArray:[options objectForKey:@"multipleUpdates"]];
        
        if (!waitingInActorQueue)
            [self checkStatefulUpdates];
    }
    
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
}

- (void)cancelSequenceTimer
{
    if (_sequenceTimeoutTimer != nil)
    {
        [_sequenceTimeoutTimer invalidate];
        _sequenceTimeoutTimer = nil;
    }
}

- (void)checkStatefulUpdates
{
    TGDatabaseState databaseState = [[TGDatabase instance] databaseState];
    
    [_statefulUpdates sortUsingComparator:^NSComparisonResult(TGUpdate *updateSet1, TGUpdate *updateSet2)
    {
        if (updateSet1.beginSeq < updateSet2.beginSeq)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }];
    
    int count = _statefulUpdates.count;
    for (int i = 0; i < count; i++)
    {
        int currentSeq = ((TGUpdate *)[_statefulUpdates objectAtIndex:0]).beginSeq;
        if (currentSeq <= databaseState.seq)
        {
#ifdef DEBUG
            TGLog(@"Ignoring old update %d", currentSeq);
#endif
            
            [_statefulUpdates removeObjectAtIndex:i];
            i--;
            count--;
        }
    }
    
    if (_statefulUpdates.count == 0)
    {
        [self cancelSequenceTimer];
        [ActionStageInstance() actionCompleted:self.path result:nil];
        
        return;
    }
    
    int stateMinSeq = ((TGUpdate *)[_statefulUpdates objectAtIndex:0]).beginSeq;
    int stateMaxSeq = ((TGUpdate *)[_statefulUpdates lastObject]).endSeq;
    
    if (stateMinSeq != databaseState.seq + 1)
    {
        TGLog(@"***** Invalid update sequence (starting seq = %d, should be %d)! Waiting for the rest.", stateMinSeq, databaseState.seq + 1);
        
        if (_sequenceTimeoutTimer == nil)
        {
            _sequenceTimeoutTimer = [[TGTimer alloc] initWithTimeout:2.0 repeat:false completion:^
            {
                [self failSequence];
            } queue:[ActionStageInstance() globalStageDispatchQueue]];
            [_sequenceTimeoutTimer start];
        }
    }
    else
    {
        bool chainError = false;
        
        int correctUpdatesChainLength = 0;
        
        int lastSeq = stateMinSeq - 1;
        count = _statefulUpdates.count;
        for (int i = 0; i < count; i++)
        {
            int currentSeq = ((TGUpdate *)[_statefulUpdates objectAtIndex:i]).beginSeq;
            if (currentSeq != lastSeq + 1)
            {
                TGLog(@"***** Update seq chain error: missing %d before %d", lastSeq + 1, currentSeq);
                
                chainError = true;
                
                break;
            }
            else
                correctUpdatesChainLength++;
            
            lastSeq = ((TGUpdate *)[_statefulUpdates objectAtIndex:i]).endSeq;
        }
        
        if (chainError)
        {
            if (correctUpdatesChainLength != 0)
            {
                NSMutableArray *completeUpdates = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < correctUpdatesChainLength; i++)
                {
                    TGUpdate *update = [_statefulUpdates objectAtIndex:0];
                    [completeUpdates addObject:update];
                    [_statefulUpdates removeObjectAtIndex:0];
                }
                
                if (completeUpdates.count != 0)
                {
                    int maxValidSeq = ((TGUpdate *)[completeUpdates lastObject]).endSeq;
                    TGLog(@"Processing updates from %d to %d", ((TGUpdate *)[completeUpdates objectAtIndex:0]).beginSeq, maxValidSeq);
                    [self processUpdates:completeUpdates stateSeq:maxValidSeq completeAction:false];
                }
            }
            
            if (_sequenceTimeoutTimer == nil)
            {
                _sequenceTimeoutTimer = [[TGTimer alloc] initWithTimeout:2.0 repeat:false completion:^
                {
                    [self failSequence];
                } queue:[ActionStageInstance() globalStageDispatchQueue]];
                [_sequenceTimeoutTimer start];
            }
        }
        else
        {
            [self cancelSequenceTimer];
            [self processUpdates:_statefulUpdates stateSeq:stateMaxSeq completeAction:true];
        }
    }
}

- (void)failSequence
{
    TGLog(@"***** Inconsistent state! Synchronization required.");
    
    [self cancelSequenceTimer];
    
    [TGTelegraphInstance stateUpdateRequired];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

template<typename T>
static int64_t extractMessageConversationId(T concreteMessage, int &outFromUid)
{
    int64_t fromUid = concreteMessage.from_id;
    bool outgoing = concreteMessage.out;
    
    if (!outgoing)
        outFromUid = (int)fromUid;
    
    if ([concreteMessage.to_id isKindOfClass:[TLPeer$peerUser class]])
    {
        TLPeer$peerUser *toUser = (TLPeer$peerUser *)concreteMessage.to_id;
        int64_t toUid = toUser.user_id;
        if (toUid == fromUid && !outgoing)
            outgoing = true;
        return outgoing ? toUid : fromUid;
    }
    else if ([concreteMessage.to_id isKindOfClass:[TLPeer$peerChat class]])
    {
        TLPeer$peerChat *toChat = (TLPeer$peerChat *)concreteMessage.to_id;
        int64_t toUid = -toChat.chat_id;
        return toUid;
    }
    
    return 0;
}

- (void)processUpdates:(NSArray *)updatesArray stateSeq:(int)stateSeq completeAction:(bool)completeAction
{
    static Class updateNewMessageClass = nil;
    static Class updateNewEncryptedMessageClass = nil;
    static Class updateReadMessagesClass = nil;
    static Class updateDeleteMessagesClass = nil;
    static Class updateRestoreMessagesClass = nil;
    static Class updateChangePtsClass = nil;
    static Class updateUserTypingClass = nil;
    static Class updateChatUserTypingClass = nil;
    static Class updateChatParticipantsClass = nil;
    static Class updateChatParticipantAddClass = nil;
    static Class updateChatParticipantDeleteClass = nil;
    static Class updateContactLocatedClass = nil;
    
    static Class messageClass = nil;
    static Class messageServiceClass = nil;
    static Class messageForwardedClass = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        updateNewMessageClass = [TLUpdate$updateNewMessage class];
        updateNewEncryptedMessageClass = [TLUpdate$updateNewEncryptedMessage class];
        updateReadMessagesClass = [TLUpdate$updateReadMessages class];
        updateDeleteMessagesClass = [TLUpdate$updateDeleteMessages class];
        updateRestoreMessagesClass = [TLUpdate$updateRestoreMessages class];
        updateChangePtsClass = [TLUpdate$updateChangePts class];
        updateUserTypingClass = [TLUpdate$updateUserTyping class];
        updateChatUserTypingClass = [TLUpdate$updateChatUserTyping class];
        updateChatParticipantsClass = [TLUpdate$updateChatParticipants class];
        updateChatParticipantAddClass = [TLUpdate$updateChatParticipantAdd class];
        updateChatParticipantDeleteClass = [TLUpdate$updateChatParticipantDelete class];
        updateContactLocatedClass = [TLUpdate$updateContactLocated class];
        
        messageClass = [TLMessage$message class];
        messageServiceClass = [TLMessage$messageService class];
        messageForwardedClass = [TLMessage$messageForwarded class];
    });
    
    int statePts = 0;
    int stateDate = 0;
    int stateQts = 0;
    
    TGDatabaseState databaseState = [[TGDatabase instance] databaseState];
    
    for (TGUpdate *updateSet in updatesArray)
    {
        int date = updateSet.date;
        if (date > stateDate)
            stateDate = date;
        
        for (TLUpdate *update in updateSet.updates)
        {
            if ([update isKindOfClass:updateNewMessageClass])
            {
                int updatePts = ((TLUpdate$updateNewMessage *)update).pts;
                if (updatePts > statePts)
                    statePts = updatePts;
            }
            else if ([update isKindOfClass:updateReadMessagesClass])
            {
                int updatePts = ((TLUpdate$updateReadMessages *)update).pts;
                if (updatePts > statePts)
                    statePts = updatePts;
            }
            else if ([update isKindOfClass:updateDeleteMessagesClass])
            {
                int updatePts = ((TLUpdate$updateDeleteMessages *)update).pts;
                if (updatePts > statePts)
                    statePts = updatePts;
            }
            else if ([update isKindOfClass:updateRestoreMessagesClass])
            {
                int updatePts = ((TLUpdate$updateRestoreMessages *)update).pts;
                if (updatePts > statePts)
                    statePts = updatePts;
            }
            else if ([update isKindOfClass:updateChangePtsClass])
            {
                int updatePts = ((TLUpdate$updateChangePts *)update).pts;
                if (updatePts > statePts)
                    statePts = updatePts;
            }
            else if ([update isKindOfClass:updateNewEncryptedMessageClass])
            {
                TLUpdate$updateNewEncryptedMessage *encryptedMessageUpdate = (TLUpdate$updateNewEncryptedMessage *)update;
                if (encryptedMessageUpdate.qts > stateQts)
                    stateQts = encryptedMessageUpdate.qts;
            }
        }
    }
    
    std::map<int, TLUser *> processedUsers;
    std::map<int, TLChat *> processedChats;
    
    NSMutableArray *updatesWithDates = [[NSMutableArray alloc] init];
    
    std::set<int> knownUsers;
    std::set<int64_t> knownChats;
    
    NSMutableArray *addedMessages = [[NSMutableArray alloc] init];
    NSMutableArray *messagesForLocalNotification = [[NSMutableArray alloc] init];
    
    NSMutableArray *allUpdates = [[NSMutableArray alloc] init];
    
    int currentTime = (int)[[TGTelegramNetworking instance] globalTime];
    
    bool failedProcessing = false;
    bool updatesTooLong = false;
    
    for (TGUpdate *updateSet in updatesArray)
    {
        int date = updateSet.date;
        
        if (updateSet.usersDesc != nil)
        {
            for (TLUser *userDesc in updateSet.usersDesc)
            {
                maybeProcessUser(userDesc, processedUsers);
            }
        }
        
        if (updateSet.chatsDesc != nil)
        {
            for (TLChat *chatDesc in updateSet.chatsDesc)
            {
                maybeProcessChat(chatDesc, processedChats);
            }
        }
        
        for (TLUpdate *update in updateSet.updates)
        {
            if ([update isKindOfClass:updateNewMessageClass])
            {
                TLUpdate$updateNewMessage *newMessage = (TLUpdate$updateNewMessage *)update;
                
                TLMessage *message = newMessage.message;
                
                if (updateSet.messageDate != 0 && updateSet.messageDate - date < 4 && ([message isKindOfClass:[TLMessage$message class]] || [message isKindOfClass:[TLMessage$messageService class]]) && !((TLMessage$message *)message).out)
                    [messagesForLocalNotification addObject:newMessage.message];
                else
                {
                    //TGLog(@"Message is too old, skipping local notification");
                }
                
                int64_t conversationId = 0;
                int fromUid = 0;
                
                if ([message isKindOfClass:messageClass])
                    conversationId = extractMessageConversationId((TLMessage$message *)message, fromUid);
                else if ([message isKindOfClass:messageServiceClass])
                    conversationId = extractMessageConversationId((TLMessage$messageService *)message, fromUid);
                else if ([message isKindOfClass:messageForwardedClass])
                    conversationId = extractMessageConversationId((TLMessage$messageForwarded *)message, fromUid);
                
                if (conversationId != 0)
                {
                    if (conversationId < 0)
                    {
                        if (knownChats.find(conversationId) == knownChats.end() && processedChats.find(-(int)conversationId) == processedChats.end())
                        {
                            bool contains = [TGDatabaseInstance() containsConversationWithId:conversationId];
                            if (contains)
                                knownChats.insert(conversationId);
                            else
                                failedProcessing = true;
                        }
                    }
                    else
                    {
                        if (knownUsers.find((int)conversationId) == knownUsers.end() && processedUsers.find((int)conversationId) == processedUsers.end())
                        {
                            bool contains = [TGDatabaseInstance() loadUser:(int)conversationId];
                            if (contains)
                                knownUsers.insert((int)conversationId);
                            else
                                failedProcessing = true;
                        }
                    }
                }
                
                if (!failedProcessing && fromUid != 0 && fromUid != conversationId)
                {
                    if (knownUsers.find(fromUid) == knownUsers.end() && processedUsers.find(fromUid) == processedUsers.end())
                    {
                        bool contains = [TGDatabaseInstance() loadUser:fromUid];
                        if (contains)
                            knownUsers.insert(fromUid);
                        else
                            failedProcessing = true;
                    }
                }
                
                if (failedProcessing)
                    break;
                
                [addedMessages addObject:message];
            }
            else if ([update isKindOfClass:updateUserTypingClass])
            {
                if (date > currentTime - 20)
                    [allUpdates addObject:update];
            }
            else if ([update isKindOfClass:updateChatUserTypingClass])
            {
                if (date > currentTime - 20)
                    [allUpdates addObject:update];
            }
            else if ([update isKindOfClass:[TLUpdate$updateEncryptedChatTyping class]])
            {
                if (date > currentTime - 20)
                    [allUpdates addObject:update];
            }
            else if ([update isKindOfClass:updateContactLocatedClass])
            {   
                if (date > currentTime - 5 * 60)
                    [allUpdates addObject:update];
            }
            else if ([update isKindOfClass:updateChatParticipantsClass])
            {
                TLUpdate$updateChatParticipants *updateChatParticipants = (TLUpdate$updateChatParticipants *)update;
                
                int64_t conversationId = -updateChatParticipants.participants.chat_id;
                
                if (conversationId < 0)
                {
                    if (knownChats.find(conversationId) == knownChats.end() && processedChats.find(-(int)conversationId) == processedChats.end())
                    {
                        bool contains = [TGDatabaseInstance() containsConversationWithId:conversationId];
                        if (contains)
                            knownChats.insert(conversationId);
                        else
                            failedProcessing = true;
                    }
                }
                
                [allUpdates addObject:update];
            }
            else if ([update isKindOfClass:updateChatParticipantAddClass] || [update isKindOfClass:updateChatParticipantDeleteClass])
            {
                int64_t conversationId = 0;
                if ([update isKindOfClass:updateChatParticipantAddClass])
                    conversationId = -((TLUpdate$updateChatParticipantAdd *)update).chat_id;
                if ([update isKindOfClass:updateChatParticipantDeleteClass])
                    conversationId = -((TLUpdate$updateChatParticipantDelete *)update).chat_id;
                
                if (conversationId < 0)
                {
                    if (knownChats.find(conversationId) == knownChats.end() && processedChats.find(-(int)conversationId) == processedChats.end())
                    {
                        bool contains = [TGDatabaseInstance() containsConversationWithId:conversationId];
                        if (contains)
                            knownChats.insert(conversationId);
                        else
                            failedProcessing = true;
                    }
                }
                
                [updatesWithDates addObject:@[update, @(date)]];
                [allUpdates addObject:update];
            }
            else if ([update isKindOfClass:[TLUpdate$updateEncryption class]])
            {
                TLUpdate$updateEncryption *updateEncryption = (TLUpdate$updateEncryption *)update;
                
                TGConversation *conversation = [[TGConversation alloc] initWithTelegraphEncryptedChatDesc:updateEncryption.chat];
#if TARGET_IPHONE_SIMULATOR
                if (conversation.conversationId != 0)
#else
                if (conversation.conversationId != 0)
#endif
                {
                    if (conversation.chatParticipants.chatParticipantUids.count != 0)
                    {
                        int userId = [conversation.chatParticipants.chatParticipantUids[0] intValue];
                        if ([TGDatabaseInstance() loadUser:userId] != nil)
                            [allUpdates addObject:update];
                        else
                            failedProcessing = true;
                    }
                    else
                        failedProcessing = true;
                }
                else
                    failedProcessing = true;
            }
            else if ([update isKindOfClass:updateNewEncryptedMessageClass])
            {
                TLUpdate$updateNewEncryptedMessage *updateNewEncryptedMessage = (TLUpdate$updateNewEncryptedMessage *)update;
                
                if (![updateNewEncryptedMessage.message isKindOfClass:[TLEncryptedMessage$encryptedMessageService class]] && updateSet.messageDate != 0 && updateSet.messageDate - date < 4 && updateNewEncryptedMessage.message != nil && stateQts != 0)
                    [messagesForLocalNotification addObject:@{@"message": updateNewEncryptedMessage.message, @"qts": @(stateQts)}];
                
                [allUpdates addObject:update];
            }
            else if ([update isKindOfClass:[TLUpdates$updatesTooLong class]])
            {
                failedProcessing = true;
                updatesTooLong = true;
                
                break;
            }
            else
            {
                [allUpdates addObject:update];
            }
        }
    }
    
    if (!failedProcessing)
    {
        NSMutableArray *usersToProcess = [[NSMutableArray alloc] initWithCapacity:processedUsers.size()];
        
        for (std::map<int, TLUser *>::iterator it = processedUsers.begin(); it != processedUsers.end(); it++)
        {
            [usersToProcess addObject:it->second];
        }
        
        NSMutableArray *chatsToProcess = [[NSMutableArray alloc] initWithCapacity:processedChats.size()];
        
        for (std::map<int, TLChat *>::iterator it = processedChats.begin(); it != processedChats.end(); it++)
        {
            [chatsToProcess addObject:it->second];
        }
        
        [TGUpdateStateRequestBuilder applyUpdates:addedMessages addedParsedMessages:nil otherUpdates:allUpdates addedEncryptedActions:nil usersDesc:usersToProcess chatsDesc:chatsToProcess chatParticipantsDesc:nil updatesWithDates:updatesWithDates];
        
        [delayedNotifications() addObjectsFromArray:messagesForLocalNotification];
        
        if (self.requestQueueName.length != 0 && stateSeq != 0)
        {
            if (stateSeq == 0)
                stateSeq = databaseState.seq;
            
            if (stateDate == 0)
                stateDate = databaseState.date;
            
            if (statePts == 0)
                statePts = databaseState.pts;
            
            if (stateQts == 0)
                stateQts = databaseState.qts;
            
            if (stateQts > 0)
            {
                [TGDatabaseInstance() updateLatestQts:stateQts applied:false completion:^(int greaterQtsForSynchronization)
                {
                    if (greaterQtsForSynchronization > 0)
                    {
                        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/messages/reportDelivery/(qts)"] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:stateQts], @"qts", nil] watcher:TGTelegraphInstance];
                    }
                }];
            }
            
            static int applyStateCounter = 0;
            [[[TGApplyStateRequestBuilder alloc] initWithPath:[NSString stringWithFormat:@"/tg/service/applystate/(a%d)", applyStateCounter++]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:statePts], @"pts", [NSNumber numberWithInt:stateDate], @"date", [NSNumber numberWithInt:stateSeq], @"seq", @(stateQts), @"qts", [NSNumber numberWithInt:-1], @"unreadCount", nil]];
        }
    }
    
    if (completeAction)
        [ActionStageInstance() actionCompleted:self.path result:nil];
    
    if (failedProcessing)
    {
        if (updatesTooLong)
            TGLog(@"===== Updates too long, requesting complete difference");
        else
            TGLog(@"***** Unknown chat or user found, requesting complete difference");
        [TGTelegraphInstance stateUpdateRequired];
    }
}

- (void)cancel
{
    [self cancelSequenceTimer];
    
    [super cancel];
}

+ (void)applyDelayedNotifications:(int)maxMid mids:(NSArray *)mids maxQts:(int)maxQts randomIds:(NSArray *)randomIds
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            if (applicationState != UIApplicationStateActive)
            {
                int globalMessageSoundId = 1;
                bool globalMessagePreviewText = true;
                int globalMessageMuteUntil = 0;
                bool notFound = false;
                [TGDatabaseInstance() loadPeerNotificationSettings:INT_MAX - 1 soundId:&globalMessageSoundId muteUntil:&globalMessageMuteUntil previewText:&globalMessagePreviewText photoNotificationsEnabled:NULL notFound:&notFound];
                if (notFound)
                {
                    globalMessageSoundId = 1;
                    globalMessagePreviewText = true;
                }
                
                int globalGroupSoundId = 1;
                bool globalGroupPreviewText = true;
                int globalGroupMuteUntil = 0;
                notFound = false;
                [TGDatabaseInstance() loadPeerNotificationSettings:INT_MAX - 2 soundId:&globalGroupSoundId muteUntil:&globalGroupMuteUntil previewText:&globalGroupPreviewText photoNotificationsEnabled:NULL notFound:&notFound];
                if (notFound)
                {
                    globalGroupSoundId = 1;
                    globalGroupPreviewText = true;
                }
                
                @try
                {
                    std::set<int> midsSet;
                    for (NSNumber *nMid in mids)
                    {
                        midsSet.insert([nMid intValue]);
                    }
                    
                    std::set<int64_t> randomIdsSet;
                    for (NSNumber *nRandomId in randomIds)
                    {
                        randomIdsSet.insert([nRandomId longLongValue]);
                    }
                    
                    int count = delayedNotifications().count;
                    for (int i = 0; i < count; i++)
                    {
                        TGMessage *message = nil;
                        
                        int messageQts = 0;
                        
                        id abstractDesc = delayedNotifications()[i];
                        if ([abstractDesc respondsToSelector:@selector(allKeys)])
                        {
                            messageQts = [abstractDesc[@"qts"] intValue];
                            abstractDesc = abstractDesc[@"message"];
                        }
                        
                        if ([abstractDesc isKindOfClass:[TLMessage class]])
                        {
                            if (mids == nil)
                                continue;
                            
                            TLMessage *messageDesc = abstractDesc;
                            int mid = messageDesc.n_id;
                            
                            if (mid == 0 || mid > maxMid)
                                continue;
                            
                            [delayedNotifications() removeObjectAtIndex:i];
                            i--;
                            count--;
                            
                            if (midsSet.find(mid) == midsSet.end())
                                continue;
                            
                            message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
                        }
                        else if ([abstractDesc isKindOfClass:[TLEncryptedMessage class]])
                        {
                            if (randomIds == nil)
                                continue;
                            
                            TLEncryptedMessage *encryptedMessage = abstractDesc;
                            
                            if (messageQts > maxQts)
                                continue;
                            
                            [delayedNotifications() removeObjectAtIndex:i];
                            i--;
                            count--;
                            
                            if (randomIdsSet.find(encryptedMessage.random_id) == randomIdsSet.end())
                                continue;
                            
                            message = [[TGMessage alloc] init];
                            message.randomId = encryptedMessage.random_id;
                            message.cid = [TGDatabaseInstance() peerIdForEncryptedConversationId:encryptedMessage.chat_id];
                        }
                        else
                        {
                            TGLog(@"***** unknown notification message type %@", abstractDesc);
                            continue;
                        }
                        
                        if ([TGDatabaseInstance() isPeerMuted:message.cid])
                            continue;
                        
                        if (message.cid > 0 || message.cid <= INT_MIN)
                        {
                            if (globalMessageMuteUntil > 0)
                                continue;
                        }
                        else
                        {
                            if (globalGroupMuteUntil > 0)
                                continue;
                        }
                        
                        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                        if (localNotification == nil)
                            continue;
                        
                        TGUser *user = nil;
                        NSString *chatName = nil;
                        
                        int64_t notificationPeerId = 0;
                        
                        if (message.cid <= INT_MIN)
                        {
                            notificationPeerId = [TGDatabaseInstance() encryptedParticipantIdForConversationId:message.cid];
                        }
                        else if (message.cid > 0)
                        {
                            user = [TGDatabaseInstance() loadUser:(int)message.cid];
                            notificationPeerId = message.cid;
                        }
                        else
                        {
                            user = [TGDatabaseInstance() loadUser:(int)message.fromUid];
                            notificationPeerId = message.cid;
#warning optimize
                            chatName = [TGDatabaseInstance() loadConversationWithId:message.cid].chatTitle;
                        }
                        
                        if ([TGDatabaseInstance() isPeerMuted:notificationPeerId])
                            continue;
                        
                        NSString *text = nil;
                        
                        bool attachmentFound = false;
                        
                        for (TGMediaAttachment *attachment in message.mediaAttachments)
                        {
                            if (attachment.type == TGActionMediaAttachmentType)
                            {
                                TGActionMediaAttachment *actionAttachment = (TGActionMediaAttachment *)attachment;
                                switch (actionAttachment.actionType)
                                {
                                    case TGMessageActionChatEditTitle:
                                    {
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_TITLE_EDITED"), user.displayName, [((TGActionMediaAttachment *)attachment).actionData objectForKey:@"title"]];
                                        attachmentFound = true;
                                        
                                        break;
                                    }
                                    case TGMessageActionChatEditPhoto:
                                    {
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_PHOTO_EDITED"), user.displayName, chatName];
                                        attachmentFound = true;
                                        
                                        break;
                                    }
                                    case TGMessageActionChatAddMember:
                                    {
                                        NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                                        if (nUid != nil)
                                        {
                                            TGUser *subjectUser = [TGDatabaseInstance() loadUser:[nUid intValue]];
                                            
                                            if (subjectUser.uid == user.uid)
                                                text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_RETURNED"), user.displayName, chatName];
                                            else if (subjectUser.uid == TGTelegraphInstance.clientUserId)
                                                text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_ADD_YOU"), user.displayName, chatName];
                                            else
                                                text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_ADD_MEMBER"), user.displayName, chatName, subjectUser.displayName];
                                            attachmentFound = true;
                                        }
                                        
                                        break;
                                    }
                                    case TGMessageActionChatDeleteMember:
                                    {
                                        NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                                        if (nUid != nil)
                                        {
                                            TGUser *subjectUser = [TGDatabaseInstance() loadUser:[nUid intValue]];
                                            
                                            if (subjectUser.uid == user.uid)
                                                text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_LEFT"), user.displayName, chatName];
                                            else if (subjectUser.uid == TGTelegraphInstance.clientUserId)
                                                text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_DELETE_YOU"), user.displayName, chatName];
                                            else
                                                text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_DELETE_MEMBER"), user.displayName, chatName, subjectUser.displayName];
                                            attachmentFound = true;
                                        }
                                        
                                        break;
                                    }
                                    case TGMessageActionCreateChat:
                                    {
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_CREATED"), user.displayName, chatName];
                                        attachmentFound = true;
                                        
                                        break;
                                    }
                                    default:
                                        break;
                                }
                            }
                            else if (attachment.type == TGImageMediaAttachmentType)
                            {
                                if (message.cid > 0)
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_PHOTO"), user.displayName];
                                else
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_PHOTO"), user.displayName, chatName];
                                
                                attachmentFound = true;
                                
                                break;
                            }
                            else if (attachment.type == TGVideoMediaAttachmentType)
                            {
                                if (message.cid > 0)
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_VIDEO"), user.displayName];
                                else
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_VIDEO"), user.displayName, chatName];
                                
                                attachmentFound = true;
                                
                                break;
                            }
                            else if (attachment.type == TGLocationMediaAttachmentType)
                            {
                                if (message.cid > 0)
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_GEO"), user.displayName];
                                else
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_GEO"), user.displayName, chatName];
                                
                                attachmentFound = true;
                                
                                break;
                            }
                            else if (attachment.type == TGContactMediaAttachmentType)
                            {
                                if (message.cid > 0)
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_CONTACT"), user.displayName];
                                else
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_CONTACT"), user.displayName, chatName];
                                
                                attachmentFound = true;
                                
                                break;
                            }
                            else if (attachment.type == TGDocumentMediaAttachmentType)
                            {
                                if (message.cid > 0)
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_DOC"), user.displayName];
                                else
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_DOC"), user.displayName, chatName];
                                
                                attachmentFound = true;
                                
                                break;
                            }
                            else if (attachment.type == TGAudioMediaAttachmentType)
                            {
                                if (message.cid > 0)
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_AUDIO"), user.displayName];
                                else
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_AUDIO"), user.displayName, chatName];
                                
                                attachmentFound = true;
                                
                                break;
                            }
                        }
                        
                        int soundId = 1;
                        bool notFound = false;
                        [TGDatabaseInstance() loadPeerNotificationSettings:notificationPeerId soundId:&soundId muteUntil:NULL previewText:NULL photoNotificationsEnabled:NULL notFound:&notFound];
                        if (notFound)
                        {
                            soundId = 1;
                        }
                        
                        if (soundId == 1)
                            soundId = (message.cid > 0 || message.cid <= INT_MIN) ? globalMessageSoundId : globalGroupSoundId;
                        
                        if (soundId > 0)
                            localNotification.soundName = [[NSString alloc] initWithFormat:@"%d.m4a", soundId];

                        if (message.cid <= INT_MIN)
                        {
                            text = [[NSString alloc] initWithFormat:TGLocalized(@"ENCRYPTED_MESSAGE"), @""];
                        }
                        else if (message.cid > 0)
                        {
                            if (globalMessagePreviewText && !attachmentFound)
                                text = [[NSString alloc] initWithFormat:@"%@: %@", user.displayName, message.text];
                            else
                                text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_NOTEXT"), user.displayName];
                        }
                        else
                        {
                            if (globalGroupPreviewText && !attachmentFound)
                                text = [[NSString alloc] initWithFormat:@"%@@%@: %@", user.displayName, chatName, message.text];
                            else
                                text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_NOTEXT"), user.displayName, chatName];
                        }
                        
                        if (text.length > 256)
                            text = [text substringToIndex:256];
                        
                        localNotification.alertBody = text;
                        localNotification.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:message.cid], @"cid", nil];
                        
                        if (text != nil)
                            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                    }
                }
                @catch (NSException *e)
                {
                    TGLog(@"%@", e);
                }
            }
            else
            {
                [TGApplyUpdatesActor clearDelayedNotifications];
            }
        }];
    });
}

+ (NSArray *)filterStatelessUpdates:(TLUpdates *)updates
{
    static Class updateUserTypingClass = nil;
    static Class updateChatUserTypingClass = nil;
    static Class updateUserStatusClass = nil;
    static Class updateUserNameClass = nil;
    static Class updateUserPhotoClass = nil;
    static Class updateEncryptedChatTypingClass = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        updateUserTypingClass = [TLUpdate$updateUserTyping class];
        updateChatUserTypingClass = [TLUpdate$updateChatUserTyping class];
        updateUserStatusClass = [TLUpdate$updateUserStatus class];
        updateUserNameClass = [TLUpdate$updateUserName class];
        updateUserPhotoClass = [TLUpdate$updateUserPhoto class];
        updateEncryptedChatTypingClass = [TLUpdate$updateEncryptedChatTyping class];
    });
    
    NSMutableArray *array = nil;
    
    if ([updates isKindOfClass:[TLUpdates$updates class]] || [updates isKindOfClass:[TLUpdates$updatesCombined class]])
    {
        NSMutableArray *replacedArray = nil;
        
        int index = -1;
        int date = ((TLUpdates$updates *)updates).date;
        
        for (TLUpdate *update in ((TLUpdates$updates *)updates).updates)
        {
            index++;
            
            if ([update isKindOfClass:updateUserTypingClass] ||
                [update isKindOfClass:updateChatUserTypingClass] ||
                [update isKindOfClass:updateEncryptedChatTypingClass] ||
                [update isKindOfClass:updateUserStatusClass] ||
                [update isKindOfClass:updateUserNameClass] ||
                [update isKindOfClass:updateUserPhotoClass])
            {
                if (array == nil)
                    array = [[NSMutableArray alloc] init];
                
                TLUpdates$updateShort *shortUpdate = [[TLUpdates$updateShort alloc] init];
                shortUpdate.date = date;
                shortUpdate.update = update;
                
                [array addObject:shortUpdate];
                
                if (replacedArray == nil)
                {
                    replacedArray = [[NSMutableArray alloc] initWithArray:((TLUpdates$updates *)updates).updates];
                    ((TLUpdates$updates *)updates).updates = replacedArray;
                }
                
                [replacedArray removeObjectAtIndex:index];
                index--;
            }
        }
        
        if (replacedArray != nil)
            TGLog(@"(modified updates: %@ (%d items)", replacedArray, replacedArray.count);
    }
    
    return array;
}

+ (NSArray *)makeStatelessUpdates:(TLUpdates *)updates
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if ([updates isKindOfClass:[TLUpdates$updates class]] || [updates isKindOfClass:[TLUpdates$updatesCombined class]])
    {
        int date = ((TLUpdates$updates *)updates).date;
        
        for (TLUpdate *update in ((TLUpdates$updates *)updates).updates)
        {
            TLUpdates$updateShort *shortUpdate = [[TLUpdates$updateShort alloc] init];
            shortUpdate.date = date;
            shortUpdate.update = update;
            
            [array addObject:shortUpdate];
        }
        
        TGLog(@"(converted %d updates to stateless", array.count);
    }
    
    return array;
}

@end
