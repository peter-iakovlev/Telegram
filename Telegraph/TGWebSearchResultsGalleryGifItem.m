#import "TGWebSearchResultsGalleryGifItem.h"

#import "TGGiphySearchResultItem+TGMediaItem.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGWebSearchResultsGalleryGifItemView.h"

@implementation TGWebSearchResultsGalleryGifItem

@synthesize selectionContext;

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

- (NSString *)uniqueId
{
    return [[NSString alloc] initWithFormat:@"TGWebSearchResultsGalleryGifItem_%@", _webSearchResult.gifId];
}

@end
