#import "TGButtonCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGButtonCollectionItemView ()
{
    UILabel *_titleLabel;
    NSTextAlignment _alignment;
}

@end

@implementation TGButtonCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
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

- (void)setTitleAlignment:(NSTextAlignment)alignment
{
    _alignment = alignment;
    
    [self setNeedsLayout];
}

- (void)setEnabled:(bool)enabled
{
    _titleLabel.alpha = enabled ? 1.0f : 0.5f;
}

- (void)setItemPosition:(int)itemPosition
{
    [super setItemPosition:itemPosition];
    
    if (_itemPosition != itemPosition)
    {
        _itemPosition = itemPosition;
        [self setNeedsLayout];
    }
}

- (void)setLeftInset:(CGFloat)leftInset
{
    _leftInset = leftInset;
    self.separatorInset = _leftInset;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat inset = _leftInset;
    
    _titleLabel.frame = CGRectMake(inset, floorf((bounds.size.height - 26) / 2), bounds.size.width - inset - 15.0f, 26);
    [_titleLabel sizeToFit];
    
    CGFloat verticalOffset = TGRetinaPixel;
    if (_itemPosition & TGCollectionItemViewPositionLastInBlock)
        verticalOffset -= TGRetinaPixel;
    if (_itemPosition & TGCollectionItemViewPositionFirstInBlock)
        verticalOffset += TGRetinaPixel;
    
    if (_alignment == NSTextAlignmentCenter)
        _titleLabel.frame = CGRectMake(floorf((bounds.size.width - _titleLabel.frame.size.width) / 2), floorf((bounds.size.height - _titleLabel.frame.size.height) / 2) + verticalOffset, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    else
        _titleLabel.frame = CGRectMake(inset, floorf((bounds.size.height - _titleLabel.frame.size.height) / 2) + verticalOffset, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
}

@end
