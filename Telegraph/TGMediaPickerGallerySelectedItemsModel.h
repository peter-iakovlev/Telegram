#import <Foundation/Foundation.h>
#import "TGModernMediaListItem.h"
#import "TGModernMediaListSelectableItem.h"

@interface TGMediaPickerGallerySelectedItemsModel : NSObject

@property (nonatomic, copy) void (^itemSelected)(id<TGModernMediaListSelectableItem> item);
@property (nonatomic, copy) bool (^isItemSelected)(id<TGModernMediaListSelectableItem> item);
@property (nonatomic, copy) void (^selectionUpdated)(bool reload, bool incremental, bool add, NSInteger index);
@property (nonatomic, copy) void (^selectedItemsReordered)(NSArray *reorderedSelectedItems);

@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSArray *selectedItems;

@property (nonatomic, readonly) NSInteger totalCount;
@property (nonatomic, readonly) NSInteger selectedCount;

- (instancetype)initWithSelectedItems:(NSArray *)selectedItems itemSelected:(void (^)(id<TGModernMediaListSelectableItem>))itemSelected isItemSelected:(bool (^)(id<TGModernMediaListSelectableItem>))isItemSelected;

- (void)addSelectedItem:(id<TGModernMediaListSelectableItem>)item;
- (void)removeSelectedItem:(id<TGModernMediaListSelectableItem>)item;

- (void)setItems:(NSArray *)items;

- (void)exchangeItemAtIndex:(NSUInteger)index1 withItemAtIndex:(NSUInteger)index2;

@end
