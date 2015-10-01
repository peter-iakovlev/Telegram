/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedLocalImageMessage.h"

#import "TGMessage.h"

#import "TGAppDelegate.h"

@implementation TGPreparedLocalImageMessage

+ (instancetype)messageWithImageData:(NSData *)imageData imageSize:(CGSize)imageSize thumbnailData:(NSData *)thumbnailData thumbnailSize:(CGSize)thumbnailSize assetUrl:(NSString *)assetUrl caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage
{
#ifdef DEBUG
    NSAssert(imageData != nil, @"imageData should not be nil");
    NSAssert(thumbnailData != nil, @"thumbnailData should not be nil");
#endif
    
    TGPreparedLocalImageMessage *message = [[TGPreparedLocalImageMessage alloc] init];
    
    message.imageSize = imageSize;
    message.thumbnailSize = thumbnailSize;
    message.assetUrl = assetUrl;
    
    message.localImageDataPath = [self _fileUrlForStoredData:imageData];
    message.localThumbnailDataPath = [self _fileUrlForStoredData:thumbnailData];
    
    message.caption = caption;
    
    message.replyMessage = replyMessage;
    
    return message;
}

+ (instancetype)messageWithLocalImageDataPath:(NSString *)localImageDataPath imageSize:(CGSize)imageSize localThumbnailDataPath:(NSString *)localThumbnailDataPath thumbnailSize:(CGSize)thumbnailSize assetUrl:(NSString *)assetUrl caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage
{
#ifdef DEBUG
    NSAssert(localImageDataPath != nil, @"localImageDataPath should not be nil");
    NSAssert(localThumbnailDataPath != nil, @"localThumbnailDataPath should not be nil");
#endif
    
    TGPreparedLocalImageMessage *message = [[TGPreparedLocalImageMessage alloc] init];
    
    message.imageSize = imageSize;
    message.thumbnailSize = thumbnailSize;
    message.assetUrl = assetUrl;
    
    message.localImageDataPath = localImageDataPath;
    message.localThumbnailDataPath = localThumbnailDataPath;
    
    message.caption = caption;
    
    message.replyMessage = replyMessage;
    
    return message;
}

+ (instancetype)messageByCopyingMessageData:(TGPreparedLocalImageMessage *)source
{
    TGPreparedLocalImageMessage *message = [[TGPreparedLocalImageMessage alloc] init];
    
    message.imageSize = source.imageSize;
    message.thumbnailSize = source.thumbnailSize;
    message.assetUrl = source.assetUrl;
    
    message.localImageDataPath = [TGPreparedLocalImageMessage _fileUrlForStoredFile:source.localImageDataPath];
    message.localThumbnailDataPath = [TGPreparedLocalImageMessage _fileUrlForStoredFile:source.localThumbnailDataPath];
    
    message.caption = source.caption;
    
    message.replyMessage = source.replyMessage;
    
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

+ (NSString *)_fileUrlForStoredFile:(NSString *)storedFilePath
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *uploadDirectory = [documentsDirectory stringByAppendingPathComponent:@"upload"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:uploadDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:uploadDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    int64_t randomId = 0;
    arc4random_buf(&randomId, sizeof(randomId));
    NSString *imagePathComponent = [[NSString alloc] initWithFormat:@"%" PRIx64 ".bin", randomId];
    NSString *filePath = [uploadDirectory stringByAppendingPathComponent:imagePathComponent];
    [[NSFileManager defaultManager] copyItemAtURL:[NSURL URLWithString:storedFilePath] toURL:[NSURL URLWithString:[@"file://" stringByAppendingString:filePath]] error:nil];
    
    return [@"file://" stringByAppendingString:filePath];
}

- (TGMessage *)message
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
    TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
    [imageInfo addImageWithSize:_imageSize url:[self localImageDataPath]];
    [imageInfo addImageWithSize:_thumbnailSize url:[self localThumbnailDataPath]];
    imageAttachment.imageInfo = imageInfo;
    imageAttachment.caption = self.caption;
    [attachments addObject:imageAttachment];
    
    TGLocalMessageMetaMediaAttachment *mediaMeta = [[TGLocalMessageMetaMediaAttachment alloc] init];
    mediaMeta.imageUrlToDataFile[[self localImageDataPath]] = [self localImageDataPath];
    mediaMeta.imageUrlToDataFile[[self localThumbnailDataPath]] = [self localThumbnailDataPath];
    [attachments addObject:mediaMeta];
    
    if (_replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = _replyMessage.mid;
        replyMedia.replyMessage = _replyMessage;
        [attachments addObject:replyMedia];
    }
    
    message.mediaAttachments = attachments;
    
    return message;
}

@end
