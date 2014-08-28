#import "TGModernGalleryModel.h"

@class TGImageInfo;

@interface TGGroupAvatarGalleryModel : TGModernGalleryModel

- (instancetype)initWithMessageId:(int32_t)messageId legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize;

@end
