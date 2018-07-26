#import <LegacyComponents/LegacyComponents.h>

@interface TGCallAlertView : UIView

@property (nonatomic, readonly) UIButton *cancelButton;
@property (nonatomic, readonly) UIButton *doneButton;
@property (nonatomic, readonly) UILabel *messageLabel;
@property (nonatomic, assign) bool followsKeyboard;
@property (nonatomic, assign) bool noActionOnDimTap;
@property (nonatomic, copy) bool (^shouldDismissOnDimTap)(void);

@property (nonatomic, readonly) bool cancelIsBold;

@property (nonatomic, weak, readonly) UIWindow *alertWindow;

- (void)updateCustomViewHeight:(CGFloat)height;

- (void)dismiss:(bool)done fromDim:(bool)fromDim animated:(bool)animated;

+ (TGCallAlertView *)presentAlertWithTitle:(NSString *)title message:(NSString *)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle completionBlock:(void (^)(bool done))completionBlock;
+ (TGCallAlertView *)_presentAlert:(Class)alertClass withTitle:(NSString *)title message:(id)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle completionBlock:(void (^)(bool))completionBlock;
+ (TGCallAlertView *)_presentAlert:(Class)alertClass withTitle:(NSString *)title message:(id)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle keepKeyboard:(bool)keepKeyboard completionBlock:(void (^)(bool))completionBlock;

@end

@interface TGCallAlertViewController : TGOverlayController
{
    @public
    TGCallAlertView *_alertView;
}

- (instancetype)initWithView:(TGCallAlertView *)view;

@end
