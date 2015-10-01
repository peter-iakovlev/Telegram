#import <UIKit/UIKit.h>

@interface TGLoginPasswordView : UIView

@property (nonatomic, copy) void (^passwordChanged)(NSString *);
@property (nonatomic, copy) void (^forgotPassword)();
@property (nonatomic, copy) void (^resetPassword)();
@property (nonatomic, copy) void (^checkPassword)();

@property (nonatomic, strong) NSString *hint;
@property (nonatomic) bool resetMode;

- (void)setFirstReponder;
- (void)clearFirstResponder;

@end
