#import <Foundation/Foundation.h>

/*
 * Layer 73
 */

@class Secret73_DecryptedMessageAction;
@class Secret73_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class Secret73_DecryptedMessageAction_decryptedMessageActionReadMessages;
@class Secret73_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class Secret73_DecryptedMessageAction_decryptedMessageActionScreenshotMessages;
@class Secret73_DecryptedMessageAction_decryptedMessageActionFlushHistory;
@class Secret73_DecryptedMessageAction_decryptedMessageActionNotifyLayer;
@class Secret73_DecryptedMessageAction_decryptedMessageActionResend;
@class Secret73_DecryptedMessageAction_decryptedMessageActionRequestKey;
@class Secret73_DecryptedMessageAction_decryptedMessageActionAcceptKey;
@class Secret73_DecryptedMessageAction_decryptedMessageActionAbortKey;
@class Secret73_DecryptedMessageAction_decryptedMessageActionCommitKey;
@class Secret73_DecryptedMessageAction_decryptedMessageActionNoop;

@class Secret73_PhotoSize;
@class Secret73_PhotoSize_photoSizeEmpty;
@class Secret73_PhotoSize_photoSize;
@class Secret73_PhotoSize_photoCachedSize;

@class Secret73_FileLocation;
@class Secret73_FileLocation_fileLocationUnavailable;
@class Secret73_FileLocation_fileLocation;

@class Secret73_DecryptedMessageLayer;
@class Secret73_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret73_DecryptedMessage;
@class Secret73_DecryptedMessage_decryptedMessageService;
@class Secret73_DecryptedMessage_decryptedMessage;

@class Secret73_DocumentAttribute;
@class Secret73_DocumentAttribute_documentAttributeImageSize;
@class Secret73_DocumentAttribute_documentAttributeAnimated;
@class Secret73_DocumentAttribute_documentAttributeFilename;
@class Secret73_DocumentAttribute_documentAttributeSticker;
@class Secret73_DocumentAttribute_documentAttributeAudio;
@class Secret73_DocumentAttribute_documentAttributeVideo;

@class Secret73_InputStickerSet;
@class Secret73_InputStickerSet_inputStickerSetShortName;
@class Secret73_InputStickerSet_inputStickerSetEmpty;

@class Secret73_MessageEntity;
@class Secret73_MessageEntity_messageEntityUnknown;
@class Secret73_MessageEntity_messageEntityMention;
@class Secret73_MessageEntity_messageEntityHashtag;
@class Secret73_MessageEntity_messageEntityBotCommand;
@class Secret73_MessageEntity_messageEntityUrl;
@class Secret73_MessageEntity_messageEntityEmail;
@class Secret73_MessageEntity_messageEntityBold;
@class Secret73_MessageEntity_messageEntityItalic;
@class Secret73_MessageEntity_messageEntityCode;
@class Secret73_MessageEntity_messageEntityPre;
@class Secret73_MessageEntity_messageEntityTextUrl;

@class Secret73_DecryptedMessageMedia;
@class Secret73_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret73_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret73_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret73_DecryptedMessageMedia_decryptedMessageMediaAudio;
@class Secret73_DecryptedMessageMedia_decryptedMessageMediaExternalDocument;
@class Secret73_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret73_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class Secret73_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret73_DecryptedMessageMedia_decryptedMessageMediaVenue;
@class Secret73_DecryptedMessageMedia_decryptedMessageMediaWebPage;


@interface Secret73__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

@interface Secret73_FunctionContext : NSObject

@property (nonatomic, strong, readonly) NSData *payload;
@property (nonatomic, copy, readonly) id (^responseParser)(NSData *);
@property (nonatomic, strong, readonly) id metadata;

- (instancetype)initWithPayload:(NSData *)payload responseParser:(id (^)(NSData *))responseParser metadata:(id)metadata;

@end

/*
 * Types 73
 */

@interface Secret73_DecryptedMessageAction : NSObject

+ (Secret73_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds;
+ (Secret73_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret73_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret73_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret73_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret73_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;
+ (Secret73_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStartSeqNo:(NSNumber *)startSeqNo endSeqNo:(NSNumber *)endSeqNo;
+ (Secret73_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchangeId:(NSNumber *)exchangeId gA:(NSData *)gA;
+ (Secret73_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchangeId:(NSNumber *)exchangeId gB:(NSData *)gB keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret73_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchangeId:(NSNumber *)exchangeId;
+ (Secret73_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchangeId:(NSNumber *)exchangeId keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret73_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret73_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttlSeconds;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret73_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret73_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret73_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret73_DecryptedMessageAction

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret73_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionResend : Secret73_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * startSeqNo;
@property (nonatomic, strong, readonly) NSNumber * endSeqNo;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionRequestKey : Secret73_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gA;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionAcceptKey : Secret73_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gB;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionAbortKey : Secret73_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionCommitKey : Secret73_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret73_DecryptedMessageAction_decryptedMessageActionNoop : Secret73_DecryptedMessageAction

@end


@interface Secret73_PhotoSize : NSObject

@property (nonatomic, strong, readonly) NSString * type;

+ (Secret73_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type;
+ (Secret73_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(Secret73_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size;
+ (Secret73_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(Secret73_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes;

@end

@interface Secret73_PhotoSize_photoSizeEmpty : Secret73_PhotoSize

@end

@interface Secret73_PhotoSize_photoSize : Secret73_PhotoSize

@property (nonatomic, strong, readonly) Secret73_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;

@end

@interface Secret73_PhotoSize_photoCachedSize : Secret73_PhotoSize

@property (nonatomic, strong, readonly) Secret73_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSData * bytes;

@end


@interface Secret73_FileLocation : NSObject

@property (nonatomic, strong, readonly) NSNumber * volumeId;
@property (nonatomic, strong, readonly) NSNumber * localId;
@property (nonatomic, strong, readonly) NSNumber * secret;

+ (Secret73_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;
+ (Secret73_FileLocation_fileLocation *)fileLocationWithDcId:(NSNumber *)dcId volumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;

@end

@interface Secret73_FileLocation_fileLocationUnavailable : Secret73_FileLocation

@end

@interface Secret73_FileLocation_fileLocation : Secret73_FileLocation

@property (nonatomic, strong, readonly) NSNumber * dcId;

@end


@interface Secret73_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSData * randomBytes;
@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) NSNumber * inSeqNo;
@property (nonatomic, strong, readonly) NSNumber * outSeqNo;
@property (nonatomic, strong, readonly) Secret73_DecryptedMessage * message;

+ (Secret73_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandomBytes:(NSData *)randomBytes layer:(NSNumber *)layer inSeqNo:(NSNumber *)inSeqNo outSeqNo:(NSNumber *)outSeqNo message:(Secret73_DecryptedMessage *)message;

@end

@interface Secret73_DecryptedMessageLayer_decryptedMessageLayer : Secret73_DecryptedMessageLayer

@end


@interface Secret73_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * randomId;

+ (Secret73_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId action:(Secret73_DecryptedMessageAction *)action;
+ (Secret73_DecryptedMessage_decryptedMessage *)decryptedMessageWithFlags:(NSNumber *)flags randomId:(NSNumber *)randomId ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret73_DecryptedMessageMedia *)media entities:(NSArray *)entities viaBotName:(NSString *)viaBotName replyToRandomId:(NSNumber *)replyToRandomId groupedId:(NSNumber *)groupedId;

@end

@interface Secret73_DecryptedMessage_decryptedMessageService : Secret73_DecryptedMessage

@property (nonatomic, strong, readonly) Secret73_DecryptedMessageAction * action;

@end

@interface Secret73_DecryptedMessage_decryptedMessage : Secret73_DecryptedMessage

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * ttl;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret73_DecryptedMessageMedia * media;
@property (nonatomic, strong, readonly) NSArray * entities;
@property (nonatomic, strong, readonly) NSString * viaBotName;
@property (nonatomic, strong, readonly) NSNumber * replyToRandomId;
@property (nonatomic, strong, readonly) NSNumber * groupedId;

@end


@interface Secret73_DocumentAttribute : NSObject

+ (Secret73_DocumentAttribute_documentAttributeImageSize *)documentAttributeImageSizeWithW:(NSNumber *)w h:(NSNumber *)h;
+ (Secret73_DocumentAttribute_documentAttributeAnimated *)documentAttributeAnimated;
+ (Secret73_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFileName:(NSString *)fileName;
+ (Secret73_DocumentAttribute_documentAttributeSticker *)documentAttributeStickerWithAlt:(NSString *)alt stickerset:(Secret73_InputStickerSet *)stickerset;
+ (Secret73_DocumentAttribute_documentAttributeAudio *)documentAttributeAudioWithFlags:(NSNumber *)flags duration:(NSNumber *)duration title:(NSString *)title performer:(NSString *)performer waveform:(NSData *)waveform;
+ (Secret73_DocumentAttribute_documentAttributeVideo *)documentAttributeVideoWithFlags:(NSNumber *)flags duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h;

@end

@interface Secret73_DocumentAttribute_documentAttributeImageSize : Secret73_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Secret73_DocumentAttribute_documentAttributeAnimated : Secret73_DocumentAttribute

@end

@interface Secret73_DocumentAttribute_documentAttributeFilename : Secret73_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * fileName;

@end

@interface Secret73_DocumentAttribute_documentAttributeSticker : Secret73_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * alt;
@property (nonatomic, strong, readonly) Secret73_InputStickerSet * stickerset;

@end

@interface Secret73_DocumentAttribute_documentAttributeAudio : Secret73_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * performer;
@property (nonatomic, strong, readonly) NSData * waveform;

@end

@interface Secret73_DocumentAttribute_documentAttributeVideo : Secret73_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end


@interface Secret73_InputStickerSet : NSObject

+ (Secret73_InputStickerSet_inputStickerSetShortName *)inputStickerSetShortNameWithShortName:(NSString *)shortName;
+ (Secret73_InputStickerSet_inputStickerSetEmpty *)inputStickerSetEmpty;

@end

@interface Secret73_InputStickerSet_inputStickerSetShortName : Secret73_InputStickerSet

@property (nonatomic, strong, readonly) NSString * shortName;

@end

@interface Secret73_InputStickerSet_inputStickerSetEmpty : Secret73_InputStickerSet

@end


@interface Secret73_MessageEntity : NSObject

@property (nonatomic, strong, readonly) NSNumber * offset;
@property (nonatomic, strong, readonly) NSNumber * length;

+ (Secret73_MessageEntity_messageEntityUnknown *)messageEntityUnknownWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret73_MessageEntity_messageEntityMention *)messageEntityMentionWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret73_MessageEntity_messageEntityHashtag *)messageEntityHashtagWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret73_MessageEntity_messageEntityBotCommand *)messageEntityBotCommandWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret73_MessageEntity_messageEntityUrl *)messageEntityUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret73_MessageEntity_messageEntityEmail *)messageEntityEmailWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret73_MessageEntity_messageEntityBold *)messageEntityBoldWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret73_MessageEntity_messageEntityItalic *)messageEntityItalicWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret73_MessageEntity_messageEntityCode *)messageEntityCodeWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret73_MessageEntity_messageEntityPre *)messageEntityPreWithOffset:(NSNumber *)offset length:(NSNumber *)length language:(NSString *)language;
+ (Secret73_MessageEntity_messageEntityTextUrl *)messageEntityTextUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length url:(NSString *)url;

@end

@interface Secret73_MessageEntity_messageEntityUnknown : Secret73_MessageEntity

@end

@interface Secret73_MessageEntity_messageEntityMention : Secret73_MessageEntity

@end

@interface Secret73_MessageEntity_messageEntityHashtag : Secret73_MessageEntity

@end

@interface Secret73_MessageEntity_messageEntityBotCommand : Secret73_MessageEntity

@end

@interface Secret73_MessageEntity_messageEntityUrl : Secret73_MessageEntity

@end

@interface Secret73_MessageEntity_messageEntityEmail : Secret73_MessageEntity

@end

@interface Secret73_MessageEntity_messageEntityBold : Secret73_MessageEntity

@end

@interface Secret73_MessageEntity_messageEntityItalic : Secret73_MessageEntity

@end

@interface Secret73_MessageEntity_messageEntityCode : Secret73_MessageEntity

@end

@interface Secret73_MessageEntity_messageEntityPre : Secret73_MessageEntity

@property (nonatomic, strong, readonly) NSString * language;

@end

@interface Secret73_MessageEntity_messageEntityTextUrl : Secret73_MessageEntity

@property (nonatomic, strong, readonly) NSString * url;

@end


@interface Secret73_DecryptedMessageMedia : NSObject

+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId;
+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)decryptedMessageMediaExternalDocumentWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date mimeType:(NSString *)mimeType size:(NSNumber *)size thumb:(Secret73_PhotoSize *)thumb dcId:(NSNumber *)dcId attributes:(NSArray *)attributes;
+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv caption:(NSString *)caption;
+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv attributes:(NSArray *)attributes caption:(NSString *)caption;
+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration mimeType:(NSString *)mimeType w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv caption:(NSString *)caption;
+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaVenue *)decryptedMessageMediaVenueWithLat:(NSNumber *)lat plong:(NSNumber *)plong title:(NSString *)title address:(NSString *)address provider:(NSString *)provider venueId:(NSString *)venueId;
+ (Secret73_DecryptedMessageMedia_decryptedMessageMediaWebPage *)decryptedMessageMediaWebPageWithUrl:(NSString *)url;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret73_DecryptedMessageMedia

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret73_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaContact : Secret73_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phoneNumber;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;
@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret73_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaExternalDocument : Secret73_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) Secret73_PhotoSize * thumb;
@property (nonatomic, strong, readonly) NSNumber * dcId;
@property (nonatomic, strong, readonly) NSArray * attributes;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret73_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;
@property (nonatomic, strong, readonly) NSString * caption;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret73_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSData * thumb;
@property (nonatomic, strong, readonly) NSNumber * thumbW;
@property (nonatomic, strong, readonly) NSNumber * thumbH;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;
@property (nonatomic, strong, readonly) NSArray * attributes;
@property (nonatomic, strong, readonly) NSString * caption;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret73_DecryptedMessageMedia

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
@property (nonatomic, strong, readonly) NSString * caption;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaVenue : Secret73_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * address;
@property (nonatomic, strong, readonly) NSString * provider;
@property (nonatomic, strong, readonly) NSString * venueId;

@end

@interface Secret73_DecryptedMessageMedia_decryptedMessageMediaWebPage : Secret73_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * url;

@end


/*
 * Functions 73
 */

@interface Secret73: NSObject

@end
