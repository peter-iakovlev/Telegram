#import <LegacyComponents/TGModernGalleryZoomableItemView.h>

@protocol TGPIPAblePlayerView;
@class TGModernButton;
@class TGModernGalleryVideoPlayerView;
@class TGModernGalleryVideoScrubbingInterfaceView;
@class TGModernGalleryPIPHeaderView;

@interface TGItemCollectionGalleryVideoBaseItemView : TGModernGalleryZoomableItemView {
    TGModernButton *_actionButton;
    TGModernGalleryVideoPlayerView *_playerView;
    TGModernGalleryPIPHeaderView *_pipHeaderView;
    TGModernGalleryVideoScrubbingInterfaceView *_scrubbingInterfaceView;
    bool _playerViewDetached;
    
    CGSize _videoDimensions;
}

- (bool)shouldLoopVideo:(NSUInteger)currentLoopCount;

- (void)play;
- (void)loadAndPlay;
- (void)hidePlayButton;
- (void)showPlayButton;
- (void)stop;
- (void)stopForOutTransition;

- (void)setDefaultFooterHidden:(bool)hidden;
- (void)updateInterface;
- (void)_willPlay;

- (void)_initializePlayerWithMedia:(id)media synchronously:(bool)synchronously;
- (void)_configurePlayerView;
- (void)_subscribeToStateOfPlayerView:(UIView<TGPIPAblePlayerView> *)playerView;

- (UIView<TGPIPAblePlayerView> *)_playerView;

@end
