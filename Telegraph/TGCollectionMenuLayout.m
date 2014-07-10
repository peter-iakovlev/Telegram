#import "TGCollectionMenuLayout.h"

@interface TGCollectionMenuLayout ()
{
    NSMutableArray *_insertIndexPaths;
    NSMutableArray *_deleteIndexPaths;
    NSMutableArray *_reloadIndexPaths;
    NSMutableIndexSet *_reloadSectionIndices;
    
    bool _updatingLayout;
}

@end

@implementation TGCollectionMenuLayout

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    _deleteIndexPaths = [[NSMutableArray alloc] init];
    _insertIndexPaths = [[NSMutableArray alloc] init];
    _reloadIndexPaths = [[NSMutableArray alloc] init];
    _reloadSectionIndices = [[NSMutableIndexSet alloc] init];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        if (update.updateAction == UICollectionUpdateActionDelete)
            [_deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        else if (update.updateAction == UICollectionUpdateActionInsert)
            [_insertIndexPaths addObject:update.indexPathAfterUpdate];
        else if (update.updateAction == UICollectionUpdateActionReload)
            [_reloadIndexPaths addObject:update.indexPathAfterUpdate];
    }
    
    for (NSIndexPath *indexPath in _reloadIndexPaths)
    {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell != nil)
            [cell.superview sendSubviewToBack:cell];
    }
    
    _updatingLayout = true;
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];

    _deleteIndexPaths = nil;
    _insertIndexPaths = nil;
    _reloadIndexPaths = nil;
    
    _updatingLayout = false;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    if (!_updatingLayout || _withoutAnimation)
        return nil;
    
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([_insertIndexPaths containsObject:itemIndexPath] || [_reloadIndexPaths containsObject:itemIndexPath])
    {
        if (!attributes)
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        attributes = [attributes copy];
        attributes.alpha = 0.0f;
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    if (!_updatingLayout || _withoutAnimation)
        return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([_deleteIndexPaths containsObject:itemIndexPath])
    {
        attributes = [attributes copy];
        attributes.alpha = 0.0f;
    }
    else if ([_reloadIndexPaths containsObject:itemIndexPath])
    {
        attributes = [attributes copy];
        attributes.alpha = 1.0f;
    }
    
    return attributes;
}

@end
