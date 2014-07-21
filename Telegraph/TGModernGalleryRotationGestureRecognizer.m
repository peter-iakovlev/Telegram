#import "TGModernGalleryRotationGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation TGModernGalleryRotationGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.numberOfTouches >= 2 && self.state == UIGestureRecognizerStatePossible)
    {
        self.state = UIGestureRecognizerStateBegan;
    }
    
    [super touchesBegan:touches withEvent:event];
}

@end
