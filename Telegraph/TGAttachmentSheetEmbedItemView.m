#import "TGAttachmentSheetEmbedItemView.h"

#import "TGViewController.h"
#import "TGImageUtils.h"

#import "TGWebPageMediaAttachment.h"

#import "TGAudioSessionManager.h"

@interface TGAttachmentSheetEmbedItemView () <UIWebViewDelegate>
{
    CGSize _embedSize;
    UIWebView *_webView;
    UIActivityIndicatorView *_activityIndicator;
    
    id<SDisposable> _currentAudioSession;
}

@end

@implementation TGAttachmentSheetEmbedItemView

- (instancetype)initWithWebPage:(TGWebPageMediaAttachment *)webPage
{
    self = [super init];
    if (self != nil)
    {
        _currentAudioSession = [[TGAudioSessionManager instance] requestSessionWithType:TGAudioSessionTypePlayVideo interrupted:^
        {
        }];
        
        CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
        CGFloat screenWidth = MIN(screenSize.width, screenSize.height);
        
        _embedSize = TGFitSize(CGSizeMake(webPage.embedSize.width, webPage.embedSize.height), CGSizeMake(screenWidth, CGFloor(screenWidth * 1.2f)));
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidden = true;
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _embedSize.width, _embedSize.height)];
        _webView.backgroundColor = [UIColor blackColor];
        CGFloat factor = _embedSize.width / (_embedSize.width + 10.0f);
        _webView.transform = CGAffineTransformMakeScale(factor, factor);
        [self addSubview:_webView];
        _webView.allowsInlineMediaPlayback = true;
        _webView.delegate = self;
        NSURL *url = [NSURL URLWithString:webPage.embedUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *referer = [[NSString alloc] initWithFormat:@"%@://%@", [url scheme], [url host]];
        [request setValue:referer forHTTPHeaderField:@"Referer"];
        [_webView loadRequest:request];
        
        [self addSubview:_activityIndicator];
    }
    return self;
}

- (void)dealloc
{
    [_currentAudioSession dispose];
}

- (CGFloat)preferredHeight
{
    return _embedSize.height + 6.0f;
}

- (bool)wantsFullSeparator
{
    return true;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _webView.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
    _activityIndicator.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
}

- (void)webViewDidStartLoad:(UIWebView *)__unused webView
{
    _activityIndicator.hidden = false;
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)__unused webView
{
    _activityIndicator.hidden = true;
    [_activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)__unused webView didFailLoadWithError:(NSError *)__unused error
{
    _activityIndicator.hidden = true;
    [_activityIndicator stopAnimating];
}

@end
