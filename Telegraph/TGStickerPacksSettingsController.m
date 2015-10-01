#import "TGStickerPacksSettingsController.h"

#import "TGHeaderCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGStickerPackCollectionItem.h"

#import "TGStickersSignals.h"

#import "TGProgressWindow.h"
#import "TGAlertView.h"

#import "TGStickerPackPreviewWindow.h"

#import "TGAppDelegate.h"

@interface TGStickerPacksSettingsController ()
{
    TGSwitchCollectionItem *_showStickersButtonItem;
    TGCollectionMenuSection *_stickerPacksSection;
    
    SMetaDisposable *_stickerPacksDisposable;
    
    UIActivityIndicatorView *_activityIndicator;
    
    NSArray *_originalStickerPacks;
    NSDictionary *_packUseCount;
}

@end

@implementation TGStickerPacksSettingsController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        __weak TGStickerPacksSettingsController *weakSelf = self;
        
        self.title = TGLocalized(@"StickerPacksSettings.Title");
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
        
        _showStickersButtonItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"StickerPacksSettings.ShowStickersButton") isOn:TGAppDelegateInstance.alwaysShowStickersMode == 2];
        
        _showStickersButtonItem.toggled = ^(bool value)
        {
            TGAppDelegateInstance.alwaysShowStickersMode = value ? 2 : 1;
            [TGAppDelegateInstance saveSettings];
        };
        
        TGCommentCollectionItem *showStickersHelpItem = [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"StickerPacksSettings.ShowStickersButtonHelp")];
        TGCollectionMenuSection *topSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _showStickersButtonItem,
            showStickersHelpItem
        ]];
        topSection.insets = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0f);
        [self.menuSections addSection:topSection];
        
        NSMutableArray *stickerPacksSectionItems = [[NSMutableArray alloc] init];
        [stickerPacksSectionItems addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"StickerPacksSettings.StickerPacksSection")]];
        [stickerPacksSectionItems addObject:[[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"StickerPacksSettings.ManagingHelp")]];
        _stickerPacksSection = [[TGCollectionMenuSection alloc] initWithItems:stickerPacksSectionItems];
        _stickerPacksSection.insets = UIEdgeInsetsMake(16.0f, 0.0f, 16.0f, 0.0f);
        [self.menuSections addSection:_stickerPacksSection];
        
        _stickerPacksDisposable = [[SMetaDisposable alloc] init];
        [_stickerPacksDisposable setDisposable:[[[TGStickersSignals stickerPacks] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict)
        {
            __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil && ((NSArray *)dict[@"packs"]).count != 0)
            {
                [strongSelf->_activityIndicator stopAnimating];
                [strongSelf->_activityIndicator removeFromSuperview];
                strongSelf.collectionView.hidden = false;
                
                if (![strongSelf->_originalStickerPacks isEqual:dict[@"packs"]] || ![strongSelf->_packUseCount isEqual:dict[@"packUseCount"]])
                {
                    [strongSelf setStickerPacks:dict[@"packs"] packUseCount:dict[@"packUseCount"]];
                }
            }
        }]];
    }
    return self;
}

- (void)dealloc
{
    [_stickerPacksDisposable dispose];
}

- (void)editPressed
{
    [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(editCancelPressed)] animated:true];
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(editDonePressed)] animated:true];
    
    self.enableItemReorderingGestures = false;
    
    [self enterEditingMode:true];
}

- (void)editCancelPressed
{
    self.enableItemReorderingGestures = false;
    
    [self setLeftBarButtonItem:nil animated:true];
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
    
    [self leaveEditingMode:true];
}

- (void)editDonePressed
{
    [self setLeftBarButtonItem:nil animated:true];
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
    
    [self leaveEditingMode:true];
}

- (void)loadView
{
    [super loadView];
    
    if (_originalStickerPacks == nil)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activityIndicator.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        self.collectionView.hidden = true;
    }
}

- (void)setStickerPacks:(NSArray *)stickerPacks packUseCount:(NSDictionary *)packUseCount
{
    _showStickersButtonItem.isOn = TGAppDelegateInstance.alwaysShowStickersMode == 2;
    
    _originalStickerPacks = stickerPacks;
    _packUseCount = packUseCount;
    
    __weak TGStickerPacksSettingsController *weakSelf = self;
    
    NSUInteger sectionIndex = [self indexForSection:_stickerPacksSection];
    while (_stickerPacksSection.items.count != 2)
    {
        [self.menuSections deleteItemFromSection:sectionIndex atIndex:1];
    }
    NSUInteger insertIndex = 1;
    NSArray *sortedStickerPacks = [stickerPacks sortedArrayUsingComparator:^NSComparisonResult(TGStickerPack *pack1, TGStickerPack *pack2)
    {
        NSNumber *id1 = @(((TGStickerPackIdReference *)pack1.packReference).packId);
        NSNumber *id2 = @(((TGStickerPackIdReference *)pack2.packReference).packId);
        NSNumber *useCount1 = packUseCount[id1];
        NSNumber *useCount2 = packUseCount[id2];
        if (useCount1 != nil && useCount2 != nil)
        {
            NSComparisonResult result = [useCount1 compare:useCount2];
            if (result == NSOrderedSame)
                return [id1 compare:id2];
            return result;
        }
        else if (useCount1 != nil)
            return NSOrderedDescending;
        else if (useCount2 != nil)
            return NSOrderedAscending;
        else
            return [id1 compare:id2];
    }];
    
    for (TGStickerPack *stickerPack in sortedStickerPacks.reverseObjectEnumerator)
    {
        TGStickerPackCollectionItem *packItem = [[TGStickerPackCollectionItem alloc] initWithStickerPack:stickerPack];
        packItem.deselectAutomatically = true;
        
        if ([stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]])
        {
            packItem.enableEditing = ((TGStickerPackIdReference *)stickerPack.packReference).shortName.length != 0;
        }
        else
        {
            packItem.enableEditing = ![stickerPack.packReference isKindOfClass:[TGStickerPackBuiltinReference class]];
        }
        /*packItem.canBeMovedToSectionAtIndex = ^bool (NSUInteger sectionIndex, NSUInteger index)
        {
            __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGCollectionMenuSection *section = strongSelf.menuSections.sections[sectionIndex];
                return section == strongSelf->_stickerPacksSection && index > 0 && index < section.items.count - 1;
            }
            return false;
        };*/
        packItem.deleteStickerPack = ^
        {
            __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf deleteStickerPack:stickerPack];
        };
        packItem.previewStickerPack = ^
        {
            __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf previewStickerPack:stickerPack];
        };
        [self.menuSections insertItem:packItem toSection:sectionIndex atIndex:insertIndex];
        insertIndex++;
    }
    [self.collectionView reloadData];
}

- (void)deleteStickerPack:(TGStickerPack *)stickerPack
{
    __weak TGStickerPacksSettingsController *weakSelf = self;
    NSString *text = [[NSString alloc] initWithFormat:TGLocalized(@"StickerPack.RemovePrompt"), stickerPack.title];
    [[[TGAlertView alloc] initWithTitle:nil message:text cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
    {
        if (okButtonPressed)
        {
            TGProgressWindow *progresWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [progresWindow show:true];
            
            [[[[TGStickersSignals removeStickerPack:stickerPack.packReference] deliverOn:[SQueue mainQueue]] onDispose:^
            {
                TGDispatchOnMainThread(^
                {
                    [progresWindow dismiss:true];
                });
            }] startWithNext:^(__unused id next)
            {
                __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    NSInteger index = -1;
                    for (id item in strongSelf->_stickerPacksSection.items)
                    {
                        index++;
                        
                        if ([item isKindOfClass:[TGStickerPackCollectionItem class]])
                        {
                            TGStickerPackCollectionItem *stickerPackItem = item;
                            if ([stickerPackItem.stickerPack.packReference isEqual:[stickerPack packReference]])
                            {
                                NSUInteger sectionIndex = [strongSelf indexForSection:strongSelf->_stickerPacksSection];
                                [strongSelf.menuSections deleteItemFromSection:sectionIndex atIndex:index];
                                [strongSelf.collectionView performBatchUpdates:^
                                {
                                    [strongSelf.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:sectionIndex]]];
                                } completion:nil];
                                [strongSelf updateItemPositions];
                                break;
                            }
                        }
                    }
                    
                    for (NSUInteger i = 0; i < strongSelf->_originalStickerPacks.count; i++)
                    {
                        if ([((TGStickerPack *)strongSelf->_originalStickerPacks[i]).packReference isEqual:stickerPack.packReference])
                        {
                            NSMutableArray *updatedStickerPacks = [[NSMutableArray alloc] initWithArray:strongSelf->_originalStickerPacks];
                            [updatedStickerPacks removeObjectAtIndex:i];
                            strongSelf->_originalStickerPacks = updatedStickerPacks;
                            break;
                        }
                    }
                }
            }];
        }
    }] show];
}

- (void)previewStickerPack:(TGStickerPack *)stickerPack
{
    TGStickerPackPreviewWindow *previewWindow = [[TGStickerPackPreviewWindow alloc] initWithParentController:self stickerPack:stickerPack];
    __weak TGStickerPackPreviewWindow *weakPreviewWindow = previewWindow;
    __weak TGStickerPacksSettingsController *weakSelf = self;
    if ([self stickerPackShortname:stickerPack].length != 0)
    {
        [previewWindow.view setAction:^
        {
            __strong TGStickerPackPreviewWindow *strongPreviewWindow = weakPreviewWindow;
            if (strongPreviewWindow != nil)
            {
                [strongPreviewWindow.view animateDismiss:^
                {
                    __strong TGStickerPackPreviewWindow *strongPreviewWindow = weakPreviewWindow;
                    if (strongPreviewWindow != nil)
                        [strongPreviewWindow dismiss];
                }];
            }
            __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf shareStickerPack:stickerPack];
        } title:TGLocalized(@"StickerPack.ShareStickers")];
    }
    previewWindow.view.dismiss = ^
    {
        __strong TGStickerPackPreviewWindow *strongPreviewWindow = weakPreviewWindow;
        if (strongPreviewWindow != nil)
            [strongPreviewWindow dismiss];
    };
    previewWindow.hidden = false;
}

- (NSString *)stickerPackShortname:(TGStickerPack *)stickerPack
{
    NSString *shortName = nil;
    if ([stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]])
        shortName = ((TGStickerPackIdReference *)stickerPack.packReference).shortName;
    else if ([stickerPack.packReference isKindOfClass:[TGStickerPackShortnameReference class]])
        shortName = ((TGStickerPackShortnameReference *)stickerPack.packReference).shortName;
    return shortName;
}

- (void)shareStickerPack:(TGStickerPack *)stickerPack
{
    NSString *shortName = [self stickerPackShortname:stickerPack];
    if (shortName.length != 0)
    {
        NSString *linkText = [[NSString alloc] initWithFormat:@"https://telegram.me/addstickers/%@", shortName];
        NSArray *dataToShare = @[[NSURL URLWithString:linkText]];
        for (id item in _stickerPacksSection.items)
        {
            if ([item isKindOfClass:[TGStickerPackCollectionItem class]] && [((TGStickerPackCollectionItem *)item).stickerPack.packReference isEqual:stickerPack.packReference] && [(TGStickerPackCollectionItem *)item boundView] != nil)
            {
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
                if (iosMajorVersion() >= 7 && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                {
                    UIView *sourceView = [(TGStickerPackCollectionItem *)item boundView];
                    activityViewController.popoverPresentationController.sourceView = sourceView;
                    activityViewController.popoverPresentationController.sourceRect = sourceView.bounds;
                }
                [self presentViewController:activityViewController animated:YES completion:nil];
                
                break;
            }
        }
    }
}

@end
