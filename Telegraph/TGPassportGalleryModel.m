#import "TGPassportGalleryModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPassportGalleryItem.h"
#import "TGGenericPeerMediaGalleryDefaultFooterView.h"
#import "TGGenericPeerMediaGalleryDefaultHeaderView.h"
#import "TGGenericPeerMediaGalleryActionsAccessoryView.h"
#import <LegacyComponents/TGMenuSheetController.h>

#import "TGGenericPeerGalleryGroupItem.h"
#import "TGGenericPeerMediaGalleryDeleteAccessoryView.h"

#import <LegacyComponents/TGMediaAssetsUtils.h>

#import "MediaBox.h"
#import "TGTelegraph.h"
#import "PhotoResources.h"

#import "TGLegacyComponentsContext.h"

@interface TGPassportGalleryModel ()
{
    NSMutableDictionary *_groupedItems;
    
    TGGenericPeerMediaGalleryDefaultFooterView *_footerView;
}
@end

@implementation TGPassportGalleryModel

- (instancetype)initWithFiles:(NSArray *)files centralFile:(TGPassportFile *)centralFile {
    self = [super init];
    if (self != nil) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        id<TGModernGalleryItem> centralItem = nil;
        int32_t index = 1;
        NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *groupedItems = [[NSMutableDictionary alloc] init];
        for (id file in files) {
            TGPassportGalleryItem *item = [[TGPassportGalleryItem alloc] initWithIndex:index file:file];
            if ([file isEqual:centralFile])
                centralItem = item;
            
            [items addObject:item];
            index++;
//
//            if (media.groupedId != 0)
//            {
//                NSMutableArray *groupItems = groups[@(media.groupedId)];
//                if (groupItems == nil)
//                {
//                    groupItems = [[NSMutableArray alloc] init];
//                    groups[@(media.groupedId)] = groupItems;
//                }
//
//                [groupItems addObject:[[TGGenericPeerGalleryGroupItem alloc] initWithItemCollectionItem:item]];
//                item.groupItems = groupItems;
//                item.groupedId = media.groupedId;
//
//                groupedItems[@(item.index)] = item;
//            }
        }
        _groupedItems = groupedItems;
        if (centralItem == nil) {
            centralItem = items.firstObject;
        }
        [self _replaceItems:items focusingOnItem:centralItem];
    }
    return self;
}

- (UIView<TGModernGalleryDefaultFooterView> *)createDefaultFooterView
{
    __weak TGPassportGalleryModel *weakSelf = self;
    _footerView = [[TGGenericPeerMediaGalleryDefaultFooterView alloc] init];
    _footerView.groupItemChanged = ^(TGGenericPeerGalleryGroupItem *item, bool synchronously)
    {
        __strong TGPassportGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        id<TGGenericPeerGalleryItem> galleryItem = strongSelf->_groupedItems[@(item.keyId)];
        [strongSelf _focusOnItem:(id<TGModernGalleryItem>)galleryItem synchronously:synchronously];
    };
    return _footerView;
}

- (void)_interItemTransitionProgressChanged:(CGFloat)progress
{
    [_footerView setInterItemTransitionProgress:progress];
}

- (UIView<TGModernGalleryDefaultHeaderView> *)createDefaultHeaderView
{
    __weak TGPassportGalleryModel *weakSelf = self;
    return [[TGGenericPeerMediaGalleryDefaultHeaderView alloc] initWithPositionAndCountBlock:^(id<TGModernGalleryItem> item, NSUInteger *position, NSUInteger *count) {
        __strong TGPassportGalleryModel *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (position != NULL) {
                NSUInteger index = [strongSelf.items indexOfObject:item];
                if (index != NSNotFound) {
                    *position = index;
                }
            }
            if (count != NULL) {
                *count = strongSelf.items.count;
            }
        }
    }];
}

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *)createDefaultRightAccessoryView
{
    TGGenericPeerMediaGalleryDeleteAccessoryView *accessoryView = [[TGGenericPeerMediaGalleryDeleteAccessoryView alloc] init];
    __weak TGGenericPeerMediaGalleryDeleteAccessoryView *weakAccessoryView = accessoryView;
    __weak TGPassportGalleryModel *weakSelf = self;
    accessoryView.action = ^(id<TGModernGalleryItem> item)
    {
        __strong TGPassportGalleryModel *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            CGRect (^sourceRect)(void) = ^CGRect
            {
                __strong TGGenericPeerMediaGalleryDeleteAccessoryView *strongAccessoryView = weakAccessoryView;
                if (strongAccessoryView == nil)
                    return CGRectZero;
                
                return strongAccessoryView.bounds;
            };
            
            TGViewController *viewController = nil;
            if (strongSelf.viewControllerForModalPresentation) {
                viewController = (TGViewController *)strongSelf.viewControllerForModalPresentation();
            }
            
            __strong TGGenericPeerMediaGalleryDeleteAccessoryView *strongAccessoryView = weakAccessoryView;
            
            TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
            __weak TGMenuSheetController *weakController = controller;
            controller.dismissesByOutsideTap = true;
            controller.hasSwipeGesture = true;
            controller.narrowInLandscape = true;
            controller.sourceRect = sourceRect;
            controller.permittedArrowDirections = (UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown);
        
            NSMutableArray *itemViews = [[NSMutableArray alloc] init];
            TGMenuSheetButtonItemView *basicItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Delete") type:TGMenuSheetButtonTypeDestructive action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                [strongController dismissAnimated:true];
                
                [strongSelf _commitDeleteItem:item];
            }];
            [itemViews addObject:basicItem];
            
            TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                [strongController dismissAnimated:true];
            }];
            [itemViews addObject:cancelItem];
            
            [controller setItemViews:itemViews animated:true];
        
            [controller presentInViewController:viewController sourceView:strongAccessoryView animated:true];
        }
    };
    return accessoryView;
}

- (void)_commitDeleteItem:(TGPassportGalleryItem *)item
{
    if (self.dismiss)
        self.dismiss(true, false);
    
    if (self.deleteFile != nil)
        self.deleteFile(item.file);
}

@end

