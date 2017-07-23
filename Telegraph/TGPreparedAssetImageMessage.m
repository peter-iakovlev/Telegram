#import "TGPreparedAssetImageMessage.h"

#import "TGMessage.h"
#import "TGImageInfo.h"

#import "TGAppDelegate.h"
#import "TGRemoteImageView.h"

@interface TGPreparedAssetImageMessage ()
{
    NSString *_fileName;
}
@end

@implementation TGPreparedAssetImageMessage

- (instancetype)initWithAssetIdentifier:(NSString *)assetIdentifier imageInfo:(TGImageInfo *)imageInfo caption:(NSString *)caption useMediaCache:(bool)useMediaCache isCloud:(bool)isCloud document:(bool)document localDocumentId:(int64_t)localDocumentId fileSize:(int)fileSize mimeType:(NSString *)mimeType attributes:(NSArray *)attributes replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup messageLifetime:(int32_t)messageLifetime
{
    self = [self init];
    if (self != nil)
    {
        _assetIdentifier = assetIdentifier;
        _imageInfo = imageInfo;
        _caption = caption;
        _useMediaCache = useMediaCache;
        _isCloud = isCloud;
        _document = document;
        _localDocumentId = localDocumentId;
        _fileSize = fileSize;
        _mimeType = mimeType;
        _attributes = attributes;
        
        self.replyMessage = replyMessage;
        self.replyMarkup = replyMarkup;
        self.messageLifetime = messageLifetime;
    }
    return self;
}

- (void)setImageInfoWithThumbnailData:(NSData *)data thumbnailSize:(CGSize)thumbnailSize
{
    TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
    [imageInfo addImageWithSize:thumbnailSize url:[TGPreparedAssetImageMessage _fileUrlForStoredData:data]];
    _imageInfo = imageInfo;
}

- (NSString *)localThumbnailDataPath
{
    return [_imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
}

- (NSString *)localDocumentDirectory
{
    return [TGPreparedAssetImageMessage localDocumentDirectoryForLocalDocumentId:_localDocumentId];
}

- (NSString *)localDocumentFileName
{
    NSString *fileName = _fileName;
    if (fileName.length == 0)
    {
        for (id attribute in _attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
                fileName = ((TGDocumentAttributeFilename *)attribute).filename;
        }
    }
    
    if (fileName.length == 0)
        fileName = @"file";
    
    return [TGDocumentMediaAttachment safeFileNameForFileName:fileName];
}

- (NSString *)fileName
{
    NSString *name = _fileName;
    if (name.length == 0)
    {
        for (id attribute in _attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
                name = ((TGDocumentAttributeFilename *)attribute).filename;
        }
    }
    
    if (name.length == 0)
        name = @"IMAGE.JPG";
    
    return name;
}

+ (NSString *)localDocumentDirectoryForLocalDocumentId:(int64_t)localDocumentId
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"files"];
    return [filesDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%llx", localDocumentId]];
}

+ (NSString *)localDocumentDirectoryForDocumentId:(int64_t)documentId
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"files"];
    return [filesDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%llx", documentId]];
}

- (TGMessage *)message
{
    if (self.document)
        return [self documentMessage];
    else
        return [self imageMessage];
}

- (TGMessage *)imageMessage
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
    imageAttachment.imageInfo = _imageInfo;
    imageAttachment.caption = self.caption;
    [attachments addObject:imageAttachment];
    
    if (self.replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = self.replyMessage.mid;
        replyMedia.replyMessage = self.replyMessage;
        [attachments addObject:replyMedia];
    }
    
    message.mediaAttachments = attachments;
    message.contentProperties = @{@"mediaAsset": [[TGMediaAssetContentProperty alloc] initWithAssetIdentifier:_assetIdentifier isVideo:false isCloud:_isCloud useMediaCache:_useMediaCache]};
    
    return message;
}

- (TGMessage *)documentMessage
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
    documentAttachment.localDocumentId = _localDocumentId;
    documentAttachment.size = _fileSize;
    documentAttachment.attributes = [self attributes];
    documentAttachment.mimeType = _mimeType;
    documentAttachment.thumbnailInfo = _imageInfo;
    documentAttachment.caption = self.caption;
    [attachments addObject:documentAttachment];
    
    if (self.replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = self.replyMessage.mid;
        replyMedia.replyMessage = self.replyMessage;
        [attachments addObject:replyMedia];
    }
    
    if (self.replyMarkup != nil) {
        [attachments addObject:self.replyMarkup];
    }

    message.mediaAttachments = attachments;
    message.contentProperties = @{@"mediaAsset": [[TGMediaAssetContentProperty alloc] initWithAssetIdentifier:_assetIdentifier isVideo:false isCloud:_isCloud useMediaCache:false]};
    
    return message;
}

- (NSArray *)attributes
{
    NSMutableArray *attributes =  _attributes != nil ? [_attributes mutableCopy] : [[NSMutableArray alloc] init];
    
    bool hasFileName = false;
    for (id attribute in attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
            hasFileName = true;
    }
    
    if (!hasFileName)
    {
        TGDocumentAttributeFilename *nameAttribute = [[TGDocumentAttributeFilename alloc] initWithFilename:self.fileName];
        [attributes addObject:nameAttribute];
    }
    
    _attributes = attributes;
    
    return attributes;
}

+ (TGImageInfo *)imageInfoForThumbnailSize:(CGSize)thumbnailSize thumbnailData:(NSData *)thumbnailData
{
    TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
    [imageInfo addImageWithSize:thumbnailSize url:[self _fileUrlForStoredData:thumbnailData]];
    return imageInfo;
}

+ (NSString *)_fileUrlForStoredData:(NSData *)data
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *uploadDirectory = [documentsDirectory stringByAppendingPathComponent:@"upload"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:uploadDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:uploadDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    int64_t randomId = 0;
    arc4random_buf(&randomId, sizeof(randomId));
    NSString *imagePathComponent = [[NSString alloc] initWithFormat:@"%" PRIx64 ".bin", randomId];
    NSString *filePath = [uploadDirectory stringByAppendingPathComponent:imagePathComponent];
    [data writeToFile:filePath atomically:true];
    
    return [@"file://" stringByAppendingString:filePath];
}

@end
