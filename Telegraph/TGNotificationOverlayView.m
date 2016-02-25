#import "TGNotificationOverlayView.h"

@interface TGNotificationOverlayView ()
{
    UIVisualEffectView *_effectView;
    UIView *_backgroundView;
}
@end

@implementation TGNotificationOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        if (iosMajorVersion() >= 8)
        {
            _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            _effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _effectView.frame = self.bounds;
            _effectView.userInteractionEnabled = false;
            [self addSubview:_effectView];
        }
        else
        {
            _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
            _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.67f];
            _backgroundView.userInteractionEnabled = false;
            [self addSubview:_backgroundView];
        }
    }
    return self;
}

- (void)setIsTransparent:(bool)isTransparent
{
    _isTransparent = isTransparent;
    _effectView.hidden = isTransparent;
    _backgroundView.hidden = isTransparent;
}

@end
