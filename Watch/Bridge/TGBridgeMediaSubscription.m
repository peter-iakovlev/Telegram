#import "TGBridgeMediaSubscription.h"
#import <UIKit/UIKit.h>

#import "TGBridgeImageMediaAttachment.h"
#import "TGBridgeVideoMediaAttachment.h"

NSString *const TGBridgeMediaPhotoThumbnailSubscriptionName = @"media.photoThumbnail";
NSString *const TGBridgeMediaPhotoThumbnailImageAttachmentKey = @"image";
NSString *const TGBridgeMediaPhotoThumbnailSizeKey = @"size";

@implementation TGBridgeMediaPhotoThumbnailSubscription

- (instancetype)initWithImageAttachment:(TGBridgeImageMediaAttachment *)imageAttachment size:(CGSize)size
{
    self = [super init];
    if (self != nil)
    {
        _imageAttachment = imageAttachment;
        _size = size;
    }
    return self;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.imageAttachment forKey:TGBridgeMediaPhotoThumbnailImageAttachmentKey];
    [aCoder encodeCGSize:self.size forKey:TGBridgeMediaPhotoThumbnailSizeKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _imageAttachment = [aDecoder decodeObjectForKey:TGBridgeMediaPhotoThumbnailImageAttachmentKey];
    _size = [aDecoder decodeCGSizeForKey:TGBridgeMediaPhotoThumbnailSizeKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeMediaPhotoThumbnailSubscriptionName;
}

@end


NSString *const TGBridgeMediaVideoThumbnailSubscriptionName = @"media.videoThumbnail";
NSString *const TGBridgeMediaVideoThumbnailImageAttachmentKey = @"video";
NSString *const TGBridgeMediaVideoThumbnailSizeKey = @"size";

@implementation TGBridgeMediaVideoThumbnailSubscription

- (instancetype)initWithVideoAttachment:(TGBridgeVideoMediaAttachment *)videoAttachment size:(CGSize)size
{
    self = [super init];
    if (self != nil)
    {
        _videoAttachment = videoAttachment;
        _size = size;
    }
    return self;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.videoAttachment forKey:TGBridgeMediaVideoThumbnailImageAttachmentKey];
    [aCoder encodeCGSize:self.size forKey:TGBridgeMediaVideoThumbnailSizeKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _videoAttachment = [aDecoder decodeObjectForKey:TGBridgeMediaVideoThumbnailImageAttachmentKey];
    _size = [aDecoder decodeCGSizeForKey:TGBridgeMediaVideoThumbnailSizeKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeMediaVideoThumbnailSubscriptionName;
}

@end


NSString *const TGBridgeMediaAvatarSubscriptionName = @"media.avatar";
NSString *const TGBridgeMediaAvatarUrlKey = @"url";
NSString *const TGBridgeMediaAvatarTypeKey = @"type";

@implementation TGBridgeMediaAvatarSubscription

- (instancetype)initWithUrl:(NSString *)url type:(TGBridgeMediaAvatarType)type
{
    self = [super init];
    if (self != nil)
    {
        _url = url;
        _type = type;
    }
    return self;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:TGBridgeMediaAvatarUrlKey];
    [aCoder encodeInt32:self.type forKey:TGBridgeMediaAvatarTypeKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _url = [aDecoder decodeObjectForKey:TGBridgeMediaAvatarUrlKey];
    _type = [aDecoder decodeInt32ForKey:TGBridgeMediaAvatarTypeKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeMediaAvatarSubscriptionName;
}

@end


NSString *const TGBridgeMediaStickerSubscriptionName = @"media.sticker";
NSString *const TGBridgeMediaStickerDocumentIdKey = @"documentId";
NSString *const TGBridgeMediaStickerAccessHashKey = @"accessHash";
NSString *const TGBridgeMediaStickerDatacenterIdKey = @"datacenterId";
NSString *const TGBridgeMediaStickerLegacyThumbnailUriKey = @"legacyThumbnailUri";
NSString *const TGBridgeMediaStickerSizeKey = @"size";

@implementation TGBridgeMediaStickerSubscription

- (instancetype)initWithDocumentId:(int64_t)documentId accessHash:(int64_t)accessHash datacenterId:(int32_t)datacenterId legacyThumbnailUri:(NSString *)legacyThumbnailUri size:(CGSize)size
{
    self = [super init];
    if (self != nil)
    {
        _documentId = documentId;
        _accessHash = accessHash;
        _datacenterId = datacenterId;
        _legacyThumbnailUri = legacyThumbnailUri;
        _size = size;
    }
    return self;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.documentId forKey:TGBridgeMediaStickerDocumentIdKey];
    [aCoder encodeInt64:self.accessHash forKey:TGBridgeMediaStickerAccessHashKey];
    [aCoder encodeInt32:self.datacenterId forKey:TGBridgeMediaStickerDatacenterIdKey];
    [aCoder encodeObject:self.legacyThumbnailUri forKey:TGBridgeMediaStickerLegacyThumbnailUriKey];
    [aCoder encodeCGSize:self.size forKey:TGBridgeMediaStickerSizeKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _documentId = [aDecoder decodeInt64ForKey:TGBridgeMediaStickerDocumentIdKey];
    _accessHash = [aDecoder decodeInt64ForKey:TGBridgeMediaStickerAccessHashKey];
    _datacenterId = [aDecoder decodeInt32ForKey:TGBridgeMediaStickerDatacenterIdKey];
    _legacyThumbnailUri = [aDecoder decodeObjectForKey:TGBridgeMediaStickerLegacyThumbnailUriKey];
    _size = [aDecoder decodeCGSizeForKey:TGBridgeMediaStickerSizeKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeMediaStickerSubscriptionName;
}

@end
