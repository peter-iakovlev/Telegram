#import "TGStickerKeyboardView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <AudioToolbox/AudioToolbox.h>

#import "TGAppDelegate.h"
#import "TGStickerPacksSettingsController.h"
#import "TGChannelStickersController.h"

#import "TGDatabase.h"

#import <LegacyComponents/TGStickerCollectionViewCell.h>
#import "TGStickerCollectionHeader.h"
#import <LegacyComponents/TGStickerKeyboardTabPanel.h>

#import "TGGifKeyboardCell.h"

#import "TGGifKeyboardBalancedLayout.h"

#import <LegacyComponents/TGSearchBar.h>
#import <LegacyComponents/TGMenuView.h>
#import <LegacyComponents/TGTimerTarget.h>

#import <LegacyComponents/TGItemPreviewController.h>
#import <LegacyComponents/TGStickerItemPreviewView.h>

#import <LegacyComponents/TGItemMenuSheetPreviewView.h>
#import <LegacyComponents/TGMenuSheetButtonItemView.h>
#import "TGPreviewGifItemView.h"
#import "TGPreviewMenu.h"

#import "TGRecentStickersSignal.h"
#import "TGFavoriteStickersSignal.h"

#import "TGTrendingStickerPackKeyboardCell.h"
#import "TGStickerGroupPackCell.h"

#import <LegacyComponents/TGProgressWindow.h>
#import "TGArchivedStickerPacksAlert.h"

#import "TGStickersMenu.h"

#import "TGForceTouchGestureRecognizer.h"

#import "TGStickersSignals.h"
#import "TGMaskStickersSignals.h"
#import "TGRecentGifsSignal.h"
#import "TGEmojiSuggestions.h"

#import "TGLegacyComponentsContext.h"

#import "TGPresentation.h"

static const CGFloat preloadInset = 160.0f;
static const CGFloat gifInset = 128.0f;

typedef enum {
    TGStickerKeyboardViewModeStickers = 0,
    TGStickerKeyboardViewModeGifs,
    TGStickerKeyboardViewModeTrendingFirst,
    TGStickerKeyboardViewModeTrendingLast
} TGStickerKeyboardViewMode;

@interface TGStickerKeyboardCollectionView : UICollectionView

@property (nonatomic, assign) bool blockScrolling;
- (void)setForcedContentOffset:(CGPoint)contentOffset animated:(bool)animated;

@end

@interface TGStickerKeyboardView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TGGifKeyboardBalancedLayoutDelegate, UIGestureRecognizerDelegate, TGSearchBarDelegate>
{
    bool _didScroll;
    id<SDisposable> _stickerPacksDisposable;
    id<SDisposable> _updatedFeaturedStickerPacksDisposable;
    SPipe *_pinPipe;
    
    TGStickerKeyboardViewStyle _style;
    TGStickerKeyboardTabPanel *_tabPanel;
    CGFloat _lastContentOffset;
    
    UICollectionView *_gifsCollectionView;
    TGGifKeyboardBalancedLayout *_gifsCollectionLayout;
    
    UICollectionView *_trendingCollectionView;
    UICollectionViewFlowLayout *_trendingCollectionLayout;
    
    TGStickerKeyboardCollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionLayout;
    NSMapTable *_visibleCollectionReusableHeaderViews;
    
    bool _shouldScrollToHideSearchBar;
    CGFloat _draggingStartOffset;
    bool _searchActive;
    TGSearchBar *_searchBar;
    UIView *_searchWrapperView;
    UIImageView *_searchMaskView;
    UICollectionView *_searchCollectionView;
    UICollectionViewFlowLayout *_searchCollectionLayout;
    SMetaDisposable *_queryDisposable;
    SMetaDisposable *_searchDisposable;
    NSArray *_searchLocalStickerPacks;
    NSArray *_searchRemoteStickerPacks;
    NSMapTable *_searchVisibleCollectionReusableHeaderViews;
    SMetaDisposable *_emojiDisposable;
    NSArray *_searchEmojiQuery;
    UIImageView *_stickersPlaceholderImageView;
    UILabel *_stickersPlaceholderLabel;
    SVariable *_searchEmojiStickers;
    
    bool _autorotationWasEnabled;
    
    UIView *_topStripe;
    
    NSArray *_stickerPacks;
    NSArray *_recentStickersOriginal;
    NSArray *_recentStickersSorted;
    NSArray *_recentDocuments;
    
    NSArray *_favoriteDocuments;
    NSArray *_groupDocuments;
    bool _showGroupPlaceholder;
    bool _isGroupAdmin;
    bool _groupStickersUnpinned;
    int64_t _groupStickerPackId;
    int64_t _peerId;
    NSString *_groupTitle;

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
    
    UIPanGestureRecognizer *_trendingPanRecognizer;
    TGForceTouchGestureRecognizer *_trendingForceTouchRecognizer;
    
    UIPanGestureRecognizer *_searchPanRecognizer;
    TGForceTouchGestureRecognizer *_searchForceTouchRecognizer;
    
    UIPanGestureRecognizer *_tabPanRecognizer;
    
    TGStickerKeyboardViewMode _mode;
    
    bool _ignoreSetSection;
    
    bool _ignoreGifCellContents;
    
    TGMenuContainerView *_menuContainerView;
    
    TGItemPreviewHandle *_stickersPreviewHandle;
    TGItemPreviewHandle *_gifPreviewHandle;
    
    __weak TGItemPreviewController *_previewController;
    __weak TGMenuSheetButtonItemView *_faveItem;
    
    SAtomic *_accumulatedReadFeaturedPackIds;
    STimer *_accumulatedReadFeaturedPackIdsTimer;
    NSMutableSet *_alreadyReadFeaturedPackIds;
    
    NSTimer *_actionsTimer;
    
    bool _expanded;
    
    void (^_openGroupStickerPackSettings)(void);
}

@end

@implementation TGStickerKeyboardView

@synthesize safeAreaInset = _safeAreaInset;
@synthesize presentation = _presentation;

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame style:TGStickerKeyboardViewDefaultStyle];
}

- (instancetype)initWithFrame:(CGRect)frame style:(TGStickerKeyboardViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _pinPipe = [[SPipe alloc] init];
        
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
        _collectionView = [[TGStickerKeyboardCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionLayout];
        if (iosMajorVersion() >= 11)
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.opaque = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.alwaysBounceVertical = true;
        _collectionView.delaysContentTouches = false;
        _collectionView.contentInset = UIEdgeInsetsMake(tabPanelHeight + preloadInset + [self searchBarInset], 0.0f, preloadInset, 0.0f);
        [_collectionView registerClass:[TGStickerCollectionViewCell class] forCellWithReuseIdentifier:@"TGStickerCollectionViewCell"];
        [_collectionView registerClass:[TGStickerGroupPackCell class] forCellWithReuseIdentifier:@"TGStickerGroupPackCell"];
        [_collectionView registerClass:[TGStickerCollectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TGStickerCollectionHeader"];
        [self addSubview:_collectionView];
        _visibleCollectionReusableHeaderViews = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    
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
        
        UILongPressGestureRecognizer *trendingTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTrendingStickerPress:)];
        trendingTapRecognizer.minimumPressDuration = 0.25;
        [_trendingCollectionView addGestureRecognizer:trendingTapRecognizer];
        
        _trendingPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTrendingStickerPan:)];
        _trendingPanRecognizer.delegate = self;
        _trendingPanRecognizer.cancelsTouchesInView = false;
        [_trendingCollectionView addGestureRecognizer:_trendingPanRecognizer];
        
        _gifsCollectionLayout = [[TGGifKeyboardBalancedLayout alloc] init];
        _gifsCollectionLayout.preferredRowSize = TGIsPad() ? 145.0f : 93.0f;
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
        
        if (_style == TGStickerKeyboardViewDefaultStyle)
        {
            _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectZero style:TGSearchBarStyleKeyboard];
            _searchBar.delegate = self;
            _searchBar.placeholder = TGLocalized(@"Stickers.Search");
            [_searchBar sizeToFit];
            _searchBar.delayActivity = false;
            [_searchBar customCancelButton];
            [_collectionView addSubview:_searchBar];
            
            _queryDisposable = [[SMetaDisposable alloc] init];
            _searchDisposable = [[SMetaDisposable alloc] init];
            _emojiDisposable = [[SMetaDisposable alloc] init];
            _searchEmojiStickers = [[SVariable alloc] init];
        
            _searchWrapperView = [[UIView alloc] init];
            _searchWrapperView.backgroundColor = self.backgroundColor;
            _searchWrapperView.clipsToBounds = true;
            _searchWrapperView.hidden = true;
            [self addSubview:_searchWrapperView];
            
            _searchCollectionLayout = [[UICollectionViewFlowLayout alloc] init];
            _searchCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_searchCollectionLayout];
            _searchCollectionView.delegate = self;
            _searchCollectionView.dataSource = self;
            _searchCollectionView.backgroundColor = [UIColor clearColor];
            _searchCollectionView.opaque = false;
            _searchCollectionView.showsHorizontalScrollIndicator = false;
            _searchCollectionView.showsVerticalScrollIndicator = false;
            _searchCollectionView.alwaysBounceVertical = true;
            _searchCollectionView.delaysContentTouches = false;
            _searchCollectionView.contentInset = UIEdgeInsetsMake(preloadInset, 0.0f, preloadInset, 0.0f);
            [_searchCollectionView registerClass:[TGStickerCollectionViewCell class] forCellWithReuseIdentifier:@"TGStickerCollectionViewCell"];
            [_searchCollectionView registerClass:[TGTrendingStickerPackKeyboardCell class] forCellWithReuseIdentifier:@"TGTrendingStickerPackKeyboardCell"];
            [_searchCollectionView registerClass:[TGStickerCollectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TGStickerCollectionHeader"];
            [_searchWrapperView addSubview:_searchCollectionView];
            _searchVisibleCollectionReusableHeaderViews = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
            
            _searchMaskView = [[UIImageView alloc] init];
            [_searchWrapperView addSubview:_searchMaskView];
            
            UILongPressGestureRecognizer *searchtapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSearchStickerPress:)];
            searchtapRecognizer.minimumPressDuration = 0.25;
            [_searchCollectionView addGestureRecognizer:searchtapRecognizer];
            
            _searchPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSearchStickerPan:)];
            _searchPanRecognizer.delegate = self;
            _searchPanRecognizer.cancelsTouchesInView = false;
            [_searchCollectionView addGestureRecognizer:_searchPanRecognizer];
            
            _stickersPlaceholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 90.0f, 90.0f)];
            _stickersPlaceholderImageView.hidden = true;
            [_searchWrapperView addSubview:_stickersPlaceholderImageView];
            
            _stickersPlaceholderLabel = [[UILabel alloc] init];
            _stickersPlaceholderLabel.backgroundColor = [UIColor clearColor];
            _stickersPlaceholderLabel.font = TGMediumSystemFontOfSize(14.0f);
            _stickersPlaceholderLabel.text = TGLocalized(@"Stickers.NoStickersFound");
            _stickersPlaceholderLabel.textAlignment = NSTextAlignmentCenter;
            _stickersPlaceholderLabel.hidden = true;
            [_stickersPlaceholderLabel sizeToFit];
            [_searchWrapperView addSubview:_stickersPlaceholderLabel];
        }
        
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
                [strongSelf scrollToSection:index fromGifs:fromGifs animated:true];
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
        
        [self setupSignals];
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
                        
                        TGItemMenuSheetPreviewView *previewView = [[TGItemMenuSheetPreviewView alloc] initWithContext:[TGLegacyComponentsContext shared] mainItemViews:@[ gifItem ] actionItemViews:@[ deleteItem, sendItem ]];
                        
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
                        
                        controller = [[TGItemPreviewController alloc] initWithContext:[TGLegacyComponentsContext shared] parentController:parentViewController previewView:previewView];
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

- (CGFloat)searchBarInset
{
    return _style == TGStickerKeyboardViewDefaultStyle ? 50.0f : 0.0f;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    
    [_searchBar setPallete:presentation.keyboardSearchBarPallete];
    _tabPanel.pallete = presentation.stickerKeyboardPallete;
    self.backgroundColor = presentation.pallete.chatInputKeyboardBackgroundColor;
    _searchWrapperView.backgroundColor = self.backgroundColor;
    
    _stickersPlaceholderImageView.image = presentation.images.chatStickersPlaceholderImage;
    _stickersPlaceholderLabel.textColor = presentation.pallete.chatInputButtonColor;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2.0f, 10.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *whiteColor = self.backgroundColor;
    
    CGColorRef colors[2] = {
        CGColorRetain(whiteColor.CGColor),
        CGColorRetain([whiteColor colorWithAlphaComponent:0.0f].CGColor)
    };
    
    CFArrayRef colorsArray = CFArrayCreate(kCFAllocatorDefault, (const void **)&colors, 2, NULL);
    CGFloat locations[2] = {0.0f, 1.0f};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorsArray, (CGFloat const *)&locations);
    
    CFRelease(colorsArray);
    CFRelease(colors[0]);
    CFRelease(colors[1]);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, 10.0f), 0);
    
    CFRelease(gradient);
    
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _searchMaskView.image = maskImage;
    
    for (UICollectionViewCell *cell in _collectionView.visibleCells)
    {
        if ([cell respondsToSelector:@selector(setPresentation:)])
            [cell performSelector:@selector(setPresentation:) withObject:presentation];
    }
    
    for (UICollectionViewCell *cell in _trendingCollectionView.visibleCells)
    {
        if ([cell respondsToSelector:@selector(setPresentation:)])
            [cell performSelector:@selector(setPresentation:) withObject:presentation];
    }
    
    for (UICollectionViewCell *cell in _searchCollectionView.visibleCells)
    {
        if ([cell respondsToSelector:@selector(setPresentation:)])
            [cell performSelector:@selector(setPresentation:) withObject:presentation];
    }
}

- (void)updateInsets
{
    CGFloat tabPanelHeight = 45.0f;
    if (_style == TGStickerKeyboardViewDefaultStyle)
        tabPanelHeight -= 3.0f;
    
    _collectionView.contentInset = UIEdgeInsetsMake(tabPanelHeight + preloadInset + [self searchBarInset], 0.0f, preloadInset + _safeAreaInset.bottom, 0.0f);
    _trendingCollectionView.contentInset = UIEdgeInsetsMake(tabPanelHeight + gifInset, 0.0f, gifInset + _safeAreaInset.bottom, 0.0f);
    _gifsCollectionView.contentInset = UIEdgeInsetsMake(tabPanelHeight + gifInset, 0.0f, gifInset + _safeAreaInset.bottom, 0.0f);
    
    _searchCollectionView.contentInset = UIEdgeInsetsMake(preloadInset, 0.0f, preloadInset + _safeAreaInset.bottom, 0.0f);
}

- (void)setChannelInfoSignal:(SSignal *)channelInfoSignal
{
    _channelInfoSignal = channelInfoSignal;
    [self setupSignals];
}

- (void)updateGroupStickersHeader:(TGStickerCollectionHeader *)header
{
    bool isAdmin = _isGroupAdmin;
    bool isUnpinned = _groupStickersUnpinned;
    bool hasStickers = _groupDocuments.count > 0;
    
    __weak TGStickerKeyboardView *weakSelf = self;
    header.accessoryPressed = ^{
        __strong TGStickerKeyboardView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (isAdmin)
        {
            if (hasStickers)
            {
                if (strongSelf->_openGroupStickerPackSettings != nil)
                    strongSelf->_openGroupStickerPackSettings();
            }
            else
            {
                [strongSelf unpinGroupStickers];
            }
        }
        else
        {
            if (!isUnpinned)
            {
                [strongSelf unpinGroupStickers];
            }
        }
    };
    
    if (hasStickers && isAdmin)
    {
        header.icon = TGImageNamed(@"StickersGroupSettings");
    }
    else
    {
        if (!isUnpinned)
            header.icon = TGImageNamed(@"StickersGroupCross");
        else
            header.icon = nil;
    }
    
    header.title = [NSString stringWithFormat:TGLocalized(@"Stickers.GroupStickers"), _groupTitle];
}

- (void)unpinGroupStickers
{
    if (_peerId == 0)
        return;
    
    int64_t packId = _groupStickerPackId;
    if (packId == 0)
        packId = -1;
    
    [TGDatabaseInstance() storeGroupStickerPackUnpinned:packId forPeerId:_peerId];
    _pinPipe.sink(@true);
}

- (void)setupSignals
{
    SSignal *groupStickersSignal = [SSignal single:@{}];
    if (self.channelInfoSignal != nil)
    {
        groupStickersSignal = [self.channelInfoSignal mapToSignal:^SSignal *(NSDictionary *dict) {
            TGCachedConversationData *data = dict[@"data"];
            if (data == nil)
                data = [[TGCachedConversationData alloc] init];
            
            if (data.stickerPack == nil) {
                return [SSignal single:@{@"conversation":dict[@"conversation"], @"data": data}];
            } else {
                return [[TGStickersSignals cachedStickerPack:data.stickerPack] map:^id(TGStickerPack *stickerPack) {
                    return @{@"conversation":dict[@"conversation"], @"data":data, @"stickerPack":stickerPack};
                }];
            }
        }];
    }
    
    SVariable *pinVar = [[SVariable alloc] init];
    [pinVar set:_pinPipe.signalProducer()];
    _pinPipe.sink(@true);
    
    SSignal *combinedSignal = [SSignal combineSignals:@[(iosMajorVersion() >= 8 && _style == TGStickerKeyboardViewDefaultStyle) ? [TGRecentGifsSignal recentGifs] : [SSignal single:@[]], [[TGStickersSignals stickerPacks] startOn:[SQueue concurrentDefaultQueue]], [TGRecentStickersSignal recentStickers], [TGFavoriteStickersSignal favoriteStickers], groupStickersSignal, pinVar.signal]];
    
    __weak TGStickerKeyboardView *weakSelf = self;
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
        
        NSMutableSet *favoriteStickerIds = [[NSMutableSet alloc] init];
        NSMutableDictionary *documentToStickerPack = [[NSMutableDictionary alloc] init];
        NSMutableArray *reversedFavoriteStickers = [[NSMutableArray alloc] init];
        for (id item in [combinedResult[3] reverseObjectEnumerator]) {
            TGDocumentMediaAttachment *document = (TGDocumentMediaAttachment *)item;
            [reversedFavoriteStickers addObject:document];
            [favoriteStickerIds addObject:@(document.documentId)];
            if ([document.stickerPackReference isKindOfClass:[TGStickerPackIdReference class]]) {
                TGStickerPackIdReference *packReference = (TGStickerPackIdReference *)document.stickerPackReference;
                
                documentToStickerPack[@(document.documentId)] = packIdMap[@(packReference.packId)];
            }
        }
        
        NSMutableArray *reversedRecentStickers = [[NSMutableArray alloc] init];
        for (id item in [combinedResult[2][@"documents"] reverseObjectEnumerator]) {
            TGDocumentMediaAttachment *document = (TGDocumentMediaAttachment *)item;
            
            if (![favoriteStickerIds containsObject:@(document.documentId)]) {
                [reversedRecentStickers addObject:item];
            
                if ([document.stickerPackReference isKindOfClass:[TGStickerPackIdReference class]]) {
                    TGStickerPackIdReference *packReference = (TGStickerPackIdReference *)document.stickerPackReference;
                    
                    documentToStickerPack[@(document.documentId)] = packIdMap[@(packReference.packId)];
                }
            }
        }
        
        NSDictionary *groupStickersInfo = combinedResult[4];
        TGStickerPack *groupStickerPack = (TGStickerPack *)groupStickersInfo[@"stickerPack"];
        TGStickerPackIdReference *groupStickerPackReference = [groupStickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]] ? groupStickerPack.packReference : nil;
        NSArray *groupStickers = [groupStickerPack documents];
        
        __strong TGStickerKeyboardView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            strongSelf->_recentDocumentToStickerPack = documentToStickerPack;
            strongSelf->_groupStickerPackId = groupStickerPackReference.packId;
            
            TGConversation *conversation = (TGConversation *)groupStickersInfo[@"conversation"];
            TGCachedConversationData *conversationData = (TGCachedConversationData *)groupStickersInfo[@"data"];
            if (conversation != nil)
            {
                strongSelf->_peerId = conversation.conversationId;
                strongSelf->_isGroupAdmin = (conversation.channelRole == TGChannelRoleCreator || conversation.channelAdminRights.canChangeInfo);
                strongSelf->_groupTitle = conversation.chatTitle;
            }
            
            if (strongSelf->_peerId != 0)
            {
                int64_t unpinnedPackId = [TGDatabaseInstance() groupStickerPackUnpinned:strongSelf->_peerId];
                strongSelf->_groupStickersUnpinned = (groupStickerPackReference.packId != 0 && unpinnedPackId == groupStickerPackReference.packId) || unpinnedPackId == -1;
                [strongSelf->_tabPanel setAvatarUrl:conversation.chatPhotoSmall peerId:conversation.conversationId title:conversation.chatTitle];
                
                if (unpinnedPackId != 0 && !strongSelf->_groupStickersUnpinned)
                    [TGDatabaseInstance() storeGroupStickerPackUnpinned:0 forPeerId:strongSelf->_peerId];
            }
            
            bool hasGroupStickerPack = false;
            if (groupStickerPackReference != nil) {
                for (TGStickerPack *stickerPack in reversed)
                {
                    if ([stickerPack.packReference isEqual:groupStickerPackReference]) {
                        hasGroupStickerPack = true;
                        break;
                    }
                }
            }
            
            if (strongSelf->_isGroupAdmin)
            {
                strongSelf->_showGroupPlaceholder = groupStickers.count == 0 && conversationData.canSetStickerPack;
                if (groupStickers.count > 0 && strongSelf->_groupStickersUnpinned)
                {
                    strongSelf->_groupStickersUnpinned = false;
                    [TGDatabaseInstance() storeGroupStickerPackUnpinned:0 forPeerId:strongSelf->_peerId];
                }
                
                strongSelf->_openGroupStickerPackSettings = ^{
                    __strong TGStickerKeyboardView *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        TGChannelStickersController *stickersController = [[TGChannelStickersController alloc] initWithConversation:conversation];
                        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[stickersController]];
                        [strongSelf->_parentViewController presentViewController:navigationController animated:true completion:nil];
                    }
                };
            }
            else
            {
                strongSelf->_showGroupPlaceholder = false;
                if (hasGroupStickerPack)
                    groupStickers = @[];
            }
            
            TGStickerCollectionHeader *header = [strongSelf->_visibleCollectionReusableHeaderViews objectForKey:[NSIndexPath indexPathForItem:0 inSection:2]];
            if (header == nil)
                header = [strongSelf->_visibleCollectionReusableHeaderViews objectForKey:[NSIndexPath indexPathForItem:0 inSection:[strongSelf lastGroupSection]]];
            
            [strongSelf updateGroupStickersHeader:header];
            
            NSUInteger unreadFeaturedCount = ((NSArray *)dict[@"featuredPacksUnreadIds"]).count;
            [strongSelf setTrendingBadge:unreadFeaturedCount == 0 ? nil : [NSString stringWithFormat:@"%d", (int)unreadFeaturedCount]];
            NSMutableSet *unreadPacks = [[NSMutableSet alloc] init];
            for (NSNumber *nPackId in dict[@"featuredPacksUnreadIds"]) {
                [unreadPacks addObject:nPackId];
            }
            
            if (![strongSelf->_stickerPacks isEqual:reversed] || ![strongSelf->_recentStickersOriginal isEqual:reversedRecentStickers] || ![strongSelf->_favoriteDocuments isEqual:reversedFavoriteStickers] || ![strongSelf->_groupDocuments isEqual:groupStickers]) {
                NSArray *updatedRecentStickers = nil;
                if (strongSelf->_recentStickersOriginal == nil) {
                    strongSelf->_recentStickersOriginal = reversedRecentStickers;
                    updatedRecentStickers = reversedRecentStickers;
                } else {
                    strongSelf->_recentStickersOriginal = reversedRecentStickers;
                    updatedRecentStickers = strongSelf->_recentStickersSorted;
                }
                [strongSelf setStickerPacks:reversed recentStickers:updatedRecentStickers favoriteStickers:reversedFavoriteStickers groupStickers:groupStickers];
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
            
            [strongSelf setUnreadTrendingPacks:unreadPacks];
            
            [strongSelf updateCurrentSection];
            
            if (strongSelf->_stickerPacks.count == 0 && strongSelf->_favoriteDocuments.count == 0 & strongSelf->_recentDocuments.count == 0 && strongSelf->_groupDocuments.count == 0)
            {
                [strongSelf setMode:[strongSelf showTrendingFirst] ? TGStickerKeyboardViewModeTrendingFirst : TGStickerKeyboardViewModeTrendingLast];
            }
        }
    }];
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
    if (_trendingForceTouchRecognizer == nil)
    {
        _trendingForceTouchRecognizer = [[TGForceTouchGestureRecognizer alloc] initWithTarget:self action:@selector(handleForceTouch:)];
        _trendingForceTouchRecognizer.delegate = self;
        [_trendingCollectionView addGestureRecognizer:_trendingForceTouchRecognizer];
        
        if (![_trendingForceTouchRecognizer forceTouchAvailable])
            _trendingForceTouchRecognizer.enabled = false;
    }
    if (_searchForceTouchRecognizer == nil)
    {
        _searchForceTouchRecognizer = [[TGForceTouchGestureRecognizer alloc] initWithTarget:self action:@selector(handleForceTouch:)];
        _searchForceTouchRecognizer.delegate = self;
        [_searchCollectionView addGestureRecognizer:_searchForceTouchRecognizer];
        
        if (![_searchForceTouchRecognizer forceTouchAvailable])
            _searchForceTouchRecognizer.enabled = false;
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

- (void)setSafeAreaInset:(UIEdgeInsets)safeAreaInset
{
    if (UIEdgeInsetsEqualToEdgeInsets(_safeAreaInset, safeAreaInset))
        return;
    
    _safeAreaInset = safeAreaInset;
    _tabPanel.safeAreaInset = safeAreaInset;
    [self updateInsets];
    if (!UIEdgeInsetsEqualToEdgeInsets(_safeAreaInset, UIEdgeInsetsZero))
        [self layoutForSize:self.bounds.size];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_expanded)
        return CGRectContainsPoint(CGRectMake(0, -15.0f, self.bounds.size.width, self.bounds.size.height + 15.0f), point);
    
    return [super pointInside:point withEvent:event];
}

- (void)layoutForSize:(CGSize)size
{
    if (!_collectionView.blockScrolling)
    {
        _tabPanel.frame = CGRectMake(0.0f, 0.0f, size.width, _tabPanel.frame.size.height);
        [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
    }
    
    CGFloat left = _safeAreaInset.left;
    CGFloat width = size.width - _safeAreaInset.left - _safeAreaInset.right;
    
    _searchBar.frame = CGRectMake(0.0f, -50.0f, width, [_searchBar baseHeight]);
    _searchMaskView.frame = CGRectMake(0.0f, 0.0, self.frame.size.width, 10.0f);
    
    if (_mode == TGStickerKeyboardViewModeStickers) {
        _collectionView.frame = CGRectMake(left, -preloadInset, width, size.height + preloadInset * 2.0f);
        _gifsCollectionView.frame = CGRectMake(-size.width + left, -gifInset, width, size.height + gifInset * 2.0f);
        _trendingCollectionView.frame = CGRectMake(size.width + left, -gifInset, width, size.height + gifInset * 2.0f);
    } else if (_mode == TGStickerKeyboardViewModeGifs) {
        _collectionView.frame = CGRectMake(size.width + left, -preloadInset, width, size.height + preloadInset * 2.0f);
        _gifsCollectionView.frame = CGRectMake(left, -gifInset, width, size.height + gifInset * 2.0f);
        _trendingCollectionView.frame = CGRectMake(size.width * 2.0f + left, -gifInset, width, size.height + gifInset * 2.0f);
    } else {
        _collectionView.frame = CGRectMake(-size.width * 2.0 + left, -preloadInset, width, size.height + preloadInset * 2.0f);
        _gifsCollectionView.frame = CGRectMake(-size.width + left, -gifInset, width, size.height + gifInset * 2.0f);
        _trendingCollectionView.frame = CGRectMake(left, -gifInset, width, size.height + gifInset * 2.0f);
    }
    [_collectionLayout invalidateLayout];
    [_gifsCollectionLayout invalidateLayout];
    [_trendingCollectionLayout invalidateLayout];
    
    _searchWrapperView.frame = CGRectMake(left, 96.0f, width, size.height - 96.0f);
    _searchCollectionView.frame = CGRectMake(0.0f, -preloadInset + 8.0f, width, size.height + preloadInset * 2.0f - 96.0f);
    [_searchCollectionLayout invalidateLayout];
    
    CGFloat placeholderCenter = floor((_searchWrapperView.frame.size.height - [TGStickerKeyboardView preferredHeight:false]) / 2.0f);
    _stickersPlaceholderImageView.frame = CGRectMake(floor((_searchWrapperView.frame.size.width - _stickersPlaceholderImageView.frame.size.width) / 2.0f), placeholderCenter - 50.0f, _stickersPlaceholderImageView.frame.size.width, _stickersPlaceholderImageView.frame.size.height);
    _stickersPlaceholderLabel.frame = CGRectMake((_searchWrapperView.frame.size.width - _stickersPlaceholderLabel.frame.size.width) / 2.0f, placeholderCenter + 50.0f, _stickersPlaceholderLabel.frame.size.width, _stickersPlaceholderLabel.frame.size.height);
    
    CGFloat stripeHeight = TGScreenPixel;
    _topStripe.frame = CGRectMake(0.0f, 0.0f, size.width, stripeHeight);
    
    if (_expanded && _collectionView.blockScrolling)
        [_collectionView setForcedContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:false];
    
    [self resetInitialScrollPosition];
}

- (void)resetInitialScrollPosition
{
    if (_searchBar != nil && !_expanded && _collectionView.contentOffset.y < -_collectionView.contentInset.top + 130.0f + FLT_EPSILON && _tabPanRecognizer.state != UIGestureRecognizerStateChanged)
        _collectionView.contentOffset = CGPointMake(0.0f, -_collectionView.contentInset.top + 50.0f);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == _gifsCollectionView) {
        return 1;
    } else if (collectionView == _trendingCollectionView) {
        return 1;
    } else if (collectionView == _collectionView) {
        return 4 + _stickerPacks.count;
    } else if (collectionView == _searchCollectionView) {
        return _searchLocalStickerPacks.count + 1;
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
            return (NSInteger)_favoriteDocuments.count;
        } else if (section == 1) {
            return (NSInteger)_recentDocuments.count;
        } else if (section == 2) {
            return _groupStickersUnpinned ? 0 : MAX(_showGroupPlaceholder ? 1 : 0, (NSInteger)_groupDocuments.count);
        } else if (section == [self lastGroupSection]) {
            return _groupStickersUnpinned ? MAX(_showGroupPlaceholder ? 1 : 0, (NSInteger)_groupDocuments.count) : 0;
        } else {
            return ((TGStickerPack *)_stickerPacks[section - 3]).documents.count;
        }
        return 0;
    } else if (collectionView == _searchCollectionView) {
        if (_searchLocalStickerPacks.count > 0 && section != (NSInteger)_searchLocalStickerPacks.count) {
            return ((TGStickerPack *)_searchLocalStickerPacks[section]).documents.count;
        } else {
            return _searchRemoteStickerPacks.count;
        }
    } else {
        return 0;
    }
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _gifsCollectionView) {
        return CGSizeMake(30.0f, 30.0f);
    } else if (collectionView == _trendingCollectionView) {
        return CGSizeMake(collectionViewLayout.collectionView.bounds.size.width, 124.0f);
    } else if (collectionView == _searchCollectionView) {
        if (_searchLocalStickerPacks.count > 0 && indexPath.section != (NSInteger)_searchLocalStickerPacks.count) {
            return CGSizeMake(62.0f, 62.0f);
        } else {
            return CGSizeMake(collectionViewLayout.collectionView.bounds.size.width, 124.0f);
        }
    } else {
        if (((indexPath.section == 2 && !_groupStickersUnpinned) || (indexPath.section == [self lastGroupSection] && _groupStickersUnpinned)) && _groupDocuments.count == 0 && _showGroupPlaceholder) {
            NSString *text = TGLocalized(@"Stickers.GroupStickersHelp");
            CGSize size = [text sizeWithFont:TGSystemFontOfSize(14.0f) constrainedToSize:CGSizeMake(collectionViewLayout.collectionView.bounds.size.width - 26.0f, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            
            return CGSizeMake(collectionViewLayout.collectionView.bounds.size.width, ceil(size.height) + 33.0f + 16.0f);
        } else {
            return CGSizeMake(62.0f, 62.0f);
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView == _gifsCollectionView) {
        return UIEdgeInsetsZero;
    } else if (collectionView == _trendingCollectionView) {
        return UIEdgeInsetsZero;
    } else if (collectionView == _searchCollectionView) {
        if (_searchLocalStickerPacks.count > 0 && section != (NSInteger)_searchLocalStickerPacks.count) {
            CGFloat topInset = 8.0f;
            CGFloat inset = 12.0f;
            CGFloat sideInset = (collectionView.frame.size.width < 330.0f) ? 3.0f : inset;
            return UIEdgeInsetsMake(topInset, sideInset, inset, sideInset);
        } else {
            return UIEdgeInsetsZero;
        }
    } else {
        CGFloat topInset = 8.0f;
        CGFloat inset = 12.0f;
        CGFloat sideInset = (collectionView.frame.size.width < 330.0f) ? 3.0f : inset;
        
        bool sectionVisible = true;
        if ((section == 0 && _favoriteDocuments.count == 0) || (section == 1 && _recentDocuments.count == 0) || (section == 2 && (_groupStickersUnpinned || (_groupDocuments.count == 0 && !_showGroupPlaceholder))) || (section == [self lastGroupSection] && (!_groupStickersUnpinned || (_groupDocuments.count == 0 && !_showGroupPlaceholder)))) {
            sectionVisible = false;
        }
        
        if (!sectionVisible)
            return UIEdgeInsetsZero;
        
        if (section == 0) {
            return UIEdgeInsetsMake(topInset, sideInset, [self collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section], sideInset);
        }
        
        if (section == 2 || section == [self lastGroupSection])
            topInset = 3.0f;
        
        if (section == [self lastGroupSection] && _showGroupPlaceholder) {
            return UIEdgeInsetsMake(topInset, sideInset, inset, sideInset);
        }
        
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
    if (scrollView == _searchCollectionView && scrollView.isTracking)
    {
        [_searchBar resignFirstResponder];
    }
    else if (scrollView == _collectionView || scrollView == _trendingCollectionView || (scrollView == _gifsCollectionView && _mode == TGStickerKeyboardViewModeGifs))
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
        
        if (_expanded && !_collectionView.blockScrolling)
            tabPanelFrame.origin.y = 0.0f;
        
        _tabPanel.frame = tabPanelFrame;
        [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
        
        if (!_ignoreSetSection && _mode != TGStickerKeyboardViewModeGifs) {
            [self updateCurrentSection];
        }
    }
    
    if (scrollView == _collectionView) {
        if (scrollView.isTracking)
            _didScroll = true;
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
        _draggingStartOffset = scrollView.contentOffset.y;
        
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

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)__unused velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (_searchBar == nil)
        return;
    
    if (scrollView == _collectionView)
    {
        if (targetContentOffset != NULL)
        {
            if (targetContentOffset->y > -scrollView.contentInset.top - FLT_EPSILON && targetContentOffset->y < -scrollView.contentInset.top + 50.0f + FLT_EPSILON)
            {
                if (_draggingStartOffset < -scrollView.contentInset.top + 25.0f)
                {
                    if (targetContentOffset->y < -scrollView.contentInset.top + 50.0f * 0.2)
                        targetContentOffset->y = -scrollView.contentInset.top;
                    else
                        targetContentOffset->y = -scrollView.contentInset.top + 50.0f;
                }
                else
                {
                    if (targetContentOffset->y < -scrollView.contentInset.top + 50.0f * 0.8)
                        targetContentOffset->y = -scrollView.contentInset.top;
                    else
                        targetContentOffset->y = -scrollView.contentInset.top + 50.0f;
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDragging:scrollView willDecelerate:false];
}

- (void)showTabPanel
{
    if (![TGViewController hasTallScreen])
        return;
    
    [_collectionView setContentOffset:_collectionView.contentOffset animated:false];
    [_trendingCollectionView setContentOffset:_trendingCollectionView.contentOffset animated:false];
    [_gifsCollectionView setContentOffset:_gifsCollectionView.contentOffset animated:false];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
    {
        CGRect frame = _tabPanel.frame;
        frame.origin.y = 0.0f;
        
        _tabPanel.frame = frame;
        [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
    } completion:nil];
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
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == [self lastGroupSection])
    {
        TGDocumentMediaAttachment *document = [self documentAtIndexPath:indexPath];
        return _recentDocumentToStickerPack[@(document.documentId)];
    }
    else
    {
        return _stickerPacks[indexPath.section - 3];
    }
}

- (NSInteger)lastGroupSection
{
    return 3 + _stickerPacks.count;
}

- (TGDocumentMediaAttachment *)documentAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return _favoriteDocuments[indexPath.item];
    else if (indexPath.section == 1)
        return _recentDocuments[indexPath.item];
    else if (indexPath.section == 2 || indexPath.section == [self lastGroupSection])
        return _groupDocuments[indexPath.item];
    else
        return ((TGStickerPack *)_stickerPacks[indexPath.section - 3]).documents[indexPath.item];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _searchCollectionView && [kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        if (indexPath.section < (NSInteger)_searchLocalStickerPacks.count)
        {
            TGStickerCollectionHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TGStickerCollectionHeader" forIndexPath:indexPath];
            view.presentation = self.presentation;
            
            NSString *title = [_searchLocalStickerPacks[indexPath.section] title];
            view.title = title;
            
            [_searchVisibleCollectionReusableHeaderViews setObject:view forKey:indexPath];
            
            return view;
        }
        else
        {
            return nil;
        }
    }
    else if (collectionView == _collectionView && [kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        if (indexPath.section == 0)
            return nil;
        
        TGStickerCollectionHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TGStickerCollectionHeader" forIndexPath:indexPath];
        view.presentation = self.presentation;
        
        NSString *title = nil;
        switch (indexPath.section) {
            case 0:
                title = TGLocalized(@"Stickers.FavoriteStickers");
                break;
                
            case 1:
                title = TGLocalized(@"Stickers.FrequentlyUsed");
                break;
                
            case 2:
                break;
                
            default:
                if (indexPath.section != [self lastGroupSection])
                    title = [_stickerPacks[indexPath.section - 3] title];
                break;
        }
        view.title = title;
        
        if (indexPath.section == 2 || indexPath.section == [self lastGroupSection])
            [self updateGroupStickersHeader:view];
        else
            view.icon = nil;
        
        [_visibleCollectionReusableHeaderViews setObject:view forKey:indexPath];
        
        return view;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (collectionView == _collectionView)
    {
        if (section == 0)
            return CGSizeZero;
        else if (section == 1 && _recentDocuments.count == 0)
            return CGSizeZero;
        else if (section == 2 && (_groupStickersUnpinned || (_groupDocuments.count == 0 && !_showGroupPlaceholder)))
            return CGSizeZero;
        else if (section == [self lastGroupSection] && (!_groupStickersUnpinned || (_groupDocuments.count == 0 && !_showGroupPlaceholder)))
            return CGSizeZero;
        
        return CGSizeMake(collectionView.bounds.size.width, 23.0f);
    }
    else if (collectionView == _searchCollectionView)
    {
        if (_searchLocalStickerPacks.count > 0 && section != (NSInteger)_searchLocalStickerPacks.count) {
            if ([_searchLocalStickerPacks.firstObject title] == nil)
                return CGSizeZero;
            else
                return CGSizeMake(collectionView.bounds.size.width, 23.0f);
        } else {
            return CGSizeZero;
        }
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
        cell.presentation = self.presentation;
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
    } else if (collectionView == _searchCollectionView) {
        if (_searchLocalStickerPacks.count > 0 && indexPath.section != (NSInteger)_searchLocalStickerPacks.count) {
            TGStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerCollectionViewCell" forIndexPath:indexPath];
            TGDocumentMediaAttachment *document = ((TGStickerPack *)_searchLocalStickerPacks[indexPath.section]).documents[indexPath.item];
            [cell setDocumentMedia:document];
            return cell;
        } else {
            TGTrendingStickerPackKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGTrendingStickerPackKeyboardCell" forIndexPath:indexPath];
            cell.presentation = self.presentation;
            TGStickerPack *pack = _searchRemoteStickerPacks[indexPath.item];
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
                    [strongSelf endEditing:true];
                    [strongSelf previewStickerPack:pack sticker:nil];
                }
            };
            return cell;
        }
    } else {
        if (((indexPath.section == 2 && !_groupStickersUnpinned) || (indexPath.section == [self lastGroupSection] && _groupStickersUnpinned)) && _groupDocuments.count == 0 && _showGroupPlaceholder) {
            __weak TGStickerKeyboardView *weakSelf = self;
            TGStickerGroupPackCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerGroupPackCell" forIndexPath:indexPath];
            cell.presentation = self.presentation;
            cell.pressed = ^{
                __strong TGStickerKeyboardView *strongSelf = weakSelf;
                if (strongSelf != nil && strongSelf->_openGroupStickerPackSettings) {
                    strongSelf->_openGroupStickerPackSettings();
                }
            };
            return cell;
        } else {
            TGStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TGStickerCollectionViewCell" forIndexPath:indexPath];
            [cell setDocumentMedia:[self documentAtIndexPath:indexPath]];
        
            return cell;
        }
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
    } else if (collectionView == _searchCollectionView) {
        [self endEditing:true];
        
        if (_searchLocalStickerPacks.count > 0 && indexPath.section != (NSInteger)_searchLocalStickerPacks.count) {
            TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            if (![cell isKindOfClass:[TGStickerCollectionViewCell class]])
                return;
            
            if ([cell isEnabled])
            {
                [cell setDisabledTimeout];
                
                TGDocumentMediaAttachment *document = ((TGStickerPack *)_searchLocalStickerPacks[indexPath.section]).documents[indexPath.item];
                if (_stickerSelected)
                    _stickerSelected(document);
                
                NSUInteger i = 0;
                for (TGStickerPack *pack in _stickerPacks)
                {
                    if ([pack.packReference isEqual:document.stickerPackReference])
                    {
                        [self scrollToSection:3 + i fromGifs:false animated:false];
                        break;
                    }
                    i++;
                }
            }
        }
    } else {
        TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (![cell isKindOfClass:[TGStickerCollectionViewCell class]])
            return;
        
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
    [self scrollToSection:section fromGifs:false animated:true];
}

- (void)scrollToSection:(NSUInteger)section fromGifs:(bool)fromGifs animated:(bool)animated
{
    _ignoreSetSection = false;
    _didScroll = true;
    
    [_tabPanel setCurrentStickerPackIndex:section animated:false];
    
    if (!_expanded && section != 0 && !fromGifs && _collectionView.frame.size.height < _collectionView.contentSize.height)
    {
        [UIView animateWithDuration:0.15 delay:0.0 options:kNilOptions animations:^
        {
            CGRect frame = _tabPanel.frame;
            frame.origin.y = -_tabPanel.frame.size.height;
            _tabPanel.frame = frame;
            [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
        } completion:nil];
    }
    
    void (^scrollTo)(CGFloat) = ^(CGFloat y)
    {
        if (fromGifs)
            y -= _tabPanel.frame.size.height;
        
        CGFloat verticalOffset = y - [self collectionView:_collectionView layout:_collectionLayout minimumLineSpacingForSectionAtIndex:section] - [self collectionView:_collectionView layout:_collectionLayout referenceSizeForHeaderInSection:section].height;
        CGFloat effectiveInset = preloadInset;
        if (_expanded)
            effectiveInset = effectiveInset + 45.0f;
        
        CGFloat contentOffset = verticalOffset - effectiveInset;
        if (contentOffset > _collectionView.contentSize.height - _collectionView.frame.size.height + _collectionView.contentInset.bottom) {
            contentOffset = _collectionView.contentSize.height - _collectionView.frame.size.height + _collectionView.contentInset.bottom;
        }
        
        if (contentOffset < -_collectionView.contentInset.top) {
            contentOffset = -_collectionView.contentInset.top;
        }
        
        _ignoreSetSection = true;
        [_collectionView setContentOffset:CGPointMake(0.0f, contentOffset) animated:animated];
    };
    
    if (section == 0)
    {
        if (_favoriteDocuments.count != 0)
        {
            _ignoreSetSection = true;
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
        }
        else
        {
            _ignoreSetSection = true;
            [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:animated];
        }
    }
    else if (section == 1)
    {
        if (_recentDocuments.count != 0)
        {
            UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            scrollTo(attributes.frame.origin.y);
        }
    }
    else if (section == 2 || section == (NSUInteger)[self lastGroupSection])
    {
        if (_groupDocuments.count != 0 || _showGroupPlaceholder)
        {
            UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            scrollTo(attributes.frame.origin.y);
        }
    }
    else
    {
        if (((TGStickerPack *)_stickerPacks[section - 3]).documents.count != 0) {
            UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            
            scrollTo(attributes.frame.origin.y);
        }
    }
}

- (void)setTrendingBadge:(NSString *)trendingBadge {
    if (_trendingStickersBadge == nil) {
        _trendingStickersBadge = trendingBadge;
        [_tabPanel setTrendingStickersBadge:trendingBadge];
    }
}

- (bool)showGroupStickers {
    return (_showGroupPlaceholder || _groupDocuments.count != 0) && !_groupStickersUnpinned;
}

- (bool)showGroupStickersLast {
    return (_showGroupPlaceholder || _groupDocuments.count != 0) && _groupStickersUnpinned;
}

- (void)setStickerPacks:(NSArray *)stickerPacks recentStickers:(NSArray *)recentStickers favoriteStickers:(NSArray *)favoriteStickers groupStickers:(NSArray *)groupStickers
{
    _stickerPacks = stickerPacks;
    
    _recentStickersSorted = recentStickers;
    [self updateRecentDocuments];
    
    _favoriteDocuments = favoriteStickers;
    _groupDocuments = groupStickers;
    
    bool shouldRestoreSearchFocus = _searchBar.isFirstResponder;
    [_collectionView reloadData];
    if (shouldRestoreSearchFocus)
        [_searchBar becomeFirstResponder];
    
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0 showFavorite:_favoriteDocuments.count != 0 showGroup:[self showGroupStickers] showGroupLast:[self showGroupStickersLast] showGifs:_recentGifs.count != 0 showTrendingFirst:[self showTrendingFirst] showTrendingLast:[self showTrendingLast]];
    
    if (!_didScroll)
        [self resetInitialScrollPosition];
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
    
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0 showFavorite:_favoriteDocuments.count != 0 showGroup:[self showGroupStickers] showGroupLast:[self showGroupStickersLast] showGifs:_recentGifs.count != 0 showTrendingFirst:[self showTrendingFirst] showTrendingLast:[self showTrendingLast]];
    
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
    
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0 showFavorite:_favoriteDocuments.count != 0 showGroup:[self showGroupStickers] showGroupLast:[self showGroupStickersLast] showGifs:_recentGifs.count != 0 showTrendingFirst:[self showTrendingFirst] showTrendingLast:[self showTrendingLast]];
}

- (bool)showTrendingFirst
{
    bool disableTrending = _style == TGStickerKeyboardViewDarkBlurredStyle;
    return !disableTrending && (_trendingStickerPacks.count != 0) && _trendingStickersBadge != nil;
}

- (bool)showTrendingLast
{
    bool disableTrending = _style == TGStickerKeyboardViewDarkBlurredStyle;
    return !disableTrending && (_trendingStickerPacks.count != 0) && _trendingStickersBadge == nil;
}

- (void)setInstalledTrendingPacks:(NSSet *)installedTrendingPacks {
    if (TGObjectCompare(installedTrendingPacks, _installedTrendingStickerPacks)) {
        return;
    }
    
    _installedTrendingStickerPacks = installedTrendingPacks;
    
    void (^processCell)(id) = ^(id cell) {
        if ([cell isKindOfClass:[TGTrendingStickerPackKeyboardCell class]]) {
            TGTrendingStickerPackKeyboardCell *packCell = cell;
            bool installed = true;
            if ([packCell.stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
                TGStickerPackIdReference *reference = (TGStickerPackIdReference *)packCell.stickerPack.packReference;
                installed = [installedTrendingPacks containsObject:@(reference.packId)];
            }
            packCell.installed = installed;
        }
    };
    
    for (id cell in [_trendingCollectionView visibleCells]) {
        processCell(cell);
    }
    
    for (id cell in [_searchCollectionView visibleCells]) {
        processCell(cell);
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
    
    [_tabPanel setStickerPacks:_stickerPacks showRecent:_recentDocuments.count != 0 showFavorite:_favoriteDocuments.count != 0 showGroup:[self showGroupStickers] showGroupLast:[self showGroupStickersLast] showGifs:_recentGifs.count != 0 showTrendingFirst:[self showTrendingFirst] showTrendingLast:[self showTrendingLast]];
    
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

- (void)startActionsTimer
{
    if (_actionsTimer != nil)
    {
        [_actionsTimer invalidate];
        _actionsTimer = nil;
    }
    
    _actionsTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(presentActions) interval:0.9 repeat:false];
}

- (void)presentActions
{
    if (_previewController != nil)
    {
        if (_searchBar.isFirstResponder)
            [_searchBar resignFirstResponder];
        
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        
        bool isFaved = [TGFavoriteStickersSignal isFaved:previewView.item];
        [_faveItem setTitle:isFaved ? TGLocalized(@"Stickers.RemoveFromFavorites") : TGLocalized(@"Stickers.AddToFavorites")];
        
        [previewView presentActions];
    }
    
    [_actionsTimer invalidate];
    _actionsTimer = nil;
}

- (void)handleStickerPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [recognizer locationInView:_collectionView];
        
        for (NSIndexPath *indexPath in [_collectionView indexPathsForVisibleItems])
        {
            TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
            if (![cell isKindOfClass:[TGStickerCollectionViewCell class]])
                continue;
            
            if (CGRectContainsPoint(cell.frame, point))
            {
                TGViewController *parentViewController = _parentViewController;
                if (parentViewController != nil)
                {
                    bool isRecent = (_favoriteDocuments.count > 0 && indexPath.section == 0);
                    
                    TGStickerItemPreviewView *previewView = [[TGStickerItemPreviewView alloc] initWithContext:[TGLegacyComponentsContext shared] frame:CGRectZero];
                    if ((NSInteger)TGScreenSize().height == 736)
                        previewView.eccentric = false;
                    if (!_forceTouchRecognizer.enabled)
                    {
                        if (isRecent)
                            previewView.presentActionsImmediately = true;
                        else
                            [self startActionsTimer];
                    }
                    
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
                    
                    TGMenuSheetButtonItemView *faveItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Stickers.AddToFavorites") type:TGMenuSheetButtonTypeDefault action:^
                    {
                        __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
                        __strong TGStickerKeyboardView *strongSelf = weakSelf;
                        if (strongSelf == nil || strongPreviewView == nil)
                            return;
                        
                        [TGFavoriteStickersSignal setSticker:strongPreviewView.item faved:![TGFavoriteStickersSignal isFaved:strongPreviewView.item]];
                        [strongPreviewView performDismissal];
                    }];
                    [actions addObject:faveItem];
                    _faveItem = faveItem;
                    
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
                    
                    TGItemPreviewController *controller = [[TGItemPreviewController alloc] initWithContext:[TGLegacyComponentsContext shared] parentController:parentViewController previewView:previewView];
                    _previewController = controller;
                    
                    controller.sourcePointForItem = ^(id item)
                    {
                        __strong TGStickerKeyboardView *strongSelf = weakSelf;
                        if (strongSelf == nil)
                            return CGPointZero;
                        
                        for (TGStickerCollectionViewCell *cell in strongSelf->_collectionView.visibleCells)
                        {
                            if (![cell isKindOfClass:[TGStickerCollectionViewCell class]])
                                continue;
                            
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
                    if (stickerPack == nil)
                        stickerPack = [TGDatabaseInstance() stickerPackForReference:sticker.stickerPackReference].stickerPack;
                    
                    [previewView setSticker:sticker stickerPack:stickerPack recent:isRecent];
                    
                    [cell setHighlightedWithBounce:true];
                    
                    if (previewView.presentActionsImmediately)
                    {
                        bool isFaved = [TGFavoriteStickersSignal isFaved:sticker];
                        [_faveItem setTitle:isFaved ? TGLocalized(@"Stickers.RemoveFromFavorites") : TGLocalized(@"Stickers.AddToFavorites")];
                    }
                }
                
                break;
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        [_actionsTimer invalidate];
        _actionsTimer = nil;
        
        for (TGStickerCollectionViewCell *cell in [_collectionView visibleCells])
        {
            if ([cell isKindOfClass:[TGStickerCollectionViewCell class]])
                [cell setHighlightedWithBounce:false];
        }
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
        
        if (_actionsTimer != nil)
            [self startActionsTimer];
        
        CGPoint point = [gestureRecognizer locationInView:_collectionView];
        CGPoint relativePoint = [gestureRecognizer locationInView:self];
        
        if (CGRectContainsPoint(CGRectOffset(_collectionView.frame, 0, preloadInset), relativePoint))
        {
            for (NSIndexPath *indexPath in [_collectionView indexPathsForVisibleItems])
            {
                TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
                if (![cell isKindOfClass:[TGStickerCollectionViewCell class]])
                    continue;
                
                if (CGRectContainsPoint(cell.frame, point))
                {
                    TGDocumentMediaAttachment *sticker = [self documentAtIndexPath:indexPath];
                    TGStickerPack *stickerPack = [self stickerPackAtIndexPath:indexPath];
                    if (stickerPack == nil)
                        stickerPack = [TGDatabaseInstance() stickerPackForReference:sticker.stickerPackReference].stickerPack;
                    
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
        [self presentActions];
        
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        if (fabs(CFAbsoluteTimeGetCurrent() - previewView.lastFeedbackTime) > 0.6)
            AudioServicesPlaySystemSound(1519);
    }
}

- (void)handleTrendingStickerPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [recognizer locationInView:_trendingCollectionView];
        
        for (NSIndexPath *indexPath in [_trendingCollectionView indexPathsForVisibleItems])
        {
            TGTrendingStickerPackKeyboardCell *trendingCell = (TGTrendingStickerPackKeyboardCell *)[_trendingCollectionView cellForItemAtIndexPath:indexPath];
            if (![trendingCell isKindOfClass:[TGTrendingStickerPackKeyboardCell class]])
                continue;
            
            if (CGRectContainsPoint(trendingCell.frame, point))
            {
                [trendingCell enumerateCells:^(TGStickerCollectionViewCell *cell)
                {
                    CGPoint location = [_trendingCollectionView convertPoint:point toView:cell];
                    if (CGRectContainsPoint(cell.bounds, location))
                    {
                        
                        TGViewController *parentViewController = _parentViewController;
                        if (parentViewController != nil)
                        {
                            TGStickerItemPreviewView *previewView = [[TGStickerItemPreviewView alloc] initWithContext:[TGLegacyComponentsContext shared] frame:CGRectZero];
                            if ((NSInteger)TGScreenSize().height == 736)
                                previewView.eccentric = false;
                            if (!_trendingForceTouchRecognizer.enabled)
                                [self startActionsTimer];
                            
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
                            
                            TGMenuSheetButtonItemView *faveItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Stickers.AddToFavorites") type:TGMenuSheetButtonTypeDefault action:^
                            {
                                __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
                                __strong TGStickerKeyboardView *strongSelf = weakSelf;
                                if (strongSelf == nil || strongPreviewView == nil)
                                    return;
                                
                                [TGFavoriteStickersSignal setSticker:strongPreviewView.item faved:![TGFavoriteStickersSignal isFaved:strongPreviewView.item]];
                                [strongPreviewView performDismissal];
                            }];
                            [actions addObject:faveItem];
                            _faveItem = faveItem;
                            
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
                            
                            TGItemPreviewController *controller = [[TGItemPreviewController alloc] initWithContext:[TGLegacyComponentsContext shared] parentController:parentViewController previewView:previewView];
                            _previewController = controller;
                            
                            controller.sourcePointForItem = ^(id item)
                            {
                                __strong TGStickerKeyboardView *strongSelf = weakSelf;
                                if (strongSelf == nil)
                                    return CGPointZero;
                                
                                for (NSIndexPath *indexPath in [strongSelf->_trendingCollectionView indexPathsForVisibleItems])
                                {
                                    TGTrendingStickerPackKeyboardCell *trendingCell = (TGTrendingStickerPackKeyboardCell *)[strongSelf->_trendingCollectionView cellForItemAtIndexPath:indexPath];
                                    if (![trendingCell isKindOfClass:[TGTrendingStickerPackKeyboardCell class]])
                                        continue;
                                    
                                    TGStickerCollectionViewCell *cell = [trendingCell cellForDocument:item];
                                    if (cell != nil)
                                        return [trendingCell convertPoint:cell.center toView:nil];
                                }
                                
                                return CGPointZero;
                            };
                            
                            TGDocumentMediaAttachment *sticker = cell.documentMedia;
                            TGStickerPack *stickerPack = trendingCell.stickerPack;
                            if (stickerPack == nil)
                                stickerPack = [TGDatabaseInstance() stickerPackForReference:sticker.stickerPackReference].stickerPack;
                            
                            [previewView setSticker:sticker stickerPack:stickerPack recent:false];
                            
                            [cell setHighlightedWithBounce:true];
                            
                            if (previewView.presentActionsImmediately)
                            {
                                bool isFaved = [TGFavoriteStickersSignal isFaved:sticker];
                                [_faveItem setTitle:isFaved ? TGLocalized(@"Stickers.RemoveFromFavorites") : TGLocalized(@"Stickers.AddToFavorites")];
                            }
                        }
                    }
                }];
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        [_actionsTimer invalidate];
        _actionsTimer = nil;
        
        for (TGTrendingStickerPackKeyboardCell *cell in [_trendingCollectionView visibleCells])
        {
            if ([cell isKindOfClass:[TGTrendingStickerPackKeyboardCell class]])
                [cell clearHighlight];
        }
        TGItemPreviewController *controller = _previewController;
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        if (previewView.isLocked)
            return;
        
        [controller dismiss];
    }
}

- (void)handleTrendingStickerPan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (_previewController != nil && gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        if (previewView.isLocked)
            return;
        
        if (_actionsTimer != nil)
            [self startActionsTimer];
        
        CGPoint point = [gestureRecognizer locationInView:_trendingCollectionView];
        CGPoint relativePoint = [gestureRecognizer locationInView:self];
        
        if (CGRectContainsPoint(CGRectOffset(_trendingCollectionView.frame, 0, preloadInset), relativePoint))
        {
            for (NSIndexPath *indexPath in [_trendingCollectionView indexPathsForVisibleItems])
            {
                TGTrendingStickerPackKeyboardCell *trendingCell = (TGTrendingStickerPackKeyboardCell *)[_trendingCollectionView cellForItemAtIndexPath:indexPath];
                if (![trendingCell isKindOfClass:[TGTrendingStickerPackKeyboardCell class]])
                    continue;
                
                if (CGRectContainsPoint(trendingCell.frame, point))
                {
                    [trendingCell enumerateCells:^(TGStickerCollectionViewCell *cell)
                    {
                        CGPoint location = [_trendingCollectionView convertPoint:point toView:cell];
                        if (CGRectContainsPoint(cell.bounds, location))
                        {
                            TGDocumentMediaAttachment *sticker = cell.documentMedia;
                            TGStickerPack *stickerPack = trendingCell.stickerPack;
                            if (stickerPack == nil)
                                stickerPack = [TGDatabaseInstance() stickerPackForReference:sticker.stickerPackReference].stickerPack;
                            if (sticker != nil)
                                [previewView setSticker:sticker stickerPack:stickerPack recent:false];
                            
                            [cell setHighlightedWithBounce:true];
                        }
                        else
                        {
                            [cell setHighlightedWithBounce:false];
                        }
                    }];
                }
                else
                {
                    [trendingCell clearHighlight];
                }
            }
        }
    }
}

- (void)handleSearchStickerPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [recognizer locationInView:_searchCollectionView];
        
        for (NSIndexPath *indexPath in [_searchCollectionView indexPathsForVisibleItems])
        {
            UICollectionViewCell *baseCell = (TGStickerCollectionViewCell *)[_searchCollectionView cellForItemAtIndexPath:indexPath];
            if ([baseCell isKindOfClass:[TGTrendingStickerPackKeyboardCell class]])
            {
                TGTrendingStickerPackKeyboardCell *trendingCell = (TGTrendingStickerPackKeyboardCell *)baseCell;
                if (CGRectContainsPoint(trendingCell.frame, point))
                {
                    [trendingCell enumerateCells:^(TGStickerCollectionViewCell *cell)
                    {
                        CGPoint location = [_searchCollectionView convertPoint:point toView:cell];
                        if (CGRectContainsPoint(cell.bounds, location))
                        {
                            TGViewController *parentViewController = _parentViewController;
                            if (parentViewController != nil)
                            {
                                TGStickerItemPreviewView *previewView = [[TGStickerItemPreviewView alloc] initWithContext:[TGLegacyComponentsContext shared] frame:CGRectZero];
                                if ((NSInteger)TGScreenSize().height == 736)
                                    previewView.eccentric = false;
                                if (!_searchForceTouchRecognizer.enabled)
                                    [self startActionsTimer];
                                
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
                                
                                TGMenuSheetButtonItemView *faveItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Stickers.AddToFavorites") type:TGMenuSheetButtonTypeDefault action:^
                                {
                                    __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
                                    __strong TGStickerKeyboardView *strongSelf = weakSelf;
                                    if (strongSelf == nil || strongPreviewView == nil)
                                        return;
                                    
                                    [TGFavoriteStickersSignal setSticker:strongPreviewView.item faved:![TGFavoriteStickersSignal isFaved:strongPreviewView.item]];
                                    [strongPreviewView performDismissal];
                                }];
                                [actions addObject:faveItem];
                                _faveItem = faveItem;
                                
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
                                
                                TGItemPreviewController *controller = [[TGItemPreviewController alloc] initWithContext:[TGLegacyComponentsContext shared] parentController:parentViewController previewView:previewView];
                                _previewController = controller;
                                
                                controller.sourcePointForItem = ^CGPoint(id item)
                                {
                                    __strong TGStickerKeyboardView *strongSelf = weakSelf;
                                    if (strongSelf == nil)
                                        return CGPointZero;
                                    
                                    for (NSIndexPath *indexPath in [strongSelf->_searchCollectionView indexPathsForVisibleItems])
                                    {
                                        TGTrendingStickerPackKeyboardCell *trendingCell = (TGTrendingStickerPackKeyboardCell *)[strongSelf->_searchCollectionView cellForItemAtIndexPath:indexPath];
                                        if (![trendingCell isKindOfClass:[TGTrendingStickerPackKeyboardCell class]])
                                            continue;
                                        
                                        TGStickerCollectionViewCell *cell = [trendingCell cellForDocument:item];
                                        if (cell != nil)
                                            return [trendingCell convertPoint:cell.center toView:nil];
                                    }
                                    
                                    return CGPointZero;
                                };
                                
                                TGDocumentMediaAttachment *sticker = cell.documentMedia;
                                TGStickerPack *stickerPack = trendingCell.stickerPack;
                                if (stickerPack == nil)
                                    stickerPack = [TGDatabaseInstance() stickerPackForReference:sticker.stickerPackReference].stickerPack;
                                
                                [previewView setSticker:sticker stickerPack:stickerPack recent:false];
                                
                                [cell setHighlightedWithBounce:true];
                                
                                if (previewView.presentActionsImmediately)
                                {
                                    bool isFaved = [TGFavoriteStickersSignal isFaved:sticker];
                                    [_faveItem setTitle:isFaved ? TGLocalized(@"Stickers.RemoveFromFavorites") : TGLocalized(@"Stickers.AddToFavorites")];
                                }
                            }
                        }
                    }];
                }
            }
            else if ([baseCell isKindOfClass:[TGStickerCollectionViewCell class]])
            {
                TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)baseCell;
                if (CGRectContainsPoint(cell.frame, point))
                {
                    TGViewController *parentViewController = _parentViewController;
                    if (parentViewController != nil)
                    {
                        TGStickerItemPreviewView *previewView = [[TGStickerItemPreviewView alloc] initWithContext:[TGLegacyComponentsContext shared] frame:CGRectZero];
                        if ((NSInteger)TGScreenSize().height == 736)
                            previewView.eccentric = false;
                        if (!_searchForceTouchRecognizer.enabled)
                            [self startActionsTimer];
                        
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
                        
                        TGMenuSheetButtonItemView *faveItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Stickers.AddToFavorites") type:TGMenuSheetButtonTypeDefault action:^
                        {
                            __strong TGStickerItemPreviewView *strongPreviewView = weakPreviewView;
                            __strong TGStickerKeyboardView *strongSelf = weakSelf;
                            if (strongSelf == nil || strongPreviewView == nil)
                                return;
                            
                            [TGFavoriteStickersSignal setSticker:strongPreviewView.item faved:![TGFavoriteStickersSignal isFaved:strongPreviewView.item]];
                            [strongPreviewView performDismissal];
                        }];
                        [actions addObject:faveItem];
                        _faveItem = faveItem;
                        
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
                        
                        TGItemPreviewController *controller = [[TGItemPreviewController alloc] initWithContext:[TGLegacyComponentsContext shared] parentController:parentViewController previewView:previewView];
                        _previewController = controller;
                        
                        controller.sourcePointForItem = ^(id item)
                        {
                            __strong TGStickerKeyboardView *strongSelf = weakSelf;
                            if (strongSelf == nil)
                                return CGPointZero;
                            
                            for (TGStickerCollectionViewCell *cell in strongSelf->_searchCollectionView.visibleCells)
                            {
                                if (![cell isKindOfClass:[TGStickerCollectionViewCell class]])
                                    continue;
                                
                                if ([cell.documentMedia isEqual:item])
                                {
                                    NSIndexPath *indexPath = [strongSelf->_searchCollectionView indexPathForCell:cell];
                                    if (indexPath != nil)
                                        return [strongSelf->_searchCollectionView convertPoint:cell.center toView:nil];
                                }
                            }
                            
                            return CGPointZero;
                        };
                        
                        TGStickerPack *stickerPack = _searchLocalStickerPacks[indexPath.section];
                        TGDocumentMediaAttachment *sticker = stickerPack.documents[indexPath.row];
                        if (stickerPack.packReference == nil)
                            stickerPack = [TGDatabaseInstance() stickerPackForReference:sticker.stickerPackReference].stickerPack;
                        
                        [previewView setSticker:sticker stickerPack:stickerPack recent:false];
                        
                        [cell setHighlightedWithBounce:true];
                        
                        if (previewView.presentActionsImmediately)
                        {
                            bool isFaved = [TGFavoriteStickersSignal isFaved:sticker];
                            [_faveItem setTitle:isFaved ? TGLocalized(@"Stickers.RemoveFromFavorites") : TGLocalized(@"Stickers.AddToFavorites")];
                        }
                    }
                    
                    break;
                }
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        [_actionsTimer invalidate];
        _actionsTimer = nil;
        
        for (UICollectionViewCell *cell in [_searchCollectionView visibleCells])
        {
            if ([cell isKindOfClass:[TGStickerCollectionViewCell class]])
                [(TGStickerCollectionViewCell *)cell setHighlightedWithBounce:false];
            else if ([cell isKindOfClass:[TGTrendingStickerPackKeyboardCell class]])
                [(TGTrendingStickerPackKeyboardCell *)cell clearHighlight];
        }
        TGItemPreviewController *controller = _previewController;
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        if (previewView.isLocked)
            return;
        
        [controller dismiss];
    }
}

- (void)handleSearchStickerPan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (_previewController != nil && gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        TGStickerItemPreviewView *previewView = (TGStickerItemPreviewView *)_previewController.previewView;
        if (previewView.isLocked)
            return;
        
        if (_actionsTimer != nil)
            [self startActionsTimer];
        
        CGPoint point = [gestureRecognizer locationInView:_searchCollectionView];
        CGPoint relativePoint = [gestureRecognizer locationInView:self];
        
        if (CGRectContainsPoint(CGRectOffset(_searchCollectionView.frame, 0, preloadInset), relativePoint))
        {
            for (NSIndexPath *indexPath in [_searchCollectionView indexPathsForVisibleItems])
            {
                UICollectionViewCell *baseCell = [_searchCollectionView cellForItemAtIndexPath:indexPath];
                if ([baseCell isKindOfClass:[TGTrendingStickerPackKeyboardCell class]])
                {
                    TGTrendingStickerPackKeyboardCell *trendingCell = (TGTrendingStickerPackKeyboardCell *)baseCell;
                    if (CGRectContainsPoint(trendingCell.frame, point))
                    {
                        [trendingCell enumerateCells:^(TGStickerCollectionViewCell *cell)
                        {
                            CGPoint location = [_searchCollectionView convertPoint:point toView:cell];
                            if (CGRectContainsPoint(cell.bounds, location))
                            {
                                TGDocumentMediaAttachment *sticker = cell.documentMedia;
                                TGStickerPack *stickerPack = trendingCell.stickerPack;
                                if (stickerPack == nil)
                                    stickerPack = [TGDatabaseInstance() stickerPackForReference:sticker.stickerPackReference].stickerPack;
                                if (sticker != nil)
                                    [previewView setSticker:sticker stickerPack:stickerPack recent:false];
                                
                                [cell setHighlightedWithBounce:true];
                            }
                            else
                            {
                                [cell setHighlightedWithBounce:false];
                            }
                        }];
                    }
                    else
                    {
                        [trendingCell clearHighlight];
                    }
                }
                else if ([baseCell isKindOfClass:[TGStickerCollectionViewCell class]])
                {
                    TGStickerCollectionViewCell *cell = (TGStickerCollectionViewCell *)baseCell;
                    
                    if (CGRectContainsPoint(cell.frame, point))
                    {
                        TGStickerPack *stickerPack = _searchLocalStickerPacks[indexPath.section];
                        TGDocumentMediaAttachment *sticker = stickerPack.documents[indexPath.row];
                        if (stickerPack.packReference == nil)
                            stickerPack = [TGDatabaseInstance() stickerPackForReference:sticker.stickerPackReference].stickerPack;
                        
                        if (sticker != nil)
                            [previewView setSticker:sticker stickerPack:stickerPack recent:false];
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
    
    if (gestureRecognizer == _searchPanRecognizer || otherGestureRecognizer == _searchPanRecognizer)
        return true;
    
    if (gestureRecognizer == _searchForceTouchRecognizer || otherGestureRecognizer == _searchForceTouchRecognizer)
        return true;
    
    if (gestureRecognizer == _trendingPanRecognizer || otherGestureRecognizer == _trendingPanRecognizer)
        return true;
    
    return false;
}

- (void)setMode:(TGStickerKeyboardViewMode)mode {
    if (_searchActive)
        return;
    
    if (_mode != mode) {
        _mode = mode;
        
        if (_gifTabActive) {
            _gifTabActive(_mode == TGStickerKeyboardViewModeGifs);
        }
        
        CGSize size = self.bounds.size;
        
        CGFloat left = _safeAreaInset.left;
        CGFloat width = size.width - _safeAreaInset.left - _safeAreaInset.right;
        
        [UIView animateWithDuration:0.2 animations:^{
            if (_mode == TGStickerKeyboardViewModeStickers) {
                _collectionView.frame = CGRectMake(left, -preloadInset, width, size.height + preloadInset * 2.0f);
                _gifsCollectionView.frame = CGRectMake(-size.width + left, -gifInset, width, size.height + gifInset * 2.0f);
                _trendingCollectionView.frame = CGRectMake(size.width + left, -gifInset, width, size.height + gifInset * 2.0f);
            } else if (_mode == TGStickerKeyboardViewModeGifs) {
                _collectionView.frame = CGRectMake(size.width + left, -preloadInset, width, size.height + preloadInset * 2.0f);
                _gifsCollectionView.frame = CGRectMake(left, -gifInset, width, size.height + gifInset * 2.0f);
                _trendingCollectionView.frame = CGRectMake(size.width * 2.0f + left, -gifInset, width, size.height + gifInset * 2.0f);
            } else {
                _collectionView.frame = CGRectMake(-size.width * 2.0 + left, -preloadInset, width, size.height + preloadInset * 2.0f);
                _gifsCollectionView.frame = CGRectMake(-size.width + left, -gifInset, width, size.height + gifInset * 2.0f);
                _trendingCollectionView.frame = CGRectMake(left, -gifInset, width, size.height + gifInset * 2.0f);
            }
        }];
        
        if (mode == TGStickerKeyboardViewModeGifs)
            [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:false];
        else
            [_gifsCollectionView setContentOffset:_gifsCollectionView.contentOffset animated:false];
        
        _ignoreSetSection = true;
        [self scrollViewDidScroll:_gifsCollectionView];
        _ignoreSetSection = false;
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
    bool scrollToNewPack = false;
    if (_searchActive) {
        [self searchBarCancelButtonClicked:(UISearchBar *)_searchBar];
        scrollToNewPack = true;
    }
    
    __weak TGStickerKeyboardView *weakSelf = self;
    __weak TGViewController *weakParentController = _parentViewController;
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.1];
    SSignal *installStickerPackAndGetArchivedSignal = [TGStickersSignals installStickerPackAndGetArchived:stickerPack.packReference];
    [[[installStickerPackAndGetArchivedSignal deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:^(NSArray *archivedPacks) {
        __strong TGViewController *parentController = weakParentController;
        if (parentController != nil) {
            if (archivedPacks.count != 0) {
                TGArchivedStickerPacksAlert *previewWindow = [[TGArchivedStickerPacksAlert alloc] initWithManager:[[TGLegacyComponentsContext shared] makeOverlayWindowManager] parentController:parentController stickerPacks:archivedPacks];
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
        
        if (scrollToNewPack) {
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            [strongSelf scrollToSection:3];
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
        if (index == NSNotFound) {
            [self previewStickerPack:stickerPack sticker:sticker];
        } else {
            [self scrollToSection:3 + index];
        }
    }
}

- (void)previewStickerPack:(TGStickerPack *)stickerPack sticker:(TGDocumentMediaAttachment *)sticker {
    TGViewController *parentViewController = _parentViewController;
    
    __weak TGStickerKeyboardView *weakSelf = self;

    CGRect sourceRect = CGRectMake(CGFloor(self.bounds.size.width / 2.0f), [UIScreen mainScreen].bounds.size.height, 0.0f, 0.0f);
    
    void (^stickerPackAdded)(id<TGStickerPackReference>) = nil;
    void (^stickerPackRemoved)(id<TGStickerPackReference>) = nil;
    void (^linkOpened)(void) = nil;
    if (_searchActive)
    {
        stickerPackAdded = ^(__unused id<TGStickerPackReference> pack)
        {
            [self searchBarCancelButtonClicked:(UISearchBar *)_searchBar];
            [self scrollToSection:3];
        };
        stickerPackRemoved = ^(__unused id<TGStickerPackReference> pack)
        {
            [self searchBarCancelButtonClicked:(UISearchBar *)_searchBar];
        };
        linkOpened = ^
        {
            [self searchBarCancelButtonClicked:(UISearchBar *)_searchBar];
        };
    }
    
    id<TGStickerPackReference> packReference = stickerPack == nil ? sticker.stickerPackReference : nil;
    [TGStickersMenu presentWithParentController:parentViewController packReference:packReference stickerPack:stickerPack showShareAction:false sendSticker:^(TGDocumentMediaAttachment *document) {
        __strong TGStickerKeyboardView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (strongSelf.stickerSelected) {
                strongSelf.stickerSelected(document);
            }
        }
    } stickerPackRemoved:stickerPackRemoved stickerPackAdded:stickerPackAdded stickerPackHidden:nil linkOpened:linkOpened stickerPackArchived:false stickerPackIsMask:stickerPack.isMask sourceView:parentViewController.view sourceRect:^CGRect{
        return sourceRect;
    } centered:true existingController:nil expanded:_expanded];
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
    
    if (!_collectionView.blockScrolling)
    {
        _tabPanel.frame = CGRectMake(_tabPanel.frame.origin.x, 0.0f, _tabPanel.frame.size.width, _tabPanel.frame.size.height);
        [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
    }
    
    if (_searchBar != nil)
    {
        if (!expanded)
            [self searchEnded];
        else if (_collectionView.contentOffset.y < -_collectionView.contentInset.top + 130.0f + FLT_EPSILON)
            _collectionView.contentOffset = CGPointMake(0.0f, -_collectionView.contentInset.top);
    }
}

- (void)updateExpanded
{
    [_tabPanel updateExpanded:true];
}

- (void)setVisible:(bool)visible animated:(bool)animated
{
    if (![TGViewController hasTallScreen])
        return;
    
    [_tabPanel setHidden:!visible animated:animated];
}

- (CGFloat)preferredHeight:(bool)landscape
{
    return [TGStickerKeyboardView preferredHeight:landscape];
}

+ (CGFloat)preferredHeight:(bool)landscape
{
    if (TGIsPad())
        return landscape ? 398.0f : 313.0f;
    
    if ([TGViewController hasTallScreen])
        return landscape ? 209.0f : 333.0f;
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




- (BOOL)searchBarShouldBeginEditing:(TGSearchBar *)__unused searchBar
{
    if (_mode != TGStickerKeyboardViewModeStickers)
        return false;
    
    _searchActive = true;
    
    _collectionView.blockScrolling = true;
    [_collectionView setForcedContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:false];
    
    [_searchBar setShowsCancelButton:true animated:true];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
    {
        CGRect frame = _tabPanel.frame;
        frame.origin.y = -_tabPanel.frame.size.height;
        
        _tabPanel.frame = frame;
        [self setMaskWithTabPanelOffset:_tabPanel.frame.origin.y];
        
        [self layoutForSize:self.frame.size];
    } completion:nil];
    
    if (self.requestedCollapse != nil)
        self.requestedCollapse(true);
    
    if (self.requestedExpand != nil)
        self.requestedExpand(true);
 
    _searchWrapperView.hidden = false;
    
    return true;
}

- (void)searchBarTextDidBeginEditing:(TGSearchBar *)__unused searchBar
{
    [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top)];
    [self setSearchQuery:nil];
    
    _autorotationWasEnabled = [TGViewController autorotationAllowed];
    [TGViewController disableAutorotation];
}

- (void)searchBar:(TGSearchBar *)__unused searchBar textDidChange:(NSString *)searchText
{
    if (!searchBar.maybeCustomTextField.isFirstResponder)
        return;
    
    SSignal *signal = [SSignal complete];
    if ([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
        signal = [signal delay:0.4 onQueue:[SQueue mainQueue]];
                  
    __weak TGStickerKeyboardView *weakSelf = self;
    [_queryDisposable setDisposable:[signal startWithNext:nil completed:^
    {
        __strong TGStickerKeyboardView *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf setSearchQuery:searchText];
    }]];
}

- (void)searchBar:(TGSearchBar *)__unused searchBar willChangeHeight:(CGFloat)__unused newHeight
{
    
}

- (void)searchBarCancelButtonClicked:(TGSearchBar *)__unused searchBar
{
    [self searchEnded];
    
    if (self.requestedExpand != nil)
        self.requestedExpand(false);
}

- (void)setSearchQuery:(NSString *)query
{
    query = [query lowercaseString];
    [_searchCollectionView setContentOffset:CGPointMake(0.0f, -_searchCollectionView.contentInset.top) animated:false];
    
    bool isSingleEmoji = false;
    NSString *keyString = nil;
    if (query.length > 0)
    {
        isSingleEmoji = [query containsSingleEmoji];
        keyString = [[query emojiArray:true] firstObject];
        if (keyString.length == 0)
            isSingleEmoji = false;
    }
    
    __weak TGStickerKeyboardView *weakSelf = self;
    if (query.length == 0)
    {
        [_searchDisposable setDisposable:[[[[TGStickersSignals stickerPacks] startOn:[SQueue concurrentDefaultQueue]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict)
        {
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
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
            
            [strongSelf setSearchLocalStickerPacks:trendingPacks.count == 0 ? dict[@"packs"] : @[] remoteStickerPacks:trendingPacks];
        }]];
        
        _searchEmojiQuery = nil;
        [_searchEmojiStickers set:[SSignal single:nil]];
    }
    else if (isSingleEmoji)
    {
        _searchBar.showActivity = true;
        
        [_searchDisposable setDisposable:[[[[[TGStickersSignals stickersForEmojis:@[keyString] includeRemote:true updateRemoteCached:false] filter:^bool(NSDictionary *stickers)
        {
            return stickers != nil;
        }] deliverOn:[SQueue mainQueue]] onDispose:^
        {
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf->_searchBar.showActivity = false;
        }] startWithNext:^(NSDictionary *next)
        {
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            NSArray *stickers = nil;
            if ([next[@"emojis"] firstObject] != nil)
                stickers = [next[@"emojis"] firstObject][@"documents"];
            
            NSMutableArray *packs = [[NSMutableArray alloc] init];
            if (stickers.count > 0)
            {
                [packs addObject:[[TGStickerPack alloc] initWithPackReference:nil title:nil stickerAssociations:nil documents:stickers packHash:0 hidden:false isMask:false isFeatured:false installedDate:0]];
            }
            [strongSelf setSearchLocalStickerPacks:packs remoteStickerPacks:[next[@"final"] boolValue] ? @[] : nil];
        }]];
        
        _searchEmojiQuery = nil;
        [_searchEmojiStickers set:[SSignal single:nil]];
    }
    else
    {
        _searchBar.showActivity = true;
        
        SSignal *emojiSignal = [[SSignal defer:^SSignal *
        {
            NSArray *emojiArray = [TGEmojiSuggestions suggestionsForQuery:query];
            return [SSignal single:emojiArray];
        }] startOn:[SQueue concurrentDefaultQueue]];
        
        emojiSignal = [emojiSignal map:^id(NSArray *entries)
        {
            NSMutableArray *emojis = [[NSMutableArray alloc] init];
            for (TGAlphacodeEntry *entry in entries)
            {
                [emojis addObject:entry.emoji];
            }
            return [emojis subarrayWithRange:NSMakeRange(0, MIN(5, (int)emojis.count))];
        }];
        
        [_emojiDisposable setDisposable:[[emojiSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *emojis)
        {
            __strong TGStickerKeyboardView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (![emojis isEqualToArray:strongSelf->_searchEmojiQuery])
            {
                strongSelf->_searchEmojiQuery = emojis;
                [strongSelf->_searchEmojiStickers set:[TGStickersSignals stickersForEmojis:emojis includeRemote:true updateRemoteCached:false]];
            }
            
            SSignal *signal = [[[strongSelf->_searchEmojiStickers.signal filter:^bool(id value) {
                return value != nil;
            }] take:1] mapToSignal:^SSignal *(NSDictionary *emojiResults)
            {
                return [[TGStickersSignals searchStickersWithQuery:query] map:^id(NSDictionary *searchResults)
                {
                    return @[ emojiResults, searchResults ];
                }];
            }];
            
            [strongSelf->_searchDisposable setDisposable:[[[signal deliverOn:[SQueue mainQueue]] onDispose:^
            {
                __strong TGStickerKeyboardView *strongSelf = weakSelf;
                if (strongSelf != nil)
                    strongSelf->_searchBar.showActivity = false;
            }] startWithNext:^(NSArray *next)
            {
                __strong TGStickerKeyboardView *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    NSDictionary *emojiResults = next.firstObject;
                    NSDictionary *searchResults = next.lastObject;
                    
                    NSMutableArray *localPacks = [[NSMutableArray alloc] init];
                    for (NSDictionary *set in emojiResults[@"emojis"])
                    {
                        NSString *emoji = set[@"emoji"];
                        NSArray *stickers = set[@"documents"];
                        if (stickers.count == 0)
                            continue;
                        
                        TGStickerPack *pack = [[TGStickerPack alloc] initWithPackReference:nil title:emoji stickerAssociations:nil documents:stickers packHash:0 hidden:false isMask:false isFeatured:false installedDate:0];
                        [localPacks addObject:pack];
                    }
                    
                    [localPacks addObjectsFromArray:searchResults[@"local"]];
                    [strongSelf setSearchLocalStickerPacks:localPacks remoteStickerPacks:searchResults[@"remote"]];
                }
            }]];
        }]];
    }
}

- (void)setSearchLocalStickerPacks:(NSArray *)localStickerPacks remoteStickerPacks:(NSArray *)remoteStickerPacks
{
    if (localStickerPacks.count + remoteStickerPacks.count == 0 && remoteStickerPacks == nil)
        return;
    
    _searchLocalStickerPacks = localStickerPacks;
    _searchRemoteStickerPacks = remoteStickerPacks;
    
    [_searchCollectionView reloadData];
    
    bool placeholderHidden = (_searchLocalStickerPacks.count + _searchRemoteStickerPacks.count > 0) || _searchRemoteStickerPacks == nil;
    _stickersPlaceholderImageView.hidden = placeholderHidden;
    _stickersPlaceholderLabel.hidden = placeholderHidden;
}

- (void)searchEnded
{
    _searchActive = false;
    _searchWrapperView.hidden = true;
    
    [_searchBar setShowsCancelButton:false animated:true];
    _collectionView.blockScrolling = false;
    
    if ([_searchBar isFirstResponder])
        [_searchBar resignFirstResponder];
    if (_searchBar.maybeCustomTextField != nil)
        [_searchBar setText:@""];
    
    if (self.requestedCollapse != nil)
        self.requestedCollapse(false);
    
    if (_autorotationWasEnabled)
        [TGViewController enableAutorotation];
}

@end


@implementation TGStickerKeyboardCollectionView

- (void)setContentOffset:(CGPoint)contentOffset
{
    if (self.blockScrolling)
        return;
    [super setContentOffset:contentOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(bool)animated
{
    if (self.blockScrolling)
        return;
    [super setContentOffset:contentOffset animated:animated];
}

- (void)setForcedContentOffset:(CGPoint)contentOffset animated:(bool)animated
{
    [super setContentOffset:contentOffset animated:animated];
}

@end
