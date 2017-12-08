#import <LegacyComponents/LegacyComponents.h>

@interface TGLoginResetAccountProtectedController : TGViewController

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber protectedUntilDate:(NSTimeInterval)protectedUntilDate;

@end
