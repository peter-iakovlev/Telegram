#import <UIKit/UIKit.h>

@interface TGTabletMainView : UIView

@property (nonatomic) bool fullScreenDetail;
@property (nonatomic, strong) UIView *masterView;
@property (nonatomic, strong) UIView *detailView;

- (CGRect)rectForDetailViewForFrame:(CGRect)frame;

@end
