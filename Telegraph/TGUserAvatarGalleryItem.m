#import "TGUserAvatarGalleryItem.h"

#import "TGUserAvatarGalleryItemView.h"

#import "TGRemoteImageView.h"

@implementation TGUserAvatarGalleryItem

- (instancetype)initWithLegacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize isCurrent:(bool)isCurrent
{
    NSMutableString *imageUri = [[NSMutableString alloc] initWithString:@"peer-avatar://?"];
    [imageUri appendFormat:@"legacy-cache-url=%@", legacyUrl];
    [imageUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailUrl];
    [imageUri appendFormat:@"&width=%d&height=%d", (int)imageSize.width, (int)imageSize.height];
    
    self = [super initWithUri:imageUri imageSize:imageSize];
    if (self != nil)
    {
        _legacyThumbnailUrl = legacyThumbnailUrl;
        _legacyUrl = legacyUrl;
        _isCurrent = isCurrent;
    }
    return self;
}

- (Class)viewClass
{
    return [TGUserAvatarGalleryItemView class];
}

- (NSString *)filePath
{
    return [[TGRemoteImageView sharedCache] pathForCachedData:_legacyUrl];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGUserAvatarGalleryItem class]] && ((_isCurrent && ((TGUserAvatarGalleryItem *)object)->_isCurrent) || [super isEqual:object]);
}

@end
