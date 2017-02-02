#import "TGDoubleTapGestureRecognizer.h"

#import "TGTimerTarget.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface TGDoubleTapGestureRecognizer () {
    CGPoint _touchLocation;
}

@property (nonatomic, strong) NSTimer *tapTimer;
@property (nonatomic, strong) NSTimer *longPressTimer;
@property (nonatomic) int currentTapCount;

@end

@implementation TGDoubleTapGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self != nil)
    {
    }
    return self;
}

- (void)failGesture
{
    if (_tapTimer != nil)
    {
        [_tapTimer invalidate];
        _tapTimer = nil;
    }
    
    if (_longPressTimer != nil)
    {
        [_longPressTimer invalidate];
        _longPressTimer = nil;
    }
    
    self.state = UIGestureRecognizerStateFailed;
    
    if ([self.delegate respondsToSelector:@selector(gestureRecognizerDidFail:)])
        [(id<TGDoubleTapGestureRecognizerDelegate>)self.delegate gestureRecognizerDidFail:self];
}

- (void)endGesture
{
    if (_tapTimer != nil)
    {
        [_tapTimer invalidate];
        _tapTimer = nil;
    }
    
    if (_longPressTimer != nil)
    {
        [_longPressTimer invalidate];
        _longPressTimer = nil;
    }
    
    self.state = UIGestureRecognizerStateRecognized;
}

- (void)reset
{
    if (_tapTimer != nil)
    {
        [_tapTimer invalidate];
        _tapTimer = nil;
    }
    
    if (_longPressTimer != nil)
    {
        [_longPressTimer invalidate];
        _longPressTimer = nil;
    }
    
    _currentTapCount = 0;
    
    _doubleTapped = false;
    _longTapped = false;
    
    [super reset];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_avoidControls)
    {
        for (UITouch *touch in [touches allObjects])
        {
            UIView *hitResult = [self.view hitTest:[touch locationInView:self.view] withEvent:event];
            if ([hitResult isKindOfClass:[UIControl class]])
            {
                [self failGesture];
                return;
            }
        }
    }
    
    _touchLocation = [(UITouch *)[touches anyObject] locationInView:[self view]];
    
    [super touchesBegan:touches withEvent:event];
    
    if ([self numberOfTouches] > 1)
    {
        [self failGesture];
        return;
    }
    
    if (_tapTimer != nil)
    {
        [_tapTimer invalidate];
        _tapTimer = nil;
    }
    
    if (_longPressTimer != nil)
    {
        [_longPressTimer invalidate];
        _longPressTimer = nil;
    }
    
    if (_currentTapCount == 0)
    {        
        _currentTapCount++;
        
        if ([self.delegate respondsToSelector:@selector(gestureRecognizer:didBeginAtPoint:)])
        {
            [(id<TGDoubleTapGestureRecognizerDelegate>)self.delegate gestureRecognizer:self didBeginAtPoint:[[touches anyObject] locationInView:self.view]];
        }
        
        _longPressTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(longTapEvent) interval:0.4 repeat:false];
    }
    else if (_currentTapCount >= 1)
    {
        _doubleTapped = true;
        
        [self endGesture];
    }
}

- (void)touchesMoved:(NSSet *)__unused touches withEvent:(UIEvent *)__unused event
{
    CGPoint location = [(UITouch *)[touches anyObject] locationInView:[self view]];
    CGPoint distance = CGPointMake(location.x - _touchLocation.x, location.y - _touchLocation.y);
    if (distance.x * distance.x + distance.y * distance.y > 4.0 * 4.0) {
    
        if ([self.delegate respondsToSelector:@selector(gestureRecognizerShouldFailOnMove:)])
        {
            if (![(id<TGDoubleTapGestureRecognizerDelegate>)self.delegate gestureRecognizerShouldFailOnMove:self])
                return;
        }
        
        [self failGesture];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_currentTapCount == 1)
    {
        UITouch *touch = [touches anyObject];
        int failTapType = 0;
        if ([self.delegate conformsToProtocol:@protocol(TGDoubleTapGestureRecognizerDelegate)] && (failTapType = [(id<TGDoubleTapGestureRecognizerDelegate>)self.delegate gestureRecognizer:self shouldFailTap:[touch locationInView:self.view]]))
        {
            _doubleTapped = false;
            if ((_consumeSingleTap && failTapType != 2) || failTapType == 3)
                [self endGesture];
            else
                [self failGesture];
        }
        else
        {
            _tapTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(tapTimerEvent) interval:0.2 repeat:false];
        }
    }
    
    [super touchesEnded:touches withEvent:event];
}

- (void)tapTimerEvent
{
    _tapTimer = nil;
    
    _doubleTapped = false;
    
    if ([self.delegate conformsToProtocol:@protocol(TGDoubleTapGestureRecognizerDelegate)] && [self.delegate respondsToSelector:@selector(doubleTapGestureRecognizerSingleTapped:)])
    {
        [(id<TGDoubleTapGestureRecognizerDelegate>)self.delegate doubleTapGestureRecognizerSingleTapped:self];
    }
    
    if (_consumeSingleTap)
        [self endGesture];
    else
        [self failGesture];
}

- (void)longTapEvent
{
    _longPressTimer = nil;
    
    if ([self.delegate respondsToSelector:@selector(gestureRecognizerShouldHandleLongTap:)])
    {
        if ([(id<TGDoubleTapGestureRecognizerDelegate>)self.delegate gestureRecognizerShouldHandleLongTap:self])
        {
            _longTapped = true;
            
            [self endGesture];
        }
    }
}

- (bool)canScrollViewStealTouches
{
    if ([self.delegate respondsToSelector:@selector(gestureRecognizerShouldLetScrollViewStealTouches:)])
    {
        if ([(id<TGDoubleTapGestureRecognizerDelegate>)self.delegate gestureRecognizerShouldLetScrollViewStealTouches:self])
            return true;
        else
            return false;
    }
    
    return true;
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesCancelled:touches withEvent:event];
    
    [self failGesture];
}

@end
