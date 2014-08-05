//
//  RMIntroViewController.m
//  IntroOpenGL
//
//  Created by Ilya Rimchikov on 19/01/14.
//
//

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define dDeviceOrientation [[UIDevice currentDevice] orientation]
#define isPortrait  UIDeviceOrientationIsPortrait(dDeviceOrientation)
#define isLandscape UIDeviceOrientationIsLandscape(dDeviceOrientation)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define _(n) NSLocalizedString(n, nil)

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

@interface UIScrollView (CurrentPage)
- (int)currentPage;
- (void)setPage:(NSInteger)page;
- (int)currentPageMin;
- (int)currentPageMax;

@end
@implementation UIScrollView (CurrentPage)
- (int)currentPage{
    CGFloat pageWidth = self.frame.size.width;
    return floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (int)currentPageMin{
    CGFloat pageWidth = self.frame.size.width;
    return floor((self.contentOffset.x - pageWidth / 2 - pageWidth / 2) / pageWidth) + 1;
}

- (int)currentPageMax{
    CGFloat pageWidth = self.frame.size.width;
    return floor((self.contentOffset.x - pageWidth / 2 + pageWidth / 2 ) / pageWidth) + 1;
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
}

@end

@implementation RMIntroViewController


@synthesize rootVC;
@synthesize draw_q;


- (id)init
{
    self = [super init];
    if (self) {
        
        if (iosMajorVersion() >= 7)
            self.automaticallyAdjustsScrollViewInsets = false;
        
        _headlines = @[_(@"Tour.Title1"), _(@"Tour.Title2"),  _(@"Tour.Title6"), _(@"Tour.Title3"), _(@"Tour.Title4"), _(@"Tour.Title5")];
        _descriptions = @[_(@"Tour.Text1"), _(@"Tour.Text2"),  _(@"Tour.Text6"), _(@"Tour.Text3"), _(@"Tour.Text4"), _(@"Tour.Text5")];
     
        //[self startTimer];
        
        __weak RMIntroViewController *weakSelf = self;
        
        _didEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(__unused NSNotification *note)
        {
            __strong RMIntroViewController *strongSelf = weakSelf;
            [strongSelf stopTimer];
        }];
        
        _willEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(__unused NSNotification *note)
        {
            __strong RMIntroViewController *strongSelf = weakSelf;
            [strongSelf startTimer];
        }];
    }
    return self;
}

- (void)startTimer
{
    if (_updateAndRenderTimer == nil) {
        _updateAndRenderTimer = [NSTimer timerWithTimeInterval:1.0f/60.0f target:self selector:@selector(updateAndRender) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_updateAndRenderTimer forMode:NSRunLoopCommonModes];
    }
    
}

- (void)stopTimer
{
    if (_updateAndRenderTimer) {
        [_updateAndRenderTimer invalidate];
        _updateAndRenderTimer=nil;
    }
    
}


- (void)loadView
{
    [super loadView];
    
#if defined(DEBUG) || defined(INTERNAL_RELEASE)
    [self.view addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(switchToDebugPressed:)]];
#endif
    
    //NSLog(@"loadView Orientation>%@", [self convertOrientationToString:self.interfaceOrientation]);
    //NSLog(@"loadView Width>%f", self.window.bounds.size.width);
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

static bool is4inch = YES;

- (CGRect)windowBounds
{
    CGRect r = CGRectZero;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        switch (self.interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                r = CGRectMake(0, 0, 1024, 768);
                break;
                
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                r = CGRectMake(0, 0, 768, 1024);
                break;
                
            default:
                break;
        }
        
        is4inch = NO;
        
    }
    else
    {
        if (MAX(self.view.bounds.size.width, self.view.window.bounds.size.height) > 480) {
            is4inch = YES;
            r = CGRectMake(0, 0, 320, 568);
        }
        else
        {
            is4inch = NO;
            r = CGRectMake(0, 0, 320, 480);
        }
        
    }
    //NSLog(@"windowBounds>%@", NSStringFromCGRect(r));
    return r;
    
}




- (void)loadGL
{
    if (!_isOpenGLLoaded) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!context) {
            NSLog(@"Failed to create ES context");
        }
        
        int size = 200;
        if (IPAD) size *= 1.2;
        
        int height = 50;
        if (IPAD) height += 138/2;
        
        _glkView = [[GLKView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2-size/2, height, size, size) context:context];
        //_glkView.backgroundColor=[UIColor redColor];
        _glkView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        _glkView.drawableMultisample = GLKViewDrawableMultisample4X;
        _glkView.enableSetNeedsDisplay = NO;
        _glkView.userInteractionEnabled=NO;
        _glkView.delegate = self;
        [self setupGL];
        [self.view addSubview:_glkView];
        
        [self startTimer];
        _isOpenGLLoaded = YES;
    }
}


- (void)freeGL
{
    if (_isOpenGLLoaded) {
        [self stopTimer];
        
        if ([EAGLContext currentContext] == _glkView.context) {
            [EAGLContext setCurrentContext:nil];
        }
        _glkView.context = nil;
        context = nil;
        [_glkView removeFromSuperview];
        _glkView=nil;
        _isOpenGLLoaded = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self loadGL];
    

    _pageScrollView = [[UIScrollView alloc]initWithFrame:[self windowBounds]];
    _pageScrollView.clipsToBounds=YES;
    _pageScrollView.opaque=YES;
    _pageScrollView.clearsContextBeforeDrawing=NO;
    [_pageScrollView setShowsHorizontalScrollIndicator:NO];
    [_pageScrollView setShowsVerticalScrollIndicator:NO];
    _pageScrollView.pagingEnabled = YES;
    _pageScrollView.contentSize=CGSizeMake(_headlines.count*[self windowBounds].size.width, [self windowBounds].size.height);
    _pageScrollView.delegate = self;
    [self.view addSubview:_pageScrollView];
    
    
    _pageViews = [NSMutableArray array];
    for (int i=0; i<_headlines.count; i++) {
        RMIntroPageView *p = [[RMIntroPageView alloc]initWithFrame:CGRectMake(i*[self windowBounds].size.width, 0, [self windowBounds].size.width, 0) headline:[_headlines objectAtIndex:i] description:[_descriptions objectAtIndex:i]];
        p.opaque=YES;
        p.clearsContextBeforeDrawing=NO;
        [_pageViews addObject:p];
        [_pageScrollView addSubview:p];
    }
    [_pageScrollView setPage:0];


    _startButton = [[TGModernButton alloc] init];
    ((TGModernButton *)_startButton).modernHighlight = true;
    [_startButton setTitle:_(@"Tour.StartButton") forState:UIControlStateNormal];
    [_startButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:IPAD? 55/2. : 21]];
    [_startButton setTitleColor:UIColorFromRGB(0x007ee5) forState:UIControlStateNormal];
    _startArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:IPAD ? @"start_arrow_ipad.png" : @"start_arrow.png"]];
    _startButton.titleLabel.clipsToBounds=NO;
    
    
    _startArrow.frame = CGRectChangedOrigin(_startArrow.frame, CGPointMake([_startButton.titleLabel.text sizeWithFont:_startButton.font].width+ (IPAD ? 7 : 6), IPAD ? 6.5 : 4.5));
    [_startButton.titleLabel addSubview:_startArrow];
    [self.view addSubview:_startButton];
    

    _pageControl = [[UIPageControl alloc]init];
    _pageControl.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    _pageControl.userInteractionEnabled=NO;
    [_pageControl setPageIndicatorTintColor:[UIColor colorWithWhite:.85 alpha:1]];
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithWhite:.2 alpha:1]];
    [_pageControl setNumberOfPages:6];
    [self.view addSubview:_pageControl];
    
    
    if (IPAD) {
        _separatorView = [[UIView alloc]init];
        _separatorView.backgroundColor = UIColorFromRGB(0xc8c8cc);
        [self.view addSubview:_separatorView];
    }

    
    

}


- (void)viewWillLayoutSubviews
{
    NSLog(@"viewWillLayoutSubviews");
    
    int status_height = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue] >=7 ? 0 : 20;
    
    
    
    int w = 1046/2;
    _separatorView.frame = CGRectMake([self windowBounds].size.width/2-w/2, [self windowBounds].size.height-248/2 - status_height, w, .5);
    _separatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    
    NSLog(@"status_height>%d", status_height);
    
    NSLog(@"_startButton.titleLabel>%f", _startButton.titleLabel.bounds.size.width);
    
    //_startArrow.frame = CGRectChangedOrigin(_startArrow.frame, CGPointMake(/*_startButton.titleLabel.frame.size.width*/ 200 + (IPAD ? 7 : 6), IPAD ? 6.5 : 4.5));
    
    _pageControl.frame = CGRectMake(0, [self windowBounds].size.height- (IPAD ? 386/2 : 162/2) - status_height, [self windowBounds].size.width, 7);
    
    
    
    int originY = 50+24/2;
    if (IPAD)
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
            originY += 138/2+90-10;
        }
        else
        {
            originY += 138/2-10;
        }
    }
    
    
   
    
    _glkView.frame = CGRectChangedOriginY(_glkView.frame, originY - status_height - (is4inch ? 0 : 20));
    
    
   
    
    _startButton.frame = CGRectMake(0-9, [self windowBounds].size.height-(IPAD ? 90+17/2. : 75) - status_height, [self windowBounds].size.width, 75-4);
    [_startButton addTarget:self action:@selector(startButtonPress) forControlEvents:UIControlEventTouchUpInside];
    
    
    _pageScrollView.frame=CGRectMake(0, 20, [self windowBounds].size.width, [self windowBounds].size.height - 20); //[self windowBounds];
    //_pageScrollView.contentSize=CGSizeMake(_headlines.count*[self windowBounds].size.width, [self windowBounds].size.height - 20);
    _pageScrollView.contentSize=CGSizeMake(_headlines.count*[self windowBounds].size.width, 150);
    _pageScrollView.contentOffset = CGPointMake(_currentPage*[self windowBounds].size.width, 0);

    
    int i=0;
    
    originY = 270-25 - (is4inch ? 0 : 30);
    if (IPAD)
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
            originY = 760/2 + 110-5;
        }
        else
        {
            originY = 760/2-45;
        }
    }
    
    for (RMIntroPageView *p in _pageViews) {
        //p.alpha=(5-i)/5.;
        //p.backgroundColor = [UIColor redColor];
        p.frame = CGRectMake(i*[self windowBounds].size.width, (originY-status_height), [self windowBounds].size.width, 150);
        i++;
    }
    
    /*
    NSLog(@"viewWillLayoutSubviews");
    
    NSLog(@"viewWillLayoutSubviews Orientation>%@", [self convertOrientationToString:self.interfaceOrientation]);
    NSLog(@"viewWillLayoutSubviews Width>%f", self.view.bounds.size.width);
     */
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_stillLogoView == nil && !_displayedStillLogo)
    {
        _displayedStillLogo = true;
        
        CGFloat verticalOffset = 0.0f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if ([TGViewController isWidescreen])
                verticalOffset = 87.0f;
            else
                verticalOffset = 67.0f;
        }
        else
        {
            verticalOffset = (self.view.frame.size.width > 768 + FLT_EPSILON) ? 131.0f : 221.0f;
        }
        
        _stillLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"telegram_logo_still.png"]];
        _stillLogoView.frame = (CGRect){CGPointMake((self.view.frame.size.width - _stillLogoView.frame.size.width) / 2.0f, verticalOffset), _stillLogoView.frame.size};
        [self.view addSubview:_stillLogoView];
    }
    
    [self loadGL];
    //[self startTimer];
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
    NSLog(@"viewDidDisappear");
    
    [self freeGL];
    //[self stopTimer];
}

- (void)startButtonPress
{
    NSLog(@"startButtonPress");
    
    /*
    if (!_updateAndRenderTimer) {
        [self loadGL];
    }
    else
    {
        [self freeGL];
    }
    
    */
    
    TGLoginPhoneController *phoneController = [[TGLoginPhoneController alloc] init];
    [self.navigationController pushViewController:phoneController animated:true];
}

- (NSString*)convertOrientationToString:(UIInterfaceOrientation)orientation {
    NSString *result = nil;
    
    typedef NS_ENUM(NSInteger, UIInterfaceOrientation) {
        UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
        UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
        UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
        UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
    };
    
    switch(orientation) {
        case UIInterfaceOrientationPortrait:
            result = @"UIInterfaceOrientationPortrait";
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            result = @"UIInterfaceOrientationPortraitUpsideDown";
            break;
        case UIInterfaceOrientationLandscapeLeft:
            result = @"UIInterfaceOrientationLandscapeLeft";
            break;
        case UIInterfaceOrientationLandscapeRight:
            result = @"UIInterfaceOrientationLandscapeRight";
            break;
            
        default:
            result = @"unknown";
    }
    
    return result;
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
    
    set_ic_textures(setup_texture(@"ic_bubble_dot.png"), setup_texture(@"ic_bubble.png"), setup_texture(@"ic_cam_button.png"), setup_texture(@"ic_cam_lens.png"), setup_texture(@"ic_cam.png"), setup_texture(@"ic_pencil.png"), setup_texture(@"ic_pin.png"), setup_texture(@"ic_smile_eye.png"), setup_texture(@"ic_smile.png"), setup_texture(@"ic_videocam.png"));
    
    set_fast_textures(setup_texture(@"fast_body.png"), setup_texture(@"fast_spiral.png"), setup_texture(@"fast_arrow.png"), setup_texture(@"fast_arrow_shadow.png"));
    
    set_free_textures(setup_texture(@"knot_up.png"), setup_texture(@"knot_down.png"));
    
    set_powerful_textures(setup_texture(@"powerful_bg.jpg"), setup_texture(@"powerful_mask.png"), setup_texture(@"powerful_star.png"), setup_texture(@"powerful_infinity.png"), setup_texture(@"powerful_infinity_white.png"));

    set_private_textures(setup_texture(@"private_bg.jpg"), setup_texture(@"private_button.png"),setup_texture(@"private_dot.png"),setup_texture(@"private_stroked_dot.png"), setup_texture(@"private_leg.png"));


    set_need_pages(0);
    
    
    on_surface_created();
    on_surface_changed(200, 200);
}




#pragma mark - GLKView delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    double time = CFAbsoluteTimeGetCurrent();
    //NSLog(@">%f", time);
    
    set_page(_currentPage);
    set_date(time);

    on_draw_frame();
}





static CGFloat x;
static bool justEndDragging;


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    x=scrollView.contentOffset.x;
    justEndDragging=YES;
    //NSLog(@"scrollViewDidEndDragging x>%f", x);
}

int _current_page_end;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    //float offset = MIN(1, MAX(-1, (scrollView.contentOffset.x - _currentPage*[self windowBounds].size.width)/320.));
    float offset = (scrollView.contentOffset.x - _currentPage*[self windowBounds].size.width)/self.view.frame.size.width;
    
    set_scroll_offset(offset);
    
    if (justEndDragging) {
        justEndDragging=NO;
        
        CGFloat page = scrollView.contentOffset.x/[self windowBounds].size.width;
        CGFloat sign = scrollView.contentOffset.x - x;
        
        if (sign>0) {
            if (page>_currentPage) {
                _currentPage++;
            }
        }
        
        if (sign<0) {
            if (page<_currentPage) {
                _currentPage--;
            }
        }

        _currentPage = MAX(0, MIN(5, _currentPage));
        _current_page_end = _currentPage;
    }
    else
    {
        if (_pageScrollView.contentOffset.x > _current_page_end*_pageScrollView.frame.size.width) {
            if (_pageScrollView.currentPageMin > _current_page_end) {
                _currentPage = [_pageScrollView currentPage];
                _current_page_end = _currentPage;
            }
        }
        else
        {
            if (_pageScrollView.currentPageMax < _current_page_end) {
                _currentPage = [_pageScrollView currentPage];
                _current_page_end = _currentPage;
            }
        }
    }
    
    [_pageControl setCurrentPage:_currentPage];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
