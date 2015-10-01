#import "TGMediaPickerGalleryPhotoItem.h"

#import "TGMediaPickerGalleryPhotoItemView.h"

#import "TGMediaPickerAsset+TGEditablePhotoItem.h"

@implementation TGMediaPickerGalleryPhotoItem

@synthesize itemSelected = _itemSelected;

- (NSString *)uniqueId
{
    return self.asset.uniqueId;
}

- (id<TGEditablePhotoItem>)editableMediaItem
{
    return self.asset;
}

- (Class)viewClass
{
    return [TGMediaPickerGalleryPhotoItemView class];
}

@end
