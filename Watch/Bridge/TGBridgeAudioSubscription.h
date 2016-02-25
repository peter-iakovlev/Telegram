#import "TGBridgeSubscription.h"

@class TGBridgeMediaAttachment;

@interface TGBridgeAudioSubscription : TGBridgeSubscription

@property (nonatomic, readonly) TGBridgeMediaAttachment *attachment;
@property (nonatomic, readonly) int64_t conversationId;
@property (nonatomic, readonly) int32_t messageId;

- (instancetype)initWithAttachment:(TGBridgeMediaAttachment *)Attachment conversationId:(int64_t)conversationId messageId:(int32_t)messageId;

@end


@interface TGBridgeAudioSentSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t conversationId;

- (instancetype)initWithConversationId:(int64_t)conversationId;

@end
