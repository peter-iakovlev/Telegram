#import "TGModernGalleryView.h"

#import "TGModernGalleryDefaultInterfaceView.h"
#import "TGModernGalleryScrollView.h"

#import "TGModernGalleryZoomableScrollViewSwipeGestureRecognizer.h"

#import "TGHacks.h"

#import <pop/POP.h>

static const CGFloat swipeMinimumVelocity = 600.0f;
static const CGFloat swipeVelocityThreshold = 700.0f;
static const CGFloat swipeDistanceThreshold = 128.0f;

@interface TGModernGalleryView () <UIGestureRecognizerDelegate>
{
    CGFloat _itemPadding;
    
    UIView *_scrollViewContainer;
    CGFloat _dismissProgress;
}

@end

@implementation TGModernGalleryView

- (instancetype)initWithFrame:(CGRect)__unused frame
{
    NSAssert(false, @"use designated initializer");
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame itemPadding:(CGFloat)itemPadding interfaceView:(UIView<TGModernGalleryInterfaceView> *)interfaceView
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _itemPadding = itemPadding;
        
        self.opaque = false;
        self.backgroundColor = UIColorRGBA(0x000000, 1.0f);
        
        _scrollViewContainer = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        [self addSubview:_scrollViewContainer];
        
        _scrollView = [[TGModernGalleryScrollView alloc] initWithFrame:CGRectMake(-_itemPadding, 0.0f, frame.size.width + itemPadding * 2.0f, frame.size.height)];
        [_scrollViewContainer addSubview:_scrollView];
        
        _interfaceView = interfaceView;
        _interfaceView.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        __weak TGModernGalleryView *weakSelf = self;
        _interfaceView.closePressed = ^
        {
            __strong TGModernGalleryView *strongSelf = weakSelf;
            if (strongSelf.transitionOut)
                strongSelf.transitionOut(0.0f);
        };
        [self addSubview:_interfaceView];
        
        bool hasSwipeGesture = true;
        if ([interfaceView respondsToSelector:@selector(allowsDismissalWithSwipeGesture)])
            hasSwipeGesture = [interfaceView allowsDismissalWithSwipeGesture];
        
        if (hasSwipeGesture)
        {
            TGModernGalleryZoomableScrollViewSwipeGestureRecognizer *swipeRecognizer = [[TGModernGalleryZoomableScrollViewSwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
            swipeRecognizer.delegate = self;
            swipeRecognizer.delaysTouchesBegan = true;
            swipeRecognizer.cancelsTouchesInView = false;
            [_scrollViewContainer addGestureRecognizer:swipeRecognizer];
        }
    }
    return self;
}

- (bool)shouldAutorotate
{
    return (_dismissProgress < FLT_EPSILON && (_interfaceView == nil || ![_interfaceView respondsToSelector:@selector(shouldAutorotate)] || [_interfaceView shouldAutorotate]));
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _interfaceView.frame = (CGRect){CGPointZero, frame.size};
    _scrollViewContainer.frame = (CGRect){CGPointZero, frame.size};
    
    CGRect scrollViewFrame = CGRectMake(-_itemPadding, _scrollView.frame.origin.y, frame.size.width + _itemPadding * 2.0f, frame.size.height);
    if (!CGRectEqualToRect(_scrollView.frame, scrollViewFrame))
    {
        NSInteger currentItemIndex = (NSInteger)(CGFloor((_scrollView.bounds.origin.x + _scrollView.bounds.size.width / 2.0f) / _scrollView.bounds.size.width));
        [_scrollView setFrameAndBoundsInTransaction:scrollViewFrame bounds:CGRectMake(currentItemIndex * scrollViewFrame.size.width, 0.0f, scrollViewFrame.size.width, scrollViewFrame.size.height)];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)showHideInterface
{
    if ([_interfaceView allowsHide])
    {
        if (_interfaceView.alpha > FLT_EPSILON)
        {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                _interfaceView.alpha = 0.0f;
                [TGHacks setApplicationStatusBarAlpha:0.0f];
            } completion:nil];
        }
        else
        {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                _interfaceView.alpha = 1.0f;
                if (![_interfaceView prefersStatusBarHidden])
                    [TGHacks setApplicationStatusBarAlpha:1.0f];
            } completion:nil];
        }
    }
}

- (void)showInterfaceAnimated
{
    if ([_interfaceView allowsHide])
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _interfaceView.alpha = 1.0f;
            if (![_interfaceView prefersStatusBarHidden])
                [TGHacks setApplicationStatusBarAlpha:1.0f];
        } completion:nil];
    }
}

- (void)hideInterfaceAnimated
{
    if ([_interfaceView allowsHide])
    {
        if (_interfaceView.alpha > FLT_EPSILON)
        {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                _interfaceView.alpha = 0.0f;
                [TGHacks setApplicationStatusBarAlpha:0.0f];
            } completion:nil];
        }
    }
}

- (void)updateInterfaceVisibility
{
    if ([_interfaceView allowsHide])
    {
        bool showsOnScroll = false;
        if ([_interfaceView respondsToSelector:@selector(showHiddenInterfaceOnScroll)])
            showsOnScroll = [_interfaceView showHiddenInterfaceOnScroll];
        
        if (showsOnScroll)
            [self showInterfaceAnimated];
    }
}

- (void)addItemHeaderView:(UIView *)itemHeaderView
{
    [_interfaceView addItemHeaderView:itemHeaderView];
}

- (void)removeItemHeaderView:(UIView *)itemHeaderView
{
    [_interfaceView removeItemHeaderView:itemHeaderView];
}

- (void)addItemFooterView:(UIView *)itemFooterView
{
    [_interfaceView addItemFooterView:itemFooterView];
}

- (void)removeItemFooterView:(UIView *)itemFooterView
{
    [_interfaceView removeItemFooterView:itemFooterView];
}

- (BOOL)gestureRecognizerShouldBegin1:(UIGestureRecognizer *)__unused gestureRecognizer
{
    return true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    return false;
}

- (CGFloat)dismissProgressForSwipeDistance:(CGFloat)distance
{
    return MAX(0.0f, MIN(1.0f, ABS(distance / 150.0f)));
}

- (void)swipeGesture:(TGModernGalleryZoomableScrollViewSwipeGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        _dismissProgress = [self dismissProgressForSwipeDistance:[recognizer swipeDistance]];
        [self _updateDismissTransitionWithProgress:_dismissProgress animated:false];
        [self _updateDismissTransitionMovementWithDistance:[recognizer swipeDistance] animated:false];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGFloat swipeVelocity = [recognizer swipeVelocity];
        if (ABS(swipeVelocity) < swipeMinimumVelocity)
            swipeVelocity = (swipeVelocity < 0.0f ? -1.0f : 1.0f) * swipeMinimumVelocity;
        
        if ((ABS(swipeVelocity) < swipeVelocityThreshold && ABS([recognizer swipeDistance]) < swipeDistanceThreshold) ||  !_transitionOut || !_transitionOut(swipeVelocity))
        {
            _dismissProgress = 0.0f;
            [self _updateDismissTransitionWithProgress:0.0f animated:true];
            [self _updateDismissTransitionMovementWithDistance:0.0f animated:true];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled)
    {
        _dismissProgress = 0.0f;
        [self _updateDismissTransitionWithProgress:0.0f animated:true];
        [self _updateDismissTransitionMovementWithDistance:0.0f animated:true];
    }
}

- (void)_updateDismissTransitionMovementWithDistance:(CGFloat)distance animated:(bool)animated
{
    CGRect scrollViewFrame = (CGRect){{_scrollView.frame.origin.x, distance}, _scrollView.frame.size};
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            _scrollView.frame = scrollViewFrame;
        }];
    }
    else
        _scrollView.frame = scrollViewFrame;
}

- (void)_updateDismissTransitionWithProgress:(CGFloat)progress animated:(bool)animated
{
    CGFloat alpha = 1.0f - MAX(0.0f, MIN(1.0f, progress * 4.0f));
    CGFloat transitionProgress = MAX(0.0f, MIN(1.0f, progress * 2.0f));
    UIColor *backgroundColor = UIColorRGBA(0x000000, alpha);
    
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            self.backgroundColor = backgroundColor;
            [_interfaceView setTransitionOutProgress:transitionProgress];
        }];
    }
    else
    {
        self.backgroundColor = backgroundColor;
        [_interfaceView setTransitionOutProgress:transitionProgress];
    }
}

- (void)simpleTransitionOutWithVelocity:(CGFloat)velocity completion:(void (^)())completion
{
    const CGFloat minVelocity = 2000.0f;
    if (ABS(velocity) < minVelocity)
        velocity = (velocity < 0.0f ? -1.0f : 1.0f) * minVelocity;
    CGFloat distance = (velocity < FLT_EPSILON ? -1.0f : 1.0f) * self.frame.size.height;
    CGRect scrollViewFrame = (CGRect){{_scrollView.frame.origin.x, distance}, _scrollView.frame.size};
    
    [UIView animateWithDuration:ABS(distance / velocity) animations:^
    {
        _scrollView.frame = scrollViewFrame;
        _interfaceView.alpha = 0.0f;
        self.backgroundColor = UIColorRGBA(0x000000, 0.0f);
    } completion:^(__unused BOOL finished)
    {
        if (completion)
            completion();
    }];
}

- (void)transitionInWithDuration:(NSTimeInterval)duration
{
    _interfaceView.alpha = 0.0f;
    self.backgroundColor = UIColorRGBA(0x000000, 0.0f);
    [UIView animateWithDuration:duration delay:0.05 options:0 animations:^
    {
        _interfaceView.alpha = 1.0f;
        self.backgroundColor = UIColorRGBA(0x000000, 1.0f);
    } completion:nil];
}

- (void)transitionOutWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^
    {
        _interfaceView.alpha = 0.0f;
        self.backgroundColor = UIColorRGBA(0x000000, 0.0f);
    }];
}

- (void)fadeOutWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    [UIView animateWithDuration:duration animations:^
    {
        _interfaceView.alpha = 0.0f;
        _scrollView.alpha = 0.0f;
        self.backgroundColor = UIColorRGBA(0x000000, 0.0f);
    } completion:^(__unused BOOL finished)
    {
        if (completion)
            completion();
    }];
}

@end
