#import "TGAttachmentSheetButtonItemView.h"

#import "TGModernButton.h"
#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGAttachmentSheetButtonItemView ()
{
    TGModernButton *_button;
    UIImageView *_imageView;
}

@end

@implementation TGAttachmentSheetButtonItemView

- (instancetype)initWithTitle:(NSString *)title pressed:(void (^)())pressed
{
    self = [super init];
    if (self != nil)
    {
        _button = [[TGModernButton alloc] init];
        _button.exclusiveTouch = true;
        [_button setTitle:title forState:UIControlStateNormal];
        [_button setTitleColor:TGAccentColor()];
        _button.titleLabel.font = TGSystemFontOfSize(20.0f + TGRetinaPixel);
        [_button addTarget:self action:@selector(_buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        CGFloat separatorHeight = TGScreenPixel;
        _button.backgroundSelectionInsets = UIEdgeInsetsMake(1.0f + separatorHeight, 0.0f, 1.0f, 0.0f);
        _button.highlightBackgroundColor = TGSelectionColor();
        _button.highlighted = false;
        
        __weak TGAttachmentSheetButtonItemView *weakSelf = self;
        _button.highlitedChanged = ^(bool highlighted)
        {
            __strong TGAttachmentSheetButtonItemView *strongSelf = weakSelf;
            if (strongSelf != nil && highlighted)
            {
                for (UIView *sibling in strongSelf.superview.subviews.reverseObjectEnumerator)
                {
                    if ([sibling isKindOfClass:[TGAttachmentSheetItemView class]])
                    {
                        if (sibling != strongSelf)
                        {
                            [strongSelf.superview exchangeSubviewAtIndex:[strongSelf.superview.subviews indexOfObject:strongSelf] withSubviewAtIndex:[strongSelf.superview.subviews indexOfObject:sibling]];
                        }
                        break;
                    }
                }
            }
        };
        
        [self addSubview:_button];
        
        _pressed = [pressed copy];
        
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    [_button setTitle:title forState:UIControlStateNormal];
}

- (void)setBold:(bool)bold
{
    _button.titleLabel.font = bold ? TGMediumSystemFontOfSize(20.0f + TGRetinaPixel) : TGSystemFontOfSize(20.0f + TGRetinaPixel);
}

- (void)setImage:(UIImage *)image
{
    if (_imageView == nil)
    {
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.contentMode = UIViewContentModeCenter;
        
        [self addSubview:_imageView];
    }
    
    _imageView.image = image;
    [self setNeedsLayout];
}

- (void)setDisabled:(bool)disabled {
    [_button setTitleColor:disabled ? UIColorRGB(0x8f8f8f) : TGAccentColor()];
    _button.userInteractionEnabled = !disabled;
}

- (void)setDestructive:(bool)destructive
{
    [_button setTitleColor:destructive ? TGDestructiveAccentColor() : TGAccentColor()];
}

- (void)_buttonPressed
{
    if (_pressed)
        _pressed();
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _button.frame = CGRectMake(0.0f, 1.0f, self.bounds.size.width, self.bounds.size.height - 2.0f);
    _imageView.frame = CGRectMake(self.frame.size.width - _button.frame.size.height - 5, 0, _button.frame.size.height, _button.frame.size.height);
}

@end
