#import <Foundation/Foundation.h>

/*
 * Layer 20
 */

@class Secret20_DecryptedMessageAction;
@class Secret20_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class Secret20_DecryptedMessageAction_decryptedMessageActionReadMessages;
@class Secret20_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class Secret20_DecryptedMessageAction_decryptedMessageActionScreenshotMessages;
@class Secret20_DecryptedMessageAction_decryptedMessageActionFlushHistory;
@class Secret20_DecryptedMessageAction_decryptedMessageActionNotifyLayer;
@class Secret20_DecryptedMessageAction_decryptedMessageActionTyping;
@class Secret20_DecryptedMessageAction_decryptedMessageActionResend;
@class Secret20_DecryptedMessageAction_decryptedMessageActionRequestKey;
@class Secret20_DecryptedMessageAction_decryptedMessageActionAcceptKey;
@class Secret20_DecryptedMessageAction_decryptedMessageActionCommitKey;
@class Secret20_DecryptedMessageAction_decryptedMessageActionAbortKey;
@class Secret20_DecryptedMessageAction_decryptedMessageActionNoop;

@class Secret20_SendMessageAction;
@class Secret20_SendMessageAction_sendMessageTypingAction;
@class Secret20_SendMessageAction_sendMessageCancelAction;
@class Secret20_SendMessageAction_sendMessageRecordVideoAction;
@class Secret20_SendMessageAction_sendMessageUploadVideoAction;
@class Secret20_SendMessageAction_sendMessageRecordAudioAction;
@class Secret20_SendMessageAction_sendMessageUploadAudioAction;
@class Secret20_SendMessageAction_sendMessageUploadPhotoAction;
@class Secret20_SendMessageAction_sendMessageUploadDocumentAction;
@class Secret20_SendMessageAction_sendMessageGeoLocationAction;
@class Secret20_SendMessageAction_sendMessageChooseContactAction;

@class Secret20_DecryptedMessageLayer;
@class Secret20_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret20_DecryptedMessage;
@class Secret20_DecryptedMessage_decryptedMessage;
@class Secret20_DecryptedMessage_decryptedMessageService;

@class Secret20_DecryptedMessageMedia;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret20_DecryptedMessageMedia_decryptedMessageMediaAudio;


@interface Secret20__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

@interface Secret20_FunctionContext : NSObject

@property (nonatomic, strong, readonly) NSData *payload;
@property (nonatomic, copy, readonly) id (^responseParser)(NSData *);
@property (nonatomic, strong, readonly) id metadata;

- (instancetype)initWithPayload:(NSData *)payload responseParser:(id (^)(NSData *))responseParser metadata:(id)metadata;

@end

/*
 * Types 20
 */

@interface Secret20_DecryptedMessageAction : NSObject

+ (Secret20_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret20_SendMessageAction *)action;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStartSeqNo:(NSNumber *)startSeqNo endSeqNo:(NSNumber *)endSeqNo;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchangeId:(NSNumber *)exchangeId gA:(NSData *)gA;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchangeId:(NSNumber *)exchangeId gB:(NSData *)gB keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchangeId:(NSNumber *)exchangeId keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchangeId:(NSNumber *)exchangeId;
+ (Secret20_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttlSeconds;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret20_DecryptedMessageAction

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionTyping : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) Secret20_SendMessageAction * action;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionResend : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * startSeqNo;
@property (nonatomic, strong, readonly) NSNumber * endSeqNo;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionRequestKey : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gA;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionAcceptKey : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gB;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionCommitKey : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionAbortKey : Secret20_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;

@end

@interface Secret20_DecryptedMessageAction_decryptedMessageActionNoop : Secret20_DecryptedMessageAction

@end


@interface Secret20_SendMessageAction : NSObject

+ (Secret20_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction;
+ (Secret20_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction;
+ (Secret20_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction;
+ (Secret20_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction;
+ (Secret20_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction;
+ (Secret20_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction;
+ (Secret20_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction;
+ (Secret20_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction;
+ (Secret20_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction;
+ (Secret20_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction;

@end

@interface Secret20_SendMessageAction_sendMessageTypingAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageCancelAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageRecordVideoAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageUploadVideoAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageRecordAudioAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageUploadAudioAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageUploadPhotoAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageUploadDocumentAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageGeoLocationAction : Secret20_SendMessageAction

@end

@interface Secret20_SendMessageAction_sendMessageChooseContactAction : Secret20_SendMessageAction

@end


@interface Secret20_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSData * randomBytes;
@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) NSNumber * inSeqNo;
@property (nonatomic, strong, readonly) NSNumber * outSeqNo;
@property (nonatomic, strong, readonly) Secret20_DecryptedMessage * message;

+ (Secret20_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandomBytes:(NSData *)randomBytes layer:(NSNumber *)layer inSeqNo:(NSNumber *)inSeqNo outSeqNo:(NSNumber *)outSeqNo message:(Secret20_DecryptedMessage *)message;

@end

@interface Secret20_DecryptedMessageLayer_decryptedMessageLayer : Secret20_DecryptedMessageLayer

@end


@interface Secret20_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * randomId;

+ (Secret20_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandomId:(NSNumber *)randomId ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret20_DecryptedMessageMedia *)media;
+ (Secret20_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId action:(Secret20_DecryptedMessageAction *)action;

@end

@interface Secret20_DecryptedMessage_decryptedMessage : Secret20_DecryptedMessage

@property (nonatomic, strong, readonly) NSNumber * ttl;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret20_DecryptedMessageMedia * media;

@end

@interface Secret20_DecryptedMessage_decryptedMessageService : Secret20_DecryptedMessage

@property (nonatomic, strong, readonly) Secret20_DecryptedMessageAction * action;

@end


@interface Secret20_DecryptedMessageMedia : NSObject

+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH fileName:(NSString *)fileName mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration mimeType:(NSString *)mimeType w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret20_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret20_DecryptedMessageMedia

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret20_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret20_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaContact : Secret20_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phoneNumber;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;
@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret20_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSString * fileName;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret20_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret20_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret20_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end


/*
 * Functions 20
 */

@interface Secret20: NSObject

@end
