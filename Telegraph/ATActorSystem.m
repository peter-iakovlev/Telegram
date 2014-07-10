#import "ATActorSystem.h"

#import "ATQueue.h"
#import "ATActor.h"

#import <pthread.h>

#define DEBUG_ATActorSystem true

@interface ATActorSystem ()
{
    ATQueue *_queue;
    
    NSMutableDictionary *_actorsByPath;
    pthread_rwlock_t _actorsByPathLock;
}

@end

@implementation ATActorSystem

- (instancetype)init
{
    return [self initWithQueue:nil];
}

- (instancetype)initWithQueue:(ATQueue *)queue
{
    self = [super init];
    if (self != nil)
    {
        if (queue == nil)
            _queue = [[ATQueue alloc] init];
        else
            _queue = queue;
        
        _actorsByPath = [[NSMutableDictionary alloc] init];
        pthread_rwlock_init(&_actorsByPathLock, NULL);
        
#if DEBUG_ATActorSystem
        TGLog(@"[ATActorSystem#%p created]", self);
#endif
    }
    return self;
}

- (void)dealloc
{
    pthread_rwlock_rdlock(&_actorsByPathLock);
    [_actorsByPath enumerateKeysAndObjectsUsingBlock:^(__unused NSString *path, ATActor *actor, __unused BOOL *stop)
    {
        [[actor queue] dispatch:^
        {
            [actor onTerminate];
        }];
    }];
    pthread_rwlock_unlock(&_actorsByPathLock);
}

- (ATQueue *)queue
{
    return _queue;
}

- (bool)addActor:(ATActor *)actor
{
    if (actor == nil)
        return false;
    
    bool result = false;
    
    pthread_rwlock_wrlock(&_actorsByPathLock);
    NSString *path = [actor path];
    if (_actorsByPath[path] == nil)
    {
        result = true;
        _actorsByPath[path] = actor;
    }
    pthread_rwlock_unlock(&_actorsByPathLock);
    
    if (result)
    {
        [self sendMessage:ATActorMessageStart toPath:[actor path] sender:nil];

#if DEBUG_ATActorSystem
        TGLog(@"[ATActorSystem#%p added actor %@#%p]", self, NSStringFromClass([actor class]), actor);
#endif
    }
    
    return result;
}

- (void)_removeActor:(ATActor *)actor
{
    if (actor == nil)
        return;
    
    pthread_rwlock_wrlock(&_actorsByPathLock);
    NSString *path = [actor path];
    [_actorsByPath removeObjectForKey:path];
    pthread_rwlock_unlock(&_actorsByPathLock);
    
#if DEBUG_ATActorSystem
    TGLog(@"[ATActorSystem#%p removed actor %@#p]", self, NSStringFromClass([actor class]), actor);
#endif
}

- (void)sendMessage:(id)message toPath:(NSString *)path sender:(id<ATMessageReceiver>)sender
{
    if (path == nil)
        return;
    
    ATActor *actor = nil;
    
    pthread_rwlock_rdlock(&_actorsByPathLock);
    actor = _actorsByPath[path];
    pthread_rwlock_unlock(&_actorsByPathLock);
    
#if DEBUG_ATActorSystem
    TGLog(@"[ATActorSystem#%p message to %@: %@]", self, path, message);
#endif
    
    [actor receiveMessage:message sender:sender];
}

@end
