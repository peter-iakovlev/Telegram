#import "TGGroupAvatarGalleryItem.h"

#import "TGGroupAvatarGalleryItemView.h"

#import "TGImageInfo.h"

@implementation TGGroupAvatarGalleryItem

- (Class)viewClass
{
    return [TGGroupAvatarGalleryItemView class];
}

- (instancetype)initWithMessageId:(int32_t)messageId legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize
{
    NSMutableString *imageUri = [[NSMutableString alloc] initWithString:@"peer-avatar://?"];
    [imageUri appendFormat:@"legacy-cache-url=%@", legacyUrl];
    [imageUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailUrl];
    [imageUri appendFormat:@"&width=%d&height=%d", (int)imageSize.width, (int)imageSize.height];
    
    self = [super initWithUri:imageUri imageSize:imageSize];
    if (self != nil)
    {
        _messageId = messageId;
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

@end
