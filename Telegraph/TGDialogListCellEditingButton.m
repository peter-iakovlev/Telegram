#import "TGDialogListCellEditingButton.h"

#import <LegacyComponents/LegacyComponents.h>

#import <Lottie.h>

@interface TGDialogListCellEditingButton () {
    UILabel *_labelView;
    UIImageView *_iconView;
    NSString *_animationName;
    
    LOTAnimationView *_animationView;
    
    bool _triggered;
}

@end

@implementation TGDialogListCellEditingButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = nil;
        _labelView.opaque = false;
        _labelView.textColor = [UIColor whiteColor];
        
        static UIFont *font;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            font = TGMediumSystemFontOfSize(13.0f);
        });
        
        _labelView.font = font;
        [self addSubview:_labelView];
        
        _iconView = [[UIImageView alloc] init];
        [self addSubview:_iconView];
    }
    return self;
}

- (void)setLabelOnly:(bool)labelOnly {
    _labelOnly = labelOnly;
    _labelView.font = TGMediumSystemFontOfSize(_labelOnly ? 18.0f : 13.0f);
}

- (void)setSmallLabel:(bool)smallLabel {
    _smallLabel = smallLabel;
    _labelView.font = TGMediumSystemFontOfSize(_smallLabel ? 14.0f : (_labelOnly ? 18.0f : 13.0f));
}

- (void)setTitle:(NSString *)title animationName:(NSString *)animationName {
    _iconView.hidden = true;
    if (!_labelOnly && _labelView.text.length == 0)
        _labelView.alpha = 0.0f;
    _labelView.text = title;
    [_labelView sizeToFit];
    
    _animationName = animationName;
    
    [self setNeedsLayout];
}

- (LOTAnimationView *)animationView
{
    LOTAnimationView *animationView = [LOTAnimationView animationNamed:_animationName];
    animationView.transform = CGAffineTransformMakeScale(0.3333f, 0.3333f);
    animationView.userInteractionEnabled = false;
    return animationView;
}

- (void)playAnimation {
    if (_labelOnly)
        return;
    
    if (_animationName.length == 0)
        return;
    
    if (_animationView == nil) {
        _animationView = [self animationView];
        [self addSubview:_animationView];
    } else if (![_animationView.sceneModel.cacheKey isEqualToString:_animationName]) {
        [_animationView setAnimationNamed:_animationName];
    }
    
    if (_animationView.isAnimationPlaying)
        return;
    
    _labelView.transform = CGAffineTransformMakeScale(0.4f, 0.4f);
    [UIView animateWithDuration:0.2 animations:^
    {
        _labelView.transform = CGAffineTransformIdentity;
        _labelView.alpha = 1.0f;
    }];
    
    [self fixAnimation];
    
    [_animationView playWithCompletion:nil];
}

- (void)resetAnimation {
    if (_triggered)
    {
        _triggered = false;
        [self setNeedsLayout];
    }
    
    if (_labelOnly)
        return;
    
    if (_animationName.length == 0)
        return;
    
    [_animationView stop];
    
    _labelView.alpha = 0.0f;
    
    if (![_animationView.sceneModel.cacheKey isEqualToString:_animationName])
        [_animationView setAnimationNamed:_animationName];
}

- (void)skipAnimation {
    if (_labelOnly)
        return;
    
    _labelView.alpha = 1.0f;
    
    if (_animationView == nil) {
        _animationView = [self animationView];
        [self addSubview:_animationView];
    } else if (![_animationView.sceneModel.cacheKey isEqualToString:_animationName]) {
        [_animationView setAnimationNamed:_animationName];
    }
    
    [_animationView playFromProgress:1.0f toProgress:1.0f withCompletion:nil];
}

- (void)fixAnimation {
    if ([_animationName rangeOfString:@"unpin"].location != NSNotFound || [_animationName rangeOfString:@"mute"].location != NSNotFound || [_animationName rangeOfString:@"ungroup"].location != NSNotFound) {
        NSString *key = @"un Outlines.Group 1.Stroke 1";
        LOTColorValueCallback *colorCallback = [LOTColorValueCallback withCGColor:self.backgroundColor.CGColor];
        [_animationView setValueDelegate:colorCallback forKeypath:[LOTKeypath keypathWithString:[key stringByAppendingString:@".Color"]]];
    }
    else if ([_animationName rangeOfString:@"unread"].location != NSNotFound) {
        NSString *key = @"Oval.Oval.Stroke 1";
        LOTColorValueCallback *colorCallback = [LOTColorValueCallback withCGColor:self.backgroundColor.CGColor];
        [_animationView setValueDelegate:colorCallback forKeypath:[LOTKeypath keypathWithString:[key stringByAppendingString:@".Color"]]];
    }
}

- (void)setTitle:(NSString *)title image:(UIImage *)image {
    _animationName = nil;
    [_animationView removeFromSuperview];
    _animationView = nil;
    
    _labelView.alpha = 1.0f;
    _labelView.text = title;
    [_labelView sizeToFit];
    
    _iconView.hidden = false;
    if (!_labelOnly)
        _iconView.image = image;
    [self setNeedsLayout];
}

- (bool)triggered {
    return _triggered;
}

- (void)setTriggered:(bool)triggered {
    [self setTriggered:triggered animated:false];
}

- (void)setTriggered:(bool)triggered animated:(bool)animated {
    if (triggered == _triggered)
        return;
    
    _triggered = triggered;
    
    if (animated)
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^{
            [self layoutSubviews];
        } completion:nil];
    }
    else
    {
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGFloat buttonWidth = self.buttonWidth;
    
    CGSize labelSize = _labelView.bounds.size;
    CGSize iconSize = _iconView.image.size;
    
    CGFloat labelY = _labelOnly ? 17.0f : 49.0f;
    if (_smallLabel) {
        labelY = 15.0f;
    } else if (_offsetLabel) {
        labelY = 14.0f;
    }
    
    CGFloat offset = _triggered ? bounds.size.width - buttonWidth : 0.0f;
    _labelView.center = CGPointMake(offset + buttonWidth / 2.0f, labelY + labelSize.height / 2.0f);
    _iconView.frame = CGRectMake(offset + CGFloor((buttonWidth - iconSize.width) / 2.0f), 14.0f, iconSize.width, iconSize.height);
    _animationView.center = CGPointMake(offset + buttonWidth / 2.0f, bounds.size.height / 2.0f - 2.0f);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self setBackgroundColor:backgroundColor force:false];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor force:(bool)force {
    if (force) {
        [super setBackgroundColor:backgroundColor];
        [self fixAnimation];
    }
}

@end
