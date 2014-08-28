#import "TGGenericPeerMediaGalleryImageItem.h"

#import "TGImageInfo.h"
#import "TGRemoteImageView.h"

#import "TGStringUtils.h"

#import "TGUser.h"

@interface TGGenericPeerMediaGalleryImageItem ()
{
    TGImageInfo *_legacyImageInfo;
}

@end

@implementation TGGenericPeerMediaGalleryImageItem

- (instancetype)initWithImageId:(int64_t)imageId orLocalId:(int64_t)localId peerId:(int64_t)peerId messageId:(int32_t)messageId legacyImageInfo:(TGImageInfo *)legacyImageInfo
{
    CGSize imageSize = CGSizeZero;
    NSString *legacyCacheUrl = [legacyImageInfo closestImageUrlWithSize:CGSizeMake(1000.0f, 1000.0f) resultingSize:&imageSize];
    NSString *legacyThumbnailCacheUrl = [legacyImageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    
    NSString *legacyFilePath = nil;
    if ([legacyCacheUrl hasPrefix:@"file://"])
        legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
    else
        legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
    
    NSMutableString *imageUri = [[NSMutableString alloc] init];
    [imageUri appendString:@"media-gallery-image://?"];
    if (imageId != 0)
        [imageUri appendFormat:@"&id=%" PRId64 "", imageId];
    else if (localId != 0)
        [imageUri appendFormat:@"&local-id=%" PRId64 "", imageId];
    [imageUri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
    
    NSString *escapedLegacyThumbnailCacheUrl = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)legacyThumbnailCacheUrl, (__bridge CFStringRef)@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-", (__bridge CFStringRef)@"&?= ", kCFStringEncodingUTF8);
    [imageUri appendFormat:@"&legacy-thumbnail-cache-url=%@", escapedLegacyThumbnailCacheUrl];
    
    [imageUri appendFormat:@"&width=%d", (int)imageSize.width];
    [imageUri appendFormat:@"&height=%d", (int)imageSize.height];
    [imageUri appendFormat:@"&renderWidth=%d", (int)imageSize.width];
    [imageUri appendFormat:@"&renderHeight=%d", (int)imageSize.height];
    
    [imageUri appendFormat:@"&messageId=%" PRId32 "", (int32_t)messageId];
    [imageUri appendFormat:@"&conversationId=%" PRId64 "", (int64_t)peerId];
    
    NSString *escapedCacheUrl = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)legacyCacheUrl, (__bridge CFStringRef)@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-", (__bridge CFStringRef)@"&?= :/", kCFStringEncodingUTF8);
    [imageUri appendFormat:@"&legacy-cache-url=%@", escapedCacheUrl];
    
    self = [super initWithUri:imageUri imageSize:imageSize];
    if (self != nil)
    {
        _legacyImageInfo = legacyImageInfo;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object])
        return false;
    
    if ([object isKindOfClass:[TGGenericPeerMediaGalleryImageItem class]])
    {
        return TGObjectCompare(_author, ((TGGenericPeerMediaGalleryImageItem *)object).author) && ABS(_date - ((TGGenericPeerMediaGalleryImageItem *)object).date) < DBL_EPSILON && _messageId == ((TGGenericPeerMediaGalleryImageItem *)object).messageId;
    }
    
    return false;
}

- (NSString *)filePath
{
    NSString *legacyCacheUrl = [_legacyImageInfo closestImageUrlWithSize:CGSizeMake(1000.0f, 1000.0f) resultingSize:NULL];
    
    NSString *legacyFilePath = nil;
    if ([legacyCacheUrl hasPrefix:@"file://"])
        legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
    else
        legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
    
    return legacyFilePath;
}

@end
