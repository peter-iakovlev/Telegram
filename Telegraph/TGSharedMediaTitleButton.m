#import "TGSharedMediaTitleButton.h"

@implementation TGSharedMediaTitleButton

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect bounds = self.bounds;
    bounds.origin.x = (bounds.size.width - _buttonTapAreaWidth) / 2.0f;
    bounds.size.width = _buttonTapAreaWidth;
    if (CGRectContainsPoint(CGRectInset(bounds, 0.0f, -22.0f), point))
        return self;
    
    return [super hitTest:point withEvent:event];
}

@end
