/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoEditingVariantCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGUserInfoEditingVariantCollectionItemView ()
{
    CALayer *_separatorLayer;
    
    UILabel *_titleLabel;
    UILabel *_variantLabel;
    UIImageView *_arrowView;
}

@end

@implementation TGUserInfoEditingVariantCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.backgroundView.layer addSublayer:_separatorLayer];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = TGAccentColor();
        _titleLabel.font = TGSystemFontOfSize(14.0f);
        [self addSubview:_titleLabel];
        
        _variantLabel = [[UILabel alloc] init];
        _variantLabel.backgroundColor = [UIColor clearColor];
        _variantLabel.textColor = [UIColor blackColor];
        _variantLabel.font = TGSystemFontOfSize(17.0f);
        [self addSubview:_variantLabel];
        
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernListsDisclosureIndicatorSmall.png"]];
        [self addSubview:_arrowView];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    [self setNeedsLayout];
}

- (void)setVariant:(NSString *)variant
{
    _variantLabel.text = variant;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat separatorHeight = TGScreenPixel;
    _separatorLayer.frame = CGRectMake(15.0f, bounds.size.height - separatorHeight, bounds.size.width - 15.0f, separatorHeight);
    
    CGFloat leftPadding = 35.0f + TGRetinaPixel;
    
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(70.0f, CGFLOAT_MAX)];
    _titleLabel.frame = CGRectMake(leftPadding, 14.0f, titleSize.width, titleSize.height);
    
    CGSize variantSize = [_variantLabel sizeThatFits:CGSizeMake(bounds.size.width - 122.0f - 35.0f, CGFLOAT_MAX)];
    _variantLabel.frame = CGRectMake(bounds.size.width - variantSize.width - 35.0f, 12.0f, variantSize.width, variantSize.height);
    
    CGSize arrowSize = _arrowView.bounds.size;
    _arrowView.frame = CGRectMake(bounds.size.width - 15.0f - arrowSize.width, 18.0f, arrowSize.width, arrowSize.height);
}

@end
