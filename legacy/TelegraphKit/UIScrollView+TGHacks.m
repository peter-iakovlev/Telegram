#import "UIScrollView+TGHacks.h"

#import <objc/message.h>

@implementation UIScrollView (TGHacks)

- (void)stopScrollingAnimation
{
    UIView *superview = self.superview;
    NSUInteger index = [self.superview.subviews indexOfObject:self];
    [self removeFromSuperview];
    [superview insertSubview:self atIndex:index];
    
    /*static SEL selector = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        selector = NSSelectorFromString(TGEncodeText(@"`tupqTdspmmEfdfmfsbujpoOpujgz;", -1));
    });
    
    if (selector != NULL && [self respondsToSelector:selector])
    {
        objc_msgSend(self, selector, true);
    }*/
}

@end
