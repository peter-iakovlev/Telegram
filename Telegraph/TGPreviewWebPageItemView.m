#import "TGPreviewWebPageItemView.h"
#import <WebKit/WebKit.h>

#import "TGImageUtils.h"

#import "TGWebPageMediaAttachment.h"

#import "TGScrollIndicatorView.h"

@interface TGPreviewWebPageItemView () <UIScrollViewDelegate, UIWebViewDelegate>
{
    NSURL *_url;
    
    WKWebView *_wkWebView;
    UIWebView *_uiWebView;
    TGScrollIndicatorView *_scrollIndicator;
    UIActivityIndicatorView *_activityIndicatorView;
    
    bool _passPanGesture;
}
@end

@implementation TGPreviewWebPageItemView

- (instancetype)initWithWebPage:(TGWebPageMediaAttachment *)webPage
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _url = [NSURL URLWithString:webPage.url];
    }
    return self;
}

- (void)dealloc
{
    [_wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    _wkWebView.scrollView.delegate = nil;
    
    _uiWebView.delegate = nil;
    _uiWebView.scrollView.delegate = nil;
}

- (void)menuView:(TGMenuSheetView *)__unused menuView willAppearAnimated:(bool)__unused animated
{
    if (iosMajorVersion() >= 8)
        [self setupWKWebView];
    else
        [self setupUIWebView];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.userInteractionEnabled = false;
    [self addSubview:_activityIndicatorView];
    
    [_activityIndicatorView startAnimating];
}

- (void)setupWKWebView
{
    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *viewportScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:true];
    [contentController addUserScript:viewportScript];
    
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    conf.allowsInlineMediaPlayback = true;
    conf.userContentController = contentController;
    
    if ([conf respondsToSelector:@selector(setRequiresUserActionForMediaPlayback:)])
        conf.requiresUserActionForMediaPlayback = false;
    else if ([conf respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)])
        conf.mediaPlaybackRequiresUserAction = false;
    
    if ([conf respondsToSelector:@selector(setAllowsPictureInPictureMediaPlayback:)])
        conf.allowsPictureInPictureMediaPlayback = false;
    
    _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:conf];
    _wkWebView.scrollView.delegate = self;
    _wkWebView.scrollView.showsHorizontalScrollIndicator = false;
    _wkWebView.scrollView.showsVerticalScrollIndicator = false;
    
    [self commonSetupWithWebView:_wkWebView completion:^(NSURLRequest *request)
    {
        [_wkWebView loadRequest:request];
    }];
    
    [_wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == _wkWebView)
    {
        if (fabs(_wkWebView.estimatedProgress - 1.0f) < FLT_EPSILON)
        {
            [_activityIndicatorView stopAnimating];
            _activityIndicatorView.hidden = true;
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setupUIWebView
{
    _uiWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _uiWebView.delegate = self;
    _uiWebView.scrollView.delegate = self;
    _uiWebView.scrollView.showsHorizontalScrollIndicator = false;
    _uiWebView.scrollView.showsVerticalScrollIndicator = false;
    _uiWebView.mediaPlaybackRequiresUserAction = false;
    
    [self commonSetupWithWebView:_uiWebView completion:^(NSURLRequest *request)
    {
        [_uiWebView loadRequest:request];
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)__unused webView
{
    [_activityIndicatorView stopAnimating];
    _activityIndicatorView.hidden = true;
}

- (void)commonSetupWithWebView:(UIView *)webView completion:(void (^)(NSURLRequest *))completion
{
    webView.backgroundColor = [UIColor whiteColor];
    [self addSubview:webView];
    
    _scrollIndicator = [[TGScrollIndicatorView alloc] init];
    [_scrollIndicator setHidden:true animated:false];
    
    if ([webView isKindOfClass:[WKWebView class]])
        [((WKWebView *)webView).scrollView addSubview:_scrollIndicator];
    else if ([webView isKindOfClass:[UIWebView class]])
        [((UIWebView *)webView).scrollView addSubview:_scrollIndicator];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
    if (completion != nil)
        completion(request);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_scrollIndicator updateScrollViewDidScroll];
    
    if (scrollView.contentOffset.y < 0)
        [_scrollIndicator setHidden:true animated:true];
    else if (scrollView.contentOffset.y > FLT_EPSILON)
        [_scrollIndicator setHidden:false animated:true];
    
    _passPanGesture = false;
    if (scrollView.contentOffset.y < 0)
    {
        scrollView.contentOffset = CGPointZero;
        scrollView.scrollEnabled = false;
        scrollView.scrollEnabled = true;
        _passPanGesture = true;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)__unused scrollView
{
    [_scrollIndicator updateScrollViewDidEndScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)__unused scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [_scrollIndicator updateScrollViewDidEndScrolling];
}

- (bool)handlesPan
{
    return true;
}

- (bool)passPanOffset:(CGFloat)__unused offset
{
    return _passPanGesture;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)__unused scrollView
{
    return nil;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    return floor(MIN(TGScreenSize().height - 175.0f, width * 1.33f));
}

- (void)layoutSubviews
{
    _wkWebView.frame = self.bounds;
    _uiWebView.frame = self.bounds;
    _activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

@end
