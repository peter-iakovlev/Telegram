#import "TGApplyUpdatesActor.h"

#import "ASCommon.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGPeerIdAdapter.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"
#import "TGAppDelegate.h"

#import "TGUser+Telegraph.h"
#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"
#import "TGUserDataRequestBuilder.h"

#import "TGUser+Telegraph.h"

#import "TGTimelineItem.h"

#import "TGConversationAddMessagesActor.h"
#import "TGApplyStateRequestBuilder.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGUpdate.h"

#import "TLUpdate$updateChangePts.h"

#import "TGUpdatesWithSeq.h"
#import "TGUpdatesWithPts.h"
#import "TGUpdatesWithQts.h"
#import "TGUpdatesWithDate.h"

#import "TLMessage$modernMessage.h"
#import "TLMessage$modernMessageService.h"

#import "TLUser$modernUser.h"
#import "TLUpdates+TG.h"

#import "TGStringUtils.h"

#import "TLMessageFwdHeader$messageFwdHeader.h"

#import "TGCurrencyFormatter.h"

#import <set>
#import <map>

@protocol TGSyntheticUpdateWithPts <NSObject>

- (int32_t)pts;
- (int32_t)pts_count;

@end

@protocol TGSyntheticUpdateWithQts <NSObject>

- (int32_t)qts;

@end

@interface TGWrappedUpdate : NSObject

@property (nonatomic, strong, readonly) id update;
@property (nonatomic, readonly) int32_t date;

@end

@implementation TGWrappedUpdate

- (instancetype)initWithUpdate:(id)update date:(int32_t)date
{
    self = [super init];
    if (self != nil)
    {
        _update = update;
        _date = date;
    }
    return self;
}

@end

static inline void maybeProcessUser(TLUser *user, std::map<int, TLUser *> &processedUsers)
{
    if (((TLUser$modernUser *)user).n_id != 0)
        processedUsers[((TLUser$modernUser *)user).n_id] = user;
}

static inline void maybeProcessChat(TLChat *chat, std::map<int, TLChat *> &processedChats)
{
    if (chat.n_id != 0)
        processedChats[chat.n_id] = chat;
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

@property (nonatomic, strong) NSMutableArray *updateList;

@property (nonatomic) bool waitingForApplyUpdates;
@property (nonatomic, strong) NSMutableArray *waitingForApplyUpdatesQueue;

@property (nonatomic, strong) TGTimer *timeoutTimer;
@property (nonatomic) NSTimeInterval overallTimeout;

@end

@implementation TGApplyUpdatesActor

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
        _updateList = [[NSMutableArray alloc] init];
        _waitingForApplyUpdatesQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self cancelTimeoutTimer];
}

- (void)prepare:(NSDictionary *)__unused options
{
    bool messagesQueue = false;
    
    if ([self.path isEqualToString:@"/tg/service/tryupdates/(withPts)"])
        messagesQueue = true;
    else if ([self.path isEqualToString:@"/tg/service/tryupdates/(withSeq)"])
        messagesQueue = true;
    else if ([self.path isEqualToString:@"/tg/service/tryupdates/(withQts)"])
        messagesQueue = true;
    else if ([self.path isEqualToString:@"/tg/service/tryupdates/(withDate)"])
        messagesQueue = false;
    else
        NSAssert(false, ([NSString stringWithFormat:@"Invalid actor path %@", self.path]));
    
    if (messagesQueue)
        self.requestQueueName = @"messages";
}

- (void)execute:(NSDictionary *)options
{
    [self dumpUpdates:[options objectForKey:@"updates"]];
    
    [_updateList addObjectsFromArray:[options objectForKey:@"updates"]];
    
    if ([self.path isEqualToString:@"/tg/service/tryupdates/(withPts)"])
        [self checkPtsUpdates];
    else if ([self.path isEqualToString:@"/tg/service/tryupdates/(withSeq)"])
        [self checkSeqUpdates];
    else if ([self.path isEqualToString:@"/tg/service/tryupdates/(withQts)"])
        [self checkQtsUpdates];
    else
    {
        NSArray *sortedDateUpdates = [_updateList sortedArrayUsingComparator:^NSComparisonResult(TGUpdatesWithDate *updates1, TGUpdatesWithDate *updates2)
        {
            return updates1.date < updates2.date ? NSOrderedAscending : NSOrderedDescending;
        }];
        NSMutableArray *users = [[NSMutableArray alloc] init];
        NSMutableArray *chats = [[NSMutableArray alloc] init];
        NSMutableArray *wrappedUpdates = [[NSMutableArray alloc] init];
        
        for (TGUpdatesWithDate *updates in sortedDateUpdates)
        {
            for (id update in updates.updates)
            {
                [wrappedUpdates addObject:[[TGWrappedUpdate alloc] initWithUpdate:update date:updates.date]];
            }
            [users addObjectsFromArray:updates.users];
            [chats addObjectsFromArray:updates.chats];
        }
        if (wrappedUpdates.count != 0)
        {
            [self _tryApplyingUpdates:wrappedUpdates users:users chats:chats optionalFinalSeq:0 optionalFinalDate:0 completion:^(bool)
            {
            }];
        }
        
        [self completeAction];
    }
}

- (void)completeAction
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)dumpUpdates:(NSArray *)updateList
{
    for (id updates in updateList)
    {
        if ([updates isKindOfClass:[TGUpdatesWithPts class]])
        {
            for (id<TGSyntheticUpdateWithPts> update in ((TGUpdatesWithPts *)updates).updates)
                TGLog(@"enqueued update with pts: %d [+%d]", [update pts], [update pts_count]);
        }
        else if ([updates isKindOfClass:[TGUpdatesWithSeq class]])
        {
            TGLog(@"enqueued updates with seq: %d..%d", ((TGUpdatesWithSeq *)updates).seqStart, ((TGUpdatesWithSeq *)updates).seqEnd);
        }
        else if ([updates isKindOfClass:[TGUpdatesWithQts class]])
        {
            for (id<TGSyntheticUpdateWithQts> update in ((TGUpdatesWithQts *)updates).updates)
                TGLog(@"enqueued update with qts: %d", [update qts]);
        }
    }
}

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    [self dumpUpdates:[options objectForKey:@"updates"]];
    
    if (_waitingForApplyUpdates)
        [_waitingForApplyUpdatesQueue addObjectsFromArray:[options objectForKey:@"updates"]];
    else
        [_updateList addObjectsFromArray:[options objectForKey:@"updates"]];
    
    if ([self.path isEqualToString:@"/tg/service/tryupdates/(withPts)"])
    {
        if (!waitingInActorQueue && !_waitingForApplyUpdates)
            [self checkPtsUpdates];
    }
    else if ([self.path isEqualToString:@"/tg/service/tryupdates/(withSeq)"])
    {
        if (!waitingInActorQueue && !_waitingForApplyUpdates)
            [self checkSeqUpdates];
    }
    else if ([self.path isEqualToString:@"/tg/service/tryupdates/(withQts)"])
    {
        if (!waitingInActorQueue && !_waitingForApplyUpdates)
            [self checkQtsUpdates];
    }
    else
    {
        [_updateList removeAllObjects];
        
        NSArray *sortedDateUpdates = [_updateList sortedArrayUsingComparator:^NSComparisonResult(TGUpdatesWithDate *updates1, TGUpdatesWithDate *updates2)
        {
            return updates1.date < updates2.date ? NSOrderedAscending : NSOrderedDescending;
        }];
        NSMutableArray *users = [[NSMutableArray alloc] init];
        NSMutableArray *chats = [[NSMutableArray alloc] init];
        NSMutableArray *wrappedUpdates = [[NSMutableArray alloc] init];
        
        for (TGUpdatesWithDate *updates in sortedDateUpdates)
        {
            for (id update in updates.updates)
            {
                [wrappedUpdates addObject:[[TGWrappedUpdate alloc] initWithUpdate:update date:updates.date]];
            }
            [users addObjectsFromArray:updates.users];
            [chats addObjectsFromArray:updates.chats];
        }
        if (wrappedUpdates.count != 0)
        {
            [self _tryApplyingUpdates:wrappedUpdates users:users chats:chats optionalFinalSeq:0 optionalFinalDate:((TGWrappedUpdate *)wrappedUpdates.lastObject).date completion:^(bool)
            {
            }];
        }
    }
    
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
}

- (void)cancelTimeoutTimer
{
    if (_timeoutTimer != nil)
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
}

- (void)startTimeoutTimer
{
    _overallTimeout += [_timeoutTimer remainingTime];
    
    [self cancelTimeoutTimer];
    
    __weak TGApplyUpdatesActor *weakSelf = self;
    NSTimeInterval timeout = MAX(0.0, MIN(2.0, 5.0 - _overallTimeout));
    _timeoutTimer = [[TGTimer alloc] initWithTimeout:timeout repeat:false completion:^
    {
        __strong TGApplyUpdatesActor *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf->_timeoutTimer = nil;
            TGLog(@"update timeout timer fired at %f", timeout);
            [strongSelf timeoutReached];
        }
    } queue:[ActionStageInstance() globalStageDispatchQueue]];
    [_timeoutTimer start];
}

- (void)timeoutReached
{
    if ([self.path isEqualToString:@"/tg/service/tryupdates/(withPts)"])
        [self _failPts];
    else if ([self.path isEqualToString:@"/tg/service/tryupdates/(withSeq)"])
        [self _failSeq];
    else if ([self.path isEqualToString:@"/tg/service/tryupdates/(withQts)"])
        [self _failQts];
}

- (void)checkPtsUpdates
{
    if (_updateList.count == 0)
    {
        [self completeAction];
    }
    else
    {
        NSMutableArray *ptsUpdates = [[NSMutableArray alloc] init];
        for (TGUpdatesWithPts *update in _updateList)
        {
            [ptsUpdates addObjectsFromArray:update.updates];
        }
        
        [ptsUpdates sortUsingComparator:^NSComparisonResult(id<TGSyntheticUpdateWithPts> update1, id<TGSyntheticUpdateWithPts> update2)
        {
            if ([update1 pts] == [update2 pts])
                return [update1 pts_count] > [update2 pts_count] ? NSOrderedAscending : NSOrderedDescending;
            return [update1 pts] < [update2 pts] ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        int32_t databasePts = [[TGDatabase instance] databaseState].pts;
        int32_t currentPts = databasePts;
        
        NSMutableArray *inOrderUpdates = [[NSMutableArray alloc] init];
        NSMutableArray *expiredUpdates = [[NSMutableArray alloc] init];
        
        for (id<TGSyntheticUpdateWithPts> update in ptsUpdates)
        {
            if ([update pts] <= databasePts)
                [expiredUpdates addObject:update];
            else
            {
                if (currentPts + [update pts_count] == [update pts])
                {
                    [inOrderUpdates addObject:update];
                    
                    currentPts = [update pts];
                }
                else
                {
                    TGLog(@"***** Missing updates: %d + %d != %d", (int)currentPts, (int)[update pts_count], (int)[update pts]);
                    [self startTimeoutTimer];
                    break;
                }
            }
        }
        
        if (expiredUpdates.count != 0)
        {
            NSMutableArray *affectedGroups = [[NSMutableArray alloc] init];
            
            for (TGUpdatesWithPts *updates in _updateList)
            {
                for (id update in expiredUpdates)
                {
                    if ([updates.updates containsObject:update])
                    {
                        if (![affectedGroups containsObject:updates])
                            [affectedGroups addObject:updates];
                    }
                }
            }
            
            for (TGUpdatesWithPts *updates in affectedGroups)
            {
                NSMutableArray *filteredUpdates = [[NSMutableArray alloc] initWithArray:updates.updates];
                for (id update in expiredUpdates)
                {
                    [filteredUpdates removeObject:update];
                }
                
                if (filteredUpdates.count == 0)
                    [_updateList removeObject:updates];
            }
        }
        
        if (inOrderUpdates.count != 0)
        {
            NSMutableArray *affectedGroups = [[NSMutableArray alloc] init];
            
            for (TGUpdatesWithPts *updates in _updateList)
            {
                for (id update in inOrderUpdates)
                {
                    if ([updates.updates containsObject:update])
                    {
                        if (![affectedGroups containsObject:updates])
                            [affectedGroups addObject:updates];
                    }
                }
            }
            
            NSMutableArray *users = [[NSMutableArray alloc] init];
            NSMutableArray *chats = [[NSMutableArray alloc] init];
            for (TGUpdatesWithPts *updates in affectedGroups)
            {
                [users addObjectsFromArray:updates.users];
                [chats addObjectsFromArray:updates.chats];
                
                NSMutableArray *filteredUpdates = [[NSMutableArray alloc] initWithArray:updates.updates];
                for (id update in inOrderUpdates)
                {
                    [filteredUpdates removeObject:update];
                }
                
                if (filteredUpdates.count == 0)
                    [_updateList removeObject:updates];
            }
            
            NSMutableArray *wrappedUpdates = [[NSMutableArray alloc] init];
            for (id update in inOrderUpdates)
            {
                [wrappedUpdates addObject:[[TGWrappedUpdate alloc] initWithUpdate:update date:0]];
            }
            
            [self _tryApplyingUpdates:wrappedUpdates users:users chats:chats optionalFinalSeq:0 optionalFinalDate:0 completion:^(bool success)
            {
                if (!success)
                    [self _failPts];
                else
                    [self checkPtsUpdates];
            }];
        }
        else
        {
            if (_updateList.count == 0)
                [self completeAction];
        }
    }
}

- (void)checkQtsUpdates
{
    if (_updateList.count == 0)
    {
        [self completeAction];
    }
    else
    {
        NSMutableArray *qtsUpdates = [[NSMutableArray alloc] init];
        for (TGUpdatesWithQts *update in _updateList)
        {
            [qtsUpdates addObjectsFromArray:update.updates];
        }
        
        [qtsUpdates sortUsingComparator:^NSComparisonResult(id<TGSyntheticUpdateWithQts> update1, id<TGSyntheticUpdateWithQts> update2)
        {
            return [update1 qts] < [update2 qts] ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        int32_t databaseQts = [[TGDatabase instance] databaseState].qts;
        int32_t currentQts = databaseQts;
        
        NSMutableArray *inOrderUpdates = [[NSMutableArray alloc] init];
        NSMutableArray *expiredUpdates = [[NSMutableArray alloc] init];
        
        for (id<TGSyntheticUpdateWithQts> update in qtsUpdates)
        {
            if ([update qts] <= databaseQts)
                [expiredUpdates addObject:update];
            else
            {
                if (currentQts + 1 == [update qts])
                {
                    [inOrderUpdates addObject:update];
                    
                    currentQts = [update qts];
                }
                else
                {
                    TGLog(@"***** Missing updates: qts %d + 1 != %d", (int)currentQts, (int)[update qts]);
                    [self startTimeoutTimer];
                    break;
                }
            }
        }
        
        if (expiredUpdates.count != 0)
        {
            NSMutableArray *affectedGroups = [[NSMutableArray alloc] init];
            
            for (TGUpdatesWithQts *updates in _updateList)
            {
                for (id update in expiredUpdates)
                {
                    if ([updates.updates containsObject:update])
                    {
                        if (![affectedGroups containsObject:updates])
                            [affectedGroups addObject:updates];
                    }
                }
            }
            
            for (TGUpdatesWithQts *updates in affectedGroups)
            {
                NSMutableArray *filteredUpdates = [[NSMutableArray alloc] initWithArray:updates.updates];
                for (id update in expiredUpdates)
                {
                    [filteredUpdates removeObject:update];
                }
                
                if (filteredUpdates.count == 0)
                    [_updateList removeObject:updates];
            }
        }
        
        if (inOrderUpdates.count != 0)
        {
            NSMutableArray *affectedGroups = [[NSMutableArray alloc] init];
            
            for (TGUpdatesWithQts *updates in _updateList)
            {
                for (id update in inOrderUpdates)
                {
                    if ([updates.updates containsObject:update])
                    {
                        if (![affectedGroups containsObject:updates])
                            [affectedGroups addObject:updates];
                    }
                }
            }
            
            NSMutableArray *users = [[NSMutableArray alloc] init];
            NSMutableArray *chats = [[NSMutableArray alloc] init];
            for (TGUpdatesWithQts *updates in affectedGroups)
            {
                [users addObjectsFromArray:updates.users];
                [chats addObjectsFromArray:updates.chats];
                
                NSMutableArray *filteredUpdates = [[NSMutableArray alloc] initWithArray:updates.updates];
                for (id update in inOrderUpdates)
                {
                    [filteredUpdates removeObject:update];
                }
                
                if (filteredUpdates.count == 0)
                    [_updateList removeObject:updates];
            }
            
            NSMutableArray *wrappedUpdates = [[NSMutableArray alloc] init];
            for (id update in inOrderUpdates)
            {
                [wrappedUpdates addObject:[[TGWrappedUpdate alloc] initWithUpdate:update date:0]];
            }
            
            [self _tryApplyingUpdates:wrappedUpdates users:users chats:chats optionalFinalSeq:0 optionalFinalDate:0 completion:^(bool success)
            {
                if (!success)
                    [self _failQts];
                else
                    [self checkQtsUpdates];
            }];
        }
        else
        {
            if (_updateList.count == 0)
                [self completeAction];
        }
    }
}

- (void)checkSeqUpdates
{
    if (_updateList.count == 0)
    {
        [self completeAction];
    }
    else
    {
        NSArray *seqUpdates = [_updateList sortedArrayUsingComparator:^NSComparisonResult(TGUpdatesWithSeq *updates1, TGUpdatesWithSeq *updates2)
        {
            return updates1.seqEnd < updates2.seqEnd ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        int32_t currentSeq = [[TGDatabase instance] databaseState].seq;
        
        NSMutableArray *inOrderUpdates = [[NSMutableArray alloc] init];
        for (TGUpdatesWithSeq *updates in seqUpdates)
        {
            if (updates.seqStart == currentSeq + 1)
            {
                [inOrderUpdates addObject:updates];
                currentSeq = updates.seqEnd;
            }
            else
            {
                TGLog(@"***** Missing updates: seq %d", (int)currentSeq + 1);
                [self startTimeoutTimer];
            }
        }
        
        if (inOrderUpdates.count != 0)
        {
            NSMutableArray *wrappedUpdates = [[NSMutableArray alloc] init];
            NSMutableArray *users = [[NSMutableArray alloc] init];
            NSMutableArray *chats = [[NSMutableArray alloc] init];
            
            for (TGUpdatesWithSeq *updates in inOrderUpdates)
            {
                for (id update in updates.updates)
                {
                    [wrappedUpdates addObject:[[TGWrappedUpdate alloc] initWithUpdate:update date:updates.date]];
                }
                [users addObjectsFromArray:updates.users];
                [chats addObjectsFromArray:updates.chats];
                
                [_updateList removeObject:updates];
            }
            
            [self _tryApplyingUpdates:wrappedUpdates users:users chats:chats optionalFinalSeq:((TGUpdatesWithSeq *)inOrderUpdates.lastObject).seqEnd optionalFinalDate:((TGWrappedUpdate *)wrappedUpdates.lastObject).date completion:^(bool success)
            {
                if (!success)
                    [self _failSeq];
                else
                    [self checkSeqUpdates];
            }];
        }
        else if (_updateList.count == 0)
        {
            [self completeAction];
        }
    }
}

- (void)_failPts
{
    TGLog(@"***** Inconsistent state by (pts, pts_count)! Synchronization required.");
    
    [self cancelTimeoutTimer];
    
    [TGTelegraphInstance stateUpdateRequired];
    
    [self completeAction];
}

- (void)_failSeq
{
    TGLog(@"***** Inconsistent state by seq! Synchronization required.");
    
    [self cancelTimeoutTimer];
    
    [TGTelegraphInstance stateUpdateRequired];
    
    [self completeAction];
}

- (void)_failQts
{
    TGLog(@"***** Inconsistent state by qts! Synchronization required.");
    
    [self cancelTimeoutTimer];
    
    [TGTelegraphInstance stateUpdateRequired];
    
    [self completeAction];
}

template<typename T>
static int64_t extractMessageConversationId(T concreteMessage, int &outFromUid)
{
    int64_t fromUid = concreteMessage.from_id;
    bool outgoing = concreteMessage.flags & 2;
    
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
    else if ([concreteMessage.to_id isKindOfClass:[TLPeer$peerChannel class]])
    {
        TLPeer$peerChannel *toChannel = (TLPeer$peerChannel *)concreteMessage.to_id;
        int64_t toUid = TGPeerIdFromChannelId(toChannel.channel_id);
        return toUid;
    }
    
    return 0;
}

- (bool)_tryApplyingUpdates:(NSArray *)updates users:(NSArray *)users chats:(NSArray *)chats optionalFinalSeq:(int32_t)optionalFinalSeq optionalFinalDate:(int32_t)optionalFinalDate completion:(void (^)(bool))completion
{
    static Class updateNewMessageClass = nil;
    static Class updateNewEncryptedMessageClass = nil;
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
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        updateNewMessageClass = [TLUpdate$updateNewMessage class];
        updateNewEncryptedMessageClass = [TLUpdate$updateNewEncryptedMessage class];
        updateDeleteMessagesClass = [TLUpdate$updateDeleteMessages class];
        updateRestoreMessagesClass = [TLUpdate$updateRestoreMessages class];
        updateChangePtsClass = [TLUpdate$updateChangePts class];
        updateUserTypingClass = [TLUpdate$updateUserTyping class];
        updateChatUserTypingClass = [TLUpdate$updateChatUserTyping class];
        updateChatParticipantsClass = [TLUpdate$updateChatParticipants class];
        updateChatParticipantAddClass = [TLUpdate$updateChatParticipantAdd class];
        updateChatParticipantDeleteClass = [TLUpdate$updateChatParticipantDelete class];
        updateContactLocatedClass = [TLUpdate$updateContactLocated class];
        
        messageClass = [TLMessage$modernMessage class];
        messageServiceClass = [TLMessage$modernMessageService class];
    });
    
    int32_t statePts = 0;
    int32_t stateQts = 0;
    
    TGDatabaseState databaseState = [[TGDatabase instance] databaseState];
    
    for (TGWrappedUpdate *update in updates)
    {
        if ([update.update hasPts])
            statePts = MAX(statePts, [(id<TGSyntheticUpdateWithPts>)update.update pts]);
        if ([update.update respondsToSelector:@selector(qts)])
            stateQts = MAX(stateQts, [(id<TGSyntheticUpdateWithQts>)update.update qts]);
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
    
    for (TLUser *userDesc in users)
    {
        maybeProcessUser(userDesc, processedUsers);
    }
    
    for (TLChat *chatDesc in chats)
    {
        maybeProcessChat(chatDesc, processedChats);
    }
    
    std::map<int64_t, int32_t> maxInboxReadMessageIdByPeerId;
    std::map<int64_t, int32_t> maxOutboxReadMessageIdByPeerId;

    for (TGWrappedUpdate *wrappedUpdate in updates)
    {
        if ([wrappedUpdate.update isKindOfClass:[TLUpdate$updateReadHistoryInbox class]])
        {
            TLUpdate$updateReadHistoryInbox *concreteUpdate = wrappedUpdate.update;
            
            int64_t peerId = 0;
            if ([concreteUpdate.peer isKindOfClass:[TLPeer$peerUser class]])
                peerId = ((TLPeer$peerUser *)concreteUpdate.peer).user_id;
            else if ([concreteUpdate.peer isKindOfClass:[TLPeer$peerChat class]])
                peerId = -((TLPeer$peerChat *)concreteUpdate.peer).chat_id;
            else if ([concreteUpdate.peer isKindOfClass:[TLPeer$peerChannel class]])
                peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)concreteUpdate.peer).channel_id);
            
            auto it = maxInboxReadMessageIdByPeerId.find(peerId);
            if (it == maxInboxReadMessageIdByPeerId.end())
                maxInboxReadMessageIdByPeerId[peerId] = concreteUpdate.max_id;
            else
                maxInboxReadMessageIdByPeerId[peerId] = MAX(it->second, concreteUpdate.max_id);
        }
        else if ([wrappedUpdate.update isKindOfClass:[TLUpdate$updateReadHistoryOutbox class]])
        {
            TLUpdate$updateReadHistoryOutbox *concreteUpdate = wrappedUpdate.update;
            
            int64_t peerId = 0;
            if ([concreteUpdate.peer isKindOfClass:[TLPeer$peerUser class]])
                peerId = ((TLPeer$peerUser *)concreteUpdate.peer).user_id;
            else if ([concreteUpdate.peer isKindOfClass:[TLPeer$peerChat class]])
                peerId = -((TLPeer$peerChat *)concreteUpdate.peer).chat_id;
            else if ([concreteUpdate.peer isKindOfClass:[TLPeer$peerChannel class]])
                peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)concreteUpdate.peer).channel_id);
            
            auto it = maxOutboxReadMessageIdByPeerId.find(peerId);
            if (it == maxOutboxReadMessageIdByPeerId.end())
                maxOutboxReadMessageIdByPeerId[peerId] = concreteUpdate.max_id;
            else
                maxOutboxReadMessageIdByPeerId[peerId] = MAX(it->second, concreteUpdate.max_id);
        }
    }
    
    for (TGWrappedUpdate *wrappedUpdate in updates)
    {
        id update = wrappedUpdate.update;
        int32_t date = wrappedUpdate.date;
        
        if ([update isKindOfClass:updateNewMessageClass])
        {
            TLUpdate$updateNewMessage *newMessage = (TLUpdate$updateNewMessage *)update;
            
            TLMessage *message = newMessage.message;
            
            if (([message isKindOfClass:[TLMessage$modernMessage class]] || [message isKindOfClass:[TLMessage$modernMessageService class]]) && !(((TLMessage$modernMessage *)message).flags & 2))
            {
                TGMessage *parsedMessage = [[TGMessage alloc] initWithTelegraphMessageDesc:message];
                if (!parsedMessage.outgoing && !parsedMessage.isSilent)
                {
                    auto maxIt = maxInboxReadMessageIdByPeerId.find(parsedMessage.cid);
                    if (maxIt == maxInboxReadMessageIdByPeerId.end()) {
                        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:parsedMessage.cid];
                        maxInboxReadMessageIdByPeerId[parsedMessage.cid] = conversation.maxReadMessageId;
                    }
                    
                    if (!(maxIt != maxInboxReadMessageIdByPeerId.end() && parsedMessage.mid <= maxIt->second))
                        [messagesForLocalNotification addObject:newMessage.message];
                }
                
                TGLog(@"message date: %d", (int32_t)parsedMessage.date);
            }
            else
                TGLog(@"Message %d does not match for local notification", (int)message.n_id);
            
            int64_t conversationId = 0;
            int fromUid = 0;
            
            if ([message isKindOfClass:messageClass])
                conversationId = extractMessageConversationId((TLMessage$message *)message, fromUid);
            else if ([message isKindOfClass:messageServiceClass])
                conversationId = extractMessageConversationId((TLMessage$modernMessageService *)message, fromUid);
            
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
                        {
                            TGLog(@"Unknown chat %" PRId64 "", conversationId);
                            failedProcessing = true;
                        }
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
                        {
                            TGLog(@"Unknown user %" PRId64 "", conversationId);
                            failedProcessing = true;
                        }
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
                    {
                        TGLog(@"Unknown user %" PRId32 "", fromUid);
                        failedProcessing = true;
                    }
                }
            }
            
            if (!failedProcessing)
            {
                if ([message isKindOfClass:[TLMessage$modernMessage class]])
                {
                    TLMessageFwdHeader$messageFwdHeader *fwd_header = (TLMessageFwdHeader$messageFwdHeader *)((TLMessage$modernMessage *)message).fwd_from;
                    if (fwd_header != nil) {
                        if (fwd_header.from_id != 0) {
                            if (knownUsers.find(fwd_header.from_id) == knownUsers.end() && processedUsers.find(fwd_header.from_id) == processedUsers.end())
                            {
                                bool contains = [TGDatabaseInstance() loadUser:fwd_header.from_id];
                                if (contains)
                                    knownUsers.insert(fwd_header.from_id);
                                else
                                {
                                    TGLog(@"Unknown user %" PRId32 "", fwd_header.from_id);
                                    failedProcessing = true;
                                }
                            }
                        }
                        if (fwd_header.channel_id != 0) {
                            int64_t peerId = TGPeerIdFromChannelId(fwd_header.channel_id);
                            if (peerId != 0) {
                                if (knownChats.find(peerId) == knownChats.end() && processedChats.find(TGChannelIdFromPeerId(peerId)) == processedChats.end()) {
                                    bool contains = [TGDatabaseInstance() _channelExists:peerId];
                                    if (contains)
                                        knownChats.insert(TGChannelIdFromPeerId(peerId));
                                    else
                                    {
                                        TGLog(@"Unknown channel %" PRId64 "", peerId);
                                        failedProcessing = true;
                                    }
                                }
                            }
                        }
                    }
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
            int32_t userId = 0;
            if ([update isKindOfClass:updateChatParticipantAddClass])
            {
                conversationId = -((TLUpdate$updateChatParticipantAdd *)update).chat_id;
                userId = ((TLUpdate$updateChatParticipantAdd *)update).user_id;
            }
            if ([update isKindOfClass:updateChatParticipantDeleteClass])
            {
                conversationId = -((TLUpdate$updateChatParticipantDelete *)update).chat_id;
                userId = ((TLUpdate$updateChatParticipantDelete *)update).user_id;
            }
            
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
            
            if (userId != 0)
            {
                if (knownUsers.find(userId) == knownUsers.end() && processedUsers.find(userId) == processedUsers.end())
                {
                    bool contains = [TGDatabaseInstance() loadUser:userId];
                    if (contains)
                        knownUsers.insert(userId);
                    else
                    {
                        TGLog(@"Unknown user %" PRId32 "", userId);
                        failedProcessing = true;
                    }
                }
            }
            
            [updatesWithDates addObject:@[update, @(date)]];
            [allUpdates addObject:update];
        }
        else if ([update isKindOfClass:[TLUpdate$updateEncryption class]])
        {
            TLUpdate$updateEncryption *updateEncryption = (TLUpdate$updateEncryption *)update;
            
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphEncryptedChatDesc:updateEncryption.chat];
            
            if (conversation.conversationId != 0)
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
            
            if (![updateNewEncryptedMessage.message isKindOfClass:[TLEncryptedMessage$encryptedMessageService class]] && updateNewEncryptedMessage.message != nil && stateQts != 0)
            {
                [messagesForLocalNotification addObject:@{@"message": updateNewEncryptedMessage.message, @"qts": @(stateQts)}];
            }
            
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
        
        _waitingForApplyUpdates = true;
        [TGUpdateStateRequestBuilder applyUpdates:addedMessages otherUpdates:allUpdates usersDesc:usersToProcess chatsDesc:chatsToProcess chatParticipantsDesc:nil updatesWithDates:updatesWithDates addedEncryptedActionsByPeerId:nil addedEncryptedUnparsedActionsByPeerId:nil completion:^(__unused bool applied)
        {
            _waitingForApplyUpdates = false;
            [_updateList addObjectsFromArray:_waitingForApplyUpdatesQueue];
            [_waitingForApplyUpdatesQueue removeAllObjects];
            
            [delayedNotifications() addObjectsFromArray:messagesForLocalNotification];
            
            if (stateQts != 0)
            {
                [TGDatabaseInstance() updateLatestQts:stateQts applied:false completion:^(int greaterQtsForSynchronization)
                 {
                     if (greaterQtsForSynchronization > 0)
                     {
                         [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/messages/reportDelivery/(qts)"] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:stateQts], @"qts", nil] watcher:TGTelegraphInstance];
                     }
                 }];
            }
            
            if ([self.path isEqualToString:@"/tg/service/tryupdates/(withPts)"] || [self.path isEqualToString:@"/tg/service/tryupdates/(withSeq)"] || [self.path isEqualToString:@"/tg/service/tryupdates/(withQts)"])
            {
                if (statePts != 0)
                    TGLog(@"=== pts: %d", statePts);
                if (optionalFinalSeq != 0)
                    TGLog(@"=== seq: %d", optionalFinalSeq);
                if (stateQts != 0)
                    TGLog(@"=== qts: %d", stateQts);
                
                [[TGDatabase instance] applyPts:statePts date:optionalFinalDate seq:optionalFinalSeq qts:stateQts unreadCount:-1];
            }
            else if (optionalFinalDate > databaseState.date)
            {
                [[TGDatabase instance] applyPts:0 date:optionalFinalDate seq:0 qts:0 unreadCount:-1];
            }
            
            if (completion)
                completion(true);
        }];
    }
    else
    {
        if (updatesTooLong)
            TGLog(@"===== Updates too long, requesting complete difference");
        else
            TGLog(@"***** Unknown chat or user found, requesting complete difference");
        
        if (completion)
            completion(false);
    }
    
    return !failedProcessing;
}

- (void)cancel
{
    [self cancelTimeoutTimer];
    
    [super cancel];
}

+ (void)applyDelayedNotifications:(int)maxMid mids:(NSArray *)mids midsWithoutSound:(NSSet *)midsWithoutSound maxQts:(int)maxQts randomIds:(NSArray *)randomIds
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
        if ([UIApplication sharedApplication] == nil)
            applicationState = UIApplicationStateBackground;
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            if (applicationState != UIApplicationStateActive)
            {
                int globalMessageSoundId = 1;
                bool globalMessagePreviewText = true;
                int globalMessageMuteUntil = 0;
                bool notFound = false;
                [TGDatabaseInstance() loadPeerNotificationSettings:INT_MAX - 1 soundId:&globalMessageSoundId muteUntil:&globalMessageMuteUntil previewText:&globalMessagePreviewText messagesMuted:NULL notFound:&notFound];
                if (notFound)
                {
                    globalMessageSoundId = 1;
                    globalMessagePreviewText = true;
                }
                
                int globalGroupSoundId = 1;
                bool globalGroupPreviewText = true;
                int globalGroupMuteUntil = 0;
                notFound = false;
                [TGDatabaseInstance() loadPeerNotificationSettings:INT_MAX - 2 soundId:&globalGroupSoundId muteUntil:&globalGroupMuteUntil previewText:&globalGroupPreviewText messagesMuted:NULL notFound:&notFound];
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
                    
                    std::set<int> processedMidsSet;
                    
                    std::set<int64_t> randomIdsSet;
                    for (NSNumber *nRandomId in randomIds)
                    {
                        randomIdsSet.insert([nRandomId longLongValue]);
                    }
                    
                    int count = (int)delayedNotifications().count;
                    for (int i = 0; i < count; i++)
                    {
                        TGMessage *message = nil;
                        NSUInteger multiforwardCount = 0;
                        
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
                            
                            if (processedMidsSet.find(mid) != processedMidsSet.end())
                                continue;
                            processedMidsSet.insert(mid);
                            
                            message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
                            bool foundForward = false;
                            
                            for (id media in message.mediaAttachments)
                            {
                                if ([media isKindOfClass:[TGForwardedMessageMediaAttachment class]])
                                {
                                    foundForward = true;
                                    break;
                                }
                            }
                            
                            if (foundForward)
                            {
                                for (int j = i + 1; j >= 0 && j < count; j++)
                                {
                                    if ([delayedNotifications()[j] isKindOfClass:[TLMessage class]])
                                    {
                                        TGMessage *nextMessage = [[TGMessage alloc] initWithTelegraphMessageDesc:delayedNotifications()[j]];
                                        
                                        if (processedMidsSet.find(nextMessage.mid) != processedMidsSet.end())
                                            continue;
                                        processedMidsSet.insert(nextMessage.mid);
                                        
                                        bool nextIsForward = false;
                                        for (id media in nextMessage.mediaAttachments)
                                        {
                                            if ([media isKindOfClass:[TGForwardedMessageMediaAttachment class]])
                                            {
                                                nextIsForward = true;
                                                break;
                                            }
                                        }
                                        
                                        if (nextIsForward)
                                        {
                                            if (multiforwardCount == 0)
                                                multiforwardCount = 1;
                                            multiforwardCount++;
                                            [delayedNotifications() removeObjectAtIndex:j];
                                            j--;
                                            count--;
                                        }
                                    }
                                }
                            }
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
                        
                        if (message.containsMention)
                        {
                            if ([TGDatabaseInstance() isPeerMuted:message.fromUid])
                                continue;
                        }
                        else
                        {
                            if ([TGDatabaseInstance() isPeerMuted:message.cid])
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
                            if (message.containsMention)
                                notificationPeerId = message.fromUid;
                            else
                                notificationPeerId = message.cid;
                            user = [TGDatabaseInstance() loadUser:(int)message.fromUid];
                            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithIdCached:message.cid];
                            if (conversation != nil)
                                chatName = conversation.chatTitle;
                            else
                                chatName = [TGDatabaseInstance() loadConversationWithId:message.cid].chatTitle;
                        }
                        
                        if ([TGDatabaseInstance() isPeerMuted:notificationPeerId])
                            continue;
                        
                        int soundId = 1;
                        bool notFound = false;
                        int muteUntil = 0;
                        [TGDatabaseInstance() loadPeerNotificationSettings:notificationPeerId soundId:&soundId muteUntil:&muteUntil previewText:NULL messagesMuted:NULL notFound:&notFound];
                        if (notFound)
                        {
                            soundId = 1;
                        }
                        
                        if (soundId == 1) {
                            soundId = (message.cid > 0 || message.cid <= INT_MIN) ? globalMessageSoundId : globalGroupSoundId;
                        }
                        
                        if (true) {
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
                        }
                        
                        NSString *text = nil;
                        
                        bool attachmentFound = false;
                        bool migrationFound = false;
                        bool skipMessage = false;
                        bool phoneCall = false;
                        
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
                                        NSArray *uids = actionAttachment.actionData[@"uids"];
                                        if (uids != nil) {
                                            TGUser *authorUser = user;
                                            NSMutableArray *subjectUsers = [[NSMutableArray alloc] init];
                                            for (NSNumber *nUid in uids) {
                                                TGUser *subjectUser = [TGDatabaseInstance() loadUser:[nUid intValue]];
                                                if (user != nil) {
                                                    [subjectUsers addObject:subjectUser];
                                                }
                                            }
                                            
                                            if (subjectUsers.count == 1 && authorUser.uid == ((TGUser *)subjectUsers[0]).uid) {
                                                text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_RETURNED"), authorUser.displayName, chatName];
                                            } else {
                                                NSMutableString *subjectNames = [[NSMutableString alloc] init];
                                                for (TGUser *subjectUser in subjectUsers) {
                                                    if (subjectNames.length != 0) {
                                                        [subjectNames appendString:@", "];
                                                    }
                                                    [subjectNames appendString:subjectUser.displayName];
                                                }
                                                text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_ADD_MEMBER"), authorUser.displayName, chatName, subjectNames];
                                            }
                                            attachmentFound = true;
                                        } else {
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
                                    case TGMessageActionChannelCreated:
                                    {
                                        text = @"";
                                        attachmentFound = true;
                                        
                                        break;
                                    }
                                    case TGMessageActionChannelCommentsStatusChanged:
                                    {
                                        text = [actionAttachment.actionData[@"enabled"] boolValue] ? TGLocalized(@"Channel.NotificationCommentsEnabled") : TGLocalized(@"Channel.NotificationCommentsDisabled");
                                        attachmentFound = true;
                                        
                                        break;
                                    }
                                    case TGMessageActionJoinedByLink:
                                    {
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"Notification.JoinedGroupByLink"), user.displayName];
                                        attachmentFound = true;
                                        
                                        break;
                                    }
                                    case TGMessageActionGroupMigratedTo:
                                    {
                                        migrationFound = true;
                                        break;
                                    }
                                    case TGMessageActionGameScore:
                                    {
                                        TGMessage *replyMessage = nil;
                                        for (id attachment in message.mediaAttachments) {
                                            if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]]) {
                                                replyMessage = ((TGReplyMessageMediaAttachment *)attachment).replyMessage;
                                                break;
                                            }
                                        }
                                        
                                        NSString *gameTitle = nil;
                                        for (id attachment in replyMessage.mediaAttachments) {
                                            if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
                                                gameTitle = ((TGGameMediaAttachment *)attachment).title;
                                                break;
                                            }
                                        }
                                        
                                        int scoreCount = (int)[actionAttachment.actionData[@"score"] intValue];
                                        
                                        NSString *formatStringBase = @"";
                                        if (gameTitle != nil) {
                                            if (user.uid == TGTelegraphInstance.clientUserId) {
                                                formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreSelfExtended_" value:scoreCount];
                                            } else {
                                                formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreExtended_" value:scoreCount];
                                            }
                                        } else {
                                            if (user.uid == TGTelegraphInstance.clientUserId) {
                                                formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreSelfSimple_" value:scoreCount];
                                            } else {
                                                formatStringBase = [TGStringUtils integerValueFormat:@"ServiceMessage.GameScoreSimple_" value:scoreCount];
                                            }
                                        }
                                        
                                        NSString *baseString = TGLocalized(formatStringBase);
                                        baseString = [baseString stringByReplacingOccurrencesOfString:@"%@" withString:@"{game}"];
                                        
                                        NSMutableString *formatString = [[NSMutableString alloc] initWithString:baseString];
                                        
                                        NSString *authorName = user.displayFirstName;
                                        
                                        for (int i = 0; i < 3; i++) {
                                            NSRange nameRange = [formatString rangeOfString:@"{name}"];
                                            NSRange scoreRange = [formatString rangeOfString:@"{score}"];
                                            NSRange gameTitleRange = [formatString rangeOfString:@"{game}"];
                                            
                                            if (nameRange.location != NSNotFound) {
                                                if (scoreRange.location == NSNotFound || scoreRange.location > nameRange.location) {
                                                    scoreRange.location = NSNotFound;
                                                }
                                                if (gameTitleRange.location == NSNotFound || gameTitleRange.location > nameRange.location) {
                                                    gameTitleRange.location = NSNotFound;
                                                }
                                            }
                                            
                                            if (scoreRange.location != NSNotFound) {
                                                if (nameRange.location == NSNotFound || nameRange.location > scoreRange.location) {
                                                    nameRange.location = NSNotFound;
                                                }
                                                if (gameTitleRange.location == NSNotFound || gameTitleRange.location > scoreRange.location) {
                                                    gameTitleRange.location = NSNotFound;
                                                }
                                            }
                                            
                                            if (gameTitleRange.location != NSNotFound) {
                                                if (scoreRange.location == NSNotFound || scoreRange.location > gameTitleRange.location) {
                                                    scoreRange.location = NSNotFound;
                                                }
                                                if (nameRange.location == NSNotFound || nameRange.location > gameTitleRange.location) {
                                                    nameRange.location = NSNotFound;
                                                }
                                            }
                                            
                                            if (nameRange.location != NSNotFound) {
                                                [formatString replaceCharactersInRange:nameRange withString:authorName];
                                            }
                                            
                                            if (scoreRange.location != NSNotFound) {
                                                [formatString replaceCharactersInRange:scoreRange withString:[NSString stringWithFormat:@"%d", scoreCount]];
                                            }
                                            
                                            if (gameTitleRange.location != NSNotFound) {
                                                [formatString replaceCharactersInRange:gameTitleRange withString:gameTitle];
                                            }
                                        }
                                        
                                        text = formatString;
                                        attachmentFound = true;
                                        
                                        break;
                                    }
                                    case TGMessageActionPhoneCall:
                                    {
                                        TGCallDiscardReason reason = (TGCallDiscardReason)[actionAttachment.actionData[@"reason"] intValue];
                                        if (reason == TGCallDiscardReasonMissed) {
                                            text = [NSString stringWithFormat:TGLocalized(@"PHONE_CALL_MISSED"), user.displayName];
                                            phoneCall = true;
                                        }
                                        else {
                                            skipMessage = true;
                                        }
                                        
                                        attachmentFound = true;
                                        break;
                                    }
                                    case TGMessageActionEncryptedChatMessageScreenshot:
                                    {
                                        text = [NSString stringWithFormat:TGLocalized(@"MESSAGE_SCREENSHOT"), user.displayName];
                                        attachmentFound = true;
                                        
                                        break;
                                    }
                                    default:
                                        break;
                                }
                            }
                            else if (attachment.type == TGImageMediaAttachmentType)
                            {
                                if (((TGImageMediaAttachment *)attachment).caption.length != 0) {
                                    if (message.cid > 0) {
                                        text = [[NSString alloc] initWithFormat:@"%@: 🖼 %@", user.displayName, ((TGImageMediaAttachment *)attachment).caption];
                                    } else {
                                        text = [[NSString alloc] initWithFormat:@"%@@%@: 🖼 %@", user.displayName, chatName, ((TGImageMediaAttachment *)attachment).caption];
                                    }
                                } else {
                                    if (message.cid > 0) {
                                        if (message.messageLifetime > 0 && message.messageLifetime <= 60) {
                                            text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_PHOTO_SECRET"), user.displayName];
                                        } else {
                                            text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_PHOTO"), user.displayName];
                                        }
                                    }
                                    else
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_PHOTO"), user.displayName, chatName];
                                }
                                
                                attachmentFound = true;
                                
                                break;
                            }
                            else if (attachment.type == TGVideoMediaAttachmentType)
                            {
                                bool isRoundMessage = ((TGVideoMediaAttachment *)attachment).roundMessage;
                                
                                if (((TGVideoMediaAttachment *)attachment).caption.length != 0) {
                                    if (message.cid > 0) {
                                        text = [[NSString alloc] initWithFormat:@"%@: 📹 %@", user.displayName, ((TGVideoMediaAttachment *)attachment).caption];
                                    } else {
                                        text = [[NSString alloc] initWithFormat:@"%@@%@: 📹 %@", user.displayName, chatName, ((TGVideoMediaAttachment *)attachment).caption];
                                    }
                                } else {
                                    if (isRoundMessage) {
                                        if (message.cid > 0)
                                            text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_ROUND"), user.displayName];
                                        else
                                            text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_ROUND"), user.displayName, chatName];
                                    }
                                    else {
                                        if (message.cid > 0)
                                            if (message.messageLifetime > 0 && message.messageLifetime <= 60) {
                                                text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_VIDEO_SECRET"), user.displayName];
                                            } else {
                                                text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_VIDEO"), user.displayName];
                                            }
                                        else
                                            text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_VIDEO"), user.displayName, chatName];
                                    }
                                }
                                
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
                                bool isAnimated = false;
                                bool isVoice = false;
                                CGSize imageSize = CGSizeZero;
                                bool isSticker = false;
                                NSString *stickerRepresentation = @"";
                                for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
                                {
                                    if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]])
                                    {
                                        isAnimated = true;
                                    }
                                    else if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]])
                                    {
                                        imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
                                    }
                                    else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                                        imageSize = ((TGDocumentAttributeVideo *)attribute).size;
                                    }
                                    else if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                                    {
                                        isSticker = true;
                                        stickerRepresentation = [((TGDocumentAttributeSticker *)attribute).alt stringByAppendingString:@" "];
                                    }
                                    else if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                                        isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
                                    }
                                }
                                
                                if (isSticker)
                                {
                                    if (message.cid > 0) {
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_STICKER"), user.displayName, stickerRepresentation];
                                    } else {
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_STICKER"), user.displayName, chatName, stickerRepresentation];
                                    }
                                }
                                else if (isAnimated) {
                                    if (message.cid > 0)
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_GIF"), user.displayName];
                                    else
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_GIF"), user.displayName, chatName];
                                }
                                else if (isVoice) {
                                    if (message.cid > 0)
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_AUDIO"), user.displayName];
                                    else
                                        text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_AUDIO"), user.displayName, chatName];
                                }
                                else
                                {
                                    if (((TGDocumentMediaAttachment *)attachment).caption.length != 0) {
                                        if (message.cid > 0) {
                                            text = [[NSString alloc] initWithFormat:@"%@: 📎 %@", user.displayName, ((TGDocumentMediaAttachment *)attachment).caption];
                                        } else {
                                            text = [[NSString alloc] initWithFormat:@"%@@%@: 📎 %@", user.displayName, chatName, ((TGDocumentMediaAttachment *)attachment).caption];
                                        }
                                    } else {
                                        if (message.cid > 0)
                                            text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_DOC"), user.displayName];
                                        else
                                            text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_DOC"), user.displayName, chatName];
                                    }
                                }
                                
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
                            else if (attachment.type == TGGameAttachmentType) {
                                NSString *gameTitle = ((TGGameMediaAttachment *)attachment).title;
                                
                                if (message.cid > 0) {
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_GAME"), user.displayName, gameTitle];
                                } else {
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_GAME"), user.displayName, chatName, gameTitle];
                                }
                                
                                attachmentFound = true;
                                break;
                            }
                            else if (attachment.type == TGInvoiceMediaAttachmentType) {
                                TGInvoiceMediaAttachment *invoice = (TGInvoiceMediaAttachment *)attachment;
                                
                                NSString *priceString = [[TGCurrencyFormatter shared] formatAmount:invoice.totalAmount currency:invoice.currency];
                                
                                if (message.cid > 0) {
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_INVOICE"), user.displayName, priceString];
                                } else {
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_INVOICE"), user.displayName, chatName, priceString];
                                }
                                
                                attachmentFound = true;
                                break;
                            }
                        }
                        
                        if (migrationFound || skipMessage) {
                            continue;
                        }
                        
                        if (soundId > 0 && ![midsWithoutSound containsObject:@(message.mid)])
                            localNotification.soundName = [[NSString alloc] initWithFormat:@"%d.m4a", soundId];

                        if (multiforwardCount != 0)
                        {
                            if (message.cid > 0)
                            {
                                text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_FWDS"), user.displayName, [[NSString alloc] initWithFormat:@"%d", (int)multiforwardCount]];
                            }
                            else
                            {
                                text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_FWDS"), user.displayName, chatName, [[NSString alloc] initWithFormat:@"%d", (int)multiforwardCount]];
                            }
                        }
                        else
                        {
                            if (message.cid <= INT_MIN)
                            {
                                text = [[NSString alloc] initWithFormat:TGLocalized(@"ENCRYPTED_MESSAGE"), @""];
                            }
                            else if (message.cid > 0)
                            {
                                if (globalMessagePreviewText && !attachmentFound)
                                    text = [[NSString alloc] initWithFormat:@"%@: %@", user.displayName, message.text];
                                else if (!attachmentFound)
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"MESSAGE_NOTEXT"), user.displayName];
                            }
                            else
                            {
                                if (globalGroupPreviewText && !attachmentFound)
                                    text = [[NSString alloc] initWithFormat:@"%@@%@: %@", user.displayName, chatName, message.text];
                                else if (!attachmentFound)
                                    text = [[NSString alloc] initWithFormat:TGLocalized(@"CHAT_MESSAGE_NOTEXT"), user.displayName, chatName];
                            }
                        }
                        
                        bool isLocked = [TGAppDelegateInstance isCurrentlyLocked];
                        if (isLocked)
                        {
                            text = [[NSString alloc] initWithFormat:TGLocalized(@"LOCKED_MESSAGE"), @""];
                        }
                        
                        static dispatch_once_t onceToken;
                        static NSString *tokenString = nil;
                        dispatch_once(&onceToken, ^
                        {
                            unichar tokenChar = 0x2026;
                            tokenString = [[NSString alloc] initWithCharacters:&tokenChar length:1];
                        });
                        
                        if (text.length > 256)
                        {
                            text = [NSString stringWithFormat:@"%@%@", [text substringToIndex:255], tokenString];
                        }
                        
                        text = [text stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
                        
#ifdef INTERNAL_RELEASE
                        text = [@"[L] " stringByAppendingString:text];
#endif
                        localNotification.alertBody = text;
                        localNotification.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:message.cid], @"cid", @(message.mid), @"mid", nil];
                        
                        if (iosMajorVersion() >= 8 && !isLocked)
                        {
                            if (phoneCall)
                                localNotification.category = @"p";
                            else if (TGPeerIdIsGroup(message.cid))
                                localNotification.category = @"m";
                            else if (TGPeerIdIsChannel(message.cid))
                                localNotification.category = @"c";
                            else if (message.cid > INT_MIN)
                                localNotification.category = @"r";
                        }
                        
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
                TGLog(@"Not showing local notifications (applicationState = %d)", (int)applicationState);
                [TGApplyUpdatesActor clearDelayedNotifications];
            }
        }];
    });
}

@end
