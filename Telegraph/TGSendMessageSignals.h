#import <SSignalKit/SSignalKit.h>

@class TGMediaAttachment;
@class TGImageMediaAttachment;
@class TGVideoMediaAttachment;
@class TGLocationMediaAttachment;
@class TGDocumentMediaAttachment;
@class TGContactMediaAttachment;

@class TGMessage;
@class TLInputMedia;

@interface TGSendMessageSignals : NSObject

+ (SSignal *)sendTextMessageWithPeerId:(int64_t)peerId text:(NSString *)text replyToMid:(int32_t)replyToMid;
+ (SSignal *)sendTextMessageWithPeerId:(int64_t)peerId text:(NSString *)text entities:(NSArray *)entities replyToMid:(int32_t)replyToMid;

+ (SSignal *)sendLocationWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid locationAttachment:(TGLocationMediaAttachment *)locationAttachment;
+ (SSignal *)sendRemoteDocumentWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid documentAttachment:(TGDocumentMediaAttachment *)documentAttachment;

+ (SSignal *)forwardMessageWithMid:(int32_t)mid peerId:(int64_t)peerId;

+ (SSignal *)forwardMessagesWithMessageIds:(NSArray *)messageIds toPeerIds:(NSArray *)peerIds fromPeerId:(int64_t)fromPeerId fromPeerAccessHash:(int64_t)fromPeerAccessHash;
+ (SSignal *)broadcastMessageWithText:(NSString *)text toPeerIds:(NSArray *)peerIds;

+ (SSignal *)sendMediaWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid attachment:(TGMediaAttachment *)attachment uploadSignal:(SSignal *)uploadSignal mediaProducer:(TLInputMedia *(^)(NSDictionary *uploadInfo))mediaProducer;

+ (SSignal *)commitSendMediaWithMessage:(TGMessage *)message mediaProducer:(TLInputMedia *(^)(NSDictionary *))mediaProducer;

@end


@interface TGShareSignals : NSObject

+ (SSignal *)shareText:(NSString *)text toPeerIds:(NSArray *)peerIds caption:(NSString *)caption;
+ (SSignal *)shareText:(NSString *)text entities:(NSArray *)entities toPeerIds:(NSArray *)peerIds caption:(NSString *)caption;
+ (SSignal *)sharePhoto:(TGImageMediaAttachment *)photo toPeerIds:(NSArray *)peerIds caption:(NSString *)caption;
+ (SSignal *)shareVideo:(TGVideoMediaAttachment *)document toPeerIds:(NSArray *)peerIds caption:(NSString *)caption;
+ (SSignal *)shareContact:(TGContactMediaAttachment *)contact toPeerIds:(NSArray *)peerIds caption:(NSString *)caption;
+ (SSignal *)shareLocation:(TGLocationMediaAttachment *)location toPeerIds:(NSArray *)peerIds caption:(NSString *)caption;
+ (SSignal *)shareDocument:(TGDocumentMediaAttachment *)document toPeerIds:(NSArray *)peerIds caption:(NSString *)caption;

@end
