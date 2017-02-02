#import <UIKit/UIKit.h>

#import "TGPIPAblePlayerView.h"

@class TGWebPageMediaAttachment;
@class TGInstantPageMedia;

@class TGEmbedPlayerView;
@class TGEmbedPlayerController;
@class TGEmbedPIPPlaceholderView;
@class TGPIPSourceLocation;

@interface TGInstantPageControllerView : UIView

@property (nonatomic, copy) void (^backPressed)();
@property (nonatomic, copy) void (^sharePressed)();
@property (nonatomic, copy) void (^openUrl)(NSString *, int64_t);
@property (nonatomic, copy) void (^openMedia)(NSArray<TGInstantPageMedia *> *, TGInstantPageMedia *);
@property (nonatomic, copy) TGEmbedPlayerController *(^openEmbedFullscreen)(TGEmbedPlayerView *, UIView *);
@property (nonatomic, copy) TGEmbedPIPPlaceholderView *(^openEmbedPIP)(TGEmbedPlayerView *, UIView *, TGPIPSourceLocation *, TGEmbedPIPCorner, TGEmbedPlayerController *);
@property (nonatomic, copy) void (^openFeedback)();
@property (nonatomic, copy) void (^statusBarOffsetUpdated)(CGFloat);

@property (nonatomic, strong) TGWebPageMediaAttachment *webPage;
@property (nonatomic, readonly) CGFloat statusBarOffset;

@property (nonatomic, assign) CGFloat statusBarHeight;

@property (nonatomic, assign) int64_t peerId;
@property (nonatomic, assign) int32_t messageId;

- (void)scrollToEmbedIndex:(int32_t)embedIndex animated:(bool)animated completion:(void (^)(void))completion;
- (void)cancelPIPWithEmbedIndex:(int32_t)embedIndex;

- (UIView *)transitionViewForMedia:(TGInstantPageMedia *)media;
- (void)updateHiddenMedia:(TGInstantPageMedia *)media;

@end
