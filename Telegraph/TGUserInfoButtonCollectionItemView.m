/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoButtonCollectionItemView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGUserInfoButtonCollectionItemView ()
{
    CALayer *_separatorLayer;
    
    UILabel *_titleLabel;
}

@end

@implementation TGUserInfoButtonCollectionItemView

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
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    [self setNeedsLayout];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleLabel.textColor = titleColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat separatorHeight = TGScreenPixel;
    _separatorLayer.frame = CGRectMake(_editing ? 15.0f : 35.0f, bounds.size.height - separatorHeight, bounds.size.width - (_editing ? 15.0f : 35.0f), separatorHeight);
    
    CGFloat leftPadding = 35.0f + TGRetinaPixel;
    
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(bounds.size.width - leftPadding - 10.0f, CGFLOAT_MAX)];
    _titleLabel.frame = CGRectMake(leftPadding, 12.0f, titleSize.width, titleSize.height);
}

@end
