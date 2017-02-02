#import "TGConversationClearHistoryActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGUpdateStateRequestBuilder.h"

@implementation TGConversationClearHistoryActor

+ (NSString *)genericPath
{
    return @"/tg/conversation/@/clearHistory/@";
}

- (void)execute:(NSDictionary *)options
{
    int64_t conversationId = [[options objectForKey:@"conversationId"] longLongValue];
    if (conversationId == 0)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    [ActionStageInstance() dispatchResource:@"/tg/conversation/historyCleared" resource:@(conversationId)];
    [TGDatabaseInstance() transactionClearConversationsWithPeerIds:@[@(conversationId)]];
    
    dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
    {
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(global)" options:nil watcher:TGTelegraphInstance];
        
        NSArray *sendMessageActors = [ActionStageInstance() executingActorsWithPathPrefix:[NSString stringWithFormat:@"/tg/sendCommonMessage/(%lld)/", conversationId]];
        for (TGActor *actor in sendMessageActors)
        {
            [ActionStageInstance() removeAllWatchersFromPath:actor.path];
        }
        
        sendMessageActors = [ActionStageInstance() executingActorsWithPathPrefix:[NSString stringWithFormat:@"/tg/sendSecretMessage/(%lld)/", conversationId]];
        for (TGActor *actor in sendMessageActors)
        {
            [ActionStageInstance() removeAllWatchersFromPath:actor.path];
        }
    });
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
