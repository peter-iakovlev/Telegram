#import "TGModernMediaListModel.h"

@implementation TGModernMediaListModel

- (void)_replaceItems:(NSArray *)items totalCount:(NSUInteger)totalCount
{
    TGDispatchOnMainThread(^
    {
        _totalCount = totalCount;
        _items = items;
 
        if (_itemsUpdated)
            _itemsUpdated();
    });
}

- (void)_transitionCompleted
{
}

- (TGModernGalleryController *)createGalleryControllerForItem:(id<TGModernMediaListItem>)__unused item hideItem:(void (^)(id<TGModernMediaListItem>))__unused hideItem referenceViewForItem:(UIView *(^)(id<TGModernMediaListItem>))__unused referenceViewForItem
{
    return nil;
}

@end
