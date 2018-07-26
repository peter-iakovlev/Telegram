#import "TGWebPageController.h"

#import "TGPresentation.h"

NSString *const TGSandboxedWebViewProtocolHandledKey = @"TGSandboxedWebViewProtocolHandledKey";

@interface TGSandboxedWebViewProtocol : NSURLProtocol

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSURLResponse *response;

@end

@interface TGWebPageController ()
{
    NSURL *_url;
    
    WKWebView *_wkWebView;
    UIWebView *_uiWebView;
}
@end

@implementation TGWebPageController

- (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url
{
    self = [super init];
    if (self != nil)
    {
        _url = url;
        self.title = title;
        
        if (TGIsPad())
        {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closePressed)];
        }
        
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePressed)];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    if (iosMajorVersion() >= 8)
    {
        WKPreferences *preferences = [[WKPreferences alloc] init];
        preferences.javaScriptEnabled = false;
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.preferences = preferences;
        
        _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        _wkWebView.scrollView.backgroundColor = self.presentation.pallete.backgroundColor;
        [self.view addSubview:_wkWebView];
        
        [_wkWebView loadRequest:[NSURLRequest requestWithURL:_url]];
    }
    else
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            [NSURLProtocol registerClass:[TGSandboxedWebViewProtocol class]];
        });
        
        _uiWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _uiWebView.scrollView.backgroundColor = self.presentation.pallete.backgroundColor;
        [self.view addSubview:_uiWebView];
        
        NSURL *sbURL = [[NSURL alloc] initWithScheme:@"sbfile" host:_url.host path:_url.path];
        [_uiWebView loadRequest:[NSURLRequest requestWithURL:sbURL]];
    }
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    _wkWebView.scrollView.backgroundColor = self.presentation.pallete.backgroundColor;
    _uiWebView.scrollView.backgroundColor = self.presentation.pallete.backgroundColor;
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    if ([self isViewLoaded])
    {
        CGRect frame = CGRectMake(0.0f, self.controllerInset.top, self.view.frame.size.width, self.view.bounds.size.height - self.controllerInset.top);
        _wkWebView.frame = frame;
        _uiWebView.frame = frame;
    }
}

- (void)closePressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)sharePressed
{
    
}

@end


@implementation TGSandboxedWebViewProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([request.URL.scheme isEqualToString:@"sbfile"])
        return true;
    
    return false;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    newRequest.URL = [[NSURL alloc] initWithScheme:@"file" host:newRequest.URL.host path:newRequest.URL.path];
    [NSURLProtocol setProperty:@true forKey:TGSandboxedWebViewProtocolHandledKey inRequest:newRequest];
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
}

- (void)connection:(NSURLConnection *)__unused connection didReceiveResponse:(NSURLResponse *)response
{
    NSDictionary *headers = @{ @"X-WebKit-CSP": @"script-src none", @"Content-type": @"text/html" };
    NSHTTPURLResponse *sbResponse = [[NSHTTPURLResponse alloc] initWithURL:response.URL statusCode:200 HTTPVersion:@"1.1" headerFields:headers];
    
    [self.client URLProtocol:self didReceiveResponse:sbResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    self.response = response;
    self.mutableData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)__unused connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
    [self.mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)__unused connection
{
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)__unused connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

@end
