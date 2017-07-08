#import "TGOverlayController.h"

@class TGModernGalleryVideoView;
@class TGMusicPlayerStatus;

@interface TGVideoMessagePIPController : TGOverlayController

@property (nonatomic, copy) SSignal *(^messageVisibilitySignal)(int64_t peerId, int32_t messageId);
@property (nonatomic, copy) void (^requestedDismissal)(void);

+ (TGModernGalleryVideoView *)videoViewForStatus:(TGMusicPlayerStatus *)status;

@end
