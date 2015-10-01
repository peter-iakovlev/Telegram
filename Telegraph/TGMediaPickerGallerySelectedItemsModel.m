#import "TGMediaPickerGallerySelectedItemsModel.h"

#import "TGModernMediaListSelectableItem.h"

@interface TGMediaPickerGallerySelectedItemsModel ()
{
    NSMutableArray *_items;
}
@end

@implementation TGMediaPickerGallerySelectedItemsModel

- (instancetype)initWithSelectedItems:(NSArray *)selectedItems itemSelected:(void (^)(id<TGModernMediaListSelectableItem>))itemSelected isItemSelected:(bool (^)(id<TGModernMediaListSelectableItem>))isItemSelected
{
    self = [super init];
    if (self != nil)
    {
        self.itemSelected = itemSelected;
        self.isItemSelected = isItemSelected;
     
        [self setItems:selectedItems];
    }
    return self;
}

- (void)exchangeItemAtIndex:(NSUInteger)index1 withItemAtIndex:(NSUInteger)index2
{
    [_items exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    
    if (self.selectedItemsReordered != nil)
        self.selectedItemsReordered(self.selectedItems);
}

- (void)addSelectedItem:(id<TGModernMediaListSelectableItem>)selectedItem
{
    for (id<TGModernMediaListSelectableItem> item in _items)
    {
        if ([item isEqual:selectedItem])
        {
            if (self.selectionUpdated != nil)
                self.selectionUpdated(false, false, false, 0);
            
            return;
        }
    }
    
    id<TGModernMediaListSelectableItem> newItem = [(NSObject *)selectedItem copy];
    newItem.itemSelected = self.itemSelected;
    newItem.isItemSelected = self.isItemSelected;
    [_items addObject:newItem];
    
    if (self.selectionUpdated != nil)
        self.selectionUpdated(true, true, true, _items.count - 1);
}

- (void)removeSelectedItem:(id<TGModernMediaListSelectableItem>)selectedItem
{
    NSInteger index = [_items indexOfObject:selectedItem];
    if (index != NSNotFound)
    {
        [_items removeObject:selectedItem];
        
        if (self.selectionUpdated != nil)
            self.selectionUpdated(true, true, false, index);
    }
}

- (NSInteger)selectedCount
{
    NSInteger count = 0;
    for (id<TGModernMediaListSelectableItem> item in _items)
    {
        if (item.isItemSelected != nil && item.isItemSelected(item))
            count++;
    }
    return count;
}

- (NSInteger)totalCount
{
    return self.items.count;
}

- (NSArray *)items
{
    return _items;
}

- (void)setItems:(NSArray *)items
{
    _items = [[NSMutableArray alloc] init];
    
    for (id<TGModernMediaListSelectableItem> item in items)
    {
        id<TGModernMediaListSelectableItem> newItem = [(NSObject *)item copy];
        newItem.itemSelected = self.itemSelected;
        newItem.isItemSelected = self.isItemSelected;
        [_items addObject:newItem];
    }
    
    if (self.selectionUpdated != nil)
        self.selectionUpdated(true, false, false, 0);
}

- (NSArray *)selectedItems
{
    NSMutableArray *selectedItems = [[NSMutableArray alloc] init];
    for (id<TGModernMediaListSelectableItem> item in _items)
    {
        if (item.isItemSelected != nil && item.isItemSelected(item))
            [selectedItems addObject:item];
    }
    return selectedItems;
}

@end
