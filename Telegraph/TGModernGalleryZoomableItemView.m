/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryZoomableItemView.h"

#import "TGModernGalleryZoomableScrollView.h"
#import "TGHacks.h"

#import <pop/POP.h>

@interface TGModernGalleryZoomableItemView () <UIScrollViewDelegate>

@end

@implementation TGModernGalleryZoomableItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _scrollView = [[TGModernGalleryZoomableScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.clipsToBounds = false;
        [self addSubview:_scrollView];
        
        __weak TGModernGalleryZoomableItemView *weakSelf = self;
        
        _scrollView.singleTapped = ^
        {
            __strong TGModernGalleryZoomableItemView *strongSelf = weakSelf;
            [strongSelf singleTap];
        };
        
        _scrollView.doubleTapped = ^
        {
            __strong TGModernGalleryZoomableItemView *strongSelf = weakSelf;
            [strongSelf doubleTap];
        };
    }
    return self;
}

- (void)dealloc
{
    _scrollView.delegate = nil;
}

- (void)prepareForReuse
{
}

- (CGSize)contentSize
{
    return CGSizeZero;
}

- (UIView *)contentView
{
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)__unused scrollView withView:(UIView *)__unused view
{
}

- (void)scrollViewDidZoom:(UIScrollView *)__unused scrollView
{
    [self adjustZoom];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)__unused scrollView withView:(UIView *)__unused view atScale:(float)__unused scale
{
    [self adjustZoom];
    
    if (_scrollView.zoomScale < _scrollView.normalZoomScale - FLT_EPSILON)
    {
        [TGHacks setAnimationDurationFactor:0.5f];
        [_scrollView setZoomScale:_scrollView.normalZoomScale animated:true];
        [TGHacks setAnimationDurationFactor:1.0f];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)__unused scrollView
{
    return [self contentView];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGSize contentSize = [self contentSize];
    if (!CGSizeEqualToSize(_scrollView.contentSize, contentSize) || !CGSizeEqualToSize(frame.size, _scrollView.frame.size))
    {
        _scrollView.minimumZoomScale = 1.0f;
        _scrollView.maximumZoomScale = 1.0f;
        _scrollView.normalZoomScale = 1.0f;
        _scrollView.zoomScale = 1.0f;
        _scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _scrollView.contentSize = contentSize;
        [self contentView].frame = CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height);
        
        [self adjustZoom];
        _scrollView.zoomScale = _scrollView.normalZoomScale;
    }
}

- (void)reset
{
    CGSize contentSize = [self contentSize];
    
    _scrollView.minimumZoomScale = 1.0f;
    _scrollView.maximumZoomScale = 1.0f;
    _scrollView.normalZoomScale = 1.0f;
    _scrollView.zoomScale = 1.0f;
    _scrollView.contentSize = contentSize;
    [self contentView].frame = CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height);
    
    [self adjustZoom];
    _scrollView.zoomScale = _scrollView.normalZoomScale;
}

- (void)adjustZoom
{
    CGSize contentSize = [self contentSize];
    CGSize boundsSize = _scrollView.frame.size;
    if (contentSize.width < FLT_EPSILON || contentSize.height < FLT_EPSILON || boundsSize.width < FLT_EPSILON || boundsSize.height < FLT_EPSILON)
        return;
    
    CGFloat scaleWidth = boundsSize.width / contentSize.width;
    CGFloat scaleHeight = boundsSize.height / contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    CGFloat maxScale = MAX(scaleWidth, scaleHeight);
    
    if (ABS(maxScale - minScale) < 0.01f)
        maxScale = minScale;

    if (_scrollView.minimumZoomScale != 0.05f)
        _scrollView.minimumZoomScale = 0.05f;
    if (_scrollView.normalZoomScale != minScale)
        _scrollView.normalZoomScale = minScale;
    if (_scrollView.maximumZoomScale != maxScale)
        _scrollView.maximumZoomScale = maxScale;

    CGRect contentFrame = [self contentView].frame;
    
    if (boundsSize.width > contentFrame.size.width)
        contentFrame.origin.x = (boundsSize.width - contentFrame.size.width) / 2.0f;
    else
        contentFrame.origin.x = 0;
    
    if (boundsSize.height > contentFrame.size.height)
        contentFrame.origin.y = (boundsSize.height - contentFrame.size.height) / 2.0f;
    else
        contentFrame.origin.y = 0;
    
    [self contentView].frame = contentFrame;
    
#warning TODO adjusted to bounds, disable scrolling
}

- (void)singleTap
{
    id<TGModernGalleryItemViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(itemViewDidRequestInterfaceShowHide:)])
        [delegate itemViewDidRequestInterfaceShowHide:self];
}

- (void)doubleTap
{
}

@end
