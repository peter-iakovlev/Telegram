#import "TGChannelStickersController.h"

#import <LegacyComponents/TGProgressWindow.h>

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGUsernameCollectionItem.h"
#import "TGUsernameCollectionItemView.h"
#import "TGHeaderCollectionItem.h"
#import "TGStickerPackCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGStickersSignals.h"
#import "TGChannelManagementSignals.h"

#import "TGStickersMenu.h"

@interface TGChannelStickersController () <UIScrollViewDelegate>
{
    TGConversation *_conversation;
    SMetaDisposable *_stickerPacksDisposable;
    NSArray *_originalStickerPacks;
    id<SDisposable> _resolveDisposable;
    bool _resolving;
    
    TGStickerPackIdReference *_initialStickerReference;
    TGStickerPackIdReference *_currentStickerReference;
    SVariable *_currentStickerPack;
    SMetaDisposable *_updateCurrentStickerPackDisposable;
    
    TGUsernameCollectionItem *_urlItem;
    TGStickerPackCollectionItem *_stickerPackItem;
    
    TGCollectionMenuSection *_urlSection;
    TGCollectionMenuSection *_stickerPacksSection;
    
    UIActivityIndicatorView *_activityIndicator;
    TGProgressWindow *_progressWindow;
}
@end

@implementation TGChannelStickersController

- (instancetype)initWithConversation:(TGConversation *)conversation
{
    self = [super init];
    if (self != nil)
    {
        _conversation = conversation;
        _currentStickerPack = [[SVariable alloc] init];
        _updateCurrentStickerPackDisposable = [[SMetaDisposable alloc] init];
        
        self.title = TGLocalized(@"Channel.Info.Stickers");

        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        
        TGCachedConversationData *data = [TGDatabaseInstance() _channelCachedDataSync:conversation.conversationId];
        if (data.stickerPack != nil)
        {
            _initialStickerReference = data.stickerPack;
            [_currentStickerPack set:[TGStickersSignals cachedStickerPack:data.stickerPack]];
        }
        else
        {
            [_currentStickerPack set:[SSignal single:nil]];
        }
            
        _urlItem = [[TGUsernameCollectionItem alloc] init];
        _urlItem.username = data.stickerPack.shortName;
        _urlItem.placeholder = TGLocalized(@"Channel.Stickers.Placeholder");
        _urlItem.title = @"";
        _urlItem.prefix = @"t.me/addstickers/";
        _urlItem.usernameValid = true;
        _urlItem.clearable = true;
        __weak TGChannelStickersController *weakSelf = self;
        _urlItem.usernameChanged = ^(NSString *username)
        {
            __strong TGChannelStickersController *strongSelf = weakSelf;
            [strongSelf urlChanged:username];
        };
        _urlItem.textPasted = ^NSString *(__unused NSRange range, NSString *text) {
            __strong TGChannelStickersController *strongSelf = weakSelf;
            return [strongSelf stickerPackShortnameFromString:text];
        };
        
        _stickerPackItem = [[TGStickerPackCollectionItem alloc] init];
        _stickerPackItem.selectable = false;
        _stickerPackItem.deselectAutomatically = true;
        _stickerPackItem.ignoreSeparatorInset = true;
        _stickerPackItem.previewStickerPack = ^{
            __strong TGChannelStickersController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf previewStickerPack:strongSelf->_stickerPackItem.stickerPack];
        };
        
        NSString *hintString = [TGLocalized(@"Channel.Stickers.CreateYourOwn") stringByReplacingOccurrencesOfString:@"@stickers" withString:@"[@stickers]"];
        TGCommentCollectionItem *hintItem = [[TGCommentCollectionItem alloc] init];
        hintItem.action = ^
        {
            NSString *username = @"stickers";
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/resolveDomain/(%@)", username] options:@{@"domain": username} flags:0 watcher:TGTelegraphInstance];
            
            __strong TGChannelStickersController *strongSelf = weakSelf;
            if (strongSelf.presentingViewController != nil)
                [strongSelf.presentingViewController dismissViewControllerAnimated:true completion:nil];
        };
        [hintItem setFormattedText:hintString];
        
        _urlSection = [[TGCollectionMenuSection alloc] initWithItems:@[_urlItem, hintItem]];
        _urlSection.insets = UIEdgeInsetsMake(32.0f, 0.0f, 27.0f, 0.0f);
        [self.menuSections addSection:_urlSection];
        
        NSMutableArray *stickerPacksSectionItems = [[NSMutableArray alloc] init];
        [stickerPacksSectionItems addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Stickers.YourStickers")]];
        _stickerPacksSection = [[TGCollectionMenuSection alloc] initWithItems:stickerPacksSectionItems];
        _stickerPacksSection.insets = UIEdgeInsetsMake(8.0f, 0.0f, 16.0f, 0.0f);
        [self.menuSections addSection:_stickerPacksSection];
        
        _resolveDisposable = [[[[_currentStickerPack signal] catch:^SSignal *(__unused id error) {
            return [SSignal single:nil];
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(TGStickerPack *next)
        {
            __strong TGChannelStickersController *strongSelf = weakSelf;
            [strongSelf setStickerPack:next searchStatus:TGStickerPackItemSearchStatusNone];
        }];
        _stickerPacksDisposable = [[SMetaDisposable alloc] init];
        
        SSignal *stickerPacksSignal = [TGStickersSignals stickerPacks];
        [_stickerPacksDisposable setDisposable:[[stickerPacksSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict)
        {
            __strong TGChannelStickersController *strongSelf = weakSelf;
            if (strongSelf != nil && (((NSArray *)dict[@"packs"]).count != 0 || [((NSNumber *)dict[@"cacheUpdateDate"]) intValue] != 0))
            {
                [strongSelf->_activityIndicator stopAnimating];
                [strongSelf->_activityIndicator removeFromSuperview];
                strongSelf.collectionView.hidden = false;
                
                if (![strongSelf->_originalStickerPacks isEqual:dict[@"packs"]])
                    [strongSelf setStickerPacks:dict[@"packs"]];
            }
        }]];
        
        [self updateSelection:_initialStickerReference];
    }
    return self;
}

- (void)dealloc
{
    [_stickerPacksDisposable dispose];
    [_resolveDisposable dispose];
    [_updateCurrentStickerPackDisposable dispose];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_urlItem.username.length == 0)
        [_urlItem becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:true];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)__unused scrollView
{
    [self.view endEditing:true];
}

- (void)cancelPressed
{
    [[self presentingViewController] dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed
{
    if (_resolving)
        return;
    
    __weak TGChannelStickersController *weakSelf = self;
    [[[[_currentStickerPack signal] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(TGStickerPack *stickerPack)
    {
        __strong TGChannelStickersController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf applyStickerPack:stickerPack];
    }];
}

- (NSString *)stickerPackShortnameFromString:(NSString *)string {
    NSRange range = [string rangeOfString:@"/addstickers/"];
    if (range.location != NSNotFound) {
        NSString *substring = [string substringFromIndex:range.location + range.length];
        
        NSInteger length = 0;
        for (int i = 0; i < (int)substring.length; i++)
        {
            unichar c = [substring characterAtIndex:i];
            if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' || c == '_'))
            {
                break;
            }
            length++;
        }
        
        if (length == 0)
            length = substring.length;
        
        return [substring substringToIndex:length];
    }
    
    return nil;
}

- (void)urlChanged:(NSString *)shortName
{
    if (shortName.length == 0)
    {
        _resolving = false;
        [_currentStickerPack set:[SSignal single:nil]];
        [self updateCurrentStickerPackItem];
    }
    else
    {
        _resolving = true;
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self updateCurrentStickerPackItem];
        });
        
        __weak TGChannelStickersController *weakSelf = self;
        TGStickerPackShortnameReference *reference = [[TGStickerPackShortnameReference alloc] initWithShortName:shortName];
        SSignal *searchSignal = [[[SSignal complete] delay:0.65f onQueue:[SQueue mainQueue]] onStart:^{
            __strong TGChannelStickersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf->_stickerPackItem setSearchStatus:TGStickerPackItemSearchStatusSearching];
                strongSelf->_stickerPackItem.selectable = false;
            }
        }];
        
        searchSignal = [[[[searchSignal then:[TGStickersSignals stickerPackInfo:reference]] deliverOn:[SQueue mainQueue]] onNext:^(__unused id next) {
            __strong TGChannelStickersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_resolving = false;
            }
        }] onError:^(__unused id error) {
            __strong TGChannelStickersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_resolving = false;
                [strongSelf->_stickerPackItem setSearchStatus:TGStickerPackItemSearchStatusFailed];
                strongSelf->_stickerPackItem.selectable = false;
            }
        }];
        
        [_currentStickerPack set:searchSignal];
    }
}

- (void)applyStickerPack:(TGStickerPack *)stickerPack
{
    if ([_initialStickerReference isEqual:stickerPack.packReference] || (_initialStickerReference == nil && stickerPack == nil))
    {
        [self.view endEditing:true];
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
        return;
    }
    
    _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_progressWindow show:true];
    
    [TGDatabaseInstance() storeStickerPack:stickerPack forReference:stickerPack.packReference];
    [TGDatabaseInstance() storeGroupStickerPackUnpinned:0 forPeerId:_conversation.conversationId];

    [[[TGChannelManagementSignals updateChannelStickerPack:_conversation.conversationId accessHash:_conversation.accessHash stickerPack:stickerPack] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(__unused id error) {
        [_progressWindow dismiss:true];
    } completed:^{
        [_progressWindow dismissWithSuccess];
        [self.view endEditing:true];
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }];
}

- (void)setStickerPack:(TGStickerPack *)stickerPack searchStatus:(TGStickerPackItemSearchStatus)searchStatus
{
    NSString *shortName = @"";
    if ([stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]])
        shortName = ((TGStickerPackIdReference *)stickerPack.packReference).shortName;
    
    _urlItem.username = shortName;
    [_stickerPackItem setSearchStatus:searchStatus];
    if (searchStatus == TGStickerPackItemSearchStatusNone)
    {
        _stickerPackItem.selectable = true;
        [_stickerPackItem setStickerPack:stickerPack];
    }
    else
    {
        _stickerPackItem.selectable = false;
    }
    
    _currentStickerReference = stickerPack.packReference;
    [self updateSelection:stickerPack.packReference];
    [self updateCurrentStickerPackItem];
}

- (void)updateCurrentStickerPackItem
{
    SSignal *signal = _resolving ? [SSignal single:@true] : [[[_currentStickerPack signal] map:^id(id value) {
        return @(value != nil);
    }] take:1];
    
    __weak TGChannelStickersController *weakSelf = self;
    _updateCurrentStickerPackDisposable = [signal startWithNext:^(NSNumber *next) {
        __strong TGChannelStickersController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        bool added = false;
        bool deleted = false;
        bool visible = next.boolValue;
        
        if (strongSelf->_urlSection.items.count > 2) {
            if (!visible) {
                [strongSelf->_urlSection deleteItemAtIndex:1];
                deleted = true;
            }
        } else {
            if (visible) {
                [strongSelf->_urlSection insertItem:strongSelf->_stickerPackItem atIndex:1];
                added = true;
            }
        }
        
        if (added || deleted) {
            [UIView performWithoutAnimation:^
            {
                UITextField *fixTextField = nil;
                if ([(TGUsernameCollectionItemView *)strongSelf->_urlItem.view textFieldIsFirstResponder])
                {
                    fixTextField = [[UITextField alloc] init];
                    fixTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    [strongSelf.view addSubview:fixTextField];
                    [fixTextField becomeFirstResponder];
                }
                
                [strongSelf.collectionView reloadData];
                
                if (added)
                {
                    CGFloat itemSize = [strongSelf->_stickerPackItem itemSizeForContainerSize:CGSizeZero].height;
                    CGPoint contentOffset = strongSelf.collectionView.contentOffset;
                    if (contentOffset.y + strongSelf.collectionView.contentInset.top > 32.0f + itemSize)
                    {
                        contentOffset = CGPointMake(contentOffset.x, contentOffset.y + itemSize);
                        strongSelf.collectionView.contentOffset = contentOffset;
                    }
                }
                
                if (fixTextField != nil)
                {
                    [strongSelf->_urlItem becomeFirstResponder];
                    [fixTextField removeFromSuperview];
                }
            }];
        }
    }];
}

- (void)updateSelection:(id<TGStickerPackReference>)currentStickerPack
{
    for (TGCollectionItem *item in _stickerPacksSection.items)
    {
        if ([item isKindOfClass:[TGStickerPackCollectionItem class]])
        {
            TGStickerPackCollectionItem *stickerPackItem = (TGStickerPackCollectionItem *)item;
            [stickerPackItem setIsChecked:[stickerPackItem.stickerPack.packReference isEqual:currentStickerPack]];
        }
    }
}

- (void)setStickerPacks:(NSArray *)stickerPacks
{
    _originalStickerPacks = stickerPacks;
    
    __weak TGChannelStickersController *weakSelf = self;
    
    NSUInteger sectionIndex = [self indexForSection:_stickerPacksSection];
    for (NSUInteger index = 0; index < _stickerPacksSection.items.count; index++)
    {
        [self.menuSections deleteItemFromSection:sectionIndex atIndex:index];
    }

    if (stickerPacks.count > 0)
    {
        [self.menuSections insertItem:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Stickers.YourStickers")] toSection:sectionIndex atIndex:0];
        
        NSUInteger insertIndex = 1;

        _stickerPacksSection.insets = UIEdgeInsetsMake(8.0f, 0.0f, 16.0f, 0.0f);
        
        for (TGStickerPack *stickerPack in stickerPacks)
        {
            TGStickerPackCollectionItem *packItem = [[TGStickerPackCollectionItem alloc] initWithStickerPack:stickerPack];
            packItem.deselectAutomatically = true;
            
            packItem.previewStickerPack = ^
            {
                __strong TGChannelStickersController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf->_currentStickerPack set:[SSignal single:stickerPack]];
                }
            };
            [self.menuSections insertItem:packItem toSection:sectionIndex atIndex:insertIndex];
            insertIndex++;
        }
    }
    [self.collectionView reloadData];
    
    [self updateSelection:_currentStickerReference];
}

- (CGRect)sourceRectForStickerPack
{
    if (_stickerPackItem.view != nil)
        return [_stickerPackItem.view convertRect:_stickerPackItem.view.bounds toView:self.view];
    
    return CGRectZero;
}

- (void)previewStickerPack:(TGStickerPack *)stickerPack
{
    [self.view endEditing:true];
    
    __weak TGChannelStickersController *weakSelf = self;
    [TGStickersMenu presentInParentController:self stickerPack:stickerPack showShareAction:false sendSticker:nil stickerPackRemoved:nil stickerPackHidden:nil stickerPackArchived:false stickerPackIsMask:stickerPack.isMask sourceView:self.view sourceRect:^CGRect
     {
         __strong TGChannelStickersController *strongSelf = weakSelf;
         if (strongSelf == nil)
             return CGRectZero;
         
         return [strongSelf sourceRectForStickerPack];
     }];
}

@end
