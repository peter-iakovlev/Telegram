#import "TGModernGalleryModel.h"

@implementation TGModernGalleryModel

- (void)_replaceItems:(NSArray *)items focusingOnItem:(id<TGModernGalleryItem>)item
{
    TGDispatchOnMainThread(^
    {
        _items = items;
        
        if (_itemsUpdated)
            _itemsUpdated(item);
    });
}

- (void)_focusOnItem:(id<TGModernGalleryItem>)item
{
    TGDispatchOnMainThread(^
    {
        if (_focusOnItem)
            _focusOnItem(item);
    });
}

@end
