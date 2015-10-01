#import "TGPhotoEditorCollectionView.h"

#import "PGPhotoFilter.h"

#import "TGPhotoFilterCell.h"
#import "TGPhotoToolCell.h"

const CGPoint TGPhotoEditorEdgeScrollTriggerOffset = { 100, 150 };

@interface TGPhotoEditorCollectionView () <UICollectionViewDelegateFlowLayout>
{
    NSIndexPath *_selectedItemIndexPath;
    UICollectionViewFlowLayout *_layout;
}

@property (nonatomic, weak) id<UICollectionViewDelegate> realDelegate;

@end

@implementation TGPhotoEditorCollectionView

- (instancetype)initWithOrientation:(UIInterfaceOrientation)orientation cellWidth:(CGFloat)cellWidth
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(cellWidth, 80);
    if (UIInterfaceOrientationIsLandscape(orientation))
        layout.minimumLineSpacing = 12;
    else
        layout.minimumLineSpacing = 3;

    layout.scrollDirection = UIInterfaceOrientationIsLandscape(orientation) ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
    
    self = [super initWithFrame:CGRectZero collectionViewLayout:layout];
    if (self != nil)
    {
        _layout = layout;
        self.dataSource = self;
        self.delegate = self;
        self.showsHorizontalScrollIndicator = false;
        self.showsVerticalScrollIndicator = false;
        
        [self registerClass:[TGPhotoFilterCell class] forCellWithReuseIdentifier:TGPhotoFilterCellKind];
        [self registerClass:[TGPhotoToolCell class] forCellWithReuseIdentifier:TGPhotoToolCellKind];
    }
    return self;
}

- (void)dealloc
{
    self.dataSource = nil;
    self.delegate = nil;
}

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate
{
    if(delegate == nil)
    {
        [super setDelegate:nil];
        self.realDelegate = nil;
    }
    else
    {
        [super setDelegate:self];
        if (delegate != self)
            self.realDelegate = delegate;
    }
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    [(UICollectionViewFlowLayout *)self.collectionViewLayout setMinimumLineSpacing:minimumLineSpacing];
    [self.collectionViewLayout invalidateLayout];
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing
{
    [(UICollectionViewFlowLayout *)self.collectionViewLayout setMinimumInteritemSpacing:minimumInteritemSpacing];
    [self.collectionViewLayout invalidateLayout];
}

- (void)setSelectedItemIndexPath:(NSIndexPath *)indexPath
{
    NSArray *visibleItemsIndexPathes = self.indexPathsForVisibleItems;
    for (NSIndexPath *i in visibleItemsIndexPathes)
    {
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:i];
        if ([cell isKindOfClass:[TGPhotoFilterCell class]])
            [(TGPhotoFilterCell *)cell setFilterSelected:[i isEqual:indexPath]];
    }
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition
{
    _selectedItemIndexPath = indexPath;
    [super selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    
    [self setSelectedItemIndexPath:indexPath];
}

- (void)reloadData
{
    [super reloadData];
    
    if (_selectedItemIndexPath != nil)
        [self selectItemAtIndexPath:_selectedItemIndexPath animated:false scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - Collection View Data Source & Delegate

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    id <TGPhotoEditorCollectionViewFiltersDataSource> filtersDataSource = self.filtersDataSource;
    id <TGPhotoEditorCollectionViewToolsDataSource> toolsDataSource = self.toolsDataSource;
    
    if ([filtersDataSource respondsToSelector:@selector(numberOfFiltersInCollectionView:)])
        return [filtersDataSource numberOfFiltersInCollectionView:self];
    else if ([toolsDataSource respondsToSelector:@selector(numberOfToolsInCollectionView:)])
        return [toolsDataSource numberOfToolsInCollectionView:self];
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)__unused collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<TGPhotoEditorCollectionViewFiltersDataSource> filtersDataSource = self.filtersDataSource;
    id<TGPhotoEditorCollectionViewToolsDataSource> toolsDataSource = self.toolsDataSource;
    
    UICollectionViewCell *cell = nil;
    
    if ([filtersDataSource respondsToSelector:@selector(collectionView:filterAtIndex:)])
    {
        PGPhotoFilter *filter = [filtersDataSource collectionView:self filterAtIndex:indexPath.row];
        
        cell = [self dequeueReusableCellWithReuseIdentifier:TGPhotoFilterCellKind forIndexPath:indexPath];
        [(TGPhotoFilterCell *)cell setPhotoFilter:filter];
        [(TGPhotoFilterCell *)cell setFilterSelected:[_selectedItemIndexPath isEqual:indexPath]];
        
        [filtersDataSource collectionView:self requestThumbnailImageForFilterAtIndex:indexPath.row completion:^(UIImage *thumbnailImage, bool cached, __unused bool finished)
        {
            TGDispatchOnMainThread(^
            {
                if ([[(TGPhotoFilterCell *)cell filterIdentifier] isEqualToString:filter.identifier])
                    [(TGPhotoFilterCell *)cell setImage:thumbnailImage animated:!cached];
            });
        }];
    }
    else if ([toolsDataSource respondsToSelector:@selector(collectionView:toolAtIndex:)])
    {
        cell = [self dequeueReusableCellWithReuseIdentifier:TGPhotoToolCellKind forIndexPath:indexPath];
        [(TGPhotoToolCell *)cell setPhotoTool:[toolsDataSource collectionView:self toolAtIndex:indexPath.row]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<TGPhotoEditorCollectionViewFiltersDataSource> filtersDataSource = self.filtersDataSource;
    id<TGPhotoEditorCollectionViewToolsDataSource> toolsDataSource = self.toolsDataSource;
    
    if ([filtersDataSource respondsToSelector:@selector(collectionView:didSelectFilterWithIndex:)])
    {
        bool vertical = false;
        if (self.frame.size.height > self.frame.size.width)
            vertical = true;
    
        CGFloat screenSize = 0;
        CGFloat contentSize = 0;
        CGFloat contentOffset = 0;
        CGFloat itemPosition = 0;
        CGFloat itemSize = 0;
        CGFloat targetOverlap = 0;
        CGFloat startInset = 0;
        CGFloat endInset = 0;
        
        CGFloat triggerOffset = 0;
        
        if (!vertical)
        {
            screenSize = self.frame.size.width;
            contentSize = self.contentSize.width;
            contentOffset = self.contentOffset.x;
            itemPosition = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame.origin.x;
            itemSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize.width;
            startInset = self.contentInset.left;
            endInset = self.contentInset.right;
            triggerOffset = TGPhotoEditorEdgeScrollTriggerOffset.x;
            targetOverlap = itemSize / 2 + ((UICollectionViewFlowLayout *)self.collectionViewLayout).minimumLineSpacing;
        }
        else
        {
            screenSize = self.frame.size.height;
            contentSize = self.contentSize.height;
            contentOffset = self.contentOffset.y;
            itemPosition = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame.origin.y;
            itemSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize.height;
            startInset = self.contentInset.top;
            endInset = self.contentInset.bottom;
            triggerOffset = TGPhotoEditorEdgeScrollTriggerOffset.y;
            targetOverlap = itemSize + 2 * ((UICollectionViewFlowLayout *)self.collectionViewLayout).minimumLineSpacing;
        }
        
        CGFloat itemsScreenPosition = itemPosition - contentOffset;
        
        if (itemsScreenPosition < triggerOffset)
        {
            CGFloat targetContentOffset = MAX(-startInset, itemPosition - targetOverlap);
            
            if (!vertical && targetContentOffset < startInset + itemSize)
                targetContentOffset = -startInset;
            
            if (contentOffset > targetContentOffset)
            {
                if (!vertical)
                    [self setContentOffset:CGPointMake(targetContentOffset, -self.contentInset.top) animated:YES];
                else
                    [self setContentOffset:CGPointMake(-self.contentInset.left, targetContentOffset) animated:YES];
                
                self.scrollEnabled = NO;
            }
        }
        else if (itemsScreenPosition > screenSize - triggerOffset)
        {
            CGFloat targetContentOffset = MIN(contentSize - screenSize + endInset,
                                              itemPosition - screenSize + itemSize + targetOverlap);
            
            if (!vertical && targetContentOffset > contentSize - screenSize - endInset - itemSize)
                targetContentOffset = contentSize - screenSize + endInset;
            
            if (contentOffset < targetContentOffset)
            {
                if (!vertical)
                    [self setContentOffset:CGPointMake(targetContentOffset, -self.contentInset.top) animated:YES];
                else
                    [self setContentOffset:CGPointMake(-self.contentInset.left, targetContentOffset) animated:YES];
                
                self.scrollEnabled = NO;
            }
        }
        
        [filtersDataSource collectionView:self didSelectFilterWithIndex:indexPath.row];
        
        _selectedItemIndexPath = indexPath;
        [self setSelectedItemIndexPath:indexPath];
    }
    else if ([toolsDataSource respondsToSelector:@selector(collectionView:didSelectToolWithIndex:)])
    {
        [toolsDataSource collectionView:self didSelectToolWithIndex:indexPath.row];
        [self deselectItemAtIndexPath:indexPath animated:false];
    }
}

- (BOOL)collectionView:(UICollectionView *)__unused collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return self.scrollEnabled;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    NSInteger numberOfItems = [self numberOfItemsInSection:0];
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (self.frame.size.width > self.frame.size.height)
    {
        CGFloat size = numberOfItems * _layout.itemSize.width + MAX(0, (numberOfItems - 1)) * _layout.minimumLineSpacing;
        CGFloat edge = MAX(0, (collectionView.frame.size.width - size) / 2);
        inset = UIEdgeInsetsMake(0, MAX(0, edge - collectionView.contentInset.left), 0, MAX(0, edge - collectionView.contentInset.right));
    }
    else
    {
        CGFloat size = numberOfItems * _layout.itemSize.height + MAX(0, (numberOfItems - 1)) * _layout.minimumLineSpacing;
        CGFloat edge = MAX(0, (collectionView.frame.size.height - size) / 2);
        inset = UIEdgeInsetsMake(MAX(0, edge - collectionView.contentInset.top), 0, MAX(0, edge - collectionView.contentInset.bottom), 0);
    }
    
    return inset;
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    id<UICollectionViewDelegate> realDelegate = self.realDelegate;
    
    if ([realDelegate respondsToSelector:_cmd])
        [realDelegate scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)__unused scrollView
{
    self.scrollEnabled = true;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)__unused scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (self.interactionEnded != nil)
                self.interactionEnded();
        });
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)__unused scrollView
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (self.interactionEnded != nil)
            self.interactionEnded();
    });
}

@end
