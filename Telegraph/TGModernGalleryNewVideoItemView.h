#import "TGModernGalleryZoomableItemView.h"

@protocol TGPIPAblePlayerView;
@class TGModernButton;
@class TGModernGalleryVideoPlayerView;
@class TGModernGalleryVideoScrubbingInterfaceView;

@interface TGModernGalleryNewVideoItemView : TGModernGalleryZoomableItemView
{
    TGModernButton *_actionButton;
    TGModernGalleryVideoPlayerView *_playerView;
    TGModernGalleryVideoScrubbingInterfaceView *_scrubbingInterfaceView;
    bool _playerViewDetached;
    
    CGSize _videoDimensions;
    bool _disablePictureInPicture;
}

- (bool)shouldLoopVideo:(NSUInteger)currentLoopCount;

- (void)play;
- (void)loadAndPlay;
- (void)hidePlayButton;
- (void)stop;
- (void)stopForOutTransition;

- (void)setDefaultFooterHidden:(bool)hidden;
- (void)updateInterface;
- (void)_willPlay;

- (void)_initializePlayerWithPath:(NSString *)videoPath duration:(NSTimeInterval)duration synchronously:(bool)synchronously;
- (void)_configurePlayerView;
- (void)_subscribeToStateOfPlayerView:(UIView<TGPIPAblePlayerView> *)playerView;

- (UIView<TGPIPAblePlayerView> *)_playerView;

@end
