#import "TGButton.h"

@implementation TGButton

@synthesize touchInset = _touchInset;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.hidden || self.alpha < FLT_EPSILON)
        return nil;
    
    if (CGRectContainsPoint(CGRectInset(self.bounds, -_touchInset.width, -_touchInset.height), point))
        return self;
    
    return [super hitTest:point withEvent:event];
}

@end
