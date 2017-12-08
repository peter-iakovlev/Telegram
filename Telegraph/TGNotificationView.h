#import <UIKit/UIKit.h>
#import <SSignalKit/SSignalKit.h>

@class TGNotificationContentView;
@class TGViewController;

@class TGMediaAttachment;
@class TGDocumentMediaAttachment;
@class TGModernViewInlineMediaContext;

@interface TGNotificationView : UIView

@property (nonatomic, copy) bool (^shouldExpandOnTap)(void);
@property (nonatomic, copy) void (^onTap)(void);

@property (nonatomic, copy) void (^onExpand)(void);
@property (nonatomic, copy) void (^onExpandProgress)(CGFloat progress);

@property (nonatomic, copy) void (^hide)(bool animated);

@property (nonatomic, copy) void (^sendTextMessage)(NSString *text);
@property (nonatomic, copy) void (^sendSticker)(TGDocumentMediaAttachment *sticker);

@property (nonatomic, copy) TGViewController *(^parentController)(void);

@property (nonatomic, copy) SSignal *(^userListSignal)(NSString *mention);
@property (nonatomic, copy) SSignal *(^hashtagListSignal)(NSString *hashtag);
@property (nonatomic, copy) SSignal *(^stickersSignal)(NSString *emoji);

@property (nonatomic, copy) id (^requestMedia)(TGMediaAttachment *attachment, int64_t cid, int32_t mid);
@property (nonatomic, copy) void (^cancelMedia)(id mediaId);
@property (nonatomic, copy) void (^playMedia)(TGMediaAttachment *attachment, int64_t cid, int32_t mid);
@property (nonatomic, copy) bool (^isMediaAvailable)(TGMediaAttachment *attachment);
@property (nonatomic, copy) TGModernViewInlineMediaContext *(^mediaContext)(int64_t cid, int32_t mid);

@property (nonatomic, readonly) TGNotificationContentView *contentView;

@property (nonatomic, assign) bool isPresented;
@property (nonatomic, assign) bool isHiding;
@property (nonatomic, readonly) bool isExpanded;
@property (nonatomic, assign) bool isRepliable;

@property (nonatomic, readonly) CGFloat expandedHeight;
@property (nonatomic, readonly) CGFloat shrinkedHeight;

@property (nonatomic, assign) UIEdgeInsets safeAreaInset;

- (void)setShrinked:(bool)shrinked;

@property (nonatomic, readonly) bool isInteracting;
@property (nonatomic, readonly) bool hasUnsavedData;
@property (nonatomic, readonly) bool isIdle;

- (void)prepareInterItemTransitionView;
- (void)playInterItemTransition;

- (void)updateHandleViewAnimated:(bool)animated;
- (void)prepareForHide;

- (void)localizationUpdated;
- (void)reset;

@end

extern const CGFloat TGNotificationDefaultHeight;
extern const CGFloat TGNotificationMaximumHeight;
extern const CGFloat TGNotificationBackgroundInset;
