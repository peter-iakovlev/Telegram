#import <Foundation/Foundation.h>

@interface TGModernConversationActivityManager : NSObject

@property (nonatomic, copy) void (^sendActivityUpdate)(NSString *type, NSString *previousType);

- (id)addActivityWithType:(NSString *)type priority:(NSInteger)priority;
- (void)addActivityWithType:(NSString *)type priority:(NSInteger)priority timeout:(NSTimeInterval)timeout;
- (void)removeActivityWithType:(NSString *)type;

@end
