/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioSliderArea.h"

@implementation TGAudioSliderArea

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.exclusiveTouch = true;
        
        static UIImage *emptyImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(2.0f, 2.0f), false, 0.0f);
            emptyImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        [self setMinimumTrackImage:emptyImage forState:UIControlStateNormal];
        [self setMaximumTrackImage:emptyImage forState:UIControlStateNormal];
        [self setThumbImage:emptyImage forState:UIControlStateNormal];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)__unused event
{
    bool result = CGRectContainsPoint(CGRectInset(self.bounds, -20, -10), point);
    return result;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)__unused rect value:(float)__unused value
{
    return bounds;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([super beginTrackingWithTouch:touch withEvent:event])
    {
        id<TGAudioSliderAreaDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(audioSliderDidBeginDragging:withTouch:)])
            [delegate audioSliderDidBeginDragging:self withTouch:touch];
        
        return true;
    }
    
    return false;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([super continueTrackingWithTouch:touch withEvent:event])
    {
        id<TGAudioSliderAreaDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(audioSliderWillMove:withTouch:)])
            [delegate audioSliderWillMove:self withTouch:touch];
        
        return true;
    }
    
    return true;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    id<TGAudioSliderAreaDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioSliderDidFinishDragging:)])
        [delegate audioSliderDidFinishDragging:self];
    
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    id<TGAudioSliderAreaDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioSliderDidCancelDragging:)])
        [delegate audioSliderDidCancelDragging:self];
    
    [super cancelTrackingWithEvent:event];
}

@end
