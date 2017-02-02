#import "TGModernGalleryModel.h"

@class TGImageInfo;

@interface TGGroupAvatarGalleryModel : TGModernGalleryModel

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize;

@end
