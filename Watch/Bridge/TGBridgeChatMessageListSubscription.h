#import "TGBridgeSubscription.h"

@interface TGBridgeChatMessageListSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t atMessageId;
@property (nonatomic, readonly) NSUInteger rangeMessageCount;

- (instancetype)initWithPeerId:(int64_t)peerId atMessageId:(int32_t)messageId rangeMessageCount:(NSUInteger)rangeMessageCount;

@end


@interface TGBridgeChatMessageSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t messageId;

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId;

@end


@interface TGBridgeReadChatMessageListSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;

- (instancetype)initWithPeerId:(int64_t)peerId;

@end
