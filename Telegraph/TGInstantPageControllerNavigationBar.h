#import <UIKit/UIKit.h>

@interface TGInstantPageControllerNavigationBar : UIView

@property (nonatomic, copy) void (^backPressed)();
@property (nonatomic, copy) void (^sharePressed)();
@property (nonatomic, copy) void (^settingsPressed)();
@property (nonatomic, copy) void (^scrollToTop)();

- (CGPoint)settingsButtonCenter;
- (void)setNavigationButtonsDimmed:(bool)dimmed animated:(bool)animated;

- (void)setProgress:(CGFloat)progress;

@end
