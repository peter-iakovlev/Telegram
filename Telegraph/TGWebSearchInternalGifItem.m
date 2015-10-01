#import "TGWebSearchInternalGifItem.h"

#import "TGWebSearchInternalGifItemView.h"

@implementation TGWebSearchInternalGifItem

- (instancetype)initWithSearchResult:(TGWebSearchInternalGifResult *)searchResult isEditing:(bool (^)())isEditing toggleEditing:(void (^)())toggleEditing itemSelected:(void (^)(id<TGWebSearchListItem>))itemSelected isItemSelected:(bool (^)(id<TGWebSearchListItem>))isItemSelected isItemHidden:(bool (^)(id<TGWebSearchListItem>))isItemHidden
{
    self = [super init];
    if (self != nil)
    {
        _webSearchResult = searchResult;
        
        _isEditing = [isEditing copy];
        _toggleEditing = [toggleEditing copy];
        _itemSelected = [itemSelected copy];
        _isItemSelected = [isItemSelected copy];
        _isItemHidden = [isItemHidden copy];
    }
    return self;
}

- (NSString *)uniqueId
{
    return [[NSString alloc] initWithFormat:@"TGWebSearchInternalGifItem_%lld", (long long)_webSearchResult.documentId];
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

- (Class)viewClass
{
    return [TGWebSearchInternalGifItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchInternalGifItem class]] && TGObjectCompare(_webSearchResult, ((TGWebSearchInternalGifItem *)object)->_webSearchResult);
}

@end
