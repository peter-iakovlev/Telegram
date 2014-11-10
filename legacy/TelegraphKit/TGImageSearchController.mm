#import "TGImageSearchController.h"

#import "ActionStage.h"

#import "TGSearchBar.h"
#import "TGToolbar.h"
#import "TGModernBackToolbarButton.h"

#import "TGImageUtils.h"
#import "TGHacks.h"
#import "UIImage+ImageEffects.h"

#import "TGStringUtils.h"

#import "TGLinearProgressView.h"

#import "TGImagePickerGalleryCell.h"

#import "TGImagePickerCheckButton.h"
#import "TGImagePickerCellCheckButton.h"

#import "TGImageSearchQueryCell.h"

#import "TGImagePagingScrollView.h"
#import "TGImageViewPage.h"
#import "TGImagePanGestureRecognizer.h"

#import "TGClockProgressView.h"

#import "TGSearchLoupeProgressView.h"

#import "TGImagePickerCell.h"

#import "TGActivityIndicatorView.h"

#import "TGImageCropController.h"

#import "TGFont.h"

#import "TGModernButton.h"

#import <QuartzCore/QuartzCore.h>

#import <AssetsLibrary/AssetsLibrary.h>

#import <set>

@interface TGImageSearchMediaItem : NSObject <TGMediaItem>

@property (nonatomic) TGMediaItemType type;

@property (nonatomic, strong) TGImageInfo *imageInfo;
@property (nonatomic) id searchId;

@end

@implementation TGImageSearchMediaItem

- (id)initWithImageInfo:(TGImageInfo *)imageInfo searchId:(id)searchId
{
    self = [super init];
    if (self != nil)
    {
        _imageInfo = imageInfo;
        _searchId = searchId;
        
        _type = TGMediaItemTypePhoto;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGImageSearchMediaItem *imageSearchMediaItem = [[TGImageSearchMediaItem alloc] initWithImageInfo:_imageInfo searchId:_searchId];
    return imageSearchMediaItem;
}

- (TGVideoMediaAttachment *)videoAttachment
{
    return nil;
}

- (id)itemId
{
    return _searchId;
}

- (int)date
{
    return 0;
}

- (int)authorUid
{
    return 0;
}

- (TGUser *)author
{
    return nil;
}

- (bool)hasLocalId
{
    return false;
}

- (UIImage *)immediateThumbnail
{
    return nil;
}

@end

@interface TGImageSearchController () <UISearchBarDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, TGImagePagingScrollViewDelegate, UIGestureRecognizerDelegate, TGSearchBarDelegate>
{
    std::set<int> _selectedSearchIds;
}

@property (nonatomic) bool avatarSelectionMode;

@property (nonatomic, strong) UIView *navigationBarContainer;

@property (nonatomic, strong) UITableView *listTableView;

@property (nonatomic, strong) NSString *executingSearchString;
@property (nonatomic, strong) NSString *currentSearchString;

@property (nonatomic, strong) TGSearchBar *searchBar;

@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) TGModernButton *doneButton;
@property (nonatomic, strong) TGModernButton *cancelButton;

@property (nonatomic, strong) UIView *darkPanelView;
@property (nonatomic, strong) TGModernButton *darkDoneButton;
@property (nonatomic, strong) TGModernButton *darkCancelButton;

@property (nonatomic, strong) UIView *progressContainer;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) TGClockProgressView *clockProgressView;

@property (nonatomic) int hideSearchId;

@property (nonatomic) bool showingSearchHistoryTableView;
@property (nonatomic, strong) UITableView *searchHistoryTableView;

@property (nonatomic) bool showingSearchResultsTableView;
@property (nonatomic, strong) UITableView *searchResultsTableView;

@property (nonatomic) int imagesInRow;
@property (nonatomic) CGFloat imageSize;
@property (nonatomic) CGFloat inset;
@property (nonatomic) CGFloat lineHeight;

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic) bool canLoadMore;

@property (nonatomic, strong) UIView *pagingScrollViewContainer;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) TGImagePagingScrollView *pagingScrollView;
@property (nonatomic) bool pagingScrollViewPanning;

@property (nonatomic, strong) ASHandle *pageHandle;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSArray *assetGroups;

@property (nonatomic, strong) UIView *imageSearchContainer;
@property (nonatomic, strong) TGSearchLoupeProgressView *imageSearchIndicator;

@property (nonatomic, strong) UIImageView *nothingFoundIcon;
@property (nonatomic, strong) UILabel *nothingFoundLabel;

@property (nonatomic, strong) UIImageView *countBadge;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *darkCountBadge;
@property (nonatomic, strong) UILabel *darkCountLabel;

@property (nonatomic, strong) TGImagePickerCheckButton *checkButton;
@property (nonatomic, strong) TGImagePickerCellCheckButton *cellCheckButton;

@property (nonatomic, strong) NSMutableArray *imagesToDownload;

@property (nonatomic, strong) UIView *imageDownloadProgressContainer;
@property (nonatomic, strong) UILabel *imageDownloadProgressLabel;
@property (nonatomic, strong) TGClockProgressView *imageDownloadClockProgressView;

@property (nonatomic, strong) UIView *dimmingOverlayView;
@property (nonatomic, strong) UIImageView *dimmingOverlayViewBackground;
@property (nonatomic, strong) UIView *dimmingOverlayViewContentView;

@property (nonatomic, strong) TGRemoteImageView *dimmingCurrentImage;
@property (nonatomic, strong) UIButton *dimmingCancelButton;
@property (nonatomic, strong) TGLinearProgressView *dimmingProgressView;
@property (nonatomic, strong) UILabel *dimmingProgressLabel;
@property (nonatomic, strong) UILabel *dimmingInformationLabel;
@property (nonatomic, strong) UIButton *dimmingRetryButton;
@property (nonatomic, strong) UIButton *dimmingSkipButton;

@property (nonatomic, strong) NSMutableArray *recentSearchQueries;

@end

@implementation TGImageSearchController

- (id)init
{
    return [self initWithAvatarSelection:false];
}

- (id)initWithAvatarSelection:(bool)avatarSelection
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.navigationBarShouldBeHidden = true;
        self.ignoreKeyboardWhenAdjustingScrollViewInsets = true;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _avatarSelectionMode = avatarSelection;
        
        self.titleText = TGLocalized(@"SearchImages.Title");
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:_assetsLibrary];
    
    [self doUnloadView];
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    ALAssetsLibrary *assetsLibrary = _assetsLibrary;
    dispatchOnAssetsProcessingQueue(^
    {
        sharedAssetsLibraryRelease();
        [assetsLibrary description];
    });
    _assetsLibrary = nil;
}

- (void)setHideSearchControls:(bool)hideSearchControls
{
    _hideSearchControls = hideSearchControls;
    
    self.navigationBarShouldBeHidden = !hideSearchControls;
}

- (int)assetsInRowForWidth:(CGFloat)width widescreenWidth:(CGFloat)widescreenWidth
{
    return (int)(width / [self imageSizeForWidth:width widescreenWidth:widescreenWidth]);
}

- (CGFloat)imageSizeForWidth:(CGFloat)width widescreenWidth:(CGFloat)widescreenWidth
{
    if (TGIsPad())
    {
        return 102.0f;
    }
    
    if ([UIScreen mainScreen].scale >= 2.0f - FLT_EPSILON)
    {
        if (widescreenWidth >= 736.0f - FLT_EPSILON)
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 103.0f;
            else
                return 103.0f;
        }
        else if (widescreenWidth >= 667.0f - FLT_EPSILON)
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 93.0f;
            else
                return 93.0f;
        }
        else if (widescreenWidth >= 568 - FLT_EPSILON)
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 111.0f;
            else
                return 105.0f;
        }
        else if (widescreenWidth >= 540 - FLT_EPSILON)
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 84.0f;
            else
                return 84.0f;
        }
        else
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 105.0f;
            else
                return 105.0f;
        }
    }
    else
    {
        if (width >= widescreenWidth - FLT_EPSILON)
            return 105.0f;
        else
            return 105.0f;
    }
}

- (CGFloat)lineSpacingForWidth:(CGFloat)width widescreenWidth:(CGFloat)widescreenWidth
{
    if (TGIsPad())
        return 3.0f;
    
    if ([UIScreen mainScreen].scale >= 2.0f - FLT_EPSILON)
    {
        if (widescreenWidth >= 736.0f - FLT_EPSILON)
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 2.0f;
            else
                return 1.0f;
        }
        else if (widescreenWidth >= 667.0f - FLT_EPSILON)
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 2.0f;
            else
                return 1.0f;
        }
        else
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 3.0f;
            else
                return 2.0f;
        }
    }
    else
    {
        if (width >= widescreenWidth - FLT_EPSILON)
            return 2.0f;
        else
            return 2.0f;
    }
}

- (CGFloat)lineHeightForWidth:(CGFloat)width widescreenWidth:(CGFloat)widescreenWidth
{
    return [self lineSpacingForWidth:width widescreenWidth:widescreenWidth] + [self imageSizeForWidth:width widescreenWidth:widescreenWidth];
}

- (CGFloat)insetForWidth:(CGFloat)width widescreenWidth:(CGFloat)widescreenWidth
{
    if ([UIScreen mainScreen].scale >= 2.0f - FLT_EPSILON)
    {
        if (widescreenWidth >= 736.0f - FLT_EPSILON)
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 2.0f;
            else
                return 0.0f;
        }
        else if (widescreenWidth >= 667.0f - FLT_EPSILON)
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 2.0f;
            else
                return 0.0f;
        }
        else
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 1.0f;
            else
                return 0.0f;
        }
    }
    else
    {
        if (width >= widescreenWidth - FLT_EPSILON)
            return 1.0f;
        else
            return 0.0f;
    }
}

- (void)loadView
{
    [super loadView];
    
    CGSize screenSize = [self referenceViewSizeForOrientation:[self currentInterfaceOrientation]];
    
    dispatchOnAssetsProcessingQueue(^
    {
        sharedAssetsLibraryRetain();
        _assetsLibrary = [TGImagePickerController sharedAssetsLibrary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryDidChange:) name:ALAssetsLibraryChangedNotification object:_assetsLibrary];
    });
    
    CGFloat widescreenWidth = MAX(screenSize.width, screenSize.height);
    
    _imagesInRow = [self assetsInRowForWidth:screenSize.width widescreenWidth:widescreenWidth];
    _imageSize = [self imageSizeForWidth:screenSize.width widescreenWidth:widescreenWidth];
    _lineHeight = [self lineHeightForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
    _inset = [self insetForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
    
    _hideSearchId = -1;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (!_hideSearchControls)
        [self setExplicitTableInset:UIEdgeInsetsMake(42, 0, 44, 0) scrollIndicatorInset:UIEdgeInsetsMake(44, 0, 44, 0)];
    
    _listTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _listTableView.backgroundColor = [UIColor whiteColor];
    _listTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTableView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 44, 0);
    [self.view addSubview:_listTableView];
    
    _searchHistoryTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _searchHistoryTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _searchHistoryTableView.backgroundColor = [UIColor whiteColor];
    _searchHistoryTableView.delegate = self;
    _searchHistoryTableView.dataSource = self;
    _searchHistoryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _searchHistoryTableView.alpha = 0.0f;
    [self.view addSubview:_searchHistoryTableView];
    
    _searchResultsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _searchResultsTableView.backgroundColor = [UIColor whiteColor];
    _searchResultsTableView.delegate = self;
    _searchResultsTableView.dataSource = self;
    _searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _searchResultsTableView.alpha = 0.0f;
    
    self.scrollViewsForAutomaticInsetsAdjustment = [[NSArray alloc] initWithObjects:_searchHistoryTableView, _searchResultsTableView, nil];
    
    [self.view addSubview:_searchResultsTableView];
    
    _imageSearchIndicator = [[TGSearchLoupeProgressView alloc] init];
    _imageSearchContainer = [[UIView alloc] initWithFrame:CGRectOffset(_imageSearchIndicator.bounds, floorf((self.view.frame.size.width - _imageSearchIndicator.frame.size.width) / 2), floorf((self.view.frame.size.height - _imageSearchIndicator.frame.size.height) / 2))];
    [_imageSearchContainer addSubview:_imageSearchIndicator];
    
    _imageSearchContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    _imageSearchContainer.hidden = true;
    
    [self.view addSubview:_imageSearchContainer];
    
    _nothingFoundLabel = [[UILabel alloc] init];
    _nothingFoundLabel.backgroundColor = [UIColor clearColor];
    _nothingFoundLabel.textColor = UIColorRGB(0x808080);
    _nothingFoundLabel.font = TGLightSystemFontOfSize(16);
    _nothingFoundLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _nothingFoundLabel.numberOfLines = 0;
    _nothingFoundLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_nothingFoundLabel];
    
    _nothingFoundIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NothingFoundIcon.png"]];
    [self.view addSubview:_nothingFoundIcon];

    [self setNothingFoundLabelText:nil];
    
    _navigationBarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
    _navigationBarContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0, 0, _navigationBarContainer.frame.size.width, 42) style:TGSearchBarStyleLight];
    _searchBar.alwaysExtended = true;
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    _searchBar.placeholder = TGLocalized(@"SearchImages.SearchImages");
    
    [_navigationBarContainer addSubview:_searchBar];
    
    if (!_hideSearchControls)
        [self.view addSubview:_navigationBarContainer];
    
    _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backgroundView.hidden = true;
    _backgroundView.alpha = 1.0f;
    _backgroundView.userInteractionEnabled = false;
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _cellCheckButton = [[TGImagePickerCellCheckButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [_cellCheckButton setChecked:false animated:false];
    _cellCheckButton.alpha = 0.0f;
    _cellCheckButton.hidden = true;
    //_cellCheckButton.layer.zPosition = 10001;
    [self.view addSubview:_cellCheckButton];
    
    _dimmingOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    _dimmingOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _dimmingOverlayView.hidden = true;
    _dimmingOverlayView.alpha = 0.0f;
    
    _dimmingOverlayViewBackground = [[UIImageView alloc] initWithFrame:_dimmingOverlayView.bounds];
    _dimmingOverlayViewBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_dimmingOverlayView addSubview:_dimmingOverlayViewBackground];
    
    UIView *dimView = [[UIView alloc] initWithFrame:_dimmingOverlayView.bounds];
    dimView.backgroundColor = UIColorRGBA(0x000000, iosMajorVersion() >= 7 ? 0.7f : 0.94f);
    dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_dimmingOverlayView addSubview:dimView];
    
    //_dimmingOverlayView.layer.zPosition = 10001;
    [self.view addSubview:_dimmingOverlayView];
    
    if (TGBackdropEnabled())
    {
        UIToolbar *toolbarView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
        toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        toolbarView.barTintColor = [UIColor whiteColor];
        _panelView = toolbarView;
    }
    else
    {
        _panelView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
        _panelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _panelView.backgroundColor = UIColorRGBA(0xf7f7f7, 1.0f);
        
        UIView *stripeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _panelView.frame.size.width, TGIsRetina() ? 0.5f : 1.0f)];
        stripeView.backgroundColor = UIColorRGB(0xb2b2b2);
        stripeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_panelView addSubview:stripeView];
    }
    
    if (!_hideSearchControls)
        [self.view addSubview:_panelView];
    
    [self.view addSubview:_backgroundView];
    
    _cancelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    _cancelButton.exclusiveTouch = true;
    [_cancelButton setTitle:TGLocalized(@"Common.Cancel") forState:UIControlStateNormal];
    [_cancelButton setTitleColor:TGAccentColor()];
    _cancelButton.titleLabel.font = TGSystemFontOfSize(17);
    _cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [_cancelButton sizeToFit];
    _cancelButton.frame = CGRectMake(0, 0, MAX(60, _cancelButton.frame.size.width), 44);
    _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_panelView addSubview:_cancelButton];
    
    _doneButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    _doneButton.exclusiveTouch = true;
    [_doneButton setTitle:TGLocalized(@"MediaPicker.Send") forState:UIControlStateNormal];
    [_doneButton setTitleColor:TGAccentColor()];
    _doneButton.titleLabel.font = TGMediumSystemFontOfSize(17);
    _doneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 27, 0, 10);
    [_doneButton sizeToFit];
    float doneButtonWidth = MAX(40, _doneButton.frame.size.width);
    _doneButton.frame = CGRectMake(_panelView.frame.size.width - doneButtonWidth, 0, doneButtonWidth, 44);
    _doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    _darkPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    UIImageView *darkBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ImagePickerPreviewPanel.png"]];
    darkBackground.frame = _darkPanelView.bounds;
    darkBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_darkPanelView addSubview:darkBackground];
    _darkPanelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _darkPanelView.backgroundColor = UIColorRGBA(0x000000, 0.7f);
    _darkPanelView.alpha = 0.0f;
    
    [self.view addSubview:_darkPanelView];
    
    _darkCancelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    _darkCancelButton.exclusiveTouch = true;
    [_darkCancelButton setTitle:TGLocalized(@"Common.Back") forState:UIControlStateNormal];
    [_darkCancelButton setTitleColor:[UIColor whiteColor]];
    _darkCancelButton.titleLabel.font = TGSystemFontOfSize(17);
    _darkCancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [_darkCancelButton sizeToFit];
    _darkCancelButton.frame = CGRectMake(0, 0, MAX(60, _darkDoneButton.frame.size.width), 44);
    _darkCancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_darkCancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_darkPanelView addSubview:_darkCancelButton];
    
    _darkDoneButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    _darkDoneButton.exclusiveTouch = true;
    [_darkDoneButton setTitle:TGLocalized(@"MediaPicker.Send") forState:UIControlStateNormal];
    [_darkDoneButton setTitleColor:[UIColor whiteColor]];
    _darkDoneButton.titleLabel.font = TGMediumSystemFontOfSize(17);
    _darkDoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 27, 0, 10);
    [_darkDoneButton sizeToFit];
    float darkDoneButtonWidth = MAX(40, _darkDoneButton.frame.size.width);
    _darkDoneButton.frame = CGRectMake(_darkPanelView.frame.size.width - darkDoneButtonWidth, 0, darkDoneButtonWidth, 44);
    _darkDoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_darkDoneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _darkDoneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_darkPanelView addSubview:_darkDoneButton];
    
    if (!_avatarSelectionMode)
    {
        [_panelView addSubview:_doneButton];
        [_darkPanelView addSubview:_darkDoneButton];
    }

    static UIImage *countBadgeBackground = nil;
    static UIImage *darkCountBadgeBackground = nil;
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
        
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(22.0f, 22.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0x14c944).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 22.0f, 22.0f));
            darkCountBadgeBackground = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:11.0f topCapHeight:11.0f];
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
    
    _darkCountBadge = [[UIImageView alloc] initWithImage:darkCountBadgeBackground];
    _darkCountBadge.alpha = 0.0f;
    _darkCountLabel = [[UILabel alloc] init];
    _darkCountLabel.backgroundColor = [UIColor clearColor];
    _darkCountLabel.textColor = [UIColor whiteColor];
    _darkCountLabel.font = TGLightSystemFontOfSize(14);
    [_darkCountBadge addSubview:_darkCountLabel];
    [_darkDoneButton addSubview:_darkCountBadge];
    
    _checkButton = [[TGImagePickerCheckButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 56, 7, 49, 49)];
    _checkButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_checkButton setChecked:false animated:false];
    [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _checkButton.alpha = 0.0f;
    [self.view addSubview:_checkButton];
    
    float retinaPixel = TGIsRetina() ? 0.5f : 0.0f;
    
    _progressContainer = [[UIView alloc] initWithFrame:_panelView.bounds];
    _progressContainer.userInteractionEnabled = false;
    _progressContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _progressContainer.alpha = 0.0f;
    [_panelView addSubview:_progressContainer];
    
    _progressLabel = [[UILabel alloc] init];
    _progressLabel.clipsToBounds = false;
    _progressLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.font = TGSystemFontOfSize(13);
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.backgroundColor = [UIColor clearColor];
    [_progressContainer addSubview:_progressLabel];
    
    _clockProgressView = [[TGClockProgressView alloc] initWithWhite];
    _clockProgressView.frame = CGRectMake(-19, 1 + retinaPixel, 15, 15);
    [_progressLabel addSubview:_clockProgressView];
    
    {
        _imageDownloadProgressContainer = [[UIView alloc] initWithFrame:_panelView.bounds];
        _imageDownloadProgressContainer.userInteractionEnabled = false;
        _imageDownloadProgressContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageDownloadProgressContainer.alpha = 0.0f;
        [_panelView addSubview:_imageDownloadProgressContainer];
        
        _imageDownloadProgressLabel = [[UILabel alloc] init];
        _imageDownloadProgressLabel.clipsToBounds = false;
        _imageDownloadProgressLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _imageDownloadProgressLabel.textAlignment = NSTextAlignmentCenter;
        _imageDownloadProgressLabel.font = TGSystemFontOfSize(14);
        _imageDownloadProgressLabel.textColor = [UIColor whiteColor];
        _imageDownloadProgressLabel.backgroundColor = [UIColor clearColor];
        [_imageDownloadProgressContainer addSubview:_imageDownloadProgressLabel];
        
        _imageDownloadClockProgressView = [[TGClockProgressView alloc] initWithWhite];
        _imageDownloadClockProgressView.frame = CGRectOffset(_imageDownloadClockProgressView.frame, -18, 2);
        [_imageDownloadProgressLabel addSubview:_imageDownloadClockProgressView];
    }
    
    [self reloadAssets];
    
    [self updateSelectionInterface:false];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)doUnloadView
{
    _searchBar.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_autoActivateSearch)
    {
        _autoActivateSearch = false;
        
        [_searchBar becomeFirstResponder];
    }
    
    if ([_listTableView indexPathForSelectedRow] != nil)
        [_listTableView deselectRowAtIndexPath:[_listTableView indexPathForSelectedRow] animated:true];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:animated];
    
    CGAffineTransform tableTransform = _searchResultsTableView.transform;
    _searchResultsTableView.transform = CGAffineTransformIdentity;
    
    CGSize screenSize = [self referenceViewSizeForOrientation:[self currentInterfaceOrientation]];
    
    CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _searchResultsTableView.frame = tableFrame;
    
    CGFloat widescreenWidth = MAX(screenSize.width, screenSize.height);
    
    int imagesInRow = [self assetsInRowForWidth:screenSize.width widescreenWidth:widescreenWidth];
    CGFloat imageSize = [self imageSizeForWidth:screenSize.width widescreenWidth:widescreenWidth];
    CGFloat lineHeight = [self lineHeightForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
    CGFloat inset = [self insetForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
    
    if (imagesInRow != _imagesInRow)
    {
        _imagesInRow = imagesInRow;
        _imageSize = imageSize;
        _lineHeight = lineHeight;
        _inset = inset;
        
        [_searchResultsTableView reloadData];
    }
    
    _searchResultsTableView.transform = tableTransform;
    
    [self updateNothingFoundLabel:self.interfaceOrientation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:animated];
    
    if (![self inFormSheet] && ![self inPopover])
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            [TGHacks setApplicationStatusBarAlpha:1.0f];
            [self setStatusBarBackgroundAlpha:1.0f];
        }];
    }
    
    [super viewWillDisappear:animated];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    CGRect navigationBarFrame = _navigationBarContainer.frame;
    navigationBarFrame.origin.y = self.controllerCleanInset.top;
    _navigationBarContainer.frame = navigationBarFrame;
}

- (void)setNothingFoundLabelText:(NSString *)text
{
    if (text.length == 0)
        _nothingFoundLabel.text = nil;
    else
    {
        _nothingFoundLabel.text = TGLocalized(@"SearchImages.NoImagesFound");
    }
    
    [self updateNothingFoundLabel:self.interfaceOrientation];
}

- (void)updateNothingFoundLabel:(UIInterfaceOrientation)orientation
{
    if (_nothingFoundLabel.text.length == 0)
    {
        _nothingFoundLabel.hidden = true;
        _nothingFoundIcon.hidden = true;
    }
    else
    {
        _nothingFoundLabel.hidden = false;
        _nothingFoundIcon.hidden = false;
        
        CGSize screenSize = [self referenceViewSizeForOrientation:orientation];
        
        CGSize size = [_nothingFoundLabel sizeThatFits:CGSizeMake(screenSize.width - 20, 1000)];
        _nothingFoundLabel.frame = CGRectMake(floorf((screenSize.width - size.width) / 2), floorf((screenSize.height - size.height) / 2), size.width, size.height);
        
        _nothingFoundIcon.frame = CGRectMake(floorf((screenSize.width - _nothingFoundIcon.frame.size.width) / 2), _nothingFoundLabel.frame.origin.y - 18 - _nothingFoundIcon.frame.size.height, _nothingFoundIcon.frame.size.width, _nothingFoundIcon.frame.size.height);
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (_searchResultsTableView.alpha > FLT_EPSILON)
    {
        _panelView.hidden = true;
        bool nothingFoundLabelWasHidden = _nothingFoundLabel.hidden;
        _nothingFoundLabel.hidden = true;
        
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 0.0f);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *tableImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *temporaryImageView = [[UIImageView alloc] initWithImage:tableImage];
        temporaryImageView.frame = self.view.bounds;
        [self.view insertSubview:temporaryImageView aboveSubview:_searchResultsTableView];
        
        [UIView animateWithDuration:duration animations:^
        {
            temporaryImageView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [temporaryImageView removeFromSuperview];
        }];
        
        _panelView.hidden = false;
        _nothingFoundLabel.hidden = nothingFoundLabelWasHidden;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        CGSize screenSize = [self referenceViewSizeForOrientation:toInterfaceOrientation];
        
        CGAffineTransform tableTransform = _searchResultsTableView.transform;
        _searchResultsTableView.transform = CGAffineTransformIdentity;
        
        CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
        _searchResultsTableView.frame = tableFrame;
        
        CGFloat widescreenWidth = MAX(screenSize.width, screenSize.height);
        
        _imagesInRow = [self assetsInRowForWidth:screenSize.width widescreenWidth:widescreenWidth];
        _imageSize = [self imageSizeForWidth:screenSize.width widescreenWidth:widescreenWidth];
        _lineHeight = [self lineHeightForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
        _inset = [self insetForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
        
        [_searchResultsTableView reloadData];
        
        _searchResultsTableView.transform = tableTransform;
    });
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    _dimmingRetryButton.frame = CGRectMake(floorf((_dimmingOverlayView.frame.size.width - 230) / 2), [self referenceViewSizeForOrientation:toInterfaceOrientation].height - _panelView.frame.size.height - (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 50 : 150), 230, _dimmingRetryButton.frame.size.height);
    
    _dimmingSkipButton.frame = CGRectMake(floorf((_dimmingOverlayView.frame.size.width - 230) / 2), _dimmingRetryButton.frame.origin.y + _dimmingRetryButton.frame.size.height + (TGIsRetina() ? 0.5f : 1.0f), 230, _dimmingSkipButton.frame.size.height);
    
    [self updateNothingFoundLabel:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    /*if (iosMajorVersion() >= 7 && _dimmingOverlayView.alpha > FLT_EPSILON)
    {
        _dimmingOverlayView.hidden = true;
        UIImage *image = [TGImageSearchController blurImageWithView:self.view];
        _dimmingOverlayViewBackground.image = image;
        _dimmingOverlayView.hidden = false;
    }*/
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark -

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (!_showingSearchHistoryTableView)
    {
        [self loadRecentQueries];
        [_searchHistoryTableView reloadData];
        
        _showingSearchHistoryTableView = true;
        
        [searchBar setShowsCancelButton:true animated:true];
        
        [UIView animateWithDuration:0.3 animations:^
        {
            _searchHistoryTableView.alpha = 1.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                _listTableView.hidden = true;
            }
        }];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (![searchBar.text isEqualToString:_executingSearchString])
    {
        [self beginSearch:searchBar.text];
    }
}

- (void)beginSearch:(NSString *)query
{
    [self addRecentQuery:query];
    
    [self showSearchResults:true];
    [self clearSearchResults];
    
    [self setNothingFoundLabelText:nil];
    
    _imageSearchContainer.hidden = false;
    [_imageSearchIndicator startAnimating];
    
    [_searchBar resignFirstResponder];
    
    _executingSearchString = query;
    
    _canLoadMore = false;
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/content/googleImages/(%d,first)", [_executingSearchString hash]] options:[[NSDictionary alloc] initWithObjectsAndKeys:_executingSearchString, @"query", nil] flags:0 watcher:self];
}

- (void)searchBar:(UISearchBar *)__unused searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)
    {
        [self clearSearchResults];
        
        [self showSearchResults:false];
        
        [self setNothingFoundLabelText:nil];
    }
}

- (void)showSearchResults:(bool)show
{
    _showingSearchHistoryTableView = !show;
    _searchHistoryTableView.alpha = show ? 0.0f : 1.0f;
    
    _showingSearchResultsTableView = show;
    _searchResultsTableView.alpha = show ? 1.0f : 0.0f;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if (_showingSearchResultsTableView || _showingSearchHistoryTableView)
    {
        _imageSearchContainer.hidden = true;
        [_imageSearchIndicator stopAnimating];
        
        searchBar.text = @"";
        [searchBar resignFirstResponder];
        
        _showingSearchResultsTableView = false;
        _showingSearchHistoryTableView = false;
        
        [searchBar setShowsCancelButton:false animated:true];
        
        _listTableView.hidden = false;
        
        [UIView animateWithDuration:0.25 animations:^
        {
            _searchResultsTableView.alpha = 0.0f;
            _searchHistoryTableView.alpha = 0.0f;
            
            _nothingFoundLabel.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                [self clearSearchResults];
                
                _nothingFoundLabel.alpha = 1.0f;
                [self setNothingFoundLabelText:nil];
            }
        }];
    }
}

- (void)cancelImageDownload
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSMutableArray *cancelPaths = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in _imagesToDownload)
        {
            [cancelPaths addObject:dict[@"path"]];
        }
        
        _imagesToDownload = nil;
        
        if (cancelPaths.count != 0)
        {
            for (NSString *path in cancelPaths)
            {
                [ActionStageInstance() removeWatcher:self fromPath:path];
            }
        }
    }];
    
    [self setImageDownloadProgressContainerVisible:false animated:true];
    [self updateDimmingViewImageStateAnimated:true currentUrl:nil pausedState:0];
}

- (void)clearSearchResults
{
    _currentSearchString = nil;
    _searchResults = nil;
    _canLoadMore = false;
    
    if (_executingSearchString != nil)
    {
        [ActionStageInstance() removeWatcher:self fromPath:[[NSString alloc] initWithFormat:@"/tg/content/googleImages/(%d,first)", [_executingSearchString hash]]];
        [ActionStageInstance() removeWatcher:self fromPath:[[NSString alloc] initWithFormat:@"/tg/content/googleImages/(%d,more)", [_executingSearchString hash]]];
        _executingSearchString = nil;
    }
    
    _imageSearchContainer.hidden = true;
    [_imageSearchIndicator stopAnimating];
    
    [_searchResultsTableView reloadData];
    
    _selectedSearchIds.clear();
    [self updateSelectionInterface:true];
    
    [self setNothingFoundLabelText:nil];
    [self updateNothingFoundLabel:self.interfaceOrientation];
}

- (void)loadRecentQueries
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:@"recentImageSearchQueries"];
    if (data.length != 0)
    {
        NSInputStream *is = [[NSInputStream alloc] initWithData:data];
        [is open];
        
        int version = 0;
        [is read:(uint8_t *)&version maxLength:4];
        
        if (version == 0)
        {
            int count = 0;
            [is read:(uint8_t *)&count maxLength:4];
            
            for (int i = 0; i < count; i++)
            {
                int length = 0;
                [is read:(uint8_t *)&length maxLength:4];
                
                uint8_t buf[length];
                [is read:buf maxLength:length];
                
                NSString *query = [[NSString alloc] initWithBytes:buf length:length encoding:NSUTF8StringEncoding];
                if (query != nil)
                    [list addObject:query];
            }
        }
        
        [is close];
    }
    
    _recentSearchQueries = list;
}

- (void)addRecentQuery:(NSString *)query
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    int version = 0;
    [data appendBytes:&version length:4];
    
    if (_recentSearchQueries == nil)
        _recentSearchQueries = [[NSMutableArray alloc] init];
    
    NSUInteger index = [_recentSearchQueries indexOfObject:query];
    if (index != NSNotFound)
        [_recentSearchQueries removeObjectAtIndex:index];
    
    [_recentSearchQueries insertObject:query atIndex:0];
    
    const int maxQueries = 100;
    
    if (_recentSearchQueries.count > maxQueries)
        [_recentSearchQueries removeObjectsInRange:NSMakeRange(maxQueries, _recentSearchQueries.count - maxQueries)];
    
    [_searchHistoryTableView reloadData];
    
    int count = _recentSearchQueries.count;
    [data appendBytes:&count length:4];
    
    for (NSString *string in _recentSearchQueries)
    {
        NSData *bytes = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        int length = bytes.length;
        [data appendBytes:&length length:4];
        
        [data appendData:bytes];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:@"recentImageSearchQueries"];
    [userDefaults synchronize];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _listTableView)
    {
        return _assetGroups.count;
    }
    else if (tableView == _searchResultsTableView)
    {
        if (section == 0)
            return _searchResults.count / _imagesInRow + (_searchResults.count % _imagesInRow != 0 ? 1 : 0) + 1;
    }
    else if (tableView == _searchHistoryTableView)
    {
        return _recentSearchQueries.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (tableView == _listTableView)
    {
        return 85;
    }
    else if (tableView == _searchResultsTableView)
    {
        int rowStartIndex = indexPath.row * _imagesInRow;
        if (rowStartIndex < _searchResults.count)
            return _lineHeight;
        return 26;
    }
    else if (tableView == _searchHistoryTableView)
    {
        return 46;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _listTableView)
    {
        if (indexPath.row < _assetGroups.count)
        {
            static NSString *galleryCellIdentifier = @"GC";
            TGImagePickerGalleryCell *galleryCell = (TGImagePickerGalleryCell *)[tableView dequeueReusableCellWithIdentifier:galleryCellIdentifier];
            if (galleryCell == nil)
            {
                galleryCell = [[TGImagePickerGalleryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:galleryCellIdentifier];
            }

            NSDictionary *galleryDesc = [_assetGroups objectAtIndex:indexPath.row];
            [galleryCell setIcon:galleryDesc[@"icon"] icon2:galleryDesc[@"icon2"] icon3:galleryDesc[@"icon3"]];
            [galleryCell setTitleAccentColor:false];
            [galleryCell setTitle:[galleryDesc objectForKey:@"name"] countString:[galleryDesc objectForKey:@"countString"]];
            
            return galleryCell;
        }
    }
    else if (tableView == _searchResultsTableView)
    {
        int rowStartIndex = indexPath.row * _imagesInRow;
        if (rowStartIndex < _searchResults.count)
        {
            static NSString *imageCellIdentifier = @"IC";
            TGImagePickerCell *imageCell = (TGImagePickerCell *)[tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
            if (imageCell == nil)
            {
                imageCell = [[TGImagePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageCellIdentifier selectionControls:!_avatarSelectionMode imageSize:_imageSize];
                imageCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [imageCell resetImages:_imagesInRow imageSize:_imageSize inset:_inset];
            
            int assetListCount = _searchResults.count;
            for (int i = rowStartIndex; i < rowStartIndex + _imagesInRow && i < assetListCount; i++)
            {
                TGImageInfo *imageInfo = [_searchResults objectAtIndex:i];
                
                bool isSelected = _selectedSearchIds.find(i) != _selectedSearchIds.end();
                
                [imageCell addImage:imageInfo searchId:i isSelected:isSelected];
            }
            
            if (_hideSearchId >= 0)
                [imageCell hideImage:[[NSNumber alloc] initWithInt:_hideSearchId] hide:true];
            
            return imageCell;
        }
        else
        {
            static NSString *indicatorCellIdentifier = @"INDC";
            UITableViewCell *indicatorCell = [tableView dequeueReusableCellWithIdentifier:indicatorCellIdentifier];
            if (indicatorCell == nil)
            {
                indicatorCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indicatorCellIdentifier];
                indicatorCell.selectionStyle = UITableViewCellSelectionStyleNone;
                indicatorCell.backgroundView = [[UIView alloc] init];
                indicatorCell.backgroundView.backgroundColor = [UIColor clearColor];
                indicatorCell.backgroundColor = [UIColor clearColor];
                indicatorCell.opaque = false;
                
                TGActivityIndicatorView *activityIndicator = [[TGActivityIndicatorView alloc] initWithStyle:TGActivityIndicatorViewStyleSmall];
                activityIndicator.tag = 100;
                activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                activityIndicator.frame = CGRectOffset(activityIndicator.frame, floorf((indicatorCell.frame.size.width - activityIndicator.frame.size.width) / 2), 4);
                [indicatorCell addSubview:activityIndicator];
            }
            
            TGActivityIndicatorView *activityIndicator = (TGActivityIndicatorView *)[indicatorCell viewWithTag:100];
            if (_executingSearchString != nil && _canLoadMore)
            {
                activityIndicator.hidden = false;
                [activityIndicator startAnimating];
            }
            else
            {
                activityIndicator.hidden = true;
                [activityIndicator stopAnimating];
            }
            
            return indicatorCell;
        }
    }
    else if (tableView == _searchHistoryTableView)
    {
        NSString *queryText = indexPath.row < _recentSearchQueries.count ? [_recentSearchQueries objectAtIndex:indexPath.row] : nil;
        
        if (queryText != nil)
        {
            static NSString *queryCellIdentifier = @"QC";
            TGImageSearchQueryCell *queryCell = (TGImageSearchQueryCell *)[tableView dequeueReusableCellWithIdentifier:queryCellIdentifier];
            if (queryCell == nil)
            {
                queryCell = [[TGImageSearchQueryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:queryCellIdentifier];
            }
            
            [queryCell setQueryText:queryText];
            
            return queryCell;
        }
    }
    
    UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
    if (emptyCell == nil)
    {
        emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"];
        emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return emptyCell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _searchResultsTableView)
    {
        [_searchBar resignFirstResponder];
    }
    else if (scrollView == _searchHistoryTableView)
    {
        [_searchBar resignFirstResponder];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)__unused cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _searchResultsTableView)
    {
        if (_canLoadMore && _executingSearchString == nil && indexPath.row >= [tableView numberOfRowsInSection:0] - 3)
        {
            _executingSearchString = _currentSearchString;
            
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/content/googleImages/(%d,more)", [_executingSearchString hash]] options:[[NSDictionary alloc] initWithObjectsAndKeys:_executingSearchString, @"query", [[NSNumber alloc] initWithInt:_searchResults.count], @"offset", nil] flags:0 watcher:self];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _listTableView)
    {
        if (indexPath.row < _assetGroups.count)
        {
            NSDictionary *galleryDesc = [_assetGroups objectAtIndex:indexPath.row];
            
            TGImagePickerController *imagePickerController = [[TGImagePickerController alloc] initWithGroupUrl:[galleryDesc objectForKey:@"url"] groupTitle:[galleryDesc objectForKey:@"name"] avatarSelection:_avatarSelectionMode];
            imagePickerController.delegate = _delegate;
            [self.navigationController pushViewController:imagePickerController animated:true];
        }
    }
    else if (tableView == _searchHistoryTableView)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:false];
        
        [_searchBar setText:[_recentSearchQueries objectAtIndex:indexPath.row]];
        [self beginSearch:_searchBar.text];
    }
}

#pragma mark -

- (void)cancelButtonPressed
{
    if (_imagesToDownload != nil)
    {
        [self cancelImageDownload];
    }
    else
    {
        if (_pagingScrollView != nil)
            [self dismissPagingScrollView:0.0f];
        else
        {
            id<TGImagePickerControllerDelegate> delegate = _delegate;
            if (delegate != nil && [delegate respondsToSelector:@selector(imagePickerController:didFinishPickingWithAssets:)])
                [delegate imagePickerController:(id)self didFinishPickingWithAssets:[[NSArray alloc] initWithObjects:nil]];
        }
    }
}

- (void)doneButtonPressed
{
    NSMutableArray *itemList = [[NSMutableArray alloc] init];
    
    for (auto it = _selectedSearchIds.begin(); it != _selectedSearchIds.end(); it++)
    {
        if (*it < _searchResults.count)
        {
            TGImageInfo *imageInfo = _searchResults[*it];
            
            [itemList addObject:@{@"imageInfo": imageInfo, @"searchId": @(*it)}];
        }
    }
    
    if (_pagingScrollView != nil)
    {
        TGImageViewPage *page = [_pagingScrollView pageForIndex:[_pagingScrollView currentPageIndex]];
        int searchId = [((TGImageSearchMediaItem *)page.imageItem).itemId intValue];
        if (_selectedSearchIds.find(searchId) == _selectedSearchIds.end())
        {
            TGImageInfo *imageInfo = ((TGImageSearchMediaItem *)page.imageItem).imageInfo;
            if (imageInfo != nil)
            {
                [itemList addObject:@{@"imageInfo": imageInfo, @"searchId": @(searchId)}];
            }
            
            _selectedSearchIds.insert(searchId);
        }
    }
    
    NSMutableArray *imagesToDownload = [[NSMutableArray alloc] init];
    
    int firstNotReady = -1;
    NSString *firstNotReadyThumbnailUrl = nil;
    
    int index = -1;
    
    int totalFileSize = 0;
    
    for (NSDictionary *downloadItemDict in itemList)
    {
        TGImageInfo *imageInfo = downloadItemDict[@"imageInfo"];
        NSNumber *nSearchId = downloadItemDict[@"searchId"];
        
        int fileSize = 0;
        
        NSString *url = [imageInfo closestImageUrlWithSize:CGSizeMake(10000, 10000) resultingSize:NULL resultingFileSize:&fileSize];
        NSString *thumnailUrl = [imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        if (url != nil)
        {
            index++;
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            dict[@"url"] = url;
            dict[@"thumbnail"] = thumnailUrl != nil ? thumnailUrl : url;
            dict[@"path"] = [[NSString alloc] initWithFormat:@"/img/(download:%@)", url];
            dict[@"downloading"] = @(false);
            dict[@"searchId"] = nSearchId;
            dict[@"fileSize"] = @(fileSize);
            
            bool ready = [[TGRemoteImageView sharedCache] diskCacheContainsSync:url];
            
#if TARGET_IPHONE_SIMULATOR
            ready = false;
#endif
            if (!ready && firstNotReady < 0)
            {
                firstNotReady = index;
                firstNotReadyThumbnailUrl = dict[@"thumbnail"];
            }
            
            if (!ready)
            {
                totalFileSize += fileSize;
            }
            
            dict[@"ready"] = @(ready);
            
            [imagesToDownload addObject:dict];
        }
    }
    
    _imagesToDownload = imagesToDownload;
    
    if (firstNotReady >= 0)
    {
        if (_pagingScrollView != nil)
            [self dismissPagingScrollView:0.0f];
        
        [self updateDownloadProgressText:firstNotReady totalCount:imagesToDownload.count totalFileSize:totalFileSize];
        
        [self setImageDownloadProgressContainerVisible:true animated:true];
        [self updateDimmingViewImageStateAnimated:true currentUrl:firstNotReadyThumbnailUrl pausedState:0];
        [_dimmingProgressView setProgress:0.0 animationDuration:0.0];
    }
    
    [self checkAndDownloadImages:true];
}

- (void)updateDownloadProgressText:(int)currentImage totalCount:(int)totalCount totalFileSize:(int)totalFileSize
{
    NSString *baseText = nil;
    
    if (totalFileSize < 1024 * 1024)
        baseText = [[NSString alloc] initWithFormat:TGLocalized(@"SearchImages.Downloading#Kb"), totalFileSize / 1024];
    else
        baseText = [[NSString alloc] initWithFormat:TGLocalized(@"SearchImages.Downloading#Mb"), totalFileSize / 1024 / 1024];
    
    _imageDownloadProgressLabel.text = baseText;
    
    [_imageDownloadProgressLabel sizeToFit];
    
    _imageDownloadProgressLabel.frame = CGRectMake(floorf((_progressContainer.frame.size.width - _imageDownloadProgressLabel.frame.size.width) / 2) + 10, 15, _imageDownloadProgressLabel.frame.size.width, _imageDownloadProgressLabel.frame.size.height);
    
    _dimmingProgressLabel.text = [[NSString alloc] initWithFormat:TGLocalized(@"SearchImages.ImageNofM"), [TGStringUtils stringWithLocalizedNumber:currentImage + 1], [TGStringUtils stringWithLocalizedNumber:totalCount]];
}

- (void)checkAndDownloadImages
{
    [self checkAndDownloadImages:false];
}

- (void)checkAndDownloadImages:(bool)__unused blocking
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        int readyCount = 0;
        bool anyDownloading = false;
        
        int totalFileSize = 0;
        
        for (NSDictionary *dict in _imagesToDownload)
        {
            bool ready = [dict[@"ready"] boolValue];
            if (ready)
                readyCount++;
            else if ([dict[@"downloading"] boolValue])
                anyDownloading = true;
            
            if (!ready)
                totalFileSize += [dict[@"fileSize"] intValue];
        }
        
        if (readyCount == _imagesToDownload.count)
        {
            NSMutableArray *urlList = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dict in _imagesToDownload)
            {
                [urlList addObject:dict[@"url"]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if (readyCount == 0)
                {
                    [self setImageDownloadProgressContainerVisible:false animated:true];
                    [self updateDimmingViewImageStateAnimated:true currentUrl:nil pausedState:0];
                }
                else
                {
                    id<TGImagePickerControllerDelegate> delegate = _delegate;
                    if (delegate != nil && [delegate respondsToSelector:@selector(imagePickerController:didFinishPickingWithAssets:)])
                        [delegate imagePickerController:(id)self didFinishPickingWithAssets:urlList];
                }
            });
        }
        else if (!anyDownloading)
        {
            int firstNotReady = -1;
            NSString *firstNotReadyThumbnailUrl = nil;
            
            int index = -1;
            for (NSMutableDictionary *dict in _imagesToDownload)
            {
                index++;
                
                if (![dict[@"ready"] boolValue])
                {
                    NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                        [NSNumber numberWithInt:0], @"cancelTimeout",
                        [TGRemoteImageView sharedCache], @"cache",
                        [NSNumber numberWithBool:false], @"useCache",
                        [NSNumber numberWithBool:false], @"allowThumbnailCache", nil];
                    
                    dict[@"downloading"] = @(true);
      
                    [ActionStageInstance() requestActor:dict[@"path"] options:options flags:0 watcher:self];
                    
                    firstNotReady = index;
                    firstNotReadyThumbnailUrl = dict[@"thumbnail"];
                    
                    break;
                }
            }
            
            int totalCount = _imagesToDownload.count;
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if (firstNotReady >= 0)
                {
                    [_dimmingProgressView setProgress:0.0 animationDuration:0.0];
                    
                    [self updateDownloadProgressText:firstNotReady totalCount:totalCount totalFileSize:totalFileSize];
                    
                    [self updateDimmingViewImageStateAnimated:true currentUrl:firstNotReadyThumbnailUrl pausedState:0];
                }
            });
        }
    }];
}

- (void)skipCurrentlyDownloadingImage
{
    if ([[NSThread currentThread] isMainThread])
        _dimmingOverlayViewContentView.userInteractionEnabled = false;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        int selectedSearchId = 0;
        
        int count = _imagesToDownload.count;
        for (int i = 0; i < count; i++)
        {
            NSDictionary *dict = _imagesToDownload[i];
            
            if ([dict[@"downloading"] boolValue])
            {
                [ActionStageInstance() removeWatcher:self fromPath:dict[@"path"]];
                selectedSearchId = [dict[@"searchId"] intValue];
                
                [_imagesToDownload removeObjectAtIndex:i];
                
                break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (selectedSearchId != 0)
            {
            }
            
            _dimmingOverlayViewContentView.userInteractionEnabled = true;
        });
        
        [self checkAndDownloadImages];
    }];
}

- (void)stopCurrentlyDownloadingImage
{
    if ([[NSThread currentThread] isMainThread])
        _dimmingOverlayViewContentView.userInteractionEnabled = false;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSString *thumbnailUrl = nil;
        
        int count = _imagesToDownload.count;
        for (int i = 0; i < count; i++)
        {
            NSDictionary *dict = _imagesToDownload[i];
            
            if ([dict[@"downloading"] boolValue])
            {
                [ActionStageInstance() removeWatcher:self fromPath:dict[@"path"]];
                thumbnailUrl = dict[@"thumbnail"];
                
                break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            _dimmingOverlayViewContentView.userInteractionEnabled = true;
            
            [self updateDimmingViewImageStateAnimated:true currentUrl:thumbnailUrl pausedState:2];
        });
        
        [self checkAndDownloadImages];
    }];

}

- (void)retryCurrentlyDownloadingImage
{
    if ([[NSThread currentThread] isMainThread])
        _dimmingOverlayViewContentView.userInteractionEnabled = false;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        for (NSMutableDictionary *dict in _imagesToDownload)
        {
            if ([dict[@"downloading"] boolValue])
            {
                dict[@"downloading"] = @(false);
                
                break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            _dimmingOverlayViewContentView.userInteractionEnabled = true;
        });
        
        [self checkAndDownloadImages];
    }];
}

#pragma mark -

- (void)assetsLibraryDidChange:(NSNotification *)__unused notification
{
    [self reloadAssets];
}

- (void)reloadAssets
{
    dispatchOnAssetsProcessingQueue(^
    {
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, __unused BOOL *stop)
        {
            if (group != nil)
            {
                NSURL *currentUrl = [group valueForProperty:ALAssetsGroupPropertyURL];
                NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                CGImageRef posterImage = group.posterImage;
                
                UIImage *icon = posterImage == NULL ? nil : [[UIImage alloc] initWithCGImage:posterImage];
                
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                
                NSMutableDictionary *groupDesc = [[NSMutableDictionary alloc] init];
                if (name != nil)
                {
                    int groupType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                    if (groupType == ALAssetsGroupSavedPhotos)
                    {
                        [groupDesc setObject:TGLocalized(@"MediaPicker.CameraRoll") forKey:@"name"];
                        [groupDesc setObject:[[NSNumber alloc] initWithInt:-1] forKey:@"order"];
                    }
                    else
                        [groupDesc setObject:name forKey:@"name"];
                }
                
                if (icon != nil)
                {
                    __block UIImage *icon2 = nil;
                    __block UIImage *icon3 = nil;
                    
                    __block int enumCount = 0;
                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, __unused NSUInteger index, BOOL *stop)
                    {
                        if (result != nil)
                        {
                            CGImageRef thumbnail = [result thumbnail];
                            
                            if (thumbnail != NULL)
                            {
                                if (enumCount == 0)
                                {
                                    icon2 = [[UIImage alloc] initWithCGImage:thumbnail];
                                    enumCount++;
                                }
                                else if (enumCount == 1)
                                {
                                    icon3 = [[UIImage alloc] initWithCGImage:thumbnail];
                                    enumCount++;
                                    
                                    if (stop != NULL)
                                        *stop = true;
                                }
                                else if (stop != NULL)
                                    *stop = true;
                            }
                        }
                    }];
                    
                    [groupDesc setObject:icon forKey:@"icon"];
                    if (icon2 != nil)
                        groupDesc[@"icon2"] = icon2;
                    if (icon3 != nil)
                        groupDesc[@"icon3"] = icon3;
                }
                
                if (currentUrl != nil)
                    [groupDesc setObject:currentUrl forKey:@"url"];
                int count = group.numberOfAssets;
                [groupDesc setObject:[[NSString alloc] initWithFormat:@"%d", count] forKey:@"countString"];
                
                [assetGroups addObject:groupDesc];
            }
            else
            {
                for (int i = 0; i < assetGroups.count; i++)
                {
                    if ([[[assetGroups objectAtIndex:i] objectForKey:@"order"] intValue] < 0)
                    {
                        id object = [assetGroups objectAtIndex:i];
                        [assetGroups removeObjectAtIndex:i];
                        [assetGroups insertObject:object atIndex:0];
                        break;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    _assetGroups = assetGroups;
                    
                    [_listTableView reloadData];
                });
            }
        } failureBlock:^(__unused NSError *error)
        {
            TGLog(@"assets access error");
        }];
    });
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:@"/img/"])
    {
        for (NSMutableDictionary *dict in _imagesToDownload)
        {
            if ([dict[@"path"] isEqualToString:path])
            {
                if ([messageType isEqualToString:@"progress"])
                {
                    if ([dict[@"downloading"] boolValue])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [_dimmingProgressView setProgress:[message floatValue] animationDuration:0.3];
                        });
                    }
                }
                
                break;
            }
        }
    }
}

- (void)actorReportedProgress:(NSString *)path progress:(float)progress
{
    [self actorMessageReceived:path messageType:@"progress" message:[[NSNumber alloc] initWithFloat:progress]];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/content/googleImages/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (![path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/content/googleImages/(%d,", [_executingSearchString hash]]])
                return;
            
            _currentSearchString = _executingSearchString;
            _executingSearchString = nil;
            
            if (status == ASStatusSuccess)
            {
                NSArray *images = [result objectForKey:@"images"];
                if ([[result objectForKey:@"offset"] intValue] == 0)
                    _searchResults = images;
                else
                {
                    NSMutableArray *newResults = [[NSMutableArray alloc] init];
                    if (_searchResults != nil)
                        [newResults addObjectsFromArray:_searchResults];
                    if (images != nil)
                        [newResults addObjectsFromArray:images];
                    _searchResults = newResults;
                }
                _canLoadMore = [[result objectForKey:@"canLoadMore"] boolValue];
                [_searchResultsTableView reloadData];
            }
            else
            {
                _canLoadMore = false;
                [_searchResultsTableView reloadData];
            }
            
            _imageSearchContainer.hidden = true;
            [_imageSearchIndicator stopAnimating];
            
            if (![path hasSuffix:@"more)"])
            {
                _selectedSearchIds.clear();
                [self updateSelectionInterface:true];
                
                if (_searchResults.count == 0)
                {
                    [self setNothingFoundLabelText:_currentSearchString];
                }
                else
                {
                    [self setNothingFoundLabelText:nil];
                }
            }
            
            _imageSearchContainer.hidden = true;
            [_imageSearchIndicator stopAnimating];
        });
    }
    else if ([path hasPrefix:@"/img/"])
    {
#if TARGET_IPHONE_SIMULATOR
        status = -1;
#endif
        
        for (NSMutableDictionary *dict in _imagesToDownload)
        {
            if ([dict[@"path"] isEqualToString:path])
            {
                if (status == ASStatusSuccess)
                {
                    dict[@"downloading"] = @(false);
                    dict[@"ready"] = @(true);
                    
                    [self checkAndDownloadImages];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        [self updateDimmingViewImageStateAnimated:true currentUrl:dict[@"thumbnail"] pausedState:1];
                    });
                }
                
                break;
            }
        }
    }
}

static inline float retinaFloorf(float value)
{
    if (!TGIsRetina())
        return floorf(value);
    
    return ((int)floorf(value * 2.0f)) / 2.0f;
}

- (void)updateSelectionInterface:(bool)animated
{
    _doneButton.enabled = !_selectedSearchIds.empty();
    
    bool incremented = true;
    
    float badgeAlpha = 0.0f;
    if (!_selectedSearchIds.empty())
    {
        badgeAlpha = 1.0f;
        
        if (_countLabel.text.length != 0)
            incremented = [_countLabel.text intValue] < _selectedSearchIds.size();
        
        _countLabel.text = [[NSString alloc] initWithFormat:@"%d", (int)_selectedSearchIds.size()];
        _darkCountLabel.text = _countLabel.text;
        [_countLabel sizeToFit];
    }
    
    float badgeWidth = MAX(22, _countLabel.frame.size.width + 14);
    _countBadge.transform = CGAffineTransformIdentity;
    _darkCountBadge.transform = CGAffineTransformIdentity;
    _countBadge.frame = CGRectMake(-badgeWidth + 22, 10 + TGRetinaPixel, badgeWidth, 22);
    _darkCountBadge.frame = _countBadge.frame;
    _countLabel.frame = CGRectMake(retinaFloorf((badgeWidth - _countLabel.frame.size.width) / 2), 2 + TGRetinaPixel, _countLabel.frame.size.width, _countLabel.frame.size.height);
    _darkCountLabel.frame = _countLabel.frame;
    
    if (animated)
    {
        if (_countBadge.alpha < FLT_EPSILON && badgeAlpha > FLT_EPSILON)
        {
            _countBadge.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            _darkCountBadge.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _countBadge.alpha = badgeAlpha;
                _darkCountBadge.alpha = _countBadge.alpha;
                _countBadge.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                _darkCountBadge.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
                    {
                        _countBadge.transform = CGAffineTransformIdentity;
                        _darkCountBadge.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }
            }];
        }
        else if (_countBadge.alpha > FLT_EPSILON && badgeAlpha < FLT_EPSILON)
        {
            [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _countBadge.alpha = badgeAlpha;
                _darkCountBadge.alpha = _countBadge.alpha;
                _countBadge.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                _darkCountBadge.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    _countBadge.transform = CGAffineTransformIdentity;
                    _darkCountBadge.transform = CGAffineTransformIdentity;
                }
            }];
        }
        else
        {
            [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _countBadge.transform = incremented ? CGAffineTransformMakeScale(1.2f, 1.2f) : CGAffineTransformMakeScale(0.8f, 0.8f);
                _darkCountBadge.transform = incremented ? CGAffineTransformMakeScale(1.2f, 1.2f) : CGAffineTransformMakeScale(0.8f, 0.8f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
                    {
                        _countBadge.transform = CGAffineTransformIdentity;
                        _darkCountBadge.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }
            }];
        }
    }
    else
    {
        _countBadge.transform = CGAffineTransformIdentity;
        _countBadge.alpha = badgeAlpha;
        _darkCountBadge.transform = CGAffineTransformIdentity;
        _darkCountBadge.alpha = _countBadge.alpha;
    }
}

- (void)imagePickerCell:(TGImagePickerCell *)cell selectedSearchId:(int)searchId imageInfo:(TGImageInfo *)__unused imageInfo
{
    bool isSelected = false;
    
    if (_selectedSearchIds.find(searchId) != _selectedSearchIds.end())
    {
        isSelected = false;
        
        _selectedSearchIds.erase(searchId);
    }
    else
    {
        isSelected = true;
        
        _selectedSearchIds.insert(searchId);
    }
    
    [cell animateImageSelected:[[NSNumber alloc] initWithInt:searchId] isSelected:isSelected];
    
    [self updateSelectionInterface:true];
}

- (void)imagePickerCell:(TGImagePickerCell *)cell tappedSearchId:(int)searchId imageInfo:(TGImageInfo *)imageInfo thumbnailImage:(UIImage *)thumbnailImage
{
    [self.view endEditing:true];
    
    if (_avatarSelectionMode)
    {
        TGImageCropController *cropController = [[TGImageCropController alloc] initWithImageInfo:imageInfo thumbnail:thumbnailImage];
        cropController.customCache = nil;
        cropController.watcherHandle = _actionHandle;
        [self.navigationController pushViewController:cropController animated:true];
    }
    else
    {
        _hideSearchId = searchId;
        
        if (_pagingScrollView != nil)
        {
            [_pagingScrollView removeFromSuperview];
            _pagingScrollView.delegate = nil;
            _pagingScrollView = nil;
            [_pagingScrollViewContainer removeFromSuperview];
            _pagingScrollViewContainer = nil;
        }
        
        NSMutableArray *pageList = [[NSMutableArray alloc] init];
        
        int currentImageIndex = 0;
        
        int index = -1;
        for (TGImageInfo *listImageInfo in _searchResults)
        {
            index++;
            
            if (listImageInfo == imageInfo)
            {
                currentImageIndex = index;
            }
            
            [pageList addObject:[[TGImageSearchMediaItem alloc] initWithImageInfo:listImageInfo searchId:[[NSNumber alloc] initWithInt:index]]];
        }
        
        TGCache *_customCache = [TGRemoteImageView sharedCache];
        
        CGRect fromRect = [cell rectForSearchId:searchId];
        
        CGSize screenSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
        
        if (!CGRectIsEmpty(fromRect))
        {
            [self setProgressState:false];
            [self setProgressContainerVisible:true animated:true];
            
            TGImageViewPage *page = [[TGImageViewPage alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
            
            page.customCache = _customCache;
            page.watcherHandle = _actionHandle;
            page.referenceScreenSize = screenSize;
            
            [self actionStageActionRequested:@"bindPage" options:page.actionHandle];
            
            [page controlsAlphaUpdated:0.0f];
            [page loadItem:[pageList objectAtIndex:currentImageIndex] placeholder:thumbnailImage willAnimateAppear:true];
            page.clipsToBounds = true;
            //page.layer.zPosition = 1001;
            [self.view insertSubview:page aboveSubview:_backgroundView];
            page.pageIndex = currentImageIndex;
            
            [TGViewController disableUserInteractionFor:0.31];
            
            fromRect = [cell convertRect:fromRect toView:self.view.window];
            
            [cell hideImage:[[NSNumber alloc] initWithInt:searchId] hide:true];
            
            //page.bottomAnimationPadding = _panelView.frame.size.height;
            [page animateAppearFromImage:thumbnailImage fromView:self.view aboveView:_searchResultsTableView fromRect:fromRect toInterfaceOrientation:self.interfaceOrientation completion:^
             {
                 _pagingScrollViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
                 _pagingScrollViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                 
                 TGImagePanGestureRecognizer *panRecognizer = [[TGImagePanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPanned:)];
                 panRecognizer.delegate = self;
                 panRecognizer.cancelsTouchesInView = true;
                 panRecognizer.maximumNumberOfTouches = 1;
                 [_pagingScrollViewContainer addGestureRecognizer:panRecognizer];
                 
                 //_pagingScrollViewContainer.layer.zPosition = 10001;
                 [self.view insertSubview:_pagingScrollViewContainer aboveSubview:_backgroundView];
                 
                 float pageGap = 40;
                 _pagingScrollView = [[TGImagePagingScrollView alloc] initWithFrame:CGRectMake(-pageGap / 2, 0, screenSize.width + pageGap, screenSize.height)];
                 _pagingScrollView.customCache = _customCache;
                 _pagingScrollView.pageGap = pageGap;
                 _pagingScrollView.delegate = self;
                 _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                 _pagingScrollView.directionalLockEnabled = false;
                 _pagingScrollView.alwaysBounceVertical = false;
                 _pagingScrollView.actionHandle = _actionHandle;
                 _pagingScrollView.interfaceHandle = _actionHandle;
                 _pagingScrollView.pagingDelegate = self;
                 [_pagingScrollViewContainer addSubview:_pagingScrollView];
                 
                 [_pagingScrollView setPageList:pageList];
                 [_pagingScrollView resetOffsetForIndex:currentImageIndex >= 0 ? currentImageIndex : 0];
                 
                 [_pagingScrollView setInitialPageState:page];
                 
                 _backgroundView.alpha = 1.0f;
                 _backgroundView.hidden = false;
                 
                 _backgroundView.alpha = 1.0f;
                 _backgroundView.hidden = false;
                 
                 _cellCheckButton.alpha = 0.0f;
                 _cellCheckButton.hidden = true;
             } keepAspect:true];
            
            _cellCheckButton.alpha = 1.0f;
            _cellCheckButton.hidden = false;
            
            [_checkButton setChecked:_selectedSearchIds.find(searchId) != _selectedSearchIds.end() animated:false];
            [_cellCheckButton setChecked:_selectedSearchIds.find(searchId) != _selectedSearchIds.end() animated:false];
            
            CGRect fromRectInViewSpace = [self.view convertRect:fromRect fromView:self.view.window];
            
            _cellCheckButton.frame = CGRectMake(fromRectInViewSpace.origin.x + fromRectInViewSpace.size.width - 32, fromRectInViewSpace.origin.y - TGRetinaPixel, 33, 33);
            
            [UIView animateWithDuration:0.15 animations:^
             {
                 _cellCheckButton.alpha = 0.0f;
             }];

            
            [UIView animateWithDuration:0.3 animations:^
             {
                if (![self inFormSheet] && ![self inPopover])
                {
                    [TGHacks setApplicationStatusBarAlpha:0.0f];
                    [self setStatusBarBackgroundAlpha:0.0f];
                }
                 //_searchResultsTableView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
                 _darkPanelView.alpha = 1.0f;
                 _checkButton.alpha = 1.0f;
             } completion:^(__unused BOOL finished)
             {
             }];
            
            //_searchResultsTableView.clipsToBounds = false;
        }
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"searchThumbnailTapped"])
    {
    }
    if ([action isEqualToString:@"hideImage"])
    {
        bool hide = [[options objectForKey:@"hide"] boolValue];
        int searchId = [[options objectForKey:@"messageId"] intValue];
        
        if (hide)
        {
            if (_hideSearchId >= 0 && _hideSearchId != searchId)
            {
                for (id cell in _searchResultsTableView.visibleCells)
                {
                    if ([cell isKindOfClass:[TGImagePickerCell class]])
                    {
                        TGImagePickerCell *imageCell = (TGImagePickerCell *)cell;
                        
                        [imageCell hideImage:[[NSNumber alloc] initWithInt:_hideSearchId] hide:false];
                        [imageCell hideImage:[[NSNumber alloc] initWithInt:searchId] hide:true];
                    }
                }
            }
            
            _hideSearchId = searchId;
        }
    }
    else if ([action isEqualToString:@"bindPage"])
    {
        [self setPageHandle:options];
    }
    else if ([action isEqualToString:@"mediaDownloadState"])
    {
        bool visible = [[options objectForKey:@"downloadProgressVisible"] boolValue];
        [self setProgressState:visible animated:!visible];
    }
    else if ([action isEqualToString:@"imageCropResult"])
    {
        if (options != nil)
        {
            id<TGImagePickerControllerDelegate> delegate = _delegate;
            if (delegate != nil && [delegate respondsToSelector:@selector(imagePickerController:didFinishPickingWithAssets:)])
                [delegate imagePickerController:(id)self didFinishPickingWithAssets:[[NSArray alloc] initWithObjects:options, nil]];
        }
    }
    else if ([action isEqualToString:@"pageTapped"])
    {
        [self checkButtonPressed];
    }
}

- (void)setProgressState:(bool)visible
{
    [self setProgressState:visible animated:false];
}

- (void)setProgressState:(bool)visible animated:(bool)animated
{
    if (visible != (_progressLabel.alpha > FLT_EPSILON))
    {
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                _progressLabel.alpha = visible ? 1.0f : 0.0f;
                _clockProgressView.alpha = _progressLabel.alpha;
            }];
        }
        else
        {
            _progressLabel.alpha = visible ? 1.0f : 0.0f;
            _clockProgressView.alpha = _progressLabel.alpha;
        }
        
        if (visible)
        {
            NSString *progressText = TGLocalized(@"Preview.LoadingImage");
            if (![progressText isEqualToString:_progressLabel.text])
            {
                _progressLabel.text = progressText;
                [_progressLabel sizeToFit];
                
                _progressLabel.frame = CGRectMake(floorf((_progressContainer.frame.size.width - _progressLabel.frame.size.width) / 2) + 10, 15, _progressLabel.frame.size.width, _progressLabel.frame.size.height);
            }
        }
        
        if (_clockProgressView.isAnimating != visible)
        {
            if (visible)
                [_clockProgressView startAnimating];
            else
                [_clockProgressView stopAnimating];
        }
    }
}

- (void)setProgressContainerVisible:(bool)visible animated:(bool)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            _progressContainer.alpha = visible ? 1.0f : 0.0f;
        }];
    }
    else
    {
        _progressContainer.alpha = visible ? 1.0f : 0.0f;
    }
}

+ (UIImage *)blurImageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:false];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [img applyLightEffect];
}

- (void)setImageDownloadProgressContainerVisible:(bool)visible animated:(bool)animated
{
    if (visible != _imageDownloadProgressContainer.alpha > FLT_EPSILON)
    {
        if (visible)
        {
            if (iosMajorVersion() >= 7)
            {
                UIImage *image = [TGImageSearchController blurImageWithView:self.view];
                _dimmingOverlayViewBackground.image = image;
            }
        }
        
        _doneButton.userInteractionEnabled = !visible;
        
        if (visible)
            _dimmingOverlayView.hidden = false;
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                _imageDownloadProgressContainer.alpha = visible ? 1.0f : 0.0f;
                _dimmingOverlayView.alpha = visible ? 1.0f : 0.0f;
                _panelView.alpha = visible ? 0.0f : 1.0f;
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    if (!visible)
                        _dimmingOverlayView.hidden = false;
                }
            }];
        }
        else
        {
            _imageDownloadProgressContainer.alpha = visible ? 1.0f : 0.0f;
            _dimmingOverlayView.alpha = visible ? 1.0f : 0.0f;
            _panelView.alpha = visible ? 1.0f : 0.0f;
            _dimmingOverlayView.hidden = !visible;
        }
        
        if (visible)
            [_imageDownloadClockProgressView startAnimating];
        else
            [_imageDownloadClockProgressView stopAnimating];
    }
}

- (void)updateDimmingViewImageStateAnimated:(bool)animated currentUrl:(NSString *)currentUrl pausedState:(int)pausedState
{
    if (_dimmingOverlayViewContentView == nil)
    {
        _dimmingOverlayViewContentView = [[UIView alloc] initWithFrame:CGRectMake(floorf((_dimmingOverlayView.frame.size.width - 160) / 2), floorf((_dimmingOverlayView.frame.size.height - 230) / 2) - 16, 160, 230)];
        _dimmingOverlayViewContentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_dimmingOverlayView addSubview:_dimmingOverlayViewContentView];
        
        _dimmingCurrentImage = [[TGRemoteImageView alloc] initWithFrame:CGRectMake(floorf((_dimmingOverlayViewContentView.frame.size.width - 116) / 2), 26, 116, 116)];
        _dimmingCurrentImage.contentHints = TGRemoteImageContentHintLoadFromDiskSynchronously;
        _dimmingCurrentImage.fadeTransition = true;
        [_dimmingOverlayViewContentView addSubview:_dimmingCurrentImage];
        
        UIImage *cancelImage = [UIImage imageNamed:@"ImageDownloadCancel.png"];
        UIImage *cancelHighlightedImage = [UIImage imageNamed:@"ImageDownloadCancel_Highlighted.png"];
        
        _dimmingCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(_dimmingCurrentImage.frame.origin.x + _dimmingCurrentImage.frame.size.width + 0, _dimmingCurrentImage.frame.origin.y + 2 - cancelImage.size.height, cancelImage.size.width, cancelImage.size.height)];
        [_dimmingCancelButton addTarget:self action:@selector(dimmingCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_dimmingCancelButton setBackgroundImage:cancelImage forState:UIControlStateNormal];
        [_dimmingCancelButton setBackgroundImage:cancelHighlightedImage forState:UIControlStateHighlighted];
        [_dimmingOverlayViewContentView addSubview:_dimmingCancelButton];
        
        static UIImage *progressBackgroundImage = nil;
        static UIImage *progressForegroundImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIImage *rawBackground = [UIImage imageNamed:@"LinearProgressBackground.png"];
            progressBackgroundImage = [rawBackground stretchableImageWithLeftCapWidth:(int)(rawBackground.size.width / 2) topCapHeight:0];
            UIImage *rawForeground = [UIImage imageNamed:@"LinearProgressForeground.png"];
            progressForegroundImage = [rawForeground stretchableImageWithLeftCapWidth:(int)(rawForeground.size.width / 2) topCapHeight:0];
        });
        
        _dimmingProgressView = [[TGLinearProgressView alloc] initWithBackgroundImage:progressBackgroundImage progressImage:progressForegroundImage];
        _dimmingProgressView.frame = CGRectMake(4, _dimmingOverlayView.frame.size.height - _panelView.frame.size.height - 8, _dimmingOverlayView.frame.size.width - 8, progressBackgroundImage.size.height);
        [_dimmingOverlayView addSubview:_dimmingProgressView];
        
        _dimmingProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(_dimmingCurrentImage.frame.origin.x, _dimmingCurrentImage.frame.origin.y + _dimmingCurrentImage.frame.size.height + 12, _dimmingCurrentImage.frame.size.width, 20)];
        _dimmingProgressLabel.backgroundColor = [UIColor clearColor];
        _dimmingProgressLabel.textColor = UIColorRGBA(0xffffff, 0.8f);
        _dimmingProgressLabel.font = TGSystemFontOfSize(13);
        _dimmingProgressLabel.textAlignment = NSTextAlignmentCenter;
        [_dimmingOverlayViewContentView addSubview:_dimmingProgressLabel];
        
        _dimmingInformationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_dimmingCurrentImage.frame.origin.x - 50, _dimmingCurrentImage.frame.origin.y + _dimmingCurrentImage.frame.size.height + 12, _dimmingCurrentImage.frame.size.width + 100, 20)];
        _dimmingInformationLabel.backgroundColor = [UIColor clearColor];
        _dimmingInformationLabel.textColor = UIColorRGBA(0xffffff, 0.8f);
        _dimmingInformationLabel.font = TGSystemFontOfSize(13);
        _dimmingInformationLabel.textAlignment = NSTextAlignmentCenter;
        _dimmingInformationLabel.text = TGLocalized(@"SearchImages.ErrorDownloadingImage");
        [_dimmingOverlayViewContentView addSubview:_dimmingInformationLabel];
        
        UIImage *rawOverlayTopButtonImage = [UIImage imageNamed:@"SearchImagesButtonTop.png"];
        UIImage *rawOverlayTopButtonHighlightedImage = [UIImage imageNamed:@"SearchImagesButtonTop_Highlighted.png"];
        UIImage *rawOverlayBottomButtonImage = [UIImage imageNamed:@"SearchImagesButtonBottom.png"];
        UIImage *rawOverlayBottomButtonHighlightedImage = [UIImage imageNamed:@"SearchImagesButtonBottom_Highlighted.png"];
        
        _dimmingRetryButton = [[UIButton alloc] initWithFrame:CGRectMake(floorf((_dimmingOverlayView.frame.size.width - 230) / 2), _dimmingOverlayView.frame.size.height - _panelView.frame.size.height - (_panelView.frame.size.width > 400 ? 80 : 150), 230, rawOverlayTopButtonImage.size.height)];
        [_dimmingOverlayView addSubview:_dimmingRetryButton];
        [_dimmingRetryButton setBackgroundImage:[rawOverlayTopButtonImage stretchableImageWithLeftCapWidth:(int)(rawOverlayTopButtonImage.size.width / 2) topCapHeight:0] forState:UIControlStateNormal];
        [_dimmingRetryButton setBackgroundImage:[rawOverlayTopButtonHighlightedImage stretchableImageWithLeftCapWidth:(int)(rawOverlayTopButtonHighlightedImage.size.width / 2) topCapHeight:0] forState:UIControlStateHighlighted];
        
        [_dimmingRetryButton setTitle:TGLocalized(@"SearchImages.RetryDownload") forState:UIControlStateNormal];
        [_dimmingRetryButton setTitleColor:UIColorRGBA(0xffffff, 0.85f) forState:UIControlStateNormal];
        _dimmingRetryButton.titleLabel.font = TGSystemFontOfSize(14);
        
        [_dimmingRetryButton addTarget:self action:@selector(retryButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _dimmingSkipButton = [[UIButton alloc] initWithFrame:CGRectMake(floorf((_dimmingOverlayView.frame.size.width - 230) / 2), _dimmingRetryButton.frame.origin.y + _dimmingRetryButton.frame.size.height + (TGIsRetina() ? 0.5f : 1.0f), 230, rawOverlayBottomButtonImage.size.height)];
        [_dimmingOverlayView addSubview:_dimmingSkipButton];
        [_dimmingSkipButton setBackgroundImage:[rawOverlayBottomButtonImage stretchableImageWithLeftCapWidth:(int)(rawOverlayBottomButtonImage.size.width / 2) topCapHeight:0] forState:UIControlStateNormal];
        [_dimmingSkipButton setBackgroundImage:[rawOverlayBottomButtonHighlightedImage stretchableImageWithLeftCapWidth:(int)(rawOverlayBottomButtonHighlightedImage.size.width / 2) topCapHeight:0] forState:UIControlStateHighlighted];
        
        [_dimmingSkipButton setTitle:TGLocalized(@"SearchImages.SkipImage") forState:UIControlStateNormal];
        [_dimmingSkipButton setTitleColor:UIColorRGBA(0xffffff, 0.85f) forState:UIControlStateNormal];
        _dimmingSkipButton.titleLabel.font = TGSystemFontOfSize(14);
        
        [_dimmingSkipButton addTarget:self action:@selector(skipButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _dimmingCurrentImage.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    }
    
    if (currentUrl == nil)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                _dimmingCurrentImage.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            }];
        }
        else
        {
            _dimmingCurrentImage.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        }
    }
    else
    {
        bool failed = pausedState != 0;
        
        _dimmingSkipButton.hidden = !failed;
        _dimmingRetryButton.hidden = !failed;
        _dimmingProgressView.hidden = failed;
        
        _dimmingProgressLabel.hidden = failed;
        _dimmingInformationLabel.hidden = !failed;
        
        _dimmingInformationLabel.text = pausedState == 2 ? TGLocalized(@"SearchImages.DownloadCancelled") : TGLocalized(@"SearchImages.ErrorDownloadingImage");
        
        _dimmingCancelButton.hidden = pausedState != 0;
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                _dimmingCurrentImage.transform = CGAffineTransformIdentity;
            }];
        }
        else
        {
            _dimmingCurrentImage.transform = CGAffineTransformIdentity;
        }
        
        if (![_dimmingCurrentImage.currentUrl isEqualToString:currentUrl])
            [_dimmingCurrentImage loadImage:currentUrl filter:@"downloadingOverlayImage" placeholder:nil];
    }
}

- (void)setPageHandle:(ASHandle *)pageHandle
{
    if (_pageHandle != nil)
        [_pageHandle requestAction:@"bindInterfaceView" options:nil];
    
    _pageHandle = pageHandle;
    
    if (_pageHandle != nil)
    {
        [_pageHandle requestAction:@"bindInterfaceView" options:_actionHandle];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    return false;
}

- (void)scrollViewPanned:(TGImagePanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        TGImageViewPage *currentPage = [_pagingScrollView pageForIndex:_pagingScrollView.currentPageIndex];
        
        if (![currentPage isZoomed])
        {
            _pagingScrollViewPanning = true;
            _pagingScrollView.clipsToBounds = false;
            
            _backgroundView.hidden = false;
            _backgroundView.alpha = 1.0f;
        }
        else
            _pagingScrollViewPanning = false;
    }
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (_pagingScrollViewPanning)
        {
            CGPoint translation = [recognizer translationInView:_pagingScrollView];
            if (ABS(translation.y) < 14)
                return;
            
            CGRect frame = _pagingScrollView.frame;
            frame.origin.y = translation.y - (translation.y > 0 ? 14 : -14);
            
            float alpha = MAX(0.4f, 1.0f - MIN(1.0f, ABS(translation.y) / 400.0f));
            _backgroundView.alpha = alpha;
            _pagingScrollView.frame = frame;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        if (_pagingScrollViewPanning)
        {
            _pagingScrollViewPanning = false;
            
            CGPoint translation = [recognizer translationInView:_pagingScrollView];
            float velocity = [recognizer velocityInView:recognizer.view].y;
            
            TGImageViewPage *currentPage = [_pagingScrollView pageForIndex:_pagingScrollView.currentPageIndex];
            
            if (recognizer.state == UIGestureRecognizerStateEnded && (ABS(translation.y) > 80 || ABS(velocity) > 800) && ABS(_pagingScrollView.contentOffset.x - currentPage.frame.origin.x + 20) < FLT_EPSILON)
            {
                _pagingScrollView.scrollEnabled = false;
                
                float swipeVelocity = [recognizer velocityInView:recognizer.view].y;
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    CGRect frame = _pagingScrollView.frame;
                    [currentPage offsetContent:CGPointMake(0, -frame.origin.y)];
                    frame.origin.y = 0;
                    _pagingScrollView.frame = frame;
                    
                    [self dismissPagingScrollView:swipeVelocity];
                });
            }
            else
            {
                CGRect frame = _pagingScrollView.frame;
                frame.origin.y = 0;
                [UIView animateWithDuration:0.28 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
                 {
                     _pagingScrollView.frame = frame;
                     _backgroundView.alpha = 1.0f;
                 } completion:^(BOOL finished)
                 {
                     if (finished)
                     {
                         _pagingScrollView.clipsToBounds = true;
                     }
                 }];
            }
        }
    }
}

- (void)dismissPagingScrollView:(float)swipeVelocity
{
    _hideSearchId = -1;
    
    TGImageViewPage *page = [_pagingScrollView pageForIndex:[_pagingScrollView currentPageIndex]];
    NSNumber *nSearchId = ((TGImageSearchMediaItem *)page.imageItem).searchId;
    
    _searchResultsTableView.transform = CGAffineTransformIdentity;
    
    CGRect targetRect = CGRectZero;
    TGImagePickerCell *targetCell = nil;
    
    if (nSearchId != nil)
    {
        for (id cell in _searchResultsTableView.visibleCells)
        {
            if ([cell isKindOfClass:[TGImagePickerCell class]])
            {
                CGRect rect = [(TGImagePickerCell *)cell rectForSearchId:[nSearchId intValue]];
                if (!CGRectIsEmpty(rect))
                {
                    targetRect = [cell convertRect:rect toView:self.view.window];
                    [(TGImagePickerCell *)cell hideImage:nSearchId hide:true];
                    targetCell = cell;
                    
                    break;
                }
            }
        }
    }
    
    UIImage *thumbnail = [[TGRemoteImageView sharedCache] cachedImage:[targetCell currentImageUrlForSearchId:[nSearchId intValue]] availability:TGCacheBoth];
    if (thumbnail == nil)
        thumbnail = [targetCell imageForSearchId:[nSearchId intValue]];
    
    if (CGRectIsEmpty(targetRect) || thumbnail == nil)
    {
        [(TGImagePickerCell *)targetCell hideImage:nSearchId hide:false];
        
        [UIView animateWithDuration:0.3 animations:^
        {
            _pagingScrollView.alpha = 0.0f;
            _backgroundView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [_pagingScrollView removeFromSuperview];
            _pagingScrollView.delegate = nil;
            _pagingScrollView = nil;
            
            [_pagingScrollViewContainer removeFromSuperview];
            _pagingScrollViewContainer = nil;
            
            _backgroundView.alpha = 1.0f;
            _backgroundView.hidden = true;
        }];
        
        [page animateDisappearToImage:nil toView:self.view aboveView:_searchResultsTableView toRect:targetRect toContainerImage:nil toInterfaceOrientation:self.interfaceOrientation keepAspect:true backgroundAlpha:_backgroundView.alpha swipeVelocity:swipeVelocity completion:^
        {
            [_pagingScrollView removeFromSuperview];
            _pagingScrollView.delegate = nil;
            _pagingScrollView = nil;
            
            [_pagingScrollViewContainer removeFromSuperview];
            _pagingScrollViewContainer = nil;
            
            [self setProgressState:false];
            
            [self updateSelectionInterface:false];
        }];
    }
    else
    {
        [page animateDisappearToImage:thumbnail toView:self.view aboveView:_searchResultsTableView toRect:targetRect toContainerImage:thumbnail toInterfaceOrientation:self.interfaceOrientation keepAspect:true backgroundAlpha:_backgroundView.alpha swipeVelocity:swipeVelocity completion:^
        {
            [_pagingScrollView removeFromSuperview];
            _pagingScrollView.delegate = nil;
            _pagingScrollView = nil;
            
            [_pagingScrollViewContainer removeFromSuperview];
            _pagingScrollViewContainer = nil;
            
            [(TGImagePickerCell *)targetCell hideImage:nSearchId hide:false];
            
            [self setProgressState:false];
            
            _cellCheckButton.alpha = 0.0f;
            _cellCheckButton.hidden = true;
            
            [self updateSelectionInterface:false];
        }];
        
        _backgroundView.alpha = 1.0f;
        _backgroundView.hidden = true;
        
        CGRect toRectInViewSpace = [self.view convertRect:targetRect fromView:self.view.window];
        
        _cellCheckButton.hidden = false;
        _cellCheckButton.alpha = 0.0f;
        _cellCheckButton.frame = CGRectMake(toRectInViewSpace.origin.x + toRectInViewSpace.size.width - 32, toRectInViewSpace.origin.y - TGRetinaPixel, 33, 33);
        
        [UIView animateWithDuration:0.15 delay:0.12 options:0 animations:^
         {
             _cellCheckButton.alpha = 1.0f;
         } completion:nil];
    }
    
    [self setProgressContainerVisible:false animated:true];
    
    //_searchResultsTableView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
    [UIView animateWithDuration:0.3 animations:^
    {
        if (![self inFormSheet] && ![self inPopover])
        {
            [TGHacks setApplicationStatusBarAlpha:1.0f];
            [self setStatusBarBackgroundAlpha:1.0f];
        }
        //_searchResultsTableView.transform = CGAffineTransformIdentity;
        _darkPanelView.alpha = 0.0f;
        _checkButton.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
       // _searchResultsTableView.clipsToBounds = true;
    }];
}

- (void)scrollViewCurrentPageChanged:(int)__unused currentPage imageItem:(id<TGMediaItem>)imageItem
{
    bool isChecked = _selectedSearchIds.find([((TGImageSearchMediaItem *)imageItem).searchId intValue]) != _selectedSearchIds.end();
    [_checkButton setChecked:isChecked animated:false];
    [_cellCheckButton setChecked:isChecked animated:false];
}

- (void)pageWillBeginDragging:(UIScrollView *)__unused scrollView
{
}

- (void)pageDidScroll:(UIScrollView *)__unused scrollView
{
}

- (void)pageDidEndDragging:(UIScrollView *)__unused scrollView
{
}

- (id)actionsSender
{
    return nil;
}

- (float)controlsAlpha
{
    return 0.0f;
}

- (void)checkButtonPressed
{
    TGImageViewPage *page = [_pagingScrollView pageForIndex:[_pagingScrollView currentPageIndex]];
    id nSearchId = ((TGImageSearchMediaItem *)page.imageItem).searchId;
    if (nSearchId != nil)
    {
        int searchId = [nSearchId intValue];
    
        bool isSelected = false;
        
        if (_selectedSearchIds.find(searchId) != _selectedSearchIds.end())
        {
            isSelected = false;
            
            _selectedSearchIds.erase(searchId);
        }
        else
        {
            isSelected = true;
            
            _selectedSearchIds.insert(searchId);
        }
        
        for (UITableViewCell *cell in _searchResultsTableView.visibleCells)
        {
            if ([cell isKindOfClass:[TGImagePickerCell class]])
            {
                [(TGImagePickerCell *)cell updateImageSelected:nSearchId isSelected:isSelected];
            }
        }
        
        [_checkButton setChecked:isSelected animated:true];
        [_cellCheckButton setChecked:isSelected animated:false];
        
        if (isSelected)
        {
            UIImage *currentImage = [page currentImage];
            if (currentImage != nil)
            {
                [TGViewController disableUserInteractionFor:0.29];
                
                UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _panelView.frame.origin.y)];
                containerView.clipsToBounds = true;
                containerView.layer.zPosition = 10001;
                [self.view insertSubview:containerView aboveSubview:_panelView];
                
                UIImageView *imageView = [[UIImageView alloc] initWithImage:currentImage];
                imageView.frame = [page currentImageFrameInView:self.view];
                [containerView addSubview:imageView];
                
                CGRect doneFrame = [_doneButton convertRect:_doneButton.bounds toView:self.view];
                
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathMoveToPoint(path, NULL, imageView.center.x, imageView.center.y);
                CGPathAddQuadCurveToPoint(path, NULL, imageView.center.x + 100, imageView.center.y - 100, doneFrame.origin.x, doneFrame.origin.y);
                
                CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
                pathAnimation.path = path;
                pathAnimation.duration = 0.28;
                pathAnimation.fillMode = kCAFillModeForwards;
                pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                [imageView.layer addAnimation:pathAnimation forKey:nil];
                imageView.layer.position = CGPointMake(doneFrame.origin.x, doneFrame.origin.y);
                
                CFRelease(path);
                
                [UIView animateWithDuration:0.1 animations:^
                 {
                     containerView.frame = self.view.bounds;
                 }];
                
                [UIView animateWithDuration:0.28 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
                 {
                     imageView.transform = CGAffineTransformMakeScale(MAX(0.001f, 10.0f / imageView.frame.size.width), MAX(0.001f, 10.0f / imageView.frame.size.height));
                 } completion:^(__unused BOOL finished)
                 {
                     [containerView removeFromSuperview];
                     [imageView removeFromSuperview];
                     [self updateSelectionInterface:true];
                 }];
            }
            else
                [self updateSelectionInterface:true];
        }
        else
            [self updateSelectionInterface:true];
    }
}

- (void)dimmingCancelButtonPressed
{
    [self stopCurrentlyDownloadingImage];
}

- (void)skipButtonPressed
{
    [self skipCurrentlyDownloadingImage];
}

- (void)retryButtonPressed
{
    [self retryCurrentlyDownloadingImage];
}

@end
