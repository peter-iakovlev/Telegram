#import "TGPIPAblePlayerView.h"

@interface TGModernGalleryVideoPlayerState : NSObject <TGPIPAblePlayerState>

+ (instancetype)stateWithPlaying:(bool)playing duration:(NSTimeInterval)duration position:(NSTimeInterval)position;

@end
