#import "ATQueue.h"

//#import <ReactiveCocoa/ReactiveCocoa.h>

static const char *AMQueueSpecific = "AMQueueSpecific";

@interface ATQueue ()
{
    dispatch_queue_t _nativeQueue;
    bool _isMainQueue;
    
    //RACScheduler *_scheduler;
}

@end

@implementation ATQueue

+ (NSString *)applicationPrefix
{
    static NSString *prefix = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        prefix = [[NSBundle mainBundle] bundleIdentifier];
    });
    
    return prefix;
}

+ (ATQueue *)mainQueue
{
    static ATQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ATQueue alloc] init];
        queue->_nativeQueue = dispatch_get_main_queue();
        queue->_isMainQueue = true;
        //queue->_scheduler = [RACScheduler mainThreadScheduler];
    });
    
    return queue;
}

- (instancetype)init
{
    return [self initWithName:[[ATQueue applicationPrefix] stringByAppendingFormat:@".%ld", lrand48()]];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self != nil)
    {
        _nativeQueue = dispatch_queue_create([name UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_nativeQueue, AMQueueSpecific, (__bridge void *)self, NULL);
        
        //_scheduler = [[RACTargetQueueScheduler alloc] initWithName:[[NSString alloc] initWithFormat:@"%@_scheduler", name] targetQueue:_nativeQueue];
    }
    return self;
}

- (instancetype)initWithNativeQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self != nil)
    {
#if !OS_OBJECT_USE_OBJC
        _nativeQueue = dispatch_retain(queue);
#else
        _nativeQueue = queue;
#endif
    }
    return self;
}

- (void)dealloc
{
    if (_nativeQueue != nil)
    {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(_nativeQueue);
#endif
        _nativeQueue = nil;
    }
}

- (void)dispatch:(dispatch_block_t)block
{
    [self dispatch:block synchronous:false];
}

- (void)dispatch:(dispatch_block_t)block synchronous:(bool)synchronous
{
    if (_isMainQueue)
    {
        if ([NSThread isMainThread])
            block();
        else if (synchronous)
            dispatch_sync(_nativeQueue, block);
        else
            dispatch_async(_nativeQueue, block);
    }
    else
    {
        if (dispatch_get_specific(AMQueueSpecific) == (__bridge void *)self)
            block();
        else if (synchronous)
            dispatch_sync(_nativeQueue, block);
        else
            dispatch_async(_nativeQueue, block);
    }
}

- (void)dispatchAfter:(NSTimeInterval)seconds block:(dispatch_block_t)block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), _nativeQueue, block);
}

- (dispatch_queue_t)nativeQueue
{
    return _nativeQueue;
}

/*- (RACScheduler *)scheduler
{
    return _scheduler;
}*/

@end
