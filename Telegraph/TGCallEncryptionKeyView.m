#import "TGCallEncryptionKeyView.h"

#import "TGStringUtils.h"
#import "TGImageUtils.h"
#import "TGCallUtils.h"
#import "TGFont.h"
#import "TGTimerTarget.h"

#import "TGViewController.h"

#import "UIControl+HitTestEdgeInsets.h"
#import "TGModernButton.h"
#import "TGMenuView.h"

#import "TGCallSession.h"
#import "TGUser.h"

typedef enum
{
    TGCallKeyViewTransitionTypeUsual,
    TGCallKeyViewTransitionTypeSimplified,
    TGCallKeyViewTransitionTypeLegacy
} TGCallKeyViewTransitionType;

@interface TGCallEncryptionKeyView ()
{
    UIView *_backgroundView;
    
    UIView *_wrapperView;
    TGModernButton *_backButton;

    UILabel *_emojiLabel;
    UILabel *_descriptionLabel;
    
    NSString *_name;
    
    bool _animating;
}

@end

@implementation TGCallEncryptionKeyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        TGCallKeyViewTransitionType type = [self _transitionType];
        
        if (type != TGCallKeyViewTransitionTypeLegacy)
        {
            _backgroundView = [[UIVisualEffectView alloc] initWithEffect:nil];
            if (type == TGCallKeyViewTransitionTypeSimplified)
            {
                ((UIVisualEffectView *)_backgroundView).effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                _backgroundView.alpha = 0.0f;
            }
        }
        else
        {
            _backgroundView = [[UIView alloc] init];
            _backgroundView.alpha = 0.0f;
            _backgroundView.backgroundColor = UIColorRGBA(0x000000, 0.5f);
        }
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.frame = self.bounds;
        [self addSubview:_backgroundView];
        
        _wrapperView = [[UIView alloc] initWithFrame:self.bounds];
        _wrapperView.alpha = 0.0f;
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_wrapperView];
        
        _emojiLabel = [[UILabel alloc] init];
        _emojiLabel.backgroundColor = [UIColor clearColor];
        _emojiLabel.font = TGSystemFontOfSize(58);
        _emojiLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_emojiLabel];
        
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.textColor = [UIColor blackColor];
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.font = [UIFont systemFontOfSize:14];
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.numberOfLines = 0;
        [_wrapperView addSubview:_descriptionLabel];
        
        _backButton = [[TGModernButton alloc] initWithFrame:CGRectZero];
        _backButton.exclusiveTouch = true;
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -20, -5, -5);
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _backButton.titleLabel.font = TGSystemFontOfSize(17);
        [_backButton setTitle:TGLocalized(@"Common.Back") forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor]];
        [_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(-19, 5.5f, 13, 22)];
        arrowView.image = [UIImage imageNamed:@"NavigationBackArrow"];
        [_backButton addSubview:arrowView];
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

- (void)tapped:(id)__unused sender
{
    [self backButtonPressed];
}

- (TGCallKeyViewTransitionType)_transitionType
{
    static dispatch_once_t onceToken;
    static TGCallKeyViewTransitionType type;
    dispatch_once(&onceToken, ^
    {
        CGSize screenSize = TGScreenSize();
        if (iosMajorVersion() < 8 || (NSInteger)screenSize.height == 480)
            type = TGCallKeyViewTransitionTypeLegacy;
        else
            type = TGCallKeyViewTransitionTypeSimplified;
    });
    return type;
}

- (bool)present
{
    if (_animating)
        return false;
    
    _animating = true;
    self.hidden = false;
    
    _backButton.hidden = false;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        _backgroundView.alpha = 1.0f;
        _wrapperView.alpha = 1.0f;
    }];
    
    _emojiLabel.center = self.emojiInitialCenter();
    _emojiLabel.transform = CGAffineTransformMakeScale(0.4, 0.4);
    
    [UIView animateWithDuration:0.3 delay:0.0 options:(7 << 16) animations:^
    {
        CGRect targetRect = CGRectMake(floor((self.frame.size.width - _emojiLabel.frame.size.width) / 2) + 6.0f, floor((self.frame.size.height - _emojiLabel.frame.size.height) / 2) - 50.0f, _emojiLabel.frame.size.width, _emojiLabel.frame.size.height);
        
        _emojiLabel.center = CGPointMake(CGRectGetMidX(targetRect), CGRectGetMidY(targetRect));
        _emojiLabel.transform = CGAffineTransformIdentity;
    } completion:^(__unused BOOL finished)
    {
        _animating = false;
        [self setNeedsLayout];
    }];
    
    return true;
}

- (void)dismiss:(void (^)(void))completion
{
    if (_animating)
        return;
    
    _animating = true;
    _backButton.hidden = true;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        _backgroundView.alpha = 0.0f;
        _wrapperView.alpha = 0.0f;
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:(7 << 16) animations:^
    {
        _emojiLabel.center = self.emojiInitialCenter();
        _emojiLabel.transform = CGAffineTransformMakeScale(0.395, 0.395);
    } completion:^(__unused BOOL finished)
    {
        self.hidden = true;
        _animating = false;
        
        if (completion != nil)
            completion();
    }];
}

- (void)backButtonPressed
{
    if (self.backPressed != nil)
        self.backPressed();
}

- (void)setState:(TGCallSessionState *)state
{
    [self setName:state.peer.firstName];
}

- (void)setName:(NSString *)name
{
    if ([name isEqualToString:_name])
        return;
    
    _name = name;
        
    NSString *textFormat = TGLocalized(@"Call.EmojiDescription");
    NSString *baseText = [[NSString alloc] initWithFormat:textFormat, name];
    
    NSDictionary *attrs = @{NSFontAttributeName: _descriptionLabel.font, NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSDictionary *subAttrs = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:_descriptionLabel.font.pointSize], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:baseText attributes:attrs];
    [attributedText setAttributes:subAttrs range:NSMakeRange([textFormat rangeOfString:@"%@"].location, name.length)];
    [_descriptionLabel setAttributedText:attributedText];
    
    [self setNeedsLayout];
}

- (void)setEmoji:(NSString *)emoji
{
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:emoji attributes:@{ NSFontAttributeName: _emojiLabel.font, NSKernAttributeName: @9.0f }];
    
    _emojiLabel.attributedText = attributedString;
    [_emojiLabel sizeToFit];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [_backButton sizeToFit];
    _backButton.frame = CGRectMake(27, 25, MAX(55.0f, _backButton.frame.size.width + 5.0f), MAX(33.0f, _backButton.frame.size.height));
    
    CGSize screenSize = TGScreenSize();
        
    if (!_animating)
    {
        _emojiLabel.frame = CGRectMake(floor((self.frame.size.width - _emojiLabel.frame.size.width) / 2) + 6.0f, floor((self.frame.size.height - _emojiLabel.frame.size.height) / 2) - 50.0f, _emojiLabel.frame.size.width, _emojiLabel.frame.size.height);
    }
    CGSize labelSize = [_descriptionLabel sizeThatFits:CGSizeMake(screenSize.width - 80, 1000)];
    _descriptionLabel.frame = CGRectMake(floor((self.frame.size.width - labelSize.width) / 2), floor((self.frame.size.height - labelSize.height) / 2) + 30.0f, labelSize.width, labelSize.height);
}

@end
