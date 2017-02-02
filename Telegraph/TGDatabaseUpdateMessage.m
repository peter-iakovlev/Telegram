#import "TGDatabaseUpdateMessage.h"

@implementation TGDatabaseUpdateMessage

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _messageId = messageId;
    }
    return self;
}

@end

@implementation TGDatabaseUpdateMessageFailedDeliveryInBackground

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId {
    self = [super initWithPeerId:peerId messageId:messageId];
    if (self != nil) {
    }
    return self;
}

@end

@implementation TGDatabaseUpdateMessageDeliveredInBackground

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId updatedMessageId:(int32_t)updatedMessageId {
    self = [super initWithPeerId:peerId messageId:messageId];
    if (self != nil) {
        _updatedMessageId = updatedMessageId;
    }
    return self;
}

@end

@implementation TGDatabaseUpdateContentsRead

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId {
    self = [super initWithPeerId:peerId messageId:messageId];
    if (self != nil) {
    }
    return self;
}

@end

@implementation TGDatabaseUpdateMessageWithMessage

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId message:(TGMessage *)message dispatchEdited:(bool)dispatchEdited {
    self = [super initWithPeerId:peerId messageId:messageId];
    if (self != nil) {
        _message = message;
        _dispatchEdited = dispatchEdited;
    }
    return self;
}

@end
