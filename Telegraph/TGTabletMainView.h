#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGTabletMainView : UIView

@property (nonatomic) bool fullScreenDetail;
@property (nonatomic, strong) UIView *masterView;
@property (nonatomic, strong) UIView *detailView;
@property (nonatomic, strong) TGPresentation *presentation;

- (void)updateBottomInset:(CGFloat)inset;
- (CGRect)rectForDetailViewForFrame:(CGRect)frame;

@end
