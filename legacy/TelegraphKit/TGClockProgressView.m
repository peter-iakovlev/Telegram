#import "TGClockProgressView.h"

#import <QuartzCore/QuartzCore.h>

static UIImage *progressFrameImage()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"ClockFrame.png"];
    return image;
}

static UIImage *progressMinImage()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"ClockMin.png"];
    return image;
}

static UIImage *progressHourImage()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"ClockHour.png"];
    return image;
}

static UIImage *progressWhiteFrameImage()
{
    return [UIImage imageNamed:@"ClockWhiteFrame.png"];
}

static UIImage *progressWhiteMinImage()
{
    return [UIImage imageNamed:@"ClockWhiteMin.png"];
}

static UIImage *progressWhiteHourImage()
{
    return [UIImage imageNamed:@"ClockWhiteHour.png"];
}

@implementation TGClockProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _frameView = [[UIImageView alloc] initWithImage:progressFrameImage()];
        [self addSubview:_frameView];
        
        _hourView = [[UIImageView alloc] initWithImage:progressHourImage()];
        [self addSubview:_hourView];
        
        _minView = [[UIImageView alloc] initWithImage:progressMinImage()];
        [self addSubview:_minView];
    }
    return self;
}

- (id)initWithWhite
{
    self = [super initWithFrame:CGRectMake(0, 0, 15, 15)];
    if (self != nil)
    {
        _frameView = [[UIImageView alloc] initWithImage:progressWhiteFrameImage()];
        [self addSubview:_frameView];
        
        _hourView = [[UIImageView alloc] initWithImage:progressWhiteHourImage()];
        [self addSubview:_hourView];
        
        _minView = [[UIImageView alloc] initWithImage:progressWhiteMinImage()];
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
