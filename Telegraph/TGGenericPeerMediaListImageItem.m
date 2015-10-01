#import "TGGenericPeerMediaListImageItem.h"

#import "TGImageInfo.h"
#import "TGRemoteImageView.h"

#import "TGImageUtils.h"

@interface TGGenericPeerMediaListImageItem ()
{
    NSString *_thumbnailUri;
}

@end

@implementation TGGenericPeerMediaListImageItem

- (instancetype)initWithImageId:(int64_t)imageId orLocalId:(int64_t)localId peerId:(int64_t)peerId messageId:(int32_t)messageId date:(NSTimeInterval)date legacyImageInfo:(TGImageInfo *)legacyImageInfo
{
    CGSize imageSize = CGSizeZero;
    NSString *legacyCacheUrl = [legacyImageInfo closestImageUrlWithSize:CGSizeMake(1000.0f, 1000.0f) resultingSize:&imageSize];
    NSString *legacyThumbnailCacheUrl = [legacyImageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    
    CGSize renderSize = CGSizeMake(50.0f, 50.0f);
    imageSize = TGFillSize(TGFitSize(imageSize, renderSize), renderSize);
    
    NSString *legacyFilePath = nil;
    if ([legacyCacheUrl hasPrefix:@"file://"])
        legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
    else
        legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
    
    NSMutableString *imageUri = [[NSMutableString alloc] init];
    [imageUri appendString:@"media-list-photo-thumbnail://?"];
    if (imageId != 0)
        [imageUri appendFormat:@"id=%" PRId64 "", imageId];
    else if (localId != 0)
        [imageUri appendFormat:@"local-id=%" PRId64 "", imageId];
    [imageUri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
    [imageUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUrl];
    
    [imageUri appendFormat:@"&width=%d", (int)renderSize.width];
    [imageUri appendFormat:@"&height=%d", (int)renderSize.height];
    [imageUri appendFormat:@"&renderWidth=%d", (int)imageSize.width];
    [imageUri appendFormat:@"&renderHeight=%d", (int)imageSize.height];
    
    [imageUri appendFormat:@"&messageId=%" PRId32 "", (int32_t)messageId];
    [imageUri appendFormat:@"&conversationId=%" PRId64 "", (int64_t)peerId];
    [imageUri appendFormat:@"&legacy-cache-url=%@", legacyCacheUrl];
    
    self = [super initWithImageUri:imageUri];
    if (self != nil)
    {
        _peerId = peerId;
        _messageId = messageId;
        _date = date;
        
        _thumbnailUri = legacyThumbnailCacheUrl;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object])
        return false;
    
    if ([object isKindOfClass:[TGGenericPeerMediaListImageItem class]])
    {
        return ABS(_date - ((TGGenericPeerMediaListImageItem *)object).date) < DBL_EPSILON && _messageId == ((TGGenericPeerMediaListImageItem *)object).messageId && _peerId == ((TGGenericPeerMediaListImageItem *)object).peerId;
    }
    
    return false;
}

- (bool)hasThumbnailUri:(NSString *)thumbnailUri
{
    return [_thumbnailUri isEqualToString:thumbnailUri];
}

@end
