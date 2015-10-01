#import "TGBridgeSubscription.h"

@interface TGBridgeConversationSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;

- (instancetype)initWithPeerId:(int64_t)peerId;

@end
