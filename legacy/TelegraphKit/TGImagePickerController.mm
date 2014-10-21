#import "TGImagePickerController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "TGActionTableView.h"
#import "TGImageUtils.h"

#import "TGImagePickerCell.h"

#import "TGTimer.h"

#import <QuartzCore/QuartzCore.h>

#import "TGImagePagingScrollView.h"
#import "TGImageViewPage.h"
#import "TGImagePanGestureRecognizer.h"

#import "TGImagePickerCheckButton.h"
#import "TGImagePickerCellCheckButton.h"

#import "TGImageCropController.h"

#import "TGHacks.h"

#import "TGToolbar.h"

#import "TGObserverProxy.h"

#import "TGModernBackToolbarButton.h"

#import "TGFont.h"

#import "TGModernButton.h"

#include <tr1/memory>
#include <vector>
#include <set>
#include <map>

@interface TGAssetMediaItem : NSObject <TGMediaItem>

@property (nonatomic) TGMediaItemType type;

@property (nonatomic, strong) TGImagePickerAsset *asset;

@property (nonatomic, strong) TGImageInfo *imageInfo;

@end

@implementation TGAssetMediaItem

- (id)initWithAsset:(TGImagePickerAsset *)asset
{
    self = [super init];
    if (self != nil)
    {
        _asset = asset;
        _type = TGMediaItemTypePhoto;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGAssetMediaItem *assetMediaItem = [[TGAssetMediaItem alloc] initWithAsset:_asset];
    
    assetMediaItem.imageInfo = _imageInfo;
    
    return assetMediaItem;
}

- (TGImageInfo *)imageInfo
{
    if (_imageInfo == nil)
    {
        TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
        CGSize dimensions = CGSizeZero;
        CGSize fullScreenSize = CGSizeZero;
        
        CGSize screenSize = [TGViewController screenSize:UIInterfaceOrientationPortrait];
        screenSize.width = MAX(screenSize.width, screenSize.height);
        screenSize.width *= 2;
        screenSize.height *= 2;
        screenSize.height = screenSize.width;
        
        if ([ALAssetRepresentation instancesRespondToSelector:@selector(dimensions)])
        {
            dimensions = _asset.asset.defaultRepresentation.dimensions;
            fullScreenSize = TGFitSize(dimensions, screenSize);
        }
        else
        {
            CGImageRef thumbnail = _asset.asset.aspectRatioThumbnail;
            if (thumbnail != NULL)
                dimensions = CGSizeMake(CGImageGetWidth(thumbnail), CGImageGetHeight(thumbnail));
            fullScreenSize = TGFitSize(dimensions, screenSize);
            fullScreenSize.width *= 2;
            fullScreenSize.height *= 2;
        }
        
        [imageInfo addImageWithSize:TGFitSize(dimensions, CGSizeMake(200, 200)) url:[[NSString alloc] initWithFormat:@"asset-thumbnail:%@", _asset.assetUrl]];
        [imageInfo addImageWithSize:fullScreenSize url:[[NSString alloc] initWithFormat:@"asset-original:%@", _asset.assetUrl]];
        
        _imageInfo = imageInfo;
    }
    
    return _imageInfo;
}

- (TGVideoMediaAttachment *)videoAttachment
{
    return nil;
}

- (id)itemId
{
    return _asset.assetUrl;
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
    return [[UIImage alloc] initWithCGImage:[_asset.asset aspectRatioThumbnail]];
}

@end

#pragma mark -

static const char *assetsProcessingQueueSpecific = "assetsProcessingQueue";

static dispatch_queue_t assetsProcessingQueue()
{
    static dispatch_queue_t queue = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = dispatch_queue_create("com.tg.assetsqueue", 0);
        if (dispatch_queue_set_specific != NULL)
            dispatch_queue_set_specific(queue, assetsProcessingQueueSpecific, (void *)assetsProcessingQueueSpecific, NULL);
    });
    
    return queue;
}

void dispatchOnAssetsProcessingQueue(dispatch_block_t block)
{
    bool isCurrentQueueAssetsProcessingQueue = false;
    isCurrentQueueAssetsProcessingQueue = dispatch_get_specific(assetsProcessingQueueSpecific) != NULL;
    
    if (isCurrentQueueAssetsProcessingQueue)
        block();
    else
        dispatch_async(assetsProcessingQueue(), block);
}

static ALAssetsLibrary *sharedLibrary = nil;
static TGTimer *sharedLibraryReleaseTimer = nil;
static int sharedLibraryRetainCount = 0;

void sharedAssetsLibraryRetain()
{
    dispatchOnAssetsProcessingQueue(^
    {
        if (sharedLibraryReleaseTimer != nil)
        {
            [sharedLibraryReleaseTimer invalidate];
            sharedLibraryReleaseTimer = nil;
        }
        
        if (sharedLibrary == nil)
        {
            TGLog(@"Preloading shared assets library");
            sharedLibraryRetainCount = 1;
            sharedLibrary = [[ALAssetsLibrary alloc] init];
            
            if (iosMajorVersion() == 5)
                [sharedLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:^(__unused NSURL *assetURL, __unused NSError *error) { }];
            
            [sharedLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
            {
                if (group != nil)
                {
                    if (stop != NULL)
                        *stop = true;
                    
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                    [group numberOfAssets];
                }
            } failureBlock:^(__unused NSError *error)
            {
                TGLog(@"assets access error");
            }];
        }
        else
            sharedLibraryRetainCount++;
    });
}

void sharedAssetsLibraryRelease()
{
    dispatchOnAssetsProcessingQueue(^
    {
        sharedLibraryRetainCount--;
        if (sharedLibraryRetainCount <= 0)
        {
            sharedLibraryRetainCount = 0;

            if (sharedLibraryReleaseTimer != nil)
            {
                [sharedLibraryReleaseTimer invalidate];
                sharedLibraryReleaseTimer = nil;
            }
            
            sharedLibraryReleaseTimer = [[TGTimer alloc] initWithTimeout:4 repeat:false completion:^
            {
                sharedLibraryReleaseTimer = nil;
                
                TGLog(@"Destroyed shared assets library");
                sharedLibrary = nil;
            } queue:assetsProcessingQueue()];
            [sharedLibraryReleaseTimer start];
        }
    });
}

@interface TGAssetsLibraryHolder : NSObject

@end

@implementation TGAssetsLibraryHolder

- (void)dealloc
{
    sharedAssetsLibraryRelease();
}

@end

@interface TGImagePickerController () <UITableViewDataSource, UITableViewDelegate, TGImagePagingScrollViewDelegate, UIGestureRecognizerDelegate>
{
    volatile bool _stopAllTasks;
    
    CGFloat _inset;
}

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic, strong) TGCache *customCache;

@property (nonatomic, strong) TGActionTableView *tableView;
@property (nonatomic) int assetsInRow;
@property (nonatomic) CGFloat imageSize;
@property (nonatomic) CGFloat lineHeight;

@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) TGModernButton *cancelButton;
@property (nonatomic, strong) TGModernButton *doneButton;

@property (nonatomic, strong) UIView *darkPanelView;
@property (nonatomic, strong) TGModernButton *darkCancelButton;
@property (nonatomic, strong) TGModernButton *darkDoneButton;

@property (nonatomic, strong) UIBarButtonItem *closeButtonItem;

@property (nonatomic, strong) UIImageView *countBadge;
@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) UIImageView *darkCountBadge;
@property (nonatomic, strong) UILabel *darkCountLabel;

@property (nonatomic, strong) NSMutableArray *assetList;
@property (nonatomic, strong) NSMutableSet *selectedAssets;

@property (nonatomic, strong) TGTimer *assetsChangeDelayTimer;

@property (nonatomic, strong) UIView *pagingScrollViewContainer;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) TGImagePagingScrollView *pagingScrollView;
@property (nonatomic) bool pagingScrollViewPanning;

@property (nonatomic, strong) TGImagePickerCheckButton *checkButton;
@property (nonatomic, strong) TGImagePickerCellCheckButton *cellCheckButton;

@property (nonatomic, strong) NSString *hideItemUrl;

@property (nonatomic, strong) NSURL *groupUrl;
@property (nonatomic, strong) NSString *groupTitle;
@property (nonatomic) bool avatarSelectionMode;

@property (nonatomic) CGPoint checkGestureStartPoint;
@property (nonatomic) bool processingCheckGesture;
@property (nonatomic) bool failCheckGesture;
@property (nonatomic) bool checkGestureChecks;

@property (nonatomic, strong) UIPanGestureRecognizer *checkGestureRecognizer;

@property (nonatomic, strong) TGObserverProxy *assetsLibraryDidChangeProxy;

@property (nonatomic, strong) UIView *accessDisabledContainer;

@end

@implementation TGImagePickerController

+ (id)sharedAssetsLibrary
{
    return sharedLibrary;
}

+ (id)preloadLibrary
{
    dispatchOnAssetsProcessingQueue(^
    {
        if ([(id)[ALAssetsLibrary class] respondsToSelector:@selector(authorizationStatus)])
        {
            if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized)
                return;
        }
        
        sharedAssetsLibraryRetain();
    });
    
    TGAssetsLibraryHolder *libraryHolder = [[TGAssetsLibraryHolder alloc] init];
    return libraryHolder;
}

+ (void)loadAssetWithUrl:(NSURL *)url completion:(void (^)(ALAsset *asset))completion
{
    dispatchOnAssetsProcessingQueue(^
    {
        if (sharedLibrary != nil)
        {
            [sharedLibrary assetForURL:url resultBlock:^(ALAsset *asset)
            {
                if (completion)
                    completion(asset);
            } failureBlock:^(__unused NSError *error)
            {
                if (completion)
                    completion(nil);
            }];
        }
        else
        {
            if (completion)
                completion(nil);
        }
    });
}

+ (void)storeImageAsset:(NSData *)data
{
    dispatchOnAssetsProcessingQueue(^
    {
        ALAssetsLibrary *library = sharedLibrary;
        if (library == nil)
            library = [[ALAssetsLibrary alloc] init];
        
        [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:nil];
    });
}

- (id)initWithGroupUrl:(NSURL *)groupUrl groupTitle:(NSString *)groupTitle avatarSelection:(bool)avatarSelection
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _groupUrl = groupUrl;
        _groupTitle = groupTitle;
        _avatarSelectionMode = avatarSelection;
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.automaticallyManageScrollViewInsets = false;
    
    _stopAllTasks = false;
    
    _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
    
    self.wantsFullScreenLayout = true;
    
    dispatchOnAssetsProcessingQueue(^
    {
        sharedAssetsLibraryRetain();
        _assetsLibrary = sharedLibrary;
    });
    
    _selectedAssets = [[NSMutableSet alloc] init];
    
    _assetsLibraryDidChangeProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(assetsLibraryDidChange:) name:ALAssetsLibraryChangedNotification object:_assetsLibrary];
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [self doUnloadView];
    
    _assetsLibraryDidChangeProxy = nil;
    
    ALAssetsLibrary *assetsLibrary = _assetsLibrary;
    dispatchOnAssetsProcessingQueue(^
    {
        sharedAssetsLibraryRelease();
        [assetsLibrary description];
    });
    _assetsLibrary = nil;
}

- (UIBarStyle)requiredNavigationBarStyle
{
    return UIBarStyleDefault;
}

- (bool)navigationBarShouldBeHidden
{
    return false;
}

- (UIStatusBarStyle)viewControllerPreferredStatusBarStyle
{
    return UIStatusBarStyleBlackTranslucent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (int)assetsInRowForWidth:(CGFloat)width widescreenWidth:(CGFloat)widescreenWidth
{
    return (int)(width / [self imageSizeForWidth:width widescreenWidth:widescreenWidth]);
}

- (CGFloat)imageSizeForWidth:(CGFloat)width widescreenWidth:(CGFloat)widescreenWidth
{
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
        else
        {
            if (width >= widescreenWidth - FLT_EPSILON)
                return 78.0f;
            else
                return 78.5f;
        }
    }
    else
    {
        if (width >= widescreenWidth - FLT_EPSILON)
            return 78.0f;
        else
            return 78.0f;
    }
}

- (CGFloat)lineSpacingForWidth:(CGFloat)width widescreenWidth:(CGFloat)widescreenWidth
{
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
    
    self.titleText = _groupTitle == nil ? TGLocalized(@"MediaPicker.CameraRoll") : _groupTitle;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _customCache = [[TGCache alloc] init];
    
    CGSize screenSize = [self referenceViewSizeForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];

    _assetsInRow = [self assetsInRowForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
    _imageSize = [self imageSizeForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
    _lineHeight = [self lineHeightForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
    _inset = [self insetForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
    
    _tableView = [[TGActionTableView alloc] init];
    CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _tableView.frame = tableFrame;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(20 + (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 44 : 32), 0, 2 + 44, 0);
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(_tableView.contentInset.top, 0, 44, 0);
    [self.view addSubview:_tableView];
    
    _checkGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tablePanRecognized:)];
    _checkGestureRecognizer.delegate = self;
    [_tableView addGestureRecognizer:_checkGestureRecognizer];
    
    _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backgroundView.hidden = true;
    _backgroundView.alpha = 1.0f;
    _backgroundView.userInteractionEnabled = false;
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    __unused float retinaPixel = TGIsRetina() ? 0.5f : 0.0f;
    
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
    _darkCancelButton.frame = CGRectMake(0, 0, MAX(120, _darkDoneButton.frame.size.width), 44);
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
    _checkButton.hidden = true;
    
    [self.view addSubview:_checkButton];
    
    _cellCheckButton = [[TGImagePickerCellCheckButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [_cellCheckButton setChecked:false animated:false];
    _cellCheckButton.alpha = 0.0f;
    _cellCheckButton.hidden = true;
    [self.view addSubview:_cellCheckButton];
    
    [self updateSelectionInterface:false];
    
    [self reloadAssets:true];
}

- (void)doUnloadView
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    
    _assetList = nil;
    
    _customCache = nil;
    
    [_selectedAssets removeAllObjects];
}

- (UIBarButtonItem *)closeButtonItem
{
    if (_closeButtonItem == nil)
    {
        TGModernBackToolbarButton *backButton = [[TGModernBackToolbarButton alloc] initWithLightMode];
        [backButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [backButton sizeToFit];
        _closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    
    return _closeButtonItem;
}

- (UIView *)accessDisabledContainer
{
    if (_accessDisabledContainer == nil)
    {
        _accessDisabledContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 2)];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = UIColorRGB(0xa8a8a8);
        titleLabel.font = TGBoldSystemFontOfSize(14);
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        titleLabel.text = TGLocalized(@"MediaPicker.AccessDeniedError");
        titleLabel.tag = 100;
        
        [_accessDisabledContainer addSubview:titleLabel];
        
        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.textColor = UIColorRGB(0xa8a8a8);
        subtitleLabel.font = TGSystemFontOfSize(14);
        subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subtitleLabel.numberOfLines = 0;
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        
        NSString *model = @"iPhone";
        NSString *rawModel = [[[UIDevice currentDevice] model] lowercaseString];
        if ([rawModel rangeOfString:@"ipod"].location != NSNotFound)
            model = @"iPod";
        else if ([rawModel rangeOfString:@"ipad"].location != NSNotFound)
            model = @"iPad";
        
        subtitleLabel.text = [[NSString alloc] initWithFormat:TGLocalized(@"MediaPicker.AccessDeniedHelp"), model];
        subtitleLabel.tag = 101;
        
        [_accessDisabledContainer addSubview:subtitleLabel];
        
        [self _updateAccessDisabledContainerLayout:self.interfaceOrientation];
    }
    
    return _accessDisabledContainer;
}

- (void)_showAccessDisabled
{
    if (_accessDisabledContainer.superview == nil)
        [self.view addSubview:[self accessDisabledContainer]];
}

- (void)_updateAccessDisabledContainerLayout:(UIInterfaceOrientation)orientation
{
    UILabel *titleLabel = (UILabel *)[_accessDisabledContainer viewWithTag:100];
    UILabel *subtitleLabel = (UILabel *)[_accessDisabledContainer viewWithTag:101];
    
    if (titleLabel == nil || subtitleLabel == nil)
        return;
    
    CGSize screenSize = [self referenceViewSizeForOrientation:orientation];
    
    CGSize titleSize = [titleLabel sizeThatFits:CGSizeMake(screenSize.width - 20, 1000)];
    titleLabel.frame = CGRectMake(floorf((titleLabel.superview.frame.size.width - titleSize.width) / 2), -titleSize.height, titleSize.width, titleSize.height);
    
    CGSize subtitleSize = [subtitleLabel sizeThatFits:CGSizeMake(screenSize.width - 20, 1000)];
    subtitleLabel.frame = CGRectMake(floorf((subtitleLabel.superview.frame.size.width - subtitleSize.width) / 2), 2, subtitleSize.width, subtitleSize.height);
    
    _accessDisabledContainer.frame = CGRectMake(floorf((screenSize.width - _accessDisabledContainer.frame.size.width) / 2), floorf((screenSize.height - _accessDisabledContainer.frame.size.height) / 2), _accessDisabledContainer.frame.size.width, _accessDisabledContainer.frame.size.height);
}

- (void)viewDidUnload
{
    [self doUnloadView];
}

- (void)performClose
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:animated];
    
    CGAffineTransform tableTransform = _tableView.transform;
    _tableView.transform = CGAffineTransformIdentity;
    
    UIInterfaceOrientation interfaceOrientation = [self currentInterfaceOrientation];
    
    CGSize screenSize = [self referenceViewSizeForOrientation:interfaceOrientation];
    
    _tableView.contentInset = UIEdgeInsetsMake(20 + (UIInterfaceOrientationIsPortrait(interfaceOrientation) ? 44 : 32), 0, 2 + 44, 0);
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(_tableView.contentInset.top, 0, 44, 0);
    
    UIEdgeInsets inset = _tableView.contentInset;
    float lastInverseOffset = MAX(0, _tableView.contentSize.height - (_tableView.contentOffset.y + _tableView.frame.size.height - inset.bottom));
    
    CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _tableView.frame = tableFrame;
    
    int assetsInRow = [self assetsInRowForWidth:tableFrame.size.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
    CGFloat imageSize = [self imageSizeForWidth:tableFrame.size.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
    if (assetsInRow != _assetsInRow || ABS(imageSize - _imageSize) > FLT_EPSILON)
    {
        _assetsInRow = assetsInRow;
        _imageSize = imageSize;
        _lineHeight = [self lineHeightForWidth:tableFrame.size.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
        _inset = [self insetForWidth:tableFrame.size.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
        [_tableView reloadData];
    }
    
    if (lastInverseOffset < 8)
    {
        CGPoint contentOffset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height + inset.bottom - lastInverseOffset);
        if (contentOffset.y < -inset.top)
            contentOffset.y = -inset.top;
        [_tableView setContentOffset:contentOffset animated:false];
    }
    
    _tableView.transform = tableTransform;
    
    if ([_tableView indexPathForSelectedRow] != nil)
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:true];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:animated];
    
    if (![self inPopover] && ![self inFormSheet])
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            [TGHacks setApplicationStatusBarAlpha:1.0f];
            [self setStatusBarBackgroundAlpha:1.0f];
        }];
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark -

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _panelView.hidden = true;
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 0.0f);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *tableImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *temporaryImageView = [[UIImageView alloc] initWithImage:tableImage];
    temporaryImageView.frame = self.view.bounds;
    [self.view insertSubview:temporaryImageView aboveSubview:_tableView];
    
    [UIView animateWithDuration:duration animations:^
    {
        temporaryImageView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [temporaryImageView removeFromSuperview];
    }];
    
    _panelView.hidden = false;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        CGSize screenSize = [self referenceViewSizeForOrientation:toInterfaceOrientation];
        
        CGAffineTransform tableTransform = _tableView.transform;
        _tableView.transform = CGAffineTransformIdentity;
        
        _tableView.contentInset = UIEdgeInsetsMake(20 + (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? 44 : 32), 0, 2 + 44, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(_tableView.contentInset.top, 0, 44, 0);
        
        UIEdgeInsets inset = _tableView.contentInset;
        float lastInverseOffset = MAX(0, _tableView.contentSize.height - (_tableView.contentOffset.y + _tableView.frame.size.height - inset.bottom));
        
        CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
        _tableView.frame = tableFrame;
        
        _assetsInRow = [self assetsInRowForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
        _imageSize = [self imageSizeForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
        _lineHeight = [self lineHeightForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
        _inset = [self insetForWidth:screenSize.width widescreenWidth:[self referenceViewSizeForOrientation:UIInterfaceOrientationLandscapeLeft].width];
        
        [_tableView reloadData];
        
        if (lastInverseOffset < 8)
        {
            CGPoint contentOffset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height + inset.bottom - lastInverseOffset);
            if (contentOffset.y < -inset.top)
                contentOffset.y = -inset.top;
            [_tableView setContentOffset:contentOffset animated:false];
        }
        
        _tableView.transform = tableTransform;
    });
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self _updateAccessDisabledContainerLayout:toInterfaceOrientation];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    _assetsGroup = assetsGroup;
}

- (void)reloadAssets:(bool)firstTime
{
    dispatchOnAssetsProcessingQueue(^
    {
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
        {            
            if (group != nil)
            {
                int groupType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                
                if (_groupUrl == nil)
                {
                    if (groupType == ALAssetsGroupSavedPhotos)
                    {
                        _assetsGroup = group;
                        [_assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                    }
                    else
                    {
                        NSURL *currentUrl = [group valueForProperty:ALAssetsGroupPropertyURL];
                        NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                        CGImageRef posterImage = group.posterImage;
                        UIImage *icon = posterImage == NULL ? nil : [[UIImage alloc] initWithCGImage:posterImage];
                        
                        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                        
                        NSMutableDictionary *groupDesc = [[NSMutableDictionary alloc] init];
                        if (name != nil)
                            [groupDesc setObject:name forKey:@"name"];
                        if (currentUrl != nil)
                            [groupDesc setObject:currentUrl forKey:@"url"];
                        if (icon != nil)
                            [groupDesc setObject:icon forKey:@"icon"];
                        int count = group.numberOfAssets;
                        [groupDesc setObject:[[NSString alloc] initWithFormat:@"(%d)", count] forKey:@"countString"];
                    }
                }
                else
                {
                    NSURL *currentUrl = [group valueForProperty:ALAssetsGroupPropertyURL];
                    if ([currentUrl isEqual:_groupUrl])
                    {
                        _assetsGroup = group;
                        [_assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                        
                        if (stop != NULL)
                            *stop = true;
                    }
                }
            }
            else
            {   
                [self reloadAssetsGroup:firstTime];
            }
        } failureBlock:^(__unused NSError *error)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self _showAccessDisabled];
            });
        }];
    });
}

- (void)reloadAssetsGroup:(bool)firstTime
{
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    dispatchOnAssetsProcessingQueue(^
    {
        if (_assetsGroup != nil)
        {
            int assetCount = [_assetsGroup numberOfAssets];
            TGLog(@"(%f) assetCount: %d", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0, assetCount);
            int enumerateCount = [TGViewController isWidescreen] ? 28 : 24;
            
            NSMutableArray *newAssets = [[NSMutableArray alloc] initWithCapacity:assetCount];
            
            if (firstTime)
            {
                for (int i = 0; i < assetCount; i++)
                    [newAssets addObject:[[TGImagePickerAsset alloc] init]];
            }
            
            [_assetsGroup enumerateAssetsWithOptions:firstTime ? NSEnumerationReverse : 0 usingBlock:^(ALAsset *result, NSUInteger index, __unused BOOL *stop)
            {
                if (result != nil && index != NSNotFound)
                {
                    TGImagePickerAsset *asset = [[TGImagePickerAsset alloc] initWithAsset:result];
                    
                    if (firstTime)
                    {
                        if (index < assetCount)
                            [newAssets replaceObjectAtIndex:index withObject:asset];
                        
                        if (index < assetCount - enumerateCount - 1)
                        {
                            if (stop != NULL)
                                *stop = true;
                        }
                    }
                    else
                        [newAssets addObject:asset];
                }
            }];
            
            TGLog(@"(%f) enumerated %d assets", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0, newAssets.count);
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if (_assetList == nil)
                {
                    _tableView.alpha = 0.0f;
                    [UIView animateWithDuration:0.25 animations:^
                    {
                        _tableView.alpha = 1.0f;
                    }];
                }
                
                _tableView.scrollEnabled = !firstTime;
                
                _assetList = newAssets;
                [_tableView reloadData];
                
                if (firstTime)
                {
                    UIEdgeInsets inset = _tableView.contentInset;
                    CGPoint contentOffset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height + inset.bottom);
                    if (contentOffset.y < -inset.top)
                        contentOffset.y = -inset.top;
                    [_tableView setContentOffset:contentOffset animated:false];
                }
                
                if (_selectedAssets.count != 0)
                    [self updateSelectedAssets];
            });
            
            if (firstTime)
            {
                [self reloadAssetsGroup:false];
            }
            else
                [self reloadAssetUrls:newAssets];
        }
        else
        {
        }
    });
}

- (void)reloadAssetUrls:(NSArray *)currentAssetList
{
    NSMutableArray *assetList = [[NSMutableArray alloc] initWithArray:currentAssetList];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        const int blockSize = 20;
        
        int count = assetList.count;
        for (int i = 0; i < count; i++)
        {
            if (i % blockSize == 0)
            {
                usleep(1 * 1000);
                
                if (_stopAllTasks)
                    return;
            }
            TGImagePickerAsset *asset = [[assetList objectAtIndex:i] copy];
            [asset assetUrl];
        }
        
        TGLog(@"Parsed assets in %f s", (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
    });
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return _assetList.count / _assetsInRow + (_assetList.count % _assetsInRow != 0 ? 1 : 0);

    return 0;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (indexPath.section == 0)
        return _lineHeight;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        int rowStartIndex = indexPath.row * _assetsInRow;
        if (rowStartIndex < _assetList.count)
        {
            static NSString *imageCellIdentifier = @"IC";
            TGImagePickerCell *imageCell = (TGImagePickerCell *)[tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
            if (imageCell == nil)
            {
                imageCell = [[TGImagePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageCellIdentifier selectionControls:!_avatarSelectionMode imageSize:TGIsRetina() ? 78.5f : 78.0f];
                imageCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [imageCell resetImages:_assetsInRow imageSize:_imageSize inset:_inset];
            
            int assetListCount = _assetList.count;
            for (int i = rowStartIndex; i < rowStartIndex + _assetsInRow && i < assetListCount; i++)
            {
                TGImagePickerAsset *asset = [_assetList objectAtIndex:i];
                UIImage *image = [asset forceLoadedThumbnailImage];
                bool isSelected = false;
                if (_selectedAssets.count != 0)
                {
                    id key = asset.assetUrl;
                    isSelected = key == nil ? false : [_selectedAssets containsObject:key];
                }
                [imageCell addAsset:asset isSelected:isSelected withImage:image];
            }
            
            if (_hideItemUrl != nil)
                [imageCell hideImage:_hideItemUrl hide:true];
            
            return imageCell;
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

#pragma mark -

- (void)assetsLibraryDidChange:(NSNotification *)__unused notification
{
    dispatchOnAssetsProcessingQueue(^
    {
        if (_assetsChangeDelayTimer != nil)
        {
            [_assetsChangeDelayTimer invalidate];
            _assetsChangeDelayTimer = nil;
        }
        ASHandle *actionHandle = _actionHandle;
        
        _assetsChangeDelayTimer = [[TGTimer alloc] initWithTimeout:1.0 repeat:false completion:^
        {
            TGImagePickerController *imagePicker = (TGImagePickerController *)actionHandle.delegate;
            if (imagePicker != nil)
                [imagePicker reloadAssets:false];
        } queue:assetsProcessingQueue()];
        [_assetsChangeDelayTimer start];
    });
}

- (void)assetsChangeDelayTimerEvent
{
    _assetsChangeDelayTimer = nil;
    
}

- (void)updateSelectedAssets
{
    if (_selectedAssets.count == 0)
        return;
    
    NSMutableSet *currentUrlsSet = [[NSMutableSet alloc] init];
    for (TGImagePickerAsset *asset in _assetList)
    {
        id key = asset.assetUrl;
        if (key != nil)
            [currentUrlsSet addObject:key];
    }
    
    [currentUrlsSet intersectSet:_selectedAssets];
    if (![currentUrlsSet isEqualToSet:_selectedAssets])
    {
        _selectedAssets = currentUrlsSet;
        
        [self updateSelectionInterface:false];
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
    _doneButton.enabled = _selectedAssets.count != 0;
    
    bool incremented = true;
    
    float badgeAlpha = 0.0f;
    if (_selectedAssets.count != 0)
    {
        badgeAlpha = 1.0f;
        
        if (_countLabel.text.length != 0)
            incremented = [_countLabel.text intValue] < _selectedAssets.count;
        
        _countLabel.text = [[NSString alloc] initWithFormat:@"%d", _selectedAssets.count];
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

- (void)assetSelected:(TGImagePickerAsset *)asset imageCell:(TGImagePickerCell *)imageCell
{
    if (asset.assetUrl == nil)
        return;
    
    bool isSelected = false;
    
    if ([_selectedAssets containsObject:asset.assetUrl])
    {
        isSelected = false;
        
        [_selectedAssets removeObject:asset.assetUrl];
    }
    else
    {
        isSelected = true;
        
        [_selectedAssets addObject:asset.assetUrl];
    }
    
    [imageCell animateImageSelected:asset.assetUrl isSelected:isSelected];
    
    [self updateSelectionInterface:true];
}

static const NSTimeInterval animationDuration = 0.25;

- (void)assetTapped:(TGImagePickerAsset *)asset imageCell:(TGImagePickerCell *)imageCell
{
    if (asset.assetUrl == nil)
        return;
    
    if (_avatarSelectionMode)
    {
        TGImageCropController *cropController = [[TGImageCropController alloc] initWithAsset:asset.asset];
        cropController.customCache = _customCache;
        cropController.watcherHandle = _actionHandle;
        [self.navigationController pushViewController:cropController animated:true];
    }
    else
    {
        NSMutableArray *pageList = [[NSMutableArray alloc] initWithCapacity:_assetList.count];
        int assetIndex = -1;
        
        int index = -1;
        for (TGImagePickerAsset *assetFromList in _assetList)
        {
            index++;
            
            TGAssetMediaItem *imageItem = [[TGAssetMediaItem alloc] initWithAsset:assetFromList];
            [pageList addObject:imageItem];
            if (assetFromList == asset)
            {
                assetIndex = index;
            }
        }
        
        if (assetIndex >= 0)
        {
            if (_pagingScrollView != nil)
            {
                [_pagingScrollView removeFromSuperview];
                _pagingScrollView.delegate = nil;
                _pagingScrollView = nil;
                [_pagingScrollViewContainer removeFromSuperview];
                _pagingScrollViewContainer = nil;
            }
            
            CGRect fromRect = [imageCell rectForAsset:asset.assetUrl];
            if (!CGRectIsEmpty(fromRect))
            {   
                TGImageViewPage *page = [[TGImageViewPage alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                page.referenceScreenSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
                page.customCache = _customCache;
                page.watcherHandle = _actionHandle;
                [page loadItem:[pageList objectAtIndex:assetIndex] placeholder:[[UIImage alloc] initWithCGImage:asset.asset.aspectRatioThumbnail] willAnimateAppear:true];
                page.clipsToBounds = true;
                [self.view insertSubview:page aboveSubview:_backgroundView];
                page.pageIndex = assetIndex;
                
                [TGViewController disableUserInteractionFor:0.21];
                
                fromRect = [imageCell convertRect:fromRect toView:self.view.window];
                
                UIView *showView = [imageCell hideImage:asset.assetUrl hide:true];
                
                [page animateAppearFromImage:[[pageList objectAtIndex:assetIndex] immediateThumbnail] fromView:self.view aboveView:_tableView transform:CGAffineTransformIdentity fromRect:fromRect toInterfaceOrientation:self.interfaceOrientation completion:^
                {
                    showView.hidden = false;
                    
                    [self actionStageActionRequested:@"hideImage" options:@{@"hide": @true, @"messageId": [(id<TGMediaItem>)[pageList objectAtIndex:assetIndex] itemId]}];
                    
                    _pagingScrollViewContainer = [[UIView alloc] initWithFrame:self.view.bounds];
                    _pagingScrollViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    
                    TGImagePanGestureRecognizer *panRecognizer = [[TGImagePanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPanned:)];
                    panRecognizer.delegate = self;
                    panRecognizer.cancelsTouchesInView = true;
                    panRecognizer.maximumNumberOfTouches = 1;
                    [_pagingScrollViewContainer addGestureRecognizer:panRecognizer];
                    
                    [self.view insertSubview:_pagingScrollViewContainer aboveSubview:_backgroundView];
                    
                    float pageGap = 40;
                    _pagingScrollView = [[TGImagePagingScrollView alloc] initWithFrame:CGRectMake(-pageGap / 2, 0, self.view.bounds.size.width + pageGap, self.view.bounds.size.height)];
                    _pagingScrollView.customCache = _customCache;
                    _pagingScrollView.pageGap = pageGap;
                    _pagingScrollView.delegate = self;
                    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    _pagingScrollView.directionalLockEnabled = false;
                    _pagingScrollView.alwaysBounceVertical = false;
                    _pagingScrollView.actionHandle = _actionHandle;
                    _pagingScrollView.pagingDelegate = self;
                    [_pagingScrollViewContainer addSubview:_pagingScrollView];
                    
                    [_pagingScrollView setPageList:pageList];
                    [_pagingScrollView resetOffsetForIndex:assetIndex >= 0 ? assetIndex : 0];
                    
                    [_pagingScrollView setInitialPageState:page];
                    
                    _backgroundView.alpha = 1.0f;
                    _backgroundView.hidden = false;
                    
                    _cellCheckButton.alpha = 0.0f;
                    _cellCheckButton.hidden = true;
                } keepAspect:true duration:animationDuration];
                
                _cellCheckButton.alpha = 1.0f;
                _cellCheckButton.hidden = false;
                
                _checkButton.alpha = 0.0f;
                _checkButton.hidden = false;
                [_checkButton setChecked:[_selectedAssets containsObject:asset.assetUrl] animated:false];
                [_cellCheckButton setChecked:[_selectedAssets containsObject:asset.assetUrl] animated:false];
                
                CGRect fromRectInViewSpace = [self.view convertRect:fromRect fromView:self.view.window];
                
                _cellCheckButton.frame = CGRectMake(fromRectInViewSpace.origin.x + fromRectInViewSpace.size.width - 32, fromRectInViewSpace.origin.y - TGRetinaPixel, 33, 33);
                
                [UIView animateWithDuration:animationDuration - 0.05 animations:^
                {
                    _cellCheckButton.alpha = 0.0f;
                    _checkButton.alpha = 1.0f;
                }];
                
                [UIView animateWithDuration:animationDuration animations:^
                {
                    _darkPanelView.alpha = 1.0f;
                    if (![self inPopover] && ![self inFormSheet])
                    {
                        [TGHacks setApplicationStatusBarAlpha:0.0f];
                        [self setStatusBarBackgroundAlpha:0.0f];
                    }
                    
                    self.navigationController.navigationBar.alpha = 0.0f;
                    
                    //_tableView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
                } completion:^(__unused BOOL finished)
                {
                    [self.navigationController setNavigationBarHidden:true];
                }];
                //_tableView.clipsToBounds = false;
            }
        }
    }
}

#pragma mark -

- (void)dismissPagingScrollView:(float)swipeVelocity
{
    TGImageViewPage *page = [_pagingScrollView pageForIndex:[_pagingScrollView currentPageIndex]];
    NSString *assetUrl = ((TGAssetMediaItem *)page.imageItem).asset.assetUrl;
    
    _tableView.transform = CGAffineTransformIdentity;
    
    CGRect targetRect = CGRectZero;
    UITableViewCell *targetCell = nil;
    
    if (assetUrl != nil)
    {
        for (UITableViewCell *cell in _tableView.visibleCells)
        {
            if ([cell isKindOfClass:[TGImagePickerCell class]])
            {
                CGRect rect = [(TGImagePickerCell *)cell rectForAsset:assetUrl];
                if (!CGRectIsEmpty(rect))
                {
                    targetRect = [cell convertRect:rect toView:self.view.window];
                    [(TGImagePickerCell *)cell hideImage:assetUrl hide:true];
                    targetCell = cell;
                    
                    break;
                }
            }
        }
    }
    
    if (CGRectIsEmpty(targetRect))
    {
        [(TGImagePickerCell *)targetCell hideImage:assetUrl hide:false];
        
        [UIView animateWithDuration:animationDuration animations:^
        {
            _pagingScrollView.alpha = 0.0f;
            _backgroundView.alpha = 0.0f;
            
            _checkButton.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [_pagingScrollView removeFromSuperview];
            _pagingScrollView.delegate = nil;
            _pagingScrollView = nil;
            _checkButton.hidden = true;
            
            [_pagingScrollViewContainer removeFromSuperview];
            _pagingScrollViewContainer = nil;
            
            _backgroundView.alpha = 1.0f;
            _backgroundView.hidden = true;
        }];
        
        [page animateDisappearToImage:nil toView:self.view aboveView:_tableView transform:CGAffineTransformIdentity toRect:targetRect toContainerImage:nil toInterfaceOrientation:self.interfaceOrientation keepAspect:true backgroundAlpha:_backgroundView.alpha swipeVelocity:swipeVelocity completion:^
         {
             [_pagingScrollView removeFromSuperview];
             _pagingScrollView.delegate = nil;
             _pagingScrollView = nil;
             
             [_pagingScrollViewContainer removeFromSuperview];
             _pagingScrollViewContainer = nil;
             
             [(TGImagePickerCell *)targetCell hideImage:assetUrl hide:false];
             
             _checkButton.alpha = 0.0f;
             _checkButton.hidden = true;
         } duration:animationDuration];
    }
    else
    {
        UIImage *thumbnail = [[UIImage alloc] initWithCGImage:((TGAssetMediaItem *)page.imageItem).asset.asset.aspectRatioThumbnail];
        [page animateDisappearToImage:thumbnail toView:self.view aboveView:_tableView transform:CGAffineTransformIdentity toRect:targetRect toContainerImage:thumbnail toInterfaceOrientation:self.interfaceOrientation keepAspect:true backgroundAlpha:_backgroundView.alpha swipeVelocity:swipeVelocity completion:^
        {
            [_pagingScrollView removeFromSuperview];
            _pagingScrollView.delegate = nil;
            _pagingScrollView = nil;
            
            [_pagingScrollViewContainer removeFromSuperview];
            _pagingScrollViewContainer = nil;
            
            [(TGImagePickerCell *)targetCell hideImage:assetUrl hide:false];
            
            _checkButton.alpha = 0.0f;
            _checkButton.hidden = true;
            
            _cellCheckButton.alpha = 0.0f;
            _cellCheckButton.hidden = true;
        } duration:animationDuration];
        
        _backgroundView.alpha = 1.0f;
        _backgroundView.hidden = true;
        
        _checkButton.alpha = 1.0f;
        _checkButton.hidden = false;
        CGRect toRectInViewSpace = [self.view convertRect:targetRect fromView:self.view.window];
        
        _cellCheckButton.hidden = false;
        _cellCheckButton.alpha = 0.0f;
        _cellCheckButton.frame = CGRectMake(toRectInViewSpace.origin.x + toRectInViewSpace.size.width - 32, toRectInViewSpace.origin.y - TGRetinaPixel, 33, 33);
        
        [UIView animateWithDuration:animationDuration - 0.05 delay:0.12 options:0 animations:^
        {
            _checkButton.alpha = 0.0f;
            _cellCheckButton.alpha = 1.0f;
        } completion:nil];
    }
    
    _closeButtonItem.customView.hidden = true;
    
    //_tableView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
    [self.navigationController setNavigationBarHidden:false];
    self.navigationController.navigationBar.alpha = 0.0f;
    [UIView animateWithDuration:animationDuration animations:^
    {
        if (![self inPopover] && ![self inFormSheet])
        {
            [TGHacks setApplicationStatusBarAlpha:1.0f];
            [self setStatusBarBackgroundAlpha:1.0f];
        }
        self.navigationController.navigationBar.alpha = 1.0f;
        _darkPanelView.alpha = 0.0f;
        //_tableView.transform = CGAffineTransformIdentity;
    } completion:^(__unused BOOL finished)
    {
        //_tableView.clipsToBounds = true;
    }];
    
    _hideItemUrl = nil;
}

- (void)cancelButtonPressed
{
    if (_pagingScrollView.alpha > FLT_EPSILON)
    {
        [self dismissPagingScrollView:0.0f];
    }
    else
    {
        _stopAllTasks = true;
        
        id<TGImagePickerControllerDelegate> delegate = _delegate;
        if (delegate != nil && [delegate respondsToSelector:@selector(imagePickerController:didFinishPickingWithAssets:)])
            [delegate imagePickerController:self didFinishPickingWithAssets:nil];
    }
}

- (void)doneButtonPressed
{
    _stopAllTasks = true;
    
    if (_selectedAssets.count == 0 && _pagingScrollView.alpha > FLT_EPSILON)
    {
        TGImageViewPage *page = [_pagingScrollView pageForIndex:[_pagingScrollView currentPageIndex]];
        id key = ((TGAssetMediaItem *)page.imageItem).asset.assetUrl;
        if (key != nil)
            [_selectedAssets addObject:key];
    }
    
    if (_selectedAssets.count != 0)
    {
        int assetsToFind = _selectedAssets.count;
        NSMutableArray *assets = [[NSMutableArray alloc] init];
        for (TGImagePickerAsset *asset in _assetList)
        {
            id key = asset.assetUrl;
            if (key != nil && [_selectedAssets containsObject:key])
            {
                [assets addObject:asset];
                assetsToFind--;
            }
            
            if (assetsToFind <= 0)
                break;
        }
        
        id<TGImagePickerControllerDelegate> delegate = _delegate;
        if (delegate != nil && [delegate respondsToSelector:@selector(imagePickerController:didFinishPickingWithAssets:)])
            [delegate imagePickerController:self didFinishPickingWithAssets:assets];
    }
}

- (void)checkButtonPressed
{
    TGImageViewPage *page = [_pagingScrollView pageForIndex:[_pagingScrollView currentPageIndex]];
    id key = ((TGAssetMediaItem *)page.imageItem).asset.assetUrl;
    if (key != nil)
    {
        bool isSelected = false;
        
        if ([_selectedAssets containsObject:key])
        {
            isSelected = false;
            
            [_selectedAssets removeObject:key];
        }
        else
        {
            isSelected = true;
            
            [_selectedAssets addObject:key];
        }
        
        for (UITableViewCell *cell in _tableView.visibleCells)
        {
            if ([cell isKindOfClass:[TGImagePickerCell class]])
            {
                [(TGImagePickerCell *)cell updateImageSelected:key isSelected:isSelected];
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
                [self.view insertSubview:containerView belowSubview:_darkPanelView];
                
                UIImageView *imageView = [[UIImageView alloc] initWithImage:currentImage];
                imageView.frame = [page currentImageFrameInView:self.view];
                [containerView insertSubview:imageView belowSubview:_checkButton];
                
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

- (void)tablePanRecognized:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _checkGestureStartPoint = [recognizer locationInView:_tableView];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:_tableView];
        CGPoint location = [recognizer locationInView:_tableView];
        
        bool processAdditionalLocation = false;
        CGPoint additionalLocation = CGPointZero;
        
        if (!_processingCheckGesture && !_failCheckGesture)
        {
            if (ABS(translation.y) >= 5)
            {
                _failCheckGesture = true;
            }
            else if (ABS(translation.x) >= 4)
            {
                for (id cell in _tableView.visibleCells)
                {
                    if ([cell isKindOfClass:[TGImagePickerCell class]])
                    {
                        TGImagePickerCell *imageCell = cell;
                        
                        if (CGRectContainsPoint(imageCell.frame, _checkGestureStartPoint))
                        {
                            NSString *assetUrl = [imageCell assetUrlAtPoint:CGPointMake(_checkGestureStartPoint.x - imageCell.frame.origin.x, _checkGestureStartPoint.y - imageCell.frame.origin.y)];
                            if (assetUrl != nil)
                            {
                                _tableView.scrollEnabled = false;
                                
                                _processingCheckGesture = true;
                                _checkGestureChecks = ![_selectedAssets containsObject:assetUrl];
                                
                                processAdditionalLocation = true;
                                additionalLocation = location;
                                location = _checkGestureStartPoint;
                                
                                break;
                            }
                        }
                    }
                }
            }
        }
        
        if (_processingCheckGesture)
        {
            for (int i = 0; i < (processAdditionalLocation ? 2 : 1); i++)
            {
                CGPoint currentLocation = i == 0 ? location : additionalLocation;
                
                for (id cell in _tableView.visibleCells)
                {
                    if ([cell isKindOfClass:[TGImagePickerCell class]])
                    {
                        TGImagePickerCell *imageCell = cell;
                        if (CGRectContainsPoint(imageCell.frame, currentLocation))
                        {
                            NSString *assetUrl = [imageCell assetUrlAtPoint:CGPointMake(currentLocation.x - imageCell.frame.origin.x, currentLocation.y - imageCell.frame.origin.y)];
                            if (assetUrl != nil && [_selectedAssets containsObject:assetUrl] != _checkGestureChecks)
                            {
                                if (_checkGestureChecks)
                                    [_selectedAssets addObject:assetUrl];
                                else
                                    [_selectedAssets removeObject:assetUrl];
                                
                                [imageCell animateImageSelected:assetUrl isSelected:_checkGestureChecks];
                                
                                [self updateSelectionInterface:true];
                            }
                            
                            break;
                        }
                    }
                }
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        _processingCheckGesture = false;
        _tableView.scrollEnabled = true;
        _failCheckGesture = false;
    }
}

- (void)scrollViewCurrentPageChanged:(int)__unused currentPage imageItem:(id<TGMediaItem>)imageItem
{
    bool isChecked = [_selectedAssets containsObject:((TGAssetMediaItem *)imageItem).asset.assetUrl];
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    return gestureRecognizer == _checkGestureRecognizer;
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

- (float)controlsAlpha
{
    return 1.0f;
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"hideImage"])
    {
        bool hide = [[options objectForKey:@"hide"] boolValue];
        
        if (_hideItemUrl != nil)
        {
            for (UITableViewCell *cell in _tableView.visibleCells)
            {
                if ([cell isKindOfClass:[TGImagePickerCell class]])
                {
                    TGImagePickerCell *imagePickerCell = (TGImagePickerCell *)cell;
                    [imagePickerCell hideImage:_hideItemUrl hide:false];
                }
            }
        }
        
        NSString *itemUrl = [options objectForKey:@"messageId"];
        
        if (itemUrl != nil)
        {
            for (UITableViewCell *cell in _tableView.visibleCells)
            {
                if ([cell isKindOfClass:[TGImagePickerCell class]])
                {
                    TGImagePickerCell *imagePickerCell = (TGImagePickerCell *)cell;
                    [imagePickerCell hideImage:itemUrl hide:hide];
                }
            }
            
            _hideItemUrl = hide ? itemUrl : nil;
        }
    }
    else if ([action isEqualToString:@"pageTapped"])
    {
        [self checkButtonPressed];
    }
    else if ([action isEqualToString:@"imageCropResult"])
    {
        id<TGImagePickerControllerDelegate> delegate = _delegate;
        if (delegate != nil && [delegate respondsToSelector:@selector(imagePickerController:didFinishPickingWithAssets:)])
            [delegate imagePickerController:self didFinishPickingWithAssets:[[NSArray alloc] initWithObjects:options, nil]];
    }
}

@end
