/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGEditingScrollViewGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface TGEditingScrollViewGestureRecognizer ()
{
    CGPoint _touchLocation;
    bool _ignoreTouches;
}

@end

@implementation TGEditingScrollViewGestureRecognizer

- (void)reset
{
    [super reset];
    
    _ignoreTouches = false;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    _touchLocation = [touch locationInView:[self view]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (!_ignoreTouches)
    {
        CGFloat contentOffsetX = ((UIScrollView *)self.view).contentOffset.x;
        if (contentOffsetX > FLT_EPSILON)
            self.state = UIGestureRecognizerStateFailed;
        
        UITouch *touch = [touches anyObject];
        CGPoint currentTouchLocation = [touch locationInView:[self view]];
        if (currentTouchLocation.x > _touchLocation.x + FLT_EPSILON)
            _ignoreTouches = true;
        else if (currentTouchLocation.x < _touchLocation.x - FLT_EPSILON)
        {
            self.state = UIGestureRecognizerStateFailed;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    self.state = UIGestureRecognizerStateEnded;
}

@end
