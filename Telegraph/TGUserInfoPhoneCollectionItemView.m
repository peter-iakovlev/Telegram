/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoPhoneCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGUserInfoPhoneCollectionItemView ()
{
    CALayer *_separatorLayer;
    
    UILabel *_labelView;
    UILabel *_phoneLabel;
}

@end

@implementation TGUserInfoPhoneCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.selectionInsets = UIEdgeInsetsMake(TGScreenPixel, 0.0f, 0.0f, 0.0f);
        
        _separatorLayer = [[CALayer alloc] init];
        _separatorLayer.backgroundColor = TGSeparatorColor().CGColor;
        [self.backgroundView.layer addSublayer:_separatorLayer];
        
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = TGAccentColor();
        _labelView.font = TGSystemFontOfSize(14.0f);
        [self addSubview:_labelView];
        
        _phoneLabel = [[UILabel alloc] init];
        _phoneLabel.backgroundColor = [UIColor clearColor];
        _phoneLabel.textColor = [UIColor blackColor];
        _phoneLabel.font = TGSystemFontOfSize(17.0f);
        [self addSubview:_phoneLabel];
    }
    return self;
}

- (void)setLabel:(NSString *)label
{
    _labelView.text = label;
    [self setNeedsLayout];
}

- (void)setPhone:(NSString *)phone
{
    _phoneLabel.text = phone;
    [self setNeedsLayout];
}

- (void)setPhoneColor:(UIColor *)phoneColor
{
    _phoneLabel.textColor = phoneColor;
}

- (void)setLastInList:(bool)lastInList
{
    _separatorLayer.hidden = !lastInList;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat separatorHeight = TGScreenPixel;
    _separatorLayer.frame = CGRectMake(35.0f, bounds.size.height - separatorHeight, bounds.size.width - 35.0f, separatorHeight);
    
    CGFloat leftPadding = 35.0f + TGRetinaPixel;
    
    CGSize labelSize = [_labelView sizeThatFits:CGSizeMake(bounds.size.width - leftPadding - 10.0f, CGFLOAT_MAX)];
    _labelView.frame = CGRectMake(leftPadding, 11.0f, labelSize.width, labelSize.height);
    
    CGSize phoneSize = [_phoneLabel sizeThatFits:CGSizeMake(bounds.size.width - leftPadding - 10.0f, CGFLOAT_MAX)];
    _phoneLabel.frame = CGRectMake(leftPadding, 30.0f, phoneSize.width, phoneSize.height);
}

@end
