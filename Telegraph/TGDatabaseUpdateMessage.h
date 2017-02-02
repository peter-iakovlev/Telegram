#import <Foundation/Foundation.h>

#import "TGMessage.h"

@interface TGDatabaseUpdateMessage : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int32_t messageId;

@end

@interface TGDatabaseUpdateMessageFailedDeliveryInBackground : TGDatabaseUpdateMessage

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId;

@end

@interface TGDatabaseUpdateMessageDeliveredInBackground : TGDatabaseUpdateMessage

@property (nonatomic, readonly) int32_t updatedMessageId;

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId updatedMessageId:(int32_t)updatedMessageId;

@end

@interface TGDatabaseUpdateContentsRead: TGDatabaseUpdateMessage

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId;

@end

@interface TGDatabaseUpdateMessageWithMessage : TGDatabaseUpdateMessage

@property (nonatomic, strong, readonly) TGMessage *message;
@property (nonatomic, readonly) bool dispatchEdited;

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId message:(TGMessage *)message dispatchEdited:(bool)dispatchEdited;

@end
