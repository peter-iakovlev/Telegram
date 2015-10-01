#import "TGGenericPeerMediaListVideoItem.h"

#import "TGVideoMediaAttachment.h"
#import "TGImageUtils.h"

#import "TGAppDelegate.h"

@interface TGGenericPeerMediaListVideoItem ()
{
    NSString *_thumbnailUri;
}

@end

@implementation TGGenericPeerMediaListVideoItem

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

- (instancetype)initWithVideoMedia:(TGVideoMediaAttachment *)videoMedia peerId:(int64_t)peerId messageId:(int32_t)messageId date:(NSTimeInterval)date
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
        
        CGSize renderSize = CGSizeMake(50.0f, 50.0f);
        CGSize size = TGFillSize(TGFitSize(videoMedia.dimensions, renderSize), renderSize);
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)renderSize.width, (int)renderSize.height, (int)size.width, (int)size.height];
        
        [previewUri appendFormat:@"&legacy-video-file-path=%@", legacyVideoFilePath];
        if (legacyThumbnailCacheUri != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        
        [previewUri appendFormat:@"&messageId=%" PRId32 "", (int32_t)messageId];
        [previewUri appendFormat:@"&conversationId=%" PRId64 "", (int64_t)peerId];
    }

    self = [super initWithImageUri:previewUri duration:videoMedia.duration];
    if (self != nil)
    {
        _peerId = peerId;
        _messageId = messageId;
        _date = date;
        
        _thumbnailUri = legacyThumbnailCacheUri;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object])
        return false;
    
    if ([object isKindOfClass:[TGGenericPeerMediaListVideoItem class]])
    {
        return ABS(_date - ((TGGenericPeerMediaListVideoItem *)object).date) < DBL_EPSILON && _messageId == ((TGGenericPeerMediaListVideoItem *)object).messageId && _peerId == ((TGGenericPeerMediaListVideoItem *)object).peerId;
    }
    
    return false;
}

- (bool)hasThumbnailUri:(NSString *)thumbnailUri
{
    return [_thumbnailUri isEqualToString:thumbnailUri];
}

@end
