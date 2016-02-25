#import "TGWebSearchInternalGifItem.h"

#import "TGWebSearchInternalGifItemView.h"

#import "TGWebSearchInternalGifResult+TGMediaItem.h"

@implementation TGWebSearchInternalGifItem

@synthesize selectionContext;

- (instancetype)initWithSearchResult:(TGWebSearchInternalGifResult *)searchResult
{
    self = [super init];
    if (self != nil)
    {
        _webSearchResult = searchResult;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

- (id<TGMediaSelectableItem>)selectableMediaItem
{
    return self.webSearchResult;
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
