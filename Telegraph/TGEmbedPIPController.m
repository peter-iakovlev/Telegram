#import "TGEmbedPIPController.h"
#import "TGEmbedPIPView.h"
#import "TGPIPAblePlayerView.h"

#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "TGEmbedPIPPlaceholderView.h"
#import "TGEmbedItemView.h"

#import "Freedom.h"
#import "TGImageUtils.h"
#import "TGObserverProxy.h"

#import "TGAppDelegate.h"
#import "TGOverlayControllerWindow.h"

#import "TGInterfaceManager.h"

const CGFloat TGEmbedPIPViewMargin = 10.0f;
const CGFloat TGEmbedPIPDefaultStatusBarHeight = 20.0f;
const CGFloat TGEmbedPIPPortraitNavigationBarHeight = 44.0f;
const CGFloat TGEmbedPIPLandscapeNavigationBarHeight = 32.0f;
const CGFloat TGEmbedPIPAngleEpsilon = 30.0f;

void freedomPIPInit();

@interface TGEmbedPIPWindow : TGOverlayControllerWindow

@end

@interface TGEmbedPIPController () <UIGestureRecognizerDelegate>
{
    UIView<TGPIPAblePlayerView> *_playerView;
    TGPIPSourceLocation *_location;
    
    CGRect _initialPlayerFrame;
    CGSize _minimalPipSize;
    TGEmbedPIPView *_pipView;
    
    CGFloat _keyboardHeight;
    
    TGEmbedPIPCorner _currentCorner;
    bool _hidden;
    bool _highVelocityOnGestureStart;
    
    CGSize _maxSize;
    
    TGEmbedPIPWindow *_window;
    bool _appearing;
    bool _closing;
 
    UIPanGestureRecognizer *_panGestureRecognizer;
    UIPinchGestureRecognizer *_pinchGestureRecognizer;
    
    TGObserverProxy *_keyboardWillChangeFrameProxy;
    TGObserverProxy *_didEnterBackgroundProxy;
}

@property (nonatomic, copy) void (^onTransitionBegin)(void);

@end

@implementation TGEmbedPIPController

- (instancetype)initWithPlayerView:(UIView<TGPIPAblePlayerView> *)playerView location:(TGPIPSourceLocation *)location corner:(TGEmbedPIPCorner)corner
{
    self = [super init];
    if (self != nil)
    {
        _currentCorner = corner;
        _playerView = playerView;
        _location = location;
        
        TGEmbedPIPWindow *window = [[TGEmbedPIPWindow alloc] initWithFrame:TGAppDelegateInstance.rootController.applicationBounds];
        window.backgroundColor = [UIColor clearColor];
        window.rootViewController = self;
        window.windowLevel = 100000000.0f + 0.001f;
        window.hidden = false;
        _window = window;
        
        _keyboardWillChangeFrameProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification];
        
        _didEnterBackgroundProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    __weak TGEmbedPIPController *weakSelf = self;
    _pipView = [[TGEmbedPIPView alloc] initWithFrame:CGRectZero];
    _pipView.switchBackPressed = ^
    {
        __strong TGEmbedPIPController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf cancel:false];
    };
    _pipView.closePressed = ^
    {
        __strong TGEmbedPIPController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        bool invisible = false;
        
        if ([strongSelf sourcePlaceholderView:&invisible] != nil)
            [strongSelf cancel:invisible];
        else
            [strongSelf dismissController];
    };
    _pipView.arrowPressed = ^
    {
        __strong TGEmbedPIPController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf->_hidden)
        {
            [strongSelf animateViewWithOptions:kNilOptions block:^
            {
                [strongSelf layoutViewAtCorner:strongSelf->_currentCorner hidden:false];
            } completion:nil];
            
            [strongSelf->_pipView setBlurred:false animated:true];
        }
    };
    [self.view addSubview:_pipView];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGestureRecognizer.delegate = self;
    [_pipView addGestureRecognizer:_panGestureRecognizer];
    
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    _pinchGestureRecognizer.delegate = self;
    [_pipView addGestureRecognizer:_pinchGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _initialPlayerFrame = _playerView.frame;
    
    CGRect transitionSourceFrame = [_playerView convertRect:_playerView.bounds toView:nil];
    [_pipView setPlayerView:_playerView];
    
    CGSize pipSize = TGFitSize(transitionSourceFrame.size, [TGEmbedPIPView defaultSize]);
    _minimalPipSize = pipSize;
    
    CGFloat minSide = MIN(self.view.frame.size.width, self.view.frame.size.height);
    CGFloat maxSide = MAX(self.view.frame.size.width, self.view.frame.size.height);
    _maxSize = CGSizeMake(minSide - TGEmbedPIPViewMargin * 2, floor(maxSide / 1.6667f));
    
    CGRect targetFrame = [self _rectForViewAtCorner:_currentCorner size:pipSize hidden:false];
    
    [_pipView setControlsHidden:true animated:false];
    _pipView.frame = transitionSourceFrame;
    
    _appearing = true;
    [self animateViewWithOptions:0 block:^
    {
        _pipView.frame = targetFrame;
    } completion:^(__unused BOOL finished)
    {
        _appearing = false;
        [_pipView setControlsHidden:false animated:true];
    }];
    
    if (self.onTransitionBegin != nil)
    {
        self.onTransitionBegin();
        self.onTransitionBegin = nil;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (!_closing)
        [self layoutViewAtCorner:_currentCorner hidden:_hidden];
}

- (void)animateViewWithOptions:(UIViewAnimationOptions)options block:(void (^)(void))block completion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.4 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveLinear | options animations:block completion:completion];
}

#pragma mark - 

+ (TGEmbedPIPPlaceholderView *)placeholderViewForLocation:(TGPIPSourceLocation *)location invisible:(bool *)invisible
{
    TGEmbedPIPPlaceholderView *placeholderView = nil;
    for (TGEmbedPIPPlaceholderView *view in [TGEmbedPIPController placeholderViews])
    {
        if ([view.location isEqual:location])
        {
            if (invisible != NULL)
                *invisible = view.invisible;
            
            placeholderView = view;
            break;
        }
    }
    
    return placeholderView;
}

- (TGEmbedPIPPlaceholderView *)sourcePlaceholderView:(bool *)invisible
{
    return [TGEmbedPIPController placeholderViewForLocation:_location invisible:invisible];
}

- (void)dismissController
{
    activePIPController = nil;
    
    self.view.userInteractionEnabled = false;
    
    _closing = true;
    
    [_playerView pauseVideo];
    [_pipView setClosing];
    
    [UIView animateWithDuration:0.15 animations:^
    {
        _pipView.alpha = 0.0f;
    }];
    
    CGRect targetFrame = CGRectInset(_pipView.frame, 0.4f * _pipView.frame.size.width, 0.4f * _pipView.frame.size.height);
    [UIView animateWithDuration:0.3 delay:0.0 options:(7 << 16) animations:^
    {
        _pipView.frame = targetFrame;
    } completion:^(__unused BOOL finished)
    {
        _window.hidden = true;
        _window = nil;
    }];
}

- (void)cancel:(bool)reset
{
    [self cancelWithOffset:CGPointZero reset:reset];
}

- (void)cancelWithOffset:(CGPoint)offset reset:(bool)reset
{
    bool invisible = false;
    TGEmbedPIPPlaceholderView *view = [self sourcePlaceholderView:&invisible];
    if (!reset && invisible)
        view = nil;
    
    _closing = true;
    
    void (^switchBlock)(TGEmbedPIPPlaceholderView *) = ^(TGEmbedPIPPlaceholderView *placeholderView)
    {
        [view _willReattach];
        
        [_playerView _prepareToLeaveFullscreen];
        [_playerView beginLeavingFullscreen];
        [_pipView setClosing];
        _pipView.userInteractionEnabled = false;
        
        CGRect targetFrame = CGRectZero;
        
        if ([placeholderView.containerView shouldReattachPlayerBeforeTransition])
        {
            _pipView.frame = [_pipView convertRect:_pipView.bounds toView:placeholderView.containerView];
            [placeholderView.containerView addSubview:_pipView];
            
            targetFrame = [placeholderView convertRect:placeholderView.bounds toView:placeholderView.containerView];
        }
        else
        {
            targetFrame = [placeholderView convertRect:placeholderView.bounds toView:nil];
            targetFrame = CGRectOffset(targetFrame, offset.x, offset.y);
        }
        
        void (^completion)(BOOL) = ^(__unused BOOL finished)
        {
            [placeholderView.containerView reattachPlayerView:_playerView];
            [_playerView finishedLeavingFullscreen];
            
            [_pipView removeFromSuperview];
            
            _window.hidden = true;
            _window = nil;
            
            activePIPController = nil;
        };
        
        if (reset)
        {
            [_playerView pauseVideo];
            [_pipView setClosing];
            
            [UIView animateWithDuration:0.15 animations:^
            {
                _pipView.alpha = 0.0f;
            }];
            
            CGRect animationFrame = CGRectInset(_pipView.frame, 0.4f * _pipView.frame.size.width, 0.4f * _pipView.frame.size.height);
            [UIView animateWithDuration:0.3 delay:0.0 options:(7 << 16) animations:^
            {
                _pipView.frame = animationFrame;
            } completion:^(__unused BOOL finished)
            {
                _window.hidden = true;
                _window = nil;
                
                _pipView.frame = targetFrame;
                [_playerView seekToPosition:0.0];
                
                completion(true);
            }];
        }
        else
        {
            [self animateViewWithOptions:0 block:^
            {
                _pipView.frame = targetFrame;
            } completion:completion];
        }
    };
    
    if (view != nil)
    {
        switchBlock(view);
    }
    else
    {
        [[TGInterfaceManager instance] navigateToConversationWithId:_location.peerId conversation:nil performActions:nil atMessage:@{ @"mid": @(_location.messageId), @"openMedia": @true, @"embed": @(_location.embed), @"cancelPIP": @true, @"pipLocation": _location } clearStack:true openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
    }
}

#pragma mark -

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (_appearing)
        return;
    
    CGPoint translation = [gestureRecognizer translationInView:self.view];
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [_pipView setPanning:true];
            
            CGFloat velocityVal = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
            _highVelocityOnGestureStart = (velocityVal > 500);
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (_highVelocityOnGestureStart)
            {
                _highVelocityOnGestureStart = false;
                return;
            }
            
            _pipView.center = CGPointMake(_pipView.center.x + translation.x, _pipView.center.y + translation.y);
            [_pipView setArrowOnRightSide:(_pipView.center.x > (self.view.frame.size.width / 2.0f))];
            
            bool shouldHide = false;
            [self targetCornerForLocation:_pipView.center hide:&shouldHide];
            [_pipView setBlurred:shouldHide animated:true];
            _hidden = shouldHide;
            
            [gestureRecognizer setTranslation:CGPointZero inView:self.view];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            bool shouldHide = false;
            
            CGFloat velocityVal = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
            
            TGEmbedPIPCorner targetCorner = _currentCorner;
            
            if (velocityVal > 500)
                targetCorner = [self targetCornerForVelocity:velocity hide:&shouldHide];
            else
                targetCorner = [self targetCornerForLocation:_pipView.center hide:&shouldHide];
            
            [self animateViewWithOptions:UIViewAnimationOptionAllowUserInteraction block:^
            {
                [self layoutViewAtCorner:targetCorner hidden:shouldHide];
            } completion:nil];
            
            [_pipView setPanning:false];
            [_pipView setBlurred:shouldHide animated:true];
            _hidden = shouldHide;
        }
            break;
            
        default:
            break;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if (_appearing)
        return;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat zoom = gestureRecognizer.scale;;
        
        CGSize size = _pipView.frame.size;
        CGFloat ratio = size.width / size.height;
        CGFloat newWidth = TGRetinaFloor(size.width * zoom);
        if (newWidth >= _maxSize.width)
            newWidth = _maxSize.width;
        else if (newWidth <= _minimalPipSize.width)
            newWidth = _minimalPipSize.width;
        
        CGFloat newHeight = newWidth / ratio;
        if (newHeight >= _maxSize.height)
        {
            newHeight = _maxSize.height;
            newWidth = newHeight * ratio;
        }
        
        CGSize newSize = CGSizeMake(newWidth, newHeight);
        CGPoint center = _pipView.center;
        _pipView.frame = CGRectMake(center.x - newSize.width / 2.0f, center.y - newSize.height / 2.0f, newSize.width, newSize.height);
        
        gestureRecognizer.scale = 1;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    return false;
}

#pragma mark - 

- (UIViewController *)statusBarAppearanceSourceController
{
    UIViewController *topViewController = TGAppDelegateInstance.rootController.viewControllers.lastObject;
    
    if ([topViewController isKindOfClass:[UITabBarController class]])
        topViewController = [(UITabBarController *)topViewController selectedViewController];
    if ([topViewController isKindOfClass:[TGViewController class]])
    {
        TGViewController *concreteTopViewController = (TGViewController *)topViewController;
        if (concreteTopViewController.associatedWindowStack.count != 0)
        {
            for (UIWindow *window in concreteTopViewController.associatedWindowStack.reverseObjectEnumerator)
            {
                if (window.rootViewController != nil && window.rootViewController != self)
                {
                    topViewController = window.rootViewController;
                    break;
                }
            }
        }
    }
    
    return topViewController;
}

- (UIViewController *)autorotationSourceController
{
    UIViewController *topViewController = TGAppDelegateInstance.rootController.viewControllers.lastObject;
    
    if ([topViewController isKindOfClass:[UITabBarController class]])
        topViewController = [(UITabBarController *)topViewController selectedViewController];
    
    return topViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [[self statusBarAppearanceSourceController] preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return [[self statusBarAppearanceSourceController] prefersStatusBarHidden];
}

- (BOOL)shouldAutorotate
{
    static NSArray *nonRotateableWindowClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        Class alertClass = NSClassFromString(TGEncodeText(@"`VJBmfsuPwfsmbzXjoepx", -1));
        if (alertClass != nil)
            [array addObject:alertClass];
        
        nonRotateableWindowClasses = array;
    });
    
    for (UIWindow *window in [UIApplication sharedApplication].windows.reverseObjectEnumerator)
    {
        for (Class classInfo in nonRotateableWindowClasses)
        {
            if ([window isKindOfClass:classInfo])
                return false;
        }
    }
    
    if (TGAppDelegateInstance.rootController.presentedViewController != nil)
        return [TGAppDelegateInstance.rootController.presentedViewController shouldAutorotate];
    
    if ([self autorotationSourceController] != nil)
        return [[self autorotationSourceController] shouldAutorotate];
    
    return true;
}

#pragma mark - 

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSTimeInterval duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil ? 0.3 : [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect screenKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:screenKeyboardFrame fromView:nil];
    
    CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0.0f :  (self.view.frame.size.height - keyboardFrame.origin.y);
    
    keyboardHeight = MAX(keyboardHeight, 0.0f);

    if (keyboardFrame.origin.y + keyboardFrame.size.height < self.view.frame.size.height - FLT_EPSILON)
        keyboardHeight = 0.0f;
    
    _keyboardHeight = keyboardHeight;
    
    [UIView animateWithDuration:duration delay:0.0 options:curve animations:^
    {
        [self layoutViewAtCorner:_currentCorner hidden:_hidden];
    } completion:nil];
}

- (void)didEnterBackground:(NSNotification *)__unused notification
{
    [_playerView pauseVideo];
}

#pragma mark - 

- (CGRect)_rectForViewAtCorner:(TGEmbedPIPCorner)corner size:(CGSize)size hidden:(bool)hidden
{
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
    statusBarHeight = MAX(TGEmbedPIPDefaultStatusBarHeight, statusBarHeight);
 
    bool isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat topBarHeight = isLandscape ? TGEmbedPIPLandscapeNavigationBarHeight : TGEmbedPIPPortraitNavigationBarHeight;
    CGFloat topMargin = TGEmbedPIPViewMargin + topBarHeight + statusBarHeight;
    CGFloat bottomMargin = TGEmbedPIPViewMargin + 44.0f + _keyboardHeight;
    CGFloat hiddenWidth = size.width - TGEmbedPIPSlipSize;
    
    CGFloat bottomY = self.view.frame.size.height - bottomMargin - size.height;
    CGFloat topY = MIN(bottomY, topMargin);
    
    switch (corner)
    {
        case TGEmbedPIPCornerTopLeft:
        {
            CGRect rect = CGRectMake(TGEmbedPIPViewMargin, topY, size.width, size.height);
            if (hidden)
                rect.origin.x -= hiddenWidth;
            return rect;
        }
        case TGEmbedPIPCornerBottomRight:
        {
            CGRect rect = CGRectMake(self.view.frame.size.width - TGEmbedPIPViewMargin - size.width, bottomY, size.width, size.height);
            if (hidden)
                rect.origin.x += hiddenWidth;
            return rect;
        }
            
        case TGEmbedPIPCornerBottomLeft:
        {
            CGRect rect = CGRectMake(TGEmbedPIPViewMargin, bottomY, size.width, size.height);
            if (hidden)
                rect.origin.x -= hiddenWidth;
            return rect;
        }
            
        case TGEmbedPIPCornerTopRight:
        default:
        {
            CGRect rect = CGRectMake(self.view.frame.size.width - TGEmbedPIPViewMargin - size.width, topY, size.width, size.height);
            if (hidden)
                rect.origin.x += hiddenWidth;
            return rect;
        }
    }
}

- (void)layoutViewAtCorner:(TGEmbedPIPCorner)corner hidden:(bool)hidden
{
    _currentCorner = corner;
    _hidden = hidden;
    _pipView.frame = [self _rectForViewAtCorner:corner size:_pipView.frame.size hidden:hidden];
    
    defaultCorner = corner;
    
    [UIView performWithoutAnimation:^
    {
        [_pipView setArrowOnRightSide:(_pipView.center.x > (self.view.frame.size.width / 2.0f))];
    }];
}

- (TGEmbedPIPCorner)targetCornerForVelocity:(CGPoint)velocity hide:(bool *)hide
{
    CGFloat x = velocity.x;
    CGFloat y = velocity.y;
    
    double angle = atan2(y, x) * 180.0f / M_PI * -1;
    if (angle < 0) angle += 360.0f;

    TGEmbedPIPCorner corner = _currentCorner;
    bool shouldHide = _hidden;
    
    switch (_currentCorner)
    {
        case TGEmbedPIPCornerTopLeft:
            if ((angle > 0 && angle < 90 - TGEmbedPIPAngleEpsilon) || angle > 360 - TGEmbedPIPAngleEpsilon)
            {
                if (!shouldHide)
                    corner = TGEmbedPIPCornerTopRight;
                else
                    shouldHide = false;
            }
            else if (angle > 180 + TGEmbedPIPAngleEpsilon && angle < 270 + TGEmbedPIPAngleEpsilon)
            {
                corner = TGEmbedPIPCornerBottomLeft;
                shouldHide = false;
            }
            else if (angle > 270 + TGEmbedPIPAngleEpsilon && angle < 360 - TGEmbedPIPAngleEpsilon)
            {
                if (!shouldHide)
                    corner = TGEmbedPIPCornerBottomRight;
                else
                    shouldHide = false;
            }
            else if (!shouldHide)
            {
                shouldHide = true;
            }
            break;
            
        case TGEmbedPIPCornerTopRight:
            if (angle > 90 + TGEmbedPIPAngleEpsilon && angle < 180 + TGEmbedPIPAngleEpsilon)
            {
                if (!shouldHide)
                    corner = TGEmbedPIPCornerTopLeft;
                else
                    shouldHide = false;
            }
            else if (angle > 270 - TGEmbedPIPAngleEpsilon && angle < 360 - TGEmbedPIPAngleEpsilon)
            {
                corner = TGEmbedPIPCornerBottomRight;
                shouldHide = false;
            }
            else if (angle > 180 + TGEmbedPIPAngleEpsilon && angle < 270 - TGEmbedPIPAngleEpsilon)
            {
                if (!shouldHide)
                    corner = TGEmbedPIPCornerBottomLeft;
                else
                    shouldHide = false;
            }
            else if (!shouldHide)
            {
                shouldHide = true;
            }
            break;
            
        case TGEmbedPIPCornerBottomLeft:
            if (angle > 90 - TGEmbedPIPAngleEpsilon && angle < 180 - TGEmbedPIPAngleEpsilon)
            {
                corner = TGEmbedPIPCornerTopLeft;
                shouldHide = false;
            }
            else if (angle < TGEmbedPIPAngleEpsilon || angle > 270 + TGEmbedPIPAngleEpsilon)
            {
                if (!shouldHide)
                    corner = TGEmbedPIPCornerBottomRight;
                else
                    shouldHide = false;
            }
            else if (angle > TGEmbedPIPAngleEpsilon && angle < 90 - TGEmbedPIPAngleEpsilon)
            {
                if (!shouldHide)
                    corner = TGEmbedPIPCornerTopRight;
                else
                    shouldHide = false;
            }
            else if (!shouldHide)
            {
                shouldHide = true;
            }
            break;
            
        case TGEmbedPIPCornerBottomRight:
            if (angle > TGEmbedPIPAngleEpsilon && angle < 90 + TGEmbedPIPAngleEpsilon)
            {
                corner = TGEmbedPIPCornerTopRight;
                shouldHide = false;
            }
            else if (angle > 180 - TGEmbedPIPAngleEpsilon && angle < 270 - TGEmbedPIPAngleEpsilon)
            {
                if (!shouldHide)
                    corner = TGEmbedPIPCornerBottomLeft;
                else
                    shouldHide = false;
            }
            else if (angle > 90 + TGEmbedPIPAngleEpsilon && angle < 180 - TGEmbedPIPAngleEpsilon)
            {
                if (!shouldHide)
                    corner = TGEmbedPIPCornerTopLeft;
                else
                    shouldHide = false;
            }
            else if (!shouldHide)
            {
                shouldHide = true;
            }
            break;
            
        default:
            break;
    }
    
    if (hide != NULL)
        *hide = shouldHide;
    
    return corner;
}

- (TGEmbedPIPCorner)targetCornerForLocation:(CGPoint)location hide:(bool *)hide
{
    bool right = false;
    bool bottom = false;
    
    if (location.x > self.view.frame.size.width / 2.0f)
        right = true;
    if (location.y > (self.view.frame.size.height - _keyboardHeight) / 2.0f)
        bottom = true;

    if (hide != NULL && (location.x < TGEmbedPIPViewMargin || location.x > self.view.frame.size.width - TGEmbedPIPViewMargin))
        *hide = true;
    
    if (!right && !bottom)
        return TGEmbedPIPCornerTopLeft;
    else if (right && !bottom)
        return TGEmbedPIPCornerTopRight;
    else if (!right && bottom)
        return TGEmbedPIPCornerBottomLeft;
    else
        return TGEmbedPIPCornerBottomRight;
}

#pragma mark -

static TGEmbedPIPController *activePIPController = nil;
static TGPIPSourceLocation *pipLocation = nil;
static void (^pipStartComlpetion)(void);
static void (^pipCompletion)(void);
static UIView<TGPIPAblePlayerView> *pipPlayerView;
static TGEmbedPIPCorner defaultCorner = TGEmbedPIPCornerTopRight;

+ (void)startPictureInPictureWithPlayerView:(UIView<TGPIPAblePlayerView> *)playerView location:(TGPIPSourceLocation *)location corner:(TGEmbedPIPCorner)corner onTransitionBegin:(void (^)(void))onTransitionBegin onTransitionFinished:(void (^)(void))onTransitionFinished
{
    if (location == nil || location.peerId == 0)
        return;
    
    if (activePIPController != nil && (activePIPController->_closing || [activePIPController->_location isEqual:location]))
        return;
    
    if (activePIPController != nil && activePIPController->_location.webPage && activePIPController->_location.webPage.webPageId == location.webPage.webPageId)
        [activePIPController cancel:true];
    else
        [self dismissPictureInPicture];
    
    if (corner == TGEmbedPIPCornerNone)
        corner = defaultCorner;
    
    if (!TGIsPad() || ![self isSystemPictureInPictureAvailable])
    {
        TGEmbedPIPController *controller = [[TGEmbedPIPController alloc] initWithPlayerView:playerView location:location corner:corner];
        controller.onTransitionBegin = onTransitionBegin;
        activePIPController = controller;
    }
    else
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            freedomPIPInit();
        });
    
        pipLocation = location;
        pipPlayerView = playerView;
        
        UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] firstObject];
        [playerView _requestSystemPictureInPictureMode];
        
        TGDispatchAfter(0.2, dispatch_get_main_queue(), ^
        {
            [mainWindow addSubview:playerView];
            
            CGRect frame = playerView.frame;
            frame.origin.x = -1000.0f;
            playerView.frame = frame;
            
            if (onTransitionBegin != nil)
                onTransitionBegin();
        });
        
        pipStartComlpetion = onTransitionFinished;
    }
}

+ (void)dismissPictureInPicture
{
    if (activePIPController != nil)
        [activePIPController dismissController];
    else if (pipPlayerView != nil)
        [self _systemPictureInPictureDidStop];
}

+ (void)resumePictureInPicturePlayback
{
    UIView<TGPIPAblePlayerView> *playerView = nil;
    if (activePIPController != nil)
        playerView = activePIPController->_playerView;
    else if (pipPlayerView != nil)
        playerView = pipPlayerView;
    
    [playerView resumePIPPlayback];
}

+ (void)pausePictureInPicturePlayback
{
    UIView<TGPIPAblePlayerView> *playerView = nil;
    if (activePIPController != nil)
        playerView = activePIPController->_playerView;
    else if (pipPlayerView != nil)
        playerView = pipPlayerView;
    
    [playerView pausePIPPlayback];
}

+ (void)hide
{
    if (activePIPController == nil)
        return;
    
    activePIPController.view.hidden = true;
    [self pausePictureInPicturePlayback];
}

+ (void)restore
{
    if (activePIPController == nil)
        return;
    
    activePIPController.view.hidden = false;
    [self resumePictureInPicturePlayback];
}

+ (bool)hasPictureInPictureActive
{
    return (activePIPController != nil || pipPlayerView != nil);
}

+ (bool)hasPictureInPictureActiveForLocation:(TGPIPSourceLocation *)location playerView:(UIView<TGPIPAblePlayerView> **)playerView
{
    bool hasPIP = (activePIPController != nil && [activePIPController->_location isEqual:location]) || (pipLocation != nil && [pipLocation isEqual:location]);
    
    if (playerView != NULL && hasPIP)
    {
        if (pipPlayerView != nil)
            *playerView = pipPlayerView;
        else if (activePIPController != nil)
            *playerView = activePIPController->_playerView;
    }
    
    return hasPIP;
}
            
+ (void)registerPlaceholderView:(TGEmbedPIPPlaceholderView *)view
{
    __weak TGEmbedPIPPlaceholderView *weakView = view;
    [[self placeholderViews] addObject:weakView];
}

+ (NSHashTable *)placeholderViews
{
    static dispatch_once_t onceToken;
    static NSHashTable *views;
    dispatch_once(&onceToken, ^
    {
        views = [NSHashTable weakObjectsHashTable];
    });
    return views;
}

+ (void)registerPlayerView:(UIView<TGPIPAblePlayerView> *)view
{
    __weak UIView<TGPIPAblePlayerView> *weakView = view;
    [[self playerViews] addObject:weakView];
    
    [self inhibitVolumeOverlay];
}

+ (NSHashTable *)playerViews
{
    static dispatch_once_t onceToken;
    static NSHashTable *views;
    dispatch_once(&onceToken, ^
    {
        views = [NSHashTable weakObjectsHashTable];
    });
    return views;
}

+ (bool)hasPlayerViews
{
    return [self playerViews].allObjects.count;
}

static MPVolumeView *volumeOverlayFixView;

+ (void)inhibitVolumeOverlay
{
    if (volumeOverlayFixView != nil)
        return;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *rootView = keyWindow.rootViewController.view;
    
    volumeOverlayFixView = [[MPVolumeView alloc] initWithFrame:CGRectMake(10000, 10000, 20, 20)];
    [rootView addSubview:volumeOverlayFixView];
}

+ (void)maybeReleaseVolumeOverlay
{
    if ([self hasPlayerViews])
        return;
    
    [volumeOverlayFixView removeFromSuperview];
    volumeOverlayFixView = nil;
}

+ (UIView<TGPIPAblePlayerView> *)activeNonPIPPlayerView
{
    if ([self hasPictureInPictureActive])
        return nil;
    
    __strong UIView<TGPIPAblePlayerView> *view = [[self playerViews] anyObject];
    if (view != nil && [view supportsPIP] && [view.state isPlaying])
        return view;
    
    return nil;
}

+ (TGEmbedPIPController *)currentInstance
{
    return activePIPController;
}

+ (void)_cancelSystemPIPWithCompletion:(void (^)(void))completion
{
    TGEmbedPIPPlaceholderView *view = [TGEmbedPIPController placeholderViewForLocation:pipLocation invisible:NULL];
    
    if (view != nil)
    {
        UIView<TGPIPAblePlayerContainerView> *containerView = view.containerView;
        [containerView reattachPlayerView:pipPlayerView];
        
        pipLocation = nil;
        pipPlayerView = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (completion != nil)
                completion();
            
            pipCompletion = nil;
        });
    }
    else
    {
        pipCompletion = [completion copy];
     
        [[TGInterfaceManager instance] navigateToConversationWithId:pipLocation.peerId conversation:nil performActions:nil atMessage:@{ @"mid": @(pipLocation.messageId), @"openMedia": @true, @"embed": @(pipLocation.embed), @"cancelPIP": @true, @"pipLocation": pipLocation } clearStack:true openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
    }
}

+ (void)cancelPictureInPictureWithOffset:(CGPoint)offset
{
    if (pipLocation != nil)
        [self _cancelSystemPIPWithCompletion:pipCompletion];
    else
        [[TGEmbedPIPController currentInstance] cancelWithOffset:offset reset:false];
}

+ (bool)isSystemPictureInPictureAvailable
{
    return iosMajorVersion() >= 9 && [AVPictureInPictureController isPictureInPictureSupported];
}

+ (void)_systemPictureInPictureDidStart
{
    if (pipStartComlpetion == nil)
        return;
    
    pipStartComlpetion();
    pipStartComlpetion = nil;
}

+ (void)_systemPictureInPictureDidStop
{
    pipLocation = nil;
    pipCompletion = nil;
    
    if (pipPlayerView != nil)
    {
        [pipPlayerView removeFromSuperview];
        pipPlayerView = nil;
    }
}

@end


@implementation TGEmbedPIPWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint localPoint = [[self.rootViewController view] convertPoint:point fromView:self];
    UIView *result = [[self.rootViewController view] hitTest:localPoint withEvent:event];
    if (result == self.rootViewController.view)
        return nil;
    
    return result;
}

@end

void freedomPIP_decorated(id self, SEL _cmd, id controller, id completion)
{
    static void (*nativeImpl)(id, SEL, id, id) = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        nativeImpl = (void *)freedomNativeImpl([self class], _cmd);
    });
    
    __strong id strongCompletion = [completion copy];
    
    [TGEmbedPIPController _cancelSystemPIPWithCompletion:^
    {
        if (nativeImpl != NULL)
            nativeImpl(self, _cmd, controller, strongCompletion);
    }];
}

void freedomPIP_decorated2(id self, SEL _cmd, id controller)
{
    static void (*nativeImpl)(id, SEL, id) = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        nativeImpl = (void *)freedomNativeImpl([self class], _cmd);
    });

    if (nativeImpl != NULL)
        nativeImpl(self, _cmd, controller);
    
    [TGEmbedPIPController _systemPictureInPictureDidStart];
}

void freedomPIP_decorated3(id self, SEL _cmd, id controller)
{
    static void (*nativeImpl)(id, SEL, id) = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        nativeImpl = (void *)freedomNativeImpl([self class], _cmd);
    });
    
    if (nativeImpl != NULL)
        nativeImpl(self, _cmd, controller);
    
    [TGEmbedPIPController _systemPictureInPictureDidStop];
}

void freedomPIPInit()
{
    FreedomDecoration instanceDecorations[] =
    {
        {
            .name = 0x74c6db05U,
            .imp = (IMP)&freedomPIP_decorated,
            .newIdentifier = FreedomIdentifierEmpty,
            .newEncoding = FreedomIdentifierEmpty
        },
        {
            .name = 0x41fcf084U,
            .imp = (IMP)&freedomPIP_decorated2,
            .newIdentifier = FreedomIdentifierEmpty,
            .newEncoding = FreedomIdentifierEmpty
        },
        {
            .name = 0xaae59802U,
            .imp = (IMP)&freedomPIP_decorated3,
            .newIdentifier = FreedomIdentifierEmpty,
            .newEncoding = FreedomIdentifierEmpty
        }
    };
    
    freedomClassAutoDecorate(0xf30012U, NULL, 0, instanceDecorations, sizeof(instanceDecorations) / sizeof(instanceDecorations[0]));
}


@implementation TGPIPSourceLocation

- (instancetype)initWithEmbed:(bool)embed peerId:(int64_t)peerId messageId:(int32_t)messageId localId:(int32_t)localId webPage:(TGWebPageMediaAttachment *)webPage
{
    self = [super init];
    if (self != nil)
    {
        _embed = embed;
        _peerId = peerId;
        _messageId = messageId;
        _localId = localId;
        _webPage = webPage;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return true;
    
    if (!object || ![object isKindOfClass:[self class]])
        return false;
    
    TGPIPSourceLocation *location = (TGPIPSourceLocation *)object;
    return _embed == location.embed && _peerId == location.peerId && _messageId == location.messageId && _localId == location.localId;
}

@end
