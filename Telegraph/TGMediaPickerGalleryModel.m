#import "TGMediaPickerGalleryModel.h"

#import "TGMediaPickerGallerySelectedItemsModel.h"

#import "TGModernGalleryController.h"
#import "TGModernGalleryItem.h"
#import "TGModernGallerySelectableItem.h"
#import "TGModernGalleryEditableItemView.h"
#import "TGModernGalleryZoomableItemView.h"
#import "TGMediaPickerGalleryVideoItemView.h"

#import "TGModernMediaListItem.h"
#import "TGModernMediaListSelectableItem.h"

#import "PGPhotoEditorValues.h"
#import "UIImage+TGEditablePhotoItem.h"

#import "TGOverlayControllerWindow.h"

@interface TGMediaPickerGalleryModel ()
{
    id<TGModernGalleryEditableItem> _itemBeingEdited;
    NSArray *_availableTabs;
    bool _forVideo;
}

@property (nonatomic, weak) TGPhotoEditorController *editorController;

@end

@implementation TGMediaPickerGalleryModel

- (instancetype)initWithItems:(NSArray *)items focusItem:(id<TGModernGalleryItem>)focusItem allowsSelection:(bool)allowsSelection allowsEditing:(bool)allowsEditing hasCaptions:(bool)hasCaptions forVideo:(bool)forVideo
{
    self = [super init];
    if (self != nil)
    {
        [self _replaceItems:items focusingOnItem:focusItem];
        
        _forVideo = forVideo;
        NSMutableArray *tabs = [[NSMutableArray alloc] init];
        if (hasCaptions)
            [tabs addObject:@(TGPhotoEditorCaptionTab)];
        [tabs addObject:@(TGPhotoEditorCropTab)];
        
        if (forVideo)
            [tabs addObject:@(TGPhotoEditorRotateTab)];
        else if (iosMajorVersion() >= 7)
            [tabs addObject:@(TGPhotoEditorToolsTab)];
        
        _availableTabs = tabs;

        __weak TGMediaPickerGalleryModel *weakSelf = self;
        _interfaceView = [[TGMediaPickerGalleryInterfaceView alloc] initWithFocusItem:focusItem allowsSelection:allowsSelection availableTabs:tabs];
        _interfaceView.allowsEditing = allowsEditing;
        [_interfaceView setEditorTabPressed:^(TGPhotoEditorTab tab)
        {
            __strong TGMediaPickerGalleryModel *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            __strong TGModernGalleryController *controller = strongSelf.controller;
            if ([controller.currentItem conformsToProtocol:@protocol(TGModernGalleryEditableItem)])
                [strongSelf presentPhotoEditorForItem:(id<TGModernGalleryEditableItem>)controller.currentItem tab:tab];
        }];
        _interfaceView.photoStripItemSelected = ^(NSInteger index)
        {
            __strong TGMediaPickerGalleryModel *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf setCurrentItemWithIndex:index];
        };
    }
    return self;
}

- (void)setCurrentItemWithListItem:(id<TGModernMediaListItem>)listItem direction:(TGModernGalleryScrollAnimationDirection)direction
{
    if (![listItem conformsToProtocol:@protocol(TGModernMediaListSelectableItem)])
        return;
    
    id<TGModernMediaListSelectableItem> selectableListItem = (id<TGModernMediaListSelectableItem>)listItem;
    
    __block NSUInteger newIndex = NSNotFound;
    [self.items enumerateObjectsUsingBlock:^(id<TGModernGalleryItem> galleryItem, NSUInteger idx, BOOL *stop)
     {
         if ([galleryItem conformsToProtocol:@protocol(TGModernGallerySelectableItem)])
         {
             id<TGModernGallerySelectableItem> selectableItem = (id<TGModernGallerySelectableItem>)galleryItem;
             
             if ([[selectableItem uniqueId] isEqual:[selectableListItem uniqueId]])
             {
                 newIndex = idx;
                 *stop = true;
             }
         }
     }];
    
    TGModernGalleryController *galleryController = self.controller;
    [galleryController setCurrentItemIndex:newIndex direction:direction animated:true];
}

- (void)setCurrentItemWithIndex:(NSUInteger)index
{
    if (self.selectedItemsModel == nil)
        return;
    
    TGModernGalleryController *galleryController = self.controller;
    
    if (![galleryController.currentItem conformsToProtocol:@protocol(TGModernGallerySelectableItem)])
        return;
    
    id<TGModernGallerySelectableItem> currentGalleryItem = (id<TGModernGallerySelectableItem>)galleryController.currentItem;

    __block NSUInteger currentSelectedItemIndex = NSNotFound;
    [self.selectedItemsModel.items enumerateObjectsUsingBlock:^(id<TGModernMediaListItem> listItem, NSUInteger idx, BOOL *stop)
    {
        if ([listItem conformsToProtocol:@protocol(TGModernMediaListSelectableItem)])
        {
            id<TGModernMediaListSelectableItem> selectableItem = (id<TGModernMediaListSelectableItem>)listItem;
            
            if ([[selectableItem uniqueId] isEqual:[currentGalleryItem uniqueId]])
            {
                currentSelectedItemIndex = idx;
                *stop = true;
            }
        }
    }];
    
    id<TGModernMediaListItem> listItem = self.selectedItemsModel.items[index];
    
    TGModernGalleryScrollAnimationDirection direction = TGModernGalleryScrollAnimationDirectionLeft;
    if (currentSelectedItemIndex < index)
        direction = TGModernGalleryScrollAnimationDirectionRight;
    
    [self setCurrentItemWithListItem:listItem direction:direction];
}

- (UIView <TGModernGalleryInterfaceView> *)createInterfaceView
{
    return _interfaceView;
}

- (UIView *)referenceViewForItem:(id<TGModernGalleryItem>)item frame:(CGRect *)frame
{
    TGModernGalleryController *galleryController = self.controller;
    TGModernGalleryItemView *galleryItemView = [galleryController itemViewForItem:item];
    
    if ([galleryItemView isKindOfClass:[TGModernGalleryZoomableItemView class]])
    {
        TGModernGalleryZoomableItemView *zoomableItemView = (TGModernGalleryZoomableItemView *)galleryItemView;
        
        if ([zoomableItemView.contentView isKindOfClass:[UIImageView class]])
        {
            if (frame != NULL)
                *frame = [zoomableItemView transitionViewContentRect];
            
            return (UIImageView *)zoomableItemView.contentView;
        }
    }
    else if ([galleryItemView isKindOfClass:[TGMediaPickerGalleryVideoItemView class]])
    {
        TGMediaPickerGalleryVideoItemView *videoItemView = (TGMediaPickerGalleryVideoItemView *)galleryItemView;
        
        if (frame != NULL)
            *frame = [videoItemView transitionViewContentRect];
        
        return (UIView *)videoItemView;
    }
    
    return nil;
}

- (void)updateHiddenItem
{
    TGModernGalleryController *galleryController = self.controller;
    
    for (TGModernGalleryItemView *itemView in galleryController.visibleItemViews)
    {
        if ([itemView conformsToProtocol:@protocol(TGModernGalleryEditableItemView)])
            [(TGModernGalleryItemView <TGModernGalleryEditableItemView> *)itemView setHiddenAsBeingEdited:[itemView.item isEqual:_itemBeingEdited]];
    }
}

- (void)updateEditedItemView
{
    TGModernGalleryController *galleryController = self.controller;
    
    for (TGModernGalleryItemView *itemView in galleryController.visibleItemViews)
    {
        if ([itemView conformsToProtocol:@protocol(TGModernGalleryEditableItemView)])
        {
            if ([itemView.item isEqual:_itemBeingEdited])
            {
                [(TGModernGalleryItemView <TGModernGalleryEditableItemView> *)itemView setItem:_itemBeingEdited synchronously:true];
                if (self.itemsUpdated != nil)
                    self.itemsUpdated(_itemBeingEdited);
            }
        }
    }
}

- (void)presentPhotoEditorForItem:(id<TGModernGalleryEditableItem>)item tab:(TGPhotoEditorTab)tab
{
    __weak TGMediaPickerGalleryModel *weakSelf = self;
    
    if (_itemBeingEdited != nil)
        return;
    
    _itemBeingEdited = item;

    id<TGEditablePhotoItem> editableMediaItem = [item editableMediaItem];
    PGPhotoEditorValues *editorValues = nil;
    if (editableMediaItem.fetchEditorValues != nil)
        editorValues = (PGPhotoEditorValues *)editableMediaItem.fetchEditorValues(editableMediaItem);
    
    NSString *caption = nil;
    if (editableMediaItem.fetchCaption != nil)
        caption = editableMediaItem.fetchCaption(editableMediaItem);

    CGRect refFrame = CGRectZero;
    UIView *editorReferenceView = [self referenceViewForItem:item frame:&refFrame];
    UIView *referenceView = nil;
    UIImage *screenImage = nil;
    UIView *referenceParentView = nil;
    UIImage *image = nil;
    
    if ([editorReferenceView isKindOfClass:[UIImageView class]])
    {
        screenImage = [(UIImageView *)editorReferenceView image];
        referenceView = editorReferenceView;
    }
    else if ([editorReferenceView isKindOfClass:[TGMediaPickerGalleryVideoItemView class]])
    {
        TGMediaPickerGalleryVideoItemView *videoItemView = (TGMediaPickerGalleryVideoItemView *)editorReferenceView;
        [videoItemView hideScrubbingPanelAnimated:true];
        [videoItemView setPlayButtonHidden:true animated:true];
        [videoItemView stop];
        refFrame = [videoItemView editorTransitionViewRect];
        screenImage = [videoItemView transitionImage];
        image = [videoItemView screenImage];
        referenceView = [[UIImageView alloc] initWithImage:screenImage];
        referenceParentView = editorReferenceView;
    }
    
    if (self.useGalleryImageAsEditableItemImage && self.storeOriginalImageForItem != nil)
        self.storeOriginalImageForItem(editableMediaItem, screenImage);
    
    TGPhotoEditorControllerIntent intent = _forVideo ? TGPhotoEditorControllerVideoIntent : TGPhotoEditorControllerGenericIntent;
    TGPhotoEditorController *controller = [[TGPhotoEditorController alloc] initWithItem:editableMediaItem intent:intent adjustments:editorValues caption:caption screenImage:screenImage availableTabs:_availableTabs selectedTab:tab];
    self.editorController = controller;
    controller.userListSignal = self.userListSignal;
    controller.hashtagListSignal = self.hashtagListSignal;
    controller.finishedEditing = ^(id<TGMediaEditAdjustments> adjustments, UIImage *resultImage, UIImage *thumbnailImage, bool noChanges)
    {
        __strong TGMediaPickerGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
#ifdef DEBUG
        if (adjustments != nil && !noChanges && !strongSelf->_forVideo)
            NSAssert(resultImage != nil, @"resultImage should not be nil");
#endif
        
        if (!noChanges)
        {
            if (strongSelf.saveEditedItem != nil)
                strongSelf.saveEditedItem(editableMediaItem, adjustments, resultImage, thumbnailImage);
            
            [strongSelf updateEditedItemView];
            [strongSelf.interfaceView updateEditedItem:strongSelf->_itemBeingEdited];
        }
        
        if ([editorReferenceView isKindOfClass:[TGMediaPickerGalleryVideoItemView class]])
        {
            TGMediaPickerGalleryVideoItemView *videoItemView = (TGMediaPickerGalleryVideoItemView *)editorReferenceView;
            [videoItemView presentScrubbingPanelAfterReload:!noChanges];
        }
        
        strongSelf->_itemBeingEdited = nil;
    };
    
    controller.captionSet = ^(NSString *caption)
    {
        __strong TGMediaPickerGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf.saveItemCaption != nil)
            strongSelf.saveItemCaption(editableMediaItem, caption);
        
        [strongSelf.interfaceView updateEditedItem:strongSelf->_itemBeingEdited];
    };
    
    controller.requestToolbarsHidden = ^(bool hidden, bool animated)
    {
        __strong TGMediaPickerGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf.interfaceView setToolbarsHidden:hidden animated:animated];
    };
    
    controller.beginTransitionIn = ^UIView *(CGRect *referenceFrame, __unused UIView **parentView)
    {
        __strong TGMediaPickerGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        [strongSelf updateHiddenItem];
        [strongSelf.interfaceView setSelectionInterfaceHidden:true animated:true];
        
        *referenceFrame = refFrame;
        
        if (referenceView.superview == nil)
            *parentView = referenceParentView;
        
        return referenceView;
    };
    
    controller.finishedTransitionIn = ^
    {
        __strong TGMediaPickerGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGModernGalleryController *galleryController = strongSelf.controller;
        TGModernGalleryItemView *galleryItemView = [galleryController itemViewForItem:strongSelf->_itemBeingEdited];
        if (![galleryItemView isKindOfClass:[TGModernGalleryZoomableItemView class]])
            return;
        
        TGModernGalleryZoomableItemView *zoomableItemView = (TGModernGalleryZoomableItemView *)galleryItemView;
        [zoomableItemView reset];
        
        [strongSelf.interfaceView setSelectedItemsModel:strongSelf.selectedItemsModel];
    };
    
    controller.beginTransitionOut = ^UIView *(CGRect *referenceFrame, __unused UIView **parentView)
    {
        __strong TGMediaPickerGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        [strongSelf.interfaceView setSelectionInterfaceHidden:false animated:true];
        
        CGRect refFrame;
        UIView *referenceView = [strongSelf referenceViewForItem:item frame:&refFrame];
        if ([referenceView isKindOfClass:[TGMediaPickerGalleryVideoItemView class]])
        {
            TGMediaPickerGalleryVideoItemView *videoItemView = (TGMediaPickerGalleryVideoItemView *)referenceView;
            refFrame = [videoItemView editorTransitionViewRect];
            UIImage *screenImage = [videoItemView transitionImage];
            *parentView = referenceView;
            referenceView = [[UIImageView alloc] initWithImage:screenImage];
        }
        
        *referenceFrame = refFrame;
        
        return referenceView;
    };
    
    controller.finishedTransitionOut = ^(__unused bool saved)
    {
        __strong TGMediaPickerGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf updateHiddenItem];
        
        UIView *referenceView = [strongSelf referenceViewForItem:item frame:NULL];
        if ([referenceView isKindOfClass:[TGMediaPickerGalleryVideoItemView class]])
            [(TGMediaPickerGalleryVideoItemView *)referenceView setPlayButtonHidden:false animated:true];
    };
    
    if (_forVideo)
    {
        controller.requestImage = ^
        {
            return image;
        };
    }
    
    TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:(TGViewController *)self.controller contentController:controller];
    controllerWindow.windowLevel = ((TGViewController *)self.controller).view.window.windowLevel + 0.0001f;
    controllerWindow.hidden = false;
    controller.view.clipsToBounds = true;
}

- (void)_replaceItems:(NSArray *)items focusingOnItem:(id<TGModernGalleryItem>)item
{
    [super _replaceItems:items focusingOnItem:item];
 
    TGModernGalleryController *controller = self.controller;
    
    for (TGModernGalleryItemView *itemView in controller.visibleItemViews)
        [itemView setItem:itemView.item synchronously:false];
}

- (bool)_shouldAutorotate
{
    TGPhotoEditorController *editorController = self.editorController;
    return (!editorController || [editorController shouldAutorotate]);
}

@end
