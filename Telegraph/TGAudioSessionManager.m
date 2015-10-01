#import "TGAudioSessionManager.h"

#import <pthread.h>
#import <AVFoundation/AVFoundation.h>

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
            return AVAudioSessionCategoryPlayback;
        case TGAudioSessionTypePlayAndRecord:
            return AVAudioSessionCategoryPlayAndRecord;
        case TGAudioSessionTypePlayAndRecordHeadphones:
            return AVAudioSessionCategoryPlayAndRecord;
    }
}

- (id<SDisposable>)requestSessionWithType:(TGAudioSessionType)type interrupted:(void (^)())interrupted
{
    NSArray *interruptedToInvoke = nil;
    id<SDisposable> result = nil;
    
    pthread_mutex_lock(&_mutex);
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
                
                TGLog(@"(TGAudioSessionManager setting category %d active)", (int)type);
                [[AVAudioSession sharedInstance] setCategory:[self nativeCategoryForType:type] error:&error];
                if (error != nil)
                    TGLog(@"(TGAudioSessionManager setting category %d error %@)", (int)type, error);
                [[AVAudioSession sharedInstance] setActive:true error:&error];
                if (error != nil)
                    TGLog(@"(TGAudioSessionManager setting active error %@)", (int)type, error);
                
                [[AVAudioSession sharedInstance] overrideOutputAudioPort:type == TGAudioSessionTypePlayAndRecordHeadphones ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker error:&error];
                //if (error != nil)
                //    TGLog(@"(TGAudioSessionManager override port error %@)", error);
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
    pthread_mutex_unlock(&_mutex);
    
    for (void (^f)() in interruptedToInvoke)
    {
        f();
    }
    
    return result;
}

- (void)cancelCurrentSession
{
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
        [[AVAudioSession sharedInstance] setActive:false error:&error];
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
            [[AVAudioSession sharedInstance] setActive:false error:&error];
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
        [self cancelCurrentSession];
}

@end
