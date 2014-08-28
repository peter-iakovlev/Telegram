#import "TGGroupAvatarGalleryModel.h"

#import "TGGroupAvatarGalleryItem.h"

@implementation TGGroupAvatarGalleryModel

- (instancetype)initWithMessageId:(int32_t)messageId legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize
{
    self = [super init];
    if (self != nil)
    {
        TGGroupAvatarGalleryItem *item = [[TGGroupAvatarGalleryItem alloc] initWithMessageId:messageId legacyThumbnailUrl:legacyThumbnailUrl legacyUrl:legacyUrl imageSize:imageSize];
        [self _replaceItems:@[item] focusingOnItem:item];
    }
    return self;
}

@end
