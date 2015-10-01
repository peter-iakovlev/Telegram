#import "TGNeoMessageViewModel.h"
#import "TGNeoLabelViewModel.h"
#import "TGNeoForwardHeaderViewModel.h"
#import "TGNeoReplyHeaderViewModel.h"

@class TGBridgeMessage;
@class TGBridgeUser;

@interface TGNeoBubbleMessageViewModel : TGNeoMessageViewModel

@property (nonatomic, readonly) TGNeoLabelViewModel *authorNameModel;

@property (nonatomic, strong) TGNeoForwardHeaderViewModel *forwardHeaderModel;
@property (nonatomic, readonly) TGNeoReplyHeaderViewModel *replyHeaderModel;

- (CGSize)contentContainerSizeWithContainerSize:(CGSize)containerSize;
- (CGSize)layoutHeaderModelsWithContainerSize:(CGSize)containerSize;

- (UIColor *)normalColorForMessage:(TGBridgeMessage *)message;
- (UIColor *)subtitleColorForMessage:(TGBridgeMessage *)message;
- (UIColor *)accentColorForMessage:(TGBridgeMessage *)message;

@end

extern const UIEdgeInsets TGNeoBubbleMessageViewModelInsets;
extern const CGFloat TGNeoBubbleMessageMetaSpacing;
extern const CGFloat TGNeoBubbleHeaderSpacing;
