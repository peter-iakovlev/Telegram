#import <UIKit/UIKit.h>

@interface TGScrollIndicatorView : UIImageView

@property (nonatomic, strong) UIColor *color;
- (void)setHidden:(bool)hidden animated:(bool)animated;

- (void)updateScrollViewDidScroll;
- (void)updateScrollViewDidEndScrolling;

@end
