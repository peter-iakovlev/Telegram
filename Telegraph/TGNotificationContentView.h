#import "TGNotificationPreviewView.h"

@class TGMessage;
@class TGConversation;

@interface TGNotificationContentView : UIView

@property (nonatomic, readonly) TGNotificationPreviewView *previewView;

@property (nonatomic, copy) id (^requestMedia)(TGMediaAttachment *attachment, int64_t cid, int32_t mid);
@property (nonatomic, copy) void (^cancelMedia)(id mediaId);
@property (nonatomic, copy) void (^playMedia)(TGMediaAttachment *attachment, int64_t cid, int32_t mid);
@property (nonatomic, copy) bool (^isMediaAvailable)(TGMediaAttachment *attachment);
@property (nonatomic, copy) TGModernViewInlineMediaContext *(^mediaContext)(int64_t cid, int32_t mid);

- (void)configureWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation peers:(NSDictionary *)peers;
- (void)reset;

@end
