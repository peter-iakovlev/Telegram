#import "TGNotificationWindow.h"

#import "TGViewController.h"
#import "ActionStage.h"
#import "TGObserverProxy.h"

#import "TGAppDelegate.h"

#import <QuartzCore/QuartzCore.h>

@implementation TGOverlayWindowViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIViewController *topViewController = ((UINavigationController *)TGAppDelegateInstance.mainNavigationController).topViewController;
    if ([topViewController isKindOfClass:[UITabBarController class]])
        topViewController = [(UITabBarController *)topViewController selectedViewController];
    UIStatusBarStyle style = [topViewController preferredStatusBarStyle];
    return style;
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
    
    if (TGAppDelegateInstance.mainNavigationController.presentedViewController != nil)
        return [TGAppDelegateInstance.mainNavigationController.presentedViewController shouldAutorotate];

    return [TGAppDelegateInstance.mainNavigationController shouldAutorotate];
}

- (void)loadView
{
    [super loadView];
    
    self.view.userInteractionEnabled = false;
    self.view.opaque = false;
    self.view.backgroundColor = [UIColor clearColor];
}

@end

@interface TGNotificationWindow ()
{
    bool _isSwipeDismissing;
}

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) TGObserverProxy *statusBarOrientationChangeProxy;

@end

@implementation TGNotificationWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.rootViewController = [[TGOverlayWindowViewController alloc] init];
        
        self.clipsToBounds = false;
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20 + 44)];
        _containerView.layer.anchorPoint = CGPointMake(0.5f, 0.0f);
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _containerView.opaque = false;
        [self addSubview:_containerView];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [self addGestureRecognizer:panRecognizer];
        
        self.exclusiveTouch = true;
        
        _statusBarOrientationChangeProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(orientationWillBeChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification];
    }
    return self;
}

- (void)orientationWillBeChanged:(NSNotification *)notification
{
    UIInterfaceOrientation fromOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    NSNumber *nNewOrientation = [notification.userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey];
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[nNewOrientation intValue];
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self willRotateToInterfaceOrientation:orientation fromOrientation:fromOrientation duration:UIInterfaceOrientationIsLandscape(orientation) == UIInterfaceOrientationIsLandscape( fromOrientation) ? 0.6 : 0.3];
    });
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation fromOrientation:(UIInterfaceOrientation)__unused fromOrientation duration:(NSTimeInterval)duration
{
    for (UIView *view in self.subviews)
    {
        if (view != _containerView)
            view.hidden = true;
    }
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    [UIView animateWithDuration:duration animations:^
    {
        if (orientation == UIDeviceOrientationPortrait)
        {
            self.layer.anchorPoint = CGPointMake(0.5f, (screenSize.height / 2) / _windowHeight);
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            self.transform = transform;
            self.frame = CGRectMake(0, 0, screenSize.width, _windowHeight);
        }
        else if (orientation == UIDeviceOrientationLandscapeLeft)
        {
            self.layer.anchorPoint = CGPointMake(0.5f, (screenSize.width / 2) / _windowHeight);
            
            CGAffineTransform transform = CGAffineTransformMakeRotation((float)M_PI_2);
            self.transform = transform;
            
            CGRect bounds = self.bounds;
            bounds.size.width = screenSize.height;
            self.bounds = bounds;
        }
        else if (orientation == UIDeviceOrientationLandscapeRight)
        {
            self.layer.anchorPoint = CGPointMake(0.5f, (screenSize.width / 2) / _windowHeight);
            
            CGAffineTransform transform = CGAffineTransformMakeRotation((float)-M_PI_2);
            self.transform = transform;
            
            CGRect bounds = self.bounds;
            bounds.size.width = screenSize.height;
            self.bounds = bounds;
        }
    }];
}

- (void)adjustToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    if (orientation == UIInterfaceOrientationPortrait)
    {
        self.layer.anchorPoint = CGPointMake(0.5f, (screenSize.height / 2) / _windowHeight);
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        self.transform = transform;
        self.frame = CGRectMake(0, 0, screenSize.width, _windowHeight);
	}
    else if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        if (CGRectIsEmpty(self.frame))
            [self adjustToInterfaceOrientation:UIInterfaceOrientationPortrait];
        
        self.layer.anchorPoint = CGPointMake(0.5f, (screenSize.width / 2) / _windowHeight);
        
        CGAffineTransform transform = CGAffineTransformMakeRotation((float)M_PI_2);
        self.transform = transform;
        
        CGRect bounds = self.bounds;
        bounds.size.width = screenSize.height;
        self.bounds = bounds;
	}
    else if (orientation == UIInterfaceOrientationLandscapeRight)
    {
        if (CGRectIsEmpty(self.frame))
            [self adjustToInterfaceOrientation:UIInterfaceOrientationPortrait];
        
        self.layer.anchorPoint = CGPointMake(0.5f, (screenSize.width / 2) / _windowHeight);
        
        CGAffineTransform transform = CGAffineTransformMakeRotation((float)-M_PI_2);
        self.transform = transform;
        
        CGRect bounds = self.bounds;
        bounds.size.width = screenSize.height;
        self.bounds = bounds;
	}
}

- (void)setContentView:(UIView *)view
{
    [_contentView removeFromSuperview];
    
    _contentView = view;
    
    view.frame = _containerView.bounds;
    [_containerView addSubview:view];
}

- (void)animateIn
{
    _isDismissed = false;
    
    CGRect frame = _containerView.layer.frame;
    frame.origin.x = 0;
    _containerView.layer.frame = frame;
    frame.origin = CGPointZero;
    if (self.hidden || !CGRectEqualToRect(_containerView.layer.frame, frame))
    {
        /*CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0f / -1000.0f;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 89.0f * (float)M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
        rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0, -frame.size.height, 0);
        
        _containerView.layer.transform = rotationAndPerspectiveTransform;*/
        
        self.hidden = false;
        
        CGRect startFrame = frame;
        startFrame.origin.y = -frame.size.height;
        _containerView.layer.frame = startFrame;
        
        [UIView animateWithDuration:0.3 animations:^
        {
            //_containerView.layer.transform = CATransform3DIdentity;
            _containerView.layer.frame = frame;
        }];
    }
}

- (void)animateOut
{
    _isDismissed = true;
    
    if (self.hidden)
        return;
    
    CGRect frame = _containerView.layer.frame;
    frame.origin.y = -frame.size.height;
    [UIView animateWithDuration:0.3 animations:^
    {
        _containerView.layer.frame = frame;
    } completion:^(__unused BOOL finished)
    {
        self.hidden = true;
    }];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (!_isDismissed)
        {
            CGRect frame = _containerView.frame;
            frame.origin.x = [recognizer translationInView:self].x;
            _containerView.frame = frame;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        float velocity = [recognizer velocityInView:self].x;
        
        //TGLog(@"Velocity: %f", velocity);
        
        if (ABS(velocity) < 120.0f)
        {
            CGRect frame = _containerView.frame;
            frame.origin.x = 0;
            [UIView animateWithDuration:0.3 animations:^
            {
                _containerView.frame = frame;
            }];
        }
        else
        {
            if (ABS(velocity) < 300)
                velocity = velocity < 0 ? -300 : 300;
            
            CGRect frame = _containerView.frame;
            if (velocity < 0)
                frame.origin.x = -frame.size.width;
            else
                frame.origin.x = frame.size.width;
            
            NSTimeInterval duration = ABS(frame.origin.x - _containerView.frame.origin.x) / ABS(velocity);
            
            _isSwipeDismissing = true;
            [UIView animateWithDuration:duration animations:^
            {
                _containerView.frame = frame;
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    _isSwipeDismissing = false;
                    self.hidden = true;
                }
            }];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isSwipeDismissing)
    {
        CGRect frame = _containerView.frame;
        frame.origin.x = 0;
        [UIView animateWithDuration:0.3 animations:^
        {
            _containerView.frame = frame;
        }];
    }
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isSwipeDismissing)
    {
        CGRect frame = _containerView.frame;
        frame.origin.x = 0;
        [UIView animateWithDuration:0.3 animations:^
        {
            _containerView.frame = frame;
        }];
    }
    
    [super touchesCancelled:touches withEvent:event];
}

- (void)performTapAction
{
    if (_isDismissed)
        return;
    
    [self animateOut];
    
    id<ASWatcher> watcher = _watcher.delegate;
    if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
    {
        [watcher actionStageActionRequested:_watcherAction options:_watcherOptions];
        
        _watcher = nil;
        _watcherAction = nil;
        _watcherOptions = nil;
    }
}

- (void)setFrame:(CGRect)frame
{
    frame.origin.y = 0;
    frame.size.height = 20 + 44;
    [super setFrame:frame];
    
    self.rootViewController.view.frame = self.bounds;
}

- (BOOL)_canBecomeKeyWindow
{
    return false;
}

@end
