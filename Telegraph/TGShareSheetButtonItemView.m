#import "TGShareSheetButtonItemView.h"

#import "TGModernButton.h"
#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGShareSheetButtonItemView ()
{
    TGModernButton *_button;
    UIImageView *_imageView;
}

@end

@implementation TGShareSheetButtonItemView

- (instancetype)initWithTitle:(NSString *)title pressed:(void (^)())pressed
{
    self = [super init];
    if (self != nil)
    {
        _button = [[TGModernButton alloc] init];
        _button.exclusiveTouch = true;
        [_button setTitle:title forState:UIControlStateNormal];
        [_button setTitleColor:TGAccentColor() forState:UIControlStateNormal];
        [_button setTitleColor:UIColorRGB(0x8e8e93) forState:UIControlStateDisabled];
        [_button setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
        _button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _button.modernHighlight = true;
        
        _button.titleLabel.font = TGSystemFontOfSize(20.0f + TGRetinaPixel);
        [_button addTarget:self action:@selector(_buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        _button.stretchHighlightImage = true;
        _button.highlighted = false;
        
        __weak TGShareSheetButtonItemView *weakSelf = self;
        _button.highlitedChanged = ^(bool highlighted)
        {
            __strong TGShareSheetButtonItemView *strongSelf = weakSelf;
            if (strongSelf != nil && highlighted)
            {
                for (UIView *sibling in strongSelf.superview.subviews.reverseObjectEnumerator)
                {
                    if ([sibling isKindOfClass:[TGShareSheetItemView class]])
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

- (void)setDestructive:(bool)destructive
{
    [_button setTitleColor:destructive ? TGDestructiveAccentColor() : TGAccentColor()];
}

- (void)setEnabled:(bool)enabled {
    _button.enabled = enabled;
}

- (void)_buttonPressed
{
    if (_pressed)
        _pressed();
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    [_button setHighlightImage:highlightedImage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _button.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    _imageView.frame = CGRectMake(self.frame.size.width - _button.frame.size.height - 5, 0, _button.frame.size.height, _button.frame.size.height);
}

@end
