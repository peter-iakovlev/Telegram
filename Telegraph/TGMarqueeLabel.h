#import <UIKit/UIKit.h>

@interface TGMarqueeLabel : UILabel

@property (nonatomic, assign) UIViewAnimationOptions animationCurve;

@property (nonatomic, assign) CGFloat scrollDuration;

@property (nonatomic, assign) CGFloat fadeLength;
@property (nonatomic, assign) CGFloat animationDelay;

@property (nonatomic, assign) CGFloat leadingBuffer;
@property (nonatomic, assign) CGFloat trailingBuffer;

@property (nonatomic, assign) CGFloat rate;

- (void)shutdownLabel;
- (void)restartLabel;

@end
