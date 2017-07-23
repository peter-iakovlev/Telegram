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
#import "TLUpdates+TG.h"

#import "TGUpdatesWithPts.h"
#import "TGUpdatesWithQts.h"
#import "TGUpdatesWithSeq.h"
#import "TGUpdatesWithDate.h"

#import "TLUpdates$modernUpdateShortMessage.h"
#import "TLUpdates$modernUpdateShortChatMessage.h"
#import "TLMessage$modernMessage.h"

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
    NSMutableArray *collectedUpdatesWithPts = [[NSMutableArray alloc] init];
    NSMutableArray *collectedUpdatesWithQts = [[NSMutableArray alloc] init];
    NSMutableArray *collectedUpdatesWithSeq = [[NSMutableArray alloc] init];
    NSMutableArray *collectedUpdatesWithDate = [[NSMutableArray alloc] init];
    
    for (MTIncomingMessage *incomingMessage in messages)
    {
        if ([incomingMessage.body isKindOfClass:[TLUpdates$updates class]] || [incomingMessage.body isKindOfClass:[TLUpdates$updatesCombined class]])
        {
            NSArray *containedUpdates = @[];
            int32_t updatesSeqStart = 0;
            int32_t updatesSeqEnd = 0;
            int32_t updatesDate = 0;
            NSArray *updatesUsers = nil;
            NSArray *updatesChats = nil;
            
            if ([incomingMessage.body isKindOfClass:[TLUpdates$updates class]])
            {
                TLUpdates$updates *updates = (TLUpdates$updates *)incomingMessage.body;
                containedUpdates = updates.updates;
                updatesSeqStart = updates.seq;
                updatesSeqEnd = updates.seq;
                updatesDate = updates.date;
                updatesUsers = updates.users;
                updatesChats = updates.chats;
            }
            else if ([incomingMessage.body isKindOfClass:[TLUpdates$updatesCombined class]])
            {
                TLUpdates$updatesCombined *updatesCombined = (TLUpdates$updatesCombined *)incomingMessage.body;
                containedUpdates = updatesCombined.updates;
                updatesSeqStart = updatesCombined.seq_start;
                updatesSeqEnd = updatesCombined.seq;
                updatesDate = updatesCombined.date;
                updatesUsers = updatesCombined.users;
                updatesChats = updatesCombined.chats;
            }
            
            NSMutableArray *updatesWithPts = [[NSMutableArray alloc] init];
            NSMutableArray *updatesWithQts = [[NSMutableArray alloc] init];
            NSMutableArray *otherUpdates = [[NSMutableArray alloc] init];
            
            for (TLUpdate *update in containedUpdates)
            {
                if ([update hasPts])
                {
                    NSAssert([update respondsToSelector:@selector(pts_count)], @"update with pts should also contain pts_count");
                    [updatesWithPts addObject:update];
                }
                if ([update respondsToSelector:@selector(qts)])
                {
                    [updatesWithQts addObject:update];
                }
                else
                    [otherUpdates addObject:update];
            }
            
            if (updatesWithPts.count != 0)
            {
                [collectedUpdatesWithPts addObject:[[TGUpdatesWithPts alloc] initWithUpdates:updatesWithPts users:updatesUsers chats:updatesChats]];
            }
            
            if (updatesWithQts.count != 0)
            {
                [collectedUpdatesWithQts addObject:[[TGUpdatesWithQts alloc] initWithUpdates:updatesWithQts users:updatesUsers chats:updatesChats]];
            }
            
            if (updatesSeqEnd != 0)
            {
                [collectedUpdatesWithSeq addObject:[[TGUpdatesWithSeq alloc] initWithUpdates:otherUpdates date:updatesDate seqStart:updatesSeqStart seqEnd:updatesSeqEnd users:updatesUsers chats:updatesChats]];
            }
            else
            {
                [collectedUpdatesWithDate addObject:[[TGUpdatesWithDate alloc] initWithUpdates:otherUpdates date:updatesDate users:updatesUsers chats:updatesChats]];
            }
        }
        else if ([incomingMessage.body isKindOfClass:[TLUpdates$updateShort class]])
        {
            TLUpdates$updateShort *updateShort = (TLUpdates$updateShort *)incomingMessage.body;
            if ([updateShort.update hasPts])
            {
                NSAssert([updateShort.update respondsToSelector:@selector(pts_count)], @"update with pts should also contain pts_count");
                [collectedUpdatesWithPts addObject:[[TGUpdatesWithPts alloc] initWithUpdates:@[updateShort.update] users:nil chats:nil]];
            }
            else if ([updateShort.update respondsToSelector:@selector(qts)])
            {
                [collectedUpdatesWithQts addObject:[[TGUpdatesWithQts alloc] initWithUpdates:@[updateShort.update] users:nil chats:nil]];
            }
            else
            {
                [collectedUpdatesWithDate addObject:[[TGUpdatesWithDate alloc] initWithUpdates:@[updateShort.update] date:updateShort.date users:nil chats:nil]];
            }
        }
        else if ([incomingMessage.body isKindOfClass:[TLUpdates$modernUpdateShortChatMessage class]])
        {
            TLUpdates$modernUpdateShortChatMessage *updateShortChatMessage = (TLUpdates$modernUpdateShortChatMessage *)incomingMessage.body;
            
            TLMessage$modernMessage *synthesizedMessage = [[TLMessage$modernMessage alloc] init];
            synthesizedMessage.n_id = updateShortChatMessage.n_id;
            synthesizedMessage.flags = updateShortChatMessage.flags;
            synthesizedMessage.from_id = updateShortChatMessage.from_id;
            TLPeer$peerChat *toId = [[TLPeer$peerChat alloc] init];
            toId.chat_id = updateShortChatMessage.chat_id;
            synthesizedMessage.to_id = toId;
            synthesizedMessage.date = updateShortChatMessage.date;
            synthesizedMessage.message = updateShortChatMessage.message;
            synthesizedMessage.media = [[TLMessageMedia$messageMediaEmpty alloc] init];
            synthesizedMessage.fwd_from = updateShortChatMessage.fwd_header;
            synthesizedMessage.reply_to_msg_id = updateShortChatMessage.reply_to_msg_id;
            synthesizedMessage.entities = updateShortChatMessage.entities;
            synthesizedMessage.via_bot_id = updateShortChatMessage.via_bot_id;
            
            TLUpdate$updateNewMessage *updateNewMessage = [[TLUpdate$updateNewMessage alloc] init];
            updateNewMessage.message = synthesizedMessage;
            updateNewMessage.pts = updateShortChatMessage.pts;
            updateNewMessage.pts_count = updateShortChatMessage.pts_count;
            
            [collectedUpdatesWithPts addObject:[[TGUpdatesWithPts alloc] initWithUpdates:@[updateNewMessage] users:nil chats:nil]];
        }
        else if ([incomingMessage.body isKindOfClass:[TLUpdates$modernUpdateShortMessage class]])
        {
            TLUpdates$modernUpdateShortMessage *updateShortMessage = (TLUpdates$modernUpdateShortMessage *)incomingMessage.body;
            
            TLMessage$modernMessage *synthesizedMessage = [[TLMessage$modernMessage alloc] init];
            synthesizedMessage.n_id = updateShortMessage.n_id;
            synthesizedMessage.flags = updateShortMessage.flags;
            if (updateShortMessage.flags & 2) //outgoing
            {
                synthesizedMessage.from_id = TGTelegraphInstance.clientUserId;
                TLPeer$peerUser *toId = [[TLPeer$peerUser alloc] init];
                toId.user_id = updateShortMessage.user_id;
                synthesizedMessage.to_id = toId;
            }
            else
            {
                synthesizedMessage.from_id = updateShortMessage.user_id;
                TLPeer$peerUser *toId = [[TLPeer$peerUser alloc] init];
                toId.user_id = TGTelegraphInstance.clientUserId;
                synthesizedMessage.to_id = toId;
            }
            synthesizedMessage.date = updateShortMessage.date;
            synthesizedMessage.message = updateShortMessage.message;
            synthesizedMessage.media = [[TLMessageMedia$messageMediaEmpty alloc] init];
            synthesizedMessage.fwd_from = updateShortMessage.fwd_header;
            synthesizedMessage.reply_to_msg_id = updateShortMessage.reply_to_msg_id;
            synthesizedMessage.entities = updateShortMessage.entities;
            synthesizedMessage.via_bot_id = updateShortMessage.via_bot_id;
            
            TLUpdate$updateNewMessage *updateNewMessage = [[TLUpdate$updateNewMessage alloc] init];
            updateNewMessage.message = synthesizedMessage;
            updateNewMessage.pts = updateShortMessage.pts;
            updateNewMessage.pts_count = updateShortMessage.pts_count;
            
            [collectedUpdatesWithPts addObject:[[TGUpdatesWithPts alloc] initWithUpdates:@[updateNewMessage] users:nil chats:nil]];
        }
        else if ([incomingMessage.body isKindOfClass:[TLUpdates$updatesTooLong class]])
        {
            if (TGTelegraphInstance.clientUserId != 0)
                [ActionStageInstance() requestActor:@"/tg/service/updatestate" options:nil watcher:TGTelegraphInstance];
        }
        else
            NSAssert(false, @"Unknown updates message class %@", incomingMessage.body);
    }
    
    if (collectedUpdatesWithPts.count != 0)
    {
        [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(withPts)" options:@{@"updates": collectedUpdatesWithPts} watcher:TGTelegraphInstance];
    }
    
    if (collectedUpdatesWithQts.count != 0)
    {
        [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(withQts)" options:@{@"updates": collectedUpdatesWithQts} watcher:TGTelegraphInstance];
    }
    
    if (collectedUpdatesWithSeq.count != 0)
    {
        [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(withSeq)" options:@{@"updates": collectedUpdatesWithSeq} watcher:TGTelegraphInstance];
    }
    
    if (collectedUpdatesWithDate.count != 0)
    {
        [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(withDate)" options:@{@"updates": collectedUpdatesWithDate} watcher:TGTelegraphInstance];
    }
}

- (void)updatePts:(int)pts ptsCount:(int)ptsCount seq:(int)seq
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (pts != 0)
        {
            TLUpdate$updateChangePts *ptsUpdate = [[TLUpdate$updateChangePts alloc] init];
            ptsUpdate.pts = pts;
            ptsUpdate.pts_count = ptsCount;
            TGUpdatesWithPts *synthesizedUpdatesWithPts = [[TGUpdatesWithPts alloc] initWithUpdates:@[ptsUpdate] users:nil chats:nil];
            [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(withPts)" options:@{@"updates": @[synthesizedUpdatesWithPts]} watcher:TGTelegraphInstance];
        }
        
        if (seq != 0)
        {
            TGUpdatesWithSeq *synthesizedUpdatesWithSeq = [[TGUpdatesWithSeq alloc] initWithUpdates:@[] date:0 seqStart:seq seqEnd:seq users:nil chats:nil];
            [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(withSeq)" options:@{@"updates": @[synthesizedUpdatesWithSeq]} watcher:TGTelegraphInstance];
        }
    }];
}

- (void)addUpdates:(id)body
{
    NSMutableArray *collectedUpdatesWithPts = [[NSMutableArray alloc] init];
    NSMutableArray *collectedUpdatesWithQts = [[NSMutableArray alloc] init];
    NSMutableArray *collectedUpdatesWithSeq = [[NSMutableArray alloc] init];
    NSMutableArray *collectedUpdatesWithDate = [[NSMutableArray alloc] init];
    
    NSArray *containedUpdates = @[];
    int32_t updatesSeqStart = 0;
    int32_t updatesSeqEnd = 0;
    int32_t updatesDate = 0;
    NSArray *updatesUsers = nil;
    NSArray *updatesChats = nil;
    
    if ([body isKindOfClass:[TLUpdates$updates class]])
    {
        TLUpdates$updates *updates = (TLUpdates$updates *)body;
        containedUpdates = updates.updates;
        updatesSeqStart = updates.seq;
        updatesSeqEnd = updates.seq;
        updatesDate = updates.date;
        updatesUsers = updates.users;
        updatesChats = updates.chats;
    }
    else if ([body isKindOfClass:[TLUpdates$updatesCombined class]])
    {
        TLUpdates$updatesCombined *updatesCombined = (TLUpdates$updatesCombined *)body;
        containedUpdates = updatesCombined.updates;
        updatesSeqStart = updatesCombined.seq_start;
        updatesSeqEnd = updatesCombined.seq;
        updatesDate = updatesCombined.date;
        updatesUsers = updatesCombined.users;
        updatesChats = updatesCombined.chats;
    }
    
    NSMutableArray *updatesWithPts = [[NSMutableArray alloc] init];
    NSMutableArray *updatesWithQts = [[NSMutableArray alloc] init];
    NSMutableArray *otherUpdates = [[NSMutableArray alloc] init];
    
    for (TLUpdate *update in containedUpdates)
    {
        if ([update hasPts])
        {
            NSAssert([update respondsToSelector:@selector(pts_count)], @"update with pts should also contain pts_count");
            [updatesWithPts addObject:update];
        }
        if ([update respondsToSelector:@selector(qts)])
        {
            [updatesWithQts addObject:update];
        }
        else
            [otherUpdates addObject:update];
    }
    
    if (updatesWithPts.count != 0)
    {
        [collectedUpdatesWithPts addObject:[[TGUpdatesWithPts alloc] initWithUpdates:updatesWithPts users:updatesUsers chats:updatesChats]];
    }
    
    if (updatesWithQts.count != 0)
    {
        [collectedUpdatesWithQts addObject:[[TGUpdatesWithQts alloc] initWithUpdates:updatesWithQts users:updatesUsers chats:updatesChats]];
    }
    
    if (updatesSeqEnd != 0)
    {
        [collectedUpdatesWithSeq addObject:[[TGUpdatesWithSeq alloc] initWithUpdates:otherUpdates date:updatesDate seqStart:updatesSeqStart seqEnd:updatesSeqEnd users:updatesUsers chats:updatesChats]];
    }
    else
    {
        [collectedUpdatesWithDate addObject:[[TGUpdatesWithDate alloc] initWithUpdates:otherUpdates date:updatesDate users:updatesUsers chats:updatesChats]];
    }
    
    if (collectedUpdatesWithPts.count != 0)
    {
        [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(withPts)" options:@{@"updates": collectedUpdatesWithPts} watcher:TGTelegraphInstance];
    }
    
    if (collectedUpdatesWithQts.count != 0)
    {
        [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(withQts)" options:@{@"updates": collectedUpdatesWithQts} watcher:TGTelegraphInstance];
    }
    
    if (collectedUpdatesWithSeq.count != 0)
    {
        [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(withSeq)" options:@{@"updates": collectedUpdatesWithSeq} watcher:TGTelegraphInstance];
    }
    
    if (collectedUpdatesWithDate.count != 0)
    {
        [ActionStageInstance() requestActor:@"/tg/service/tryupdates/(withDate)" options:@{@"updates": collectedUpdatesWithDate} watcher:TGTelegraphInstance];
    }
}

@end
