#import "TGModernMediaPickerController.h"

#import "TGModernMediaPickerLayout.h"
#import "TGModernMediaPickerCell.h"
#import "TGMediaPickerAsset.h"

#import "TGVideoPreviewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "ATQueue.h"

@interface TGModernMediaPickerController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    NSString *_assetsGroupPersistentId;
    
    CGSize _normalItemSize;
    CGSize _wideItemSize;
    
    UIEdgeInsets _normalEdgeInsets;
    UIEdgeInsets _wideEdgeInsets;
    
    UICollectionView *_collectionView;
    CGFloat _collectionViewWidth;
    TGModernMediaPickerLayout *_collectionLayout;
    UIView *_collectionContainer;
    
    ALAssetsLibrary *_assetsLibrary;
    ATQueue *_assetsQueue;
    
    NSArray *_assetList;
    NSArray *_loadedAssetList;
    
    dispatch_semaphore_t _waitSemaphore;
    bool _usedSemaphore;
}

@end

@implementation TGModernMediaPickerController

- (instancetype)init
{
    return [self initWithAssetsGroupPersistentId:nil title:@"Camera Roll"];
}

- (instancetype)initWithAssetsGroupPersistentId:(NSString *)assetsGroupPersistentId title:(NSString *)title
{
    self = [super init];
    if (self != nil)
    {
        _assetsGroupPersistentId = assetsGroupPersistentId;
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        
        if ([UIScreen mainScreen].scale > 1.0f + FLT_EPSILON)
        {
            _normalItemSize = CGSizeMake(78.5f, 78.5f);
            _wideItemSize = CGSizeMake(78.0f, 78.0f);
            _normalEdgeInsets = UIEdgeInsetsMake(4.0f, 0.0f, 2.0f, 0.0f);
            _wideEdgeInsets = UIEdgeInsetsMake(4.0f, 1.0f, 1.0f, 1.0f);
        }
        else
        {
            _normalItemSize = CGSizeMake(78.5f, 78.5f);
            _wideItemSize = CGSizeMake(78.0f, 78.0f);
            _normalEdgeInsets = UIEdgeInsetsMake(4.0f, 0.0f, 2.0f, 0.0f);
            _wideEdgeInsets = UIEdgeInsetsMake(4.0f, 1.0f, 1.0f, 1.0f);
        }
        
        self.title = title;
        
        _waitSemaphore = dispatch_semaphore_create(0);
        
        _assetsQueue = [[ATQueue alloc] init];
        [_assetsQueue dispatch:^
        {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
            [self loadAssets];
        }];
    }
    return self;
}

- (void)dealloc
{
}

- (void)cancelPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)loadView
{
    bool resetOffset = false;
    if (_waitSemaphore != nil && !_usedSemaphore)
    {
        _usedSemaphore = true;
        if (dispatch_semaphore_wait(_waitSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC))))
            TGLog(@"Media list loading took longer than expected");
        
        @synchronized(self)
        {
            if (_loadedAssetList != nil)
            {
                _assetList = _loadedAssetList;
                _loadedAssetList = nil;
                resetOffset = true;
            }
        }
    }
    
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _collectionContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    _collectionContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_collectionContainer];
    
    CGSize frameSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
    
    _collectionLayout = [[TGModernMediaPickerLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height) collectionViewLayout:_collectionLayout];
    _collectionView.alwaysBounceVertical = true;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    [_collectionView registerClass:[TGModernMediaPickerCell class] forCellWithReuseIdentifier:@"TGModernMediaPickerCell"];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionContainer addSubview:_collectionView];
    
    self.scrollViewsForAutomaticInsetsAdjustment = @[_collectionView];
    
    [self controllerInsetUpdated:UIEdgeInsetsZero];
    
    if (resetOffset)
    {
        [_collectionLayout invalidateLayout];
        [_collectionView layoutSubviews];
        [self _adjustContentOffsetToBottom:self.interfaceOrientation];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGSize frameSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
    CGRect collectionViewFrame = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    _collectionViewWidth = collectionViewFrame.size.width;
    _collectionView.frame = collectionViewFrame;
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
}

- (bool)shouldAdjustScrollViewInsetsForInversedLayout
{
    return true;
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
    
    CGFloat lastInverseOffset = MAX(0, _collectionView.contentSize.height - (_collectionView.contentOffset.y + _collectionView.frame.size.height - _collectionView.contentInset.bottom));
    CGFloat lastOffset = _collectionView.contentOffset.y;
    
    CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _collectionViewWidth = tableFrame.size.width;
    _collectionView.frame = tableFrame;
    
    if (lastInverseOffset < 2)
    {
        [self _adjustContentOffsetToBottom:toInterfaceOrientation];
    }
    else if (lastOffset < -_collectionView.contentInset.top + 2)
    {
        UIEdgeInsets contentInset = [self controllerInsetForInterfaceOrientation:toInterfaceOrientation];
        
        CGPoint contentOffset = CGPointMake(0, -contentInset.top);
        [_collectionView setContentOffset:contentOffset animated:false];
    }
    
    _collectionView.transform = tableTransform;
    
    [_collectionLayout invalidateLayout];
    [_collectionView layoutSubviews];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
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
    
    CGPoint contentOffset = CGPointMake(0, contentSize - _collectionView.frame.size.height + contentInset.bottom - 0.0f);
    if (contentOffset.y < -contentInset.top)
        contentOffset.y = -contentInset.top;
    [_collectionView setContentOffset:contentOffset animated:false];
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return (_collectionViewWidth > 320.0f + FLT_EPSILON) ? _wideItemSize : _normalItemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    if (ABS(_collectionViewWidth - 540.0f) < FLT_EPSILON)
        return UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    
    return (_collectionViewWidth > 320.0f + FLT_EPSILON) ? _wideEdgeInsets : _normalEdgeInsets;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    if (ABS(_collectionViewWidth - 540.0f) < FLT_EPSILON)
        return 10.0f;
    
    return 2.0f;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return _assetList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGModernMediaPickerCell *cell = (TGModernMediaPickerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGModernMediaPickerCell" forIndexPath:indexPath];
    cell.asset = _assetList[indexPath.item];
    
    return cell;
}

- (void)_replaceAssetList:(NSArray *)assetList title:(NSString *)title
{
    self.title = title;
    
    if (_assetList != assetList)
    {
        _assetList = assetList;
        [_collectionView reloadData];
        [self _adjustContentOffsetToBottom:self.interfaceOrientation];
    }
}

- (void)loadAssets
{
    [_assetsQueue dispatch:^
    {
        NSMutableArray *assetList = [[NSMutableArray alloc] init];
        __block NSString *groupTitle = @"";
        
        if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized)
        {
            if (_waitSemaphore != nil)
                dispatch_semaphore_signal(_waitSemaphore);
        }
        
        [_assetsLibrary enumerateGroupsWithTypes:_assetsGroupPersistentId == nil ? ALAssetsGroupSavedPhotos : ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, __unused BOOL *stop)
        {
            if (group != nil)
            {
                if (_assetsGroupPersistentId != nil && ![_assetsGroupPersistentId isEqualToString:[group valueForProperty:ALAssetsGroupPropertyPersistentID]])
                    return;
                
                groupTitle = [group valueForProperty:ALAssetsGroupPropertyName];
                
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, __unused NSUInteger index, __unused BOOL *stop)
                {
                    if (asset != nil)
                    {
                        [assetList addObject:[[TGMediaPickerAsset alloc] initWithAssetsLibrary:_assetsLibrary asset:asset]];
                    }
                }];
            }
            else
            {
                @synchronized(self)
                {
                    _loadedAssetList = assetList;
                }
                
                if (_waitSemaphore != nil)
                    dispatch_semaphore_signal(_waitSemaphore);
                
                TGDispatchOnMainThread(^
                {
                    [self _replaceAssetList:assetList title:groupTitle];
                });
            }
        } failureBlock:^(NSError *error)
        {
            if (_waitSemaphore != nil)
                dispatch_semaphore_signal(_waitSemaphore);
            
            NSLog(@"error enumerating AssetLibrary groups %@\n", error);
        }];
    }];
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGMediaPickerAsset *asset = _assetList[indexPath.row];
    NSURL *url = asset.url;
    if (url != nil && _videoPicked != nil)
    {
        TGVideoPreviewController *videoPreviewController = [[TGVideoPreviewController alloc] initWithAssetUrl:url thumbnail:[asset aspectThumbnail] duration:[asset videoDuration] enableServerAssetCache:_enableServerAssetCache];
        videoPreviewController.videoPicked = _videoPicked;
        videoPreviewController.liveUpload = _liveUpload;
        [self.navigationController pushViewController:videoPreviewController animated:true];
    }
}

@end
