#import "TGOverlayController.h"
#import "TGPIPAblePlayerView.h"

@class TGEmbedPIPPlaceholderView;
@class TGWebPageMediaAttachment;

@interface TGPIPSourceLocation : NSObject

@property (nonatomic, readonly) bool embed;
@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) int32_t localId;
@property (nonatomic, readonly) TGWebPageMediaAttachment *webPage;

- (instancetype)initWithEmbed:(bool)embed peerId:(int64_t)peerId messageId:(int32_t)messageId localId:(int32_t)localId webPage:(TGWebPageMediaAttachment *)webPage;

@end

@interface TGEmbedPIPController : TGOverlayController

- (void)cancel:(bool)reset;
- (void)cancelWithOffset:(CGPoint)offset reset:(bool)reset;

+ (void)startPictureInPictureWithPlayerView:(UIView<TGPIPAblePlayerView> *)playerView location:(TGPIPSourceLocation *)location corner:(TGEmbedPIPCorner)corner onTransitionBegin:(void (^)(void))onTransitionBegin onTransitionFinished:(void (^)(void))onTransitionFinished;
+ (void)dismissPictureInPicture;

+ (void)resumePictureInPicturePlayback;
+ (void)pausePictureInPicturePlayback;

+ (void)hide;
+ (void)restore;

+ (bool)hasPictureInPictureActiveForLocation:(TGPIPSourceLocation *)location playerView:(UIView<TGPIPAblePlayerView> **)playerView;

+ (void)registerPlaceholderView:(TGEmbedPIPPlaceholderView *)view;
+ (void)registerPlayerView:(UIView<TGPIPAblePlayerView> *)view;
+ (bool)hasPlayerViews;

+ (UIView<TGPIPAblePlayerView> *)activeNonPIPPlayerView;

+ (void)cancelPictureInPictureWithOffset:(CGPoint)offset;

+ (bool)isSystemPictureInPictureAvailable;

+ (void)_systemPictureInPictureDidStart;
+ (void)_systemPictureInPictureDidStop;
+ (void)_cancelSystemPIPWithCompletion:(void (^)(void))completion;

+ (void)maybeReleaseVolumeOverlay;

@end
