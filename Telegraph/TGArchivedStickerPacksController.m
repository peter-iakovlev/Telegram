#import "TGArchivedStickerPacksController.h"

#import "TGStickersSignals.h"
#import "TGMaskStickersSignals.h"

#import "TGStickerPack.h"

#import "TGStickerPackCollectionItem.h"

#import "TGStickersMenu.h"

#import "TGProgressWindow.h"

#import "TGCommentCollectionItem.h"

#import "TGArchivedStickerPacksAlert.h"

#import "TGActionSheet.h"
#import "TGMenuSheetController.h"

@interface TGArchivedStickerPacksController () {
    SMetaDisposable *_packsDisposable;
    SMetaDisposable *_currentPacksDisposable;
    
    NSArray<TGStickerPack *> *_packs;
    NSSet<NSNumber *> *_installedPackIds;
    
    UIActivityIndicatorView *_activityIndicator;
    
    TGCollectionMenuSection *_stickerPacksSection;
    
    bool _masksMode;
}

@end

@implementation TGArchivedStickerPacksController

- (instancetype)init {
    return [self initWithMasksMode:false];
}

- (instancetype)initWithMasksMode:(bool)masksMode {
    self = [super init];
    if (self != nil) {
        _masksMode = masksMode;
        
        self.title = masksMode ? TGLocalized(@"StickerPacksSettings.ArchivedMasks") : TGLocalized(@"StickerPacksSettings.ArchivedPacks");
        
        TGCommentCollectionItem *infoItem = [[TGCommentCollectionItem alloc] initWithFormattedText:masksMode ? TGLocalized(@"StickerPacksSettings.ArchivedMasks.Info") : TGLocalized(@"StickerPacksSettings.ArchivedPacks.Info")];
        TGCollectionMenuSection *infoSection = [[TGCollectionMenuSection alloc] initWithItems:@[infoItem]];
        infoSection.insets = UIEdgeInsetsMake(24.0f, 0.0f, 16.0f, 0.0f);
        [self.menuSections addSection:infoSection];
        
        _stickerPacksSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
        _stickerPacksSection.insets = UIEdgeInsetsMake(8.0f, 0.0f, 16.0f, 0.0f);
        [self.menuSections addSection:_stickerPacksSection];
        
        _packsDisposable = [[SMetaDisposable alloc] init];
        __weak TGArchivedStickerPacksController *weakSelf = self;
        SSignal *stickerPacksSignal = (_masksMode ? [TGMaskStickersSignals stickerPacks] : [TGStickersSignals stickerPacks]);
        _currentPacksDisposable = [[stickerPacksSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict) {
            __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSMutableSet *installedPackIds = [[NSMutableSet alloc] init];
                for (TGStickerPack *pack in dict[@"packs"]) {
                    if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
                        [installedPackIds addObject:@(((TGStickerPackIdReference *)pack.packReference).packId)];
                    }
                }
                strongSelf->_installedPackIds = installedPackIds;
                if (strongSelf->_packs != nil) {
                    [strongSelf setPacks:[strongSelf filteredPacks:strongSelf->_packs]];
                }
            }
        }];
        
        [self loadMore];
    }
    return self;
}

- (void)dealloc {
    [_currentPacksDisposable dispose];
    [_packsDisposable dispose];
}

- (void)loadView
{
    [super loadView];
    
    if (_packs == nil)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activityIndicator.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        self.collectionView.hidden = true;
    }
}

- (NSArray<TGStickerPack *> *)filteredPacks:(NSArray<TGStickerPack *> *)packs {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (TGStickerPack *pack in packs) {
        if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]] && [_installedPackIds containsObject:@(((TGStickerPackIdReference *)pack.packReference).packId)]) {
            continue;
        }
        [result addObject:pack];
    }
    return result;
}

- (void)setPacks:(NSArray<TGStickerPack *> *)packs {
    if (TGObjectCompare(_packs, packs)) {
        return;
    }
    
    _packs = packs;
    
    __weak TGArchivedStickerPacksController *weakSelf = self;
    NSUInteger sectionIndex = [self indexForSection:_stickerPacksSection];
    while (_stickerPacksSection.items.count != 0)
    {
        [self.menuSections deleteItemFromSection:sectionIndex atIndex:0];
    }
    NSUInteger insertIndex = 0;
    NSArray *sortedStickerPacks = packs;
    
    for (TGStickerPack *stickerPack in sortedStickerPacks)
    {
        TGStickerPackCollectionItem *packItem = [[TGStickerPackCollectionItem alloc] initWithStickerPack:stickerPack];
        packItem.deselectAutomatically = true;
        packItem.enableEditing = true;
        packItem.status = TGStickerPackItemStatusNotInstalled;
        
        packItem.canBeMovedToSectionAtIndex = ^bool (__unused NSUInteger sectionIndex, __unused NSUInteger index) {
            return false;
        };
        packItem.deleteStickerPack = ^{
            __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf deleteStickerPack:stickerPack];
            }
        };
        packItem.addStickerPack = ^{
            __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf installStickerPack:stickerPack];
            }
        };
        packItem.previewStickerPack = ^
        {
            __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf previewStickerPack:stickerPack];
            }
        };
        [self.menuSections insertItem:packItem toSection:sectionIndex atIndex:insertIndex];
        insertIndex++;
    }
    
    [self.collectionView reloadData];
}

- (void)previewStickerPack:(TGStickerPack *)stickerPack
{
    __weak TGArchivedStickerPacksController *weakSelf = self;
    TGMenuSheetController *controller = [TGStickersMenu presentInParentController:self stickerPack:stickerPack showShareAction:true sendSticker:nil stickerPackRemoved:nil stickerPackHidden:nil stickerPackArchived:true stickerPackIsMask:_masksMode sourceView:self.view sourceRect:^CGRect
     {
         __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
         if (strongSelf == nil)
             return CGRectZero;
         
         return [strongSelf sourceRectForStickerPack:stickerPack];
     }];
    controller.packIsArchived = true;
    controller.packIsMask = stickerPack.isMask;
}

- (CGRect)sourceRectForStickerPack:(TGStickerPack *)stickerPack {
    for (id item in _stickerPacksSection.items) {
        if ([item isKindOfClass:[TGStickerPackCollectionItem class]]) {
            TGStickerPackCollectionItem *stickerPackItem = item;
            if ([stickerPackItem.stickerPack.packReference isEqual:[stickerPack packReference]]) {
                if (stickerPackItem.view != nil)
                    return [stickerPackItem.view convertRect:stickerPackItem.view.bounds toView:self.view];
                
                return CGRectZero;
                break;
            }
        }
    }
    
    return CGRectZero;
}

- (void)deleteStickerPack:(TGStickerPack *)stickerPack {
    __weak TGArchivedStickerPacksController *weakSelf = self;
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Delete") action:@"delete" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel],
    ] actionBlock:^(__unused id target, NSString *action) {
        if ([action isEqualToString:@"delete"]) {
            __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow showWithDelay:0.1];
                
                SSignal *removeStickerPackSignal = (_masksMode ? [TGMaskStickersSignals removeStickerPack:stickerPack.packReference hintArchived:true] : [TGStickersSignals removeStickerPack:stickerPack.packReference hintArchived:true]);
                [[[removeStickerPackSignal deliverOn:[SQueue mainQueue]] onDispose:^{
                    TGDispatchOnMainThread(^{
                        [progressWindow dismiss:true];
                    });
                }] startWithNext:nil completed:^{
                    __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        for (id item in strongSelf->_stickerPacksSection.items) {
                            if ([item isKindOfClass:[TGStickerPackCollectionItem class]]) {
                                TGStickerPackCollectionItem *stickerPackItem = item;
                                if ([stickerPackItem.stickerPack.packReference isEqual:[stickerPack packReference]]) {
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[strongSelf->_stickerPacksSection indexOfItem:item] inSection:[strongSelf.menuSections.sections indexOfObject:strongSelf->_stickerPacksSection]];
                                    [strongSelf.menuSections deleteItemFromSection:indexPath.section atIndex:indexPath.item];
                                    [strongSelf.collectionView performBatchUpdates:^{
                                        [strongSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                                    } completion:nil];
                                    [strongSelf updateItemPositions];
                                    
                                    break;
                                }
                            }
                        }
                    }
                }];
            }
        } else {
            __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf leaveEditingMode:true];
            }
        }
    } target:self] showInView:self.view];
}

- (void)installStickerPack:(TGStickerPack *)stickerPack {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.1];
    __weak TGArchivedStickerPacksController *weakSelf = self;
    SSignal *installStickerPackAndGetArchivedSignal = _masksMode ? [TGMaskStickersSignals installStickerPackAndGetArchived:stickerPack.packReference hintUnarchive:true] : [TGStickersSignals installStickerPackAndGetArchived:stickerPack.packReference hintUnarchive:true];
    
    [[[installStickerPackAndGetArchivedSignal deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:^(NSArray *archivedPacks) {
        __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            bool willReload = false;
            if (archivedPacks.count != 0) {
                willReload = true;
                NSUInteger insertIndex = 0;
                NSMutableArray *updatedPacks = [[NSMutableArray alloc] initWithArray:_packs];
                NSUInteger section = [strongSelf.menuSections.sections indexOfObject:strongSelf->_stickerPacksSection];
                for (TGStickerPack *pack in archivedPacks) {
                    [updatedPacks insertObject:pack atIndex:insertIndex];
                    
                    TGStickerPackCollectionItem *packItem = [[TGStickerPackCollectionItem alloc] initWithStickerPack:pack];
                    packItem.deselectAutomatically = true;
                    packItem.enableEditing = false;
                    packItem.status = TGStickerPackItemStatusNotInstalled;
                    
                    packItem.canBeMovedToSectionAtIndex = ^bool (__unused NSUInteger sectionIndex, __unused NSUInteger index) {
                        return false;
                    };
                    packItem.deleteStickerPack = ^{
                    };
                    packItem.addStickerPack = ^{
                        __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            [strongSelf installStickerPack:pack];
                        }
                    };
                    packItem.previewStickerPack = ^
                    {
                        __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            [strongSelf previewStickerPack:stickerPack];
                        }
                    };
                    
                    [strongSelf.menuSections insertItem:packItem toSection:section atIndex:insertIndex];
                    
                    insertIndex++;
                }
                strongSelf->_packs = updatedPacks;
            }
            
            for (id item in strongSelf->_stickerPacksSection.items) {
                if ([item isKindOfClass:[TGStickerPackCollectionItem class]]) {
                    TGStickerPackCollectionItem *stickerPackItem = item;
                    if ([stickerPackItem.stickerPack.packReference isEqual:[stickerPack packReference]]) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[strongSelf->_stickerPacksSection indexOfItem:item] inSection:[strongSelf.menuSections.sections indexOfObject:strongSelf->_stickerPacksSection]];
                        [strongSelf.menuSections deleteItemFromSection:indexPath.section atIndex:indexPath.item];
                        if (!willReload) {
                            [strongSelf.collectionView performBatchUpdates:^{
                                [strongSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                            } completion:nil];
                            [strongSelf updateItemPositions];
                        }
                        
                        break;
                    }
                }
            }
            
            if (willReload) {
                [strongSelf.collectionView reloadData];
            }
            
            if (archivedPacks.count != 0) {
                TGArchivedStickerPacksAlert *previewWindow = [[TGArchivedStickerPacksAlert alloc] initWithParentController:strongSelf stickerPacks:archivedPacks];
                __weak TGArchivedStickerPacksAlert *weakPreviewWindow = previewWindow;
                previewWindow.view.dismiss = ^
                {
                    __strong TGArchivedStickerPacksAlert *strongPreviewWindow = weakPreviewWindow;
                    if (strongPreviewWindow != nil)
                        [strongPreviewWindow dismiss];
                };
                previewWindow.hidden = false;
            }
        }
    } completed:^{
    }];
}

- (void)loadMore {
    __weak TGArchivedStickerPacksController *weakSelf = self;
    SSignal *archivedStickerPacksWithOffsetIdSignal = _masksMode ? [TGMaskStickersSignals archivedStickerPacksWithOffsetId:0 limit:100] : [TGStickersSignals archivedStickerPacksWithOffsetId:0 limit:100];
    [_packsDisposable setDisposable:[[archivedStickerPacksWithOffsetIdSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *packs) {
        __strong TGArchivedStickerPacksController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_activityIndicator stopAnimating];
            [strongSelf->_activityIndicator removeFromSuperview];
            strongSelf.collectionView.hidden = false;
            
            [strongSelf setPacks:[strongSelf filteredPacks:packs]];
        }
    }]];
}

@end
