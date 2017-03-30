/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCheckCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGCheckCollectionItemView ()
{
    UIImageView *_checkView;
    UILabel *_label;
}

@end

@implementation TGCheckCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.separatorInset = 44.0f;
        
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentLeft;
        _label.textColor = [UIColor blackColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = TGSystemFontOfSize(17);
        [self addSubview:_label];
        
        _checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernMenuCheck.png"]];
        [self addSubview:_checkView];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _label.text = title;
    [self setNeedsLayout];
}

- (void)setIsChecked:(bool)isChecked
{
    _checkView.hidden = !isChecked;
}

- (void)setDrawsFullSeparator:(bool)drawsFullSeparator
{
    _drawsFullSeparator = drawsFullSeparator;
    self.separatorInset = drawsFullSeparator ? 0.0f : (_alignToRight ? 15.0f : 44.0f);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    if (_drawsFullSeparator)
    {
        CGFloat separatorHeight = TGScreenPixel;
        _topStripeView.frame = CGRectMake(self.separatorInset, 0.0f, self.frame.size.width - self.separatorInset, separatorHeight * 2.0f);
    }
    
    if (_alignToRight)
    {
        _label.frame = CGRectMake(15.0f, CGFloor((bounds.size.height - 26) / 2), bounds.size.width - 44.0f - 16.0f, 26);
        
        CGSize checkSize = _checkView.frame.size;
        _checkView.frame = CGRectMake(bounds.size.width - 15.0f - checkSize.width, 16.0f, checkSize.width, checkSize.height);
    }
    else
    {
        _label.frame = CGRectMake(44.0f, CGFloor((bounds.size.height - 26) / 2), bounds.size.width - 44.0f - 16.0f, 26);
        
        CGSize checkSize = _checkView.frame.size;
        _checkView.frame = CGRectMake(15.0f, 16.0f, checkSize.width, checkSize.height);
    }
}

@end
