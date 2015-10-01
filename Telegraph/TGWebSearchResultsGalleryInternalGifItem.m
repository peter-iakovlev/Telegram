#import "TGWebSearchResultsGalleryInternalGifItem.h"

#import "TGWebSearchResultsGalleryInternalGifItemView.h"

@implementation TGWebSearchResultsGalleryInternalGifItem

@synthesize itemSelected = _itemSelected;

- (instancetype)initWithSearchResult:(TGWebSearchInternalGifResult *)searchResult
{
    self = [super init];
    if (self != nil)
    {
        _webSearchResult = searchResult;
    }
    return self;
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
