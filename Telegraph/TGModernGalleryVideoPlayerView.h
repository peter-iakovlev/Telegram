#import <UIKit/UIKit.h>
#import <LegacyComponents/TGPIPAblePlayerView.h>
#import "TGModernGalleryVideoPlayerState.h"

@interface TGModernGalleryVideoPlayerView : UIView <TGPIPAblePlayerView>

@property (nonatomic, copy) bool (^shouldLoop)(NSUInteger loopCount);
@property (nonatomic, readonly) TGModernGalleryVideoPlayerState *state;
@property (nonatomic, readonly, getter=isLoaded) bool loaded;

- (void)loadImageWithUri:(NSString *)uri update:(bool)update synchronously:(bool)synchronously;
- (void)loadImageWithSignal:(SSignal *)signal;
- (void)setVideoPath:(NSString *)videoPath duration:(NSTimeInterval)duration;

- (void)reset;
- (void)stop;

- (void)disposeAudioSession;

@end
