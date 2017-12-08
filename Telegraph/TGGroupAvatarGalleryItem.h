#import <LegacyComponents/TGModernGalleryImageItem.h>

@class TGImageInfo;

@interface TGGroupAvatarGalleryItem : TGModernGalleryImageItem <TGModernGalleryItem>

@property (nonatomic, readonly) int32_t messageId;

- (instancetype)initWithMessageId:(int32_t)messageId legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageId:(int64_t)imageId imageSize:(CGSize)imageSize;
- (NSString *)filePath;

@end
