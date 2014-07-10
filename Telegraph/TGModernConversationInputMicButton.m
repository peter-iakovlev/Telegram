/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationInputMicButton.h"

@interface TGModernConversationInputMicButton ()
{
    CGPoint _touchLocation;
    UIPanGestureRecognizer *_panRecognizer;
    
    CGFloat _lastVelocity;
    
    bool _processCurrentTouch;
    CFAbsoluteTime _lastTouchTime;
}

@end

@implementation TGModernConversationInputMicButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.exclusiveTouch = true;
        self.multipleTouchEnabled = false;
        
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        _panRecognizer.cancelsTouchesInView = false;
        [self addGestureRecognizer:_panRecognizer];
    }
    return self;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([super beginTrackingWithTouch:touch withEvent:event])
    {
        _lastVelocity = 0.0;
        
        if (ABS(CFAbsoluteTimeGetCurrent() - _lastTouchTime) < 1.0)
        {
            _processCurrentTouch = false;
            
            return false;
        }
        else
        {
            _processCurrentTouch = true;
            _lastTouchTime = CFAbsoluteTimeGetCurrent();
        
            id<TGModernConversationInputMicButtonDelegate> delegate = _delegate;
            if ([delegate respondsToSelector:@selector(micButtonInteractionBegan)])
                [delegate micButtonInteractionBegan];
            
            _touchLocation = [touch locationInView:self];
        }
        
        return true;
    }
    
    return false;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([super continueTrackingWithTouch:touch withEvent:event])
    {
        _lastVelocity = [_panRecognizer velocityInView:self].x;
        
        if (_processCurrentTouch)
        {
            CGFloat distance = [touch locationInView:self].x - _touchLocation.x;
            
            float value = (-distance) / 100.0f;
            value = MAX(0.0f, MIN(1.0f, value));
            
            CGFloat velocity = [_panRecognizer velocityInView:self].x;
            
            if (distance < -100.0f)
            {
                id<TGModernConversationInputMicButtonDelegate> delegate = _delegate;
                if ([delegate respondsToSelector:@selector(micButtonInteractionCancelled:)])
                    [delegate micButtonInteractionCancelled:velocity];
                
                return false;
            }
            
            id<TGModernConversationInputMicButtonDelegate> delegate = _delegate;
            if ([delegate respondsToSelector:@selector(micButtonInteractionUpdate:)])
                [delegate micButtonInteractionUpdate:value];
        
            return true;
        }
    }
    
    return false;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    if (_processCurrentTouch)
    {
        id<TGModernConversationInputMicButtonDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(micButtonInteractionCancelled:)])
            [delegate micButtonInteractionCancelled:_lastVelocity];
    }
    
    [super cancelTrackingWithEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_processCurrentTouch)
    {
        CGFloat velocity = _lastVelocity;
        
        id<TGModernConversationInputMicButtonDelegate> delegate = _delegate;
        if (velocity < -400.0f)
        {
            if ([delegate respondsToSelector:@selector(micButtonInteractionCancelled:)])
                [delegate micButtonInteractionCancelled:_lastVelocity];
        }
        else
        {
            if ([delegate respondsToSelector:@selector(micButtonInteractionCompleted:)])
                [delegate micButtonInteractionCompleted:_lastVelocity];
        }
    }
    
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)panGesture:(UIPanGestureRecognizer *)__unused recognizer
{
}

@end
