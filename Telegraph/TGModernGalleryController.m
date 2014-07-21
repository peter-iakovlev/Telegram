/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryController.h"

#import "TGHacks.h"

#import "TGModernGalleryView.h"

#import "TGModernGalleryItem.h"
#import "TGModernGalleryScrollView.h"
#import "TGModernGalleryItemView.h"

#import "TGModernGalleryInterfaceView.h"

#import "TGModernGalleryModel.h"

#import <pop/POP.h>

#define TGModernGalleryItemPadding 20.0f

@interface TGModernGalleryController () <UIScrollViewDelegate, TGModernGalleryScrollViewDelegate, TGModernGalleryItemViewDelegate>
{
    NSMutableDictionary *_reusableItemViewsByIdentifier;
    NSMutableArray *_visibleItemViews;
    
    TGModernGalleryView *_view;
    
    NSUInteger _lastReportedFocusedIndex;
    bool _synchronousBoundsChange;
    
    UIStatusBarStyle _statusBarStyle;
}

@end

@implementation TGModernGalleryController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.automaticallyManageScrollViewInsets = false;
        _lastReportedFocusedIndex = NSNotFound;
        _statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

- (void)dealloc
{
    _view.scrollView.delegate = nil;
    _view.scrollView.scrollDelegate = nil;
}

- (void)dismiss
{
    [super dismiss];
    
    if (_completedTransitionOut)
        _completedTransitionOut();
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _statusBarStyle;
}

- (BOOL)shouldAutorotate
{
    return [super shouldAutorotate] && [_view shouldAutorotate];
}

- (void)dismissWhenReady
{
    for (TGModernGalleryItemView *itemView in _visibleItemViews)
    {
        if (itemView.index == [self currentItemIndex])
        {
            if ([itemView dismissControllerNowOrSchedule])
                [self dismiss];
            
            return;
        }
    }
    
    [self dismiss];
}

- (void)setModel:(TGModernGalleryModel *)model
{
    if (_model != model)
    {
        _model = model;
        
        __weak TGModernGalleryController *weakSelf = self;
        _model.itemsUpdated = ^(id<TGModernGalleryItem> item)
        {
            __strong TGModernGalleryController *strongSelf = weakSelf;
            [strongSelf reloadDataAtItem:item synchronously:false];
        };
        
        _model.focusOnItem = ^(id<TGModernGalleryItem> item)
        {
            __strong TGModernGalleryController *strongSelf = weakSelf;
            NSUInteger index = [strongSelf.model.items indexOfObject:item];
            [strongSelf setCurrentItemIndex:index == NSNotFound ? 0 : index synchronously:false];
        };
        
        [self reloadDataAtItem:_model.focusItem synchronously:false];
    }
}

- (void)itemViewIsReadyForScheduledDismiss:(TGModernGalleryItemView *)__unused itemView
{
    [self dismiss];
}

- (void)itemViewDidRequestInterfaceShowHide:(TGModernGalleryItemView *)__unused itemView
{
    [_view showHideInterface];
}

- (TGModernGalleryItemView *)dequeueViewForItem:(id<TGModernGalleryItem>)item
{
    if (item == nil || [item viewClass] == nil)
        return nil;
    
    NSString *identifier = NSStringFromClass([item viewClass]);
    NSMutableArray *views = _reusableItemViewsByIdentifier[identifier];
    if (views == nil)
    {
        views = [[NSMutableArray alloc] init];
        _reusableItemViewsByIdentifier[identifier] = views;
    }
    
    if (views.count == 0)
    {
        Class itemClass = [item viewClass];
        TGModernGalleryItemView *itemView = [[itemClass alloc] init];
        itemView.delegate = self;
        itemView.defaultFooterView = [[(id)[_model defaultFooterViewClass] alloc] init];
        return itemView;
    }

    TGModernGalleryItemView *itemView = [views lastObject];
    [views removeLastObject];
    
    itemView.delegate = self;
    [itemView prepareForReuse];
    return itemView;
}

- (void)enqueueView:(TGModernGalleryItemView *)itemView
{
    if (itemView == nil)
        return;
    
    itemView.delegate = nil;
    [itemView prepareForRecycle];
    
    NSString *identifier = NSStringFromClass([itemView class]);
    if (identifier != nil)
    {
        NSMutableArray *views = _reusableItemViewsByIdentifier[identifier];
        if (views == nil)
        {
            views = [[NSMutableArray alloc] init];
            _reusableItemViewsByIdentifier[identifier] = views;
        }
        [views addObject:itemView];
    }
}

- (void)loadView
{
    [super loadView];
    
    _reusableItemViewsByIdentifier = [[NSMutableDictionary alloc] init];
    _visibleItemViews = [[NSMutableArray alloc] init];
    
    _view = [[TGModernGalleryView alloc] initWithFrame:self.view.bounds itemPadding:TGModernGalleryItemPadding];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_view];
    
    _view.scrollView.scrollDelegate = self;
    _view.scrollView.delegate = self;
    
    __weak TGModernGalleryController *weakSelf = self;
    _view.transitionOut = ^bool (CGFloat velocity)
    {
        __strong TGModernGalleryController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            UIView *transitionOutToView = nil;
            UIView *transitionOutFromView = nil;
            
            id<TGModernGalleryItem> focusItem = nil;
            if ([strongSelf currentItemIndex] < strongSelf.model.items.count)
                focusItem = strongSelf.model.items[[strongSelf currentItemIndex]];
            
            if (strongSelf.beginTransitionOut && focusItem != nil)
                transitionOutToView = strongSelf.beginTransitionOut(focusItem);
            if (transitionOutToView != nil)
            {
                for (TGModernGalleryItemView *itemView in strongSelf->_visibleItemViews)
                {
                    if ([itemView.item isEqual:focusItem])
                    {
                        transitionOutFromView = [itemView transitionView];
                        break;
                    }
                }
            }
            
            if (transitionOutFromView != nil && transitionOutToView != nil)
            {
                [strongSelf animateTransitionOutFromView:transitionOutFromView toView:transitionOutToView];
                [strongSelf->_view transitionOutWithDuration:0.2];
            }
            else
            {
                [strongSelf animateStatusBarTransition:0.2];
                strongSelf->_statusBarStyle = UIStatusBarStyleDefault;
                [strongSelf setNeedsStatusBarAppearanceUpdate];
                
                [strongSelf->_view simpleTransitionOutWithVelocity:velocity completion:^
                {
                    __strong TGModernGalleryController *strongSelf2 = weakSelf;
                    [strongSelf2 dismiss];
                }];
            }
        }
        return true;
    };
    
    [self reloadDataAtItem:_model.focusItem synchronously:true];
    
    UIView *transitionInFromView = nil;
    UIView *transitionInToView = nil;
    if (_beginTransitionIn && _model.focusItem != nil)
        transitionInFromView = _beginTransitionIn(_model.focusItem);
    if (transitionInFromView != nil)
    {
        for (TGModernGalleryItemView *itemView in _visibleItemViews)
        {
            if ([itemView.item isEqual:_model.focusItem])
            {
                transitionInToView = [itemView transitionView];
                break;
            }
        }
    }
    
    if (transitionInFromView != nil && transitionInToView != nil)
        [self animateTransitionInFromView:transitionInFromView toView:transitionInToView];
    
    [_view transitionInWithDuration:0.2];
    
    [self animateStatusBarTransition:0.2];
}

- (UIView *)findScrollView:(UIView *)view
{
    if (view == nil || [view isKindOfClass:[UIScrollView class]])
        return view;
    
    return [self findScrollView:view.superview];
}

- (void)animateTransitionInFromView:(UIView *)fromView toView:(UIView *)toView
{
    UIView *fromScrollView = [self findScrollView:fromView];
    UIView *fromContainerView = fromScrollView.superview;
    
    CGRect fromFrame = [toView.superview convertRect:[fromView convertRect:fromView.bounds toView:nil] fromView:nil];
    
    CGRect fromContainerFromFrame = [fromContainerView convertRect:fromView.bounds fromView:fromView];
    CGRect fromContainerFrame = [fromContainerView convertRect:[toView.superview convertRect:toView.frame toView:nil] fromView:nil];
    
    UIView *fromViewContainerCopy = [fromView snapshotViewAfterScreenUpdates:false];
    fromViewContainerCopy.frame = fromContainerFromFrame;
    [fromContainerView insertSubview:fromViewContainerCopy aboveSubview:fromScrollView];
    
    POPSpringAnimation *toViewAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    toViewAnimation.fromValue = [NSValue valueWithCGRect:fromFrame];
    toViewAnimation.toValue = [NSValue valueWithCGRect:toView.frame];
    toViewAnimation.springSpeed = 20;
    toViewAnimation.springBounciness = 8;
    [toView pop_addAnimation:toViewAnimation forKey:@"transitionInSpring"];
    
    POPSpringAnimation *fromContainerViewAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    fromContainerViewAnimation.fromValue = [NSValue valueWithCGRect:fromViewContainerCopy.frame];
    fromContainerViewAnimation.toValue = [NSValue valueWithCGRect:fromContainerFrame];
    fromContainerViewAnimation.springSpeed = 20;
    fromContainerViewAnimation.springBounciness = 8;
    __weak UIView *weakFromViewContainerCopy = fromViewContainerCopy;
    fromContainerViewAnimation.completionBlock = ^(__unused POPAnimation *animation, __unused BOOL finished)
    {
        __strong UIView *strongFromViewContainerCopy = weakFromViewContainerCopy;
        [strongFromViewContainerCopy removeFromSuperview];
    };
    [fromViewContainerCopy pop_addAnimation:fromContainerViewAnimation forKey:@"transitionInSpring"];
    
    toView.alpha = 0.0f;
    
    POPBasicAnimation *toViewAlphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    toViewAlphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    toViewAlphaAnimation.duration = 0.15;
    toViewAlphaAnimation.fromValue = @(0.0);
    toViewAlphaAnimation.toValue = @(1.0);
    [toView pop_addAnimation:toViewAlphaAnimation forKey:@"transitionInAlpha"];
}

- (void)animateTransitionOutFromView:(UIView *)fromView toView:(UIView *)toView
{
    UIView *toScrollView = [self findScrollView:toView];
    UIView *toContainerView = toScrollView.superview;
    
    CGRect toFrame = [fromView.superview convertRect:[toView convertRect:toView.bounds toView:nil] fromView:nil];
    
    CGRect toContainerFrame = [toContainerView convertRect:toView.bounds fromView:toView];
    CGRect toContainerFromFrame = [toContainerView convertRect:[fromView.superview convertRect:fromView.frame toView:nil] fromView:nil];
    
    POPSpringAnimation *fromViewAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    fromViewAnimation.fromValue = [NSValue valueWithCGRect:fromView.frame];
    fromViewAnimation.toValue = [NSValue valueWithCGRect:toFrame];
    fromViewAnimation.springSpeed = 20;
    fromViewAnimation.springBounciness = 5;
    __weak TGModernGalleryController *weakSelf = self;
    fromViewAnimation.completionBlock = ^(__unused POPAnimation *animation, __unused BOOL finished)
    {
        __strong TGModernGalleryController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf dismiss];
        }
    };
    [fromView pop_addAnimation:fromViewAnimation forKey:@"transitionOutSpring"];
    
    POPBasicAnimation *fromViewAlphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fromViewAlphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fromViewAlphaAnimation.duration = 0.15;
    fromViewAlphaAnimation.fromValue = @(1.0);
    fromViewAlphaAnimation.toValue = @(0.0);
    [fromView pop_addAnimation:fromViewAlphaAnimation forKey:@"transitionOutAlpha"];
    
    CGFloat toViewAlpha = toView.alpha;
    bool toViewHidden = toView.hidden;
    CGRect toViewFrame = toView.frame;
    toView.alpha = 1.0f;
    toView.hidden = false;
    toView.frame = CGRectOffset(toViewFrame, 1000.0f, 0.0f);
    UIView *toViewCopy = [toView snapshotViewAfterScreenUpdates:true];
    toView.alpha = toViewAlpha;
    toView.hidden = toViewHidden;
    toView.frame = toViewFrame;
    toViewCopy.frame = toContainerFromFrame;
    [toContainerView insertSubview:toViewCopy aboveSubview:toScrollView];
    
    POPSpringAnimation *toViewAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    toViewAnimation.fromValue = [NSValue valueWithCGRect:toViewCopy.frame];
    toViewAnimation.toValue = [NSValue valueWithCGRect:toContainerFrame];
    toViewAnimation.springSpeed = 20;
    toViewAnimation.springBounciness = 5;
    __weak UIView *weakToViewCopy = toViewCopy;
    toViewAnimation.completionBlock = ^(__unused POPAnimation *animation, __unused BOOL finished)
    {
        __strong UIView *strongToViewCopy = weakToViewCopy;
        [strongToViewCopy removeFromSuperview];
    };
    [toViewCopy pop_addAnimation:toViewAnimation forKey:@"transitionOutSpring"];
    
    if (iosMajorVersion() >= 7)
    {
        [self animateStatusBarTransition:0.2];
        self->_statusBarStyle = UIStatusBarStyleDefault;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[TGHacks setApplicationStatusBarAlpha:0.0f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [TGHacks setApplicationStatusBarAlpha:1.0f];
}

#pragma mark -

- (void)setCurrentItemIndex:(NSUInteger)currentItemIndex synchronously:(bool)synchronously
{
    _synchronousBoundsChange = synchronously;
    _view.scrollView.bounds = CGRectMake(_view.scrollView.bounds.size.width * currentItemIndex, 0.0f, _view.scrollView.bounds.size.width, _view.scrollView.bounds.size.height);
    _synchronousBoundsChange = false;
    
    //[self scrollViewBoundsChanged:_view.scrollView.bounds synchronously:synchronously];
}

- (NSUInteger)currentItemIndex
{
    return _model.items.count == 0 ? 0 : (NSUInteger)[self currentItemFuzzyIndex];
}

- (CGFloat)currentItemFuzzyIndex
{
    if (_model.items.count == 0)
        return 0.0f;
    
    return CGFloor((_view.scrollView.bounds.origin.x + _view.scrollView.bounds.size.width / 2.0f) / _view.scrollView.bounds.size.width);
}

- (void)reloadDataAtItem:(id<TGModernGalleryItem>)item synchronously:(bool)synchronously
{
    if (_visibleItemViews.count != 0)
    {
        for (TGModernGalleryItemView *itemView in _visibleItemViews)
        {
            UIView *itemHeaderView = [itemView headerView];
            if (itemHeaderView != nil)
                [_view removeItemHeaderView:itemHeaderView];
            
            UIView *itemDefaultFooterView = [itemView defaultFooterView];
            if (itemDefaultFooterView != nil)
                [_view removeItemFooterView:itemDefaultFooterView];
            
            UIView *itemFooterView = [itemView footerView];
            if (itemFooterView != nil)
                [_view removeItemFooterView:itemFooterView];
            [itemView removeFromSuperview];
            [self enqueueView:itemView];
        }
        [_visibleItemViews removeAllObjects];
    }
    
    NSUInteger index = (item == nil || _model.items == nil) ? NSNotFound : [_model.items indexOfObject:item];
    [self setCurrentItemIndex:index == NSNotFound ? 0 : index synchronously:synchronously];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)__unused scrollView
{
}

- (void)scrollViewBoundsChanged:(CGRect)bounds
{
    [self scrollViewBoundsChanged:bounds synchronously:_synchronousBoundsChange];
}

- (void)scrollViewBoundsChanged:(CGRect)bounds synchronously:(bool)synchronously
{
    if (_view == nil)
        return;
    
    CGFloat itemWidth = bounds.size.width;
    
    NSUInteger leftmostVisibleItemIndex = 0;
    if (bounds.origin.x > 0.0f)
        leftmostVisibleItemIndex = (NSUInteger)floor((bounds.origin.x + 1.0f) / itemWidth);
    
    NSUInteger rightmostVisibleItemIndex = _model.items.count - 1;
    if (bounds.origin.x + bounds.size.width < _model.items.count * itemWidth)
    {
        rightmostVisibleItemIndex = (NSUInteger)floorf((bounds.origin.x + bounds.size.width - 1.0f) / itemWidth);
    }
    
    if (leftmostVisibleItemIndex <= rightmostVisibleItemIndex && _model.items.count != 0)
    {
        CGSize contentSize = CGSizeMake(_model.items.count * itemWidth, bounds.size.height);
        if (!CGSizeEqualToSize(_view.scrollView.contentSize, contentSize))
            _view.scrollView.contentSize = contentSize;
        
        NSUInteger loadedVisibleViewIndices[16];
        NSUInteger loadedVisibleViewIndexCount = 0;
        
        NSUInteger visibleViewCount = _visibleItemViews.count;
        for (NSUInteger i = 0; i < visibleViewCount; i++)
        {
            TGModernGalleryItemView *itemView = _visibleItemViews[i];
            if (itemView.index < leftmostVisibleItemIndex || itemView.index > rightmostVisibleItemIndex)
            {
                UIView *itemHeaderView = [itemView headerView];
                if (itemHeaderView != nil)
                    [_view removeItemHeaderView:itemHeaderView];
                
                UIView *itemDefaultFooterView = [itemView defaultFooterView];
                if (itemDefaultFooterView != nil)
                    [_view removeItemFooterView:itemDefaultFooterView];
                
                UIView *itemFooterView = [itemView footerView];
                if (itemFooterView != nil)
                    [_view removeItemFooterView:itemFooterView];
                
                [self enqueueView:itemView];
                [itemView removeFromSuperview];
                [_visibleItemViews removeObjectAtIndex:i];
                i--;
                visibleViewCount--;
            }
            else
            {
                if (loadedVisibleViewIndexCount < 16)
                    loadedVisibleViewIndices[loadedVisibleViewIndexCount++] = itemView.index;
                
                CGRect itemFrame = CGRectMake(itemWidth * itemView.index + TGModernGalleryItemPadding, 0.0f, itemWidth - TGModernGalleryItemPadding * 2.0f, bounds.size.height);
                if (!CGRectEqualToRect(itemView.frame, itemFrame))
                    itemView.frame = itemFrame;
            }
        }
        
        for (NSUInteger i = leftmostVisibleItemIndex; i <= rightmostVisibleItemIndex; i++)
        {
            bool itemHasVisibleView = false;
            for (NSUInteger j = 0; j < loadedVisibleViewIndexCount; j++)
            {
                if (loadedVisibleViewIndices[j] == i)
                {
                    itemHasVisibleView = true;
                    break;
                }
            }
            
            if (!itemHasVisibleView)
            {
                id<TGModernGalleryItem> item = _model.items[i];
                TGModernGalleryItemView *itemView = [self dequeueViewForItem:item];
                if (itemView != nil)
                {
                    itemView.frame = CGRectMake(itemWidth * i + TGModernGalleryItemPadding, 0.0f, itemWidth - TGModernGalleryItemPadding * 2.0f, bounds.size.height);
                    [itemView setItem:item synchronously:synchronously];
                    itemView.index = i;
                    [_view.scrollView addSubview:itemView];
                    
                    UIView *headerView = [itemView headerView];
                    if (headerView != nil)
                        [_view addItemHeaderView:headerView];
                    
                    UIView *defaultFooterView = [itemView defaultFooterView];
                    if (defaultFooterView != nil)
                        [_view addItemFooterView:defaultFooterView];
                    
                    UIView *footerView = [itemView footerView];
                    if (footerView != nil)
                        [_view addItemFooterView:footerView];
                    [_visibleItemViews addObject:itemView];
                }
            }
        }
    }
    else if (_visibleItemViews.count != 0)
    {
        _view.scrollView.contentSize = CGSizeZero;
        
        for (TGModernGalleryItemView *itemView in _visibleItemViews)
        {
            UIView *itemHeaderView = [itemView headerView];
            if (itemHeaderView != nil)
                [_view removeItemHeaderView:itemHeaderView];
            
            UIView *defaultFooterView = [itemView defaultFooterView];
            if (defaultFooterView != nil)
                [_view removeItemFooterView:defaultFooterView];
            
            UIView *itemFooterView = [itemView footerView];
            if (itemFooterView != nil)
                [_view removeItemFooterView:itemFooterView];
            
            [itemView removeFromSuperview];
            [self enqueueView:itemView];
        }
        [_visibleItemViews removeAllObjects];
    }
    
    CGFloat fuzzyIndex = (_view.scrollView.bounds.origin.x) / _view.scrollView.bounds.size.width;
    CGFloat titleAlpha = 1.0f;
    for (TGModernGalleryItemView *itemView in _visibleItemViews)
    {
        CGFloat alpha = MAX(0.0f, MIN(1.0f, 1.0f - ABS(itemView.index - fuzzyIndex)));
        
        UIView *itemHeaderView = [itemView headerView];
        if (itemHeaderView != nil)
        {
            itemHeaderView.alpha = alpha;
            titleAlpha -= alpha;
        }
        
        UIView *itemDefaultFooterView = [itemView defaultFooterView];
        if (itemDefaultFooterView != nil)
            itemDefaultFooterView.alpha = alpha;
        
        UIView *itemFooterView = [itemView footerView];
        if (itemFooterView != nil)
            itemFooterView.alpha = alpha;
    }
    
    [_view.interfaceView setTitleAlpha:MAX(0.0f, MIN(1.0f, titleAlpha))];
    
    if (_lastReportedFocusedIndex != [self currentItemIndex])
    {
        _lastReportedFocusedIndex = [self currentItemIndex];
        
        if (_lastReportedFocusedIndex < _model.items.count)
        {
            if (_itemFocused)
                _itemFocused(_model.items[_lastReportedFocusedIndex]);
        }
        
        [_view.interfaceView setTitle:[[NSString alloc] initWithFormat:@"%d %@ %d", (int)_lastReportedFocusedIndex + 1, TGLocalized(@"Common.of"), (int)_model.items.count]];
    }
}

- (void)animateStatusBarTransition:(NSTimeInterval)duration
{
    if (iosMajorVersion() >= 7)
    {
        [TGHacks animateApplicationStatusBarStyleTransitionWithDuration:duration];
    }
}

@end
