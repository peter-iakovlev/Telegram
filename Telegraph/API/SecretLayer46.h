#import <Foundation/Foundation.h>

/*
 * Layer 46
 */

@class Secret46_DecryptedMessageAction;
@class Secret46_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class Secret46_DecryptedMessageAction_decryptedMessageActionReadMessages;
@class Secret46_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class Secret46_DecryptedMessageAction_decryptedMessageActionScreenshotMessages;
@class Secret46_DecryptedMessageAction_decryptedMessageActionFlushHistory;
@class Secret46_DecryptedMessageAction_decryptedMessageActionNotifyLayer;
@class Secret46_DecryptedMessageAction_decryptedMessageActionTyping;
@class Secret46_DecryptedMessageAction_decryptedMessageActionResend;
@class Secret46_DecryptedMessageAction_decryptedMessageActionRequestKey;
@class Secret46_DecryptedMessageAction_decryptedMessageActionAcceptKey;
@class Secret46_DecryptedMessageAction_decryptedMessageActionCommitKey;
@class Secret46_DecryptedMessageAction_decryptedMessageActionAbortKey;
@class Secret46_DecryptedMessageAction_decryptedMessageActionNoop;

@class Secret46_SendMessageAction;
@class Secret46_SendMessageAction_sendMessageTypingAction;
@class Secret46_SendMessageAction_sendMessageCancelAction;
@class Secret46_SendMessageAction_sendMessageRecordVideoAction;
@class Secret46_SendMessageAction_sendMessageUploadVideoAction;
@class Secret46_SendMessageAction_sendMessageRecordAudioAction;
@class Secret46_SendMessageAction_sendMessageUploadAudioAction;
@class Secret46_SendMessageAction_sendMessageUploadPhotoAction;
@class Secret46_SendMessageAction_sendMessageUploadDocumentAction;
@class Secret46_SendMessageAction_sendMessageGeoLocationAction;
@class Secret46_SendMessageAction_sendMessageChooseContactAction;

@class Secret46_PhotoSize;
@class Secret46_PhotoSize_photoSizeEmpty;
@class Secret46_PhotoSize_photoSize;
@class Secret46_PhotoSize_photoCachedSize;

@class Secret46_FileLocation;
@class Secret46_FileLocation_fileLocationUnavailable;
@class Secret46_FileLocation_fileLocation;

@class Secret46_DecryptedMessageLayer;
@class Secret46_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret46_DecryptedMessage;
@class Secret46_DecryptedMessage_decryptedMessageService;
@class Secret46_DecryptedMessage_decryptedMessage;

@class Secret46_DocumentAttribute;
@class Secret46_DocumentAttribute_documentAttributeImageSize;
@class Secret46_DocumentAttribute_documentAttributeAnimated;
@class Secret46_DocumentAttribute_documentAttributeVideo;
@class Secret46_DocumentAttribute_documentAttributeFilename;
@class Secret46_DocumentAttribute_documentAttributeSticker;
@class Secret46_DocumentAttribute_documentAttributeAudio;

@class Secret46_InputStickerSet;
@class Secret46_InputStickerSet_inputStickerSetShortName;
@class Secret46_InputStickerSet_inputStickerSetEmpty;

@class Secret46_MessageEntity;
@class Secret46_MessageEntity_messageEntityUnknown;
@class Secret46_MessageEntity_messageEntityMention;
@class Secret46_MessageEntity_messageEntityHashtag;
@class Secret46_MessageEntity_messageEntityBotCommand;
@class Secret46_MessageEntity_messageEntityUrl;
@class Secret46_MessageEntity_messageEntityEmail;
@class Secret46_MessageEntity_messageEntityBold;
@class Secret46_MessageEntity_messageEntityItalic;
@class Secret46_MessageEntity_messageEntityCode;
@class Secret46_MessageEntity_messageEntityPre;
@class Secret46_MessageEntity_messageEntityTextUrl;

@class Secret46_DecryptedMessageMedia;
@class Secret46_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret46_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret46_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret46_DecryptedMessageMedia_decryptedMessageMediaAudio;
@class Secret46_DecryptedMessageMedia_decryptedMessageMediaExternalDocument;
@class Secret46_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret46_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class Secret46_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret46_DecryptedMessageMedia_decryptedMessageMediaVenue;
@class Secret46_DecryptedMessageMedia_decryptedMessageMediaWebPage;


@interface Secret46__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

@interface Secret46_FunctionContext : NSObject

@property (nonatomic, strong, readonly) NSData *payload;
@property (nonatomic, copy, readonly) id (^responseParser)(NSData *);
@property (nonatomic, strong, readonly) id metadata;

- (instancetype)initWithPayload:(NSData *)payload responseParser:(id (^)(NSData *))responseParser metadata:(id)metadata;

@end

/*
 * Types 46
 */

@interface Secret46_DecryptedMessageAction : NSObject

+ (Secret46_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret46_SendMessageAction *)action;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStartSeqNo:(NSNumber *)startSeqNo endSeqNo:(NSNumber *)endSeqNo;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchangeId:(NSNumber *)exchangeId gA:(NSData *)gA;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchangeId:(NSNumber *)exchangeId gB:(NSData *)gB keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchangeId:(NSNumber *)exchangeId keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchangeId:(NSNumber *)exchangeId;
+ (Secret46_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret46_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttlSeconds;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret46_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret46_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret46_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret46_DecryptedMessageAction

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret46_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionTyping : Secret46_DecryptedMessageAction

@property (nonatomic, strong, readonly) Secret46_SendMessageAction * action;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionResend : Secret46_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * startSeqNo;
@property (nonatomic, strong, readonly) NSNumber * endSeqNo;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionRequestKey : Secret46_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gA;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionAcceptKey : Secret46_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gB;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionCommitKey : Secret46_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionAbortKey : Secret46_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;

@end

@interface Secret46_DecryptedMessageAction_decryptedMessageActionNoop : Secret46_DecryptedMessageAction

@end


@interface Secret46_SendMessageAction : NSObject

+ (Secret46_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction;
+ (Secret46_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction;
+ (Secret46_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction;
+ (Secret46_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction;
+ (Secret46_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction;
+ (Secret46_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction;
+ (Secret46_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction;
+ (Secret46_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction;
+ (Secret46_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction;
+ (Secret46_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction;

@end

@interface Secret46_SendMessageAction_sendMessageTypingAction : Secret46_SendMessageAction

@end

@interface Secret46_SendMessageAction_sendMessageCancelAction : Secret46_SendMessageAction

@end

@interface Secret46_SendMessageAction_sendMessageRecordVideoAction : Secret46_SendMessageAction

@end

@interface Secret46_SendMessageAction_sendMessageUploadVideoAction : Secret46_SendMessageAction

@end

@interface Secret46_SendMessageAction_sendMessageRecordAudioAction : Secret46_SendMessageAction

@end

@interface Secret46_SendMessageAction_sendMessageUploadAudioAction : Secret46_SendMessageAction

@end

@interface Secret46_SendMessageAction_sendMessageUploadPhotoAction : Secret46_SendMessageAction

@end

@interface Secret46_SendMessageAction_sendMessageUploadDocumentAction : Secret46_SendMessageAction

@end

@interface Secret46_SendMessageAction_sendMessageGeoLocationAction : Secret46_SendMessageAction

@end

@interface Secret46_SendMessageAction_sendMessageChooseContactAction : Secret46_SendMessageAction

@end


@interface Secret46_PhotoSize : NSObject

@property (nonatomic, strong, readonly) NSString * type;

+ (Secret46_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type;
+ (Secret46_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(Secret46_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size;
+ (Secret46_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(Secret46_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes;

@end

@interface Secret46_PhotoSize_photoSizeEmpty : Secret46_PhotoSize

@end

@interface Secret46_PhotoSize_photoSize : Secret46_PhotoSize

@property (nonatomic, strong, readonly) Secret46_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;

@end

@interface Secret46_PhotoSize_photoCachedSize : Secret46_PhotoSize

@property (nonatomic, strong, readonly) Secret46_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSData * bytes;

@end


@interface Secret46_FileLocation : NSObject

@property (nonatomic, strong, readonly) NSNumber * volumeId;
@property (nonatomic, strong, readonly) NSNumber * localId;
@property (nonatomic, strong, readonly) NSNumber * secret;

+ (Secret46_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;
+ (Secret46_FileLocation_fileLocation *)fileLocationWithDcId:(NSNumber *)dcId volumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;

@end

@interface Secret46_FileLocation_fileLocationUnavailable : Secret46_FileLocation

@end

@interface Secret46_FileLocation_fileLocation : Secret46_FileLocation

@property (nonatomic, strong, readonly) NSNumber * dcId;

@end


@interface Secret46_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSData * randomBytes;
@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) NSNumber * inSeqNo;
@property (nonatomic, strong, readonly) NSNumber * outSeqNo;
@property (nonatomic, strong, readonly) Secret46_DecryptedMessage * message;

+ (Secret46_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandomBytes:(NSData *)randomBytes layer:(NSNumber *)layer inSeqNo:(NSNumber *)inSeqNo outSeqNo:(NSNumber *)outSeqNo message:(Secret46_DecryptedMessage *)message;

@end

@interface Secret46_DecryptedMessageLayer_decryptedMessageLayer : Secret46_DecryptedMessageLayer

@end


@interface Secret46_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * randomId;

+ (Secret46_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId action:(Secret46_DecryptedMessageAction *)action;
+ (Secret46_DecryptedMessage_decryptedMessage *)decryptedMessageWithFlags:(NSNumber *)flags randomId:(NSNumber *)randomId ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret46_DecryptedMessageMedia *)media entities:(NSArray *)entities viaBotName:(NSString *)viaBotName replyToRandomId:(NSNumber *)replyToRandomId;

@end

@interface Secret46_DecryptedMessage_decryptedMessageService : Secret46_DecryptedMessage

@property (nonatomic, strong, readonly) Secret46_DecryptedMessageAction * action;

@end

@interface Secret46_DecryptedMessage_decryptedMessage : Secret46_DecryptedMessage

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * ttl;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret46_DecryptedMessageMedia * media;
@property (nonatomic, strong, readonly) NSArray * entities;
@property (nonatomic, strong, readonly) NSString * viaBotName;
@property (nonatomic, strong, readonly) NSNumber * replyToRandomId;

@end


@interface Secret46_DocumentAttribute : NSObject

+ (Secret46_DocumentAttribute_documentAttributeImageSize *)documentAttributeImageSizeWithW:(NSNumber *)w h:(NSNumber *)h;
+ (Secret46_DocumentAttribute_documentAttributeAnimated *)documentAttributeAnimated;
+ (Secret46_DocumentAttribute_documentAttributeVideo *)documentAttributeVideoWithDuration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h;
+ (Secret46_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFileName:(NSString *)fileName;
+ (Secret46_DocumentAttribute_documentAttributeSticker *)documentAttributeStickerWithAlt:(NSString *)alt stickerset:(Secret46_InputStickerSet *)stickerset;
+ (Secret46_DocumentAttribute_documentAttributeAudio *)documentAttributeAudioWithFlags:(NSNumber *)flags duration:(NSNumber *)duration title:(NSString *)title performer:(NSString *)performer waveform:(NSData *)waveform;

@end

@interface Secret46_DocumentAttribute_documentAttributeImageSize : Secret46_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Secret46_DocumentAttribute_documentAttributeAnimated : Secret46_DocumentAttribute

@end

@interface Secret46_DocumentAttribute_documentAttributeVideo : Secret46_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Secret46_DocumentAttribute_documentAttributeFilename : Secret46_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * fileName;

@end

@interface Secret46_DocumentAttribute_documentAttributeSticker : Secret46_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * alt;
@property (nonatomic, strong, readonly) Secret46_InputStickerSet * stickerset;

@end

@interface Secret46_DocumentAttribute_documentAttributeAudio : Secret46_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * performer;
@property (nonatomic, strong, readonly) NSData * waveform;

@end


@interface Secret46_InputStickerSet : NSObject

+ (Secret46_InputStickerSet_inputStickerSetShortName *)inputStickerSetShortNameWithShortName:(NSString *)shortName;
+ (Secret46_InputStickerSet_inputStickerSetEmpty *)inputStickerSetEmpty;

@end

@interface Secret46_InputStickerSet_inputStickerSetShortName : Secret46_InputStickerSet

@property (nonatomic, strong, readonly) NSString * shortName;

@end

@interface Secret46_InputStickerSet_inputStickerSetEmpty : Secret46_InputStickerSet

@end


@interface Secret46_MessageEntity : NSObject

@property (nonatomic, strong, readonly) NSNumber * offset;
@property (nonatomic, strong, readonly) NSNumber * length;

+ (Secret46_MessageEntity_messageEntityUnknown *)messageEntityUnknownWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret46_MessageEntity_messageEntityMention *)messageEntityMentionWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret46_MessageEntity_messageEntityHashtag *)messageEntityHashtagWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret46_MessageEntity_messageEntityBotCommand *)messageEntityBotCommandWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret46_MessageEntity_messageEntityUrl *)messageEntityUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret46_MessageEntity_messageEntityEmail *)messageEntityEmailWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret46_MessageEntity_messageEntityBold *)messageEntityBoldWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret46_MessageEntity_messageEntityItalic *)messageEntityItalicWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret46_MessageEntity_messageEntityCode *)messageEntityCodeWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret46_MessageEntity_messageEntityPre *)messageEntityPreWithOffset:(NSNumber *)offset length:(NSNumber *)length language:(NSString *)language;
+ (Secret46_MessageEntity_messageEntityTextUrl *)messageEntityTextUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length url:(NSString *)url;

@end

@interface Secret46_MessageEntity_messageEntityUnknown : Secret46_MessageEntity

@end

@interface Secret46_MessageEntity_messageEntityMention : Secret46_MessageEntity

@end

@interface Secret46_MessageEntity_messageEntityHashtag : Secret46_MessageEntity

@end

@interface Secret46_MessageEntity_messageEntityBotCommand : Secret46_MessageEntity

@end

@interface Secret46_MessageEntity_messageEntityUrl : Secret46_MessageEntity

@end

@interface Secret46_MessageEntity_messageEntityEmail : Secret46_MessageEntity

@end

@interface Secret46_MessageEntity_messageEntityBold : Secret46_MessageEntity

@end

@interface Secret46_MessageEntity_messageEntityItalic : Secret46_MessageEntity

@end

@interface Secret46_MessageEntity_messageEntityCode : Secret46_MessageEntity

@end

@interface Secret46_MessageEntity_messageEntityPre : Secret46_MessageEntity

@property (nonatomic, strong, readonly) NSString * language;

@end

@interface Secret46_MessageEntity_messageEntityTextUrl : Secret46_MessageEntity

@property (nonatomic, strong, readonly) NSString * url;

@end


@interface Secret46_DecryptedMessageMedia : NSObject

+ (Secret46_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret46_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret46_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId;
+ (Secret46_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret46_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)decryptedMessageMediaExternalDocumentWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date mimeType:(NSString *)mimeType size:(NSNumber *)size thumb:(Secret46_PhotoSize *)thumb dcId:(NSNumber *)dcId attributes:(NSArray *)attributes;
+ (Secret46_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv caption:(NSString *)caption;
+ (Secret46_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv attributes:(NSArray *)attributes caption:(NSString *)caption;
+ (Secret46_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration mimeType:(NSString *)mimeType w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv caption:(NSString *)caption;
+ (Secret46_DecryptedMessageMedia_decryptedMessageMediaVenue *)decryptedMessageMediaVenueWithLat:(NSNumber *)lat plong:(NSNumber *)plong title:(NSString *)title address:(NSString *)address provider:(NSString *)provider venueId:(NSString *)venueId;
+ (Secret46_DecryptedMessageMedia_decryptedMessageMediaWebPage *)decryptedMessageMediaWebPageWithUrl:(NSString *)url;

@end

@interface Secret46_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret46_DecryptedMessageMedia

@end

@interface Secret46_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret46_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret46_DecryptedMessageMedia_decryptedMessageMediaContact : Secret46_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phoneNumber;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;
@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Secret46_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret46_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret46_DecryptedMessageMedia_decryptedMessageMediaExternalDocument : Secret46_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) Secret46_PhotoSize * thumb;
@property (nonatomic, strong, readonly) NSNumber * dcId;
@property (nonatomic, strong, readonly) NSArray * attributes;

@end

@interface Secret46_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret46_DecryptedMessageMedia

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

@interface Secret46_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret46_DecryptedMessageMedia

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

@interface Secret46_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret46_DecryptedMessageMedia

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

@interface Secret46_DecryptedMessageMedia_decryptedMessageMediaVenue : Secret46_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * address;
@property (nonatomic, strong, readonly) NSString * provider;
@property (nonatomic, strong, readonly) NSString * venueId;

@end

@interface Secret46_DecryptedMessageMedia_decryptedMessageMediaWebPage : Secret46_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * url;

@end


/*
 * Functions 46
 */

@interface Secret46: NSObject

@end
