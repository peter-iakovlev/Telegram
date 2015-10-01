#import "TGMediaFoldersController.h"

#import "TGMediaPickerAsset.h"
#import "TGMediaPickerAssetsGroup.h"

#import "TGMediaFoldersLayout.h"
#import "TGMediaFoldersCell.h"

#import "TGModernMediaPickerController.h"

#import "TGAppDelegate.h"

@interface TGMediaFoldersController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    TGMediaPickerAssetsLibrary *_assetsLibrary;
    
    NSArray *_items;
    NSArray *_loadedItems;
    
    NSString *_currentGroupId;
    
    UICollectionView *_collectionView;
    CGFloat _collectionViewWidth;
    TGMediaFoldersLayout *_collectionLayout;
    
    TGModernMediaPickerControllerIntent _intent;
    
    dispatch_semaphore_t _waitSemaphore;
    bool _usedSemaphore;
}

@end

@implementation TGMediaFoldersController

- (instancetype)init
{
    return [self initWithIntent:TGModernMediaPickerControllerDefaultIntent];
}

- (instancetype)initWithIntent:(TGModernMediaPickerControllerIntent)intent
{
    self = [super init];
    if (self != nil)
    {
        _intent = intent;
        
        self.title = TGLocalized(@"SearchImages.Title");
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        
        _waitSemaphore = dispatch_semaphore_create(0);
        
        __weak TGMediaFoldersController *weakSelf = self;
        _assetsLibrary = [[TGMediaPickerAssetsLibrary alloc] initForAssetType:[TGModernMediaPickerController assetTypeForIntent:intent]];
        _assetsLibrary.libraryChanged = ^
        {
            __strong TGMediaFoldersController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (strongSelf->_items)
                [strongSelf reloadData];
        };
    }
    return self;
}

- (void)cancelPressed
{
    if (self.dismiss != nil)
        self.dismiss();
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize frameSize = TGAppDelegateInstance.rootController.view.bounds.size;
    
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
        [self reloadData];
        
        dispatch_semaphore_wait(_waitSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)));
        
        @synchronized (self)
        {
            if (_loadedItems != nil)
            {
                _items = _loadedItems;
                _loadedItems = nil;
            }
        }
    }
    
    [super viewWillAppear:animated];
    
    _currentGroupId = nil;
    
    CGSize frameSize = TGAppDelegateInstance.rootController.view.bounds.size;
    CGRect collectionViewFrame = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    _collectionViewWidth = collectionViewFrame.size.width;
    _collectionView.frame = collectionViewFrame;
    [_collectionLayout invalidateLayout];
    
    if ([_collectionView indexPathsForSelectedItems].count != 0)
        [_collectionView deselectItemAtIndexPath:[_collectionView indexPathsForSelectedItems][0] animated:animated];
}

- (void)layoutControllerForSize:(CGSize)size duration:(NSTimeInterval)__unused duration {
    [super layoutControllerForSize:size duration:duration];
    
    CGRect tableFrame = CGRectMake(0, 0, size.width, size.height);
    _collectionViewWidth = tableFrame.size.width;
    _collectionView.frame = tableFrame;
    [_collectionLayout invalidateLayout];
}

- (void)_replaceAssetGroupList:(NSArray *)items
{
    _items = items;
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
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGMediaFoldersCell *cell = (TGMediaFoldersCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGMediaFoldersCell" forIndexPath:indexPath];
    [cell setAssetsGroup:_items[indexPath.item]];
    
    return cell;
}

- (void)reloadData
{
    [_assetsLibrary fetchAssetsGroupsWithCompletionBlock:^(NSArray *groups, TGMediaPickerAuthorizationStatus status, __unused NSError *error)
    {
        if (status == TGMediaPickerAuthorizationStatusAuthorized)
        {
            @synchronized(self)
            {
                _loadedItems = groups;
            }
            
            TGDispatchOnMainThread(^
            {
                [self _replaceAssetGroupList:groups];
                
                if (_currentGroupId != nil)
                {
                    bool currentGroupStillExists = false;
                    for (TGMediaPickerAssetsGroup *group in groups)
                    {
                        if ([group.persistentId isEqualToString:_currentGroupId])
                        {
                            currentGroupStillExists = true;
                            break;
                        }
                    }
                    
                    if (!currentGroupStillExists)
                    {
                        _currentGroupId = nil;
                        [self.navigationController popToRootViewControllerAnimated:true];
                    }
                }
            });
        }
        
        if (_waitSemaphore != nil)
            dispatch_semaphore_signal(_waitSemaphore);
    }];
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGMediaPickerAssetsGroup *assetsGroup = _items[indexPath.row];
    _currentGroupId = assetsGroup.persistentId;
    
    TGModernMediaPickerController *controller = [[TGModernMediaPickerController alloc] initWithAssetsGroup:assetsGroup intent:_intent];
    controller.photosPicked = self.photosPicked;
    controller.videoPicked = self.videoPicked;
    controller.liveUploadEnabled = self.liveUpload;
    controller.serverAssetCacheEnabled = self.enableServerAssetCache;
    controller.avatarCreated = self.avatarCreated;
    controller.dismiss = self.dismiss;
    controller.userListSignal = self.userListSignal;
    controller.hashtagListSignal = self.hashtagListSignal;
    controller.disallowCaptions = self.disallowCaptions;
    [self.navigationController pushViewController:controller animated:true];
}

@end
