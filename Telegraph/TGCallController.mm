#import "TGCallController.h"

#import <AVFoundation/AVFoundation.h>

#import "TGTelegraph.h"
#import "TGAppDelegate.h"
#import "TGDatabase.h"
#import "TGInterfaceManager.h"

#import "Freedom.h"
#import "TGHacks.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGFont.h"
#import "TGAlertView.h"
#import "TGTimerTarget.h"

#import "TGCallSession.h"
#import "TGCallSignals.h"
#import "TGCallKitAdapter.h"
#import "TGAccessChecker.h"

#import "TGCallView.h"
#import "TGCallDebugView.h"
#import "TGCallAlertView.h"
#import "TGCallRatingView.h"
#import "TGCallStatusBarView.h"

#import "TGMenuSheetController.h"
#import "TGCallAudioRouteButtonItemView.h"

@interface TGCallController ()
{
    TGHolder *_proximityChangeHolder;
    
    TGCallSession *_session;
    SMetaDisposable *_disposable;
    SMetaDisposable *_levelDisposable;
    
    int64_t _peerId;
    int64_t _accessHash;
    
    bool _appeared;
    bool _appearing;
    bool _dismissing;
    bool _disappearing;
    bool _minimizing;
    bool _timerStarted;
    
    bool _proximityListenerEnabled;
    
    NSArray *_audioRoutes;
    TGAudioRoute *_activeAudioRoute;
    
    bool _presentRatingAlert;
    bool _presentTabAlert;
    NSString *_finalError;
    
    TGCallDebugView *_debugView;
    
    SPipe *_durationPipe;
    
    CGFloat _previousStatusBarAlpha;
    CGFloat _previousStatusBarOffset;
    
    __weak TGMenuSheetController *_menuController;
    NSTimer *_routeMenuCloseTimer;
    
    NSInteger _debugBitrate;
    NSInteger _debugPacketLoss;
    bool _debugP2P;
}

@property (strong, nonatomic) TGCallView *view;

@end

@implementation TGCallController

@dynamic view;

- (instancetype)initWithSession:(TGCallSession *)session
{
    self = [super init];
    if (self != nil)
    {
        _session = session;
        _disposable = [[SMetaDisposable alloc] init];
        _durationPipe = [[SPipe alloc] init];
        
        _debugBitrate = 25;
        _debugPacketLoss = 15;
        _debugP2P = true;
    }
    return self;
}

- (void)dealloc
{
    [_disposable dispose];
}

- (void)loadView
{
    [UIView setAnimationsEnabled:false];
    self.view = [[TGCallView alloc] init];
    self.view.layer.rasterizationScale = TGScreenScaling();
    
    __weak TGCallController *weakSelf = self;
    self.view.minimizeRequested = ^
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf minimize:true];
    };
    [UIView setAnimationsEnabled:true];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.alpha = 0.0f;
    self.view.userInteractionEnabled = false;
    
    [self commonInit];
    
    __weak TGCallController *weakSelf = self;
    self.view.mutePressed = ^
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_session toggleMute];
    };
    self.view.backPressed = ^
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf minimize];
    };
    self.view.speakerPressed = ^
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf speakerPressed];
    };
    self.view.cancelPressed = ^
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf dismissController:0];
    };
    self.view.debugPressed = ^
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf showDebug];
    };
    self.view.messagePressed = ^
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf message];
    };
}

- (void)commonInit
{
    __weak TGCallController *weakSelf = self;
    
    SVariable *timer = [[SVariable alloc] init];
    [timer set:[SSignal single:@0]];
    
    SSignal *combined = [SSignal combineSignals:@[_session.stateSignal, timer.signal] withInitialStates:@[ [NSNull null], @0.0 ]];
    [_disposable setDisposable:[[combined deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next)
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf == nil || [next.firstObject isKindOfClass:[NSNull class]])
            return;
        
        TGCallSessionState *state = (TGCallSessionState *)next.firstObject;
        NSTimeInterval duration = [next.lastObject doubleValue];
        if (state.startTime > DBL_EPSILON && !strongSelf->_timerStarted)
            [timer set:[strongSelf timerSignalForStartTime:state.startTime]];
        
        if (!strongSelf->_dismissing && state.state != TGCallStateEnding && state.state != TGCallStateEnded && state.state != TGCallStateBusy && state.state != TGCallStateMissed && state.state != TGCallStateNoAnswer)
            strongSelf->_durationPipe.sink(@(duration));
        
        [strongSelf setState:state duration:duration];
        
        if (strongSelf->_peerId == 0 && state.peer.uid != 0)
            strongSelf->_peerId = state.peer.uid;
        
        if (strongSelf->_accessHash == 0 && state.stateData.accessHash != 0)
            strongSelf->_accessHash = state.stateData.accessHash;
    }]];
}

#pragma mark - Debug

- (void)showDebug
{
    if (_debugView != nil)
        return;
    
    __weak TGCallController *weakSelf = self;
    _debugView = [[TGCallDebugView alloc] initWithFrame:self.view.bounds callSession:_session];
    [_debugView setBitrate:_debugBitrate packetLoss:_debugPacketLoss p2p:_debugP2P];
    _debugView.valuesChanged = ^(NSInteger bitrate, NSInteger packetLoss, bool p2p)
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_debugBitrate = bitrate;
        [strongSelf->_session setDebugBitrate:bitrate * 1000];
        
        strongSelf->_debugPacketLoss = packetLoss;
        [strongSelf->_session setDebugPacketLoss:packetLoss];
        
        strongSelf->_debugP2P = p2p;
        [strongSelf->_session setDebugP2PEnabled:p2p];
    };
    _debugView.dismissBlock = ^
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_debugView removeFromSuperview];
        strongSelf->_debugView = nil;
    };
    [self.view addSubview:_debugView];
}

- (SSignal *)timerSignalForStartTime:(CFAbsoluteTime)time
{
    _timerStarted = true;
    return [[[[SSignal single:nil] map:^NSNumber *(__unused id value)
    {
        return @(CFAbsoluteTimeGetCurrent() - time);
    }] then:[[SSignal complete] delay:0.5 onQueue:[SQueue mainQueue]]] restart];
}

#pragma mark - State

- (SSignal *)callDuration
{
    return _durationPipe.signalProducer();
}

- (void)setState:(TGCallSessionState *)state duration:(NSTimeInterval)duration
{
    bool hasMicAccess = [TGCallSession hasMicrophoneAccess];
    
    if (!_appeared && (!hasMicAccess || ![TGCallKitAdapter callKitAvailable] || state.state == TGCallStateAccepting || state.state == TGCallStateOngoing || _session.outgoing))
        [self presentController];
    
    if (_peer == nil && state.peer != nil)
        _peer = state.peer;
    
    _audioRoutes = state.audioRoutes;
    _activeAudioRoute = state.activeAudioRoute;
    
    if (!_dismissing)
        [self updateProximityListener];
    
    __weak TGCallController *weakSelf = self;
    switch (state.state)
    {
        case TGCallStateReady:
        case TGCallStateHandshake:
        {
            self.view.declinePressed = ^
            {
                __strong TGCallController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf->_session hangUpCurrentCall];
            };
            
            self.view.callPressed = ^
            {
                __strong TGCallController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf acceptButtonPressed];
            };
        }
            break;
        
        case TGCallStateOngoing:
        case TGCallStateRequesting:
        case TGCallStateWaiting:
        case TGCallStateWaitingReceived:
        case TGCallStateAccepting:
        {
            self.view.callPressed = ^
            {
                __strong TGCallController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf->_session hangUpCurrentCall];
            };
        }
            break;
            
        case TGCallStateBusy:
        case TGCallStateNoAnswer:
        {
            if (_durationPipe != nil)
                _durationPipe.sink(nil);
            
            self.view.callPressed = ^
            {
                __strong TGCallController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf callAgainPressed];
            };
        }
            break;
            
        case TGCallStateEnded:
        case TGCallStateEnding:
        case TGCallStateMissed:
        {
            if (state.stateData.error != nil)
                _finalError = state.stateData.error;
            if ((state.state == TGCallStateEnded || state.state == TGCallStateEnding) && _session.duration > 1.0)
            {
                _presentTabAlert = true;
                if (state.stateData.needsRating)
                    _presentRatingAlert = true;
            }
            
            NSTimeInterval delay = !self.overlayWindow.hidden ? 1.0f : 0.0f;
            [self dismissController:delay];
        }
            break;
    }
    
    [self.view setState:state duration:duration];
}

- (void)acceptButtonPressed
{
    if (![TGAccessChecker checkMicrophoneAuthorizationStatusForIntent:TGMicrophoneAccessIntentCall alertDismissCompletion:nil])
        return;
    
    [TGCallController requestMicrophoneAccess:^(bool granted)
    {
        if (granted)
            [_session acceptIncomingCall];
    }];
}

- (void)callAgainPressed
{
    _accessHash = 0;
    
    _session = [TGTelegraphInstance.callManager sessionForOutgoingCallWithPeerId:_peerId];
    [self commonInit];
}

- (void)speakerPressed
{
    bool hasBluetooth = false;
    for (TGAudioRoute *route in _audioRoutes)
    {
        if (route.isBluetooth)
        {
            hasBluetooth = true;
            break;
        }
    }
    
    if (hasBluetooth)
        [self presentRouteMenu:_audioRoutes];
    else
        [_session toggleSpeaker];
}

- (void)presentRouteMenu:(NSArray *)routes
{
    if (_routeMenuCloseTimer != nil)
    {
        [_routeMenuCloseTimer invalidate];
        _routeMenuCloseTimer = nil;
    }
     
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] init];
    _menuController = controller;
    TGMenuSheetController *weakController = controller;
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    for (TGAudioRoute *route in routes)
    {
        UIImage *icon = nil;
        if (route.isLoudspeaker)
            icon = [UIImage imageNamed:@"CallRouteSpeaker"];
        else if (route.isBluetooth)
            icon = [UIImage imageNamed:@"CallRouteBluetooth"];
        
        if (icon != nil)
            icon = TGTintedImage(icon, TGAccentColor());
        
        __weak TGCallController *weakSelf = self;
        TGCallAudioRouteButtonItemView *routeItem = [[TGCallAudioRouteButtonItemView alloc] initWithTitle:route.name icon:icon selected:route == _activeAudioRoute action:^
        {
            __strong TGCallController *strongSelf = weakSelf;
            __strong TGMenuSheetController *strongController = weakController;
            if (strongSelf != nil)
            {
                [strongSelf->_session applyAudioRoute:route];
                [strongController dismissAnimated:true];
            }
        }];
        [buttons addObject:routeItem];
    }
    
    TGMenuSheetButtonItemView *hideItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Call.AudioRouteHide") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        [strongController dismissAnimated:true];
    }];
    [buttons addObject:hideItem];

    [controller setItemViews:buttons];
    
    __weak TGCallController *weakSelf = self;
    controller.sourceRect = ^
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        return [strongSelf.view.speakerButton convertRect:strongSelf.view.speakerButton.bounds toView:strongSelf.view];
    };
    controller.didDismiss = ^(__unused bool manual)
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_routeMenuCloseTimer invalidate];
        strongSelf->_routeMenuCloseTimer = nil;
    };
    [controller presentInViewController:self sourceView:self.view animated:true];
    
    _routeMenuCloseTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(menuTimerTick) interval:5.0 repeat:false];
}

- (void)menuTimerTick
{
    [_routeMenuCloseTimer invalidate];
    _routeMenuCloseTimer = nil;
    
    [_menuController dismissAnimated:true];
}

+ (void)requestMicrophoneAccess:(void (^)(bool granted))resultBlock
{
    if (iosMajorVersion() < 7)
    {
        if (resultBlock != nil)
            resultBlock(true);
        return;
    }

    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted)
    {
        TGDispatchOnMainThread(^
        {
            if (resultBlock != nil)
                resultBlock(granted);
        });
    }];
}

- (void)updateProximityListener
{
    bool proximityRequired = !_activeAudioRoute.isBluetooth && !_activeAudioRoute.isLoudspeaker;
    if (_proximityChangeHolder == nil && _proximityListenerEnabled && proximityRequired)
    {
        _proximityChangeHolder = [[TGHolder alloc] init];
        [TGAppDelegateInstance.deviceProximityListeners addHolder:_proximityChangeHolder];
    }
    else if (_proximityChangeHolder != nil && (!proximityRequired || !_proximityListenerEnabled))
    {
        [TGAppDelegateInstance.deviceProximityListeners removeHolder:_proximityChangeHolder];
        _proximityChangeHolder = nil;
    }
}

- (void)setProximityListenerEnabled:(bool)enabled
{
    _proximityListenerEnabled = enabled;
    [self updateProximityListener];
}

- (void)hangUpCall
{
    [_session hangUpCurrentCall];
}

- (void)hangUpCallWithCompletion:(void (^)())completion
{
    [_session hangUpCurrentCallCompletion:completion];
}

- (void)message
{
    [[TGInterfaceManager instance] navigateToConversationWithId:_peerId conversation:nil performActions:nil atMessage:nil clearStack:true openKeyboard:true canOpenKeyboardWhileInTransition:true animated:true];
    [self dismissController:0];
}

#pragma mark - Alerts

+ (void)presentRatingAlertView:(int64_t)callId accessHash:(int64_t)accessHash presentTabAlert:(bool)presentTabAlert
{
    TGCallRatingView *ratingView = [[TGCallRatingView alloc] init];
    __weak TGCallRatingView *weakRatingView = ratingView;
    TGCallAlertView *alertView = [TGCallAlertView presentAlertWithTitle:TGLocalized(@"Calls.RatingTitle") message:nil customView:ratingView cancelButtonTitle:TGLocalized(@"Calls.NotNow") doneButtonTitle:TGLocalized(@"Calls.SubmitRating") completionBlock:^(bool done)
    {
        if (!done)
            return;
        
        __strong TGCallRatingView *strongRatingView = weakRatingView;
        if (strongRatingView.selectedStars < 4)
        {
            [self presentSendLogsViewWithCompletion:^(bool includeLogs) {
                [[TGCallSignals reportCallRatingWithCallId:callId accessHash:accessHash rating:(int32_t)strongRatingView.selectedStars comment:strongRatingView.comment includeLogs:includeLogs] startWithNext:nil];
                
                if (presentTabAlert)
                    [TGAppDelegateInstance.rootController.callsController maybeSuggestEnableCallsTab:false];
            }];
        }
        else
        {
            [[TGCallSignals reportCallRatingWithCallId:callId accessHash:accessHash rating:(int32_t)strongRatingView.selectedStars comment:strongRatingView.comment includeLogs:false] startWithNext:nil];
            
            if (presentTabAlert)
                [TGAppDelegateInstance.rootController.callsController maybeSuggestEnableCallsTab:false];
        }
    }];
    alertView.followsKeyboard = true;
    alertView.doneButton.enabled = false;
    alertView.shouldDismissOnDimTap = ^bool
    {
        __strong TGCallRatingView *strongRatingView = weakRatingView;
        return strongRatingView.comment.length == 0 || strongRatingView.selectedStars == 5;
    };
    
    __weak TGCallAlertView *weakAlertView = alertView;
    ratingView.onStarsSelected = ^
    {
        __strong TGCallAlertView *strongAlertView = weakAlertView;
        strongAlertView.doneButton.enabled = true;
    };
    ratingView.onHeightChanged = ^(CGFloat height)
    {
        __strong TGCallAlertView *strongAlertView = weakAlertView;
        [strongAlertView updateCustomViewHeight:height];
    };
}

+ (void)presentSendLogsViewWithCompletion:(void (^)(bool))completion
{
    TGCallAlertView *alertView = [TGCallAlertView presentAlertWithTitle:TGLocalized(@"Call.ReportIncludeLog") message:TGLocalized(@"Call.ReportIncludeLogDescription") customView:nil cancelButtonTitle:TGLocalized(@"Call.ReportSkip") doneButtonTitle:TGLocalized(@"Call.ReportSend") completionBlock:^(bool done)
    {
        if (completion != nil)
            completion(done);
    }];
    alertView.followsKeyboard = true;
    alertView.shouldDismissOnDimTap = ^bool
    {
        return true;
    };
}

- (void)presentErrorAlertView:(NSString *)error
{
    NSString *text = [self _localizedStringForError:error];
    if (text.length == 0)
        return;
    
    if ([text rangeOfString:@"%@"].location != NSNotFound)
        text = [NSString stringWithFormat:text, _peer.displayFirstName];
    
    [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Call.ConnectionErrorTitle") message:text cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
}

- (NSString *)_localizedStringForError:(NSString *)error
{
    if ([error isEqualToString:@"PARTICIPANT_VERSION_OUTDATED"])
        return TGLocalized(@"Call.ParticipantVersionOutdatedError");
    else if ([error isEqualToString:@"USER_PRIVACY_RESTRICTED"])
        return TGLocalized(@"Call.PrivacyErrorMessage");
    
    return nil;
}

#pragma mark - Transition

- (void)presentController
{
    if (self.view.alpha > FLT_EPSILON || _appearing || _minimizing)
        return;
    
    _appearing = true;
    _appeared = true;
    
    _previousStatusBarAlpha = [TGHacks applicationStatusBarAlpha];
    _previousStatusBarOffset = [TGHacks applicationStatusBarOffset];
    
    self.overlayWindow.hidden = false;
    self.view.userInteractionEnabled = true;
    self.view.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    self.view.layer.shouldRasterize = true;
    
    [self.view onResume];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
    {
        self.view.alpha = 1.0f;
        self.view.transform = CGAffineTransformIdentity;
        
        [TGHacks setApplicationStatusBarAlpha:1.0f];
        [TGHacks setApplicationStatusBarOffset:0.0f];
    } completion:^(__unused BOOL finished)
    {
        _appearing = false;
        self.view.layer.shouldRasterize = false;
        
        if (self.onTransitionIn != nil)
            self.onTransitionIn();
    }];
    
    [self setProximityListenerEnabled:true];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:true];
}

- (void)dismissController:(NSTimeInterval)delay
{
    if (_dismissing)
        return;
    
    _dismissing = true;
    self.view.userInteractionEnabled = false;
    
    [self setProximityListenerEnabled:false];
    
    _durationPipe.sink(nil);
    [TGAppDelegateInstance.rootController.callStatusBarView setSignal:[SSignal single:nil]];
    
    if (_appeared)
    {
        int64_t callId = _session.callId;
        int64_t accessHash = _accessHash;
        
        TGDispatchAfter(delay, dispatch_get_main_queue(), ^
        {
            _disappearing = true;
            [self animateDismissWithCompletion:^
            {
                [self dismiss];
            }];
        });
        
        if (delay > DBL_EPSILON)
        {
            TGDispatchAfter(delay + 0.2, dispatch_get_main_queue(), ^
            {
                if (_finalError.length > 0)
                    [self presentErrorAlertView:_finalError];
                else if (_presentRatingAlert)
                    [TGCallController presentRatingAlertView:callId accessHash:accessHash presentTabAlert:_presentTabAlert];
                else if (_presentTabAlert)
                    [TGAppDelegateInstance.rootController.callsController maybeSuggestEnableCallsTab:false];
            });
        }
    }
    else
    {
        _disappearing = true;
        [self dismiss];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
}

- (void)minimize
{
    [self minimize:false];
}

- (void)minimize:(bool)fast
{
    if (self.overlayWindow.hidden)
        return;
    
    _minimizing = true;
    self.view.userInteractionEnabled = false;
    [self animateDismiss:fast completion:^
    {
        _minimizing = false;
        self.overlayWindow.hidden = true;
    }];
}

- (void)animateDismissWithCompletion:(void (^)(void))completion
{
    [self animateDismiss:false completion:completion];
}

- (void)animateDismiss:(bool)fast completion:(void (^)(void))completion
{
    [self setProximityListenerEnabled:false];
    
    self.view.layer.shouldRasterize = true;
    [self setNeedsStatusBarAppearanceUpdate];
    if (fast)
    {
        [UIView animateWithDuration:0.2 animations:^
        {
            self.view.alpha = 0.0f;
        }];
    }
    
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
    {
        if (!fast)
            self.view.alpha = 0.0f;
        [self.view centralize];
        self.view.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        
        [TGHacks setApplicationStatusBarAlpha:_previousStatusBarAlpha];
        [TGHacks setApplicationStatusBarOffset:_previousStatusBarOffset];
    } completion:^(__unused BOOL finished)
    {
        self.view.transform = CGAffineTransformIdentity;
        [self.view setNeedsLayout];
        
        [self.view resetPan];
        
        if (completion != nil)
            completion();
        
        [self.view onPause];
    }];
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (!TGIsPad())
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    if (!TGIsPad() && UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        return false;
    
    return [super shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (!TGIsPad())
        return UIInterfaceOrientationMaskPortrait;
    
    return [super supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (!TGIsPad())
        return UIInterfaceOrientationPortrait;
    
    return [super preferredInterfaceOrientationForPresentation];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (_disappearing)
        return UIStatusBarStyleDefault;
    else
        return UIStatusBarStyleLightContent;
}

@end


@implementation TGCallControllerWindow

- (instancetype)initWithParentController:(TGViewController *)parentController contentController:(TGOverlayController *)contentController
{
    self = [super initWithParentController:parentController contentController:contentController];
    if (self != nil)
    {
        self.windowLevel = UIWindowLevelStatusBar - 0.0001f;
    }
    return self;
}

static CGPoint TGCallControllerClampPointToScreenSize(__unused id self, __unused SEL _cmd, CGPoint point)
{
    CGSize screenSize = TGScreenSize();
    return CGPointMake(MAX(0, MIN(point.x, screenSize.width)), MAX(0, MIN(point.y, screenSize.height)));
}

+ (void)initialize
{
    static bool initialized = false;
    if (!initialized)
    {
        initialized = true;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && (iosMajorVersion() > 8 || (iosMajorVersion() == 8 && iosMinorVersion() >= 3)))
        {
            FreedomDecoration instanceDecorations[] =
            {
                {
                    .name = 0x4ea0b831U,
                    .imp = (IMP)&TGCallControllerClampPointToScreenSize,
                    .newIdentifier = FreedomIdentifierEmpty,
                    .newEncoding = FreedomIdentifierEmpty
                }
            };
            
            freedomClassAutoDecorate(0xcdf37bc2, NULL, 0, instanceDecorations, sizeof(instanceDecorations) / sizeof(instanceDecorations[0]));
        }
    }
}

@end
