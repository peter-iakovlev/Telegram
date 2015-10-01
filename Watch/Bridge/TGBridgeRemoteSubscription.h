#import "TGBridgeSubscription.h"

@interface TGBridgeRemoteSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) int32_t type;
@property (nonatomic, readonly) bool autoPlay;

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId type:(int32_t)type autoPlay:(bool)autoPlay;

@end
