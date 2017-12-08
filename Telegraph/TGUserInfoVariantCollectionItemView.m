#import "TGUserInfoVariantCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGUserInfoVariantCollectionItemView ()
{
    CALayer *_separatorLayer;
    
    UILabel *_titleLabel;
    UILabel *_variantLabel;
    UIImageView *_arrowView;
    
    UIImageView *_variantImageView;
}

@end

@implementation TGUserInfoVariantCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.selectionInsets = UIEdgeInsetsMake(TGScreenPixel, 0.0f, 0.0f, 0.0f);
        
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.backgroundView.layer addSublayer:_separatorLayer];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17.0f);
        _titleLabel.textColor = [UIColor blackColor];
        [self addSubview:_titleLabel];
        
        _variantLabel = [[UILabel alloc] init];
        _variantLabel.backgroundColor = [UIColor clearColor];
        _variantLabel.font = TGSystemFontOfSize(17.0f);
        _variantLabel.textColor = UIColorRGB(0x8e8e93);
        [self addSubview:_variantLabel];
        
        _arrowView = [[UIImageView alloc] initWithImage:TGComponentsImageNamed(@"ModernListsDisclosureIndicator.png")];
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

- (void)setVariantImage:(UIImage *)variantImage
{
    if (variantImage != nil)
    {
        if (_variantImageView == nil)
        {
            _variantImageView = [[UIImageView alloc] init];
            [self addSubview:_variantImageView];
        }
        _variantImageView.image = variantImage;
        [_variantImageView sizeToFit];
        _variantImageView.hidden = false;
    }
    else
        _variantImageView.hidden = true;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat separatorHeight = TGScreenPixel;
    CGFloat separatorInset = 35.0f + self.safeAreaInset.left;
    _separatorLayer.frame = CGRectMake(separatorInset, bounds.size.height - separatorHeight, bounds.size.width - separatorInset, separatorHeight);
    
    CGFloat leftPadding = 35.0f + TGScreenPixel + self.safeAreaInset.left;
    
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(bounds.size.width - leftPadding - self.safeAreaInset.right - 10.0f, CGFLOAT_MAX)];
    _titleLabel.frame = CGRectMake(leftPadding, 12.0f, titleSize.width, titleSize.height);
    
    CGSize variantSize = [_variantLabel sizeThatFits:CGSizeMake(bounds.size.width - leftPadding - self.safeAreaInset.right - 10.0f, CGFLOAT_MAX)];
    _variantLabel.frame = CGRectMake(bounds.size.width - 34.0f - variantSize.width - self.safeAreaInset.right, 12.0f, variantSize.width, variantSize.height);
    
    if (_variantImageView != nil)
    {
        _variantImageView.frame = CGRectMake(bounds.size.width - 34.0f - _variantImageView.frame.size.width - self.safeAreaInset.right, CGFloor((bounds.size.height - _variantImageView.frame.size.height) / 2.0f), _variantImageView.frame.size.width, _variantImageView.frame.size.height);
    }
    
    CGSize arrowSize = _arrowView.bounds.size;
    _arrowView.frame = CGRectMake(bounds.size.width - 15.0f - arrowSize.width - self.safeAreaInset.right, 15.0f, arrowSize.width, arrowSize.height);
}

@end
