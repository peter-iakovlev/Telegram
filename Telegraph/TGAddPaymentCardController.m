#import "TGAddPaymentCardController.h"

#import "TGCommentCollectionItem.h"
#import "TGCreditCardNumberCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGUsernameCollectionItem.h"
#import "TGVariantCollectionItem.h"

#import "TGProgressWindow.h"

#import "Stripe.h"

#import "TGPaymentMethodController.h"
#import "TGPaymentForm.h"

#import "TGAlertView.h"
#import "TGNavigationController.h"

#import "TGLoginCountriesController.h"

#import "NSString+Stripe_CardBrands.h"

@interface TGAddPaymentCardController () {
    UIBarButtonItem *_doneItem;
    
    TGCreditCardNumberCollectionItem *_cardItem;
    TGSwitchCollectionItem *_saveItem;
    TGUsernameCollectionItem *_nameItem;
    NSString *_selectedCountryCode;
    TGVariantCollectionItem *_countryItem;
    TGUsernameCollectionItem *_postcodeItem;
    STPCardParams *_currentCard;
    NSString *_publishableKey;
    bool _alreadyDidAppear;
    STPAPIClient *_apiClient;
}

@end

@implementation TGAddPaymentCardController

- (instancetype)initWithCanSave:(bool)canSave allowSaving:(bool)allowSaving requestCountry:(bool)requestCountry requestPostcode:(bool)requestPostcode requestName:(bool)requestName publishableKey:(NSString *)publishableKey {
    self = [super init];
    if (self != nil) {
        _publishableKey = publishableKey;
        
        self.title = TGLocalized(@"Checkout.NewCard.Title");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        self.navigationItem.rightBarButtonItem = _doneItem;
        _doneItem.enabled = false;
        
        __weak TGAddPaymentCardController *weakSelf = self;
        dispatch_block_t checkFields = ^{
            __strong TGAddPaymentCardController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf checkInput];
            }
        };
        
        _cardItem = [[TGCreditCardNumberCollectionItem alloc] init];
        _cardItem.cardChanged = ^(STPCardParams *params) {
            __strong TGAddPaymentCardController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_currentCard == nil && params != nil) {
                    if (_nameItem != nil)  {
                        [strongSelf->_nameItem becomeFirstResponder];
                    }
                }
                strongSelf->_currentCard = params;
                checkFields();
            }
        };
        
        TGCollectionMenuSection *cardSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Checkout.NewCard.PaymentCard")],
            _cardItem
        ]];
        cardSection.insets = UIEdgeInsetsMake(32.0f, 0.0, 32.0f, 0.0f);
        [self.menuSections addSection:cardSection];
        
        if (requestName) {
            _nameItem = [[TGUsernameCollectionItem alloc] init];
            _nameItem.title = @"";
            _nameItem.autoCapitalize = true;
            _nameItem.placeholder = TGLocalized(@"Checkout.NewCard.CardholderNamePlaceholder");
            //_nameItem.minimalInset = minimalInset;
            _nameItem.usernameChanged = ^(__unused NSString *text) {
                checkFields();
            };
            _nameItem.returnPressed = ^(__unused TGUsernameCollectionItem *item) {
                __strong TGAddPaymentCardController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (strongSelf->_postcodeItem != nil) {
                        [strongSelf->_postcodeItem becomeFirstResponder];
                    }
                }
            };
            _nameItem.usernameValid = true;
            
            TGCollectionMenuSection *nameSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Checkout.NewCard.CardholderNameTitle")],
                _nameItem
            ]];
            nameSection.insets = UIEdgeInsetsMake(0.0f, 0.0, 32.0f, 0.0f);
            [self.menuSections addSection:nameSection];
        }
        
        if (requestCountry || requestPostcode) {
            NSMutableArray *postcodeItems = [[NSMutableArray alloc] init];
            [postcodeItems addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Checkout.NewCard.PostcodeTitle")]];
            
            if (requestCountry) {
                _countryItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"CheckoutInfo.ShippingInfoCountry") variant:@"" action:@selector(countryPressed)];
                //_countryItem.minLeftPadding = minimalInset + 20.0f;
                _countryItem.variantColor = [UIColor blackColor];
                [postcodeItems addObject:_countryItem];
            }
            
            if (requestPostcode) {
                _postcodeItem = [[TGUsernameCollectionItem alloc] init];
                _postcodeItem.placeholder = TGLocalized(@"Checkout.NewCard.PostcodePlaceholder");
                _postcodeItem.title = @"";
                //_nameItem.minimalInset = minimalInset;
                _postcodeItem.usernameChanged = ^(__unused NSString *text) {
                    checkFields();
                };
                _postcodeItem.usernameValid = true;
                [postcodeItems addObject:_postcodeItem];
            }

            TGCollectionMenuSection *postcodeSection = [[TGCollectionMenuSection alloc] initWithItems:postcodeItems];
            postcodeSection.insets = UIEdgeInsetsMake(0.0f, 0.0, 32.0f, 0.0f);
            [self.menuSections addSection:postcodeSection];
        }
        
        if (canSave) {
            NSMutableArray *saveItems = [[NSMutableArray alloc] init];
            _saveItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Checkout.NewCard.SaveInfo") isOn:false];
            _saveItem.isEnabled = allowSaving;
            [saveItems addObject:_saveItem];
            if (!allowSaving) {
                TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Checkout.NewCard.SaveInfoEnableHelp") paragraphSpacing:0.0 clearFormatting:true];
                commentItem.action = ^{
                    __strong TGAddPaymentCardController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        
                    }
                };
                [saveItems addObject:commentItem];
            } else {
                [saveItems addObject:[[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Checkout.NewCard.SaveInfoHelp")]];
            }
            TGCollectionMenuSection *saveSection = [[TGCollectionMenuSection alloc] initWithItems:saveItems];
            [self.menuSections addSection:saveSection];
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_alreadyDidAppear) {
        _alreadyDidAppear = true;
        [_cardItem becomeFirstResponder];
    }
}

- (void)checkInput {
    bool doneEnabled = _currentCard != nil;
    
    if (_nameItem != nil && _nameItem.username.length == 0) {
        doneEnabled = false;
    }
    
    if (_countryItem != nil && _selectedCountryCode.length == 0) {
        doneEnabled = false;
    }
    
    if (_postcodeItem != nil && _postcodeItem.username.length == 0) {
        doneEnabled = false;
    }
    
    _doneItem.enabled = doneEnabled;
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed {
    if (_currentCard != nil) {
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow showWithDelay:0.1];
        __weak TGAddPaymentCardController *weakSelf = self;
        
        STPPaymentConfiguration *configuration = [[STPPaymentConfiguration sharedConfiguration] copy];
        configuration.smsAutofillDisabled = true;
        configuration.publishableKey = _publishableKey;
        configuration.appleMerchantIdentifier = @"merchant.ph.telegra.Telegraph";
        
        _apiClient = [[STPAPIClient alloc] initWithConfiguration:configuration];
        
        _currentCard.name = _nameItem.username;
        _currentCard.addressZip = _postcodeItem.username;
        _currentCard.addressCountry = _selectedCountryCode;
        
        [_apiClient createTokenWithCard:_currentCard completion:^(STPToken *token, NSError *error) {
            TGDispatchOnMainThread(^{
                __strong TGAddPaymentCardController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (error) {
                        [progressWindow dismiss:true];
                        [[[TGAlertView alloc] initWithTitle:nil message:error.localizedDescription cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okPressed) {
                        }] show];
                    } else {
                        [progressWindow dismiss:true];
                        NSString *last4 = token.card.last4;
                        NSString *brand = [NSString stp_stringWithCardBrand:token.card.brand];
                        TGPaymentCredentialsStripeToken *stripeToken = [[TGPaymentCredentialsStripeToken alloc] initWithTokenId:token.tokenId title:[[brand stringByAppendingString:@"*"] stringByAppendingString:last4] saveCredentials:strongSelf->_saveItem.isOn];
                        if (strongSelf->_completion) {
                            strongSelf->_completion([[TGPaymentMethodStripeToken alloc] initWithToken:stripeToken]);
                        }
                        
                        [strongSelf cancelPressed];
                    }
                }
            });
        }];
    }
}

- (void)countryPressed {
    TGLoginCountriesController *countriesController = [[TGLoginCountriesController alloc] initWithCodes:false];
    __weak TGAddPaymentCardController *weakSelf = self;
    countriesController.countrySelected = ^(__unused int code, __unused NSString *name, NSString *countryId) {
        __strong TGAddPaymentCardController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            strongSelf->_selectedCountryCode = countryId;
            NSString *countryName = countryId.length != 0 ? [TGLoginCountriesController countryNameByCountryId:countryId code:NULL] : nil;
            strongSelf->_countryItem.variant = countryName;
            [strongSelf checkInput];
        }
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:countriesController];
    [self presentViewController:navigationController animated:true completion:nil];
}

@end
