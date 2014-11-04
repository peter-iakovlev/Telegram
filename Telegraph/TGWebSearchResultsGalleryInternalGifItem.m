#import "TGWebSearchResultsGalleryInternalGifItem.h"

#import "TGWebSearchResultsGalleryInternalGifItemView.h"

@implementation TGWebSearchResultsGalleryInternalGifItem

- (instancetype)initWithSearchResult:(TGWebSearchInternalGifResult *)searchResult
{
    self = [super init];
    if (self != nil)
    {
        _webSearchResult = searchResult;
    }
    return self;
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
