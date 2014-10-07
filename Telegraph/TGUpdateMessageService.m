/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUpdateMessageService.h"

#import "TL/TLMetaScheme.h"
#import <MTProtoKit/MTIncomingMessage.h>

#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTQueue.h>

#import "TGTelegraph.h"
#import "ActionStage.h"
#import "TGApplyUpdatesActor.h"
#import "TGUpdateMessage.h"
#import "TGUpdate.h"
#import "TLUpdate$updateChangePts.h"

@interface TGUpdateMessageService ()
{
    MTQueue *_queue;
    
    int _sessionToken;
    bool _holdUpdates;
    
    bool _scheduledMessageProcessing;
    NSMutableArray *_messagesToProcess;
    
    bool _isNetworkAvailable;
    bool _isConnected;
    bool _isUpdatingConnectionContext;
    bool _isPerformingServiceTasks;
}

@end

@implementation TGUpdateMessageService

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _messagesToProcess = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)reset:(bool)clearMessages
{
    _sessionToken++;
    _holdUpdates = false;
    
    if (clearMessages)
    {
        _scheduledMessageProcessing = false;
        _messagesToProcess = [[NSMutableArray alloc] init];
    }
    
    if (TGTelegraphInstance.clientUserId != 0)
        [ActionStageInstance() requestActor:@"/tg/service/updatestate" options:nil watcher:TGTelegraphInstance];
}

- (void)mtProtoWillAddService:(MTProto *)mtProto
{
    _queue = [mtProto messageServiceQueue];
}

- (void)mtProtoNetworkAvailabilityChanged:(MTProto *)__unused mtProto isNetworkAvailable:(bool)isNetworkAvailable
{
    _isNetworkAvailable = isNetworkAvailable;
    
    [self updateHoldUpdates];
}

- (void)mtProtoConnectionStateChanged:(MTProto *)__unused mtProto isConnected:(bool)isConnected
{
    _isConnected = isConnected;
    
    [self updateHoldUpdates];
}

- (void)mtProtoConnectionContextUpdateStateChanged:(MTProto *)__unused mtProto isUpdatingConnectionContext:(bool)isUpdatingConnectionContext
{
    _isUpdatingConnectionContext = isUpdatingConnectionContext;
    
    [self updateHoldUpdates];
}

- (void)mtProtoServiceTasksStateChanged:(MTProto *)__unused mtProto isPerformingServiceTasks:(bool)isPerformingServiceTasks
{
    _isPerformingServiceTasks = isPerformingServiceTasks;
    
    [self updateHoldUpdates];
}

- (void)updateHoldUpdates
{
    bool holdUpdates = (!_isConnected) || _isUpdatingConnectionContext || _isPerformingServiceTasks;
    
    if (_holdUpdates != holdUpdates)
    {
        _holdUpdates = holdUpdates;
        
        if (!_holdUpdates)
        {
            _scheduledMessageProcessing = false;
            [self addMessageToQueueAndScheduleProcessing:nil];
        }
    }
}

- (void)mtProtoDidChangeSession:(MTProto *)__unused mtProto
{
    [self reset:true];
}

- (void)mtProtoServerDidChangeSession:(MTProto *)__unused mtProto firstValidMessageId:(int64_t)__unused firstValidMessageId otherValidMessageIds:(NSArray *)__unused otherValidMessageIds
{
    [self reset:false];
}

- (void)mtProto:(MTProto *)__unused mtProto receivedMessage:(MTIncomingMessage *)incomingMessage
{
    if ([incomingMessage.body isKindOfClass:[TLUpdates class]])
        [self addMessageToQueueAndScheduleProcessing:incomingMessage];
}

- (void)addMessageToQueueAndScheduleProcessing:(MTIncomingMessage *)message
{
    if (message != nil)
        [_messagesToProcess addObject:message];
    
    if (!_scheduledMessageProcessing && !_holdUpdates)
    {
        _scheduledMessageProcessing = true;
        
        int currentSessionToken = _sessionToken;
        dispatch_async(_queue.nativeQueue, ^
        {
            _scheduledMessageProcessing = false;
            
            if (currentSessionToken != _sessionToken)
                return;
            
            NSArray *messages = [[NSArray alloc] initWithArray:_messagesToProcess];
            [_messagesToProcess removeAllObjects];
            [self processMessages:messages];
        });
    }
}

- (void)processMessages:(NSArray *)messages
{
    NSMutableArray *statelessUpdateList = [[NSMutableArray alloc] init];
    NSMutableArray *statefulUpdateList = [[NSMutableArray alloc] init];
    
    for (MTIncomingMessage *incomingMessage in messages)
    {
        [self processMessage:incomingMessage statelessUpdateList:statelessUpdateList statefulUpdateList:statefulUpdateList];
    }
    
    if (statelessUpdateList.count != 0)
    {
        [statelessUpdateList sortUsingComparator:^NSComparisonResult(TGUpdateMessage *updateMessage1, TGUpdateMessage *updateMessage2)
        {
            TLUpdates$updateShort *message1 = updateMessage1.message;
            TLUpdates$updateShort *message2 = updateMessage2.message;
            return message1.date < message2.date ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        NSMutableArray *statelessUpdatesSequence = [[NSMutableArray alloc] init];
        
        for (TGUpdateMessage *updateMessage in statelessUpdateList)
        {
            TLUpdates$updateShort *message = updateMessage.message;
            
            [statelessUpdatesSequence addObject:[[TGUpdate alloc] initWithUpdates:[[NSArray alloc] initWithObjects:message.update, nil] date:message.date beginSeq:0 endSeq:0 messageDate:updateMessage.messageDate usersDesc:nil chatsDesc:nil]];
        }
        
        if (statelessUpdatesSequence.count != 0)
        {
            static int statelessUpdatesId = 0;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/service/tryupdates/(stateless%d)", statelessUpdatesId++] options:[NSDictionary dictionaryWithObjectsAndKeys:statelessUpdatesSequence, @"multipleUpdates", [NSNumber numberWithInt:-1], @"unreadCount", nil] watcher:TGTelegraphInstance];
        }
    }
    
    if (statefulUpdateList.count != 0)
    {
        NSMutableArray *updatesArray = [[NSMutableArray alloc] init];
        
        for (TGUpdateMessage *updateMessage in statefulUpdateList)
        {
            if ([updateMessage.message isKindOfClass:[TLUpdates$updates class]])
            {
                TLUpdates$updates *update = updateMessage.message;
                
                [updatesArray addObject:[[TGUpdate alloc] initWithUpdates:update.updates date:update.date beginSeq:update.seq endSeq:update.seq messageDate:updateMessage.messageDate usersDesc:update.users chatsDesc:update.chats]];
            }
            else if ([updateMessage.message isKindOfClass:[TLUpdates$updatesCombined class]])
            {
                TLUpdates$updatesCombined *updatesCombined = updateMessage.message;
                
                [updatesArray addObject:[[TGUpdate alloc] initWithUpdates:updatesCombined.updates date:updatesCombined.date beginSeq:updatesCombined.seq_start endSeq:updatesCombined.seq messageDate:updateMessage.messageDate usersDesc:updatesCombined.users chatsDesc:updatesCombined.chats]];
            }
        }
        
        [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(stateful)" options:[[NSDictionary alloc] initWithObjectsAndKeys:updatesArray, @"multipleUpdates", [[NSNumber alloc] initWithBool:true], @"stateful", nil] watcher:TGTelegraphInstance];
    }
}

- (void)processMessage:(MTIncomingMessage *)incomingMessage statelessUpdateList:(NSMutableArray *)statelessUpdateList statefulUpdateList:(NSMutableArray *)statefulUpdateList
{
    if ([incomingMessage.body isKindOfClass:[TLUpdates$updateShort class]])
        [statelessUpdateList addObject:[[TGUpdateMessage alloc] initWithMessage:incomingMessage.body messageDate:(int)incomingMessage.timestamp]];
    else if ([incomingMessage.body isKindOfClass:[TLUpdates$updateShortMessage class]] || [incomingMessage.body isKindOfClass:[TLUpdates$updateShortChatMessage class]])
    {
        TLUpdate$updateNewMessage *newMessageUpdate = [[TLUpdate$updateNewMessage alloc] init];
        
        TLMessage$message *newMessage = [[TLMessage$message alloc] init];
        newMessage.n_id = ((TLUpdates$updateShortMessage *)incomingMessage.body).n_id;
        newMessage.from_id = ((TLUpdates$updateShortMessage *)incomingMessage.body).from_id;
        
        if ([incomingMessage.body isKindOfClass:[TLUpdates$updateShortMessage class]])
        {
            TLPeer$peerUser *peerUser = [[TLPeer$peerUser alloc] init];
            peerUser.user_id = TGTelegraphInstance.clientUserId;
            newMessage.to_id = peerUser;
        }
        else
        {
            TLPeer$peerChat *peerChat = [[TLPeer$peerChat alloc] init];
            peerChat.chat_id = ((TLUpdates$updateShortChatMessage *)incomingMessage.body).chat_id;
            newMessage.to_id = peerChat;
        }
        
        newMessage.flags = 1;
        newMessage.date = ((TLUpdates$updateShortMessage *)incomingMessage.body).date;
        newMessage.message = ((TLUpdates$updateShortMessage *)incomingMessage.body).message;
        newMessage.media = [[TLMessageMedia$messageMediaEmpty alloc] init];
        
        newMessageUpdate.pts = ((TLUpdates$updateShortMessage *)incomingMessage.body).pts;
        newMessageUpdate.message = newMessage;
        
        TLUpdates$updates *actualUpdates = [[TLUpdates$updates alloc] init];
        actualUpdates.updates = [[NSArray alloc] initWithObjects:newMessageUpdate, nil];
        actualUpdates.date = ((TLUpdates$updateShortMessage *)incomingMessage.body).date;
        actualUpdates.seq = ((TLUpdates$updateShortMessage *)incomingMessage.body).seq;
        
        MTIncomingMessage *surrogateIncomingMessage = [[MTIncomingMessage alloc] initWithMessageId:incomingMessage.messageId seqNo:incomingMessage.seqNo salt:incomingMessage.salt timestamp:incomingMessage.timestamp size:incomingMessage.size body:actualUpdates];
        [self processMessage:surrogateIncomingMessage statelessUpdateList:statelessUpdateList statefulUpdateList:statefulUpdateList];
    }
    else if ([incomingMessage.body isKindOfClass:[TLUpdates$updatesTooLong class]])
    {
        if (TGTelegraphInstance.clientUserId != 0)
            [ActionStageInstance() requestActor:@"/tg/service/updatestate" options:nil watcher:TGTelegraphInstance];
    }
    else if ([incomingMessage.body isKindOfClass:[TLUpdates$updates class]] || [incomingMessage.body isKindOfClass:[TLUpdates$updatesCombined class]])
    {
        //#ifdef DEBUG
        if ([incomingMessage.body isKindOfClass:[TLUpdates$updatesCombined class]])
            TGLog(@"#### Update seq = [%d..%d]", ((TLUpdates$updatesCombined *)incomingMessage.body).seq_start, ((TLUpdates$updatesCombined *)incomingMessage.body).seq);
        else
            TGLog(@"#### Update seq = %d", ((TLUpdates$updates *)incomingMessage.body).seq);
        //#endif
        
        NSArray *statelessUpdates = [TGApplyUpdatesActor filterStatelessUpdates:(TLUpdates *)incomingMessage.body];
        for (id updateBody in statelessUpdates)
        {
            [statelessUpdateList addObject:[[TGUpdateMessage alloc] initWithMessage:updateBody messageDate:(int)incomingMessage.timestamp]];
        }
        
        if (((TLUpdates$updates *)incomingMessage.body).seq != 0)
        {
            if (((TLUpdates$updates *)incomingMessage.body).updates.count == 0)
                [self updatePts:0 date:0 seq:((TLUpdates$updates *)incomingMessage.body).seq];
            else
            {
                [statefulUpdateList addObject:[[TGUpdateMessage alloc] initWithMessage:incomingMessage.body messageDate:(int)incomingMessage.timestamp]];
            }
        }
        else if (((TLUpdates$updates *)incomingMessage.body).updates.count != 0)
        {
            NSArray *convertedUpdates = [TGApplyUpdatesActor makeStatelessUpdates:(TLUpdates *)incomingMessage.body];
            for (id updateBody in convertedUpdates)
            {
                [statelessUpdateList addObject:[[TGUpdateMessage alloc] initWithMessage:updateBody messageDate:(int)incomingMessage.timestamp]];
            }
        }
    }
}

- (void)updatePts:(int)pts date:(int)date seq:(int)seq
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TLUpdate$updateChangePts *ptsUpdate = [[TLUpdate$updateChangePts alloc] init];
        ptsUpdate.pts = pts;
        NSArray *updatesArray = [[NSArray alloc] initWithObjects:[[TGUpdate alloc] initWithUpdates:[[NSArray alloc] initWithObjects:ptsUpdate, nil] date:date beginSeq:seq endSeq:seq messageDate:date usersDesc:nil chatsDesc:nil], nil];
        [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(stateful)" options:[[NSDictionary alloc] initWithObjectsAndKeys:updatesArray, @"multipleUpdates", [[NSNumber alloc] initWithBool:true], @"stateful", nil] watcher:TGTelegraphInstance];
    }];
}

@end
