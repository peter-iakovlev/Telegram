#import "TGFastTwoStepVerificationSetupController.h"

#import "TGTelegramNetworking.h"

#import "TGHeaderCollectionItem.h"
#import "TGUsernameCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import <LegacyComponents/TGProgressWindow.h>

#import "TGTwoStepSetPaswordSignal.h"
#import "TGAlertView.h"
#import "TGTwoStepConfig.h"
#import "TGTwoStepConfigSignal.h"

#import "TGPasswordConfirmationController.h"

@interface TGFastTwoStepVerificationSetupController () {
    void (^_completion)();
    
    SMetaDisposable *_initialTwoStepCofigDisposable;
    TGTwoStepConfig *_currentConfig;
    
    TGCollectionMenuSection *_passwordSection;
    TGCollectionMenuSection *_emailSection;
    
    TGUsernameCollectionItem *_passwordItem;
    TGUsernameCollectionItem *_passwordConfirmationItem;
    TGUsernameCollectionItem *_emailItem;
    
    TGCollectionMenuSection *_emailConfirmationSection;
    TGCommentCollectionItem *_emailConfirmationItem;
    
    UIBarButtonItem *_doneItem;
    
    SMetaDisposable *_periodicCheckDisposable;
    bool _isPolling;
}

@end

@implementation TGFastTwoStepVerificationSetupController

- (instancetype)initWithTwoStepConfig:(SSignal *)twoStepConfig completion:(void (^)(bool))completion {
    self = [super init];
    if (self != nil) {
        _completion = [completion copy];
        
        self.title = TGLocalized(@"FastTwoStepSetup.Title");
        
        __weak TGFastTwoStepVerificationSetupController *weakSelf = self;
        void (^checkFields)(NSString *) = ^(NSString *__unused value) {
            __strong TGFastTwoStepVerificationSetupController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf checkInputValues];
            }
        };
        
        void (^focusOnNextItem)(TGUsernameCollectionItem *) = ^(TGUsernameCollectionItem *currentItem) {
            __strong TGFastTwoStepVerificationSetupController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf focusOnNextItem:currentItem];
            }
        };
        
        _passwordItem = [[TGUsernameCollectionItem alloc] init];
        _passwordItem.title = @"";
        _passwordItem.secureEntry = true;
        _passwordItem.username = @"";
        _passwordItem.placeholder = TGLocalized(@"FastTwoStepSetup.PasswordPlaceholder");
        _passwordItem.usernameChanged = checkFields;
        _passwordItem.usernameValid = true;
        _passwordItem.returnPressed = focusOnNextItem;
        
        _passwordConfirmationItem = [[TGUsernameCollectionItem alloc] init];
        _passwordConfirmationItem.title = @"";
        _passwordConfirmationItem.secureEntry = true;
        _passwordConfirmationItem.username = @"";
        _passwordConfirmationItem.placeholder = TGLocalized(@"FastTwoStepSetup.PasswordConfirmationPlaceholder");
        _passwordConfirmationItem.usernameChanged = checkFields;
        _passwordConfirmationItem.usernameValid = true;
        _passwordConfirmationItem.returnPressed = focusOnNextItem;
        
        _passwordSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"FastTwoStepSetup.PasswordSection")],
            _passwordItem,
            _passwordConfirmationItem,
            [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"FastTwoStepSetup.PasswordHelp")]
        ]];
        UIEdgeInsets topSectionInsets = _passwordSection.insets;
        topSectionInsets.top = 32.0f;
        _passwordSection.insets = topSectionInsets;
        //[self.menuSections addSection:passwordSection];
        
        _emailItem = [[TGUsernameCollectionItem alloc] init];
        _emailItem.secureEntry = false;
        _emailItem.title = @"";
        _emailItem.keyboardType = UIKeyboardTypeEmailAddress;
        _emailItem.username = @"";
        _emailItem.placeholder = TGLocalized(@"FastTwoStepSetup.EmailPlaceholder");
        _emailItem.usernameChanged = checkFields;
        _emailItem.usernameValid = true;
        _emailItem.returnPressed = ^(__unused id item) {
            __strong TGFastTwoStepVerificationSetupController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf donePressed];
            }
        };
        
        _emailSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"FastTwoStepSetup.EmailSection")],
            _emailItem,
            [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"FastTwoStepSetup.EmailHelp")]
        ]];
        //[self.menuSections addSection:emailSection];
        
        TGCommentCollectionItem *textItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"TwoStepAuth.ConfirmationText")];
        TGCommentCollectionItem *abortItem = [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"TwoStepAuth.ConfirmationAbort")];
        abortItem.topInset = 0.0f;
        abortItem.textColor = TGAccentColor();
        abortItem.action = ^ {
            __strong TGFastTwoStepVerificationSetupController *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_currentConfig != nil) {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow show:true];
                [[[[TGTwoStepSetPaswordSignal setPasswordWithCurrentSalt:nil currentPassword:nil nextSalt:strongSelf->_currentConfig.nextSalt nextPassword:@"" nextHint:nil email:nil] deliverOn:[SQueue mainQueue]] onDispose:^{
                    TGDispatchOnMainThread(^{
                        [progressWindow dismiss:true];
                    });
                }] startWithNext:^(TGTwoStepConfig *result) {
                    __strong TGFastTwoStepVerificationSetupController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        strongSelf->_passwordItem.username = @"";
                        strongSelf->_passwordConfirmationItem.username = @"";
                        strongSelf->_currentConfig = result;
                        if (strongSelf->_twoStepConfigUpdated) {
                            strongSelf->_twoStepConfigUpdated(result);
                        }
                        [strongSelf reloadSections];
                    }
                } error:^(__unused id error) {
                    
                } completed: ^{;
                }];
            }
        };
        
        _emailConfirmationItem = [[TGCommentCollectionItem alloc] initWithText:@""];
        _emailConfirmationItem.topInset = 4.0f;
        
        _emailConfirmationSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            textItem,
            _emailConfirmationItem,
            abortItem
        ]];
        _emailConfirmationSection.insets = UIEdgeInsetsMake(16.0f, 0.0f, 32.0f, 0.0f);
        //[self.menuSections addSection:_emailConfirmationSection];
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        
        _initialTwoStepCofigDisposable = [[SMetaDisposable alloc] init];
        [_initialTwoStepCofigDisposable setDisposable:[[twoStepConfig deliverOn:[SQueue mainQueue]] startWithNext:^(TGTwoStepConfig *config) {
            __strong TGFastTwoStepVerificationSetupController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_currentConfig = config;
                [strongSelf reloadSections];
            }
        }]];
        
        _periodicCheckDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_initialTwoStepCofigDisposable dispose];
    [_periodicCheckDisposable dispose];
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed {
    if (_doneItem.enabled) {
        NSString *password = _passwordItem.username;
        __weak TGFastTwoStepVerificationSetupController *weakSelf = self;
        NSString *email = _emailItem.username;
        dispatch_block_t block = ^{
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow show:true];
            
            [[[[TGTwoStepSetPaswordSignal setPassword:password hint:@"" email:email] deliverOn:[SQueue mainQueue]] onDispose:^{
                TGDispatchOnMainThread(^{
                    [progressWindow dismiss:true];
                });
            }] startWithNext:^(id result) {
                __strong TGFastTwoStepVerificationSetupController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if ([result isKindOfClass:[TGTwoStepConfig class]] && email.length != 0) {
                        [progressWindow dismiss:true];
                        strongSelf->_currentConfig = result;
                        if (strongSelf->_twoStepConfigUpdated) {
                            strongSelf->_twoStepConfigUpdated(result);
                        }
                        [strongSelf reloadSections];
                    } else {
                        [progressWindow dismissWithSuccess];
                        __strong TGFastTwoStepVerificationSetupController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            if (strongSelf->_completion) {
                                strongSelf->_completion(true);
                            }
                        }
                    }
                }
            } error:^(__unused id error) {
                NSString *errorText = TGLocalized(@"TwoStepAuth.EmailInvalid");
                if ([error respondsToSelector:@selector(hasPrefix:)] && [error hasPrefix:@"FLOOD_WAIT"])
                    errorText = TGLocalized(@"TwoStepAuth.FloodError");
                [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            } completed:^{
            }];
        };
        
        if (email.length == 0) {
            if (iosMajorVersion() >= 8)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:TGLocalized(@"TwoStepAuth.EmailSkipAlert") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TGLocalized(@"Common.Cancel") style:UIAlertActionStyleCancel handler:nil];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:TGLocalized(@"TwoStepAuth.EmailSkip") style:UIAlertActionStyleDestructive handler:^(__unused UIAlertAction *action)
                                           {
                                               block();
                                           }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:true completion:nil];
            }
            else
            {
                TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"TwoStepAuth.EmailSkipAlert") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"TwoStepAuth.EmailSkip") completionBlock:^(bool okButtonPressed)
                                          {
                                              block();
                                          }];
                [alertView show];
            }
        } else {
            block();
        }
    }
}

- (void)reloadSections {
    if (_currentConfig != nil) {
        while (self.menuSections.sections.count != 0) {
            [self.menuSections deleteSection:0];
        }
        
        if (_currentConfig.unconfirmedEmailPattern.length != 0) {
            [_emailConfirmationItem setText:_currentConfig.unconfirmedEmailPattern];
            [self.menuSections addSection:_emailConfirmationSection];
            [self setRightBarButtonItem:nil];
            if (!_isPolling) {
                _isPolling = true;
                SSignal *poll = [[[TGTwoStepConfigSignal twoStepConfig] then:[[SSignal complete] delay:10.0 onQueue:[SQueue mainQueue]]] restart];
                __weak TGFastTwoStepVerificationSetupController *weakSelf = self;
                [_periodicCheckDisposable setDisposable:[[poll deliverOn:[SQueue mainQueue]] startWithNext:^(TGTwoStepConfig *next) {
                    __strong TGFastTwoStepVerificationSetupController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        bool reload = false;
                        if ((strongSelf->_currentConfig.currentSalt != nil) != (next.currentSalt != nil)) {
                            reload = true;
                        } else if (strongSelf->_currentConfig.unconfirmedEmailPattern.length != next.unconfirmedEmailPattern.length) {
                            reload = true;
                        }
                        strongSelf->_currentConfig = next;
                        if (strongSelf->_twoStepConfigUpdated) {
                            strongSelf->_twoStepConfigUpdated(next);
                        }
                        if (reload) {
                            [strongSelf reloadSections];
                        }
                    }
                }]];
            }
        } else {
            [self.menuSections addSection:_passwordSection];
            [self.menuSections addSection:_emailSection];
            [self setRightBarButtonItem:_doneItem];
            [self checkInputValues];
            
            if (_currentConfig.currentSalt.length != 0 && _currentConfig.unconfirmedEmailPattern.length == 0) {
                if (_completion) {
                    _completion();
                }
            }
            if (_isPolling) {
                _isPolling = false;
                [_periodicCheckDisposable setDisposable:nil];
            }
        }
    }
    [self.collectionView reloadData];
}

- (void)checkInputValues {
    _doneItem.enabled = _passwordItem.username.length != 0 && _passwordConfirmationItem.username.length != 0;
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

@end
