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

@implementation TGPreparedLocalDocumentMessage

+ (instancetype)messageWithTempDocumentPath:(NSString *)tempDocumentPath size:(int32_t)size mimeType:(NSString *)mimeType thumbnailImage:(UIImage *)thumbnailImage thumbnailSize:(CGSize)thumbnailSize attributes:(NSArray *)attributes replyMessage:(TGMessage *)replyMessage
{
#ifdef DEBUG
    NSAssert(tempDocumentPath != nil, @"tempDocumentPath should not be nil");
#endif
    
    TGPreparedLocalDocumentMessage *message = [[TGPreparedLocalDocumentMessage alloc] init];
    
    int64_t localDocumentId = 0;
    arc4random_buf(&localDocumentId, 8);
    
    NSString *currentDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:localDocumentId];
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
    
    message.replyMessage = replyMessage;
    
    return message;
}

+ (instancetype)messageByCopyingDataFromMessage:(TGPreparedLocalDocumentMessage *)source
{
    TGMessage *replyMessage = nil;
    for (id mediaAttachment in source.message.mediaAttachments)
    {
        if ([mediaAttachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
        {
            replyMessage = ((TGReplyMessageMediaAttachment *)mediaAttachment).replyMessage;
        }
    }
    
    for (id mediaAttachment in source.message.mediaAttachments)
    {
        if ([mediaAttachment isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            return [self messageByCopyingDataFromMedia:mediaAttachment replyMessage:replyMessage];
        }
    }
    
    return nil;
}

+ (instancetype)messageByCopyingDataFromMedia:(TGDocumentMediaAttachment *)documentAttachment replyMessage:(TGMessage *)replyMessage
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
    
    NSString *previousDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:documentAttachment.localDocumentId];
    NSString *previousDocumentFile = [previousDocumentDirectory stringByAppendingPathComponent:[TGDocumentMediaAttachment safeFileNameForFileName:documentAttachment.fileName]];
    
    NSString *uploadDocumentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:localDocumentId];
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
    
    message.replyMessage = replyMessage;
    
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
    [data writeToFile:filePath atomically:false];
    
    return [@"file://" stringByAppendingString:filePath];
}

+ (instancetype)messageWithLocalDocumentId:(int64_t)localDocumentId size:(int32_t)size mimeType:(NSString *)mimeType localThumbnailDataPath:(NSString *)localThumbnailDataPath thumbnailSize:(CGSize)localThumbnailSize attributes:(NSArray *)attributes
{
    TGPreparedLocalDocumentMessage *message = [[TGPreparedLocalDocumentMessage alloc] init];
    
    message.localDocumentId = localDocumentId;
    message.size = size;
    message.attributes = attributes;
    message.mimeType = mimeType;
    message.localThumbnailDataPath = localThumbnailDataPath;
    message.thumbnailSize = localThumbnailSize;
    
    return message;
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

- (NSString *)localDocumentDirectory
{
    return [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:_localDocumentId];
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
    
    if (_replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyAttachment = [[TGReplyMessageMediaAttachment alloc] init];
        replyAttachment.replyMessageId = _replyMessage.mid;
        replyAttachment.replyMessage = _replyMessage;
        [attachments addObject:replyAttachment];
    }
    
    message.mediaAttachments = attachments;
    
    return message;
}

@end
