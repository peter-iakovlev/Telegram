#import "TGTextField.h"

#import "TGImageUtils.h"

@implementation TGTextField

- (void)drawPlaceholderInRect:(CGRect)rect
{
    if (_placeholderColor == nil || _placeholderFont == nil)
        [super drawPlaceholderInRect:rect];
    else
    {
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), _placeholderColor.CGColor);
        
        CGSize placeholderSize = [self.placeholder sizeWithFont:_placeholderFont];
        
        CGPoint placeholderOrigin = CGPointMake(0.0f, CGFloor((rect.size.height - placeholderSize.height) / 2.0f) - TGRetinaPixel);
        if (self.textAlignment == NSTextAlignmentCenter)
            placeholderOrigin.x = CGFloor((rect.size.width - placeholderSize.width) / 2.0f);
        else if (self.textAlignment == NSTextAlignmentRight)
            placeholderOrigin.x = rect.size.width - placeholderSize.width;
        
        [self.placeholder drawAtPoint:placeholderOrigin withFont:_placeholderFont];
    }
}

@end
