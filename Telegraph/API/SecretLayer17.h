#import <Foundation/Foundation.h>

/*
 * Layer 17
 */

@class Secret17_DecryptedMessageAction;
@class Secret17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class Secret17_DecryptedMessageAction_decryptedMessageActionReadMessages;
@class Secret17_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages;
@class Secret17_DecryptedMessageAction_decryptedMessageActionFlushHistory;
@class Secret17_DecryptedMessageAction_decryptedMessageActionNotifyLayer;
@class Secret17_DecryptedMessageAction_decryptedMessageActionTyping;
@class Secret17_DecryptedMessageAction_decryptedMessageActionResend;

@class Secret17_SendMessageAction;
@class Secret17_SendMessageAction_sendMessageTypingAction;
@class Secret17_SendMessageAction_sendMessageCancelAction;
@class Secret17_SendMessageAction_sendMessageRecordVideoAction;
@class Secret17_SendMessageAction_sendMessageUploadVideoAction;
@class Secret17_SendMessageAction_sendMessageRecordAudioAction;
@class Secret17_SendMessageAction_sendMessageUploadAudioAction;
@class Secret17_SendMessageAction_sendMessageUploadPhotoAction;
@class Secret17_SendMessageAction_sendMessageUploadDocumentAction;
@class Secret17_SendMessageAction_sendMessageGeoLocationAction;
@class Secret17_SendMessageAction_sendMessageChooseContactAction;

@class Secret17_DecryptedMessageLayer;
@class Secret17_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret17_DecryptedMessage;
@class Secret17_DecryptedMessage_decryptedMessage;
@class Secret17_DecryptedMessage_decryptedMessageService;

@class Secret17_DecryptedMessageMedia;
@class Secret17_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret17_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret17_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret17_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class Secret17_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret17_DecryptedMessageMedia_decryptedMessageMediaAudio;


@interface Secret17__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

@interface Secret17_FunctionContext : NSObject

@property (nonatomic, strong, readonly) NSData *payload;
@property (nonatomic, copy, readonly) id (^responseParser)(NSData *);
@property (nonatomic, strong, readonly) id metadata;

- (instancetype)initWithPayload:(NSData *)payload responseParser:(id (^)(NSData *))responseParser metadata:(id)metadata;

@end

/*
 * Types 17
 */

@interface Secret17_DecryptedMessageAction : NSObject

+ (Secret17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret17_SendMessageAction *)action;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStartSeqNo:(NSNumber *)startSeqNo endSeqNo:(NSNumber *)endSeqNo;

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttlSeconds;

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret17_DecryptedMessageAction

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionTyping : Secret17_DecryptedMessageAction

@property (nonatomic, strong, readonly) Secret17_SendMessageAction * action;

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionResend : Secret17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * startSeqNo;
@property (nonatomic, strong, readonly) NSNumber * endSeqNo;

@end


@interface Secret17_SendMessageAction : NSObject

+ (Secret17_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction;
+ (Secret17_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction;
+ (Secret17_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction;
+ (Secret17_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction;
+ (Secret17_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction;
+ (Secret17_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction;
+ (Secret17_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction;
+ (Secret17_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction;
+ (Secret17_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction;
+ (Secret17_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction;

@end

@interface Secret17_SendMessageAction_sendMessageTypingAction : Secret17_SendMessageAction

@end

@interface Secret17_SendMessageAction_sendMessageCancelAction : Secret17_SendMessageAction

@end

@interface Secret17_SendMessageAction_sendMessageRecordVideoAction : Secret17_SendMessageAction

@end

@interface Secret17_SendMessageAction_sendMessageUploadVideoAction : Secret17_SendMessageAction

@end

@interface Secret17_SendMessageAction_sendMessageRecordAudioAction : Secret17_SendMessageAction

@end

@interface Secret17_SendMessageAction_sendMessageUploadAudioAction : Secret17_SendMessageAction

@end

@interface Secret17_SendMessageAction_sendMessageUploadPhotoAction : Secret17_SendMessageAction

@end

@interface Secret17_SendMessageAction_sendMessageUploadDocumentAction : Secret17_SendMessageAction

@end

@interface Secret17_SendMessageAction_sendMessageGeoLocationAction : Secret17_SendMessageAction

@end

@interface Secret17_SendMessageAction_sendMessageChooseContactAction : Secret17_SendMessageAction

@end


@interface Secret17_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSData * randomBytes;
@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) NSNumber * inSeqNo;
@property (nonatomic, strong, readonly) NSNumber * outSeqNo;
@property (nonatomic, strong, readonly) Secret17_DecryptedMessage * message;

+ (Secret17_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandomBytes:(NSData *)randomBytes layer:(NSNumber *)layer inSeqNo:(NSNumber *)inSeqNo outSeqNo:(NSNumber *)outSeqNo message:(Secret17_DecryptedMessage *)message;

@end

@interface Secret17_DecryptedMessageLayer_decryptedMessageLayer : Secret17_DecryptedMessageLayer

@end


@interface Secret17_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * randomId;

+ (Secret17_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandomId:(NSNumber *)randomId ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret17_DecryptedMessageMedia *)media;
+ (Secret17_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId action:(Secret17_DecryptedMessageAction *)action;

@end

@interface Secret17_DecryptedMessage_decryptedMessage : Secret17_DecryptedMessage

@property (nonatomic, strong, readonly) NSNumber * ttl;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret17_DecryptedMessageMedia * media;

@end

@interface Secret17_DecryptedMessage_decryptedMessageService : Secret17_DecryptedMessage

@property (nonatomic, strong, readonly) Secret17_DecryptedMessageAction * action;

@end


@interface Secret17_DecryptedMessageMedia : NSObject

+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId;
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH fileName:(NSString *)fileName mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration mimeType:(NSString *)mimeType w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;

@end

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret17_DecryptedMessageMedia

@end

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaContact : Secret17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phoneNumber;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;
@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSString * fileName;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret17_DecryptedMessageMedia

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

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end


/*
 * Functions 17
 */

@interface Secret17: NSObject

@end
