#import "TGInternalGifSearchResultItem.h"

#import "TGInternalGifSearchResultItemView.h"

#import "TGInternalGifSearchResult+TGMediaItem.h"

@implementation TGInternalGifSearchResultItem

@synthesize selectionContext;

- (instancetype)initWithSearchResult:(TGInternalGifSearchResult *)searchResult
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
    return [TGInternalGifSearchResultItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGInternalGifSearchResultItem class]] && TGObjectCompare(_webSearchResult, ((TGInternalGifSearchResultItem *)object)->_webSearchResult);
}

@end
