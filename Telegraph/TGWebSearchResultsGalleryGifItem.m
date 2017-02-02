#import "TGWebSearchResultsGalleryGifItem.h"

#import "TGGiphySearchResultItem+TGMediaItem.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGWebSearchResultsGalleryGifItemView.h"

@implementation TGWebSearchResultsGalleryGifItem

@synthesize selectionContext;
@synthesize editingContext;

- (instancetype)initWithGiphySearchResultItem:(TGGiphySearchResultItem *)searchResultItem
{
    self = [super init];
    if (self != nil)
    {
        _webSearchResult = searchResultItem;
    }
    return self;
}

- (Class)viewClass
{
    return [TGWebSearchResultsGalleryGifItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchResultsGalleryGifItem class]] && TGObjectCompare(_webSearchResult, ((TGWebSearchResultsGalleryGifItem *)object)->_webSearchResult);
}

- (id<TGMediaSelectableItem>)selectableMediaItem
{
    return self.webSearchResult;
}

- (id<TGMediaEditableItem>)editableMediaItem
{
    return self.webSearchResult;
}

- (TGPhotoEditorTab)toolbarTabs
{
    return TGPhotoEditorNoneTab;
}

- (NSString *)uniqueId
{
    return [[NSString alloc] initWithFormat:@"TGWebSearchResultsGalleryGifItem_%@", _webSearchResult.gifId];
}

@end
