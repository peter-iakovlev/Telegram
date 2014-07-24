#import "TGModernGalleryRotationGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation TGModernGalleryRotationGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in [touches allObjects])
    {
        if ([[self.view hitTest:[touch locationInView:self.view] withEvent:event] isKindOfClass:[UIControl class]])
        {
            self.state = UIGestureRecognizerStateFailed;
            return;
        }
    }
    
    if (self.numberOfTouches >= 2 && self.state == UIGestureRecognizerStatePossible)
    {
        self.state = UIGestureRecognizerStateBegan;
    }
    
    [super touchesBegan:touches withEvent:event];
}

@end
