#import "TGStickerPacksSettingsController.h"

#import "TGHeaderCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGStickerPackCollectionItem.h"

#import "TGStickersSignals.h"

#import "TGProgressWindow.h"
#import "TGAlertView.h"
#import "TGActionSheet.h"

#import "TGStickerPackPreviewWindow.h"

#import "TGAppDelegate.h"

@interface TGStickerPacksSettingsController ()
{
    bool _editingMode;
    
    TGSwitchCollectionItem *_showStickersButtonItem;
    TGCollectionMenuSection *_stickerPacksSection;
    
    SMetaDisposable *_stickerPacksDisposable;
    
    UIActivityIndicatorView *_activityIndicator;
    
    NSArray *_originalStickerPacks;
}

@end

@implementation TGStickerPacksSettingsController

- (instancetype)init {
    return [self initWithEditing:false];
}

- (instancetype)initWithEditing:(bool)editing {
    self = [super init];
    if (self != nil)
    {
        _editingMode = editing;
        
        __weak TGStickerPacksSettingsController *weakSelf = self;
        
        self.title = TGLocalized(@"StickerPacksSettings.Title");
        
        if (_editingMode) {
            [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(editCancelPressed)] animated:false];
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(editDonePressed)] animated:false];
        } else {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
        }
        
        _showStickersButtonItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"StickerPacksSettings.ShowStickersButton") isOn:TGAppDelegateInstance.alwaysShowStickersMode == 2];
        
        _showStickersButtonItem.toggled = ^(bool value)
        {
            TGAppDelegateInstance.alwaysShowStickersMode = value ? 2 : 1;
            [TGAppDelegateInstance saveSettings];
        };
        
        TGCommentCollectionItem *showStickersHelpItem = [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"StickerPacksSettings.ShowStickersButtonHelp")];
        TGCollectionMenuSection *showStickersSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _showStickersButtonItem,
            showStickersHelpItem
        ]];
        if (!_editingMode) {
            [self.menuSections addSection:showStickersSection];
        }
        
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
                
                if (![strongSelf->_originalStickerPacks isEqual:dict[@"packs"]])
                {
                    [strongSelf setStickerPacks:dict[@"packs"]];
                }
            }
        }]];
        
        TGCollectionMenuSection *topSection = self.menuSections.sections.firstObject;
        topSection.insets = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0f);
    }
    return self;
}

- (void)dealloc
{
    [_stickerPacksDisposable dispose];
}

- (void)_resetCollectionView {
    [super _resetCollectionView];
    
    if (_editingMode) {
        self.enableItemReorderingGestures = true;
        [self enterEditingMode:false];
    }
}

- (void)editPressed
{
    [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(editCancelPressed)] animated:true];
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(editDonePressed)] animated:true];
    
    self.enableItemReorderingGestures = true;
    
    [self enterEditingMode:true];
}

- (void)editCancelPressed
{
    if (_editingMode) {
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    } else {
        self.enableItemReorderingGestures = false;
        
        [self setLeftBarButtonItem:nil animated:true];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
        
        [self leaveEditingMode:true];
        
        [self animateCollectionCrossfade];
        
        [self setStickerPacks:_originalStickerPacks];
    }
}

- (NSArray *)currentStickerPacks {
    NSMutableArray *currentStickerPacks = [[NSMutableArray alloc] init];
    
    for (id item in _stickerPacksSection.items) {
        if ([item isKindOfClass:[TGStickerPackCollectionItem class]]) {
            [currentStickerPacks addObject:((TGStickerPackCollectionItem *)item).stickerPack];
        }
    }
    
    return currentStickerPacks;
}

- (bool)isOrderChanged {
    NSArray *currentStickerPacks = [self currentStickerPacks];
    
    bool orderChanged = false;
    if (_originalStickerPacks.count == currentStickerPacks.count) {
        for (NSInteger i = 0; i < (NSInteger)currentStickerPacks.count; i++) {
            if (!TGObjectCompare(((TGStickerPack *)currentStickerPacks[i]).packReference, ((TGStickerPack *)_originalStickerPacks[i]).packReference)) {
                orderChanged = true;
                break;
            }
        }
    }
    
    return orderChanged;
}

- (void)editDonePressed
{
    if ([self isOrderChanged]) {
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow showWithDelay:0.1];
        
        NSMutableArray *currentStickerPacksReferences = [[NSMutableArray alloc] init];
        for (TGStickerPack *pack in [self currentStickerPacks]) {
            [currentStickerPacksReferences addObject:pack.packReference];
        }
        
        __weak TGStickerPacksSettingsController *weakSelf = self;
        [[[[TGStickersSignals reorderStickerPacks:currentStickerPacksReferences] deliverOn:[SQueue mainQueue]] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
            });
        }] startWithNext:nil completed:^{
            __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_editingMode) {
                    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
                } else {
                    strongSelf->_originalStickerPacks = [strongSelf currentStickerPacks];
                    
                    [strongSelf setLeftBarButtonItem:nil animated:true];
                    [strongSelf setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:strongSelf action:@selector(editPressed)]];
                    
                    [strongSelf leaveEditingMode:true];
                }
            }
        }];
    } else {
        if (_editingMode) {
            [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
        } else {
            _originalStickerPacks = [self currentStickerPacks];
            
            [self setLeftBarButtonItem:nil animated:true];
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
            
            [self leaveEditingMode:true];
        }
    }
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

- (void)setStickerPacks:(NSArray *)stickerPacks
{
    _showStickersButtonItem.isOn = TGAppDelegateInstance.alwaysShowStickersMode == 2;
    
    _originalStickerPacks = stickerPacks;
    
    __weak TGStickerPacksSettingsController *weakSelf = self;
    
    NSUInteger sectionIndex = [self indexForSection:_stickerPacksSection];
    while (_stickerPacksSection.items.count != 2)
    {
        [self.menuSections deleteItemFromSection:sectionIndex atIndex:1];
    }
    NSUInteger insertIndex = 1;
    NSArray *sortedStickerPacks = stickerPacks;
    
    for (TGStickerPack *stickerPack in sortedStickerPacks)
    {
        TGStickerPackCollectionItem *packItem = [[TGStickerPackCollectionItem alloc] initWithStickerPack:stickerPack];
        packItem.deselectAutomatically = true;
        
        if ([stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]])
        {
            packItem.enableEditing = true;//((TGStickerPackIdReference *)stickerPack.packReference).shortName.length != 0;
        }
        else
        {
            packItem.enableEditing = ![stickerPack.packReference isKindOfClass:[TGStickerPackBuiltinReference class]];
        }
        packItem.canBeMovedToSectionAtIndex = ^bool (NSUInteger sectionIndex, NSUInteger index)
        {
            __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGCollectionMenuSection *section = strongSelf.menuSections.sections[sectionIndex];
                return section == strongSelf->_stickerPacksSection && index > 0 && index < section.items.count - 1;
            }
            return false;
        };
        packItem.deleteStickerPack = ^
        {
            __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                TGStickerPack *foundPack = nil;
                for (TGStickerPack *pack in strongSelf->_originalStickerPacks) {
                    if ([pack.packReference isEqual:stickerPack.packReference]) {
                        foundPack = pack;
                        break;
                    }
                }
                if (foundPack != nil) {
                    [strongSelf deleteStickerPack:foundPack];
                }
            }
        };
        packItem.addStickerPack = ^{
            __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf toggleStickerPack:stickerPack hidden:false];
            }
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
    if (false) {
        __weak TGStickerPacksSettingsController *weakSelf = self;
        
        [[[TGActionSheet alloc] initWithTitle:nil actions:@[[[TGActionSheetAction alloc] initWithTitle:stickerPack.hidden ? TGLocalized(@"StickerSettings.ContextShow") : TGLocalized(@"StickerSettings.ContextHide") action:stickerPack.hidden ? @"show" : @"hide"], [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Delete") action:@"delete" type:TGActionSheetActionTypeDestructive], [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]] actionBlock:^(__unused id target, NSString *action) {
            if ([action isEqualToString:@"hide"]) {
                __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf toggleStickerPack:stickerPack hidden:true];
                }
            } else if ([action isEqualToString:@"show"]) {
                __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf toggleStickerPack:stickerPack hidden:false];
                }
            } else if ([action isEqualToString:@"delete"]) {
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
        } target:self] showInView:self.view];
        
        return;
    }
    
    bool hide = ((TGStickerPackIdReference *)stickerPack.packReference).shortName.length == 0;
    
    __weak TGStickerPacksSettingsController *weakSelf = self;
    NSString *text = [[NSString alloc] initWithFormat:hide ? TGLocalized(@"StickerSettings.ContextHide") : TGLocalized(@"StickerPack.RemovePrompt"), stickerPack.title];
    if (hide) {
        [self toggleStickerPack:stickerPack hidden:!stickerPack.hidden];
    } else {
        [[[TGAlertView alloc] initWithTitle:nil message:text cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
        {
            if (okButtonPressed)
            {
                TGProgressWindow *progresWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [progresWindow show:true];
                
                if (hide) {
                    __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf toggleStickerPack:stickerPack hidden:true];
                    }
                } else {
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
            }
        }] show];
    }
}

- (void)toggleStickerPack:(TGStickerPack *)stickerPack hidden:(bool)hidden {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow show:true];
    
    __weak TGStickerPacksSettingsController *weakSelf = self;
    [[[[TGStickersSignals toggleStickerPackHidden:stickerPack.packReference hidden:hidden] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil error:nil completed:^{
        __strong TGStickerPacksSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            TGStickerPack *updatedStickerPack = [[TGStickerPack alloc] initWithPackReference:stickerPack.packReference title:stickerPack.title stickerAssociations:stickerPack.stickerAssociations documents:stickerPack.documents packHash:stickerPack.packHash hidden:hidden];
            
            for (id item in strongSelf->_stickerPacksSection.items)
            {
                if ([item isKindOfClass:[TGStickerPackCollectionItem class]])
                {
                    TGStickerPackCollectionItem *stickerPackItem = item;
                    if ([stickerPackItem.stickerPack.packReference isEqual:[stickerPack packReference]]) {
                        stickerPackItem.stickerPack = updatedStickerPack;
                        break;
                    }
                }
            }
            
            NSInteger index = -1;
            for (TGStickerPack *pack in _originalStickerPacks) {
                index++;
                if ([pack.packReference isEqual:stickerPack.packReference]) {
                    NSMutableArray *updatedOriginalStickerPacks = [[NSMutableArray alloc] initWithArray:_originalStickerPacks];
                    [updatedOriginalStickerPacks replaceObjectAtIndex:index withObject:updatedStickerPack];
                    _originalStickerPacks = updatedOriginalStickerPacks;
                    break;
                }
            }
        }
    }];
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
                if (iosMajorVersion() >= 8 && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                {
                    UIView *sourceView = [(TGStickerPackCollectionItem *)item boundView];
                    activityViewController.popoverPresentationController.sourceView = sourceView;
                    activityViewController.popoverPresentationController.sourceRect = sourceView.bounds;
                }
                [self presentViewController:activityViewController animated:true completion:nil];
                
                break;
            }
        }
    }
}

@end
