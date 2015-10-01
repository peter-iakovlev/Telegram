#import "TGSynchronizationStateSignal.h"

#import "TGTelegramNetworking.h"
#import "ActionStage.h"

@interface TGSynchronizationStateHelper : NSObject <ASWatcher>
{
    void (^_updated)(NSNumber *);
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGSynchronizationStateHelper

- (instancetype)initWithUpdated:(void (^)(NSNumber *))updated
{
    self = [super init];
    if (self != nil)
    {
        _updated = [updated copy];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];

        [ActionStageInstance() requestActor:@"/tg/service/synchronizationstate" options:nil flags:0 watcher:self];
        [ActionStageInstance() watchForPaths:@[@"/tg/service/synchronizationstate"] watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/service/synchronizationstate"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path isEqualToString:@"/tg/service/synchronizationstate"])
    {
        if (status == ASStatusSuccess)
        {
            int state = [((SGraphObjectNode *)result).object intValue];
            
            TGSynchronizationStateValue value = TGSynchronizationStateSynchronized;
            
            if (state & 2)
            {
                if (state & 4)
                    value = TGSynchronizationStateWaitingForNetwork;
                else
                    value = TGSynchronizationStateConnecting;
            }
            else if (state & 1)
                value = TGSynchronizationStateUpdating;
            
            if (_updated)
                _updated(@((int)value));
        }
    }
}

@end

@implementation TGSynchronizationStateSignal

+ (SSignal *)synchronizationState
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGSynchronizationStateHelper *helper = [[TGSynchronizationStateHelper alloc] initWithUpdated:^(NSNumber *value)
        {
            [subscriber putNext:value];
        }];
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [helper description]; //keep reference
        }];
    }];
}

@end
