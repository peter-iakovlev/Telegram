#import "TGVerticalSwipeDismissGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface TGVerticalSwipeDismissGestureRecognizer ()
{
    
}

@end

@implementation TGVerticalSwipeDismissGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self != nil)
    {
        self.maximumNumberOfTouches = 1;
    }
    return self;
}

- (void)reset
{
    [super reset];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

@end
