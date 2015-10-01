#import "TGNeoViewModel.h"

@class TGBridgeReplyMessageMediaAttachment;
@class TGBridgeMediaAttachment;

@interface TGNeoReplyHeaderViewModel : TGNeoViewModel

@property (nonatomic, readonly) TGBridgeMediaAttachment *mediaAttachment;

- (instancetype)initWithReplyAttachment:(TGBridgeReplyMessageMediaAttachment *)attachment users:(NSDictionary *)users outgoing:(bool)outgoing;

@end

extern const CGFloat TGNeoReplyHeaderHeight;
extern const CGFloat TGNeoReplyHeaderLineWidth;
extern const CGFloat TGNeoReplyHeaderSpacing;