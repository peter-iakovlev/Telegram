#import <Foundation/Foundation.h>

@interface TGLegacyUser : NSObject

@property (nonatomic, readonly) int32_t userId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *phoneNumber;
@property (nonatomic, strong, readonly) NSString *photoSmall;

- (instancetype)initWithUserId:(int32_t)userId accessHash:(int64_t)accessHash firstName:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber photoSmall:(NSString *)photoSmall;

@end
