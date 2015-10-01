/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryScrollView.h"

@interface TGModernGalleryScrollView ()
{
    bool _suspendBoundsUpdates;
}

@end

@implementation TGModernGalleryScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.showsHorizontalScrollIndicator = false;
        self.showsVerticalScrollIndicator = false;
        self.pagingEnabled = true;
        self.clipsToBounds = false;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    bool shouldScroll = true;
    id<TGModernGalleryScrollViewDelegate> delegate = self.scrollDelegate;
    if ([delegate respondsToSelector:@selector(scrollViewShouldScrollWithTouchAtPoint:)])
        shouldScroll = [delegate scrollViewShouldScrollWithTouchAtPoint:point];
    
    self.scrollEnabled = shouldScroll;
    
    return view;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    if (!_suspendBoundsUpdates)
    {
        id<TGModernGalleryScrollViewDelegate> scrollDelegate = _scrollDelegate;
        [scrollDelegate scrollViewBoundsChanged:bounds];
    }
}

- (void)setFrameAndBoundsInTransaction:(CGRect)frame bounds:(CGRect)bounds
{
    _suspendBoundsUpdates = true;
    self.frame = frame;
    self.bounds = bounds;
    _suspendBoundsUpdates = false;
    
    id<TGModernGalleryScrollViewDelegate> scrollDelegate = _scrollDelegate;
    [scrollDelegate scrollViewBoundsChanged:bounds];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
