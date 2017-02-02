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

#import "TGCallSession.h"
#import "TGCallKitAdapter.h"
#import "TGAccessChecker.h"

#import "TGCallView.h"
#import "TGCallDebugView.h"
#import "TGCallAlertView.h"
#import "TGCallRatingView.h"

@interface TGCallController ()
{
    TGHolder *_proximityChangeHolder;
    
    TGCallSession *_session;
    SMetaDisposable *_disposable;
    SMetaDisposable *_levelDisposable;
    
    int64_t _peerId;
    
    bool _appeared;
    bool _dismissing;
    bool _disappearing;
    bool _timerStarted;
    
    bool _presentRatingAlert;
    
    UIButton *_debugButton;
    TGCallDebugView *_debugView;
    
    SPipe *_durationPipe;
    
    CGFloat _previousStatusBarAlpha;
    CGFloat _previousStatusBarOffset;
    
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
    self.view.messagePressed = ^
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf minimize];
    };
    self.view.speakerPressed = ^
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_session toggleSpeaker];
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
        
        if (state.state != TGCallStateEnding && state.state != TGCallStateEnded)
            strongSelf->_durationPipe.sink(@(duration));
        
        [strongSelf setState:state duration:duration];
        
        if (strongSelf->_peerId == 0 && state.peer.uid != 0)
            strongSelf->_peerId = state.peer.uid;
    }]];
    
    [_levelDisposable setDisposable:[[_session levelSignal] startWithNext:^(NSNumber *next)
    {
        __strong TGCallController *strongSelf = weakSelf;
        if (strongSelf != nil && [next respondsToSelector:@selector(floatValue)])
            [strongSelf.view setLevel:next.floatValue];
    }]];
    
    _debugButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 64, 64, 64)];
    _debugButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_debugButton addTarget:self action:@selector(showDebug) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_debugButton];
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
    if (!_appeared && (![TGCallKitAdapter callKitAvailable] || state.state == TGCallStateAccepting || state.state == TGCallStateOngoing || _session.outgoing))
        [self presentController];
    
    if (!_dismissing)
        [self updateProximityListener:!state.speaker];
    
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

        case TGCallStateEnded:
        case TGCallStateEnding:
        case TGCallStateBusy:
        case TGCallStateInterrupted:
        {
            if (state.state != TGCallStateBusy && state.state != TGCallStateInterrupted && _session.duration > 10.0)
                _presentRatingAlert = true;
            
            [self dismissController:state.state == TGCallStateBusy ? 2.0 : 1.0];
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

+ (void)requestMicrophoneAccess:(void (^)(bool granted))resultBlock
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted)
    {
        TGDispatchOnMainThread(^
        {
            if (resultBlock != nil)
                resultBlock(granted);
        });
    }];
}

- (void)updateProximityListener:(bool)maybeEnable
{
    if (_proximityChangeHolder == nil && maybeEnable)
    {
        _proximityChangeHolder = [[TGHolder alloc] init];
        [TGAppDelegateInstance.deviceProximityListeners addHolder:_proximityChangeHolder];
    }
    else if (_proximityChangeHolder != nil && !maybeEnable)
    {
        [TGAppDelegateInstance.deviceProximityListeners removeHolder:_proximityChangeHolder];
        _proximityChangeHolder = nil;
    }
}

static int callsCount = 0;

- (void)presentRatingAlertView:(int64_t)callId
{
    TGCallRatingView *ratingView = [[TGCallRatingView alloc] init];
    TGCallAlertView *alertView = [TGCallAlertView presentAlertWithTitle:TGLocalized(@"Calls.RatingTitle") message:nil customView:ratingView cancelButtonTitle:TGLocalized(@"Calls.NotNow") doneButtonTitle:TGLocalized(@"Calls.SubmitRating") completionBlock:^(bool done)
    {
        callsCount++;
        
        if (callsCount == 2)
            [[TGInterfaceManager instance] maybeDisplayCallTabAlert];
        
        if (!done)
            return;
    }];
    alertView.doneButton.enabled = false;
    
    __weak TGCallAlertView *weakAlertView = alertView;
    ratingView.onStarsSelected = ^
    {
        __strong TGCallAlertView *strongAlertView = weakAlertView;
        strongAlertView.doneButton.enabled = true;
    };
}

#pragma mark - Transition

- (void)presentController
{
    if (self.view.alpha > FLT_EPSILON)
        return;
        
    _previousStatusBarAlpha = [TGHacks applicationStatusBarAlpha];
    _previousStatusBarOffset = [TGHacks applicationStatusBarOffset];
    
    _appeared = true;
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
        self.view.layer.shouldRasterize = false;
    }];
    
    [self updateProximityListener:true];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:true];
}

- (void)dismissController:(NSTimeInterval)delay
{
    if (_dismissing)
        return;
    
    _dismissing = true;
    self.view.userInteractionEnabled = false;
    
    [self updateProximityListener:false];
    
    if (self.onDismissBlock != nil)
        self.onDismissBlock();
    
    if (_appeared)
    {
        int64_t callId = _session.callId;
        
        TGDispatchAfter(delay, dispatch_get_main_queue(), ^
        {
            _disappearing = true;
            [self animateDismissWithCompletion:^
            {
                [self dismiss];
                
                if (_presentRatingAlert)
                    [self presentRatingAlertView:callId];
            }];
        });
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
    self.view.userInteractionEnabled = false;
    [self animateDismissWithCompletion:^
    {
        self.overlayWindow.hidden = true;
    }];
}

- (void)animateDismissWithCompletion:(void (^)(void))completion
{
    [self updateProximityListener:false];
    
    self.view.layer.shouldRasterize = true;
    [self setNeedsStatusBarAppearanceUpdate];
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
    {
        self.view.alpha = 0.0f;
        self.view.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        
        [TGHacks setApplicationStatusBarAlpha:_previousStatusBarAlpha];
        [TGHacks setApplicationStatusBarOffset:_previousStatusBarOffset];
    } completion:^(__unused BOOL finished)
    {
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
    if (!TGIsPad())
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
