#import "TGLegacyUser.h"

@implementation TGLegacyUser

- (instancetype)initWithUserId:(int32_t)userId accessHash:(int64_t)accessHash firstName:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber photoSmall:(NSString *)photoSmall {
    self = [super init];
    if (self != nil) {
        _userId = userId;
        _accessHash = accessHash;
        _firstName = firstName;
        _lastName = lastName;
        _phoneNumber = phoneNumber;
        _photoSmall = photoSmall;
    }
    return self;
}

@end
