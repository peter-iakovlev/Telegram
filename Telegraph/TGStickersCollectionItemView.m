#import "TGStickersCollectionItemView.h"

#import <SSignalKit/SSignalKit.h>

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGTimerTarget.h"

#import "TGStickersCollectionCell.h"

#import "TGStickerPack.h"
#import "TGDocumentMediaAttachment.h"

#import "TGMenuSheetController.h"
#import "TGNavigationController.h"

#import "TGMenuView.h"

#import "TGMenuSheetCollectionView.h"
#import "TGScrollIndicatorView.h"

#import "TGItemPreviewController.h"
#import "TGStickerItemPreviewView.h"

#import "TGMessage.h"

#import "TGTextCheckingResult.h"

const UIEdgeInsets TGStickersCollectionInsets = { 58.0f, 20.0f, 12.0f, 20.0f };
const CGFloat TGStickersCollectionLoadingHeight = 145.0f;
const CGFloat TGStickersCollectionLoadingLandscapeHeight = 145.0f;
const CGFloat TGStickersCollectionRegularSizeClassHeight = 344.0f;
const NSInteger TGStickersCollectionNumberOfCollapsedRows = 3;
const NSInteger TGStickersCollectionNumberOfTimerTicks = 10;
const CGFloat TGStickersCollectionErrorLabelMargin = 23.0f;

@interface TGStickersCollectionView  : TGMenuSheetCollectionView

@end

@interface TGTextLabelLink : NSObject

@property (nonatomic, readonly) NSRange range;
@property (nonatomic, strong, readonly) UIButton *button;
@property (nonatomic, strong, readonly) NSString *link;

@end

@implementation TGTextLabelLink

- (instancetype)initWithRange:(NSRange)range button:(UIButton *)button link:(NSString *)link {
    self = [super init];
    if (self != nil) {
        _range = range;
        _button = button;
        _link = link;
    }
    return self;
}

@end

@interface TGStickersCollectionItemView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, ASWatcher>
{
    TGStickerPack *_stickerPack;
    
    TGStickersCollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionViewLayout;
    TGScrollIndicatorView *_scrollIndicator;
    
    UIView *_separator;
    
    UIActivityIndicatorView *_activityIndicator;
    UILabel *_titleLabel;
    NSArray<TGTextLabelLink *> *_titleLinks;
    
    UILabel *_errorLabel;

    UILongPressGestureRecognizer *_longPressGestureRecognizer;
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
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGStickersCollectionItemView

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
        _collectionViewLayout.itemSize = CGSizeMake(66, 66);
        _collectionViewLayout.minimumInteritemSpacing = 4;
        _collectionViewLayout.minimumLineSpacing = 10;
        
        _collectionView = [[TGStickersCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
        _collectionView.allowSimultaneousPan = true;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.bounces = false;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.scrollsToTop = false;
        [_collectionView registerClass:[TGStickersCollectionCell class] forCellWithReuseIdentifier:TGStickersCollectionCellIdentifier];
        [self addSubview:_collectionView];
        
        _scrollIndicator = [[TGScrollIndicatorView alloc] init];
        [_scrollIndicator setHidden:true animated:false];        
        [_collectionView addSubview:_scrollIndicator];
        
        [self.menuController.panGestureRecognizer requireGestureRecognizerToFail:_collectionView.panGestureRecognizer];
        
        _separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, TGScreenPixel)];
        _separator.alpha = 0.0f;
        _separator.backgroundColor = TGSeparatorColor();
        [self addSubview:_separator];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityIndicator];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = TGMediumSystemFontOfSize(20.0f);
        _titleLabel.textColor = [UIColor blackColor];
        [self addSubview:_titleLabel];
        
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
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _longPressGestureRecognizer.minimumPressDuration = 0.25;
        _longPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_longPressGestureRecognizer];
        
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

- (void)setStickerPack:(TGStickerPack *)stickerPack animated:(bool)animated
{
    _stickerPack = stickerPack;
 
    [_activityIndicator stopAnimating];
    _activityIndicator.hidden = true;
    
    for (TGTextLabelLink *link in _titleLinks) {
        [link.button removeFromSuperview];
    }
    _titleLinks = nil;
    
    NSMutableArray<TGTextLabelLink *> *titleLinks = [[NSMutableArray alloc] init];
    NSArray *textResults = [TGMessage textCheckingResultsForText:stickerPack.title highlightMentionsAndTags:true highlightCommands:false entities:nil];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:stickerPack.title attributes:@{NSFontAttributeName: _titleLabel.font, NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    static UIImage *buttonImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIImage *rawImage = [UIImage imageNamed:@"LinkFull.png"];
        buttonImage = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)];
    });
    
    for (id result in textResults) {
        if ([result isKindOfClass:[TGTextCheckingResult class]]) {
            TGTextCheckingResult *textResult = result;
            if (textResult.type == TGTextCheckingResultTypeMention) {
                [string addAttribute:NSForegroundColorAttributeName value:TGAccentColor() range:textResult.range];
                UIButton *button = [[UIButton alloc] init];
                [button setBackgroundImage:buttonImage forState:UIControlStateHighlighted];
                [button addTarget:self action:@selector(titleLinkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                [_titleLabel.superview addSubview:button];
                
                [titleLinks addObject:[[TGTextLabelLink alloc] initWithRange:textResult.range button:button link:[@"mention://" stringByAppendingString:textResult.contents]]];
            }
        }
    }
    
    _titleLabel.attributedText = string;
    _titleLinks = titleLinks;
    
    [_titleLabel sizeToFit];
        
    CGRect titleFrame = _titleLabel.frame;
    titleFrame.size.width = ceil(titleFrame.size.width);
    titleFrame.size.height = ceil(titleFrame.size.height);
    
    if (_itemViewWidth > FLT_EPSILON)
        titleFrame.size.width = MIN(_itemViewWidth - 22.0f, titleFrame.size.width);
    
    _titleLabel.frame = titleFrame;
    
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
        performMenuRelayout(^
        {
            _collectionView.frame = targetFrame;
        });
        
        for (TGStickersCollectionCell *cell in _collectionView.visibleCells)
            [cell performTransitionIn];
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
    _separator.hidden = true;
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
    
    for (TGStickersCollectionCell *cell in _collectionView.visibleCells)
        [cell setAltTick:_altTimerTick];
}

#pragma mark -

- (void)menuView:(TGMenuSheetView *)__unused menuView willAppearAnimated:(bool)__unused animated
{
    [_activityIndicator startAnimating];
}

- (void)menuView:(TGMenuSheetView *)__unused smenuView didAppearAnimated:(bool)__unused animated
{
    _appeared = true;
    
    if (_altTimer == nil && _stickerPack != nil)
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

- (TGDocumentMediaAttachment *)stickerAtPoint:(CGPoint)point stickerCell:(TGStickersCollectionCell **)stickerCell
{
    for (TGStickersCollectionCell *cell in _collectionView.visibleCells)
    {
        if (CGRectContainsPoint(cell.frame, point))
        {
            *stickerCell = cell;
            return cell.sticker;
        }
    }
    
    return nil;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (_collectionView.isDragging)
        return;
    
    _collectionView.allowSimultaneousPan = false;
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            __strong TGViewController *parentController = (TGViewController *)self.menuController.parentController;
            if ([parentController isKindOfClass:[TGNavigationController class]])
            {
                TGNavigationController *navigationController = (TGNavigationController *)parentController;
                if (navigationController.viewControllers.count > 1)
                {
                    TGViewController *controller = navigationController.viewControllers[navigationController.viewControllers.count - 2];
                    if ([controller isKindOfClass:[TGViewController class]])
                        parentController = controller;
                }
            }
            
            TGStickersCollectionCell *cell = nil;
            TGDocumentMediaAttachment *document = [self stickerAtPoint:[gestureRecognizer locationInView:_collectionView] stickerCell:&cell];
            if (document != nil && parentController != nil)
            {
                TGStickerItemPreviewView *previewView = [[TGStickerItemPreviewView alloc] initWithFrame:CGRectZero];
                TGItemPreviewController *controller = [[TGItemPreviewController alloc] initWithParentController:parentController previewView:previewView];
                _previewController = controller;
                
                __weak TGStickersCollectionItemView *weakSelf = self;
                controller.sourcePointForItem = ^(id item)
                {
                    __strong TGStickersCollectionItemView *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return CGPointZero;
                    
                    for (TGStickersCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        if ([cell.sticker isEqual:item])
                        {
                            NSIndexPath *indexPath = [strongSelf->_collectionView indexPathForCell:cell];
                            if (indexPath != nil)
                                return [strongSelf->_collectionView convertPoint:cell.center toView:nil];
                        }
                    }
                    
                    return CGPointZero;
                };
                
                NSArray *associations = !_stickerPack.isMask ? _stickerPack.stickerAssociations : nil;
                [previewView setSticker:document associations:associations];
                
                [cell setHighlighted:true animated:true];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            TGItemPreviewController *controller = _previewController;
            [controller dismiss];
            
            _collectionView.allowSimultaneousPan = true;
            
            for (TGStickersCollectionCell *cell in _collectionView.visibleCells)
                [cell setHighlighted:false animated:true];
        }
            break;
            
        default:
            break;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (_previewController == nil)
        return;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        
        TGStickersCollectionCell *highlightedCell = nil;
        TGDocumentMediaAttachment *document = [self stickerAtPoint:[gestureRecognizer locationInView:_collectionView] stickerCell:&highlightedCell];
        if (document != nil)
        {
            NSArray *associations = !_stickerPack.isMask ? _stickerPack.stickerAssociations : nil;
            [previewView setSticker:document associations:associations];
        
            for (TGStickersCollectionCell *cell in _collectionView.visibleCells)
                [cell setHighlighted:(highlightedCell == cell) animated:true];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _panGestureRecognizer)
        return (_longPressGestureRecognizer.state == UIGestureRecognizerStateBegan || _longPressGestureRecognizer.state == UIGestureRecognizerStateChanged);

    return true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    if ((gestureRecognizer == _longPressGestureRecognizer && otherGestureRecognizer == _panGestureRecognizer) || (gestureRecognizer == _panGestureRecognizer && otherGestureRecognizer == _longPressGestureRecognizer))
        return true;
    
    return false;
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGStickersCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TGStickersCollectionCellIdentifier forIndexPath:indexPath];
    [cell setAltTick:_altTimerTick];
    
    NSArray *associations = !_stickerPack.isMask ? _stickerPack.stickerAssociations : nil;
    [cell setSticker:_stickerPack.documents[indexPath.row] associations:associations mask:_stickerPack.isMask];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return _stickerPack.documents.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    CGFloat width = collectionView.frame.size.width;
    NSInteger itemsCount = [collectionView numberOfItemsInSection:0];
    NSInteger columns = (NSInteger)floor((width - TGStickersCollectionInsets.left - TGStickersCollectionInsets.right) / (_collectionViewLayout.itemSize.width + _collectionViewLayout.minimumInteritemSpacing));
    
    if (itemsCount >= columns)
        return UIEdgeInsetsMake(0, TGStickersCollectionInsets.left, 20.0f, TGStickersCollectionInsets.right);

    CGFloat inset = (width - (_collectionViewLayout.itemSize.width + _collectionViewLayout.minimumInteritemSpacing) * itemsCount - _collectionViewLayout.minimumInteritemSpacing) / 2.0f;
    
    return UIEdgeInsetsMake(0, inset, 20.0f, inset);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sendSticker == nil || _stickerPack.isMask)
        return;
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if (_menuContainerView != nil)
    {
        [_menuContainerView removeFromSuperview];
        _menuContainerView = nil;
        
        NSInteger selectedSticker = _selectedSticker;
        _selectedSticker = NSNotFound;
        if (selectedSticker == indexPath.row)
            return;
    }
    
    _selectedSticker = indexPath.row;
    
    UIView *parentView = self.menuController.parentController.view;
    _menuContainerView = [[TGMenuContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, parentView.frame.size.width, parentView.frame.size.height)];
    [parentView addSubview:_menuContainerView];
    
    NSArray *actions = @[ @{ @"title": TGLocalized(@"StickerPack.Send"), @"action": @"send" } ];
    [_menuContainerView.menuView setUserInfo:@{ @"index": @(indexPath.row) }];
    [_menuContainerView.menuView setButtonsAndActions:actions watcherHandle:_actionHandle];
    [_menuContainerView.menuView sizeToFit];
    
    CGRect sourceRect = CGRectOffset([cell convertRect:cell.bounds toView:_menuContainerView], 0, 8);
    [_menuContainerView showMenuFromRect:sourceRect animated:false];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"menuAction"])
    {
        NSString *menuAction = options[@"action"];
        if ([menuAction isEqualToString:@"send"])
        {
            NSInteger index = [options[@"userInfo"][@"index"] integerValue];
            TGDocumentMediaAttachment *sticker = _stickerPack.documents[index];
            if (self.sendSticker != nil)
                self.sendSticker(sticker);
        }
    }
    else if ([action isEqualToString:@"menuWillHide"])
    {

    }
}

#pragma mark - 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentHeight = _collapsedHeight + _expandOffset;
    CGFloat bottomContentOffset = (scrollView.contentSize.height - scrollView.frame.size.height);
    
    [_scrollIndicator updateScrollViewDidScroll];

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
    
    [self setSeparatorHidden:(scrollView.contentOffset.y < FLT_EPSILON) animated:true];
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

- (void)setSeparatorHidden:(bool)hidden animated:(bool)animated
{
    if ((hidden && _separator.alpha < FLT_EPSILON) || (!hidden && _separator.alpha > FLT_EPSILON))
        return;
    
    if (animated)
    {
        [UIView animateWithDuration:0.25 animations:^
        {
            _separator.alpha = hidden ? 0.0f : 1.0f;
        }];
    }
    else
    {
        _separator.alpha = hidden ? 0.0f : 1.0f;
    }
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
    
    if (_stickerPack == nil)
    {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:_errorLabel.text attributes:@{ NSFontAttributeName: _errorLabel.font }];
        CGSize textSize = [string boundingRectWithSize:CGSizeMake(width - 18.0f * 2.0f, screenHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        _errorLabel.frame = CGRectMake(_errorLabel.frame.origin.x, _errorLabel.frame.origin.y, ceil(textSize.width), ceil(textSize.height));
        
        if (_failed)
            return TGStickersCollectionErrorLabelMargin + TGStickersCollectionErrorLabelMargin + _errorLabel.frame.size.height;
        else
            return TGStickersCollectionLoadingHeight;
    }
    
    NSInteger columns = (NSInteger)floor((width - TGStickersCollectionInsets.left - TGStickersCollectionInsets.right) / (_collectionViewLayout.itemSize.width + _collectionViewLayout.minimumInteritemSpacing));
    NSInteger rows = _stickerPack.documents.count / columns + (((_stickerPack.documents.count % columns) > 0) ? 1 : 0);
   
    CGFloat collapsedHeight = TGStickersCollectionInsets.top + rows * (_collectionViewLayout.itemSize.height + _collectionViewLayout.minimumLineSpacing) + TGStickersCollectionInsets.bottom;
    
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
        CGFloat maxExpandedHeight = screenHeight - (self.hasShare ? 209.0f : 152.0f);
        CGFloat expandedHeight = TGStickersCollectionInsets.top + rows * (_collectionViewLayout.itemSize.height + _collectionViewLayout.minimumLineSpacing) + TGStickersCollectionInsets.bottom;

        CGFloat buttonsHeight = self.collapseInLandscape ? 2 * TGMenuSheetButtonItemViewHeight : TGMenuSheetButtonItemViewHeight;
        maxExpandedHeight = MIN(maxExpandedHeight, screenHeight - 75.0f - buttonsHeight - self.menuController.statusBarHeight);
        
        CGFloat maxCollapsedHeight = TGStickersCollectionInsets.top + (_collectionViewLayout.itemSize.height + _collectionViewLayout.minimumLineSpacing) * ((CGFloat)TGStickersCollectionNumberOfCollapsedRows - 0.5f) + 20.0f;

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
    
    _collectionView.frame = CGRectMake(0.0f, TGStickersCollectionInsets.top, self.frame.size.width, self.frame.size.height - TGStickersCollectionInsets.top);
    _activityIndicator.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
    CGRect titleFrame = CGRectMake(floor((self.frame.size.width - _titleLabel.frame.size.width) / 2.0f), 16.0f, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    _titleLabel.frame = titleFrame;
    _separator.frame = CGRectMake(0, TGStickersCollectionInsets.top, self.frame.size.width, _separator.frame.size.height);
    _errorLabel.frame = CGRectMake(floor((self.frame.size.width - _errorLabel.frame.size.width) / 2.0f), floor((self.frame.size.height - _errorLabel.frame.size.height) / 2.0f), _errorLabel.frame.size.width, _errorLabel.frame.size.height);
    
    for (TGTextLabelLink *link in _titleLinks) {
        NSAttributedString *previousString = [_titleLabel.attributedText attributedSubstringFromRange:NSMakeRange(0, link.range.location)];
        CGSize previousSize = [previousString boundingRectWithSize:CGSizeMake(400.0f, 400.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        CGSize linkSize = [[_titleLabel.attributedText attributedSubstringFromRange:link.range] boundingRectWithSize:CGSizeMake(400.0f, 400.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        link.button.frame = CGRectMake(titleFrame.origin.x + previousSize.width - 1.0f, titleFrame.origin.y - 1.0f, linkSize.width + 2.0f, titleFrame.size.height + 2.0f);
    }
}

- (void)titleLinkButtonPressed:(UIButton *)button {
    for (TGTextLabelLink *link in _titleLinks) {
        if (link.button == button) {
            if (_openLink) {
                _openLink(link.link);
            }
            break;
        }
    }
}

@end


@implementation TGStickersCollectionView

- (BOOL)pointInside:(CGPoint)__unused point withEvent:(UIEvent *)__unused event
{
    return true;
}

@end
