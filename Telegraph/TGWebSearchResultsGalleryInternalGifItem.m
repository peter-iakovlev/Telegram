#import "TGWebSearchResultsGalleryInternalGifItem.h"
#import "TGWebSearchInternalGifResult+TGMediaItem.h"
#import "TGWebSearchResultsGalleryInternalGifItemView.h"

@implementation TGWebSearchResultsGalleryInternalGifItem

@synthesize selectionContext;
@synthesize editingContext;

- (instancetype)initWithSearchResult:(TGWebSearchInternalGifResult *)searchResult
{
    self = [super init];
    if (self != nil)
    {
        _webSearchResult = searchResult;
    }
    return self;
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
    return [[NSString alloc] initWithFormat:@"TGWebSearchResultsGalleryInternalGifItem_%lld", (long long)_webSearchResult.documentId];
}

- (Class)viewClass
{
    return [TGWebSearchResultsGalleryInternalGifItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchResultsGalleryInternalGifItem class]] && TGObjectCompare(_webSearchResult, ((TGWebSearchResultsGalleryInternalGifItem *)object)->_webSearchResult);
}

@end
