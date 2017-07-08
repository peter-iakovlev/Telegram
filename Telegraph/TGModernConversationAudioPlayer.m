/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationAudioPlayer.h"

#import "TGTimerTarget.h"

#import "TGModernConversationAudioPlayerContext.h"

@interface TGModernConversationAudioPlayer () <TGAudioPlayerDelegate>
{
    NSString *_filePath;
    bool _music;
    bool _controlAudioSession;
    
    NSTimer *_timer;
    
    TGModernConversationAudioPlayerContext *_inlineMediaContext;
    
    bool _isPaused;
}

@end

@implementation TGModernConversationAudioPlayer

- (instancetype)initWithFilePath:(NSString *)filePath music:(bool)music controlAudioSession:(bool)controlAudioSession
{
    self = [super init];
    if (self != nil)
    {
        _filePath = filePath;
        _music = music;
        _controlAudioSession = controlAudioSession;
        
        _audioPlayer = [TGAudioPlayer audioPlayerForPath:filePath music:music controlAudioSession:controlAudioSession];
        _audioPlayer.delegate = self;
        _queue = [SQueue mainQueue];
    }
    return self;
}

- (void)dealloc
{
    [self cleanup];
}

- (void)cleanup
{
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    if (_audioPlayer != nil)
    {
        _audioPlayer.delegate = nil;
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
}

- (TGModernViewInlineMediaContext *)inlineMediaContext
{
    if (_inlineMediaContext == nil)
        _inlineMediaContext = [[TGModernConversationAudioPlayerContext alloc] initWithAudioPlayer:self];
    
    return _inlineMediaContext;
}

- (void)play
{
    if (_audioPlayer == nil) {
        _audioPlayer = [TGAudioPlayer audioPlayerForPath:_filePath music:_music controlAudioSession:_controlAudioSession];
        _audioPlayer.delegate = self;
    }
    
    _isPaused = false;
    
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [_audioPlayer play];
    
    [self updateCurrentTime];
    _timer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateCurrentTime) interval:0.01 repeat:true];
}

- (void)play:(float)playbackPosition
{
    _isPaused = false;
    
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    NSTimeInterval preciseDuration = [_audioPlayer duration];
    if (preciseDuration > 0.1)
    {
        [_audioPlayer playFromPosition:MAX(0.0, MIN(preciseDuration, playbackPosition * preciseDuration))];
        [_inlineMediaContext postUpdatePlaybackPosition:true];
    }
    else
    {
        [_audioPlayer play];
        [self updateCurrentTime];
    }
    
    _timer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateCurrentTime) interval:0.01 repeat:true];
}

- (void)updateCurrentTime
{
    [_inlineMediaContext postUpdatePlaybackPosition:false];
}

- (void)pause {
    [self pause:^{}];
}

- (void)pause:(void (^)())completion
{
    _isPaused = true;
    
    [_audioPlayer pause:completion];
    
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [_inlineMediaContext postUpdatePlaybackPosition:false];
}

- (void)stop
{
    _isPaused = true;
    
    [_audioPlayer stop];
    
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [self cleanup];
}

- (float)playbackPosition
{
    return [self playbackPositionSync:false];
}

- (float)playbackPositionSync:(bool)sync
{
    NSTimeInterval duration = [_audioPlayer duration];
    if (duration > 0.1)
        return (float)([_audioPlayer currentPositionSync:sync] / duration);
    
    return 0.0f;
}

- (NSTimeInterval)absolutePlaybackPosition {
    return [_audioPlayer currentPositionSync:true];
}

- (NSTimeInterval)duration
{
    return [_audioPlayer duration];
}

- (bool)isPaused
{
    return _isPaused;
}

- (void)audioPlayerDidPause:(TGAudioPlayer *)__unused audioPlayer {
    TGDispatchOnMainThread(^{
        _isPaused = true;
        
        if (_timer != nil)
        {
            [_timer invalidate];
            _timer = nil;
        }
        
        [_inlineMediaContext postUpdatePlaybackPosition:false];
    });
}

- (void)audioPlayerDidFinishPlaying:(TGAudioPlayer *)__unused audioPlayer
{
    TGDispatchOnMainThread(^
    {
        _isPaused = true;
        
        if (_timer != nil)
        {
            [_timer invalidate];
            _timer = nil;
        }
        
        [_inlineMediaContext postUpdatePlaybackPosition:false];
        
        [self cleanup];
        
        id<TGModernConversationAudioPlayerDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(audioPlayerDidFinish)])
            [delegate audioPlayerDidFinish];
    });
}

@end
