#import "TGDisclosureActionCollectionItemView.h"

#import "TGSimpleImageView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@interface TGDisclosureActionCollectionItemView ()
{
    UILabel *_titleLabel;
    TGSimpleImageView *_iconView;
    TGSimpleImageView *_disclosureIndicator;
    
    UILabel *_badgeLabel;
    TGSimpleImageView *_badgeView;
}

@end

@implementation TGDisclosureActionCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        [self addSubview:_titleLabel];
        
        _disclosureIndicator = [[TGSimpleImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 8.0f, 14.0f)];
        [self addSubview:_disclosureIndicator];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _titleLabel.textColor = presentation.pallete.collectionMenuTextColor;
    _disclosureIndicator.image = presentation.images.collectionMenuDisclosureIcon;
    
    _badgeLabel.textColor = self.presentation.pallete.collectionMenuBadgeTextColor;
    _badgeView.image = self.presentation.images.collectionMenuBadgeImage;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    
    [self setNeedsLayout];
    
    [_titleLabel setNeedsDisplay];
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

- (void)setBadge:(NSString *)badge {
    if (badge != nil) {
        if (_badgeLabel == nil) {
            _badgeLabel = [[UILabel alloc] init];
            _badgeLabel.font = TGSystemFontOfSize(14);
            _badgeLabel.backgroundColor = [UIColor clearColor];
            _badgeLabel.textColor = self.presentation.pallete.collectionMenuBadgeTextColor;
            [self addSubview:_badgeLabel];
            
            _badgeView = [[TGSimpleImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
            _badgeView.image = self.presentation.images.collectionMenuBadgeImage;
            
            [self addSubview:_badgeView];
            [self addSubview:_badgeLabel];
        }
        _badgeLabel.text = badge;
        [_badgeLabel sizeToFit];
    } else {
        [_badgeView removeFromSuperview];
        _badgeView = nil;
        [_badgeLabel removeFromSuperview];
        _badgeLabel = nil;
    }
    
    [self setNeedsLayout];
}

- (void)setHideArrow:(bool)hideArrow {
    _disclosureIndicator.hidden = hideArrow;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _iconView.frame = CGRectMake(15 + self.safeAreaInset.left, floor((self.frame.size.height - _iconView.frame.size.height) / 2) + TGScreenPixel, _iconView.frame.size.width, _iconView.frame.size.height);
    
    CGFloat startingX = (_iconView.image != nil) ? 59.0f : 15.0f;
    startingX += self.safeAreaInset.left;
    _titleLabel.frame = CGRectMake(startingX, CGFloor((bounds.size.height - 26) / 2), bounds.size.width - 15 - 40, 26);
    _disclosureIndicator.frame = CGRectMake(bounds.size.width - _disclosureIndicator.frame.size.width - 15 - self.safeAreaInset.right, CGFloor((bounds.size.height - _disclosureIndicator.frame.size.height) / 2), _disclosureIndicator.frame.size.width, _disclosureIndicator.frame.size.height);
    
    if (_badgeLabel != nil) {
        CGSize labelSize = _badgeLabel.frame.size;
        CGFloat badgeWidth = MAX(20.0f, labelSize.width + 12.0);
        _badgeView.frame = CGRectMake((_disclosureIndicator.hidden ? bounds.size.width - self.safeAreaInset.right : CGRectGetMinX(_disclosureIndicator.frame)) - 10.0 - badgeWidth, CGFloor((bounds.size.height - 20.0f) / 2.0f), badgeWidth, 20.0f);
        _badgeLabel.frame = CGRectMake(CGRectGetMinX(_badgeView.frame) + TGRetinaFloor((badgeWidth - labelSize.width) / 2.0f), CGRectGetMinY(_badgeView.frame) + 1.0f + TGScreenPixel, labelSize.width, labelSize.height);
    }
}

@end
