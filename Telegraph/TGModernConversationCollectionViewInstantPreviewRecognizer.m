/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationCollectionViewInstantPreviewRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface TGModernConversationCollectionViewInstantPreviewRecognizer ()
{
    CGPoint _touchLocation;
    bool _alreadyBegan;
}

@end

@implementation TGModernConversationCollectionViewInstantPreviewRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self != nil)
    {
        self.cancelsTouchesInView = false;
    }
    return self;
}

- (void)reset
{
    [super reset];
    _alreadyBegan = false;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (_alreadyBegan)
    {
        self.state = UIGestureRecognizerStateCancelled;
        
        id<TGModernConversationCollectionViewInstantPreviewRecognizerDelegate> delegate = (id<TGModernConversationCollectionViewInstantPreviewRecognizerDelegate>)self.delegate;
        if ([delegate respondsToSelector:@selector(instantPreviewGestureDidEnd)])
            [delegate instantPreviewGestureDidEnd];
    }
    else
    {
        UITouch *touch = [touches anyObject];
        _touchLocation = [touch locationInView:self.view];
        
        self.state = UIGestureRecognizerStateBegan;
        
        id<TGModernConversationCollectionViewInstantPreviewRecognizerDelegate> delegate = (id<TGModernConversationCollectionViewInstantPreviewRecognizerDelegate>)self.delegate;
        if ([delegate respondsToSelector:@selector(instantPreviewGestureDidBegin)])
            [delegate instantPreviewGestureDidBegin];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{   
    [super touchesEnded:touches withEvent:event];
    
    id<TGModernConversationCollectionViewInstantPreviewRecognizerDelegate> delegate = (id<TGModernConversationCollectionViewInstantPreviewRecognizerDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(instantPreviewGestureDidEnd)])
        [delegate instantPreviewGestureDidEnd];
    
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    id<TGModernConversationCollectionViewInstantPreviewRecognizerDelegate> delegate = (id<TGModernConversationCollectionViewInstantPreviewRecognizerDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(instantPreviewGestureDidEnd)])
        [delegate instantPreviewGestureDidEnd];
    
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self.view];
    
    CGPoint difference = CGPointMake(currentLocation.x - _touchLocation.x, currentLocation.y - _touchLocation.y);
    if (difference.x * difference.x + difference.y * difference.y > 2.0f * 2.0f)
    {
        id<TGModernConversationCollectionViewInstantPreviewRecognizerDelegate> delegate = (id<TGModernConversationCollectionViewInstantPreviewRecognizerDelegate>)self.delegate;
        if ([delegate respondsToSelector:@selector(instantPreviewGestureDidMove)])
            [delegate instantPreviewGestureDidMove];
    }
}

@end
