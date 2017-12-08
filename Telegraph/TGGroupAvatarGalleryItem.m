#import "TGGroupAvatarGalleryItem.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGGroupAvatarGalleryItemView.h"

#import <LegacyComponents/TGRemoteImageView.h>

@interface TGGroupAvatarGalleryItem ()
{
    NSString *_legacyUrl;
}

@end

@implementation TGGroupAvatarGalleryItem

- (Class)viewClass
{
    return [TGGroupAvatarGalleryItemView class];
}

- (instancetype)initWithMessageId:(int32_t)messageId legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageId:(int64_t)imageId imageSize:(CGSize)imageSize
{
    NSMutableString *imageUri = [[NSMutableString alloc] initWithString:@"peer-avatar://?"];
    [imageUri appendFormat:@"legacy-cache-url=%@", legacyUrl];
    [imageUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailUrl];
    [imageUri appendFormat:@"&width=%d&height=%d", (int)imageSize.width, (int)imageSize.height];
    if (imageId != 0)
        [imageUri appendFormat:@"&imageId=%lld", imageId];
    
    self = [super initWithUri:imageUri imageSize:imageSize];
    if (self != nil)
    {
        self.imageId = imageId;
        _messageId = messageId;
        _legacyUrl = legacyUrl;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object])
        return false;
    
    if ([object isKindOfClass:[TGGroupAvatarGalleryItem class]] && _messageId == ((TGGroupAvatarGalleryItem *)object).messageId)
    {
        return true;
    }
    
    return false;
}

- (NSString *)filePath
{
    return [[TGRemoteImageView sharedCache] pathForCachedData:_legacyUrl];
}

@end
