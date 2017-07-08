#import "TGCollectionMenuController.h"

#import "TGInterfaceAssets.h"
#import "TGImageUtils.h"

#import "TGCollectionMenuView.h"
#import "TGCollectionMenuLayout.h"

@interface TGCollectionMenuSection ()

- (void)insertItem:(TGCollectionItem *)item atIndex:(NSUInteger)index;
- (void)deleteItemAtIndex:(NSUInteger)index;
- (void)replaceItemAtIndex:(NSUInteger)index withItem:(TGCollectionItem *)item;

@end

@interface TGCollectionMenuController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TGCollectionMenuViewDelegate, TGCollectionMenuLayoutDataSource, TGCollectionMenuLayoutDelegateFlowLayout>
{
    bool _editingMode;
    
    NSMutableSet *_collectionRegisteredIdentifiers;
    
    CGFloat _currentLayoutWidth;
    
    UIView *_headerBackgroundView;
}

@end

@implementation TGCollectionMenuController

- (id)init
{
    self = [super init];
    if (self)
    {
        _menuSections = [[TGCollectionMenuSectionList alloc] init];
    }
    return self;
}

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (void)enterEditingMode:(bool)animated
{
    if (!_editingMode)
    {
        _editingMode = true;
        
        [_collectionView setEditing:true animated:animated];
        
        [self didEnterEditingMode:animated];
    }
}

- (void)leaveEditingMode:(bool)animated
{
    if (_editingMode)
    {
        _editingMode = false;
        
        [_collectionView setEditing:false animated:animated];
        
        [self didLeaveEditingMode:animated];
    }
}

- (void)didEnterEditingMode:(bool)__unused animated
{   
}

- (void)didLeaveEditingMode:(bool)__unused animated
{
}

- (void)_resetCollectionView
{
    if (_collectionView != nil)
    {
        _collectionView.delegate = nil;
        _collectionView.dataSource = nil;
        [_collectionView removeFromSuperview];
    }
    
    _currentLayoutWidth = self.view.frame.size.width;
    
    _collectionRegisteredIdentifiers = [[NSMutableSet alloc] init];
    
    _collectionLayout = [[TGCollectionMenuLayout alloc] init];
    _collectionView = [[TGCollectionMenuView alloc] initWithFrame:self.view.bounds collectionViewLayout:_collectionLayout];
    _collectionView.backgroundColor = nil;
    _collectionView.opaque = false;
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    _collectionView.alwaysBounceVertical = true;
    
    [_collectionView registerClass:[TGCollectionItemView class] forCellWithReuseIdentifier:@"_empty"];
    
    __weak TGCollectionMenuController *weakSelf = self;
    _collectionView.layoutForSize = ^(CGSize size) {
        __strong TGCollectionMenuController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            strongSelf->_currentLayoutWidth = size.width;
            [strongSelf->_collectionLayout invalidateLayout];
            [strongSelf->_collectionView setNeedsLayout];
            [strongSelf->_collectionView layoutSubviews];
        }
    };
    
    [self.view insertSubview:_collectionView aboveSubview:_headerBackgroundView];
}

- (void)collectionMenuViewDidEnterEditingMode:(TGCollectionMenuView *)__unused collectionMenuView
{
    if (!_editingMode)
    {
        _editingMode = true;
        
        [self didEnterEditingMode:true];
    }
}

- (void)collectionMenuViewDidLeaveEditingMode:(TGCollectionMenuView *)__unused collectionMenuView
{
    if (_editingMode)
    {
        _editingMode = false;
        
        [self didLeaveEditingMode:true];
    }
}

- (NSIndexPath *)indexPathForItem:(TGCollectionItem *)item
{
    int sectionIndex = -1;
    
    for (TGCollectionMenuSection *section in _menuSections.sections)
    {
        sectionIndex++;
        
        int itemIndex = -1;
        
        for (TGCollectionItem *listItem in section.items)
        {
            itemIndex++;
            
            if (listItem == item)
            {
                return [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            }
        }
    }
    
    return nil;
}

- (NSUInteger)indexForSection:(TGCollectionMenuSection *)section
{
    int index = -1;
    for (TGCollectionMenuSection *listSection in _menuSections.sections)
    {
        index++;
        
        if (listSection == section)
            return (NSUInteger)index;
    }
    
    return NSNotFound;
}

- (void)loadView
{
    [super loadView];
    
    if (TGIsPad()) {
        self.view.frame = self.navigationController.view.bounds;
    }
    self.view.backgroundColor = [TGInterfaceAssets listsBackgroundColor];
    
    _headerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.controllerInset.top)];
    _headerBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_headerBackgroundView];
    
    [self _resetCollectionView];
    
    [self setExplicitTableInset:UIEdgeInsetsMake(-(TGScreenPixel), 0, 0, 0)];
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

#pragma mark -

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    if ([self isViewLoaded]) {
        _headerBackgroundView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.controllerInset.top);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    for (NSIndexPath *indexPath in [_collectionView indexPathsForSelectedItems])
    {
        [_collectionView deselectItemAtIndexPath:indexPath animated:animated];
    }
    
    [super viewWillAppear:animated];
}

/*- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGFloat currentLayoutWidth = [self inPopover] ? self.view.frame.size.width : [TGViewController screenSizeForInterfaceOrientation:toInterfaceOrientation].width;
    _currentLayoutWidth = currentLayoutWidth;
    [_collectionLayout invalidateLayout];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}*/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == _collectionView)
        return _menuSections.sections.count;
    
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _collectionView && section < (NSInteger)_menuSections.sections.count)
        return ((TGCollectionMenuSection *)_menuSections.sections[section]).items.count;
    return 0;
}

- (void)updateItem:(TGCollectionItem *)item itemView:(TGCollectionItemView *)itemView positionAtIndexPath:(NSIndexPath *)indexPath ignoreDragging:(bool)ignoreDragging animated:(bool)animated
{
    TGCollectionItem *previousItem = nil;
    if (indexPath.item > 0)
    {
        if (ignoreDragging || _collectionLayout.selectedItemIndexPath == nil || ![_collectionLayout.selectedItemIndexPath isEqual:[NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section]])
        {
            previousItem = ((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items[indexPath.item - 1];
        }
    }
    
    TGCollectionItem *nextItem = nil;
    if (indexPath.item < (NSInteger)((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items.count - 1)
    {
        if (ignoreDragging || _collectionLayout.selectedItemIndexPath == nil || ![_collectionLayout.selectedItemIndexPath isEqual:[NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section]])
        {
            nextItem = ((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items[indexPath.item + 1];
        }
    }
    
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
    
    [itemView setItemPosition:itemPositionMask animated:animated];
}

- (UICollectionViewCell *)collectionView:(TGCollectionMenuView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGCollectionItem *item = indexPath.section < (NSInteger)_menuSections.sections.count && indexPath.row < (NSInteger)((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items.count ? ((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items[indexPath.item] : nil;
    
    if (item != nil)
    {
        TGCollectionItemView *itemView = [item dequeueItemView:collectionView registeredIdentifiers:_collectionRegisteredIdentifiers forIndexPath:indexPath];
        if (iosMajorVersion() <= 8) {
            if (itemView.boundItem != nil)
                [itemView.boundItem unbindView];
            
            [self updateItem:item itemView:itemView positionAtIndexPath:indexPath ignoreDragging:false animated:false];
            
            [item bindView:itemView];
            
            [collectionView setupCellForEditing:itemView];
        }
        
        return itemView;
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"_empty" forIndexPath:indexPath];
}

- (void)collectionView:(TGCollectionMenuView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (iosMajorVersion() >= 8) {
        TGCollectionItem *item = indexPath.section < (NSInteger)_menuSections.sections.count && indexPath.row < (NSInteger)((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items.count ? ((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items[indexPath.item] : nil;
        
        if (item != nil)
        {
            TGCollectionItemView *itemView = (TGCollectionItemView *)cell;
            if (itemView.boundItem != nil)
                [itemView.boundItem unbindView];
            
            [self updateItem:item itemView:itemView positionAtIndexPath:indexPath ignoreDragging:false animated:false];
            
            [item bindView:itemView];
            
            [collectionView setupCellForEditing:itemView];
            
            [self willDisplayItem:item];
        }
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView didEndDisplayingCell:(TGCollectionItemView *)cell forItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    [cell.boundItem unbindView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGCollectionItem *item = indexPath.section < (NSInteger)_menuSections.sections.count && indexPath.row < (NSInteger)((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items.count ? ((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items[indexPath.item] : nil;
    
    CGSize layoutSize = collectionView.frame.size;
    
    if (item != nil)
        return [item itemSizeForContainerSize:layoutSize];
    
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView == _collectionView)
    {
        
        return ((TGCollectionMenuSection *)_menuSections.sections[section]).insets;
    }
    
    return UIEdgeInsetsZero;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _collectionView)
    {
        TGCollectionItem *item = indexPath.section < (NSInteger)_menuSections.sections.count && indexPath.row < (NSInteger)((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items.count ? ((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items[indexPath.item] : nil;
        if (item != nil)
            return item.highlightable;
    }
    
    return false;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _collectionView)
    {
        TGCollectionItem *item = indexPath.section < (NSInteger)_menuSections.sections.count && indexPath.row < (NSInteger)((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items.count ? ((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items[indexPath.item] : nil;
        if (item != nil)
            return item.selectable;
    }
    
    return false;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _collectionView)
    {
        TGCollectionItem *item = indexPath.section < (NSInteger)_menuSections.sections.count && indexPath.row < (NSInteger)((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items.count ? ((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items[indexPath.item] : nil;
        if (item != nil)
        {
            [item itemSelected:self];
            
            if (item.deselectAutomatically)
                [collectionView deselectItemAtIndexPath:indexPath animated:true];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _collectionView)
    {
        TGCollectionItem *item = indexPath.section < (NSInteger)_menuSections.sections.count && indexPath.row < (NSInteger)((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items.count ? ((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items[indexPath.item] : nil;
        if (item != nil)
        {
            return [item itemWantsMenu];
        }
    }
    
    return false;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)__unused sender
{
    if (collectionView == _collectionView)
    {
        TGCollectionItem *item = indexPath.section < (NSInteger)_menuSections.sections.count && indexPath.row < (NSInteger)((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items.count ? ((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items[indexPath.item] : nil;
        if (item != nil)
        {
            return [item itemCanPerformAction:action];
        }
    }
    
    return false;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)__unused sender
{
    if (collectionView == _collectionView)
    {
        TGCollectionItem *item = indexPath.section < (NSInteger)_menuSections.sections.count && indexPath.row < (NSInteger)((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items.count ? ((TGCollectionMenuSection *)_menuSections.sections[indexPath.section]).items[indexPath.item] : nil;
        if (item != nil)
        {
            return [item itemPerformAction:action];
        }
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    TGCollectionMenuSection *fromSection = _menuSections.sections[fromIndexPath.section];
    TGCollectionMenuSection *toSection = _menuSections.sections[toIndexPath.section];
    if (fromSection == toSection)
    {
        NSInteger fromIndex = fromIndexPath.item;
        id item = fromSection.items[fromIndex];
        
        NSInteger toIndex = toIndexPath.item;
        
        [fromSection deleteItemAtIndex:fromIndex];
        [fromSection insertItem:item atIndex:toIndex];
    }
    else
    {
        id item = fromSection.items[fromIndexPath.item];
        [fromSection deleteItemAtIndex:fromIndexPath.item];
        [toSection insertItem:item atIndex:toIndexPath.item];
    }
}

- (void)animateCollectionCrossfade
{
    UIView *snapshotView = [self.collectionView snapshotViewAfterScreenUpdates:false];
    [self.view insertSubview:snapshotView aboveSubview:self.collectionView];
    
    [UIView animateWithDuration:0.3 animations:^
    {
        snapshotView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [snapshotView removeFromSuperview];
    }];
}

- (void)updateItemPositions
{
    [self updateItemPositions:false];
}

- (void)updateItemPositions:(bool)ignoreDragging
{
    for (NSIndexPath *indexPath in [_collectionView indexPathsForVisibleItems])
    {
        TGCollectionMenuSection *section = _menuSections.sections[indexPath.section];
        TGCollectionItem *item = section.items[indexPath.item];
        TGCollectionItemView *itemView = (TGCollectionItemView *)[_collectionView cellForItemAtIndexPath:indexPath];
        [self updateItem:item itemView:itemView positionAtIndexPath:indexPath ignoreDragging:ignoreDragging animated:true];
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView itemAtIndexPath:(NSIndexPath *)__unused fromIndexPath willBeginMovingToIndexPath:(NSIndexPath *)__unused toIndexPath
{
    [self updateItemPositions:false];
}

- (void)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    [self updateItemPositions:true];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGCollectionItemView *itemView = (TGCollectionItemView *)[collectionView cellForItemAtIndexPath:indexPath];
    [itemView setItemPosition:TGCollectionItemViewPositionFirstInBlock | TGCollectionItemViewPositionLastInBlock];
}

- (void)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    [self updateItemPositions:false];
}

- (void)collectionView:(UICollectionView *)__unused collectionView itemAtIndexPath:(NSIndexPath *)__unused fromIndexPath didMoveToIndexPath:(NSIndexPath *)__unused toIndexPath
{
}

- (BOOL)collectionView:(UICollectionView *)__unused collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGCollectionMenuSection *section = _menuSections.sections[indexPath.section];
    TGCollectionItem *item = section.items[indexPath.item];
    return _editingMode && item.canBeMovedToSectionAtIndex != nil;
}

- (BOOL)collectionView:(UICollectionView *)__unused collectionView itemAtIndexPath:(NSIndexPath *) fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    TGCollectionMenuSection *section = _menuSections.sections[fromIndexPath.section];
    TGCollectionItem *item = section.items[fromIndexPath.item];
    return item.canBeMovedToSectionAtIndex != nil && item.canBeMovedToSectionAtIndex(toIndexPath.section, toIndexPath.item);
}

- (BOOL)collectionViewCanMoveItems:(UICollectionView *)__unused collectionView
{
    return _enableItemReorderingGestures;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height * 2.0f) {
            [self loadMore];
        }
    }
}

- (void)willDisplayItem:(TGCollectionItem *)__unused item {
}

- (void)loadMore {
}

@end
