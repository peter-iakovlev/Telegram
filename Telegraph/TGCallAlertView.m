#import "TGCallAlertView.h"

#import <LegacyComponents/LegacyComponents.h>
#import "TGLegacyComponentsGlobalsProvider.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGDefaultPresentationPallete.h"

#import <LegacyComponents/TGObserverProxy.h>

#import <LegacyComponents/TGModernButton.h>

#import "TGLegacyComponentsContext.h"
#import "TGPresentation.h"

const CGFloat TGCallAlertViewWidth = 270.0f;
const CGFloat TGCallAlertViewButtonHeight = 44.0f;

@interface TGCallAlertView ()
{
    bool _wide;
    UIButton *_dimView;
    UIView *_backgroundView;
    UILabel *_titleLabel;
    UIView *_customView;
    UIView *_horizontalSeparator;
    UIView *_verticalSeparator;
    TGModernButton *_cancelButton;
    TGModernButton *_doneButton;
    
    bool _dismissed;
    
    void (^_completionBlock)(bool);
    
    CGFloat _keyboardOffset;
    id _keyboardWillChangeFrameProxy;
}

@property (nonatomic, copy) void (^onDismiss)(void);

@end

@implementation TGCallAlertView

- (instancetype)initWithTitle:(NSString *)title message:(id)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle completionBlock:(void (^)(bool))completionBlock
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        self.alpha = 0.0f;
        self.tag = 0xbeef;
        _completionBlock = [completionBlock copy];
        
        _dimView = [[UIButton alloc] init];
        _dimView.exclusiveTouch = true;
        _dimView.backgroundColor = UIColorRGBA(0x000000, 0.4f);
        [_dimView addTarget:self action:@selector(dimPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_dimView];
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        _backgroundView.layer.rasterizationScale = TGScreenScaling();
        _backgroundView.layer.shouldRasterize = true;
        _backgroundView.layer.cornerRadius = 12.0f;
        _backgroundView.layer.masksToBounds = true;
        [self addSubview:_backgroundView];
        
        NSUInteger messageLength = 0;
        if ([message isKindOfClass:[NSString class]]) {
            messageLength = [message length];
        }
        else if ([message isKindOfClass:[NSAttributedString class]]) {
            messageLength = [message length];
            _wide = true;
        }
        
        CGFloat inset = 20.0f;
//        if (_wide && [self alertWidth] < 310)
//            inset = 16.0f;
        
        if (title.length > 0)
        {
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.backgroundColor = [UIColor whiteColor];
            _titleLabel.font = TGMediumSystemFontOfSize(17.0f);
            _titleLabel.numberOfLines = 0;
            _titleLabel.text = title;
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.textColor = [UIColor blackColor];
            [_titleLabel sizeToFit];
            [_backgroundView addSubview:_titleLabel];
            
            CGSize size = [_titleLabel sizeThatFits:CGSizeMake([self alertWidth] - inset * 2, FLT_MAX)];
            _titleLabel.frame = CGRectMake(0.0f, 0.0f, ceil(size.width), ceil(size.height));
        }
        
        if (customView != nil)
        {
            _customView = customView;
            [_backgroundView addSubview:_customView];
        }
        
        TGPresentation *presentation = TGTelegraphInstance.clientUserId == 0 ? [TGPresentation defaultPresentation] : TGPresentation.current;
        
        if (messageLength > 0)
        {
            _messageLabel = [[UILabel alloc] init];
            _messageLabel.backgroundColor = [UIColor whiteColor];
            _messageLabel.font = TGSystemFontOfSize(13.0f);
            _messageLabel.numberOfLines = 0;
            
            if ([message isKindOfClass:[NSString class]])
            {
                _messageLabel.text = message;
                _messageLabel.textAlignment = NSTextAlignmentCenter;
                _messageLabel.textColor = presentation.pallete.menuTextColor;
            }
            else if ([message isKindOfClass:[NSAttributedString class]])
            {
                _messageLabel.attributedText = message;
            }
            
            [_messageLabel sizeToFit];
            [_backgroundView addSubview:_messageLabel];
            
            CGSize size = [_messageLabel sizeThatFits:CGSizeMake([self alertWidth] - inset * 2, FLT_MAX)];
            _messageLabel.frame = CGRectMake(0.0f, 0.0f, ceil(size.width), ceil(size.height));
        }
        
        _cancelButton = [[TGModernButton alloc] init];
        _cancelButton.exclusiveTouch = true;
        _cancelButton.titleLabel.font = self.cancelIsBold ? TGBoldSystemFontOfSize(17.0f) : TGSystemFontOfSize(17.0f);
        _cancelButton.highlightBackgroundColor = UIColorRGB(0xebebeb);
        [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [_cancelButton setTitleColor:TGAccentColor()];
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_cancelButton];
        
        _horizontalSeparator = [[UIView alloc] init];
        _horizontalSeparator.backgroundColor = UIColorRGB(0xc3c3c8);
        _horizontalSeparator.userInteractionEnabled = false;
        [_backgroundView addSubview:_horizontalSeparator];
     
        if (doneButtonTitle.length > 0)
        {
            _doneButton = [[TGModernButton alloc] init];
            _doneButton.exclusiveTouch = true;
            _doneButton.titleLabel.font = !self.cancelIsBold ? TGBoldSystemFontOfSize(17.0f) : TGSystemFontOfSize(17.0f);
            _doneButton.highlightBackgroundColor = UIColorRGB(0xebebeb);
            [_doneButton setTitle:doneButtonTitle forState:UIControlStateNormal];
            [_doneButton setTitleColor:TGAccentColor()];
            [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [_backgroundView addSubview:_doneButton];
            
            _verticalSeparator = [[UIView alloc] init];
            _verticalSeparator.backgroundColor = UIColorRGB(0xc3c3c8);
            _verticalSeparator.userInteractionEnabled = false;
            [_backgroundView addSubview:_verticalSeparator];
        }
        
        _backgroundView.backgroundColor = presentation.pallete.menuBackgroundColor;
        _titleLabel.textColor = presentation.pallete.menuTextColor;
        _titleLabel.backgroundColor = _backgroundView.backgroundColor;
        
        _messageLabel.backgroundColor = _backgroundView.backgroundColor;
        
        [_cancelButton setTitleColor:presentation.pallete.menuAccentColor];
        _cancelButton.highlightBackgroundColor = presentation.pallete.menuSelectionColor;
        [_doneButton setTitleColor:presentation.pallete.menuAccentColor];
        _doneButton.highlightBackgroundColor = presentation.pallete.menuSelectionColor;
        
        _horizontalSeparator.backgroundColor = presentation.pallete.menuSeparatorColor;
        _verticalSeparator.backgroundColor = presentation.pallete.menuSeparatorColor;
    }
    return self;
}

- (CGFloat)alertWidth
{
    CGFloat width = TGCallAlertViewWidth;
//    if (_wide)
//        width = MIN(320, TGScreenSize().width - 20.0f);
    return width;
}

- (void)setFollowsKeyboard:(bool)followsKeyboard
{
    _followsKeyboard = followsKeyboard;

    if (followsKeyboard)
    {
        _keyboardWillChangeFrameProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification];
    }
    else
    {
        _keyboardWillChangeFrameProxy = nil;
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSTimeInterval duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil ? 0.3 : [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect screenKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrame = [self.superview convertRect:screenKeyboardFrame fromView:nil];
    
    CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0.0f : (self.superview.frame.size.height - keyboardFrame.origin.y);
    keyboardHeight = MAX(keyboardHeight, 0.0f);
    _keyboardOffset = keyboardHeight;

    if (self.followsKeyboard)
    {
        if (duration >= FLT_EPSILON)
        {
            [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^
            {
                [self layoutSubviews];
            } completion:nil];
        }
        else
        {
            [self layoutSubviews];
        }
    }
}

- (void)updateCustomViewHeight:(CGFloat)height
{
    _customView.frame = CGRectMake(_customView.frame.origin.x, _customView.frame.origin.y, _customView.frame.size.width, height);
    [self layoutSubviews];
}

- (void)cancelButtonPressed
{
    [self dismiss:false];
}

- (void)doneButtonPressed
{
    [self dismiss:true];
}

- (void)dimPressed
{
    if (self.shouldDismissOnDimTap != nil)
    {
        if (self.shouldDismissOnDimTap())
            [self dismiss:false fromDim:true animated:true];
    }
    else
    {
        [self dismiss:false fromDim:true animated:true];
    }
}

- (void)present
{
    [UIView animateWithDuration:0.2 animations:^
    {
        self.alpha = 1.0f;
    }];
    
    _backgroundView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
    {
        _backgroundView.transform = CGAffineTransformIdentity;
    } completion:^(__unused BOOL finished)
    {
        
    }];
}

- (void)dismiss:(bool)done
{
    [self dismiss:done fromDim:false animated:true];
}

- (void)dismiss:(bool)done fromDim:(bool)fromDim animated:(bool)animated
{
    if (_dismissed)
        return;
    
    _dismissed = true;
    self.userInteractionEnabled = false;
    
    if (animated)
    {
        [UIView animateWithDuration:0.2 animations:^
        {
            self.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            if (_onDismiss != nil)
                _onDismiss();
        }];
    }
    else
    {
        self.alpha = 0.0f;
        if (_onDismiss != nil)
            _onDismiss();
    }
    
    if (!fromDim || !self.noActionOnDimTap)
    {
        if (_completionBlock != nil)
            _completionBlock(done);
    }
}

- (void)layoutSubviews
{
    _dimView.frame = self.bounds;
    bool isLandscape = self.bounds.size.width > self.bounds.size.height;
    
    CGFloat width = [self alertWidth];
    CGFloat height = 20.0f;
    
    if (_titleLabel != nil)
    {
        _titleLabel.frame = CGRectMake((width - _titleLabel.frame.size.width) / 2.0f, height, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
        height = CGRectGetMaxY(_titleLabel.frame);
        
        if (_customView != nil || _messageLabel != nil)
            height += 13.0f;
    }
    
    if (_customView != nil)
    {
        _customView.frame = CGRectMake((width - _customView.frame.size.width) / 2.0f, height, _customView.frame.size.width, _customView.frame.size.height);
        
        height = CGRectGetMaxY(_customView.frame);
        
        if (_messageLabel != nil)
            height += 15.0f;
    }
    
    if (_messageLabel != nil)
    {
        if (_customView == nil && _titleLabel != nil)
            height -= 9.0f;
        
        _messageLabel.frame = CGRectMake((width - _messageLabel.frame.size.width) / 2.0f, height, _messageLabel.frame.size.width, _messageLabel.frame.size.height);
        
        height = CGRectGetMaxY(_messageLabel.frame);
    }
    
    height += 20.0f;
    
    CGFloat separatorThickness = TGSeparatorHeight();
    _horizontalSeparator.frame = CGRectMake(0, height, width, separatorThickness);
    _verticalSeparator.frame = CGRectMake(width / 2.0f, height, separatorThickness, TGCallAlertViewButtonHeight);
    
    CGFloat halfWidth = width / 2.0f;
    CGFloat cancelTextWidth = [[_cancelButton titleForState:UIControlStateNormal] sizeWithFont:_cancelButton.titleLabel.font].width;
    CGFloat doneTextWidth = [[_doneButton titleForState:UIControlStateNormal] sizeWithFont:_doneButton.titleLabel.font].width;
    
    CGFloat cancelWidth = _doneButton != nil ? halfWidth : width;
    CGFloat doneWidth = halfWidth;
    
    CGFloat cancelOrigin = CGRectGetMaxY(_horizontalSeparator.frame);
    CGFloat doneOriginY = cancelOrigin;
    
    if (_doneButton != nil && (cancelTextWidth > halfWidth - 10.0f || doneTextWidth > halfWidth - 10.0f))
    {
        cancelWidth = width;
        doneWidth = width;
        
        cancelOrigin += TGCallAlertViewButtonHeight;
        _verticalSeparator.frame = CGRectMake(0.0f, cancelOrigin, width, separatorThickness);
    }
    
    CGFloat doneOriginX = width - cancelWidth;
    
    _cancelButton.frame = CGRectMake(0, cancelOrigin, cancelWidth, TGCallAlertViewButtonHeight);
    _doneButton.frame = CGRectMake(doneOriginX, doneOriginY, doneWidth, TGCallAlertViewButtonHeight);
    
    height = CGRectGetMaxY(_cancelButton.frame);
    
    CGFloat keyboardOffset = self.followsKeyboard ? _keyboardOffset : 0;
    CGFloat y = ceil((self.bounds.size.height - keyboardOffset - height) / 2.0f);
    if (self.followsKeyboard && isLandscape)
    {
        CGFloat minY = self.bounds.size.height - keyboardOffset - height - 16.0f;
        if (y > minY)
        {
            y = minY;
            _titleLabel.alpha = 0.4f;
        }
        else
        {
            _titleLabel.alpha = 1.0f;
        }
    }
    else
    {
        _titleLabel.alpha = 1.0f;
    }
    _backgroundView.frame = CGRectMake((self.bounds.size.width - width) / 2.0f, y, width, height);
}

+ (TGCallAlertView *)presentAlertWithTitle:(NSString *)title message:(id)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle completionBlock:(void (^)(bool))completionBlock
{
    return [self _presentAlert:[TGCallAlertView class] withTitle:title message:message customView:customView cancelButtonTitle:cancelButtonTitle doneButtonTitle:doneButtonTitle completionBlock:completionBlock];
}

+ (TGCallAlertView *)_presentAlert:(Class)alertClass withTitle:(NSString *)title message:(id)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle completionBlock:(void (^)(bool))completionBlock
{
    return [self _presentAlert:alertClass withTitle:title message:message customView:customView cancelButtonTitle:cancelButtonTitle doneButtonTitle:doneButtonTitle keepKeyboard:false completionBlock:completionBlock];
}

+ (TGCallAlertView *)_presentAlert:(Class)alertClass withTitle:(NSString *)title message:(id)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle keepKeyboard:(bool)keepKeyboard completionBlock:(void (^)(bool))completionBlock
{
    TGCallAlertView *alertView = [[alertClass alloc] initWithTitle:title message:message customView:customView cancelButtonTitle:cancelButtonTitle doneButtonTitle:doneButtonTitle completionBlock:completionBlock];
    TGCallAlertViewController *controller = [[TGCallAlertViewController alloc] initWithView:alertView];
    TGOverlayControllerWindow *window = [[TGOverlayControllerWindow alloc] initWithManager:[[TGLegacyComponentsContext shared] makeOverlayWindowManager] parentController:TGAppDelegateInstance.rootController contentController:controller keepKeyboard:keepKeyboard];
    window.hidden = false;
    alertView->_alertWindow = window;
    
    return alertView;
}

@end


@implementation TGCallAlertViewController

@dynamic view;

- (instancetype)initWithView:(TGCallAlertView *)view
{
    self = [super init];
    if (self != nil)
    {
        __weak TGCallAlertViewController *weakSelf = self;
        _alertView = view;
        _alertView.onDismiss = ^
        {
            __strong TGCallAlertViewController *strongSelf = weakSelf;
            [strongSelf dismiss];
        };
    }
    return self;
}

- (void)loadView
{
    self.view = _alertView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_alertView present];
}

- (void)dismiss
{
    [super dismiss];
    [self.view removeFromSuperview];
}

- (UIViewController *)statusBarAppearanceSourceController
{
    UIViewController *rootController = [[LegacyComponentsGlobals provider] applicationWindows].firstObject.rootViewController;
    UIViewController *topViewController = nil;
    if ([rootController respondsToSelector:@selector(viewControllers)]) {
        topViewController = [(UINavigationController *)rootController viewControllers].lastObject;
    }
    
    if ([topViewController isKindOfClass:[UITabBarController class]])
        topViewController = [(UITabBarController *)topViewController selectedViewController];
    if ([topViewController isKindOfClass:[TGViewController class]])
    {
        TGViewController *concreteTopViewController = (TGViewController *)topViewController;
        if (concreteTopViewController.presentedViewController != nil)
        {
            topViewController = concreteTopViewController.presentedViewController;
        }
        else if (concreteTopViewController.associatedWindowStack.count != 0)
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
    UIViewController *rootController = [[LegacyComponentsGlobals provider] applicationWindows].firstObject.rootViewController;
    UIViewController *topViewController = nil;
    if ([rootController respondsToSelector:@selector(viewControllers)]) {
        topViewController = [(UINavigationController *)rootController viewControllers].lastObject;
    }
    
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
    
    for (UIWindow *window in [[LegacyComponentsGlobals provider] applicationWindows].reverseObjectEnumerator)
    {
        for (Class classInfo in nonRotateableWindowClasses)
        {
            if ([window isKindOfClass:classInfo])
                return false;
        }
    }
    
    UIViewController *rootController = [[LegacyComponentsGlobals provider] applicationWindows].firstObject.rootViewController;
    
    if (rootController.presentedViewController != nil)
        return [rootController.presentedViewController shouldAutorotate];
    
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


@end
