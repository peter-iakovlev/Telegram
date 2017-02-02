#import "TGConversationDeleteActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGDownloadManager.h"

#import "TGPeerIdAdapter.h"

#import "TGChannelManagementSignals.h"

#import "TGRecentPeersSignals.h"

@interface TGConversationDeleteActor () {
    id<SDisposable> _resetPeerRatingDisposable;
}

@end

@implementation TGConversationDeleteActor

+ (NSString *)genericPath
{
    return @"/tg/conversation/@/delete";
}

- (void)dealloc {
    [_resetPeerRatingDisposable dispose];
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
        [TGDatabaseInstance() transactionRemoveConversationsWithPeerIds:@[@(conversationId)]];
    } else {
        TGUser *user = conversationId > 0 ? [TGDatabaseInstance() loadUser:(int)conversationId] : nil;
        if ([options[@"block"] boolValue] && user != nil && (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot))
        {
            static int actionId = 0;
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/changePeerBlockedStatus/(auto%d)", actionId++] options:@{@"peerId": @(conversationId), @"block": @(true)} watcher:TGTelegraphInstance];
        }
        
        [TGDatabaseInstance() transactionRemoveConversationsWithPeerIds:@[@(conversationId)]];
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
    
    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
    if (conversation != nil) {
        int64_t accessHash = conversation.accessHash;
        if (TGPeerIdIsUser(conversationId)) {
            TGUser *user = [TGDatabaseInstance() loadUser:(int)conversationId];
            accessHash = user.phoneNumberHash;
        }
        _resetPeerRatingDisposable = [[TGRecentPeersSignals resetGenericPeerRating:conversation.conversationId accessHash:accessHash] startWithNext:nil error:^(__unused id error) {
            [ActionStageInstance() actionCompleted:self.path result:nil];
        } completed:^{
            [ActionStageInstance() actionCompleted:self.path result:nil];
        }];
    } else {
        [ActionStageInstance() actionCompleted:self.path result:nil];
    }
}
        
- (void)cancel {
    [super cancel];
    
    [_resetPeerRatingDisposable dispose];
}

@end
