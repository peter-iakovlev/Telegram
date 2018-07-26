#import <UIKit/UIKit.h>
#import "TGCallAlertView.h"

@interface TGCustomAlertView : TGCallAlertView

+ (instancetype)presentAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool okButtonPressed))completionBlock;

+ (instancetype)presentAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool okButtonPressed))completionBlock disableKeyboardWorkaround:(bool)disableKeyboardWorkaround;

+ (instancetype)presentAlertWithTitle:(NSString *)title attributedMessage:(NSAttributedString *)attributedMessage cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool okButtonPressed))completionBlock disableKeyboardWorkaround:(bool)disableKeyboardWorkaround;

+ (instancetype)presentAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle destructive:(bool)destructive completionBlock:(void (^)(bool okButtonPressed))completionBlock disableKeyboardWorkaround:(bool)disableKeyboardWorkaround;

+ (instancetype)presentAlertWithTitle:(NSString *)title customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool))completionBlock disableKeyboardWorkaround:(bool)disableKeyboardWorkaround;

+ (void)dismissAllAlertViews;

@end
