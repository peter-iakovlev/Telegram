#import "TGMusicPlayerScrubbingArea.h"

@implementation TGMusicPlayerScrubbingArea

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
        if (_didBeginDragging)
            _didBeginDragging(touch);
        
        return true;
    }
    
    return false;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([super continueTrackingWithTouch:touch withEvent:event])
    {
        if (_willMove)
            _willMove(touch);
        
        return true;
    }
    
    return true;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_didFinishDragging)
        _didFinishDragging();
    
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    if (_didCancelDragging)
        _didCancelDragging();
    
    [super cancelTrackingWithEvent:event];
}

@end
