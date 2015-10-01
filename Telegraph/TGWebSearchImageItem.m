#import "TGWebSearchImageItem.h"

#import "TGBingSearchResultItem+TGEditablePhotoItem.h"

#import "TGWebSearchImageItemView.h"

@implementation TGWebSearchImageItem

- (instancetype)initWithPreviewUrl:(NSString *)previewUrl searchResultItem:(TGBingSearchResultItem *)searchResultItem isEditing:(bool (^)())isEditing toggleEditing:(void (^)())toggleEditing itemSelected:(void (^)(id<TGWebSearchListItem>))itemSelected isItemSelected:(bool (^)(id<TGWebSearchListItem>))isItemSelected isItemHidden:(bool (^)(id<TGWebSearchListItem>))isItemHidden
{
    self = [super init];
    if (self != nil)
    {
        _previewUrl = previewUrl;
        _webSearchResult = searchResultItem;
        
        _isEditing = [isEditing copy];
        _toggleEditing = [toggleEditing copy];
        _itemSelected = [itemSelected copy];
        _isItemSelected = [isItemSelected copy];
        _isItemHidden = [isItemHidden copy];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

- (id<TGEditablePhotoItem>)editableMediaItem
{
    return self.webSearchResult;
}

- (NSString *)uniqueId
{
    return [self.webSearchResult uniqueId];
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
