#import "TGModernGalleryImageItem.h"

@interface TGUserAvatarGalleryItem : TGModernGalleryImageItem

@property (nonatomic, strong, readonly) NSString *legacyThumbnailUrl;
@property (nonatomic, strong, readonly) NSString *legacyUrl;

@property (nonatomic, readonly) bool isCurrent;

- (instancetype)initWithLegacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize isCurrent:(bool)isCurrent;

- (NSString *)filePath;

@end
