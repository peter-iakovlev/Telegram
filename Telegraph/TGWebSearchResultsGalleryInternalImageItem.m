#import "TGWebSearchResultsGalleryInternalImageItem.h"

#import "TGWebSearchResultsGalleryImageItemView.h"
#import "TGWebSearchInternalImageResult+TGMediaItem.h"

#import "TGImageInfo.h"
#import "TGRemoteImageView.h"

#import "TGStringUtils.h"

#import "TGUser.h"

@implementation TGWebSearchResultsGalleryInternalImageItem

@synthesize selectionContext;
@synthesize editingContext;

- (instancetype)initWithSearchResult:(TGWebSearchInternalImageResult *)searchResult
{
    TGImageInfo *legacyImageInfo = searchResult.imageInfo;
    
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
    if (searchResult.imageId != 0)
        [imageUri appendFormat:@"&id=%" PRId64 "", searchResult.imageId];
    [imageUri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
    
    NSString *escapedLegacyThumbnailCacheUrl = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)legacyThumbnailCacheUrl, (__bridge CFStringRef)@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-", (__bridge CFStringRef)@"&?= ", kCFStringEncodingUTF8);
    [imageUri appendFormat:@"&legacy-thumbnail-cache-url=%@", escapedLegacyThumbnailCacheUrl];
    
    [imageUri appendFormat:@"&width=%d", (int)imageSize.width];
    [imageUri appendFormat:@"&height=%d", (int)imageSize.height];
    [imageUri appendFormat:@"&renderWidth=%d", (int)imageSize.width];
    [imageUri appendFormat:@"&renderHeight=%d", (int)imageSize.height];
    
    //[imageUri appendFormat:@"&messageId=%" PRId32 "", (int32_t)messageId];
    //[imageUri appendFormat:@"&conversationId=%" PRId64 "", (int64_t)peerId];
    
    NSString *escapedCacheUrl = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)legacyCacheUrl, (__bridge CFStringRef)@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-", (__bridge CFStringRef)@"&?= :/", kCFStringEncodingUTF8);
    [imageUri appendFormat:@"&legacy-cache-url=%@", escapedCacheUrl];
    
    self = [super initWithUri:imageUri imageSize:imageSize];
    if (self != nil)
    {
        _webSearchResult = searchResult;
    }
    return self;
}

- (Class)viewClass
{
    return [TGWebSearchResultsGalleryImageItemView class];
}

- (id<TGMediaSelectableItem>)selectableMediaItem
{
    return self.webSearchResult;
}

- (id<TGMediaEditableItem>)editableMediaItem
{
    return self.webSearchResult;
}

- (TGPhotoEditorTab)toolbarTabs
{
    return TGPhotoEditorCropTab | TGPhotoEditorToolsTab;
}

- (NSString *)uniqueId
{
    return [self.webSearchResult uniqueIdentifier];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchResultsGalleryInternalImageItem class]] && TGObjectCompare(_webSearchResult, ((TGWebSearchResultsGalleryInternalImageItem *)object)->_webSearchResult);
}

@end
