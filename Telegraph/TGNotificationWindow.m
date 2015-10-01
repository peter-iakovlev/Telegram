#import "TGNotificationWindow.h"

#import "TGViewController.h"
#import "ActionStage.h"
#import "TGObserverProxy.h"

#import "TGAppDelegate.h"

#import <QuartzCore/QuartzCore.h>

@implementation TGOverlayWindowViewController

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
    UIStatusBarStyle style = [[self statusBarAppearanceSourceController] preferredStatusBarStyle];
    return style;
}

- (BOOL)prefersStatusBarHidden
{
    bool value = [[self statusBarAppearanceSourceController] prefersStatusBarHidden];
    return value;
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.view.window.layer removeAnimationForKey:@"backgroundColor"];
    [CATransaction begin];
    [CATransaction setDisableActions:true];
    self.view.window.layer.backgroundColor = [UIColor clearColor].CGColor;
    [CATransaction commit];
    
    for (UIView *view in self.view.window.subviews)
    {
        if (view != self.view)
        {
            [view removeFromSuperview];
            break;
        }
    }
}

- (void)loadView
{
    [super loadView];
    
    self.view.userInteractionEnabled = false;
    self.view.opaque = false;
    self.view.backgroundColor = [UIColor clearColor];
}

@end

@interface TGNotificationWindowView : UIView
{
    bool _isSwipeDismissing;
}

@property (nonatomic, weak) UIWindow *weakWindow;
@property (nonatomic) bool isDismissed;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation TGNotificationWindowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20 + 44)];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _containerView.opaque = false;
        [self addSubview:_containerView];
        
        _containerView.exclusiveTouch = true;
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [_containerView addGestureRecognizer:panRecognizer];
    }
    return self;
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
    
    UIWindow *window = _weakWindow;
    
    CGRect frame = _containerView.frame;
    frame.origin.x = 0;
    _containerView.frame = frame;
    frame.origin = CGPointZero;
    if (window.hidden || !CGRectEqualToRect(_containerView.frame, frame))
    {
        window.hidden = false;
        
        CGRect startFrame = frame;
        startFrame.origin.y = -frame.size.height;
        _containerView.frame = startFrame;
        
        [UIView animateWithDuration:0.3 animations:^
         {
             _containerView.frame = frame;
         }];
    }
}

- (void)animateOut
{
    _isDismissed = true;
    
    UIWindow *window = _weakWindow;
    
    if (window.hidden)
        return;
    
    CGRect frame = _containerView.frame;
    frame.origin.y = -frame.size.height;
    [UIView animateWithDuration:0.3 animations:^
     {
         _containerView.frame = frame;
     } completion:^(__unused BOOL finished)
     {
         window.hidden = true;
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
        CGFloat velocity = [recognizer velocityInView:self].x;
        
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
                     
                    UIWindow *window = _weakWindow;
                     window.hidden = true;
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

@end

@interface TGNotificationWindowController : TGOverlayWindowViewController

@property (nonatomic, strong) TGNotificationWindowView *notificationView;
@property (nonatomic, weak) UIWindow *weakWindow;

@end

@implementation TGNotificationWindowController

- (void)loadView
{
    [super loadView];
    
    _notificationView = [[TGNotificationWindowView alloc] initWithFrame:self.view.bounds];
    _notificationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _notificationView.weakWindow = _weakWindow;
    [self.view addSubview:_notificationView];
}

- (TGNotificationWindowView *)notificationView
{
    if (![self isViewLoaded])
        [self loadView];
    
    return _notificationView;
}

@end

@interface TGNotificationWindow ()

@end

@implementation TGNotificationWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        TGNotificationWindowController *controller = [[TGNotificationWindowController alloc] init];
        controller.weakWindow = self;
        self.rootViewController = controller;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint localPoint = [((TGNotificationWindowController *)self.rootViewController).notificationView convertPoint:point fromView:self];
    UIView *result = [((TGNotificationWindowController *)self.rootViewController).notificationView hitTest:localPoint withEvent:event];
    if (result == ((TGNotificationWindowController *)self.rootViewController).notificationView || result == self.rootViewController.view)
        return nil;
    
    return result;
}

- (void)setContentView:(UIView *)view
{
    [((TGNotificationWindowController *)self.rootViewController).notificationView setContentView:view];
}

- (UIView *)contentView
{
    return [((TGNotificationWindowController *)self.rootViewController).notificationView contentView];
}

- (void)animateIn
{
    [((TGNotificationWindowController *)self.rootViewController).notificationView animateIn];
}

- (void)animateOut
{
    [((TGNotificationWindowController *)self.rootViewController).notificationView animateOut];
}

- (BOOL)_canBecomeKeyWindow
{
    return false;
}

- (bool)isDismissed
{
    return [((TGNotificationWindowController *)self.rootViewController).notificationView isDismissed];
}

- (void)performTapAction
{
    if ([self isDismissed])
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
    [super setFrame:frame];
}

@end
