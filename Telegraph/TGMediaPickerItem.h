#import "TGModernMediaListItem.h"
#import "TGModernMediaListSelectableItem.h"
#import "TGModernMediaListEditableItem.h"
#import "TGMediaPickerAsset.h"

@interface TGMediaPickerItem : NSObject <TGModernMediaListItem, TGModernMediaListSelectableItem, TGModernMediaListEditableItem>

@property (nonatomic, readonly) TGMediaPickerAsset *asset;

- (instancetype)initWithAsset:(TGMediaPickerAsset *)asset itemSelected:(void (^)(id<TGModernMediaListItem>, bool))itemSelected isItemSelected:(bool (^)(id<TGModernMediaListItem>))isItemSelected isItemHidden:(bool (^)(id<TGModernMediaListItem>))isItemHidden;

@end
