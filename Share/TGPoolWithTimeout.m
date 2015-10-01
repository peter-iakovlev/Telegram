#import "TGPoolWithTimeout.h"

#import <SSignalKit/SSignalKit.h>

@interface TGPoolObject : NSObject

@property (nonatomic, strong, readonly) STimer *timer;
@property (nonatomic, strong, readonly) id object;
@property (nonatomic, copy, readonly) dispatch_block_t timeoutReached;

- (instancetype)initWithObject:(id)object timeout:(NSTimeInterval)timeout timeoutReached:(dispatch_block_t)timeoutReached;

@end

@implementation TGPoolObject

- (instancetype)initWithObject:(id)object timeout:(NSTimeInterval)timeout timeoutReached:(dispatch_block_t)timeoutReached
{
    self = [super init];
    if (self != nil)
    {
        _object = object;
        _timeoutReached = [timeoutReached copy];
        
        __weak TGPoolObject *weakSelf = self;
        _timer = [[STimer alloc] initWithTimeout:timeout repeat:false completion:^
        {
            __strong TGPoolObject *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_timeoutReached)
                    strongSelf->_timeoutReached();
            }
        } queue:[SQueue concurrentDefaultQueue]];
        [_timer start];
    }
    return self;
}

- (void)dealloc
{
    [_timer invalidate];
}

@end

@interface TGPoolWithTimeout ()
{
    NSTimeInterval _timeout;
    NSUInteger _maxObjects;
    NSLock *_lock;
    NSMutableArray *_objects;
}

@end

@implementation TGPoolWithTimeout

- (instancetype)initWithTimeout:(NSTimeInterval)timeout maxObjects:(NSUInteger)maxObjects
{
    self = [super init];
    if (self != nil)
    {
        _timeout = timeout;
        _maxObjects = maxObjects;
        _lock = [[NSLock alloc] init];
        _objects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addObject:(id)object
{
    [_lock lock];
    __weak TGPoolWithTimeout *weakSelf = self;
    [_objects addObject:[[TGPoolObject alloc] initWithObject:object timeout:_timeout timeoutReached:^
    {
        __strong TGPoolWithTimeout *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_lock lock];
            for (NSUInteger i = 0; i < strongSelf->_objects.count; i++)
            {
                TGPoolObject *poolObject = strongSelf->_objects[i];
                if (poolObject.object == object)
                {
                    [strongSelf->_objects removeObjectAtIndex:i];
                    break;
                }
            }
            [strongSelf->_lock unlock];
        }
    }]];
    [_lock unlock];
}

- (id)takeObject
{
    id object = nil;
    [_lock lock];
    TGPoolObject *poolObject = [_objects firstObject];
    if (poolObject != nil)
    {
        [_objects removeObjectAtIndex:0];
        object = poolObject.object;
    }
    [_lock unlock];
    
    return object;
    
}

@end
