/*
 * Layer 8
 */

@class Secret8_DecryptedMessageLayer;
@class Secret8_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret8_DecryptedMessage;
@class Secret8_DecryptedMessage_decryptedMessage;
@class Secret8_DecryptedMessage_decryptedMessageService;

@class Secret8_DecryptedMessageMedia;
@class Secret8_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret8_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret8_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret8_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret8_DecryptedMessageMedia_decryptedMessageMediaContact;

@class Secret8_DecryptedMessageAction;
@class Secret8_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;


@interface Secret8__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

/*
 * Types 8
 */

@interface Secret8_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) Secret8_DecryptedMessage * message;

+ (Secret8_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithLayer:(NSNumber *)layer message:(Secret8_DecryptedMessage *)message;

@end

@interface Secret8_DecryptedMessageLayer_decryptedMessageLayer : Secret8_DecryptedMessageLayer

@end


@interface Secret8_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * random_id;
@property (nonatomic, strong, readonly) NSData * random_bytes;

+ (Secret8_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes message:(NSString *)message media:(Secret8_DecryptedMessageMedia *)media;
+ (Secret8_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandom_id:(NSNumber *)random_id random_bytes:(NSData *)random_bytes action:(Secret8_DecryptedMessageAction *)action;

@end

@interface Secret8_DecryptedMessage_decryptedMessage : Secret8_DecryptedMessage

@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret8_DecryptedMessageMedia * media;

@end

@interface Secret8_DecryptedMessage_decryptedMessageService : Secret8_DecryptedMessage

@property (nonatomic, strong, readonly) Secret8_DecryptedMessageAction * action;

@end


@interface Secret8_DecryptedMessageMedia : NSObject

+ (Secret8_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret8_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret8_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumb_w:(NSNumber *)thumb_w thumb_h:(NSNumber *)thumb_h duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret8_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret8_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhone_number:(NSString *)phone_number first_name:(NSString *)first_name last_name:(NSString *)last_name user_id:(NSNumber *)user_id;

@end

@interface Secret8_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret8_DecryptedMessageMedia

@end

@interface Secret8_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret8_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumb_w;
@property (nonatomic, strong, readonly) NSNumber * thumb_h;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret8_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret8_DecryptedMessageMedia

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

@interface Secret8_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret8_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret8_DecryptedMessageMedia_decryptedMessageMediaContact : Secret8_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phone_number;
@property (nonatomic, strong, readonly) NSString * first_name;
@property (nonatomic, strong, readonly) NSString * last_name;
@property (nonatomic, strong, readonly) NSNumber * user_id;

@end


@interface Secret8_DecryptedMessageAction : NSObject

@property (nonatomic, strong, readonly) NSNumber * ttl_seconds;

+ (Secret8_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtl_seconds:(NSNumber *)ttl_seconds;

@end

@interface Secret8_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret8_DecryptedMessageAction

@end


/*
 * Functions 8
 */

