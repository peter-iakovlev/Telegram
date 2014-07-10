#import "TGCollectionMenuSection.h"

#import "TGCollectionViewUpdateContext.h"

@interface TGCollectionMenuSection ()
{
    NSMutableArray *_items;
}

@end

@implementation TGCollectionMenuSection

- (instancetype)init
{
    return [self initWithItems:nil];
}

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super init];
    if (self != nil)
    {
        _insets = UIEdgeInsetsMake(0.0f, 0.0f, 35.0f, 0.0f);
        
        _items = [[NSMutableArray alloc] init];
        if (items != nil)
            [_items addObjectsFromArray:items];
    }
    return self;
}

- (NSArray *)items
{
    return _items;
}

- (void)insertItem:(TGCollectionItem *)item atIndex:(NSUInteger)index
{
    [_items insertObject:item atIndex:index];
}

- (void)deleteItemAtIndex:(NSUInteger)index
{
    [_items removeObjectAtIndex:index];
}

- (void)replaceItemAtIndex:(NSUInteger)index withItem:(TGCollectionItem *)item
{
    [_items replaceObjectAtIndex:index withObject:item];
}

@end
