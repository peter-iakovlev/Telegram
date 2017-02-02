#import "TGForceTouchGestureRecognizer.h"
#import "TGTimerTarget.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

const CGFloat TGForceTouchBasePressureThreshold = 1.0f;
const CGFloat TGForceTouchTriggerPressureThreshold = 2.5f;
const NSTimeInterval TGForceTouchDelay = 0.4;

@interface TGForceTouchGestureRecognizer ()
{
    bool _ready;
    
    NSTimer *_forceTimer;
    UITouch *_forceTouch;
}
@end

@implementation TGForceTouchGestureRecognizer

- (void)dealloc
{
    [_forceTimer invalidate];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)__unused event
{
    if (touches.count > 1)
    {
        self.state = UIGestureRecognizerStateCancelled;
        return;
    }

    self.state = UIGestureRecognizerStatePossible;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStateFailed || self.state == UIGestureRecognizerStateRecognized)
        return;
    
    CGPoint location = [touches.anyObject locationInView:self.view];
    if (![self.view pointInside:location withEvent:event])
    {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    UITouch *touch = touches.anyObject;
    if (!_ready)
        [self _startWithTouch:touch];
    else if (_ready)
        [self _updateWithTouch:touch];
}

- (void)touchesEnded:(NSSet<UITouch *> *)__unused touches withEvent:(UIEvent *)__unused event
{
    [self _invalidateForceTimer];
    
    if (_triggered)
        self.state = UIGestureRecognizerStateRecognized;
    else
        self.state = UIGestureRecognizerStateCancelled;
    
    _triggered = false;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    [self _invalidateForceTimer];
    
    self.state = UIGestureRecognizerStateFailed;
    
    _triggered = false;
}

- (void)reset
{
    _triggered = false;
    _ready = false;
}

#pragma mark - 

- (void)_startWithTouch:(UITouch *)touch
{
    if (_forceTimer == nil)
    {
        _forceTouch = touch;
        [self _startForceTimer];
    }
}

- (void)_updateWithTouch:(UITouch *)touch
{
    _forceTouch = touch;
    [self _maybeTriggerForceTouch];
}

#pragma mark -

- (void)_startForceTimer
{
    [self _invalidateForceTimer];
    _forceTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(_maybeTriggerForceTouch) interval:TGForceTouchDelay repeat:false];
}

- (void)_invalidateForceTimer
{
    [_forceTimer invalidate];
    _forceTimer = nil;
}

- (void)_maybeTriggerForceTouch
{
    if (self.isTriggered)
        return;
    
    _ready = true;
    
    if ([self _testForce])
        self.state = UIGestureRecognizerStateRecognized;
    
    [self _invalidateForceTimer];
}

- (bool)_testForce
{
    return (_forceTouch.force >= TGForceTouchTriggerPressureThreshold);
}

- (bool)forceTouchAvailable
{
    return (iosMajorVersion() >= 9 && self.view.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable);
}

@end
