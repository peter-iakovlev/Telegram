#import "TGLinearProgressView.h"

@interface TGLinearProgressView ()

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *progressView;

@property (nonatomic) CGFloat minProgressWidth;

@end

@implementation TGLinearProgressView

- (id)initWithBackgroundImage:(UIImage *)backgroundImage progressImage:(UIImage *)progressImage
{
    self = [super init];
    if (self != nil)
    {
        _backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        [self addSubview:_backgroundView];
        
        _progressView = [[UIImageView alloc] initWithImage:progressImage];
        [self addSubview:_progressView];
        
        _minProgressWidth = progressImage.size.width;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animationDuration:0.0];
}

- (void)setProgress:(CGFloat)progress animationDuration:(NSTimeInterval)animationDuration
{
    _progress = progress;
    
    CGRect frame = self.frame;
    
    CGFloat progressWidth = (frame.size.width) * _progress;
    
    CGRect progressFrame = CGRectMake(0, 0, _alwaysShowMinimum ? MAX(progressWidth, _minProgressWidth) : progressWidth, _progressView.frame.size.height);
    
    if (animationDuration > DBL_EPSILON)
    {
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^
        {
            _progressView.alpha = progressFrame.size.width < _minProgressWidth ? 0.0f : 1.0f;
            _progressView.frame = progressFrame;
        } completion:nil];
    }
    else
    {
        _progressView.alpha = progressFrame.size.width < _minProgressWidth ? 0.0f : 1.0f;
        _progressView.frame = progressFrame;
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _backgroundView.frame = CGRectMake(0, 0, frame.size.width, _backgroundView.frame.size.height);
    CGRect progressFrame = CGRectMake(0, 0, (frame.size.width) * _progress, _progressView.frame.size.height);
    _progressView.alpha = progressFrame.size.width < _minProgressWidth ? 0.0f : 1.0f;
    _progressView.frame = progressFrame;
}

@end
