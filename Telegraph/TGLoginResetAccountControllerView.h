#import <UIKit/UIKit.h>

@interface TGLoginResetAccountControllerView : UIView

@property (nonatomic, copy) void (^resetAccount)();

- (void)setPhoneNumber:(NSString *)phoneNumber;
- (void)setProtectedUntilDate:(NSTimeInterval)protectedUntilDate;

@end
