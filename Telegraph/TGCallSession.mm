#import "TGCallSession.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MTProtoKit/MTEncryption.h>
#import <MTProtoKit/MTNetworkUsageManager.h>

#import "TGAppDelegate.h"
#import "TGTelegramNetworking.h"
#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGUser.h"
#import "TGAudioSessionManager.h"

#import "TGCallUtils.h"
#import "TGImageUtils.h"
#import "TGObserverProxy.h"

#import "TGCallSignals.h"
#import "TGCallAudioPlayer.h"
#import "TGCallKitAdapter.h"

#import "VoIPController.h"
#import "VoIPServerConfig.h"

typedef enum
{
    TGCallToneUndefined,
    TGCallToneRingback,
    TGCallToneBusy,
    TGCallToneConnecting,
    TGCallToneFailed,
    TGCallToneEnded
} TGCallTone;

@interface VoIPControllerHolder : NSObject {
    CVoIPController *_controller;
}

@property (nonatomic, assign, readonly) CVoIPController *controller;

@end

@implementation VoIPControllerHolder

- (instancetype)initWithController:(CVoIPController *)controller {
    self = [super init];
    if (self != nil) {
        _controller = controller;
    }
    return self;
}

- (CVoIPController *)controller {
    return _controller;
}

@end

const NSTimeInterval TGCallReceiveTimeout = 20;
const NSTimeInterval TGCallRingTimeout = 90;
const NSTimeInterval TGCallConnectTimeout = 30;
const NSTimeInterval TGCallPacketTimeout = 10;

@interface TGCallAudioContext : NSObject

@property (nonatomic, readonly) NSArray<TGAudioRoute *> *availableRoutes;
@property (nonatomic, readonly) TGAudioRoute *activeRoute;
@property (nonatomic, readonly) bool speaker;

- (instancetype)initWithAvailableRoutes:(NSArray<TGAudioRoute *> *)availableRoutes activeRoute:(TGAudioRoute *)activeRoute speaker:(bool)speaker;

@end


@interface TGCallSessionData : NSObject

@property (nonatomic, readonly) TGCallStateData *stateData;
@property (nonatomic, readonly) TGCallAudioContext *audioContext;

- (instancetype)initWithStateData:(TGCallStateData *)stateData audioContext:(TGCallAudioContext *)audioContext;

@end


@interface TGCallSession ()
{
    SMetaDisposable *_networkDisposable;
    SMetaDisposable *_disposable;
    SMetaDisposable *_timeoutDisposable;

    SVariable *_state;
    SPipe *_statePipe;
    TGCallState _currentState;

    SVariable *_transmissionState;
    SPipe *_transmissionPipe;

    SPipe *_audioTogglesPipe;
    SPipe *_audioContextPipe;

    bool _started;
    bool _discarded;
    NSNumber *_internalId;
    SAtomic *_controller;

    TGUser *_peer;

    CFAbsoluteTime _startTime;
    NSTimeInterval _callAcceptedTime;

    NSData *_keySha1;
    NSData *_keySha256;

    bool _playingRingtone;
    TGCallAudioPlayer *_audioPlayer;
    SMetaDisposable *_vibrateDisposable;

    bool _muted;
    bool _speaker;
    NSNumber *_targetSpeaker;
    NSNumber *_delayedSpeaker;

    TGObserverProxy *_applicationWillResignActiveProxy;
    TGObserverProxy *_applicationDidBecomeActiveProxy;

    UILocalNotification *_notification;
}

@property (nonatomic, copy) void (^hangUpCompletion)(void);

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

        _audioTogglesPipe = [[SPipe alloc] init];
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
    [_vibrateDisposable dispose];
}

- (void)markCallAcceptedTime
{
    _callAcceptedTime = CFAbsoluteTimeGetCurrent();
}

- (NSTimeInterval)callConnectionDuration
{
    if (_callAcceptedTime > DBL_EPSILON && _startTime > DBL_EPSILON)
        return _startTime - _callAcceptedTime;

    return 0.0;
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
    _controller = [[SAtomic alloc] initWithValue:nil recursive:true];
    [_controller modify:^id(VoIPControllerHolder *current) {
        assert(current == nil);

        CVoIPController *controller = new CVoIPController();
        controller->implData = (__bridge void *)self;
        controller->SetStateCallback(&controllerStateCallback);

        CVoIPController::crypto.sha1 = &TGCallSha1;
        CVoIPController::crypto.sha256 = &TGCallSha256;
        CVoIPController::crypto.rand_bytes = &TGCallRandomBytes;
        CVoIPController::crypto.aes_ige_encrypt = &TGCallAesIgeEncryptInplace;
        CVoIPController::crypto.aes_ige_decrypt = &TGCallAesIgeDecryptInplace;

        return [[VoIPControllerHolder alloc] initWithController:controller];
    }];
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
        [self stopAudio];
        _startTime = CFAbsoluteTimeGetCurrent();

        if (self.onConnected != nil)
            self.onConnected();
    }

    _transmissionPipe.sink(@(tranmissionState));

    if (tranmissionState == TGCallTransmissionStateFailed)
    {
        [self playTone:TGCallToneFailed];
        [self _discardCurrentCallWithReason:TGCallDiscardReasonDisconnect];
    }
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

    _started = true;

    void (^block)(void) = ^
    {
        [self playTone:TGCallToneConnecting];

        SSignal *readySignal = [SSignal single:@true];
        if ([TGCallKitAdapter callKitAvailable] && !_outgoing && _audioSessionActivated != nil)
            readySignal = _audioSessionActivated.signal;

        [[[[readySignal filter:^bool(NSNumber *value) {
            return value;
        }] timeout:1.5 onQueue:[SQueue mainQueue] orSignal:[SSignal single:@true]] take:1] startWithNext:^(__unused id next)
        {
            [self startNetworkTypeMonitoring];

            [_controller with:^id(VoIPControllerHolder *controller) {
                size_t endpointsCount = 1 + state.connection.alternativeConnections.count;
                voip_endpoint_t endpoints[endpointsCount];

                NSArray *connections = [@[state.connection.defaultConnection] arrayByAddingObjectsFromArray:state.connection.alternativeConnections];
                for (NSUInteger i = 0; i < connections.count; i++)
                {
                    [self setupVoipEndpoint:&endpoints[i] withConnection:connections[i]];
                }

                voip_config_t config;
                config.init_timeout = [TGCallSession callConnectTimeout];
                config.recv_timeout = [TGCallSession callPacketTimeout];
                config.data_saving = TGAppDelegateInstance.callsDataUsageMode;
				memset(config.logFilePath, 0, sizeof(config.logFilePath));
                config.enableAEC = false;
                config.enableNS = true;
                config.enableAGC = true;

                controller.controller->SetConfig(&config);

                controller.controller->SetEncryptionKey((char *)state.connection.key.bytes, _outgoing);
                controller.controller->SetRemoteEndpoints(endpoints, endpointsCount, true);
                controller.controller->Start();

                controller.controller->Connect();

                return nil;
            }];

            if (self.onStartedConnecting != nil)
                self.onStartedConnecting();
        }];
    };

    if ([TGCallKitAdapter callKitAvailable])
        block();
    else
        [self setupAudioSession:block];
}

- (void)stopTransmission:(bool)sendDebugLog
{
    if (_controller == nil)
        return;

    [_controller modify:^id(VoIPControllerHolder *controller) {
        NSString *debugLog = nil;
        char buffer[controller.controller->GetDebugLogLength()];
        controller.controller->GetDebugLog(buffer);
        debugLog = [[NSString alloc] initWithUTF8String:buffer];

        voip_stats_t stats;
        controller.controller->GetStats(&stats);
        delete controller.controller;

        MTNetworkUsageManager *usageManager = [[MTNetworkUsageManager alloc] initWithInfo:[[TGTelegramNetworking instance] mediaUsageInfoForType:TGNetworkMediaTypeTagCall]];
        [usageManager addIncomingBytes:stats.bytesRecvdMobile interface:MTNetworkUsageManagerInterfaceWWAN];
        [usageManager addIncomingBytes:stats.bytesRecvdWifi interface:MTNetworkUsageManagerInterfaceOther];

        [usageManager addOutgoingBytes:stats.bytesSentMobile interface:MTNetworkUsageManagerInterfaceWWAN];
        [usageManager addOutgoingBytes:stats.bytesSentWifi interface:MTNetworkUsageManagerInterfaceOther];

        if (sendDebugLog && self.peerId != 0 && self.accessHash != 0)
            [[TGCallSignals saveCallDebug:self.peerId accessHash:self.accessHash data:debugLog] startWithNext:nil];

        return nil;
    }];
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
        if (strongSelf != nil && strongSelf->_controller != nil) {
            [strongSelf->_controller with:^id(VoIPControllerHolder *controller) {
                controller.controller->SetNetworkType(next.intValue);
                return nil;
            }];
        }
    }]];
}

#pragma mark - Actions

- (void)acceptIncomingCall
{
    if (_internalId != nil)
    {
        [self markCallAcceptedTime];
        [self _setCallSignal:[TGTelegraphInstance.callManager acceptCallWithInternalId:_internalId]];
    }
}

- (void)hangUpCurrentCallCompletion:(void (^)())completion
{
    self.hangUpCompletion = completion;
    [self hangUpCurrentCall:false];
}

- (void)hangUpCurrentCall
{
    [self hangUpCurrentCall:false];
}

- (void)hangUpCurrentCall:(bool)external
{
    _completed = external;
    [[[_state.signal take:1] timeout:0.5 onQueue:[SQueue mainQueue] orSignal:[SSignal single:nil]] startWithNext:^(TGCallStateData *next)
    {
        TGCallDiscardReason reason = TGCallDiscardReasonHangup;
        if (next.state != TGCallStateOngoing)
            reason = _outgoing ? TGCallDiscardReasonMissed : TGCallDiscardReasonBusy;

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

+ (NSTimeInterval)callReceiveTimeout
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

+ (NSTimeInterval)callRingTimeout
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

+ (NSTimeInterval)callConnectTimeout
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

+ (NSTimeInterval)callPacketTimeout
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

+ (void)applyCallsConfig:(NSString *)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if (dict != nil) {
        std::vector<std::string> result;
        //std::map<std::string, std::string> *pResult = &result;
        char **values = (char **)malloc(sizeof(char *) * (int)dict.count * 2);
        memset(values, 0, (int)dict.count * 2);
        __block int index = 0;
        [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, __unused BOOL *stop) {
            NSString *valueText = [NSString stringWithFormat:@"%@", value];
            const char *keyText = [key UTF8String];
            const char *valueTextValue = [valueText UTF8String];
            values[index] = (char *)malloc(strlen(keyText) + 1);
            values[index][strlen(keyText)] = 0;
            memcpy(values[index], keyText, strlen(keyText));
            values[index + 1] = (char *)malloc(strlen(valueTextValue) + 1);
            values[index + 1][strlen(valueTextValue)] = 0;
            memcpy(values[index + 1], valueTextValue, strlen(valueTextValue));
            index += 2;

            //(*pResult)[std::string(key.UTF8String)] = std::string(valueText.UTF8String);
        }];
        CVoIPServerConfig::GetSharedInstance()->Update((const char **)values, index);
        for (int i = 0; i < (int)dict.count * 2; i++) {
            free(values[i]);
        }
        free(values);
    }
}

#pragma mark - Notifications

- (bool)_isInBackground
{
    UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
    if ([UIApplication sharedApplication] == nil)
        applicationState = UIApplicationStateBackground;

    return applicationState != UIApplicationStateActive;
}

- (void)presentCallNotification:(int64_t)peerId
{
    UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
    if ([UIApplication sharedApplication] == nil)
        applicationState = UIApplicationStateBackground;

    if ([self _isInBackground])
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];

        TGUser *peer = [TGDatabaseInstance() loadUser:(int)peerId];
        NSString *text = [NSString stringWithFormat:TGLocalized(@"PHONE_CALL_REQUEST"), peer.displayName];

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
            notification.soundName = [[NSString alloc] initWithFormat:@"%d.m4a", soundId];

#ifdef INTERNAL_RELEASE
        text = [@"[L] " stringByAppendingString:text];
#endif
        notification.alertBody = text;
        notification.userInfo = @{@"cid": @(_peer.uid)};

        if (text != nil)
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];

        _notification = notification;
    }
}

- (void)cancelLocalNotification
{
    if (_notification == nil)
        return;

    [[UIApplication sharedApplication] cancelLocalNotification:_notification];
    _notification = nil;
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

static id<SDisposable> audioSession;

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
    [TGCallSession setupAudioSession:nil];
}

- (void)setupAudioSession:(void (^)(void))completion
{
    [TGCallSession setupAudioSession:completion];
}

- (void)resetAudioSession
{
    [TGCallSession resetAudioSession];
}

- (void)resetAudioSessionIfNeeded
{
    if (![TGCallKitAdapter callKitAvailable])
        [self resetAudioSession];
}

+ (void)setupAudioSession:(void (^)(void))completion
{
    [[self audioQueue] dispatch:^
    {
        if (audioSession != nil)
        {
            TGDispatchOnMainThread(^
            {
                if (completion != nil)
                    completion();
            });
            return;
        }

        audioSession = [[TGAudioSessionManager instance] requestSessionWithType:TGAudioSessionTypeCall interrupted:^{}];

        AVAudioSession *session = [AVAudioSession sharedInstance];
		[session setPreferredIOBufferDuration:0.005 error:NULL];

        [self _updatePolarPattern:false];

        TGDispatchOnMainThread(^
        {
            if (completion != nil)
                completion();
        });
    }];
}

+ (void)resetAudioSession
{
    [[self audioQueue] dispatch:^
    {
        if (audioSession == nil)
            return;

        [audioSession dispose];
        audioSession = nil;
    } synchronous:true];
}

+ (bool)hasMicrophoneAccess
{
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusAuthorized;
}

- (void)toggleMute
{
    [self setMuted:!_muted];
}

- (void)setMuted:(bool)muted
{
    _muted = muted;
    if (_controller != nil) {
        [_controller with:^id(VoIPControllerHolder *controller) {
            controller.controller->SetMicMute(_muted);
            return nil;
        }];
    }

    [self _updateAudioToggles];
}

- (void)toggleSpeaker
{
    bool newValue = !_speaker;
    _targetSpeaker = @(newValue);
    _delayedSpeaker = _targetSpeaker;

    [[TGCallSession audioQueue] dispatch:^
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        AVAudioSessionPortOverride value = newValue ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
        NSError *error;
        BOOL success = [session overrideOutputAudioPort:value error:&error];
        if (!success)
            TGLog(@"CallSession: failed to override output audio port: %@", error.localizedDescription);

        [TGCallSession _updatePolarPattern:newValue];
        
        TGDispatchOnMainThread(^
        {
            _targetSpeaker = nil;
        });
    }];

    [self _updateAudioToggles];
}

+ (void)_updatePolarPattern:(bool)__unused speaker
{
//    if (false && iosMajorVersion() >= 7)
//    {
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        AVAudioSessionDataSourceDescription *src = session.inputDataSource;
//        if ([src.orientation isEqualToString:AVAudioSessionOrientationFront])
//        {
//            NSString *polarPattern = speaker ? AVAudioSessionPolarPatternOmnidirectional : AVAudioSessionPolarPatternCardioid;
//            if ([src.supportedPolarPatterns containsObject:polarPattern])
//                [src setPreferredPolarPattern:polarPattern error:NULL];
//        }
//    }
}

- (void)applyAudioRoute:(TGAudioRoute *)audioRoute
{
    [[TGCallSession audioQueue] dispatch:^
    {
        [[TGAudioSessionManager instance] applyRoute:audioRoute];
        if (!audioRoute.isLoudspeaker)
            _speaker = audioRoute.isLoudspeaker;
        [self _updateAudioToggles];
    }];
}

- (void)_updateAudioToggles
{
    _audioTogglesPipe.sink(@true);
}

- (void)_startRingtonePlayer
{
    _audioPlayer = [TGCallAudioPlayer playFileURL:[NSURL URLWithString:@"/Library/Ringtones/Opening.m4r"] loops:-1 completion:nil];

    _vibrateDisposable = [[SMetaDisposable alloc] init];
    [_vibrateDisposable setDisposable:[[[[SSignal single:nil] then:[[SSignal complete] delay:1.6 onQueue:[SQueue mainQueue]]] restart] startWithNext:^(__unused id next)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }]];
}

- (void)playRingtone
{
    if ([TGCallKitAdapter callKitAvailable] || _audioPlayer != nil)
        return;

    _playingRingtone = true;
    if (![self _isInBackground])
        [self _startRingtonePlayer];
}

- (void)playTone:(TGCallTone)tone
{
    [self playTone:tone completion:nil];
}

- (void)playTone:(TGCallTone)tone completion:(void (^)(void))completion
{
    [self _playTone:[self _pathForTone:tone] loops:[self _loopsForTone:tone] completion:completion];
}

- (NSString *)_pathForTone:(TGCallTone)tone
{
    switch (tone)
    {
        case TGCallToneBusy:
            return [[NSBundle mainBundle] pathForResource:@"voip_busy" ofType:@"caf"];

        case TGCallToneRingback:
            return [[NSBundle mainBundle] pathForResource:@"voip_ringback" ofType:@"caf"];

        case TGCallToneConnecting:
            return [[NSBundle mainBundle] pathForResource:@"voip_connecting" ofType:@"mp3"];

        case TGCallToneFailed:
            return [[NSBundle mainBundle] pathForResource:@"voip_fail" ofType:@"caf"];

        case TGCallToneEnded:
            return [[NSBundle mainBundle] pathForResource:@"voip_end" ofType:@"caf"];

        default:
            return nil;
    }
}

- (NSInteger)_loopsForTone:(TGCallTone)tone
{
    switch (tone)
    {
        case TGCallToneBusy:
            return 3;

        case TGCallToneRingback:
            return -1;

        case TGCallToneConnecting:
            return -1;

        case TGCallToneFailed:
            return 1;

        case TGCallToneEnded:
            return 1;

        default:
            return 0;
    }
}

- (void)_playTone:(NSString *)path loops:(NSInteger)loops completion:(void (^)(void))completion
{
    if (_audioPlayer != nil || path == nil)
        return;

    [self setupAudioSession];

    _audioPlayer = [TGCallAudioPlayer playFileURL:[NSURL URLWithString:path] loops:loops completion:completion];
}

- (void)stopAudio
{
    _playingRingtone = false;

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

    if (_accessHash == 0 && state.accessHash != 0)
        _accessHash = state.accessHash;

    if (_keySha256 == nil && state.connection.keyHash != nil)
        _keySha256 = state.connection.keyHash;

    TGCallState previousState = _currentState;
    _currentState = state.state;

    switch (state.state)
    {
        case TGCallStateWaiting:
        {
            [self startTimeout:[TGCallSession callReceiveTimeout] discardReason:TGCallDiscardReasonMissedTimeout];
        }
            break;

        case TGCallStateWaitingReceived:
            [self startTimeout:[TGCallSession callRingTimeout] discardReason:TGCallDiscardReasonMissedTimeout];
            [self playTone:TGCallToneRingback];
            break;

        case TGCallStateHandshake:
        {
            [self playRingtone];
        }
            break;

        case TGCallStateReady:
        {
            [self playRingtone];
        }
            break;

        case TGCallStateAccepting:
        {
            [self stopAudio];
        }
            break;

        case TGCallStateOngoing:
        {
            [self invalidateTimeout];
            [self stopAudio];
            [self startTransmissionIfNeeded:state];
        }
            break;

        case TGCallStateEnded:
        case TGCallStateEnding:
        case TGCallStateBusy:
        case TGCallStateMissed:
        {
            if (!_hungUpOutside)
                _hungUpOutside = state.hungUpOutside;

            [self invalidateTimeout];
            [self stopAudio];
            [self stopTransmission:state.needsDebug];

            [self cancelLocalNotification];
            
            void (^completeHangup)(void) = ^
            {
                if (self.hangUpCompletion == nil || state.state != TGCallStateEnded)
                    return;
                
                SSignal *readySignal = [SSignal single:@true];
                if ([TGCallKitAdapter callKitAvailable])
                    readySignal = _audioSessionDeactivated.signal;
                
                [[[[readySignal filter:^bool(NSNumber *value) {
                    return value;
                }] timeout:1.5 onQueue:[SQueue mainQueue] orSignal:[SSignal single:@true]] take:1] startWithNext:^(__unused id next)
                {
                    void (^completion)(void) = [self.hangUpCompletion copy];
                    self.hangUpCompletion = nil;
                    completion();
                }];
            };

            if (_outgoing && state.state == TGCallStateBusy)
            {
                [self playTone:TGCallToneBusy];
                TGDispatchAfter(2.0, dispatch_get_main_queue(), ^
                {
                    [self resetAudioSessionIfNeeded];
                });
            }
            else
            {
                TGCallTone tone = TGCallToneEnded;
                if (state.error != nil)
                    tone = TGCallToneFailed;

                if (!_outgoing && (previousState == TGCallStateHandshake || previousState == TGCallStateReady || previousState == TGCallStateMissed || previousState == TGCallStateEnding))
                    tone = TGCallToneUndefined;

                if (state.state == TGCallStateEnded || state.state == TGCallStateEnding)
                {
                    [self playTone:tone];
                    TGDispatchAfter(2.0, dispatch_get_main_queue(), ^
                    {
                        [self resetAudioSessionIfNeeded];
                    });
                }
                else
                {
                    [self resetAudioSessionIfNeeded];
                }
                
                completeHangup();
            }
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

    SSignal *combinedSignal = [SSignal combineSignals:@[_state.signal, [self audioContextSignal], _transmissionState.signal, _audioTogglesPipe.signalProducer()] withInitialStates:@[ [NSNull null], [NSNull null], @0, @0 ]];

    return [[combinedSignal deliverOn:[SQueue mainQueue]] map:^id(NSArray *values)
    {
        __strong TGCallSession *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;

        TGCallStateData *stateData = [values[0] isKindOfClass:[NSNull class]] ? nil : (TGCallStateData *)values[0];
        TGCallAudioContext *audioContext = [values[1] isKindOfClass:[NSNull class]] ? nil : (TGCallAudioContext *)values[1];
        TGCallTransmissionState transmissionState = (TGCallTransmissionState)[values[2] integerValue];
        
        bool muted = strongSelf->_muted;
        bool speaker = strongSelf->_targetSpeaker ? strongSelf->_targetSpeaker.boolValue : audioContext.speaker;
        
        return [[TGCallSessionState alloc] initWithOutgoing:strongSelf->_outgoing callStateData:stateData transmissionState:transmissionState peer:strongSelf->_peer keySha256:strongSelf->_keySha256 startTime:strongSelf->_startTime mute:muted speaker:speaker audioRoutes:audioContext.availableRoutes activeAudioRoute:audioContext.activeRoute];
    }];
}

- (SSignal *)audioContextSignal
{
    __weak TGCallSession *weakSelf = self;
    return [[[SSignal combineSignals:@[_state.signal, _transmissionState.signal, [TGAudioSessionManager routeChange], _audioTogglesPipe.signalProducer(), [[[SSignal single:@true] delay:1.0 onQueue:[SQueue concurrentDefaultQueue]] restart]] withInitialStates:@[ [NSNull null], @0, @0, @0, @0 ]] deliverOn:[SQueue concurrentDefaultQueue]] map:^id(__unused NSArray *values)
    {
        __strong TGCallSession *strongSelf = weakSelf;
        
        TGCallStateData *stateData = [values[0] isKindOfClass:[NSNull class]] ? nil : (TGCallStateData *)values[0];
        TGCallState currentState = stateData.state;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSArray *inputs = audioSession.availableInputs;
        NSArray *outputs = audioSession.currentRoute.outputs;
        
        NSMutableArray *audioRoutes = [[NSMutableArray alloc] init];
        TGAudioRoute *activeRoute = nil;
        bool hasHeadphones = false;
        bool speaker = strongSelf->_speaker;
        if (strongSelf->_targetSpeaker != nil)
        {
            speaker = strongSelf->_targetSpeaker.boolValue;
        }
        else if (currentState == TGCallStateWaitingReceived || currentState == TGCallStateOngoing)
        {
            strongSelf->_delayedSpeaker = nil;
            speaker = false;
            for (AVAudioSessionPortDescription *output in outputs)
            {
                if ([output.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker])
                {
                    speaker = true;
                    break;
                }
            }
        }
        else if (strongSelf->_delayedSpeaker != nil)
        {
            speaker = strongSelf->_delayedSpeaker.boolValue;
        }
        
        for (AVAudioSessionPortDescription *input in inputs)
        {
            if ([input.portType isEqualToString:AVAudioSessionPortBuiltInMic])
                continue;
            
            if ([input.portType isEqualToString:AVAudioSessionPortHeadsetMic])
            {
                hasHeadphones = true;
                continue;
            }
            
            TGAudioRoute *route = [TGAudioRoute routeWithDescription:input];
            [audioRoutes addObject:route];
            
            for (AVAudioSessionPortDescription *currentInput in audioSession.currentRoute.inputs)
            {
                if ([currentInput.UID isEqualToString:input.UID])
                    activeRoute = route;
            }
        }
        
        TGAudioRoute *builtInRoute = [TGAudioRoute routeForBuiltIn:hasHeadphones];
        [audioRoutes addObject:builtInRoute];
        TGAudioRoute *speakerRoute = [TGAudioRoute routeForSpeaker];
        if (speakerRoute != nil)
        {
            [audioRoutes addObject:speakerRoute];
            if (speaker)
                activeRoute = speakerRoute;
        }
        
        if (activeRoute == nil)
            activeRoute = builtInRoute;
        
        strongSelf->_speaker = speaker;

        return [[TGCallAudioContext alloc] initWithAvailableRoutes:audioRoutes activeRoute:activeRoute speaker:speaker];
    }];
}

- (SSignal *)debugSignal
{
    __weak TGCallSession *weakSelf = self;
    return [[[SSignal defer:^SSignal *{
        __strong TGCallSession *strongSelf = weakSelf;
        if (strongSelf == nil || strongSelf->_controller == nil)
            return [SSignal complete];

        NSArray *debugValues = [strongSelf->_controller with:^id(VoIPControllerHolder *controller) {
            NSString *versionString = [NSString stringWithUTF8String:controller.controller->GetVersion()];
            char buffer[2048];
            controller.controller->GetDebugString(buffer, 2048);
            NSString *debugString = [NSString stringWithUTF8String:buffer];
            return @[debugString, versionString];
        }];
        return [SSignal single:[NSString stringWithFormat:@"libtgvoip v%@\n%@", debugValues[1], debugValues[0]]];
    }] then:[[SSignal complete] delay:0.5 onQueue:[SQueue mainQueue]]] restart];
}

- (SSignal *)levelSignal
{
    __weak TGCallSession *weakSelf = self;
    return [[[SSignal defer:^SSignal *{
        __strong TGCallSession *strongSelf = weakSelf;
        if (strongSelf == nil || strongSelf->_controller == nil)
            return [SSignal complete];

        NSNumber *level = [strongSelf->_controller with:^id(VoIPControllerHolder *controller) {
            CGFloat value = MIN(1.0f, MAX(0.0f, controller.controller->GetOutputLevel()));
            return @(value);
        }];
        return [SSignal single:level];
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

    [_controller with:^id(VoIPControllerHolder *controller) {
        controller.controller->DebugCtl(1, (int)bitrate);
        return nil;
    }];
}

- (void)setDebugPacketLoss:(NSInteger)packetLossPercent
{
    if (_controller == nil)
        return;

    [_controller with:^id(VoIPControllerHolder *controller) {
        controller.controller->DebugCtl(2, (int)packetLossPercent);
        return nil;
    }];
}

- (void)setDebugP2PEnabled:(bool)enabled
{
    if (_controller == nil)
        return;

    [_controller with:^id(VoIPControllerHolder *controller) {
        controller.controller->DebugCtl(3, enabled);
        return nil;
    }];
}

@end


@implementation TGCallSessionState

- (instancetype)initWithOutgoing:(bool)outgoing callStateData:(TGCallStateData *)stateData transmissionState:(TGCallTransmissionState)transmissionState peer:(TGUser *)peer keySha256:(NSData *)keySha256 startTime:(CFAbsoluteTime)startTime mute:(bool)mute speaker:(bool)speaker audioRoutes:(NSArray *)audioRoutes activeAudioRoute:(TGAudioRoute *)activeAudioRoute
{
    self = [super init];
    if (self != nil)
    {
        _outgoing = outgoing;
        _stateData = stateData;
        _state = stateData.state;
        _transmissionState = transmissionState;
        _peer = peer;
        _keySha256 = keySha256;
        _startTime = startTime;
        _mute = mute;
        _speaker = speaker;
        _audioRoutes = audioRoutes;
        _activeAudioRoute = activeAudioRoute;
    }
    return self;
}

@end


@implementation TGCallAudioContext

- (instancetype)initWithAvailableRoutes:(NSArray<TGAudioRoute *> *)availableRoutes activeRoute:(TGAudioRoute *)activeRoute speaker:(bool)speaker
{
    self = [super init];
    if (self != nil)
    {
        _availableRoutes = availableRoutes;
        _activeRoute = activeRoute;
        _speaker = speaker;
    }
    return self;
}

@end


@implementation TGCallSessionData

- (instancetype)initWithStateData:(TGCallStateData *)stateData audioContext:(TGCallAudioContext *)audioContext
{
    self = [super init];
    if (self != nil)
    {
        _stateData = stateData;
        _audioContext = audioContext;
    }
    return self;
}

@end
