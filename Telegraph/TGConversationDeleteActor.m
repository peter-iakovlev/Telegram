#import "TGConversationDeleteActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGDownloadManager.h"

#import "TGPeerIdAdapter.h"

#import "TGChannelManagementSignals.h"

@implementation TGConversationDeleteActor

+ (NSString *)genericPath
{
    return @"/tg/conversation/@/delete";
}

- (void)execute:(NSDictionary *)options
{
    int64_t conversationId = [[options objectForKey:@"conversationId"] longLongValue];
    if (conversationId == 0)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    [[TGDownloadManager instance] cancelItemsWithGroupId:conversationId];
    
    if (TGPeerIdIsChannel(conversationId)) {
        [TGDatabaseInstance() enqueueLeaveChannel:conversationId];
    } else {
        TGUser *user = conversationId > 0 ? [TGDatabaseInstance() loadUser:(int)conversationId] : nil;
        if ([options[@"block"] boolValue] && user != nil && (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot))
        {
            static int actionId = 0;
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/changePeerBlockedStatus/(auto%d)", actionId++] options:@{@"peerId": @(conversationId), @"block": @(true)} watcher:TGTelegraphInstance];
        }
        
        [TGDatabaseInstance() deleteConversation:conversationId populateActionQueue:true];
    }
    
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
