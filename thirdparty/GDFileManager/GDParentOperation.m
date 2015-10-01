//
//  GDParentOperation.m
//  
//
//  Created by Graham Dennis on 6/07/13.
//
//

#import "GDParentOperation.h"

@interface GDParentOperation ()

@property (nonatomic) dispatch_queue_t private_queue;
@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, strong) NSMutableArray *childOperations;

@end

NSError *GDOperationCancelledError;

@implementation GDParentOperation

@synthesize successCallbackQueue = _successCallbackQueue;
@synthesize failureCallbackQueue = _failureCallbackQueue;

+ (void)initialize
{
    if (self == [GDParentOperation class]) {
        GDOperationCancelledError = [NSError errorWithDomain:@"GDParentOperation" code:0 userInfo:nil];
    }
}

#if !OS_OBJECT_USE_OBJC
- (void)dealloc
{
    if (self.private_queue) {
        dispatch_release(self.private_queue);
        self.private_queue = NULL;
    }
    if (_successCallbackQueue) {
        dispatch_release(_successCallbackQueue);
        _successCallbackQueue = NULL;
    }
    if (_failureCallbackQueue) {
        dispatch_release(_failureCallbackQueue);
        _failureCallbackQueue = NULL;
    }
}
#endif

- (id)init
{
    if ((self = [super init])) {
        self.private_queue = dispatch_queue_create("me.grahamdennis.GDParentOperation", DISPATCH_QUEUE_SERIAL);
        self.childOperations = [NSMutableArray new];
        
    }
    
    return self;
}

- (void)start
{
    dispatch_sync(self.private_queue, ^{
        if ([self isCancelled]) {
            [self willChangeValueForKey:@"isFinished"];
            self.isFinished = YES;
            [self didChangeValueForKey:@"isFinished"];
        }
        else if ([self isReady] && ![self isExecuting]) {
            [self willChangeValueForKey:@"isExecuting"];
            self.isExecuting = YES;
            [self didChangeValueForKey:@"isExecuting"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self main];
            });
        }
    });
}

- (void)main {}

- (void)finish
{
    dispatch_sync(self.private_queue, ^{
        if ([self isExecuting]) {
            [self willChangeValueForKey:@"isExecuting"];
            self.isExecuting = NO;
            [self didChangeValueForKey:@"isExecuting"];
        }
        [self willChangeValueForKey:@"isFinished"];
        self.isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
    });
}

- (void)cancel
{
    dispatch_sync(self.private_queue, ^{
        [super cancel];
        
        for (NSOperation *childOperation in self.childOperations) {
            [childOperation cancel];
        }
    });
}

- (BOOL)isConcurrent { return YES; }


- (void)addChildOperation:(NSOperation *)operation
{
    if (!operation) return;
    
    dispatch_async(self.private_queue, ^{
        if ([self isCancelled]) {
            [operation cancel];
        }
        [self.childOperations addObject:operation];
    });
}

#if !OS_OBJECT_USE_OBJC
- (void)setSuccessCallbackQueue:(dispatch_queue_t)successCallbackQueue
{
    dispatch_retain(successCallbackQueue);
    if (_successCallbackQueue) {
        dispatch_release(_successCallbackQueue);
    }
    _successCallbackQueue = successCallbackQueue;
}
#endif

- (dispatch_queue_t)successCallbackQueue
{
    if (!_successCallbackQueue)
        return dispatch_get_main_queue();
    return _successCallbackQueue;
}

#if !OS_OBJECT_USE_OBJC
- (void)setFailureCallbackQueue:(dispatch_queue_t)failureCallbackQueue
{
    dispatch_retain(failureCallbackQueue);
    if (_failureCallbackQueue) {
        dispatch_release(_failureCallbackQueue);
    }
    _failureCallbackQueue = failureCallbackQueue;
}
#endif

- (dispatch_queue_t)failureCallbackQueue
{
    if (!_failureCallbackQueue)
        return dispatch_get_main_queue();
    return _failureCallbackQueue;
}


@end
