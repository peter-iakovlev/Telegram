/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioPlayer.h"

#import "ASQueue.h"

#import "TGOpusAudioPlayerAU.h"
#import "TGNativeAudioPlayer.h"

#import "TGObserverProxy.h"
#import "TGAppDelegate.h"

#import <SSignalKit/SSignalKit.h>

#import <AVFoundation/AVFoundation.h>

#import "TGAudioSessionManager.h"

@interface TGAudioPlayer ()
{
    bool _proximityState;
    TGObserverProxy *_proximityChangedNotification;
    TGHolder *_proximityChangeHolder;
    
    SMetaDisposable *_currentAudioSession;
    bool _changingProximity;
}

@end

@implementation TGAudioPlayer

+ (TGAudioPlayer *)audioPlayerForPath:(NSString *)path
{
    if (path == nil)
        return nil;
    
    if ([TGOpusAudioPlayerAU canPlayFile:path])
        return [[TGOpusAudioPlayerAU alloc] initWithPath:path];
    else
        return [[TGNativeAudioPlayer alloc] initWithPath:path];
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _currentAudioSession = [[SMetaDisposable alloc] init];
        _proximityState = TGAppDelegateInstance.deviceProximityState;
        _proximityChangedNotification = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(proximityChanged:) name:TGDeviceProximityStateChangedNotification object:nil];
        _proximityChangeHolder = [[TGHolder alloc] init];
        [TGAppDelegateInstance.deviceProximityListeners addHolder:_proximityChangeHolder];
    }
    return self;
}

- (void)dealloc
{
    [TGAppDelegateInstance.deviceProximityListeners removeHolder:_proximityChangeHolder];
}

- (void)play
{
    [self playFromPosition:-1.0];
}

- (void)playFromPosition:(NSTimeInterval)__unused position
{
}

- (void)pause
{
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
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        bool overridePort = _proximityState && ![TGAudioPlayer isHeadsetPluggedIn];
        __weak TGAudioPlayer *weakSelf = self;
        [_currentAudioSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:overridePort ? TGAudioSessionTypePlayAndRecordHeadphones : TGAudioSessionTypePlayVoice interrupted:^
        {
            __strong TGAudioPlayer *strongSelf = weakSelf;
            if (strongSelf != nil && !strongSelf->_changingProximity)
            {
                [strongSelf stop];
                [strongSelf _notifyFinished];
            }
        }]];
    }];
}

- (void)_endAudioSession
{
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        [_currentAudioSession setDisposable:nil];
    }];
}

- (void)_endAudioSessionFinal
{
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
