#import "TGWebController.h"

#import "TGImageUtils.h"

#import "TGAppManager.h"

#import "TGNavigationBar.h"
#import "TGToolbarButton.h"

#import "TGHacks.h"

#import "TGLabel.h"

#import "TGAlertView.h"

#import <AVFoundation/AVFoundation.h>

@interface TGWebController () <UIWebViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *displayUrl;

@property (nonatomic, weak) id<UIScrollViewDelegate> webViewScrolDelegate;
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) TGNavigationBar *customNavigationBar;
@property (nonatomic, strong) UINavigationItem *customNavigationItem;

@property (nonatomic, strong) UIView *genericNavigationView;
@property (nonatomic, strong) UIView *customNavigationView;

@property (nonatomic, strong) UILabel *genericTitleLabel;
@property (nonatomic, strong) UILabel *customTitleLabel;

@property (nonatomic, strong) TGToolbarButton *overlayBackButton;

@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) UIImageView *toolbarBackgroundView;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIButton *maximizeButton;

@property (nonatomic, strong) UIButton *minimizeOverlayButton;
@property (nonatomic) bool maximizeInLandscape;

@property (nonatomic, strong) UIActivityIndicatorView *customActivityIndicator;

@property (nonatomic, strong) UIActionSheet *currentActionSheet;

@property (nonatomic) bool customWantsNavigationBarHidden;

@property (nonatomic) float draggingInProgress;
@property (nonatomic) float draggingStartOffset;
@property (nonatomic) float draggingStartPosition;

@end

@implementation TGWebController

- (id)initWithUrl:(NSString *)url
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.automaticallyManageScrollViewInsets = false;
        
        NSURL *nativeUrl = [[NSURL alloc] initWithString:url];
        _url = [[NSString alloc] initWithFormat:@"%@:%@", nativeUrl.scheme, nativeUrl.resourceSpecifier];
        _displayUrl = [[_url lowercaseString] hasPrefix:@"http://"] ? [nativeUrl.resourceSpecifier substringFromIndex:2] : _url;
        
        _customNavigationItem = [[UINavigationItem alloc] init];
        
        [self adjustNavigationAppearanceAnimated:self.interfaceOrientation duration:0.0];
        
        [self setNavigationBarShouldBeHidden:_customWantsNavigationBarHidden];
    }
    return self;
}

- (void)dealloc
{
    [self doUnloadView];
    
    _currentActionSheet.delegate = nil;
}

- (UILabel *)_createCustomTitleLabel
{
    TGLabel *titleLabel = [[TGLabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    titleLabel.portraitFont = [TGViewController titleFontForStyle:self.style landscape:false];
    titleLabel.landscapeFont = [TGViewController titleFontForStyle:self.style landscape:true];
    
    titleLabel.font = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? titleLabel.landscapeFont : titleLabel.portraitFont;
    titleLabel.textColor = [TGViewController titleTextColorForStyle:self.style];
    
    return titleLabel;
}

- (void)setTitleText:(NSString *)titleText
{
    [self setTitleText:titleText forOrientation:self.interfaceOrientation];
}

- (void)setTitleText:(NSString *)titleText forOrientation:(UIInterfaceOrientation)orientation
{
    if (_genericTitleLabel == nil)
        _genericTitleLabel = [self _createCustomTitleLabel];
    
    if (_customTitleLabel == nil)
        _customTitleLabel = [self _createCustomTitleLabel];
    
    if (_genericNavigationView == nil)
    {
        _genericNavigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 2)];
        [_genericNavigationView addSubview:_genericTitleLabel];
        
        self.navigationItem.titleView = _genericNavigationView;
    }
    
    if (_customNavigationView == nil)
    {
        _customNavigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 2)];
        [_customNavigationView addSubview:_customTitleLabel];
        
        _customNavigationItem.titleView = _customNavigationView;
    }
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:orientation];
    
    _genericTitleLabel.text = titleText;
    _genericTitleLabel.frame = CGRectMake(0, 0, 480, 44);
    [_genericTitleLabel sizeToFit];
    CGRect titleLabelFrame = _genericTitleLabel.frame;
    if (titleLabelFrame.size.width > screenSize.width - 72 * 2)
        titleLabelFrame.size.width = screenSize.width - 72 * 2;
    titleLabelFrame.origin.x = floorf((2 - titleLabelFrame.size.width) / 2);
    titleLabelFrame.origin.y = -12;
    _genericTitleLabel.frame = titleLabelFrame;
    
    _customTitleLabel.text = titleText;
    _customTitleLabel.frame = _genericTitleLabel.frame;
}

- (void)loadView
{
    [super loadView];
    
    _customNavigationBar = [[TGNavigationBar alloc] initWithFrame:CGRectMake(0, 20 + 44, self.view.frame.size.width, UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 44 : 32)];
    [_customNavigationBar setItems:@[_customNavigationItem]];
    _customNavigationBar.alpha = _customWantsNavigationBarHidden ? 0.0f : 1.0f;
    
    TGToolbarButton *backButton = [[TGToolbarButton alloc] initWithType:TGToolbarButtonTypeBack];
    backButton.tag = ((int)0x263D9E33);
    backButton.text = TGLocalized(@"Common.Back");
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(performBackAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [_customNavigationItem setLeftBarButtonItem:backItem animated:false];
    
    self.titleText = _displayUrl;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        BOOL ok;
        NSError *setCategoryError = nil;
        ok = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
        if (!ok)
        {
            NSLog(@"%s setCategoryError=%@", __PRETTY_FUNCTION__, setCategoryError);
        }
    });
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_webView];
    
    _webView.delegate = self;
    _webViewScrolDelegate = _webView;
    _webView.scrollView.delegate = self;
    _webView.scalesPageToFit = true;
    
    //[TGHacks setWebScrollViewContentInsetEnabled:_webView.scrollView enabled:false];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    
    UIImage *imageNormal = [[UIImage imageNamed:@"BackButton_Overlay.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    UIImage *imageNormalHighlighted = [[UIImage imageNamed:@"BackButton_Overlay_Highlighted.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    
    _overlayBackButton = [[TGToolbarButton alloc] initWithCustomImages:imageNormal imageNormalHighlighted:imageNormalHighlighted imageLandscape:nil imageLandscapeHighlighted:nil textColor:[UIColor whiteColor] shadowColor:UIColorRGBA(0x000000, 0.3f)];
    _overlayBackButton.backSemantics = true;
    _overlayBackButton.paddingLeft = 15;
    _overlayBackButton.paddingRight = 9;
    _overlayBackButton.text = @"Back";
    [_overlayBackButton sizeToFit];
    [_overlayBackButton addTarget:self action:@selector(performBackAction) forControlEvents:UIControlEventTouchUpInside];
    _overlayBackButton.frame = CGRectOffset(_overlayBackButton.frame, 4, 28);
    [self.view addSubview:_overlayBackButton];
    
    UIImage *minimizeImage = [UIImage imageNamed:@"BrowserMinimize.png"];
    UIImage *minimizeHighlightedImage = [UIImage imageNamed:@"BrowserMinimize_Highlighted.png"];
    
    _minimizeOverlayButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - minimizeImage.size.width - 5, self.view.frame.size.height - minimizeImage.size.height - 5, minimizeImage.size.width, minimizeImage.size.height)];
    _minimizeOverlayButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    _minimizeOverlayButton.adjustsImageWhenDisabled = false;
    _minimizeOverlayButton.adjustsImageWhenHighlighted = false;
    _minimizeOverlayButton.exclusiveTouch = true;
    [_minimizeOverlayButton setBackgroundImage:minimizeImage forState:UIControlStateNormal];
    [_minimizeOverlayButton setBackgroundImage:minimizeHighlightedImage forState:UIControlStateHighlighted];
    [_minimizeOverlayButton addTarget:self action:@selector(minimizeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_minimizeOverlayButton];
    
    _minimizeOverlayButton.alpha = 0.0f;
    
    _toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    UIImageView *shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BrowserFooterShadow.png"]];
    shadowView.frame = CGRectMake(0, -shadowView.frame.size.height, _toolbarView.frame.size.width, shadowView.frame.size.height);
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_toolbarView addSubview:shadowView];
    
    _toolbarBackgroundView = [[UIImageView alloc] initWithFrame:_toolbarView.bounds];
    _toolbarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _toolbarBackgroundView.image = [UIImage imageNamed:(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? @"BrowserFooter.png" : @"BrowserFooter_Landscape.png")];
    [_toolbarView addSubview:_toolbarBackgroundView];
    [self.view addSubview:_toolbarView];
    
    UIImage *backImage = [UIImage imageNamed:@"BrowserFooterBack.png"];
    UIImage *backHighlightedImage = [UIImage imageNamed:@"BrowserFooterBack_Highlighted.png"];
    
    UIImage *forwardImage = [UIImage imageNamed:@"BrowserFooterForward.png"];
    UIImage *forwardHighlightedImage = [UIImage imageNamed:@"BrowserFooterForward_Highlighted.png"];
    
    UIImage *stopImage = [UIImage imageNamed:@"BrowserFooterStop.png"];
    UIImage *stopHighlightedImage = [UIImage imageNamed:@"BrowserFooterStop_Highlighted.png"];
    
    UIImage *reloadImage = [UIImage imageNamed:@"BrowserFooterRefresh.png"];
    UIImage *reloadHighlightedImage = [UIImage imageNamed:@"BrowserFooterRefresh_Highlighted.png"];
    
    UIImage *actionImage = [UIImage imageNamed:@"BrowserFooterActions.png"];
    UIImage *actionHighlightedImage = [UIImage imageNamed:@"BrowserFooterActions_Highlighted.png"];
    
    UIImage *maximizeImage = [UIImage imageNamed:@"BrowserFooterMaximize.png"];
    UIImage *maximizeHighlightedImage = [UIImage imageNamed:@"BrowserFooterMaximize_Highlighted.png"];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    _backButton.adjustsImageWhenDisabled = false;
    _backButton.adjustsImageWhenHighlighted = false;
    _backButton.exclusiveTouch = true;
    [_backButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [_backButton setBackgroundImage:backHighlightedImage forState:UIControlStateHighlighted];
    [_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView addSubview:_backButton];
    
    _forwardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, forwardImage.size.width, forwardImage.size.height)];
    _forwardButton.adjustsImageWhenDisabled = false;
    _forwardButton.adjustsImageWhenHighlighted = false;
    _forwardButton.exclusiveTouch = true;
    [_forwardButton setBackgroundImage:forwardImage forState:UIControlStateNormal];
    [_forwardButton setBackgroundImage:forwardHighlightedImage forState:UIControlStateHighlighted];
    [_forwardButton addTarget:self action:@selector(forwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView addSubview:_forwardButton];
    
    _reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, reloadImage.size.width, reloadImage.size.height)];
    _reloadButton.adjustsImageWhenDisabled = false;
    _reloadButton.adjustsImageWhenHighlighted = false;
    _reloadButton.exclusiveTouch = true;
    [_reloadButton setBackgroundImage:reloadImage forState:UIControlStateNormal];
    [_reloadButton setBackgroundImage:reloadHighlightedImage forState:UIControlStateHighlighted];
    [_reloadButton addTarget:self action:@selector(reloadButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView addSubview:_reloadButton];
    
    _reloadButton.alpha = 0.0f;
    
    _stopButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, stopImage.size.width, stopImage.size.height)];
    _stopButton.adjustsImageWhenDisabled = false;
    _stopButton.adjustsImageWhenHighlighted = false;
    _stopButton.exclusiveTouch = true;
    [_stopButton setBackgroundImage:stopImage forState:UIControlStateNormal];
    [_stopButton setBackgroundImage:stopHighlightedImage forState:UIControlStateHighlighted];
    [_stopButton addTarget:self action:@selector(stopButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView addSubview:_stopButton];
    
    _actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, actionImage.size.width, actionImage.size.height)];
    _actionButton.adjustsImageWhenDisabled = false;
    _actionButton.adjustsImageWhenHighlighted = false;
    _actionButton.exclusiveTouch = true;
    [_actionButton setBackgroundImage:actionImage forState:UIControlStateNormal];
    [_actionButton setBackgroundImage:actionHighlightedImage forState:UIControlStateHighlighted];
    [_actionButton addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView addSubview:_actionButton];
    
    _maximizeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, actionImage.size.width, actionImage.size.height)];
    _maximizeButton.adjustsImageWhenDisabled = false;
    _maximizeButton.adjustsImageWhenHighlighted = false;
    _maximizeButton.exclusiveTouch = true;
    [_maximizeButton setBackgroundImage:maximizeImage forState:UIControlStateNormal];
    [_maximizeButton setBackgroundImage:maximizeHighlightedImage forState:UIControlStateHighlighted];
    [_maximizeButton addTarget:self action:@selector(maximizeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView addSubview:_maximizeButton];
    
    _customActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _customActivityIndicator.alpha = 0.0f;
    _customActivityIndicator.hidden = true;
    UIView *activityIndicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _customActivityIndicator.frame.size.width + 4, _customActivityIndicator.frame.size.height)];
    [activityIndicatorContainer addSubview:_customActivityIndicator];
    
    _customNavigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorContainer];
    [_customActivityIndicator startAnimating];
    
    [self.view addSubview:_customNavigationBar];
}

- (void)doUnloadView
{
    _webView.delegate = nil;
    _webView = nil;
    
    _toolbarView = nil;
    _backButton = nil;
    _forwardButton = nil;
    _reloadButton = nil;
    _stopButton = nil;
    _actionButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateViewLayout:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setNavigationBarHidden:true animated:false];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            [TGHacks setApplicationStatusBarAlpha:1.0f];
        }];
    }
    else
        [TGHacks setApplicationStatusBarAlpha:1.0f];
    
    [super viewWillDisappear:animated];
}

- (void)updateViewLayout:(UIInterfaceOrientation)orientation
{
    _overlayBackButton.hidden = UIInterfaceOrientationIsPortrait(orientation);
    
    float toolbarHeight = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
    
    _toolbarView.frame = CGRectMake(0, self.view.frame.size.height + ((UIInterfaceOrientationIsLandscape(orientation) && _maximizeInLandscape) ? 0 : -toolbarHeight), self.view.frame.size.width, 44);
    
    _toolbarBackgroundView.image = [UIImage imageNamed:(UIInterfaceOrientationIsPortrait(orientation) ? @"BrowserFooter.png" : @"BrowserFooter_Landscape.png")];
    
    CGSize buttonSize = _backButton.frame.size;
    float padding = 10;
    int buttonCount = UIInterfaceOrientationIsPortrait(orientation) ? 4 : 5;
    float spacing = floorf((_toolbarView.frame.size.width - buttonSize.width * buttonCount - padding * 2) / (buttonCount - 1));
    
    CGPoint buttonPosition = CGPointMake(padding, floorf((toolbarHeight - buttonSize.height) / 2 - 1));
    
    _backButton.frame = CGRectMake(buttonPosition.x, buttonPosition.y, buttonSize.width, buttonSize.height);
    buttonPosition.x += buttonSize.width + spacing;
    
    _forwardButton.frame = CGRectMake(buttonPosition.x, buttonPosition.y, buttonSize.width, buttonSize.height);
    buttonPosition.x += buttonSize.width + spacing;
    
    _reloadButton.frame = CGRectMake(buttonPosition.x, buttonPosition.y, buttonSize.width, buttonSize.height);
    _stopButton.frame = _reloadButton.frame;
    buttonPosition.x += buttonSize.width + spacing;
    
    _actionButton.frame = CGRectMake(buttonPosition.x, buttonPosition.y, buttonSize.width, buttonSize.height);
    buttonPosition.x += buttonSize.width + spacing;
    
    _maximizeButton.frame = CGRectMake(buttonPosition.x, buttonPosition.y, buttonSize.width, buttonSize.height);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self adjustNavigationAppearanceAnimated:toInterfaceOrientation duration:duration];

    [self updateViewLayout:toInterfaceOrientation];
    
    [self controllerInsetUpdated:self.controllerInset];
    
    float statusBarAlpha = (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && _maximizeInLandscape) ? 0.0f : 1.0f;
    [TGHacks setApplicationStatusBarAlpha:statusBarAlpha];

    CGRect frame = self.statusBarBackgroundView.frame;
    frame.origin.y = statusBarAlpha < FLT_EPSILON ? -frame.size.height : 0;
    self.statusBarBackgroundView.frame = frame;
 
    [self setTitleText:_genericTitleLabel.text forOrientation:toInterfaceOrientation];
}

- (void)adjustNavigationAppearanceAnimated:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)__unused duration
{
    bool navigationBarHidden = false;
    
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        navigationBarHidden = false;
    }
    else
    {
        navigationBarHidden = true;
    }
    
    _customWantsNavigationBarHidden = navigationBarHidden;
    
    _customNavigationBar.alpha = navigationBarHidden ? 0.0f : 1.0f;
    //[self setNavigationBarHidden:navigationBarHidden withAnimation:TGViewControllerNavigationBarAnimationSlideFar duration:duration];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    _customNavigationBar.frame = CGRectMake(0, self.controllerStatusBarHeight, self.view.frame.size.width, 44);
    
    _overlayBackButton.frame = CGRectMake(_overlayBackButton.frame.origin.x, (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && _maximizeInLandscape) ? 8 : 28, _overlayBackButton.frame.size.width, _overlayBackButton.frame.size.height);
    
    _minimizeOverlayButton.alpha = (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && _maximizeInLandscape) ? 1.0f : 0.0f;
    
    [self adjustScrollViewContentInset:self.interfaceOrientation];
}

- (void)adjustScrollViewContentInset:(UIInterfaceOrientation)orientation
{
    UIEdgeInsets scrollInset = UIEdgeInsetsMake(0, 0, (UIInterfaceOrientationIsLandscape(orientation) && _maximizeInLandscape) ? 0 : (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 44 : 32), 0);
    
    scrollInset.bottom = MAX(self.controllerInset.bottom, scrollInset.bottom);
    
    float barHeight = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 44 : 0);
    
    CGRect webViewFrame = CGRectMake(0, (UIInterfaceOrientationIsLandscape(orientation) && _maximizeInLandscape) ? 0 : (self.controllerStatusBarHeight + barHeight), self.view.frame.size.width, self.view.frame.size.height - ((UIInterfaceOrientationIsLandscape(orientation) && _maximizeInLandscape) ? 0 : ((UIInterfaceOrientationIsPortrait(orientation) ? 44 : 0) + self.controllerStatusBarHeight)));
    
    scrollInset.top = webViewFrame.origin.y;
    webViewFrame.size.height += webViewFrame.origin.y;
    webViewFrame.origin.y = 0;
    
    _webView.frame = webViewFrame;
    
    //[TGHacks setWebScrollViewContentInsetEnabled:_webView.scrollView enabled:true];
    [_webView.scrollView setContentInset:scrollInset];
    [_webView.scrollView setScrollIndicatorInsets:scrollInset];
    //[TGHacks setWebScrollViewContentInsetEnabled:_webView.scrollView enabled:false];
}

#pragma mark -

- (void)performBackAction
{
    if (ABS(self.controllerStatusBarHeight - _customNavigationBar.frame.origin.y) < FLT_EPSILON)
    {
        if (!_customWantsNavigationBarHidden)
        {
            [self setNavigationBarHidden:false animated:false];
            _customNavigationBar.alpha = 0.0f;
        }
    }
    
    [self.navigationController popViewControllerAnimated:true];
}

- (void)webViewDidStartLoad:(UIWebView *)__unused webView
{
    _customActivityIndicator.hidden = false;
    [_customActivityIndicator startAnimating];
    
    [UIView animateWithDuration:0.2f animations:^
    {
        _customActivityIndicator.alpha = 1.0f;
        _stopButton.alpha = 1.0f;
        _reloadButton.alpha = 0.0f;
    }];
    
    [self updateWebInterface];
}

- (void)webViewDidFinishLoad:(UIWebView *)__unused webView
{
    [UIView animateWithDuration:0.2f animations:^
    {
        _customActivityIndicator.alpha = 0.0f;
        _stopButton.alpha = 0.0f;
        _reloadButton.alpha = 1.0f;
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            _customActivityIndicator.hidden = true;
            [_customActivityIndicator stopAnimating];
        }
    }];
    
    NSString *pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self setTitleText:pageTitle];
    
    [self updateWebInterface];
}

- (void)webView:(UIWebView *)__unused webView didFailLoadWithError:(NSError *)__unused error
{
    [UIView animateWithDuration:0.2f animations:^
    {
        _customActivityIndicator.alpha = 0.0f;
        _stopButton.alpha = 0.0f;
        _reloadButton.alpha = 1.0f;
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            _customActivityIndicator.hidden = true;
            [_customActivityIndicator stopAnimating];
        }
    }];
    
    NSString *pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (pageTitle.length == 0)
        pageTitle = _displayUrl;
    self.titleText = pageTitle;
    
    if (error.code == -999)
        return;
    
    TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Web.Error") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
    [alertView show];
    
    [self updateWebInterface];
}

- (void)updateWebInterface
{
    _backButton.enabled = _webView.canGoBack;
    _forwardButton.enabled = _webView.canGoForward;
    
    _backButton.alpha = _backButton.enabled ? 1.0f : 0.4f;
    _forwardButton.alpha = _forwardButton.enabled ? 1.0f : 0.4f;
    
    if (_webView.isLoading)
    {
    }
    else
    {
        NSString *pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        self.titleText = pageTitle;
    }
}

- (BOOL)webView:(UIWebView *)__unused myWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)__unused navigationType
{
    bool loadNative = false;
    
    if (![request.URL.scheme isEqualToString:@"http"] && ![request.URL.scheme isEqualToString:@"https"])
    {
        loadNative = true;
    }
    
    if ([request.URL.host isEqualToString:@"itunes.apple.com"])
        loadNative = true;
    
    if (loadNative && navigationType != UIWebViewNavigationTypeOther)
    {
        TGLog(@"Open native: %@", request.URL);
        [(id<TGAppManager>)[UIApplication sharedApplication].delegate openURLNative:request.URL];
            return false;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self updateWebInterface];
    });
    return true;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView == _webView.scrollView)
    {
        return [_webViewScrolDelegate viewForZoomingInScrollView:scrollView];
    }
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if (scrollView == _webView.scrollView)
    {
        [_webViewScrolDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scrollView == _webView.scrollView)
    {
        [_webViewScrolDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView == _webView.scrollView)
    {
        [_webViewScrolDelegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _webView.scrollView)
    {
        float scrollOffset = MIN(MAX(-44, -scrollView.contentOffset.y - scrollView.contentInset.top + _draggingStartPosition + _draggingStartOffset), 0);
        
        if (_draggingInProgress)
        {
            CGRect frame = _customNavigationBar.frame;
            frame.origin.y = self.controllerStatusBarHeight + scrollOffset;
            _customNavigationBar.frame = frame;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _webView.scrollView)
    {
        _draggingInProgress = true;
        _draggingStartPosition = scrollView.contentOffset.y;
        _draggingStartOffset = _customNavigationBar.frame.origin.y + 44;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)__unused decelerate
{
    if (scrollView == _webView.scrollView)
    {
        _draggingInProgress = false;
        
        CGRect frame = _customNavigationBar.frame;
        
        if (frame.origin.y - self.controllerStatusBarHeight > -22)
            frame.origin.y = self.controllerStatusBarHeight;
        else
            frame.origin.y = self.controllerStatusBarHeight - 44;
        
        [UIView animateWithDuration:0.3 animations:^
        {
            _customNavigationBar.frame = frame;
        }];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if (scrollView == _webView.scrollView)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            CGRect frame = _customNavigationBar.frame;
            frame.origin.y = self.controllerStatusBarHeight;
            _customNavigationBar.frame = frame;
        }];
    }
    
    return true;
}

#pragma mark -

- (void)backButtonPressed
{
    [_webView goBack];
}

- (void)forwardButtonPressed
{
    [_webView goForward];
}

- (void)stopButtonPressed
{
    [_webView stopLoading];
}

- (void)reloadButtonPressed
{
    [_webView reload];
}

- (void)actionButtonPressed
{
    _currentActionSheet.delegate = nil;
    _currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [_currentActionSheet addButtonWithTitle:TGLocalized(@"Web.OpenExternal")];
    [_currentActionSheet addButtonWithTitle:TGLocalized(@"Web.CopyLink")];
    
    _currentActionSheet.cancelButtonIndex = [_currentActionSheet addButtonWithTitle:TGLocalized(@"Common.Cancel")];
    
    [_currentActionSheet showInView:self.view];
}

- (void)maximizeButtonPressed
{
    _maximizeInLandscape = true;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        [self updateViewLayout:self.interfaceOrientation];
        [self controllerInsetUpdated:self.controllerInset];
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            [TGHacks setApplicationStatusBarAlpha:0.0f];
            
            CGRect frame = self.statusBarBackgroundView.frame;
            frame.origin.y = -frame.size.height;
            self.statusBarBackgroundView.frame = frame;
        }
    }];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        [TGHacks animateApplicationStatusBarAppearance:TGStatusBarAppearanceAnimationSlideUp duration:0.3 completion:nil];
    }
}

- (void)minimizeButtonPressed
{
    _maximizeInLandscape = false;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        [self updateViewLayout:self.interfaceOrientation];
        [self controllerInsetUpdated:self.controllerInset];
        
        [TGHacks setApplicationStatusBarAlpha:1.0f];
        
        CGRect frame = self.statusBarBackgroundView.frame;
        frame.origin.y = 0;
        self.statusBarBackgroundView.frame = frame;
    }];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        [TGHacks animateApplicationStatusBarAppearance:TGStatusBarAppearanceAnimationSlideDown duration:0.3 completion:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)__unused actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _currentActionSheet.delegate = nil;
    _currentActionSheet = nil;
    
    if (buttonIndex == 0)
    {
        if ([[UIApplication sharedApplication].delegate conformsToProtocol:@protocol(TGAppManager)])
        {
            NSURL *url = _webView.request.URL;
            if (url == nil || url.absoluteString.length == 0)
                url = [NSURL URLWithString:_url];
            [(id<TGAppManager>)[UIApplication sharedApplication].delegate openURLNative:url];
        }
    }
    else if (buttonIndex == 1)
    {
        NSURL *url = _webView.request.URL;
        if (url == nil)
            url = [NSURL URLWithString:_url];
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if (url != nil)
            [pasteboard setString:[NSString stringWithString:_url]];
    }
}

@end
