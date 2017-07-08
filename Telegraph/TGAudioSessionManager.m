#import "TGAudioSessionManager.h"

#import <pthread.h>

#import "TGTelegraph.h"

@interface TGAudioSessionManager ()
{
    pthread_mutex_t _mutex;
    int32_t _clientId;
    
    TGAudioSessionType _currentType;
    bool _currentActive;
    NSMutableArray *_currentClientIds;
    NSMutableArray *_currentInterruptedArray;
    
    bool _isInterrupting;
}

@end

@implementation TGAudioSessionManager

+ (TGAudioSessionManager *)instance
{
    static TGAudioSessionManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        singleton = [[TGAudioSessionManager alloc] init];
    });
    
    return singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        pthread_mutex_init(&_mutex, NULL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
}

- (NSString *)nativeCategoryForType:(TGAudioSessionType)type
{
    switch (type)
    {
        case TGAudioSessionTypePlayVoice:
        case TGAudioSessionTypePlayMusic:
        case TGAudioSessionTypePlayVideo:
        case TGAudioSessionTypePlayEmbedVideo:
            return AVAudioSessionCategoryPlayback;
        case TGAudioSessionTypePlayAndRecord:
        case TGAudioSessionTypePlayAndRecordHeadphones:
        case TGAudioSessionTypeCall:
            return AVAudioSessionCategoryPlayAndRecord;
    }
}

- (id<SDisposable>)requestSessionWithType:(TGAudioSessionType)type interrupted:(void (^)())interrupted
{
    NSArray *interruptedToInvoke = nil;
    id<SDisposable> result = nil;
    
    if (type == TGAudioSessionTypePlayVideo) {
        [TGTelegraphInstance.musicPlayer controlPause];
    }
    
    pthread_mutex_lock(&_mutex);
    {
        if (_currentType != TGAudioSessionTypeCall)
        {
            if (_isInterrupting)
            {
                if (interrupted)
                    interruptedToInvoke = @[[interrupted copy]];
            }
            else
            {
                if (_currentInterruptedArray == nil)
                    _currentInterruptedArray = [[NSMutableArray alloc] init];
                if (_currentClientIds == nil)
                    _currentClientIds = [[NSMutableArray alloc] init];
                
                int32_t clientId = _clientId++;
                
                if (!_currentActive || _currentType != type)
                {
                    _currentActive = true;
                    _currentType = type;
                    
                    interruptedToInvoke = [[NSArray alloc] initWithArray:_currentInterruptedArray];
                    [_currentInterruptedArray removeAllObjects];
                    [_currentClientIds removeAllObjects];
                    
                    NSError *error = nil;
                    
                    TGLog(@"(TGAudioSessionManager setting category %d active overriding port: %d)", (int)type, ((type == TGAudioSessionTypePlayAndRecordHeadphones || type == TGAudioSessionTypePlayMusic || type == TGAudioSessionTypePlayVideo || type == TGAudioSessionTypePlayEmbedVideo)) ? 1 : 0);
                    [[AVAudioSession sharedInstance] setCategory:[self nativeCategoryForType:type] withOptions:(type == TGAudioSessionTypePlayAndRecord || type == TGAudioSessionTypePlayAndRecordHeadphones || type == TGAudioSessionTypeCall) ? AVAudioSessionCategoryOptionAllowBluetooth : 0 error:&error];
                    if (error != nil)
                        TGLog(@"(TGAudioSessionManager setting category %d error %@)", (int)type, error);
                    [[AVAudioSession sharedInstance] setMode:(type == TGAudioSessionTypeCall) ? AVAudioSessionModeVoiceChat : AVAudioSessionModeDefault error:&error];
                    if (error != nil)
                        TGLog(@"(TGAudioSessionManager setting mode error %@)", error);
                    [[AVAudioSession sharedInstance] setActive:true error:&error];
                    if (error != nil)
                        TGLog(@"(TGAudioSessionManager setting active error %@)", error);
                    //if ((type == TGAudioSessionTypePlayAndRecordHeadphones || type == TGAudioSessionTypePlayMusic || type == TGAudioSessionTypePlayVideo)) {
                    [[AVAudioSession sharedInstance] overrideOutputAudioPort:(type == TGAudioSessionTypePlayAndRecordHeadphones || type == TGAudioSessionTypePlayMusic || type == TGAudioSessionTypePlayVideo || type == TGAudioSessionTypePlayEmbedVideo || type == TGAudioSessionTypeCall) ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker error:&error];
                    //}
                    if (error != nil)
                        TGLog(@"(TGAudioSessionManager override port error %@)", error);
                }
                
                if (interrupted)
                    [_currentInterruptedArray addObject:[interrupted copy]];
                else
                    [_currentInterruptedArray addObject:[^{} copy]];
                [_currentClientIds addObject:@(clientId)];
                
                __weak TGAudioSessionManager *weakSelf = self;
                result = [[SBlockDisposable alloc] initWithBlock:^
                {
                    __strong TGAudioSessionManager *strongSelf = weakSelf;
                    if (strongSelf != nil)
                        [strongSelf endSessionForClientId:clientId];
                }];
            }
        }
    }
    pthread_mutex_unlock(&_mutex);
    
    for (void (^f)() in interruptedToInvoke)
    {
        f();
    }
    
    return result;
}

- (void)cancelCurrentSession
{
    [self cancelCurrentSession:false];
}

- (void)cancelCurrentSession:(bool)interrupted
{
    if (interrupted)
    {
        bool ignore = false;
        pthread_mutex_lock(&_mutex);
        {
            if (_currentType == TGAudioSessionTypeCall || _currentType == TGAudioSessionTypePlayEmbedVideo)
                ignore = true;
        }
        pthread_mutex_unlock(&_mutex);
        if (ignore)
            return;
    }
    
    NSArray *interruptedToInvoke = nil;

    pthread_mutex_lock(&_mutex);
    {
        _isInterrupting = true;
        interruptedToInvoke = [[NSArray alloc] initWithArray:_currentInterruptedArray];
    }
    pthread_mutex_unlock(&_mutex);
    
    for (void (^f)() in interruptedToInvoke)
    {
        f();
    }
    
    pthread_mutex_lock(&_mutex);
    {
        _isInterrupting = false;
        
        [_currentClientIds removeAllObjects];
        [_currentInterruptedArray removeAllObjects];
        
        _currentActive = false;
        _currentType = TGAudioSessionTypePlayMusic;
        
        TGLog(@"(TGAudioSessionManager setting inactive)");
        NSError *error = nil;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        if (error != nil)
            TGLog(@"(TGAudioSessionManager override port error %@)", error);
        [[AVAudioSession sharedInstance] setCategory:[self nativeCategoryForType:_currentType] error:&error];
        if (error != nil)
            TGLog(@"(TGAudioSessionManager setting category error %@)", error);
        [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:&error];
        if (error != nil)
            TGLog(@"(TGAudioSessionManager setting mode error %@)", error);
        [[AVAudioSession sharedInstance] setActive:false withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
        if (error != nil)
            TGLog(@"(TGAudioSessionManager setting inactive error %@)", error);
    }
    pthread_mutex_unlock(&_mutex);
}

- (void)endSessionForClientId:(int32_t)clientId
{
    pthread_mutex_lock(&_mutex);
    {
        for (NSUInteger i = 0; i < _currentClientIds.count; i++)
        {
            if ([_currentClientIds[i] intValue] == clientId)
            {
                [_currentInterruptedArray removeObjectAtIndex:i];
                [_currentClientIds removeObjectAtIndex:i];
                
                break;
            }
        }
        
        if (_currentActive && _currentClientIds.count == 0)
        {
            _currentActive = false;
            _currentType = TGAudioSessionTypePlayMusic;
            
            TGLog(@"(TGAudioSessionManager setting inactive)");
            NSError *error = nil;
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
            if (error != nil)
                TGLog(@"(TGAudioSessionManager override port error %@)", error);
            [[AVAudioSession sharedInstance] setCategory:[self nativeCategoryForType:_currentType] error:&error];
            if (error != nil)
                TGLog(@"(TGAudioSessionManager setting category error %@)", error);
            [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:&error];
            if (error != nil)
                TGLog(@"(TGAudioSessionManager setting mode error %@)", error);
            [[AVAudioSession sharedInstance] setActive:false withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
            if (error != nil)
                TGLog(@"(TGAudioSessionManager setting inactive error %@)", error);
        }
    }
    pthread_mutex_unlock(&_mutex);
}

+ (SSignal *)routeChange
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:AVAudioSessionRouteChangeNotification object:nil queue:nil usingBlock:^(NSNotification *notification)
        {
            if ([notification.userInfo[AVAudioSessionRouteChangeReasonKey] intValue] == AVAudioSessionRouteChangeReasonOldDeviceUnavailable)
            {
                [subscriber putNext:@(TGAudioSessionRouteChangePause)];
            }
            else if ([notification.userInfo[AVAudioSessionRouteChangeReasonKey] intValue] == AVAudioSessionRouteChangeReasonNewDeviceAvailable)
            {
                [subscriber putNext:@(TGAudioSessionRouteChangeResume)];
            }
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    }];
}

- (void)audioSessionInterruption:(NSNotification *)notification
{
    NSNumber *interruptionType = (NSNumber *)notification.userInfo[AVAudioSessionInterruptionTypeKey];
    if ([interruptionType intValue] == AVAudioSessionInterruptionTypeBegan)
        [self cancelCurrentSession:true];
}

- (void)applyRoute:(TGAudioRoute *)route
{
    NSError *error;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([route.uid isEqualToString:@"builtin"])
    {
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:NULL];
        NSArray *inputs = [[AVAudioSession sharedInstance] availableInputs];
        for (AVAudioSessionPortDescription *input in inputs)
        {
            if ([input.portType isEqualToString:AVAudioSessionPortBuiltInMic])
            {
                [session setPreferredInput:input error:&error];
                return;
            }
        }
    }
    else if ([route.uid isEqualToString:@"speaker"])
    {
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
    }
    else
    {
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:NULL];
        NSArray *inputs = [[AVAudioSession sharedInstance] availableInputs];
        for (AVAudioSessionPortDescription *input in inputs)
        {
            if ([input.UID isEqualToString:route.uid])
            {
                [session setPreferredInput:input error:&error];
                return;
            }
        }
    }
}

@end


@interface TGAudioRoute ()
{
    bool _isBluetooth;
}
@end

@implementation TGAudioRoute

+ (instancetype)routeForBuiltIn:(bool)headphones
{
    NSString *deviceModel = [UIDevice currentDevice].model;
    TGAudioRoute *route = [[TGAudioRoute alloc] init];
    route->_name = headphones ? TGLocalized(@"Call.AudioRouteHeadphones") : deviceModel;
    route->_uid = @"builtin";
    route->_isBuiltIn = true;
    route->_isHeadphones = headphones;
    return route;
}

+ (instancetype)routeForSpeaker
{
    NSString *deviceModel = [UIDevice currentDevice].model;
    if (![deviceModel isEqualToString:@"iPhone"])
        return nil;
    
    TGAudioRoute *route = [[TGAudioRoute alloc] init];
    route->_name = TGLocalized(@"Call.AudioRouteSpeaker");
    route->_uid = @"speaker";
    route->_isLoudspeaker = true;
    return route;
}

+ (instancetype)routeWithDescription:(AVAudioSessionPortDescription *)description
{
    TGAudioRoute *route = [[TGAudioRoute alloc] init];
    route->_name = description.portName;
    route->_uid = description.UID;
    route->_isBluetooth = [[self bluetoothTypes] containsObject:description.portType];
    return route;
}

+ (NSArray *)bluetoothTypes
{
    static dispatch_once_t onceToken;
    static NSArray *bluetoothTypes;
    dispatch_once(&onceToken, ^
    {
        bluetoothTypes = @[AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP];
    });
    return bluetoothTypes;
}

@end
