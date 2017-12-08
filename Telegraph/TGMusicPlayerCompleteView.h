#import <UIKit/UIKit.h>

@interface TGMusicPlayerCompleteView : UIView

@property (nonatomic) CGFloat topInset;
@property (nonatomic, assign) bool preview;

- (instancetype)initWithFrame:(CGRect)frame;
- (bool)isSwipeGestureAllowedAtPoint:(CGPoint)point;

@end
