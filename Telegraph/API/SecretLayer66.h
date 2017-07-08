#import <Foundation/Foundation.h>

/*
 * Layer 46
 */

@class Secret66_DecryptedMessageAction;
@class Secret66_DecryptedMessageAction_decryptedMessageActionSetMessageTTL;
@class Secret66_DecryptedMessageAction_decryptedMessageActionReadMessages;
@class Secret66_DecryptedMessageAction_decryptedMessageActionDeleteMessages;
@class Secret66_DecryptedMessageAction_decryptedMessageActionScreenshotMessages;
@class Secret66_DecryptedMessageAction_decryptedMessageActionFlushHistory;
@class Secret66_DecryptedMessageAction_decryptedMessageActionNotifyLayer;
@class Secret66_DecryptedMessageAction_decryptedMessageActionTyping;
@class Secret66_DecryptedMessageAction_decryptedMessageActionResend;
@class Secret66_DecryptedMessageAction_decryptedMessageActionRequestKey;
@class Secret66_DecryptedMessageAction_decryptedMessageActionAcceptKey;
@class Secret66_DecryptedMessageAction_decryptedMessageActionCommitKey;
@class Secret66_DecryptedMessageAction_decryptedMessageActionAbortKey;
@class Secret66_DecryptedMessageAction_decryptedMessageActionNoop;

@class Secret66_SendMessageAction;
@class Secret66_SendMessageAction_sendMessageTypingAction;
@class Secret66_SendMessageAction_sendMessageCancelAction;
@class Secret66_SendMessageAction_sendMessageRecordVideoAction;
@class Secret66_SendMessageAction_sendMessageUploadVideoAction;
@class Secret66_SendMessageAction_sendMessageRecordAudioAction;
@class Secret66_SendMessageAction_sendMessageUploadAudioAction;
@class Secret66_SendMessageAction_sendMessageUploadPhotoAction;
@class Secret66_SendMessageAction_sendMessageUploadDocumentAction;
@class Secret66_SendMessageAction_sendMessageGeoLocationAction;
@class Secret66_SendMessageAction_sendMessageChooseContactAction;

@class Secret66_PhotoSize;
@class Secret66_PhotoSize_photoSizeEmpty;
@class Secret66_PhotoSize_photoSize;
@class Secret66_PhotoSize_photoCachedSize;

@class Secret66_FileLocation;
@class Secret66_FileLocation_fileLocationUnavailable;
@class Secret66_FileLocation_fileLocation;

@class Secret66_DecryptedMessageLayer;
@class Secret66_DecryptedMessageLayer_decryptedMessageLayer;

@class Secret66_DecryptedMessage;
@class Secret66_DecryptedMessage_decryptedMessageService;
@class Secret66_DecryptedMessage_decryptedMessage;

@class Secret66_DocumentAttribute;
@class Secret66_DocumentAttribute_documentAttributeImageSize;
@class Secret66_DocumentAttribute_documentAttributeAnimated;
@class Secret66_DocumentAttribute_documentAttributeVideo;
@class Secret66_DocumentAttribute_documentAttributeFilename;
@class Secret66_DocumentAttribute_documentAttributeSticker;
@class Secret66_DocumentAttribute_documentAttributeAudio;

@class Secret66_InputStickerSet;
@class Secret66_InputStickerSet_inputStickerSetShortName;
@class Secret66_InputStickerSet_inputStickerSetEmpty;

@class Secret66_MessageEntity;
@class Secret66_MessageEntity_messageEntityUnknown;
@class Secret66_MessageEntity_messageEntityMention;
@class Secret66_MessageEntity_messageEntityHashtag;
@class Secret66_MessageEntity_messageEntityBotCommand;
@class Secret66_MessageEntity_messageEntityUrl;
@class Secret66_MessageEntity_messageEntityEmail;
@class Secret66_MessageEntity_messageEntityBold;
@class Secret66_MessageEntity_messageEntityItalic;
@class Secret66_MessageEntity_messageEntityCode;
@class Secret66_MessageEntity_messageEntityPre;
@class Secret66_MessageEntity_messageEntityTextUrl;

@class Secret66_DecryptedMessageMedia;
@class Secret66_DecryptedMessageMedia_decryptedMessageMediaEmpty;
@class Secret66_DecryptedMessageMedia_decryptedMessageMediaGeoPoint;
@class Secret66_DecryptedMessageMedia_decryptedMessageMediaContact;
@class Secret66_DecryptedMessageMedia_decryptedMessageMediaAudio;
@class Secret66_DecryptedMessageMedia_decryptedMessageMediaExternalDocument;
@class Secret66_DecryptedMessageMedia_decryptedMessageMediaPhoto;
@class Secret66_DecryptedMessageMedia_decryptedMessageMediaDocument;
@class Secret66_DecryptedMessageMedia_decryptedMessageMediaVideo;
@class Secret66_DecryptedMessageMedia_decryptedMessageMediaVenue;
@class Secret66_DecryptedMessageMedia_decryptedMessageMediaWebPage;


@interface Secret66__Environment : NSObject

+ (NSData *)serializeObject:(id)object;
+ (id)parseObject:(NSData *)data;

@end

@interface Secret66_FunctionContext : NSObject

@property (nonatomic, strong, readonly) NSData *payload;
@property (nonatomic, copy, readonly) id (^responseParser)(NSData *);
@property (nonatomic, strong, readonly) id metadata;

- (instancetype)initWithPayload:(NSData *)payload responseParser:(id (^)(NSData *))responseParser metadata:(id)metadata;

@end

/*
 * Types 46
 */

@interface Secret66_DecryptedMessageAction : NSObject

+ (Secret66_DecryptedMessageAction_decryptedMessageActionSetMessageTTL *)decryptedMessageActionSetMessageTTLWithTtlSeconds:(NSNumber *)ttlSeconds;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionReadMessages *)decryptedMessageActionReadMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionDeleteMessages *)decryptedMessageActionDeleteMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *)decryptedMessageActionScreenshotMessagesWithRandomIds:(NSArray *)randomIds;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionFlushHistory *)decryptedMessageActionFlushHistory;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionNotifyLayer *)decryptedMessageActionNotifyLayerWithLayer:(NSNumber *)layer;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionTyping *)decryptedMessageActionTypingWithAction:(Secret66_SendMessageAction *)action;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionResend *)decryptedMessageActionResendWithStartSeqNo:(NSNumber *)startSeqNo endSeqNo:(NSNumber *)endSeqNo;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionRequestKey *)decryptedMessageActionRequestKeyWithExchangeId:(NSNumber *)exchangeId gA:(NSData *)gA;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionAcceptKey *)decryptedMessageActionAcceptKeyWithExchangeId:(NSNumber *)exchangeId gB:(NSData *)gB keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionCommitKey *)decryptedMessageActionCommitKeyWithExchangeId:(NSNumber *)exchangeId keyFingerprint:(NSNumber *)keyFingerprint;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionAbortKey *)decryptedMessageActionAbortKeyWithExchangeId:(NSNumber *)exchangeId;
+ (Secret66_DecryptedMessageAction_decryptedMessageActionNoop *)decryptedMessageActionNoop;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionSetMessageTTL : Secret66_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * ttlSeconds;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionReadMessages : Secret66_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionDeleteMessages : Secret66_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionScreenshotMessages : Secret66_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSArray * randomIds;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionFlushHistory : Secret66_DecryptedMessageAction

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionNotifyLayer : Secret66_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * layer;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionTyping : Secret66_DecryptedMessageAction

@property (nonatomic, strong, readonly) Secret66_SendMessageAction * action;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionResend : Secret66_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * startSeqNo;
@property (nonatomic, strong, readonly) NSNumber * endSeqNo;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionRequestKey : Secret66_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gA;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionAcceptKey : Secret66_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSData * gB;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionCommitKey : Secret66_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;
@property (nonatomic, strong, readonly) NSNumber * keyFingerprint;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionAbortKey : Secret66_DecryptedMessageAction

@property (nonatomic, strong, readonly) NSNumber * exchangeId;

@end

@interface Secret66_DecryptedMessageAction_decryptedMessageActionNoop : Secret66_DecryptedMessageAction

@end


@interface Secret66_SendMessageAction : NSObject

+ (Secret66_SendMessageAction_sendMessageTypingAction *)sendMessageTypingAction;
+ (Secret66_SendMessageAction_sendMessageCancelAction *)sendMessageCancelAction;
+ (Secret66_SendMessageAction_sendMessageRecordVideoAction *)sendMessageRecordVideoAction;
+ (Secret66_SendMessageAction_sendMessageUploadVideoAction *)sendMessageUploadVideoAction;
+ (Secret66_SendMessageAction_sendMessageRecordAudioAction *)sendMessageRecordAudioAction;
+ (Secret66_SendMessageAction_sendMessageUploadAudioAction *)sendMessageUploadAudioAction;
+ (Secret66_SendMessageAction_sendMessageUploadPhotoAction *)sendMessageUploadPhotoAction;
+ (Secret66_SendMessageAction_sendMessageUploadDocumentAction *)sendMessageUploadDocumentAction;
+ (Secret66_SendMessageAction_sendMessageGeoLocationAction *)sendMessageGeoLocationAction;
+ (Secret66_SendMessageAction_sendMessageChooseContactAction *)sendMessageChooseContactAction;

@end

@interface Secret66_SendMessageAction_sendMessageTypingAction : Secret66_SendMessageAction

@end

@interface Secret66_SendMessageAction_sendMessageCancelAction : Secret66_SendMessageAction

@end

@interface Secret66_SendMessageAction_sendMessageRecordVideoAction : Secret66_SendMessageAction

@end

@interface Secret66_SendMessageAction_sendMessageUploadVideoAction : Secret66_SendMessageAction

@end

@interface Secret66_SendMessageAction_sendMessageRecordAudioAction : Secret66_SendMessageAction

@end

@interface Secret66_SendMessageAction_sendMessageUploadAudioAction : Secret66_SendMessageAction

@end

@interface Secret66_SendMessageAction_sendMessageUploadPhotoAction : Secret66_SendMessageAction

@end

@interface Secret66_SendMessageAction_sendMessageUploadDocumentAction : Secret66_SendMessageAction

@end

@interface Secret66_SendMessageAction_sendMessageGeoLocationAction : Secret66_SendMessageAction

@end

@interface Secret66_SendMessageAction_sendMessageChooseContactAction : Secret66_SendMessageAction

@end


@interface Secret66_PhotoSize : NSObject

@property (nonatomic, strong, readonly) NSString * type;

+ (Secret66_PhotoSize_photoSizeEmpty *)photoSizeEmptyWithType:(NSString *)type;
+ (Secret66_PhotoSize_photoSize *)photoSizeWithType:(NSString *)type location:(Secret66_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size;
+ (Secret66_PhotoSize_photoCachedSize *)photoCachedSizeWithType:(NSString *)type location:(Secret66_FileLocation *)location w:(NSNumber *)w h:(NSNumber *)h bytes:(NSData *)bytes;

@end

@interface Secret66_PhotoSize_photoSizeEmpty : Secret66_PhotoSize

@end

@interface Secret66_PhotoSize_photoSize : Secret66_PhotoSize

@property (nonatomic, strong, readonly) Secret66_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSNumber * size;

@end

@interface Secret66_PhotoSize_photoCachedSize : Secret66_PhotoSize

@property (nonatomic, strong, readonly) Secret66_FileLocation * location;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;
@property (nonatomic, strong, readonly) NSData * bytes;

@end


@interface Secret66_FileLocation : NSObject

@property (nonatomic, strong, readonly) NSNumber * volumeId;
@property (nonatomic, strong, readonly) NSNumber * localId;
@property (nonatomic, strong, readonly) NSNumber * secret;

+ (Secret66_FileLocation_fileLocationUnavailable *)fileLocationUnavailableWithVolumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;
+ (Secret66_FileLocation_fileLocation *)fileLocationWithDcId:(NSNumber *)dcId volumeId:(NSNumber *)volumeId localId:(NSNumber *)localId secret:(NSNumber *)secret;

@end

@interface Secret66_FileLocation_fileLocationUnavailable : Secret66_FileLocation

@end

@interface Secret66_FileLocation_fileLocation : Secret66_FileLocation

@property (nonatomic, strong, readonly) NSNumber * dcId;

@end


@interface Secret66_DecryptedMessageLayer : NSObject

@property (nonatomic, strong, readonly) NSData * randomBytes;
@property (nonatomic, strong, readonly) NSNumber * layer;
@property (nonatomic, strong, readonly) NSNumber * inSeqNo;
@property (nonatomic, strong, readonly) NSNumber * outSeqNo;
@property (nonatomic, strong, readonly) Secret66_DecryptedMessage * message;

+ (Secret66_DecryptedMessageLayer_decryptedMessageLayer *)decryptedMessageLayerWithRandomBytes:(NSData *)randomBytes layer:(NSNumber *)layer inSeqNo:(NSNumber *)inSeqNo outSeqNo:(NSNumber *)outSeqNo message:(Secret66_DecryptedMessage *)message;

@end

@interface Secret66_DecryptedMessageLayer_decryptedMessageLayer : Secret66_DecryptedMessageLayer

@end


@interface Secret66_DecryptedMessage : NSObject

@property (nonatomic, strong, readonly) NSNumber * randomId;

+ (Secret66_DecryptedMessage_decryptedMessageService *)decryptedMessageServiceWithRandomId:(NSNumber *)randomId action:(Secret66_DecryptedMessageAction *)action;
+ (Secret66_DecryptedMessage_decryptedMessage *)decryptedMessageWithFlags:(NSNumber *)flags randomId:(NSNumber *)randomId ttl:(NSNumber *)ttl message:(NSString *)message media:(Secret66_DecryptedMessageMedia *)media entities:(NSArray *)entities viaBotName:(NSString *)viaBotName replyToRandomId:(NSNumber *)replyToRandomId;

@end

@interface Secret66_DecryptedMessage_decryptedMessageService : Secret66_DecryptedMessage

@property (nonatomic, strong, readonly) Secret66_DecryptedMessageAction * action;

@end

@interface Secret66_DecryptedMessage_decryptedMessage : Secret66_DecryptedMessage

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * ttl;
@property (nonatomic, strong, readonly) NSString * message;
@property (nonatomic, strong, readonly) Secret66_DecryptedMessageMedia * media;
@property (nonatomic, strong, readonly) NSArray * entities;
@property (nonatomic, strong, readonly) NSString * viaBotName;
@property (nonatomic, strong, readonly) NSNumber * replyToRandomId;

@end


@interface Secret66_DocumentAttribute : NSObject

+ (Secret66_DocumentAttribute_documentAttributeImageSize *)documentAttributeImageSizeWithW:(NSNumber *)w h:(NSNumber *)h;
+ (Secret66_DocumentAttribute_documentAttributeAnimated *)documentAttributeAnimated;
+ (Secret66_DocumentAttribute_documentAttributeVideo *)documentAttributeVideoWithFlags:(NSNumber *)flags duration:(NSNumber *)duration w:(NSNumber *)w h:(NSNumber *)h;
+ (Secret66_DocumentAttribute_documentAttributeFilename *)documentAttributeFilenameWithFileName:(NSString *)fileName;
+ (Secret66_DocumentAttribute_documentAttributeSticker *)documentAttributeStickerWithAlt:(NSString *)alt stickerset:(Secret66_InputStickerSet *)stickerset;
+ (Secret66_DocumentAttribute_documentAttributeAudio *)documentAttributeAudioWithFlags:(NSNumber *)flags duration:(NSNumber *)duration title:(NSString *)title performer:(NSString *)performer waveform:(NSData *)waveform;

@end

@interface Secret66_DocumentAttribute_documentAttributeImageSize : Secret66_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Secret66_DocumentAttribute_documentAttributeAnimated : Secret66_DocumentAttribute

@end

@interface Secret66_DocumentAttribute_documentAttributeVideo : Secret66_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * w;
@property (nonatomic, strong, readonly) NSNumber * h;

@end

@interface Secret66_DocumentAttribute_documentAttributeFilename : Secret66_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * fileName;

@end

@interface Secret66_DocumentAttribute_documentAttributeSticker : Secret66_DocumentAttribute

@property (nonatomic, strong, readonly) NSString * alt;
@property (nonatomic, strong, readonly) Secret66_InputStickerSet * stickerset;

@end

@interface Secret66_DocumentAttribute_documentAttributeAudio : Secret66_DocumentAttribute

@property (nonatomic, strong, readonly) NSNumber * flags;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * performer;
@property (nonatomic, strong, readonly) NSData * waveform;

@end


@interface Secret66_InputStickerSet : NSObject

+ (Secret66_InputStickerSet_inputStickerSetShortName *)inputStickerSetShortNameWithShortName:(NSString *)shortName;
+ (Secret66_InputStickerSet_inputStickerSetEmpty *)inputStickerSetEmpty;

@end

@interface Secret66_InputStickerSet_inputStickerSetShortName : Secret66_InputStickerSet

@property (nonatomic, strong, readonly) NSString * shortName;

@end

@interface Secret66_InputStickerSet_inputStickerSetEmpty : Secret66_InputStickerSet

@end


@interface Secret66_MessageEntity : NSObject

@property (nonatomic, strong, readonly) NSNumber * offset;
@property (nonatomic, strong, readonly) NSNumber * length;

+ (Secret66_MessageEntity_messageEntityUnknown *)messageEntityUnknownWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret66_MessageEntity_messageEntityMention *)messageEntityMentionWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret66_MessageEntity_messageEntityHashtag *)messageEntityHashtagWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret66_MessageEntity_messageEntityBotCommand *)messageEntityBotCommandWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret66_MessageEntity_messageEntityUrl *)messageEntityUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret66_MessageEntity_messageEntityEmail *)messageEntityEmailWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret66_MessageEntity_messageEntityBold *)messageEntityBoldWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret66_MessageEntity_messageEntityItalic *)messageEntityItalicWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret66_MessageEntity_messageEntityCode *)messageEntityCodeWithOffset:(NSNumber *)offset length:(NSNumber *)length;
+ (Secret66_MessageEntity_messageEntityPre *)messageEntityPreWithOffset:(NSNumber *)offset length:(NSNumber *)length language:(NSString *)language;
+ (Secret66_MessageEntity_messageEntityTextUrl *)messageEntityTextUrlWithOffset:(NSNumber *)offset length:(NSNumber *)length url:(NSString *)url;

@end

@interface Secret66_MessageEntity_messageEntityUnknown : Secret66_MessageEntity

@end

@interface Secret66_MessageEntity_messageEntityMention : Secret66_MessageEntity

@end

@interface Secret66_MessageEntity_messageEntityHashtag : Secret66_MessageEntity

@end

@interface Secret66_MessageEntity_messageEntityBotCommand : Secret66_MessageEntity

@end

@interface Secret66_MessageEntity_messageEntityUrl : Secret66_MessageEntity

@end

@interface Secret66_MessageEntity_messageEntityEmail : Secret66_MessageEntity

@end

@interface Secret66_MessageEntity_messageEntityBold : Secret66_MessageEntity

@end

@interface Secret66_MessageEntity_messageEntityItalic : Secret66_MessageEntity

@end

@interface Secret66_MessageEntity_messageEntityCode : Secret66_MessageEntity

@end

@interface Secret66_MessageEntity_messageEntityPre : Secret66_MessageEntity

@property (nonatomic, strong, readonly) NSString * language;

@end

@interface Secret66_MessageEntity_messageEntityTextUrl : Secret66_MessageEntity

@property (nonatomic, strong, readonly) NSString * url;

@end


@interface Secret66_DecryptedMessageMedia : NSObject

+ (Secret66_DecryptedMessageMedia_decryptedMessageMediaEmpty *)decryptedMessageMediaEmpty;
+ (Secret66_DecryptedMessageMedia_decryptedMessageMediaGeoPoint *)decryptedMessageMediaGeoPointWithLat:(NSNumber *)lat plong:(NSNumber *)plong;
+ (Secret66_DecryptedMessageMedia_decryptedMessageMediaContact *)decryptedMessageMediaContactWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName userId:(NSNumber *)userId;
+ (Secret66_DecryptedMessageMedia_decryptedMessageMediaAudio *)decryptedMessageMediaAudioWithDuration:(NSNumber *)duration mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv;
+ (Secret66_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)decryptedMessageMediaExternalDocumentWithPid:(NSNumber *)pid accessHash:(NSNumber *)accessHash date:(NSNumber *)date mimeType:(NSString *)mimeType size:(NSNumber *)size thumb:(Secret66_PhotoSize *)thumb dcId:(NSNumber *)dcId attributes:(NSArray *)attributes;
+ (Secret66_DecryptedMessageMedia_decryptedMessageMediaPhoto *)decryptedMessageMediaPhotoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv caption:(NSString *)caption;
+ (Secret66_DecryptedMessageMedia_decryptedMessageMediaDocument *)decryptedMessageMediaDocumentWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH mimeType:(NSString *)mimeType size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv attributes:(NSArray *)attributes caption:(NSString *)caption;
+ (Secret66_DecryptedMessageMedia_decryptedMessageMediaVideo *)decryptedMessageMediaVideoWithThumb:(NSData *)thumb thumbW:(NSNumber *)thumbW thumbH:(NSNumber *)thumbH duration:(NSNumber *)duration mimeType:(NSString *)mimeType w:(NSNumber *)w h:(NSNumber *)h size:(NSNumber *)size key:(NSData *)key iv:(NSData *)iv caption:(NSString *)caption;
+ (Secret66_DecryptedMessageMedia_decryptedMessageMediaVenue *)decryptedMessageMediaVenueWithLat:(NSNumber *)lat plong:(NSNumber *)plong title:(NSString *)title address:(NSString *)address provider:(NSString *)provider venueId:(NSString *)venueId;
+ (Secret66_DecryptedMessageMedia_decryptedMessageMediaWebPage *)decryptedMessageMediaWebPageWithUrl:(NSString *)url;

@end

@interface Secret66_DecryptedMessageMedia_decryptedMessageMediaEmpty : Secret66_DecryptedMessageMedia

@end

@interface Secret66_DecryptedMessageMedia_decryptedMessageMediaGeoPoint : Secret66_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;

@end

@interface Secret66_DecryptedMessageMedia_decryptedMessageMediaContact : Secret66_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * phoneNumber;
@property (nonatomic, strong, readonly) NSString * firstName;
@property (nonatomic, strong, readonly) NSString * lastName;
@property (nonatomic, strong, readonly) NSNumber * userId;

@end

@interface Secret66_DecryptedMessageMedia_decryptedMessageMediaAudio : Secret66_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) NSData * key;
@property (nonatomic, strong, readonly) NSData * iv;

@end

@interface Secret66_DecryptedMessageMedia_decryptedMessageMediaExternalDocument : Secret66_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * pid;
@property (nonatomic, strong, readonly) NSNumber * accessHash;
@property (nonatomic, strong, readonly) NSNumber * date;
@property (nonatomic, strong, readonly) NSString * mimeType;
@property (nonatomic, strong, readonly) NSNumber * size;
@property (nonatomic, strong, readonly) Secret66_PhotoSize * thumb;
@property (nonatomic, strong, readonly) NSNumber * dcId;
@property (nonatomic, strong, readonly) NSArray * attributes;

@end

@interface Secret66_DecryptedMessageMedia_decryptedMessageMediaPhoto : Secret66_DecryptedMessageMedia

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

@interface Secret66_DecryptedMessageMedia_decryptedMessageMediaDocument : Secret66_DecryptedMessageMedia

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

@interface Secret66_DecryptedMessageMedia_decryptedMessageMediaVideo : Secret66_DecryptedMessageMedia

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

@interface Secret66_DecryptedMessageMedia_decryptedMessageMediaVenue : Secret66_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSNumber * lat;
@property (nonatomic, strong, readonly) NSNumber * plong;
@property (nonatomic, strong, readonly) NSString * title;
@property (nonatomic, strong, readonly) NSString * address;
@property (nonatomic, strong, readonly) NSString * provider;
@property (nonatomic, strong, readonly) NSString * venueId;

@end

@interface Secret66_DecryptedMessageMedia_decryptedMessageMediaWebPage : Secret66_DecryptedMessageMedia

@property (nonatomic, strong, readonly) NSString * url;

@end


/*
 * Functions 46
 */

@interface Secret66: NSObject

@end
