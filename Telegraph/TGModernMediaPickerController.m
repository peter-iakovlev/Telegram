#import "TGModernMediaPickerController.h"

#import "TGAppDelegate.h"

#import "TGFileUtils.h"
#import "TGImageUtils.h"
#import "UICollectionView+Utils.h"

#import "TGModernButtonView.h"
#import "TGFont.h"

#import "TGMediaPickerAssetsLibrary.h"
#import "TGMediaPickerAsset+TGEditablePhotoItem.h"
#import "TGMediaPickerAssetsGroup.h"
#import "TGAssetImageManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

#import <MTProtoKit/MTTime.h>
#import <SSignalKit/SSignalKit.h>

#import "TGAssetImageView.h"
#import "TGMediaPickerItem.h"
#import "TGModernMediaListEditableItem.h"
#import "TGMediaPickerPhotoItemView.h"
#import "TGMediaPickerVideoItemView.h"

#import "TGModernMediaCollectionView.h"
#import "TGModernMediaListLayout.h"
#import "TGModernMediaListItem.h"
#import "TGModernMediaListItemView.h"

#import "TGModernGalleryController.h"
#import "TGMediaPickerGallerySelectedItemsModel.h"
#import "TGMediaPickerGalleryModel.h"
#import "TGMediaPickerGalleryPhotoItem.h"
#import "TGMediaPickerGalleryVideoItem.h"
#import "TGMediaPickerGalleryVideoItemView.h"
#import "TGOverlayControllerWindow.h"

#import "PGPhotoEditorValues.h"
#import "TGVideoEditAdjustments.h"
#import "TGMediaEditingContext.h"
#import "TGPhotoEditorController.h"

#import "TGVideoConverter.h"
#import "TGImageDownloadActor.h"

#import "TGLegacyMediaPickerTipView.h"

@interface TGModernMediaPickerController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    TGModernMediaPickerControllerIntent _intent;
    
    CGSize _normalItemSize;
    CGSize _wideItemSize;
    CGFloat _widescreenWidth;
    CGFloat _normalLineSpacing;
    CGFloat _wideLineSpacing;
    UIEdgeInsets _normalEdgeInsets;
    UIEdgeInsets _wideEdgeInsets;
    
    UIView *_toolbarView;
    UIImageView *_toolbarLogoView;
    TGModernButton *_cancelButton;
    TGModernButton *_doneButton;
    UIImageView *_countBadge;
    UILabel *_countLabel;
    
    UIPanGestureRecognizer *_panGestureRecognizer;
    CGPoint _checkGestureStartPoint;
    bool _processingCheckGesture;
    bool _failCheckGesture;
    bool _checkGestureChecks;
    
    UICollectionView *_collectionView;
    CGFloat _collectionViewWidth;
    TGModernMediaListLayout *_collectionLayout;
    UIView *_collectionContainer;
    bool _loadItemsSynchronously;
    CGRect _previousPreheatRect;
    
    id<TGModernMediaListItem> _hiddenItem;
    
    TGMediaPickerAssetsLibrary *_assetsLibrary;
    TGMediaPickerAssetsGroup *_assetsGroup;
    NSArray *_items;
    NSArray *_selectedItems;
    
    bool (^_isItemSelected)(TGMediaPickerItem *);
    bool (^_isItemHidden)(TGMediaPickerItem *);
    void (^_changeItemSelection)(id<TGModernMediaListItem>, bool);
    void (^_changeGalleryItemSelection)(id<TGModernGalleryItem>, TGMediaPickerGallerySelectedItemsModel *);
    
    UIView *_accessDeniedContainer;
    UIView *_emptyGroupContainer;
    
    __weak TGMediaPickerGalleryModel *_galleryModel;
    
    TGMediaEditingContext *_editingContext;
    
    id<TGMediaEditAdjustments> (^_fetchAdjustments)(TGMediaPickerAsset *);
    NSString *(^_fetchCaption)(TGMediaPickerAsset *);
    UIImage *(^_fetchThumbnailImage)(TGMediaPickerAsset *);
    UIImage *(^_fetchScreenImage)(TGMediaPickerAsset *);
    
    TGVideoConverter *_videoConverter;
    
    bool _appeared;
    MTAbsoluteTime _appearanceTime;
    dispatch_semaphore_t _waitSemaphore;
    bool _usedSemaphore;
    
    void (^_recycleItemContentView)(TGModernMediaListItemContentView *);
    NSMutableArray *_storedItemContentViews;
    NSMutableDictionary *_reusableItemContentViewsByIdentifier;
}

@end

@implementation TGModernMediaPickerController

- (instancetype)init
{
    return [self initWithAssetsGroup:nil intent:TGModernMediaPickerControllerDefaultIntent];
}

- (instancetype)initWithAssetsGroup:(TGMediaPickerAssetsGroup *)assetsGroup intent:(TGModernMediaPickerControllerIntent)intent
{
    self = [super init];
    if (self != nil)
    {
        _intent = intent;
        
        self.title = assetsGroup ? assetsGroup.title : @"Camera Roll";
        
        _assetsGroup = assetsGroup;
        
        __weak TGModernMediaPickerController *weakSelf = self;
        
        _reusableItemContentViewsByIdentifier = [[NSMutableDictionary alloc] init];
        _storedItemContentViews = [[NSMutableArray alloc] init];
        
        _recycleItemContentView = ^(TGModernMediaListItemContentView *itemContentView)
        {
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
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
        
        if (_assetsGroup.subtype == TGMediaPickerAssetsGroupSubtypePanoramas)
        {
            _normalLineSpacing = 10.0f;
            _wideLineSpacing = 10.0f;
            _normalEdgeInsets = UIEdgeInsetsMake(_normalEdgeInsets.top, 0, _normalEdgeInsets.bottom, 0);
            _wideEdgeInsets = UIEdgeInsetsMake(_wideEdgeInsets.top, 0, _wideEdgeInsets.bottom, 0);
        }

        _waitSemaphore = dispatch_semaphore_create(0);
        
        _editingContext = [[TGMediaEditingContext alloc] init];
        
        _changeItemSelection = ^(TGMediaPickerItem *item, bool updateInterface)
        {
            if (item == nil)
                return;
            
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf toggleItemSelected:item updateInterface:updateInterface];
        };
        
        _isItemSelected = ^bool (TGMediaPickerItem *item)
        {
            if (item == nil)
                return false;
            
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [[strongSelf selectedItems] containsObject:item];
            return false;
        };
        
        _isItemHidden = ^bool (TGMediaPickerItem *item)
        {
            if (item == nil)
                return false;
            
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [item isEqual:strongSelf->_hiddenItem];
            return false;
        };
        
        _changeGalleryItemSelection = ^(TGMediaPickerGalleryItem *item, TGMediaPickerGallerySelectedItemsModel *gallerySelectedItems)
        {
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGMediaPickerItem *listItem = [strongSelf listItemForAsset:[item asset]];
                
                if (listItem != nil)
                {
                    bool added = [strongSelf toggleItemSelected:listItem updateInterface:true];
                    
                    if (gallerySelectedItems != nil)
                    {
                        if (added)
                            [gallerySelectedItems addSelectedItem:listItem];
                        else
                            [gallerySelectedItems removeSelectedItem:listItem];
                    }
                }
            }
        };
        
        _fetchAdjustments = ^id<TGMediaEditAdjustments> (id<TGEditablePhotoItem> item)
        {
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_editingContext adjustmentsForItemId:item.uniqueId];
            return nil;
        };
        
        _fetchThumbnailImage = ^UIImage *(id<TGEditablePhotoItem> item)
        {
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_editingContext thumbnailImageForItemId:item.uniqueId];
            return nil;
        };
        
        _fetchCaption = ^NSString *(id<TGEditablePhotoItem> item)
        {
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_editingContext captionForItemId:item.uniqueId];
            return nil;
        };
        
        _fetchScreenImage = ^UIImage *(id<TGEditablePhotoItem> item)
        {
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_editingContext imageForItemId:item.uniqueId];
            return nil;
        };
        
        _assetsLibrary = [[TGMediaPickerAssetsLibrary alloc] initForAssetType:[TGModernMediaPickerController assetTypeForIntent:intent]];
        _assetsLibrary.libraryChanged = ^
        {
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf _handleAssetsLibraryChanged];
        };
    }
    return self;
}

- (void)dealloc
{
}

- (void)cancelButtonPressed
{
    if (self.dismiss != nil)
        self.dismiss();
}

- (void)doneButtonPressed
{
    [self completeWithItem:nil];
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _collectionContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    _collectionContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_collectionContainer];
    
    CGSize frameSize = self.view.bounds.size;
    
    _collectionLayout = [[TGModernMediaListLayout alloc] init];
    _collectionView = [[TGModernMediaCollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height) collectionViewLayout:_collectionLayout];
    _collectionView.alwaysBounceVertical = true;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delaysContentTouches = true;
    _collectionView.canCancelContentTouches = true;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionContainer addSubview:_collectionView];
    
    [_collectionView registerClass:[TGModernMediaListItemView class] forCellWithReuseIdentifier:@"TGModernMediaListItemView"];
    
    self.scrollViewsForAutomaticInsetsAdjustment = @[_collectionView];
    
    _toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 44.0f, self.view.frame.size.width, 44.0f)];
    _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _toolbarView.backgroundColor = UIColorRGBA(0xf7f7f7, 1.0f);
    UIView *stripeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _toolbarView.frame.size.width, TGIsRetina() ? 0.5f : 1.0f)];
    stripeView.backgroundColor = UIColorRGB(0xb2b2b2);
    stripeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_toolbarView addSubview:stripeView];
    [self.view addSubview:_toolbarView];
    
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
    [_toolbarView addSubview:_cancelButton];

    if (_intent == TGModernMediaPickerControllerSendPhotoIntent || _intent == TGModernMediaPickerControllerSendFileIntent)
    {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGestureRecognizer.delegate = self;
        [_collectionView addGestureRecognizer:_panGestureRecognizer];
    }

    if (_intent == TGModernMediaPickerControllerSendPhotoIntent || _intent == TGModernMediaPickerControllerSendVideoIntent || _intent == TGModernMediaPickerControllerSendFileIntent)
    {
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
    }

    self.explicitTableInset = UIEdgeInsetsMake(0, 0.0f, 44.0f, 0.0f);
    self.explicitScrollIndicatorInset = self.explicitTableInset;
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_appeared)
    {
        [self _layoutCollectionViewForSize:self.view.bounds.size];
        return;
    }
    
    CGSize frameSize = self.view.bounds.size;
    CGRect collectionViewFrame = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    _collectionViewWidth = collectionViewFrame.size.width;
    _collectionView.frame = collectionViewFrame;
    
    _appearanceTime = MTAbsoluteSystemTime();
    _appeared = true;
    
    dispatch_block_t reloadBlock = [self reloadData];
    
    if (_waitSemaphore != nil && !_usedSemaphore)
    {
        _usedSemaphore = true;
        if (dispatch_semaphore_wait(_waitSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC))))
            TGLog(@"Media list loading took longer than expected");
        
        reloadBlock();
    }
    
    if (_intent == TGModernMediaPickerControllerSendFileIntent && self.shouldShowFileTipIfNeeded && iosMajorVersion() >= 7)
    {
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"didShowDocumentPickerTip_v2"] boolValue])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@true forKey:@"didShowDocumentPickerTip_v2"];
            
            TGLegacyMediaPickerTipView *tipView = [[TGLegacyMediaPickerTipView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
            tipView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.navigationController.view addSubview:tipView];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self _updateAssetsImageCaching];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    TGMediaPickerGalleryModel *galleryModel = _galleryModel;
    if (galleryModel != nil)
        galleryModel.dismiss(false, false);
}

- (bool)shouldAdjustScrollViewInsetsForInversedLayout
{
    return true;
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (void)_layoutCollectionViewForSize:(CGSize)size
{
    CGSize screenSize = size;
    
    CGAffineTransform tableTransform = _collectionView.transform;
    _collectionView.transform = CGAffineTransformIdentity;
    
    CGFloat lastInverseOffset = MAX(0, _collectionView.contentSize.height - (_collectionView.contentOffset.y + _collectionView.frame.size.height - _collectionView.contentInset.bottom));
    CGFloat lastOffset = _collectionView.contentOffset.y;
    
    CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _collectionViewWidth = tableFrame.size.width;
    _collectionView.frame = tableFrame;
    
    if (lastInverseOffset < 2)
    {
        [self _adjustContentOffsetToBottom:TGAppDelegateInstance.rootController.interfaceOrientation];
    }
    else if (lastOffset < -_collectionView.contentInset.top + 2)
    {
        UIEdgeInsets contentInset = [self controllerInsetForInterfaceOrientation:TGAppDelegateInstance.rootController.interfaceOrientation];
        
        CGPoint contentOffset = CGPointMake(0, -contentInset.top);
        [_collectionView setContentOffset:contentOffset animated:false];
    }
    
    _collectionView.transform = tableTransform;
    
    [_collectionLayout invalidateLayout];
    [_collectionView layoutSubviews];
}

- (void)layoutControllerForSize:(CGSize)size duration:(NSTimeInterval)duration {
    [super layoutControllerForSize:size duration:duration];

    if (duration > DBL_EPSILON) {
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
    }

    [self _layoutCollectionViewForSize:size];
    
    [self _updateContainerLayout:_accessDeniedContainer forSize:size];
    [self _updateContainerLayout:_emptyGroupContainer forSize:size];
    
    TGMediaPickerGalleryModel *galleryModel = _galleryModel;
    TGModernGalleryController *galleryController = galleryModel.controller;
    if (galleryModel != nil && galleryController.shouldAutorotate)
        [galleryModel.interfaceView willRotateWithDuration:duration];
}

- (void)_adjustContentOffsetToBottom:(UIInterfaceOrientation)orientation
{
    UIEdgeInsets sectionInsets = [self collectionView:_collectionView layout:_collectionLayout insetForSectionAtIndex:0];
    
    CGFloat itemSpacing = [self collectionView:_collectionView layout:_collectionLayout minimumInteritemSpacingForSectionAtIndex:0];
    CGFloat lineSpacing = [self collectionView:_collectionView layout:_collectionLayout minimumLineSpacingForSectionAtIndex:0];
    
    CGFloat additionalRowWidth = sectionInsets.left + sectionInsets.right;
    CGFloat currentRowWidth = 0.0f;
    CGFloat maxRowWidth = _collectionView.frame.size.width;
    
    CGSize itemSize = CGSizeZero;
    if ([self collectionView:_collectionView numberOfItemsInSection:0] != 0)
    {
        itemSize = [self collectionView:_collectionView layout:_collectionLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    
    CGFloat contentSize = 0.0f;
    
    for (int i = (int)([self collectionView:_collectionView numberOfItemsInSection:0]) - 1; i >= 0; i--)
    {
        if (currentRowWidth + itemSize.width + (currentRowWidth > FLT_EPSILON ? itemSpacing : 0.0f) + additionalRowWidth > maxRowWidth)
        {
            if (contentSize > FLT_EPSILON)
                contentSize += lineSpacing;
            contentSize += itemSize.height;
            
            currentRowWidth = 0.0f;
        }
        
        if (currentRowWidth > FLT_EPSILON)
            currentRowWidth += itemSpacing;
        currentRowWidth += itemSize.width;
    }
    
    if (currentRowWidth > FLT_EPSILON)
    {
        if (contentSize > FLT_EPSILON)
            contentSize += lineSpacing;
        contentSize += itemSize.height;
    }
    
    contentSize += sectionInsets.top + sectionInsets.bottom;
    
    UIEdgeInsets contentInset = [self controllerInsetForInterfaceOrientation:orientation];
    
    CGPoint contentOffset = CGPointMake(0, contentSize - _collectionView.frame.size.height + contentInset.bottom);
    if (contentOffset.y < -contentInset.top)
        contentOffset.y = -contentInset.top;
    [_collectionView setContentOffset:contentOffset animated:false];
}

#pragma mark - Collection View Data Source & Delegate

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    CGSize size = (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON) ? _wideItemSize : _normalItemSize;
    if (_assetsGroup.subtype == TGMediaPickerAssetsGroupSubtypePanoramas)
    {
        size.width = _collectionViewWidth;
        if (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON)
            size.width -= (_wideEdgeInsets.left + _wideEdgeInsets.right);
        else
            size.width -= (_normalEdgeInsets.left + _normalEdgeInsets.right);
    }

    return size;
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
    return _items.count;
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
        id<TGModernMediaListItem> item = _items[index];
        
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
        
        return itemView;
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGMediaPickerItem *item = _items[indexPath.row];

    __block UIImage *thumbnailImage = nil;
    
    if (![TGAssetImageManager usesLegacyAssetsLibrary])
    {
        TGModernMediaListItemView *listItemView = (TGModernMediaListItemView *)[_collectionView cellForItemAtIndexPath:indexPath];
        
        if ([listItemView.itemContentView isKindOfClass:[TGMediaPickerAssetItemView class]])
        {
            TGMediaPickerAssetItemView *itemContentView = (TGMediaPickerAssetItemView *)listItemView.itemContentView;
            thumbnailImage = itemContentView.imageView.image;
        }
    }
    else
    {
        [TGAssetImageManager requestImageWithAsset:item.asset imageType:TGAssetImageTypeAspectRatioThumbnail size:CGSizeZero completionBlock:^(UIImage *image, __unused NSError *error)
        {
            thumbnailImage = image;
        }];
    }
    
    if (_intent == TGModernMediaPickerControllerSetProfilePhotoIntent)
    {
        __weak TGModernMediaPickerController *weakSelf = self;
        TGPhotoEditorController *controller = [[TGPhotoEditorController alloc] initWithItem:item.asset intent:TGPhotoEditorControllerAvatarIntent adjustments:nil caption:nil screenImage:thumbnailImage availableTabs:[TGPhotoEditorController defaultTabsForAvatarIntent] selectedTab:TGPhotoEditorCropTab];
        controller.finishedEditing = ^(PGPhotoEditorValues *editorValues, UIImage *resultImage, __unused UIImage *thumbnailImage, __unused bool noChanges)
        {
            if (noChanges)
                return;
            
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (strongSelf.avatarCreated != nil)
                strongSelf.avatarCreated(resultImage);
            
            if ([editorValues toolsApplied])
                [[TGMediaPickerAssetsLibrary sharedLibrary] saveAssetWithImage:resultImage completionBlock:nil];
        };
        [self.navigationController pushViewController:controller animated:true];
    }
    else
    {
        [self presentGalleryControllerForItem:item withThumbnailImage:thumbnailImage];
    }
}

- (dispatch_block_t)reloadData
{
    NSMutableArray *items = [NSMutableArray array];
    
    dispatch_block_t returnBlock = nil;
    
    void (^reloadBlock)(void) = ^
    {
        self.title = _assetsGroup ? _assetsGroup.title : TGLocalized(@"MediaPicker.CameraRoll");
        
        bool firstTime = (_items == nil);
        
        if (_items != items)
        {
            _items = items;
            [_collectionView reloadData];
        }
        
        [_collectionLayout invalidateLayout];
        [_collectionView layoutSubviews];
        
        if (!firstTime)
            [self actualizeSelectedItems];
        else
            [self _adjustContentOffsetToBottom:self.interfaceOrientation];
    };
    
    if (_items == nil)
        returnBlock = reloadBlock;
    
    [_assetsLibrary fetchAssetsOfAssetsGroup:_assetsGroup reversed:false withEnumerationBlock:^(TGMediaPickerAsset *asset, TGMediaPickerAuthorizationStatus status, __unused NSError *error)
    {
        if (asset != nil)
        {
            asset.fetchEditorValues = _fetchAdjustments;
            asset.fetchCaption = _fetchCaption;
            asset.fetchThumbnailImage = _fetchThumbnailImage;
            asset.fetchScreenImage = _fetchScreenImage;
            
            void(^itemSelected)(id<TGModernMediaListItem>, bool) = nil;
            bool(^isItemSelected)(id<TGModernMediaListItem>) = nil;
            if (_intent == TGModernMediaPickerControllerSendPhotoIntent || _intent == TGModernMediaPickerControllerSendVideoIntent || _intent == TGModernMediaPickerControllerSendFileIntent)
            {
                itemSelected = _changeItemSelection;
                isItemSelected = _isItemSelected;
            }
            
            [items addObject:[[TGMediaPickerItem alloc] initWithAsset:asset
                                                         itemSelected:itemSelected
                                                       isItemSelected:isItemSelected
                                                         isItemHidden:_isItemHidden]];
        }
        else if (status != TGMediaPickerAuthorizationStatusAuthorized && status != TGMediaPickerAuthorizationStatusNotDetermined)
        {
            TGDispatchOnMainThread(^
            {
                [self _showAccessDisabled];
            });
        }
        else
        {
            if (_items != nil)
                TGDispatchOnMainThread(reloadBlock);
            
            if (_waitSemaphore != nil)
                dispatch_semaphore_signal(_waitSemaphore);
        }
    }];
    
    return returnBlock;
}

- (void)_handleAssetsLibraryChanged
{
    [self _resetAssetsImageCaching];
    [self reloadData];
}

#pragma mark - Asset Images Caching

- (void)scrollViewDidScroll:(UIScrollView *)__unused scrollView
{
    [self _updateAssetsImageCaching];
}

- (void)_updateAssetsImageCaching
{
    bool isViewVisible = self.isViewLoaded && self.view.window != nil;
    if (!isViewVisible)
        return;
    
    CGRect preheatRect = _collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(_previousPreheatRect));
    if (delta > CGRectGetHeight(_collectionView.bounds) / 3.0f)
    {
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [_collectionView computeDifferenceBetweenRect:_previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect)
        {
            NSArray *indexPaths = [_collectionView indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect)
        {
            NSArray *indexPaths = [_collectionView indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self _assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self _assetsAtIndexPaths:removedIndexPaths];
        
        [TGAssetImageManager startCachingImagesForAssets:assetsToStartCaching
                                                    size:CGSizeMake(_normalItemSize.width * [UIScreen mainScreen].scale,
                                                                    _normalItemSize.width * [UIScreen mainScreen].scale)
                                               imageType:TGAssetImageTypeThumbnail];
        [TGAssetImageManager stopCachingImagesForAssets:assetsToStopCaching
                                                   size:CGSizeMake(_normalItemSize.width * [UIScreen mainScreen].scale,
                                                                   _normalItemSize.width * [UIScreen mainScreen].scale)
                                              imageType:TGAssetImageTypeThumbnail];
        
        _previousPreheatRect = preheatRect;
    }
}

- (void)_resetAssetsImageCaching
{
    [TGAssetImageManager stopCachingImagesForAllAssets];
    _previousPreheatRect = CGRectZero;
}

- (NSArray *)_assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0)
        return nil;
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths)
    {
        if ((NSUInteger)indexPath.row < _items.count)
            [assets addObject:[_items[indexPath.row] asset]];
    }
    
    return assets;
}

#pragma mark - Selection

- (void)actualizeSelectedItems
{
    NSMutableSet *existingItemsIds = [[NSMutableSet alloc] init];
    NSMutableDictionary *uniqueIdToItemDictionary = [[NSMutableDictionary alloc] init];
    for (TGMediaPickerItem *item in _items)
    {
        NSString *uniqueId = item.uniqueId;
        if (uniqueId != nil)
        {
            [existingItemsIds addObject:uniqueId];
            uniqueIdToItemDictionary[uniqueId] = item;
        }
    }

    TGMediaPickerGalleryModel *galleryModel = _galleryModel;
    TGModernGalleryController *galleryController = galleryModel.controller;
    TGMediaPickerGallerySelectedItemsModel *selectedItemsModel = galleryModel.selectedItemsModel;
    
    if (galleryModel != nil)
    {
        TGMediaPickerGalleryItem *galleryItem = (TGMediaPickerGalleryItem *)galleryController.currentItem;
        if ([galleryItem conformsToProtocol:@protocol(TGModernGallerySelectableItem)])
        {
            id<TGModernGallerySelectableItem> selectableItem = (id<TGModernGallerySelectableItem>)galleryItem;
            if (![existingItemsIds containsObject:selectableItem.uniqueId])
            {
                if (galleryModel.dismiss != nil)
                    galleryModel.dismiss(true, false);
            }
        }
    }
    
    __block id<TGModernGalleryItem> focusItem = nil;
    NSArray *galleryItems = [self prepareGalleryItemsWithSelectedItemsModel:selectedItemsModel enumerationBlock:^(TGMediaPickerGalleryItem *item)
    {
        if (focusItem == nil && [item isEqual:galleryController.currentItem])
            focusItem = item;
    }];
    
    [galleryModel _replaceItems:galleryItems focusingOnItem:focusItem];
    
    if (_selectedItems.count == 0)
        return;
    
    NSMutableOrderedSet *currentSelectedItemsIds = [[NSMutableOrderedSet alloc] init];
    for (TGMediaPickerItem *item in _selectedItems)
    {
        NSString *uniqueId = item.uniqueId;
        if (uniqueId != nil)
            [currentSelectedItemsIds addObject:uniqueId];
    }
    
    NSMutableOrderedSet *existingSelectedItemIds = [[NSMutableOrderedSet alloc] initWithOrderedSet:currentSelectedItemsIds];
    [existingSelectedItemIds intersectSet:existingItemsIds];
    
    if (![existingSelectedItemIds isEqualToOrderedSet:currentSelectedItemsIds])
    {
        NSMutableArray *newSelectedItems = [[NSMutableArray alloc] init];
        for (NSString *uniqueId in existingSelectedItemIds)
        {
            TGMediaPickerItem *item = uniqueIdToItemDictionary[uniqueId];
            if (item != nil)
                [newSelectedItems addObject:item];
        }
        
        [self setSelectedItems:newSelectedItems animated:false];
    }
    
    if (selectedItemsModel != nil)
    {
        NSMutableOrderedSet *currentGallerySelectedItemsIds = [[NSMutableOrderedSet alloc] init];
        for (TGMediaPickerItem *item in selectedItemsModel.items)
        {
            NSString *uniqueId = item.uniqueId;
            if (uniqueId != nil)
                [currentGallerySelectedItemsIds addObject:uniqueId];
        }
        
        NSMutableOrderedSet *existingGallerySelectedItemIds = [[NSMutableOrderedSet alloc] initWithOrderedSet:currentSelectedItemsIds];
        [existingGallerySelectedItemIds intersectSet:existingItemsIds];
        
        if (![existingGallerySelectedItemIds isEqualToOrderedSet:currentGallerySelectedItemsIds])
        {
            NSMutableArray *newSelectedItems = [[NSMutableArray alloc] init];
            for (NSString *uniqueId in existingSelectedItemIds)
            {
                TGMediaPickerItem *item = uniqueIdToItemDictionary[uniqueId];
                if (item != nil)
                    [newSelectedItems addObject:item];
            }
            
            [selectedItemsModel setItems:newSelectedItems];
        }
    }
}

- (void)updateSelectionInterface:(bool)animated
{
    NSUInteger selectedCount = _selectedItems.count;
    _doneButton.enabled = selectedCount != 0;
    
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
    
    CGFloat badgeWidth = MAX(22, _countLabel.frame.size.width + 14);
    _countBadge.transform = CGAffineTransformIdentity;
    _countBadge.frame = CGRectMake(-badgeWidth + 22, 10 + TGRetinaPixel, badgeWidth, 22);
    _countLabel.frame = CGRectMake(TGRetinaFloor((badgeWidth - _countLabel.frame.size.width) / 2), 2 + TGRetinaPixel, _countLabel.frame.size.width, _countLabel.frame.size.height);
    
    if (animated)
    {
        if ([_countBadge alpha] < FLT_EPSILON && badgeAlpha > FLT_EPSILON)
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
        else if ([_countBadge alpha] > FLT_EPSILON && badgeAlpha < FLT_EPSILON)
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

- (bool)toggleItemSelected:(id<TGModernMediaListSelectableItem>)item updateInterface:(bool)updateInterface
{
    bool addedItem = false;
    if ([[self selectedItems] containsObject:item])
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self selectedItems]];
        [array removeObject:item];
        [self setSelectedItems:array animated:true];
    }
    else
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self selectedItems]];
        [array addObject:item];
        [self setSelectedItems:array animated:true];
        
        addedItem = true;
    }
    
    if (updateInterface)
        [self updateItemsSelectedAnimated:NO];
    
    return addedItem;
}

- (NSArray *)selectedItems
{
    return _selectedItems;
}

- (void)setSelectedItems:(NSArray *)selectedItems animated:(bool)animated
{
    _selectedItems = selectedItems;
    
    [self updateSelectionInterface:animated];
}

- (void)updateEditedItem:(TGMediaPickerItem *)item
{
    for (TGModernMediaListItemView *itemView in [_collectionView visibleCells])
    {
        if ([itemView.itemContentView.item isEqual:item])
            [((TGMediaPickerPhotoItemView *)itemView.itemContentView) updateItem];
    }
}

- (void)updateHiddenItemAnimated:(bool)animated
{
    for (TGModernMediaListItemView *itemView in [_collectionView visibleCells])
    {
        if ([itemView.itemContentView isKindOfClass:[TGMediaPickerAssetItemView class]])
            [((TGMediaPickerAssetItemView *)itemView.itemContentView) updateHiddenAnimated:animated];
    }
}

- (void)updateItemsSelectedAnimated:(BOOL)animated
{
    for (TGModernMediaListItemView *itemView in [_collectionView visibleCells])
    {
        if ([itemView.itemContentView isKindOfClass:[TGMediaPickerAssetItemView class]])
            [((TGMediaPickerAssetItemView *)itemView.itemContentView) updateSelectionAnimated:animated];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _checkGestureStartPoint = [recognizer locationInView:_collectionView];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:_collectionView];
        CGPoint location = [recognizer locationInView:_collectionView];
        
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
                for (id cell in _collectionView.visibleCells)
                {
                    if ([cell isKindOfClass:[TGModernMediaListItemView class]])
                    {
                        TGModernMediaListItemView *listItemView = cell;
                        
                        if ([listItemView.itemContentView isKindOfClass:[TGMediaPickerPhotoItemView class]]) {
                            
                            TGMediaPickerPhotoItemView *photoItemView = (TGMediaPickerPhotoItemView *)listItemView.itemContentView;
                            
                            if (CGRectContainsPoint(listItemView.frame, _checkGestureStartPoint))
                            {
                                id<TGModernMediaListItem> item = photoItemView.item;
                                
                                if (item)
                                {
                                    _collectionView.scrollEnabled = false;
                                    
                                    _processingCheckGesture = true;
                                    _checkGestureChecks = ![_selectedItems containsObject:item];
                                    
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
        }
        
        if (_processingCheckGesture)
        {
            for (int i = 0; i < (processAdditionalLocation ? 2 : 1); i++)
            {
                CGPoint currentLocation = i == 0 ? location : additionalLocation;
                
                for (id cell in _collectionView.visibleCells)
                {
                    if ([cell isKindOfClass:[TGModernMediaListItemView class]])
                    {
                        TGModernMediaListItemView *listItemView = cell;
                        
                        if ([listItemView.itemContentView isKindOfClass:[TGMediaPickerPhotoItemView class]])
                        {
                            TGMediaPickerPhotoItemView *photoItemView = (TGMediaPickerPhotoItemView *)listItemView.itemContentView;
                            
                            if (CGRectContainsPoint(listItemView.frame, currentLocation))
                            {
                                id<TGModernMediaListItem> item = photoItemView.item;
                                if ([_selectedItems containsObject:item] != _checkGestureChecks)
                                {
                                    if (_changeItemSelection != nil)
                                        _changeItemSelection(item, false);
                                    
                                    [photoItemView updateSelectionAnimated:true];
                                }
                                
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        _processingCheckGesture = false;
        _collectionView.scrollEnabled = true;
        _failCheckGesture = false;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    return gestureRecognizer == _panGestureRecognizer;
}

#pragma mark - Gallery

- (UIView *)referenceViewForAsset:(TGMediaPickerAsset *)asset
{
    if (asset == nil)
        return nil;
    
    for (TGModernMediaListItemView *itemView in [_collectionView visibleCells])
    {
        if ([itemView.itemContentView isKindOfClass:[TGMediaPickerAssetItemView class]])
        {
            TGMediaPickerAssetItemView *itemContentView = (TGMediaPickerAssetItemView *)itemView.itemContentView;
            if ([[(TGMediaPickerItem *)itemContentView.item asset] isEqual:asset])
                return itemContentView;
        }
    }
    
    return nil;
}

- (TGMediaPickerItem *)listItemForAsset:(TGMediaPickerAsset *)asset
{
    if (asset == nil)
        return nil;
    
    for (TGMediaPickerItem *item in _items)
    {
        if ([[item asset] isEqual:asset])
            return item;
    }
    
    return nil;
}

- (NSArray *)prepareGalleryItemsWithSelectedItemsModel:(TGMediaPickerGallerySelectedItemsModel *)selectedItemsModel enumerationBlock:(void (^)(TGMediaPickerGalleryItem *item))enumerationBlock
{
    __weak TGModernMediaPickerController *weakSelf = self;
    __weak TGMediaPickerGallerySelectedItemsModel *weakSelectedItemsModel = selectedItemsModel;
    
    NSMutableArray *galleryItems = [[NSMutableArray alloc] init];
    
    for (TGMediaPickerItem *listItem in _items)
    {
        TGMediaPickerGalleryItem *galleryItem = nil;
        
        if (listItem.asset.isVideo)
        {
            TGMediaPickerGalleryVideoItem *videoItem = [[TGMediaPickerGalleryVideoItem alloc] initWithAsset:listItem.asset];
            videoItem.updateAdjustments = ^(id<TGEditablePhotoItem> editableMediaItem, id<TGMediaEditAdjustments> adjustments)
            {
                __strong TGModernMediaPickerController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                [strongSelf->_editingContext setAdjustments:adjustments forItemId:editableMediaItem.uniqueId synchronous:true];
                [strongSelf updateEditedItem:[strongSelf listItemForAsset:editableMediaItem]];
            };
            videoItem.updateThumbnail = ^(id<TGEditablePhotoItem> editableMediaItem, UIImage *screenImage, UIImage *thumbnailImage)
            {
                __strong TGModernMediaPickerController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                [strongSelf->_editingContext setImage:screenImage thumbnailImage:thumbnailImage forItemId:editableMediaItem.uniqueId synchronous:true];
                TGDispatchOnMainThread(^
                {
                    [strongSelf updateEditedItem:[strongSelf listItemForAsset:editableMediaItem]];                                           
                });
            };
            
            galleryItem = videoItem;
        }
        else
        {
            TGMediaPickerGalleryPhotoItem *photoItem = [[TGMediaPickerGalleryPhotoItem alloc] initWithAsset:listItem.asset];
            
            galleryItem = photoItem;
        }
        
        if (_intent == TGModernMediaPickerControllerSendPhotoIntent || _intent == TGModernMediaPickerControllerSendVideoIntent || _intent == TGModernMediaPickerControllerSendFileIntent)
        {
            id<TGModernGallerySelectableItem> selectableGalleryItem = (id<TGModernGallerySelectableItem>)galleryItem;
            
            selectableGalleryItem.itemSelected = ^(id<TGModernGallerySelectableItem> item)
            {
                __strong TGModernMediaPickerController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                strongSelf->_changeGalleryItemSelection(item, weakSelectedItemsModel);
            };
        }
        
        galleryItem.asFile = (_intent == TGModernMediaPickerControllerSendFileIntent);
        
        if (enumerationBlock != nil)
            enumerationBlock(galleryItem);
        
        if (galleryItem != nil)
            [galleryItems addObject:galleryItem];
    }
    
    return galleryItems;
}

- (void)presentGalleryControllerForItem:(TGMediaPickerItem *)item withThumbnailImage:(UIImage *)thumbnailImage
{
    TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
 
    __weak TGModernMediaPickerController *weakSelf = self;
    
    void(^itemSelected)(TGMediaPickerItem *) = ^(TGMediaPickerItem *item)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGMediaPickerItem *listItem = [strongSelf listItemForAsset:[item asset]];
            
            if (listItem != nil)
                strongSelf->_changeItemSelection(listItem, true);
            
            TGMediaPickerGalleryModel *galleryModel = strongSelf->_galleryModel;
            [galleryModel.interfaceView updateSelectionInterface:galleryModel.selectedItemsModel.selectedCount
                                                  counterVisible:(galleryModel.selectedItemsModel.totalCount > 0)
                                                        animated:true];
        }
    };
    
    bool(^isItemSelected)(TGMediaPickerItem *) = ^bool(TGMediaPickerItem *item)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGMediaPickerItem *listItem = [strongSelf listItemForAsset:[item asset]];
            
            if (listItem != nil)
                return strongSelf->_isItemSelected(listItem);
        }
        return false;
    };
    
    TGMediaPickerGallerySelectedItemsModel *selectedItemsModel = [[TGMediaPickerGallerySelectedItemsModel alloc] initWithSelectedItems:_selectedItems itemSelected:itemSelected isItemSelected:isItemSelected];

    __weak TGMediaPickerGallerySelectedItemsModel *weakSelectedPhotosModel = selectedItemsModel;
    selectedItemsModel.selectionUpdated = ^(bool reload, bool incremental, bool add, NSInteger index)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGMediaPickerGalleryModel *galleryModel = strongSelf->_galleryModel;
        [galleryModel.interfaceView updateSelectionInterface:galleryModel.selectedItemsModel.selectedCount
                                              counterVisible:(galleryModel.selectedItemsModel.totalCount > 0)
                                                    animated:incremental];
        
        [galleryModel.interfaceView updateSelectedPhotosView:reload incremental:incremental add:add index:index];
    };
    
    selectedItemsModel.selectedItemsReordered = ^(NSArray *reorderedSelectedItems)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (reorderedSelectedItems != nil)
            strongSelf->_selectedItems = [reorderedSelectedItems copy];
    };
    
    __block id<TGModernGalleryItem> focusItem = nil;
    NSArray *galleryItems = [self prepareGalleryItemsWithSelectedItemsModel:selectedItemsModel enumerationBlock:^(TGMediaPickerGalleryItem *galleryItem)
    {
        if (focusItem == nil && [galleryItem.asset isEqual:item.asset])
        {
            focusItem = galleryItem;
            galleryItem.immediateThumbnailImage = thumbnailImage;
        }
    }];
    
    bool allowsEditing = (_intent == TGModernMediaPickerControllerSendPhotoIntent || _intent == TGModernMediaPickerControllerSetProfilePhotoIntent || _intent == TGModernMediaPickerControllerSendVideoIntent);
    bool allowsSelection = (_intent == TGModernMediaPickerControllerSendPhotoIntent || _intent == TGModernMediaPickerControllerSendVideoIntent || _intent == TGModernMediaPickerControllerSendFileIntent);
    bool hasCaption = (_intent == TGModernMediaPickerControllerSendPhotoIntent || _intent == TGModernMediaPickerControllerSendVideoIntent) && !self.disallowCaptions;
    bool forVideo = (_intent == TGModernMediaPickerControllerSendVideoIntent);
    
    TGMediaPickerGalleryModel *model = [[TGMediaPickerGalleryModel alloc] initWithItems:galleryItems focusItem:focusItem allowsSelection:allowsSelection allowsEditing:allowsEditing hasCaptions:hasCaption forVideo:forVideo];
    _galleryModel = model;
    model.controller = modernGallery;
    model.selectedItemsModel = selectedItemsModel;
    model.saveEditedItem = ^(id<TGEditablePhotoItem> editableItem, id<TGMediaEditAdjustments> editorValues, UIImage *resultImage, UIImage *thumbnailImage)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_editingContext setAdjustments:editorValues forItemId:editableItem.uniqueId synchronous:true];
        [strongSelf->_editingContext setImage:resultImage thumbnailImage:thumbnailImage forItemId:editableItem.uniqueId synchronous:true];
        
        TGMediaPickerItem *listItem = [strongSelf listItemForAsset:editableItem];
        [strongSelf updateEditedItem:listItem];

        if (editorValues != nil)
            [strongSelf _selectItemIfApplicable:editableItem];
    };
    model.saveItemCaption = ^(id<TGEditablePhotoItem> editableItem, NSString *caption)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_editingContext setCaption:caption forItemId:editableItem.uniqueId synchronous:true];
        
        if (caption.length > 0)
            [strongSelf _selectItemIfApplicable:editableItem];
    };
    
    if (_intent == TGModernMediaPickerControllerSendFileIntent || _intent == TGModernMediaPickerControllerSendVideoIntent)
        model.interfaceView.usesSimpleLayout = true;
    
    [model.interfaceView updateSelectionInterface:_selectedItems.count counterVisible:(_selectedItems.count > 0) animated:false];
    [model.interfaceView setSelectedItemsModel:selectedItemsModel];
    
    model.interfaceView.itemSelected = ^(TGMediaPickerGalleryItem *item)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_changeGalleryItemSelection(item, weakSelectedPhotosModel);
    };
    
    model.interfaceView.isItemSelected = ^bool (TGMediaPickerGalleryItem *item)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGMediaPickerItem *listItem = [strongSelf listItemForAsset:[item asset]];
            
            if (listItem != nil)
                return strongSelf->_isItemSelected(listItem);
        }
        return false;
    };
    
    model.interfaceView.donePressed = ^(TGMediaPickerGalleryItem *item)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGMediaPickerItem *listItem = [strongSelf listItemForAsset:[item asset]];
            
            if (_intent != TGModernMediaPickerControllerSendVideoIntent)
            {
                NSMutableArray *selectedItems = [strongSelf->_selectedItems mutableCopy];
                if (selectedItems == nil)
                    selectedItems = [[NSMutableArray alloc] init];
                
                if (listItem != nil && ![selectedItems containsObject:listItem])
                    [selectedItems addObject:listItem];
                
                strongSelf->_selectedItems = selectedItems;
            }
            
            [strongSelf completeWithItem:listItem];
        }
    };
    
    model.userListSignal = self.userListSignal;
    model.hashtagListSignal = self.hashtagListSignal;
    
    modernGallery.model = model;
    modernGallery.itemFocused = ^(TGMediaPickerGalleryItem *item)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGMediaPickerItem *listItem = [strongSelf listItemForAsset:[item asset]];
            strongSelf->_hiddenItem = listItem;
            [strongSelf updateHiddenItemAnimated:false];
        }
    };
    
    modernGallery.beginTransitionIn = ^UIView *(TGMediaPickerGalleryItem *item, __unused TGModernGalleryItemView *itemView)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            return [strongSelf referenceViewForAsset:[item asset]];
        }
        return nil;
    };
    
    modernGallery.beginTransitionOut = ^UIView *(TGMediaPickerGalleryItem *item)
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            return [strongSelf referenceViewForAsset:[item asset]];
        }
        return nil;
    };
    
    modernGallery.completedTransitionOut = ^
    {
        __strong TGModernMediaPickerController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf->_hiddenItem = nil;
            [strongSelf updateHiddenItemAnimated:true];
        }
    };
    
    TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:modernGallery];
    controllerWindow.hidden = false;
    modernGallery.view.clipsToBounds = true;
}

- (void)_selectItemIfApplicable:(id<TGEditablePhotoItem>)item
{
    TGMediaPickerItem *listItem = [self listItemForAsset:item];
    if (listItem.isItemSelected != nil && !listItem.isItemSelected(listItem) && listItem.itemSelected != nil)
    {
        listItem.itemSelected(listItem);
        TGMediaPickerGalleryModel *galleryModel = _galleryModel;
        [galleryModel.selectedItemsModel addSelectedItem:listItem];
        
        [galleryModel.interfaceView updateSelectionInterface:galleryModel.selectedItemsModel.selectedCount
                                              counterVisible:(galleryModel.selectedItemsModel.totalCount > 0)
                                                    animated:true];
    }
}

- (void)completeWithItem:(TGMediaPickerItem *)item
{
    if (_intent == TGModernMediaPickerControllerSendVideoIntent)
    {
        NSMutableArray *selectedItems = [_selectedItems mutableCopy];
        if (selectedItems == nil)
            selectedItems = [[NSMutableArray alloc] init];
        
        if (item != nil && ![selectedItems containsObject:item])
            [selectedItems addObject:item];

        [self prepareVideoSendWithSelectedItems:selectedItems];
    }
    else
    {
        TGMediaPickerGalleryModel *galleryModel = _galleryModel;
        if (galleryModel.dismiss != nil)
            galleryModel.dismiss(true, false);
        
        if (self.photosPicked != nil)
            self.photosPicked(self);
        
        if (self.dismiss != nil)
            self.dismiss();
    }
}

- (void)prepareVideoSendWithSelectedItems:(NSArray *)selectedItems
{
    TGMediaPickerGalleryModel *galleryModel = _galleryModel;
    TGModernGalleryController *galleryController = galleryModel.controller;
    TGMediaPickerGalleryVideoItemView *itemView = (TGMediaPickerGalleryVideoItemView *)[galleryController itemViewForItem:galleryController.currentItem];
    [itemView stop];
    
    NSMutableArray *itemsToSend = [[NSMutableArray alloc] init];

    for (TGMediaPickerItem *item in _items)
    {
        if ([selectedItems containsObject:item])
        {
            if (!item.asset.isVideo)
                continue;
            
            [itemsToSend addObject:item];
        }
    }
    
    NSInteger itemsCount = itemsToSend.count;
    
    if (galleryModel == nil)
    {
        [self presentGalleryControllerForItem:itemsToSend.firstObject withThumbnailImage:nil];
        galleryModel = _galleryModel;
        
        TGDispatchAfter(0.5f, dispatch_get_main_queue(), ^
        {
            [self commitVideoSendWithItems:itemsToSend currentIndex:1];
        });
    }
    else
    {
        [self commitVideoSendWithItems:itemsToSend currentIndex:1];
    }
    [galleryModel.interfaceView showVideoConversionProgressForItemsCount:itemsCount];
}

- (void)_cancelVideoConversion
{
    [_videoConverter cancel];
    _videoConverter = nil;
}

- (void)dismissVideoCompression
{
    TGMediaPickerGalleryModel *galleryModel = _galleryModel;
    
    [self _cancelVideoConversion];
    
    if (galleryModel.dismiss != nil)
        galleryModel.dismiss(true, false);
    
    if (self.dismiss != nil)
        self.dismiss();
}

- (void)commitVideoSendWithItems:(NSMutableArray *)items currentIndex:(NSInteger)currentIndex
{
    TGMediaPickerGalleryModel *galleryModel = _galleryModel;
    TGMediaPickerItem *item = items.firstObject;
    if (items.count == 0)
    {
        [self dismissVideoCompression];
        return;
    }
    [items removeObjectAtIndex:0];

    NSDate *startDate = [NSDate date];
    
    [galleryModel setCurrentItemWithListItem:item direction:TGModernGalleryScrollAnimationDirectionRight];

    TGModernGalleryController *galleryController = galleryModel.controller;
    TGMediaPickerGalleryVideoItemView *itemView = (TGMediaPickerGalleryVideoItemView *)[galleryController itemViewForItem:galleryController.currentItem];
    [itemView setPlayButtonHidden:true animated:false];
    
    NSString *caption = nil;
    CGRect cropRect = CGRectZero;
    UIImageOrientation cropOrientation = UIImageOrientationUp;
    CMTimeRange trimRange = kCMTimeRangeZero;
    bool isTrimmed = false;
    bool isCropped = false;;
    
    if ([item conformsToProtocol:@protocol(TGModernMediaListEditableItem)])
    {
        caption = [_editingContext captionForItemId:item.uniqueId];
        
        TGVideoEditAdjustments *adjustments = [_editingContext adjustmentsForItemId:item.uniqueId];
        if (adjustments != nil)
        {
            if ([adjustments cropAppliedForAvatar:false])
            {
                cropRect = adjustments.cropRect;
                isCropped = true;
            }
            cropOrientation = adjustments.cropOrientation;
            
            if (adjustments.trimStartValue > DBL_EPSILON || adjustments.trimEndValue > DBL_EPSILON)
            {
                trimRange = CMTimeRangeMake(CMTimeMakeWithSeconds(adjustments.trimStartValue , NSEC_PER_SEC), CMTimeMakeWithSeconds((adjustments.trimEndValue - adjustments.trimStartValue), NSEC_PER_SEC));
                isTrimmed = true;
            }
        }
    }
    
    _videoConverter = [[TGVideoConverter alloc] initForConvertationWithAsset:item.asset liveUpload:self.liveUploadEnabled highDefinition:false];
    _videoConverter.cropOrientation = cropOrientation;
    if (isCropped)
        _videoConverter.cropRect = cropRect;
    if (isTrimmed)
        _videoConverter.trimRange = trimRange;
    
    void (^itemSwitchBlock)(void) = ^
    {
        NSTimeInterval interval = fabs([startDate timeIntervalSinceNow]);
        
        void (^turnBlock)(void) = ^
        {
            if (items.count > 0)
            {
                [self commitVideoSendWithItems:items currentIndex:currentIndex + 1];
                [galleryModel.interfaceView updateVideoConversionProgress:0 cancelEnabled:true];
                [galleryModel.interfaceView updateVideoConversionActiveItemNumber:currentIndex + 1];
            }
            else
            {
                [self dismissVideoCompression];
            }
        };
        
        if (interval > 0.8f)
            turnBlock();
        else
            TGDispatchAfter(0.8f - interval, dispatch_get_main_queue(), turnBlock);
    };
    
    void (^convertAndSendBlock)(NSString *) = ^(NSString *hash)
    {
        __weak TGModernMediaPickerController *weakSelf = self;
        galleryModel.interfaceView.videoConversionCancelled = ^
        {
            __strong TGModernMediaPickerController *strongSelf = self;
            if (strongSelf != nil)
                [strongSelf _cancelVideoConversion];
        };
        
        [_videoConverter processWithCompletion:^(NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *previewImage, TGLiveUploadActorData *liveUploadData)
        {
            __strong TGModernMediaPickerController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            strongSelf->_videoConverter = nil;
            
            TGDispatchOnMainThread(^
            {
                if (tempFilePath != nil && strongSelf.videoPicked != nil)
                    strongSelf.videoPicked(hash, tempFilePath, dimensions, duration, previewImage, caption, liveUploadData);
                
                itemSwitchBlock();
            });
        } progress:^(float progress)
        {
            TGDispatchOnMainThread(^
            {
                __strong TGModernMediaPickerController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                TGMediaPickerGalleryModel *galleryModel = strongSelf->_galleryModel;
                [galleryModel.interfaceView updateVideoConversionProgress:progress cancelEnabled:true];
            });
        }];
    };
    
    if (self.serverAssetCacheEnabled)
    {
        id videoAsset = [TGAssetImageManager avAssetForVideoAsset:item.asset];
        [TGVideoConverter computeHashForVideoAsset:videoAsset hasTrimming:isTrimmed isCropped:isCropped highDefinition:false completion:^(NSString *hash)
        {
            if ([TGImageDownloadActor serverMediaDataForAssetUrl:hash] != nil)
            {
                if (self.videoPicked != nil)
                    self.videoPicked(hash, nil, CGSizeZero, 0.0, nil, caption, nil);
                
                itemSwitchBlock();
            }
            else
            {
                convertAndSendBlock(hash);
            }
        }];
    }
    else
    {
        convertAndSendBlock(nil);
    }
}

- (NSArray *)selectedItemSignals:(id (^)(id, NSString *, NSString *))descriptionGenerator
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if (_intent == TGModernMediaPickerControllerSendPhotoIntent)
    {
        TGMediaEditingContext *editingContext = _editingContext;
        for (TGMediaPickerItem *item in _items)
        {
            if ([_selectedItems containsObject:item])
            {
                PGPhotoEditorValues *editorValues = [_editingContext adjustmentsForItemId:item.uniqueId];
                NSString *caption = [_editingContext captionForItemId:item.uniqueId];
                
                if (editorValues != nil)
                {
                    [result addObject:[[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
                    {
                        UIImage *image = [editingContext imageForItemId:item.uniqueId];
                        if (image != nil)
                        {
                            id generatedItem = descriptionGenerator(image, caption, nil);
                            if (generatedItem != nil)
                                [subscriber putNext:generatedItem];
                            
                            if ([editorValues toolsApplied])
                                [[TGMediaPickerAssetsLibrary sharedLibrary] saveAssetWithImage:image completionBlock:nil];
                        }
                        [subscriber putCompletion];
                        
                        return nil;
                    }]];
                }
                else
                {
                    [result addObject:[[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
                    {
                        [TGAssetImageManager requestImageWithAsset:item.asset imageType:TGAssetImageTypeScreen size:CGSizeMake(1280, 1280) completionBlock:^(UIImage *image, __unused NSError *error)
                        {
                            if (image != nil)
                            {
                                NSData *data = UIImageJPEGRepresentation(image, 0.54f);
                                
                                CC_MD5_CTX md5;
                                CC_MD5_Init(&md5);
                                CC_MD5_Update(&md5, [data bytes], (CC_LONG)data.length);
                                
                                unsigned char md5Buffer[16];
                                CC_MD5_Final(md5Buffer, &md5);
                                NSString *hash = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
                                
                                if (image != nil)
                                {
                                    id generatedItem = descriptionGenerator(image, caption, hash);
                                    if (generatedItem != nil)
                                        [subscriber putNext:generatedItem];
                                }
                            }
                            
                            [subscriber putCompletion];
                        }];
                        
                        return nil;
                    }]];
                }
            }
        }
    }
    else if (_intent == TGModernMediaPickerControllerSendFileIntent)
    {
        for (TGMediaPickerItem *item in _items)
        {
            if ([_selectedItems containsObject:item])
            {
                NSString *tempFileName = TGTemporaryFileName(nil);

                if (item.asset.isVideo)
                {
                    __block NSString *fileName = nil;
                    bool succeed = [TGAssetImageManager copyOriginalFileForAsset:item.asset toPath:tempFileName completion:^(NSString *name)
                    {
                        fileName = name;
                    }];

                    NSString *fileExtension = fileName.pathExtension;
                    
                    [result addObject:[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
                    {
                        if (succeed)
                        {
                            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                            dict[@"tempFileUrl"] = [NSURL fileURLWithPath:tempFileName];
                            dict[@"fileName"] = fileName;
                            dict[@"mimeType"] = TGMimeTypeForFileExtension(fileExtension);
                            
                            id generatedItem = descriptionGenerator(dict, nil, nil);
                            [subscriber putNext:generatedItem];
                        }
                        [subscriber putCompletion];
                        
                        return nil;
                    }]];
                }
                else
                {
                    [result addObject:[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
                    {
                        [TGAssetImageManager requestImageDataWithAsset:item.asset completionBlock:^(NSData *data, NSString *fileName, NSString *dataUTI, NSError *error)
                        {
                            if (data != nil && error == nil)
                            {
                                [data writeToURL:[NSURL fileURLWithPath:tempFileName] atomically:true];
                                
                                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                dict[@"tempFileUrl"] = [NSURL fileURLWithPath:tempFileName];
                                dict[@"fileName"] = fileName;
                                dict[@"mimeType"] = TGMimeTypeForFileUTI(dataUTI);
                                                   
                                id generatedItem = descriptionGenerator(dict, nil, nil);
                                [subscriber putNext:generatedItem];
                            }
                            
                            [subscriber putCompletion];
                        }];
                        
                        return nil;
                    }]];
                }
            }
        }
    }
    
    return result;
}

#pragma mark - Placeholder Containers

- (UIView *)emptyGroupContainer
{
    if (_emptyGroupContainer)
    {
        _emptyGroupContainer = [[UIView alloc] initWithFrame:CGRectZero];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = UIColorRGB(0xa8a8a8);
        titleLabel.font = TGBoldSystemFontOfSize(14);
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        titleLabel.text = TGLocalized(@"MediaPicker.AccessDeniedError");
        titleLabel.tag = 100;
        
        [_emptyGroupContainer addSubview:titleLabel];
        
        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.textColor = UIColorRGB(0xa8a8a8);
        subtitleLabel.font = TGSystemFontOfSize(14);
        subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subtitleLabel.numberOfLines = 0;
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        
        subtitleLabel.text = @"";
        subtitleLabel.tag = 101;
        
        [_emptyGroupContainer addSubview:subtitleLabel];
        
        [self _updateContainerLayout:_emptyGroupContainer forSize:self.view.bounds.size];
    }
    
    return _emptyGroupContainer;
}

- (UIView *)accessDisabledContainer
{
    if (_accessDeniedContainer == nil)
    {
        _accessDeniedContainer = [[UIView alloc] initWithFrame:CGRectZero];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = UIColorRGB(0xa8a8a8);
        titleLabel.font = TGBoldSystemFontOfSize(14);
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        titleLabel.text = TGLocalized(@"MediaPicker.AccessDeniedError");
        titleLabel.tag = 100;
        
        [_accessDeniedContainer addSubview:titleLabel];
        
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
        
        [_accessDeniedContainer addSubview:subtitleLabel];
        
        if (iosMajorVersion() >= 8)
        {
            TGModernButton *settingsButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [settingsButton setTitle:[[NSString alloc] initWithFormat:TGLocalized(@"Settings.OpenSystemPrivacySettings"), model] forState:UIControlStateNormal];
            [settingsButton setTitleColor:TGAccentColor()];
            [_accessDeniedContainer addSubview:settingsButton];
        }
        
        [self _updateContainerLayout:_accessDeniedContainer forSize:self.view.bounds.size];
    }
    
    return _accessDeniedContainer;
}

- (void)_setNoMediaHidden:(BOOL)hidden
{
    if (!hidden)
    {
        if (_emptyGroupContainer.superview == nil)
            [self.view addSubview:[self emptyGroupContainer]];

        _emptyGroupContainer.hidden = false;
    }
    else
    {
        _emptyGroupContainer.hidden = true;
    }
}

- (void)_showAccessDisabled
{
    if (_accessDeniedContainer.superview == nil)
    {
        [self.view addSubview:[self accessDisabledContainer]];
    
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectZero]]];
    }
}

- (void)_updateContainerLayout:(UIView *)container forSize:(CGSize)size
{
    UILabel *titleLabel = (UILabel *)[container viewWithTag:100];
    UILabel *subtitleLabel = (UILabel *)[container viewWithTag:101];
    
    if (titleLabel == nil || subtitleLabel == nil)
        return;
    
    CGSize screenSize = size;
    
    CGSize titleSize = [titleLabel sizeThatFits:CGSizeMake(screenSize.width - 20, 1000)];
    titleLabel.frame = CGRectMake(CGFloor((titleLabel.superview.frame.size.width - titleSize.width) / 2), -titleSize.height, titleSize.width, titleSize.height);
    
    CGSize subtitleSize = [subtitleLabel sizeThatFits:CGSizeMake(screenSize.width - 20, 1000)];
    subtitleLabel.frame = CGRectMake(CGFloor((subtitleLabel.superview.frame.size.width - subtitleSize.width) / 2), 2, subtitleSize.width, subtitleSize.height);
    
    container.frame = CGRectMake(CGFloor((screenSize.width - container.frame.size.width) / 2), CGFloor((screenSize.height - container.frame.size.height) / 2), container.frame.size.width, container.frame.size.height);
}

+ (TGMediaPickerAssetType)assetTypeForIntent:(TGModernMediaPickerControllerIntent)intent
{
    TGMediaPickerAssetType assetType = TGMediaPickerAssetAnyType;
    
    switch (intent)
    {
        case TGModernMediaPickerControllerSendPhotoIntent:
        case TGModernMediaPickerControllerSetProfilePhotoIntent:
        case TGModernMediaPickerControllerSetCustomWallpaperIntent:
            assetType = TGMediaPickerAssetPhotoType;
            break;
            
        case TGModernMediaPickerControllerSendVideoIntent:
            assetType = TGMediaPickerAssetVideoType;
            break;
            
        default:
            break;
    }
    
    return assetType;
}

@end
