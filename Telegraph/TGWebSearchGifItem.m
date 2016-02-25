#import "TGWebSearchGifItem.h"

#import "TGWebSearchGifItemView.h"

#import "TGGiphySearchResultItem+TGMediaItem.h"

@implementation TGWebSearchGifItem

@synthesize selectionContext;

- (instancetype)initWithPreviewUrl:(NSString *)previewUrl searchResultItem:(TGGiphySearchResultItem *)searchResultItem
{
    self = [super init];
    if (self != nil)
    {
        _previewUrl = previewUrl;
        _webSearchResult = searchResultItem;
    }
    return self;
}

- (Class)viewClass
{
    return [TGWebSearchGifItemView class];
}

- (id<TGMediaSelectableItem>)selectableMediaItem
{
    return self.webSearchResult;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchGifItem class]] && TGObjectCompare(_webSearchResult, ((TGWebSearchGifItem *)object)->_webSearchResult);
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

@end
