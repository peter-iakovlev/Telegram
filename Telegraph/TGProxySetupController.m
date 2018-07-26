#import "TGProxySetupController.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TGAppDelegate.h"

#import "TGCheckCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGUsernameCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGProxyCollectionItem.h"

#import "TGCustomAlertView.h"

#import "TGDatabase.h"
#import "TGProxySignals.h"
#import "TGProxyItem.h"

#import "TGProxyDetailsController.h"

#import <MTProtoKit/MTProtoKit.h>

@interface TGProxySetupController () <ASWatcher> {
    UIBarButtonItem *_cancelItem;
    UIBarButtonItem *_editItem;
    UIBarButtonItem *_doneItem;
    
    TGSwitchCollectionItem *_socksItem;
    TGCollectionMenuSection *_listSection;
    TGSwitchCollectionItem *_callsItem;
    TGCollectionMenuSection *_callsSection;
    
    TGButtonCollectionItem *_shareItem;
    
    NSArray *_proxies;
    TGProxyItem *_selectedProxy;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGProxySetupController

- (instancetype)init
{
    return [self initModal:false];
}

- (instancetype)initModal:(bool)modal {
    self = [super init];
    if (self != nil) {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.title = TGLocalized(@"SocksProxySetup.Title");
        
        if (modal)
        {
            _cancelItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
            [self setLeftBarButtonItem:_cancelItem];
        }
        
        _editItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)];
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        
        bool inactive = false;
        _proxies = [TGProxySignals loadStoredProxies];
        _selectedProxy = [TGProxySignals currentProxy:&inactive];
    
        if (_selectedProxy == nil) {
            inactive = true;
            
            if (_proxies.count > 0)
                _selectedProxy = _proxies.firstObject;
        } else {
            for (TGProxyItem *proxy in _proxies)
            {
                if ([proxy isEqual:_selectedProxy])
                {
                    _selectedProxy = proxy;
                    break;
                }
            }
        }
        
        _socksItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.UseProxy") isOn:!inactive];
        _socksItem.interfaceHandle = self.actionHandle;
        
        TGCollectionMenuSection *typeSection = [[TGCollectionMenuSection alloc] initWithItems:@
        [
         _socksItem
        ]];
        [self.menuSections addSection:typeSection];
        
        TGHeaderCollectionItem *headerItem = [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.SavedProxies")];
        TGButtonCollectionItem *addItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.AddProxy") action:@selector(addPressed)];
        addItem.icon = self.presentation.images.collectionMenuAddImage;
        addItem.iconOffset = CGPointMake(0.0f, 0.0f);
        addItem.leftInset = 50.0f;
        _listSection = [[TGCollectionMenuSection alloc] initWithItems:@[headerItem, addItem]];
        [self.menuSections addSection:_listSection];
        
        _shareItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.ShareProxyList") action:@selector(sharePressed)];
        _shareItem.deselectAutomatically = true;
        
        _callsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.UseForCalls") isOn:!_selectedProxy.isMTProxy && TGAppDelegateInstance.callsUseProxy];
        _callsItem.isEnabled = !_selectedProxy.isMTProxy;
        _callsItem.interfaceHandle = _actionHandle;
        _callsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _callsItem,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"SocksProxySetup.UseForCallsHelp")]]
        ];
        [self.menuSections addSection:_callsSection];
        
        if (self.menuSections.sections.count != 0) {
            UIEdgeInsets topSectionInsets = ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets;
            topSectionInsets.top = 32.0f;
            ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets = topSectionInsets;
        }
        
        [self updateProxies];
    }
    return self;
}

- (void)dealloc
{
    if (_actionHandle)
    {
        [_actionHandle reset];
        [ActionStageInstance() removeWatcher:self];
    }
}

- (void)editPressed
{
    self.enableItemReorderingGestures = true;
    
    [self enterEditingMode:true];
}

- (void)donePressed
{
    self.enableItemReorderingGestures = false;
    
    if ([self isOrderChanged]) {
        _proxies = [self currentProxies];
        [TGProxySignals storeProxies:_proxies];
    }
    
    [self leaveEditingMode:true];
}

- (void)didEnterEditingMode:(bool)animated
{
    [super didEnterEditingMode:animated];
    
    if (_cancelItem != nil)
        [self setLeftBarButtonItem:nil];
    [self setRightBarButtonItem:_doneItem];
}

- (void)didLeaveEditingMode:(bool)animated
{
    [super didLeaveEditingMode:animated];
    
    if (_cancelItem != nil)
        [self setLeftBarButtonItem:_cancelItem];
    [self setRightBarButtonItem:_editItem];
}

- (NSArray *)currentProxies {
    NSMutableArray *currentProxies = [[NSMutableArray alloc] init];
    
    for (id item in _listSection.items) {
        if ([item isKindOfClass:[TGProxyCollectionItem class]]) {
            [currentProxies addObject:((TGProxyCollectionItem *)item).proxy];
        }
    }
    
    return currentProxies;
}

- (bool)isOrderChanged {
    NSArray *currentProxies = [self currentProxies];
    
    bool orderChanged = false;
    if (_proxies.count == currentProxies.count) {
        for (NSInteger i = 0; i < (NSInteger)currentProxies.count; i++) {
            if (!TGObjectCompare(((TGProxyItem *)currentProxies[i]), ((TGProxyItem *)_proxies[i]))) {
                orderChanged = true;
                break;
            }
        }
    }
    
    return orderChanged;
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"switchItemChanged"])
    {
        TGSwitchCollectionItem *switchItem = options[@"item"];
        
        if (switchItem == _callsItem)
        {
            TGAppDelegateInstance.callsUseProxy = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
        }
        else if (switchItem == _socksItem)
        {
            if (_proxies.count == 0)
            {
                [_socksItem setIsOn:false animated:true];
                [self addPressed];
            }
            else
            {
                if (_selectedProxy != nil)
                {
                    MTSocksProxySettings *settings = [self applyProxy:_selectedProxy inactive:!switchItem.isOn];;
                    if (self.completion != nil)
                        self.completion(settings, !switchItem.isOn);
                }
                else if (switchItem.isOn && _proxies.count > 0)
                {
                    _selectedProxy = _proxies.firstObject;
                    MTSocksProxySettings *settings = [self applyProxy:_selectedProxy inactive:!switchItem.isOn];
                    if (self.completion != nil)
                        self.completion(settings, !switchItem.isOn);
                }
                
                [self updateEditItem];
            }
        }
    }
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)updateEditItem
{
    [self setRightBarButtonItem:_proxies.count > 0 ? _editItem : nil];
}

- (SSignal *)connectionSignal
{
    return [[SSignal single:@(TGConnectionStateConnecting)] then:[[[SSignal complete] delay:0.1 onQueue:[SQueue mainQueue]] then:[TGProxySignals connectionStatus]]];
}

- (void)updateProxies
{
    while (_listSection.items.count != 2)
    {
        [_listSection deleteItemAtIndex:2];
    }
    
    for (TGProxyItem *proxy in _proxies)
    {
        TGProxyCollectionItem *item = [self createItemForProxy:proxy];
        if (item.selected && _socksItem.isOn)
            [item setStatusSignal:[self connectionSignal]];
        else
            [item setStatusSignal:[SSignal single:@(TGConnectionStateNotConnected)]];
        [_listSection addItem:item];
    }
    
    if (_proxies.count > 0)
        [_listSection addItem:_shareItem];
    
    [self.collectionView reloadData];
    [self updateEditItem];
}

- (TGProxyCollectionItem *)createItemForProxy:(TGProxyItem *)proxy
{
    __weak TGProxySetupController *weakSelf = self;
    TGProxyCollectionItem *item = [[TGProxyCollectionItem alloc] initWithProxy:proxy removeRequested:^{
        __strong TGProxySetupController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf removeProxy:proxy];
    }];
    __weak TGProxyCollectionItem *weakItem = item;
    item.deselectAutomatically = true;
    item.selected = [proxy isEqual:_selectedProxy];
    item.pressed = ^
    {
        __strong TGProxySetupController *strongSelf = weakSelf;
        __strong TGProxyCollectionItem *strongItem = weakItem;
        if (strongSelf != nil && strongItem != nil)
        {
            if (![strongSelf->_selectedProxy isEqual:strongItem.proxy] || !strongSelf->_socksItem.isOn)
            {
                [strongSelf applyProxy:strongItem.proxy inactive:false];
                strongSelf->_socksItem.isOn = true;
            }
        }
    };
    item.infoPressed = ^
    {
        __strong TGProxySetupController *strongSelf = weakSelf;
        __strong TGProxyCollectionItem *strongItem = weakItem;
        if (strongSelf != nil && strongItem != nil)
            [strongSelf viewProxy:strongItem.proxy];
    };
    item.canBeMovedToSectionAtIndex = ^bool (NSUInteger sectionIndex, NSUInteger index)
    {
        __strong TGProxySetupController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGCollectionMenuSection *section = strongSelf.menuSections.sections[sectionIndex];
            return section == strongSelf->_listSection && index > 1 && index < section.items.count;
        }
        return false;
    };
    [item setAvailabilitySignal:[TGProxySignals availabiltyForProxy:proxy withContext:[[TGTelegramNetworking instance] context] datacenterId:[[TGTelegramNetworking instance] masterDatacenterId]]];
    return item;
}

- (void)addPressed
{
    [self donePressed];
    
    __weak TGProxySetupController *weakSelf = self;
    TGProxyDetailsController *controller = [[TGProxyDetailsController alloc] initWithProxy:nil];
    controller.completionBlock = ^(TGProxyItem *proxy)
    {
        __strong TGProxySetupController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            NSArray<TGProxyItem *> *proxies = [strongSelf->_proxies mutableCopy];
            bool addShareItem = proxies.count == 0;
            
            NSUInteger existingIndex = [proxies indexOfObject:proxy];
            if (existingIndex != NSNotFound)
                [(NSMutableArray *)proxies removeObject:proxy];
            
            strongSelf->_proxies = [@[proxy] arrayByAddingObjectsFromArray:proxies];
            [TGProxySignals storeProxies:strongSelf->_proxies];
            
            NSUInteger listSectionIndex = [strongSelf.menuSections.sections indexOfObject:strongSelf->_listSection];
            [strongSelf.menuSections beginRecordingChanges];
            TGProxyCollectionItem *item = [strongSelf createItemForProxy:proxy];
            if (existingIndex != NSNotFound)
                [strongSelf.menuSections deleteItemFromSection:listSectionIndex atIndex:existingIndex + 2];
            [strongSelf.menuSections insertItem:item toSection:listSectionIndex atIndex:2];
            
            if (addShareItem)
                [strongSelf.menuSections addItemToSection:listSectionIndex item:strongSelf->_shareItem];
            
            [strongSelf.menuSections commitRecordedChanges:strongSelf.collectionView];

            [strongSelf applyProxy:proxy inactive:false];
            
            [strongSelf updateEditItem];
            
            strongSelf->_socksItem.isOn = true;
        }
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:controller];
    [self.navigationController presentViewController:navigationController animated:true completion:nil];
}

- (MTSocksProxySettings *)applyProxy:(TGProxyItem *)proxy inactive:(bool)inactive
{
    _selectedProxy = proxy;
    _callsItem.isEnabled = !_selectedProxy.isMTProxy;
    _callsItem.isOn = _callsItem.isEnabled && TGAppDelegateInstance.callsUseProxy;
    
    MTSocksProxySettings *settings = [TGProxySignals applyProxy:proxy inactive:proxy == nil || inactive];
    if (self.completion != nil)
        self.completion(settings, proxy == nil);
    
    for (TGProxyCollectionItem *item in _listSection.items)
    {
        if (![item isKindOfClass:[TGProxyCollectionItem class]])
            continue;
        
        item.selected = [item.proxy isEqual:proxy];
            
        if (item.selected && !inactive)
            [item setStatusSignal:[self connectionSignal]];
        else
            [item setStatusSignal:[SSignal single:@(TGConnectionStateNotConnected)]];
    }
    return settings;
}

- (void)viewProxy:(TGProxyItem *)proxy
{
    __weak TGProxySetupController *weakSelf = self;
    TGProxyDetailsController *controller = [[TGProxyDetailsController alloc] initWithProxy:proxy];
    controller.completionBlock = ^(TGProxyItem *newProxy)
    {
        __strong TGProxySetupController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updateProxy:proxy withProxy:newProxy];
    };
    [self.navigationController pushViewController:controller animated:true];
}

- (void)updateProxy:(TGProxyItem *)proxy withProxy:(TGProxyItem *)newProxy
{
    [_listSection.items enumerateObjectsUsingBlock:^(TGProxyCollectionItem *item, __unused NSUInteger index, BOOL * _Nonnull stop)
    {
        if (![item isKindOfClass:[TGProxyCollectionItem class]])
            return;
        
        if ([item.proxy isEqual:proxy])
        {
            item.proxy = newProxy;
            [item setAvailabilitySignal:[TGProxySignals availabiltyForProxy:newProxy withContext:[[TGTelegramNetworking instance] context] datacenterId:[[TGTelegramNetworking instance] masterDatacenterId]]];
            *stop = true;
        }
    }];
    
    NSMutableArray *newProxies = [_proxies mutableCopy];
    NSUInteger proxyIndex = [newProxies indexOfObject:proxy];
    if (proxyIndex == NSNotFound)
        return;
    
    [newProxies replaceObjectAtIndex:proxyIndex withObject:newProxy];
    _proxies = newProxies;
    [TGProxySignals storeProxies:newProxies];
    
    if ([_selectedProxy isEqual:proxy])
    {
        _socksItem.isOn = true;
        [self applyProxy:newProxy inactive:false];
    }
}

- (void)removeProxy:(TGProxyItem *)proxy
{
    __block NSUInteger indexToRemove = NSNotFound;
    [_listSection.items enumerateObjectsUsingBlock:^(TGProxyCollectionItem *item, NSUInteger index, BOOL * _Nonnull stop)
    {
        if (![item isKindOfClass:[TGProxyCollectionItem class]])
            return;
        
        if ([item.proxy isEqual:proxy])
        {
            indexToRemove = index;
            *stop = true;
        }
    }];
    
    NSMutableArray *newProxies = [_proxies mutableCopy];
    [newProxies removeObject:proxy];
    _proxies = newProxies;
    [TGProxySignals storeProxies:newProxies];
    
    bool removeShareItem = false;
    if (_proxies.count == 0)
    {
        _socksItem.isOn = false;
        removeShareItem = true;
    }
    
    if ([proxy isEqual:_selectedProxy])
        [self applyProxy:newProxies.firstObject inactive:false];
    
    if (indexToRemove == NSNotFound)
        return;
    
    NSUInteger listSectionIndex = [self.menuSections.sections indexOfObject:_listSection];
    [self.menuSections beginRecordingChanges];
    
    if (removeShareItem)
    {
        TGCollectionMenuSection *listSection = self.menuSections.sections[listSectionIndex];
        NSUInteger shareItemIndex = [listSection.items indexOfObject:_shareItem];
        if (shareItemIndex != NSNotFound)
            [self.menuSections deleteItemFromSection:listSectionIndex atIndex:shareItemIndex];
    }
    
    [self.menuSections deleteItemFromSection:listSectionIndex atIndex:indexToRemove];
    [self.menuSections commitRecordedChanges:self.collectionView];
}

- (void)sharePressed
{
    NSMutableString *proxiesString = [[NSMutableString alloc] init];
    
    NSMutableString *proxyString = [[NSMutableString alloc] init];
    for (TGProxyItem *proxy in _proxies)
    {
        if (proxiesString.length > 0)
            [proxiesString appendString:@"\n\n"];
        
        if (!proxy.isMTProxy)
        {
            proxyString = [[NSMutableString alloc] initWithFormat:@"https://t.me/socks?server=%@&port=%d", [TGStringUtils stringByEscapingForActorURL:proxy.server], proxy.port];
            if (proxy.username.length != 0) {
                [proxyString appendFormat:@"&user=%@&pass=%@", [TGStringUtils stringByEscapingForURL:proxy.username],[TGStringUtils stringByEscapingForURL:proxy.password]];
            }
        }
        else
        {
            proxyString = [[NSMutableString alloc] initWithFormat:@"https://t.me/proxy?server=%@&port=%d", [TGStringUtils stringByEscapingForActorURL:proxy.server], proxy.port];
            [proxyString appendFormat:@"&secret=%@", [TGStringUtils stringByEscapingForURL:proxy.secret]];
        }
        
        [proxiesString appendString:proxyString];
        [proxyString deleteCharactersInRange:NSMakeRange(0, proxyString.length)];
    }

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[proxiesString] applicationActivities:nil];
    [self presentViewController:activityViewController animated:true completion:nil];
    if (iosMajorVersion() >= 8 && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        UIView *sourceView = [_shareItem boundView];
        activityViewController.popoverPresentationController.sourceView = sourceView;
        activityViewController.popoverPresentationController.sourceRect = sourceView.bounds;
    }
}

- (BOOL)prefersStatusBarHidden
{
    if (!TGIsPad() && iosMajorVersion() >= 11 && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        return true;
    
    return [super prefersStatusBarHidden];
}

@end
