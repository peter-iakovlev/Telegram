#import "TGProfileUserAvatarGalleryItem.h"

#import "TGProfileUserAvatarGalleryItemView.h"

@implementation TGProfileUserAvatarGalleryItem

- (instancetype)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize isCurrent:(bool)isCurrent
{
    self = [super initWithLegacyThumbnailUrl:legacyThumbnailUrl legacyUrl:legacyUrl imageSize:imageSize isCurrent:isCurrent];
    if (self != nil)
    {
        self.imageId = imageId;
        self.accessHash = accessHash;
    }
    return self;
}

- (Class)viewClass
{
    return [TGProfileUserAvatarGalleryItemView class];
}

@end
