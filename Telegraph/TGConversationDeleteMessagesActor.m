#import "TGConversationDeleteMessagesActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGDownloadManager.h"

@implementation TGConversationDeleteMessagesActor

+ (NSString *)genericPath
{
    return @"/tg/conversation/@/deleteMessages/@";
}

- (void)execute:(NSDictionary *)options
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
    
    NSArray *messageIds = [options objectForKey:@"mids"];
    
    [[TGDownloadManager instance] cancelItemsWithMessageIdsInArray:messageIds];
    
    NSMutableDictionary *messagesByConversation = [[NSMutableDictionary alloc] init];
    [TGDatabaseInstance() deleteMessages:messageIds populateActionQueue:true fillMessagesByConversationId:messagesByConversation];
    
    [messagesByConversation enumerateKeysAndObjectsUsingBlock:^(NSNumber *nConversationId, NSArray *messagesInConversation, __unused BOOL *stop)
    {
        for (NSNumber *nMid in messagesInConversation)
        {
            int32_t mid = (int32_t)[nMid intValue];
            if (mid >= TGMessageLocalMidBaseline)
            {
                [ActionStageInstance() removeAllWatchersFromPath:[[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%lld)/(%d)", [nConversationId longLongValue], [nMid intValue]]];
                [ActionStageInstance() removeAllWatchersFromPath:[[NSString alloc] initWithFormat:@"/tg/sendSecretMessage/(%lld)/(%d)", [nConversationId longLongValue], [nMid intValue]]];
            }
        }
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", [nConversationId longLongValue]] resource:[[SGraphObjectNode alloc] initWithObject:messagesInConversation]];
    }];
    
    dispatch_async([ActionStageInstance() globalStageDispatchQueue], ^
    {
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(global)" options:nil watcher:TGTelegraphInstance];
    });
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
