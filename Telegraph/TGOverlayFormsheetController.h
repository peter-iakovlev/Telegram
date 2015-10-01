#import <UIKit/UIKit.h>

@class TGOverlayFormsheetWindow;

@interface TGOverlayFormsheetController : UIViewController

@property (nonatomic, weak) TGOverlayFormsheetWindow *formSheetWindow;
@property (nonatomic, readonly) UIViewController *viewController;

- (instancetype)initWithContentController:(UIViewController *)viewController;
- (void)setContentController:(UIViewController *)viewController;

- (void)animateInWithCompletion:(void (^)(void))completion;
- (void)animateOutWithCompletion:(void (^)(void))completion;

@end
