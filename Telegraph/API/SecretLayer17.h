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

/*
 * Types 17
 */

@interface Secret17_DecryptedMessageAction : NSObject

+ (Secret17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret17_SendMessageAction *)action;
+ (Secret17_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStart_seq_no:(NSNumber *)start_seq_no end_seq_no:(NSNumber *)end_seq_no;

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttl_seconds;

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret17_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

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

@property (nonatomic, strong, readonly) NSNumber * start_seq_no;
@property (nonatomic, strong, readonly) NSNumber * end_seq_no;

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

@property (nonatomic, strong, readonly) NSData * random_bytes;
@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) NSNumber * in_seq_no;
@property (nonatomic, strong, readonly) NSNumber * out_seq_no;
@property (nonatomic, strong, readonly) Secret17_DecryptedMessage * message;

+ (Secret17_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandom_bytes:(NSData *)random_bytes layer:(NSNumber *)layer in_seq_no:(NSNumber *)in_seq_no out_seq_no:(NSNumber *)out_seq_no message:(Secret17_DecryptedMessage *)message;

@end

@interface Secret17_DecryptedMessageLayer_decryptedMessageLayer : Secret17_DecryptedMessageLayer

@end


@interface Secret17_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * random_id;

+ (Secret17_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret17_DecryptedMessageMedia *)media;
+ (Secret17_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id action:(Secret17_DecryptedMessageAction *)action;

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
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id;
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration mime_type:(NSString *)mime_type w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret17_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;

@end

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret17_DecryptedMessageMedia

@end

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
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

@property (nonatomic, strong, readonly) NSString * phone_number;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSString * file_name;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret17_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret17_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end


/*
 * Functions 17
 */

