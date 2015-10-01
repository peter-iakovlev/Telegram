#import <Foundation/Foundation.h>

/*
 * Layer 23
 */

@class Secret23_DecryptedMessageAction;
@class Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages;
@class Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages;
@class Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory;
@class Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer;
@class Secret23_DecryptedMessageAction_decryptedMessageActionTyping;
@class Secret23_DecryptedMessageAction_decryptedMessageActionResend;
@class Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey;
@class Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey;
@class Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey;
@class Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey;
@class Secret23_DecryptedMessageAction_decryptedMessageActionNoop;

@class Secret23_SendMessageAction;
@class Secret23_SendMessageAction_sendMessageTypingAction;
@class Secret23_SendMessageAction_sendMessageCancelAction;
@class Secret23_SendMessageAction_sendMessageRecordVideoAction;
@class Secret23_SendMessageAction_sendMessageUploadVideoAction;
@class Secret23_SendMessageAction_sendMessageRecordAudioAction;
@class Secret23_SendMessageAction_sendMessageUploadAudioAction;
@class Secret23_SendMessageAction_sendMessageUploadPhotoAction;
@class Secret23_SendMessageAction_sendMessageUploadDocumentAction;
@class Secret23_SendMessageAction_sendMessageGeoLocationAction;
@class Secret23_SendMessageAction_sendMessageChooseContactAction;

@class Secret23_PhotoSize;
@class Secret23_PhotoSize_photoSizeEmpty;
@class Secret23_PhotoSize_photoSize;
@class Secret23_PhotoSize_photoCachedSize;

@class Secret23_FileLocation;
@class Secret23_FileLocation_fileLocationUnavailable;
@class Secret23_FileLocation_fileLocation;

@class Secret23_DecryptedMessageLayer;
@class Secret23_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret23_DecryptedMessage;
@class Secret23_DecryptedMessage_decryptedMessage;
@class Secret23_DecryptedMessage_decryptedMessageService;

@class Secret23_DocumentAttribute;
@class Secret23_DocumentAttribute_documentAttributeImageSize;
@class Secret23_DocumentAttribute_documentAttributeAnimated;
@class Secret23_DocumentAttribute_documentAttributeSticker;
@class Secret23_DocumentAttribute_documentAttributeVideo;
@class Secret23_DocumentAttribute_documentAttributeAudio;
@class Secret23_DocumentAttribute_documentAttributeFilename;

@class Secret23_DecryptedMessageMedia;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio;
@class Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument;


@interface Secret23__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

@interface Secret23_FunctionContext : NSObject

@property (nonatomic, strong, readonly) NSData *payload;
@property (nonatomic, copy, readonly) id (^responseParser)(NSData *);
@property (nonatomic, strong, readonly) id metadata;

- (instancetype)initWithPayload:(NSData *)payload responseParser:(id (^)(NSData *))responseParser metadata:(id)metadata;

@end

/*
 * Types 23
 */

@interface Secret23_DecryptedMessageAction : NSObject

+ (Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret23_SendMessageAction *)action;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStartSeqNo:(NSNumber *)startSeqNo endSeqNo:(NSNumber *)endSeqNo;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchangeId:(NSNumber *)exchangeId gA:(NSData *)gA;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchangeId:(NSNumber *)exchangeId gB:(NSData *)gB keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchangeId:(NSNumber *)exchangeId keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchangeId:(NSNumber *)exchangeId;
+ (Secret23_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttlSeconds;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret23_DecryptedMessageAction

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionTyping : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) Secret23_SendMessageAction * action;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionResend : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * startSeqNo;
@property (nonatomic, strong, readonly) NSNumber * endSeqNo;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gA;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gB;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey : Secret23_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;

@end

@interface Secret23_DecryptedMessageAction_decryptedMessageActionNoop : Secret23_DecryptedMessageAction

@end


@interface Secret23_SendMessageAction : NSObject

+ (Secret23_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction;
+ (Secret23_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction;
+ (Secret23_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction;
+ (Secret23_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction;
+ (Secret23_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction;
+ (Secret23_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction;
+ (Secret23_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction;
+ (Secret23_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction;
+ (Secret23_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction;
+ (Secret23_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction;

@end

@interface Secret23_SendMessageAction_sendMessageTypingAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageCancelAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageRecordVideoAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageUploadVideoAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageRecordAudioAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageUploadAudioAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageUploadPhotoAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageUploadDocumentAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageGeoLocationAction : Secret23_SendMessageAction

@end

@interface Secret23_SendMessageAction_sendMessageChooseContactAction : Secret23_SendMessageAction

@end


@interface Secret23_PhotoSize : NSObject

@property (nonatomic, strong, readonly) NSString * type;

+ (Secret23_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type;
+ (Secret23_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(Secret23_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size;
+ (Secret23_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(Secret23_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes;

@end

@interface Secret23_PhotoSize_photoSizeEmpty : Secret23_PhotoSize

@end

@interface Secret23_PhotoSize_photoSize : Secret23_PhotoSize

@property (nonatomic, strong, readonly) Secret23_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;

@end

@interface Secret23_PhotoSize_photoCachedSize : Secret23_PhotoSize

@property (nonatomic, strong, readonly) Secret23_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSData * bytes;

@end


@interface Secret23_FileLocation : NSObject

@property (nonatomic, strong, readonly) NSNumber * volumeId;
@property (nonatomic, strong, readonly) NSNumber * localId;
@property (nonatomic, strong, readonly) NSNumber * secret;

+ (Secret23_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;
+ (Secret23_FileLocation_fileLocation *)fileLocationWithDcId:(NSNumber *)dcId volumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;

@end

@interface Secret23_FileLocation_fileLocationUnavailable : Secret23_FileLocation

@end

@interface Secret23_FileLocation_fileLocation : Secret23_FileLocation

@property (nonatomic, strong, readonly) NSNumber * dcId;

@end


@interface Secret23_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSData * randomBytes;
@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) NSNumber * inSeqNo;
@property (nonatomic, strong, readonly) NSNumber * outSeqNo;
@property (nonatomic, strong, readonly) Secret23_DecryptedMessage * message;

+ (Secret23_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandomBytes:(NSData *)randomBytes layer:(NSNumber *)layer inSeqNo:(NSNumber *)inSeqNo outSeqNo:(NSNumber *)outSeqNo message:(Secret23_DecryptedMessage *)message;

@end

@interface Secret23_DecryptedMessageLayer_decryptedMessageLayer : Secret23_DecryptedMessageLayer

@end


@interface Secret23_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * randomId;

+ (Secret23_DecryptedMessage_decryptedMessage *)decryptedMessageWithRandomId:(NSNumber *)randomId ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret23_DecryptedMessageMedia *)media;
+ (Secret23_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId action:(Secret23_DecryptedMessageAction *)action;

@end

@interface Secret23_DecryptedMessage_decryptedMessage : Secret23_DecryptedMessage

@property (nonatomic, strong, readonly) NSNumber * ttl;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret23_DecryptedMessageMedia * media;

@end

@interface Secret23_DecryptedMessage_decryptedMessageService : Secret23_DecryptedMessage

@property (nonatomic, strong, readonly) Secret23_DecryptedMessageAction * action;

@end


@interface Secret23_DocumentAttribute : NSObject

+ (Secret23_DocumentAttribute_documentAttributeImageSize *)documentAttributeImageSizeWithW:(NSNumber *)w h:(NSNumber *)h;
+ (Secret23_DocumentAttribute_documentAttributeAnimated *)documentAttributeAnimated;
+ (Secret23_DocumentAttribute_documentAttributeSticker *)documentAttributeSticker;
+ (Secret23_DocumentAttribute_documentAttributeVideo *)documentAttributeVideoWithDuration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h;
+ (Secret23_DocumentAttribute_documentAttributeAudio *)documentAttributeAudioWithDuration:(NSNumber *)duration;
+ (Secret23_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFileName:(NSString *)fileName;

@end

@interface Secret23_DocumentAttribute_documentAttributeImageSize : Secret23_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Secret23_DocumentAttribute_documentAttributeAnimated : Secret23_DocumentAttribute

@end

@interface Secret23_DocumentAttribute_documentAttributeSticker : Secret23_DocumentAttribute

@end

@interface Secret23_DocumentAttribute_documentAttributeVideo : Secret23_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Secret23_DocumentAttribute_documentAttributeAudio : Secret23_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * duration;

@end

@interface Secret23_DocumentAttribute_documentAttributeFilename : Secret23_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * fileName;

@end


@interface Secret23_DecryptedMessageMedia : NSObject

+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH fileName:(NSString *)fileName mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration mimeType:(NSString *)mimeType w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)decryptedMessageMediaExternalDocumentWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date mimeType:(NSString *)mimeType size:(NSNumber *)size thumb:(Secret23_PhotoSize *)thumb dcId:(NSNumber *)dcId attributes:(NSArray *)attributes;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret23_DecryptedMessageMedia

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaContact : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phoneNumber;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;
@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSString * fileName;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret23_DecryptedMessageMedia

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

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument : Secret23_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) Secret23_PhotoSize * thumb;
@property (nonatomic, strong, readonly) NSNumber * dcId;
@property (nonatomic, strong, readonly) NSArray * attributes;

@end


/*
 * Functions 23
 */

@interface Secret23: NSObject

@end
