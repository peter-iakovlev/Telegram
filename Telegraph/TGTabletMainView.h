#import <UIKit/UIKit.h>

@interface TGTabletMainView : UIView

@property (nonatomic) bool fullScreenDetail;
@property (nonatomic, strong) UIView *masterView;
@property (nonatomic, strong) UIView *detailView;

- (void)updateBottomInset:(CGFloat)inset;
- (CGRect)rectForDetailViewForFrame:(CGRect)frame;

@end
