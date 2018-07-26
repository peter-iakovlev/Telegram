#import "TGProxyBarButton.h"

@interface TGProxyBarButton ()
{
    UIImageView *_iconView;
    UIImageView *_spinnerView;
}
@end

@implementation TGProxyBarButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _iconView = [[UIImageView alloc] init];
        [self addSubview:_iconView];
        
        _spinnerView = [[UIImageView alloc] init];
        _spinnerView.hidden = true;
        [self addSubview:_spinnerView];
    }
    return self;
}

//- (UIEdgeInsets)alignmentRectInsets
//{
//    UIEdgeInsets insets = UIEdgeInsetsZero;
//    insets = UIEdgeInsetsMake(0.0f, 0.0f, 8.0f, 0.0f);
//    return insets;
//}

- (UIImage *)icon
{
    return _iconView.image;
}

- (void)setIcon:(UIImage *)icon
{
    _iconView.image = icon;
    _iconView.frame = CGRectMake(0.0f, 0.0f, icon.size.width, icon.size.height);
    [self setNeedsLayout];
}

- (UIImage *)spinner
{
    return _spinnerView.image;
}

- (void)setSpinner:(UIImage *)spinner
{
    _spinnerView.image = spinner;
    _spinnerView.frame = CGRectMake(0.0f, 0.0f, spinner.size.width, spinner.size.height);
    [self setNeedsLayout];
}

- (void)setSpinning:(bool)spinning
{
    _spinnerView.hidden = !spinning;
    
    if (spinning && _spinnerView.layer.animationKeys.count == 0)
    {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = @(M_PI * 2.0f);
        rotationAnimation.duration = 1.0;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = HUGE_VALF;
        
        [_spinnerView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    
    if (!spinning)
        [_spinnerView.layer removeAllAnimations];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.superview.frame.size.height > 32.0f + 1.0f)
        _iconView.frame = CGRectMake(_portraitAdjustment.x, _portraitAdjustment.y, _iconView.frame.size.width, _iconView.frame.size.height);
    else
        _iconView.frame = CGRectMake(_landscapeAdjustment.x, _landscapeAdjustment.y, _iconView.frame.size.width, _iconView.frame.size.height);
    
    _spinnerView.center = _iconView.center;
}

@end
