/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGNativeAudioPlayer.h"

#import "ASQueue.h"

#import <AVFoundation/AVFoundation.h>

@interface TGNativeAudioPlayer () <AVAudioPlayerDelegate>
{
    AVAudioPlayer *_audioPlayer;
}

@end

@implementation TGNativeAudioPlayer

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self != nil)
    {
        __autoreleasing NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
        _audioPlayer.delegate = self;
        
        if (_audioPlayer == nil || error != nil)
        {
            [self cleanupWithError];
        }
    }
    return self;
}

- (void)dealloc
{
    [self cleanup];
}

- (void)cleanupWithError
{
    [self cleanup];
}

- (void)cleanup
{
    AVAudioPlayer *audioPlayer = _audioPlayer;
    _audioPlayer.delegate = nil;
    _audioPlayer = nil;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        [audioPlayer stop];
    }];
    
    [self _endAudioSessionFinal];
}

- (void)playFromPosition:(NSTimeInterval)position
{
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        [self _beginAudioSession];
        
        if (position >= 0.0)
            [_audioPlayer setCurrentTime:position];
        [_audioPlayer play];
    }];
}

- (void)pause
{
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        [_audioPlayer pause];
    }];
}

- (void)stop
{
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        [_audioPlayer stop];
    }];
}

- (NSTimeInterval)currentPositionSync:(bool)sync
{
    __block NSTimeInterval result = 0.0;
    
    dispatch_block_t block = ^
    {
        result = [_audioPlayer currentTime];
    };
    
    if (sync)
        [[TGAudioPlayer _playerQueue] dispatchOnQueue:block synchronous:true];
    else
        block();
    
    return result;
}

- (NSTimeInterval)duration
{
    return [_audioPlayer duration];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)__unused player successfully:(BOOL)__unused flag
{
    [self _notifyFinished];
}

@end
