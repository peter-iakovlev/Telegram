#import "TGMediaPickerGalleryItem.h"
#import "TGModernGalleryItemView.h"

@implementation TGMediaPickerGalleryItem

- (instancetype)initWithAsset:(TGMediaPickerAsset *)asset
{    
    self = [super init];
    if (self != nil)
    {
        _asset = asset;
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernGalleryItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGMediaPickerGalleryItem class]] && TGObjectCompare(_asset, ((TGMediaPickerGalleryItem *)object)->_asset);
}

@end
