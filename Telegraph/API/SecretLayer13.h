/*
 * Layer 13
 */

@class Secret13_DecryptedMessageLayer;
@class Secret13_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret13_DecryptedMessage;
@class Secret13_DecryptedMessage_decryptedMessage;
@class Secret13_DecryptedMessage_decryptedMessageService;

@class Secret13_DecryptedMessageMedia;
@class Secret13_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret13_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret13_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret13_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret13_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class Secret13_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret13_DecryptedMessageMedia_decryptedMessageMediaAudio;

@class Secret13_DecryptedMessageAction;
@class Secret13_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class Secret13_DecryptedMessageAction_decryptedMessageActionReadMessages;
@class Secret13_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class Secret13_DecryptedMessageAction_decryptedMessageActionScreenshotMessages;
@class Secret13_DecryptedMessageAction_decryptedMessageActionFlushHistory;
@class Secret13_DecryptedMessageAction_decryptedMessageActionNotifyLayer;


@interface Secret13__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

/*
 * Types 13
 */

@interface Secret13_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) Secret13_DecryptedMessage * message;

+ (Secret13_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithLayer:(NSNumber *)layer message:(Secret13_DecryptedMessage *)message;

@end

@interface Secret13_DecryptedMessageLayer_decryptedMessageLayer : Secret13_DecryptedMessageLayer

@end


@interface Secret13_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * random_id;
@property (nonatomic, strong, readonly) NSData * random_bytes;

+ (Secret13_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes message:(NSString *)message media:(Secret13_DecryptedMessageMedia *)media;
+ (Secret13_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes action:(Secret13_DecryptedMessageAction *)action;

@end

@interface Secret13_DecryptedMessage_decryptedMessage : Secret13_DecryptedMessage

@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret13_DecryptedMessageMedia * media;

@end

@interface Secret13_DecryptedMessage_decryptedMessageService : Secret13_DecryptedMessage

@property (nonatomic, strong, readonly) Secret13_DecryptedMessageAction * action;

@end


@interface Secret13_DecryptedMessageMedia : NSObject

+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id;
+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration mime_type:(NSString *)mime_type w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret13_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret13_DecryptedMessageMedia

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret13_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret13_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaContact : Secret13_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phone_number;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret13_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSString * file_name;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret13_DecryptedMessageMedia

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

@interface Secret13_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret13_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end


@interface Secret13_DecryptedMessageAction : NSObject

+ (Secret13_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds;
+ (Secret13_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret13_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret13_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret13_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret13_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret13_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttl_seconds;

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret13_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret13_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret13_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret13_DecryptedMessageAction

@end

@interface Secret13_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret13_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end


/*
 * Functions 13
 */

