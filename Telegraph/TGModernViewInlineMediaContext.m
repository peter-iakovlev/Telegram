/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewInlineMediaContext.h"

@implementation TGModernViewInlineMediaContext

- (void)setDelegate:(id<TGModernViewInlineMediaContextDelegate>)delegate
{
    _delegate = delegate;
}

- (void)removeDelegate:(id<TGModernViewInlineMediaContextDelegate>)delegate
{
    id<TGModernViewInlineMediaContextDelegate> currentDelegate = _delegate;
    if (delegate == currentDelegate)
        _delegate = nil;
}

- (bool)isPlaybackActive
{
    return false;
}

- (bool)isPaused
{
    return true;
}

- (float)playbackPosition:(CFAbsoluteTime *)timestamp
{
    return [self playbackPosition:timestamp sync:false];
}

- (float)playbackPosition:(CFAbsoluteTime *)__unused timestamp sync:(bool)__unused sync
{
    return 0.0f;
}

- (NSTimeInterval)preciseDuration
{
    return 0.0;
}

- (void)play
{
}

- (void)play:(float)__unused playbackPosition
{
}

- (void)pause
{
}

- (void)postUpdatePlaybackPosition:(bool)sync
{
    CFAbsoluteTime timestamp = MTAbsoluteSystemTime();
    float position = [self playbackPosition:&timestamp sync:sync];
    
    id<TGModernViewInlineMediaContextDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(inlineMediaPlaybackStateUpdated:playbackPosition:timestamp:preciseDuration:)])
        [delegate inlineMediaPlaybackStateUpdated:[self isPaused] playbackPosition:position timestamp:timestamp preciseDuration:[self preciseDuration]];
}

@end
