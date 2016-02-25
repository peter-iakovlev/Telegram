#import "TGMediaAssetsUtils.h"
#import "UICollectionView+Utils.h"

#import "TGMediaSelectionContext.h"

@interface TGMediaAssetsPreheatMixin ()
{
    UICollectionView *_collectionView;
    UICollectionViewScrollDirection _scrollDirection;
    
    CGRect _previousPreheatRect;
}
@end

@implementation TGMediaAssetsPreheatMixin

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView scrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    self = [super init];
    if (self != nil)
    {
        _collectionView = collectionView;
        _scrollDirection = scrollDirection;
    }
    return self;
}

- (void)update
{
    CGRect preheatRect = _collectionView.bounds;
    CGFloat delta = 0.0f;
    CGFloat threshold = 0.0f;
    switch (_scrollDirection)
    {
        case UICollectionViewScrollDirectionHorizontal:
            preheatRect = CGRectInset(preheatRect, -0.5f * preheatRect.size.width, 0.0f);
            delta = fabs(CGRectGetMidX(preheatRect) - CGRectGetMidX(_previousPreheatRect));
            threshold = _collectionView.bounds.size.width / 3.0f;
            break;
            
        case UICollectionViewScrollDirectionVertical:
            preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * preheatRect.size.height);
            delta = fabs(CGRectGetMidY(preheatRect) - CGRectGetMidY(_previousPreheatRect));
            threshold = _collectionView.bounds.size.height / 3.0f;
            break;
    }
    
    if (delta > threshold)
    {
        NSMutableArray *addedIndexPaths = [[NSMutableArray alloc] init];
        NSMutableArray *removedIndexPaths = [[NSMutableArray alloc] init];
        
        __weak TGMediaAssetsPreheatMixin *weakSelf = self;
        [_collectionView computeDifferenceBetweenRect:_previousPreheatRect andRect:preheatRect direction:_scrollDirection removedHandler:^(CGRect removedRect)
        {
            __strong TGMediaAssetsPreheatMixin *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            NSArray *indexPaths = [strongSelf->_collectionView indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect)
        {
            __strong TGMediaAssetsPreheatMixin *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            NSArray *indexPaths = [strongSelf->_collectionView indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToCache = [self _assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToInvalidate = [self _assetsAtIndexPaths:removedIndexPaths];
        
        CGSize imageSize = self.imageSize;
        [TGMediaAssetImageSignals startCachingImagesForAssets:assetsToCache imageType:self.imageType size:imageSize];
        [TGMediaAssetImageSignals stopCachingImagesForAssets:assetsToInvalidate imageType:self.imageType size:imageSize];
        
        _previousPreheatRect = preheatRect;
    }
}

- (void)stop
{
    [TGMediaAssetImageSignals stopCachingImagesForAllAssets];
    _previousPreheatRect = CGRectZero;
}

- (NSArray *)_assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0)
        return nil;
    
    NSInteger assetCount = self.assetCount();
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths)
    {
        NSInteger index = indexPath.row;
        
        if (index < assetCount)
            [assets addObject:self.assetAtIndex(index)];
    }
    
    return assets;
}

@end


@implementation TGMediaAssetsCollectionViewIncrementalUpdater

+ (void)updateCollectionView:(UICollectionView *)collectionView withChange:(TGMediaAssetFetchResultChange *)change completion:(void (^)(bool incremental))completion
{
    [collectionView reloadData];
    if (completion != nil)
        completion(false);
    
    return;
    
    if (!change.hasIncrementalChanges)
    {
        [collectionView reloadData];
        if (completion != nil)
            completion(false);
        return;
    }
    
    NSMutableArray *removedIndexPaths = [[NSMutableArray alloc] init];
    [change.removedIndexes enumerateIndexesUsingBlock:^(NSUInteger index, __unused BOOL *stop)
    {
        [removedIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }];
    
    NSMutableArray *insertedIndexPaths = [[NSMutableArray alloc] init];
    [change.insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger index, __unused BOOL *stop)
    {
        [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }];
    
    NSMutableArray *updatedIndexPaths = [[NSMutableArray alloc] init];
    [change.updatedIndexes enumerateIndexesUsingBlock:^(NSUInteger index, __unused BOOL *stop)
    {
        [updatedIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }];
    
    [collectionView performBatchUpdates:^
    {
        [collectionView deleteItemsAtIndexPaths:removedIndexPaths];
        [collectionView insertItemsAtIndexPaths:insertedIndexPaths];
    } completion:^(__unused BOOL finished)
    {
        if (updatedIndexPaths.count > 0 || change.hasMoves)
        {
            [collectionView performBatchUpdates:^
            {
                [collectionView reloadItemsAtIndexPaths:updatedIndexPaths];
                
                [change enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex)
                {
                    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:fromIndex inSection:0];
                    NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:toIndex inSection:0];
                    
                    [collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                }];
            } completion:^(__unused BOOL finished)
            {
                if (completion != nil)
                    completion(true);
            }];
        }
        else if (completion != nil)
        {
            completion(true);
        }
    }];
}

@end
