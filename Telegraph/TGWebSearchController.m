#import "TGWebSearchController.h"

#import "TGAppDelegate.h"
#import "ActionStage.h"

#import "TGSearchBar.h"
#import "TGModernButton.h"

#import "TGStringUtils.h"
#import "TGImageUtils.h"
#import "TGFont.h"
#import "UIImage+TG.h"

#import "TGNavigationController.h"

#import "TGModernMediaCollectionView.h"
#import "TGModernMediaListLayout.h"
#import "TGModernMediaListItem.h"
#import "TGModernMediaListItemView.h"
#import "TGModernMediaListItemContentView.h"

#import "TGImageView.h"

#import "TGGiphySearchResultItem+TGMediaItem.h"
#import "TGWebSearchGifItem.h"
#import "TGWebSearchGifItemView.h"

#import "TGBingSearchResultItem+TGMediaItem.h"
#import "TGWebSearchImageItem.h"
#import "TGWebSearchImageItemView.h"

#import "TGInternalGifSearchResult+TGMediaItem.h"
#import "TGInternalGifSearchResultItem.h"
#import "TGInternalGifSearchResultItemView.h"

#import "TGExternalGifSearchResult+TGMediaItem.h"
#import "TGExternalGifSearchResultItem.h"
#import "TGExternalGifSearchResultItemView.h"

#import "TGWebSearchInternalImageResult+TGMediaItem.h"
#import "TGWebSearchInternalImageItem.h"
#import "TGWebSearchInternalImageItemView.h"

#import "TGWebSearchInternalGifResult+TGMediaItem.h"
#import "TGWebSearchInternalGifItem.h"
#import "TGWebSearchInternalGifItemView.h"

#import "TGModernGalleryController.h"
#import "TGWebSearchResultsGalleryImageItem.h"
#import "TGWebSearchResultsGalleryGifItem.h"
#import "TGWebSearchResultsGalleryInternalImageItem.h"
#import "TGWebSearchResultsGalleryInternalGifItem.h"

#import "TGInternalGifSearchResultGalleryItem.h"
#import "TGExternalGifSearchResultGalleryItem.h"

#import "TGMediaPickerGalleryModel.h"

#import "TGActionSheet.h"

#import "TGMediaAssetsLibrary.h"

#import "TGMediaSelectionContext.h"
#import "TGMediaEditingContext.h"

#import "PGPhotoEditorValues.h"
#import "TGPaintingData.h"

#import "TGPhotoEditorController.h"

#import "TGOverlayControllerWindow.h"

#import "TGRecentSearchResultsTableView.h"

#import "TGDoubleTapGestureRecognizer.h"

#import "TGMediaPickerLayoutMetrics.h"

@interface TGWebSearchController () <TGSearchBarDelegate, ASWatcher, UICollectionViewDataSource, UICollectionViewDelegate>
{
    TGMediaPickerLayoutMetrics *_layoutMetrics;
    
    TGSearchBar *_searchBar;
    UIView *_toolbarView;
    UIImageView *_toolbarLogoView;
    TGModernButton *_doneButton;
    UIImageView *_countBadge;
    UILabel *_countLabel;
    TGModernButton *_clearButton;
    
    NSString *_searchString;
    
    NSString *_imageSearchPath;
    NSString *_gifSearchPath;
    
    NSArray *_imageSearchResults;
    NSArray *_rawImageSearchResults;
    TGMediaSelectionContext *_imageSelectionContext;
    bool _imageMoreResultsAvailable;
    bool _searchingImage;
    
    NSArray *_gifSearchResults;
    NSArray *_rawGifSearchResults;
    bool _gifMoreResultsAvailable;
    TGMediaSelectionContext *_gifSelectionContext;
    int32_t _gifMoreResultsOffset;
    bool _searchingGif;

    NSArray *_recentSearchResults;
    TGMediaSelectionContext *_recentSelectionContext;
    
    NSArray *_selectedItems;
    
    UIView *_nothingFoundView;
    
    bool _appeared;
    
    UICollectionView *_collectionView;
    CGFloat _collectionViewWidth;
    TGModernMediaListLayout *_collectionLayout;
    UIView *_collectionContainer;
    NSMutableDictionary *_reusableItemContentViewsByIdentifier;
    bool _loadItemsSynchronously;
    
    TGRecentSearchResultsTableView *_recentSearchResultsTableView;
    
    id<TGModernMediaListItem> _hiddenItem;
    
    bool _embedded;
    NSArray *_scopeButtonTitles;
    
    void (^_recycleItemContentView)(TGModernMediaListItemContentView *);
    NSMutableArray *_storedItemContentViews;
    
    __weak TGMediaPickerGalleryModel *_galleryModel;
    
    TGMediaEditingContext *_editingContext;
    
    SMetaDisposable *_selectionChangedDisposable;
    
    void(^_fetchOriginalImage)(id<TGMediaEditableItem>, void(^)(UIImage *));
    void(^_fetchOriginalThumbnailImage)(id<TGMediaEditableItem>, void(^)(UIImage *));
    
    bool _checked3dTouch;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGWebSearchController

- (instancetype)init
{
    return [self initForAvatarSelection:false embedded:false];
}

- (instancetype)initForAvatarSelection:(bool)avatarSelection embedded:(bool)embedded
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
     
        _avatarSelection = avatarSelection;
        
        if (!avatarSelection)
        {
            _imageSelectionContext = [[TGMediaSelectionContext alloc] init];
            _gifSelectionContext = [[TGMediaSelectionContext alloc] init];
            _recentSelectionContext = [[TGMediaSelectionContext alloc] init];
        }
        _editingContext = [[TGMediaEditingContext alloc] init];
        
        if (!embedded)
            self.navigationBarShouldBeHidden = true;
        
        _reusableItemContentViewsByIdentifier = [[NSMutableDictionary alloc] init];
        _storedItemContentViews = [[NSMutableArray alloc] init];
        
        __weak TGWebSearchController *weakSelf = self;
        _recycleItemContentView = ^(TGModernMediaListItemContentView *itemContentView)
        {
            __strong TGWebSearchController *strongSelf = weakSelf;
            [strongSelf enqueueView:itemContentView];
        };
        
        _layoutMetrics = [TGMediaPickerLayoutMetrics defaultLayoutMetrics];
        
        _fetchOriginalImage = ^void(id<TGMediaEditableItem> item, void(^completion)(UIImage *))
        {
            __strong TGWebSearchController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf->_editingContext requestOriginalImageForItem:item completion:completion];
        };
        
        _fetchOriginalThumbnailImage = ^void(id<TGMediaEditableItem> item, void(^completion)(UIImage *))
        {
            __strong TGWebSearchController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf->_editingContext requestOriginalThumbnailImageForItem:item completion:completion];
        };
        
        _recentSearchResults = [self _listItemsFromResults:[TGWebSearchController recentSelectedItems]];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (NSArray *)scopeSearchResults
{
    if (_searchBar.selectedScopeButtonIndex == [self imagesScopeIndex])
        return _imageSearchResults;
    else if (_searchBar.selectedScopeButtonIndex == [self gifsScopeIndex])
        return _gifSearchResults;
    else
        return _recentSearchResults;
}

- (NSArray *)scopeRawSearchResults
{
    if (_searchBar.selectedScopeButtonIndex == [self imagesScopeIndex])
        return _rawImageSearchResults;
    else if (_searchBar.selectedScopeButtonIndex == [self gifsScopeIndex])
        return _rawGifSearchResults;
    else
        return @[];
}

- (bool)scopeMoreResultsAvailable
{
    if (_searchBar.selectedScopeButtonIndex == [self imagesScopeIndex])
        return _imageMoreResultsAvailable;
    else if (_searchBar.selectedScopeButtonIndex == [self gifsScopeIndex])
        return _gifMoreResultsAvailable;
    else
        return false;
}

- (int32_t)scopeMoreResultsOffset {
    if (_searchBar.selectedScopeButtonIndex == [self imagesScopeIndex])
        return 0;
    else if (_searchBar.selectedScopeButtonIndex == [self gifsScopeIndex])
        return _gifMoreResultsOffset;
    else
        return 0;
}

- (NSString *)scopeSearchPath
{
    if (_searchBar.selectedScopeButtonIndex == [self imagesScopeIndex])
        return _imageSearchPath;
    else if (_searchBar.selectedScopeButtonIndex == [self gifsScopeIndex])
        return _gifSearchPath;
    else
        return nil;
}

- (UIView *)nothingFoundView
{
    if (_nothingFoundView == nil)
    {
        _nothingFoundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
        [self.view insertSubview:_nothingFoundView belowSubview:_collectionView];
        _nothingFoundView.frame = CGRectMake(CGFloor((self.view.frame.size.width - _nothingFoundView.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _nothingFoundView.frame.size.height) / 2.0f), _nothingFoundView.frame.size.width, _nothingFoundView.frame.size.height);
        _nothingFoundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        UILabel *nothingFoundLabel = [[UILabel alloc] init];
        nothingFoundLabel.backgroundColor = [UIColor clearColor];
        nothingFoundLabel.textColor = UIColorRGB(0x808080);
        nothingFoundLabel.font = TGLightSystemFontOfSize(16);
        nothingFoundLabel.lineBreakMode = NSLineBreakByWordWrapping;
        nothingFoundLabel.numberOfLines = 0;
        nothingFoundLabel.textAlignment = NSTextAlignmentCenter;
        nothingFoundLabel.text = TGLocalized(@"SearchImages.NoImagesFound");
        [_nothingFoundView addSubview:nothingFoundLabel];
        
        UIImageView *nothingFoundIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NothingFoundIcon.png"]];
        [_nothingFoundView addSubview:nothingFoundIcon];
        
        CGSize size = [nothingFoundLabel sizeThatFits:CGSizeMake(320 - 20, 1000)];
        nothingFoundLabel.frame = CGRectMake(CGFloor((_nothingFoundView.frame.size.width - size.width) / 2), nothingFoundIcon.frame.size.height / 2.0f + 4.0f, size.width, size.height);
        
        nothingFoundIcon.frame = CGRectMake(CGFloor((_nothingFoundView.frame.size.width - nothingFoundIcon.frame.size.width) / 2), -nothingFoundIcon.frame.size.height / 2.0f - 4.0f, nothingFoundIcon.frame.size.width, nothingFoundIcon.frame.size.height);
    }
    
    return _nothingFoundView;
}

- (void)loadView
{
    [super loadView];
    
    self.view.clipsToBounds = true;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _collectionContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    _collectionContainer.backgroundColor = [UIColor whiteColor];
    _collectionContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_collectionContainer];
    
    CGSize frameSize = self.view.bounds.size;
    
    _collectionLayout = [[TGModernMediaListLayout alloc] init];
    _collectionView = [[TGModernMediaCollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height) collectionViewLayout:_collectionLayout];
    _collectionView.alwaysBounceVertical = true;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delaysContentTouches = true;
    _collectionView.canCancelContentTouches = true;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[TGModernMediaListItemView class] forCellWithReuseIdentifier:@"TGModernMediaListItemView"];
    [_collectionContainer addSubview:_collectionView];
    
    _recentSearchResultsTableView = [[TGRecentSearchResultsTableView alloc] initWithFrame:_collectionView.frame style:UITableViewStylePlain];
    _recentSearchResultsTableView.items = [self _recentSearchItems];
    __weak TGWebSearchController *weakSelf = self;
    _recentSearchResultsTableView.itemSelected = ^(NSString *item)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_searchBar resignFirstResponder];
            [strongSelf->_searchBar setText:item];
            [strongSelf searchBarSearchButtonClicked:(UISearchBar *)strongSelf->_searchBar];
        }
    };
    _recentSearchResultsTableView.clearPressed = ^
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf _clearRecentSearchItems];
        }
    };
    [self.view addSubview:_recentSearchResultsTableView];
    
    self.scrollViewsForAutomaticInsetsAdjustment = @[_collectionView, _recentSearchResultsTableView];
    
    if (self.avatarSelection)
        _scopeButtonTitles = @[TGLocalized(@"WebSearch.Images"), TGLocalized(@"WebSearch.RecentSectionTitle")];
    else
        _scopeButtonTitles = @[TGLocalized(@"WebSearch.Images"), TGLocalized(@"WebSearch.GIFs"), TGLocalized(@"WebSearch.RecentSectionTitle")];
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frameSize.width, 0.0f) style:TGSearchBarStyleHeader];
    _searchBar.customScopeButtonTitles = _scopeButtonTitles;
    _searchBar.scopeBarCollapsed = _embedded;
    _searchBar.showsScopeBar = true;
    [_searchBar setAlwaysExtended:true];
    [_searchBar setShowsCancelButton:true animated:false];
    _searchBar.delegate = self;
    [_searchBar sizeToFit];
    _searchBar.delayActivity = false;
    if (!self.avatarSelection)
        _searchBar.selectedScopeButtonIndex = MAX(0, MIN(2, [[[NSUserDefaults standardUserDefaults] objectForKey:@"webSearchSelectedScope"] intValue]));
    [self searchBar:(UISearchBar *)_searchBar selectedScopeButtonIndexDidChange:_searchBar.selectedScopeButtonIndex];
    [self.view addSubview:_searchBar];
    
    if (!self.avatarSelection)
    {
        _toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 44.0f, self.view.frame.size.width, 44.0f)];
        _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _toolbarView.backgroundColor = UIColorRGBA(0xf7f7f7, 1.0f);
        UIView *stripeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _toolbarView.frame.size.width, TGScreenPixel)];
        stripeView.backgroundColor = UIColorRGB(0xb2b2b2);
        stripeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_toolbarView addSubview:stripeView];
        [self.view addSubview:_toolbarView];
        
        _toolbarLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GiphyToolbarLogo.png"]];
        _toolbarLogoView.frame = CGRectMake(CGFloor((_toolbarView.frame.size.width - _toolbarLogoView.frame.size.width) / 2.0f), 9.0f, _toolbarLogoView.frame.size.width, _toolbarLogoView.frame.size.height);
        _toolbarLogoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _toolbarLogoView.hidden = _searchBar.selectedScopeButtonIndex != [self gifsScopeIndex];
        _toolbarLogoView.alpha = _toolbarLogoView.hidden ? 0.0f : 1.0f;
        [_toolbarView addSubview:_toolbarLogoView];
        
        _clearButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _clearButton.hidden = _searchBar.selectedScopeButtonIndex != [self recentScopeIndex] || _recentSearchResults.count == 0;
        _clearButton.exclusiveTouch = true;
        [_clearButton setTitle:TGLocalized(@"WebSearch.RecentSectionClear") forState:UIControlStateNormal];
        [_clearButton setTitleColor:TGAccentColor()];
        _clearButton.titleLabel.font = TGSystemFontOfSize(17);
        _clearButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_clearButton sizeToFit];
        _clearButton.frame = CGRectMake(0, 0, MAX(60, _clearButton.frame.size.width), 44);
        _clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_clearButton addTarget:self action:@selector(clearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView addSubview:_clearButton];
        
        _doneButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        _doneButton.exclusiveTouch = true;
        [_doneButton setTitle:TGLocalized(@"MediaPicker.Send") forState:UIControlStateNormal];
        [_doneButton setTitleColor:TGAccentColor()];
        _doneButton.titleLabel.font = TGMediumSystemFontOfSize(17);
        _doneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 27, 0, 10);
        [_doneButton sizeToFit];
        CGFloat doneButtonWidth = MAX(40, _doneButton.frame.size.width);
        _doneButton.frame = CGRectMake(_toolbarView.frame.size.width - doneButtonWidth, 0, doneButtonWidth, 44);
        _doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _doneButton.enabled = false;
        [_toolbarView addSubview:_doneButton];
        
        static UIImage *countBadgeBackground = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(22.0f, 22.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 22.0f, 22.0f));
            countBadgeBackground = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:11.0f topCapHeight:11.0f];
            UIGraphicsEndImageContext();
        });
        _countBadge = [[UIImageView alloc] initWithImage:countBadgeBackground];
        _countBadge.alpha = 0.0f;
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = TGLightSystemFontOfSize(14);
        [_countBadge addSubview:_countLabel];
        [_doneButton addSubview:_countBadge];
        
        _selectionChangedDisposable = [[SMetaDisposable alloc] init];
        SSignal *combinedSignal = [TGMediaSelectionContext combinedSelectionChangedSignalForContexts:@[ _imageSelectionContext, _gifSelectionContext, _recentSelectionContext ]];
        [_selectionChangedDisposable setDisposable:[combinedSignal startWithNext:^(TGMediaSelectionChange *next)
        {
            __strong TGWebSearchController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf updateSelectionInterface:![next.sender isKindOfClass:[TGMediaSelectionContext class]]];
        }]];
    }
    
    [self _updateExplicitTableInset];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)_updateExplicitTableInset
{
    self.explicitTableInset = UIEdgeInsetsMake(_searchBar.frame.size.height, 0.0f, (_toolbarView != nil) ? 44.0f : 0.0f, 0.0f);
    self.explicitScrollIndicatorInset = self.explicitTableInset;
}

- (CGFloat)_searchBarHeight
{
    return MAX(88.0f, _searchBar.frame.size.height);
}

+ (NSString *)recentSelectedItemsKey
{
    return @"webSearchRecentSelectedItems_v1";
}

+ (void)addRecentSelectedItems:(NSArray *)items
{
    NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
    [updatedItems addObjectsFromArray:items];
    for (id item in [self recentSelectedItems])
    {
        if (![updatedItems containsObject:item])
            [updatedItems addObject:item];
    }
    
    if (updatedItems.count > 1024)
        [updatedItems removeObjectsInRange:NSMakeRange(4, updatedItems.count - 4)];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:updatedItems];
    if (data != nil)
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:[self recentSelectedItemsKey]];
}

+ (NSArray *)recentSelectedItems
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[self recentSelectedItemsKey]];
    if (data != nil)
    {
        @try {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        } @catch (NSException *e) {
            return @[];
        }
    }
    return @[];
}

+ (void)clearRecents
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self recentSelectedItemsKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)_listItemsFromResults:(NSArray *)results
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (id item in results)
    {
        if ([item isKindOfClass:[TGGiphySearchResultItem class]] && !self.avatarSelection)
        {
            TGGiphySearchResultItem *concreteItem = item;
            TGWebSearchGifItem *listItem = [[TGWebSearchGifItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:item];
            listItem.selectionContext = _recentSelectionContext;
            [items addObject:listItem];
        }
        else if ([item isKindOfClass:[TGBingSearchResultItem class]])
        {
            TGBingSearchResultItem *concreteItem = item;
            TGWebSearchImageItem *listItem = [[TGWebSearchImageItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:item];
            listItem.selectionContext = _recentSelectionContext;
            listItem.editingContext = _editingContext;
            [items addObject:listItem];
            
            if (!self.avatarSelection)
            {
                concreteItem.fetchOriginalImage = _fetchOriginalImage;
                concreteItem.fetchOriginalThumbnailImage = _fetchOriginalThumbnailImage;
            }
        }
        else if ([item isKindOfClass:[TGWebSearchInternalImageResult class]])
        {
            TGWebSearchInternalImageResult *concreteItem = item;
            TGWebSearchInternalImageItem *listItem = [[TGWebSearchInternalImageItem alloc] initWithSearchResult:concreteItem];
            listItem.selectionContext = _recentSelectionContext;
            listItem.editingContext = _editingContext;
            [items addObject:listItem];
        
            if (!self.avatarSelection)
            {
                concreteItem.fetchOriginalImage = _fetchOriginalImage;
                concreteItem.fetchOriginalThumbnailImage = _fetchOriginalThumbnailImage;
            }
        }
        else if ([item isKindOfClass:[TGWebSearchInternalGifResult class]] && !self.avatarSelection)
        {
            TGWebSearchInternalGifItem *listItem = [[TGWebSearchInternalGifItem alloc] initWithSearchResult:item];
            listItem.selectionContext = _recentSelectionContext;
            [items addObject:listItem];
        }
        else if ([item isKindOfClass:[TGInternalGifSearchResult class]] && !self.avatarSelection)
        {
            TGInternalGifSearchResultItem *listItem = [[TGInternalGifSearchResultItem alloc] initWithSearchResult:item];
            listItem.selectionContext = _recentSelectionContext;
            [items addObject:listItem];
        }
        else if ([item isKindOfClass:[TGExternalGifSearchResult class]] && !self.avatarSelection)
        {
            TGExternalGifSearchResultItem *listItem = [[TGExternalGifSearchResultItem alloc] initWithSearchResult:item];
            listItem.selectionContext = _recentSelectionContext;
            [items addObject:listItem];
        }
    }
    return items;
}

- (NSArray *)_recentSearchItems
{
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"webSearchRecentQueries"];
    return array;
}

- (void)_addRecentSearchItem:(NSString *)item
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self _recentSearchItems]];
    [array removeObject:item];
    [array insertObject:item atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"webSearchRecentQueries"];
    
    [_recentSearchResultsTableView setItems:array];
}

- (void)_clearRecentSearchItems
{
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"webSearchRecentQueries"];
    [_recentSearchResultsTableView setItems:@[]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGSize frameSize = self.view.bounds.size;
    CGRect collectionViewFrame = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    _collectionViewWidth = collectionViewFrame.size.width;
    _collectionView.frame = collectionViewFrame;
    
    _recentSearchResultsTableView.frame = collectionViewFrame;
    
    [self setup3DTouch];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_appeared)
    {
        [UIView performWithoutAnimation:^
        {
            [_searchBar layoutSubviews];
        }];
        
        if (_searchBar.selectedScopeButtonIndex != [self recentScopeIndex])
            [_searchBar becomeFirstResponder];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || _searchBar.selectedScopeButtonIndex == [self recentScopeIndex])
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self _performEmbeddedTransitionIn];
            });
        }
        
        _appeared = true;
    }
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (bool)shouldIgnoreNavigationBar
{
    return _embedded;
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    CGRect navigationBarFrame = _searchBar.frame;
    navigationBarFrame.origin.y = self.controllerCleanInset.top;
    _searchBar.frame = navigationBarFrame;
        
    [super controllerInsetUpdated:previousInset];
}

- (void)layoutControllerForSize:(CGSize)size duration:(NSTimeInterval)duration
{
    [super layoutControllerForSize:size duration:duration];
    
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
    
    CGSize screenSize = size;
    
    CGAffineTransform tableTransform = _collectionView.transform;
    _collectionView.transform = CGAffineTransformIdentity;
    
    CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _collectionViewWidth = tableFrame.size.width;
    _collectionView.frame = tableFrame;
    
    _recentSearchResultsTableView.frame = _collectionView.frame;
    
    _collectionView.transform = tableTransform;
    
    [_collectionLayout invalidateLayout];
    [_collectionView layoutSubviews];
    
    void (^changeBlock)(void) = ^
    {
        _searchBar.frame = CGRectMake(_searchBar.frame.origin.x, _searchBar.frame.origin.y, size.width, 0.0f);
        [_searchBar sizeToFit];
    };
    
    if (duration > DBL_EPSILON)
    {
        [UIView animateWithDuration:duration animations:changeBlock];
    }
    else
    {
        changeBlock();
    }
    
    [self _updateExplicitTableInset];
}

- (NSInteger)totalSelectionCount
{
    return _imageSelectionContext.count + _gifSelectionContext.count + _recentSelectionContext.count;
}

- (NSMutableArray *)selectedItems
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObjectsFromArray:_imageSelectionContext.selectedItems];
    [items addObjectsFromArray:_gifSelectionContext.selectedItems];
    [items addObjectsFromArray:_recentSelectionContext.selectedItems];
    
    return items;
}

- (void)updateSelectionInterface:(bool)animated
{
    NSUInteger selectedCount = [self totalSelectionCount];
    _doneButton.enabled = selectedCount != 0;
    
    bool incremented = true;
    
    CGFloat badgeAlpha = 0.0f;
    if (selectedCount != 0)
    {
        badgeAlpha = 1.0f;
        
        if (_countLabel.text.length != 0)
            incremented = [_countLabel.text intValue] < (int)selectedCount;
        
        _countLabel.text = [[NSString alloc] initWithFormat:@"%d", (int)selectedCount];
        [_countLabel sizeToFit];
    }
    
    CGFloat badgeWidth = MAX(22, _countLabel.frame.size.width + 14);
    _countBadge.transform = CGAffineTransformIdentity;
    _countBadge.frame = CGRectMake(-badgeWidth + 22, 10 + TGRetinaPixel, badgeWidth, 22);
    _countLabel.frame = CGRectMake(TGRetinaFloor((badgeWidth - _countLabel.frame.size.width) / 2), 2 + TGRetinaPixel, _countLabel.frame.size.width, _countLabel.frame.size.height);
    
    if (animated)
    {
        if (_countBadge.alpha < FLT_EPSILON && badgeAlpha > FLT_EPSILON)
        {
            _countBadge.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _countBadge.alpha = badgeAlpha;
                _countBadge.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
                    {
                        _countBadge.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }
            }];
        }
        else if (_countBadge.alpha > FLT_EPSILON && badgeAlpha < FLT_EPSILON)
        {
            [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _countBadge.alpha = badgeAlpha;
                _countBadge.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    _countBadge.transform = CGAffineTransformIdentity;
                }
            }];
        }
        else
        {
            [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _countBadge.transform = incremented ? CGAffineTransformMakeScale(1.2f, 1.2f) : CGAffineTransformMakeScale(0.8f, 0.8f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
                    {
                        _countBadge.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }
            }];
        }
    }
    else
    {
        _countBadge.transform = CGAffineTransformIdentity;
        _countBadge.alpha = badgeAlpha;
    }
}

- (void)updateEmptyState
{
    bool searching = false;
    if (_searchBar.selectedScopeButtonIndex == [self imagesScopeIndex])
        searching = _searchingImage;
    else if (_searchBar.selectedScopeButtonIndex == [self gifsScopeIndex])
        searching = _searchingGif;
    if ([self scopeSearchPath].length != 0 && !searching && [self scopeSearchResults].count == 0 && _searchBar.selectedScopeButtonIndex != [self recentScopeIndex])
        [self nothingFoundView].hidden = false;
    else
        _nothingFoundView.hidden = true;
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
    
    [_collectionLayout invalidateLayout];
    [_collectionView layoutSubviews];
    
    for (TGModernMediaListItemContentView *itemContentView in _storedItemContentViews)
    {
        [self enqueueView:itemContentView];
    }
    
    [_storedItemContentViews removeAllObjects];
    
    [self updateEmptyState];
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return (_collectionViewWidth >= _layoutMetrics.widescreenWidth - FLT_EPSILON) ? _layoutMetrics.wideItemSize : _layoutMetrics.normalItemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    if (ABS(_collectionViewWidth - 540.0f) < FLT_EPSILON)
        return UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    
    return (_collectionViewWidth >= _layoutMetrics.widescreenWidth - FLT_EPSILON) ? _layoutMetrics.wideEdgeInsets : _layoutMetrics.normalEdgeInsets;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return (_collectionViewWidth >= _layoutMetrics.widescreenWidth - FLT_EPSILON) ? _layoutMetrics.wideLineSpacing : _layoutMetrics.normalLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return (NSInteger)[self scopeSearchResults].count;
}

- (TGModernMediaListItemContentView *)dequeueViewForItem:(id<TGModernMediaListItem>)item synchronously:(bool)synchronously
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
        [itemView setItem:item synchronously:synchronously];
        
        return itemView;
    }
    
    TGModernMediaListItemContentView *itemView = [views lastObject];
    [views removeLastObject];
    
    [itemView setItem:item synchronously:synchronously];
    
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
        [itemView prepareForReuse];
        [views addObject:itemView];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.item;
    if (index < 0)
    {
        TGModernMediaListItemView *itemView = (TGModernMediaListItemView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGModernMediaListItemView" forIndexPath:indexPath];
        return itemView;
    }
    else
    {
        id<TGModernMediaListItem> item = [self scopeSearchResults][index];
        
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
            itemContentView = [self dequeueViewForItem:item synchronously:_loadItemsSynchronously];
        
        [itemView setItemContentView:itemContentView];
        
        bool hidden = (_hiddenItem != nil && [_hiddenItem isEqual:itemContentView.item]);
        [itemContentView setHidden:hidden animated:false];
        
        return itemView;
    }
}

- (UIView *)referenceViewForSearchResult:(id<TGWebSearchResult>)searchResult
{
    if (searchResult == nil)
        return nil;
    
    for (TGModernMediaListItemView *itemView in [_collectionView visibleCells])
    {
        if ([[(id<TGWebSearchListItem>)itemView.itemContentView.item webSearchResult] isEqual:searchResult])
            return itemView.itemContentView;
    }
    
    return nil;
}

- (id<TGWebSearchListItem>)listItemForSearchResult:(id<TGWebSearchResult>)searchResult
{
    if (searchResult == nil)
        return nil;
    
    for (id<TGWebSearchListItem> item in [self scopeSearchResults])
    {
        if ([[item webSearchResult] isEqual:searchResult])
            return item;
    }
    
    return nil;
}

- (id<TGWebSearchResultsGalleryItem>)galleryItemForWebSearchResult:(id<TGWebSearchResult>)result
{
    if ([result isKindOfClass:[TGWebSearchInternalImageResult class]])
    {
        return [[TGWebSearchResultsGalleryInternalImageItem alloc] initWithSearchResult:(TGWebSearchInternalImageResult *)result];
    }
    else if ([result isKindOfClass:[TGWebSearchInternalGifResult class]])
    {
        return [[TGWebSearchResultsGalleryInternalGifItem alloc] initWithSearchResult:(TGWebSearchInternalGifResult *)result];
    }
    else if ([result isKindOfClass:[TGBingSearchResultItem class]])
    {
        return [[TGWebSearchResultsGalleryImageItem alloc] initWithImageUrl:((TGBingSearchResultItem *)result).imageUrl imageSize:((TGBingSearchResultItem *)result).imageSize searchResultItem:(TGBingSearchResultItem *)result];
    }
    else if ([result isKindOfClass:[TGGiphySearchResultItem class]])
    {
        return [[TGWebSearchResultsGalleryGifItem alloc] initWithGiphySearchResultItem:(TGGiphySearchResultItem *)result];
    }
    else if ([result isKindOfClass:[TGInternalGifSearchResult class]]) {
        return [[TGInternalGifSearchResultGalleryItem alloc] initWithSearchResult:(TGInternalGifSearchResult *)result];
    } else if ([result isKindOfClass:[TGExternalGifSearchResult class]]) {
        return [[TGExternalGifSearchResultGalleryItem alloc] initWithSearchResultItem:(TGExternalGifSearchResult *)result];
    }
    
    return nil;
}

- (NSArray *)prepareGalleryItemsWithEnumerationBlock:(void (^)(id<TGWebSearchResultsGalleryItem> item))enumerationBlock
{
    NSMutableArray *galleryItems = [[NSMutableArray alloc] init];
    
    for (id<TGWebSearchListItem> item in [self scopeSearchResults])
    {
        id<TGWebSearchResultsGalleryItem> galleryItem = [self galleryItemForWebSearchResult:[item webSearchResult]];
        galleryItem.selectionContext = item.selectionContext;
        if ([galleryItem conformsToProtocol:@protocol(TGModernGalleryEditableItem)])
            ((id<TGModernGalleryEditableItem>)galleryItem).editingContext = _editingContext;
        
        if (galleryItem != nil)
        {
            if (enumerationBlock != nil)
                enumerationBlock(galleryItem);
            
            [galleryItems addObject:galleryItem];
        }
    }
    return galleryItems;
}

- (TGModernGalleryController *)createGalleryControllerForItem:(id<TGWebSearchListItem>)item previewMode:(bool)previewMode
{
    __weak TGWebSearchController *weakSelf = self;
    TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
    modernGallery.previewMode = previewMode;
    
    __block id<TGModernGalleryItem> focusItem = nil;
    NSArray *galleryItems = [self prepareGalleryItemsWithEnumerationBlock:^(id<TGWebSearchResultsGalleryItem> galleryItem)
    {
        if ([[galleryItem webSearchResult] isEqual:[item webSearchResult]])
            focusItem = galleryItem;
    }];

    TGMediaPickerGalleryModel *model = [[TGMediaPickerGalleryModel alloc] initWithItems:galleryItems focusItem:focusItem selectionContext:item.selectionContext editingContext:_editingContext hasCaptions:self.captionsEnabled hasTimer:false inhibitDocumentCaptions:false hasSelectionPanel:false recipientName:self.recipientName];
    model.suggestionContext = self.suggestionContext;
    model.controller = modernGallery;
    model.externalSelectionCount = ^NSInteger
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return 0;
        
        return [strongSelf totalSelectionCount];
    };
    model.useGalleryImageAsEditableItemImage = true;
    model.storeOriginalImageForItem = ^(id<TGMediaEditableItem> editableItem, UIImage *originalImage)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_editingContext setOriginalImage:originalImage forItem:editableItem synchronous:false];
    };
    model.willFinishEditingItem = ^(id<TGMediaEditableItem> editableItem, id<TGMediaEditAdjustments> adjustments, id representation, bool hasChanges)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (hasChanges)
            [strongSelf->_editingContext setAdjustments:adjustments forItem:editableItem];
        
        [strongSelf->_editingContext setTemporaryRep:representation forItem:editableItem];
        
        if (item.selectionContext != nil && adjustments != nil && [editableItem conformsToProtocol:@protocol(TGMediaSelectableItem)])
            [item.selectionContext setItem:(id<TGMediaSelectableItem>)editableItem selected:true];
    };
    model.didFinishEditingItem = ^(id<TGMediaEditableItem> editableItem, __unused id<TGMediaEditAdjustments> adjustments, UIImage *resultImage, UIImage *thumbnailImage)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_editingContext setImage:resultImage thumbnailImage:thumbnailImage forItem:editableItem synchronous:true];
    };
    model.saveItemCaption = ^(id<TGMediaEditableItem> editableItem, NSString *caption)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_editingContext setCaption:caption forItem:editableItem];
        
        if (item.selectionContext != nil && caption.length > 0 && [editableItem conformsToProtocol:@protocol(TGMediaSelectableItem)])
            [item.selectionContext setItem:(id<TGMediaSelectableItem>)editableItem selected:true];
    };
    [model.interfaceView updateSelectionInterface:[self totalSelectionCount] counterVisible:([self totalSelectionCount] > 0) animated:false];
    model.interfaceView.donePressed = ^(id<TGWebSearchResultsGalleryItem> item)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
    
        NSMutableArray *selectedItems = [strongSelf selectedItems];
        
        if (selectedItems.count == 0)
            [selectedItems addObject:[item webSearchResult]];
        
        strongSelf->_selectedItems = selectedItems;
        [strongSelf complete];
    };
    _galleryModel = model;
    modernGallery.model = model;
    
    __weak TGModernGalleryController *weakGallery = modernGallery;
    modernGallery.itemFocused = ^(id<TGWebSearchResultsGalleryItem> item)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        __strong TGModernGalleryController *strongGallery = weakGallery;
        if (strongSelf != nil)
        {
            if (strongGallery.previewMode)
                return;
            
            id<TGWebSearchListItem> listItem = [strongSelf listItemForSearchResult:[item webSearchResult]];
            strongSelf->_hiddenItem = listItem;
            [strongSelf updateHiddenItemAnimated:false];
        }
    };

    modernGallery.beginTransitionIn = ^UIView *(id<TGWebSearchResultsGalleryItem> item, __unused TGModernGalleryItemView *itemView)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        __strong TGModernGalleryController *strongGallery = weakGallery;
        if (strongSelf != nil)
        {
            if (strongGallery.previewMode)
                return nil;
            
            return [strongSelf referenceViewForSearchResult:[item webSearchResult]];
        }
        
        return nil;
    };

    modernGallery.beginTransitionOut = ^UIView *(id<TGWebSearchResultsGalleryItem> item, __unused TGModernGalleryItemView *itemView)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            return [strongSelf referenceViewForSearchResult:[item webSearchResult]];
        }
        
        return nil;
    };

    modernGallery.completedTransitionOut = ^
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf->_hiddenItem = nil;
            [strongSelf updateHiddenItemAnimated:true];
        }
    };
    
    if (!previewMode)
    {
        TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:modernGallery];
        controllerWindow.hidden = false;
        modernGallery.view.clipsToBounds = true;
    }

    return modernGallery;
}

- (void)updateHiddenItemAnimated:(bool)animated
{
    for (TGModernMediaListItemView *itemView in [_collectionView visibleCells])
    {
        bool hidden = (_hiddenItem != nil && [_hiddenItem isEqual:itemView.itemContentView.item]);
        [itemView.itemContentView setHidden:hidden animated:animated];
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<TGWebSearchListItem> item = [self scopeSearchResults][indexPath.row];
    
    if (self.avatarSelection)
    {
        if (![[item webSearchResult] conformsToProtocol:@protocol(TGMediaEditableItem)])
            return;
        
        UIImage *thumbnailImage = nil;
        TGModernMediaListItemView *listItemView = (TGModernMediaListItemView *)[_collectionView cellForItemAtIndexPath:indexPath];
        
        if ([listItemView.itemContentView isKindOfClass:[TGWebSearchImageItemView class]])
        {
            TGWebSearchImageItemView *itemContentView = (TGWebSearchImageItemView *)listItemView.itemContentView;
            thumbnailImage = itemContentView.imageView.image;
        }
        
        __weak TGWebSearchController *weakSelf = self;
        TGPhotoEditorController *controller = [[TGPhotoEditorController alloc] initWithItem:(id<TGMediaEditableItem>)item.webSearchResult intent:TGPhotoEditorControllerAvatarIntent | TGPhotoEditorControllerWebIntent adjustments:nil caption:nil screenImage:thumbnailImage availableTabs:[TGPhotoEditorController defaultTabsForAvatarIntent] selectedTab:TGPhotoEditorCropTab];
        controller.editingContext = _editingContext;
        controller.didFinishEditing = ^(PGPhotoEditorValues *editorValues, UIImage *resultImage, __unused UIImage *thumbnailImage, bool hasChanges)
        {
            if (!hasChanges)
                return;
         
            __strong TGWebSearchController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (strongSelf.avatarCompletionBlock != nil)
                strongSelf.avatarCompletionBlock(resultImage);
            
            if (TGAppDelegateInstance.saveEditedPhotos && [editorValues toolsApplied])
                [[[TGMediaAssetsLibrary sharedLibrary] saveAssetWithImage:resultImage] startWithNext:nil];
        };
        controller.requestThumbnailImage = ^SSignal *(id<TGMediaEditableItem> editableItem)
        {
            return [editableItem thumbnailImageSignal];
        };
        controller.requestOriginalScreenSizeImage = ^SSignal *(id<TGMediaEditableItem> editableItem, NSTimeInterval position)
        {
            return [editableItem screenImageSignal:position];
        };
        controller.requestOriginalFullSizeImage = ^SSignal *(id<TGMediaEditableItem> editableItem, NSTimeInterval position)
        {
            return [editableItem originalImageSignal:position];
        };
        
        UINavigationController *navController = self.parentNavigationController ? : self.navigationController;
        [navController pushViewController:controller animated:true];
    }
    else
    {
        [self createGalleryControllerForItem:item previewMode:false];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self scopeSearchPath].length != 0 && !_searchBar.showActivity && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.size.height && _searchString.length != 0 && [self scopeMoreResultsAvailable])
    {
        _searchBar.showActivity = true;
        
        [ActionStageInstance() requestActor:[self scopeSearchPath] options:@{@"query": _searchString, @"currentItems": [self scopeRawSearchResults], @"moreResultsOffset": @([self scopeMoreResultsOffset])} flags:0 watcher:self];
    }
}

- (void)_updateSearchQuery:(NSString *)query
{
    NSString *currentImageSearchPath = _imageSearchPath;
    NSString *currentGifSearchPath = _gifSearchPath;
    
    if (currentImageSearchPath != nil)
        [ActionStageInstance() removeWatcher:self fromPath:currentImageSearchPath];
    if (currentGifSearchPath != nil)
        [ActionStageInstance() removeWatcher:self fromPath:currentGifSearchPath];
    
    if (query.length == 0)
    {
        _imageSearchPath = nil;
        _gifSearchPath = nil;
        _searchString = nil;
        _imageMoreResultsAvailable = false;
        _gifMoreResultsAvailable = false;
        _gifMoreResultsOffset = 0;
        _searchBar.showActivity = false;
        
        _rawImageSearchResults = nil;
        _imageSearchResults = nil;
        [_imageSelectionContext clear];
        
        _rawGifSearchResults = nil;
        _gifSearchResults = nil;
        [_gifSelectionContext clear];
        
        [self updateSelectionInterface:false];
        
        _recentSearchResultsTableView.hidden = _searchBar.selectedScopeButtonIndex == [self recentScopeIndex];
    }
    else
    {
        _recentSearchResultsTableView.hidden = true;
        
        _imageSearchPath = [[NSString alloc] initWithFormat:@"/search/%@/(%d)", @"bing", (int)murMurHash32(query)];
        _gifSearchPath = [[NSString alloc] initWithFormat:@"/search/%@/(%d)", @"giphy", (int)murMurHash32(query)];
    }
    
    _nothingFoundView.hidden = true;
    
    if (!TGStringCompare(_imageSearchPath, currentImageSearchPath))
    {
        _rawImageSearchResults = nil;
        _imageSearchResults = nil;
        [_imageSelectionContext clear];

        _rawGifSearchResults = nil;
        _gifSearchResults = nil;
        [_gifSelectionContext clear];
        
        [self updateSelectionInterface:false];
        
        _searchString = query;
        _imageMoreResultsAvailable = false;
        _gifMoreResultsAvailable = false;
        _gifMoreResultsOffset = 0;
        
        if (_imageSearchPath.length != 0)
        {
            _searchBar.showActivity = true;
            _searchingImage = true;
            [ActionStageInstance() requestActor:_imageSearchPath options:@{@"query": query} flags:0 watcher:self];
        }
        
        if (_gifSearchPath.length != 0)
        {
            _searchBar.showActivity = true;
            _searchingGif = true;
            [ActionStageInstance() requestActor:_gifSearchPath options:@{@"query": query} flags:0 watcher:self];
        }
        
        [self reloadData];
    }
}

- (void)searchBar:(TGSearchBar *)__unused searchBar willChangeHeight:(CGFloat)__unused newHeight
{
    searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, searchBar.frame.size.width, newHeight);
}

- (void)searchBarCancelButtonClicked:(TGSearchBar *)__unused searchBar
{
    [_searchBar endEditing:true];
    
    if (self.dismiss != nil)
        self.dismiss();
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)__unused searchBar
{
    if (_searchBar.text.length != 0)
        [self _addRecentSearchItem:_searchBar.text];
    [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top)];
    [self _updateSearchQuery:_searchBar.text];
    
    if (_searchBar.selectedScopeButtonIndex == [self recentScopeIndex])
    {
        _searchBar.selectedScopeButtonIndex = 0;
        [self searchBar:(UISearchBar *)_searchBar selectedScopeButtonIndexDidChange:0];
    }
}

- (void)searchBar:(UISearchBar *)__unused searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)
        [self _updateSearchQuery:searchText];
}

- (void)searchBar:(UISearchBar *)__unused searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [_searchBar resignFirstResponder];
    
    if (!self.avatarSelection)
        [[NSUserDefaults standardUserDefaults] setObject:@((int)selectedScope) forKey:@"webSearchSelectedScope"];
    [self updateToolbarItemsAnimated:true];
    _recentSearchResultsTableView.hidden = selectedScope == [self recentScopeIndex] || _searchString.length != 0;
    [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top)];
    _loadItemsSynchronously = true;
    [_collectionView reloadData];
    [_collectionView layoutSubviews];
    _loadItemsSynchronously = false;
    
    bool searching = false;
    if (_searchBar.selectedScopeButtonIndex == [self imagesScopeIndex])
        searching = _searchingImage;
    else if (_searchBar.selectedScopeButtonIndex == [self gifsScopeIndex])
        searching = _searchingGif;
    if ([self scopeSearchPath].length != 0 && !searching && [self scopeSearchResults].count == 0 && _searchBar.selectedScopeButtonIndex != [self recentScopeIndex])
        [self nothingFoundView].hidden = false;
    else
        _nothingFoundView.hidden = true;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)__unused searchBar
{
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
        [self _performEmbeddedTransitionIn];
}

- (void)updateToolbarItemsAnimated:(bool)animated
{
    bool logoViewHidden = _searchBar.selectedScopeButtonIndex != [self gifsScopeIndex];
    bool clearButtonHidden = _searchBar.selectedScopeButtonIndex != [self recentScopeIndex] || _recentSearchResults.count == 0;
    
    if (animated)
    {
        _toolbarLogoView.hidden = false;
        _clearButton.hidden = clearButtonHidden;
        
        [UIView animateWithDuration:0.15f animations:^
        {
            _toolbarLogoView.alpha = logoViewHidden ? 0.0f : 1.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                _toolbarLogoView.hidden = logoViewHidden;
                _clearButton.hidden = clearButtonHidden;
            }
        }];
    }
    else
    {
        _toolbarLogoView.hidden = logoViewHidden;
        _toolbarLogoView.alpha = _toolbarLogoView.hidden ? 0.0f : 1.0f;
        _clearButton.hidden = clearButtonHidden;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)__unused scrollView
{
    [_searchBar resignFirstResponder];
}

- (void)clearButtonPressed
{
    __weak TGWebSearchController *weakSelf = self;
    
    TGActionSheetAction *confirmAction = [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"WebSearch.RecentSectionClear") action:@"confirm" type:TGActionSheetActionTypeDestructive];
    TGActionSheetAction *cancelAction = [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel];
    TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:TGLocalized(@"WebSearch.RecentClearConfirmation") actions:@[ confirmAction, cancelAction ] actionBlock:^(__unused id target, NSString *action)
    {
        if ([action isEqualToString:@"confirm"])
        {
            __strong TGWebSearchController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [TGWebSearchController clearRecents];
            
            strongSelf->_recentSearchResults = nil;
            [strongSelf reloadData];
            
            [strongSelf->_recentSelectionContext clear];
            
            strongSelf->_clearButton.hidden = true;
        }
    } target:self];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        [actionSheet showInView:self.view];
    else
        [actionSheet showFromRect:[self.view convertRect:_clearButton.frame fromView:_clearButton.superview] inView:self.view animated:true];
}

- (void)doneButtonPressed
{
    _selectedItems = [self selectedItems];
    
    [self complete];
}

- (void)complete
{
    [TGWebSearchController addRecentSelectedItems:_selectedItems];
    
    if (self.completionBlock != nil)
        self.completionBlock(self);
    
    TGMediaPickerGalleryModel *galleryModel = _galleryModel;
    if (galleryModel != nil)
    {
        if (galleryModel.dismiss)
            galleryModel.dismiss(true, false);
    }
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (NSArray *)selectedItemSignals:(id (^)(id, NSString *))imageDescriptionGenerator
{
    NSMutableArray *resultSignals = [[NSMutableArray alloc] init];
    
    for (id<TGWebSearchResult> item in _selectedItems)
    {
        NSString *caption = nil;
        id<TGMediaEditAdjustments> adjustments = nil;
        if ([item conformsToProtocol:@protocol(TGMediaEditableItem)])
        {
            caption = [_editingContext captionForItem:(id<TGMediaEditableItem>)item];
            adjustments = [_editingContext adjustmentsForItem:(id<TGMediaEditableItem>)item];
        }
        if (caption.length == 0)
            caption = nil;
        
        SSignal *signal = [SSignal single:item];
        
        if ([item conformsToProtocol:@protocol(TGMediaEditableItem)] && [item respondsToSelector:@selector(screenImageSignal:)])
        {
            signal = [[[[_editingContext imageSignalForItem:(id<TGMediaEditableItem>)item] filter:^bool(id result)
            {
                return result == nil || ([result isKindOfClass:[UIImage class]] && !((UIImage *)result).degraded);
            }] take:1] mapToSignal:^SSignal *(id result)
            {
                if (result == nil)
                {
                    return [SSignal single:item];
                }
                else if ([result isKindOfClass:[UIImage class]])
                {
                    UIImage *image = (UIImage *)result;
                    image.edited = true;
                    return [SSignal single:image];
                }
                
                return [SSignal complete];
            }];
        }
        
        signal = [signal mapToSignal:^SSignal *(id item)
        {
            if (item == nil)
                return [SSignal complete];
            
            NSArray *stickers = adjustments.paintingData.stickers;
            id generatedItem = nil;
            if ([item isKindOfClass:[UIImage class]] && stickers.count > 0)
            {
                NSDictionary *dictItem = @
                {
                    @"type": @"webPhoto",
                    @"image": item,
                    @"stickers": stickers
                };
                generatedItem = imageDescriptionGenerator(dictItem, caption);
            }
            else
            {
                generatedItem = imageDescriptionGenerator(item, caption);
            }
            if (generatedItem == nil)
                return [SSignal complete];
            
            return [SSignal single:generatedItem];
        }];
        
        [resultSignals addObject:signal];
    }
    
    return resultSignals;
}

- (NSArray *)uniqueItemsInArray:(NSArray *)array
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSMutableArray *set = [[NSMutableArray alloc] init];
    
    for (id item in array)
    {
        if (![set containsObject:item])
        {
            [set addObject:item];
            [result addObject:item];
        }
    }
    
    return result;
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    TGDispatchOnMainThread(^
    {
        if ([path isEqualToString:_imageSearchPath])
        {
            _searchingImage = false;
            _searchBar.showActivity = _searchingGif;
            
            if (status == ASStatusSuccess)
            {
                NSMutableArray *searchResults = [[NSMutableArray alloc] init];
                
                for (id item in result[@"items"])
                {
                    if ([item isKindOfClass:[TGGiphySearchResultItem class]])
                    {
                        TGGiphySearchResultItem *concreteItem = item;
                        TGWebSearchGifItem *listItem = [[TGWebSearchGifItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:concreteItem];
                        listItem.selectionContext = _gifSelectionContext;
                        [searchResults addObject:listItem];
                    }
                    else if ([item isKindOfClass:[TGBingSearchResultItem class]])
                    {
                        TGBingSearchResultItem *concreteItem = item;
                        TGWebSearchImageItem *listItem = [[TGWebSearchImageItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:concreteItem];
                        listItem.selectionContext = _imageSelectionContext;
                        listItem.editingContext = _editingContext;
                        [searchResults addObject:listItem];
                        
                        if (!self.avatarSelection)
                        {
                            concreteItem.fetchOriginalImage = _fetchOriginalImage;
                            concreteItem.fetchOriginalThumbnailImage = _fetchOriginalThumbnailImage;
                        }
                    }
                    else if ([item isKindOfClass:[TGInternalGifSearchResult class]] && !self.avatarSelection)
                    {
                        TGInternalGifSearchResultItem *listItem = [[TGInternalGifSearchResultItem alloc] initWithSearchResult:item];
                        listItem.selectionContext = _gifSelectionContext;
                        [searchResults addObject:listItem];
                    }
                    else if ([item isKindOfClass:[TGExternalGifSearchResult class]] && !self.avatarSelection)
                    {
                        TGExternalGifSearchResultItem *listItem = [[TGExternalGifSearchResultItem alloc] initWithSearchResult:item];
                        listItem.selectionContext = _gifSelectionContext;
                        [searchResults addObject:listItem];
                    }
                }
                
                _imageSearchResults = [self uniqueItemsInArray:searchResults];
                _rawImageSearchResults = result[@"items"];
                _imageMoreResultsAvailable = [result[@"moreResultsAvailable"] boolValue];
                
                if (_searchBar.selectedScopeButtonIndex == [self imagesScopeIndex])
                    [self reloadData];
            }
        }
        else if ([path isEqualToString:_gifSearchPath])
        {
            _searchingGif = false;
            _searchBar.showActivity = _searchingImage;
            
            if (status == ASStatusSuccess)
            {
                NSMutableArray *searchResults = [[NSMutableArray alloc] init];
                
                for (id item in result[@"items"])
                {
                    if ([item isKindOfClass:[TGGiphySearchResultItem class]])
                    {
                        TGGiphySearchResultItem *concreteItem = item;
                        TGWebSearchGifItem *listItem = [[TGWebSearchGifItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:concreteItem];
                        listItem.selectionContext = _gifSelectionContext;
                        [searchResults addObject:listItem];
                    }
                    else if ([item isKindOfClass:[TGBingSearchResultItem class]])
                    {
                        TGBingSearchResultItem *concreteItem = item;
                        TGWebSearchImageItem *listItem = [[TGWebSearchImageItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:concreteItem];
                        listItem.selectionContext = _imageSelectionContext;
                        listItem.editingContext = _editingContext;
                        [searchResults addObject:listItem];
                        
                        if (!self.avatarSelection)
                        {
                            concreteItem.fetchOriginalImage = _fetchOriginalImage;
                            concreteItem.fetchOriginalThumbnailImage = _fetchOriginalThumbnailImage;
                        }
                    }
                    else if ([item isKindOfClass:[TGInternalGifSearchResult class]] && !self.avatarSelection)
                    {
                        TGInternalGifSearchResultItem *listItem = [[TGInternalGifSearchResultItem alloc] initWithSearchResult:item];
                        listItem.selectionContext = _gifSelectionContext;
                        [searchResults addObject:listItem];
                    }
                    else if ([item isKindOfClass:[TGExternalGifSearchResult class]] && !self.avatarSelection)
                    {
                        TGExternalGifSearchResultItem *listItem = [[TGExternalGifSearchResultItem alloc] initWithSearchResult:item];
                        listItem.selectionContext = _gifSelectionContext;
                        [searchResults addObject:listItem];
                    }
                }
                
                _gifSearchResults = [self uniqueItemsInArray:searchResults];
                _rawGifSearchResults = result[@"items"];
                _gifMoreResultsAvailable = [result[@"moreResultsAvailable"] boolValue];
                _gifMoreResultsOffset = [result[@"moreResultsOffset"] intValue];
                
                if (_searchBar.selectedScopeButtonIndex == [self gifsScopeIndex])
                    [self reloadData];
            }
        }
    });
}

- (NSInteger)imagesScopeIndex
{
    return 0;
}

- (NSInteger)gifsScopeIndex
{
    if (_avatarSelection)
        return -1;
    
    return 1;
}

- (NSInteger)recentScopeIndex
{
    if (_avatarSelection)
        return 1;
    
    return 2;
}

- (void)presentEmbeddedInController:(UIViewController *)controller animated:(bool)__unused animated
{
    _embedded = true;
    //[controller addChildViewController:self];
    
    self.view.frame = controller.view.bounds;
    
    [self beginAppearanceTransition:true animated:false];
    [controller.view addSubview:self.view];
    
    self.view.backgroundColor = [UIColor clearColor];
    _collectionContainer.alpha = 0.0f;
    _searchBar.alpha = 0.0f;
    _toolbarView.alpha = 0.0f;
    _recentSearchResultsTableView.alpha = 0.0f;
    
    [self endAppearanceTransition];
}

- (void)_performEmbeddedTransitionIn
{
    if (!_embedded || !_searchBar.scopeBarCollapsed)
        return;
    
    CGRect recentTableFrame = _recentSearchResultsTableView.frame;
    CGRect collectionFrame = _collectionContainer.frame;
    [UIView performWithoutAnimation:^
    {
        [_searchBar setCustomScopeBarHidden:true];
        [_searchBar layoutSubviews];
        
        _recentSearchResultsTableView.frame = CGRectOffset(_recentSearchResultsTableView.frame, 0, -44);
        _collectionContainer.frame = CGRectOffset(_collectionContainer.frame, 0, -44);
    }];
    
    TGDispatchAfter(0.015, dispatch_get_main_queue(), ^
    {
        [UIView animateWithDuration:0.2 animations:^
        {
            _searchBar.alpha = 1.0f;
        }];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowAnimatedContent animations:^
        {
            _searchBar.scopeBarCollapsed = false;
            [_searchBar setSearchBarShouldShowScopeControl:true];
            
            _collectionContainer.alpha = 1.0f;
            _collectionContainer.frame = collectionFrame;
            
            _toolbarView.alpha = 1.0f;
            
            if (_recentSearchResultsTableView.items.count > 0)
                _recentSearchResultsTableView.alpha = 1.0f;
            _recentSearchResultsTableView.frame = recentTableFrame;
        } completion:^(__unused BOOL finished)
        {
            self.view.backgroundColor = [UIColor whiteColor];
        }];
        
        [UIView animateWithDuration:0.2 delay:0.08 options:UIViewAnimationOptionAllowAnimatedContent animations:^
        {
            [_searchBar setCustomScopeBarHidden:false];
        } completion:nil];
        
        [self _updateExplicitTableInset];
    });
}

- (void)dismissEmbeddedAnimated:(bool)__unused animated
{
    [self beginAppearanceTransition:false animated:false];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^
    {
        _searchBar.alpha = 0.0f;
        [_searchBar setCustomScopeBarHidden:true];
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowAnimatedContent animations:^
    {
        _searchBar.scopeBarCollapsed = true;
        [_searchBar setSearchBarShouldShowScopeControl:false];
        
        _collectionContainer.alpha = 0.0f;
        _collectionContainer.frame = CGRectOffset(_collectionContainer.frame, 0, -44);
        
        _toolbarView.alpha = 0.0f;
        
        _recentSearchResultsTableView.alpha = 0.0f;
        _recentSearchResultsTableView.frame = CGRectOffset(_recentSearchResultsTableView.frame, 0, -44);
    } completion:^(__unused BOOL finished)
    {
        [self.view removeFromSuperview];
        
        [self endAppearanceTransition];
        [self removeFromParentViewController];
    }];
}

- (void)setup3DTouch
{
    if (_checked3dTouch)
        return;
    
    _checked3dTouch = true;
    if (iosMajorVersion() >= 9)
    {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
            [self registerForPreviewingWithDelegate:(id)self sourceView:self.view];
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    CGPoint point = [self.view convertPoint:location toView:_collectionView];
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
    if (indexPath == nil)
        return nil;
    
    CGRect cellFrame = [_collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame;
    previewingContext.sourceRect = [self.view convertRect:cellFrame fromView:_collectionView];
    
    id<TGWebSearchListItem> item = [self scopeSearchResults][indexPath.row];
    CGSize dimensions = CGSizeZero;
    
    if ([item.webSearchResult isKindOfClass:[TGWebSearchInternalImageResult class]])
        [((TGWebSearchInternalImageResult *)item.webSearchResult).imageInfo imageUrlForLargestSize:&dimensions];
    else if ([item.webSearchResult isKindOfClass:[TGWebSearchInternalGifResult class]])
        [((TGWebSearchInternalGifResult *)item.webSearchResult).thumbnailInfo imageUrlForLargestSize:&dimensions];
    else if ([item.webSearchResult isKindOfClass:[TGInternalGifSearchResult class]])
        [((TGInternalGifSearchResult *)item.webSearchResult).document.thumbnailInfo imageUrlForLargestSize:&dimensions];
    else if ([item.webSearchResult isKindOfClass:[TGGiphySearchResultItem class]])
        dimensions = ((TGGiphySearchResultItem *)item.webSearchResult).gifSize;
    else if ([item.webSearchResult isKindOfClass:[TGExternalGifSearchResult class]])
        dimensions = ((TGExternalGifSearchResult *)item.webSearchResult).size;
    else if ([item.webSearchResult isKindOfClass:[TGBingSearchResultItem class]])
        dimensions = ((TGBingSearchResultItem *)item.webSearchResult).imageSize;
    
    UIViewController *controller = [self createGalleryControllerForItem:item previewMode:true];
    controller.preferredContentSize = TGFitSize(dimensions, self.view.frame.size);
    return controller;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)__unused previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    if ([viewControllerToCommit isKindOfClass:[TGModernGalleryController class]])
    {
        TGModernGalleryController *controller = (TGModernGalleryController *)viewControllerToCommit;
        controller.previewMode = false;
        
        TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:controller];
        controllerWindow.hidden = false;
        controller.view.clipsToBounds = true;
    }
}

@end
