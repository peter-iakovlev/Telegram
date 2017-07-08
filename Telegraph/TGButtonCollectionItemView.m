#import "TGButtonCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGButtonCollectionItemView ()
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
    NSTextAlignment _alignment;
    CGPoint _iconOffset;
}

@end

@implementation TGButtonCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
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

- (void)setIcon:(UIImage *)icon {
    if (icon != nil) {
        if (_iconView == nil) {
            _iconView = [[UIImageView alloc] init];
        }
        
        if (_iconView.superview == nil) {
            [self addSubview:_iconView];
        }
        _iconView.image = icon;
    } else {
        _iconView.image = nil;
        [_iconView removeFromSuperview];
    }
    
    [self setNeedsLayout];
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

- (void)setIconOffset:(CGPoint)iconOffset
{
    _iconOffset = iconOffset;
    [self setNeedsLayout];
}

- (void)setLeftInset:(CGFloat)leftInset
{
    _leftInset = leftInset;
    self.separatorInset = _leftInset + _additionalSeparatorInset;
    
    [self setNeedsLayout];
}

- (void)setAdditionalSeparatorInset:(CGFloat)additionalSeparatorInset
{
    _additionalSeparatorInset = additionalSeparatorInset;
    self.separatorInset = _leftInset + _additionalSeparatorInset;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat inset = _leftInset;
    
    if (_iconView.superview != nil) {
        CGSize iconSize = _iconView.image.size;
        
        _iconView.frame = CGRectMake(CGFloor((_leftInset - iconSize.width) / 2.0f) + _iconOffset.x, CGFloor((bounds.size.height - iconSize.height) / 2.0f) + _iconOffset.y, iconSize.width, iconSize.height);
    }
    
    _titleLabel.frame = CGRectMake(inset, CGFloor((bounds.size.height - 26) / 2), bounds.size.width - inset - 15.0f, 26);
    [_titleLabel sizeToFit];
    
    CGFloat verticalOffset = TGRetinaPixel;
    if (_itemPosition & TGCollectionItemViewPositionLastInBlock)
        verticalOffset -= TGRetinaPixel;
    if (_itemPosition & TGCollectionItemViewPositionFirstInBlock)
        verticalOffset += TGRetinaPixel;
    
    if (_alignment == NSTextAlignmentCenter)
        _titleLabel.frame = CGRectMake(CGFloor((bounds.size.width - _titleLabel.frame.size.width) / 2), CGFloor((bounds.size.height - _titleLabel.frame.size.height) / 2) + verticalOffset, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    else
        _titleLabel.frame = CGRectMake(inset, CGFloor((bounds.size.height - _titleLabel.frame.size.height) / 2) + verticalOffset, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
}

@end
