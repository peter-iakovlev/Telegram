#import "TGCallSession.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MTProtoKit/MTEncryption.h>

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGUser.h"

#import "TGCallUtils.h"
#import "TGImageUtils.h"
#import "TGObserverProxy.h"

#import "TGCallKitAdapter.h"

#import "VoIPController.h"

const double TGCallAudioSampleRate = 48000;
const NSInteger TGCallDefaultFrameSize = 40;

const NSTimeInterval TGCallReceiveTimeout = 20;
const NSTimeInterval TGCallRingTimeout = 90;
const NSTimeInterval TGCallConnectTimeout = 30;
const NSTimeInterval TGCallPacketTimeout = 10;

@interface TGCallAudioToggles : NSObject

@property (nonatomic, readonly) bool muted;
@property (nonatomic, readonly) bool speaker;

- (instancetype)initWithMuted:(bool)muted speaker:(bool)speaker;

@end

@interface TGCallSession ()
{
    SMetaDisposable *_networkDisposable;
    SMetaDisposable *_disposable;
    SMetaDisposable *_timeoutDisposable;
    
    SVariable *_state;
    SPipe *_statePipe;
    
    SVariable *_transmissionState;
    SPipe *_transmissionPipe;
    
    SVariable *_audioToggles;
    
    bool _hadAudioSession;
    bool _started;
    bool _discarded;
    NSNumber *_internalId;
    CVoIPController *_controller;
    
    TGUser *_peer;
    CFAbsoluteTime _startTime;
    NSData *_keySha1;
    NSData *_keySha256;
    
    bool _playingRingtone;
    AVAudioPlayer *_audioPlayer;
    SMetaDisposable *_vibrateDisposable;
    
    bool _muted;
    bool _speaker;
    
    UIView *_debugView;
    UILabel *_debugLabel;
    SMetaDisposable *_debugDisposable;
    
    TGObserverProxy *_applicationWillResignActiveProxy;
    TGObserverProxy *_applicationDidBecomeActiveProxy;
}
@end

@implementation TGCallSession

- (instancetype)initOutgoing:(bool)outgoing
{
    self = [super init];
    if (self != nil)
    {
        _outgoing = outgoing;
        
        _statePipe = [[SPipe alloc] init];
        _state = [[SVariable alloc] init];
        [_state set:_statePipe.signalProducer()];
        
        _transmissionPipe = [[SPipe alloc] init];
        _transmissionState = [[SVariable alloc] init];
        [_transmissionState set:_transmissionPipe.signalProducer()];
        
        _audioToggles = [[SVariable alloc] init];
        [self _updateAudioToggles];
        
        _applicationWillResignActiveProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification];
        _applicationDidBecomeActiveProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification];
    }
    return self;
}

- (instancetype)initWithSignal:(SSignal *)signal outgoing:(bool)outgoing
{
    self = [self initOutgoing:outgoing];
    if (self != nil)
    {
        [self startWithSignal:signal];
    }
    return self;
}

- (void)dealloc
{
    [_disposable dispose];
    [_networkDisposable dispose];
    [_timeoutDisposable dispose];
    [_debugDisposable dispose];
}

- (void)startWithSignal:(SSignal *)signal
{
    [self _controllerInit];
    [self _setCallSignal:signal];
}

- (void)_setCallSignal:(SSignal *)signal
{
    __weak TGCallSession *weakSelf = self;
    
    __block SMetaDisposable *disposable = _disposable;
    _disposable = [[SMetaDisposable alloc] init];
    [disposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(TGCallStateData *next)
    {
        __strong TGCallSession *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updateWithState:next];
        
        if (disposable != nil)
        {
            [disposable setDisposable:nil];
            disposable = nil;
        }
    } error:^(__unused id error)
    {
        __strong TGCallSession *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
    } completed:^
    {
        
    }]];
}

static void controllerStateCallback(CVoIPController *controller, int state)
{
    TGCallSession *session = (__bridge TGCallSession *)controller->implData;
    [session controllerStateChanged:state];
}

- (void)_controllerInit
{
    _controller = new CVoIPController();
    _controller->implData = (__bridge void *)self;
    _controller->SetStateCallback(&controllerStateCallback);
    
    CVoIPController::crypto.sha1 = &TGCallSha1;
    CVoIPController::crypto.sha256 = &TGCallSha256;
    CVoIPController::crypto.rand_bytes = &TGCallRandomBytes;
    CVoIPController::crypto.aes_ige_encrypt = &TGCallAesIgeEncryptInplace;
    CVoIPController::crypto.aes_ige_decrypt = &TGCallAesIgeDecryptInplace;
}

- (void)controllerStateChanged:(int)state
{
    TGCallTransmissionState tranmissionState = TGCallTransmissionStateInitializing;
    switch (state)
    {
        case STATE_ESTABLISHED:
            tranmissionState = TGCallTransmissionStateEstablished;
            break;
            
        case STATE_FAILED:
            tranmissionState = TGCallTransmissionStateFailed;
            break;
            
        default:
            break;
    }
    
    if (tranmissionState == TGCallTransmissionStateEstablished && _startTime < DBL_EPSILON)
    {
        _startTime = CFAbsoluteTimeGetCurrent();
        
        if (self.outgoing && self.onConnected != nil)
            self.onConnected();
    }
    
    _transmissionPipe.sink(@(tranmissionState));
 
    if (tranmissionState == TGCallTransmissionStateFailed)
        [self _discardCurrentCallWithReason:TGCallDiscardReasonDisconnect];
}

#pragma mark - Transmission

- (void)setupVoipEndpoint:(voip_endpoint_t *)endpoint withConnection:(TGCallConnectionDescription *)connection
{
    struct in_addr addrIpV4;
    if (!inet_aton(connection.ipv4.UTF8String, &addrIpV4))
        TGLog(@"CallSession: invalid ipv4 address");
    
    struct in6_addr addrIpV6;
    if (!inet_pton(AF_INET6, connection.ipv6.UTF8String, &addrIpV6))
        TGLog(@"CallSession: invalid ipv6 address");
    
    endpoint->id = connection.identifier;
    endpoint->port = (uint32_t)connection.port;
    endpoint->address = addrIpV4;
    endpoint->address6 = addrIpV6;
    endpoint->type = EP_TYPE_UDP_RELAY;
    [connection.peerTag getBytes:endpoint->peerTag length:16];
}

- (void)startTransmissionIfNeeded:(TGCallStateData *)state
{
    if (_started)
        return;
    
    if (![TGCallKitAdapter callKitAvailable])
        [self setupAudioSession];
    
    size_t endpointsCount = 1 + state.connection.alternativeConnections.count;
    voip_endpoint_t endpoints[endpointsCount];
    
    NSArray *connections = [@[state.connection.defaultConnection] arrayByAddingObjectsFromArray:state.connection.alternativeConnections];
    for (NSUInteger i = 0; i < connections.count; i++)
    {
        [self setupVoipEndpoint:&endpoints[i] withConnection:connections[i]];
    }
    
    voip_config_t config;
    config.init_timeout = [self callConnectTimeout];
    config.recv_timeout = [self callPacketTimeout];
    config.data_saving = TGAppDelegateInstance.callsDataUsageMode;
    config.frame_size = TGCallDefaultFrameSize;
    _controller->SetConfig(&config);
    
    _controller->SetEncryptionKey((char *)state.connection.key.bytes);
    _controller->SetRemoteEndpoints(endpoints, endpointsCount, true);
    _controller->Start();

    [self startNetworkTypeMonitoring];
    _controller->Connect();
    
    if (self.outgoing && self.onStartedConnecting != nil)
        self.onStartedConnecting();
    
    _started = true;
}

- (void)stopTransmission
{
    if (_controller == nil)
        return;
    
    voip_stats_t stats;
    _controller->GetStats(&stats);
    
    //TODO: Update stats here
    
    delete _controller;
    _controller = nil;
}

- (void)startNetworkTypeMonitoring
{
    __weak TGCallSession *weakSelf = self;
    _networkDisposable = [[SMetaDisposable alloc] init];
    [_networkDisposable setDisposable:[[[[TGCallUtils networkTypeSignal] map:^NSNumber *(NSNumber *value)
    {
        switch ((TGCallNetworkType)value.integerValue)
        {
            case TGCallNetworkTypeGPRS:
                return @(NET_TYPE_GPRS);
                
            case TGCallNetworkTypeEdge:
                return @(NET_TYPE_EDGE);
                
            case TGCallNetworkType3G:
                return @(NET_TYPE_3G);
                
            case TGCallNetworkTypeLTE:
                return @(NET_TYPE_LTE);
                
            case TGCallNetworkTypeWiFi:
                return @(NET_TYPE_WIFI);
                
            default:
                return @(NET_TYPE_UNKNOWN);
        }
    }] ignoreRepeated] startWithNext:^(NSNumber *next)
    {
        __strong TGCallSession *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_controller != nil)
            strongSelf->_controller->SetNetworkType(next.intValue);
    }]];
}

#pragma mark - Actions

- (void)acceptIncomingCall
{
    if (_internalId != nil)
        [self _setCallSignal:[TGTelegraphInstance.callManager acceptCallWithInternalId:_internalId]];
}

- (void)hangUpCurrentCall
{
    [self hangUpCurrentCall:false];
}

- (void)hangUpCurrentCall:(bool)external
{
    _completed = external;
    [[_state.signal take:1] startWithNext:^(TGCallStateData *next)
    {
        TGCallDiscardReason reason = TGCallDiscardReasonHangup;
        if (next.state != TGCallStateOngoing)
            reason = TGCallDiscardReasonMissed;
        
        [self _discardCurrentCallWithReason:reason];
    }];
}

- (void)_discardCurrentCallWithReason:(TGCallDiscardReason)reason
{
    if (_internalId != nil && !_discarded)
    {
        _discarded = true;
        [self _setCallSignal:[TGTelegraphInstance.callManager discardCallWithInternalId:_internalId reason:reason]];
    }
}

#pragma mark - Timeout

- (void)startTimeout:(NSTimeInterval)duration discardReason:(TGCallDiscardReason)discardReason
{
    if (_timeoutDisposable == nil)
        _timeoutDisposable = [[SMetaDisposable alloc] init];
    
    __weak TGCallSession *weakSelf = self;
    [_timeoutDisposable setDisposable:[[[SSignal complete] delay:duration onQueue:[SQueue mainQueue]] startWithNext:nil completed:^
    {
       __strong TGCallSession *strongSelf = weakSelf;
       if (strongSelf != nil)
           [strongSelf _discardCurrentCallWithReason:discardReason];
    }]];
}

- (void)invalidateTimeout
{
    [_timeoutDisposable setDisposable:nil];
}

- (NSTimeInterval)callReceiveTimeout
{
    int32_t value = (int32_t)TGCallReceiveTimeout;
    NSData *data = [TGDatabaseInstance() customProperty:@"callReceiveTimeout"];
    if (data.length >= 4)
    {
        [data getBytes:&value length:4];
        value /= 1000;
    }
    return value;
}

- (NSTimeInterval)callRingTimeout
{
    int32_t value = (int32_t)TGCallRingTimeout;
    NSData *data = [TGDatabaseInstance() customProperty:@"callRingTimeout"];
    if (data.length >= 4)
    {
        [data getBytes:&value length:4];
        value /= 1000;
    }
    return value;
}

- (NSTimeInterval)callConnectTimeout
{
    int32_t value = (int32_t)TGCallConnectTimeout;
    NSData *data = [TGDatabaseInstance() customProperty:@"callConnectTimeout"];
    if (data.length >= 4)
    {
        [data getBytes:&value length:4];
        value /= 1000;
    }
    return value;
}

- (NSTimeInterval)callPacketTimeout
{
    int32_t value = (int32_t)TGCallPacketTimeout;
    NSData *data = [TGDatabaseInstance() customProperty:@"callPacketTimeout"];
    if (data.length >= 4)
    {
        [data getBytes:&value length:4];
        value /= 1000;
    }
    return value;
}

#pragma mark - Notifications

- (bool)_isInBackground
{
    UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
    if ([UIApplication sharedApplication] == nil)
        applicationState = UIApplicationStateBackground;
    
    return applicationState != UIApplicationStateActive;
}

- (void)displayNotification
{
    if ([TGCallKitAdapter callKitAvailable])
        return;
    
    UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
    if ([UIApplication sharedApplication] == nil)
        applicationState = UIApplicationStateBackground;
    
    if ([self _isInBackground])
    {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        if (localNotification == nil)
            return;
        
        //bool isLocked = [TGAppDelegateInstance isCurrentlyLocked];
        NSString *text = [NSString stringWithFormat:TGLocalized(@"PHONE_CALL_REQUEST"), _peer.displayName];
        
        int globalMessageSoundId = 1;
        bool globalMessagePreviewText = true;
        int globalMessageMuteUntil = 0;
        bool notFound = false;
        [TGDatabaseInstance() loadPeerNotificationSettings:INT_MAX - 1 soundId:&globalMessageSoundId muteUntil:&globalMessageMuteUntil previewText:&globalMessagePreviewText messagesMuted:NULL notFound:&notFound];
        if (notFound)
        {
            globalMessageSoundId = 1;
            globalMessagePreviewText = true;
        }

        int soundId = 1;
        notFound = false;
        int muteUntil = 0;
        [TGDatabaseInstance() loadPeerNotificationSettings:_peer.uid soundId:&soundId muteUntil:&muteUntil previewText:NULL messagesMuted:NULL notFound:&notFound];
        if (notFound)
            soundId = 1;
        
        if (soundId == 1)
            soundId = globalMessageSoundId;
        
        if (soundId > 0)
            localNotification.soundName = [[NSString alloc] initWithFormat:@"%d.m4a", soundId];
        
#ifdef INTERNAL_RELEASE
        text = [@"[L] " stringByAppendingString:text];
#endif
        localNotification.alertBody = text;
        localNotification.userInfo = @{@"cid": @(_peer.uid)};
        
        if (text != nil)
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

- (void)applicationWillResignActive:(NSNotification *)__unused notification
{
    if ([TGCallKitAdapter callKitAvailable])
        return;
    
    if (_playingRingtone && _audioPlayer != nil)
        [self stopAudio];
}

- (void)applicationDidBecomeActive:(NSNotification *)__unused notification
{
    if ([TGCallKitAdapter callKitAvailable])
        return;
    
    if (_playingRingtone && _audioPlayer == nil)
        [self _startRingtonePlayer];
}

#pragma mark - Audio

static BOOL audioHasSession = false;
NSString *audioPreviousCategory;
NSString *audioPreviousMode;
AVAudioSessionCategoryOptions audioPreviousOptions;
double audioPreviousSampleRate;

+ (SQueue *)audioQueue
{
    static dispatch_once_t onceToken;
    static SQueue *queue;
    dispatch_once(&onceToken, ^
    {
        queue = [[SQueue alloc] init];
    });
    return queue;
}

- (void)setupAudioSession
{
    _hadAudioSession = true;
    [TGCallSession setupAudioSession];
}

- (void)resetAudioSession
{
    if (!_hadAudioSession)
        return;
    
    [TGCallSession resetAudioSession];
}

+ (void)setupAudioSession
{
    if (audioHasSession)
        return;
    
    audioHasSession = true;
    
    [[self audioQueue] dispatch:^
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        audioPreviousCategory = session.category;
        audioPreviousMode = session.mode;
        audioPreviousOptions = session.categoryOptions;
        audioPreviousSampleRate = session.sampleRate;
        
        [session setPreferredSampleRate:TGCallAudioSampleRate error:NULL];
		[session setPreferredIOBufferDuration:0.020 error:NULL];
        
        AVAudioSessionCategoryOptions options = session.categoryOptions;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:options error:NULL];
        [session setMode:AVAudioSessionModeVoiceChat error:NULL];
    }];
}

+ (void)resetAudioSession
{
    if (!audioHasSession)
        return;
    
    audioHasSession = false;
    [[self audioQueue] dispatch:^
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setPreferredSampleRate:audioPreviousSampleRate error:NULL];
        [session setCategory:audioPreviousCategory withOptions:audioPreviousOptions error:NULL];
        [session setMode:audioPreviousMode error:NULL];
    }];
}

- (void)toggleMute
{
    [self setMuted:!_muted];
}

- (void)setMuted:(bool)muted
{
    _muted = muted;
    if (_controller != nil)
        _controller->SetMicMute(_muted);
    
    [self _updateAudioToggles];
}

- (void)toggleSpeaker
{
    _speaker = !_speaker;
    
    [[TGCallSession audioQueue] dispatch:^
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        AVAudioSessionPortOverride value = _speaker ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
        [session overrideOutputAudioPort:value error:NULL];
    }];
    
    [self _updateAudioToggles];
}

- (void)_updateAudioToggles
{
    [_audioToggles set:[SSignal single:[[TGCallAudioToggles alloc] initWithMuted:_muted speaker:_speaker]]];
}

- (void)playRingtone
{
    if ([TGCallKitAdapter callKitAvailable] || _audioPlayer != nil)
        return;
    
    _playingRingtone = true;
    if (![self _isInBackground])
        [self _startRingtonePlayer];
}

- (void)_startRingtonePlayer
{
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:@"/Library/Ringtones/Opening.m4r"] error:NULL];
    _audioPlayer.numberOfLoops = -1;
    [_audioPlayer play];
    
    _vibrateDisposable = [[SMetaDisposable alloc] init];
    [_vibrateDisposable setDisposable:[[[[SSignal single:nil] then:[[SSignal complete] delay:1.6 onQueue:[SQueue mainQueue]]] restart] startWithNext:^(__unused id next)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }]];
}

- (void)playBusyTone
{
    [self _playTone:@"/System/Library/Audio/UISounds/nano/busy_tone_ansi.caf" loops:3];
}

- (void)playRingbackTone
{
    [self _playTone:@"/System/Library/Audio/UISounds/nano/ringback_tone_ansi.caf" loops:-1];
}

- (void)_playTone:(NSString *)path loops:(NSInteger)loops
{
    if (_audioPlayer != nil)
        return;
    
    [self setupAudioSession];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:NULL];
    _audioPlayer.numberOfLoops = loops;
    [_audioPlayer play];
}

- (void)stopAudio
{
    [_audioPlayer stop];
    _audioPlayer = nil;
    
    [_vibrateDisposable setDisposable:nil];
    _vibrateDisposable = nil;
}

#pragma mark - State

- (void)updateWithState:(TGCallStateData *)state
{
    _internalId = state.internalId;
    if (_peer == nil && state.peerId != 0)
        _peer = [TGDatabaseInstance() loadUser:(int32_t)state.peerId];
    
    if (_callId == 0 && state.callId != 0)
        _callId = state.callId;
    
    if (state.connection.key != nil && _keySha1 == nil)
    {
        _keySha1 = MTSha1(state.connection.key);
        _keySha256 = MTSha256(state.connection.key);
    }
    
    switch (state.state)
    {
        case TGCallStateWaiting:
            [self startTimeout:[self callReceiveTimeout] discardReason:TGCallDiscardReasonMissed];
            break;
            
        case TGCallStateWaitingReceived:
            [self startTimeout:[self callRingTimeout] discardReason:TGCallDiscardReasonMissed];
            [self playRingbackTone];
            break;
            
        case TGCallStateHandshake:
        {
            [self playRingtone];
            [self displayNotification];
        }
            break;
            
        case TGCallStateReady:
            [self playRingtone];
            break;
            
        case TGCallStateAccepting:
            _playingRingtone = false;
            [self stopAudio];
            break;
            
        case TGCallStateOngoing:
            _playingRingtone = false;
            [self invalidateTimeout];
            [self stopAudio];
            [self startTransmissionIfNeeded:state];
            break;
            
        case TGCallStateEnded:
        case TGCallStateEnding:
        case TGCallStateBusy:
        case TGCallStateInterrupted:
            _playingRingtone = false;
            [self invalidateTimeout];
            [self stopAudio];
            [self stopTransmission];
            
            if (_outgoing && state.state == TGCallStateBusy)
            {
                [self playBusyTone];
            }
            else
            {
                if (![TGCallKitAdapter callKitAvailable])
                    [self resetAudioSession];
            }
            break;
            
        default:
            break;
    }
    
    _statePipe.sink(state);
}

- (NSTimeInterval)duration
{
    if (_startTime > DBL_EPSILON)
        return CFAbsoluteTimeGetCurrent() - _startTime;
    return 0.0;
}

- (SSignal *)stateSignal
{
    __weak TGCallSession *weakSelf = self;
    return [[[SSignal combineSignals:@[_state.signal, _transmissionState.signal, _audioToggles.signal]] deliverOn:[SQueue mainQueue]] map:^id(NSArray *values)
    {
        __strong TGCallSession *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        TGCallStateData *stateData = (TGCallStateData *)values[0];
        TGCallTransmissionState transmissionState = (TGCallTransmissionState)[values[1] integerValue];
        TGCallAudioToggles *audioToggles = (TGCallAudioToggles *)values[2];
        
        return [[TGCallSessionState alloc] initWithOutgoing:_outgoing callStateData:stateData transmissionState:transmissionState peer:strongSelf->_peer keySha1:strongSelf->_keySha1 keySha256:strongSelf->_keySha256 startTime:strongSelf->_startTime mute:audioToggles.muted speaker:audioToggles.speaker];
    }];
}

- (SSignal *)debugSignal
{
    __weak TGCallSession *weakSelf = self;
    return [[[SSignal defer:^SSignal *{
        __strong TGCallSession *strongSelf = weakSelf;
        if (strongSelf == nil || strongSelf->_controller == nil)
            return [SSignal complete];
        
        NSString *versionString = [NSString stringWithUTF8String:strongSelf->_controller->GetVersion()];
        char buffer[2048];
        strongSelf->_controller->GetDebugString(buffer, 2048);
        NSString *debugString = [NSString stringWithUTF8String:buffer];
        return [SSignal single:[NSString stringWithFormat:@"libtgvoip v%@\n%@", versionString, debugString]];
    }] then:[[SSignal complete] delay:0.5 onQueue:[SQueue mainQueue]]] restart];
}

- (SSignal *)levelSignal
{
    __weak TGCallSession *weakSelf = self;
    return [[[SSignal defer:^SSignal *{
        __strong TGCallSession *strongSelf = weakSelf;
        if (strongSelf == nil || strongSelf->_controller == nil)
            return [SSignal complete];
        
        CGFloat level = MIN(1.0f, MAX(0.0f, strongSelf->_controller->GetOutputLevel()));
        return [SSignal single:@(level)];
    }] then:[[SSignal complete] delay:0.1 onQueue:[SQueue mainQueue]]] restart];
}

- (int64_t)peerId
{
    return _peer.uid;
}

#pragma mark - Debug

- (void)setDebugBitrate:(NSInteger)bitrate
{
    if (_controller == nil)
        return;
    
    _controller->DebugCtl(1, (int)bitrate);
}

- (void)setDebugPacketLoss:(NSInteger)packetLossPercent
{
    if (_controller == nil)
        return;
    
    _controller->DebugCtl(2, (int)packetLossPercent);
}

- (void)setDebugP2PEnabled:(bool)enabled
{
    if (_controller == nil)
        return;
    
    _controller->DebugCtl(3, enabled);
}

@end


@implementation TGCallSessionState

- (instancetype)initWithOutgoing:(bool)outgoing callStateData:(TGCallStateData *)stateData transmissionState:(TGCallTransmissionState)transmissionState peer:(TGUser *)peer keySha1:(NSData *)keySha1 keySha256:(NSData *)keySha256 startTime:(CFAbsoluteTime)startTime mute:(bool)mute speaker:(bool)speaker
{
    self = [super init];
    if (self != nil)
    {
        _outgoing = outgoing;
        _state = stateData.state;
        _transmissionState = transmissionState;
        _peer = peer;
        _keySha1 = keySha1;
        _keySha256 = keySha256;
        _startTime = startTime;
        _mute = mute;
        _speaker = speaker;
    }
    return self;
}

@end


@implementation TGCallAudioToggles

- (instancetype)initWithMuted:(bool)muted speaker:(bool)speaker
{
    self = [super init];
    if (self != nil)
    {
        _muted = muted;
        _speaker = speaker;
    }
    return self;
}

@end
