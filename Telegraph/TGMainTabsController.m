#import "TGMainTabsController.h"

#import "TGViewController.h"

#import "TGNavigationBar.h"

#import "TGLabel.h"

#import <QuartzCore/QuartzCore.h>

#import <objc/runtime.h>

#import "TGHacks.h"

#import "FreedomUIKit.h"

#import "TGBackdropView.h"

#import "TGStringUtils.h"
#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGAppDelegate.h"
#import "TGDebugController.h"

#import "TGNavigationController.h"

@protocol TGTabBarDelegate <NSObject>

- (void)tabBarSelectedItem:(int)index;

@end


@interface TGTabBarBadge : UIView
{
    UIImageView *_backgroundView;
    UILabel *_label;
}
@end

@implementation TGTabBarBadge

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
    if (self != nil)
    {
        self.hidden = true;
        self.userInteractionEnabled = false;
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        static dispatch_once_t onceToken;
        static UIImage *badgeImage;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(18.0f, 18.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xff3b30).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 18.0f, 18.0f));
            badgeImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:9.0f topCapHeight:0.0f];
            UIGraphicsEndImageContext();
        });

        
        _backgroundView = [[UIImageView alloc] initWithImage:badgeImage];
        [self addSubview:_backgroundView];
        
        _label = [[UILabel alloc] init];
        _label.text = @"1";
        [_label sizeToFit];
        _label.text = nil;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor whiteColor];
        _label.font = TGSystemFontOfSize(13);
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

- (void)setCount:(int)count
{
    if (count <= 0)
    {
        self.hidden = true;
    }
    else
    {
        NSString *text = nil;
        
        if (TGIsLocaleArabic())
        {
            text = [TGStringUtils stringWithLocalizedNumber:count];
        }
        else
        {
            if (count < 1000)
                text = [[NSString alloc] initWithFormat:@"%d", count];
            else if (count < 1000000)
                text = [[NSString alloc] initWithFormat:@"%dK", count / 1000];
            else
                text = [[NSString alloc] initWithFormat:@"%dM", count / 1000000];
        }
        
        _label.text = text;
        [_label sizeToFit];
        self.hidden = false;
        
        CGRect frame = _backgroundView.frame;
        CGFloat textWidth = ceil(_label.frame.size.width);
        frame.size.width = count < 10 ? 18.0f : MAX(18.0f, textWidth + 10.0f + TGRetinaPixel * 2.0f);
        frame.origin.x = _backgroundView.superview.frame.size.width - frame.size.width - 1.0f;
        _backgroundView.frame = frame;
        
        CGRect labelFrame = _label.frame;
        labelFrame.origin.x = frame.origin.x;
        labelFrame.origin.y = 1;
        labelFrame.size.width = frame.size.width;
        _label.frame = labelFrame;
    }
}

@end

@interface TGTabBarButton : UIView
{
    UIImageView *_imageView;
    UILabel *_label;
}

@property (nonatomic, assign, getter=isSelected) bool selected;

@end

@implementation TGTabBarButton

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(nullable UIImage *)highlightedImage title:(NSString *)title
{
    self = [super init];
    if (self != nil)
    {
        self.accessibilityTraits = UIAccessibilityTraitButton;
        self.accessibilityLabel = title;
        
        _imageView = [[UIImageView alloc] initWithImage:image highlightedImage:highlightedImage];
        [self addSubview:_imageView];
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = UIColorRGB(0x929292);
        _label.highlightedTextColor = TGAccentColor();
        _label.font = [TGTabBarButton labelFont];
        _label.text = title;
        _label.textAlignment = NSTextAlignmentCenter;
        [_label sizeToFit];
        _label.frame = CGRectMake(_label.frame.origin.x, _label.frame.origin.y, ceil(_label.frame.size.width), ceil(_label.frame.size.height));
        [self addSubview:_label];
    }
    return self;
}

- (void)setSelected:(bool)selected
{
    _selected = selected;
    _imageView.highlighted = selected;
    _label.highlighted = selected;
}

- (void)layoutSubviews
{
    _imageView.frame = CGRectMake(floor((self.frame.size.width - _imageView.frame.size.width) / 2), [self iconVerticalOffset], _imageView.frame.size.width, _imageView.frame.size.height);
    _label.frame = CGRectMake(0, [self labelVerticalOffset], self.frame.size.width, _label.frame.size.height);
}

- (CGFloat)iconVerticalOffset
{
    static CGFloat offset = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (!TGIsPad())
            offset = 4;
        else
            offset = 5 + TGRetinaPixel;
    });
    return offset;
}

- (CGFloat)labelVerticalOffset
{
    static CGFloat offset = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (!TGIsPad())
            offset = 35 - TGRetinaPixel;
        else
            offset = 36;
    });
    return offset;
}

+ (UIFont *)labelFont
{
    static UIFont *font = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (!TGIsPad())
            font = TGSystemFontOfSize(10);
        else
            font = TGSystemFontOfSize(11);
    });
    return font;
}

@end


@interface TGTabBar : UIView
{
    bool _skipNextLayout;
    
    int _callsCount;
    int _messagesCount;
}

@property (nonatomic, weak) id<TGTabBarDelegate> tabDelegate;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *stripeView;

@property (nonatomic, strong) NSMutableArray *tabButtons;
@property (nonatomic, strong) TGTabBarButton *callsButton;
@property (nonatomic, assign) bool callsHidden;

@property (nonatomic, strong) TGTabBarBadge *callsBadge;
@property (nonatomic, strong) TGTabBarBadge *messagesBadge;

@property (nonatomic) int selectedIndex;

@end

@implementation TGTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        if ([TGViewController useExperimentalRTL])
            self.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
        
        self.multipleTouchEnabled = false;
        self.exclusiveTouch = true;
        
        if (TGBackdropEnabled())
        {
            _backgroundView = [[UIToolbar alloc] initWithFrame:self.bounds];
            [self addSubview:_backgroundView];
        }
        else
        {
            _backgroundView = [TGBackdropView viewWithLightNavigationBarStyle];
            _backgroundView.frame = self.bounds;
            [self addSubview:_backgroundView];
            
            _stripeView = [[UIView alloc] init];
            _stripeView.backgroundColor = UIColorRGB(0xb2b2b2);
            [self addSubview:_stripeView];
        }
        
        _tabButtons = [[NSMutableArray alloc] init];
        
        TGTabBarButton *contactsButton = [[TGTabBarButton alloc] initWithImage:[UIImage imageNamed:@"TabIconContacts.png"] highlightedImage:[UIImage imageNamed:@"TabIconContacts_Highlighted.png"] title:TGLocalized(@"Contacts.TabTitle")];
        TGTabBarButton *messagesButton = [[TGTabBarButton alloc] initWithImage:[UIImage imageNamed:@"TabIconMessages.png"] highlightedImage:[UIImage imageNamed:@"TabIconMessages_Highlighted.png"] title:TGLocalized(@"DialogList.TabTitle")];
        TGTabBarButton *settingsButton = [[TGTabBarButton alloc] initWithImage:[UIImage imageNamed:@"TabIconSettings.png"] highlightedImage:[UIImage imageNamed:@"TabIconSettings_Highlighted.png"] title:TGLocalized(@"Settings.TabTitle")];
        
        _callsButton = [[TGTabBarButton alloc] initWithImage:[UIImage imageNamed:@"TabIconCalls.png"] highlightedImage:[UIImage imageNamed:@"TabIconCalls_Highlighted.png"] title:TGLocalized(@"Calls.TabTitle")];
        _callsButton.hidden = true;
        _callsHidden = true;
        
        [_tabButtons addObject:contactsButton];
        [_tabButtons addObject:_callsButton];
        [_tabButtons addObject:messagesButton];
        [_tabButtons addObject:settingsButton];
        
        for (TGTabBarButton *button in _tabButtons)
            [self addSubview:button];
    }
    return self;
}

- (CGFloat)sideIconOffsetForWidth:(CGFloat)width
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return 0.0f;
    if (width < 320.0f + FLT_EPSILON)
        return 0.0f;
    
    return CGFloor(width / 21.5f);
}

- (void)setCallsTabHidden:(bool)hidden animated:(bool)animated
{
    if (_callsHidden == hidden)
        return;
    
    if (animated)
    {
        _callsButton.hidden = false;
        if (!hidden)
            _callsButton.alpha = 0.0f;
        
        [UIView animateWithDuration:0.2 animations:^
        {
            _callsButton.alpha = hidden ? 0.0f : 1.0f;
        }];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews animations:^
        {
            _callsHidden = hidden;
            [self layoutButtons];
        } completion:^(__unused BOOL finished)
        {
            _skipNextLayout = false;
            _callsButton.hidden = hidden;
        }];
        
        _skipNextLayout = true;
    }
    else
    {
        _callsHidden = hidden;
        _callsButton.alpha = hidden ? 0.0f : 1.0f;
        _callsButton.hidden = hidden;
        [self setNeedsLayout];
    }
}

- (void)setSelectedIndex:(int)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    [_tabButtons enumerateObjectsUsingBlock:^(TGTabBarButton *button, NSUInteger index, __unused BOOL *stop)
    {
        [button setSelected:((int)index == selectedIndex)];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    NSInteger buttonsCount = _callsHidden ? 3 : 4;
    int index = MAX(0, MIN((int)buttonsCount - 1, (int)([touch locationInView:self].x / (self.frame.size.width / buttonsCount))));
    if (buttonsCount == 3 && index > 0)
        index += 1;
    [self setSelectedIndex:index];
    
    __strong id<TGTabBarDelegate> delegate = _tabDelegate;
    [delegate tabBarSelectedItem:index];
}

- (void)setMissedCallsCount:(int)callsCount
{
    if (callsCount <= 0 && _callsBadge == nil)
        return;
    
    if (_callsBadge == nil)
    {
        _callsBadge = [[TGTabBarBadge alloc] init];
        [_callsButton addSubview:_callsBadge];
        
        [self setNeedsLayout];
    }
    
    _callsCount = callsCount;
    [self updateCounts];
}

- (void)setUnreadCount:(int)unreadCount
{
    if (unreadCount <= 0 && _messagesBadge == nil)
        return;
    
    if (_messagesBadge == nil)
    {
        _messagesBadge = [[TGTabBarBadge alloc] init];
        [_tabButtons[2] addSubview:_messagesBadge];
        
        [self setNeedsLayout];
    }
    
    _messagesCount = unreadCount;
    [self updateCounts];
}

- (void)updateCounts
{
    [_callsBadge setCount:_callsCount];
    [_messagesBadge setCount:MAX(0, _messagesCount - _callsCount)];
}

- (void)layoutButtons
{    
    CGSize viewSize = self.frame.size;
    
    NSUInteger buttonsCount = _callsHidden ? 3 : 4;
    CGFloat buttonWidth = floor(viewSize.width / buttonsCount);
    
    [_tabButtons enumerateObjectsUsingBlock:^(TGTabBarButton *button, NSUInteger index, __unused BOOL *stop)
    {
        NSInteger realIndex = index;
        if (buttonsCount == 3 && index > 1)
            index--;
        
        button.frame = CGRectMake(index * buttonWidth, 0, buttonWidth, self.frame.size.height);
        
        TGTabBarBadge *badge = nil;
        if (realIndex == 1)
            badge = _callsBadge;
        else if (realIndex == 2)
            badge = _messagesBadge;
        
        if (badge != nil)
        {
            CGRect badgeFrame = badge.frame;
            badgeFrame.origin.x = button.frame.size.width / 2.0f + 6.0f + (_callsHidden ? 0 : TGRetinaPixel);
            badgeFrame.origin.y = 2 - button.frame.origin.y;
            badge.frame = badgeFrame;
        }
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    
    _backgroundView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    CGFloat stripeHeight = TGScreenPixel;
    _stripeView.frame = CGRectMake(0, -stripeHeight, viewSize.width, stripeHeight);
    
    [self layoutButtons];
}

@end

#pragma mark -

@interface TGTabsContainerSubview : UIView

@end

@implementation TGTabsContainerSubview

- (void)layoutSubviews
{
    static void (*nativeImpl)(id, SEL) = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        nativeImpl = (void (*)(id, SEL))freedomNativeImpl([self class], _cmd);
    });
    
    if (nativeImpl != NULL)
        nativeImpl(self, _cmd);
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:self.frame.size.width > 320.0f + FLT_EPSILON ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait];
    
    for (UIView *subview in self.subviews)
    {
        subview.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, screenSize.height);
    }
}

@end

#pragma mark -

@interface TGMainTabsController () <UITabBarControllerDelegate, TGTabBarDelegate>
{
    int _missedCallsCount;
    int _unreadCount;
    bool _callsHidden;
    NSTimeInterval _lastSameIndexTapTime;
    int _tapsInSuccession;
}

@property (nonatomic, strong) TGTabBar *customTabBar;

@end

@implementation TGMainTabsController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.delegate = self;
        
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)])
            [self setAutomaticallyAdjustsScrollViewInsets:false];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem.possibleTitles = [NSSet setWithObject:TGLocalized(@"Common.Back")];
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    if (iosMajorVersion() <= 6 && [NSStringFromClass([self.view.subviews.firstObject class]) isEqualToString:TGEncodeText(@"VJUsbotjujpoWjfx", -1)])
    {
        Class subclass = freedomMakeClass([self.view.subviews.firstObject class], [TGTabsContainerSubview class]);
        object_setClass(self.view.subviews.firstObject, subclass);
    }
}

- (CGFloat)tabBarHeight
{
    static CGFloat height = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            height = 49.0f;
        else
            height = 56.0f;
    });
    
    return height;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _customTabBar = [[TGTabBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [self tabBarHeight], self.view.frame.size.width, [self tabBarHeight])];
    _customTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _customTabBar.tabDelegate = self;
    [self.view insertSubview:_customTabBar aboveSubview:self.tabBar];
    
    //_customTabBar.alpha = 0.5f;
    
    self.tabBar.hidden = true;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [TGViewController autorotationAllowed] && (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)shouldAutorotate
{
    return [TGViewController autorotationAllowed];
}

- (UIBarStyle)requiredNavigationBarStyle
{
    if (self.selectedViewController == nil)
        return UIBarStyleDefault;
    else if ([self.selectedViewController conformsToProtocol:@protocol(TGViewControllerNavigationBarAppearance)])
        return [(id<TGViewControllerNavigationBarAppearance>)self.selectedViewController requiredNavigationBarStyle];
    else
        return UIBarStyleDefault;
}

- (bool)navigationBarShouldBeHidden
{
    if (self.selectedViewController == nil)
        return false;
    else if ([self.selectedViewController conformsToProtocol:@protocol(TGViewControllerNavigationBarAppearance)])
        return [(id<TGViewControllerNavigationBarAppearance>)self.selectedViewController navigationBarShouldBeHidden];
    else
        return false;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view layoutIfNeeded];
    
    [super viewWillAppear:animated];
}

- (BOOL)tabBarController:(UITabBarController *)__unused tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (viewController == self.selectedViewController)
        return false;
    
    return true;
}

- (void)tabBarSelectedItem:(int)index
{
    if ((int)self.selectedIndex != index)
    {
        [self tabBarController:self shouldSelectViewController:[self.viewControllers objectAtIndex:index]];
        [self setSelectedIndex:index];
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([self.selectedViewController respondsToSelector:@selector(scrollToTopRequested)])
            [self.selectedViewController performSelector:@selector(scrollToTopRequested)];
#pragma clang diagnostic pop
    }
    
    if (index == 3) {
        NSTimeInterval t = CACurrentMediaTime();
        if (_lastSameIndexTapTime < DBL_EPSILON || t < _lastSameIndexTapTime + 0.5) {
            _lastSameIndexTapTime = t;
            _tapsInSuccession++;
            if (_tapsInSuccession == 10) {
                _tapsInSuccession = 0;
                _lastSameIndexTapTime = 0.0;
                
                [TGAppDelegateInstance.rootController pushContentController:[[TGDebugController alloc] init]];
            }
        } else {
            _lastSameIndexTapTime = 0.0;
            _tapsInSuccession = 0;
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    
    [self _updateNavigationItemOverride:selectedIndex];
    
    [_customTabBar setSelectedIndex:(int)selectedIndex];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    [super setViewControllers:viewControllers animated:animated];
    
    [self _updateNavigationItemOverride:self.selectedIndex];
}

- (void)_updateNavigationItemOverride:(NSUInteger)selectedIndex
{
    int index = -1;
    for (UIViewController *viewController in self.viewControllers)
    {
        index++;
        
        if ([viewController isKindOfClass:[TGViewController class]])
        {
            if (index == (int)selectedIndex)
                [(TGViewController *)viewController setTargetNavigationItem:self.navigationItem titleController:self];
            else
                [(TGViewController *)viewController setTargetNavigationItem:nil titleController:nil];
        }
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    NSString *backTitle = title == nil || ![title isEqualToString:TGLocalized(@"DialogList.Title")] ? TGLocalized(@"Common.Back") : title;
    
    if (!TGStringCompare(self.navigationItem.backBarButtonItem.title, backTitle))
        self.navigationItem.backBarButtonItem.title = backTitle;
}

- (void)setCallsHidden:(bool)hidden animated:(bool)animated
{
    _callsHidden = hidden;
    [_customTabBar setCallsTabHidden:hidden animated:animated];
}

- (void)setMissedCallsCount:(int)callsCount
{
    _missedCallsCount = callsCount;
    [_customTabBar setMissedCallsCount:callsCount];
}

- (void)setUnreadCount:(int)unreadCount
{
    _unreadCount = unreadCount;
    [_customTabBar setUnreadCount:unreadCount];
}

- (void)localizationUpdated
{
    _customTabBar.tabDelegate = nil;
    [_customTabBar removeFromSuperview];
    
    _customTabBar = [[TGTabBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [self tabBarHeight], self.view.frame.size.width, [self tabBarHeight])];
    _customTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _customTabBar.tabDelegate = self;
    [self.view insertSubview:_customTabBar aboveSubview:self.tabBar];
    
    [_customTabBar setSelectedIndex:(int)self.selectedIndex];
    [_customTabBar setCallsTabHidden:_callsHidden animated:false];
    [_customTabBar setMissedCallsCount:_missedCallsCount];
    [_customTabBar setUnreadCount:_unreadCount];
    
    for (TGViewController *controller in self.viewControllers)
    {
        [controller localizationUpdated];
    }
    
    [_customTabBar layoutSubviews];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [super dismissViewControllerAnimated:flag completion:completion];
    [self.navigationController setToolbarHidden:true animated:false];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (!TGAppDelegateInstance.rootController.callStatusBarHidden)
        return UIStatusBarStyleLightContent;
    else {
        if (iosMajorVersion() >= 7) {
            return [super preferredStatusBarStyle];
        } else {
            return UIStatusBarStyleDefault;
        }
    }
}

- (CGRect)frameForRightmostTab {
    return [(TGTabBarButton *)_customTabBar.tabButtons.lastObject frame];
}

- (UIView *)viewForRightmostTab {
    return _customTabBar.tabButtons.lastObject;
}

@end
