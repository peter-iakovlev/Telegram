#import "TGSearchLoupeProgressView.h"

#import <QuartzCore/QuartzCore.h>

@implementation TGSearchLoupeProgressView

- (id)init
{
    return [self initWithFrame:CGRectMake(0, 0, 33, 34)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _frameView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProgressLoupeFrame.png"]];
        [self addSubview:_frameView];
        
        _hourView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProgressLoupeHour.png"]];
        _hourView.frame = CGRectOffset(_hourView.frame, 10.5f, 2.5f);
        [self addSubview:_hourView];
        
        _minView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProgressLoupeMinute.png"]];
        _minView.frame = CGRectOffset(_minView.frame, 10.5f, 2.5f);
        [self addSubview:_minView];
    }
    return self;
}

- (void)startAnimating
{
    if (_isAnimating)
        return;
    
    [_hourView.layer removeAllAnimations];
    [_minView.layer removeAllAnimations];
    
    _isAnimating = true;
    
    [self animateHourView];
    [self animateMinView];
}

#define MINUTE_DURATION 0.3f

- (void)animateHourView
{
    [UIView animateWithDuration:MINUTE_DURATION * 6.0 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^
     {
         _hourView.transform = CGAffineTransformRotate(_hourView.transform, (CGFloat)M_PI_2);
     } completion:^(BOOL finished)
     {
         if (finished)
         {
             [self animateHourView];
         }
         else
         {
             _isAnimating = false;
         }
     }];
}

- (void)animateMinView
{
    [UIView animateWithDuration:MINUTE_DURATION delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^
     {
         _minView.transform = CGAffineTransformRotate(_minView.transform, (CGFloat)M_PI_2);
     } completion:^(BOOL finished)
     {
         if (finished)
         {
             [self animateMinView];
         }
         else
         {
             _isAnimating = false;
         }
     }];
}

- (void)stopAnimating
{
    if (!_isAnimating)
        return;
    
    _isAnimating = false;
    
    [_hourView.layer removeAllAnimations];
    [_minView.layer removeAllAnimations];
}

@end
