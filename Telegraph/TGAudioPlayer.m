/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioPlayer.h"

#import <LegacyComponents/ASQueue.h>

#import "TGOpusAudioPlayerAU.h"
#import "TGNativeAudioPlayer.h"

#import <LegacyComponents/TGObserverProxy.h>
#import "TGAppDelegate.h"

#import <SSignalKit/SSignalKit.h>

#import <AVFoundation/AVFoundation.h>

#import "TGAudioSessionManager.h"

@interface TGAudioPlayer ()
{
    bool _music;
    bool _controlAudioSession;
    
    bool _proximityState;
    TGObserverProxy *_proximityChangedNotification;
    TGHolder *_proximityChangeHolder;
    
    SMetaDisposable *_currentAudioSession;
    bool _changingProximity;
    
    SMetaDisposable *_routeChangeDisposable;
}

@end

@implementation TGAudioPlayer

+ (TGAudioPlayer *)audioPlayerForPath:(NSString *)path music:(bool)music controlAudioSession:(bool)controlAudioSession
{
    if (path == nil)
        return nil;
    
    if ([TGOpusAudioPlayerAU canPlayFile:path])
        return [[TGOpusAudioPlayerAU alloc] initWithPath:path music:music controlAudioSession:controlAudioSession];
    else
        return [[TGNativeAudioPlayer alloc] initWithPath:path music:music controlAudioSession:controlAudioSession];
}

- (instancetype)init {
    return [self initWithMusic:false controlAudioSession:true];
}

- (instancetype)initWithMusic:(bool)music controlAudioSession:(bool)controlAudioSession
{
    self = [super init];
    if (self != nil)
    {
        _music = music;
        _controlAudioSession = controlAudioSession;
        
        _currentAudioSession = [[SMetaDisposable alloc] init];
        if (!_music && _controlAudioSession) {
            _proximityState = TGAppDelegateInstance.deviceProximityState;
            _proximityChangedNotification = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(proximityChanged:) name:TGDeviceProximityStateChangedNotification object:nil];
            _proximityChangeHolder = [[TGHolder alloc] init];
            [TGAppDelegateInstance.deviceProximityListeners addHolder:_proximityChangeHolder];
            
            __weak TGAudioPlayer *weakSelf = self;
            _routeChangeDisposable = [[[TGAudioSessionManager routeChange] deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *action) {
                if ([action intValue] == TGAudioSessionRouteChangePause) {
                    __strong TGAudioPlayer *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf pause:nil];
                        [strongSelf _notifyPaused];
                    }
                }
            }];
        }
    }
    return self;
}

- (void)dealloc
{
    if (!_music) {
        [TGAppDelegateInstance.deviceProximityListeners removeHolder:_proximityChangeHolder];
    }
}

- (void)play
{
    [self playFromPosition:-1.0];
}

- (void)playFromPosition:(NSTimeInterval)__unused position
{
}

- (void)pause:(void (^)())completion
{
    if (completion) {
        completion();
    }
}

- (void)stop
{
}

- (NSTimeInterval)currentPositionSync:(bool)__unused sync
{
    return 0.0;
}

- (NSTimeInterval)duration
{
    return 0.0;
}

+ (ASQueue *)_playerQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ASQueue alloc] initWithName:"org.telegram.audioPlayerQueue"];
    });
    
    return queue;
}

- (void)proximityChanged:(NSNotification *)__unused notification
{
    if (_music) {
        return;
    }
    
    bool proximityState = TGAppDelegateInstance.deviceProximityState;
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        _proximityState = proximityState;
        bool overridePort = _proximityState && ![TGAudioPlayer isHeadsetPluggedIn];
        __weak TGAudioPlayer *weakSelf = self;
        _changingProximity = true;
        [_currentAudioSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:overridePort ? TGAudioSessionTypePlayAndRecordHeadphones : TGAudioSessionTypePlayVoice interrupted:^
        {
            __strong TGAudioPlayer *strongSelf = weakSelf;
            if (strongSelf != nil && !strongSelf->_changingProximity)
            {
                [strongSelf stop];
                [strongSelf _notifyFinished];
            }
        }]];
        _changingProximity = false;
    }];
}

- (void)_beginAudioSession
{
    if (!_controlAudioSession) {
        return;
    }
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        __weak TGAudioPlayer *weakSelf = self;
        if (_music) {
            [_currentAudioSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:TGAudioSessionTypePlayMusic interrupted:^
            {
                __strong TGAudioPlayer *strongSelf = weakSelf;
                if (strongSelf != nil && !strongSelf->_changingProximity)
                {
                    [strongSelf pause:nil];
                    [strongSelf _notifyPaused];
                }
            }]];
        } else {
            bool overridePort = _proximityState && ![TGAudioPlayer isHeadsetPluggedIn];
            [_currentAudioSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:overridePort ? TGAudioSessionTypePlayAndRecordHeadphones : TGAudioSessionTypePlayVoice interrupted:^
            {
                __strong TGAudioPlayer *strongSelf = weakSelf;
                if (strongSelf != nil && !strongSelf->_changingProximity)
                {
                    [strongSelf stop];
                    [strongSelf _notifyFinished];
                }
            }]];
        }
    }];
}

- (void)_endAudioSession
{
    if (!_controlAudioSession) {
        return;
    }
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        [_currentAudioSession setDisposable:nil];
    }];
}

- (void)_endAudioSessionFinal
{
    if (!_controlAudioSession) {
        return;
    }
    
    SMetaDisposable *currentAudioSession = _currentAudioSession;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        [currentAudioSession setDisposable:nil];
    }];
}

- (void)_notifyFinished
{
    id<TGAudioPlayerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)])
        [delegate audioPlayerDidFinishPlaying:self];
}

- (void)_notifyPaused {
    id<TGAudioPlayerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioPlayerDidPause:)])
        [delegate audioPlayerDidPause:self];
}

+ (bool)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription *desc in [route outputs])
    {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return true;
    }
    return false;
}

@end
