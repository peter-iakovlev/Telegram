/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedLocalDocumentMessage.h"

#import "TGRemoteImageView.h"
#import "TGImageUtils.h"
#import "TGMimeTypeMap.h"

#import "TGMessage.h"

#import "TGAppDelegate.h"

#import "TGDataItem.h"

@implementation TGPreparedLocalDocumentMessage

+ (instancetype)messageWithTempDataItem:(TGDataItem *)tempDataItem size:(int32_t)size mimeType:(NSString *)mimeType thumbnailImage:(UIImage *)thumbnailImage thumbnailSize:(CGSize)thumbnailSize attributes:(NSArray *)attributes caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup {
#ifdef DEBUG
    NSAssert(tempDataItem != nil, @"tempDataItem should not be nil");
#endif
    
    TGPreparedLocalDocumentMessage *message = [[TGPreparedLocalDocumentMessage alloc] init];
    
    int64_t localDocumentId = 0;
    arc4random_buf(&localDocumentId, 8);
    
    NSString *currentDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:localDocumentId version:0];
    if (![[NSFileManager defaultManager] fileExistsAtPath:currentDocumentDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:currentDocumentDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    NSString *fileName = @"file";
    for (id attribute in attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
            fileName = ((TGDocumentAttributeFilename *)attribute).filename;
    }
    
    NSString *uploadDocumentFile = [currentDocumentDirectory stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:fileName]];
    [tempDataItem moveToPath:uploadDocumentFile];
    
    message.localDocumentId = localDocumentId;
    message.size = size;
    message.attributes = attributes;
    
    if (mimeType.length != 0)
        message.mimeType = mimeType;
    else
        message.mimeType = [TGMimeTypeMap mimeTypeForExtension:[fileName pathExtension]];
    
    if (thumbnailImage != nil)
    {
        NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 0.9f);
        message.localThumbnailDataPath = [self _fileUrlForStoredData:thumbnailData];
        CGSize networkThumbnailSize = TGFitSize(thumbnailSize, CGSizeMake(90, 90));
        message.thumbnailSize = networkThumbnailSize;
    }
    
    message.caption = caption;
    
    message.replyMessage = replyMessage;
    message.replyMarkup = replyMarkup;
    
    return message;
}

+ (instancetype)messageWithTempDocumentPath:(NSString *)tempDocumentPath size:(int32_t)size mimeType:(NSString *)mimeType thumbnailImage:(UIImage *)thumbnailImage thumbnailSize:(CGSize)thumbnailSize attributes:(NSArray *)attributes caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
#ifdef DEBUG
    NSAssert(tempDocumentPath != nil, @"tempDocumentPath should not be nil");
#endif
    
    TGPreparedLocalDocumentMessage *message = [[TGPreparedLocalDocumentMessage alloc] init];
    
    int64_t localDocumentId = 0;
    arc4random_buf(&localDocumentId, 8);
    
    NSString *currentDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:localDocumentId version:0];
    if (![[NSFileManager defaultManager] fileExistsAtPath:currentDocumentDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:currentDocumentDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    NSString *fileName = @"file";
    for (id attribute in attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
            fileName = ((TGDocumentAttributeFilename *)attribute).filename;
    }
    
    NSString *uploadDocumentFile = [currentDocumentDirectory stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:fileName]];
    [[NSFileManager defaultManager] moveItemAtPath:tempDocumentPath toPath:uploadDocumentFile error:nil];
    
    message.localDocumentId = localDocumentId;
    message.size = size;
    message.attributes = attributes;
    
    if (mimeType.length != 0)
        message.mimeType = mimeType;
    else
        message.mimeType = [TGMimeTypeMap mimeTypeForExtension:[fileName pathExtension]];
    
    if (thumbnailImage != nil)
    {
        NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 0.9f);
        message.localThumbnailDataPath = [self _fileUrlForStoredData:thumbnailData];
        CGSize networkThumbnailSize = TGFitSize(thumbnailSize, CGSizeMake(90, 90));
        message.thumbnailSize = networkThumbnailSize;
    }
    
    message.caption = caption;
    
    message.replyMessage = replyMessage;
    message.replyMarkup = replyMarkup;
    
    return message;
}

+ (instancetype)messageByCopyingDataFromMessage:(TGPreparedLocalDocumentMessage *)source
{
    TGMessage *replyMessage = nil;
    TGReplyMarkupAttachment *replyMarkup = nil;
    for (id mediaAttachment in source.message.mediaAttachments)
    {
        if ([mediaAttachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
        {
            replyMessage = ((TGReplyMessageMediaAttachment *)mediaAttachment).replyMessage;
        }
        else if ([mediaAttachment isKindOfClass:[TGReplyMarkupAttachment class]]) {
            replyMarkup = mediaAttachment;
        }
    }
    
    for (id mediaAttachment in source.message.mediaAttachments)
    {
        if ([mediaAttachment isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            return [self messageByCopyingDataFromMedia:mediaAttachment replyMessage:replyMessage replyMarkup:replyMarkup];
        }
    }
    
    return nil;
}

+ (instancetype)messageByCopyingDataFromMedia:(TGDocumentMediaAttachment *)documentAttachment replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
#ifdef DEBUG
    NSAssert(documentAttachment != nil, @"documentAttachment should not be nil");
#endif
    
    TGPreparedLocalDocumentMessage *message = [[TGPreparedLocalDocumentMessage alloc] init];
    
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"files"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filesDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:filesDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    int64_t localDocumentId = 0;
    arc4random_buf(&localDocumentId, 8);
    
    NSString *previousDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:documentAttachment.localDocumentId version:0];
    NSString *previousDocumentFile = [previousDocumentDirectory stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:documentAttachment.fileName]];
    
    NSString *uploadDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:localDocumentId version:0];
    NSString *uploadDocumentFile = [uploadDocumentDirectory stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:documentAttachment.fileName]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:uploadDocumentDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:uploadDocumentDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    [[NSFileManager defaultManager] copyItemAtPath:previousDocumentFile toPath:uploadDocumentFile error:nil];
    
    message.localDocumentId = localDocumentId;
    message.size = documentAttachment.size;
    message.attributes = documentAttachment.attributes;
    message.mimeType = documentAttachment.mimeType;
    
    if (documentAttachment.thumbnailInfo != nil)
    {
        CGSize thumbnailSize = CGSizeZero;
        NSString *thumbnailUrl = [documentAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeMake(90, 90) resultingSize:&thumbnailSize];
        NSString *thumbnailFile = nil;
        if ([thumbnailUrl hasPrefix:@"file://"])
            thumbnailFile = [thumbnailUrl substringFromIndex:@"file://".length];
        if (thumbnailFile != nil)
        {
            NSData *thumbnailData = [[NSData alloc] initWithContentsOfFile:thumbnailFile];
            message.localThumbnailDataPath = [self _fileUrlForStoredData:thumbnailData];
        }
        
        message.thumbnailSize = thumbnailSize;
    }
    
    message.caption = documentAttachment.caption;
    
    message.replyMessage = replyMessage;
    message.replyMarkup = replyMarkup;
    
    return message;
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

+ (instancetype)messageWithLocalDocumentId:(int64_t)localDocumentId size:(int32_t)size mimeType:(NSString *)mimeType localThumbnailDataPath:(NSString *)localThumbnailDataPath thumbnailSize:(CGSize)localThumbnailSize attributes:(NSArray *)attributes replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
    TGPreparedLocalDocumentMessage *message = [[TGPreparedLocalDocumentMessage alloc] init];
    
    message.localDocumentId = localDocumentId;
    message.size = size;
    message.attributes = attributes;
    message.mimeType = mimeType;
    message.localThumbnailDataPath = localThumbnailDataPath;
    message.thumbnailSize = localThumbnailSize;
    message.replyMarkup = replyMarkup;
    
    return message;
}

+ (NSString *)localDocumentDirectoryForLocalDocumentId:(int64_t)localDocumentId version:(int32_t)version
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"files"];
    NSString *versionString = @"";
    if (version > 0) {
        versionString = [NSString stringWithFormat:@"-%d", version];
    }
    return [[filesDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%llx", localDocumentId]] stringByAppendingString:versionString];
}

+ (NSString *)localDocumentDirectoryForDocumentId:(int64_t)documentId version:(int32_t)version
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"files"];
    NSString *versionString = @"";
    if (version > 0) {
        versionString = [NSString stringWithFormat:@"-%d", version];
    }
    return [[filesDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%llx", documentId]]  stringByAppendingString:versionString];
}

- (NSString *)localDocumentDirectory
{
    return [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:_localDocumentId version:0];
}

- (NSString *)localDocumentFileName
{
    NSString *fileName = @"file";
    for (id attribute in _attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeFilename class]])
            fileName = ((TGDocumentAttributeFilename *)attribute).filename;
    }
    
    return [TGDocumentMediaAttachment safeFileNameForFileName:fileName];
}

- (TGMessage *)message
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
    documentAttachment.localDocumentId = _localDocumentId;
    documentAttachment.size = _size;
    documentAttachment.attributes = _attributes;
    documentAttachment.mimeType = _mimeType;
    documentAttachment.caption = self.caption;
    
    if (_localThumbnailDataPath != nil)
    {
        TGImageInfo *thumbnailInfo = [[TGImageInfo alloc] init];
        [thumbnailInfo addImageWithSize:_thumbnailSize url:_localThumbnailDataPath];
        documentAttachment.thumbnailInfo = thumbnailInfo;
        
        TGLocalMessageMetaMediaAttachment *mediaMeta = [[TGLocalMessageMetaMediaAttachment alloc] init];
        mediaMeta.imageUrlToDataFile[_localThumbnailDataPath] = _localThumbnailDataPath;
        [attachments addObject:mediaMeta];
    }
    [attachments addObject:documentAttachment];
    
    if (self.replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyAttachment = [[TGReplyMessageMediaAttachment alloc] init];
        replyAttachment.replyMessageId = self.replyMessage.mid;
        replyAttachment.replyMessage = self.replyMessage;
        [attachments addObject:replyAttachment];
    }
    
    if (self.replyMarkup != nil) {
        [attachments addObject:self.replyMarkup];
    }
    
    message.mediaAttachments = attachments;
    
    return message;
}

- (TGDocumentMediaAttachment *)document {
    TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] init];
    documentAttachment.localDocumentId = _localDocumentId;
    documentAttachment.size = _size;
    documentAttachment.attributes = _attributes;
    documentAttachment.mimeType = _mimeType;
    
    if (_localThumbnailDataPath != nil)
    {
        TGImageInfo *thumbnailInfo = [[TGImageInfo alloc] init];
        [thumbnailInfo addImageWithSize:_thumbnailSize url:_localThumbnailDataPath];
        documentAttachment.thumbnailInfo = thumbnailInfo;
    }
    
    return documentAttachment;
}

@end
