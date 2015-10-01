#import "TGWebSearchInternalImageItem.h"

#import "TGWebSearchInternalImageResult+TGEditablePhotoItem.h"

#import "TGImageUtils.h"
#import "TGImageInfo.h"
#import "TGRemoteImageView.h"

#import "TGWebSearchInternalImageItemView.h"

@implementation TGWebSearchInternalImageItem

- (instancetype)initWithSearchResult:(TGWebSearchInternalImageResult *)searchResult isEditing:(bool (^)())isEditing toggleEditing:(void (^)())toggleEditing itemSelected:(void (^)(id<TGWebSearchListItem>))itemSelected isItemSelected:(bool (^)(id<TGWebSearchListItem>))isItemSelected isItemHidden:(bool (^)(id<TGWebSearchListItem>))isItemHidden
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
        
        _isEditing = [isEditing copy];
        _toggleEditing = [toggleEditing copy];
        _itemSelected = [itemSelected copy];
        _isItemSelected = [isItemSelected copy];
        _isItemHidden = [isItemHidden copy];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

- (id<TGEditablePhotoItem>)editableMediaItem
{
    return self.webSearchResult;
}

- (NSString *)uniqueId
{
    return [self.webSearchResult uniqueId];
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
