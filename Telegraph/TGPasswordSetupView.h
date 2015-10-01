#import <UIKit/UIKit.h>

@interface TGPasswordSetupView : UIView

@property (nonatomic, copy) void (^passwordChanged)();
@property (nonatomic) bool secureEntry;

- (NSString *)password;

- (void)setContentInsets:(UIEdgeInsets)contentInsets;
- (void)setTitle:(NSString *)title;
- (void)clearInput;
- (void)setText:(NSString *)text;

- (void)becomeFirstResponder;

@end
