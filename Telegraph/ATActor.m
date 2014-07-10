#import "ATActor.h"

#import "ATActorSystem.h"
#import "ATQueue.h"

id ATActorMessageStart = @"ATActorMessageStart";
id ATActorMessageStop = @"ATActorMessageStop";

typedef enum {
    ATActorStateStopped = 0,
    ATActorStateRunning = 1
} ATActorState;

@interface ATActor ()
{
    __weak ATActorSystem *_actorSystem;
    ATQueue *_queue;

    NSString *_path;
    
    int _state;
}

@end

@implementation ATActor

- (instancetype)initWithActorSystem:(ATActorSystem *)actorSystem path:(NSString *)path
{
#ifdef DEBUG
    NSAssert(actorSystem != nil, @"actorSystem should not be nil");
    NSAssert(path != nil, @"path should not be nil");
#endif
    
    self = [super init];
    if (self != nil)
    {
        _actorSystem = actorSystem;
        _queue = [self executesOnDedicatedQueue] ? [[ATQueue alloc] init] : [actorSystem queue];
        _path = path;
    }
    return self;
}

- (bool)executesOnDedicatedQueue
{
    return false;
}

- (NSString *)path
{
    return _path;
}

- (ATActorSystem *)actorSystem
{
    return _actorSystem;
}

- (ATQueue *)queue
{
    return _queue;
}

- (bool)isRunning
{
    __block bool result = false;
    [[self queue] dispatch:^
    {
        result = _state == ATActorStateRunning;
    } synchronous:true];
    
    return result;
}

- (void)receiveMessage:(id)message sender:(id<ATMessageReceiver>)sender
{
    [[self queue] dispatch:^
    {
        [self processMessage:message sender:sender];
    }];
}

- (void)processMessage:(id)__unused message sender:(id<ATMessageReceiver>)__unused sender
{
    if ([message isEqual:ATActorMessageStart])
    {
        [[self queue] dispatch:^
        {
            if (![self isRunning])
            {
                _state = ATActorStateRunning;
                [self onStart];
            }
        }];
    }
    else if ([message isEqual:ATActorMessageStop])
    {
        [[self queue] dispatch:^
        {
            if ([self isRunning])
            {
                _state = ATActorStateStopped;
                [self onStop];
                
                [[self actorSystem] _removeActor:self];
            }
        }];
    }
}

- (void)onStart
{
}

- (void)onStop
{
}

- (void)onTerminate
{
    TGLog(@"[ATActor#%p terminated]", self);
}

@end
