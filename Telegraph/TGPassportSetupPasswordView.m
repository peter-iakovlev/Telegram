#import "TGPassportSetupPasswordView.h"
#import "TGButtonCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@interface TGPassportSetupPasswordView ()
{
    UIImageView *_iconView;
    UILabel *_textLabel;
    
    TGModernButton *_button;
    UIView *_topStripView;
    UIView *_bottomStripView;
}
@end

@implementation TGPassportSetupPasswordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _iconView = [[UIImageView alloc] initWithImage:TGImageNamed(@"PasswordPlaceholderIcon.png")];
        [self addSubview:_iconView];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = UIColorRGB(0x6d6d72);
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _textLabel.numberOfLines = 0;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = TGSystemFontOfSize(14.0f);
        _textLabel.text = TGLocalized(@"Passport.PasswordDescription");
        [self addSubview:_textLabel];
        
        __weak TGPassportSetupPasswordView *weakSelf = self;
        _button = [[TGModernButton alloc] init];
        _button.titleLabel.font = TGSystemFontOfSize(17);
        _button.exclusiveTouch = true;
        _button.highlitedChanged = ^(bool highlighted)
        {
            __strong TGPassportSetupPasswordView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_topStripView.hidden = highlighted;
                strongSelf->_bottomStripView.hidden = highlighted;
            }
        };
        [_button setTitle:TGLocalized(@"Passport.PasswordCreate") forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        
        _topStripView = [[UIView alloc] init];
        [_button addSubview:_topStripView];
        
        _bottomStripView = [[UIView alloc] init];
        [_button addSubview:_bottomStripView];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _button.backgroundColor = presentation.pallete.collectionMenuCellBackgroundColor;
    [_button setTitleColor:presentation.pallete.collectionMenuAccentColor];
    _button.highlightBackgroundColor = presentation.pallete.collectionMenuCellSelectionColor;
    _topStripView.backgroundColor = presentation.pallete.collectionMenuSeparatorColor;
    _bottomStripView.backgroundColor = presentation.pallete.collectionMenuSeparatorColor;
    _textLabel.textColor = presentation.pallete.collectionMenuCommentColor;
}

- (void)buttonPressed
{
    if (self.setupPressed != nil)
        self.setupPressed();
}

- (void)setRequest:(bool)request
{
    _request = request;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGFloat inset = ![TGViewController hasLargeScreen] ? 30.0f : 60.0f;
    CGSize textSize = [_textLabel.attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width - inset, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    CGFloat offset = 64.0f;// [TGViewController isWidescreen] ? 40.0f : 38.0f;

    CGFloat iconTitleSpacing = [TGViewController isWidescreen] ? -12.0f : -26.0f;
    
    CGFloat contentHeight = _iconView.frame.size.height + textSize.height;
    
    CGFloat buttonBottomInset = 130.0f;
    if ((int)TGScreenSize().height == 480 || ((int)TGScreenSize().height == 568 && _request))
        buttonBottomInset = 96.0f;
    
    _button.frame = CGRectMake(0.0f, self.frame.size.height - 44.0f - buttonBottomInset, self.frame.size.width, 44.0f);
    
    CGFloat minimumOrigin = -20.0f;
    if (_request && (int)TGScreenSize().height == 568)
        minimumOrigin = 46.0f;
    
    CGFloat contentOrigin = MAX(minimumOrigin, MIN(CGFloor((self.frame.size.height - contentHeight) / 2.0f) - offset - 44.0f, _button.frame.origin.y - _iconView.frame.size.height - textSize.height - iconTitleSpacing - 20.0f));
    
    _iconView.frame = CGRectMake(CGFloor((self.frame.size.width - _iconView.frame.size.width) / 2.0f), contentOrigin, _iconView.frame.size.width, _iconView.frame.size.height);
    _textLabel.frame = CGRectMake(CGFloor((self.frame.size.width - textSize.width) / 2.0f), contentOrigin + _iconView.frame.size.height + iconTitleSpacing, textSize.width, textSize.height);
    
    _topStripView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, TGSeparatorHeight());
    _bottomStripView.frame = CGRectMake(0.0f, 44.0f - TGSeparatorHeight(), self.frame.size.width, TGSeparatorHeight());
    
    CGFloat alpha = self.frame.size.height < 1.0f ? 0.0f : 1.0f;
    _iconView.alpha = alpha;
    _textLabel.alpha = alpha;
}

@end
