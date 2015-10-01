#import "TGAttachmentSheetRecentItemView.h"

#import "TGModernMediaCollectionView.h"
#import "TGAttachmentSheetRecentLayout.h"
#import "TGAttachmentSheetRecentAssetCell.h"

#import "TGAttachmentSheetRecentCameraView.h"

#import "TGMediaPickerAssetsLibrary.h"
#import "TGMediaPickerAssetsGroup.h"
#import "TGMediaPickerAsset.h"
#import "TGMediaPickerItem.h"
#import "TGMediaPickerAsset+TGEditablePhotoItem.h"

#import "TGModernGalleryController.h"
#import "TGMediaPickerGalleryPhotoItem.h"
#import "TGMediaPickerGalleryModel.h"
#import "TGOverlayControllerWindow.h"
#import "TGMediaPickerGallerySelectedItemsModel.h"
#import "TGMediaEditingContext.h"
#import "TGPhotoEditorUtils.h"

#import "TGAttachmentSheetRecentControlledButtonItemView.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>

#import <SSignalKit/SSignalKit.h>
#import "TGAssetImageManager.h"
#import "PGPhotoEditorValues.h"

@interface TGAttachmentSheetRecentItemView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    TGAttachmentSheetItemViewMode _mode;
    
    UICollectionView *_collectionView;
    TGAttachmentSheetRecentLayout *_layout;
    
    TGMediaPickerAssetsLibrary *_assetsLibrary;
    NSArray *_items;
    NSArray *_selectedItems;

    bool (^_isItemSelected)(TGMediaPickerItem *);
    bool (^_isItemHidden)(TGMediaPickerItem *);
    void (^_changeItemSelection)(TGMediaPickerItem *);
    void (^_changeGalleryItemSelection)(id<TGModernGalleryItem>, TGMediaPickerGallerySelectedItemsModel *);
    void (^_openItem)(TGMediaPickerItem *);
    
    TGAttachmentSheetRecentControlledButtonItemView *_multifunctionButtonView;
    TGAttachmentSheetRecentCameraView *_cameraView;
    
    __weak TGMediaPickerGalleryModel *_galleryModel;
    __weak TGMediaPickerItem *_hiddenItem;
    
    TGMediaEditingContext *_editingContext;
    
    id<TGMediaEditAdjustments> (^_fetchEditorValues)(TGMediaPickerAsset *);
    NSString *(^_fetchCaption)(TGMediaPickerAsset *);
    UIImage *(^_fetchThumbnailImage)(TGMediaPickerAsset *);
    UIImage *(^_fetchScreenImage)(TGMediaPickerAsset *);
    
    __weak TGViewController *_parentController;
}
@end

@implementation TGAttachmentSheetRecentItemView

- (instancetype)initWithParentController:(TGViewController *)controller mode:(TGAttachmentSheetItemViewMode)mode
{
    self = [super init];
    if (self != nil)
    {
        _parentController = controller;
        _mode = mode;
        
        _layout = [[TGAttachmentSheetRecentLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[TGModernMediaCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.backgroundColor = nil;
        _collectionView.opaque = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.delaysContentTouches = false;
        _collectionView.canCancelContentTouches = true;
        
        __weak TGAttachmentSheetRecentItemView *weakSelf = self;
        
        _cameraView = [[TGAttachmentSheetRecentCameraView alloc] initWithFrontCamera:(mode == TGAttachmentSheetItemViewSetProfilePhotoMode)];
        
        __weak TGAttachmentSheetRecentCameraView *weakCameraView = _cameraView;
        _cameraView.frame = CGRectMake(5.0f, 5.0f, 78.0f, 78.0f);
        _cameraView.pressed = ^
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf.openCamera && strongSelf->_galleryModel == nil)
                strongSelf.openCamera(weakCameraView);
        };
        [_collectionView addSubview:_cameraView];
        
        [_cameraView startPreview];
        
        [_collectionView registerClass:[TGAttachmentSheetRecentAssetCell class] forCellWithReuseIdentifier:@"TGAttachmentSheetRecentAssetCell"];
        [self addSubview:_collectionView];
        
        _editingContext = [[TGMediaEditingContext alloc] init];
        
        _changeGalleryItemSelection = ^(TGMediaPickerGalleryItem *item, TGMediaPickerGallerySelectedItemsModel *gallerySelectedItems)
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGMediaPickerItem *listItem = [strongSelf listItemForAsset:[item asset]];
                
                if (listItem != nil)
                {
                    bool added = [strongSelf toggleItemSelected:listItem];
                    
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
        
        _fetchEditorValues = ^id<TGMediaEditAdjustments> (id<TGEditablePhotoItem> item)
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_editingContext adjustmentsForItemId:item.uniqueId];
            return nil;
        };
        
        _fetchThumbnailImage = ^UIImage *(id<TGEditablePhotoItem> item)
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_editingContext thumbnailImageForItemId:item.uniqueId];
            return nil;
        };
        
        _fetchCaption = ^NSString *(id<TGEditablePhotoItem> item)
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_editingContext captionForItemId:item.uniqueId];
            return nil;
        };
        
        _fetchScreenImage = ^UIImage *(id<TGEditablePhotoItem> item)
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_editingContext imageForItemId:item.uniqueId];
            return nil;
        };
        
        _isItemSelected = ^bool (TGMediaPickerItem *item)
        {
            if (item == nil)
                return false;
            
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_selectedItems containsObject:item];
            return false;
        };
        
        _isItemHidden = ^bool (TGMediaPickerItem *item)
        {
            if (item == nil)
                return false;
            
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGMediaPickerItem *strongHiddenItem = strongSelf->_hiddenItem;
                return [strongHiddenItem isEqual:item];
            }
            return false;
        };
        
        _changeItemSelection = ^(TGMediaPickerItem *item)
        {
            if (item == nil)
                return;
            
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf toggleItemSelected:item];
        };
        
        _openItem = ^(TGMediaPickerItem *item)
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf _openItem:item];
        };
        
        _assetsLibrary = [[TGMediaPickerAssetsLibrary alloc] initForAssetType:TGMediaPickerAssetPhotoType];
        _assetsLibrary.libraryChanged = ^
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf _handleAssetsLibraryChanged];
        };
        [self reloadData];
    }
    return self;
}

- (void)reloadData
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    NSMutableArray *assetsToCache = [[NSMutableArray alloc] init];
    
    __block NSInteger index = 0;
    [_assetsLibrary fetchAssetsOfAssetsGroup:nil reversed:true withEnumerationBlock:^(TGMediaPickerAsset *asset, TGMediaPickerAuthorizationStatus status, __unused NSError *error)
    {
        bool reloadNeeded = false;
        
        if (asset != nil)
        {
            asset.fetchEditorValues = _fetchEditorValues;
            asset.fetchCaption = _fetchCaption;
            asset.fetchThumbnailImage = _fetchThumbnailImage;
            asset.fetchScreenImage = _fetchScreenImage;
            
            __weak TGAttachmentSheetRecentItemView *weakSelf = self;
            void(^itemSelected)(id<TGModernMediaListItem>, bool) = nil;
            bool(^isItemSelected)(id<TGModernMediaListItem>) = nil;
            if (_mode == TGAttachmentSheetItemViewSendPhotoMode)
            {
                itemSelected = ^(TGMediaPickerItem *item, __unused bool updateInterface)
                {
                    __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
                    if (strongSelf != nil)
                        [strongSelf toggleItemSelected:item];
                };
                isItemSelected = ^bool(TGMediaPickerItem *item)
                {
                    __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
                    if (strongSelf != nil)
                        return strongSelf->_isItemSelected(item);
                    return false;
                };
            }
        
            [items addObject:[[TGMediaPickerItem alloc] initWithAsset:asset itemSelected:itemSelected isItemSelected:isItemSelected isItemHidden:^bool(TGMediaPickerItem *item)
            {
                __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
                if (strongSelf != nil)
                    return strongSelf->_isItemHidden(item);
                return false;
            }]];
            
            index++;
            if (_items == nil && index == 8)
                reloadNeeded = true;
        }
        else if (status != TGMediaPickerAuthorizationStatusAuthorized && status != TGMediaPickerAuthorizationStatusNotDetermined)
        {
            return;
        }
        
        if (asset == nil || reloadNeeded)
        {
            NSArray *loadedItems = items;
            if (reloadNeeded)
                loadedItems = [items copy];
        
            TGDispatchOnMainThread(^
            {
                bool fadeIn = (_items.count == 0);
                
                if (_items == nil && reloadNeeded)
                {
                    TGDispatchAfter(1.0f, dispatch_get_main_queue(), ^
                    {
                        CGFloat thumbnailImageSide = TGPhotoThumbnailSizeForCurrentScreen().width * [UIScreen mainScreen].scale;
                        [TGAssetImageManager startCachingImagesForAssets:assetsToCache
                                                                    size:CGSizeMake(thumbnailImageSide, thumbnailImageSide)
                                                               imageType:TGAssetImageTypeThumbnail];
                    });
                }
                
                _items = loadedItems;
                [_collectionView reloadData];
                [_collectionView layoutSubviews];
                
                if (!reloadNeeded)
                    [self actualizeSelectedItems];

                _collectionView.scrollEnabled = !reloadNeeded;
                
                if (fadeIn)
                {
                    for (UIView *cell in _collectionView.visibleCells)
                        cell.alpha = 0.0f;
                    
                    [UIView animateWithDuration:0.12f animations:^
                    {
                        for (UIView *cell in _collectionView.visibleCells)
                             cell.alpha = 1.0f;
                    }];
                }
            });
        }
    }];
}

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
    
    [self _updateCellSelections];
}

- (void)_handleAssetsLibraryChanged
{
    [self reloadData];
}

- (void)_openItem:(TGMediaPickerItem *)item
{
    for (UIView *sibling in self.superview.subviews.reverseObjectEnumerator)
    {
        if ([sibling isKindOfClass:[TGAttachmentSheetItemView class]])
        {
            if (sibling != self)
            {
                [self.superview exchangeSubviewAtIndex:[self.superview.subviews indexOfObject:self] withSubviewAtIndex:[self.superview.subviews indexOfObject:sibling]];
            }
            break;
        }
    }
    
    if (self.itemOpened != nil)
        self.itemOpened();
    
    __block UIImage *thumbnailImage = nil;
    if (![TGAssetImageManager usesLegacyAssetsLibrary])
    {
        for (TGAttachmentSheetRecentAssetCell *itemView in [_collectionView visibleCells])
        {
            if ([itemView.item isEqual:item])
            {
                thumbnailImage = [itemView imageForAsset:item.asset];
                break;
            }
        }
    }
    else
    {
        [TGAssetImageManager requestImageWithAsset:item.asset imageType:TGAssetImageTypeAspectRatioThumbnail size:CGSizeZero completionBlock:^(UIImage *image, __unused NSError *error)
        {
            thumbnailImage = image;
        }];
    }
    
    TGOverlayController *overlayController = nil;
    if (_mode == TGAttachmentSheetItemViewSendPhotoMode)
    {
        TGModernGalleryController *controller = [self createGalleryControllerForItem:item withThumbnailImage:thumbnailImage];
        overlayController = controller;
    }
    else
    {
        _hiddenItem = item;
        
        UIView *referenceView = [self referenceViewForAsset:[item asset]];
        CGRect refFrame = [referenceView.superview convertRect:referenceView.frame toView:nil];
        
        __weak TGAttachmentSheetRecentItemView *weakSelf = self;
        TGPhotoEditorController *controller = [[TGPhotoEditorController alloc] initWithItem:item.asset intent:TGPhotoEditorControllerAvatarIntent adjustments:nil caption:nil screenImage:thumbnailImage availableTabs:[TGPhotoEditorController defaultTabsForAvatarIntent] selectedTab:TGPhotoEditorCropTab];
        controller.dontHideStatusBar = true;
        
        __weak TGPhotoEditorController *weakController = controller;
        controller.finishedEditing = ^(PGPhotoEditorValues *editorValues, UIImage *resultImage, __unused UIImage *thumbnailImage, __unused bool noChanges)
        {
            if (noChanges)
                return;
            
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (strongSelf.avatarCreated != nil)
                strongSelf.avatarCreated(resultImage);
            
            if ([editorValues toolsApplied])
                [[TGMediaPickerAssetsLibrary sharedLibrary] saveAssetWithImage:resultImage completionBlock:nil];
        };

        controller.beginTransitionIn = ^UIView *(CGRect *referenceFrame, UIView **parentView)
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            [strongSelf updateHiddenItem:false];
            
            TGViewController *parentController = strongSelf->_parentController;
            if (parentController != nil)
                *parentView = parentController.associatedWindowStack.firstObject;
            *referenceFrame = refFrame;
            
            return referenceView;
        };
        
        controller.finishedTransitionIn = ^
        {
            __strong TGPhotoEditorController *strongController = weakController;
            if (strongController != nil)
                strongController.view.backgroundColor = [UIColor blackColor];
        };
        
        controller.beginTransitionOut = ^UIView *(CGRect *referenceFrame, UIView **parentView)
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            TGViewController *parentController = strongSelf->_parentController;
            if (parentController != nil)
                *parentView = parentController.associatedWindowStack.firstObject;
            *referenceFrame = [referenceView.superview convertRect:referenceView.frame toView:nil];
            
            __strong TGPhotoEditorController *strongController = weakController;
            if (strongController != nil)
                strongController.view.backgroundColor = [UIColor clearColor];
            
            return [strongSelf referenceViewForAsset:[item asset]];
        };
        
        controller.finishedTransitionOut = ^(__unused bool saved)
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            strongSelf->_hiddenItem = nil;
            
            [strongSelf updateHiddenItem:true];
        };
        
        overlayController = controller;
    }
    
    if (overlayController != nil)
    {
        TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:_parentController contentController:overlayController];
        controllerWindow.windowLevel = self.window.windowLevel + 0.0001f;
        controllerWindow.hidden = false;
        overlayController.view.clipsToBounds = true;
        overlayController.view.backgroundColor = [UIColor clearColor];
    }
}

- (NSArray *)prepareGalleryItemsWithSelectedItemsModel:(TGMediaPickerGallerySelectedItemsModel *)selectedItemsModel enumerationBlock:(void (^)(TGMediaPickerGalleryItem *item))enumerationBlock
{
    __weak TGAttachmentSheetRecentItemView *weakSelf = self;
    __weak TGMediaPickerGallerySelectedItemsModel *weakSelectedItemsModel = selectedItemsModel;
    
    NSMutableArray *galleryItems = [[NSMutableArray alloc] init];
    
    for (TGMediaPickerItem *listItem in _items)
    {
        if (listItem.asset.isVideo)
            continue;
        
        TGMediaPickerGalleryPhotoItem *galleryItem = [[TGMediaPickerGalleryPhotoItem alloc] initWithAsset:listItem.asset];
        galleryItem.itemSelected = ^(id<TGModernGallerySelectableItem> item)
        {
            __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
                
            strongSelf->_changeGalleryItemSelection(item, weakSelectedItemsModel);
        };
        
        if (enumerationBlock != nil)
            enumerationBlock(galleryItem);
        
        if (galleryItem != nil)
            [galleryItems addObject:galleryItem];
    }
    
    return galleryItems;
}

- (TGModernGalleryController *)createGalleryControllerForItem:(TGMediaPickerItem *)item withThumbnailImage:(UIImage *)thumbnailImage
{
    if (_galleryModel != nil || !_cameraView.previewViewAttached)
        return nil;
    
    TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
    __weak TGAttachmentSheetRecentItemView *weakSelf = self;
    
    void (^itemSelected)(TGMediaPickerItem *) = ^(TGMediaPickerItem *item)
    {
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGMediaPickerItem *listItem = [strongSelf listItemForAsset:[item asset]];
            
            if (listItem != nil)
                strongSelf->_changeItemSelection(listItem);
            
            TGMediaPickerGalleryModel *galleryModel = strongSelf->_galleryModel;
            [galleryModel.interfaceView updateSelectionInterface:galleryModel.selectedItemsModel.selectedCount
                                                  counterVisible:(galleryModel.selectedItemsModel.totalCount > 0)
                                                        animated:true];
        }
    };
    bool(^isItemSelected)(TGMediaPickerItem *) = ^bool(TGMediaPickerItem *item)
    {
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (item != nil)
                return strongSelf->_isItemSelected(item);
        }
        
        return false;
    };
    
    TGMediaPickerGallerySelectedItemsModel *selectedItemsModel = [[TGMediaPickerGallerySelectedItemsModel alloc] initWithSelectedItems:_selectedItems itemSelected:itemSelected isItemSelected:isItemSelected];
    
    __weak TGMediaPickerGallerySelectedItemsModel *weakSelectedPhotosModel = selectedItemsModel;
    selectedItemsModel.selectionUpdated = ^(bool reload, bool incremental, bool add, NSInteger index)
    {
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
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
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
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
    
    TGMediaPickerGalleryModel *model = [[TGMediaPickerGalleryModel alloc] initWithItems:galleryItems focusItem:focusItem allowsSelection:true allowsEditing:true hasCaptions:!self.disallowCaptions forVideo:false];
    _galleryModel = model;
    model.controller = modernGallery;
    model.selectedItemsModel = selectedItemsModel;
    model.saveEditedItem = ^(id<TGEditablePhotoItem> editableItem, id<TGMediaEditAdjustments> editorValues, UIImage *resultImage, UIImage *thumbnailImage)
    {
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
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
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_editingContext setCaption:caption forItemId:editableItem.uniqueId synchronous:true];
        
        if (caption.length > 0)
            [strongSelf _selectItemIfApplicable:editableItem];
    };
    [model.interfaceView updateSelectionInterface:_selectedItems.count counterVisible:(_selectedItems.count > 0) animated:false];
    [model.interfaceView setSelectedItemsModel:selectedItemsModel];
    
    model.interfaceView.itemSelected = ^(TGMediaPickerGalleryItem *item)
    {
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_changeGalleryItemSelection(item, weakSelectedPhotosModel);
    };
    
    model.interfaceView.isItemSelected = ^bool (TGMediaPickerGalleryItem *item)
    {
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
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
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGMediaPickerItem *listItem = [strongSelf listItemForAsset:[item asset]];
            
            NSMutableArray *selectedItems = [strongSelf->_selectedItems mutableCopy];
            if (selectedItems == nil)
                selectedItems = [[NSMutableArray alloc] init];
            
            if (listItem != nil && ![selectedItems containsObject:listItem])
                [selectedItems addObject:listItem];
            
            strongSelf->_selectedItems = selectedItems;
            
            [strongSelf complete];
        }
    };
    model.userListSignal = self.userListSignal;
    model.hashtagListSignal = self.hashtagListSignal;
    
    modernGallery.model = model;
    modernGallery.itemFocused = ^(TGMediaPickerGalleryItem *item)
    {
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGMediaPickerItem *listItem = [strongSelf listItemForAsset:[item asset]];
            strongSelf->_hiddenItem = listItem;
            [strongSelf updateHiddenItem:false];
        }
    };
    
    modernGallery.beginTransitionIn = ^UIView *(TGMediaPickerGalleryItem *item, __unused TGModernGalleryItemView *itemView)
    {
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_cameraView pausePreview];
            return [strongSelf referenceViewForAsset:[item asset]];
        }
        return nil;
    };
    
    modernGallery.beginTransitionOut = ^UIView *(TGMediaPickerGalleryItem *item)
    {
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_cameraView resumePreview];
            return [strongSelf referenceViewForAsset:[item asset]];
        }
        return nil;
    };
    
    modernGallery.completedTransitionOut = ^
    {
        __strong TGAttachmentSheetRecentItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf->_hiddenItem = nil;
            [strongSelf updateHiddenItem:true];
        }
    };
    
    return modernGallery;
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

- (UIView *)referenceViewForAsset:(TGMediaPickerAsset *)asset
{
    for (TGAttachmentSheetRecentAssetCell *cell in _collectionView.visibleCells)
    {
        UIView *result = [cell referenceViewForAsset:asset];
        if (result != nil)
            return result;
    }
    
    return nil;
}

- (NSArray *)selectedItems
{
    return _selectedItems;
}

- (bool)toggleItemSelected:(id<TGModernMediaListSelectableItem>)item
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
    
    [self _updateCellSelections];
    
    return addedItem;
}

- (void)setSelectedItems:(NSArray *)selectedItems animated:(bool)__unused animated
{
    _selectedItems = selectedItems;
}

- (void)updateEditedItem:(TGMediaPickerItem *)item
{
    for (TGAttachmentSheetRecentAssetCell *itemView in [_collectionView visibleCells])
    {
        if ([itemView.item isEqual:item])
            [itemView updateItem];
    }
}

- (void)updateHiddenItem:(bool)animated
{
    for (TGAttachmentSheetRecentAssetCell *cell in _collectionView.visibleCells)
    {
        [cell updateHidden:animated];
    }
}

- (void)setMultifunctionButtonView:(TGAttachmentSheetRecentControlledButtonItemView *)multifunctionButtonView
{
    _multifunctionButtonView = multifunctionButtonView;
}

- (NSArray *)selectedItemSignals:(id (^)(UIImage *, NSString *, NSString *))imageDescriptionGenerator
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    TGMediaEditingContext *editingContext = _editingContext;
    for (TGMediaPickerItem *item in _items)
    {
        if ([_selectedItems containsObject:item])
        {
            NSString *caption = [editingContext captionForItemId:item.uniqueId];
            
            if ([editingContext adjustmentsForItemId:item.uniqueId] != nil)
            {
                [result addObject:[[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
                {
                    UIImage *image = [editingContext imageForItemId:item.uniqueId];
                    if (image != nil)
                    {
                        id generatedItem = imageDescriptionGenerator(image, caption, nil);
                        if (generatedItem != nil)
                            [subscriber putNext:generatedItem];
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
                                id generatedItem = imageDescriptionGenerator(image, caption, hash);
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
    
    return result;
}

- (void)complete
{
    TGMediaPickerGalleryModel *galleryModel = _galleryModel;
    if (galleryModel != nil)
    {
        if (galleryModel.dismiss)
            galleryModel.dismiss(true, false);
    }
    
    if (_done)
        _done();
}

- (CGFloat)preferredHeight
{
    return 88.0f;
}

- (bool)wantsFullSeparator
{
    return true;
}

- (void)sheetDidAppear
{
    [super sheetDidAppear];
}

- (void)sheetWillDisappear
{
    [super sheetWillDisappear];
    
    [_cameraView stopPreview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _collectionView.frame = self.bounds;
}

- (void)_updateCellSelections
{
    for (id cell in _collectionView.visibleCells)
    {
        if ([cell isKindOfClass:[TGAttachmentSheetRecentAssetCell class]])
        {
            [(TGAttachmentSheetRecentAssetCell *)cell updateSelection];
        }
    }
    
    if (_selectedItems.count != 0)
        [_multifunctionButtonView setAlternateWithTitle:[self stringForSendPhotos:_selectedItems.count]];
    else
        [_multifunctionButtonView setDefault];
}

- (NSString *)stringForSendPhotos:(NSUInteger)count
{
    NSString *format = TGLocalized(@"QuickSend.Photos_any");
    if (count == 1)
        format =  TGLocalized(@"QuickSend.Photos_1");
    else if (count == 2)
        format =  TGLocalized(@"QuickSend.Photos_2");
    else if (count >= 3 && count <= 10)
        format =  TGLocalized(@"QuickSend.Photos_3_10");
    
    return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", (int)count]];
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return CGSizeMake(78.0f, 78.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    return UIEdgeInsetsMake(5.0f, 5.0f + 78.0f + 5.0f, 5.0f, 5.0f);
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 5.0f;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
        return _items.count;
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGAttachmentSheetRecentAssetCell *cell = (TGAttachmentSheetRecentAssetCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGAttachmentSheetRecentAssetCell" forIndexPath:indexPath];
    
    TGMediaPickerItem *item = _items[indexPath.row];
    [cell setItem:item isItemSelected:item.isItemSelected isItemHidden:item.isItemHidden changeItemSelection:item.itemSelected openItem:_openItem];
    return cell;
}

@end
