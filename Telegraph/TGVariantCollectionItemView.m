#import "TGVariantCollectionItemView.h"
#import "TGSimpleImageView.h"
#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@interface TGVariantCollectionItemView ()
{
    UILabel *_titleLabel;
    UILabel *_variantLabel;
    TGSimpleImageView *_iconView;
    TGSimpleImageView *_variantIconView;
    TGSimpleImageView *_disclosureIndicator;
    CGFloat _minLeftPadding;
    bool _flexibleLayout;
    
    UIColor *_customVariantColor;
}

@end

@implementation TGVariantCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        [self addSubview:_titleLabel];
        
        _variantLabel = [[UILabel alloc] init];
        _variantLabel.textColor = UIColorRGB(0x929297);
        _variantLabel.backgroundColor = [UIColor clearColor];
        _variantLabel.font = TGSystemFontOfSize(17);
        [self addSubview:_variantLabel];
        
        _disclosureIndicator = [[TGSimpleImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 8.0f, 14.0f)];
        [self addSubview:_disclosureIndicator];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _titleLabel.textColor = presentation.pallete.collectionMenuTextColor;
    _variantLabel.textColor = _customVariantColor ?: presentation.pallete.collectionMenuVariantColor;
    _disclosureIndicator.image = presentation.images.collectionMenuDisclosureIcon;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    [self setNeedsLayout];
    [_titleLabel setNeedsDisplay];
}

- (void)setVariant:(NSString *)variant variantColor:(UIColor *)variantColor
{
    _variantLabel.text = variant;
    _customVariantColor = variantColor;
    _variantLabel.textColor = variantColor == nil ? self.presentation.pallete.collectionMenuVariantColor : variantColor;
    [self setNeedsLayout];
    [_variantLabel setNeedsDisplay];
}

- (void)setIcon:(UIImage *)icon
{
    if (_iconView == nil && icon != nil)
    {
        _iconView = [[TGSimpleImageView alloc] initWithFrame:CGRectMake(15, (self.frame.size.height - 15) / 2, 29, 29)];
        _iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:_iconView];
    }
    
    _iconView.image = icon;
    self.separatorInset = (icon != nil) ? 59.0f : 15.0f;
    
    [self setNeedsLayout];
}

- (void)setVariantIcon:(UIImage *)variantIcon {
    if (_variantIconView == nil && variantIcon != nil) {
        _variantIconView = [[TGSimpleImageView alloc] init];
        _variantIconView.contentMode = UIViewContentModeCenter;
        [self addSubview:_variantIconView];
    } else if (variantIcon == nil) {
        [_variantIconView removeFromSuperview];
        _variantIconView = nil;
    }
    
    _variantIconView.image = variantIcon;
    
    [self setNeedsLayout];
}

- (void)setEnabled:(bool)enabled {
    self.userInteractionEnabled = enabled;
    _titleLabel.textColor = enabled ? self.presentation.pallete.collectionMenuTextColor : [self.presentation.pallete.collectionMenuTextColor colorWithAlphaComponent:0.56f];
}

- (void)setHideArrow:(bool)hideArrow {
    _disclosureIndicator.hidden = hideArrow;
}

- (void)setMinLeftPadding:(CGFloat)minLeftPadding {
    _minLeftPadding = minLeftPadding;
    [self setNeedsLayout];
}

- (void)setFlexibleLayout:(bool)flexibleLayout {
    _flexibleLayout = flexibleLayout;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGFloat width = bounds.size.width - self.safeAreaInset.left - self.safeAreaInset.right;
    
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGSize variantSize = [_variantLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    if (_flexibleLayout) {
        variantSize = [_variantLabel.text sizeWithFont:_variantLabel.font];
        variantSize.width = CGCeil(variantSize.width);
        variantSize.height = CGCeil(variantSize.height);
    }
    
    _disclosureIndicator.frame = CGRectMake(bounds.size.width - _disclosureIndicator.frame.size.width - 15 - self.safeAreaInset.right, CGFloor((bounds.size.height - _disclosureIndicator.frame.size.height) / 2), _disclosureIndicator.frame.size.width, _disclosureIndicator.frame.size.height);
    
    CGFloat disclosureWidth = _disclosureIndicator.hidden ? 0.0f: _disclosureIndicator.frame.size.width;
    
    CGFloat startingX = (_iconView.image != nil) ? 59.0f : 15.0f;
    startingX += self.safeAreaInset.left;
    
    CGFloat indicatorSpacing = _disclosureIndicator.hidden ? 0.0f : 10.0f;
    CGFloat labelSpacing = 8.0f;
    CGFloat availableWidth = bounds.size.width - disclosureWidth - 15.0f - startingX - indicatorSpacing - self.safeAreaInset.right;
    
    CGFloat titleY =  CGFloor((bounds.size.height - titleSize.height) / 2.0f) + TGRetinaPixel;
    CGFloat variantY =  CGFloor((bounds.size.height - variantSize.height) / 2.0f) + TGRetinaPixel;
    
    if (_flexibleLayout) {
        _titleLabel.frame = CGRectMake(startingX, titleY, titleSize.width, titleSize.height);
        
        CGFloat variantWidth = MIN(CGFloor(availableWidth / 2.0f), MIN(availableWidth - titleSize.width - 25.0f, variantSize.width));
        
        CGFloat variantOffset = startingX + availableWidth - variantWidth;
        _variantLabel.frame = CGRectMake(variantOffset, variantY, variantWidth, variantSize.height);
    }
    else if (titleSize.width + labelSpacing + variantSize.width <= availableWidth)
    {
        _titleLabel.frame = CGRectMake(startingX, titleY, titleSize.width, titleSize.height);
        CGFloat variantOffset = startingX + availableWidth - variantSize.width;
        if (_minLeftPadding > FLT_EPSILON) {
            variantOffset = MAX(startingX + titleSize.width + 4.0, _minLeftPadding + self.safeAreaInset.left);
        }
        _variantLabel.frame = CGRectMake(variantOffset, variantY, variantSize.width, variantSize.height);
    }
    else if (titleSize.width > variantSize.width)
    {
        CGFloat titleWidth = CGFloor(availableWidth * 3.0f / 4.0f) - labelSpacing;
        _titleLabel.frame = CGRectMake(startingX, titleY, titleWidth, titleSize.height);
        CGFloat variantWidth = MIN(variantSize.width, availableWidth - titleWidth - labelSpacing);
        _variantLabel.frame = CGRectMake(startingX + availableWidth - variantWidth, variantY, variantWidth, variantSize.height);
    }
    else
    {
        CGFloat variantWidth = CGFloor(availableWidth / 2.0f) - labelSpacing;
        _variantLabel.frame = CGRectMake(startingX + availableWidth - variantWidth, variantY, variantWidth, variantSize.height);
        CGFloat titleWidth = MIN(titleSize.width, availableWidth - variantWidth - labelSpacing);
        _titleLabel.frame = CGRectMake(startingX, titleY, titleWidth, titleSize.height);
    }
    
    if (_iconView.image != nil)
    {
        _iconView.frame = CGRectMake(15.0f + self.safeAreaInset.left, floor((self.frame.size.height - _iconView.frame.size.height) / 2) + TGScreenPixel, _iconView.frame.size.width, _iconView.frame.size.height);
    }
    
    if (_variantIconView.image != nil) {
        _variantIconView.frame = CGRectMake(CGRectGetMinX(_variantLabel.frame) - 8.0 - _variantIconView.image.size.width, CGFloor(self.frame.size.height - _variantIconView.image.size.height) / 2, _variantIconView.image.size.width, _variantIconView.image.size.height);
    }
}

@end
