#import "TGInternalGifSearchResultGalleryItem.h"

#import "TGInternalGifSearchResult+TGMediaItem.h"

#import "TGInternalGifSearchResultGalleryItemView.h"

@implementation TGInternalGifSearchResultGalleryItem

@synthesize selectionContext;
@synthesize editingContext;

- (instancetype)initWithSearchResult:(TGInternalGifSearchResult *)searchResult
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
    return [[NSString alloc] initWithFormat:@"TGInternalGifSearchResultGalleryItem_%lld", (long long)_webSearchResult.document.documentId];
}

- (Class)viewClass
{
    return [TGInternalGifSearchResultGalleryItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGInternalGifSearchResultGalleryItem class]] && TGObjectCompare(_webSearchResult, ((TGInternalGifSearchResultGalleryItem *)object)->_webSearchResult);
}

@end
