#import <Foundation/Foundation.h>

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

@interface Secret1_FunctionContext : NSObject

@property (nonatomic, strong, readonly) NSData *payload;
@property (nonatomic, copy, readonly) id (^responseParser)(NSData *);
@property (nonatomic, strong, readonly) id metadata;

- (instancetype)initWithPayload:(NSData *)payload responseParser:(id (^)(NSData *))responseParser metadata:(id)metadata;

@end

/*
 * Types 1
 */

@interface Secret1_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * randomId;
@property (nonatomic, strong, readonly) NSData * randomBytes;

+ (Secret1_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandomId:(NSNumber *)randomId randomBytes:(NSData *)randomBytes message:(NSString *)message media:(Secret1_DecryptedMessageMedia *)media;
+ (Secret1_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId randomBytes:(NSData *)randomBytes action:(Secret1_DecryptedMessageAction *)action;

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
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId;
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH fileName:(NSString *)fileName mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret1_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret1_DecryptedMessageMedia

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret1_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret1_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
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

@property (nonatomic, strong, readonly) NSString * phoneNumber;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;
@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Secret1_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret1_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSString * fileName;
@property (nonatomic, strong, readonly) NSString * mimeType;
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

+ (Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds;
+ (Secret1_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret1_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret1_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttlSeconds;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret1_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret1_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret1_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret1_DecryptedMessageAction

@end

@interface Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret1_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end


/*
 * Functions 1
 */

@interface Secret1: NSObject

@end
