#import "TGChatActionsContainerView.h"

#import "TGChatActionItem.h"
#import "TGChatActionItemView.h"

@interface TGChatActionsContainerView ()
{
    NSArray *_items;
    TGChatActionItem *_expandedItem;
    
    UILongPressGestureRecognizer *_pressGestureRecognizer;
}
@end

@implementation TGChatActionsContainerView

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super init];
    if (self != nil)
    {
        _items = items;
    }
    return self;
}

- (NSArray *)displayedItems
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for (TGChatActionItem *item in _items)
    {
        if (_expandedItem == nil)
        {
            [items addObject:item];
        }
        else
        {
            if (item == _expandedItem)
            {
                [items addObject:item];
                [items addObjectsFromArray:item.subitems];
                break;
            }
        }
    }
    
    return items;
}

- (CGFloat)preferredHeight
{
    return 0;
}

- (void)layoutSubviews
{
    
}

@end
