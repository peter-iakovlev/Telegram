#import "TGSecretPeerMediaGalleryVideoItem.h"

#import "TGMessage.h"
#import "TGImageInfo.h"

#import "TGSecretPeerMediaGalleryVideoItemView.h"

#import "TGAppDelegate.h"

#import "TGPreparedLocalDocumentMessage.h"

@implementation TGSecretPeerMediaGalleryVideoItem

- (NSString *)filePathForVideoId:(int64_t)videoId local:(bool)local
{
    static NSString *videosDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *documentsDirectory = [TGAppDelegate documentsPath];
        videosDirectory = [documentsDirectory stringByAppendingPathComponent:@"video"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:videosDirectory])
            [[NSFileManager defaultManager] createDirectoryAtPath:videosDirectory withIntermediateDirectories:true attributes:nil error:nil];
    });
    
    return [videosDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@%" PRIx64 ".mov", local ? @"local" : @"remote", videoId]];
}

- (instancetype)initWithVideoMedia:(TGVideoMediaAttachment *)videoMedia peerId:(int64_t)peerId messageId:(int32_t)messageId messageCountdownTime:(NSTimeInterval)messageCountdownTime messageLifetime:(NSTimeInterval)messageLifetime
{
    NSMutableString *previewUri = nil;
    
    NSString *legacyVideoFilePath = [self filePathForVideoId:videoMedia.videoId != 0 ? videoMedia.videoId : videoMedia.localVideoId local:videoMedia.videoId == 0];
    NSString *legacyThumbnailCacheUri = [videoMedia.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    
    if (videoMedia.videoId != 0 || videoMedia.localVideoId != 0)
    {
        previewUri = [[NSMutableString alloc] initWithString:@"media-gallery-video-preview://?"];
        if (videoMedia.videoId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", videoMedia.videoId];
        else
            [previewUri appendFormat:@"local-id=%" PRId64 "", videoMedia.localVideoId];
        
        CGSize size = videoMedia.dimensions;
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)size.width, (int)size.height, (int)size.width, (int)size.height];
        
        [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
        if (legacyThumbnailCacheUri != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        
        [previewUri appendFormat:@"&messageId=%" PRId32 "", (int32_t)messageId];
        [previewUri appendFormat:@"&conversationId=%" PRId64 "", (int64_t)peerId];
    }
    
    self = [super initWithMedia:videoMedia previewUri:previewUri];
    if (self != nil)
    {
        _peerId = peerId;
        _messageId = messageId;
        _messageCountdownTime = messageCountdownTime;
        _messageLifetime = messageLifetime;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object])
        return false;
    
    if ([object isKindOfClass:[TGSecretPeerMediaGalleryVideoItem class]])
    {
        return _messageId == ((TGSecretPeerMediaGalleryVideoItem *)object).messageId && _peerId == ((TGSecretPeerMediaGalleryVideoItem *)object).peerId;
    }
    
    return false;
}

- (id)videoDownloadArguments
{
    return @{@"peerId": @(_peerId), @"messageId": @(_messageId)};
}

- (NSString *)filePath
{
    if ([self.media isKindOfClass:[TGVideoMediaAttachment class]]) {
        TGVideoMediaAttachment *videoMedia = self.media;
        NSString *legacyVideoFilePath = [self filePathForVideoId:videoMedia.videoId != 0 ? videoMedia.videoId : videoMedia.localVideoId local:videoMedia.videoId == 0];
        return legacyVideoFilePath;
    } else if ([self.media isKindOfClass:[TGDocumentMediaAttachment class]]) {
        TGDocumentMediaAttachment *documentMedia = self.media;
        NSString *documentPath = documentMedia.localDocumentId != 0 ? [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:documentMedia.localDocumentId version:documentMedia.version] : [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentMedia.documentId version:documentMedia.version];
        NSString *legacyVideoFilePath = [documentPath stringByAppendingPathComponent:[documentMedia safeFileName]];
        return legacyVideoFilePath;
    } else {
        return nil;
    }
}

- (Class)viewClass
{
    return [TGSecretPeerMediaGalleryVideoItemView class];
}

@end
