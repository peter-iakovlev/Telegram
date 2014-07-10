#import "TGUserUUID.h"

#import "PSCoding.h"

@interface TGUserPresenceModel : NSObject <PSCoding>

@property (nonatomic, strong, readonly) TGUserUUID *uuid;

@property (nonatomic, readonly) NSTimeInterval lastSeen;

- (instancetype)initWithUserId:(int32_t)userId lastSeen:(NSTimeInterval)lastSeen;

@end
