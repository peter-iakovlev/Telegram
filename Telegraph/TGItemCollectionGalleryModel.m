#import "TGItemCollectionGalleryModel.h"

#import "TGItemCollectionGalleryItem.h"
#import "TGGenericPeerMediaGalleryDefaultFooterView.h"
#import "TGGenericPeerMediaGalleryDefaultHeaderView.h"
#import "TGGenericPeerMediaGalleryActionsAccessoryView.h"
#import "TGMenuSheetController.h"

#import "TGImageMediaAttachment.h"
#import "TGVideoMediaAttachment.h"

#import "TGMediaAssetsUtils.h"

#import "MediaBox.h"
#import "TGTelegraph.h"
#import "PhotoResources.h"

@implementation TGItemCollectionGalleryModel

- (instancetype)initWithMedias:(NSArray *)medias centralMedia:(TGInstantPageMedia *)centralMedia {
    self = [super init];
    if (self != nil) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        id<TGModernGalleryItem> centralItem = nil;
        for (TGInstantPageMedia *media in medias) {
            TGItemCollectionGalleryItem *item = [[TGItemCollectionGalleryItem alloc] initWithMedia:media];
            if ([media isEqual:centralMedia]) {
                centralItem = item;
            }
            [items addObject:item];
        }
        if (centralItem == nil) {
            centralItem = items.firstObject;
        }
        [self _replaceItems:items focusingOnItem:centralItem];
    }
    return self;
}

- (UIView<TGModernGalleryDefaultFooterView> *)createDefaultFooterView
{
    return [[TGGenericPeerMediaGalleryDefaultFooterView alloc] init];
}

- (UIView<TGModernGalleryDefaultHeaderView> *)createDefaultHeaderView
{
    __weak TGItemCollectionGalleryModel *weakSelf = self;
    return [[TGGenericPeerMediaGalleryDefaultHeaderView alloc] initWithPositionAndCountBlock:^(id<TGModernGalleryItem> item, NSUInteger *position, NSUInteger *count) {
        __strong TGItemCollectionGalleryModel *strongSelf = weakSelf;
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

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *)createDefaultLeftAccessoryView
{
    TGGenericPeerMediaGalleryActionsAccessoryView *accessoryView = [[TGGenericPeerMediaGalleryActionsAccessoryView alloc] init];
    __weak TGGenericPeerMediaGalleryActionsAccessoryView *weakAccessoryView = accessoryView;
    __weak TGItemCollectionGalleryModel *weakSelf = self;
    accessoryView.action = ^(id<TGModernGalleryItem> item)
    {
        if (![item isKindOfClass:[TGItemCollectionGalleryItem class]]) {
            return;
        }
        
        TGItemCollectionGalleryItem *galleryItem = (TGItemCollectionGalleryItem *)item;
        
        __strong TGItemCollectionGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        
        if ([galleryItem.media.media isKindOfClass:[TGVideoMediaAttachment class]]) {
            return;
        }
        
        TGViewController *viewController = nil;
        if (strongSelf.viewControllerForModalPresentation) {
            viewController = (TGViewController *)self.viewControllerForModalPresentation();
        }
        
        CGRect (^sourceRect)(void) = ^CGRect {
            __strong TGGenericPeerMediaGalleryActionsAccessoryView *strongAccessoryView = weakAccessoryView;
            if (strongAccessoryView == nil)
                return CGRectZero;
            
            return strongAccessoryView.bounds;
        };
        
        __strong TGGenericPeerMediaGalleryActionsAccessoryView *strongAccessoryView = weakAccessoryView;
        
        TGMenuSheetController *controller = [[TGMenuSheetController alloc] init];
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.narrowInLandscape = true;
        controller.sourceRect = sourceRect;
        
        NSString *actionTitle = TGLocalized(@"Preview.SaveToCameraRoll");

        __weak TGMenuSheetController *weakController = controller;
        TGMenuSheetButtonItemView *saveItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:actionTitle type:TGMenuSheetButtonTypeDefault action:^ {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController != nil) {
                [strongController dismissAnimated:true manual:true];
                
                if ([galleryItem.media.media isKindOfClass:[TGImageMediaAttachment class]]) {
                    [[[[TGTelegraphInstance.mediaBox resourceData:imageFullSizeResource(galleryItem.media.media, nil) pathExtension:nil] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(ResourceData *data) {
                        if (data.complete) {
                            [TGMediaAssetsSaveToCameraRoll saveImageWithData:[NSData dataWithContentsOfFile:data.path]];
                        }
                    }];
                } else if ([galleryItem.media.media isKindOfClass:[TGVideoMediaAttachment class]]) {
                    [[[[TGTelegraphInstance.mediaBox resourceData: videoFullSizeResource(galleryItem.media.media) pathExtension:@"mp4"] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(ResourceData *data) {
                        if (data.complete) {
                            [TGMediaAssetsSaveToCameraRoll saveVideoAtURL:[NSURL fileURLWithPath:data.path]];
                        }
                    }];
                }
                //saveAction();
            }
        }];

        TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^ {
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController != nil) {
                [strongController dismissAnimated:true manual:true];
            }
        }];

        [controller setItemViews:@[ saveItem, cancelItem ]];

        [controller presentInViewController:viewController sourceView:strongAccessoryView animated:true];
    };
    return accessoryView;
}

@end
