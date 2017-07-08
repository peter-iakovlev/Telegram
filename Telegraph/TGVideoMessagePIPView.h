#import "TGModernGalleryVideoView.h"

@class TGMusicPlayerStatus;
@class TGMusicPlayerItem;

@interface TGVideoMessagePIPView : UIView

@property (nonatomic, copy) void (^onTap)(void);
@property (nonatomic, strong) TGMusicPlayerItem *item;
@property (nonatomic, strong) TGModernGalleryVideoView *videoView;

- (void)setStatus:(TGMusicPlayerStatus *)status;

@end
