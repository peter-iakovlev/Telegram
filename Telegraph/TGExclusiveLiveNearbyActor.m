#import "TGExclusiveLiveNearbyActor.h"

#import "ActionStage.h"
#import "TGLiveNearbyActor.h"

@implementation TGExclusiveLiveNearbyActor

@synthesize actionHandle = _actionHandle;

+ (NSString *)genericPath
{
    return @"/tg/exclusiveLiveNearby/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        _actionHandle.delegate = self;
        
        if ([path hasSuffix:@"(holdTimeout)"])
            self.cancelTimeout = 5 * 60;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)execute:(NSDictionary *)__unused options
{
    [ActionStageInstance() requestActor:@"/tg/liveNearby" options:nil watcher:self];
    
    if ([self.path hasSuffix:@"(discloseLocation)"])
    {
        TGLiveNearbyActor *actor = (TGLiveNearbyActor *)[ActionStageInstance() executingActorWithPath:@"/tg/liveNearby"];
        if (actor != nil)
        {
            actor.discloseLocation = true;
            [actor forceCheckNearby];
        }
    }
}

- (void)cancel
{
    [ActionStageInstance() removeWatcher:self];
    
    if ([self.path hasSuffix:@"(discloseLocation)"])
    {
        TGLiveNearbyActor *actor = (TGLiveNearbyActor *)[ActionStageInstance() executingActorWithPath:@"/tg/liveNearby"];
        if (actor != nil)
            actor.discloseLocation = false;
    }
}

@end
