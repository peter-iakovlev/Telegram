#import "TGNotificationBackgroundView.h"

@interface TGNotificationBackgroundView ()
{
    UIView *_backgroundView;
}
@end

@implementation TGNotificationBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        CGFloat backgroundAlpha = 0.8f;
        
        if (iosMajorVersion() >= 8)
        {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            
            _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _blurEffectView.frame = self.bounds;
            [self addSubview:_blurEffectView];
            
            _vibrantEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:blurEffect]];
            _vibrantEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _vibrantEffectView.frame = self.bounds;
            [_blurEffectView.contentView addSubview:_vibrantEffectView];
            
            backgroundAlpha = 0.4f;
        }

        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:backgroundAlpha];
        [self addSubview:_backgroundView];
    }
    return self;
}

@end
