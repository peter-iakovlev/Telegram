#import "PSUUID.h"

@interface TGUserUUID : NSObject <PSUUID>

- (instancetype)initWithUserId:(int32_t)userId;
- (int32_t)userId;

@end
