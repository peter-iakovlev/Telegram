#import "GDDispatchUtilities.h"

typedef void(^ContinuationBlock)(BOOL);

void __attribute__((overloadable)) AsyncSequentialEnumeration(NSEnumerator *enumerator,
                                                              void (^iterationBlock)(id object, ContinuationBlock continuationBlock))
{
    return AsyncSequentialEnumeration(enumerator, iterationBlock, NULL);
}

void __attribute__((overloadable)) AsyncSequentialEnumeration(NSEnumerator *enumerator,
                                                              void (^iterationBlock)(id object, ContinuationBlock continuationBlock),
                                                              void (^completionBlock)(BOOL completed))
{
    return AsyncSequentialEnumeration(enumerator, NULL, iterationBlock, completionBlock);
}

void __attribute__((overloadable)) AsyncSequentialEnumeration(NSEnumerator *enumerator,
                                                              dispatch_queue_t queue,
                                                              void (^iterationBlock)(id object, ContinuationBlock continuationBlock),
                                                              void (^completionBlock)(BOOL completed))
{
    if (!queue) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
#if !OS_OBJECT_USE_OBJC
    dispatch_retain(queue);
#endif
    
    __block void (^continuationBlock)(BOOL) = ^(BOOL keepGoing){
        if (!keepGoing) {
            if (completionBlock) {
                dispatch_async(queue, ^{
                    completionBlock(NO);
                });
            }
#if !OS_OBJECT_USE_OBJC
            dispatch_release(queue);
#endif
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            continuationBlock = nil;
#pragma clang diagnostic pop
            return;
        }
        id object = [enumerator nextObject];
        if (object && continuationBlock) {
            dispatch_async(queue, ^{
                iterationBlock(object, continuationBlock);
            });
        } else {
            if (completionBlock)
                completionBlock(YES);
#if !OS_OBJECT_USE_OBJC
            dispatch_release(queue);
#endif
            continuationBlock = nil;
        }
    };
    
    continuationBlock(YES);
}