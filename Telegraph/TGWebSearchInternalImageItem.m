#import "TGWebSearchInternalImageItem.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGWebSearchInternalImageResult+TGMediaItem.h"

#import <LegacyComponents/TGRemoteImageView.h>

#import "TGWebSearchInternalImageItemView.h"

@implementation TGWebSearchInternalImageItem

@synthesize selectionContext;
@synthesize editingContext;

- (instancetype)initWithSearchResult:(TGWebSearchInternalImageResult *)searchResult
{
    TGImageInfo *legacyImageInfo = searchResult.imageInfo;
    
    CGSize imageSize = CGSizeZero;
    NSString *legacyCacheUrl = [legacyImageInfo closestImageUrlWithSize:CGSizeMake(1000.0f, 1000.0f) resultingSize:&imageSize];
    NSString *legacyThumbnailCacheUrl = [legacyImageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    
    CGSize renderSize = CGSizeMake(90.0f, 90.0f);
    imageSize = TGFillSize(TGFitSize(imageSize, renderSize), renderSize);
    
    NSString *legacyFilePath = nil;
    if ([legacyCacheUrl hasPrefix:@"file://"])
        legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
    else
        legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
    
    NSMutableString *imageUri = [[NSMutableString alloc] init];
    [imageUri appendString:@"media-list-photo-thumbnail://?"];
    if (searchResult.imageId != 0)
        [imageUri appendFormat:@"id=%" PRId64 "", searchResult.imageId];
    [imageUri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
    [imageUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUrl];
    
    [imageUri appendFormat:@"&width=%d", (int)renderSize.width];
    [imageUri appendFormat:@"&height=%d", (int)renderSize.height];
    [imageUri appendFormat:@"&renderWidth=%d", (int)imageSize.width];
    [imageUri appendFormat:@"&renderHeight=%d", (int)imageSize.height];
    
    //[imageUri appendFormat:@"&messageId=%" PRId32 "", (int32_t)messageId];
    //[imageUri appendFormat:@"&conversationId=%" PRId64 "", (int64_t)peerId];
    [imageUri appendFormat:@"&legacy-cache-url=%@", legacyCacheUrl];
    
    self = [super initWithImageUri:imageUri];
    if (self != nil)
    {
        _webSearchResult = searchResult;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

- (id<TGMediaSelectableItem>)selectableMediaItem
{
    return self.webSearchResult;
}

- (id<TGMediaEditableItem>)editableMediaItem
{
    return self.webSearchResult;
}

- (Class)viewClass
{
    return [TGWebSearchInternalImageItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchInternalImageItem class]] && TGObjectCompare(_webSearchResult, ((TGWebSearchInternalImageItem *)object)->_webSearchResult);
}

@end
