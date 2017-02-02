#import "TGOverlayController.h"

@class TGEmbedPlayerView;
@class TGEmbedPlayerState;
@class TGEmbedItemView;

@protocol TGEmbedPlayerWrapperView;

@interface TGEmbedPlayerController : TGOverlayController

@property (nonatomic, assign) NSTimeInterval transitionDuration;

@property (nonatomic, weak) UIView<TGEmbedPlayerWrapperView> *embedWrapperView;

@property (nonatomic, copy) void(^playPressed)(void);
@property (nonatomic, copy) void(^pausePressed)(void);
@property (nonatomic, copy) void(^seekToPosition)(CGFloat position);

@property (nonatomic, readonly) bool requestedFromRotation;

- (instancetype)initWithParentController:(TGViewController *)parentController playerView:(TGEmbedPlayerView *)playerView transitionSourceFrame:(CGRect (^)(void))transitionSourceFrame;

- (void)dismissForPIP;
- (void)dismissFullscreen:(bool)fromRotation duration:(NSTimeInterval)duration;

- (void)updateState:(TGEmbedPlayerState *)state;
- (void)setAboveStatusBar;

@end
