#import "TGPasswordEntryController.h"

#import "TGTelegraph.h"

#import "TGNavigationController.h"

#import "TGUsernameCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGButtonCollectionItem.h"

#import "TGTwoStepVerifyPasswordSignal.h"
#import "TGTwoStepRecoverySignals.h"

#import "TGProgressWindow.h"

#import "TGAlertView.h"

#import "TGPasswordRecoveryController.h"

#import "TGAccountSignals.h"

@interface TGPasswordEntryController ()
{
    TGTwoStepConfig *_twoStepConfig;
    
    TGUsernameCollectionItem *_passwordItem;
    
    SMetaDisposable *_verifyPasswordDisposable;
    SMetaDisposable *_requestRecoveryDisposable;
    
    UIBarButtonItem *_nextItem;
    
    TGCollectionMenuSection *_resetSection;
}

@end

@implementation TGPasswordEntryController

- (instancetype)initWithConfig:(TGTwoStepConfig *)config
{
    self = [super init];
    if (self != nil)
    {
        _verifyPasswordDisposable = [[SMetaDisposable alloc] init];
        _requestRecoveryDisposable = [[SMetaDisposable alloc] init];
        
        _twoStepConfig = config;
        
        self.title = TGLocalized(@"TwoStepAuth.EnterPasswordTitle");
        _nextItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
        [self setRightBarButtonItem:_nextItem];
        _nextItem.enabled = false;
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        _passwordItem = [[TGUsernameCollectionItem alloc] init];
        _passwordItem.title = TGLocalized(@"TwoStepAuth.EnterPasswordPassword");
        _passwordItem.placeholder = @"";
        _passwordItem.usernameValid = true;
        _passwordItem.secureEntry = true;
        __weak TGPasswordEntryController *weakSelf = self;
        _passwordItem.usernameChanged = ^(NSString *password)
        {
            __strong TGPasswordEntryController *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf->_nextItem.enabled = password.length != 0;
        };
        [items addObject:_passwordItem];
        
        if (_twoStepConfig.currentHint.length != 0)
        {
            TGCommentCollectionItem *hintItem = [[TGCommentCollectionItem alloc] initWithText:[[NSString alloc] initWithFormat:TGLocalized(@"TwoStepAuth.EnterPasswordHint"), _twoStepConfig.currentHint]];
            hintItem.topInset = 0.0f;
            [items addObject:hintItem];
        }
        
        TGCommentCollectionItem *helpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"TwoStepAuth.EnterPasswordHelp")];
        helpItem.topInset = 2.0f;
        [items addObject:helpItem];
        
        TGCommentCollectionItem *forgotItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"TwoStepAuth.EnterPasswordForgot")];
        forgotItem.textColor = TGAccentColor();
        forgotItem.action = ^
        {
            __strong TGPasswordEntryController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf forgotPressed];
        };
        [items addObject:forgotItem];
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
        section.insets = UIEdgeInsetsMake(32.0f, 0.0f, 32.0f, 0.0f);
        [self.menuSections addSection:section];
    }
    return self;
}

- (void)dealloc
{
    [_verifyPasswordDisposable dispose];
    [_requestRecoveryDisposable dispose];
}

- (void)nextPressed
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    NSString *password = _passwordItem.username;
    __weak TGPasswordEntryController *weakSelf = self;
    [_verifyPasswordDisposable setDisposable:[[[[TGTwoStepVerifyPasswordSignal checkPassword:password config:_twoStepConfig] deliverOn:[SQueue mainQueue]] onDispose:^
    {
        TGDispatchOnMainThread(^
        {
            [progressWindow dismiss:true];
        });
    }] startWithNext:^(__unused id next)
    {
        __strong TGPasswordEntryController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (strongSelf->_completion)
                strongSelf->_completion(password);
        }
    } error:^(id error)
    {
        NSString *errorText = TGLocalized(@"TwoStepAuth.EnterPasswordInvalid");
        if ([error respondsToSelector:@selector(hasPrefix:)] && [error hasPrefix:@"FLOOD_WAIT"])
            errorText = TGLocalized(@"TwoStepAuth.FloodError");
        [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
    } completed:nil]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_passwordItem becomeFirstResponder];
}

- (void)forgotPressed
{
    if (_twoStepConfig.hasRecovery)
    {
        __weak TGPasswordEntryController *weakSelf = self;
        
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [progressWindow show:true];
        
        [_requestRecoveryDisposable setDisposable:[[[[TGTwoStepRecoverySignals requestPasswordRecovery] deliverOn:[SQueue mainQueue]] onDispose:^
        {
            TGDispatchOnMainThread(^
            {
                [progressWindow dismiss:true];
            });
        }] startWithNext:^(NSString *emailPattern)
        {
            __strong TGPasswordEntryController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGPasswordRecoveryController *controller = [[TGPasswordRecoveryController alloc] initWithEmailPattern:emailPattern];
                controller.completion = ^(bool success, __unused int32_t userId)
                {
                    __strong TGPasswordEntryController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        if (success)
                        {
                            [strongSelf dismissViewControllerAnimated:true completion:^
                            {
                                __strong TGPasswordEntryController *strongSelf = weakSelf;
                                if (strongSelf->_completion)
                                    strongSelf->_completion(nil);
                            }];
                        }
                        else
                        {
                            [strongSelf dismissViewControllerAnimated:true completion:nil];
                            
                            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"TwoStepAuth.RecoveryFailed") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                            
                            /*if (_resetSection == nil)
                            {
                                TGButtonCollectionItem *resetItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"TwoStepAuth.ResetAccount") action:@selector(resetAccountPressed)];
                                resetItem.titleColor = TGDestructiveAccentColor();
                                resetItem.deselectAutomatically = true;
                                TGCommentCollectionItem *resetHelpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"TwoStepAuth.ResetAccountHelp")];
                                strongSelf->_resetSection = [[TGCollectionMenuSection alloc] initWithItems:@[resetItem, resetHelpItem]];
                                [strongSelf.menuSections addSection:strongSelf->_resetSection];
                                [strongSelf.collectionView reloadData];
                            }*/
                        }
                    }
                };
                controller.cancelled = ^
                {
                    __strong TGPasswordEntryController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [strongSelf dismissViewControllerAnimated:true completion:nil];
                    }
                };
                
                TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
                [strongSelf presentViewController:navigationController animated:true completion:nil];
            }
        } error:^(id error)
        {
            NSString *errorText = TGLocalized(@"TwoStepAuth.GenericError");
            if ([error hasPrefix:@"FLOOD_WAIT"])
                errorText = TGLocalized(@"TwoStepAuth.FloodError");
            [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        } completed:nil]];
    }
    else
    {
        [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"TwoStepAuth.RecoveryUnavailable") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        
        /*if (_resetSection == nil)
        {
            TGButtonCollectionItem *resetItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"TwoStepAuth.ResetAccount") action:@selector(resetAccountPressed)];
            resetItem.titleColor = TGDestructiveAccentColor();
            resetItem.deselectAutomatically = true;
            TGCommentCollectionItem *resetHelpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"TwoStepAuth.ResetAccountHelp")];
            _resetSection = [[TGCollectionMenuSection alloc] initWithItems:@[resetItem, resetHelpItem]];
            [self.menuSections addSection:_resetSection];
            [self.collectionView reloadData];
        }*/
    }
}

- (void)resetAccountPressed
{
    __weak TGPasswordEntryController *weakSelf = self;
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"TwoStepAuth.ResetAccountConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
    {
        __strong TGPasswordEntryController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (okButtonPressed)
            {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [progressWindow show:true];
                
                [[[[TGAccountSignals deleteAccount] deliverOn:[SQueue mainQueue]] onDispose:^
                {
                    [progressWindow dismiss:true];
                }] startWithNext:nil error:^(__unused id error)
                {
                } completed:^
                {
                    __strong TGPasswordEntryController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [TGTelegraphInstance doLogout];
                    }
                }];
            }
        }
    }] show];
}

@end
