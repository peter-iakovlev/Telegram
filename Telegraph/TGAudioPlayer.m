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

#import <AVFoundation/AVFoundation.h>

@interface TGAudioPlayer ()
{
    bool _audioSessionIsActive;
    bool _proximityState;
    TGObserverProxy *_proximityChangedNotification;
    TGHolder *_proximityChangeHolder;
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
        if (_audioSessionIsActive)
        {
            __autoreleasing NSError *error = nil;
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            if (![audioSession setCategory:overridePort ? AVAudioSessionCategoryPlayAndRecord:AVAudioSessionCategoryPlayback error:&error])
                TGLog(@"[TGAudioPlayer audio session set category failed: %@]", error);
            if (![audioSession overrideOutputAudioPort:overridePort ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker error:&error])
                TGLog(@"[TGAudioPlayer override route failed: %@]", error);
        }
    }];
}

- (void)_beginAudioSession
{
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        if (!_audioSessionIsActive)
        {
            __autoreleasing NSError *error = nil;
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            bool overridePort = _proximityState && ![TGAudioPlayer isHeadsetPluggedIn];
            if (![audioSession setCategory:overridePort ? AVAudioSessionCategoryPlayAndRecord :AVAudioSessionCategoryPlayback error:&error])
                TGLog(@"[TGAudioPlayer audio session set category failed: %@]", error);
            else if (![audioSession setActive:true error:&error])
                TGLog(@"[TGAudioPlayer audio session activation failed: %@]", error);
            else
            {
                if (![audioSession overrideOutputAudioPort:overridePort ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker error:&error])
                    TGLog(@"[TGAudioPlayer override route failed: %@]", error);
                
                _audioSessionIsActive = true;
            }
        }
    }];
}

- (void)_endAudioSession
{
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        if (_audioSessionIsActive)
        {
            __autoreleasing NSError *error = nil;
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            if (![audioSession setActive:false error:&error])
                TGLog(@"[TGAudioPlayer audio session deactivation failed: %@]", error);
            if (![audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error])
                TGLog(@"[TGAudioPlayer override route failed: %@]", error);
            
            _audioSessionIsActive = false;
        }
    }];
}

- (void)_endAudioSessionFinal
{
    bool audioSessionIsActive = _audioSessionIsActive;
    _audioSessionIsActive = false;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        if (audioSessionIsActive)
        {
            __autoreleasing NSError *error = nil;
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            if (![audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error])
                TGLog(@"[TGAudioPlayer override route failed: %@]", error);
            if (![audioSession setActive:false error:&error])
                TGLog(@"[TGAudioPlayer audio session deactivation failed: %@]", error);
        }
    }];
}

- (void)_notifyFinished
{
    id<TGAudioPlayerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)])
        [delegate audioPlayerDidFinishPlaying:self];
}

+ (BOOL)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

@end
