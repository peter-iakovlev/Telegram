/*
 * Layer 1
 */

@class Secret1_DecryptedMessage;
@class Secret1_DecryptedMessage_decryptedMessage;
@class Secret1_DecryptedMessage_decryptedMessageService;

@class Secret1_DecryptedMessageMedia;
@class Secret1_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret1_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio;

@class Secret1_DecryptedMessageAction;
@class Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class Secret1_DecryptedMessageAction_decryptedMessageActionReadMessages;
@class Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class Secret1_DecryptedMessageAction_decryptedMessageActionScreenshotMessages;
@class Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory;
@class Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer;


@interface Secret1__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

/*
 * Types 1
 */

@interface Secret1_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * random_id;
@property (nonatomic, strong, readonly) NSData * random_bytes;

+ (Secret1_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes message:(NSString *)message media:(Secret1_DecryptedMessageMedia *)media;
+ (Secret1_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes action:(Secret1_DecryptedMessageAction *)action;

@end

@interface Secret1_DecryptedMessage_decryptedMessage : Secret1_DecryptedMessage

@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret1_DecryptedMessageMedia * media;

@end

@interface Secret1_DecryptedMessage_decryptedMessageService : Secret1_DecryptedMessage

@property (nonatomic, strong, readonly) Secret1_DecryptedMessageAction * action;

@end


@interface Secret1_DecryptedMessageMedia : NSObject

+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id;
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret1_DecryptedMessageMedia

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret1_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret1_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret1_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaContact : Secret1_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phone_number;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret1_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSString * file_name;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret1_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end


@interface Secret1_DecryptedMessageAction : NSObject

+ (Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds;
+ (Secret1_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret1_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandom_ids:(NSArray *)random_ids;
+ (Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret1_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttl_seconds;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret1_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret1_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret1_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * random_ids;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret1_DecryptedMessageAction

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret1_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end


/*
 * Functions 1
 */

