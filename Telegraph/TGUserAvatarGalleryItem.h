#import "TGModernGalleryImageItem.h"

@interface TGUserAvatarGalleryItem : TGModernGalleryImageItem

@property (nonatomic, strong, readonly) NSString *legacyThumbnailUrl;
@property (nonatomic, strong, readonly) NSString *legacyUrl;

- (instancetype)initWithLegacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize;

- (NSString *)filePath;

@end
