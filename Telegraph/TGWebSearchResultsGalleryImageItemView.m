#import "TGWebSearchResultsGalleryImageItemView.h"
#import "TGModernGalleryImageItemImageView.h"

#import "TGWebSearchResultsGalleryImageItem.h"
#import "TGWebSearchResultsGalleryInternalImageItem.h"

#import "TGBingSearchResultItem+TGEditablePhotoItem.h"
#import "TGWebSearchInternalImageResult+TGEditablePhotoItem.h"

#import "TGImageUtils.h"

#import "TGWebSearchResult.h"
#import "TGEditablePhotoItem.h"
#import "PGPhotoEditorValues.h"

@implementation TGWebSearchResultsGalleryImageItemView

- (void)setHiddenAsBeingEdited:(bool)hidden
{
    self.imageView.hidden = hidden;
}

- (void)setItem:(id<TGModernGalleryItem>)item synchronously:(bool)synchronously
{
    if (item == nil)
    {
        [super setItem:item synchronously:synchronously];
    }
    else if ([item isKindOfClass:[TGWebSearchResultsGalleryImageItem class]] || [item isKindOfClass:[TGWebSearchResultsGalleryInternalImageItem class]])
    {
        _item = item;
        
        id<TGWebSearchResult> searchResult = [(id)item webSearchResult];
        
        if ([searchResult conformsToProtocol:@protocol(TGEditablePhotoItem)])
        {
            id<TGEditablePhotoItem> editableMediaItem = (id<TGEditablePhotoItem>)searchResult;
            CGSize imageSize = TGFitSize(editableMediaItem.originalSize, CGSizeMake(1600, 1600));
            PGPhotoEditorValues *editorValues = nil;
            if (editableMediaItem.fetchEditorValues != nil)
                editorValues = editableMediaItem.fetchEditorValues(editableMediaItem);
            
            if (editorValues != nil)
            {
                imageSize = editorValues.cropRect.size;
                
                self.imageSize = imageSize;
                
                UIImage *image = editableMediaItem.fetchScreenImage(editableMediaItem);
                if (image != nil)
                    [self.imageView loadUri:@"embedded://" withOptions:@{ TGImageViewOptionEmbeddedImage:image }];
                else
                    [self.imageView reset];
                
                [self reset];
            }
            else
            {
                if (editableMediaItem.fetchOriginalImage != nil)
                {
                    self.imageSize = imageSize;
                    editableMediaItem.fetchOriginalImage(editableMediaItem, ^(UIImage *image)
                    {
                        if (item != self.item)
                            return;
                        
                        TGDispatchOnMainThread(^
                        {
                            if (image != nil)
                                [self.imageView loadUri:@"embedded://" withOptions:@{ TGImageViewOptionEmbeddedImage:image }];
                            else
                                [super setItem:item synchronously:synchronously];
                        });
                    });
                    [self reset];
                }
                else
                {
                    [super setItem:item synchronously:synchronously];
                }
            }
        }
        else
        {
            [super setItem:item synchronously:synchronously];
        }
    }
}

- (void)singleTap
{
    if ([self.item conformsToProtocol:@protocol(TGModernGallerySelectableItem)])
    {
        id<TGModernGallerySelectableItem> item = (id<TGModernGallerySelectableItem>)self.item;
        
        if (item.itemSelected != nil)
            item.itemSelected(item);
    }
    else
    {
        id<TGModernGalleryItemViewDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(itemViewDidRequestInterfaceShowHide:)])
            [delegate itemViewDidRequestInterfaceShowHide:self];
    }
}

@end
