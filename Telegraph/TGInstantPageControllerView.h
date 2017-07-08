#import <UIKit/UIKit.h>

#import "TGInstantPageLayout.h"
#import "TGPIPAblePlayerView.h"

@class TGConversation;
@class TGWebPageMediaAttachment;
@class TGInstantPageMedia;

@class TGEmbedPlayerView;
@class TGEmbedPlayerController;
@class TGEmbedPIPPlaceholderView;
@class TGPIPSourceLocation;

@class TGInstantPageScrollState;

@interface TGInstantPageControllerView : UIView

@property (nonatomic, copy) void (^backPressed)();
@property (nonatomic, copy) void (^sharePressed)();
@property (nonatomic, copy) void (^shareText)(NSString *);
@property (nonatomic, copy) void (^openUrl)(NSString *, int64_t);
@property (nonatomic, copy) void (^openUrlOptions)(NSString *, int64_t);
@property (nonatomic, copy) void (^openMedia)(NSArray<TGInstantPageMedia *> *, TGInstantPageMedia *);
@property (nonatomic, copy) void (^openAudio)(NSArray<TGDocumentMediaAttachment *> *, TGDocumentMediaAttachment *);
@property (nonatomic, copy) TGEmbedPlayerController *(^openEmbedFullscreen)(TGEmbedPlayerView *, UIView *);
@property (nonatomic, copy) TGEmbedPIPPlaceholderView *(^openEmbedPIP)(TGEmbedPlayerView *, UIView *, TGPIPSourceLocation *, TGEmbedPIPCorner, TGEmbedPlayerController *);
@property (nonatomic, copy) void (^openFeedback)();
@property (nonatomic, copy) void (^statusBarOffsetUpdated)(CGFloat);
@property (nonatomic, copy) void (^openChannel)(TGConversation *);
@property (nonatomic, copy) void (^joinChannel)(TGConversation *);
@property (nonatomic, copy) void (^themeChanged)(TGInstantPagePresentationTheme theme);
@property (nonatomic, copy) void (^fontSizeChanged)(CGFloat multiplier);
@property (nonatomic, copy) void (^fontSerifChanged)(bool serif);
@property (nonatomic, copy) void (^autoNightThemeChanged)(bool enabled);

@property (nonatomic, strong) TGWebPageMediaAttachment *webPage;
@property (nonatomic, strong) TGInstantPagePresentation *presentation;
- (void)setPresentation:(TGInstantPagePresentation *)presentation animated:(bool)animated;
@property (nonatomic, assign) bool autoNightThemeEnabled;

@property (nonatomic, readonly) CGFloat statusBarOffset;

@property (nonatomic, assign) CGFloat statusBarHeight;

@property (nonatomic, assign) int64_t peerId;
@property (nonatomic, assign) int32_t messageId;

@property (nonatomic, strong) NSString *initialAnchor;

- (void)scrollToEmbedIndex:(int32_t)embedIndex animated:(bool)animated completion:(void (^)(void))completion;
- (void)cancelPIPWithEmbedIndex:(int32_t)embedIndex;

- (UIView *)transitionViewForMedia:(TGInstantPageMedia *)media;
- (void)updateHiddenMedia:(TGInstantPageMedia *)media;

- (void)applyScrollState:(TGInstantPageScrollState *)scrollState;
- (TGInstantPageScrollState *)currentScrollState;

@end
