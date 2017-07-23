#import "TGStickerKeyboardView.h"

#import <AudioToolbox/AudioToolbox.h>

#import "TGAppDelegate.h"
#import "TGStickerPacksSettingsController.h"

#import "TGStickerCollectionViewCell.h"
#import "TGStickerCollectionHeader.h"
#import "TGStickerKeyboardTabPanel.h"

#import "TGDocumentMediaAttachment.h"
#import "TGStickersSignals.h"
#import "TGRecentGifsSignal.h"

#import "TGImageUtils.h"

#import "TGGifKeyboardCell.h"

#import "TGGifKeyboardBalancedLayout.h"

#import "TGDocumentMediaAttachment.h"

#import "TGMenuView.h"

#import "TGItemPreviewController.h"
#import "TGStickerItemPreviewView.h"

#import "TGItemMenuSheetPreviewView.h"
#import "TGMenuSheetButtonItemView.h"
#import "TGPreviewGifItemView.h"
#import "TGPreviewMenu.h"

#import "TGRecentStickersSignal.h"

#import "TGTrendingStickerPackKeyboardCell.h"

#import "TGProgressWindow.h"
#import "TGArchivedStickerPacksAlert.h"

#import "TGStickersMenu.h"

#import "TGForceTouchGestureRecognizer.h"

static const CGFloat preloadInset = 160.0f;
static const CGFloat gifInset = 128.0f;

typedef enum {
    TGStickerKeyboardViewModeStickers = 0,
    TGStickerKeyboardViewModeGifs,
    TGStickerKeyboardViewModeTrendingFirst,
    TGStickerKeyboardViewModeTrendingLast
} TGStickerKeyboardViewMode;

@interface TGStickerKeyboardView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TGGifKeyboardBalancedLayoutDelegate, UIGestureRecognizerDelegate>
{
    id<SDisposable> _stickerPacksDisposable;
    id<SDisposable> _updatedFeaturedStickerPacksDisposable;
    
    TGStickerKeyboardViewStyle _style;
    TGStickerKeyboardTabPanel *_tabPanel;
    CGFloat _lastContentOffset;
    
    UICollectionView *_gifsCollectionView;
    TGGifKeyboardBalancedLayout *_gifsCollectionLayout;
    
    UICollectionView *_trendingCollectionView;
    UICollectionViewFlowLayout *_trendingCollectionLayout;
    
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    
    UIView *_topStripe;
    
    NSArray *_stickerPacks;
    NSArray *_recentStickersOriginal;
    NSArray *_recentStickersSorted;
    NSArray *_recentDocuments;
    
    NSDictionary *_recentDocumentToStickerPack;
    
    NSArray *_recentGifsOriginal;
    NSArray *_recentGifsSorted;
    NSArray *_recentGifs;
    
    NSArray *_trendingStickerPacks;
    NSString *_trendingStickersBadge;
    NSSet *_installedTrendingStickerPacks;
    NSSet *_unreadTrendingStickerPacks;
    
    UIPanGestureRecognizer *_panRecognizer;
    TGForceTouchGestureRecognizer *_forceTouchRecognizer;
    
    UIPanGestureRecognizer *_tabPanRecognizer;
    
    TGStickerKeyboardViewMode _mode;
    
    bool _ignoreSetSection;
    
    bool _ignoreGifCellContents;
    
    TGMenuContainerView *_menuContainerView;
    
    TGItemPreviewHandle *_stickersPreviewHandle;
    TGItemPreviewHandle *_gifPreviewHandle;
    
    __weak TGItemPreviewController *_previewController;
    
    SAtomic *_accumulatedReadFeaturedPackIds;
    STimer *_accumulatedReadFeaturedPackIdsTimer;
    NSMutableSet *_alreadyReadFeaturedPackIds;
    
    bool _expanded;
}

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
        _style = style;
        
        CGFloat tabPanelHeight = 45.0f;
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
            self.backgroundColor = UIColorRGB(0xe8ebf0);
        }
        
        if (style == TGStickerKeyboardViewDefaultStyle)
            tabPanelHeight -= 3.0f;
        
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
        _collectionView.contentInset = UIEdgeInsetsMake(tabPanelHeight + preloadInset, 0.0f, preloadInset, 0.0f);
        [_collectionView registerClass:[TGStickerCollectionViewCell class] forCellWithReuseIdentifier:@"TGStickerCollectionViewCell"];
        [_collectionView registerClass:[TGStickerCollectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TGStickerCollectionHeader"];
        [self addSubview:_collectionView];
        
        _trendingCollectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _trendingCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_trendingCollectionLayout];
        _trendingCollectionView.delegate = self;
        _trendingCollectionView.dataSource = self;
        _trendingCollectionView.backgroundColor = [UIColor clearColor];
        _trendingCollectionView.opaque = false;
        _trendingCollectionView.showsHorizontalScrollIndicator = false;
        _trendingCollectionView.showsVerticalScrollIndicator = true;
        _trendingCollectionView.alwaysBounceVertical = true;
        _trendingCollectionView.delaysContentTouches = false;
        _trendingCollectionView.contentInset = UIEdgeInsetsMake(tabPanelHeight + gifInset, 0.0f, gifInset, 0.0f);
        _trendingCollectionView.scrollIndicatorInsets = _trendingCollectionView.contentInset;
        [_trendingCollectionView registerClass:[TGTrendingStickerPackKeyboardCell class] forCellWithReuseIdentifier:@"TGTrendingStickerPackKeyboardCell"];
        [self addSubview:_trendingCollectionView];
        
        _gifsCollectionLayout = [[TGGifKeyboardBalancedLayout alloc] init];
        _gifsCollectionLayout.preferredRowSize = TGIsPad() ? 115.0f : 93.0f;
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
        _gifsCollectionView.contentInset = UIEdgeInsetsMake(tabPanelHeight + gifInset, 0.0f, gifInset, 0.0f);
        [_gifsCollectionView registerClass:[TGGifKeyboardCell class] forCellWithReuseIdentifier:@"TGGifKeyboardCell"];
        [self addSubview:_gifsCollectionView];
        
        UILongPressGestureRecognizer *tapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleStickerPress:)];
        tapRecognizer.minimumPressDuration = 0.25;
        [_collectionView addGestureRecognizer:tapRecognizer];
        
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleStickerPan:)];
        _panRecognizer.delegate = self;
        _panRecognizer.cancelsTouchesInView = false;
        [_collectionView addGestureRecognizer:_panRecognizer];
        
        __weak TGStickerKeyboardView *weakSelf = self;
        _tabPanel = [[TGStickerKeyboardTabPanel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, tabPanelHeight) style:style];
        _tabPanel.currentStickerPackIndexChanged = ^(NSUInteger index)
        {
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                bool fromGifs = strongSelf->_mode != TGStickerKeyboardViewModeStickers;
                [strongSelf setMode:TGStickerKeyboardViewModeStickers];
                [strongSelf scrollToSection:index fromGifs:fromGifs];
            }
        };
        _tabPanel.navigateToGifs = ^{
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setMode:TGStickerKeyboardViewModeGifs];
            }
        };
        _tabPanel.navigateToTrendingFirst = ^{
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setMode:TGStickerKeyboardViewModeTrendingFirst];
            }
        };
        _tabPanel.navigateToTrendingLast = ^{
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setMode:TGStickerKeyboardViewModeTrendingLast];
            }
        };
        _tabPanel.toggleExpanded = ^ {
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.requestedExpand != nil) {
                strongSelf.requestedExpand(!strongSelf->_expanded);
            }
        };
        _tabPanel.expandInteraction = ^(CGFloat offset) {
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.expandInteraction != nil) {
                strongSelf.expandInteraction(offset);
            }
        };
        _tabPanel.openSettings = ^{
            [TGAppDelegateInstance.rootController presentViewController:[TGNavigationController navigationControllerWithControllers:@[[[TGStickerPacksSettingsController alloc] initWithEditing:true masksMode:false]]] animated:true completion:nil];
            
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.isExpanded) {
                strongSelf.requestedExpand(false);
            }
        };
        [_tabPanel setTrendingStickersBadge:_trendingStickersBadge];
        [self addSubview:_tabPanel];
        
        if (_style == TGMenuSheetItemTypeDefault && !TGIsPad())
        {
            _tabPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTabPan:)];
            _tabPanRecognizer.delegate = self;
            _tabPanRecognizer.cancelsTouchesInView = true;
            _tabPanel.exclusiveTouch = true;
            [_tabPanel addGestureRecognizer:_tabPanRecognizer];
        }
        
        CGFloat stripeHeight = TGScreenPixel;
        _topStripe = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, stripeHeight)];
        _topStripe.backgroundColor = UIColorRGB(0xd8d8d8);
        if (style != TGStickerKeyboardViewDarkBlurredStyle && style != TGStickerKeyboardViewDefaultStyle)
            [self addSubview:_topStripe];
        
        SSignal *combinedSignal = [SSignal combineSignals:@[(iosMajorVersion() >= 8 && !TGIsPad() && _style == TGStickerKeyboardViewDefaultStyle) ? [TGRecentGifsSignal recentGifs] : [SSignal single:@[]], [TGStickersSignals stickerPacks], [TGRecentStickersSignal recentStickers]]];
        
        _stickerPacksDisposable = [[combinedSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *combinedResult)
        {
            NSArray *gifs = combinedResult[0];
            
            NSDictionary *dict = combinedResult[1];
            NSMutableArray *filteredPacks = [[NSMutableArray alloc] init];
            NSMutableDictionary *packIdMap = [[NSMutableDictionary alloc] init];
            for (TGStickerPack *pack in dict[@"packs"])
            {
                if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]] && !pack.hidden) {
                    [filteredPacks addObject:pack];
                    
                    TGStickerPackIdReference *packReference = (TGStickerPackIdReference *)pack.packReference;
                    packIdMap[@(packReference.packId)] = pack;
                }
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
            
            NSMutableArray *reversedRecentStickers = [[NSMutableArray alloc] init];
            NSMutableDictionary *documentToStickerPack = [[NSMutableDictionary alloc] init];
            for (id item in [combinedResult[2] reverseObjectEnumerator]) {
                [reversedRecentStickers addObject:item];
                
                TGDocumentMediaAttachment *document = (TGDocumentMediaAttachment *)item;
                if ([document.stickerPackReference isKindOfClass:[TGStickerPackIdReference class]]) {
                    TGStickerPackIdReference *packReference = (TGStickerPackIdReference *)document.stickerPackReference;
                    
                    documentToStickerPack[@(document.documentId)] = packIdMap[@(packReference.packId)];
                }
            }
            
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_recentDocumentToStickerPack = documentToStickerPack;
                
                NSUInteger unreadFeaturedCount = ((NSArray *)dict[@"featuredPacksUnreadIds"]).count;
                [strongSelf setTrendingBadge:unreadFeaturedCount == 0 ? nil : [NSString stringWithFormat:@"%d", (int)unreadFeaturedCount]];
                NSMutableSet *unreadPacks = [[NSMutableSet alloc] init];
                for (NSNumber *nPackId in dict[@"featuredPacksUnreadIds"]) {
                    [unreadPacks addObject:nPackId];
                }
                
                if (![strongSelf->_stickerPacks isEqual:reversed] || ![strongSelf->_recentStickersOriginal isEqual:reversedRecentStickers]) {
                    NSArray *updatedRecentStickers = nil;
                    if (strongSelf->_recentStickersOriginal == nil) {
                        strongSelf->_recentStickersOriginal = reversedRecentStickers;
                        updatedRecentStickers = reversedRecentStickers;
                    } else {
                        strongSelf->_recentStickersOriginal = reversedRecentStickers;
                        updatedRecentStickers = strongSelf->_recentStickersSorted;
                    }
                    [strongSelf setStickerPacks:reversed recentStickers:updatedRecentStickers];
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
                
                NSMutableSet<NSNumber *> *installedPacks = [[NSMutableSet alloc] init];
                for (TGStickerPack *pack in dict[@"packs"]) {
                    if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
                        int64_t packId = ((TGStickerPackIdReference *)pack.packReference).packId;
                        [installedPacks addObject:@(packId)];
                    }
                }
                
                NSMutableArray *trendingPacks = [[NSMutableArray alloc] init];
                for (TGStickerPack *pack in dict[@"featuredPacks"]) {
                    if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
                        int64_t packId = ((TGStickerPackIdReference *)pack.packReference).packId;
                        if (![installedPacks containsObject:@(packId)]) {
                            [trendingPacks addObject:pack];
                        }
                    }
                }
                
                if (![strongSelf->_trendingStickerPacks isEqualToArray:trendingPacks]) {
                    [strongSelf setTrendingStickerPacks:trendingPacks];
                }
                
                //[strongSelf setInstalledTrendingPacks:installedPacks];
                [strongSelf setUnreadTrendingPacks:unreadPacks];
                
                [strongSelf updateCurrentSection];
            }
        }];
        
        _updatedFeaturedStickerPacksDisposable = [[TGStickersSignals updatedFeaturedStickerPacks] startWithNext:nil];
        
        _gifPreviewHandle = [TGPreviewMenu setupPreviewControllerForView:_gifsCollectionView configurator:^TGItemPreviewController *(CGPoint gestureLocation) {
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            TGItemPreviewController *controller = nil;
            for (NSIndexPath *indexPath in [strongSelf->_gifsCollectionView indexPathsForVisibleItems])
            {
                TGGifKeyboardCell *cell = (TGGifKeyboardCell *)[strongSelf->_gifsCollectionView cellForItemAtIndexPath:indexPath];
                if (CGRectContainsPoint(cell.frame, gestureLocation))
                {
                    TGViewController *parentViewController = strongSelf->_parentViewController;
                    if (parentViewController != nil)
                    {
                        TGDocumentMediaAttachment *gif = [strongSelf gifAtIndexPath:indexPath];
                        TGPreviewGifItemView *gifItem = [[TGPreviewGifItemView alloc] initWithDocument:gif];
                        
                        TGMenuSheetButtonItemView *deleteItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Preview.DeleteGif") type:TGMenuSheetButtonTypeDestructive action:nil];
                        
                        TGMenuSheetButtonItemView *sendItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"ShareMenu.Send") type:TGMenuSheetButtonTypeSend action:nil];
                        
                        TGItemMenuSheetPreviewView *previewView = [[TGItemMenuSheetPreviewView alloc] initWithMainItemViews:@[ gifItem ] actionItemViews:@[ deleteItem, sendItem ]];
                        
                        __weak TGItemMenuSheetPreviewView *weakPreviewView = previewView;
                        deleteItem.action = ^
                        {
                            __strong TGStickerKeyboardView *strongSelf = weakSelf;
                            if (strongSelf == nil)
                                return;
                            
                            __strong TGItemMenuSheetPreviewView *strongPreviewView = weakPreviewView;
                            if (strongPreviewView == nil)
                                return;
                            
                            [TGRecentGifsSignal removeRecentGifByDocumentId:gif.documentId];
                            [strongPreviewView performCommit];
                        };
                        
                        sendItem.action = ^
                        {
                            __strong TGStickerKeyboardView *strongSelf = weakSelf;
                            if (strongSelf == nil)
                                return;
                            
                            __strong TGItemMenuSheetPreviewView *strongPreviewView = weakPreviewView;
                            if (strongPreviewView == nil)
                                return;
                            
                            strongSelf.stickerSelected(gif);
                            [strongPreviewView performCommit];
                        };
                        
                        controller = [[TGItemPreviewController alloc] initWithParentController:parentViewController previewView:previewView];
                        controller.sourcePointForItem = ^(__unused id item)
                        {
                            __strong TGStickerKeyboardView *strongSelf = weakSelf;
                            if (strongSelf == nil)
                                return CGPointZero;
                            
                            for (TGGifKeyboardCell *cell in strongSelf->_gifsCollectionView.visibleCells)
                            {
                                if ([cell.contents.document isEqual:gif])
                                {
                                    NSIndexPath *indexPath = [strongSelf->_gifsCollectionView indexPathForCell:cell];
                                    if (indexPath != nil)
                                        return [strongSelf->_gifsCollectionView convertPoint:cell.center toView:nil];
                                }
                            }
                            
                            return CGPointZero;
                        };
                    }
                    
                    break;
                }
            }
            
            return controller;
        }];
    }
    return self;
}

- (void)dealloc
{
    [_stickerPacksDisposable dispose];
    [_updatedFeaturedStickerPacksDisposable dispose];
    [_accumulatedReadFeaturedPackIdsTimer invalidate];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (_forceTouchRecognizer == nil)
    {
        _forceTouchRecognizer = [[TGForceTouchGestureRecognizer alloc] initWithTarget:self action:@selector(handleForceTouch:)];
        _forceTouchRecognizer.delegate = self;
        [_collectionView addGestureRecognizer:_forceTouchRecognizer];
        
        if (![_forceTouchRecognizer forceTouchAvailable])
            _forceTouchRecognizer.enabled = false;
    }
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

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_expanded)
        return CGRectContainsPoint(CGRectMake(0, -15.0f, self.bounds.size.width, self.bounds.size.height + 15.0f), point);
    
    return [super pointInside:point withEvent:event];
}

- (void)layoutForSize:(CGSize)size
{
    _tabPanel.frame = CGRectMake(0.0f, 0.0f, size.width, _tabPanel.frame.size.height);
    [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
    
    if (_mode == TGStickerKeyboardViewModeStickers) {
        _collectionView.frame = CGRectMake(0.0f, -preloadInset, size.width, size.height + preloadInset * 2.0f);
        _gifsCollectionView.frame = CGRectMake(-size.width, -gifInset, size.width, size.height + gifInset * 2.0f);
        _trendingCollectionView.frame = CGRectMake(size.width, -gifInset, size.width, size.height + gifInset * 2.0f);
    } else if (_mode == TGStickerKeyboardViewModeGifs) {
        _collectionView.frame = CGRectMake(size.width, -preloadInset, size.width, size.height + preloadInset * 2.0f);
        _gifsCollectionView.frame = CGRectMake(0.0f, -gifInset, size.width, size.height + gifInset * 2.0f);
        _trendingCollectionView.frame = CGRectMake(size.width * 2.0f, -gifInset, size.width, size.height + gifInset * 2.0f);
    } else {
        _collectionView.frame = CGRectMake(-size.width * 2.0, -preloadInset, size.width, size.height + preloadInset * 2.0f);
        _gifsCollectionView.frame = CGRectMake(-size.width, -gifInset, size.width, size.height + gifInset * 2.0f);
        _trendingCollectionView.frame = CGRectMake(0.0f, -gifInset, size.width, size.height + gifInset * 2.0f);
    }
    [_collectionLayout invalidateLayout];
    [_gifsCollectionLayout invalidateLayout];
    [_trendingCollectionLayout invalidateLayout];
    
    CGFloat stripeHeight = TGScreenPixel;
    _topStripe.frame = CGRectMake(0.0f, 0.0f, size.width, stripeHeight);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == _gifsCollectionView) {
        return 1;
    } else if (collectionView == _trendingCollectionView) {
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
    } else if (collectionView == _trendingCollectionView) {
        if (section == 0) {
            return _trendingStickerPacks.count;
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
    } else if (collectionView == _trendingCollectionView) {
        return CGSizeMake(collectionViewLayout.collectionView.bounds.size.width, 132.0f);
    } else {
        return CGSizeMake(62.0f, 62.0f);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView == _gifsCollectionView) {
        return UIEdgeInsetsZero;
    } else if (collectionView == _trendingCollectionView) {
        return UIEdgeInsetsZero;
    } else {
        CGFloat topInset = 8.0f;
        CGFloat inset = 12.0f;
        CGFloat sideInset = (collectionView.frame.size.width < 330.0f) ? 3.0f : inset;
        
        if (_recentDocuments.count == 0 && _stickerPacks.count == 1)
        {
            if (section == 0)
                return UIEdgeInsetsZero;
            
            return UIEdgeInsetsMake(topInset, sideInset, inset, sideInset);
        }
        
        if (section == 0)
        {
            if (_recentDocuments.count == 0)
                return UIEdgeInsetsMake(inset, sideInset, 0.0f, sideInset);
            else
            {
                return UIEdgeInsetsMake(topInset, sideInset, [self collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section], sideInset);
            }
        }
        else if (section == (NSInteger)_stickerPacks.count)
            return UIEdgeInsetsMake(topInset, sideInset, inset, sideInset);
        return UIEdgeInsetsMake(topInset, sideInset, [self collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section], sideInset);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    if (collectionView == _gifsCollectionView) {
        return 0.0f;
    } else if (collectionView == _trendingCollectionView) {
        return 0.0f;
    } else {
        return 7.0f;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    if (collectionView == _gifsCollectionView) {
        return 0.0f;
    } else if (collectionView == _trendingCollectionView) {
        return 0.0f;
    } else {
        return (collectionView.frame.size.width < 330.0f) ? 0.0f : 4.0f;
    }
}

- (void)setMaskWithTabPanelOffset:(CGFloat)offset
{
    CGFloat value = fabs(offset) / _tabPanel.frame.size.height;
    [_tabPanel setInnerAlpha:MAX(0.0f, 1.0f - (value * 1.25f))];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _collectionView || scrollView == _trendingCollectionView || (scrollView == _gifsCollectionView && _mode == TGStickerKeyboardViewModeGifs))
    {
        CGFloat delta = scrollView.contentOffset.y - _lastContentOffset;
        _lastContentOffset = scrollView.contentOffset.y;
        
        CGFloat inset = preloadInset;
        if (scrollView == _trendingCollectionView || scrollView == _gifsCollectionView) {
            inset = gifInset;
        }
        
        CGRect tabPanelFrame = _tabPanel.frame;
        
        if (!_ignoreSetSection)
        {
            if (scrollView.contentOffset.y <= -_tabPanel.frame.size.height - inset)
                tabPanelFrame.origin.y = 0.0f;
            else
                tabPanelFrame.origin.y -= delta;
            tabPanelFrame.origin.y = MAX(-_tabPanel.frame.size.height, MIN(0.0f, tabPanelFrame.origin.y));
        }
        
        if (_expanded)
            tabPanelFrame.origin.y = 0.0f;
        
        _tabPanel.frame = tabPanelFrame;
        [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
        
        if (!_ignoreSetSection && _mode != TGStickerKeyboardViewModeGifs) {
            [self updateCurrentSection];
        }
    }
    
    if (scrollView == _gifsCollectionView) {
        CGRect bounds = scrollView.bounds;
        bounds.origin.y += scrollView.contentInset.top;
        bounds.size.height -= scrollView.contentInset.top + scrollView.contentInset.bottom;
        for (TGGifKeyboardCell *cell in _gifsCollectionView.visibleCells) {
            if (CGRectIntersectsRect(bounds, cell.frame)) {
                [cell setEnableAnimation:_enableAnimation && _mode == TGStickerKeyboardViewModeGifs];
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_style != TGStickerKeyboardViewDefaultStyle || decelerate)
        return;
    
    if (scrollView == _collectionView || scrollView == _trendingCollectionView || scrollView == _gifsCollectionView)
    {
        if (_expanded)
            return;
        
        CGFloat y = _tabPanel.frame.origin.y;
        if (y < -FLT_EPSILON && y > -_tabPanel.frame.size.height + FLT_EPSILON)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
             {
                 CGRect frame = _tabPanel.frame;
                 if (scrollView.contentOffset.y <= -preloadInset || fabs(y) < _tabPanel.frame.size.height / 2.0f)
                     frame.origin.y = 0.0f;
                 else
                     frame.origin.y = -_tabPanel.frame.size.height;
                 
                 _tabPanel.frame = frame;
                 [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
             } completion:nil];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDragging:scrollView willDecelerate:false];
}

- (void)updateCurrentSection {
    if (_mode == TGStickerKeyboardViewModeGifs) {
        [_tabPanel setCurrentGifsModeSelected];
    } else if (_mode == TGStickerKeyboardViewModeTrendingFirst || _mode == TGStickerKeyboardViewModeTrendingLast) {
        [_tabPanel setCurrentTrendingModeSelected];
    } else {
        NSArray *layoutAttributes = [_collectionLayout layoutAttributesForElementsInRect:CGRectMake(0.0f, _collectionView.contentOffset.y + _tabPanel.frame.size.height + preloadInset + 7.0f, _collectionView.frame.size.width, _collectionView.frame.size.height - _tabPanel.frame.size.height - preloadInset - 7.0f)];
        NSInteger minSection = INT_MAX;
        for (UICollectionViewLayoutAttributes *attributes in layoutAttributes)
        {
            minSection = MIN(attributes.indexPath.section, minSection);
        }
        if (minSection != INT_MAX)
            [_tabPanel setCurrentStickerPackIndex:minSection animated:true];
    }
}

- (TGDocumentMediaAttachment *)gifAtIndexPath:(NSIndexPath *)indexPath
{
    return _recentGifs[indexPath.item];
}

- (TGStickerPack *)stickerPackAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        TGDocumentMediaAttachment *document = [self documentAtIndexPath:indexPath];
        return _recentDocumentToStickerPack[@(document.documentId)];
    }
    else
    {
        return _stickerPacks[indexPath.section - 1];
    }
}

- (TGDocumentMediaAttachment *)documentAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return _recentDocuments[indexPath.item];
    else
        return ((TGStickerPack *)_stickerPacks[indexPath.section - 1]).documents[indexPath.item];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _collectionView && [kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        TGStickerCollectionHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TGStickerCollectionHeader" forIndexPath:indexPath];
        view.title = indexPath.section == 0 ? TGLocalized(@"Stickers.FrequentlyUsed") : [_stickerPacks[indexPath.section - 1] title];
        return view;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)__unused section
{
    if (collectionView == _collectionView)
    {
        if (section == 0 && _recentDocuments.count == 0)
            return CGSizeZero;
        
        return CGSizeMake(collectionView.bounds.size.width, 23.0f);
    }
    return CGSizeZero;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _gifsCollectionView) {
        TGGifKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGGifKeyboardCell" forIndexPath:indexPath];
        if (!_ignoreGifCellContents) {
            [cell setDocument:_recentGifs[indexPath.item]];
        }
        return cell;
    } else if (collectionView == _trendingCollectionView) {
        TGTrendingStickerPackKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGTrendingStickerPackKeyboardCell" forIndexPath:indexPath];
        TGStickerPack *pack = _trendingStickerPacks[indexPath.item];
        [cell setStickerPack:pack];
        bool installed = true;
        bool unread = false;
        if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
            TGStickerPackIdReference *reference = (TGStickerPackIdReference *)pack.packReference;
            installed = [_installedTrendingStickerPacks containsObject:@(reference.packId)];
            unread = [_unreadTrendingStickerPacks containsObject:@(reference.packId)];
        }
        cell.installed = installed;
        cell.unread = unread;
        __weak TGStickerKeyboardView *weakSelf = self;
        cell.install = ^{
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf installStickerPack:pack];
            }
        };
        cell.info = ^{
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf previewStickerPack:pack sticker:nil];
            }
        };
        return cell;
    } else {
        TGStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerCollectionViewCell" forIndexPath:indexPath];
        [cell setDocumentMedia:[self documentAtIndexPath:indexPath]];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _gifsCollectionView) {
        TGGifKeyboardCell *cell = (TGGifKeyboardCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell != nil && _gifSelected) {
            _gifSelected(_recentGifs[indexPath.row]);
        }
    } else if (collectionView == _trendingCollectionView) {
    } else {
        TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if ([cell isEnabled])
        {
            [cell setDisabledTimeout];
            
            TGDocumentMediaAttachment *document = [self documentAtIndexPath:indexPath];
            if (_stickerSelected)
                _stickerSelected(document);
        }
    }
}

- (void)scrollToSection:(NSUInteger)section
{
    [self scrollToSection:section fromGifs:false];
}

- (void)scrollToSection:(NSUInteger)section fromGifs:(bool)fromGifs
{
    _ignoreSetSection = false;
    
    [_tabPanel setCurrentStickerPackIndex:section animated:false];
    
    if (!_expanded && section != 0 && !fromGifs)
    {
        [UIView animateWithDuration:0.15 delay:0.0 options:kNilOptions animations:^
        {
            CGRect frame = _tabPanel.frame;
            frame.origin.y = -_tabPanel.frame.size.height;
            _tabPanel.frame = frame;
            [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
        } completion:nil];
    }
    
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
            
            CGFloat verticalOffset = attributes.frame.origin.y - [self collectionView:_collectionView layout:_collectionLayout minimumLineSpacingForSectionAtIndex:section] - [self collectionView:_collectionView layout:_collectionLayout referenceSizeForHeaderInSection:section].height;
            CGFloat effectiveInset = preloadInset;
            if (_expanded)
                effectiveInset = _collectionView.contentInset.top;
            
            CGFloat contentOffset = verticalOffset - effectiveInset;
            if (contentOffset > _collectionView.contentSize.height - _collectionView.frame.size.height + _collectionView.contentInset.bottom) {
                contentOffset = _collectionView.contentSize.height - _collectionView.frame.size.height + _collectionView.contentInset.bottom;
            }
            
            _ignoreSetSection = true;
            [_collectionView setContentOffset:CGPointMake(0.0f, contentOffset) animated:true];
        }
    }
}

- (void)setTrendingBadge:(NSString *)trendingBadge {
    if (_trendingStickersBadge == nil) {
        _trendingStickersBadge = trendingBadge;
        [_tabPanel setTrendingStickersBadge:trendingBadge];
    }
}

- (void)setStickerPacks:(NSArray *)stickerPacks recentStickers:(NSArray *)recentStickers
{
    _stickerPacks = stickerPacks;
    
    _recentStickersSorted = recentStickers;
    
    [self updateRecentDocuments];
    
    [_collectionView reloadData];
    
    bool disableTrending = _style == TGStickerKeyboardViewDarkBlurredStyle;
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0 showGifs:_recentGifs.count != 0 showTrendingFirst:!disableTrending && (_trendingStickerPacks.count != 0) && _trendingStickersBadge != nil showTrendingLast:!disableTrending && (_trendingStickerPacks.count != 0) && _trendingStickersBadge == nil];
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
    
    bool disableTrending = _style == TGStickerKeyboardViewDarkBlurredStyle;
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0 showGifs:_recentGifs.count != 0 showTrendingFirst:!disableTrending && (_trendingStickerPacks.count != 0) && _trendingStickersBadge != nil showTrendingLast:!disableTrending && (_trendingStickerPacks.count != 0) && _trendingStickersBadge == nil];
    
    [self scrollViewDidScroll:_gifsCollectionView];
    
    if (_recentGifs.count == 0 && _mode == TGStickerKeyboardViewModeGifs) {
        [self setMode:TGStickerKeyboardViewModeStickers];
    }
}

- (void)setTrendingStickerPacks:(NSArray *)trendingStickerPacks {
    if (TGObjectCompare(trendingStickerPacks, _trendingStickerPacks)) {
        return;
    }
    
    _trendingStickerPacks = trendingStickerPacks;
    
    [_trendingCollectionView reloadData];
    
    bool disableTrending = _style == TGStickerKeyboardViewDarkBlurredStyle;
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0 showGifs:_recentGifs.count != 0 showTrendingFirst:!disableTrending && (_trendingStickerPacks.count != 0) && _trendingStickersBadge != nil showTrendingLast:!disableTrending && (_trendingStickerPacks.count != 0) && _trendingStickersBadge == nil];
}

- (void)setInstalledTrendingPacks:(NSSet *)installedTrendingPacks {
    if (TGObjectCompare(installedTrendingPacks, _installedTrendingStickerPacks)) {
        return;
    }
    
    _installedTrendingStickerPacks = installedTrendingPacks;
    for (id cell in [_trendingCollectionView visibleCells]) {
        if ([cell isKindOfClass:[TGTrendingStickerPackKeyboardCell class]]) {
            TGTrendingStickerPackKeyboardCell *packCell = cell;
            bool installed = true;
            if ([packCell.stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
                TGStickerPackIdReference *reference = (TGStickerPackIdReference *)packCell.stickerPack.packReference;
                installed = [installedTrendingPacks containsObject:@(reference.packId)];
            }
            packCell.installed = installed;
        }
    }
}

- (void)setUnreadTrendingPacks:(NSSet *)unreadTrendingPacks {
    if (_unreadTrendingStickerPacks != nil) {
        return;
    }
    
    if (TGObjectCompare(unreadTrendingPacks, _unreadTrendingStickerPacks)) {
        return;
    }
    
    _unreadTrendingStickerPacks = unreadTrendingPacks;
    
    for (id cell in [_trendingCollectionView visibleCells]) {
        if ([cell isKindOfClass:[TGTrendingStickerPackKeyboardCell class]]) {
            TGTrendingStickerPackKeyboardCell *packCell = cell;
            bool unread = true;
            if ([packCell.stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
                TGStickerPackIdReference *reference = (TGStickerPackIdReference *)packCell.stickerPack.packReference;
                unread = [unreadTrendingPacks containsObject:@(reference.packId)];
            }
            packCell.unread = unread;
        }
    }
}

- (void)updateRecentDocuments
{
    NSMutableArray *recentDocuments = [[NSMutableArray alloc] initWithArray:_recentStickersSorted];
    
    if (recentDocuments.count > 20) {
        [recentDocuments removeObjectsInRange:NSMakeRange(20, recentDocuments.count - 20)];
    }
    
    _recentDocuments = recentDocuments;
}

- (void)updateIfNeeded
{
    _recentStickersSorted = _recentStickersOriginal;
    
    [self updateRecentDocuments];
    
    [_collectionView reloadData];
    bool disableTrending = _style == TGStickerKeyboardViewDarkBlurredStyle;
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0 showGifs:_recentGifs.count != 0 showTrendingFirst:!disableTrending && (_trendingStickerPacks.count != 0) && _trendingStickersBadge != nil showTrendingLast:!disableTrending && (_trendingStickerPacks.count != 0) && _trendingStickersBadge == nil];
    
    if (!TGObjectCompare(_recentGifsOriginal, _recentGifs)) {
        [self setRecentGifs:_recentGifsOriginal];
    }
    
    _tabPanel.frame = CGRectMake(_tabPanel.frame.origin.x, 0.0f, _tabPanel.frame.size.width, _tabPanel.frame.size.height);
    [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
    
    [self updateCurrentSection];
    
    if (_gifTabActive) {
        _gifTabActive(_mode == TGStickerKeyboardViewModeGifs);
    }
}

- (void)handleStickerPress:(UILongPressGestureRecognizer *)recognizer
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
                    bool isRecent = _recentDocuments.count > 0 && indexPath.section == 0;
                    
                    TGStickerItemPreviewView *previewView = [[TGStickerItemPreviewView alloc] initWithFrame:CGRectZero];
                    if ((NSInteger)TGScreenSize().height == 736)
                        previewView.eccentric = false;
                    if (isRecent && !_forceTouchRecognizer.enabled)
                        previewView.presentActionsImmediately = true;
                    
                    __weak TGStickerKeyboardView *weakSelf = self;
                    __weak TGStickerItemPreviewView *weakPreviewView = previewView;
                    NSMutableArray *actions = [[NSMutableArray alloc] init];
                    TGMenuSheetButtonItemView *sendItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"ShareMenu.Send") type:TGMenuSheetButtonTypeSend action:^
                                                           {
                                                               __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
                                                               __strong TGStickerKeyboardView *strongSelf = weakSelf;
                                                               if (strongSelf == nil || strongPreviewView == nil)
                                                                   return;
                                                               
                                                               [strongPreviewView performCommit];
                                                               
                                                               TGDispatchAfter(0.2, dispatch_get_main_queue(), ^
                                                                               {
                                                                                   if (strongSelf->_stickerSelected)
                                                                                       strongSelf->_stickerSelected(strongPreviewView.item);
                                                                               });
                                                           }];
                    [actions addObject:sendItem];
                    
//                    TGMenuSheetButtonItemView *favoriteItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Stickers.AddToFavorites") type:TGMenuSheetButtonTypeDefault action:^
//                    {
//                        __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
//                        __strong TGStickerKeyboardView *strongSelf = weakSelf;
//                        if (strongSelf == nil || strongPreviewView == nil)
//                            return;
//
//                        [strongPreviewView performDismissal];
//                    }];
//                    [actions addObject:favoriteItem];
                    
                    TGMenuSheetButtonItemView *viewItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"StickerPack.ViewPack") type:TGMenuSheetButtonTypeDefault action:^
                                                           {
                                                               __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
                                                               __strong TGStickerKeyboardView *strongSelf = weakSelf;
                                                               if (strongSelf == nil || strongPreviewView == nil)
                                                                   return;
                                                               
                                                               [strongPreviewView performDismissal];
                                                               
                                                               TGDispatchAfter(0.2, dispatch_get_main_queue(), ^
                                                                               {
                                                                                   [strongSelf viewPack:strongPreviewView.stickerPack sticker:strongPreviewView.item recent:strongPreviewView.recent];
                                                                               });
                                                           }];
                    [actions addObject:viewItem];
                    
                    TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeDefault action:^
                                                             {
                                                                 __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
                                                                 if (strongPreviewView == nil)
                                                                     return;
                                                                 
                                                                 [strongPreviewView performDismissal];
                                                             }];
                    [actions addObject:cancelItem];
                    
                    [previewView setupWithMainItemViews:nil actionItemViews:actions];
                    
                    TGItemPreviewController *controller = [[TGItemPreviewController alloc] initWithParentController:parentViewController previewView:previewView];
                    _previewController = controller;
                    
                    controller.sourcePointForItem = ^(id item)
                    {
                        __strong TGStickerKeyboardView *strongSelf = weakSelf;
                        if (strongSelf == nil)
                            return CGPointZero;
                        
                        for (TGStickerCollectionViewCell *cell in strongSelf->_collectionView.visibleCells)
                        {
                            if ([cell.documentMedia isEqual:item])
                            {
                                NSIndexPath *indexPath = [strongSelf->_collectionView indexPathForCell:cell];
                                if (indexPath != nil)
                                    return [strongSelf->_collectionView convertPoint:cell.center toView:nil];
                            }
                        }
                        
                        return CGPointZero;
                    };
                    
                    TGDocumentMediaAttachment *sticker = [self documentAtIndexPath:indexPath];
                    TGStickerPack *stickerPack = [self stickerPackAtIndexPath:indexPath];
                    
                    [previewView setSticker:sticker stickerPack:stickerPack recent:isRecent];
                    
                    [cell setHighlightedWithBounce:true];
                }
                
                break;
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        for (TGStickerCollectionViewCell *cell in [_collectionView visibleCells])
            [cell setHighlightedWithBounce:false];
        
        TGItemPreviewController *controller = _previewController;
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        if (previewView.isLocked)
            return;
        
        [controller dismiss];
    }
}

- (void)handleStickerPan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (_previewController != nil && gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        if (previewView.isLocked)
            return;
        
        CGPoint point = [gestureRecognizer locationInView:_collectionView];
        CGPoint relativePoint = [gestureRecognizer locationInView:self];
        
        if (CGRectContainsPoint(CGRectOffset(_collectionView.frame, 0, preloadInset), relativePoint))
        {
            for (NSIndexPath *indexPath in [_collectionView indexPathsForVisibleItems])
            {
                TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
                if (CGRectContainsPoint(cell.frame, point))
                {
                    TGDocumentMediaAttachment *sticker = [self documentAtIndexPath:indexPath];
                    TGStickerPack *stickerPack = [self stickerPackAtIndexPath:indexPath];
                    if (sticker != nil)
                    {
                        bool isRecent = _recentDocuments.count > 0 && indexPath.section == 0;
                        [previewView setSticker:sticker stickerPack:stickerPack recent:isRecent];
                    }
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

- (void)handleForceTouch:(TGForceTouchGestureRecognizer *)gestureRecognizer
{
    if (_previewController != nil && gestureRecognizer.state == UIGestureRecognizerStateRecognized)
    {
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        [previewView presentActions];
        
        if (fabs(CFAbsoluteTimeGetCurrent() - previewView.lastFeedbackTime) > 1.0)
            AudioServicesPlaySystemSound(1519);
    }
}

- (void)handleTabPan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (_mode == TGStickerKeyboardViewModeGifs)
        return;
    
    CGPoint translation = [gestureRecognizer translationInView:nil];
    if (_expanded)
        translation.y = MAX(0.0f, translation.y);
    else
        translation.y = MIN(0.0f, translation.y);
    
    CGPoint velocity = [gestureRecognizer velocityInView:nil];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        if (self.expandInteraction != nil)
            self.expandInteraction(translation.y);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.requestedExpand == nil)
            return;
        
        if (_expanded)
        {
            if (translation.y > 100 || velocity.y > 200.0f)
                self.requestedExpand(false);
            else
                self.requestedExpand(true);
        }
        else
        {
            if (translation.y < -100 || velocity.y < -200.0f)
                self.requestedExpand(true);
            else
                self.requestedExpand(false);
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        self.requestedExpand(_expanded);
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _tabPanRecognizer)
    {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        
        CGPoint velocity = [panGestureRecognizer velocityInView:gestureRecognizer.view];
        
        if (fabs(velocity.x) > fabs(velocity.y))
            return false;
        
        if (_expanded)
            return velocity.y > 2.0f;
        else
            return velocity.y < 2.0f;
    }
    
    return true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == _panRecognizer || otherGestureRecognizer == _panRecognizer)
        return true;
    
    if (gestureRecognizer == _forceTouchRecognizer || otherGestureRecognizer == _forceTouchRecognizer)
        return true;
    
    return false;
}

- (void)setMode:(TGStickerKeyboardViewMode)mode {
    if (_mode != mode) {
        _mode = mode;
        
        if (_gifTabActive) {
            _gifTabActive(_mode == TGStickerKeyboardViewModeGifs);
        }
        
        CGSize size = self.bounds.size;
        
        [UIView animateWithDuration:0.2 animations:^{
            if (_mode == TGStickerKeyboardViewModeStickers) {
                _collectionView.frame = CGRectMake(0.0f, -preloadInset, size.width, size.height + preloadInset * 2.0f);
                _gifsCollectionView.frame = CGRectMake(-size.width, -gifInset, size.width, size.height + gifInset * 2.0f);
                _trendingCollectionView.frame = CGRectMake(size.width, -gifInset, size.width, size.height + gifInset * 2.0f);
            } else if (_mode == TGStickerKeyboardViewModeGifs) {
                _collectionView.frame = CGRectMake(size.width, -preloadInset, size.width, size.height + preloadInset * 2.0f);
                _gifsCollectionView.frame = CGRectMake(0.0f, -gifInset, size.width, size.height + gifInset * 2.0f);
                _trendingCollectionView.frame = CGRectMake(size.width * 2.0f, -gifInset, size.width, size.height + gifInset * 2.0f);
            } else {
                _collectionView.frame = CGRectMake(-size.width * 2.0, -preloadInset, size.width, size.height + preloadInset * 2.0f);
                _gifsCollectionView.frame = CGRectMake(-size.width, -gifInset, size.width, size.height + gifInset * 2.0f);
                _trendingCollectionView.frame = CGRectMake(0.0f, -gifInset, size.width, size.height + gifInset * 2.0f);
            }
        }];
        
        if (mode == TGStickerKeyboardViewModeGifs)
        {
            if (_recentDocuments.count != 0)
            {
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:false];
            }
            else
            {
                [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:false];
            }
        }
        else
        {
            [_gifsCollectionView setContentOffset:_gifsCollectionView.contentOffset animated:false];
        }
        
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

- (void)installStickerPack:(TGStickerPack *)stickerPack {
    __weak TGViewController *weakParentController = _parentViewController;
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.1];
    SSignal *installStickerPackAndGetArchivedSignal = false ? [TGStickersSignals installStickerPackAndGetArchived:stickerPack.packReference] : [TGStickersSignals installStickerPackAndGetArchived:stickerPack.packReference];
    [[[installStickerPackAndGetArchivedSignal deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:^(NSArray *archivedPacks) {
        __strong TGViewController *parentController = weakParentController;
        if (parentController != nil) {
            if (archivedPacks.count != 0) {
                TGArchivedStickerPacksAlert *previewWindow = [[TGArchivedStickerPacksAlert alloc] initWithParentController:parentController stickerPacks:archivedPacks];
                __weak TGArchivedStickerPacksAlert *weakPreviewWindow = previewWindow;
                previewWindow.view.dismiss = ^
                {
                    __strong TGArchivedStickerPacksAlert *strongPreviewWindow = weakPreviewWindow;
                    if (strongPreviewWindow != nil)
                        [strongPreviewWindow dismiss];
                };
                previewWindow.hidden = false;
            }
        }
    }];
}

- (void)viewPack:(TGStickerPack *)stickerPack sticker:(TGDocumentMediaAttachment *)sticker recent:(bool)recent
{
    if (stickerPack == nil || !recent)
    {
        [self previewStickerPack:stickerPack sticker:sticker];
    }
    else
    {
        NSUInteger index = [_stickerPacks indexOfObject:stickerPack];
        [self scrollToSection:index + 1];
    }
}

- (void)previewStickerPack:(TGStickerPack *)stickerPack sticker:(TGDocumentMediaAttachment *)sticker {
    TGViewController *parentViewController = _parentViewController;
    
    TGOverlayController *innerController = [[TGOverlayController alloc] init];
    innerController.view.backgroundColor = [UIColor clearColor];
    
    __weak TGStickerKeyboardView *weakSelf = self;
    TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:parentViewController contentController:innerController keepKeyboard:true];
    controllerWindow.dismissByMenuSheet = true;
    controllerWindow.windowLevel = 100000000.0f + 0.002f;
    controllerWindow.hidden = false;
    
    CGRect sourceRect = CGRectMake(CGFloor(self.bounds.size.width / 2.0f), [UIScreen mainScreen].bounds.size.height, 0.0f, 0.0f);
    
    id<TGStickerPackReference> packReference = stickerPack == nil ? sticker.stickerPackReference : nil;
    [TGStickersMenu presentWithParentController:innerController packReference:packReference stickerPack:stickerPack showShareAction:false sendSticker:^(TGDocumentMediaAttachment *document) {
        __strong TGStickerKeyboardView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (strongSelf.stickerSelected) {
                strongSelf.stickerSelected(document);
            }
        }
    } stickerPackRemoved:nil stickerPackHidden:nil stickerPackArchived:false stickerPackIsMask:stickerPack.isMask sourceView:innerController.view sourceRect:^CGRect{
        return sourceRect;
    } centered:true existingController:nil];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)__unused cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _trendingCollectionView) {
        TGStickerPack *pack = _trendingStickerPacks[indexPath.item];
        int64_t packId = 0;
        if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
            packId = ((TGStickerPackIdReference *)pack.packReference).packId;
        }
        if (_alreadyReadFeaturedPackIds == nil) {
            _alreadyReadFeaturedPackIds = [[NSMutableSet alloc] init];
        }
        if (![_alreadyReadFeaturedPackIds containsObject:@(packId)]) {
            [_alreadyReadFeaturedPackIds addObject:@(packId)];
            [self scheduleReadFeaturedPackId:packId];
        }
    }
}

- (void)scheduleReadFeaturedPackId:(int64_t)packId {
    [_accumulatedReadFeaturedPackIdsTimer invalidate];
    if (_accumulatedReadFeaturedPackIds == nil) {
        _accumulatedReadFeaturedPackIds = [[SAtomic alloc] initWithValue:nil];
    }
    [_accumulatedReadFeaturedPackIds modify:^id(NSArray *packIds) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([packIds count] != 0) {
            [array addObjectsFromArray:packIds];
        }
        [array addObject:@(packId)];
        return array;
    }];
    __weak TGStickerKeyboardView *weakSelf = self;
    _accumulatedReadFeaturedPackIdsTimer = [[STimer alloc] initWithTimeout:0.2 repeat:false completion:^{
        __strong TGStickerKeyboardView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf commitReadFeaturedPackIds];
        }
    } queue:[SQueue mainQueue]];
    [_accumulatedReadFeaturedPackIdsTimer start];
}

- (void)commitReadFeaturedPackIds {
    NSArray *packIds = [_accumulatedReadFeaturedPackIds swap:nil];
    [TGStickersSignals markFeaturedStickerPackAsRead:packIds];
}

- (bool)isExpanded
{
    return _expanded;
}

- (void)setExpanded:(bool)expanded
{
    _expanded = expanded;
    [_tabPanel setExpanded:expanded];
    
    _tabPanel.frame = CGRectMake(_tabPanel.frame.origin.x, 0.0f, _tabPanel.frame.size.width, _tabPanel.frame.size.height);
    [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
}

- (void)updateExpanded
{
    [_tabPanel updateExpanded:true];
}

- (CGFloat)preferredHeight:(bool)landscape
{
    if (TGIsPad())
        return landscape ? 398.0f : 313.0f;
    
    if ([TGViewController hasVeryLargeScreen])
        return landscape ? 194.0f : 271.0f;
    else if ([TGViewController hasLargeScreen])
        return landscape ? 194.0f : 258.0f;
    else if ([TGViewController isWidescreen])
        return landscape ? 193.0f : 253.0f;
    
    return landscape ? 193.0f : 253.0f;
}

- (bool)isInteracting
{
    return _tabPanRecognizer.state == UIGestureRecognizerStateChanged;
}

- (bool)isGif
{
    return _mode == TGStickerKeyboardViewModeGifs;
}

@end
