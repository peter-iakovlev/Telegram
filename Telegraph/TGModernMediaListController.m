#import "TGModernMediaListController.h"

#import "TGModernMediaListModel.h"
#import "TGModernMediaListItem.h"

#import "TGModernMediaListLayout.h"
#import "TGModernMediaListItemView.h"

#import "TGModernGalleryController.h"
#import "TGOverlayControllerWindow.h"

#import "TGImageUtils.h"

@interface TGModernMediaListController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    CGSize _normalItemSize;
    CGSize _wideItemSize;
    CGFloat _widescreenWidth;
    CGFloat _normalLineSpacing;
    CGFloat _wideLineSpacing;
    
    UIEdgeInsets _normalEdgeInsets;
    UIEdgeInsets _wideEdgeInsets;
    
    UICollectionView *_collectionView;
    CGFloat _collectionViewWidth;
    TGModernMediaListLayout *_collectionLayout;
    UIView *_collectionContainer;
    NSMutableDictionary *_reusableItemContentViewsByIdentifier;
    
    id<TGModernMediaListItem> _hiddenItem;
    
    void (^_recycleItemContentView)(TGModernMediaListItemContentView *);
    NSMutableArray *_storedItemContentViews;
}

@end

@implementation TGModernMediaListController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _reusableItemContentViewsByIdentifier = [[NSMutableDictionary alloc] init];
        _storedItemContentViews = [[NSMutableArray alloc] init];
        
        __weak TGModernMediaListController *weakSelf = self;
        _recycleItemContentView = ^(TGModernMediaListItemContentView *itemContentView)
        {
            __strong TGModernMediaListController *strongSelf = weakSelf;
            [strongSelf enqueueView:itemContentView];
        };
        
        CGSize screenSize = TGScreenSize();
        _widescreenWidth = MAX(screenSize.width, screenSize.height);
        
        if ([UIScreen mainScreen].scale >= 2.0f - FLT_EPSILON)
        {
            if (_widescreenWidth >= 736.0f - FLT_EPSILON)
            {
                _normalItemSize = CGSizeMake(103.0f, 103.0f);
                _wideItemSize = CGSizeMake(103.0f, 103.0f);
                _normalEdgeInsets = UIEdgeInsetsMake(4.0f, 0.0f, 2.0f, 0.0f);
                _wideEdgeInsets = UIEdgeInsetsMake(4.0f, 2.0f, 1.0f, 2.0f);
                _normalLineSpacing = 1.0f;
                _wideLineSpacing = 2.0f;
            }
            else if (_widescreenWidth >= 667.0f - FLT_EPSILON)
            {
                _normalItemSize = CGSizeMake(93.0f, 93.5f);
                _wideItemSize = CGSizeMake(93.0f, 93.0f);
                _normalEdgeInsets = UIEdgeInsetsMake(4.0f, 0.0f, 2.0f, 0.0f);
                _wideEdgeInsets = UIEdgeInsetsMake(4.0f, 2.0f, 1.0f, 2.0f);
                _normalLineSpacing = 1.0f;
                _wideLineSpacing = 2.0f;
            }
            else
            {
                _normalItemSize = CGSizeMake(78.5f, 78.5f);
                _wideItemSize = CGSizeMake(78.0f, 78.0f);
                _normalEdgeInsets = UIEdgeInsetsMake(4.0f, 0.0f, 2.0f, 0.0f);
                _wideEdgeInsets = UIEdgeInsetsMake(4.0f, 1.0f, 1.0f, 1.0f);
                _normalLineSpacing = 2.0f;
                _wideLineSpacing = 3.0f;
            }
        }
        else
        {
            _normalItemSize = CGSizeMake(78.5f, 78.5f);
            _wideItemSize = CGSizeMake(78.0f, 78.0f);
            _normalEdgeInsets = UIEdgeInsetsMake(4.0f, 0.0f, 2.0f, 0.0f);
            _wideEdgeInsets = UIEdgeInsetsMake(4.0f, 1.0f, 1.0f, 1.0f);
            _normalLineSpacing = 2.0f;
            _wideLineSpacing = 2.0f;
        }
        
        self.title = TGLocalized(@"ConversationMedia.Title");
    }
    return self;
}

- (void)setModel:(TGModernMediaListModel *)model
{
    if (_model != model)
    {
        _model = model;
        
        __weak TGModernMediaListController *weakSelf = self;
        _model.itemsUpdated = ^
        {
            __strong TGModernMediaListController *strongSelf = weakSelf;
            [strongSelf reloadData];
        };
        _model.itemUpdated = ^(id<TGModernMediaListItem> item)
        {
            __strong TGModernMediaListController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                for (TGModernMediaListItemView *itemView in strongSelf->_collectionView.visibleCells)
                {
                    if ([itemView.itemContentView.item isEqual:item])
                    {
                        [itemView.itemContentView updateItem];
                        
                        break;
                    }
                }
            }
        };
        
        [self reloadData];
    }
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _collectionContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    _collectionContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_collectionContainer];
    
    CGSize frameSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
    
    _collectionLayout = [[TGModernMediaListLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height) collectionViewLayout:_collectionLayout];
    _collectionView.alwaysBounceVertical = true;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[TGModernMediaListItemView class] forCellWithReuseIdentifier:@"TGModernMediaListItemView"];
    [_collectionContainer addSubview:_collectionView];
    
    self.scrollViewsForAutomaticInsetsAdjustment = @[_collectionView];
    
    [self controllerInsetUpdated:UIEdgeInsetsZero];
    
    [_collectionLayout invalidateLayout];
    [_collectionView layoutSubviews];
    [self _adjustContentOffsetToBottom:self.interfaceOrientation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGSize frameSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
    CGRect collectionViewFrame = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    _collectionViewWidth = collectionViewFrame.size.width;
    _collectionView.frame = collectionViewFrame;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_model _transitionCompleted];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
}

- (bool)shouldAdjustScrollViewInsetsForInversedLayout
{
    return true;
}

- (void)reloadData
{
    for (TGModernMediaListItemView *itemView in [_collectionView visibleCells])
    {
        TGModernMediaListItemContentView *itemContentView = [itemView _takeItemContentView];
        if (itemContentView != nil)
            [_storedItemContentViews addObject:itemContentView];
    }
    
    [_collectionView reloadData];
    
    CGSize screenSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
    
    CGAffineTransform tableTransform = _collectionView.transform;
    _collectionView.transform = CGAffineTransformIdentity;
    
    CGFloat lastInverseOffset = MAX(0, _collectionView.contentSize.height - (_collectionView.contentOffset.y + _collectionView.frame.size.height - _collectionView.contentInset.bottom));
    //CGFloat lastOffset = _collectionView.contentOffset.y;
    
    CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _collectionViewWidth = tableFrame.size.width;
    _collectionView.frame = tableFrame;
    
    if (lastInverseOffset < 2)
        [self _adjustContentOffsetToBottom:self.interfaceOrientation];
    else
        [self _adjustInverseContentOffset:lastInverseOffset];
    /*else if (lastOffset < -_collectionView.contentInset.top + 2)
    {
        UIEdgeInsets contentInset = [self controllerInsetForInterfaceOrientation:self.interfaceOrientation];
        
        CGPoint contentOffset = CGPointMake(0, -contentInset.top);
        [_collectionView setContentOffset:contentOffset animated:false];
    }*/
    
    _collectionView.transform = tableTransform;
    
    [_collectionLayout invalidateLayout];
    [_collectionView layoutSubviews];
    
    for (TGModernMediaListItemContentView *itemContentView in _storedItemContentViews)
    {
        [self enqueueView:itemContentView];
    }
    
    [_storedItemContentViews removeAllObjects];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIView *snapshotView = [_collectionContainer snapshotViewAfterScreenUpdates:false];
    snapshotView.frame = _collectionContainer.frame;
    [self.view insertSubview:snapshotView aboveSubview:_collectionContainer];
    [UIView animateWithDuration:duration animations:^
    {
        snapshotView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [snapshotView removeFromSuperview];
    }];
    
    CGSize screenSize = [self referenceViewSizeForOrientation:toInterfaceOrientation];
    
    CGAffineTransform tableTransform = _collectionView.transform;
    _collectionView.transform = CGAffineTransformIdentity;
    
    CGFloat lastInverseOffset = MAX(0, _collectionView.contentSize.height - (_collectionView.contentOffset.y + _collectionView.frame.size.height - _collectionView.contentInset.bottom));
    CGFloat lastOffset = _collectionView.contentOffset.y;
    
    CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _collectionViewWidth = tableFrame.size.width;
    _collectionView.frame = tableFrame;
    
    if (lastInverseOffset < 2)
    {
        [self _adjustContentOffsetToBottom:toInterfaceOrientation];
    }
    else if (lastOffset < -_collectionView.contentInset.top + 2)
    {
        UIEdgeInsets contentInset = [self controllerInsetForInterfaceOrientation:toInterfaceOrientation];
        
        CGPoint contentOffset = CGPointMake(0, -contentInset.top);
        [_collectionView setContentOffset:contentOffset animated:false];
    }
    
    _collectionView.transform = tableTransform;
    
    [_collectionLayout invalidateLayout];
    [_collectionView layoutSubviews];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)_adjustContentOffsetToBottom:(UIInterfaceOrientation)orientation
{
    UIEdgeInsets sectionInsets = [self collectionView:_collectionView layout:_collectionLayout insetForSectionAtIndex:0];
    
    CGFloat itemSpacing = [self collectionView:_collectionView layout:_collectionLayout minimumInteritemSpacingForSectionAtIndex:0];
    CGFloat lineSpacing = [self collectionView:_collectionView layout:_collectionLayout minimumLineSpacingForSectionAtIndex:0];
    
    CGFloat additionalRowWidth = sectionInsets.left + sectionInsets.right;
    CGFloat currentRowWidth = 0.0f;
    CGFloat maxRowWidth = _collectionView.frame.size.width;
    
    CGSize itemSize = CGSizeZero;
    if ([self collectionView:_collectionView numberOfItemsInSection:0] != 0)
    {
        itemSize = [self collectionView:_collectionView layout:_collectionLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    
    CGFloat contentSize = 0.0f;
    
    for (int i = (int)([self collectionView:_collectionView numberOfItemsInSection:0]) - 1; i >= 0; i--)
    {
        if (currentRowWidth + itemSize.width + (currentRowWidth > FLT_EPSILON ? itemSpacing : 0.0f) + additionalRowWidth > maxRowWidth)
        {
            if (contentSize > FLT_EPSILON)
                contentSize += lineSpacing;
            contentSize += itemSize.height;
            
            currentRowWidth = 0.0f;
        }
        
        if (currentRowWidth > FLT_EPSILON)
            currentRowWidth += itemSpacing;
        currentRowWidth += itemSize.width;
    }
    
    if (currentRowWidth > FLT_EPSILON)
    {
        if (contentSize > FLT_EPSILON)
            contentSize += lineSpacing;
        contentSize += itemSize.height;
    }
    
    contentSize += sectionInsets.top + sectionInsets.bottom;
    
    UIEdgeInsets contentInset = [self controllerInsetForInterfaceOrientation:orientation];
    
    CGPoint contentOffset = CGPointMake(0, contentSize - _collectionView.frame.size.height + contentInset.bottom - 0.0f);
    if (contentOffset.y < -contentInset.top)
        contentOffset.y = -contentInset.top;
    [_collectionView setContentOffset:contentOffset animated:false];
}

- (void)_adjustInverseContentOffset:(CGFloat)inverseContentOffset
{
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    UIEdgeInsets sectionInsets = [self collectionView:_collectionView layout:_collectionLayout insetForSectionAtIndex:0];
    
    CGFloat itemSpacing = [self collectionView:_collectionView layout:_collectionLayout minimumInteritemSpacingForSectionAtIndex:0];
    CGFloat lineSpacing = [self collectionView:_collectionView layout:_collectionLayout minimumLineSpacingForSectionAtIndex:0];
    
    CGFloat additionalRowWidth = sectionInsets.left + sectionInsets.right;
    CGFloat currentRowWidth = 0.0f;
    CGFloat maxRowWidth = _collectionView.frame.size.width;
    
    CGSize itemSize = CGSizeZero;
    if ([self collectionView:_collectionView numberOfItemsInSection:0] != 0)
    {
        itemSize = [self collectionView:_collectionView layout:_collectionLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    
    CGFloat contentSize = 0.0f;
    
    for (int i = (int)([self collectionView:_collectionView numberOfItemsInSection:0]) - 1; i >= 0; i--)
    {
        if (currentRowWidth + itemSize.width + (currentRowWidth > FLT_EPSILON ? itemSpacing : 0.0f) + additionalRowWidth > maxRowWidth)
        {
            if (contentSize > FLT_EPSILON)
                contentSize += lineSpacing;
            contentSize += itemSize.height;
            
            currentRowWidth = 0.0f;
        }
        
        if (currentRowWidth > FLT_EPSILON)
            currentRowWidth += itemSpacing;
        currentRowWidth += itemSize.width;
    }
    
    if (currentRowWidth > FLT_EPSILON)
    {
        if (contentSize > FLT_EPSILON)
            contentSize += lineSpacing;
        contentSize += itemSize.height;
    }
    
    contentSize += sectionInsets.top + sectionInsets.bottom;
    
    UIEdgeInsets contentInset = [self controllerInsetForInterfaceOrientation:orientation];
    
    CGPoint contentOffset = CGPointMake(0.0f, contentSize - _collectionView.frame.size.height + contentInset.bottom - inverseContentOffset);
    
    if (contentOffset.y < -contentInset.top)
        contentOffset.y = -contentInset.top;
    [_collectionView setContentOffset:contentOffset animated:false];
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON) ? _wideItemSize : _normalItemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    if (ABS(_collectionViewWidth - 540.0f) < FLT_EPSILON)
        return UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    
    return (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON) ? _wideEdgeInsets : _normalEdgeInsets;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    if (ABS(_collectionViewWidth - 540.0f) < FLT_EPSILON)
        return 10.0f;
    
    return (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON) ? _wideLineSpacing : _normalLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return _model.totalCount;
}

- (TGModernMediaListItemContentView *)dequeueViewForItem:(id<TGModernMediaListItem>)item
{
    if (item == nil || [item viewClass] == nil)
        return nil;
    
    NSString *identifier = NSStringFromClass([item viewClass]);
    NSMutableArray *views = _reusableItemContentViewsByIdentifier[identifier];
    if (views == nil)
    {
        views = [[NSMutableArray alloc] init];
        _reusableItemContentViewsByIdentifier[identifier] = views;
    }
    
    if (views.count == 0)
    {
        Class itemClass = [item viewClass];
        TGModernMediaListItemContentView *itemView = [[itemClass alloc] init];
        [itemView setItem:item];
        
        return itemView;
    }
    
    TGModernMediaListItemContentView *itemView = [views lastObject];
    [views removeLastObject];
    
    [itemView setItem:item];
    
    return itemView;
}

- (void)enqueueView:(TGModernMediaListItemContentView *)itemView
{
    if (itemView == nil)
        return;
    
    NSString *identifier = NSStringFromClass([itemView class]);
    if (identifier != nil)
    {
        NSMutableArray *views = _reusableItemContentViewsByIdentifier[identifier];
        if (views == nil)
        {
            views = [[NSMutableArray alloc] init];
            _reusableItemContentViewsByIdentifier[identifier] = views;
        }
        [views addObject:itemView];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.item - (_model.totalCount - _model.items.count);
    if (index < 0)
    {
        TGModernMediaListItemView *itemView = (TGModernMediaListItemView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGModernMediaListItemView" forIndexPath:indexPath];
        return itemView;
    }
    else
    {
        id<TGModernMediaListItem> item = _model.items[index];
        
        TGModernMediaListItemView *itemView = (TGModernMediaListItemView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGModernMediaListItemView" forIndexPath:indexPath];
        
        if (itemView.recycleItemContentView == nil)
            itemView.recycleItemContentView = _recycleItemContentView;
        
        TGModernMediaListItemContentView *itemContentView = nil;
        if (_storedItemContentViews.count != 0)
        {
            NSInteger index = -1;
            for (TGModernMediaListItemContentView *stroredItemContentView in _storedItemContentViews)
            {
                index++;
                
                if ([item isEqual:stroredItemContentView.item])
                {
                    itemContentView = stroredItemContentView;
                    [_storedItemContentViews removeObjectAtIndex:(NSUInteger)index];
                    
                    break;
                }
            }
        }
        
        if (itemContentView == nil)
            itemContentView = [self dequeueViewForItem:item];
        
        [itemView setItemContentView:itemContentView];
        
        if (_hiddenItem == nil)
            itemContentView.isHidden = false;
        else
            itemContentView.isHidden = [_hiddenItem isEqual:itemContentView.item];
        
        return itemView;
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.item - (_model.totalCount - _model.items.count);
    if (index >= 0)
    {
        __weak TGModernMediaListController *weakSelf = self;
        TGModernGalleryController *controller = [_model createGalleryControllerForItem:_model.items[index] hideItem:^(id<TGModernMediaListItem> item)
        {
            __strong TGModernMediaListController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_hiddenItem = item;
                [strongSelf _updateHiddenItems];
            }
        } referenceViewForItem:^UIView *(id<TGModernMediaListItem> item)
        {
            if (item == nil)
                return nil;
            
            __strong TGModernMediaListController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                for (TGModernMediaListItemView *itemView in [strongSelf->_collectionView visibleCells])
                {
                    if ([itemView.itemContentView.item isEqual:item])
                        return itemView.itemContentView;
                }
            }
            
            return nil;
        }];
        if (controller != nil)
        {
            TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:controller];
            controllerWindow.hidden = false;
        }
    }
}

- (void)_updateHiddenItems
{
    for (TGModernMediaListItemView *itemView in [_collectionView visibleCells])
    {
        if (_hiddenItem == nil)
            itemView.itemContentView.isHidden = false;
        else
            itemView.itemContentView.isHidden = [_hiddenItem isEqual:itemView.itemContentView.item];
    }
}

@end
