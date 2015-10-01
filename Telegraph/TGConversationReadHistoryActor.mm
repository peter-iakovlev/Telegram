#import "TGConversationReadHistoryActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGDatabase.h"

#import "TGPeerIdAdapter.h"

@implementation TGConversationReadHistoryActor

+ (NSString *)genericPath
{
    return @"/tg/conversations/@/readHistory/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
    }
    return self;
}

- (void)execute:(NSDictionary *)options
{
    NSRange range;
    range.location = [@"/tg/conversations/(" length];
    range.length = [self.path rangeOfString:@")/" options:NSLiteralSearch range:NSMakeRange(range.location, [self.path length] - range.location)].location - range.location;
    int64_t conversationId = [[self.path substringWithRange:range] longLongValue];
    
    int minRemoteMid = INT_MAX;
    if (options[@"minRemoteId"] != nil)
        minRemoteMid = [options[@"minRemoteId"] intValue];
    
    [TGDatabaseInstance() readHistory:conversationId includeOutgoing:conversationId == TGTelegraphInstance.clientUserId populateActionQueue:true minRemoteMid:minRemoteMid completion:^(bool hasItemsOnActionQueue)
    {
        if (hasItemsOnActionQueue)
            [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(global)" options:nil watcher:TGTelegraphInstance];
    }];
    
    [self conversationReadHistoryRequestSuccess:nil];
}

+ (void)executeStandalone:(int64_t)conversationId
{
    if (TGPeerIdIsChannel(conversationId)) {
        [TGDatabaseInstance() enqueueReadChannelHistory:conversationId];
    } else {
        [TGDatabaseInstance() readHistory:conversationId includeOutgoing:conversationId == TGTelegraphInstance.clientUserId populateActionQueue:true minRemoteMid:0 completion:^(bool hasItemsOnActionQueue)
        {
            if (hasItemsOnActionQueue)
                [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(global)" options:nil watcher:TGTelegraphInstance];
        }];
    }
}

- (void)conversationReadHistoryRequestSuccess:(NSArray *)__unused readMessages
{   
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)conversationReadHistoryRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)cancel
{
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
        self.cancelToken = nil;
    }
    
    [super cancel];
}

@end
