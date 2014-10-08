/*
 * Layer 10
 */

@class Secret10_DecryptedMessageLayer;
@class Secret10_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret10_DecryptedMessage;
@class Secret10_DecryptedMessage_decryptedMessage;
@class Secret10_DecryptedMessage_decryptedMessageService;

@class Secret10_DecryptedMessageMedia;
@class Secret10_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret10_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret10_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret10_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret10_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret10_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class Secret10_DecryptedMessageMedia_decryptedMessageMediaAudio;

@class Secret10_DecryptedMessageAction;
@class Secret10_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;


@interface Secret10__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

/*
 * Types 10
 */

@interface Secret10_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) Secret10_DecryptedMessage * message;

+ (Secret10_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithLayer:(NSNumber *)layer message:(Secret10_DecryptedMessage *)message;

@end

@interface Secret10_DecryptedMessageLayer_decryptedMessageLayer : Secret10_DecryptedMessageLayer

@end


@interface Secret10_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * random_id;
@property (nonatomic, strong, readonly) NSData * random_bytes;

+ (Secret10_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes message:(NSString *)message media:(Secret10_DecryptedMessageMedia *)media;
+ (Secret10_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes action:(Secret10_DecryptedMessageAction *)action;

@end

@interface Secret10_DecryptedMessage_decryptedMessage : Secret10_DecryptedMessage

@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret10_DecryptedMessageMedia * media;

@end

@interface Secret10_DecryptedMessage_decryptedMessageService : Secret10_DecryptedMessage

@property (nonatomic, strong, readonly) Secret10_DecryptedMessageAction * action;

@end


@interface Secret10_DecryptedMessageMedia : NSObject

+ (Secret10_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret10_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret10_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret10_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret10_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id;
+ (Secret10_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h file_name:(NSString *)file_name mime_type:(NSString *)mime_type size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret10_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;

@end

@interface Secret10_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret10_DecryptedMessageMedia

@end

@interface Secret10_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret10_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret10_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret10_DecryptedMessageMedia

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

@interface Secret10_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret10_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret10_DecryptedMessageMedia_decryptedMessageMediaContact : Secret10_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phone_number;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * user_id;

@end

@interface Secret10_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret10_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSString * file_name;
@property (nonatomic, strong, readonly) NSString * mime_type;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret10_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret10_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end


@interface Secret10_DecryptedMessageAction : NSObject

@property (nonatomic, strong, readonly) NSNumber * ttl_seconds;

+ (Secret10_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds;

@end

@interface Secret10_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret10_DecryptedMessageAction

@end


/*
 * Functions 10
 */

