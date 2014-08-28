#import "TGUserAvatarGalleryItem.h"

#import "TGUserAvatarGalleryItemView.h"

@implementation TGUserAvatarGalleryItem

- (instancetype)initWithLegacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize
{
    NSMutableString *imageUri = [[NSMutableString alloc] initWithString:@"peer-avatar://?"];
    [imageUri appendFormat:@"legacy-cache-url=%@", legacyUrl];
    [imageUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailUrl];
    [imageUri appendFormat:@"&width=%d&height=%d", (int)imageSize.width, (int)imageSize.height];
    
    self = [super initWithUri:imageUri imageSize:imageSize];
    if (self != nil)
    {
        _legacyThumbnailUrl = legacyThumbnailUrl;
    }
    return self;
}

- (Class)viewClass
{
    return [TGUserAvatarGalleryItemView class];
}

@end
