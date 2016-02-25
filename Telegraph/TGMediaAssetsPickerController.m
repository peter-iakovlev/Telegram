#import "TGMediaAssetsPickerController.h"

#import "UICollectionView+Utils.h"

#import "TGMediaPickerLayoutMetrics.h"
#import "TGMediaAssetsPhotoCell.h"
#import "TGMediaAssetsVideoCell.h"
#import "TGMediaAssetsGifCell.h"

#import "TGMediaAssetsUtils.h"
#import "TGMediaAssetImageSignals.h"
#import "TGMediaAssetFetchResultChange.h"

#import "TGModernBarButton.h"

#import "TGMediaAsset+TGMediaEditableItem.h"
#import "TGPhotoEditorController.h"
#import "PGPhotoEditorValues.h"

#import "TGMediaPickerModernGalleryMixin.h"
#import "TGMediaPickerGalleryItem.h"

@interface TGMediaAssetsPickerController ()
{
    TGMediaAssetsControllerIntent _intent;
    TGMediaAssetsLibrary *_assetsLibrary;
    
    SMetaDisposable *_assetsDisposable;
    
    TGMediaAssetFetchResult *_fetchResult;
    TGMediaAssetsPreheatMixin *_preheatMixin;
    
    TGModernBarButton *_searchBarButton;
    
    TGMediaPickerModernGalleryMixin *_galleryMixin;
}
@end

@implementation TGMediaAssetsPickerController

- (instancetype)initWithAssetsLibrary:(TGMediaAssetsLibrary *)assetsLibrary assetGroup:(TGMediaAssetGroup *)assetGroup intent:(TGMediaAssetsControllerIntent)intent selectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext
{
    bool hasSelection = false;
    bool hasEditing = false;
    
    switch (intent)
    {
        case TGMediaAssetsControllerSendMediaIntent:
            hasSelection = true;
            hasEditing = true;
            break;
            
        case TGMediaAssetsControllerSendFileIntent:
            hasSelection = true;
            hasEditing = true;
            break;
            
        case TGMediaAssetsControllerSetProfilePhotoIntent:
            hasEditing = true;
            break;
            
        default:
            break;
    }
    
    self = [super initWithSelectionContext:hasSelection ? selectionContext : nil editingContext:hasEditing ? editingContext : nil];
    if (self != nil)
    {
        _assetsLibrary = assetsLibrary;
        _assetGroup = assetGroup;
        _intent = intent;
        
        [self setTitle:_assetGroup.title];
        
        _assetsDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_assetsDisposable dispose];
}

- (void)loadView
{
    [super loadView];
    
    [_collectionView registerClass:[TGMediaAssetsPhotoCell class] forCellWithReuseIdentifier:TGMediaAssetsPhotoCellKind];
    [_collectionView registerClass:[TGMediaAssetsVideoCell class] forCellWithReuseIdentifier:TGMediaAssetsVideoCellKind];
    [_collectionView registerClass:[TGMediaAssetsGifCell class] forCellWithReuseIdentifier:TGMediaAssetsGifCellKind];
    
    __weak TGMediaAssetsPickerController *weakSelf = self;
    _preheatMixin = [[TGMediaAssetsPreheatMixin alloc] initWithCollectionView:_collectionView scrollDirection:UICollectionViewScrollDirectionVertical];
    _preheatMixin.imageType = TGMediaAssetImageTypeThumbnail;
    _preheatMixin.assetCount = ^NSInteger
    {
        __strong TGMediaAssetsPickerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return 0;
        
        return strongSelf->_fetchResult.count;
    };
    _preheatMixin.assetAtIndex = ^TGMediaAsset *(NSInteger index)
    {
        __strong TGMediaAssetsPickerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf->_fetchResult assetAtIndex:index];
    };
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setRightBarButtonItem:[(TGMediaAssetsController *)self.navigationController rightBarButtonItem]];
    
    SSignal *groupSignal = nil;
    if (_assetGroup != nil)
        groupSignal = [SSignal single:_assetGroup];
    else
        groupSignal = [_assetsLibrary cameraRollGroup];
    
    __weak TGMediaAssetsPickerController *weakSelf = self;
    [_assetsDisposable setDisposable:[[[[groupSignal deliverOn:[SQueue mainQueue]] mapToSignal:^SSignal *(TGMediaAssetGroup *assetGroup)
    {
        __strong TGMediaAssetsPickerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        if (strongSelf->_assetGroup == nil)
            strongSelf->_assetGroup = assetGroup;
        
        [strongSelf setTitle:assetGroup.title];
        
        return [strongSelf->_assetsLibrary assetsOfAssetGroup:assetGroup reversed:false];
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong TGMediaAssetsPickerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf->_layoutMetrics == nil)
        {
            if (strongSelf->_assetGroup.subtype == TGMediaAssetGroupSubtypePanoramas)
                strongSelf->_layoutMetrics = [TGMediaPickerLayoutMetrics panoramaLayoutMetrics];
            else
                strongSelf->_layoutMetrics = [TGMediaPickerLayoutMetrics defaultLayoutMetrics];
            
            strongSelf->_preheatMixin.imageSize = [strongSelf->_layoutMetrics imageSize];
        }
        
        if ([next isKindOfClass:[TGMediaAssetFetchResult class]])
        {
            TGMediaAssetFetchResult *fetchResult = (TGMediaAssetFetchResult *)next;
            
            bool scrollToBottom = (strongSelf->_fetchResult == nil);
            
            strongSelf->_fetchResult = fetchResult;
            [strongSelf->_collectionView reloadData];
            
            if (scrollToBottom)
            {
                [strongSelf->_collectionView layoutSubviews];
                [strongSelf _adjustContentOffsetToBottom];
            }
        }
        else if ([next isKindOfClass:[TGMediaAssetFetchResultChange class]])
        {
            TGMediaAssetFetchResultChange *change = (TGMediaAssetFetchResultChange *)next;
            
            strongSelf->_fetchResult = change.fetchResultAfterChanges;
            [TGMediaAssetsCollectionViewIncrementalUpdater updateCollectionView:strongSelf->_collectionView withChange:change completion:nil];
        }
        
        if (strongSelf->_galleryMixin != nil && strongSelf->_fetchResult != nil)
            [strongSelf->_galleryMixin updateWithFetchResult:strongSelf->_fetchResult];
    }]];
}

#pragma mark -

- (NSInteger)_numberOfItems
{
    return _fetchResult.count;
}

- (id)_itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_fetchResult assetAtIndex:indexPath.row];
}

- (SSignal *)_signalForItem:(id)item
{
    SSignal *assetSignal = [TGMediaAssetImageSignals imageForAsset:item imageType:TGMediaAssetImageTypeThumbnail size:[_layoutMetrics imageSize]];
    return [[self.editingContext thumbnailImageSignalForItem:item] mapToSignal:^SSignal *(id result)
    {
        if (result != nil)
            return [SSignal single:result];
        else
            return assetSignal;
    }];
}

- (NSString *)_cellKindForItem:(id)item
{
    TGMediaAsset *asset = (TGMediaAsset *)item;
    if ([asset isKindOfClass:[TGMediaAsset class]])
    {
        switch (asset.type)
        {
            case TGMediaAssetVideoType:
                return TGMediaAssetsVideoCellKind;
                
            case TGMediaAssetGifType:
                if (_intent == TGMediaAssetsControllerSetProfilePhotoIntent)
                    return TGMediaAssetsPhotoCellKind;
                else
                    return TGMediaAssetsGifCellKind;
                
            default:
                break;
        }
    }
    return TGMediaAssetsPhotoCellKind;
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    TGMediaAsset *asset = [_fetchResult assetAtIndex:index];

    __block UIImage *thumbnailImage = nil;
    if ([TGMediaAssetsLibrary usesPhotoFramework])
    {
        TGMediaPickerCell *cell = (TGMediaPickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if ([cell isKindOfClass:[TGMediaPickerCell class]])
            thumbnailImage = cell.imageView.image;
    }
    else
    {
        [[TGMediaAssetImageSignals imageForAsset:asset imageType:TGMediaAssetImageTypeAspectRatioThumbnail size:CGSizeZero] startWithNext:^(UIImage *next)
        {
            thumbnailImage = next;
        }];
    }

    __weak TGMediaAssetsPickerController *weakSelf = self;
    if (_intent == TGMediaAssetsControllerSetProfilePhotoIntent)
    {
        TGPhotoEditorController *controller = [[TGPhotoEditorController alloc] initWithItem:asset intent:TGPhotoEditorControllerAvatarIntent adjustments:nil caption:nil screenImage:thumbnailImage availableTabs:[TGPhotoEditorController defaultTabsForAvatarIntent] selectedTab:TGPhotoEditorCropTab];
        controller.didFinishRenderingFullSizeImage = ^(UIImage *resultImage)
        {
            __strong TGMediaAssetsPickerController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [[strongSelf->_assetsLibrary saveAssetWithImage:resultImage] startWithNext:nil];
        };
        controller.didFinishEditing = ^(__unused id<TGMediaEditAdjustments> adjustments, UIImage *resultImage, __unused UIImage *thumbnailImage, bool hasChanges)
        {
            if (!hasChanges)
                return;
            
            __strong TGMediaAssetsPickerController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [(TGMediaAssetsController *)strongSelf.navigationController completeWithAvatarImage:resultImage];
        };
        
        controller.requestThumbnailImage = ^(id<TGMediaEditableItem> editableItem)
        {
            return [editableItem thumbnailImageSignal];
        };
        
        controller.requestOriginalScreenSizeImage = ^(id<TGMediaEditableItem> editableItem)
        {
            return [editableItem screenImageSignal];
        };
        
        controller.requestOriginalFullSizeImage = ^(id<TGMediaEditableItem> editableItem)
        {
            return [editableItem originalImageSignal];
        };
        
        [self.navigationController pushViewController:controller animated:true];
    }
    else
    {
        bool hasCaption = (_intent == TGMediaAssetsControllerSendMediaIntent && self.captionsEnabled);
        bool asFile = (_intent == TGMediaAssetsControllerSendFileIntent);
        
        _galleryMixin = [[TGMediaPickerModernGalleryMixin alloc] initWithItem:asset fetchResult:_fetchResult parentController:self thumbnailImage:thumbnailImage selectionContext:self.selectionContext editingContext:self.editingContext suggestionContext:self.suggestionContext hasCaption:hasCaption asFile:asFile itemsLimit:0];
        
        _galleryMixin.thumbnailSignalForItem = ^SSignal *(id item)
        {
            __strong TGMediaAssetsPickerController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            return [strongSelf _signalForItem:item];
        };
        
        _galleryMixin.referenceViewForItem = ^UIView *(TGMediaPickerGalleryItem *item)
        {
            __strong TGMediaAssetsPickerController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            for (TGMediaPickerCell *cell in [strongSelf->_collectionView visibleCells])
            {
                if ([cell.item isEqual:item.asset])
                    return cell;
            }
            
            return nil;
        };
        
        _galleryMixin.itemFocused = ^(TGMediaPickerGalleryItem *item)
        {
            __strong TGMediaAssetsPickerController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf _hideCellForItem:item.asset animated:false];
        };
        
        _galleryMixin.didTransitionOut = ^
        {
            __strong TGMediaAssetsPickerController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf _hideCellForItem:nil animated:true];
            strongSelf->_galleryMixin = nil;
        };
        
        _galleryMixin.completeWithItem = ^(TGMediaPickerGalleryItem *item)
        {
            __strong TGMediaAssetsPickerController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [(TGMediaAssetsController *)strongSelf.navigationController completeWithCurrentItem:item.asset];
        };
    
        [_galleryMixin present];
    }
}

#pragma mark - Asset Image Preheating

- (void)scrollViewDidScroll:(UIScrollView *)__unused scrollView
{
    bool isViewVisible = (self.isViewLoaded && self.view.window != nil);
    if (!isViewVisible)
        return;
    
    [_preheatMixin update];
}

- (NSArray *)_assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0)
        return nil;
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths)
    {
        if ((NSUInteger)indexPath.row < _fetchResult.count)
            [assets addObject:[_fetchResult assetAtIndex:indexPath.row]];
    }
    
    return assets;
}

@end
