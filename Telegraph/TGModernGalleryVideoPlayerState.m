#import "TGModernGalleryVideoPlayerState.h"

@implementation TGModernGalleryVideoPlayerState

@synthesize playing = _playing;
@synthesize duration = _duration;
@synthesize position = _position;

- (CGFloat)downloadProgress
{
    return 1.0f;
}

+ (instancetype)stateWithPlaying:(bool)playing duration:(NSTimeInterval)duration position:(NSTimeInterval)position
{
    TGModernGalleryVideoPlayerState *state = [[TGModernGalleryVideoPlayerState alloc] init];
    state->_playing = playing;
    state->_duration = duration;
    state->_position = position;
    return state;
}

@end
