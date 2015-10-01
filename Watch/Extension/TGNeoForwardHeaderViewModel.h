#import "TGNeoViewModel.h"

@class TGBridgeUser;
@class TGBridgeForwardedMessageMediaAttachment;

@interface TGNeoForwardHeaderViewModel : TGNeoViewModel

- (instancetype)initWithForwardAttachment:(TGBridgeForwardedMessageMediaAttachment *)attachment user:(TGBridgeUser *)user outgoing:(bool)outgoing;

@end

extern const CGFloat TGNeoForwardHeaderHeight;
