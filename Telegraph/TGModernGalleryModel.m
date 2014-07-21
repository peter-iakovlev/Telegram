#import "TGModernGalleryModel.h"

@implementation TGModernGalleryModel

- (void)_replaceItems:(NSArray *)items focusingOnItem:(id<TGModernGalleryItem>)item
{
    TGDispatchOnMainThread(^
    {
        _items = items;
        _focusItem = item;
        
        if (_itemsUpdated)
            _itemsUpdated(item);
    });
}

- (void)_focusOnItem:(id<TGModernGalleryItem>)item
{
    TGDispatchOnMainThread(^
    {
        _focusItem = item;
        
        if (_focusOnItem)
            _focusOnItem(item);
    });
}

- (Class<TGModernGalleryDefaultFooterView>)defaultFooterViewClass
{
    return nil;
}

@end
