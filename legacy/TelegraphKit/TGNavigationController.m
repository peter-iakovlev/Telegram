#import "TGNavigationController.h"

#import "Freedom.h"

#import "TGNavigationBar.h"
#import "TGViewController.h"
#import "TGToolbarButton.h"

#import "TGHacks.h"

#import "TGAnimatedNavigationTransition.h"
#import "TGInteractiveNavigationTransition.h"
#import "TGRTLScreenEdgePanGestureRecognizer.h"

#import "TGImageUtils.h"

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface TGNavigationPercentTransition : UIPercentDrivenInteractiveTransition

@end

@interface TGNavigationController () <UINavigationControllerDelegate>
{
    UITapGestureRecognizer *_dimmingTapRecognizer;
    CGSize _preferredContentSize;
}

@property (nonatomic) bool wasShowingNavigationBar;

@property (nonatomic, strong) TGAutorotationLock *autorotationLock;

@end

@implementation TGNavigationController

+ (TGNavigationController *)navigationControllerWithRootController:(UIViewController *)controller
{
    return [self navigationControllerWithControllers:[NSArray arrayWithObject:controller]];
}

+ (TGNavigationController *)navigationControllerWithControllers:(NSArray *)controllers
{
    return [self navigationControllerWithControllers:controllers navigationBarClass:[TGNavigationBar class]];
}

+ (TGNavigationController *)navigationControllerWithControllers:(NSArray *)controllers navigationBarClass:(Class)navigationBarClass
{
    if (iosMajorVersion() >= 7)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            if ([TGViewController useExperimentalRTL])
            {
                InjectInstanceMethodFromAnotherClass([TGNavigationController class], [TGNavigationController class], @selector(replacedKeyboardDirection:arg2:), NSSelectorFromString(TGEncodeText(@"`lfzcpbseEjsfdujpoGpsUsbotjujpo;psefsjohJo;", -1)));
            }
        });
    }
    
    TGNavigationController *navigationController = [[TGNavigationController alloc] initWithNavigationBarClass:navigationBarClass toolbarClass:[UIToolbar class]];
    
    [navigationController setViewControllers:controllers];
    
    ((TGNavigationBar *)navigationController.navigationBar).navigationController = navigationController;
    
    return navigationController;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass
{
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    if (self != nil)
    {
        
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    [_dimmingTapRecognizer.view removeGestureRecognizer:_dimmingTapRecognizer];
}

- (void)loadView
{
    [super loadView];
    
    if ([TGViewController useExperimentalRTL])
        ((UIView *)self.view.subviews[0]).transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
    
    if ([TGViewController useExperimentalRTL])
    {
        SEL selector = NSSelectorFromString(TGEncodeText(@"`tdsffoFehfQboHftuvsfSfdphoj{fs", -1));
        if ([self respondsToSelector:selector])
        {
            UIScreenEdgePanGestureRecognizer *screenPanRecognizer = objc_msgSend(self, selector);
            if (screenPanRecognizer != nil)
            {
                screenPanRecognizer.edges = UIRectEdgeRight;
                object_setClass(screenPanRecognizer, [TGRTLScreenEdgePanGestureRecognizer class]);
            }
        }
    }
}

static UIView *findDimmingView(UIView *view)
{
    static NSString *encodedString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        encodedString = TGEncodeText(@"VJEjnnjohWjfx", -1);
    });
    
    if ([NSStringFromClass(view.class) isEqualToString:encodedString])
        return view;
    
    for (UIView *subview in view.subviews)
    {
        UIView *result = findDimmingView(subview);
        if (result != nil)
            return result;
    }
    
    return nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.modalPresentationStyle == UIModalPresentationFormSheet)
    {
        UIView *dimmingView = findDimmingView(self.view.window);
        bool tapSetup = false;
        if (_dimmingTapRecognizer != nil)
        {
            for (UIGestureRecognizer *recognizer in dimmingView.gestureRecognizers)
            {
                if (recognizer == _dimmingTapRecognizer)
                {
                    tapSetup = true;
                    break;
                }
            }
        }
        
        if (!tapSetup)
        {
            _dimmingTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)];
            [dimmingView addGestureRecognizer:_dimmingTapRecognizer];
        }
    }
}

- (void)dimmingViewTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize screenSize = TGScreenSize();
    static Class containerClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        containerClass = freedomClass(0xf045e5dfU);
    });
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:containerClass])
        {
            CGRect frame = view.frame;
            
            if (ABS(frame.size.width - screenSize.width) < FLT_EPSILON)
            {
                if (ABS(frame.size.height - screenSize.height + 20) < FLT_EPSILON)
                {
                    frame.origin.y = frame.size.height - screenSize.height;
                    frame.size.height = screenSize.height;
                }
                else if (frame.size.height > screenSize.height + FLT_EPSILON)
                {
                    frame.origin.y = 0;
                    frame.size.height = screenSize.height;
                }
            }
            else if (ABS(frame.size.width - screenSize.height) < FLT_EPSILON)
            {
                if (frame.size.height > screenSize.width + FLT_EPSILON)
                {
                    frame.origin.y = 0;
                    frame.size.height = screenSize.width;
                }
            }
            
            if (!CGRectEqualToRect(view.frame, frame))
                view.frame = frame;
            
            break;
        }
    }
}

- (void)viewDidLoad
{   
    self.delegate = self;
    
    [super viewDidLoad];
}

- (void)updateControllerLayout:(bool)__unused animated
{
    /*UIBarStyle barStyle = UIBarStyleDefault;
     bool navigationBarShouldBeHidden = false;
     UIStatusBarStyle statusBarStyle = UIStatusBarStyleBlackOpaque;
     bool statusBarShouldBeHidden = false;
     if ([self.topViewController conformsToProtocol:@protocol(TGViewControllerNavigationBarAppearance)])
     {
     id<TGViewControllerNavigationBarAppearance> appearance = (id<TGViewControllerNavigationBarAppearance>)self.topViewController;
     barStyle = [appearance requiredNavigationBarStyle];
     navigationBarShouldBeHidden = [appearance navigationBarShouldBeHidden];
     if ([appearance respondsToSelector:@selector(viewControllerPreferredStatusBarStyle)])
     statusBarStyle = [appearance viewControllerPreferredStatusBarStyle];
     if ([appearance respondsToSelector:@selector(statusBarShouldBeHidden)])
     statusBarShouldBeHidden = [appearance statusBarShouldBeHidden];
     }
     
     if ([self.navigationBar barStyle] != barStyle)
     [(TGNavigationBar *)self.navigationBar setBarStyle:barStyle animated:(_wasShowingNavigationBar == !self.navigationBarHidden)];
     if ([[UIApplication sharedApplication] isStatusBarHidden] != statusBarShouldBeHidden)
     [[UIApplication sharedApplication] setStatusBarHidden:statusBarShouldBeHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
     if ([[UIApplication sharedApplication] statusBarStyle] != statusBarStyle)
     [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:animated];*/
    
    //[self setNavigationBarHidden:!self.navigationBarHidden animated:false];
    //[self setNavigationBarHidden:!self.navigationBarHidden animated:false];
}

- (void)setupNavigationBarForController:(UIViewController *)viewController animated:(bool)animated
{
    UIBarStyle barStyle = UIBarStyleDefault;
    bool navigationBarShouldBeHidden = false;
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleBlackOpaque;
    bool statusBarShouldBeHidden = false;
    
    if ([viewController conformsToProtocol:@protocol(TGViewControllerNavigationBarAppearance)])
    {
        id<TGViewControllerNavigationBarAppearance> appearance = (id<TGViewControllerNavigationBarAppearance>)viewController;
        
        barStyle = [appearance requiredNavigationBarStyle];
        navigationBarShouldBeHidden = [appearance navigationBarShouldBeHidden];
        if ([appearance respondsToSelector:@selector(preferredStatusBarStyle)])
            statusBarStyle = [appearance preferredStatusBarStyle];
        if ([appearance respondsToSelector:@selector(statusBarShouldBeHidden)])
            statusBarShouldBeHidden = [appearance statusBarShouldBeHidden];
    }
    
    if (navigationBarShouldBeHidden != self.navigationBarHidden)
    {
        [self setNavigationBarHidden:navigationBarShouldBeHidden animated:animated];
    }
    
    if ([[UIApplication sharedApplication] isStatusBarHidden] != statusBarShouldBeHidden)
        [[UIApplication sharedApplication] setStatusBarHidden:statusBarShouldBeHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    if ([[UIApplication sharedApplication] statusBarStyle] != statusBarStyle)
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (_restrictLandscape)
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    
    if (self.topViewController != nil)
        return [self.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)shouldAutorotate
{
    if (_restrictLandscape)
        return false;
    
    if (self.topViewController != nil)
    {
        if ([self.topViewController respondsToSelector:@selector(shouldAutorotate)])
        {
            if (![self.topViewController shouldAutorotate])
                return false;
        }
    }
    
    bool result = [super shouldAutorotate];
    if (!result)
        return false;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        UIGestureRecognizerState state = self.interactivePopGestureRecognizer.state;
        if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
            return false;
    }
    
    return true;
}

- (void)acquireRotationLock
{
    if (_autorotationLock == nil)
        _autorotationLock = [[TGAutorotationLock alloc] init];
}

- (void)releaseRotationLock
{
    _autorotationLock = nil;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (_restrictLandscape)
        return UIInterfaceOrientationMaskPortrait;
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!hidden)
        self.navigationBar.alpha = 1.0f;
    
    [(TGNavigationBar *)self.navigationBar setHiddenState:hidden animated:animated];
    
    [super setNavigationBarHidden:hidden animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    _isInControllerTransition = true;
    [super pushViewController:viewController animated:animated];
    _isInControllerTransition = false;
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    _isInControllerTransition = true;
    [super setViewControllers:viewControllers animated:animated];
    _isInControllerTransition = false;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (animated)
    {
        static ptrdiff_t controllerOffset = -1;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            controllerOffset = freedomIvarOffset([UINavigationController class], 0xb281e8fU);
        });
        
        if (controllerOffset != -1)
        {
            __unsafe_unretained NSObject **controller = (__unsafe_unretained NSObject **)(void *)(((uint8_t *)(__bridge void *)self) + controllerOffset);
            if (*controller != nil)
            {
                static Class decoratedClass = Nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^
                {
                   decoratedClass = freedomMakeClass([*controller class], [TGNavigationPercentTransition class]);
                });
                
                if (decoratedClass != Nil && ![*controller isKindOfClass:decoratedClass])
                    object_setClass(*controller, decoratedClass);
            }
        }
    }
    
    _isInPopTransition = true;
    UIViewController *result = [super popViewControllerAnimated:animated];
    _isInPopTransition = false;
    
    return result;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    for (NSUInteger i = self.viewControllers.count - 1; i >= 1; i--)
    {
        UIViewController *viewController = self.viewControllers[i];
        if (viewController.presentedViewController != nil)
            [viewController dismissViewControllerAnimated:false completion:nil];
    }
    
    return [super popToRootViewControllerAnimated:animated];
}

TGNavigationController *findNavigationControllerInWindow(UIWindow *window)
{
    if ([window.rootViewController isKindOfClass:[TGNavigationController class]])
        return (TGNavigationController *)window.rootViewController;
    
    return nil;
}

TGNavigationController *findNavigationController()
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (int i = windows.count - 1; i >= 0; i--)
    {
        TGNavigationController *result = findNavigationControllerInWindow(windows[i]);
        if (result != nil)
            return result;
    }
    
    return nil;
}

- (CGFloat)myNominalTransitionAnimationDuration
{
    return 0.2f;
}

- (int)replacedKeyboardDirection:(int)arg1 arg2:(BOOL)arg2
{
    static SEL selector = NULL;
    static int (*impl)(id, SEL, int, BOOL) = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        selector = NSSelectorFromString(TGEncodeText(@"`lfzcpbseEjsfdujpoGpsUsbotjujpo;psefsjohJo;", -1));
        Method method = class_getInstanceMethod([UINavigationController class], selector);
        impl = (int (*)(id, SEL, int, BOOL))method_getImplementation(method);
    });
    
    int result = 1;
    if (impl != NULL)
        result = impl(self, selector, arg1, arg2);
    
    if ([TGViewController useExperimentalRTL])
    {
        if (result == 1)
            result = 2;
        else if (result == 2)
            result = 1;
    }
    
    return result;
}

- (void)setPreferredContentSize:(CGSize)preferredContentSize
{
    _preferredContentSize = preferredContentSize;
}

- (CGSize)preferredContentSize
{
    return _preferredContentSize;
}

@end

@implementation TGNavigationPercentTransition

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    TGNavigationController *navigationController = findNavigationController();
    if (navigationController != nil)
    {
        if (!navigationController.disableInteractiveKeyboardTransition && [TGHacks applicationKeyboardWindow] != nil && ![TGHacks applicationKeyboardWindow].hidden)
        {
            CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:navigationController.interfaceOrientation];
            CGFloat keyboardOffset = MAX(0.0f, percentComplete * screenSize.width);
            
            if ([TGViewController useExperimentalRTL])
                keyboardOffset = -keyboardOffset;
            
            UIView *keyboardView = [TGHacks applicationKeyboardView];
            CGRect keyboardViewFrame = keyboardView.frame;
            keyboardViewFrame.origin.x = keyboardOffset;
            
            keyboardView.frame = keyboardViewFrame;
        }
    }
    
    [super updateInteractiveTransition:percentComplete];
}

- (void)finishInteractiveTransition
{
    CGFloat value = self.percentComplete;
    UIView *keyboardView = [TGHacks applicationKeyboardView];
    CGRect keyboardViewFrame = keyboardView.frame;
    
    [super finishInteractiveTransition];
    
    TGNavigationController *navigationController = findNavigationController();
    if (navigationController != nil)
    {
        if (!navigationController.disableInteractiveKeyboardTransition)
        {
            keyboardView.frame = keyboardViewFrame;
            
            CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:navigationController.interfaceOrientation];
            CGFloat keyboardOffset = 1.0f * screenSize.width;
            if ([TGViewController useExperimentalRTL])
                keyboardOffset = -keyboardOffset;
            
            keyboardViewFrame.origin.x = keyboardOffset;
            NSTimeInterval duration = (1.0 - value) * [navigationController myNominalTransitionAnimationDuration];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^
             {
                 keyboardView.frame = keyboardViewFrame;
             } completion:nil];
        }
    }
}

- (void)cancelInteractiveTransition
{
    CGFloat value = self.percentComplete;
    
    TGNavigationController *navigationController = findNavigationController();
    if (navigationController != nil)
    {
        if (!navigationController.disableInteractiveKeyboardTransition && [TGHacks applicationKeyboardWindow] != nil && ![TGHacks applicationKeyboardWindow].hidden)
        {
            UIView *keyboardView = [TGHacks applicationKeyboardView];
            CGRect keyboardViewFrame = keyboardView.frame;
            keyboardViewFrame.origin.x = 0.0f;
            
            NSTimeInterval duration = value * [navigationController myNominalTransitionAnimationDuration];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^
             {
                 keyboardView.frame = keyboardViewFrame;
             } completion:nil];
        }
    }
    
    [super cancelInteractiveTransition];
}

@end
