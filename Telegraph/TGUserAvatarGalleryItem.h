#import <LegacyComponents/TGModernGalleryImageItem.h>

@interface TGUserAvatarGalleryItem : TGModernGalleryImageItem

@property (nonatomic, strong, readonly) NSString *legacyThumbnailUrl;
@property (nonatomic, strong, readonly) NSString *legacyUrl;

@property (nonatomic, readonly) bool isCurrent;

- (instancetype)initWithLegacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageId:(int64_t)imageId imageSize:(CGSize)imageSize isCurrent:(bool)isCurrent;

- (NSString *)filePath;

@end
