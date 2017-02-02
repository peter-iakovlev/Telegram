#import "TGFeaturedStickerPacksController.h"

#import "TGStickersSignals.h"
#import "TGMaskStickersSignals.h"

#import "TGStickerPack.h"

#import "TGStickerPackCollectionItem.h"

#import "TGStickersMenu.h"

#import "TGProgressWindow.h"

#import "TGArchivedStickerPacksAlert.h"

@interface TGFeaturedStickerPacksController () {
    id<SDisposable> _packsDisposable;
    id<SDisposable> _updatedFeaturedStickerPacksDisposable;
    
    NSSet<NSNumber *> *_initialUnreadPackIds;
    NSSet<NSNumber *> *_installedPacks;
    NSArray<TGStickerPack *> *_packs;
    
    UIActivityIndicatorView *_activityIndicator;
    
    TGCollectionMenuSection *_stickerPacksSection;
    bool _masksMode;
    
    SAtomic *_accumulatedReadFeaturedPackIds;
    STimer *_accumulatedReadFeaturedPackIdsTimer;
    NSMutableSet *_alreadyReadFeaturedPackIds;
}

@end

@implementation TGFeaturedStickerPacksController

- (instancetype)init {
    return [self initWithMasksMode:false];
}

- (instancetype)initWithMasksMode:(bool)masksMode {
    self = [super init];
    if (self != nil) {
        _masksMode = masksMode;
        
        self.title = TGLocalized(@"FeaturedStickerPacks.Title");
        
        _stickerPacksSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
        _stickerPacksSection.insets = UIEdgeInsetsMake(32.0f, 0.0f, 16.0f, 0.0f);
        [self.menuSections addSection:_stickerPacksSection];
        
        __weak TGFeaturedStickerPacksController *weakSelf = self;
        SSignal *stickerPacksSignal = _masksMode ? [TGMaskStickersSignals stickerPacks] : [TGStickersSignals stickerPacks];
        
        _packsDisposable = [[stickerPacksSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict) {
            __strong TGFeaturedStickerPacksController *strongSelf = weakSelf;
            if (strongSelf != nil && ((NSArray *)dict[@"featuredPacks"]).count != 0) {
                [strongSelf->_activityIndicator stopAnimating];
                [strongSelf->_activityIndicator removeFromSuperview];
                strongSelf.collectionView.hidden = false;
                
                NSArray *featuredPacksUnreadIds = dict[@"featuredPacksUnreadIds"];
                strongSelf->_initialUnreadPackIds = [[NSSet alloc] initWithArray:featuredPacksUnreadIds == nil ? @[] : featuredPacksUnreadIds];
                
                //if (featuredPacksUnreadIds.count != 0) {
                if (_masksMode) {
                    //[TGMaskStickersSignals markFeaturedStickersAsRead];
                } else {
                    //[TGStickersSignals markFeaturedStickersAsRead];
                }
                //}
                
                NSMutableSet<NSNumber *> *installedPacks = [[NSMutableSet alloc] init];
                for (TGStickerPack *pack in dict[@"packs"]) {
                    if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
                        int64_t packId = ((TGStickerPackIdReference *)pack.packReference).packId;
                        [installedPacks addObject:@(packId)];
                    }
                }
                
                [strongSelf setPacks:dict[@"featuredPacks"] installedPacks:installedPacks];
            }
        }];
        
        SSignal *updatedFeaturedStickerPacksSignal = _masksMode ? [TGMaskStickersSignals updatedFeaturedStickerPacks] : [TGStickersSignals updatedFeaturedStickerPacks];
        _updatedFeaturedStickerPacksDisposable = [updatedFeaturedStickerPacksSignal startWithNext:nil];
    }
    return self;
}

- (void)dealloc {
    [_packsDisposable dispose];
    [_updatedFeaturedStickerPacksDisposable dispose];
    [_accumulatedReadFeaturedPackIdsTimer invalidate];
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

- (void)updatePackStatuses {
    for (id item in _stickerPacksSection.items) {
        if ([item isKindOfClass:[TGStickerPackCollectionItem class]]) {
            TGStickerPackCollectionItem *stickerPackItem = item;
            
            TGStickerPackItemStatus status = TGStickerPackItemStatusNotInstalled;
            
            if ([stickerPackItem.stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
                int64_t packId = ((TGStickerPackIdReference *)stickerPackItem.stickerPack.packReference).packId;
                if ([_installedPacks containsObject:@(packId)]) {
                    status = TGStickerPackItemStatusInstalled;
                }
            }
            stickerPackItem.status = status;
        }
    }
}

- (void)setPacks:(NSArray<TGStickerPack *> *)packs installedPacks:(NSSet<NSNumber *> *)installedPacks {
    _installedPacks = installedPacks;
    
    if (TGObjectCompare(_packs, packs)) {
        [self updatePackStatuses];
        return;
    }
    
    _packs = packs;
    
    __weak TGFeaturedStickerPacksController *weakSelf = self;
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
        packItem.enableEditing = false;
        
        bool unread = false;
        if ([stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
            unread = [_initialUnreadPackIds containsObject:@(((TGStickerPackIdReference *)stickerPack.packReference).packId)];
        }
        packItem.unread = unread;
        
        packItem.canBeMovedToSectionAtIndex = ^bool (__unused NSUInteger sectionIndex, __unused NSUInteger index) {
            return false;
        };
        packItem.deleteStickerPack = ^{
        };
        packItem.addStickerPack = ^{
            __strong TGFeaturedStickerPacksController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf installStickerPack:stickerPack];
            }
        };
        packItem.previewStickerPack = ^
        {
            __strong TGFeaturedStickerPacksController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf previewStickerPack:stickerPack];
            }
        };
        [self.menuSections insertItem:packItem toSection:sectionIndex atIndex:insertIndex];
        insertIndex++;
    }
    [self updatePackStatuses];
    [self.collectionView reloadData];
}

- (void)previewStickerPack:(TGStickerPack *)stickerPack
{
    __weak TGFeaturedStickerPacksController *weakSelf = self;
    [TGStickersMenu presentInParentController:self stickerPack:stickerPack showShareAction:true sendSticker:nil stickerPackRemoved:nil stickerPackHidden:nil stickerPackArchived:false stickerPackIsMask:stickerPack.isAccessibilityElement sourceView:self.view sourceRect:^CGRect
     {
         __strong TGFeaturedStickerPacksController *strongSelf = weakSelf;
         if (strongSelf == nil)
             return CGRectZero;
         
         return [strongSelf sourceRectForStickerPack:stickerPack];
     }];
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

- (void)installStickerPack:(TGStickerPack *)stickerPack {
    __weak TGFeaturedStickerPacksController *weakSelf = self;
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.1];
    SSignal *installStickerPackAndGetArchivedSignal = _masksMode ? [TGStickersSignals installStickerPackAndGetArchived:stickerPack.packReference] : [TGStickersSignals installStickerPackAndGetArchived:stickerPack.packReference];
    [[[installStickerPackAndGetArchivedSignal deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:^(NSArray *archivedPacks) {
        TGFeaturedStickerPacksController *strongSelf = weakSelf;
        if (strongSelf != nil) {
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
    }];
}

- (void)willDisplayItem:(TGCollectionItem *)item {
    if ([item isKindOfClass:[TGStickerPackCollectionItem class]]) {
        TGStickerPack *pack = ((TGStickerPackCollectionItem *)item).stickerPack;
        int64_t packId = 0;
        if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
            packId = ((TGStickerPackIdReference *)pack.packReference).packId;
        }
        if (_alreadyReadFeaturedPackIds == nil) {
            _alreadyReadFeaturedPackIds = [[NSMutableSet alloc] init];
        }
        if (![_alreadyReadFeaturedPackIds containsObject:@(packId)]) {
            [_alreadyReadFeaturedPackIds addObject:@(packId)];
            [self scheduleReadFeaturedPackId:packId];
        }
    }
}

- (void)scheduleReadFeaturedPackId:(int64_t)packId {
    [_accumulatedReadFeaturedPackIdsTimer invalidate];
    if (_accumulatedReadFeaturedPackIds == nil) {
        _accumulatedReadFeaturedPackIds = [[SAtomic alloc] initWithValue:nil];
    }
    [_accumulatedReadFeaturedPackIds modify:^id(NSArray *packIds) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([packIds count] != 0) {
            [array addObjectsFromArray:packIds];
        }
        [array addObject:@(packId)];
        return array;
    }];
    __weak TGFeaturedStickerPacksController *weakSelf = self;
    _accumulatedReadFeaturedPackIdsTimer = [[STimer alloc] initWithTimeout:0.2 repeat:false completion:^{
        __strong TGFeaturedStickerPacksController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf commitReadFeaturedPackIds];
        }
    } queue:[SQueue mainQueue]];
    [_accumulatedReadFeaturedPackIdsTimer start];
}

- (void)commitReadFeaturedPackIds {
    NSArray *packIds = [_accumulatedReadFeaturedPackIds swap:nil];
    [TGStickersSignals markFeaturedStickerPackAsRead:packIds];
}

@end
