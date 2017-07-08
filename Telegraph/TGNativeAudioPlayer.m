/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGNativeAudioPlayer.h"

#import "ASQueue.h"

#import "TGObserverProxy.h"

@interface TGNativeAudioPlayer ()
{
    AVPlayerItem *_currentItem;
    TGObserverProxy *_didPlayToEndObserver;
}

@end

@implementation TGNativeAudioPlayer

- (instancetype)initWithPath:(NSString *)path music:(bool)music controlAudioSession:(bool)controlAudioSession
{
    self = [super initWithMusic:music controlAudioSession:controlAudioSession];
    if (self != nil)
    {
        __autoreleasing NSError *error = nil;
        NSString *realPath = path;
        NSArray *audioExtensions = @[@"mp3", @"aac", @"m4a", @"mov", @"mp4"];
        if (![audioExtensions containsObject:realPath.pathExtension.lowercaseString]) {
            realPath = [path stringByAppendingPathExtension:@"mp3"];
            [[NSFileManager defaultManager] createSymbolicLinkAtPath:realPath withDestinationPath:path error:nil];
        }
        _currentItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:realPath]];
        if (_currentItem != nil) {
            _player = [[AVPlayer alloc] initWithPlayerItem:_currentItem];
            _didPlayToEndObserver = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        }
        
        if (_player == nil || error != nil)
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
    AVPlayer *player = _player;
    _player = nil;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        [player pause];
    }];
    
    [self _endAudioSessionFinal];
}

- (void)playFromPosition:(NSTimeInterval)position
{
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        [self _beginAudioSession];
        
        if (position >= 0.0) {
            CMTime targetTime = CMTimeMakeWithSeconds(position, NSEC_PER_SEC);
            [_currentItem seekToTime:targetTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
        [_player play];
    }];
}

- (void)pause:(void (^)())completion
{
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        [_player pause];
        if (completion) {
            completion();
        }
    }];
}

- (void)stop
{
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        [_player pause];
    }];
}

- (NSTimeInterval)currentPositionSync:(bool)sync
{
    __block NSTimeInterval result = 0.0;
    
    dispatch_block_t block = ^
    {
        result = CMTimeGetSeconds(_currentItem.currentTime);
    };
    
    if (sync)
        [[TGAudioPlayer _playerQueue] dispatchOnQueue:block synchronous:true];
    else
        block();
    
    return result;
}

- (NSTimeInterval)duration
{
    return CMTimeGetSeconds(_currentItem.duration);
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)__unused player successfully:(BOOL)__unused flag
{
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)__unused notification
{
    [_player pause];
    
    [self _notifyFinished];
}

@end
