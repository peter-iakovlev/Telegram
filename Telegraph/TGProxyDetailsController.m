#import "TGProxyDetailsController.h"

#import "TGHeaderCollectionItem.h"
#import "TGCheckCollectionItem.h"
#import "TGUsernameCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGCustomAlertView.h"

#import "TGProxyItem.h"

@interface TGProxyDetailsController ()
{
    bool _editing;
    
    TGCheckCollectionItem *_socksItem;
    TGCheckCollectionItem *_telegramItem;
    
    TGUsernameCollectionItem *_addressItem;
    TGUsernameCollectionItem *_portItem;
    
    TGHeaderCollectionItem *_credentialsItem;
    TGUsernameCollectionItem *_usernameItem;
    TGUsernameCollectionItem *_passwordItem;
    TGUsernameCollectionItem *_secretItem;
    TGCommentCollectionItem *_adNoticeItem;
    
    TGCollectionMenuSection *_typeSection;
    TGCollectionMenuSection *_connectionSection;
    TGCollectionMenuSection *_authSection;
    
    TGButtonCollectionItem *_shareItem;
    TGCollectionMenuSection *_shareSection;
}
@end

@implementation TGProxyDetailsController

- (instancetype)initWithProxy:(TGProxyItem *)proxy
{
    self = [super init];
    if (self != nil)
    {
        self.title = proxy == nil ? TGLocalized(@"SocksProxySetup.AddProxyTitle") : TGLocalized(@"SocksProxySetup.ProxyDetailsTitle");
        
        if (proxy == nil)
        {
            [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        }
        else
        {
            _editing = true;
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        }
        
        CGFloat minimalInset = 100.0f;
        
        __weak TGProxyDetailsController *weakSelf = self;
        
        void (^checkFields)(NSString *) = ^(NSString *__unused value) {
            __strong TGProxyDetailsController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf checkInputValues];
            }
        };
        
        void (^focusOnNextItem)(TGUsernameCollectionItem *) = ^(TGUsernameCollectionItem *currentItem) {
            __strong TGProxyDetailsController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf focusOnNextItem:currentItem];
            }
        };
        
        _socksItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.ProxySocks5") action:@selector(socksPressed)];
        _telegramItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.ProxyTelegram") action:@selector(telegramPressed)];
        
        if (proxy != nil)
        {
            _socksItem.isChecked = !proxy.isMTProxy;
            _telegramItem.isChecked = proxy.isMTProxy;
        }
        else
        {
            _socksItem.isChecked = true;
        }
        
        _typeSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.ProxyType")],
            _socksItem,
            _telegramItem
        ]];
        [self.menuSections addSection:_typeSection];
        
        _addressItem = [[TGUsernameCollectionItem alloc] init];
        _addressItem.title = TGLocalized(@"SocksProxySetup.Hostname");
        _addressItem.placeholder = TGLocalized(@"SocksProxySetup.HostnamePlaceholder");
        if (proxy.server != nil) {
            _addressItem.username = proxy.server;
        } else {
            _addressItem.username = @"";
        }
        _addressItem.minimalInset = minimalInset;
        _addressItem.usernameChanged = checkFields;
        _addressItem.usernameValid = true;
        _addressItem.returnPressed = focusOnNextItem;
        
        _portItem = [[TGUsernameCollectionItem alloc] init];
        _portItem.title = TGLocalized(@"SocksProxySetup.Port");
        _portItem.placeholder = TGLocalized(@"SocksProxySetup.PortPlaceholder");
        if (proxy.port != 0) {
            _portItem.username = [NSString stringWithFormat:@"%d", (int)proxy.port];
        } else {
            _portItem.username = @"";
        }
        _portItem.minimalInset = minimalInset;
        _portItem.usernameChanged = checkFields;
        _portItem.usernameValid = true;
        _portItem.returnPressed = focusOnNextItem;
        _portItem.keyboardType = UIKeyboardTypeNumberPad;
        
        _connectionSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.Connection")],
            _addressItem,
            _portItem
        ]];
        [self.menuSections addSection:_connectionSection];

        _usernameItem = [[TGUsernameCollectionItem alloc] init];
        _usernameItem.title = TGLocalized(@"SocksProxySetup.Username");
        _usernameItem.placeholder = TGLocalized(@"SocksProxySetup.UsernamePlaceholder");
        if (proxy.username != nil) {
            _usernameItem.username = proxy.username;
        } else {
            _usernameItem.username = @"";
        }
        _usernameItem.minimalInset = minimalInset;
        _usernameItem.usernameChanged = checkFields;
        _usernameItem.usernameValid = true;
        _usernameItem.returnPressed = focusOnNextItem;
        
        _passwordItem = [[TGUsernameCollectionItem alloc] init];
        _passwordItem.title = TGLocalized(@"SocksProxySetup.Password");
        _passwordItem.placeholder = TGLocalized(@"SocksProxySetup.PasswordPlaceholder");
        _passwordItem.secureEntry = true;
        if (proxy.password != nil) {
            _passwordItem.username = proxy.password;
        } else {
            _passwordItem.username = @"";
        }
        _passwordItem.minimalInset = minimalInset;
        _passwordItem.usernameChanged = checkFields;
        _passwordItem.usernameValid = true;
        _passwordItem.returnPressed = focusOnNextItem;
        
        _secretItem = [[TGUsernameCollectionItem alloc] init];
        _secretItem.title = TGLocalized(@"SocksProxySetup.Secret");
        _secretItem.placeholder = TGLocalized(@"SocksProxySetup.SecretPlaceholder");
        _secretItem.keyboardType = UIKeyboardTypeASCIICapable;
        if (proxy.secret != nil) {
            _secretItem.username = proxy.secret;
        }
        _secretItem.minimalInset = minimalInset;
        _secretItem.usernameChanged = checkFields;
        _secretItem.usernameValid = true;
        _secretItem.returnPressed = focusOnNextItem;
        
        _adNoticeItem = [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"SocksProxySetup.AdNoticeHelp")];
        
        _credentialsItem = [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.Credentials")];
        _authSection = [[TGCollectionMenuSection alloc] initWithItems:@[_credentialsItem]];
        [self.menuSections addSection:_authSection];
        
        _shareItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Conversation.ContextMenuShare") action:@selector(sharePressed)];
        _shareItem.deselectAutomatically = true;
        _shareSection = [[TGCollectionMenuSection alloc] initWithItems:@[_shareItem]];
        [self.menuSections addSection:_shareSection];
        
        if (self.menuSections.sections.count != 0) {
            UIEdgeInsets topSectionInsets = ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets;
            topSectionInsets.top = 32.0f;
            ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets = topSectionInsets;
        }
        
        [self updateSectionsAnimated:false];
        [self checkInputValues];
    }
    return self;
}

- (void)updateSectionsAnimated:(bool)animated
{
    bool isTelegram = _telegramItem.isChecked;
    bool changed = false;
    
    _credentialsItem.title = isTelegram ? TGLocalized(@"SocksProxySetup.RequiredCredentials") : TGLocalized(@"SocksProxySetup.Credentials");
    
    if (animated)
        [self.menuSections beginRecordingChanges];
    
    NSUInteger credentialsSectionIndex = [self.menuSections.sections indexOfObject:_authSection];
    NSUInteger indexOfSecretItem = [self.menuSections.sections[credentialsSectionIndex] indexOfItem:_secretItem];
    NSUInteger indexOfAdItem = [self.menuSections.sections[credentialsSectionIndex] indexOfItem:_adNoticeItem];
    NSUInteger indexOfUsernameItem = [self.menuSections.sections[credentialsSectionIndex] indexOfItem:_usernameItem];
    NSUInteger indexOfPasswordItem = [self.menuSections.sections[credentialsSectionIndex] indexOfItem:_passwordItem];
    
    if (isTelegram)
    {
        if (indexOfPasswordItem != NSNotFound)
            [self.menuSections deleteItemFromSection:credentialsSectionIndex atIndex:indexOfPasswordItem];
        if (indexOfUsernameItem != NSNotFound)
            [self.menuSections deleteItemFromSection:credentialsSectionIndex atIndex:indexOfUsernameItem];
        if (indexOfSecretItem == NSNotFound)
        {
            [self.menuSections insertItem:_secretItem toSection:credentialsSectionIndex atIndex:1];
            [self.menuSections addItemToSection:credentialsSectionIndex item:_adNoticeItem];
        }
    }
    else
    {
        if (indexOfSecretItem != NSNotFound)
        {
            [self.menuSections deleteItemFromSection:credentialsSectionIndex atIndex:indexOfAdItem];
            [self.menuSections deleteItemFromSection:credentialsSectionIndex atIndex:indexOfSecretItem];
        }
        if (indexOfUsernameItem == NSNotFound)
            [self.menuSections insertItem:_usernameItem toSection:credentialsSectionIndex atIndex:1];
        if (indexOfPasswordItem == NSNotFound)
            [self.menuSections insertItem:_passwordItem toSection:credentialsSectionIndex atIndex:2];
    }
    
    if (animated)
        [self.menuSections commitRecordedChanges:self.collectionView];
    else if (changed)
        [self.collectionView reloadData];
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed {
    if (_editing)
        [self.navigationController popViewControllerAnimated:true];
    else
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];

    if (self.completionBlock != nil)
        self.completionBlock([[TGProxyItem alloc] initWithServer:_addressItem.username port:(uint16_t)[_portItem.username intValue] username:_usernameItem.username password:_passwordItem.username secret:_secretItem.username]);
}

- (void)checkInputValues {
    bool ready = false;
    bool hasConnection = _addressItem.username.length != 0 && _portItem.username.length != 0;
    if (_socksItem.isChecked)
    {
        ready = hasConnection;
    }
    else if (_telegramItem.isChecked)
    {
        NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFabcdef0123456789"];
        NSCharacterSet *invalidChars = [validChars invertedSet];
        
        bool hasCorrectSecret = (_secretItem.username.length == 32 || _secretItem.username.length == 34) && [_secretItem.username rangeOfCharacterFromSet:invalidChars].location == NSNotFound;
        ready = hasConnection && hasCorrectSecret;
    }
    self.navigationItem.rightBarButtonItem.enabled = ready;
    _shareItem.highlightable = ready;
    _shareItem.enabled = ready;
}

- (void)focusOnNextItem:(TGCollectionItem *)currentItem {
    bool foundCurrent = false;
    for (TGCollectionMenuSection *section in self.menuSections.sections) {
        for (TGCollectionItem *item in section.items) {
            if (item == currentItem) {
                foundCurrent = true;
            } else if (foundCurrent) {
                if ([item isKindOfClass:[TGUsernameCollectionItem class]]) {
                    [(TGUsernameCollectionItem *)item becomeFirstResponder];
                    
                    NSIndexPath *indexPath = [self indexPathForItem:item];
                    if (indexPath != nil) {
                        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:true];
                        [self.collectionView layoutSubviews];
                        if ([item isKindOfClass:[TGUsernameCollectionItem class]]) {
                            [((TGUsernameCollectionItem *)item) becomeFirstResponder];
                        }
                    }
                    
                    return;
                }
            }
        }
    }
    
    [self.view endEditing:true];
}

- (void)sharePressed {
    NSMutableString *result = nil;
    if (_socksItem.isChecked)
    {
        result = [[NSMutableString alloc] initWithFormat:@"https://t.me/socks?server=%@&port=%@", [TGStringUtils stringByEscapingForActorURL:_addressItem.username], [TGStringUtils stringByEscapingForURL:_portItem.username]];
        if (_usernameItem.username.length != 0) {
            [result appendFormat:@"&user=%@&pass=%@", [TGStringUtils stringByEscapingForURL:_usernameItem.username], [TGStringUtils stringByEscapingForURL:_passwordItem.username]];
        }
    }
    else if (_telegramItem.isChecked)
    {
        result = [[NSMutableString alloc] initWithFormat:@"https://t.me/proxy?server=%@&port=%@", [TGStringUtils stringByEscapingForActorURL:_addressItem.username], [TGStringUtils stringByEscapingForURL:_portItem.username]];
        [result appendFormat:@"&secret=%@", [TGStringUtils stringByEscapingForURL:_secretItem.username]];
    }
    else
    {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:result];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    [self presentViewController:activityViewController animated:true completion:nil];
    if (iosMajorVersion() >= 8 && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        UIView *sourceView = [_shareItem boundView];
        activityViewController.popoverPresentationController.sourceView = sourceView;
        activityViewController.popoverPresentationController.sourceRect = sourceView.bounds;
    }
    //[[UIPasteboard generalPasteboard] setString:result];
    //[TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"Username.LinkCopied") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
}

- (void)socksPressed
{
    _socksItem.isChecked = true;
    _telegramItem.isChecked = false;
    [self checkInputValues];
    [self updateSectionsAnimated:true];
}

- (void)telegramPressed
{
    _socksItem.isChecked = false;
    _telegramItem.isChecked = true;
    [self checkInputValues];
    [self updateSectionsAnimated:true];
}

@end
