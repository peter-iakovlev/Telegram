#import "TGGoogleDriveAuthController.h"

#import "GDURLUtilities.h"
#import "GDGoogleDriveClient.h"
#import "GDGoogleDriveFileService.h"

#import "GDClientManager.h"

#import "TGAlertView.h"

NSString *const TGGoogleDriveRedirectURL = @"http://localhost";
NSString *const TGGoogleDriveCookiesURL = @"https://accounts.google.com";
NSString *const TGGoogleDriveScopes = @"https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/drive";

@interface TGGoogleDriveAuthController () <UIWebViewDelegate>
{
    GDGoogleDriveFileService *_service;
    GDGoogleDriveAPIToken *_apiToken;
    
    NSHTTPCookieAcceptPolicy _savedCookiePolicy;
    
    UIWebView *_webView;
    UIActivityIndicatorView *_activityIndicator;
    
    bool _hasAppeared;
    bool _hasLoadedFirstPage;
}

@property (nonatomic, copy) void(^completionBlock)(GDGoogleDriveClient *client, NSError *error);

@end

@implementation TGGoogleDriveAuthController

- (instancetype)initWithService:(GDGoogleDriveFileService *)service completion:(void (^)(GDGoogleDriveClient *client, NSError *error))completion
{
    self = [super init];
    if (self != nil)
    {
        _service = service;
        _apiToken = (GDGoogleDriveAPIToken *)_service.clientManager.defaultAPIToken;
        _savedCookiePolicy = NSUIntegerMax;
    
        self.title = TGLocalized(@"GoogleDrive.Title");
        self.navigationItem.hidesBackButton = true;
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        
        self.completionBlock = completion;
    }
    return self;
}

- (void)dealloc
{
    _webView.delegate = nil;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    CGRect frame = _activityIndicator.frame;
    frame.origin.x = CGFloor(self.view.bounds.size.width / 2 - frame.size.width / 2);
    frame.origin.y = CGFloor(self.view.bounds.size.height / 2 - frame.size.height / 2);
    _activityIndicator.frame = frame;
    
    [_activityIndicator startAnimating];
    [self.view addSubview:_activityIndicator];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _webView.delegate = self;
    _webView.hidden = true;
    _webView.scalesPageToFit = false;
    [self.view addSubview:_webView];
    
    //self.scrollViewsForAutomaticInsetsAdjustment = @[_webView.scrollView];
    
    //if (![self _updateControllerInset:false])
    //    [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_hasAppeared)
    {
        _hasAppeared = true;
        [self _authorize];
        
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSHTTPCookieAcceptPolicy policy = [storage cookieAcceptPolicy];
        if (policy == NSHTTPCookieAcceptPolicyNever)
        {
            _savedCookiePolicy = policy;
            [storage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain];
        }
    }
}

- (void)viewWillDisappear:(BOOL)__unused animated
{
    [super viewWillDisappear:animated];
    
    if (_savedCookiePolicy != (NSHTTPCookieAcceptPolicy)NSUIntegerMax)
    {
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [storage setCookieAcceptPolicy:_savedCookiePolicy];
        _savedCookiePolicy = (NSHTTPCookieAcceptPolicy)NSUIntegerMax;
    }
}

- (void)cancelPressed
{
    [self.view endEditing:true];
    
    [self dismissWithSuccess:false];
}

#pragma mark - Authorization

- (void)_authorize
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"client_id"] = _apiToken.key;
    parameters[@"redirect_uri"] = TGGoogleDriveRedirectURL;
    parameters[@"scope"] = TGGoogleDriveScopes;
    parameters[@"state"] = _apiToken.key;
    parameters[@"response_type"] = @"code";
    
    NSString *urlString = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?%@", GDURLQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding)];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (NSString *)_oauthCodeFromCallbackURL:(NSURL *)callbackURL error:(NSError **)error
{
    NSString *queryString = [callbackURL query];
    NSDictionary *parameters = GDParametersFromURLQueryStringWithEncoding(queryString, NSUTF8StringEncoding);
    
    if (parameters[@"code"])
    {
        return parameters[@"code"];
    }
    else if (parameters[@"error"])
    {
        if (error != nil)
            *error = [NSError errorWithDomain:@"OAuth" code:0 userInfo:parameters];
    }
    return nil;
}

- (void)_processCallbackWithUrl:(NSURL *)url
{
    AFOAuth2Client *oauthClient = [AFOAuth2Client clientWithBaseURL:[NSURL URLWithString:@"https://accounts.google.com/o/oauth2/"]
                                                           clientID:_apiToken.key secret:_apiToken.secret];
    
    NSError *error = nil;
    NSString *oauthCode = [self _oauthCodeFromCallbackURL:url error:&error];
    if (oauthCode == nil)
    {
        if (self.completionBlock != nil)
            self.completionBlock(nil, error);
        
        [self dismissWithSuccess:false];
        
        return;
    }
    
    __weak TGGoogleDriveAuthController *weakSelf = self;
    [oauthClient authenticateUsingOAuthWithPath:@"token"
                                           code:oauthCode
                                    redirectURI:TGGoogleDriveRedirectURL
                                        success:^(AFOAuthCredential *credential)
    {
        __strong TGGoogleDriveAuthController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        GDOAuth2Credential *gdCredential = [[GDOAuth2Credential alloc] initWithOAuthCredential:credential userID:nil apiToken:_apiToken];
        
        [strongSelf validateCredential:gdCredential
                        apiToken:_apiToken
                         success:^(GDGoogleDriveClient *client)
        {
            [_service.clientManager addCredential:client.credential];
            
            if (strongSelf.completionBlock != nil)
                strongSelf.completionBlock(client, nil);
            
            [strongSelf dismissWithSuccess:true];
        } failure:^(NSError *error)
        {
           if (strongSelf.completionBlock != nil)
               strongSelf.completionBlock(nil, error);
            
            [strongSelf dismissWithSuccess: false];
        }];
    } failure:^(NSError *error)
    {
        __strong TGGoogleDriveAuthController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf.completionBlock != nil)
            strongSelf.completionBlock(nil, error);
        
        [strongSelf dismissWithSuccess:false];
    }];
}

- (void)validateCredential:(GDOAuth2Credential *)credential apiToken:(GDGoogleDriveAPIToken *)apiToken
                   success:(void (^)(GDGoogleDriveClient *client))success failure:(void (^)(NSError *error))failure
{
    GDGoogleDriveClient *client = [[GDGoogleDriveClient alloc] initWithClientManager:_service.clientManager credential:credential];
    
    [client getAccountInfoWithSuccess:^(GDGoogleDriveAccountInfo *accountInfo)
    {
        GDOAuth2Credential *validatedCredential = [[GDOAuth2Credential alloc] initWithOAuthCredential:credential.oauthCredential
                                                                                               userID:accountInfo.userID
                                                                                             apiToken:apiToken];
        client.credential = validatedCredential;
        if (success != nil)
            success(client);
    } failure:failure];
}

- (void)_clearBrowserCookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:TGGoogleDriveCookiesURL]];
    
    for (NSHTTPCookie *cookie in cookies)
        [cookieStorage deleteCookie:cookie];
}

- (void)dismissWithSuccess:(bool)success
{
    [self _clearBrowserCookies];
    
    if (success)
    {
        [self.navigationController popToRootViewControllerAnimated:true];
    }
    else
    {
        if (self.dismissBlock != nil)
            self.dismissBlock();
    }
}

#pragma mark - Web View Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout = \"none\";"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect = \"none\";"];
    
    NSString *js = [NSString stringWithFormat:@"var meta = document.createElement('meta'); " \
     "meta.setAttribute( 'name', 'viewport' ); " \
     "meta.setAttribute( 'content', 'width = %fpx, initial-scale = 5.0, user-scalable = yes' ); " \
     "document.getElementsByTagName('head')[0].appendChild(meta)", CGRectGetWidth(self.view.frame)];
    
    [_webView stringByEvaluatingJavaScriptFromString:js];
    
    if (!_hasLoadedFirstPage)
    {
        _hasLoadedFirstPage = true;

        CATransition *transition = [CATransition animation];
        transition.duration = 0.25f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type = kCATransitionFade;
        [_webView.layer addAnimation:transition forKey:nil];
        
        _webView.hidden = false;
    }
}

- (BOOL)webView:(UIWebView *)__unused webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)__unused navigationType
{
    NSURL *url = [request URL];
 
    if ([url.absoluteString hasPrefix:TGGoogleDriveRedirectURL])
    {
        [self _processCallbackWithUrl:url];
        return false;
    }
    
    return true;
}

- (void)webView:(UIWebView *)__unused webView didFailLoadWithError:(NSError *)error
{
    if (error.code == 102 && [error.domain isEqualToString:@"WebKitErrorDomain"]) return;
    if (error.code == NSURLErrorCancelled && [error.domain isEqualToString:NSURLErrorDomain]) return;
    
    [[[TGAlertView alloc] initWithTitle:TGLocalized(@"GoogleDrive.LoadErrorTitle") message:TGLocalized(@"GoogleDrive.LoadErrorMessage") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okButtonPressed)
    {
        [self dismissWithSuccess:false];
    }] show];
}

@end
