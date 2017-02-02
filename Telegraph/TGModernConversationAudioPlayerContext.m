/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationAudioPlayerContext.h"

#import "TGModernConversationAudioPlayer.h"

@interface TGModernConversationAudioPlayerContext ()
{
    __weak TGModernConversationAudioPlayer *_audioPlayer;
}

@end

@implementation TGModernConversationAudioPlayerContext

- (instancetype)initWithAudioPlayer:(TGModernConversationAudioPlayer *)audioPlayer
{
    self = [super init];
    if (self != nil)
    {
        _audioPlayer = audioPlayer;
    }
    return self;
}

- (bool)isPlaybackActive
{
    return true;
}

- (bool)isPaused
{
    TGModernConversationAudioPlayer *audioPlayer = _audioPlayer;
    return [audioPlayer isPaused];
}

- (float)playbackPosition:(CFAbsoluteTime *)timestamp sync:(bool)sync
{
    if (timestamp != NULL)
        *timestamp = MTAbsoluteSystemTime();
    
    TGModernConversationAudioPlayer *audioPlayer = _audioPlayer;
    return [audioPlayer playbackPositionSync:sync];
}

- (NSTimeInterval)preciseDuration
{
    TGModernConversationAudioPlayer *audioPlayer = _audioPlayer;
    return [audioPlayer duration];
}

- (void)play
{
    TGModernConversationAudioPlayer *audioPlayer = _audioPlayer;
    [audioPlayer play];
}

- (void)play:(float)playbackPosition
{
    TGModernConversationAudioPlayer *audioPlayer = _audioPlayer;
    [audioPlayer play:playbackPosition];
}

- (void)pause
{
    TGModernConversationAudioPlayer *audioPlayer = _audioPlayer;
    [audioPlayer pause];
}

@end
