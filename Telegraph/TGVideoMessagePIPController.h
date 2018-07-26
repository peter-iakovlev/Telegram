#import <LegacyComponents/LegacyComponents.h>

@class TGModernGalleryVideoView;
@class TGMusicPlayerStatus;

@interface TGVideoMessagePIPController : TGOverlayController

@property (nonatomic, copy) SSignal *(^messageVisibilitySignal)(int64_t cid, int32_t messageId, int64_t peerId);
@property (nonatomic, copy) void (^requestedDismissal)(void);

+ (TGModernGalleryVideoView *)videoViewForStatus:(TGMusicPlayerStatus *)status;

@end
