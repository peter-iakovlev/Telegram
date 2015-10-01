#import "TGHighlightableButton.h"

@implementation TGHighlightableButton

- (void)setHighlighted:(BOOL)highlighted
{
    for (UIView *view in self.subviews)
    {
        if ([view isKindOfClass:[UILabel class]])
            [(UILabel *)view setHighlighted:highlighted];
        else if ([view isKindOfClass:[UIImageView class]])
            [(UIImageView *)view setHighlighted:highlighted];
    }
    
    if (_reverseTitleShadow)
        self.titleLabel.shadowOffset = highlighted ? CGSizeMake(-_normalTitleShadowOffset.width, -_normalTitleShadowOffset.height) : _normalTitleShadowOffset;
    
    if (_normalBackgroundColor != nil && _highlightedBackgroundColor != nil)
        self.backgroundColor = highlighted ? _highlightedBackgroundColor : _normalBackgroundColor;
    
    [super setHighlighted:highlighted];
}

@end