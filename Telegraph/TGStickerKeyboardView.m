#import "TGStickerKeyboardView.h"

#import "TGStickerCollectionViewCell.h"
#import "TGStickerKeyboardTabPanel.h"

#import "TGDocumentMediaAttachment.h"
#import "TGStickersSignals.h"

#import "TGImageUtils.h"

#import "TGSingleStickerPreviewWindow.h"

static const CGFloat preloadInset = 160.0f;

@interface TGStickerKeyboardView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
{
    id<SDisposable> _stickerPacksDisposable;
    
    TGStickerKeyboardTabPanel *_tabPanel;
    CGFloat _lastContentOffset;
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    UIView *_topStripe;
    
    NSArray *_stickerPacks;
    NSMutableDictionary *_documentIdsUseCount;
    NSArray *_recentDocuments;
    
    TGSingleStickerPreviewWindow *_stickerPreviewWindow;
    UIPanGestureRecognizer *_panRecognizer;
}

@end

@implementation TGStickerKeyboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = UIColorRGB(0xe8ebef);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.clipsToBounds = true;
        
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = nil;
        _collectionView.opaque = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.alwaysBounceVertical = true;
        _collectionView.delaysContentTouches = false;
        _collectionView.contentInset = UIEdgeInsetsMake(45.0f + preloadInset, 0.0f, preloadInset, 0.0f);
        [_collectionView registerClass:[TGStickerCollectionViewCell class] forCellWithReuseIdentifier:@"TGStickerCollectionViewCell"];
        [self addSubview:_collectionView];
        
        UILongPressGestureRecognizer *tapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        tapRecognizer.minimumPressDuration = 0.25;
        [_collectionView addGestureRecognizer:tapRecognizer];
        
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        _panRecognizer.delegate = self;
        _panRecognizer.cancelsTouchesInView = false;
        [_collectionView addGestureRecognizer:_panRecognizer];
        
        __weak TGStickerKeyboardView *weakSelf = self;
        _tabPanel = [[TGStickerKeyboardTabPanel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 45.0f)];
        _tabPanel.currentStickerPackIndexChanged = ^(NSUInteger index)
        {
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf scrollToSection:index];
        };
        [self addSubview:_tabPanel];
        
        CGFloat stripeHeight = TGIsRetina() ? 0.5f : 1.0f;
        _topStripe = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, stripeHeight)];
        _topStripe.backgroundColor = UIColorRGB(0xd8d8d8);
        [self addSubview:_topStripe];
        
        _stickerPacksDisposable = [[[TGStickersSignals stickerPacks] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict)
        {
            NSDictionary *packUseCount = dict[@"packUseCount"];
            
            NSMutableArray *filteredPacks = [[NSMutableArray alloc] init];
            for (TGStickerPack *pack in dict[@"packs"])
            {
                if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]])
                    [filteredPacks addObject:pack];
            }
            
            NSArray *sortedStickerPacks = [filteredPacks sortedArrayUsingComparator:^NSComparisonResult(TGStickerPack *pack1, TGStickerPack *pack2)
            {
                NSNumber *id1 = @(((TGStickerPackIdReference *)pack1.packReference).packId);
                NSNumber *id2 = @(((TGStickerPackIdReference *)pack2.packReference).packId);
                NSNumber *useCount1 = packUseCount[id1];
                NSNumber *useCount2 = packUseCount[id2];
                if (useCount1 != nil && useCount2 != nil)
                {
                    NSComparisonResult result = [useCount1 compare:useCount2];
                    if (result == NSOrderedSame)
                        return [id1 compare:id2];
                    return result;
                }
                else if (useCount1 != nil)
                    return NSOrderedDescending;
                else if (useCount2 != nil)
                    return NSOrderedAscending;
                else
                    return [id1 compare:id2];
            }];
            
            NSMutableArray *reversed = [[NSMutableArray alloc] init];
            for (id item in sortedStickerPacks.reverseObjectEnumerator)
            {
                [reversed addObject:item];
            }
            
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (![strongSelf->_stickerPacks isEqual:reversed])
                {
                    [strongSelf setStickerPacks:reversed documentIdsUseCount:dict[@"documentIdsUseCount"]];
                }
            }
        }];
    }
    return self;
}

- (void)dealloc
{
    [_stickerPacksDisposable dispose];
}

- (void)sizeToFitForWidth:(CGFloat)width
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat maxSide = MAX(screenSize.width, screenSize.height);
    CGFloat height = ABS(maxSide - width) < FLT_EPSILON ? 100.0f : 216.0f;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
}

- (void)setFrame:(CGRect)frame
{
    bool sizeUpdated = !CGSizeEqualToSize(frame.size, self.frame.size);
    [super setFrame:frame];
    
    if (sizeUpdated && frame.size.width > FLT_EPSILON && frame.size.height > FLT_EPSILON)
        [self layoutForSize:frame.size];
}

- (void)setBounds:(CGRect)bounds
{
    bool sizeUpdated = !CGSizeEqualToSize(bounds.size, self.bounds.size);
    [super setBounds:bounds];
    
    if (sizeUpdated && bounds.size.width > FLT_EPSILON && bounds.size.height > FLT_EPSILON)
        [self layoutForSize:bounds.size];
}

- (void)layoutForSize:(CGSize)size
{
    _tabPanel.frame = CGRectMake(0.0f, 0.0f, size.width, 45.0f);
    _collectionView.frame = CGRectMake(0.0f, -preloadInset, size.width, size.height + preloadInset * 2.0f);
    [_collectionLayout invalidateLayout];
    
    CGFloat stripeHeight = TGIsRetina() ? 0.5f : 1.0f;
    _topStripe.frame = CGRectMake(0.0f, 0.0f, size.width, stripeHeight);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView
{
    return 1 + _stickerPacks.count;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
        return (NSInteger)_recentDocuments.count;
    return ((TGStickerPack *)_stickerPacks[section - 1]).documents.count;
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return CGSizeMake(62.0f, 62.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat sideInset = (collectionView.frame.size.width < 330.0f) ? 3.0f : 15.0f;
    
    if (_recentDocuments.count == 0 && _stickerPacks.count == 1)
    {
        if (section == 0)
            return UIEdgeInsetsZero;
        
        return UIEdgeInsetsMake(15.0f, sideInset, 15.0f, sideInset);
    }
    
    if (section == 0)
    {
        if (_recentDocuments.count == 0)
            return UIEdgeInsetsMake(15.0f, sideInset, 0.0f, sideInset);
        else
        {
            return UIEdgeInsetsMake(15.0f, sideInset, [self collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section], sideInset);
        }
    }
    else if (section == (NSInteger)_stickerPacks.count)
        return UIEdgeInsetsMake(0.0f, sideInset, 15.0f, sideInset);
    return UIEdgeInsetsMake(0.0f, sideInset, [self collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section], sideInset);
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 7.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return (collectionView.frame.size.width < 330.0f) ? 0.0f : 4.0f;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _collectionView)
    {
        CGFloat delta = scrollView.contentOffset.y - _lastContentOffset;
        _lastContentOffset = scrollView.contentOffset.y;
        
        CGRect tabPanelFrame = _tabPanel.frame;
        if (scrollView.contentOffset.y <= - 45.0f - preloadInset)
            tabPanelFrame.origin.y = 0.0f;
        else if (scrollView.contentOffset.y < scrollView.contentSize.height - scrollView.frame.size.height)
            tabPanelFrame.origin.y -= delta;
        tabPanelFrame.origin.y = MAX(-45.0f - preloadInset, MIN(0.0f, tabPanelFrame.origin.y));
        _tabPanel.frame = tabPanelFrame;
        
        NSArray *layoutAttributes = [_collectionLayout layoutAttributesForElementsInRect:CGRectMake(0.0f, scrollView.contentOffset.y + 45.0f + preloadInset + 7.0f, scrollView.frame.size.width, scrollView.frame.size.height - 45.0f - preloadInset - 7.0f)];
        NSInteger minSection = INT_MAX;
        for (UICollectionViewLayoutAttributes *attributes in layoutAttributes)
        {
            minSection = MIN(attributes.indexPath.section, minSection);
        }
        if (minSection != INT_MAX)
            [_tabPanel setCurrentStickerPackIndex:minSection];
    }
}

- (TGDocumentMediaAttachment *)documentAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return _recentDocuments[indexPath.item];
    else
        return ((TGStickerPack *)_stickerPacks[indexPath.section - 1]).documents[indexPath.item];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerCollectionViewCell" forIndexPath:indexPath];
    [cell setDocumentMedia:[self documentAtIndexPath:indexPath]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isEnabled])
    {
        [cell setDisabledTimeout];
        
        TGDocumentMediaAttachment *document = [self documentAtIndexPath:indexPath];
        _documentIdsUseCount[@(document.documentId)] = @([_documentIdsUseCount[@(document.documentId)] intValue] + 1);
        [[SQueue concurrentDefaultQueue] dispatch:^{
            [TGStickersSignals addUseCountForDocumentId:document.documentId];
        }];
        if (_stickerSelected)
            _stickerSelected(document);
    }
}

- (void)scrollToSection:(NSUInteger)section
{
    [_tabPanel setCurrentStickerPackIndex:section];
    
    if (section == 0)
    {
        if (_recentDocuments.count != 0)
        {
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:true];
        }
        else
        {
            [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:true];
        }
    }
    else
    {
        if (((TGStickerPack *)_stickerPacks[section - 1]).documents.count != 0)
        {
            UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            
            CGFloat verticalOffset = attributes.frame.origin.y - [self collectionView:_collectionView layout:_collectionLayout minimumLineSpacingForSectionAtIndex:section];
            CGFloat effectiveInset = 0.0f;
            if (verticalOffset < _collectionView.contentOffset.y)
                effectiveInset = _collectionView.contentInset.top;
            else
                effectiveInset = preloadInset;
            
            [_collectionView setContentOffset:CGPointMake(0.0f, verticalOffset - effectiveInset) animated:true];
        }
    }
}

- (void)setStickerPacks:(NSArray *)stickerPacks documentIdsUseCount:(NSDictionary *)documentIdsUseCount
{
    _stickerPacks = stickerPacks;
    _documentIdsUseCount = [[NSMutableDictionary alloc] initWithDictionary:documentIdsUseCount];
    
    [self updateRecentDocuments];
    
    [_collectionView reloadData];
    
    [_tabPanel setStickerPacks:stickerPacks showRecent:_recentDocuments.count != 0];
}

- (void)updateRecentDocuments
{
    NSMutableArray *recentDocuments = [[NSMutableArray alloc] init];
    NSMutableSet *processedDocumentIds = [[NSMutableSet alloc] init];
    for (TGStickerPack *stickerPack in _stickerPacks)
    {
        for (TGDocumentMediaAttachment *document in stickerPack.documents)
        {
            if (![processedDocumentIds containsObject:@(document.documentId)] && _documentIdsUseCount[@(document.documentId)] != nil)
            {
                [recentDocuments addObject:document];
                [processedDocumentIds addObject:@(document.documentId)];
            }
        }
    }
    
    [recentDocuments sortUsingComparator:^NSComparisonResult(TGDocumentMediaAttachment *document1, TGDocumentMediaAttachment *document2)
    {
        int useCount1 = [_documentIdsUseCount[@(document1.documentId)] intValue];
        int useCount2 = [_documentIdsUseCount[@(document2.documentId)] intValue];
        if (useCount1 > useCount2)
            return NSOrderedAscending;
        else if (useCount1 < useCount2)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    if (recentDocuments.count > 20)
        [recentDocuments removeObjectsInRange:NSMakeRange(20, recentDocuments.count - 20)];
    
    _recentDocuments = recentDocuments;
}

- (void)updateIfNeeded
{
    [self updateRecentDocuments];
    
    [_collectionView reloadData];
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0];
}

- (void)tapGesture:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [recognizer locationInView:_collectionView];
        
        for (NSIndexPath *indexPath in [_collectionView indexPathsForVisibleItems])
        {
            TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
            if (CGRectContainsPoint(cell.frame, point))
            {
                TGViewController *parentViewController = _parentViewController;
                if (parentViewController != nil)
                {
                    _stickerPreviewWindow.hidden = true;
                    
                    _stickerPreviewWindow = [[TGSingleStickerPreviewWindow alloc] initWithParentController:parentViewController];
                    _stickerPreviewWindow.userInteractionEnabled = false;
                    TGDocumentMediaAttachment *document = [self documentAtIndexPath:indexPath];
                    [_stickerPreviewWindow.view setDocument:document];
                    _stickerPreviewWindow.hidden = false;
                    [cell setHighlightedWithBounce:true];
                }
                
                break;
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        __weak UIWindow *weakWindow = _stickerPreviewWindow;
        [_stickerPreviewWindow.view animateDismiss:^{
            __strong UIWindow *strongWindow = weakWindow;
            strongWindow.hidden = true;
        }];
        _stickerPreviewWindow = nil;
        
        for (TGStickerCollectionViewCell *cell in [_collectionView visibleCells])
        {
            [cell setHighlightedWithBounce:false];
        }
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
    if (_stickerPreviewWindow != nil && recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint point = [recognizer locationInView:_collectionView];
        
        for (NSIndexPath *indexPath in [_collectionView indexPathsForVisibleItems])
        {
            TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
            if (CGRectContainsPoint(cell.frame, point))
            {
                TGDocumentMediaAttachment *document = [self documentAtIndexPath:indexPath];
                [_stickerPreviewWindow.view setDocument:document];
                [cell setHighlightedWithBounce:true];
            }
            else
            {
                [cell setHighlightedWithBounce:false];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == _panRecognizer || otherGestureRecognizer == _panRecognizer)
        return true;
    return false;
}

@end
