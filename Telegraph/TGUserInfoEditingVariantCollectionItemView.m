#import "TGUserInfoEditingVariantCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

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
        
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 8.0f, 14.0f)];
        [self addSubview:_arrowView];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _titleLabel.textColor = presentation.pallete.collectionMenuAccentColor;
    _variantLabel.textColor = presentation.pallete.collectionMenuVariantColor;
    _separatorLayer.backgroundColor = presentation.pallete.collectionMenuSeparatorColor.CGColor;
    _arrowView.image = presentation.images.collectionMenuDisclosureIcon;
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
    CGFloat separatorInset = 15.0f + self.safeAreaInset.left;
    _separatorLayer.frame = CGRectMake(separatorInset, bounds.size.height - separatorHeight, bounds.size.width - separatorInset, separatorHeight);
    
    CGFloat leftPadding = 15.0f + TGScreenPixel + self.safeAreaInset.left;
    
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(70.0f, CGFLOAT_MAX)];
    _titleLabel.frame = CGRectMake(leftPadding, 14.0f, titleSize.width, titleSize.height);
    
    CGSize variantSize = [_variantLabel sizeThatFits:CGSizeMake(bounds.size.width - 122.0f - 15.0f, CGFLOAT_MAX)];
    _variantLabel.frame = CGRectMake(bounds.size.width - variantSize.width - 35.0f - self.safeAreaInset.right, 12.0f, variantSize.width, variantSize.height);
    
    CGSize arrowSize = _arrowView.bounds.size;
    _arrowView.frame = CGRectMake(bounds.size.width - 15.0f - arrowSize.width - self.safeAreaInset.right, (self.frame.size.height - arrowSize.height) / 2.0f, arrowSize.width, arrowSize.height);
}

@end
