#import "TGModernGalleryMessageImageItemView.h"

#import "TGModernGalleryMessageImageItem.h"

#import <LegacyComponents/TGModernGalleryEmbeddedStickersHeaderView.h>

#import <LegacyComponents/TGMenuSheetController.h>

#import "TGStickersMenu.h"
#import "TGDownloadMessagesSignal.h"
#import "TGMultipleStickerPacksCollectionItemView.h"
#import "TGLegacyComponentsContext.h"

@interface TGModernGalleryMessageImageItemView () {
    TGModernGalleryEmbeddedStickersHeaderView *_stickersHeaderView;
    
    SMetaDisposable *_stickersInfoDisposable;
    SVariable *_stickersInfo;
    bool _requestedStickersInfo;
}

@end

@implementation TGModernGalleryMessageImageItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _stickersInfoDisposable = [[SMetaDisposable alloc] init];
        _stickersInfo = [[SVariable alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_stickersInfoDisposable dispose];
    [_stickersInfo set:[SSignal single:nil]];
}

- (void)prepareForRecycle
{
    [super prepareForRecycle];
    
    [_stickersInfoDisposable setDisposable:nil];
    [_stickersInfo set:[SSignal single:nil]];
    _requestedStickersInfo = false;
}

- (UIView *)headerView {
    if ([self.item isKindOfClass:[TGModernGalleryImageItem class]] && ((TGModernGalleryImageItem *)self.item).hasStickers) {
        if (_stickersHeaderView == nil) {
            _stickersHeaderView = [[TGModernGalleryEmbeddedStickersHeaderView alloc] init];
            __weak TGModernGalleryMessageImageItemView *weakSelf = self;
            _stickersHeaderView.showEmbeddedStickers = ^{
                __strong TGModernGalleryMessageImageItemView *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf showEmbeddedStickerPacks];
                }
            };
        }
        return _stickersHeaderView;
    }
    
    return nil;
}

- (void)showEmbeddedStickerPacks {
    if ([self.item isKindOfClass:[TGModernGalleryImageItem class]] && ((TGModernGalleryImageItem *)self.item).hasStickers) {
        NSMutableArray *stickerPackReferences = [[NSMutableArray alloc] init];
        for (TGDocumentMediaAttachment *document in ((TGModernGalleryImageItem *)self.item).embeddedStickerDocuments) {
            for (id attribute in document.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
                    if (((TGDocumentAttributeSticker *)attribute).packReference != nil) {
                        if (![stickerPackReferences containsObject:((TGDocumentAttributeSticker *)attribute).packReference]) {
                            [stickerPackReferences addObject:((TGDocumentAttributeSticker *)attribute).packReference];
                        }
                    }
                }
            }
        }
        
        TGViewController *controller = [self.delegate parentControllerForPresentation];
        if (controller != nil) {
            CGRect sourceRect = _stickersHeaderView.bounds;
            if (stickerPackReferences.count == 1) {
                [TGStickersMenu presentInParentController:controller stickerPackReference:stickerPackReferences[0] showShareAction:false sendSticker:nil stickerPackRemoved:nil stickerPackHidden:nil sourceView:_stickersHeaderView sourceRect:^CGRect
                 {
                     return sourceRect;
                 }];
            } else if (stickerPackReferences.count != 0) {
                
            } else if (((TGModernGalleryImageItem *)self.item).imageId != 0) {
                if (!_requestedStickersInfo) {
                    _requestedStickersInfo = true;
                    TGImageMediaAttachment *imageMedia = [[TGImageMediaAttachment alloc] init];
                    imageMedia.imageId = ((TGModernGalleryImageItem *)self.item).imageId;
                    imageMedia.accessHash = ((TGModernGalleryImageItem *)self.item).accessHash;
                    [_stickersInfo set:[TGDownloadMessagesSignal mediaStickerpacks:imageMedia]];
                }
                
                __weak TGModernGalleryMessageImageItemView *weakSelf = self;
                [_stickersInfoDisposable setDisposable:[[[[[_stickersInfo signal] filter:^bool(id next) {
                    return next != nil;
                }] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray<TGStickerPack *> *stickerPacks) {
                    __strong TGModernGalleryMessageImageItemView *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        if (stickerPacks.count == 1) {
                            TGViewController *controller = [strongSelf.delegate parentControllerForPresentation];
                            [TGStickersMenu presentInParentController:controller stickerPack:stickerPacks[0] showShareAction:false sendSticker:nil stickerPackRemoved:nil stickerPackHidden:nil stickerPackArchived:false stickerPackIsMask:stickerPacks[0].isMask sourceView:strongSelf->_stickersHeaderView sourceRect:^CGRect{
                                return sourceRect;
                            }];
                        } else if (stickerPacks.count != 0) {
                            [strongSelf previewMultipleStickerPacks:stickerPacks];
                        }
                    }
                }]];
            }
        }
    }
}

- (void)previewStickerPack:(TGStickerPack *)stickerPack inMenuController:(TGMenuSheetController *)menuController {
    TGViewController *controller = [self.delegate parentControllerForPresentation];
    if (controller != nil) {
        CGRect sourceRect = _stickersHeaderView.bounds;
        [TGStickersMenu presentWithParentController:controller packReference:nil stickerPack:stickerPack showShareAction:false sendSticker:nil stickerPackRemoved:nil stickerPackHidden:nil stickerPackArchived:false stickerPackIsMask:stickerPack.isMask sourceView:_stickersHeaderView sourceRect:^CGRect{
            return sourceRect;
        } centered:true existingController:menuController];
    }
}

- (void)previewMultipleStickerPacks:(NSArray<TGStickerPack *> *)stickerPacks {
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
    __weak TGMenuSheetController *weakController = controller;
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.narrowInLandscape = true;
    CGRect sourceRect = [_stickersHeaderView convertRect:_stickersHeaderView.bounds toView:self];;
    controller.sourceRect = ^CGRect { return sourceRect; };
    controller.permittedArrowDirections = 0;
    
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    TGMultipleStickerPacksCollectionItemView *collectionItem = [[TGMultipleStickerPacksCollectionItemView alloc] init];
    [itemViews addObject:collectionItem];
    __weak TGModernGalleryMessageImageItemView *weakSelf = self;
    collectionItem.previewPack = ^(TGStickerPack *pack, __unused id<TGStickerPackReference> packReference) {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        //[strongController dismissAnimated:true manual:true];
        
        if (pack != nil) {
            __strong TGModernGalleryMessageImageItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf previewStickerPack:pack inMenuController:strongController];
            }
        }
    };
    [collectionItem setStickerPacks:stickerPacks animated:false];
    
    collectionItem.collapseInLandscape = false;
    
    TGMenuSheetButtonItemView *cancelButton = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
                                               {
                                                   __strong TGMenuSheetController *strongController = weakController;
                                                   if (strongController == nil)
                                                       return;
                                                   
                                                   [strongController dismissAnimated:true manual:true];
                                               }];
    [itemViews addObject:cancelButton];
    
    [controller setItemViews:itemViews];
    
    TGViewController *parentController = [self.delegate parentControllerForPresentation];
    if (parentController != nil) {
        [controller presentInViewController:parentController sourceView:parentController.view animated:true];
    }
}

@end
