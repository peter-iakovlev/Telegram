#import "TGModernGalleryImageItem.h"

@interface TGUserAvatarGalleryItem : TGModernGalleryImageItem

@property (nonatomic, strong, readonly) NSString *legacyThumbnailUrl;

- (instancetype)initWithLegacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize;

@end
