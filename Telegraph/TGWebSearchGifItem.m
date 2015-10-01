#import "TGWebSearchGifItem.h"

#import "TGWebSearchGifItemView.h"

@implementation TGWebSearchGifItem

- (instancetype)initWithPreviewUrl:(NSString *)previewUrl searchResultItem:(TGGiphySearchResultItem *)searchResultItem itemSelected:(void (^)(id<TGWebSearchListItem>))itemSelected isItemSelected:(bool (^)(id<TGWebSearchListItem>))isItemSelected isItemHidden:(bool (^)(id<TGWebSearchListItem>))isItemHidden
{
    self = [super init];
    if (self != nil)
    {
        _previewUrl = previewUrl;
        _webSearchResult = searchResultItem;
        _itemSelected = [itemSelected copy];
        _isItemSelected = [isItemSelected copy];
        _isItemHidden = [isItemHidden copy];
    }
    return self;
}

- (Class)viewClass
{
    return [TGWebSearchGifItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchGifItem class]] && TGObjectCompare(_webSearchResult, ((TGWebSearchGifItem *)object)->_webSearchResult);
}

- (NSString *)uniqueId
{
    return [[NSString alloc] initWithFormat:@"TGWebSearchGifItem_%@", _webSearchResult.gifId];
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

@end
