#import "TGWebSearchController.h"

#import "ActionStage.h"

#import "TGSearchBar.h"
#import "TGModernButton.h"

#import "TGStringUtils.h"
#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGModernMediaListLayout.h"
#import "TGModernMediaListItem.h"
#import "TGModernMediaListItemView.h"
#import "TGModernMediaListItemContentView.h"

#import "TGGiphySearchResultItem.h"
#import "TGWebSearchGifItem.h"
#import "TGWebSearchGifItemView.h"

#import "TGBingSearchResultItem.h"
#import "TGWebSearchImageItem.h"
#import "TGWebSearchImageItemView.h"

#import "TGWebSearchInternalImageResult.h"
#import "TGWebSearchInternalImageItem.h"
#import "TGWebSearchInternalImageItemView.h"

#import "TGWebSearchInternalGifResult.h"
#import "TGWebSearchInternalGifItem.h"
#import "TGWebSearchInternalGifItemView.h"

#import "TGModernGalleryController.h"
#import "TGWebSearchResultsGalleryModel.h"
#import "TGWebSearchResultsGalleryImageItem.h"
#import "TGWebSearchResultsGalleryGifItem.h"
#import "TGWebSearchResultsGalleryInternalImageItem.h"
#import "TGWebSearchResultsGalleryInternalGifItem.h"

#import "TGOverlayControllerWindow.h"

#import "TGRecentSearchResultsTableView.h"

#import "TGDoubleTapGestureRecognizer.h"

@interface TGWebSearchController () <TGSearchBarDelegate, ASWatcher, UICollectionViewDataSource, UICollectionViewDelegate>
{
    CGSize _normalItemSize;
    CGSize _wideItemSize;
    CGFloat _widescreenWidth;
    CGFloat _normalLineSpacing;
    CGFloat _wideLineSpacing;
    
    UIEdgeInsets _normalEdgeInsets;
    UIEdgeInsets _wideEdgeInsets;
    
    TGSearchBar *_searchBar;
    UIView *_toolbarView;
    UIImageView *_toolbarLogoView;
    TGModernButton *_doneButton;
    UIImageView *_countBadge;
    UILabel *_countLabel;
    
    NSString *_searchString;
    
    NSString *_imageSearchPath;
    NSString *_gifSearchPath;
    
    bool _editingRecents;
    
    NSArray *_imageSearchResults;
    NSArray *_rawImageSearchResults;
    NSArray *_selectedImageItems;
    bool _imageMoreResultsAvailable;
    bool _searchingImage;
    
    NSArray *_gifSearchResults;
    NSArray *_rawGifSearchResults;
    NSArray *_selectedGifItems;
    bool _gifMoreResultsAvailable;
    bool _searchingGif;

    NSArray *_recentSearchResults;
    NSArray *_selectedRecentItems;
    
    UIView *_nothingFoundView;
    
    UICollectionView *_collectionView;
    CGFloat _collectionViewWidth;
    TGModernMediaListLayout *_collectionLayout;
    UIView *_collectionContainer;
    NSMutableDictionary *_reusableItemContentViewsByIdentifier;
    bool _loadItemsSynchronously;
    
    TGRecentSearchResultsTableView *_recentSearchResultsTableView;
    
    id<TGModernMediaListItem> _hiddenItem;
    
    void (^_recycleItemContentView)(TGModernMediaListItemContentView *);
    NSMutableArray *_storedItemContentViews;
    
    __weak TGWebSearchResultsGalleryModel *_galleryModel;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, copy) bool (^isEditing)();
@property (nonatomic, copy) void (^toggleEditing)();
@property (nonatomic, copy) void (^itemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy) bool (^isItemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy) bool (^isItemHidden)(id<TGWebSearchListItem>);

@end

@implementation TGWebSearchController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.navigationBarShouldBeHidden = true;
        
        _reusableItemContentViewsByIdentifier = [[NSMutableDictionary alloc] init];
        _storedItemContentViews = [[NSMutableArray alloc] init];
        
        __weak TGWebSearchController *weakSelf = self;
        _recycleItemContentView = ^(TGModernMediaListItemContentView *itemContentView)
        {
            __strong TGWebSearchController *strongSelf = weakSelf;
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
        
        self.isEditing = ^bool()
        {
            __strong TGWebSearchController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                return strongSelf->_searchBar.selectedScopeButtonIndex == 2 && strongSelf->_editingRecents;
            }
            
            return false;
        };
        self.toggleEditing = ^
        {
            __strong TGWebSearchController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_searchBar.selectedScopeButtonIndex == 2)
                {
                    strongSelf->_editingRecents = !strongSelf->_editingRecents;
                    [strongSelf updateItemsEditing];
                }
            }
        };
        self.itemSelected = ^(id<TGWebSearchListItem> item)
        {
            __strong TGWebSearchController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if ([[strongSelf scopeSelectedItems] containsObject:item])
                {
                    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[strongSelf scopeSelectedItems]];
                    [array removeObject:item];
                    [strongSelf setScopeSelectedItems:array animated:true];
                }
                else
                {
                    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[strongSelf scopeSelectedItems]];
                    [array addObject:item];
                    [strongSelf setScopeSelectedItems:array animated:true];
                }
                
                [strongSelf updateItemsSelected];
            }
        };
        self.isItemSelected = ^bool (id<TGWebSearchListItem> item)
        {
            __strong TGWebSearchController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                return [[strongSelf scopeSelectedItems] containsObject:item];
            }
            return false;
        };
        self.isItemHidden = ^bool (id<TGWebSearchListItem> item)
        {
            __strong TGWebSearchController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                return [item isEqual:strongSelf->_hiddenItem];
            }
            return false;
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

- (NSArray *)scopeSelectedItems
{
    if (_searchBar.selectedScopeButtonIndex == 0)
        return _selectedImageItems;
    else if (_searchBar.selectedScopeButtonIndex == 1)
        return _selectedGifItems;
    else
        return _selectedRecentItems;
}

- (void)setScopeSelectedItems:(NSArray *)selectedItems animated:(bool)animated
{
    if (_searchBar.selectedScopeButtonIndex == 0)
        _selectedImageItems = selectedItems;
    else if (_searchBar.selectedScopeButtonIndex == 1)
        _selectedGifItems = selectedItems;
    else
        _selectedRecentItems = selectedItems;
    
    [self updateSelectionInterface:animated];
}

- (NSArray *)scopeSearchResults
{
    if (_searchBar.selectedScopeButtonIndex == 0)
        return _imageSearchResults;
    else if (_searchBar.selectedScopeButtonIndex == 1)
        return _gifSearchResults;
    else
        return _recentSearchResults;
}

- (NSArray *)scopeRawSearchResults
{
    if (_searchBar.selectedScopeButtonIndex == 0)
        return _rawImageSearchResults;
    else if (_searchBar.selectedScopeButtonIndex == 1)
        return _rawGifSearchResults;
    else
        return @[];
}

- (bool)scopeMoreResultsAvailable
{
    if (_searchBar.selectedScopeButtonIndex == 0)
        return _imageMoreResultsAvailable;
    else if (_searchBar.selectedScopeButtonIndex == 1)
        return _gifMoreResultsAvailable;
    else
        return false;
}

- (NSString *)scopeSearchPath
{
    if (_searchBar.selectedScopeButtonIndex == 0)
        return _imageSearchPath;
    else if (_searchBar.selectedScopeButtonIndex == 1)
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
        nothingFoundLabel.frame = CGRectMake(floorf((_nothingFoundView.frame.size.width - size.width) / 2), nothingFoundIcon.frame.size.height / 2.0f + 4.0f, size.width, size.height);
        
        nothingFoundIcon.frame = CGRectMake(floorf((_nothingFoundView.frame.size.width - nothingFoundIcon.frame.size.width) / 2), -nothingFoundIcon.frame.size.height / 2.0f - 4.0f, nothingFoundIcon.frame.size.width, nothingFoundIcon.frame.size.height);
    }
    
    return _nothingFoundView;
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
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delaysContentTouches = false;
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[TGModernMediaListItemView class] forCellWithReuseIdentifier:@"TGModernMediaListItemView"];
    [_collectionContainer addSubview:_collectionView];
    
    /*UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGesture.minimumPressDuration = 0.5;
    [_collectionView addGestureRecognizer:longPressGesture];
    for (UIGestureRecognizer* recognizer in [_collectionView gestureRecognizers])
    {
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]])
            [recognizer requireGestureRecognizerToFail:longPressGesture];
    }*/
    
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
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frameSize.width, 0.0f) style:TGSearchBarStyleLight];
    _searchBar.customScopeButtonTitles = @[TGLocalized(@"WebSearch.Images"), TGLocalized(@"WebSearch.GIFs"), TGLocalized(@"WebSearch.RecentSectionTitle")];
    _searchBar.showsScopeBar = true;
    [_searchBar setAlwaysExtended:true];
    [_searchBar setShowsCancelButton:true animated:false];
    _searchBar.delegate = self;
    [_searchBar sizeToFit];
    _searchBar.delayActivity = false;
    _searchBar.selectedScopeButtonIndex = MAX(0, MIN(2, [[[NSUserDefaults standardUserDefaults] objectForKey:@"webSearchSelectedScope"] intValue]));
    [self searchBar:(UISearchBar *)_searchBar selectedScopeButtonIndexDidChange:_searchBar.selectedScopeButtonIndex];
    [self.view addSubview:_searchBar];
    
    _toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 44.0f, self.view.frame.size.width, 44.0f)];
    _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _toolbarView.backgroundColor = UIColorRGBA(0xf7f7f7, 1.0f);
    UIView *stripeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _toolbarView.frame.size.width, TGIsRetina() ? 0.5f : 1.0f)];
    stripeView.backgroundColor = UIColorRGB(0xb2b2b2);
    stripeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_toolbarView addSubview:stripeView];
    [self.view addSubview:_toolbarView];
    
    _toolbarLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GiphyToolbarLogo.png"]];
    _toolbarLogoView.frame = CGRectMake(CGFloor((_toolbarView.frame.size.width - _toolbarLogoView.frame.size.width) / 2.0f), 9.0f, _toolbarLogoView.frame.size.width, _toolbarLogoView.frame.size.height);
    _toolbarLogoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _toolbarLogoView.hidden = true;
    [_toolbarView addSubview:_toolbarLogoView];
    
    _doneButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    _doneButton.exclusiveTouch = true;
    [_doneButton setTitle:TGLocalized(@"MediaPicker.Send") forState:UIControlStateNormal];
    [_doneButton setTitleColor:TGAccentColor()];
    _doneButton.titleLabel.font = TGMediumSystemFontOfSize(17);
    _doneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 27, 0, 10);
    [_doneButton sizeToFit];
    float doneButtonWidth = MAX(40, _doneButton.frame.size.width);
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
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(22.0f, 22.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 22.0f, 22.0f));
            countBadgeBackground = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:11.0f topCapHeight:11.0f];
            UIGraphicsEndImageContext();
        }
    });
    _countBadge = [[UIImageView alloc] initWithImage:countBadgeBackground];
    _countBadge.alpha = 0.0f;
    _countLabel = [[UILabel alloc] init];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.font = TGLightSystemFontOfSize(14);
    [_countBadge addSubview:_countLabel];
    [_doneButton addSubview:_countBadge];
    
    self.explicitTableInset = UIEdgeInsetsMake(_searchBar.frame.size.height, 0.0f, 44.0f, 0.0f);
    self.explicitScrollIndicatorInset = self.explicitTableInset;
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[recognizer locationInView:_collectionView]];
        if (indexPath != nil)
        {
            if ([_collectionView cellForItemAtIndexPath:indexPath] != nil && _searchBar.selectedScopeButtonIndex == 2)
            {
                //_toggleEditing();
            }
        }
    }
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
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
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
        if ([item isKindOfClass:[TGGiphySearchResultItem class]])
        {
            TGGiphySearchResultItem *concreteItem = item;
            [items addObject:[[TGWebSearchGifItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:item itemSelected:_itemSelected isItemSelected:_isItemSelected isItemHidden:_isItemHidden]];
        }
        else if ([item isKindOfClass:[TGBingSearchResultItem class]])
        {
            TGBingSearchResultItem *concreteItem = item;
            [items addObject:[[TGWebSearchImageItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:item isEditing:_isEditing toggleEditing:_toggleEditing itemSelected:_itemSelected isItemSelected:_isItemSelected isItemHidden:_isItemHidden]];
        }
        else if ([item isKindOfClass:[TGWebSearchInternalImageResult class]])
        {
            TGWebSearchInternalImageResult *concreteItem = item;
            [items addObject:[[TGWebSearchInternalImageItem alloc] initWithSearchResult:concreteItem isEditing:_isEditing toggleEditing:_toggleEditing itemSelected:_itemSelected isItemSelected:_isItemSelected isItemHidden:_isItemHidden]];
        }
        else if ([item isKindOfClass:[TGWebSearchInternalGifResult class]])
        {
            TGWebSearchInternalGifResult *concreteResult = item;
            [items addObject:[[TGWebSearchInternalGifItem alloc] initWithSearchResult:concreteResult isEditing:_isEditing toggleEditing:_toggleEditing itemSelected:_itemSelected isItemSelected:_isItemSelected isItemHidden:_isItemHidden]];
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
    
    CGSize frameSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
    CGRect collectionViewFrame = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    _collectionViewWidth = collectionViewFrame.size.width;
    _collectionView.frame = collectionViewFrame;
    
    _recentSearchResultsTableView.frame = collectionViewFrame;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_searchBar.selectedScopeButtonIndex != 2)
        [_searchBar becomeFirstResponder];
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    CGRect navigationBarFrame = _searchBar.frame;
    navigationBarFrame.origin.y = self.controllerCleanInset.top;
    _searchBar.frame = navigationBarFrame;
    
    [super controllerInsetUpdated:previousInset];
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
    
    CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _collectionViewWidth = tableFrame.size.width;
    _collectionView.frame = tableFrame;
    
    _recentSearchResultsTableView.frame = _collectionView.frame;
    
    _collectionView.transform = tableTransform;
    
    [_collectionLayout invalidateLayout];
    [_collectionView layoutSubviews];
    
    [UIView animateWithDuration:duration animations:^
    {
        _searchBar.frame = CGRectMake(_searchBar.frame.origin.x, _searchBar.frame.origin.y, [self referenceViewSizeForOrientation:toInterfaceOrientation].width, 0.0f);
        [_searchBar sizeToFit];
    }];
    
    self.explicitTableInset = UIEdgeInsetsMake(_searchBar.frame.size.height, 0.0f, 44.0f, 0.0f);
    self.explicitScrollIndicatorInset = self.explicitTableInset;
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)updateSelectionInterface:(bool)animated
{
    NSUInteger selectedCount = (_selectedImageItems.count + _selectedGifItems.count + _selectedRecentItems.count);
    _doneButton.enabled = selectedCount != 0;
    
    TGWebSearchResultsGalleryModel *galleryModel = _galleryModel;
    if (galleryModel != nil)
        [galleryModel.interfaceView updateSelectionInterface:selectedCount animated:true];
    
    bool incremented = true;
    
    float badgeAlpha = 0.0f;
    if (selectedCount != 0)
    {
        badgeAlpha = 1.0f;
        
        if (_countLabel.text.length != 0)
            incremented = [_countLabel.text intValue] < (int)selectedCount;
        
        _countLabel.text = [[NSString alloc] initWithFormat:@"%d", (int)selectedCount];
        [_countLabel sizeToFit];
    }
    
    float badgeWidth = MAX(22, _countLabel.frame.size.width + 14);
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
    if (_searchBar.selectedScopeButtonIndex == 0)
        searching = _searchingImage;
    else if (_searchBar.selectedScopeButtonIndex == 1)
        searching = _searchingGif;
    if ([self scopeSearchPath].length != 0 && !searching && [self scopeSearchResults].count == 0 && _searchBar.selectedScopeButtonIndex != 2)
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
    return (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON) ? _wideLineSpacing : _normalLineSpacing;
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
        
        if (_hiddenItem == nil)
            itemContentView.isHidden = false;
        else
            itemContentView.isHidden = [_hiddenItem isEqual:itemContentView.item];
        
        return itemView;
    }
}

- (NSArray *)galleryItems
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (id<TGWebSearchListItem> item in [self scopeSearchResults])
    {
        id<TGWebSearchResultsGalleryItem> galleryItem = [self galleryItemForWebSearchResult:[item webSearchResult]];
        if (galleryItem != nil)
            [array addObject:galleryItem];
    }
    return array;
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
    
    return nil;
}

- (TGModernGalleryController *)createGalleryControllerForItem:(id<TGWebSearchListItem>)item
{
    TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
    NSArray *galleryItems = [self galleryItems];
    id<TGModernGalleryItem> focusItem = nil;
    for (id<TGWebSearchResultsGalleryItem> galleryItem in galleryItems)
    {
        if ([[galleryItem webSearchResult] isEqual:[item webSearchResult]])
        {
            focusItem = galleryItem;
            break;
        }
    }
    __weak TGWebSearchController *weakSelf = self;
    
    TGWebSearchResultsGalleryModel *model = [[TGWebSearchResultsGalleryModel alloc] initWithItems:galleryItems focusItem:focusItem];
    [model.interfaceView updateSelectionInterface:_selectedImageItems.count + _selectedGifItems.count animated:false];
    model.interfaceView.itemSelected = ^(id<TGWebSearchResultsGalleryItem> item)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            id<TGWebSearchListItem> listItem = [strongSelf listItemForSearchResult:[item webSearchResult]];
            
            if (listItem != nil)
                strongSelf.itemSelected(listItem);
        }
    };
    model.interfaceView.isItemSelected = ^bool (id<TGWebSearchResultsGalleryItem> item)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            id<TGWebSearchListItem> listItem = [strongSelf listItemForSearchResult:[item webSearchResult]];
            
            if (listItem != nil)
                return strongSelf.isItemSelected(listItem);
        }
        
        return false;
    };
    model.interfaceView.donePressed = ^(id<TGWebSearchResultsGalleryItem> item)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            id<TGWebSearchListItem> listItem = [strongSelf listItemForSearchResult:[item webSearchResult]];
            
            NSMutableArray *selectedItems = [[NSMutableArray alloc] init];
            [selectedItems addObjectsFromArray:_selectedImageItems];
            [selectedItems addObjectsFromArray:_selectedGifItems];
            [selectedItems addObjectsFromArray:_selectedRecentItems];
            
            if (listItem != nil && ![selectedItems containsObject:listItem])
                [selectedItems addObject:listItem];
            [strongSelf completeWithItems:selectedItems];
        }
    };
    _galleryModel = model;
    modernGallery.model = model;
    
    modernGallery.itemFocused = ^(id<TGWebSearchResultsGalleryItem> item)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            id<TGWebSearchListItem> listItem = [strongSelf listItemForSearchResult:[item webSearchResult]];
            strongSelf->_hiddenItem = listItem;
            [strongSelf updateHiddenItem];
        }
    };
    
    modernGallery.beginTransitionIn = ^UIView *(id<TGWebSearchResultsGalleryItem> item, __unused TGModernGalleryItemView *itemView)
    {
        __strong TGWebSearchController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            return [strongSelf referenceViewForSearchResult:[item webSearchResult]];
        }
        
        return nil;
    };
    
    modernGallery.beginTransitionOut = ^UIView *(id<TGWebSearchResultsGalleryItem> item)
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
            [strongSelf updateHiddenItem];
        }
    };
    
    return modernGallery;
}

- (void)updateHiddenItem
{
    for (TGModernMediaListItemView *itemView in [_collectionView visibleCells])
    {
        if ([itemView.itemContentView isKindOfClass:[TGWebSearchImageItemView class]])
        {
            [(TGWebSearchImageItemView *)itemView.itemContentView updateItemHidden];
        }
        else if ([itemView.itemContentView isKindOfClass:[TGWebSearchGifItemView class]])
        {
            [(TGWebSearchGifItemView *)itemView.itemContentView updateItemHidden];
        }
        else if ([itemView.itemContentView isKindOfClass:[TGWebSearchInternalImageItemView class]])
        {
            [(TGWebSearchInternalImageItemView *)itemView.itemContentView updateItemHidden];
        }
        else if ([itemView.itemContentView isKindOfClass:[TGWebSearchInternalGifItemView class]])
        {
            [(TGWebSearchInternalGifItemView *)itemView.itemContentView updateItemHidden];
        }
    }
}

- (void)updateItemsSelected
{
    for (TGModernMediaListItemView *itemView in [_collectionView visibleCells])
    {
        if ([itemView.itemContentView isKindOfClass:[TGWebSearchImageItemView class]])
        {
            [(TGWebSearchImageItemView *)itemView.itemContentView updateItemSelected];
        }
        else if ([itemView.itemContentView isKindOfClass:[TGWebSearchGifItemView class]])
        {
            [(TGWebSearchGifItemView *)itemView.itemContentView updateItemSelected];
        }
        else if ([itemView.itemContentView isKindOfClass:[TGWebSearchInternalImageItemView class]])
        {
            [(TGWebSearchInternalImageItemView *)itemView.itemContentView updateItemSelected];
        }
        else if ([itemView.itemContentView isKindOfClass:[TGWebSearchInternalGifItemView class]])
        {
            [(TGWebSearchInternalGifItemView *)itemView.itemContentView updateItemSelected];
        }
    }
}

- (void)updateItemsEditing
{
    for (TGModernMediaListItemView *itemView in [_collectionView visibleCells])
    {
        if ([itemView.itemContentView isKindOfClass:[TGWebSearchImageItemView class]])
        {
            [(TGWebSearchImageItemView *)itemView.itemContentView updateIsEditing];
        }
        else if ([itemView.itemContentView isKindOfClass:[TGWebSearchGifItemView class]])
        {
        }
        else if ([itemView.itemContentView isKindOfClass:[TGWebSearchInternalImageItemView class]])
        {
        }
        else if ([itemView.itemContentView isKindOfClass:[TGWebSearchInternalGifItemView class]])
        {
        }
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<TGWebSearchListItem> item = [self scopeSearchResults][indexPath.row];
    
    TGModernGalleryController *controller = [self createGalleryControllerForItem:item];
    if (controller != nil)
    {
        TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:controller];
        controllerWindow.hidden = false;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self scopeSearchPath].length != 0 && !_searchBar.showActivity && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.size.height && _searchString.length != 0 && [self scopeMoreResultsAvailable])
    {
        _searchBar.showActivity = true;
        
        [ActionStageInstance() requestActor:[self scopeSearchPath] options:@{@"query": _searchString, @"currentItems": [self scopeRawSearchResults]} flags:0 watcher:self];
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
        _searchBar.showActivity = false;
        
        _rawImageSearchResults = nil;
        _imageSearchResults = nil;
        _selectedImageItems = nil;
        
        _rawGifSearchResults = nil;
        _gifSearchResults = nil;
        _selectedGifItems = nil;
        
        [self updateSelectionInterface:false];
        
        _recentSearchResultsTableView.hidden = _searchBar.selectedScopeButtonIndex == 2;
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
        _selectedImageItems = nil;

        _rawGifSearchResults = nil;
        _gifSearchResults = nil;
        _selectedGifItems = nil;
        
        [self updateSelectionInterface:false];
        
        _searchString = query;
        _imageMoreResultsAvailable = false;
        _gifMoreResultsAvailable = false;
        
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

- (void)searchBar:(TGSearchBar *)__unused searchBar willChangeHeight:(float)__unused newHeight
{
    searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, searchBar.frame.size.width, newHeight);
}

- (void)searchBarCancelButtonClicked:(TGSearchBar *)__unused searchBar
{
    [_searchBar endEditing:true];
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)__unused searchBar
{
    if (_searchBar.text.length != 0)
        [self _addRecentSearchItem:_searchBar.text];
    [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top)];
    [self _updateSearchQuery:_searchBar.text];
    
    if (_searchBar.selectedScopeButtonIndex == 2)
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
    
    [[NSUserDefaults standardUserDefaults] setObject:@((int)selectedScope) forKey:@"webSearchSelectedScope"];
    _toolbarLogoView.hidden = _searchBar.selectedScopeButtonIndex != 1;
    _recentSearchResultsTableView.hidden = selectedScope == 2 || _searchString.length != 0;
    [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top)];
    _loadItemsSynchronously = true;
    [_collectionView reloadData];
    [_collectionView layoutSubviews];
    _loadItemsSynchronously = false;
    
    bool searching = false;
    if (_searchBar.selectedScopeButtonIndex == 0)
        searching = _searchingImage;
    else if (_searchBar.selectedScopeButtonIndex == 1)
        searching = _selectedGifItems;
    if ([self scopeSearchPath].length != 0 && !searching && [self scopeSearchResults].count == 0 && _searchBar.selectedScopeButtonIndex != 2)
        [self nothingFoundView].hidden = false;
    else
        _nothingFoundView.hidden = true;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)__unused scrollView
{
    [_searchBar resignFirstResponder];
}

- (void)doneButtonPressed
{
    NSMutableArray *selectedItems = [[NSMutableArray alloc] init];
    [selectedItems addObjectsFromArray:_selectedImageItems];
    [selectedItems addObjectsFromArray:_selectedGifItems];
    [selectedItems addObjectsFromArray:_selectedRecentItems];
    [self completeWithItems:selectedItems];
}

- (void)completeWithItems:(NSArray *)items
{
    NSMutableArray *searchItems = [[NSMutableArray alloc] init];
    for (id<TGWebSearchListItem> item in items)
    {
        [searchItems addObject:[item webSearchResult]];
    }
    
    [TGWebSearchController addRecentSelectedItems:searchItems];
    
    if (_completion)
        _completion(searchItems);
    
    TGWebSearchResultsGalleryModel *galleryModel = _galleryModel;
    if (galleryModel != nil)
    {
        if (galleryModel.dismiss)
            galleryModel.dismiss(true, false);
    }
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
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
                        [searchResults addObject:[[TGWebSearchGifItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:item itemSelected:_itemSelected isItemSelected:_isItemSelected isItemHidden:_isItemHidden]];
                    }
                    else if ([item isKindOfClass:[TGBingSearchResultItem class]])
                    {
                        TGBingSearchResultItem *concreteItem = item;
                        [searchResults addObject:[[TGWebSearchImageItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:item isEditing:_isEditing toggleEditing:_toggleEditing itemSelected:_itemSelected isItemSelected:_isItemSelected isItemHidden:_isItemHidden]];
                    }
                }
                
                _imageSearchResults = searchResults;
                _rawImageSearchResults = result[@"items"];
                _imageMoreResultsAvailable = [result[@"moreResultsAvailable"] boolValue];
                
                if (_searchBar.selectedScopeButtonIndex == 0)
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
                        [searchResults addObject:[[TGWebSearchGifItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:item itemSelected:_itemSelected isItemSelected:_isItemSelected isItemHidden:_isItemHidden]];
                    }
                    else if ([item isKindOfClass:[TGBingSearchResultItem class]])
                    {
                        TGBingSearchResultItem *concreteItem = item;
                        [searchResults addObject:[[TGWebSearchImageItem alloc] initWithPreviewUrl:concreteItem.previewUrl searchResultItem:item isEditing:_isEditing toggleEditing:_toggleEditing itemSelected:_itemSelected isItemSelected:_isItemSelected isItemHidden:_isItemHidden]];
                    }
                }
                
                _gifSearchResults = searchResults;
                _rawGifSearchResults = result[@"items"];
                _gifMoreResultsAvailable = [result[@"moreResultsAvailable"] boolValue];
                
                if (_searchBar.selectedScopeButtonIndex == 1)
                    [self reloadData];
            }
        }
    });
}

@end
