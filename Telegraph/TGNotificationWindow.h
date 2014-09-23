#import <UIKit/UIKit.h>

#import "ActionStage.h"

@interface TGOverlayWindowViewController : UIViewController

@end

@interface TGNotificationWindow : UIWindow

@property (nonatomic, readonly) bool isDismissed;

@property (nonatomic) float windowHeight;

@property (nonatomic, strong) ASHandle *watcher;
@property (nonatomic, strong) NSString *watcherAction;
@property (nonatomic, strong) NSDictionary *watcherOptions;

- (void)setContentView:(UIView *)view;
- (UIView *)contentView;

- (void)animateIn;
- (void)animateOut;
- (void)performTapAction;

@end
