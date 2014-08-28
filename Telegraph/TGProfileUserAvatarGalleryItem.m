#import "TGProfileUserAvatarGalleryItem.h"

#import "TGProfileUserAvatarGalleryItemView.h"

@implementation TGProfileUserAvatarGalleryItem

- (instancetype)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize
{
    self = [super initWithLegacyThumbnailUrl:legacyThumbnailUrl legacyUrl:legacyUrl imageSize:imageSize];
    if (self != nil)
    {
        _imageId = imageId;
        _accessHash = accessHash;
    }
    return self;
}

- (Class)viewClass
{
    return [TGProfileUserAvatarGalleryItemView class];
}

@end
