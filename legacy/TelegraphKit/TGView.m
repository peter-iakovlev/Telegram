#import "TGView.h"

@implementation TGView

@synthesize hitTestMatchAll = _hitTestMatchAll;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_hitTestMatchAll)
    {
        for (UIView *view in self.subviews)
        {
            if (CGRectContainsPoint(view.frame, point))
            {
                UIView *hitResult = [view hitTest:CGPointMake(point.x - view.frame.origin.x, point.y - view.frame.origin.y) withEvent:event];
                if (hitResult != nil)
                    return hitResult;
            }
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
