#import "TGModernButtonView.h"

#import "TGModernClockProgressView.h"
#import "TGModernClockProgressViewModel.h"

@interface TGModernButtonView ()
{
    long _backgroundImageFingerprint;
    long _highightedBackgroundImageFingerprint;
    
    NSString *_title;
    NSArray *_possibleTitles;
    long _titleFontFingerprint;
    
    long _imageFingerprint;
    
    UIImageView *_supplementaryIconView;
    
    TGModernClockProgressView *_activityIndicator;
    UIView *_fadingActivityIndicator;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.adjustsImageWhenDisabled = false;
        self.adjustsImageWhenHighlighted = false;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)willBecomeRecycled
{
    [self removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    
    [self setDisplayProgress:false animated:false];
    [_fadingActivityIndicator removeFromSuperview];
    _fadingActivityIndicator = nil;
}

- (NSString *)viewStateIdentifier
{
    if (_viewStateIdentifier)
    {
    }
    
    return [[NSString alloc] initWithFormat:@"TGModernButtonView/%lx/%lx/%@/%lx/%lx", _backgroundImageFingerprint, _highightedBackgroundImageFingerprint, _title, (long)_titleFontFingerprint, (long)_imageFingerprint];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImageFingerprint = (long)backgroundImage;
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
}

- (void)setHighlightedBackgroundImage:(UIImage *)highlightedBackgroundImage
{
    _highightedBackgroundImageFingerprint = (long)highlightedBackgroundImage;
    [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self setTitle:title forState:UIControlStateNormal];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFontFingerprint = (long)titleFont;
    self.titleLabel.font = titleFont;
}

- (void)setImage:(UIImage *)image
{
    _imageFingerprint = (long)image;
    [self setImage:image forState:UIControlStateNormal];
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    [self setImage:highlightedImage forState:UIControlStateHighlighted];
}

- (void)setSupplementaryIcon:(UIImage *)supplementaryIcon {
    if (supplementaryIcon != nil) {
        if (_supplementaryIconView == nil) {
            _supplementaryIconView = [[UIImageView alloc] init];
            [self addSubview:_supplementaryIconView];
        }
        _supplementaryIconView.image = supplementaryIcon;
        _supplementaryIconView.frame = CGRectMake(self.frame.size.width - supplementaryIcon.size.width - 5.0f, 5.0f, supplementaryIcon.size.width, supplementaryIcon.size.height);
        _supplementaryIconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    } else {
        if (_supplementaryIconView != nil) {
            [_supplementaryIconView removeFromSuperview];
            _supplementaryIconView = nil;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setDisplayProgress:(bool)displayProgress animated:(bool)animated {
    if (displayProgress) {
        if (_activityIndicator == nil) {
            _activityIndicator = [[TGModernClockProgressView alloc] initWithFrame:CGRectMake(self.frame.size.width - 15.0f - 2.0f, self.frame.size.height - 15.0f - 2.0f, 15.0f, 15.0f)];
            [TGModernClockProgressViewModel setupView:_activityIndicator forType:TGModernClockProgressTypeOutgoingMediaClock];
            _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
            [self addSubview:_activityIndicator];
            if (animated) {
                _activityIndicator.alpha = 0.0f;
                [UIView animateWithDuration:0.25 animations:^{
                    _activityIndicator.alpha = 1.0f;
                }];
            }
        }
    } else if (_activityIndicator != nil) {
        [_fadingActivityIndicator removeFromSuperview];
        _fadingActivityIndicator = _activityIndicator;
        if (animated) {
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _fadingActivityIndicator.alpha = 0.0f;
            } completion:^(__unused BOOL finished) {
                [_fadingActivityIndicator removeFromSuperview];
                _fadingActivityIndicator = nil;
            }];
        } else {
            [_fadingActivityIndicator removeFromSuperview];
            _fadingActivityIndicator = nil;
        }
        _activityIndicator = nil;
    }
}

@end
