#import "TGExternalGifSearchResultGalleryItem.h"

#import "TGExternalGifSearchResult+TGMediaItem.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGExternalGifSearchResultGalleryItemView.h"

@implementation TGExternalGifSearchResultGalleryItem

@synthesize selectionContext;
@synthesize editingContext;

- (instancetype)initWithSearchResultItem:(TGExternalGifSearchResult *)searchResultItem
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
    return [TGExternalGifSearchResultGalleryItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGExternalGifSearchResultGalleryItem class]] && TGObjectCompare(_webSearchResult, ((TGExternalGifSearchResultGalleryItem *)object)->_webSearchResult);
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
    return [[NSString alloc] initWithFormat:@"TGExternalGifSearchResultGalleryItem_%@", _webSearchResult.url];
}

@end
