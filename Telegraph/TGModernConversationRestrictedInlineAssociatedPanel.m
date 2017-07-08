#import "TGModernConversationRestrictedInlineAssociatedPanel.h"

#import "TGUser.h"

#import "TGMentionPanelCell.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGViewController.h"

#import "TGLocalization.h"

@interface TGModernConversationRestrictedInlineAssociatedPanel ()
{
    SMetaDisposable *_disposable;
    NSArray *_userList;
    
    UIView *_backgroundView;
    UIView *_effectView;
    
    UIView *_stripeView;
    UIView *_separatorView;
    
    bool _resetOffsetOnLayout;
    bool _animatingOut;
    
    UILabel *_label;
}

@end

@implementation TGModernConversationRestrictedInlineAssociatedPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _disposable = [[SMetaDisposable alloc] init];
        
        UIColor *backgroundColor = [UIColor whiteColor];
        UIColor *bottomColor = UIColorRGBA(0xfafafa, 0.98f);
        UIColor *separatorColor = UIColorRGB(0xc5c7d0);
        UIColor *cellSeparatorColor = UIColorRGB(0xdbdbdb);
        
        self.clipsToBounds = true;
        
        if (self.style == TGModernConversationAssociatedInputPanelDarkStyle)
        {
            backgroundColor = UIColorRGB(0x171717);
            bottomColor = backgroundColor;
            separatorColor = UIColorRGB(0x292929);
            cellSeparatorColor = separatorColor;
        }
        else if (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle)
        {
            backgroundColor = [UIColor clearColor];
            separatorColor = UIColorRGBA(0xb2b2b2, 0.7f);
            cellSeparatorColor = UIColorRGBA(0xb2b2b2, 0.4f);
            bottomColor = [UIColor clearColor];
            
            CGFloat backgroundAlpha = 0.8f;
            if (iosMajorVersion() >= 8)
            {
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
                blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                blurEffectView.frame = self.bounds;
                [self addSubview:blurEffectView];
                _effectView = blurEffectView;
                
                backgroundAlpha = 0.4f;
            }
            
            _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
            _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:backgroundAlpha];
            [self addSubview:_backgroundView];
        } else {
            _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
            _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _backgroundView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
            [self addSubview:_backgroundView];
        }
        
        _stripeView = [[UIView alloc] init];
        _stripeView.backgroundColor = separatorColor;
        [self addSubview:_stripeView];
        
        if (self.style != TGModernConversationAssociatedInputPanelDarkBlurredStyle)
        {
            _separatorView = [[UIView alloc] init];
            _separatorView.backgroundColor = separatorColor;
            [self addSubview:_separatorView];
        }
        
        _label = [[UILabel alloc] init];
        _label.font = TGSystemFontOfSize(13.0f);
        _label.textColor = UIColorRGB(0x8e8e93);
        _label.numberOfLines = 0;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

- (void)dealloc {
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.alpha = frame.size.height >= FLT_EPSILON;
}

- (bool)fillsAvailableSpace {
    return false;
}

- (CGFloat)preferredHeight {
    return 60.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_animatingOut) {
        return;
    }
    
    _backgroundView.frame = CGRectMake(-1000, 0, self.frame.size.width + 2000, self.frame.size.height);
    _effectView.frame = CGRectMake(-1000, 0, self.frame.size.width + 2000, self.frame.size.height);
    
    CGFloat separatorHeight = TGScreenPixel;
    _separatorView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, separatorHeight);
    
    _stripeView.frame = CGRectMake(0.0f, self.frame.size.height - separatorHeight, self.frame.size.width, separatorHeight);
    
    CGSize labelSize = [_label sizeThatFits:CGSizeMake(self.bounds.size.width - 54 * 2.0f, self.frame.size.height - 8.0f)];
    _label.frame = CGRectMake(CGFloor((self.bounds.size.width - labelSize.width) / 2.0f), CGFloor((self.bounds.size.height - labelSize.height) / 2.0f), labelSize.width, labelSize.height);
}

/*- (void)animateIn {
    [self layoutSubviews];
    
    CGFloat offset = [self preferredHeight];
    CGRect bounds = self.bounds;
    self.bounds = CGRectOffset(self.bounds, 0.0f, offset);
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^{
        self.bounds = bounds;
    } completion:nil];
}

- (void)animateOut:(void (^)())completion {
    _animatingOut = true;
    CGFloat offset = [self preferredHeight];
    [UIView animateWithDuration:0.15 delay:0.0 options:0 animations:^{
        self.bounds = CGRectOffset(self.bounds, 0.0f, offset);
    } completion:^(__unused BOOL finished) {
        completion();
    }];
}*/

- (void)setBarInset:(CGFloat)barInset animated:(bool)animated {
    if (ABS(barInset - self.barInset) > FLT_EPSILON) {
        [super setBarInset:barInset animated:animated];
        
        if (animated) {
            [self layoutSubviews];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                [self layoutSubviews];
            }];
        }
    }
}

- (void)setTimeout:(int32_t)timeout {
    if (_timeout != timeout) {
        if (timeout == 0 || timeout == INT32_MAX) {
            _label.text = TGLocalized(@"Conversation.RestrictedInline");
        } else {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"E, d MMM HH:mm"];
            formatter.locale = [NSLocale localeWithLocaleIdentifier:effectiveLocalization().code];
            NSString *dateStringPlain = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeout]];
            
            _label.text = [NSString stringWithFormat:TGLocalized(@"Conversation.RestrictedInlineTimed"), dateStringPlain];
        }
        [self setNeedsLayout];
    }
}

@end
