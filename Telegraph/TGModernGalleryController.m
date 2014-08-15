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

#import "TGModernGalleryContainerView.h"
#import "TGModernGalleryInterfaceView.h"

#import "TGModernGalleryModel.h"

#import <pop/POP.h>

#import <objc/runtime.h>

#define TGModernGalleryItemPadding 20.0f

@interface TGModernGalleryController () <UIScrollViewDelegate, TGModernGalleryScrollViewDelegate, TGModernGalleryItemViewDelegate>
{
    NSMutableDictionary *_reusableItemViewsByIdentifier;
    NSMutableArray *_visibleItemViews;
    bool _preloadVisibleItemViews;
    
    TGModernGalleryView *_view;
    UIView<TGModernGalleryDefaultHeaderView> *_defaultHeaderView;
    
    NSUInteger _lastReportedFocusedIndex;
    bool _synchronousBoundsChange;
    bool _reloadingItems;
    
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
        
        _model.actionSheetView = ^
        {
            __strong TGModernGalleryController *strongSelf = weakSelf;
            return strongSelf.view;
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
        itemView.defaultFooterView = [_model createDefaultFooterView];
        itemView.defaultFooterAccessoryLeftView = [_model createDefaultLeftAccessoryView];
        itemView.defaultFooterAccessoryRightView = [_model createDefaultRightAccessoryView];
        
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
    object_setClass(self.view, [TGModernGalleryContainerView class]);
    
    self.view.frame = (CGRect){self.view.frame.origin, [self referenceViewSizeForOrientation:self.interfaceOrientation]};
    
    _reusableItemViewsByIdentifier = [[NSMutableDictionary alloc] init];
    _visibleItemViews = [[NSMutableArray alloc] init];
    
    _view = [[TGModernGalleryView alloc] initWithFrame:self.view.bounds itemPadding:TGModernGalleryItemPadding];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_view];
    
    _defaultHeaderView = [_model createDefaultHeaderView];
    if (_defaultHeaderView != nil)
        [_view addItemHeaderView:_defaultHeaderView];
    
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
                [strongSelf->_view.interfaceView animateTransitionOutWithDuration:0.2];
            }
            else
            {
                [strongSelf animateStatusBarTransition:0.2];
                strongSelf->_statusBarStyle = UIStatusBarStyleDefault;
                [strongSelf setNeedsStatusBarAppearanceUpdate];
                
                [UIView animateWithDuration:0.2 animations:^
                {
                    [TGHacks setApplicationStatusBarAlpha:1.0f];
                }];
                
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
    {
        TGModernGalleryItemView *itemView = nil;
        for (TGModernGalleryItemView *visibleItemView in self->_visibleItemViews)
        {
            if ([visibleItemView.item isEqual:self.model.focusItem])
            {
                itemView = visibleItemView;
                
                break;
            }
        }
        
        transitionInFromView = _beginTransitionIn(_model.focusItem, itemView);
    }
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
    else if (_finishedTransitionIn && _model.focusItem != nil)
    {
        TGModernGalleryItemView *itemView = nil;
        if (self.finishedTransitionIn && self.model.focusItem != nil)
        {
            for (TGModernGalleryItemView *visibleItemView in self->_visibleItemViews)
            {
                if ([visibleItemView.item isEqual:self.model.focusItem])
                {
                    itemView = visibleItemView;
                    
                    break;
                }
            }
        }
        
        _finishedTransitionIn(_model.focusItem, itemView);
        
        [_model _transitionCompleted];
    }
    else
        [_model _transitionCompleted];
    
    [_view transitionInWithDuration:0.2];
    
    [self animateStatusBarTransition:0.2];
}

- (UIView *)findScrollView:(UIView *)view
{
    if (view == nil || [view isKindOfClass:[UIScrollView class]])
        return view;
    
    return [self findScrollView:view.superview];
}

- (UIView *)topSuperviewOfView:(UIView *)view
{
    if (view.superview == nil)
        return view;
    
    return [self topSuperviewOfView:view.superview];
}

- (UIView *)findCommonSuperviewOfView:(UIView *)view andView:(UIView *)andView
{
    UIView *leftSuperview = [self topSuperviewOfView:view];
    UIView *rightSuperview = [self topSuperviewOfView:andView];
    
    if (leftSuperview != rightSuperview)
        return nil;
    
    return leftSuperview;
}

- (UIView *)subviewOfView:(UIView *)view containingView:(UIView *)containingView
{
    if (view == containingView)
        return view;
    
    for (UIView *subview in view.subviews)
    {
        if ([self subviewOfView:subview containingView:containingView] != nil)
            return subview;
    }
    
    return nil;
}

- (CGRect)convertFrameOfView:(UIView *)view toView:(UIView *)toView outRotationZ:(CGFloat *)outRotationZ
{
    if (view == toView)
        return view.bounds;
    
    CGFloat sourceWindowRotation = 0.0f;
    
    CGRect frame = (CGRect){CGPointZero, view.frame.size};
    UIView *currentView = view;
    while (currentView != nil)
    {
        frame.origin.x += currentView.frame.origin.x - currentView.bounds.origin.x;
        frame.origin.y += currentView.frame.origin.y - currentView.bounds.origin.y;
        
        CGFloat rotation = transformRotation(currentView.transform);
        if (ABS(rotation) > FLT_EPSILON)
        {
            CGAffineTransform transform = CGAffineTransformMakeTranslation(currentView.bounds.size.width / 2.0f, currentView.bounds.size.height / 2.0f);
            transform = CGAffineTransformRotate(transform, rotation);
            transform = CGAffineTransformTranslate(transform, -currentView.bounds.size.width / 2.0f, -currentView.bounds.size.height / 2.0f);
            
            frame = CGRectApplyAffineTransform(frame, transform);
        }
        
        //TGLog(@"%f: %@", rotation, currentView);
        
        if ([currentView.superview isKindOfClass:[UIWindow class]])
            sourceWindowRotation = rotation;
        
        //frame = CGRectApplyAffineTransform(frame, transform);
        
        currentView = currentView.superview;
    }
    
    UIView *subview = [self topSuperviewOfView:toView];
    while (subview != nil && subview != toView)
    {
        frame.origin.x -= subview.frame.origin.x - subview.bounds.origin.x;
        frame.origin.y -= subview.frame.origin.y - subview.bounds.origin.y;
        
        if (ABS(sourceWindowRotation) > FLT_EPSILON)
        {
            CGAffineTransform transform = CGAffineTransformMakeTranslation(subview.bounds.size.width / 2.0f, subview.bounds.size.height / 2.0f);
            transform = CGAffineTransformRotate(transform, -sourceWindowRotation);
            transform = CGAffineTransformTranslate(transform, -subview.bounds.size.width / 2.0f, -subview.bounds.size.height / 2.0f);
            
            frame = CGRectApplyAffineTransform(frame, transform);
            
            sourceWindowRotation = 0.0f;
        }
        
        subview = [self subviewOfView:subview containingView:toView];
    }
    
    if (outRotationZ != NULL)
        *outRotationZ = 0.0f;
    
    return frame;
}

static CGFloat transformRotation(CGAffineTransform transform)
{
    return (CGFloat)atan2(transform.b, transform.a);
}

- (void)animateView:(UIView *)view frameFrom:(CGRect)fromFrame to:(CGRect)toFrame rotationFrom:(CGFloat)fromRotation to:(CGFloat)toRotation completion:(void (^)(bool))completion
{
    if (ABS(toRotation - fromRotation) > FLT_EPSILON)
    {
        POPSpringAnimation *rotationAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
        rotationAnimation.fromValue = @(fromRotation);
        rotationAnimation.toValue = @(toRotation);
        rotationAnimation.springSpeed = 20;
        rotationAnimation.springBounciness = 8;
        [view.layer pop_addAnimation:rotationAnimation forKey:@"layerTransitionRotation"];
    }
    
    POPSpringAnimation *frameAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    frameAnimation.fromValue = [NSValue valueWithCGRect:fromFrame];
    frameAnimation.toValue = [NSValue valueWithCGRect:toFrame];
    frameAnimation.springSpeed = 20;
    frameAnimation.springBounciness = 8;
    //frameAnimation.dynamicsFriction = 2;
    //frameAnimation.dynamicsTension = 94;
    frameAnimation.completionBlock = ^(__unused POPAnimation *animation, BOOL finished)
    {
        if (completion)
            completion(finished);
    };
    [view pop_addAnimation:frameAnimation forKey:@"layerTransitionFrame"];
}

- (void)animateTransitionInFromView:(UIView *)fromView toView:(UIView *)toView
{
    UIView *fromScrollView = [self findScrollView:fromView];
    UIView *fromContainerView = fromScrollView.superview;
    
    CGFloat fromRotationZ = 0.0f;
    CGRect fromFrame = [self convertFrameOfView:fromView toView:toView.superview outRotationZ:&fromRotationZ];
    
    CGRect fromContainerFromFrame = [fromContainerView convertRect:fromView.bounds fromView:fromView];
    //CGRect fromContainerFromFrame = [self convertFrameOfView:fromView toView:fromContainerView outRotationZ:NULL];
    CGRect fromContainerFrame = [self convertFrameOfView:toView toView:fromContainerView outRotationZ:NULL];
    
    UIView *fromViewContainerCopy = [fromView snapshotViewAfterScreenUpdates:false];
    fromViewContainerCopy.frame = fromContainerFromFrame;
    [fromContainerView insertSubview:fromViewContainerCopy aboveSubview:fromScrollView];
    
    __weak TGModernGalleryController *weakSelf = self;
    self.view.userInteractionEnabled = false;
    [self animateView:toView frameFrom:fromFrame to:toView.frame rotationFrom:fromRotationZ to:0.0f completion:^(bool __unused finished)
    {
        __strong TGModernGalleryController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf.view.userInteractionEnabled = true;
            
            TGModernGalleryItemView *itemView = nil;
            if (strongSelf.finishedTransitionIn && strongSelf.model.focusItem != nil)
            {
                for (TGModernGalleryItemView *visibleItemView in strongSelf->_visibleItemViews)
                {
                    if ([visibleItemView.item isEqual:strongSelf.model.focusItem])
                    {
                        itemView = visibleItemView;
                        
                        break;
                    }
                }
            }
            
            strongSelf.finishedTransitionIn(strongSelf.model.focusItem, itemView);
            
            strongSelf->_preloadVisibleItemViews = true;
            [strongSelf scrollViewBoundsChanged:strongSelf->_view.scrollView.bounds synchronously:false];
            
            [strongSelf.model _transitionCompleted];
        }
    }];
    
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
    
    [UIView animateWithDuration:0.2 animations:^
    {
        [TGHacks setApplicationStatusBarAlpha:1.0f];
    }];
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

- (void)reloadDataAtItem:(id<TGModernGalleryItem>)atItem synchronously:(bool)synchronously
{
    NSMutableIndexSet *removeIndices = nil;
    
    id<TGModernGalleryItem> focusItem = atItem;
    
    if (focusItem == nil)
    {
        for (TGModernGalleryItemView *itemView in _visibleItemViews)
        {
            if (itemView.index == [self currentItemIndex])
            {
                focusItem = itemView.item;
                
                break;
            }
        }
    }
    
    NSInteger itemViewIndex = -1;
    for (TGModernGalleryItemView *itemView in _visibleItemViews)
    {
        itemViewIndex++;
        
        NSInteger itemIndex = -1;
        bool itemFound = false;
        for (id<TGModernGalleryItem> item in _model.items)
        {
            itemIndex++;
            
            if ([item isEqual:itemView.item])
            {
                itemView.index = (NSUInteger)itemIndex;
                itemFound = true;
                
                break;
            }
        }
        
        if (!itemFound)
        {
            if (removeIndices == nil)
                removeIndices = [[NSMutableIndexSet alloc] init];
            [removeIndices addIndex:(NSUInteger)itemViewIndex];
        
            UIView *itemHeaderView = [itemView headerView];
            if (itemHeaderView != nil)
                [_view removeItemHeaderView:itemHeaderView];
            
            UIView *itemDefaultFooterView = [itemView defaultFooterView];
            if (itemDefaultFooterView != nil)
                [_view removeItemFooterView:itemDefaultFooterView];
            
            UIView *itemDefaultLeftAcessoryView = [itemView defaultFooterAccessoryLeftView];
            if (itemDefaultLeftAcessoryView != nil)
                [_view.interfaceView removeItemLeftAcessoryView:itemDefaultLeftAcessoryView];
            
            UIView *itemDefaultRightAcessoryView = [itemView defaultFooterAccessoryRightView];
            if (itemDefaultRightAcessoryView != nil)
                [_view.interfaceView removeItemRightAcessoryView:itemDefaultRightAcessoryView];
            
            UIView *itemFooterView = [itemView footerView];
            if (itemFooterView != nil)
                [_view removeItemFooterView:itemFooterView];
            [itemView removeFromSuperview];
            [self enqueueView:itemView];
        }
    }
    
    if (removeIndices != nil)
        [_visibleItemViews removeObjectsAtIndexes:removeIndices];
    
    _reloadingItems = true;
    
    NSUInteger index = (focusItem == nil || _model.items.count == 0) ? NSNotFound : [_model.items indexOfObject:focusItem];
    if (index != NSNotFound && index != _lastReportedFocusedIndex)
    {
        _lastReportedFocusedIndex = NSNotFound;
        [self setCurrentItemIndex:index == NSNotFound ? 0 : index synchronously:synchronously];
    }
    else
    {
        _lastReportedFocusedIndex = NSNotFound;
        
        CGFloat itemWidth = _view.scrollView.bounds.size.width;
        CGSize contentSize = CGSizeMake(_model.items.count * itemWidth, _view.scrollView.bounds.size.height);
        if (!CGSizeEqualToSize(_view.scrollView.contentSize, contentSize))
        {
            _view.scrollView.contentSize = contentSize;
            if (_view.scrollView.bounds.origin.x > contentSize.width - itemWidth)
            {
                _view.scrollView.bounds = CGRectMake(contentSize.width - itemWidth, 0.0f, itemWidth, _view.scrollView.bounds.size.height);
            }
            else
                [self scrollViewBoundsChanged:_view.scrollView.bounds];
        }
        else
            [self scrollViewBoundsChanged:_view.scrollView.bounds];
    }
    
    _reloadingItems = false;
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
    NSUInteger leftmostTrulyVisibleItemIndex = leftmostVisibleItemIndex;
    
    NSUInteger rightmostVisibleItemIndex = _model.items.count - 1;
    if (bounds.origin.x + bounds.size.width < _model.items.count * itemWidth)
        rightmostVisibleItemIndex = (NSUInteger)floorf((bounds.origin.x + bounds.size.width - 1.0f) / itemWidth);
    NSUInteger rightmostTrulyVisibleItemIndex = rightmostVisibleItemIndex;
    
    if (_preloadVisibleItemViews)
    {
        if (leftmostVisibleItemIndex > 1)
            leftmostVisibleItemIndex = leftmostVisibleItemIndex - 1;
        if (rightmostVisibleItemIndex < _model.items.count - 1)
            rightmostVisibleItemIndex = rightmostVisibleItemIndex + 1;
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
                
                UIView *itemDefaultLeftAcessoryView = [itemView defaultFooterAccessoryLeftView];
                if (itemDefaultLeftAcessoryView != nil)
                    [_view.interfaceView removeItemLeftAcessoryView:itemDefaultLeftAcessoryView];
                
                UIView *itemDefaultRightAcessoryView = [itemView defaultFooterAccessoryRightView];
                if (itemDefaultRightAcessoryView != nil)
                    [_view.interfaceView removeItemRightAcessoryView:itemDefaultRightAcessoryView];
                
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
                
                [itemView setIsVisible:itemView.index >= leftmostTrulyVisibleItemIndex && itemView.index <= rightmostTrulyVisibleItemIndex];
                
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
                    
                    UIView *itemDefaultLeftAcessoryView = [itemView defaultFooterAccessoryLeftView];
                    if (itemDefaultLeftAcessoryView != nil)
                        [_view.interfaceView addItemLeftAcessoryView:itemDefaultLeftAcessoryView];
                    
                    UIView *itemDefaultRightAcessoryView = [itemView defaultFooterAccessoryRightView];
                    if (itemDefaultRightAcessoryView != nil)
                        [_view.interfaceView addItemRightAcessoryView:itemDefaultRightAcessoryView];
                    
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
            
            UIView *itemDefaultLeftAcessoryView = [itemView defaultFooterAccessoryLeftView];
            if (itemDefaultLeftAcessoryView != nil)
                [_view.interfaceView addItemLeftAcessoryView:itemDefaultLeftAcessoryView];
            
            UIView *itemDefaultRightAcessoryView = [itemView defaultFooterAccessoryRightView];
            if (itemDefaultRightAcessoryView != nil)
                [_view.interfaceView addItemRightAcessoryView:itemDefaultRightAcessoryView];
            
            UIView *itemFooterView = [itemView footerView];
            if (itemFooterView != nil)
                [_view removeItemFooterView:itemFooterView];
            
            [itemView removeFromSuperview];
            [self enqueueView:itemView];
        }
        [_visibleItemViews removeAllObjects];
    }
    
    CGFloat fuzzyIndex = MAX(0, MIN(_model.items.count - 1, (_view.scrollView.bounds.origin.x) / _view.scrollView.bounds.size.width));
    CGFloat titleAlpha = 1.0f;
    
    NSUInteger currentItemIndex = [self currentItemIndex];
    
    for (TGModernGalleryItemView *itemView in _visibleItemViews)
    {
        CGFloat alpha = MAX(0.0f, MIN(1.0f, 1.0f - ABS(itemView.index - fuzzyIndex)));
        
        UIView *itemHeaderView = [itemView headerView];
        if (itemHeaderView != nil)
        {
            itemHeaderView.alpha = alpha;
            titleAlpha -= alpha;
        }
        
        CGFloat footerAlpha = itemView.index == currentItemIndex ? 1.0f : 0.0f;
        
        UIView *itemDefaultFooterView = [itemView defaultFooterView];
        if (itemDefaultFooterView != nil)
            itemDefaultFooterView.alpha = footerAlpha;
        
        UIView *itemDefaultLeftAcessoryView = [itemView defaultFooterAccessoryLeftView];
        if (itemDefaultLeftAcessoryView != nil)
            itemDefaultLeftAcessoryView.alpha = footerAlpha;
        
        UIView *itemDefaultRightAcessoryView = [itemView defaultFooterAccessoryRightView];
        if (itemDefaultRightAcessoryView != nil)
            itemDefaultRightAcessoryView.alpha = footerAlpha;
        
        UIView *itemFooterView = [itemView footerView];
        if (itemFooterView != nil)
            itemFooterView.alpha = footerAlpha;
    }
    
    _defaultHeaderView.alpha = MAX(0.0f, MIN(1.0f, titleAlpha));
    
    if (_lastReportedFocusedIndex != [self currentItemIndex])
    {
        if (!_reloadingItems && _lastReportedFocusedIndex != NSNotFound)
            [_view hideInterfaceAnimated];
        
        _lastReportedFocusedIndex = [self currentItemIndex];
        
        if (_lastReportedFocusedIndex < _model.items.count)
        {
            if (_itemFocused)
                _itemFocused(_model.items[_lastReportedFocusedIndex]);
            
            [_defaultHeaderView setItem:_model.items[_lastReportedFocusedIndex]];
        }
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
