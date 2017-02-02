#import <UIKit/UIKit.h>

@protocol TGCallAlertContentView;

@interface TGCallAlertView : UIView

@property (nonatomic, readonly) UIButton *cancelButton;
@property (nonatomic, readonly) UIButton *doneButton;

+ (TGCallAlertView *)presentAlertWithTitle:(NSString *)title message:(NSString *)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle completionBlock:(void (^)(bool done))completionBlock;

@end
