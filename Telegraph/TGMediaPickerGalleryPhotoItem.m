#import "TGMediaPickerGalleryPhotoItem.h"
#import "TGMediaPickerGalleryPhotoItemView.h"

#import "TGMediaAsset+TGMediaEditableItem.h"

@implementation TGMediaPickerGalleryPhotoItem

@synthesize selectionContext;
@synthesize editingContext;

- (NSString *)uniqueId
{
    return self.asset.identifier;
}

- (id<TGMediaSelectableItem>)selectableMediaItem
{
    return self.asset;
}

- (id<TGMediaEditableItem>)editableMediaItem
{
    return self.asset;
}

- (TGPhotoEditorTab)toolbarTabs
{
    return TGPhotoEditorCaptionTab | TGPhotoEditorCropTab | TGPhotoEditorToolsTab;
}

- (Class)viewClass
{
    return [TGMediaPickerGalleryPhotoItemView class];
}

@end
