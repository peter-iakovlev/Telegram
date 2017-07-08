#import "TGPreparedAssetVideoMessage.h"
#import "TGAppDelegate.h"

#import "TGMessage.h"

#import "TGImageInfo.h"
#import "TGRemoteImageView.h"

@interface TGPreparedAssetVideoMessage ()
{
    NSString *_fileName;
}
@end

@implementation TGPreparedAssetVideoMessage

- (instancetype)initWithAssetIdentifier:(NSString *)assetIdentifier assetURL:(NSURL *)assetURL localVideoId:(int64_t)localVideoId imageInfo:(TGImageInfo *)imageInfo duration:(NSTimeInterval)duration dimensions:(CGSize)dimensions adjustments:(NSDictionary *)adjustments useMediaCache:(bool)useMediaCache liveUpload:(bool)liveUpload passthrough:(bool)passthrough caption:(NSString *)caption isCloud:(bool)isCloud document:(bool)document localDocumentId:(int64_t)localDocumentId fileSize:(int)fileSize mimeType:(NSString *)mimeType attributes:(NSArray *)attributes replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup stickerDocuments:(NSArray *)stickerDocuments roundMessage:(bool)roundMessage
{
    self = [super init];
    if (self != nil)
    {
        _assetIdentifier = assetIdentifier;
        _assetURL = assetURL;
        _localVideoId = localVideoId;
        _imageInfo = imageInfo;
        _duration = duration;
        _dimensions = dimensions;
        _adjustments = adjustments;
        _useMediaCache = useMediaCache;
        _liveUpload = liveUpload;
        _passthrough = passthrough;
        _caption = caption;
        _isCloud = isCloud;
        _document = document;
        _localDocumentId = localDocumentId;
        _fileSize = fileSize;
        _mimeType = mimeType;
        _attributes = attributes;
        _stickerDocuments = stickerDocuments;
        _roundMessage = roundMessage;
        
        self.replyMessage = replyMessage;
        self.replyMarkup = replyMarkup;
    }
    return self;
}

- (void)setImageInfoWithThumbnailData:(NSData *)data thumbnailSize:(CGSize)thumbnailSize
{
    TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
    [imageInfo addImageWithSize:thumbnailSize url:[TGPreparedAssetVideoMessage _fileUrlForStoredData:data isAnimation:self.isAnimation]];
     _imageInfo = imageInfo;
}

+ (NSString *)_fileUrlForStoredData:(NSData *)data isAnimation:(bool)isAnimation
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *uploadDirectory = [documentsDirectory stringByAppendingPathComponent:@"upload"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:uploadDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:uploadDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    int64_t randomId = 0;
    arc4random_buf(&randomId, sizeof(randomId));
    NSString *imagePathComponent = [[NSString alloc] initWithFormat:@"%" PRIx64 ".bin", randomId];
    NSString *filePath = [uploadDirectory stringByAppendingPathComponent:imagePathComponent];
    
    NSString *fileUrl = [@"file://" stringByAppendingString:filePath];
    if (isAnimation)
        [data writeToFile:[[TGRemoteImageView sharedCache] pathForCachedData:fileUrl] atomically:true];

    [data writeToFile:filePath atomically:true];
    
    return fileUrl;
}

- (NSString *)localVideoPath
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    return [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%llx.mov", _localVideoId]];
}

- (NSString *)localThumbnailDataPath
{
    return [_imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
}

- (NSString *)localDocumentDirectory
{
    return [TGPreparedAssetVideoMessage localDocumentDirectoryForLocalDocumentId:_localDocumentId];
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
        name = @"video.mov";
    
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
        return [self videoMessage];
}

- (TGMessage *)videoMessage
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    message.outgoing = true;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    TGVideoMediaAttachment *videoAttachment = [[TGVideoMediaAttachment alloc] init];
    videoAttachment.localVideoId = _localVideoId;
    videoAttachment.duration = (int)_duration;
    videoAttachment.dimensions = _dimensions;
    
    videoAttachment.thumbnailInfo = _imageInfo;
   
    TGVideoInfo *videoInfo = [[TGVideoInfo alloc] init];
    [videoInfo addVideoWithQuality:1 url:[[NSString alloc] initWithFormat:@"local-video:local%llx.mov", _localVideoId] size:_fileSize];
    videoAttachment.videoInfo = videoInfo;
    videoAttachment.caption = self.caption;
    videoAttachment.roundMessage = self.roundMessage;
    [attachments addObject:videoAttachment];
    
    TGLocalMessageMetaMediaAttachment *mediaMeta = [[TGLocalMessageMetaMediaAttachment alloc] init];
    mediaMeta.imageUrlToDataFile[self.localThumbnailDataPath] = self.localThumbnailDataPath;
    [attachments addObject:mediaMeta];
    
    if (self.replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = self.replyMessage.mid;
        replyMedia.replyMessage = self.replyMessage;
        [attachments addObject:replyMedia];
    }
    
    message.mediaAttachments = attachments;
    message.contentProperties = @{@"mediaAsset": [[TGMediaAssetContentProperty alloc] initWithAssetIdentifier:_assetIdentifier assetURL:_assetURL isVideo:true editAdjustments:_adjustments isCloud:_isCloud useMediaCache:_useMediaCache liveUpload:_liveUpload passthrough:_passthrough roundMessage:_roundMessage]};
    
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
    message.contentProperties = @{@"mediaAsset": [[TGMediaAssetContentProperty alloc] initWithAssetIdentifier:_assetIdentifier assetURL:_assetURL isVideo:true editAdjustments:nil isCloud:_isCloud useMediaCache:false liveUpload:false passthrough:false roundMessage:false]};
    
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

- (bool)isAnimation
{
    for (id attribute in _attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]])
            return true;
    }
    return false;
}

@end
