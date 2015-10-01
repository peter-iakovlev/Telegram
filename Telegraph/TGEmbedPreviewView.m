#import "TGEmbedPreviewView.h"

#import "TGImageUtils.h"

#import "TGWebPageMediaAttachment.h"

@interface TGEmbedPreviewView () <UIWebViewDelegate>
{
    TGWebPageMediaAttachment *_webPage;
    UIView *_dimView;
    UIView *_webViewWrapper;
    UIWebView *_webView;
    UIActivityIndicatorView *_activityIndicator;
}

@end

@implementation TGEmbedPreviewView

- (instancetype)initWithFrame:(CGRect)frame webPage:(TGWebPageMediaAttachment *)webPage
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _dimView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        _dimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        [_dimView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimViewTapGesture:)]];
        [self addSubview:_dimView];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidden = true;
        [self addSubview:_activityIndicator];
        
        _webViewWrapper = [[UIView alloc] initWithFrame:[self webViewFrameForSize:frame.size]];
        [self addSubview:_webViewWrapper];
        
        _webPage = webPage;
        _webView = [[UIWebView alloc] initWithFrame:_webViewWrapper.bounds];
        _webView.delegate = self;
        [_webViewWrapper addSubview:_webView];
        _webView.allowsInlineMediaPlayback = true;
        NSURL *url = [NSURL URLWithString:_webPage.embedUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *referer = [[NSString alloc] initWithFormat:@"%@://%@", [url scheme], [url host]];
        [request setValue:referer forHTTPHeaderField:@"Referer"];
        [_webView loadRequest:request];
        
        _dimView.alpha = 0.0f;
        _webView.alpha = 0.0f;
    }
    return self;
}

- (void)dimViewTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_dismiss)
            _dismiss();
    }
}

- (UIEdgeInsets)insets
{
    return UIEdgeInsetsMake(20.0f, 0.0f, 20.0f, 0.0f);
}

- (CGRect)webViewFrameForSize:(CGSize)size
{
    UIEdgeInsets insets = [self insets];
    CGSize webSize = TGFitSize(_webPage.embedSize, CGSizeMake(size.width - insets.left - insets.right, size.height - insets.top - insets.bottom));
    return CGRectMake(insets.left + CGFloor((size.width - insets.left - insets.right - webSize.width) / 2.0f), insets.right + CGFloor((size.height - insets.top - insets.bottom - webSize.height) / 2.0f), webSize.width, webSize.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _dimView.frame = self.bounds;
    CGAffineTransform webViewTransform = _webView.transform;
    _webView.transform = CGAffineTransformIdentity;
    _webView.frame = [self webViewFrameForSize:self.frame.size];
    [_webView layoutSubviews];
    _webView.transform = webViewTransform;
    
    _activityIndicator.frame = CGRectMake(CGFloor((self.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
}

- (void)animateIn
{
    _dimView.alpha = 0.0f;
    _webView.alpha = 0.0f;
    _webView.transform = CGAffineTransformMakeScale(0.94f, 0.94f);
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        _dimView.alpha = 1.0f;
        _webView.alpha = 1.0f;
        _webView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)animateOut:(void (^)())completion
{
    [UIView animateWithDuration:0.2 animations:^
    {
        _dimView.alpha = 0.0f;
        _webView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
        _webView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        if (completion)
            completion();
    }];
}

- (void)webViewDidStartLoad:(UIWebView *)__unused webView
{
    _activityIndicator.hidden = false;
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)__unused webView
{
    [_activityIndicator stopAnimating];
    [_activityIndicator removeFromSuperview];
}

@end
