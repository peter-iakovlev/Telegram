#import "TGWebAppController.h"
#import <WebKit/WebKit.h>
#import "TGModernConversationTitleView.h"

#import "TGForwardTargetController.h"

#import "ActionStage.h"

#import "TGImageUtils.h"
#import "TGDatabase.h"
#import "TGBotSignals.h"

#import "TGProgressWindow.h"

#import "TGInterfaceManager.h"

#import "TGShareMenu.h"
#import "TGSendMessageSignals.h"

#import "TGTelegraph.h"

@interface TGWeakScriptMessageHandler : NSObject <WKScriptMessageHandler> {
    void (^_block)(WKScriptMessage *);
}

@end

@implementation TGWeakScriptMessageHandler

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

@implementation TGWebAppControllerShareGameData

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId botName:(NSString *)botName shareName:(NSString *)shareName {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _messageId = messageId;
        _botName = botName;
        _shareName = shareName;
    }
    return self;
}

@end

@interface TGWebAppController () <WKNavigationDelegate, ASWatcher> {
    NSString *_botName;
    NSURL *_url;
    UIView *_webView;
    TGModernConversationTitleView *_titleView;
    
    bool _shareWithScore;
    
    SMetaDisposable *_shareDisposable;
    TGMenuSheetController *_menuController;
    int64_t _peerIdForActivityUpdates;
    int64_t _peerAccessHashForActivityUpdates;
    
    id _activityHolder;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGWebAppController

- (instancetype)initWithUrl:(NSURL *)url title:(NSString *)title botName:(NSString *)botName peerIdForActivityUpdates:(int64_t)peerIdForActivityUpdates peerAccessHashForActivityUpdates:(int64_t)peerAccessHashForActivityUpdates {
    self = [super init];
    if (self != nil) {
        _shareDisposable = [[SMetaDisposable alloc] init];
        _peerIdForActivityUpdates = peerIdForActivityUpdates;
        _peerAccessHashForActivityUpdates = peerAccessHashForActivityUpdates;
        
        _url = url;
        _botName = botName;

        if (TGIsPad())
        {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closePressed)];
        }
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePressed)];
        
        _titleView = [[TGModernConversationTitleView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        [self setTitleView:_titleView];
        
        _titleView.title = title;
        _titleView.status = [NSString stringWithFormat:@"@%@", botName];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
    }
    return self;
}

- (void)dealloc {
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [_shareDisposable dispose];
}

- (void)closePressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)sharePressed {
    _shareWithScore = false;
    [TGWebAppController presentShare:_shareGameData parentController:self withScore:_shareWithScore];
}

+ (void)presentShare:(TGWebAppControllerShareGameData *)shareGameData parentController:(UIViewController *)parentController withScore:(bool)withScore {
    NSString *fixedSharedLink = nil;
    
    if (shareGameData.shareName != nil) {
        fixedSharedLink = [NSString stringWithFormat:@"https://t.me/%@?game=%@", shareGameData.botName, shareGameData.shareName];
    }
    
    //__weak TGWebAppController *weakSelf = self;
    __weak UIViewController *weakParentController = parentController;
    id _menuController = [TGShareMenu presentInParentController:parentController menuController:nil buttonTitle:TGLocalized(@"ShareMenu.CopyShareLinkGame") buttonAction:^
    {
        if (fixedSharedLink != nil) {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow showWithDelay:0.2];
            
            [[UIPasteboard generalPasteboard] setString:fixedSharedLink];
            [progressWindow dismissWithSuccess];
        }
    } shareAction:^(NSArray *peerIds, NSString *caption)
    {
        //__strong TGWebAppController *strongSelf = weakSelf;
        if (peerIds.count == 0)
            return;
        
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow showWithDelay:0.1];
        
        NSMutableArray *signals = [[NSMutableArray alloc] init];
        for (NSNumber *nPeerId in peerIds) {
            [signals addObject:[TGBotSignals shareBotGame:shareGameData.peerId messageId:shareGameData.messageId toPeerId:[nPeerId int64Value] withScore:withScore]];
        }
        
        NSMutableArray *captionSignals = [[NSMutableArray alloc] init];
        if (caption.length != 0) {
            for (NSNumber *peerIdVal in peerIds)
            {
                int64_t peerId = peerIdVal.int64Value;
                SSignal *signal = [TGSendMessageSignals sendTextMessageWithPeerId:peerId text:caption replyToMid:0];
                [captionSignals addObject:signal];
            }
        }
        
        SSignal *combined = [[SSignal combineSignals:signals] then:[SSignal combineSignals:captionSignals]];
        
        id<SDisposable> disposable = [[[combined deliverOn:[SQueue mainQueue]] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
            });
        }] startWithNext:nil error:nil completed:^{
            [progressWindow dismissWithSuccess];
        }];
        //[strongSelf->_shareDisposable setDisposable:disposable];
    } externalShareItemSignal:nil sourceView:parentController.view sourceRect:^CGRect {
        __strong UIViewController *strongParentController = weakParentController;
        if (strongParentController != nil) {
            return strongParentController.view.bounds;
        }
        return CGRectZero;
    } barButtonItem:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
        __weak TGWebAppController *weakSelf = self;
        [userController addScriptMessageHandler:[[TGWeakScriptMessageHandler alloc] initWithBlock:^(WKScriptMessage *message){
            __strong TGWebAppController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf userContentControllerDidReceiveScriptMessage:message];
            }
        }] name:@"performAction"];
        
        configuration.userContentController = userController;
        
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        webView.navigationDelegate = self;
        [self.view addSubview:webView];
        webView.scrollView.alwaysBounceVertical = false;
        webView.scrollView.alwaysBounceHorizontal = false;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController.viewControllers.count >= 2)
    {
        UIViewController *previousController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        [_titleView setBackButtonTitle:previousController.navigationItem.backBarButtonItem.title.length == 0 ? TGLocalized(@"Common.Back") : previousController.navigationItem.backBarButtonItem.title];
    }
    
    [_titleView setOrientation:self.interfaceOrientation];
    
    if (_peerIdForActivityUpdates != 0) {
        _activityHolder = [[TGTelegraphInstance activityManagerForConversationId:_peerIdForActivityUpdates accessHash:_peerAccessHashForActivityUpdates] addActivityWithType:@"playingGame" priority:0];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    if ([self isViewLoaded])
        _webView.frame = CGRectMake(0.0f, self.controllerInset.top, self.view.frame.size.width, self.view.bounds.size.height - self.controllerInset.top);
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_titleView setOrientation:toInterfaceOrientation];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)webView:(WKWebView *)__unused webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.host isEqualToString:_url.host]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        //decisionHandler(WKNavigationActionPolicyCancel);
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)userContentControllerDidReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.body respondsToSelector:@selector(objectForKey:)]) {
        NSString *eventName = [message.body objectForKey:@"eventName"];
        if ([eventName isEqual:@"share_game"] || [eventName isEqual:@"share_score"]) {
            _shareWithScore = [eventName isEqualToString:@"share_score"];
            [TGWebAppController presentShare:_shareGameData parentController:self withScore:_shareWithScore];
        }
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options {
    if ([action isEqualToString:@"willForwardMessages"]) {
        int64_t peerId = 0;
        if ([options[@"target"] isKindOfClass:[TGUser class]]) {
            peerId = ((TGUser *)options[@"target"]).uid;
        } else if ([options[@"target"] isKindOfClass:[TGConversation class]]) {
            peerId = ((TGConversation *)options[@"target"]).conversationId;
        }
        
        if (peerId != 0) {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow showWithDelay:0.1];
            [_shareDisposable setDisposable:[[[[TGBotSignals shareBotGame:_shareGameData.peerId messageId:_shareGameData.messageId toPeerId:peerId withScore:_shareWithScore] deliverOn:[SQueue mainQueue]] onDispose:^{
                TGDispatchOnMainThread(^{
                    [progressWindow dismiss:true];
                });
            }] startWithNext:nil error:nil completed:^{
                [[TGInterfaceManager instance] navigateToConversationWithId:peerId conversation:nil animated:true];
            }]];
        }
    }
}

@end
