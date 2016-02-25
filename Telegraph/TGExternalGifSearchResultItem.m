#import "TGExternalGifSearchResultItem.h"

#import "TGExternalGifSearchResultItemView.h"

#import "TGExternalGifSearchResult+TGMediaItem.h"

@implementation TGExternalGifSearchResultItem

@synthesize selectionContext;

- (instancetype)initWithSearchResult:(TGExternalGifSearchResult *)searchResult
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
    return [TGExternalGifSearchResultItemView class];
}

- (id<TGMediaSelectableItem>)selectableMediaItem
{
    return self.webSearchResult;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGExternalGifSearchResultItem class]] && TGObjectCompare(_webSearchResult, ((TGExternalGifSearchResultItem *)object)->_webSearchResult);
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

@end
