#import "TGBridgeSubscription.h"

@class TGBridgeLocationMediaAttachment;
@class TGBridgeDocumentMediaAttachment;

@interface TGBridgeSendTextMessageSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) int32_t replyToMid;

- (instancetype)initWithPeerId:(int64_t)peerId text:(NSString *)text replyToMid:(int32_t)replyToMid;

@end


@interface TGBridgeSendStickerMessageSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) TGBridgeDocumentMediaAttachment *document;
@property (nonatomic, readonly) int32_t replyToMid;

- (instancetype)initWithPeerId:(int64_t)peerId document:(TGBridgeDocumentMediaAttachment *)document replyToMid:(int32_t)replyToMid;

@end


@interface TGBridgeSendLocationMessageSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) TGBridgeLocationMediaAttachment *location;
@property (nonatomic, readonly) int32_t replyToMid;

- (instancetype)initWithPeerId:(int64_t)peerId location:(TGBridgeLocationMediaAttachment *)location replyToMid:(int32_t)replyToMid;

@end


@interface TGBridgeSendForwardedMessageSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t messageId;

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId;

@end