#import <Foundation/Foundation.h>

@class ATQueue;

@interface TGModernConversationActivity : NSObject

@property (nonatomic, strong, readonly) NSString *type;
@property (nonatomic, readonly) NSInteger priority;
@property (nonatomic, readonly) NSTimeInterval timeout;

@property (nonatomic, copy) void (^onDelete)(TGModernConversationActivity *);
@property (nonatomic, copy) void (^onTick)(TGModernConversationActivity *);

- (instancetype)initWithType:(NSString *)type priority:(NSInteger)priority tickInterval:(NSTimeInterval)tickInterval timeout:(NSTimeInterval)timeout timeoutQueue:(ATQueue *)timeoutQueue;

- (id)holder;
- (void)resetTimeout;

@end
