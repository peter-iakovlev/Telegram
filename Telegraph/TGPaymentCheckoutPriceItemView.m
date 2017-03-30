#import "TGPaymentCheckoutPriceItemView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGPaymentCheckoutPriceItemView () {
    UILabel *_titleLabel;
    UILabel *_valueLabel;
}

@end

@implementation TGPaymentCheckoutPriceItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.opaque = false;
        _titleLabel.backgroundColor = nil;
        _titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_titleLabel];
        
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.opaque = false;
        _valueLabel.backgroundColor = nil;
        _valueLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_valueLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title value:(NSString *)value bold:(bool)bold {
    if (bold) {
        _titleLabel.font = TGBoldSystemFontOfSize(17.0f);
        _valueLabel.font = TGBoldSystemFontOfSize(17.0f);
        _titleLabel.textColor = [UIColor blackColor];
        _valueLabel.textColor = [UIColor blackColor];
    } else {
        _titleLabel.font = TGSystemFontOfSize(17.0f);
        _valueLabel.font = TGSystemFontOfSize(17.0f);
        _titleLabel.textColor = UIColorRGB(0x999999);
        _valueLabel.textColor = UIColorRGB(0x999999);
    }
    _titleLabel.text = title;
    _valueLabel.text = value;
    [self setNeedsLayout];
}

- (void)setItemPosition:(int)itemPosition animated:(bool)animated {
    [super setItemPosition:itemPosition animated:animated];
    _topStripeView.hidden = true;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(bounds.size.width, CGFLOAT_MAX)];
    CGSize variantSize = [_valueLabel sizeThatFits:CGSizeMake(bounds.size.width, CGFLOAT_MAX)];
    
    CGFloat disclosureWidth = 0.0f;
    
    CGFloat startingX = 15.0f;
    CGFloat indicatorSpacing = 0.0f;
    CGFloat labelSpacing = 8.0f;
    CGFloat availableWidth = bounds.size.width - disclosureWidth - 15.0f - startingX - indicatorSpacing;
    
    CGFloat titleY =  CGFloor((bounds.size.height - titleSize.height) / 2.0f) + TGScreenPixel;
    CGFloat variantY =  CGFloor((bounds.size.height - variantSize.height) / 2.0f) + TGScreenPixel;
    
    if (titleSize.width + labelSpacing + variantSize.width <= availableWidth)
    {
        _titleLabel.frame = CGRectMake(startingX, titleY, titleSize.width, titleSize.height);
        _valueLabel.frame = CGRectMake(startingX + availableWidth - variantSize.width, variantY, variantSize.width, variantSize.height);
    }
    else if (titleSize.width > variantSize.width)
    {
        CGFloat titleWidth = CGFloor(availableWidth * 2.0f / 3.0f) - labelSpacing;
        _titleLabel.frame = CGRectMake(startingX, titleY, titleWidth, titleSize.height);
        CGFloat variantWidth = MIN(variantSize.width, availableWidth - titleWidth - labelSpacing);
        _valueLabel.frame = CGRectMake(startingX + availableWidth - variantWidth, variantY, variantWidth, variantSize.height);
    }
    else
    {
        CGFloat variantWidth = CGFloor(availableWidth / 2.0f) - labelSpacing;
        _valueLabel.frame = CGRectMake(startingX + availableWidth - variantWidth, variantY, variantWidth, variantSize.height);
        CGFloat titleWidth = MIN(titleSize.width, availableWidth - variantWidth - labelSpacing);
        _titleLabel.frame = CGRectMake(startingX, titleY, titleWidth, titleSize.height);
    }
}

@end
