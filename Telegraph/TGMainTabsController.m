#import "TGMainTabsController.h"

#import <LegacyComponents/LegacyComponents.h>

#import <QuartzCore/QuartzCore.h>

#import <objc/runtime.h>

#import "TGAppDelegate.h"
#import "TGDebugController.h"

#import "TGPresentation.h"

@protocol TGTabBarDelegate <NSObject>

- (void)tabBarSelectedItem:(int)index;

@end


@interface TGTabBarBadge : UIView
{
    UIImageView *_backgroundView;
    UILabel *_label;
}

@property (nonatomic, strong) UIImage *image;

@end

@implementation TGTabBarBadge

- (instancetype)initWithPresentation:(TGPresentation *)presentation
{
    self = [super initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
    if (self != nil)
    {
        self.hidden = true;
        self.userInteractionEnabled = false;
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
        _backgroundView = [[UIImageView alloc] init];
        [self addSubview:_backgroundView];
        
        _label = [[UILabel alloc] init];
        _label.text = @"1";
        [_label sizeToFit];
        _label.text = nil;
        _label.backgroundColor = [UIColor clearColor];
        _label.font = TGSystemFontOfSize(13);
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        [self setPresentation:presentation];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _backgroundView.image = presentation.images.tabBarBadgeImage;
    _label.textColor = presentation.pallete.tabBadgeTextColor;
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
        frame.size.width = count < 10 ? 20.0f : MAX(20.0f, textWidth + 12.0f + TGScreenPixel * 2.0f);
        frame.size.height = 20.0f;
        frame.origin.x = _backgroundView.superview.frame.size.width - frame.size.width - 1.0f;
        frame.origin.y = -1.0f;
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
    UILabel *_label;
    TGPresentation *_presentation;
}

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, assign, getter=isSelected) bool selected;
@property (nonatomic, assign) bool landscape;

@end

@implementation TGTabBarButton

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title presentation:(TGPresentation *)presentation
{
    self = [super init];
    if (self != nil)
    {
        _presentation = presentation;
        
        self.accessibilityTraits = UIAccessibilityTraitButton;
        self.accessibilityLabel = title;
        
        _imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:_imageView];
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = presentation.pallete.tabTextColor;
        _label.highlightedTextColor = presentation.pallete.tabActiveIconColor;
        _label.font = [TGTabBarButton labelFont];
        _label.text = title;
        _label.textAlignment = NSTextAlignmentLeft;
        [_label sizeToFit];
        [self addSubview:_label];
    }
    return self;
}

- (void)setImage:(UIImage *)image presentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    
    _imageView.image = image;
    if (_imageView.highlighted)
        _imageView.highlightedImage = TGTintedImage(image, presentation.pallete.tabActiveIconColor);
    else
        _imageView.highlightedImage = nil;
    
    _label.textColor = presentation.pallete.tabTextColor;
    _label.highlightedTextColor = presentation.pallete.tabActiveIconColor;
}

- (void)setSelected:(bool)selected
{
    _selected = selected;
    if (_imageView.highlightedImage == nil && selected)
        _imageView.highlightedImage = TGTintedImage(_imageView.image, _presentation.pallete.tabActiveIconColor);
    _imageView.highlighted = selected;
    _label.highlighted = selected;
}

- (void)layoutSubviews
{
    _imageView.frame = CGRectMake(floor((self.frame.size.width - _imageView.frame.size.width) / 2), [self iconVerticalOffset], _imageView.frame.size.width, _imageView.frame.size.height);
    
    _imageView.center = CGPointMake(self.frame.size.width / 2, [self iconVerticalOffset] + _imageView.bounds.size.height / 2.0f);
    
    if (_landscape)
    {
        _label.font = [TGTabBarButton landscapeLabelFont];
        if (CGAffineTransformIsIdentity(_imageView.transform))
        {
            [UIView animateWithDuration:0.2 animations:^
            {
                _imageView.transform = CGAffineTransformMakeScale(0.6667f, 0.6667f);
            }];
            [_label sizeToFit];
        }
        
        CGFloat width = ceil(_imageView.frame.size.width + 6.0f + _label.frame.size.width);
        _imageView.center = CGPointMake((self.frame.size.width - width) / 2.0f + _imageView.frame.size.width / 2.0f, _imageView.bounds.size.height / 2.0f + 1.0f);
    
        _label.frame = CGRectMake(round(((self.frame.size.width - width) / 2.0f) + _imageView.frame.size.width + 6.0f), 9.0f, _label.frame.size.width, _label.frame.size.height);
    }
    else
    {
        _label.font = [TGTabBarButton labelFont];
        if (!CGAffineTransformIsIdentity(_imageView.transform))
        {
            [UIView animateWithDuration:0.2 animations:^
            {
                _imageView.transform = CGAffineTransformIdentity;
            }];
            
            [_label sizeToFit];
        }
        _imageView.center = CGPointMake(self.frame.size.width / 2, [self iconVerticalOffset] + _imageView.bounds.size.height / 2.0f);
        _label.frame = CGRectMake(round((self.frame.size.width - _label.frame.size.width) / 2.0f), [self labelVerticalOffset], _label.frame.size.width, _label.frame.size.height);
    }
}

- (void)setLandscape:(bool)landscape
{
    if (_landscape != landscape)
    {
        _landscape = landscape;
        [self setNeedsLayout];
    }
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
            offset = 35 - TGScreenPixel;
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
            font = TGMediumSystemFontOfSize(10);
        else
            font = TGMediumSystemFontOfSize(11);
    });
    return font;
}

+ (UIFont *)landscapeLabelFont
{
    static UIFont *font = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGSystemFontOfSize(12);
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
@property (nonatomic, strong) TGTabBarButton *contactsButton;
@property (nonatomic, strong) TGTabBarButton *callsButton;
@property (nonatomic, strong) TGTabBarButton *chatsButton;
@property (nonatomic, strong) TGTabBarButton *settingsButton;
@property (nonatomic, assign) bool callsHidden;

@property (nonatomic, strong) TGTabBarBadge *callsBadge;
@property (nonatomic, strong) TGTabBarBadge *messagesBadge;

@property (nonatomic, assign) UIEdgeInsets safeAreaInset;
@property (nonatomic, assign) bool landscape;

@property (nonatomic) int selectedIndex;


@property (nonatomic, strong) TGPresentation *presentation;
@end

@implementation TGTabBar

- (instancetype)initWithFrame:(CGRect)frame presentation:(TGPresentation *)presentation
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.multipleTouchEnabled = false;
        self.exclusiveTouch = true;
        
        _presentation = presentation;
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = presentation.pallete.barBackgroundColor;
        _backgroundView.frame = self.bounds;
        [self addSubview:_backgroundView];
        
        _stripeView = [[UIView alloc] init];
        _stripeView.backgroundColor = presentation.pallete.barSeparatorColor;
        [self addSubview:_stripeView];
        
        _tabButtons = [[NSMutableArray alloc] init];
        
        _contactsButton = [[TGTabBarButton alloc] initWithImage:presentation.images.tabBarContactsIcon title:TGLocalized(@"Contacts.TabTitle") presentation:presentation];
        _chatsButton = [[TGTabBarButton alloc] initWithImage:presentation.images.tabBarChatsIcon title:TGLocalized(@"DialogList.TabTitle") presentation:presentation];
        _settingsButton = [[TGTabBarButton alloc] initWithImage:presentation.images.tabBarSettingsIcon title:TGLocalized(@"Settings.TabTitle") presentation:presentation];
        _callsButton = [[TGTabBarButton alloc] initWithImage:presentation.images.tabBarCallsIcon title:TGLocalized(@"Calls.TabTitle") presentation:presentation];
        _callsButton.hidden = true;
        _callsHidden = true;
        
        [_tabButtons addObject:_contactsButton];
        [_tabButtons addObject:_callsButton];
        [_tabButtons addObject:_chatsButton];
        [_tabButtons addObject:_settingsButton];
        
        for (TGTabBarButton *button in _tabButtons)
            [self addSubview:button];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    
    _backgroundView.backgroundColor = presentation.pallete.barBackgroundColor;
    _stripeView.backgroundColor = presentation.pallete.barSeparatorColor;
    
    [_contactsButton setImage:presentation.images.tabBarContactsIcon presentation:presentation];
    [_chatsButton setImage:presentation.images.tabBarChatsIcon presentation:presentation];
    [_settingsButton setImage:presentation.images.tabBarSettingsIcon presentation:presentation];
    [_callsButton setImage:presentation.images.tabBarCallsIcon presentation:presentation];
    
    _chatsButton = [[TGTabBarButton alloc] initWithImage:presentation.images.tabBarChatsIcon title:TGLocalized(@"DialogList.TabTitle") presentation:presentation];
    _settingsButton = [[TGTabBarButton alloc] initWithImage:presentation.images.tabBarSettingsIcon title:TGLocalized(@"Settings.TabTitle") presentation:presentation];
    _callsButton = [[TGTabBarButton alloc] initWithImage:presentation.images.tabBarCallsIcon title:TGLocalized(@"Calls.TabTitle") presentation:presentation];
    
    [_messagesBadge setPresentation:presentation];
    [_callsBadge setPresentation:presentation];
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
    CGPoint location = [touch locationInView:self];
    if (location.y > [TGTabBar tabBarHeight:_landscape])
        return;
    
    int index = MAX(0, MIN((int)buttonsCount - 1, (int)(location.x / (self.frame.size.width / buttonsCount))));
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
        _callsBadge = [[TGTabBarBadge alloc] initWithPresentation:_presentation];
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
        _messagesBadge = [[TGTabBarBadge alloc] initWithPresentation:_presentation];
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
    
    CGFloat width = viewSize.width - self.safeAreaInset.left - self.safeAreaInset.right;
    
    NSUInteger buttonsCount = _callsHidden ? 3 : 4;
    CGFloat buttonWidth = floor(width / buttonsCount);
    
    [_tabButtons enumerateObjectsUsingBlock:^(TGTabBarButton *button, NSUInteger index, __unused BOOL *stop)
    {
        NSInteger realIndex = index;
        if (buttonsCount == 3 && index > 1)
            index--;
        
        button.landscape = self.landscape;
        button.frame = CGRectMake(self.safeAreaInset.left + index * buttonWidth, 0, buttonWidth, [TGTabBar tabBarHeight:_landscape]);
        
        TGTabBarBadge *badge = nil;
        if (realIndex == 1)
            badge = _callsBadge;
        else if (realIndex == 2)
            badge = _messagesBadge;
        
        if (badge != nil)
        {
            if (self.landscape)
            {
                [button layoutSubviews];
                badge.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
                badge.center = CGPointMake(button.imageView.center.x + 10.0f, 10.0f);
            }
            else
            {
                badge.transform = CGAffineTransformIdentity;
                CGRect badgeFrame = badge.frame;
                badgeFrame.origin.x = button.frame.size.width / 2.0f + 6.0f + (_callsHidden ? 0 : TGRetinaPixel);
                badgeFrame.origin.y = 2 - button.frame.origin.y;
                badge.frame = badgeFrame;
            }
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

+ (CGFloat)tabBarHeight:(bool)landscape
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return iosMajorVersion() >= 11 ? (landscape ? 32.0f : 49.0f) : 49.0f;
    else
        return 56.0f;
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
    
    bool _initialized;
    
    CGFloat _keyboardHeight;
    bool _ignoreKeyboardFrameChange;
    
    id<SDisposable> _presentationDisposable;
    TGPresentation *_presentation;
}

@property (nonatomic, strong) TGTabBar *customTabBar;

@end

@implementation TGMainTabsController

- (instancetype)initWithPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (self.view.frame.size.width > self.view.frame.size.height)
        orientation = UIInterfaceOrientationLandscapeLeft;
    
    UIEdgeInsets safeAreaInset = [TGViewController safeAreaInsetForOrientation:orientation];
    CGFloat inset = 0.0f;
    if (iosMajorVersion() >= 11 && safeAreaInset.bottom > FLT_EPSILON)
        inset = safeAreaInset.bottom;

    bool landscape = !TGIsPad() && iosMajorVersion() >= 11 && UIInterfaceOrientationIsLandscape(orientation);
    _customTabBar = [[TGTabBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [TGTabBar tabBarHeight:landscape] - inset, self.view.frame.size.width, [TGTabBar tabBarHeight:landscape] + inset) presentation:_presentation];
    _customTabBar.safeAreaInset = safeAreaInset;
    _customTabBar.landscape = landscape;
    _customTabBar.tabDelegate = self;
    [self.view insertSubview:_customTabBar aboveSubview:self.tabBar];
    
    self.tabBar.hidden = true;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    [_customTabBar setPresentation:presentation];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (self.view.frame.size.width > self.view.frame.size.height)
        orientation = UIInterfaceOrientationLandscapeLeft;
    
    UIEdgeInsets safeAreaInset = [TGViewController safeAreaInsetForOrientation:orientation];
    CGFloat inset = 0.0f;
    if (iosMajorVersion() >= 11 && safeAreaInset.bottom > FLT_EPSILON)
        inset = safeAreaInset.bottom;
    
    bool landscape = !TGIsPad() && iosMajorVersion() >= 11 && UIInterfaceOrientationIsLandscape(orientation);
    _customTabBar.safeAreaInset = safeAreaInset;
    _customTabBar.landscape = landscape;
    _customTabBar.frame = CGRectMake(0.0f, self.view.frame.size.height - [TGTabBar tabBarHeight:landscape] - inset, self.view.frame.size.width, [TGTabBar tabBarHeight:landscape] + inset);
}

- (void)setIgnoreKeyboardFrameChange:(bool)ignoreKeyboardFrameChange restoringFocus:(bool)restoringFocus
{
    _ignoreKeyboardFrameChange = ignoreKeyboardFrameChange;
    
    if (!ignoreKeyboardFrameChange && !restoringFocus)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:7 << 16 animations:^
        {
            [self _updateForKeyboardHeight:_keyboardHeight];
        } completion:nil];
    }
}

- (void)controllerInsetUpdated:(UIEdgeInsets)newInset
{
    _keyboardHeight = newInset.bottom;
    
    if (_ignoreKeyboardFrameChange)
        return;
    
    [self _updateForKeyboardHeight:_keyboardHeight];
}

- (void)_updateForKeyboardHeight:(CGFloat)keyboardHeight
{
    _customTabBar.frame = CGRectMake(0.0f, self.view.frame.size.height - [TGTabBar tabBarHeight:false] - keyboardHeight, self.view.frame.size.width, [TGTabBar tabBarHeight:false]);
    
    if (self.onControllerInsetUpdated != nil)
        self.onControllerInsetUpdated(keyboardHeight);
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
    self.debugReady();
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
    if (!_initialized && self.viewControllers.count > 2)
    {
        selectedIndex = 2;
        _initialized = true;
    }
    
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
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (self.view.frame.size.width > self.view.frame.size.height)
        orientation = UIInterfaceOrientationLandscapeLeft;
    
    UIEdgeInsets safeAreaInset = [TGViewController safeAreaInsetForOrientation:orientation];
    CGFloat inset = 0.0f;
    if (iosMajorVersion() >= 11 && safeAreaInset.bottom > FLT_EPSILON)
        inset = safeAreaInset.bottom;
    
    bool landscape = !TGIsPad() && iosMajorVersion() >= 11 && UIInterfaceOrientationIsLandscape(orientation);
    _customTabBar = [[TGTabBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [TGTabBar tabBarHeight:landscape] - inset, self.view.frame.size.width, [TGTabBar tabBarHeight:landscape] + inset) presentation:_presentation];
    _customTabBar.safeAreaInset = safeAreaInset;
    _customTabBar.landscape = landscape;
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
