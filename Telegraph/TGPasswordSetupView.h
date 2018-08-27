#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGPasswordSetupView : UIView

@property (nonatomic, copy) void (^passwordChanged)(NSString *password);
@property (nonatomic, copy) void (^returnPressed)(NSString *password);
@property (nonatomic) bool secureEntry;

@property (nonatomic, strong) TGPresentation *presentation;

- (NSString *)password;

- (void)setContentInsets:(UIEdgeInsets)contentInsets;
- (void)setTitle:(NSString *)title;
- (void)clearInput;
- (void)setText:(NSString *)text;

- (void)becomeFirstResponder;

@end
