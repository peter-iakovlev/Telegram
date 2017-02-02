#import "TGUserAvatarGalleryItem.h"

@interface TGProfileUserAvatarGalleryItem : TGUserAvatarGalleryItem

- (instancetype)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize isCurrent:(bool)isCurrent;

@end
