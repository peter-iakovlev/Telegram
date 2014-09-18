#import "TGImagePanGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface TGImagePanGestureRecognizer ()

@property (nonatomic) bool lockedDirection;

@end

@implementation TGImagePanGestureRecognizer

@synthesize lockedDirection = _lockedDirection;

- (void)reset
{
    _lockedDirection = false;
    
    [super reset];
}

- (void)failGesture
{
    self.state = UIGestureRecognizerStateFailed;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent*)event
{
    CGPoint translation = [self translationInView:self.view];
    
    if (ABS(translation.y) > 20)
        _lockedDirection = true;
    
    if (ABS(translation.x) > 20 && !_lockedDirection)
        [self failGesture];
    else
        [super touchesMoved:touches withEvent:event];
}

@end
