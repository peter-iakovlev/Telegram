#import "TGPasswordSettingsController.h"

#import "TGPasswordInputItem.h"
#import "TGCommentCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGButtonCollectionItem.h"

#import <LegacyComponents/TGProgressWindow.h>
#import "TGCustomAlertView.h"

#import "TGPasswordSetupController.h"
#import "TGPasswordEmailController.h"
#import "TGPasswordHintController.h"
#import "TGPasswordConfirmationController.h"
#import "TGPasswordPlaceholderItem.h"

#import "TGTwoStepConfigSignal.h"
#import "TGTwoStepSetPaswordSignal.h"
#import "TGTwoStepVerifyPasswordSignal.h"

#import <LegacyComponents/TGObserverProxy.h>

#import <MTProtoKit/MTEncryption.h>

#import "TGPresentation.h"

@interface TGPasswordSettingsController ()
{
    UIActivityIndicatorView *_activityIndicator;
    
    TGTwoStepConfig *_twoStepConfig;
    NSString *_currentPassword;
    
    TGProgressWindow *_progressWindow;
    
    TGCollectionMenuSection *_withoutPasswordSection;
    TGPasswordPlaceholderItem *_placeholderItem;
    TGButtonCollectionItem *_setPasswordItem;
    TGCommentCollectionItem *_setPasswordCommentItem;
    TGCommentCollectionItem *_passwordHelpItem;
    
    TGCollectionMenuSection *_withPasswordSection;
    
    TGButtonCollectionItem *_changePasswordItem;
    TGButtonCollectionItem *_removePasswordItem;
    TGButtonCollectionItem *_emailItem;
    
    SMetaDisposable *_configDisposable;
    SMetaDisposable *_setPasswordDisposable;
    
    id _willBecomeActiveProxy;
}

@end

@implementation TGPasswordSettingsController

- (instancetype)initWithConfig:(TGTwoStepConfig *)config currentPassword:(NSString *)currentPassword
{
    self = [super init];
    if (self != nil)
    {
        self.title = TGLocalized(@"TwoStepAuth.Title");
        
        _willBecomeActiveProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification];
        
        _configDisposable = [[SMetaDisposable alloc] init];
        _setPasswordDisposable = [[SMetaDisposable alloc] init];
        
        _placeholderItem = [[TGPasswordPlaceholderItem alloc] initWithIcon:TGImageNamed(@"PasswordPlaceholderIcon.png") title:TGLocalized(@"TwoStepAuth.AdditionalPassword") text:TGLocalized(@"TwoStepAuth.SetPasswordHelp")];
        
        _setPasswordItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"TwoStepAuth.SetPassword") action:@selector(setPasswordPressed)];
        _setPasswordItem.alignment = NSTextAlignmentCenter;
        
        _setPasswordCommentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"TwoStepAuth.SetPasswordHelp")];
        _withoutPasswordSection = [[TGCollectionMenuSection alloc] initWithItems:@[_placeholderItem, _setPasswordItem, _setPasswordCommentItem]];
        _withoutPasswordSection.insets = UIEdgeInsetsMake(34.0f, 0.0f, 34.0f, 0.0f);
        
        _changePasswordItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"TwoStepAuth.ChangePassword") action:@selector(changePasswordPressed)];
        _removePasswordItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"TwoStepAuth.RemovePassword") action:@selector(removePasswordPressed)];
        _removePasswordItem.deselectAutomatically = true;
        _emailItem = [[TGButtonCollectionItem alloc] initWithTitle:@"" action:@selector(emailActionPressed)];
        _passwordHelpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"TwoStepAuth.GenericHelp")];
        _withPasswordSection = [[TGCollectionMenuSection alloc] initWithItems:@[_changePasswordItem, _removePasswordItem, _emailItem, _passwordHelpItem]];
        _withPasswordSection.insets = UIEdgeInsetsMake(34.0f, 0.0f, 34.0f, 0.0f);
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        
        _currentPassword = currentPassword;
        [self setTwoStepConfig:config];
    }
    return self;
}

- (void)dealloc
{
    [_configDisposable dispose];
    [_setPasswordDisposable dispose];
}

- (void)viewDidLoad
{
    _setPasswordCommentItem.hidden = self.view.frame.size.width < self.view.frame.size.height;
    [_setPasswordCommentItem setAlpha:!_setPasswordCommentItem.hidden ? 1.0f : 0.0f];
    [self.collectionView reloadData];
}

- (void)layoutControllerForSize:(CGSize)size duration:(NSTimeInterval)duration
{
    [super layoutControllerForSize:size duration:duration];
    
    _setPasswordCommentItem.hidden = size.width < size.height;
    [UIView animateWithDuration:duration animations:^
    {
       [_setPasswordCommentItem setAlpha:!_setPasswordCommentItem.hidden ? 1.0f : 0.0f];
    }];
}

- (void)willEnterForeground:(__unused id)notification
{
    __weak TGPasswordSettingsController *weakSelf = self;
    [_configDisposable setDisposable:[[[TGTwoStepConfigSignal twoStepConfig] deliverOn:[SQueue mainQueue]] startWithNext:^(TGTwoStepConfig *config)
    {
        __strong TGPasswordSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (!TGObjectCompare(strongSelf->_twoStepConfig, config))
                [strongSelf setTwoStepConfig:config];
        }
    }]];
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)setTwoStepConfig:(TGTwoStepConfig *)twoStepConfig
{
    _twoStepConfig = twoStepConfig;
    
    while (self.menuSections.sections.count != 0)
    {
        [self.menuSections deleteSection:0];
    }
    
    if (_twoStepConfig.hasPassword)
    {
        [self.menuSections addSection:_withPasswordSection];
        
        if (_twoStepConfig.hasRecovery)
            _emailItem.title = TGLocalized(@"TwoStepAuth.ChangeEmail");
        else
            _emailItem.title = TGLocalized(@"TwoStepAuth.SetupEmail");
        
        if (_twoStepConfig.unconfirmedEmailPattern.length == 0)
            [_passwordHelpItem setText:TGLocalized(@"TwoStepAuth.GenericHelp")];
        else
        {
            [_passwordHelpItem setText:[[NSString alloc] initWithFormat:TGLocalized(@"TwoStepAuth.PendingEmailHelp"), _twoStepConfig.unconfirmedEmailPattern]];
        }
    }
    else
        [self.menuSections addSection:_withoutPasswordSection];
    
    [self.collectionView reloadData];
}

- (void)setPasswordPressed
{
    TGPasswordSetupController *controller = [[TGPasswordSetupController alloc] initWithSetupNew:true];
    __weak TGPasswordSettingsController *weakSelf = self;
    controller.completion = ^(NSString *password)
    {
        __strong TGPasswordSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGPasswordHintController *hintController = [[TGPasswordHintController alloc] initWithPassword:password];
            hintController.completion = ^(NSString *hint)
            {
                __strong TGPasswordSettingsController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    TGPasswordEmailController *controller = [[TGPasswordEmailController alloc] initWithSkipEnabled:true];
                    controller.completion = ^(NSString *email)
                    {
                        __strong TGPasswordSettingsController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                            [progressWindow show:true];
                            
                            [strongSelf->_setPasswordDisposable setDisposable:[[[[TGTwoStepSetPaswordSignal setPasswordWithCurrentAlgo:nil currentPassword:nil currentSecret:nil nextAlgo:strongSelf->_twoStepConfig.nextAlgo nextPassword:password nextHint:hint email:email nextSecureAlgo:strongSelf->_twoStepConfig.nextSecureAlgo secureRandom:strongSelf->_twoStepConfig.secureRandom srpId:strongSelf->_twoStepConfig.srpId srpB:strongSelf->_twoStepConfig.srpB] deliverOn:[SQueue mainQueue]] onDispose:^
                            {
                                TGDispatchOnMainThread(^
                                {
                                    [progressWindow dismiss:true];
                                });
                            }] startWithNext:^(TGTwoStepConfig *config)
                            {
                                __strong TGPasswordSettingsController *strongSelf = weakSelf;
                                if (strongSelf != nil)
                                {
                                    strongSelf->_currentPassword = password;
                                    [strongSelf setTwoStepConfig:config];
                                    
                                    if (email.length != 0)
                                    {
                                        TGPasswordConfirmationController *confirmationController = [[TGPasswordConfirmationController alloc] initWithEmail:email];
                                        __weak UINavigationController *weakNavigationController = strongSelf.navigationController;
                                        confirmationController.completion = ^
                                        {
                                            __strong UINavigationController *strongNavigationController = weakNavigationController;
                                            if (strongNavigationController != nil)
                                            {
                                                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                [progressWindow show:true];
                                                
                                                [[[[TGTwoStepConfigSignal twoStepConfig] deliverOn:[SQueue mainQueue]] onDispose:^
                                                {
                                                    TGDispatchOnMainThread(^
                                                    {
                                                        [progressWindow dismiss:true];
                                                    });
                                                }] startWithNext:^(__unused TGTwoStepConfig *config)
                                                {
                                                    __strong UINavigationController *strongNavigationController = weakNavigationController;
                                                    if (strongNavigationController != nil)
                                                    {
                                                        [strongNavigationController popViewControllerAnimated:true];
                                                    }
                                                }];
                                            }
                                        };
                                        confirmationController.removePassword = ^
                                        {
                                            __strong UINavigationController *strongNavigationController = weakNavigationController;
                                            if (strongNavigationController != nil)
                                            {
                                                [TGPasswordSettingsController removePasswordWhileWaitingForActivation:strongNavigationController twoStepConfig:config];
                                            }
                                        };
                                        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:strongSelf.navigationController.viewControllers];
                                        [viewControllers removeLastObject];
                                        [viewControllers replaceObjectAtIndex:viewControllers.count - 1 withObject:confirmationController];
                                        [strongSelf.navigationController setViewControllers:viewControllers animated:true];
                                    }
                                    else
                                    {
                                        [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"TwoStepAuth.PasswordSet") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                        
                                        [strongSelf.navigationController popToViewController:strongSelf animated:true];
                                    }
                                }
                            } error:^(id error)
                            {
                                NSString *errorText = TGLocalized(@"TwoStepAuth.EmailInvalid");
                                if ([error respondsToSelector:@selector(hasPrefix:)] && [error hasPrefix:@"FLOOD_WAIT"])
                                    errorText = TGLocalized(@"TwoStepAuth.FloodError");
                                [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                            } completed:nil]];
                        }
                    };
                    
                    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:strongSelf.navigationController.viewControllers];
                    [viewControllers replaceObjectAtIndex:viewControllers.count - 1 withObject:controller];
                    [strongSelf.navigationController setViewControllers:viewControllers animated:true];
                }
            };
            
            NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:strongSelf.navigationController.viewControllers];
            [viewControllers replaceObjectAtIndex:viewControllers.count - 1 withObject:hintController];
            [strongSelf.navigationController setViewControllers:viewControllers animated:true];
        }
    };
    
    [self.navigationController pushViewController:controller animated:true];
}

- (void)changeEmailWhileWaitingForActivation
{
    
}

+ (void)removePasswordWhileWaitingForActivation:(UINavigationController *)navigationController twoStepConfig:(TGTwoStepConfig *)__unused twoStepConfig
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    __weak UINavigationController *weakNavigationController = navigationController;
    [[[[TGTwoStepSetPaswordSignal setPasswordWithCurrentAlgo:nil currentPassword:nil currentSecret:nil nextAlgo:nil nextPassword:nil nextHint:nil email:nil nextSecureAlgo:nil secureRandom:nil srpId:0 srpB:nil] deliverOn:[SQueue mainQueue]] onDispose:^
    {
        TGDispatchOnMainThread(^
        {
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil error:^(id error)
    {
        NSString *errorText = TGLocalized(@"Login.UnknownError");
        if ([error respondsToSelector:@selector(hasPrefix:)] && [error hasPrefix:@"FLOOD_WAIT"])
            errorText = TGLocalized(@"TwoStepAuth.FloodError");
        [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
    } completed:^
    {
        __strong UINavigationController *navigationController = weakNavigationController;
        if (navigationController != nil)
            [navigationController popViewControllerAnimated:true];
    }];
}

- (void)changePasswordPressed
{
    __weak TGPasswordSettingsController *weakSelf = self;
    TGPasswordSetupController *controller = [[TGPasswordSetupController alloc] initWithSetupNew:false];
    controller.completion = ^(NSString *password)
    {
        __strong TGPasswordSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGPasswordHintController *hintController = [[TGPasswordHintController alloc] initWithPassword:password];
            hintController.completion = ^(NSString *hint)
            {
                __strong TGPasswordSettingsController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if (strongSelf->_twoStepConfig.hasRecovery)
                    {
                        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                        [progressWindow show:true];
                        
                        __weak TGPasswordSettingsController *weakSelf = strongSelf;
                        
                        SSignal *signal = [[TGTwoStepVerifyPasswordSignal passwordSettings:strongSelf->_currentPassword config:strongSelf->_twoStepConfig] mapToSignal:^SSignal *(TGPasswordSettings *settings)
                        {
                            return [[TGTwoStepConfigSignal twoStepConfig] mapToSignal:^SSignal *(TGTwoStepConfig *nextConfig) {
                                return [TGTwoStepSetPaswordSignal setPasswordWithCurrentAlgo:nextConfig.currentAlgo currentPassword:settings.password currentSecret:settings.secret nextAlgo:nextConfig.nextAlgo nextPassword:password nextHint:hint email:nil nextSecureAlgo:nextConfig.nextSecureAlgo secureRandom:nextConfig.secureRandom srpId:nextConfig.srpId srpB:nextConfig.srpB];
                            }];
                        }];
                        
                        
                        [strongSelf->_setPasswordDisposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(TGTwoStepConfig *config)
                        {
                            __strong TGPasswordSettingsController *strongSelf = weakSelf;
                            if (strongSelf != nil)
                            {
                                strongSelf->_currentPassword = password;
                                [strongSelf setTwoStepConfig:config];
                                [strongSelf.navigationController popToViewController:strongSelf animated:true];
                            }
                        } error:^(id error)
                        {
                            [progressWindow dismiss:true];
                            
                            NSString *errorText = TGLocalized(@"Login.UnknownError");
                            if ([error respondsToSelector:@selector(hasPrefix:)] && [error hasPrefix:@"FLOOD_WAIT"])
                                errorText = TGLocalized(@"TwoStepAuth.FloodError");
                            [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                        } completed:^
                        {
                            [progressWindow dismiss:true];
                        }]];
                    }
                    else
                    {
                        TGPasswordEmailController *controller = [[TGPasswordEmailController alloc] initWithSkipEnabled:true];
                        controller.completion = ^(NSString *email)
                        {
                            __strong TGPasswordSettingsController *strongSelf = weakSelf;
                            if (strongSelf != nil)
                            {
                                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                [progressWindow show:true];
                                
                                SSignal *signal = [[TGTwoStepVerifyPasswordSignal passwordSettings:strongSelf->_currentPassword config:strongSelf->_twoStepConfig] mapToSignal:^SSignal *(TGPasswordSettings *settings)
                                {
                                    return [[TGTwoStepConfigSignal twoStepConfig] mapToSignal:^SSignal *(TGTwoStepConfig *nextConfig) {
                                        return [TGTwoStepSetPaswordSignal setPasswordWithCurrentAlgo:nextConfig.currentAlgo currentPassword:settings.password currentSecret:settings.secret nextAlgo:nextConfig.nextAlgo nextPassword:password nextHint:hint email:email  nextSecureAlgo:nextConfig.nextSecureAlgo secureRandom:nextConfig.secureRandom srpId:nextConfig.srpId srpB:nextConfig.srpB];
                                    }];
                                }];
                                
                                [strongSelf->_setPasswordDisposable setDisposable:[[[signal deliverOn:[SQueue mainQueue]] onDispose:^
                                {
                                    [progressWindow dismiss:true];
                                }] startWithNext:^(TGTwoStepConfig *config)
                                {
                                    __strong TGPasswordSettingsController *strongSelf = weakSelf;
                                    if (strongSelf != nil)
                                    {
                                        if (email.length != 0)
                                        {
                                            [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"TwoStepAuth.EmailSent") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                        }
                                        else
                                        {
                                            [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"TwoStepAuth.PasswordSet") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                        }
                                        
                                        [strongSelf setTwoStepConfig:config];
                                        [strongSelf.navigationController popToViewController:strongSelf animated:true];
                                    }
                                } error:^(__unused id error)
                                {
                                    [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"TwoStepAuth.EmailInvalid") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                } completed:nil]];
                            }
                        };
                        
                        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:strongSelf.navigationController.viewControllers];
                        [viewControllers replaceObjectAtIndex:viewControllers.count - 1 withObject:controller];
                        [strongSelf.navigationController setViewControllers:viewControllers animated:true];
                    }
                }
            };
            
            NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:strongSelf.navigationController.viewControllers];
            [viewControllers replaceObjectAtIndex:viewControllers.count - 1 withObject:hintController];
            [strongSelf.navigationController setViewControllers:viewControllers animated:true];
        }
    };
    
    [self.navigationController pushViewController:controller animated:true];
}

- (void)removePasswordPressed
{
    NSString *text = _twoStepConfig.hasSecureValues ? TGLocalized(@"TwoStepAuth.PasswordRemovePassportConfirmation") : TGLocalized(@"TwoStepAuth.PasswordRemoveConfirmation");
    
    __weak TGPasswordSettingsController *weakSelf = self;
    [TGCustomAlertView presentAlertWithTitle:nil message:text cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
    {
        if (okButtonPressed)
        {
            __strong TGPasswordSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [progressWindow show:true];
                
                SSignal *signal = [[TGTwoStepConfigSignal twoStepConfig] mapToSignal:^SSignal *(TGTwoStepConfig *nextConfig) {
                    return [TGTwoStepSetPaswordSignal setPasswordWithCurrentAlgo:nextConfig.currentAlgo currentPassword:strongSelf->_currentPassword currentSecret:nil nextAlgo:nil nextPassword:@"" nextHint:nil email:nil nextSecureAlgo:nil secureRandom:nil srpId:nextConfig.srpId srpB:nextConfig.srpB];
                }];
                
                [strongSelf->_setPasswordDisposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(TGTwoStepConfig *config)
                {
                    __strong TGPasswordSettingsController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        strongSelf->_currentPassword = nil;
                        [strongSelf setTwoStepConfig:config];
                    }
                } error:^(id error)
                {
                    [progressWindow dismiss:true];
                    
                    NSString *errorText = TGLocalized(@"Login.UnknownError");
                    if ([error respondsToSelector:@selector(hasPrefix:)] && [error hasPrefix:@"FLOOD_WAIT"])
                        errorText = TGLocalized(@"TwoStepAuth.FloodError");
                    [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                } completed:^
                {
                    [progressWindow dismiss:true];
                }]];
            }
        }
    }];
}

- (void)emailActionPressed
{
    __weak TGPasswordSettingsController *weakSelf = self;
    TGPasswordEmailController *controller = [[TGPasswordEmailController alloc] initWithSkipEnabled:false];
    controller.completion = ^(NSString *email)
    {
        __strong TGPasswordSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            __strong TGPasswordSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [progressWindow show:true];
                
                SSignal *signal = [[TGTwoStepConfigSignal twoStepConfig] mapToSignal:^SSignal *(TGTwoStepConfig *nextConfig)
                {
                    return [TGTwoStepSetPaswordSignal setRecoveryEmail:email currentPassword:strongSelf->_currentPassword algo:nextConfig.currentAlgo srpId:nextConfig.srpId srpB:nextConfig.srpB];
                }];
                
                [strongSelf->_setPasswordDisposable setDisposable:[[[signal deliverOn:[SQueue mainQueue]] onDispose:^
                {
                    [progressWindow dismiss:true];
                }] startWithNext:^(TGTwoStepConfig *config)
                {
                    __strong TGPasswordSettingsController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"TwoStepAuth.EmailSent") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                        
                        [strongSelf setTwoStepConfig:config];
                        [strongSelf.navigationController popToViewController:strongSelf animated:true];
                    }
                } error:^(__unused id error)
                {
                    [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"TwoStepAuth.EmailInvalid") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                } completed:nil]];
            }
        }
    };
    [self.navigationController pushViewController:controller animated:true];
}

@end
