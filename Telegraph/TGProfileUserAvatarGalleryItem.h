#import "TGUserAvatarGalleryItem.h"

@interface TGProfileUserAvatarGalleryItem : TGUserAvatarGalleryItem

@property (nonatomic, readonly) int64_t imageId;
@property (nonatomic, readonly) int64_t accessHash;

- (instancetype)initWithImageId:(int64_t)imageId accessHash:(int64_t)accessHash legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize isCurrent:(bool)isCurrent;

@end
