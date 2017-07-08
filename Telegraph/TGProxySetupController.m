#import "TGProxySetupController.h"

#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TGAppDelegate.h"

#import "TGCheckCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGUsernameCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGAlertView.h"

#import "TGStringUtils.h"

#import "TGDatabase.h"

#import <MTProtoKit/MtProtoKit.h>

@interface TGProxySetupController () <ASWatcher> {
    TGCheckCollectionItem *_typeNone;
    TGCheckCollectionItem *_typeSocks;
    
    TGUsernameCollectionItem *_addressItem;
    TGUsernameCollectionItem *_portItem;
    TGUsernameCollectionItem *_usernameItem;
    TGUsernameCollectionItem *_passwordItem;
    
    TGCollectionMenuSection *_connectionSection;
    TGCollectionMenuSection *_authSection;
    
    TGSwitchCollectionItem *_callsItem;
    TGCollectionMenuSection *_callsSection;
    
    TGButtonCollectionItem *_shareItem;
    TGCollectionMenuSection *_shareSection;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGProxySetupController

- (instancetype)initWithCurrentSettings {
    self = [super init];
    if (self != nil) {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.title = TGLocalized(@"SocksProxySetup.Title");
        
        MTSocksProxySettings *settings = nil;
        bool inactive = false;
        NSData *socksProxyData = [TGDatabaseInstance() customProperty:@"socksProxyData"];
        if (socksProxyData != nil) {
            NSDictionary *socksProxyDict = [NSKeyedUnarchiver unarchiveObjectWithData:socksProxyData];
            if (socksProxyDict[@"ip"] != nil && socksProxyDict[@"port"] != nil) {
                settings = [[MTSocksProxySettings alloc] initWithIp:socksProxyDict[@"ip"] port:(uint16_t)[socksProxyDict[@"port"] intValue] username:socksProxyDict[@"username"] password:socksProxyDict[@"password"]];
                inactive = [socksProxyDict[@"inactive"] boolValue];
            }
        }
        if (settings == nil) {
            inactive = true;
        }
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        
        self.navigationItem.rightBarButtonItem.enabled = false;
        
        CGFloat minimalInset = 100.0f;
        
        __weak TGProxySetupController *weakSelf = self;
        
        _typeNone = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.TypeNone") action:@selector(typeNonePressed)];
        _typeSocks = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.TypeSocks") action:@selector(typeSocksPressed)];
        
        _typeNone.isChecked = inactive;
        _typeSocks.isChecked = !inactive;
        
        TGCollectionMenuSection *typeSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _typeNone,
            _typeSocks
        ]];
        [self.menuSections addSection:typeSection];
        
        void (^checkFields)(NSString *) = ^(NSString *__unused value) {
            __strong TGProxySetupController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf checkInputValues];
            }
        };
        
        void (^focusOnNextItem)(TGUsernameCollectionItem *) = ^(TGUsernameCollectionItem *currentItem) {
            __strong TGProxySetupController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf focusOnNextItem:currentItem];
            }
        };
        
        _addressItem = [[TGUsernameCollectionItem alloc] init];
        _addressItem.title = TGLocalized(@"SocksProxySetup.Hostname");
        if (settings.ip != nil) {
            _addressItem.username = settings.ip;
        } else {
            _addressItem.username = @"";
        }
        _addressItem.placeholder = @"";
        _addressItem.minimalInset = minimalInset;
        _addressItem.usernameChanged = checkFields;
        _addressItem.usernameValid = true;
        _addressItem.returnPressed = focusOnNextItem;
        
        _portItem = [[TGUsernameCollectionItem alloc] init];
        _portItem.title = TGLocalized(@"SocksProxySetup.Port");
        if (settings.port != 0) {
            _portItem.username = [NSString stringWithFormat:@"%d", (int)settings.port];
        } else {
            _portItem.username = @"";
        }
        _portItem.placeholder = @"";
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
        
        _usernameItem = [[TGUsernameCollectionItem alloc] init];
        _usernameItem.title = TGLocalized(@"SocksProxySetup.Username");
        if (settings.username != nil) {
            _usernameItem.username = settings.username;
        } else {
            _usernameItem.username = @"";
        }
        _usernameItem.placeholder = @"";
        _usernameItem.minimalInset = minimalInset;
        _usernameItem.usernameChanged = checkFields;
        _usernameItem.usernameValid = true;
        _usernameItem.returnPressed = focusOnNextItem;
        
        _passwordItem = [[TGUsernameCollectionItem alloc] init];
        _passwordItem.title = TGLocalized(@"SocksProxySetup.Password");
        _passwordItem.secureEntry = true;
        if (settings.password != nil) {
            _passwordItem.username = settings.password;
        } else {
            _passwordItem.username = @"";
        }
        _passwordItem.placeholder = @"";
        _passwordItem.minimalInset = minimalInset;
        _passwordItem.usernameChanged = checkFields;
        _passwordItem.usernameValid = true;
        _passwordItem.returnPressed = focusOnNextItem;
        
        _authSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.Credentials")],
            _usernameItem,
            _passwordItem
        ]];
        
        _shareItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Conversation.ContextMenuShare") action:@selector(sharePressed)];
        _shareItem.deselectAutomatically = true;
        _shareSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _shareItem
        ]];
        
        _callsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"SocksProxySetup.UseForCalls") isOn:TGAppDelegateInstance.callsUseProxy];
        _callsItem.interfaceHandle = _actionHandle;
        _callsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _callsItem,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"SocksProxySetup.UseForCallsHelp")]]
        ];
        
        if (self.menuSections.sections.count != 0) {
            UIEdgeInsets topSectionInsets = ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets;
            topSectionInsets.top = 32.0f;
            ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets = topSectionInsets;
        }
        
        [self resetSections];
        [self checkInputValues];
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
    }
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed {
    if (_completion) {
        _completion([[MTSocksProxySettings alloc] initWithIp:_addressItem.username port:(uint16_t)[_portItem.username intValue] username:_usernameItem.username password:_passwordItem.username], _typeNone.isChecked);
    }
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)checkInputValues {
    bool ready = _addressItem.username.length != 0 && _portItem.username.length != 0;
    if (_typeNone.isChecked) {
        ready = true;
    }
    self.navigationItem.rightBarButtonItem.enabled = ready;
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

- (void)resetSections {
    while (self.menuSections.sections.count != 1) {
        [self.menuSections deleteSection:1];
    }
    
    if (_typeNone.isChecked) {
    } else if (_typeSocks.isChecked) {
        [self.menuSections addSection:_connectionSection];
        [self.menuSections addSection:_authSection];
        [self.menuSections addSection:_callsSection];
        [self.menuSections addSection:_shareSection];
    } 
    
    if (self.isViewLoaded) {
        [self.collectionView reloadData];
    }
}

- (void)typeNonePressed {
    if (!_typeNone.isChecked) {
        _typeNone.isChecked = true;
        _typeSocks.isChecked = false;
        [self resetSections];
        [self checkInputValues];
    }
}

- (void)typeSocksPressed {
    if (!_typeSocks.isChecked) {
        _typeSocks.isChecked = true;
        _typeNone.isChecked = false;
        [self resetSections];
        [self checkInputValues];
    }
}

- (void)sharePressed {
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"tg://socks?server=%@&port=%@", [TGStringUtils stringByEscapingForURL:_addressItem.username], [TGStringUtils stringByEscapingForURL:_portItem.username]];
    if (_usernameItem.username.length != 0) {
        [result appendFormat:@"&user=%@&pass=%@", [TGStringUtils stringByEscapingForURL:_usernameItem.username], [TGStringUtils stringByEscapingForURL:_passwordItem.username]];
    }
    
    [[UIPasteboard generalPasteboard] setString:result];
    
    [TGAlertView presentAlertWithTitle:nil message:TGLocalized(@"Username.LinkCopied") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
}

@end
