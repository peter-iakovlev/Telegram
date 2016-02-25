#import "TGWebSearchImageItem.h"

#import "TGBingSearchResultItem+TGMediaItem.h"

#import "TGWebSearchImageItemView.h"

@implementation TGWebSearchImageItem

@synthesize selectionContext;
@synthesize editingContext;

- (instancetype)initWithPreviewUrl:(NSString *)previewUrl searchResultItem:(TGBingSearchResultItem *)searchResultItem
{
    self = [super init];
    if (self != nil)
    {
        _previewUrl = previewUrl;
        _webSearchResult = searchResultItem;
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

- (id<TGMediaEditableItem>)editableMediaItem
{
    return self.webSearchResult;
}

- (Class)viewClass
{
    return [TGWebSearchImageItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGWebSearchImageItem class]] && TGObjectCompare(_webSearchResult, ((TGWebSearchImageItem *)object)->_webSearchResult);
}

@end
