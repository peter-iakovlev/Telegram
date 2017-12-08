#import <LegacyComponents/TGModernGalleryModel.h>

@class TGUserAvatarGalleryItem;

@interface TGUserAvatarGalleryModel : TGModernGalleryModel

- (instancetype)initWithPeerId:(int64_t)peerId currentAvatarLegacyThumbnailImageUri:(NSString *)currentAvatarLegacyThumbnailImageUri currentAvatarLegacyImageUri:(NSString *)currentAvatarLegacyImageUri currentAvatarImageSize:(CGSize)currentAvatarImageSize;

- (TGUserAvatarGalleryItem *)itemForImageId:(int64_t)imageId accessHash:(int64_t)accessHash legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize isCurrent:(bool)isCurrent;

- (void)_commitDeletedGroupItem:(TGUserAvatarGalleryItem *)item;

@end
