#import "TGMenuSheetController.h"

#import "TGMenuSheetView.h"
#import "TGMenuSheetDimView.h"
#import "TGMenuSheetItemView.h"

#import "TGAppDelegate.h"

const CGFloat TGMenuSheetPadMenuWidth = 320.0f;

typedef enum
{
    TGMenuSheetAnimationChange,
    TGMenuSheetAnimationDismiss,
    TGMenuSheetAnimationPresent,
    TGMenuSheetAnimationFastDismiss
} TGMenuSheetAnimation;

@interface TGMenuSheetController ()
{
    UIView *_containerView;
    TGMenuSheetDimView *_dimView;
    TGMenuSheetView *_sheetView;
    bool _presented;
    
    SMetaDisposable *_sizeClassDisposable;
    UIUserInterfaceSizeClass _sizeClass;
    
    bool _hasSwipeGesture;
    UIPanGestureRecognizer *_gestureRecognizer;
    CGFloat _gestureStartPosition;
    
    __weak UIView *_sourceView;
    __weak UIViewController *_parentController;
}
@end

@implementation TGMenuSheetController

- (instancetype)initWithItemViews:(NSArray *)itemViews
{
    self = [self init];
    if (self != nil)
    {
        [self setItemViews:itemViews];
    }
    return self;
}

- (void)dealloc
{
    [_sizeClassDisposable dispose];
}

- (void)loadView
{
    [super loadView];
    
    if (TGAppDelegateInstance.rootController.currentSizeClass == UIUserInterfaceSizeClassCompact)
    {
        self.view.frame = TGAppDelegateInstance.rootController.applicationBounds;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    __weak TGMenuSheetController *weakSelf = self;
    _sizeClassDisposable = [[SMetaDisposable alloc] init];
    [_sizeClassDisposable setDisposable:[[TGAppDelegateInstance rootController].sizeClass startWithNext:^(NSNumber *next)
    {
        __strong TGMenuSheetController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        UIUserInterfaceSizeClass sizeClass = next.integerValue;
        [strongSelf updateTraitsWithSizeClass:sizeClass];
    }]];
    
    _containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_containerView];
    
    _dimView = [[TGMenuSheetDimView alloc] initWithActionMenuView:_sheetView];
    _dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_dimView addTarget:self action:@selector(dimViewPressed) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_dimView];
    
    [_containerView addSubview:_sheetView];
}

- (void)setItemViews:(NSArray *)itemViews
{
    [self setItemViews:itemViews animated:false];
}

- (void)setItemViews:(NSArray *)itemViews animated:(bool)animated
{
    bool compact = (_sizeClass == UIUserInterfaceSizeClassCompact);
    
    __weak TGMenuSheetController *weakSelf = self;
    void (^menuRelayout)(void) = ^
    {
        __strong TGMenuSheetController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf repositionMenuWithReferenceSize:TGAppDelegateInstance.rootController.applicationBounds.size];
    };
    
    if (animated && compact)
    {
        TGMenuSheetView *sheetView = _sheetView;
        
        UIView *snapshotView = [sheetView snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = [_containerView convertRect:sheetView.frame toView:_containerView.superview];
        [_containerView.superview addSubview:snapshotView];
        
        [sheetView menuWillDisappearAnimated:false];
        [sheetView removeFromSuperview];
        [sheetView menuDidDisappearAnimated:false];
        
        void (^changeBlock)(void) = ^
        {
            snapshotView.frame = CGRectMake(snapshotView.frame.origin.x, snapshotView.frame.origin.y + snapshotView.frame.size.height, snapshotView.frame.size.width, snapshotView.frame.size.height);
        };
        void (^completionBlock)(BOOL) = ^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
        };
        
        if (iosMajorVersion() >= 7)
        {
            [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:1.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:changeBlock completion:completionBlock];
        }
        else
        {
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:changeBlock completion:completionBlock];
        }
        
        _sheetView = [[TGMenuSheetView alloc] initWithItemViews:itemViews sizeClass:_sizeClass];
        _sheetView.menuRelayout = menuRelayout;
        [_containerView addSubview:_sheetView];

        [self updateGestureRecognizer];
        [self.view setNeedsLayout];
        
        [self applySheetOffset:_sheetView.menuHeight];
        [self animateSheetViewToPosition:0 velocity:0 type:TGMenuSheetAnimationPresent completion:^
        {
            [_sheetView menuDidAppearAnimated:animated];
        }];
    }
    else
    {
        void (^configureBlock)(void) = ^
        {
            _sheetView = [[TGMenuSheetView alloc] initWithItemViews:itemViews sizeClass:_sizeClass];
            _sheetView.menuRelayout = menuRelayout;
            if (self.isViewLoaded)
                [_containerView addSubview:_sheetView];
            
            [self updateGestureRecognizer];
            [self.view setNeedsLayout];
        };
        
        if (_sheetView != nil)
        {
            [_parentController dismissViewControllerAnimated:false completion:^
            {
                [_sheetView removeFromSuperview];
                configureBlock();
                [_parentController presentViewController:self animated:false completion:nil];
                
                if (iosMajorVersion() >= 8 && self.popoverPresentationController != nil)
                {
                    self.popoverPresentationController.backgroundColor = [UIColor whiteColor];
                    self.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
                    self.popoverPresentationController.sourceView = _sourceView;
                    self.popoverPresentationController.sourceRect = _sourceView.bounds;
                }
            }];
        }
        else
        {
            configureBlock();
        }
    }
    
    _itemViews = itemViews;
}

- (void)dimViewPressed
{
    if (!self.dismissesByOutsideTap)
        return;
    
    bool dismissalAllowed = true;
    if (_sheetView.tapDismissalAllowed != nil)
        dismissalAllowed = _sheetView.tapDismissalAllowed();
    
    if (!dismissalAllowed)
        return;

    [self dismissAnimated:true manual:true];
}

#pragma mark -

- (void)presentInViewController:(UIViewController *)viewController sourceView:(UIView *)sourceView animated:(bool)animated
{
    _sourceView = sourceView;
    
    bool compact = (_sizeClass == UIUserInterfaceSizeClassCompact);
    if (compact)
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    else
        self.modalPresentationStyle = UIModalPresentationPopover;
    
    [_sheetView menuWillAppearAnimated:animated];
    
    if (viewController.navigationController != nil)
        viewController = viewController.navigationController.parentViewController;
    
    _parentController = viewController;
    
    if (compact)
    {
        [viewController addChildViewController:self];
        [viewController.view addSubview:self.view];
        
        _dimView.alpha = 0.0f;
        [self setDimViewHidden:false animated:animated];
        
        if (iosMajorVersion() >= 7 && [viewController isKindOfClass:[TGNavigationController class]])
            ((TGNavigationController *)viewController).interactivePopGestureRecognizer.enabled = false;
        
        if (animated)
        {
            [self applySheetOffset:_sheetView.menuHeight];
            [self animateSheetViewToPosition:0 velocity:0 type:TGMenuSheetAnimationPresent completion:^
            {
                [_sheetView menuDidAppearAnimated:animated];
                _presented = true;
            }];
        }
        else
        {
            [_sheetView menuDidAppearAnimated:animated];
            _presented = true;
        }
    }
    else
    {
        [viewController presentViewController:self animated:false completion:nil];
        
        if (iosMajorVersion() >= 8 && self.popoverPresentationController != nil)
        {
            self.popoverPresentationController.backgroundColor = [UIColor whiteColor];
            self.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
            self.popoverPresentationController.sourceView = _sourceView;
            self.popoverPresentationController.sourceRect = _sourceView.bounds;
        }
        
        [_sheetView menuDidAppearAnimated:false];
        _presented = true;
    }
}

- (void)dismissAnimated:(bool)animated
{
    [self dismissAnimated:animated manual:false];
}

- (void)dismissAnimated:(bool)animated manual:(bool)manual
{
    bool compact = (_sizeClass == UIUserInterfaceSizeClassCompact);
    
    if (compact)
    {
        if (iosMajorVersion() >= 7 && [self.parentViewController isKindOfClass:[TGNavigationController class]])
            ((TGNavigationController *)self.parentViewController).interactivePopGestureRecognizer.enabled = true;
        
        [_sheetView menuWillDisappearAnimated:animated];
        [self setDimViewHidden:true animated:animated];
        if (animated)
        {
            self.view.userInteractionEnabled = false;
            [self animateSheetViewToPosition:_sheetView.menuHeight velocity:0 type:TGMenuSheetAnimationDismiss completion:^
            {
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                [_sheetView menuDidDisappearAnimated:animated];
                
                if (self.didDismiss != nil)
                    self.didDismiss(manual);
            }];
        }
        else
        {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [_sheetView menuDidDisappearAnimated:animated];
            
            if (self.didDismiss != nil)
                self.didDismiss(manual);
        }
    }
    else
    {
        [_sheetView menuWillDisappearAnimated:animated];
        [self.presentingViewController dismissViewControllerAnimated:false completion:^
        {
            [_sheetView menuDidDisappearAnimated:animated];
            if (self.didDismiss != nil)
                self.didDismiss(manual);
        }];
    }
}

- (void)animateSheetViewToPosition:(CGFloat)position velocity:(CGFloat)velocity type:(TGMenuSheetAnimation)type completion:(void (^)(void))completion
{
    CGFloat animationVelocity = position > 0 ? fabs(velocity) / fabs(position - self.view.frame.origin.y) : 0;
    
    void (^changeBlock)(void) = ^
    {
        _containerView.frame = CGRectMake(_containerView.frame.origin.x, position, _containerView.frame.size.width, _containerView.frame.size.height);
    };
    void (^completionBlock)(BOOL) = ^(__unused BOOL finished)
    {
        if (completion != nil)
            completion();
    };
    
    if (type == TGMenuSheetAnimationPresent)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction;
        if (iosMajorVersion() >= 7)
            options |= 7 << 16;
        [UIView animateWithDuration:0.3 delay:0.0 options:options animations:changeBlock completion:completionBlock];
    }
    else
    {
        CGFloat duration = 0.25;
        if (type == TGMenuSheetAnimationFastDismiss)
            duration = 0.2;
        
        if (iosMajorVersion() >= 7)
        {
            [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:1.5 initialSpringVelocity:animationVelocity options:UIViewAnimationOptionCurveLinear animations:changeBlock completion:completionBlock];
        }
        else
        {
            [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:changeBlock completion:completionBlock];
        }
    }
}

#pragma mark -

- (bool)hasSwipeGesture
{
    return _hasSwipeGesture;
}

- (void)setHasSwipeGesture:(bool)hasSwipeGesture
{
    if (_hasSwipeGesture == hasSwipeGesture)
        return;

    _hasSwipeGesture = hasSwipeGesture;
    [self updateGestureRecognizer];
}

- (void)updateGestureRecognizer
{
    if (_sheetView == nil)
        return;

    if (_hasSwipeGesture && _sizeClass != UIUserInterfaceSizeClassRegular)
    {
        _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_sheetView addGestureRecognizer:_gestureRecognizer];
    }
    else
    {
        [_sheetView removeGestureRecognizer:_gestureRecognizer];
        _gestureRecognizer = nil;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGFloat location = [gestureRecognizer locationInView:self.view].y;
    CGFloat offset = location - _gestureStartPosition;
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _gestureStartPosition = location;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            [self applySheetOffset:[self swipeOffsetForOffset:offset]];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGFloat velocity = [gestureRecognizer velocityInView:self.view].y;
            
            if (velocity > 200.0f)
            {
                [self setDimViewHidden:true animated:true];
                [self animateSheetViewToPosition:_sheetView.menuHeight velocity:velocity type:TGMenuSheetAnimationDismiss completion:^
                {
                    [self dismissAnimated:false];
                }];
            }
            else
            {
                [self animateSheetViewToPosition:0 velocity:0 type:TGMenuSheetAnimationChange completion:nil];
            }
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            [self animateSheetViewToPosition:0 velocity:0 type:TGMenuSheetAnimationChange completion:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)applySheetOffset:(CGFloat)offset
{
    _containerView.frame = CGRectMake(_containerView.frame.origin.x, self.view.frame.origin.y + offset, self.view.frame.size.width, self.view.frame.size.height);
}

- (CGFloat)swipeOffsetForOffset:(CGFloat)offset
{
    if (offset >= 0)
        return offset;
    
    static CGFloat c = 0.05f;
    static CGFloat d = 300.0f;
    
    return (1.0f - (1.0f / ((offset * c / d) + 1.0f))) * d;
}

- (CGFloat)clampVelocity:(CGFloat)velocity
{
    CGFloat value = velocity < 0.0f ? -velocity : velocity;
    value = MIN(30.0f, 0.0f);
    return velocity < 0.0f ? -value : value;
}

#pragma mark - Traits

- (void)updateTraitsWithSizeClass:(UIUserInterfaceSizeClass)sizeClass
{
    UIUserInterfaceSizeClass previousClass = _sizeClass;
    _sizeClass = sizeClass;
    
    [_sheetView updateTraitsWithSizeClass:sizeClass];
    
    if (_presented && previousClass != sizeClass)
    {
        switch (sizeClass)
        {
            case UIUserInterfaceSizeClassRegular:
            {
                _dimView.hidden = true;
                
                self.modalPresentationStyle = UIModalPresentationPopover;
                
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                
                [_parentController presentViewController:self animated:false completion:nil];
                
                if (iosMajorVersion() >= 8 && self.popoverPresentationController != nil && _sourceView != nil)
                {
                    self.popoverPresentationController.backgroundColor = [UIColor whiteColor];
                    self.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
                    self.popoverPresentationController.sourceView = _sourceView;
                    self.popoverPresentationController.sourceRect = _sourceView.bounds;
                }
                
                if (iosMajorVersion() >= 7 && [_parentController isKindOfClass:[TGNavigationController class]])
                    ((TGNavigationController *)_parentController).interactivePopGestureRecognizer.enabled = true;
            }
                break;
                
            default:
            {
                _dimView.hidden = false;
                
                [self.presentingViewController dismissViewControllerAnimated:false completion:^
                {
                    self.modalPresentationStyle = UIModalPresentationFullScreen;
                    
                    [_parentController addChildViewController:self];
                    [_parentController.view addSubview:self.view];
                    [self.view setNeedsLayout];
                    
                    if (iosMajorVersion() >= 7 && [_parentController isKindOfClass:[TGNavigationController class]])
                        ((TGNavigationController *)_parentController).interactivePopGestureRecognizer.enabled = false;
                }];
            }
                break;
        }
    }
    
    [self updateGestureRecognizer];
}

#pragma mark -

- (CGSize)preferredContentSize
{
    return [super preferredContentSize];
}

- (void)viewWillLayoutSubviews
{
    if (_sizeClass == UIUserInterfaceSizeClassRegular)
    {
        _sheetView.menuWidth = TGMenuSheetPadMenuWidth;
        
        CGSize menuSize = _sheetView.menuSize;
        self.preferredContentSize = menuSize;
        _sheetView.frame = CGRectMake(0, 0, menuSize.width, menuSize.height);
        _containerView.frame = _sheetView.bounds;
        _dimView.frame = CGRectZero;
    }
    else
    {
        CGSize referenceSize = TGAppDelegateInstance.rootController.applicationBounds.size;

        _containerView.frame = CGRectMake(_containerView.frame.origin.x, _containerView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        _dimView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

        _sheetView.menuWidth = referenceSize.width;
        
        [self repositionMenuWithReferenceSize:referenceSize];
    }
}

- (void)repositionMenuWithReferenceSize:(CGSize)referenceSize
{
    if (_sizeClass == UIUserInterfaceSizeClassRegular)
        return;
        
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
    statusBarHeight = MAX(20.0f, statusBarHeight);
    referenceSize.height = referenceSize.height + 20.0f - statusBarHeight;
    
    CGSize menuSize = _sheetView.menuSize;
    _sheetView.frame = CGRectMake(0, referenceSize.height - menuSize.height, menuSize.width, menuSize.height);
}

- (void)setDimViewHidden:(bool)hidden animated:(bool)animated
{
    void (^changeBlock)(void) = ^
    {
        _dimView.alpha = hidden ? 0.0f : 1.0f;
    };
    
    if (animated)
        [UIView animateWithDuration:0.25f animations:changeBlock];
    else
        changeBlock();
}

@end
