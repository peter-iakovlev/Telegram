#import "TGUserAvatarGalleryModel.h"

@interface TGProfileUserAvatarGalleryModel : TGUserAvatarGalleryModel

@property (nonatomic, copy) void (^deleteCurrentAvatar)();

- (instancetype)initWithCurrentAvatarLegacyThumbnailImageUri:(NSString *)currentAvatarLegacyThumbnailImageUri currentAvatarLegacyImageUri:(NSString *)currentAvatarLegacyImageUri currentAvatarImageSize:(CGSize)currentAvatarImageSize;

@end
