#import "TGModernMediaListImageItem.h"
#import "TGWebSearchListItem.h"

#import "TGModernMediaListEditableItem.h"

#import "TGWebSearchInternalImageResult.h"

@interface TGWebSearchInternalImageItem : TGModernMediaListImageItem <TGWebSearchListItem, TGModernMediaListEditableItem>

@property (nonatomic, strong, readonly) TGWebSearchInternalImageResult *webSearchResult;

@property (nonatomic, copy, readonly) bool (^isEditing)();
@property (nonatomic, copy) void (^toggleEditing)();
@property (nonatomic, copy) void (^itemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy) bool (^isItemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy) bool (^isItemHidden)(id<TGWebSearchListItem>);

- (instancetype)initWithSearchResult:(TGWebSearchInternalImageResult *)searchResult isEditing:(bool (^)())isEditing toggleEditing:(void (^)())toggleEditing itemSelected:(void (^)(id<TGWebSearchListItem>))itemSelected isItemSelected:(bool (^)(id<TGWebSearchListItem>))isItemSelected isItemHidden:(bool (^)(id<TGWebSearchListItem>))isItemHidden;

@end
