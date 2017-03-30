#import <UIKit/UIKit.h>

@class TGViewController;

@interface TGPaymentAlertView : UIView

@property (nonatomic, weak) TGViewController *controller;
@property (nonatomic, copy) void (^dismiss)();

- (void)animateAppear;
- (void)animateDismiss:(void (^)())completion;

@end
