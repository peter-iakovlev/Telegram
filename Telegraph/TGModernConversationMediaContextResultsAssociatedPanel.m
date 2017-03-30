#import "TGModernConversationMediaContextResultsAssociatedPanel.h"

#import "TGBotContextResults.h"
#import "TGImageUtils.h"

#import "TGAnimatedMediaContextResultCell.h"

#import "TGBotContextExternalResult.h"
#import "TGBotContextMediaResult.h"

#import "TGImageUtils.h"

#import "TGBotContextResultAttachment.h"

#import "TGExternalGifSearchResult.h"
#import "TGExternalImageSearchResult.h"

#import "TGBotSignals.h"

#import "TGItemPreviewController.h"
#import "TGItemMenuSheetPreviewView.h"
#import "TGMenuSheetButtonItemView.h"
#import "TGPreviewMenu.h"

#import "TGModernConversationGenericContextResultsAssociatedPanelSwitchPm.h"

@interface TGModernConversationMediaContextResultsAssociatedPanel () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    TGBotContextResults *_results;
    
    UIView *_backgroundView;
    UIView *_effectView;
    
    UIView *_stripeView;
    UIView *_separatorView;
    
    UIView *_bottomView;
    
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    
    bool _doNotBindContent;
    
    SMetaDisposable *_loadMoreDisposable;
    bool _loadingMore;
    CGFloat _preferredHeight;
    bool _stickers;
    
    TGItemPreviewHandle *_previewHandle;
    
    TGModernConversationGenericContextResultsAssociatedPanelSwitchPm *_switchPm;
}

@end

@implementation TGModernConversationMediaContextResultsAssociatedPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _loadMoreDisposable = [[SMetaDisposable alloc] init];
        
        UIColor *backgroundColor = [UIColor whiteColor];
        UIColor *bottomColor = UIColorRGBA(0xfafafa, 0.98f);
        UIColor *separatorColor = UIColorRGB(0xc5c7d0);
        UIColor *cellSeparatorColor = UIColorRGB(0xdbdbdb);
        
        if (self.style == TGModernConversationAssociatedInputPanelDarkStyle)
        {
            backgroundColor = UIColorRGB(0x171717);
            bottomColor = backgroundColor;
            separatorColor = UIColorRGB(0x292929);
            cellSeparatorColor = separatorColor;
        }
        else if (self.style == TGModernConversationAssociatedInputPanelDarkBlurredStyle)
        {
            backgroundColor = [UIColor clearColor];
            bottomColor = [UIColor clearColor];
            separatorColor = UIColorRGBA(0xb2b2b2, 0.7f);
            cellSeparatorColor = separatorColor;
            
            CGFloat backgroundAlpha = 0.8f;
            if (iosMajorVersion() >= 8)
            {
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
                blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                blurEffectView.frame = self.bounds;
                [self addSubview:blurEffectView];
                _effectView = blurEffectView;
                
                backgroundAlpha = 0.4f;
            }
            
            _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
            _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:backgroundAlpha];
            [self addSubview:_backgroundView];
        }
        
        self.backgroundColor = backgroundColor;
        
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = bottomColor;
        [self addSubview:_bottomView];
        
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.opaque = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.alwaysBounceVertical = false;
        _collectionView.alwaysBounceHorizontal = true;
        _collectionView.delaysContentTouches = true;
        [_collectionView registerClass:[TGAnimatedMediaContextResultCell class] forCellWithReuseIdentifier:@"TGAnimatedMediaContextResultCell"];
        [self addSubview:_collectionView];
        
        _stripeView = [[UIView alloc] init];
        _stripeView.backgroundColor = separatorColor;
        [self addSubview:_stripeView];
        
        if (self.style != TGModernConversationAssociatedInputPanelDarkBlurredStyle)
        {
            _separatorView = [[UIView alloc] init];
            _separatorView.backgroundColor = separatorColor;
            [self addSubview:_separatorView];
        }
        
        _preferredHeight = 105.0f;
        
        __weak TGModernConversationMediaContextResultsAssociatedPanel *weakSelf = self;
        _previewHandle = [TGPreviewMenu setupPreviewControllerForView:_collectionView configurator:^TGItemPreviewController *(CGPoint gestureLocation)
        {
            __strong TGModernConversationMediaContextResultsAssociatedPanel *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            NSIndexPath *indexPath = [strongSelf->_collectionView indexPathForItemAtPoint:gestureLocation];
            if (indexPath == nil)
                return nil;
            
            TGBotContextResult *result = strongSelf->_results.results[indexPath.item];
            return [strongSelf presentPreviewForResultIfAvailable:result immediately:false];
        }];
    }
    return self;
}

- (void)dealloc {
    [_loadMoreDisposable dispose];
}

- (TGItemPreviewController *)presentPreviewForResultIfAvailable:(TGBotContextResult *)result immediately:(bool)immediately
{
    if (self.onResultPreview != nil)
        self.onResultPreview();
    
    __weak TGModernConversationMediaContextResultsAssociatedPanel *weakSelf = self;
    return [TGPreviewMenu presentInParentController:self.controller expandImmediately:immediately result:result results:_results sendAction:^(TGBotContextResult *result)
    {
        __strong TGModernConversationMediaContextResultsAssociatedPanel *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf.resultSelected != nil)
            strongSelf.resultSelected(strongSelf->_results, result);
    } sourcePointForItem:^CGPoint(__unused id item)
    {
        __strong TGModernConversationMediaContextResultsAssociatedPanel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGPointZero;
        
        for (TGAnimatedMediaContextResultCell *cell in strongSelf->_collectionView.visibleCells)
        {
            if ([cell.result isEqual:result])
            {
                NSIndexPath *indexPath = [strongSelf->_collectionView indexPathForCell:cell];
                if (indexPath != nil)
                    return [strongSelf->_collectionView convertPoint:cell.center toView:nil];
            }
        }
        
        return CGPointZero;
    } sourceView:nil sourceRect:nil];
}

- (CGFloat)preferredHeight {
    return _preferredHeight;
}

- (bool)displayForTextEntryOnly {
    return true;
}

- (void)setResults:(TGBotContextResults *)results reload:(bool)reload {
    CGFloat preferredHeight = 105.0f;
    
    _results = results;
    
    bool smallOnly = true;
    bool stickersOnly = true;
    for (TGBotContextResult *result in results.results) {
        if (![result.type isEqualToString:@"sticker"] && ![result.type isEqualToString:@"article"]) {
            smallOnly = false;
        }
        if (![result.type isEqualToString:@"sticker"]) {
            stickersOnly = false;
        }
    }
    
    if (smallOnly) {
        preferredHeight = 73.0f;
    }
    
    if (results.switchPm != nil) {
        if (_switchPm == nil) {
            _switchPm = [[TGModernConversationGenericContextResultsAssociatedPanelSwitchPm alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 32.0f)];
            _switchPm.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            __weak TGModernConversationMediaContextResultsAssociatedPanel *weakSelf = self;
            _switchPm.pressed = ^{
                __strong TGModernConversationMediaContextResultsAssociatedPanel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (strongSelf->_activateSwitchPm) {
                        strongSelf->_activateSwitchPm(results.switchPm.startParam);
                    }
                }
            };
            [self addSubview:_switchPm];
        }
        _switchPm.title = results.switchPm.text;
    } else {
        [_switchPm removeFromSuperview];
        _switchPm = nil;
    }
    
    preferredHeight += _switchPm.frame.size.height;
    
    _stickers = stickersOnly;
    
    if (ABS(_preferredHeight - preferredHeight) > FLT_EPSILON) {
        _preferredHeight = preferredHeight;
        self.preferredHeightUpdated();
        [self setNeedsLayout];
    }
    
    NSMutableDictionary *cachedContents = [[NSMutableDictionary alloc] init];
    for (TGAnimatedMediaContextResultCell *cell in [_collectionView visibleCells]) {
        TGAnimatedMediaContextResultCellContents *content = [cell _takeContent];
        if (content != nil && content.result.resultId != nil) {
            cachedContents[content.result.resultId] = content;
        }
    }
    
    _doNotBindContent = true;
    
    [_collectionView reloadData];
    [_collectionView layoutSubviews];
    
    for (NSIndexPath *indexPath in [_collectionView indexPathsForVisibleItems]) {
        TGAnimatedMediaContextResultCell *cell = (TGAnimatedMediaContextResultCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        TGBotContextResult *result = _results.results[indexPath.row];
        TGAnimatedMediaContextResultCellContents *content = cachedContents[result.resultId];
        if (content != nil) {
            [cell _putContent:content];
            [cachedContents removeObjectForKey:result.resultId];
        }
    }
    
    [self bindCellContents];
    
    _doNotBindContent = false;
    
    if (reload) {
        [_collectionView setContentOffset:CGPointZero animated:false];
    }
    
    [self scrollViewDidScroll:_collectionView];
}

- (void)bindCellContents {
    for (NSIndexPath *indexPath in [_collectionView indexPathsForVisibleItems]) {
        TGAnimatedMediaContextResultCell *cell = (TGAnimatedMediaContextResultCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        if (![cell hasContent]) {
            [cell setResult:_results.results[indexPath.row]];
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return _results.results.count;
    }
    return 0;
}

- (CGSize)contentSizeForResult:(id)result {
    if ([result isKindOfClass:[TGBotContextExternalResult class]]) {
        TGBotContextExternalResult *concreteResult = result;
        return concreteResult.size;
    } else if ([result isKindOfClass:[TGBotContextMediaResult class]]) {
        TGBotContextMediaResult *concreteResult = result;
        if (concreteResult.photo != nil) {
            CGSize largestSize = CGSizeZero;
            if ([concreteResult.photo.imageInfo imageUrlForLargestSize:&largestSize] != nil) {
                return largestSize;
            }
        }
        if (concreteResult.document != nil) {
            return [concreteResult.document pictureSize];
        }
    }
    return CGSizeMake(32.0f, 32.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize preferredSize = [self contentSizeForResult:_results.results[indexPath.row]];
    UIEdgeInsets insets = [self collectionView:collectionView layout:_collectionLayout insetForSectionAtIndex:indexPath.section];
    CGSize availableSize = collectionView.frame.size;
    availableSize.width -= insets.left + insets.right;
    availableSize.height -= insets.top + insets.bottom;
    availableSize.width = MAX(1.0f, availableSize.width);
    availableSize.height = MAX(1.0f, availableSize.height);
    return TGScaleToFill(TGFitSize(preferredSize, availableSize), CGSizeMake(10.0f, availableSize.height));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section {
    if (_stickers) {
        return UIEdgeInsetsMake(4.0f, 12.0f, 4.0f, 12.0f);
    }
    return UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f);
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section {
    if (_stickers) {
        return 12.0f;
    }
    return 4.0f;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section {
    return 4.0f;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TGAnimatedMediaContextResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGAnimatedMediaContextResultCell" forIndexPath:indexPath];
    if (!_doNotBindContent) {
        [cell setResult:_results.results[indexPath.row]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TGBotContextResult *result = _results.results[indexPath.row];
    
    if ([self presentPreviewForResultIfAvailable:result immediately:true] == nil)
    {
        if (_resultSelected != nil)
            _resultSelected(_results, result);
    }
    
    [_collectionView deselectItemAtIndexPath:indexPath animated:true];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        if (!_loadingMore && _results.nextOffset.length != 0 && scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.size.width * 2.0f) {
            _loadingMore = true;
            TGBotContextResultsSwitchPm *switchPm = _results.switchPm;
            __weak TGModernConversationMediaContextResultsAssociatedPanel *weakSelf = self;
            [_loadMoreDisposable setDisposable:[[[TGBotSignals botContextResultForUserId:_results.userId peerId:_results.peerId accessHash:_results.accessHash query:_results.query geoPoint:nil offset:_results.nextOffset] deliverOn:[SQueue mainQueue]] startWithNext:^(TGBotContextResults *nextResults) {
                __strong TGModernConversationMediaContextResultsAssociatedPanel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    TGBotContextResults *mergedResults = [[TGBotContextResults alloc] initWithUserId:strongSelf->_results.userId peerId:strongSelf->_results.peerId accessHash:strongSelf->_results.accessHash isMedia:strongSelf->_results.isMedia query:strongSelf->_results.query nextOffset:nextResults.nextOffset results:[strongSelf->_results.results arrayByAddingObjectsFromArray:nextResults.results] switchPm:switchPm];
                    strongSelf->_loadingMore = false;
                    [strongSelf setResults:mergedResults reload:false];
                }
            }]];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _backgroundView.frame = CGRectMake(-1000, 0, self.frame.size.width + 2000, self.frame.size.height);
    _effectView.frame = CGRectMake(-1000, 0, self.frame.size.width + 2000, self.frame.size.height);
    
    CGFloat separatorHeight = TGScreenPixel;
    _stripeView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, separatorHeight);
    _separatorView.frame = CGRectMake(0.0f, self.frame.size.height - separatorHeight, self.frame.size.width, separatorHeight);
    
    _collectionView.frame = CGRectMake(0.0f, separatorHeight + _switchPm.frame.size.height, self.frame.size.width, self.frame.size.height - separatorHeight - _switchPm.frame.size.height);
    
    _bottomView.frame = CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, 4.0f);
}

- (void)selectPreviousItem
{
    if ([self collectionView:_collectionView numberOfItemsInSection:0] == 0)
        return;
    
    NSIndexPath *newIndexPath = _collectionView.indexPathsForSelectedItems.firstObject;
    
    if (newIndexPath == nil)
        newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    else if (newIndexPath.row > 0)
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row - 1 inSection:0];
    
    if (_collectionView.indexPathsForSelectedItems.firstObject != nil)
        [_collectionView deselectItemAtIndexPath:_collectionView.indexPathsForSelectedItems.firstObject animated:false];
    
    if (newIndexPath != nil)
        [_collectionView selectItemAtIndexPath:newIndexPath animated:false scrollPosition:UICollectionViewScrollPositionRight];
}

- (void)selectNextItem
{
    if ([self collectionView:_collectionView numberOfItemsInSection:0] == 0)
        return;
    
    NSIndexPath *newIndexPath = _collectionView.indexPathsForSelectedItems.firstObject;
    
    if (newIndexPath == nil)
        newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    else if (newIndexPath.row < [self collectionView:_collectionView numberOfItemsInSection:newIndexPath.section] - 1)
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:0];
    
    if (_collectionView.indexPathsForSelectedItems.firstObject != nil)
        [_collectionView deselectItemAtIndexPath:_collectionView.indexPathsForSelectedItems.firstObject animated:false];
    
    if (newIndexPath != nil)
        [_collectionView selectItemAtIndexPath:newIndexPath animated:false scrollPosition:UICollectionViewScrollPositionRight];
}

- (void)commitSelectedItem
{
    if ([self collectionView:_collectionView numberOfItemsInSection:0] == 0)
        return;
    
    NSIndexPath *selectedIndexPath = _collectionView.indexPathsForSelectedItems.firstObject;
    if (selectedIndexPath == nil)
        selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self collectionView:_collectionView didSelectItemAtIndexPath:selectedIndexPath];
}

@end
