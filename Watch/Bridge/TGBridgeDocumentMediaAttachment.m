#import "TGBridgeDocumentMediaAttachment.h"

const NSInteger TGBridgeDocumentMediaAttachmentType = 0xE6C64318;

NSString *const TGBridgeDocumentMediaDocumentIdKey = @"documentId";
NSString *const TGBridgeDocumentMediaAccessHashKey = @"accessHash";
NSString *const TGBridgeDocumentMediaDatacenterIdKey = @"datacenterId";
NSString *const TGBridgeDocumentMediaLegacyThumbnailUriKey = @"legacyThumbnailUri";

NSString *const TGBridgeDocumentMediaFileSizeKey = @"fileSize";
NSString *const TGBridgeDocumentMediaFileNameKey = @"fileName";
NSString *const TGBridgeDocumentMediaImageSizeKey = @"imageSize";
NSString *const TGBridgeDocumentMediaAnimatedKey = @"animated";
NSString *const TGBridgeDocumentMediaStickerKey = @"sticker";
NSString *const TGBridgeDocumentMediaStickerAltKey = @"stickerAlt";
NSString *const TGBridgeDocumentMediaAudioKey = @"audio";
NSString *const TGBridgeDocumentMediaAudioTitleKey = @"title";
NSString *const TGBridgeDocumentMediaAudioPerformerKey = @"performer";

@implementation TGBridgeDocumentMediaAttachment

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _documentId = [aDecoder decodeInt64ForKey:TGBridgeDocumentMediaDocumentIdKey];
        _accessHash = [aDecoder decodeInt64ForKey:TGBridgeDocumentMediaAccessHashKey];
        _datacenterId = [aDecoder decodeInt32ForKey:TGBridgeDocumentMediaDatacenterIdKey];
        _legacyThumbnailUri = [aDecoder decodeObjectForKey:TGBridgeDocumentMediaLegacyThumbnailUriKey];
        _fileSize = [aDecoder decodeInt32ForKey:TGBridgeDocumentMediaFileSizeKey];
        _fileName = [aDecoder decodeObjectForKey:TGBridgeDocumentMediaFileNameKey];
        _imageSize = [aDecoder decodeObjectForKey:TGBridgeDocumentMediaImageSizeKey];
        _isAnimated = [aDecoder decodeBoolForKey:TGBridgeDocumentMediaAnimatedKey];
        _isSticker = [aDecoder decodeBoolForKey:TGBridgeDocumentMediaStickerKey];
        _stickerAlt = [aDecoder decodeObjectForKey:TGBridgeDocumentMediaStickerAltKey];
        _isAudio = [aDecoder decodeBoolForKey:TGBridgeDocumentMediaAudioKey];
        _title = [aDecoder decodeObjectForKey:TGBridgeDocumentMediaAudioTitleKey];
        _performer = [aDecoder decodeObjectForKey:TGBridgeDocumentMediaAudioPerformerKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.documentId forKey:TGBridgeDocumentMediaDocumentIdKey];
    [aCoder encodeInt64:self.accessHash forKey:TGBridgeDocumentMediaAccessHashKey];
    [aCoder encodeInt32:self.datacenterId forKey:TGBridgeDocumentMediaDatacenterIdKey];
    [aCoder encodeObject:self.legacyThumbnailUri forKey:TGBridgeDocumentMediaLegacyThumbnailUriKey];
    [aCoder encodeInt32:self.fileSize forKey:TGBridgeDocumentMediaFileSizeKey];
    [aCoder encodeObject:self.fileName forKey:TGBridgeDocumentMediaFileNameKey];
    [aCoder encodeObject:self.imageSize forKey:TGBridgeDocumentMediaImageSizeKey];
    [aCoder encodeBool:self.isAnimated forKey:TGBridgeDocumentMediaAnimatedKey];
    [aCoder encodeBool:self.isSticker forKey:TGBridgeDocumentMediaStickerKey];
    [aCoder encodeObject:self.stickerAlt forKey:TGBridgeDocumentMediaStickerAltKey];
    [aCoder encodeBool:self.isAudio forKey:TGBridgeDocumentMediaAudioKey];
    [aCoder encodeObject:self.title forKey:TGBridgeDocumentMediaAudioTitleKey];
    [aCoder encodeObject:self.performer forKey:TGBridgeDocumentMediaAudioPerformerKey];
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    TGBridgeDocumentMediaAttachment *document = (TGBridgeDocumentMediaAttachment *)object;
    
    return (self.documentId == document.documentId && self.accessHash == document.accessHash);
}

+ (NSInteger)mediaType
{
    return TGBridgeDocumentMediaAttachmentType;
}

@end
