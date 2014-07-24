#import <UIKit/UIKit.h>

@interface TGModernGalleryInterfaceView : UIView

@property (nonatomic, copy) void (^closePressed)();

@property (nonatomic, strong, readonly) UIView *navigationBarView;
@property (nonatomic, strong, readonly) UIView *toolbarView;

- (void)addItemHeaderView:(UIView *)itemHeaderView;
- (void)removeItemHeaderView:(UIView *)itemHeaderView;
- (void)addItemFooterView:(UIView *)itemFooterView;
- (void)removeItemFooterView:(UIView *)itemFooterView;

- (void)setTitle:(NSString *)title;
- (void)setTitleAlpha:(CGFloat)titleAlpha;

- (void)animateTransitionInWithDuration:(NSTimeInterval)dutation;
- (void)animateTransitionOutWithDuration:(NSTimeInterval)dutation;

@end
