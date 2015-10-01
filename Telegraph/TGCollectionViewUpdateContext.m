#import "TGCollectionViewUpdateContext.h"

typedef enum {
    TGCollectionViewUpdateContextUpdateInsertSection = 0,
    TGCollectionViewUpdateContextUpdateDeleteSection = 1,
    TGCollectionViewUpdateContextUpdateInsertItem = 2,
    TGCollectionViewUpdateContextUpdateDeleteItem = 3,
    TGCollectionViewUpdateContextUpdateReplaceItem = 4
} TGCollectionViewUpdateContextUpdateType;

typedef struct
{
    TGCollectionViewUpdateContextUpdateType type;
    int section;
    int index;
} TGCollectionViewUpdateContextUpdate;

@interface TGCollectionViewUpdateContext ()
{
    NSMutableArray *_updates;
}

@end

@implementation TGCollectionViewUpdateContext

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _updates = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)insertSectionAtIndex:(NSUInteger)index
{
    TGCollectionViewUpdateContextUpdate update = {.type = TGCollectionViewUpdateContextUpdateInsertSection, .section = (int)index, .index = 0};
    [_updates addObject:[NSValue valueWithBytes:&update objCType:@encode(TGCollectionViewUpdateContextUpdate)]];
}

- (void)deleteSectionAtIndex:(NSUInteger)index
{
    TGCollectionViewUpdateContextUpdate update = {.type = TGCollectionViewUpdateContextUpdateDeleteSection, .section = (int)index, .index = 0};
    [_updates addObject:[NSValue valueWithBytes:&update objCType:@encode(TGCollectionViewUpdateContextUpdate)]];
}

- (void)insertItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    TGCollectionViewUpdateContextUpdate update = {.type = TGCollectionViewUpdateContextUpdateInsertItem, .section = (int)section, .index = (int)index};
    [_updates addObject:[NSValue valueWithBytes:&update objCType:@encode(TGCollectionViewUpdateContextUpdate)]];
}

- (void)deleteItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    TGCollectionViewUpdateContextUpdate update = {.type = TGCollectionViewUpdateContextUpdateDeleteItem, .section = (int)section, .index = (int)index};
    [_updates addObject:[NSValue valueWithBytes:&update objCType:@encode(TGCollectionViewUpdateContextUpdate)]];
}

- (void)replaceItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    TGCollectionViewUpdateContextUpdate update = {.type = TGCollectionViewUpdateContextUpdateReplaceItem, .section = (int)section, .index = (int)index};
    [_updates addObject:[NSValue valueWithBytes:&update objCType:@encode(TGCollectionViewUpdateContextUpdate)]];
}

- (void)commit:(UICollectionView *)collectionView
{
    for (NSValue *updateValue in _updates)
    {
        TGCollectionViewUpdateContextUpdate update;
        [updateValue getValue:&update];
        
        switch (update.type)
        {
            case TGCollectionViewUpdateContextUpdateInsertSection:
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:update.section]];
                break;
            case TGCollectionViewUpdateContextUpdateDeleteSection:
                [collectionView deleteSections:[NSIndexSet indexSetWithIndex:update.section]];
                break;
            case TGCollectionViewUpdateContextUpdateInsertItem:
                [collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:update.index inSection:update.section]]];
                break;
            case TGCollectionViewUpdateContextUpdateDeleteItem:
                [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:update.index inSection:update.section]]];
                break;
            case TGCollectionViewUpdateContextUpdateReplaceItem:
                [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:update.index inSection:update.section]]];
                break;
            default:
                break;
        }
    }
}

@end
