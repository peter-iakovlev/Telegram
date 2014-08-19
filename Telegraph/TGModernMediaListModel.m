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

@end
