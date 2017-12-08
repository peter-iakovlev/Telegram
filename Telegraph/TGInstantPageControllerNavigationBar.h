#import <UIKit/UIKit.h>

@interface TGInstantPageControllerNavigationBar : UIView

@property (nonatomic, copy) void (^backPressed)();
@property (nonatomic, copy) void (^sharePressed)();
@property (nonatomic, copy) void (^settingsPressed)();
@property (nonatomic, copy) void (^scrollToTop)();

@property (nonatomic, assign) UIEdgeInsets safeAreaInset;

@property (nonatomic, assign) CGFloat collapsedHeight;
@property (nonatomic, assign) CGFloat expandedHeight;

- (CGPoint)settingsButtonCenter;
- (void)setNavigationButtonsDimmed:(bool)dimmed animated:(bool)animated;

- (void)setProgress:(CGFloat)progress;

@end
