#import <SSignalKit/SSignalKit.h>

@class TGMediaAttachment;
@class TGLocationMediaAttachment;
@class TGDocumentMediaAttachment;

@class TGMessage;
@class TLInputMedia;

@interface TGSendMessageSignals : NSObject

+ (SSignal *)sendTextMessageWithPeerId:(int64_t)peerId text:(NSString *)text replyToMid:(int32_t)replyToMid;

+ (SSignal *)sendLocationWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid locationAttachment:(TGLocationMediaAttachment *)locationAttachment;
+ (SSignal *)sendRemoteDocumentWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid documentAttachment:(TGDocumentMediaAttachment *)documentAttachment;

+ (SSignal *)forwardMessageWithMid:(int32_t)mid peerId:(int64_t)peerId;

+ (SSignal *)_addMessageToDatabaseWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid text:(NSString *)text attachment:(TGMediaAttachment *)attachment;
+ (SSignal *)_sendMediaWithMessage:(TGMessage *)message replyToMid:(int32_t)replyToMid mediaProducer:(TLInputMedia *(^)(void))mediaProducer;

@end
