/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPreparedLocalVideoMessage.h"

#import "TGMessage.h"

#import "TGImageUtils.h"
#import "TGRemoteImageView.h"

#import "TGAppDelegate.h"

@implementation TGPreparedLocalVideoMessage

+ (instancetype)messageWithTempVideoPath:(NSString *)tempVideoPath videoSize:(CGSize)videoSize size:(int32_t)size duration:(NSTimeInterval)duration previewImage:(UIImage *)previewImage thumbnailSize:(CGSize)thumbnailSize assetUrl:(NSString *)assetUrl caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
#ifdef DEBUG
    NSAssert(tempVideoPath != nil, @"tempVideoPath should not be nil");
    NSAssert(previewImage != nil, @"previewImage should not be nil");
#endif
    
    TGPreparedLocalVideoMessage *message = [[TGPreparedLocalVideoMessage alloc] init];
    
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    int64_t localVideoId = 0;
    arc4random_buf(&localVideoId, 8);
    
    NSString *uploadVideoFile = [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%llx.mov", localVideoId]];
    [[NSFileManager defaultManager] moveItemAtPath:tempVideoPath toPath:uploadVideoFile error:nil];
    [[NSFileManager defaultManager] createSymbolicLinkAtPath:tempVideoPath withDestinationPath:uploadVideoFile error:nil];
    
    message.localVideoId = localVideoId;
    message.duration = duration;
    message.videoSize = videoSize;
    message.size = size;
    
    NSData *previewData = UIImageJPEGRepresentation(previewImage, 0.87f);
    [[TGRemoteImageView sharedCache] cacheImage:nil withData:previewData url:[[NSString alloc] initWithFormat:@"video-thumbnail-local%llx.jpg", localVideoId] availability:TGCacheDisk];
    
    UIImage *thumbnailImage = TGScaleImageToPixelSize(previewImage, thumbnailSize);
    NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 0.9f);
    message.localThumbnailDataPath = [self _fileUrlForStoredData:thumbnailData];
    CGSize networkThumbnailSize = TGFitSize(thumbnailSize, CGSizeMake(90, 90));
    message.thumbnailSize = networkThumbnailSize;
    
    message.assetUrl = assetUrl;
    
    message.caption = caption;
    
    message.replyMessage = replyMessage;
    message.replyMarkup = replyMarkup;
    
    return message;
}

+ (instancetype)messageWithLocalVideoId:(int64_t)localVideoId videoSize:(CGSize)videoSize size:(int32_t)size duration:(NSTimeInterval)duration localThumbnailDataPath:(NSString *)localThumbnailDataPath thumbnailSize:(CGSize)thumbnailSize assetUrl:(NSString *)assetUrl caption:(NSString *)caption replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
#ifdef DEBUG
    NSAssert(localThumbnailDataPath != nil, @"localThumbnailDataPath should not be nil");
#endif
    
    TGPreparedLocalVideoMessage *message = [[TGPreparedLocalVideoMessage alloc] init];
    
    message.localVideoId = localVideoId;
    message.videoSize = videoSize;
    message.size = size;
    message.duration = duration;
    message.localThumbnailDataPath = localThumbnailDataPath;
    message.thumbnailSize = thumbnailSize;
    message.assetUrl = assetUrl;
    message.caption = caption;
    message.replyMessage = replyMessage;
    message.replyMarkup = replyMarkup;
    
    return message;
}

+ (instancetype)messageByCopyingDataFromMessage:(TGPreparedLocalVideoMessage *)source
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
        if ([mediaAttachment isKindOfClass:[TGVideoMediaAttachment class]])
        {
            return [self messageByCopyingDataFromMedia:mediaAttachment replyMessage:replyMessage replyMarkup:replyMarkup];
        }
    }
    
    return nil;
}

+ (instancetype)messageByCopyingDataFromMedia:(TGVideoMediaAttachment *)videoAttachment replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup
{
#ifdef DEBUG
    NSAssert(videoAttachment != nil, @"videoAttachment should not be nil");
#endif
    
    int32_t fileSize = 0;
    NSString *currentUrl = [videoAttachment.videoInfo urlWithQuality:0 actualQuality:NULL actualSize:&fileSize];
    if (currentUrl == nil)
        return nil;
    
    TGPreparedLocalVideoMessage *message = [[TGPreparedLocalVideoMessage alloc] init];
    
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    int64_t localVideoId = 0;
    arc4random_buf(&localVideoId, sizeof(localVideoId));
    
    NSString *currentVideoFile = [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%llx.mov", videoAttachment.localVideoId]];
    NSString *uploadVideoFile = [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%llx.mov", localVideoId]];
    [[NSFileManager defaultManager] copyItemAtPath:currentVideoFile toPath:uploadVideoFile error:nil];
    
    message.localVideoId = localVideoId;
    message.duration = videoAttachment.duration;
    message.videoSize = videoAttachment.dimensions;
    message.size = fileSize;
    
    NSData *previewData = [[NSData alloc] initWithContentsOfFile:[[TGRemoteImageView sharedCache] pathForCachedData:[[NSString alloc] initWithFormat:@"video-thumbnail-local%llx.jpg", videoAttachment.localVideoId]]];
    [[TGRemoteImageView sharedCache] cacheImage:nil withData:previewData url:[[NSString alloc] initWithFormat:@"video-thumbnail-local%llx.jpg", localVideoId] availability:TGCacheDisk];
    
    CGSize thumbnailSize = CGSizeZero;
    NSString *thumbnailUrl = [videoAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeMake(90, 90) resultingSize:NULL];
    NSString *thumbnailFile = nil;
    if ([thumbnailUrl hasPrefix:@"file://"])
        thumbnailFile = [thumbnailUrl substringFromIndex:@"file://".length];
    if (thumbnailFile != nil)
    {
        NSData *thumbnailData = [[NSData alloc] initWithContentsOfFile:thumbnailFile];
        message.localThumbnailDataPath = [self _fileUrlForStoredData:thumbnailData];
    }
    
    message.thumbnailSize = thumbnailSize;
    
    message.caption = videoAttachment.caption;
    
    message.replyMessage = replyMessage;
    message.replyMarkup = replyMarkup;
    
    return message;
}

+ (NSString *)_fileUrlForMovedTempFile:(NSString *)tempFilePath
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *videoDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    int64_t randomId = 0;
    arc4random_buf(&randomId, sizeof(randomId));
    NSString *imagePathComponent = [[NSString alloc] initWithFormat:@"local%" PRIx64 ".mov", randomId];
    NSString *filePath = [videoDirectory stringByAppendingPathComponent:imagePathComponent];

    [[NSFileManager defaultManager] moveItemAtPath:tempFilePath toPath:filePath error:nil];
    
    return [@"file://" stringByAppendingString:filePath];
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

- (NSString *)localVideoPath
{
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    NSString *videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    
    return [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"local%llx.mov", _localVideoId]];
}

- (TGMessage *)message
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    
    TGVideoMediaAttachment *videoAttachment = [[TGVideoMediaAttachment alloc] init];
    videoAttachment.localVideoId = _localVideoId;
    videoAttachment.duration = (int)_duration;
    videoAttachment.dimensions = _videoSize;
    
    TGImageInfo *thumbnailInfo = [[TGImageInfo alloc] init];
    [thumbnailInfo addImageWithSize:_thumbnailSize url:_localThumbnailDataPath];
    videoAttachment.thumbnailInfo = thumbnailInfo;
    
    TGVideoInfo *videoInfo = [[TGVideoInfo alloc] init];
    [videoInfo addVideoWithQuality:1 url:[[NSString alloc] initWithFormat:@"local-video:local%llx.mov", _localVideoId] size:_size];
    videoAttachment.videoInfo = videoInfo;
    videoAttachment.caption = self.caption;
    [attachments addObject:videoAttachment];
    
    TGLocalMessageMetaMediaAttachment *mediaMeta = [[TGLocalMessageMetaMediaAttachment alloc] init];
    mediaMeta.imageUrlToDataFile[_localThumbnailDataPath] = _localThumbnailDataPath;
    [attachments addObject:mediaMeta];
    
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
    
    return message;
}

@end
