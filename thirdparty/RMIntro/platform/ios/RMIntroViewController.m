//
//  RMIntroViewController.m
//  IntroOpenGL
//
//  Created by Ilya Rimchikov on 19/01/14.
//
//

#import "RMGeometry.h"

#import "TGLoginPhoneController.h"
#import "TGModernButton.h"

#import "RMIntroViewController.h"
#import "RMIntroPageView.h"

#include "animations.h"
#include "objects.h"
#include "texture_helper.h"

#include "TGAppDelegate.h"

#import "TGTelegramNetworking.h"

#import "TGFont.h"

#import "TGLocalizationSignals.h"
#import "TGAnimationUtils.h"
#import "TGProgressWindow.h"

#import "TGDatabase.h"

@interface UIScrollView (CurrentPage)
- (int)currentPage;
- (void)setPage:(NSInteger)page;
- (int)currentPageMin;
- (int)currentPageMax;

@end

@implementation UIScrollView (CurrentPage)

- (int)currentPage
{
    CGFloat pageWidth = self.frame.size.width;
    return (int)floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (int)currentPageMin
{
    CGFloat pageWidth = self.frame.size.width;
    return (int)floor((self.contentOffset.x - pageWidth / 2 - pageWidth / 2) / pageWidth) + 1;
}

- (int)currentPageMax
{
    CGFloat pageWidth = self.frame.size.width;
    return (int)floor((self.contentOffset.x - pageWidth / 2 + pageWidth / 2 ) / pageWidth) + 1;
}

- (void)setPage:(NSInteger)page
{
    self.contentOffset = CGPointMake(self.frame.size.width*page, 0);
}
@end


@interface RMIntroViewController () <UIGestureRecognizerDelegate>
{
    id _didEnterBackgroundObserver;
    id _willEnterBackgroundObserver;
    
    UIImageView *_stillLogoView;
    bool _displayedStillLogo;
    
    UIButton *_switchToDebugButton;
    
    TGModernButton *_alternativeLanguageButton;
    
    SMetaDisposable *_localizationsDisposable;
    TGSuggestedLocalization *_alternativeLocalizationInfo;
    
    SVariable *_alternativeLocalization;
}
@end


@implementation RMIntroViewController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        if (iosMajorVersion() >= 7)
            self.automaticallyAdjustsScrollViewInsets = false;
        
        self.wantsFullScreenLayout = true;
        
        _headlines = @[ TGLocalized(@"Tour.Title1"), TGLocalized(@"Tour.Title2"),  TGLocalized(@"Tour.Title6"), TGLocalized(@"Tour.Title3"), TGLocalized(@"Tour.Title4"), TGLocalized(@"Tour.Title5")];
        _descriptions = @[TGLocalized(@"Tour.Text1"), TGLocalized(@"Tour.Text2"),  TGLocalized(@"Tour.Text6"), TGLocalized(@"Tour.Text3"), TGLocalized(@"Tour.Text4"), TGLocalized(@"Tour.Text5")];
        
        __weak RMIntroViewController *weakSelf = self;
        _didEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(__unused NSNotification *notification)
        {
            __strong RMIntroViewController *strongSelf = weakSelf;
            [strongSelf stopTimer];
        }];
        
        _willEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(__unused NSNotification *notification)
        {
            __strong RMIntroViewController *strongSelf = weakSelf;
            [strongSelf loadGL];
            [strongSelf startTimer];
        }];
        
        _alternativeLanguageButton = [[TGModernButton alloc] init];
        _alternativeLanguageButton.modernHighlight = true;
        [_alternativeLanguageButton setTitleColor:TGAccentColor()];
        _alternativeLanguageButton.titleLabel.font = TGSystemFontOfSize(18.0f);
        _alternativeLanguageButton.hidden = true;
        [_alternativeLanguageButton addTarget:self action:@selector(alternativeLanguageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _alternativeLocalization = [[SVariable alloc] init];
        
        SSignal *localizationSignal = [TGLocalizationSignals suggestedLocalization];
#ifdef DEBUG
        localizationSignal = [localizationSignal delay:1.0 onQueue:[SQueue mainQueue]];
#endif
        _localizationsDisposable = [[localizationSignal deliverOn:[SQueue mainQueue]] startWithNext:^(TGSuggestedLocalization *next) {
            __strong RMIntroViewController *strongSelf = weakSelf;
            if (strongSelf != nil && next != nil) {
                if (strongSelf->_alternativeLocalizationInfo == nil) {
                    _alternativeLocalizationInfo = next;
                    
                    [strongSelf->_alternativeLanguageButton setTitle:next.continueWithLanguageString forState:UIControlStateNormal];
                    strongSelf->_alternativeLanguageButton.hidden = false;
                    [strongSelf->_alternativeLanguageButton sizeToFit];
                    
                    if ([strongSelf isViewLoaded]) {
                        [strongSelf->_alternativeLanguageButton.layer animateAlphaFrom:0.0f to:1.0f duration:0.3f timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
                        [UIView animateWithDuration:0.3 animations:^{
                            [strongSelf viewWillLayoutSubviews];
                        }];
                    }
                }
            }
        }];
    }
    return self;
}

- (void)startTimer
{
    if (_updateAndRenderTimer == nil)
    {
        _updateAndRenderTimer = [NSTimer timerWithTimeInterval:1.0f / 60.0f target:self selector:@selector(updateAndRender) userInfo:nil repeats:true];
        [[NSRunLoop mainRunLoop] addTimer:_updateAndRenderTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer
{
    if (_updateAndRenderTimer != nil)
    {
        [_updateAndRenderTimer invalidate];
        _updateAndRenderTimer = nil;
    }
}


- (void)loadView
{
    [super loadView];
    
#if defined(DEBUG) || defined(INTERNAL_RELEASE)
    [self.view addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(switchToDebugPressed:)]];
#endif
}

- (void)switchToDebugPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (_switchToDebugButton == nil)
        {
            _switchToDebugButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 45.0f, self.view.frame.size.width, 45.0f)];
            _switchToDebugButton.backgroundColor = [UIColor grayColor];
            [_switchToDebugButton setTitle:!TGAppDelegateInstance.useDifferentBackend ? @"Switch to production" : @"Switch to debug" forState:UIControlStateNormal];
            [_switchToDebugButton addTarget:self action:@selector(reallySwitchToDebugPressed) forControlEvents:UIControlEventTouchUpInside];
            [self.view removeGestureRecognizer:recognizer];
            [self.view addSubview:_switchToDebugButton];
        }
    }
}

- (void)reallySwitchToDebugPressed
{
    [[TGTelegramNetworking instance] switchBackends];
}

- (void)loadGL
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground && !_isOpenGLLoaded)
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!context)
            NSLog(@"Failed to create ES context");
        
        bool isIpad = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
        
        CGFloat size = 200;
        if (isIpad)
            size *= 1.2;
        
        int height = 50;
        if (isIpad)
            height += 138 / 2;
        
        _glkView = [[GLKView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - size / 2, height, size, size) context:context];
        _glkView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        _glkView.drawableMultisample = GLKViewDrawableMultisample4X;
        _glkView.enableSetNeedsDisplay = false;
        _glkView.userInteractionEnabled = false;
        _glkView.delegate = self;
        
        int patchHalfWidth = 1;
        UIView *v1 = [[UIView alloc] initWithFrame:CGRectMake(-patchHalfWidth, -patchHalfWidth, _glkView.frame.size.width + patchHalfWidth * 2, patchHalfWidth * 2)];
        UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(-patchHalfWidth, -patchHalfWidth, patchHalfWidth * 2, _glkView.frame.size.height + patchHalfWidth * 2)];
        UIView *v3 = [[UIView alloc] initWithFrame:CGRectMake(-patchHalfWidth, -patchHalfWidth + _glkView.frame.size.height, _glkView.frame.size.width + patchHalfWidth * 2, patchHalfWidth * 2)];
        UIView *v4 = [[UIView alloc] initWithFrame:CGRectMake(-patchHalfWidth + _glkView.frame.size.width, -patchHalfWidth, patchHalfWidth * 2, _glkView.frame.size.height + patchHalfWidth * 2)];
        
        v1.backgroundColor = v2.backgroundColor = v3.backgroundColor = v4.backgroundColor = [UIColor whiteColor];
        
        [_glkView addSubview:v1];
        [_glkView addSubview:v2];
        [_glkView addSubview:v3];
        [_glkView addSubview:v4];
        
        [self setupGL];
        [self.view addSubview:_glkView];
        
        [self startTimer];
        _isOpenGLLoaded = true;
    }
}

- (void)freeGL
{
    if (!_isOpenGLLoaded)
        return;

    [self stopTimer];
    
    if ([EAGLContext currentContext] == _glkView.context)
        [EAGLContext setCurrentContext:nil];

    _glkView.context = nil;
    context = nil;
    [_glkView removeFromSuperview];
    _glkView = nil;
    _isOpenGLLoaded = false;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadGL];
    
    bool isIpad = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
    
    _pageScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    _pageScrollView.clipsToBounds = true;
    _pageScrollView.opaque = true;
    _pageScrollView.clearsContextBeforeDrawing = false;
    [_pageScrollView setShowsHorizontalScrollIndicator:false];
    [_pageScrollView setShowsVerticalScrollIndicator:false];
    _pageScrollView.pagingEnabled = true;
    _pageScrollView.contentSize = CGSizeMake(_headlines.count * self.view.bounds.size.width, self.view.bounds.size.height);
    _pageScrollView.delegate = self;
    [self.view addSubview:_pageScrollView];
    
    _pageViews = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < _headlines.count; i++)
    {
        RMIntroPageView *p = [[RMIntroPageView alloc]initWithFrame:CGRectMake(i * self.view.bounds.size.width, 0, self.view.bounds.size.width, 0) headline:[_headlines objectAtIndex:i] description:[_descriptions objectAtIndex:i]];
        p.opaque = true;
        p.clearsContextBeforeDrawing = false;
        [_pageViews addObject:p];
        [_pageScrollView addSubview:p];
    }
    [_pageScrollView setPage:0];
    
    _startButton = [[TGModernButton alloc] init];
    ((TGModernButton *)_startButton).modernHighlight = false;
    [_startButton setTitle:TGLocalized(@"Tour.StartButton") forState:UIControlStateNormal];
    [_startButton.titleLabel setFont:TGMediumSystemFontOfSize(20.0f)];
    [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(48.0f, 48.0f), false, 0.0f);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(contextRef, UIColorRGB(0x2ca5e0).CGColor);
        CGContextFillEllipseInRect(contextRef, CGRectMake(0.0f, 0.0f, 48.0f, 48.0f));
        UIImage *startButtonImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:24 topCapHeight:24];
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(48.0f, 48.0f), false, 0.0f);
        contextRef = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(contextRef, UIColorRGB(0x227eab).CGColor);
        CGContextFillEllipseInRect(contextRef, CGRectMake(0.0f, 0.0f, 48.0f, 48.0f));
        UIImage *startButtonHighlightedImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:24 topCapHeight:24];
        UIGraphicsEndImageContext();
        
        [_startButton setBackgroundImage:startButtonImage forState:UIControlStateNormal];
        [_startButton setBackgroundImage:startButtonHighlightedImage forState:UIControlStateHighlighted];
        [_startButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f)];
    }
    _startArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:isIpad ? @"start_arrow_ipad.png" : @"start_arrow.png"]];
    _startButton.titleLabel.clipsToBounds = false;
    _startArrow.frame = CGRectChangedOrigin(_startArrow.frame, CGPointMake([_startButton.titleLabel.text sizeWithFont:_startButton.titleLabel.font].width + (isIpad ? 7 : 6), isIpad ? 6.5f : 4.5f));
    //[_startButton.titleLabel addSubview:_startArrow];
    [self.view addSubview:_startButton];
    
    [self.view addSubview:_alternativeLanguageButton];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    _pageControl.userInteractionEnabled = false;
    [_pageControl setPageIndicatorTintColor:[UIColor colorWithWhite:.85 alpha:1]];
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithWhite:.2 alpha:1]];
    [_pageControl setNumberOfPages:6];
    [self.view addSubview:_pageControl];
}

- (BOOL)shouldAutorotate
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return true;
    
    return false;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    
    return UIInterfaceOrientationMaskPortrait;
}

- (DeviceScreen)deviceScreen
{
    CGSize viewSize = self.view.frame.size;
    int max = (int)MAX(viewSize.width, viewSize.height);
    
    DeviceScreen deviceScreen = Inch55;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        switch (max)
        {
            case 1366:
                deviceScreen = iPadPro;
                break;
                
            default:
                deviceScreen = iPad;
                break;
        }
    }
    else
    {
        switch (max)
        {
            case 480:
                deviceScreen = Inch35;
                break;
            case 568:
                deviceScreen = Inch4;
                break;
            case 667:
                deviceScreen = Inch47;
                break;
            default:
                deviceScreen = Inch55;
                break;
        }
    }
    
    return deviceScreen;
}

- (void)viewWillLayoutSubviews
{
    UIInterfaceOrientation isVertical = (self.view.bounds.size.height / self.view.bounds.size.width > 1.0f);
    
    CGFloat statusBarHeight = (iosMajorVersion() >= 7) ? 0 : 20;
    
    CGFloat pageControlY = 0;
    CGFloat glViewY = 0;
    CGFloat startButtonY = 0;
    CGFloat pageY = 0;
    
    CGFloat languageButtonSpread = 60.0f;
    CGFloat languageButtonOffset = 26.0f;
    
    DeviceScreen deviceScreen = [self deviceScreen];
    switch (deviceScreen)
    {
        case iPad:
            glViewY = isVertical ? 121 + 90 : 121;
            startButtonY = 120;
            pageY = isVertical ? 485 : 335;
            pageControlY = pageY + 200.0f;
            break;
        
        case iPadPro:
            glViewY = isVertical ? 221 + 110 : 221;
            startButtonY = 120;
            pageY = isVertical ? 605 : 435;
            pageControlY = pageY + 200.0f;
            break;
            
        case Inch35:
            pageControlY = 162 / 2;
            glViewY = 62 - 20;
            startButtonY = 75;
            pageY = 215;
            pageControlY = pageY + 160.0f;
            if (!_alternativeLanguageButton.isHidden) {
                glViewY -= 40.0f;
                pageY -= 40.0f;
                pageControlY -= 40.0f;
                startButtonY -= 30.0f;
            }
            languageButtonSpread = 65.0f;
            languageButtonOffset = 15.0f;
            break;
            
        case Inch4:
            glViewY = 62;
            startButtonY = 75;
            pageY = 245;
            pageControlY = pageY + 160.0f;
            languageButtonSpread = 50.0f;
            languageButtonOffset = 20.0f;
            break;

        case Inch47:
            pageControlY = 162 / 2 + 10;
            glViewY = 62 + 25;
            startButtonY = 75 + 5;
            pageY = 245 + 50;
            pageControlY = pageY + 160.0f;
            break;

        case Inch55:
            glViewY = 62 + 45;
            startButtonY = 75 + 20;
            pageY = 245 + 85;
            pageControlY = pageY + 160.0f;
            break;
            
        default:
            break;
    }
    
    if (!_alternativeLanguageButton.isHidden) {
        startButtonY += languageButtonSpread;
    }
    
    _pageControl.frame = CGRectMake(0, pageControlY, self.view.bounds.size.width, 7);
    _glkView.frame = CGRectChangedOriginY(_glkView.frame, glViewY - statusBarHeight);
    
    [_startButton sizeToFit];
    _startButton.frame = CGRectMake(CGFloor((self.view.bounds.size.width - _startButton.frame.size.width) / 2.0f), self.view.bounds.size.height - startButtonY - statusBarHeight, _startButton.frame.size.width, 48.0f);
    [_startButton addTarget:self action:@selector(startButtonPress) forControlEvents:UIControlEventTouchUpInside];\
    
    _alternativeLanguageButton.frame = CGRectMake(CGFloor((self.view.bounds.size.width - _alternativeLanguageButton.frame.size.width) / 2.0f), CGRectGetMaxY(_startButton.frame) + languageButtonOffset, _alternativeLanguageButton.frame.size.width, _alternativeLanguageButton.frame.size.height);
    
    _pageScrollView.frame=CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 20);
    _pageScrollView.contentSize=CGSizeMake(_headlines.count * self.view.bounds.size.width, 150);
    _pageScrollView.contentOffset = CGPointMake(_currentPage * self.view.bounds.size.width, 0);
    
    [_pageViews enumerateObjectsUsingBlock:^(UIView *pageView, NSUInteger index, __unused BOOL *stop)
    {
        pageView.frame = CGRectMake(index * self.view.bounds.size.width, (pageY - statusBarHeight), self.view.bounds.size.width, 150);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_stillLogoView == nil && !_displayedStillLogo)
    {
        _displayedStillLogo = true;
        
        _stillLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"telegram_logo_still.png"]];
        _stillLogoView.contentMode = UIViewContentModeCenter;
        _stillLogoView.bounds = CGRectMake(0, 0, 200, 200);
        
        UIInterfaceOrientation isVertical = (self.view.bounds.size.height / self.view.bounds.size.width > 1.0f);
        
        CGFloat statusBarHeight = (iosMajorVersion() >= 7) ? 0 : 20;
        
        CGFloat glViewY = 0;
        DeviceScreen deviceScreen = [self deviceScreen];
        switch (deviceScreen)
        {
            case iPad:
                glViewY = isVertical ? 121 + 90 : 121;
                break;
                
            case iPadPro:
                glViewY = isVertical ? 221 + 110 : 221;
                break;
                
            case Inch35:
                glViewY = 62 - 20;
                break;
                
            case Inch4:
                glViewY = 62;
                break;
                
            case Inch47:
                glViewY = 62 + 25;
                break;
                
            case Inch55:
                glViewY = 62 + 45;
                break;
                
            default:
                break;
        }
        
        _stillLogoView.frame = CGRectChangedOriginY(_glkView.frame, glViewY - statusBarHeight);
        [self.view addSubview:_stillLogoView];
    }
    
    [self loadGL];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_stillLogoView != nil)
    {
        [_stillLogoView removeFromSuperview];
        _stillLogoView = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self freeGL];
}

- (void)startButtonPress
{
    if (_alternativeLocalizationInfo != nil) {
        [TGDatabaseInstance() setCustomProperty:@"checkedLocalization" value:[_alternativeLocalizationInfo.info.code dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    TGLoginPhoneController *phoneController = [[TGLoginPhoneController alloc] init];
    [self.navigationController pushViewController:phoneController animated:true];
}

- (void)updateAndRender
{
    [_glkView display];
    
    TGDispatchOnMainThread(^
    {
        if (_stillLogoView != nil)
        {
            [_stillLogoView removeFromSuperview];
            _stillLogoView = nil;
        }
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_didEnterBackgroundObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_willEnterBackgroundObserver];
    
    [self freeGL];
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:_glkView.context];
    
    
    set_telegram_textures(setup_texture(@"telegram_sphere.png"), setup_texture(@"telegram_plane.png"));
    
    set_ic_textures(setup_texture(@"ic_bubble_dot.png"), setup_texture(@"ic_bubble.png"), setup_texture(@"ic_cam_lens.png"), setup_texture(@"ic_cam.png"), setup_texture(@"ic_pencil.png"), setup_texture(@"ic_pin.png"), setup_texture(@"ic_smile_eye.png"), setup_texture(@"ic_smile.png"), setup_texture(@"ic_videocam.png"));
    
    set_fast_textures(setup_texture(@"fast_body.png"), setup_texture(@"fast_spiral.png"), setup_texture(@"fast_arrow.png"), setup_texture(@"fast_arrow_shadow.png"));
    
    set_free_textures(setup_texture(@"knot_up.png"), setup_texture(@"knot_down.png"));
    
    set_powerful_textures(setup_texture(@"powerful_mask.png"), setup_texture(@"powerful_star.png"), setup_texture(@"powerful_infinity.png"), setup_texture(@"powerful_infinity_white.png"));
    
     set_private_textures(setup_texture(@"private_door.png"), setup_texture(@"private_screw.png"));
    
    
    set_need_pages(0);
    
    
    on_surface_created();
    on_surface_changed(200, 200, 1, 0,0,0,0,0);
}

#pragma mark - GLKView delegate methods

- (void)glkView:(GLKView *)__unused view drawInRect:(CGRect)__unused rect
{
    double time = CFAbsoluteTimeGetCurrent();
    
    set_page((int)_currentPage);
    set_date(time);
    
    on_draw_frame();
}

static CGFloat x;
static bool justEndDragging;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)__unused decelerate
{
    x = scrollView.contentOffset.x;
    justEndDragging = true;
}

NSInteger _current_page_end;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = (scrollView.contentOffset.x - _currentPage * scrollView.frame.size.width) / self.view.frame.size.width;
    
    set_scroll_offset((float)offset);
    
    if (justEndDragging)
    {
        justEndDragging = false;
        
        CGFloat page = scrollView.contentOffset.x / scrollView.frame.size.width;
        CGFloat sign = scrollView.contentOffset.x - x;
        
        if (sign > 0)
        {
            if (page > _currentPage)
                _currentPage++;
        }
        
        if (sign < 0)
        {
            if (page < _currentPage)
                _currentPage--;
        }
        
        _currentPage = MAX(0, MIN(5, _currentPage));
        _current_page_end = _currentPage;
    }
    else
    {
        if (_pageScrollView.contentOffset.x > _current_page_end*_pageScrollView.frame.size.width)
        {
            if (_pageScrollView.currentPageMin > _current_page_end) {
                _currentPage = [_pageScrollView currentPage];
                _current_page_end = _currentPage;
            }
        }
        else
        {
            if (_pageScrollView.currentPageMax < _current_page_end)
            {
                _currentPage = [_pageScrollView currentPage];
                _current_page_end = _currentPage;
            }
        }
    }
    
    [_pageControl setCurrentPage:_currentPage];
}

- (void)updateLocalization {
    [_startButton setTitle:TGLocalized(@"Tour.StartButton") forState:UIControlStateNormal];
    
    _headlines = @[ TGLocalized(@"Tour.Title1"), TGLocalized(@"Tour.Title2"),  TGLocalized(@"Tour.Title6"), TGLocalized(@"Tour.Title3"), TGLocalized(@"Tour.Title4"), TGLocalized(@"Tour.Title5")];
    _descriptions = @[TGLocalized(@"Tour.Text1"), TGLocalized(@"Tour.Text2"),  TGLocalized(@"Tour.Text6"), TGLocalized(@"Tour.Text3"), TGLocalized(@"Tour.Text4"), TGLocalized(@"Tour.Text5")];
}

- (void)alternativeLanguageButtonPressed {
    if (_alternativeLocalizationInfo != nil) {
        [TGDatabaseInstance() setCustomProperty:@"checkedLocalization" value:[_alternativeLocalizationInfo.info.code dataUsingEncoding:NSUTF8StringEncoding]];
        
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow showWithDelay:0.1];
        __weak RMIntroViewController *weakSelf = self;
        [[[[TGLocalizationSignals applyLocalization:_alternativeLocalizationInfo.info.code] deliverOn:[SQueue mainQueue]] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
            });
        }] startWithNext:nil error:^(id error) {
            
        } completed:^{
            __strong RMIntroViewController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf startButtonPress];
            }
        }];
    }
}

@end
