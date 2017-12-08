#import "TGHashtagOverviewController.h"

#import "TGInterfaceManager.h"
#import "TGModernConversationController.h"
#import "TGHashtagSearchController.h"

@interface TGHashtagOverviewController () <UINavigationControllerDelegate>
{
    TGModernConversationController *_conversationController;
    TGHashtagSearchController *_searchController;
        
    UIView *_navbarExtensionClipView;
    UIView *_navbarExtensionView;
    UIView *_stripeView;
    UISegmentedControl *_segmentedControl;
    UILabel *_titleLabel;
    
    NSArray *_chatControllers;
}
@end

@implementation TGHashtagOverviewController

- (instancetype)initWithQuery:(NSString *)query peerId:(int64_t)peerId
{
    self = [super initWithNavigationBarClass:[TGNavigationBar class] toolbarClass:nil];
    if (self != nil)
    {
        self.forceAdditionalNavigationBarHeight = true;
        self.currentAdditionalNavigationBarHeight = 38 + TGScreenPixel;
        self.delegate = self;
        
        [self setQuery:query peerId:peerId];
    }
    return self;
}

- (void)setQuery:(NSString *)query peerId:(int64_t)peerId
{
    _query = query;
    _titleLabel.text = _query;
    [self _layoutTitleLabel];
    
    _conversationController = [[TGInterfaceManager instance] configuredConversationControlerWithId:peerId performActions:nil preview:false];
    [self setViewControllers:@[_conversationController]];
    
    __weak TGHashtagOverviewController *weakSelf = self;
    _searchController = [[TGHashtagSearchController alloc] initWithQuery:query peerId:0 accessHash:0];
    _searchController.customResultBlockPeerId = peerId;
    _searchController.customResultBlock = ^(int32_t messageId)
    {
        __strong TGHashtagOverviewController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf->_segmentedControl.selectedSegmentIndex = 0;
            [strongSelf segmentedControlChanged];
            
            [strongSelf->_conversationController scrollToMessage:messageId sourceMessageId:0 animated:true];
        }
    };
    
    _chatControllers = nil;
    
    _segmentedControl.selectedSegmentIndex = 0;
    
    [self updateNavigationItem];
    [self updateSegmentItems];
    
    [_conversationController setExclusiveSearchQuery:_query];
    [_conversationController setLeftBarButtonItem:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self createNavigationBarExtension];
    [_conversationController setExclusiveSearchQuery:_query];
    [_conversationController setLeftBarButtonItem:nil];
    
    [self updateNavigationItem];
}

- (void)_layoutTitleLabel
{
    [_titleLabel sizeToFit];
    
    bool landscape = self.view.frame.size.width > self.view.frame.size.height;
    _titleLabel.frame = CGRectMake((_navbarExtensionView.frame.size.width - _titleLabel.frame.size.width) / 2.0f, landscape ? -15.0f : -20.0f, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (_navbarExtensionClipView != nil)
    {
        TGNavigationBar *navigationBar = (TGNavigationBar *)self.navigationBar;
        [navigationBar insertSubview:_navbarExtensionClipView atIndex:1];
        
        if (navigationBar == nil || navigationBar.frame.origin.y < 0)
            return;
        
        CGRect frame = _navbarExtensionClipView.frame;
        frame.origin.y = navigationBar.frame.size.height - 12.0f;
        _navbarExtensionClipView.frame = frame;
        
        UIEdgeInsets safeAreaInset = [TGViewController safeAreaInsetForOrientation:self.interfaceOrientation];
        _segmentedControl.frame = CGRectMake(12.0f + safeAreaInset.left, 0.0f, _navbarExtensionView.frame.size.width - 24.0f - safeAreaInset.left - safeAreaInset.right, 29.0f);
        
        [self _layoutTitleLabel];
    }
}

- (void)createNavigationBarExtension
{
    if (iosMajorVersion() < 7 || _navbarExtensionClipView != nil)
        return;
    
    TGNavigationBar *navigationBar = (TGNavigationBar *)self.navigationBar;
    
    static UIImage *maskImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(10.0f, 10.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        UIColor *whiteColor = TGIsPad() ? [UIColor whiteColor] : UIColorRGB(0xf7f7f7);
        
        CGColorRef colors[3] = {
            CGColorRetain(whiteColor.CGColor),
            CGColorRetain(whiteColor.CGColor),
            CGColorRetain([whiteColor colorWithAlphaComponent:0.0f].CGColor)
        };
        
        CFArrayRef colorsArray = CFArrayCreate(kCFAllocatorDefault, (const void **)&colors, 3, NULL);
        CGFloat locations[3] = {0.0f, 0.45f, 1.0f};
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorsArray, (CGFloat const *)&locations);
        
        CFRelease(colorsArray);
        CFRelease(colors[0]);
        CFRelease(colors[1]);
        CFRelease(colors[2]);
        
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, 10.0f), 0);
        
        CFRelease(gradient);
        
        maskImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    _navbarExtensionClipView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, navigationBar.frame.size.height - 12.0f, navigationBar.frame.size.width, 51.0f)];
    _navbarExtensionClipView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [navigationBar insertSubview:_navbarExtensionClipView atIndex:1];
    
    navigationBar.additionalView = _navbarExtensionClipView;
    
    _navbarExtensionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 11.0f, navigationBar.frame.size.width, 40.0f)];
    _navbarExtensionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _navbarExtensionView.backgroundColor = UIColorRGB(0xf7f7f7);
    [_navbarExtensionClipView addSubview:_navbarExtensionView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = TGMediumSystemFontOfSize(17.0f);
    _titleLabel.text = _query;
    _titleLabel.textColor = [UIColor blackColor];
    [_titleLabel sizeToFit];
    [_navbarExtensionClipView addSubview:_titleLabel];
    
    NSArray *items = @[[_conversationController.companion title], TGLocalized(@"HashtagSearch.AllChats")];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    [_segmentedControl setBackgroundImage:TGImageNamed(@"ModernSegmentedControlBackground.png") forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:TGImageNamed(@"ModernSegmentedControlSelected.png") forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:TGImageNamed(@"ModernSegmentedControlSelected.png") forState:UIControlStateSelected | UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:TGImageNamed(@"ModernSegmentedControlHighlighted.png") forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    UIImage *dividerImage = TGImageNamed(@"ModernSegmentedControlDivider.png");
    [_segmentedControl setDividerImage:dividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    _segmentedControl.frame = CGRectMake(12.0f, 0.0f, _navbarExtensionView.frame.size.width - 24.0f, 29.0f);
    _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [_segmentedControl setTitleTextAttributes:@{UITextAttributeTextColor: TGAccentColor(), UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(13)} forState:UIControlStateNormal];
    [_segmentedControl setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor], UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(13)} forState:UIControlStateSelected];
    
    [_segmentedControl setSelectedSegmentIndex:0];
    [_segmentedControl addTarget:self action:@selector(segmentedControlChanged) forControlEvents:UIControlEventValueChanged];
    
    _stripeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _navbarExtensionView.frame.size.height - TGScreenPixel, _navbarExtensionView.frame.size.width, TGScreenPixel)];
    _stripeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _stripeView.backgroundColor = TGSeparatorColor();
    [_navbarExtensionView addSubview:_stripeView];
    
    [_navbarExtensionView addSubview:_segmentedControl];
    
    [self _layoutTitleLabel];
    
    _segmentedControl.selectedSegmentIndex = 0;
    
    navigationBar.musicPlayerOffset = 39.0f;
}

- (void)segmentedControlChanged
{
    NSArray *chatControllers = _chatControllers ?: @[_searchController];
    if (_segmentedControl.selectedSegmentIndex == 0)
        _chatControllers = self.viewControllers;
    
    [self setViewControllers:_segmentedControl.selectedSegmentIndex == 0 ? @[ _conversationController ] : chatControllers];
    [self updateNavigationItem];
}

- (void)navigationController:(UINavigationController *)__unused navigationController willShowViewController:(UIViewController *)__unused viewController animated:(BOOL)__unused animated
{
    [self updateNavigationItem];
}

- (void)updateNavigationItem
{
    for (TGViewController *controller in self.viewControllers)
    {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        
        if ([controller isKindOfClass:[TGViewController class]])
        {
            [controller setTitleView:nil];
            [controller setTitleText:@" "];
            controller.navigationItem.backBarButtonItem = backItem;
            [controller setRightBarButtonItem:rightItem];
        }
        else
        {
            controller.navigationItem.backBarButtonItem = backItem;
            controller.navigationItem.rightBarButtonItem = rightItem;
            controller.navigationItem.title = @" ";
        }
    }
    
    [self updateNavigationBarExtension];
}

- (void)updateNavigationBarExtension
{
    TGNavigationBar *navigationBar = (TGNavigationBar *)self.navigationBar;
    if ((_segmentedControl.selectedSegmentIndex == 0 && self.viewControllers.count > 1) || (_segmentedControl.selectedSegmentIndex == 1 && self.viewControllers.count > 2))
    {
        navigationBar.additionalView = nil;
        [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^{
            _navbarExtensionView.alpha = 0.0f;
            _navbarExtensionView.transform = CGAffineTransformMakeTranslation(0.0f, -_navbarExtensionView.frame.size.height + 1.0f);
            navigationBar.musicPlayerOffset = 0.0f;
            self.currentAdditionalNavigationBarHeight = 0.0f;
            [self updatePlayerOnControllers];
        } completion:^(__unused BOOL finished)
        {
            _stripeView.alpha = 0.0f;
        }];
    }
    else
    {
        navigationBar.additionalView = _navbarExtensionClipView;
        
        _stripeView.alpha = 1.0f;
        [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^{
            _navbarExtensionView.alpha = 1.0f;
            _navbarExtensionView.transform = CGAffineTransformIdentity;
            navigationBar.musicPlayerOffset = 39.0f;
            self.currentAdditionalNavigationBarHeight = 38.0f + TGScreenPixel;
            [self updatePlayerOnControllers];
        } completion:nil];
    }
}

- (void)backPressed
{
    [self popViewControllerAnimated:true];
}

- (void)donePressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    [self updateNavigationItem];
    
    if (_segmentedControl.selectedSegmentIndex == 1 && [viewController isKindOfClass:[TGModernConversationController class]])
    {
        [self updateSegmentItems];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *result = [super popViewControllerAnimated:animated];
    
    if (_segmentedControl.selectedSegmentIndex == 1)
        [self updateSegmentItems];
    
    [self updateNavigationBarExtension];
    
    return result;
}

- (void)updateSegmentItems
{
    NSString *leftTitle = [_conversationController.companion title];
    NSString *rightTitle = self.viewControllers.count == 2 ? [((TGModernConversationController *)self.topViewController).companion title] : TGLocalized(@"HashtagSearch.AllChats");
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [_segmentedControl setTitle:leftTitle forSegmentAtIndex:0];
        [_segmentedControl setTitle:rightTitle forSegmentAtIndex:1];
    });
}

@end
