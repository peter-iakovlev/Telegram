#import "TGStickerKeyboardView.h"

#import "TGStickerCollectionViewCell.h"
#import "TGStickerKeyboardTabPanel.h"

#import "TGDocumentMediaAttachment.h"
#import "TGStickersSignals.h"
#import "TGRecentGifsSignal.h"

#import "TGImageUtils.h"

#import "TGSingleStickerPreviewWindow.h"

#import "TGGifKeyboardCell.h"

#import "TGGifKeyboardBalancedLayout.h"

#import "TGDocumentMediaAttachment.h"

#import "TGMenuView.h"

static const CGFloat preloadInset = 160.0f;
static const CGFloat gifInset = 128.0f;

@interface TGStickerKeyboardView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TGGifKeyboardBalancedLayoutDelegate, UIGestureRecognizerDelegate, ASWatcher>
{
    id<SDisposable> _stickerPacksDisposable;
    
    TGStickerKeyboardViewStyle _style;
    TGStickerKeyboardTabPanel *_tabPanel;
    CGFloat _lastContentOffset;

    UICollectionView *_gifsCollectionView;
    TGGifKeyboardBalancedLayout *_gifsCollectionLayout;
    
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    
    UIView *_topStripe;
    
    NSArray *_stickerPacks;
    NSMutableDictionary *_documentIdsUseCount;
    NSArray *_recentDocuments;
    
    NSArray *_recentGifsOriginal;
    NSArray *_recentGifsSorted;
    NSArray *_recentGifs;
    
    TGSingleStickerPreviewWindow *_stickerPreviewWindow;
    UIPanGestureRecognizer *_panRecognizer;
    
    bool _gifsMode;
    
    bool _ignoreSetSection;
    
    bool _ignoreGifCellContents;
    
    TGMenuContainerView *_menuContainerView;
    bool _ignoreSelection;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGStickerKeyboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame style:TGStickerKeyboardViewDefaultStyle];
}

- (instancetype)initWithFrame:(CGRect)frame style:(TGStickerKeyboardViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        _style = style;
        
        if (style == TGStickerKeyboardViewDarkBlurredStyle)
        {
            if (iosMajorVersion() >= 8)
                self.backgroundColor = [UIColor clearColor];
            else
                self.backgroundColor = UIColorRGB(0x292a2a);
            
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        else
        {
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.backgroundColor = UIColorRGB(0xe8ebef);
        }
    
        self.clipsToBounds = true;
        
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.opaque = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.alwaysBounceVertical = true;
        _collectionView.delaysContentTouches = false;
        _collectionView.contentInset = UIEdgeInsetsMake(45.0f + preloadInset, 0.0f, preloadInset, 0.0f);
        [_collectionView registerClass:[TGStickerCollectionViewCell class] forCellWithReuseIdentifier:@"TGStickerCollectionViewCell"];
        [self addSubview:_collectionView];
        
        _gifsCollectionLayout = [[TGGifKeyboardBalancedLayout alloc] init];
        _gifsCollectionLayout.preferredRowSize = 93.0f;
        //_gifsCollectionLayout.preferredRowSize = 28.0f;
        _gifsCollectionLayout.sectionInset = UIEdgeInsetsZero;
        _gifsCollectionLayout.minimumInteritemSpacing = 0.5f;
        _gifsCollectionLayout.minimumLineSpacing = 0.5f;
        _gifsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_gifsCollectionLayout];
        _gifsCollectionView.delegate = self;
        _gifsCollectionView.dataSource = self;
        _gifsCollectionView.backgroundColor = [UIColor clearColor];
        _gifsCollectionView.opaque = false;
        _gifsCollectionView.showsHorizontalScrollIndicator = false;
        _gifsCollectionView.showsVerticalScrollIndicator = false;
        _gifsCollectionView.alwaysBounceVertical = true;
        _gifsCollectionView.delaysContentTouches = false;
        _gifsCollectionView.contentInset = UIEdgeInsetsMake(45.0f + gifInset, 0.0f, gifInset, 0.0f);
        [_gifsCollectionView registerClass:[TGGifKeyboardCell class] forCellWithReuseIdentifier:@"TGGifKeyboardCell"];
        [self addSubview:_gifsCollectionView];
        
        UILongPressGestureRecognizer *tapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        tapRecognizer.minimumPressDuration = 0.25;
        [_collectionView addGestureRecognizer:tapRecognizer];
        
        UILongPressGestureRecognizer *gifTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gifTapGesture:)];
        gifTapRecognizer.minimumPressDuration = 0.3;
        [_gifsCollectionView addGestureRecognizer:gifTapRecognizer];
        
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        _panRecognizer.delegate = self;
        _panRecognizer.cancelsTouchesInView = false;
        [_collectionView addGestureRecognizer:_panRecognizer];
        
        __weak TGStickerKeyboardView *weakSelf = self;
        _tabPanel = [[TGStickerKeyboardTabPanel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 45.0f) style:style];
        _tabPanel.currentStickerPackIndexChanged = ^(NSUInteger index)
        {
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setGifsMode:false];
                [strongSelf scrollToSection:index];
            }
        };
        _tabPanel.navigateToGifs = ^{
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setGifsMode:true];
            }
        };
        [self addSubview:_tabPanel];
        
        CGFloat stripeHeight = TGIsRetina() ? 0.5f : 1.0f;
        _topStripe = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, stripeHeight)];
        _topStripe.backgroundColor = UIColorRGB(0xd8d8d8);
        if (style != TGStickerKeyboardViewDarkBlurredStyle)
            [self addSubview:_topStripe];
        
        SSignal *combinedSignal = [SSignal combineSignals:@[(iosMajorVersion() >= 8 && !TGIsPad() && _style == TGStickerKeyboardViewDefaultStyle) ? [TGRecentGifsSignal recentGifs] : [SSignal single:@[]], [TGStickersSignals stickerPacks]]];
        
        _stickerPacksDisposable = [[combinedSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *combinedResult)
        {
            NSArray *gifs = combinedResult[0];
            
            NSDictionary *dict = combinedResult[1];
            NSMutableArray *filteredPacks = [[NSMutableArray alloc] init];
            for (TGStickerPack *pack in dict[@"packs"])
            {
                if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]] && !pack.hidden)
                    [filteredPacks addObject:pack];
            }
            
            NSArray *sortedStickerPacks = filteredPacks;
            
            NSMutableArray *reversed = [[NSMutableArray alloc] init];
            for (id item in sortedStickerPacks)
            {
                [reversed addObject:item];
            }
            
            NSMutableArray *reversedGifs = [[NSMutableArray alloc] init];
            for (id item in [gifs reverseObjectEnumerator])
            {
                [reversedGifs addObject:item];
            }
            
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (![strongSelf->_stickerPacks isEqual:reversed]) {
                    [strongSelf setStickerPacks:reversed documentIdsUseCount:dict[@"documentIdsUseCount"]];
                }
                
                if (![strongSelf->_recentGifsOriginal isEqual:reversedGifs]) {
                    strongSelf->_recentGifsOriginal = reversedGifs;
                    
                    NSArray *sortedGifs = [reversedGifs sortedArrayUsingComparator:^NSComparisonResult(TGDocumentMediaAttachment *document1, TGDocumentMediaAttachment *document2) {
                        return document1.documentId < document2.documentId ? NSOrderedAscending : NSOrderedDescending;
                    }];
                    
                    if (!TGObjectCompare(sortedGifs, strongSelf->_recentGifsSorted)) {
                        strongSelf->_recentGifsSorted = sortedGifs;
                        [strongSelf setRecentGifs:reversedGifs];
                    }
                }
                
                [self updateCurrentSection];
            }
        }];
    }
    return self;
}

- (void)dealloc
{
    [_stickerPacksDisposable dispose];
    [_actionHandle reset];
}

- (void)sizeToFitForWidth:(CGFloat)width
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat maxSide = MAX(screenSize.width, screenSize.height);
    CGFloat height = 0.0f;
    
    if (ABS(maxSide - width) < FLT_EPSILON)
        height = 194.0f;
    else
        height = (_style == TGStickerKeyboardViewDarkBlurredStyle) ? 258.0f : 216.0f;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
    [self.superview.superview setNeedsLayout];    
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
    _collectionView.frame = CGRectMake(_gifsMode ? size.width : 0.0f, -preloadInset, size.width, size.height + preloadInset * 2.0f);
    _gifsCollectionView.frame = CGRectMake(_gifsMode ? 0.0f : -size.width, -gifInset, size.width, size.height + gifInset * 2.0f);
    [_collectionLayout invalidateLayout];
    
    [_gifsCollectionLayout invalidateLayout];
    
    CGFloat stripeHeight = TGIsRetina() ? 0.5f : 1.0f;
    _topStripe.frame = CGRectMake(0.0f, 0.0f, size.width, stripeHeight);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == _gifsCollectionView) {
        return 1;
    } else if (collectionView == _collectionView) {
        return 1 + _stickerPacks.count;
    } else {
        return 0;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _gifsCollectionView) {
        if (section == 0) {
            return _recentGifs.count;
        } else {
            return 0;
        }
    } else if (collectionView == _collectionView ) {
        if (section == 0) {
            return (NSInteger)_recentDocuments.count;
        } else {
            return ((TGStickerPack *)_stickerPacks[section - 1]).documents.count;
        }
    } else {
        return 0;
    }
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (collectionView == _gifsCollectionView) {
        return CGSizeMake(30.0f, 30.0f);
    } else {
        return CGSizeMake(62.0f, 62.0f);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView == _gifsCollectionView) {
        return UIEdgeInsetsZero;
    } else {
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
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    if (collectionView == _gifsCollectionView) {
        return 0.0f;
    } else {
        return 7.0f;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    if (collectionView == _gifsCollectionView) {
        return 0.0f;
    } else {
        return (collectionView.frame.size.width < 330.0f) ? 0.0f : 4.0f;
    }
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
        
        if (!_ignoreSetSection) {
            [self updateCurrentSection];
        }
    } else if (scrollView == _gifsCollectionView) {
        CGRect bounds = scrollView.bounds;
        bounds.origin.y += scrollView.contentInset.top;
        bounds.size.height -= scrollView.contentInset.top + scrollView.contentInset.bottom;
        for (TGGifKeyboardCell *cell in _gifsCollectionView.visibleCells) {
            if (CGRectIntersectsRect(bounds, cell.frame)) {
                [cell setEnableAnimation:_enableAnimation && _gifsMode];
            } else {
                [cell setEnableAnimation:false];
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)__unused indexPath {
    if (collectionView == _gifsCollectionView) {
        [(TGGifKeyboardCell *)cell setEnableAnimation:false];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        _ignoreSetSection = false;
        [self updateCurrentSection];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        _ignoreSetSection = false;
        [self updateCurrentSection];
    }
}

- (void)updateCurrentSection {
    if (_gifsMode) {
        [_tabPanel setCurrentGifsModeSelected];
    } else {
        NSArray *layoutAttributes = [_collectionLayout layoutAttributesForElementsInRect:CGRectMake(0.0f, _collectionView.contentOffset.y + 45.0f + preloadInset + 7.0f, _collectionView.frame.size.width, _collectionView.frame.size.height - 45.0f - preloadInset - 7.0f)];
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
    if (collectionView == _gifsCollectionView) {
        TGGifKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGGifKeyboardCell" forIndexPath:indexPath];
        if (!_ignoreGifCellContents) {
            [cell setDocument:_recentGifs[indexPath.item]];
        }
        return cell;
    } else {
        TGStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerCollectionViewCell" forIndexPath:indexPath];
        [cell setDocumentMedia:[self documentAtIndexPath:indexPath]];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_ignoreSelection) {
        return;
    }
    if (collectionView == _gifsCollectionView) {
        TGGifKeyboardCell *cell = (TGGifKeyboardCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell != nil && _gifSelected && ![_menuContainerView isShowingMenu]) {
            _gifSelected(_recentGifs[indexPath.row]);
        }
    } else {
        TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if ([cell isEnabled])
        {
            [cell setDisabledTimeout];
            
            TGDocumentMediaAttachment *document = [self documentAtIndexPath:indexPath];
            __block int maxUseCount = 1;
            [_documentIdsUseCount enumerateKeysAndObjectsUsingBlock:^(__unused id  _Nonnull key, NSNumber *nCount, __unused BOOL *stop) {
                maxUseCount = MAX(maxUseCount, [nCount intValue]);
            }];
            _documentIdsUseCount[@(document.documentId)] = @(maxUseCount + 1);
            [[SQueue concurrentDefaultQueue] dispatch:^{
                [TGStickersSignals addUseCountForDocumentId:document.documentId];
            }];
            if (_stickerSelected)
                _stickerSelected(document);
        }
    }
}

- (void)scrollToSection:(NSUInteger)section
{
    _ignoreSetSection = false;
    
    [_tabPanel setCurrentStickerPackIndex:section];
    
    if (section == 0)
    {
        if (_recentDocuments.count != 0)
        {
            _ignoreSetSection = true;
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:true];
        }
        else
        {
            _ignoreSetSection = true;
            [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:true];
        }
    }
    else
    {
        if (section == 1 && _recentDocuments.count == 0) {
            _ignoreSetSection = true;
            [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:true];
        } else if (((TGStickerPack *)_stickerPacks[section - 1]).documents.count != 0) {
            UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            
            CGFloat verticalOffset = attributes.frame.origin.y - [self collectionView:_collectionView layout:_collectionLayout minimumLineSpacingForSectionAtIndex:section];
            CGFloat effectiveInset = 0.0f;
            if (verticalOffset < _collectionView.contentOffset.y)
                effectiveInset = _collectionView.contentInset.top;
            else
                effectiveInset = preloadInset;
            
            CGFloat contentOffset = verticalOffset - effectiveInset;
            if (contentOffset > _collectionView.contentSize.height - _collectionView.frame.size.height + _collectionView.contentInset.bottom) {
                contentOffset = _collectionView.contentSize.height - _collectionView.frame.size.height + _collectionView.contentInset.bottom;
            }
            
            _ignoreSetSection = true;
            [_collectionView setContentOffset:CGPointMake(0.0f, contentOffset) animated:true];
        }
    }
}

- (void)setStickerPacks:(NSArray *)stickerPacks documentIdsUseCount:(NSDictionary *)documentIdsUseCount
{
    _stickerPacks = stickerPacks;
    _documentIdsUseCount = [[NSMutableDictionary alloc] initWithDictionary:documentIdsUseCount];
    
    [self updateRecentDocuments];
    
    [_collectionView reloadData];
    
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0 showGifs:_recentGifs.count != 0];
}

- (void)setRecentGifs:(NSArray *)recentGifs {
    _recentGifs = recentGifs;
    
    NSMutableArray *cachedContents = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in [_gifsCollectionView indexPathsForVisibleItems]) {
        TGGifKeyboardCell *cell = (TGGifKeyboardCell *)[_gifsCollectionView cellForItemAtIndexPath:indexPath];
        if (cell != nil) {
            TGGifKeyboardCellContents *contents = [cell _takeContents];
            if (contents != nil && contents.document != nil) {
                [cachedContents addObject:contents];
            }
        }
    }
    
    _ignoreGifCellContents = true;
    
    [_gifsCollectionView reloadData];
    [_gifsCollectionView layoutSubviews];
    
    for (NSIndexPath *indexPath in [_gifsCollectionView indexPathsForVisibleItems]) {
        TGGifKeyboardCell *cell = (TGGifKeyboardCell *)[_gifsCollectionView cellForItemAtIndexPath:indexPath];
        if (cell != nil) {
            TGDocumentMediaAttachment *document = _recentGifs[indexPath.item];
            
            TGGifKeyboardCellContents *contents = nil;
            NSInteger index = -1;
            for (TGGifKeyboardCellContents *cached in cachedContents) {
                index++;
                if ([cached.document isEqual:document]) {
                    contents = cached;
                    [cachedContents removeObjectAtIndex:index];
                    break;
                }
            }
            
            if (contents != nil) {
                [cell _putContents:contents];
            } else {
                [cell setDocument:document];
            }
        }
    }
    
    _ignoreGifCellContents = false;
    
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0 showGifs:_recentGifs.count != 0];
    
    [self scrollViewDidScroll:_gifsCollectionView];
    
    if (_recentGifs.count == 0 && _gifsMode) {
        [self setGifsMode:false];
    }
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
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0 showGifs:_recentGifs.count != 0];
    
    if (!TGObjectCompare(_recentGifsOriginal, _recentGifs)) {
        [self setRecentGifs:_recentGifsOriginal];
    }
    
    [self updateCurrentSection];
    
    if (_gifTabActive) {
        _gifTabActive(_gifsMode);
    }
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

- (void)gifTapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [recognizer locationInView:_gifsCollectionView];
        
        for (NSIndexPath *indexPath in [_gifsCollectionView indexPathsForVisibleItems])
        {
            TGGifKeyboardCell *cell = (TGGifKeyboardCell *)[_gifsCollectionView cellForItemAtIndexPath:indexPath];
            if (CGRectContainsPoint(cell.frame, point))
            {
                if (_menuContainerView == nil) {
                    _menuContainerView = [[TGMenuContainerView alloc] initWithFrame:self.bounds];
                    _menuContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                }
                
                if (_menuContainerView.superview == nil) {
                    [self addSubview:_menuContainerView];
                }
                
                NSMutableArray *actions = [[NSMutableArray alloc] init];
                [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Common.Delete"), @"title", @"delete", @"action", nil]];
                
                [_menuContainerView.menuView setUserInfo:@{@"documentId": @(((TGDocumentMediaAttachment *)_recentGifs[indexPath.row]).documentId)}];
                [_menuContainerView.menuView setButtonsAndActions:actions watcherHandle:_actionHandle];
                [_menuContainerView.menuView sizeToFit];
                [_menuContainerView showMenuFromRect:[_menuContainerView convertRect:CGRectMake(cell.bounds.size.width / 2.0f, cell.bounds.size.height / 2.0f, 1.0f, 1.0f) fromView:cell]];
                
                break;
            }
        }
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
    if (_stickerPreviewWindow != nil && recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint point = [recognizer locationInView:_collectionView];
        CGPoint relativePoint = [recognizer locationInView:self];
        if (CGRectContainsPoint(CGRectOffset(_collectionView.frame, 0, preloadInset), relativePoint))
        {
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
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == _panRecognizer || otherGestureRecognizer == _panRecognizer)
        return true;
    return false;
}

- (void)setGifsMode:(bool)gifsMode {
    if (_gifsMode != gifsMode) {
        _gifsMode = gifsMode;
        
        if (_gifTabActive) {
            _gifTabActive(gifsMode);
        }
        
        CGSize size = self.bounds.size;
        
        [UIView animateWithDuration:0.2 animations:^{
            _collectionView.frame = CGRectMake(_gifsMode ? size.width : 0.0f, -preloadInset, size.width, size.height + preloadInset * 2.0f);
            _gifsCollectionView.frame = CGRectMake(_gifsMode ? 0.0f : -size.width, -gifInset, size.width, size.height + gifInset * 2.0f);
        }];
        
        [self scrollViewDidScroll:_gifsCollectionView];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(TGGifKeyboardBalancedLayout *)__unused collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _gifsCollectionView) {
        TGDocumentMediaAttachment *document = _recentGifs[indexPath.row];
        for (id attribute in document.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]]) {
                CGSize fittedSize = TGFitSize(((TGDocumentAttributeImageSize *)attribute).size, CGSizeMake(256.0f, _gifsCollectionLayout.preferredRowSize));
                return fittedSize;
            } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                CGSize fittedSize = TGFitSize(((TGDocumentAttributeVideo *)attribute).size, CGSizeMake(256.0f, _gifsCollectionLayout.preferredRowSize));
                return fittedSize;
            }
        }
        
        CGSize size = CGSizeMake(32.0f, 32.0f);
        [document.thumbnailInfo imageUrlForLargestSize:&size];
        return size;
    }
    
    return CGSizeMake(32.0f, 32.0f);
}

- (void)setEnableAnimation:(bool)enableAnimation {
    if (_enableAnimation != enableAnimation) {
        _enableAnimation = enableAnimation;
        
        [self scrollViewDidScroll:_gifsCollectionView];
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options {
    if ([action isEqualToString:@"menuAction"]) {
        NSString *menuAction = options[@"action"];
        if ([menuAction isEqualToString:@"delete"]) {
            [TGRecentGifsSignal removeRecentGifByDocumentId:[options[@"userInfo"][@"documentId"] longLongValue]];
        }
    } else if ([action isEqualToString:@"menuWillHide"]) {
        _ignoreSelection = true;
        TGDispatchAfter(0.2, dispatch_get_main_queue(), ^{
            _ignoreSelection = false;
        });
    }
}

@end
