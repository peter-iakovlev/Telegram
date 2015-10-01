#import "TGWebSearchResultsGalleryGifItem.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGWebSearchResultsGalleryGifItemView.h"

@implementation TGWebSearchResultsGalleryGifItem

@synthesize itemSelected = _itemSelected;

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

- (NSString *)uniqueId
{
    return [[NSString alloc] initWithFormat:@"TGWebSearchResultsGalleryGifItem_%@", _webSearchResult.gifId];
}

@end
