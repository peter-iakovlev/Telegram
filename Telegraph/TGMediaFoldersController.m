#import "TGMediaFoldersController.h"

#import "ATQueue.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "TGMediaPickerAsset.h"
#import "TGMediaPickerAssetsGroup.h"

#import "TGMediaFoldersLayout.h"
#import "TGMediaFoldersCell.h"

#import "TGModernMediaPickerController.h"

@interface TGMediaFoldersController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    ALAssetsLibrary *_assetsLibrary;
    ATQueue *_assetsQueue;
    
    UICollectionView *_collectionView;
    CGFloat _collectionViewWidth;
    TGMediaFoldersLayout *_collectionLayout;
    
    NSArray *_assetGroupList;
    NSArray *_loadedAssetGroupList;
    
    dispatch_semaphore_t _waitSemaphore;
    bool _usedSemaphore;
}

@end

@implementation TGMediaFoldersController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = TGLocalized(@"SearchImages.Title");
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        
        _waitSemaphore = dispatch_semaphore_create(0);
        
        _assetsQueue = [[ATQueue alloc] init];
        [_assetsQueue dispatch:^
        {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
        }];
    }
    return self;
}

- (void)cancelPressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize frameSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
    
    _collectionLayout = [[TGMediaFoldersLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height) collectionViewLayout:_collectionLayout];
    _collectionView.alwaysBounceVertical = true;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    [_collectionView registerClass:[TGMediaFoldersCell class] forCellWithReuseIdentifier:@"TGMediaFoldersCell"];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_waitSemaphore != nil && !_usedSemaphore)
    {
        _usedSemaphore = true;
        [self loadAssets];
        
        dispatch_semaphore_wait(_waitSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)));
        
        @synchronized (self)
        {
            if (_loadedAssetGroupList != nil)
            {
                _assetGroupList = _loadedAssetGroupList;
                _loadedAssetGroupList = nil;
            }
        }
    }
    
    [super viewWillAppear:animated];
    
    CGSize frameSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
    CGRect collectionViewFrame = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    _collectionViewWidth = collectionViewFrame.size.width;
    _collectionView.frame = collectionViewFrame;
    [_collectionLayout invalidateLayout];
    
    if ([_collectionView indexPathsForSelectedItems].count != 0)
        [_collectionView deselectItemAtIndexPath:[_collectionView indexPathsForSelectedItems][0] animated:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGSize screenSize = [self referenceViewSizeForOrientation:toInterfaceOrientation];
    
    CGRect tableFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _collectionViewWidth = tableFrame.size.width;
    _collectionView.frame = tableFrame;
    [_collectionLayout invalidateLayout];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)_replaceAssetGroupList:(NSArray *)assetGroupList
{
    _assetGroupList = assetGroupList;
    [_collectionView reloadData];
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return CGSizeMake(_collectionViewWidth, 86.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return _assetGroupList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGMediaFoldersCell *cell = (TGMediaFoldersCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGMediaFoldersCell" forIndexPath:indexPath];
    [cell setAssetsGroup:_assetGroupList[indexPath.item]];
    
    return cell;
}

- (void)loadAssets
{
    [_assetsQueue dispatch:^
    {
        if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized)
        {
            if (_waitSemaphore != nil)
                dispatch_semaphore_signal(_waitSemaphore);
        }
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, __unused BOOL *stop)
        {
            if (group != nil)
            {
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
                
                NSMutableArray *groupAssetList = [[NSMutableArray alloc] init];
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, __unused NSUInteger index, BOOL *stop)
                {
                    if (asset != nil)
                    {
                        [groupAssetList addObject:[[TGMediaPickerAsset alloc] initWithAssetsLibrary:_assetsLibrary asset:asset]];
                    }
                    if (groupAssetList.count == 3 && stop != NULL)
                        *stop = true;
                }];
                
                [assetGroups addObject:[[TGMediaPickerAssetsGroup alloc] initWithLatestAssets:groupAssetList groupThumbnail:[[UIImage alloc] initWithCGImage:[group posterImage]] persistentId:[group valueForProperty:ALAssetsGroupPropertyPersistentID] title:[group valueForProperty:ALAssetsGroupPropertyName] assetCount:group.numberOfAssets]];
            }
            else
            {
                [assetGroups sortUsingComparator:^NSComparisonResult(TGMediaPickerAssetsGroup *group1, TGMediaPickerAssetsGroup *group2)
                {
                    NSDate *date1 = [group1 latestAssets].count == 0 ? nil : ((TGMediaPickerAsset *)[group1 latestAssets][0]).date;
                    NSDate *date2 = [group2 latestAssets].count == 0 ? nil : ((TGMediaPickerAsset *)[group2 latestAssets][0]).date;
                    
                    if (date1 != nil && date2 == nil)
                        return NSOrderedAscending;
                    else if (date1 == nil && date2 != nil)
                        return NSOrderedDescending;
                    else if (date1 != nil && date2 != nil)
                        return [date1 compare:date2] == NSOrderedAscending ? NSOrderedDescending : NSOrderedAscending;
                    
                    return [group1.title compare:group2.title];
                }];
                
                @synchronized(self)
                {
                    _loadedAssetGroupList = assetGroups;
                }
                
                TGDispatchOnMainThread(^
                {
                    [self _replaceAssetGroupList:assetGroups];
                });
                
                if (_waitSemaphore != nil)
                    dispatch_semaphore_signal(_waitSemaphore);
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
    TGMediaPickerAssetsGroup *assetsGroup = _assetGroupList[indexPath.row];
    TGModernMediaPickerController *mediaPickerController = [[TGModernMediaPickerController alloc] initWithAssetsGroupPersistentId:[assetsGroup persistentId] title:[assetsGroup title]];
    mediaPickerController.videoPicked = _videoPicked;
    mediaPickerController.liveUpload = _liveUpload;
    mediaPickerController.enableServerAssetCache = _enableServerAssetCache;
    [self.navigationController pushViewController:mediaPickerController animated:true];
}

@end
