#import "TGCustomAlertView.h"

#import <LegacyComponents/TGHacks.h>
#import "TGPresentation.h"

@implementation TGCustomAlertView

+ (instancetype)presentAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool))completionBlock
{
    return [self presentAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle okButtonTitle:okButtonTitle destructive:false completionBlock:completionBlock disableKeyboardWorkaround:true];
}

+ (instancetype)presentAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool))completionBlock disableKeyboardWorkaround:(bool)disableKeyboardWorkaround
{
    return [self presentAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle okButtonTitle:okButtonTitle destructive:false completionBlock:completionBlock disableKeyboardWorkaround:disableKeyboardWorkaround];
}

+ (instancetype)presentAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle destructive:(bool)destructive completionBlock:(void (^)(bool))completionBlock disableKeyboardWorkaround:(bool)disableKeyboardWorkaround
{
    return [self presentAlertWithTitle:title anyMessage:message customView:nil cancelButtonTitle:cancelButtonTitle okButtonTitle:okButtonTitle destructive:destructive completionBlock:completionBlock disableKeyboardWorkaround:disableKeyboardWorkaround];
}

+ (instancetype)presentAlertWithTitle:(NSString *)title attributedMessage:(NSAttributedString *)attributedMessage cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool))completionBlock disableKeyboardWorkaround:(bool)disableKeyboardWorkaround
{
    return [self presentAlertWithTitle:title anyMessage:attributedMessage customView:nil cancelButtonTitle:cancelButtonTitle okButtonTitle:okButtonTitle destructive:false completionBlock:completionBlock disableKeyboardWorkaround:disableKeyboardWorkaround];
}

+ (instancetype)presentAlertWithTitle:(NSString *)title customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle completionBlock:(void (^)(bool))completionBlock disableKeyboardWorkaround:(bool)disableKeyboardWorkaround
{
    return [self presentAlertWithTitle:title anyMessage:nil customView:customView cancelButtonTitle:cancelButtonTitle okButtonTitle:okButtonTitle destructive:false completionBlock:completionBlock disableKeyboardWorkaround:disableKeyboardWorkaround];
}

+ (instancetype)presentAlertWithTitle:(NSString *)title anyMessage:(id)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle destructive:(bool)destructive completionBlock:(void (^)(bool))completionBlock disableKeyboardWorkaround:(bool)disableKeyboardWorkaround
{
    NSString *finalTitle = title;
    NSString *finalMessage = message;
    if (finalTitle.length == 0 && finalMessage.length > 0)
    {
        finalTitle = [message isKindOfClass:[NSString class]] ? message : [message text];
        finalMessage = nil;
    }
    
    if (!disableKeyboardWorkaround)
        [self dismissAllAlertViews];
    
    TGCustomAlertView *alertView = (TGCustomAlertView *)[self _presentAlert:[TGCustomAlertView class] withTitle:finalTitle message:finalMessage customView:customView cancelButtonTitle:cancelButtonTitle doneButtonTitle:okButtonTitle keepKeyboard:!disableKeyboardWorkaround completionBlock:completionBlock];
    if (destructive)
        [alertView.doneButton setTitleColor:TGPresentation.current.pallete.menuDestructiveColor forState:UIControlStateNormal];
    
    if (!disableKeyboardWorkaround)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            UIWindow *keyboardWindow = [TGHacks applicationKeyboardWindow];
            CGFloat keyboardPosition = [TGHacks applicationKeyboardView].frame.origin.y;
            if (keyboardWindow != nil && fabs(keyboardWindow.frame.size.height - keyboardPosition) > FLT_EPSILON)
            {
                alertView.alertWindow.userInteractionEnabled = false;
                [keyboardWindow addSubview:alertView];
            }
        });
    }
    
    return alertView;
}

+ (void)dismissAllAlertViews
{
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if ([window isKindOfClass:[TGOverlayControllerWindow class]])
        {
            if ([window.rootViewController isKindOfClass:[TGCallAlertViewController class]])
            {
                TGCallAlertViewController *controller = (TGCallAlertViewController *)window.rootViewController;
                [controller->_alertView dismiss:false fromDim:true animated:false];
            }
        }
    }
}

- (bool)cancelIsBold
{
    return true;
}

@end
