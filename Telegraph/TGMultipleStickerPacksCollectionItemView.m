#import "TGMultipleStickerPacksCollectionItemView.h"

#import <SSignalKit/SSignalKit.h>

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGTimerTarget.h"

#import "TGMultipleStickerPacksCell.h"

#import "TGStickerPack.h"
#import "TGDocumentMediaAttachment.h"

#import "TGMenuSheetController.h"
#import "TGNavigationController.h"

#import "TGMenuView.h"

#import "TGMenuSheetCollectionView.h"
#import "TGScrollIndicatorView.h"

#import "TGItemPreviewController.h"
#import "TGStickerItemPreviewView.h"

static const CGFloat TGStickersCollectionItemHeight = 125.0f;
static const UIEdgeInsets TGStickersCollecitonInsets = { 0.0f, 0.0f, 0.0f, 0.0f };
static const UIEdgeInsets TGStickersCollecitonSectionInsets = { 4.0f, 0.0f, 4.0f, 0.0f };
static const CGFloat TGStickersCollectionLoadingHeight = 145.0f;
static const CGFloat TGStickersCollectionLoadingLandscapeHeight = 145.0f;
static const CGFloat TGStickersCollectionRegularSizeClassHeight = 344.0f;
static const NSInteger TGStickersCollectionNumberOfCollapsedRows = 3;
static const NSInteger TGStickersCollectionNumberOfTimerTicks = 10;
static const CGFloat TGStickersCollectionErrorLabelMargin = 23.0f;

@interface TGMultipleStickerPacksCollectionView  : TGMenuSheetCollectionView

@end

@interface TGMultipleStickerPacksCollectionItemView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, ASWatcher>
{
    TGMultipleStickerPacksCollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionViewLayout;
    TGScrollIndicatorView *_scrollIndicator;
    
    UIActivityIndicatorView *_activityIndicator;
    
    UILabel *_errorLabel;
    
    UIPanGestureRecognizer *_panGestureRecognizer;
    
    TGMenuContainerView *_menuContainerView;
    NSInteger _selectedSticker;
    
    bool _transitionedIn;
    CGFloat _expandOffset;
    CGFloat _expandedHeight;
    CGFloat _collapsedHeight;
    
    CGFloat _smallActivationHeight;
    bool _smallActivated;
    
    __weak TGItemPreviewController *_previewController;
    
    bool _appeared;
    NSTimer *_altTimer;
    NSInteger _altTimerTick;
    
    CGFloat _itemViewWidth;
    
    bool _failed;
    
    NSArray<TGStickerPack *> *_stickerPacks;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGMultipleStickerPacksCollectionItemView

- (instancetype)init
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        _selectedSticker = NSNotFound;
        _altTimerTick = -1;
        
        self.clipsToBounds = true;
        
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionViewLayout.minimumInteritemSpacing = 0.0f;
        _collectionViewLayout.minimumLineSpacing = 0.0f;
        
        _collectionView = [[TGMultipleStickerPacksCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
        _collectionView.allowSimultaneousPan = true;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.bounces = false;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.scrollsToTop = false;
        [_collectionView registerClass:[TGMultipleStickerPacksCell class] forCellWithReuseIdentifier:@"TGMultipleStickerPacksCell"];
        [self addSubview:_collectionView];
        
        _scrollIndicator = [[TGScrollIndicatorView alloc] init];
        [_scrollIndicator setHidden:true animated:false];
        [_collectionView addSubview:_scrollIndicator];
        
        [self.menuController.panGestureRecognizer requireGestureRecognizerToFail:_collectionView.panGestureRecognizer];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityIndicator];
        
        _errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _errorLabel.backgroundColor = [UIColor whiteColor];
        _errorLabel.font = TGSystemFontOfSize(16);
        _errorLabel.numberOfLines = 0;
        _errorLabel.hidden = true;
        _errorLabel.text = TGLocalized(@"StickerPack.ErrorNotFound");
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        _errorLabel.textColor = [UIColor blackColor];
        [self addSubview:_errorLabel];
        
        CGSize screenSize = TGScreenSize();
        _smallActivationHeight = screenSize.width;
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_panGestureRecognizer];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    
    [_menuContainerView removeFromSuperview];
    _menuContainerView = nil;
    
    [_altTimer invalidate];
    _altTimer = nil;
}

#pragma mark -

- (void)setStickerPacks:(NSArray<TGStickerPack *> *)stickerPacks animated:(bool)animated {
    _stickerPacks = stickerPacks;
    
    [_activityIndicator stopAnimating];
    _activityIndicator.hidden = true;
    
    [self layoutSubviews];
    [_collectionView reloadData];
    
    void (^performMenuRelayout)(void (^)(void)) = ^(void (^animation)(void))
    {
        UIViewAnimationOptions options = UIViewAnimationOptionAllowAnimatedContent;
        if (iosMajorVersion() >= 7)
            options = options | (7 << 16);
        
        if (!animated)
            [self requestMenuLayoutUpdate];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:options animations:^
         {
             if (animated)
                 [self requestMenuLayoutUpdate];
             
             if (animation != nil)
                 animation();
         } completion:^(__unused BOOL finished)
         {
             if (_appeared && _altTimer == nil)
                 [self altTimerTick];
         }];
    };
    
    if (!_transitionedIn)
    {
        _transitionedIn = true;
        if (iosMajorVersion() < 8 || self.sizeClass == UIUserInterfaceSizeClassRegular)
        {
            performMenuRelayout(nil);
            return;
        }
        
        [_collectionView layoutSubviews];
        
        CGRect targetFrame = _collectionView.frame;
        _collectionView.frame = CGRectOffset(_collectionView.frame, 0, 35);
        performMenuRelayout(^{
            _collectionView.frame = targetFrame;
        });
        
        //for (TGStickersCollectionCell *cell in _collectionView.visibleCells)
        //    [cell performTransitionIn];
    }
    else
    {
        performMenuRelayout(nil);
    }
}

- (void)setFailed
{
    _failed = true;
    _errorLabel.hidden = false;
    _collectionView.userInteractionEnabled = false;
    [_activityIndicator stopAnimating];
    [self _updateHeightAnimated:true];
}

- (void)altTimerTick
{
    if (true)
        return;
    
    [_altTimer invalidate];
    _altTimer = nil;
    
    _altTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(altTimerTick) interval:2.5 repeat:false];
    _altTimerTick = (_altTimerTick + 1) % TGStickersCollectionNumberOfTimerTicks;
    
    //for (TGStickersCollectionCell *cell in _collectionView.visibleCells)
    //    [cell setAltTick:_altTimerTick];
}

#pragma mark -

- (void)menuView:(TGMenuSheetView *)__unused menuView willAppearAnimated:(bool)__unused animated
{
    if (_stickerPacks == nil) {
        [_activityIndicator startAnimating];
    } else {
        [_activityIndicator stopAnimating];
        _activityIndicator.hidden = true;
    }
}

- (void)menuView:(TGMenuSheetView *)__unused smenuView didAppearAnimated:(bool)__unused animated
{
    _appeared = true;
    
    if (_altTimer == nil && _stickerPacks != nil)
        [self altTimerTick];
}

- (void)menuView:(TGMenuSheetView *)__unused menuView willDisappearAnimated:(bool)__unused animated
{
    if (_menuContainerView == nil)
        return;
    
    [_menuContainerView removeFromSuperview];
}

- (void)menuView:(TGMenuSheetView *)__unused menuView didDisappearAnimated:(bool)__unused animated
{
    [_altTimer invalidate];
}

#pragma mark -

- (void)handlePan:(UIPanGestureRecognizer *)__unused gestureRecognizer
{
    if (_previewController == nil)
        return;
    
    /*if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        
        TGStickersCollectionCell *highlightedCell = nil;
        TGDocumentMediaAttachment *document = [self stickerAtPoint:[gestureRecognizer locationInView:_collectionView] stickerCell:&highlightedCell];
        if (document != nil)
        {
            [previewView setSticker:document associations:_stickerPack.stickerAssociations];
            
            for (TGStickersCollectionCell *cell in _collectionView.visibleCells)
                [cell setHighlighted:(highlightedCell == cell) animated:true];
        }
    }*/
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)__unused gestureRecognizer
{
    /*if (gestureRecognizer == _panGestureRecognizer)
        return (_longPressGestureRecognizer.state == UIGestureRecognizerStateBegan || _longPressGestureRecognizer.state == UIGestureRecognizerStateChanged);*/
    
    return true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    /*if ((gestureRecognizer == _longPressGestureRecognizer && otherGestureRecognizer == _panGestureRecognizer) || (gestureRecognizer == _panGestureRecognizer && otherGestureRecognizer == _longPressGestureRecognizer))
        return true;*/
    
    return true;
}

#pragma mark -

- (bool)handlesPan
{
    return true;
}

- (bool)passPanOffset:(CGFloat)offset
{
    if (_previewController != nil)
        return false;
    
    if (!_collectionView.scrollEnabled || _failed)
        return true;
    
    CGFloat currentHeight = _collapsedHeight + _expandOffset;
    CGFloat bottomContentOffset = (_collectionView.contentSize.height - _collectionView.frame.size.height);
    
    if (bottomContentOffset > 0 && _collectionView.contentOffset.y > bottomContentOffset)
        return false;
    
    bool atTop = (_collectionView.contentOffset.y < FLT_EPSILON);
    bool atBottom = (_collectionView.contentOffset.y - bottomContentOffset > -FLT_EPSILON);
    bool expanded = fabs(currentHeight - _expandedHeight) < FLT_EPSILON;
    
    if (atTop && (offset > FLT_EPSILON || expanded))
        return true;
    
    if (atBottom && expanded && offset < 0)
        return true;
    
    return false;
}

#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath {
    return CGSizeMake(collectionView.bounds.size.width, TGStickersCollectionItemHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGMultipleStickerPacksCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGMultipleStickerPacksCell" forIndexPath:indexPath];
    //[cell setAltTick:_altTimerTick];
    //[cell setSticker:_stickerPack.documents[indexPath.row] associations:_stickerPack.stickerAssociations];
    [cell setStickerPack:_stickerPacks[indexPath.row]];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return _stickerPacks.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    return UIEdgeInsetsMake(4.0f, 0.0f, 4.0f, 0.0f);
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_previewPack) {
        _previewPack(_stickerPacks[indexPath.item], nil);
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{

}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentHeight = _collapsedHeight + _expandOffset;
    CGFloat bottomContentOffset = (scrollView.contentSize.height - scrollView.frame.size.height);
    
    //[_scrollIndicator updateScrollViewDidScroll];
    
    bool atTop = (scrollView.contentOffset.y < FLT_EPSILON);
    bool atBottom = (scrollView.contentOffset.y - bottomContentOffset > -FLT_EPSILON);
    bool expanded = fabs(currentHeight - _expandedHeight) < FLT_EPSILON;
    
    if (atTop || (atBottom && expanded))
        [_scrollIndicator setHidden:true animated:true];
    else if (scrollView.contentOffset.y > FLT_EPSILON && expanded)
        [_scrollIndicator setHidden:false animated:true];
    
    if ((atTop || (atBottom && expanded)) && self.sizeClass == UIUserInterfaceSizeClassCompact)
    {
        if (scrollView.isTracking && scrollView.bounces && (scrollView.contentOffset.y - bottomContentOffset) < 20.0f)
        {
            scrollView.bounces = false;
            if (atTop)
                scrollView.contentOffset = CGPointMake(0, 0);
            else if (atBottom)
                scrollView.contentOffset = CGPointMake(0, bottomContentOffset);
        }
    }
    else
    {
        scrollView.bounces = true;
    }
    
    if (currentHeight < _expandedHeight && self.sizeClass == UIUserInterfaceSizeClassCompact)
    {
        if (scrollView.contentOffset.y > FLT_EPSILON)
        {
            _expandOffset = MIN(_expandedHeight - _collapsedHeight, _expandOffset + scrollView.contentOffset.y);
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
            if (fabs(_collapsedHeight + _expandOffset - _expandedHeight) <= 2.0f)
                _expandOffset = _expandedHeight - _collapsedHeight;
            
            [self requestMenuLayoutUpdate];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat currentHeight = _collapsedHeight + _expandOffset;
    CGFloat bottomContentOffset = (scrollView.contentSize.height - scrollView.frame.size.height);
    
    bool atTop = (scrollView.contentOffset.y < FLT_EPSILON);
    bool atBottom = (scrollView.contentOffset.y - bottomContentOffset > -FLT_EPSILON);
    bool expanded = fabs(currentHeight - _expandedHeight) < FLT_EPSILON;
    
    if ((atTop || (atBottom && expanded)) && scrollView.bounces && !scrollView.isTracking && self.sizeClass == UIUserInterfaceSizeClassCompact)
        scrollView.bounces = false;
    
    [_scrollIndicator updateScrollViewDidEndScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)__unused scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [_scrollIndicator updateScrollViewDidEndScrolling];
}

#pragma mark -

- (bool)requiresDivider
{
    return true;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width screenHeight:(CGFloat)screenHeight
{
    [_menuContainerView removeFromSuperview];
    _menuContainerView = nil;
    
    if (width > FLT_EPSILON)
        _itemViewWidth = width;
    
    if (self.sizeClass == UIUserInterfaceSizeClassRegular)
    {
        CGFloat height = TGStickersCollectionRegularSizeClassHeight;
        _expandedHeight = height;
        _collapsedHeight = height;
        return height;
    }
    
    _smallActivated = fabs(screenHeight - _smallActivationHeight) < FLT_EPSILON;
    
    if (_stickerPacks == nil)
    {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:_errorLabel.text attributes:@{ NSFontAttributeName: _errorLabel.font }];
        CGSize textSize = [string boundingRectWithSize:CGSizeMake(width - 18.0f * 2.0f, screenHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        _errorLabel.frame = CGRectMake(_errorLabel.frame.origin.x, _errorLabel.frame.origin.y, ceil(textSize.width), ceil(textSize.height));
        
        if (_failed)
            return TGStickersCollectionErrorLabelMargin + TGStickersCollectionErrorLabelMargin + _errorLabel.frame.size.height;
        else
            return TGStickersCollectionLoadingHeight;
    }
    
    NSInteger rows = _stickerPacks.count;
    
    CGFloat collapsedHeight = rows * (TGStickersCollectionItemHeight) + TGStickersCollecitonSectionInsets.top + TGStickersCollecitonSectionInsets.bottom;
    
    CGFloat height = 0.0f;
    if (_smallActivated)
    {
        CGFloat maxHeight = screenHeight - 152.0f;
        height = MIN(maxHeight, collapsedHeight);
        
        _collectionView.contentOffset = CGPointZero;
        _collectionView.scrollEnabled = (collapsedHeight > maxHeight);
    }
    else
    {
        CGFloat maxExpandedHeight = TGStickersCollecitonSectionInsets.top + (TGStickersCollectionItemHeight + _collectionViewLayout.minimumLineSpacing) * 4.5f;
        CGFloat expandedHeight = TGStickersCollecitonSectionInsets.top + rows * (TGStickersCollectionItemHeight + _collectionViewLayout.minimumLineSpacing) + TGStickersCollecitonSectionInsets.bottom;
        
        CGFloat buttonsHeight = 0.0f;
        maxExpandedHeight = MIN(maxExpandedHeight, screenHeight - 75.0f - buttonsHeight - self.menuController.statusBarHeight);
        
        CGFloat maxCollapsedHeight = TGStickersCollecitonSectionInsets.top + (TGStickersCollectionItemHeight + _collectionViewLayout.minimumLineSpacing) * ((CGFloat)TGStickersCollectionNumberOfCollapsedRows - 0.5f) + 20.0f;
        
        if (rows == TGStickersCollectionNumberOfCollapsedRows)
        {
            maxCollapsedHeight = collapsedHeight;
            expandedHeight = maxCollapsedHeight;
        }
        else if (fabs(maxCollapsedHeight - maxExpandedHeight) < 4.0f)
        {
            maxCollapsedHeight = maxExpandedHeight;
        }
        
        _expandedHeight = MIN(expandedHeight, maxExpandedHeight);
        _collapsedHeight = MIN(collapsedHeight, maxCollapsedHeight);
        
        _collectionView.scrollEnabled = (collapsedHeight > maxCollapsedHeight);
        
        height = MIN(_collapsedHeight + _expandOffset, _expandedHeight);
    }
    
    return height;
}

- (CGFloat)contentHeightCorrection
{
    if (self.sizeClass == UIUserInterfaceSizeClassRegular)
        return 0.0f;
    
    CGFloat correction = self.collapseInLandscape ? (_smallActivated ? -TGMenuSheetButtonItemViewHeight : 0.0f) : 0.0f;
    
    if (_failed)
        correction -= TGMenuSheetButtonItemViewHeight;
    
    return correction;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _collectionView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    _activityIndicator.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
    _errorLabel.frame = CGRectMake(floor((self.frame.size.width - _errorLabel.frame.size.width) / 2.0f), floor((self.frame.size.height - _errorLabel.frame.size.height) / 2.0f), _errorLabel.frame.size.width, _errorLabel.frame.size.height);
}

@end


@implementation TGMultipleStickerPacksCollectionView

- (BOOL)pointInside:(CGPoint)__unused point withEvent:(UIEvent *)__unused event
{
    return true;
}

@end
