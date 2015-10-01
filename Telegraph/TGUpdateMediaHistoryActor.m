#import "TGUpdateMediaHistoryActor.h"

#import "ActionStage.h"
#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGTimer.h"

#import "TGUserDataRequestBuilder.h"

#import "TL/TLMetaScheme.h"
#import "TGMessage+Telegraph.h"

@interface TGUpdateMediaHistoryActor ()
{
    int64_t _peerId;
    int32_t _maxMid;
    TGTimer *_timer;
}

@end

@implementation TGUpdateMediaHistoryActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/tg/updateMediaHistory/@";
}

- (void)dealloc
{
    [_timer invalidate];
}

- (void)execute:(NSDictionary *)options
{
    if (options[@"peerId"] == nil)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    _peerId = [options[@"peerId"] longLongValue];
    
    if (_peerId <= INT_MIN || [TGDatabaseInstance() loadPeerMinMediaMid:_peerId] != 0)
        [ActionStageInstance() actionCompleted:self.path result:nil];
    else
        [self _requestMoreHistory];
}

- (void)_requestMoreHistory
{
    [TGDatabaseInstance() loadLastRemoteMediaMessageIdInConversation:_peerId completion:^(int32_t messageId)
    {
        if (messageId == 0)
            [ActionStageInstance() actionCompleted:self.path result:nil];
        else
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                _maxMid = messageId;
                self.cancelToken = [TGTelegraphInstance doRequestConversationMediaHistory:_peerId accessHash:0 maxMid:messageId maxDate:0 limit:256 actor:self];
            }];
        }
    }];
}

- (void)mediaHistoryRequestSuccess:(TLmessages_Messages *)messages
{
    [TGUserDataRequestBuilder executeUserDataUpdate:messages.users];
    
    NSMutableArray *messageItems = [[NSMutableArray alloc] init];
    
    for (TLMessage *messageDesc in messages.messages)
    {
        if (messageDesc.n_id >= _maxMid)
            continue;
        
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
        if (message.mid != 0)
            [messageItems addObject:message];
    }
    
    if (messages.messages.count == 0)
    {
        [TGDatabaseInstance() storePeerMinMediaMid:_peerId minMediaMid:1];
        [ActionStageInstance() actionCompleted:self.path result:nil];
    }
    else
    {
        [TGDatabaseInstance() addMediaToConversation:_peerId messages:messageItems completion:nil];
        
        int32_t mediaCount = [TGDatabaseInstance() mediaCountInConversation:_peerId];
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/sharedMediaCount/(%" PRIx64 ")", _peerId] resource:@(mediaCount)];
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"messagesLoaded" message:messageItems];
    
        __weak TGUpdateMediaHistoryActor *weakSelf = self;
        _timer = [[TGTimer alloc] initWithTimeout:1.0 repeat:false completion:^
        {
            __strong TGUpdateMediaHistoryActor *strongSelf = weakSelf;
            [strongSelf _requestMoreHistory];
        } queue:[ActionStageInstance() globalStageDispatchQueue]];
        [_timer start];
    }
}

- (void)mediaHistoryRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
