#import "TGModernMediaListItem.h"
#import "TGWebSearchListItem.h"

#import "TGModernMediaListEditableItem.h"

#import "TGBingSearchResultItem.h"

@interface TGWebSearchImageItem : NSObject <TGModernMediaListItem, TGWebSearchListItem, TGModernMediaListEditableItem>

@property (nonatomic, strong, readonly) NSString *previewUrl;
@property (nonatomic, strong, readonly) TGBingSearchResultItem *webSearchResult;

@property (nonatomic, copy, readonly) bool (^isEditing)();
@property (nonatomic, copy) void (^toggleEditing)();
@property (nonatomic, copy) void (^itemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy) bool (^isItemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy) bool (^isItemHidden)(id<TGWebSearchListItem>);

- (instancetype)initWithPreviewUrl:(NSString *)previewUrl searchResultItem:(TGBingSearchResultItem *)searchResultItem isEditing:(bool (^)())isEditing toggleEditing:(void (^)())toggleEditing itemSelected:(void (^)(id<TGWebSearchListItem>))itemSelected isItemSelected:(bool (^)(id<TGWebSearchListItem>))isItemSelected isItemHidden:(bool (^)(id<TGWebSearchListItem>))isItemHidden;

@end
