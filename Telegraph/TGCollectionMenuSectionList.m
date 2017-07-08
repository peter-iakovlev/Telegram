#import "TGCollectionMenuSectionList.h"

#import "TGCollectionViewUpdateContext.h"

#import "TGCollectionItemView.h"

@interface TGCollectionMenuSection ()

- (void)insertItem:(TGCollectionItem *)item atIndex:(NSUInteger)index;
- (void)deleteItemAtIndex:(NSUInteger)index;
- (void)replaceItemAtIndex:(NSUInteger)index withItem:(TGCollectionItem *)item;

@end

@interface TGCollectionMenuSectionList ()
{
    bool _recordingChanges;
    TGCollectionViewUpdateContext *_updateContext;
    
    NSMutableArray *_sections;
}

@end

@implementation TGCollectionMenuSectionList

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _sections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)sections
{
    return _sections;
}

- (void)addSection:(TGCollectionMenuSection *)section
{
    [self insertSection:section atIndex:_sections.count];
}

- (void)insertSection:(TGCollectionMenuSection *)section atIndex:(NSUInteger)index
{
    if (section != nil)
    {
        [_sections insertObject:section atIndex:index];
        
        if (_recordingChanges)
            [_updateContext insertSectionAtIndex:index];
    }
}

- (void)deleteSection:(NSUInteger)section
{
    if (_recordingChanges)
        [_updateContext deleteSectionAtIndex:section];
    
    [_sections removeObjectAtIndex:section];
}

- (void)deleteSectionByReference:(TGCollectionMenuSection *)section {
    [_sections removeObject:section];
}

- (void)addItemToSection:(NSUInteger)section item:(TGCollectionItem *)item
{
    TGCollectionMenuSection *menuSection = _sections[section];
    
    if (_recordingChanges)
        [_updateContext insertItemAtIndex:menuSection.items.count inSection:section];
    
    [menuSection insertItem:item atIndex:menuSection.items.count];
}

- (void)insertItem:(TGCollectionItem *)item toSection:(NSUInteger)section atIndex:(NSUInteger)index
{
    TGCollectionMenuSection *menuSection = _sections[section];
    
    if (_recordingChanges)
        [_updateContext insertItemAtIndex:index inSection:section];
    
    [menuSection insertItem:item atIndex:index];
}

- (void)deleteItemFromSection:(NSUInteger)section atIndex:(NSUInteger)index
{
    TGCollectionMenuSection *menuSection = _sections[section];
    
    if (_recordingChanges)
        [_updateContext deleteItemAtIndex:index inSection:section];
    
    [menuSection deleteItemAtIndex:index];
}

- (void)replaceItemInSection:(NSUInteger)section atIndex:(NSUInteger)index withItem:(TGCollectionItem *)item
{
    TGCollectionMenuSection *menuSection = _sections[section];
    
    if (_recordingChanges)
        [_updateContext replaceItemAtIndex:index inSection:section];
    
    [menuSection replaceItemAtIndex:index withItem:item];
}

- (void)beginRecordingChanges
{
    if (!_recordingChanges)
    {
        _recordingChanges = true;
        _updateContext = [[TGCollectionViewUpdateContext alloc] init];
    }
}

- (bool)commitRecordedChanges:(UICollectionView *)collectionView
{
    return [self commitRecordedChanges:collectionView additionalActions:nil];
}

- (bool)commitRecordedChanges:(UICollectionView *)collectionView additionalActions:(void (^)())additionalActions
{
    if (_recordingChanges)
    {
        _recordingChanges = false;
        
        TGCollectionViewUpdateContext *updateContext = _updateContext;
        _updateContext = nil;
        
        @try
        {
            [collectionView performBatchUpdates:^
            {
                [updateContext commit:collectionView];
                
                if (additionalActions != nil)
                    additionalActions();
            } completion:nil];
            
            for (NSIndexPath *indexPath in [collectionView indexPathsForVisibleItems])
            {
                id itemView = [collectionView cellForItemAtIndexPath:indexPath];
                
                if ([itemView isKindOfClass:[TGCollectionItemView class]])
                {
                    TGCollectionItem *item = ((TGCollectionMenuSection *)_sections[indexPath.section]).items[indexPath.item];
                    
                    TGCollectionItem *previousItem = nil;
                    if (indexPath.item > 0)
                        previousItem = ((TGCollectionMenuSection *)_sections[indexPath.section]).items[indexPath.item - 1];
                    
                    TGCollectionItem *nextItem = nil;
                    if (indexPath.item < (NSInteger)((TGCollectionMenuSection *)_sections[indexPath.section]).items.count - 1)
                        nextItem = ((TGCollectionMenuSection *)_sections[indexPath.section]).items[indexPath.item + 1];
                    
                    int itemPositionMask = 0;
                    if (!item.transparent)
                    {
                        if (previousItem == nil || previousItem.transparent)
                            itemPositionMask |= TGCollectionItemViewPositionFirstInBlock;
                        
                        if (nextItem == nil || nextItem.transparent)
                            itemPositionMask |= TGCollectionItemViewPositionLastInBlock;
                        
                        if (itemPositionMask == 0)
                            itemPositionMask = TGCollectionItemViewPositionMiddleInBlock;
                    }
                    
                    [itemView setItemPosition:itemPositionMask];
                }
            }
        }
        @catch (NSException *e)
        {
            TGLog(@"%@", e);
            
            return false;
        }
    }
    
    return true;
}

@end
