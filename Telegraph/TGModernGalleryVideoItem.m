#import "TGModernGalleryVideoItem.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGModernGalleryVideoItemView.h"

@implementation TGModernGalleryVideoItem

- (instancetype)initWithMedia:(id)media previewUri:(NSString *)previewUri
{
    self = [super init];
    if (self != nil)
    {
        _media = media;
        _previewUri = previewUri;
    }
    return self;
}

- (CGSize)imageSize
{
    if ([_media isKindOfClass:[TGVideoMediaAttachment class]])
        return ((TGVideoMediaAttachment *)_media).dimensions;
    
    return CGSizeZero;
}

- (Class)viewClass
{
    return [TGModernGalleryVideoItemView class];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TGModernGalleryVideoItem class]])
    {
        return TGStringCompare(_previewUri, ((TGModernGalleryVideoItem *)object).previewUri) && TGObjectCompare(_media, ((TGModernGalleryVideoItem *)object).media);
    }
    
    return false;
}

@end
