#import "TGPaymentWebController.h"

#import <WebKit/WebKit.h>

#import "TGAlertView.h"

@interface TGWeakPaymentScriptMessageHandler : NSObject <WKScriptMessageHandler> {
    void (^_block)(WKScriptMessage *);
}

@end

@implementation TGWeakPaymentScriptMessageHandler

- (instancetype)initWithBlock:(void (^)(WKScriptMessage *))block {
    self = [super init];
    if (self != nil) {
        _block = [block copy];
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)__unused userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (_block) {
        _block(message);
    }
}

@end


@interface TGPaymentWebController () <WKNavigationDelegate> {
    NSURL *_url;
    UIView *_webView;
    bool _confirmation;
    bool _canSave;
    bool _allowSaving;
}

@end

@implementation TGPaymentWebController

- (instancetype)initWithUrl:(NSString *)url confirmation:(bool)confirmation canSave:(bool)canSave allowSaving:(bool)allowSaving {
    self = [super init];
    if (self != nil) {
        _url = [NSURL URLWithString:url];
        _confirmation = confirmation;
        
        _canSave = canSave && allowSaving;
        _allowSaving = allowSaving;
        
        if (_confirmation) {
            self.title = TGLocalized(@"Checkout.WebConfirmation.Title");
        } else {
            self.title = TGLocalized(@"Checkout.NewCard.Title");
        }
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
    }
    return self;
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    if ([self isViewLoaded])
        _webView.frame = CGRectMake(0.0f, self.controllerInset.top, self.view.frame.size.width, self.view.bounds.size.height - self.controllerInset.top);
}

- (void)loadView {
    [super loadView];
    
    if (iosMajorVersion() >= 8) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        
        WKUserContentController *userController = [[WKUserContentController alloc] init];
        NSString *js = @"var TelegramWebviewProxyProto = function() {}; \
        TelegramWebviewProxyProto.prototype.postEvent = function(eventName, eventData) { \
        window.webkit.messageHandlers.performAction.postMessage({'eventName': eventName, 'eventData': eventData}); \
        };\
        var TelegramWebviewProxy = new TelegramWebviewProxyProto();";
        
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:false];
        [userController addUserScript:userScript];
        __weak TGPaymentWebController *weakSelf = self;
        [userController addScriptMessageHandler:[[TGWeakPaymentScriptMessageHandler alloc] initWithBlock:^(WKScriptMessage *message){
            __strong TGPaymentWebController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf userContentControllerDidReceiveScriptMessage:message];
            }
        }] name:@"performAction"];
        
        configuration.userContentController = userController;
        
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        [self.view addSubview:webView];
        webView.scrollView.alwaysBounceVertical = false;
        webView.scrollView.alwaysBounceHorizontal = false;
        webView.navigationDelegate = self;
        _webView = webView;
        if ([[_url.absoluteString lowercaseString] hasPrefix:@"http://"] || [[_url.absoluteString lowercaseString] hasPrefix:@"https://"]) {
            [webView loadRequest:[NSURLRequest requestWithURL:_url]];
        }
    } else {
        UIWebView *webView = [[UIWebView alloc] init];
        [self.view addSubview:webView];
        webView.scrollView.alwaysBounceVertical = false;
        webView.scrollView.alwaysBounceHorizontal = false;
        /*id scriptObject = [webView performSelector:NSSelectorFromString(TGEncodeText(@"xjoepxTdsjquPckfdu", -1))];
         if (scriptObject != nil) {
         __weak TGWebAppController *weakSelf = self;
         [scriptObject setValue:[[TGWebAppControllerLegacyInterface alloc] initWithEventReceived:^(id event) {
         __strong TGWebAppController *strongSelf = weakSelf;
         if (strongSelf != nil) {
         TGLog(@"legacy event received: %@", event);
         }
         }] forKey:@"TelegramEventProxy"];
         }*/
        _webView = webView;
        if ([[_url.absoluteString lowercaseString] hasPrefix:@"http://"] || [[_url.absoluteString lowercaseString] hasPrefix:@"https://"]) {
            [webView loadRequest:[NSURLRequest requestWithURL:_url]];
            
            NSString *js = @"var TelegramWebviewProxyProto = function() {}; \
            TelegramWebviewProxyProto.prototype.postEvent = function(eventName, eventData) { \
            window.TelegramEventProxy.postMessage({'eventName': eventName, 'eventData': eventData}); \
            };\
            var TelegramWebviewProxy = new TelegramWebviewProxyProto();";
            [webView stringByEvaluatingJavaScriptFromString:js];
        }
    }
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)userContentControllerDidReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.body respondsToSelector:@selector(objectForKey:)]) {
        NSString *eventName = [message.body objectForKey:@"eventName"];
        if ([eventName isEqual:@"payment_form_submit"]) {
            NSString *eventData = [message.body objectForKey:@"eventData"];
            if ([eventData respondsToSelector:@selector(characterAtIndex:)]) {
                __autoreleasing NSError *error = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[eventData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                if (dict != nil && [dict respondsToSelector:@selector(objectForKey:)] && dict[@"title"] != nil && dict[@"credentials"] != nil) {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:dict[@"credentials"] options:0 error:&error];
                    __weak TGPaymentWebController *weakSelf = self;
                    if (_canSave) {
                        [TGAlertView presentAlertWithTitle:nil message:TGLocalized(@"Checkout.NewCard.SaveInfoHelp") cancelButtonTitle:TGLocalized(@"Common.NotNow") okButtonTitle:TGLocalized(@"Common.Yes") completionBlock:^(bool okButtonPressed) {
                            __strong TGPaymentWebController *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                NSString *credentials = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                if (strongSelf->_completed) {
                                    strongSelf->_completed(credentials, dict[@"title"], okButtonPressed);
                                }
                            }
                        } disableKeyboardWorkaround:true];
                    } else if (_allowSaving) {
                        NSString *text = TGLocalized(@"Checkout.NewCard.SaveInfoEnableHelp");
                        text = [text stringByReplacingOccurrencesOfString:@"[" withString:@""];
                        text = [text stringByReplacingOccurrencesOfString:@"]" withString:@""];
                        [TGAlertView presentAlertWithTitle:nil message:text cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okButtonPressed) {
                            __strong TGPaymentWebController *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                NSString *credentials = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                if (strongSelf->_completed) {
                                    strongSelf->_completed(credentials, dict[@"title"], false);
                                }
                            }
                        } disableKeyboardWorkaround:true];
                    } else {
                        NSString *credentials = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        _completed(credentials, dict[@"title"], false);
                    }
                }
            }
        }
    }
}

- (void)webView:(WKWebView *)__unused webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *host = navigationAction.request.URL.host;
    if ([host isEqualToString:@"t.me"] || [host isEqualToString:@"telegram.me"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        if (_completedConfirmation) {
            _completedConfirmation();
        }
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
