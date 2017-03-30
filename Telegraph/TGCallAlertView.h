#import "TGOverlayController.h"

@interface TGCallAlertView : UIView

@property (nonatomic, readonly) UIButton *cancelButton;
@property (nonatomic, readonly) UIButton *doneButton;
@property (nonatomic, assign) bool followsKeyboard;
@property (nonatomic, copy) bool (^shouldDismissOnDimTap)(void);

- (void)updateCustomViewHeight:(CGFloat)height;

+ (TGCallAlertView *)presentAlertWithTitle:(NSString *)title message:(NSString *)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle completionBlock:(void (^)(bool done))completionBlock;

@end

@interface TGCallAlertViewController : TGOverlayController
{
    TGCallAlertView *_alertView;
}

- (instancetype)initWithView:(TGCallAlertView *)view;

@end
