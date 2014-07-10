/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGHeaderCollectionItemView.h"

#import "TGFont.h"

@interface TGHeaderCollectionItemView ()
{
    UILabel *_label;
}

@end

@implementation TGHeaderCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = UIColorRGB(0x6d6d72);
        _label.font = TGSystemFontOfSize(14.0f);
        _label.textAlignment = NSTextAlignmentLeft;
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
        _label.numberOfLines = 1;
        [self addSubview:_label];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _label.text = title;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize labelSize = [_label sizeThatFits:CGSizeMake(self.bounds.size.width - 30.0f, CGFLOAT_MAX)];
    _label.frame = CGRectMake(15.0f, 0.0f, labelSize.width, labelSize.height);
}

@end
