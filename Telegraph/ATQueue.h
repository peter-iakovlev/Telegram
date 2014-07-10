#import <Foundation/Foundation.h>

//@class RACScheduler;

@interface ATQueue : NSObject

+ (ATQueue *)mainQueue;

- (instancetype)init;
- (instancetype)initWithName:(NSString *)name;

- (void)dispatch:(dispatch_block_t)block;
- (void)dispatch:(dispatch_block_t)block synchronous:(bool)synchronous;
- (void)dispatchAfter:(NSTimeInterval)seconds block:(dispatch_block_t)block;

- (dispatch_queue_t)nativeQueue;

//- (RACScheduler *)scheduler;

@end
