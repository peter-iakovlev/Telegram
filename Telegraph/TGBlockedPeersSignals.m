#import "TGBlockedPeersSignals.h"

#import "ActionStage.h"
#import "TGUser.h"
#import "TGTelegraph.h"

@interface TGBlockedPeersHelper : NSObject <ASWatcher>
{
    int64_t _peerId;
    void (^_blockedUpdated)(bool);
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGBlockedPeersHelper

- (instancetype)initWithPeerId:(int64_t)peerId blockedUpdated:(void (^)(bool))blockedUpdated
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _blockedUpdated = [blockedUpdated copy];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/blockedUsers/(%" PRId32 ",cached)", (int32_t)peerId] options:@{@"uid": @(peerId)} watcher:self];
            [ActionStageInstance() watchForPath:@"/tg/blockedUsers" watcher:self];
        }];
    }
    return self;
}

- (void)dealloc
{
    [ActionStageInstance() removeWatcher:self];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    [self actorCompleted:ASStatusSuccess path:path result:resource];
}

- (void)actorCompleted:(int)__unused status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/blockedUsers"])
    {
        id blockedResult = ((SGraphObjectNode *)result).object;
        
        bool blocked = false;
        
        if ([blockedResult respondsToSelector:@selector(boolValue)])
            blocked = [blockedResult boolValue];
        else if ([blockedResult isKindOfClass:[NSArray class]])
        {
            for (TGUser *user in blockedResult)
            {
                if (user.uid == _peerId)
                {
                    blocked = true;
                    break;
                }
            }
        }
        
        if (_blockedUpdated)
            _blockedUpdated(blocked);
    }
}

@end

@implementation TGBlockedPeersSignals

+ (SSignal *)peerBlockedStatusWithPeerId:(int64_t)peerId
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGBlockedPeersHelper *helper = [[TGBlockedPeersHelper alloc] initWithPeerId:peerId blockedUpdated:^(bool blocked)
        {
            [subscriber putNext:@(blocked)];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [helper description]; //keep reference
        }];
    }];
}

+ (SSignal *)updatePeerBlockedStatusWithPeerId:(int64_t)peerId blocked:(bool)blocked
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        static int actionId = 0;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/changePeerBlockedStatus/(cbs%d)", actionId++] options:@{@"peerId": @((int32_t)peerId), @"block": @(blocked)} watcher:TGTelegraphInstance];
        [subscriber putCompletion];
        
        return nil;
    }];
}

@end
