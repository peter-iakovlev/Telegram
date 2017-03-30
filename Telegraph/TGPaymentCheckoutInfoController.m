#import "TGPaymentCheckoutInfoController.h"

#import "TGPaymentForm.h"

#import "TGHeaderCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGUsernameCollectionItem.h"
#import "TGCountryAndPhoneCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGNavigationController.h"
#import "TGProgressWindow.h"

#import "Stripe.h"
#import "TGBotSignals.h"

#import "TGTwoStepConfigSignal.h"
#import "TGPaymentPasswordAlert.h"

#import "TGTwoStepVerifyPasswordSignal.h"
#import "TGLoginCountriesController.h"
#import "TGVariantCollectionItem.h"

#import "TGTelegramNetworking.h"

#import "TGAlertView.h"

@interface TGPaymentCheckoutInfoController () {
    UIBarButtonItem *_doneItem;
    
    int32_t _messageId;
    
    TGUsernameCollectionItem *_shippindAddressLine1;
    TGUsernameCollectionItem *_shippindAddressLine2;
    TGUsernameCollectionItem *_shippindAddressCity;
    TGUsernameCollectionItem *_shippindAddressState;
    TGVariantCollectionItem *_shippingAddressCountry;
    NSString *_shippingAddressCountryId;
    TGUsernameCollectionItem *_shippindAddressPostcode;
    
    TGUsernameCollectionItem *_receiverName;
    TGUsernameCollectionItem *_receiverEmail;
    TGUsernameCollectionItem *_receiverPhone;
    
    TGSwitchCollectionItem *_saveInfo;
    
    SMetaDisposable *_validateDisposable;
    TGPaymentCheckoutInfoControllerFocus _focus;
}

@end

@implementation TGPaymentCheckoutInfoController

- (instancetype)initWithMessageId:(int32_t)messageId invoice:(TGInvoice *)invoice canSaveInfo:(bool)canSaveInfo enableSaveInfoByDefault:(bool)enableSaveInfoByDefault currentInfo:(TGPaymentRequestedInfo *)currentInfo focus:(TGPaymentCheckoutInfoControllerFocus)focus {
    self = [super init];
    if (self != nil) {
        _messageId = messageId;
        _validateDisposable = [[SMetaDisposable alloc] init];
        
        _focus = focus;
        
        self.title = TGLocalized(@"CheckoutInfo.Title");
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        self.navigationItem.rightBarButtonItem = _doneItem;
        
        CGFloat minimalInset = 100.0f;
        
        __weak TGPaymentCheckoutInfoController *weakSelf = self;
        void (^checkFields)(NSString *) = ^(NSString *__unused value) {
            __strong TGPaymentCheckoutInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf checkInputValues];
            }
        };
        
        void (^focusOnNextItem)(TGUsernameCollectionItem *) = ^(TGUsernameCollectionItem *currentItem) {
            __strong TGPaymentCheckoutInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf focusOnNextItem:currentItem];
            }
        };
        
        if (invoice.shippingAddressRequested) {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"CheckoutInfo.ShippingInfoTitle")]];
            
            _shippindAddressLine1 = [[TGUsernameCollectionItem alloc] init];
            _shippindAddressLine1.placeholder = TGLocalized(@"CheckoutInfo.ShippingInfoAddress1Placeholder");
            _shippindAddressLine1.title = TGLocalized(@"CheckoutInfo.ShippingInfoAddress1");
            _shippindAddressLine1.username = currentInfo.shippingAddress.streetLine1 ?: @"";
            _shippindAddressLine1.minimalInset = minimalInset;
            _shippindAddressLine1.usernameChanged = checkFields;
            _shippindAddressLine1.usernameValid = true;
            _shippindAddressLine1.returnPressed = focusOnNextItem;
            [items addObject:_shippindAddressLine1];
            
            _shippindAddressLine2 = [[TGUsernameCollectionItem alloc] init];
            _shippindAddressLine2.placeholder = TGLocalized(@"CheckoutInfo.ShippingInfoAddress2Placeholder");
            _shippindAddressLine2.title = TGLocalized(@"CheckoutInfo.ShippingInfoAddress2");
            _shippindAddressLine2.username = currentInfo.shippingAddress.streetLine2 ?: @"";
            _shippindAddressLine2.minimalInset = minimalInset;
            _shippindAddressLine2.usernameChanged = checkFields;
            _shippindAddressLine2.usernameValid = true;
            _shippindAddressLine2.returnPressed = focusOnNextItem;
            [items addObject:_shippindAddressLine2];
            
            _shippindAddressCity = [[TGUsernameCollectionItem alloc] init];
            _shippindAddressCity.placeholder = TGLocalized(@"CheckoutInfo.ShippingInfoCityPlaceholder");
            _shippindAddressCity.title = TGLocalized(@"CheckoutInfo.ShippingInfoCity");
            _shippindAddressCity.username = currentInfo.shippingAddress.city ?: @"";
            _shippindAddressCity.minimalInset = minimalInset;
            _shippindAddressCity.usernameChanged = checkFields;
            _shippindAddressCity.usernameValid = true;
            _shippindAddressCity.returnPressed = focusOnNextItem;
            [items addObject:_shippindAddressCity];
            
            _shippindAddressState = [[TGUsernameCollectionItem alloc] init];
            _shippindAddressState.placeholder = TGLocalized(@"CheckoutInfo.ShippingInfoStatePlaceholder");
            _shippindAddressState.title = TGLocalized(@"CheckoutInfo.ShippingInfoState");
            _shippindAddressState.username = currentInfo.shippingAddress.state ?: @"";
            _shippindAddressState.minimalInset = minimalInset;
            _shippindAddressState.usernameChanged = checkFields;
            _shippindAddressState.usernameValid = true;
            _shippindAddressState.returnPressed = focusOnNextItem;
            [items addObject:_shippindAddressState];
            
            _shippingAddressCountryId = currentInfo.shippingAddress.countryIso2;
            NSString *countryName = _shippingAddressCountryId.length != 0 ? [TGLoginCountriesController countryNameByCountryId:_shippingAddressCountryId code:NULL] : nil;
            _shippingAddressCountry = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"CheckoutInfo.ShippingInfoCountry") variant:countryName == nil ? @"" : countryName action:@selector(countryPressed)];
            _shippingAddressCountry.minLeftPadding = minimalInset + 20.0f;
            _shippingAddressCountry.variantColor = [UIColor blackColor];
            [items addObject:_shippingAddressCountry];
            
            _shippindAddressPostcode = [[TGUsernameCollectionItem alloc] init];
            _shippindAddressPostcode.placeholder = TGLocalized(@"CheckoutInfo.ShippingInfoPostcodePlaceholder");
            _shippindAddressPostcode.title = TGLocalized(@"CheckoutInfo.ShippingInfoPostcode");
            _shippindAddressPostcode.username = currentInfo.shippingAddress.postCode ?: @"";
            _shippindAddressPostcode.minimalInset = minimalInset;
            _shippindAddressPostcode.usernameChanged = checkFields;
            _shippindAddressPostcode.usernameValid = true;
            _shippindAddressPostcode.returnPressed = focusOnNextItem;
            [items addObject:_shippindAddressPostcode];
            
            TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
            [self.menuSections addSection:section];
        }
        
        if (invoice.nameRequested || invoice.emailRequested || invoice.phoneRequested) {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"CheckoutInfo.ReceiverInfoTitle")]];
            
            if (invoice.nameRequested) {
                _receiverName = [[TGUsernameCollectionItem alloc] init];
                _receiverName.placeholder = TGLocalized(@"CheckoutInfo.ReceiverInfoNamePlaceholder");
                _receiverName.title = TGLocalized(@"CheckoutInfo.ReceiverInfoName");
                _receiverName.username = currentInfo.name ?: @"";
                _receiverName.minimalInset = minimalInset;
                _receiverName.usernameChanged = checkFields;
                _receiverName.usernameValid = true;
                _receiverName.returnPressed = focusOnNextItem;
                [items addObject:_receiverName];
            }
            
            if (invoice.emailRequested) {
                _receiverEmail = [[TGUsernameCollectionItem alloc] init];
                _receiverEmail.placeholder = TGLocalized(@"CheckoutInfo.ReceiverInfoEmailPlaceholder");
                _receiverEmail.title = TGLocalized(@"CheckoutInfo.ReceiverInfoEmail");
                _receiverEmail.username = currentInfo.email ?: @"";
                _receiverEmail.minimalInset = minimalInset;
                _receiverEmail.usernameChanged = checkFields;
                _receiverEmail.usernameValid = true;
                _receiverEmail.returnPressed = focusOnNextItem;
                [items addObject:_receiverEmail];
            }
            
            if (invoice.phoneRequested) {
                _receiverPhone = [[TGUsernameCollectionItem alloc] init];
                _receiverPhone.placeholder = TGLocalized(@"CheckoutInfo.ReceiverInfoPhone");
                _receiverPhone.title = TGLocalized(@"CheckoutInfo.ReceiverInfoPhone");
                _receiverPhone.username = currentInfo.phone ?: @"";
                _receiverPhone.minimalInset = minimalInset;
                _receiverPhone.usernameChanged = checkFields;
                _receiverPhone.usernameValid = true;
                _receiverPhone.keyboardType = UIKeyboardTypePhonePad;
                _receiverPhone.returnPressed = focusOnNextItem;
                [items addObject:_receiverPhone];
            }
            
            TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
            [self.menuSections addSection:section];
        }
        
        if (canSaveInfo) {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            _saveInfo = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"CheckoutInfo.SaveInfo") isOn:enableSaveInfoByDefault];
            [items addObject:_saveInfo];
            
            TGCommentCollectionItem *helpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"CheckoutInfo.SaveInfoHelp")];
            [items addObject:helpItem];
            
            TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
            [self.menuSections addSection:section];
        }
        
        if (self.menuSections.sections.count != 0) {
            UIEdgeInsets topSectionInsets = ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets;
            topSectionInsets.top = 32.0f;
            ((TGCollectionMenuSection *)self.menuSections.sections[0]).insets = topSectionInsets;
        }
        
        [self checkInputValues];
    }
    return self;
}

- (void)dealloc {
    [_validateDisposable dispose];
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
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

- (void)checkInputValues {
    bool enablePay = true;
    if (_shippindAddressLine1 != nil && _shippindAddressLine1.username.length == 0) {
        enablePay = false;
    }
    if (_shippindAddressCity != nil && _shippindAddressCity.username.length == 0) {
        enablePay = false;
    }
    if (_shippindAddressState != nil && _shippindAddressState.username.length == 0) {
        //enablePay = false;
    }
    if (_shippingAddressCountry != nil && _shippingAddressCountryId.length == 0) {
        enablePay = false;
    }
    if (_shippindAddressPostcode != nil && _shippindAddressPostcode.username.length < 2) {
        enablePay = false;
    }
    if (_receiverName != nil && _receiverName.username.length == 0) {
        enablePay = false;
    }
    if (_receiverEmail != nil && _receiverEmail.username.length == 0) {
        enablePay = false;
    }
    if (_receiverPhone != nil && _receiverPhone.username.length == 0) {
        enablePay = false;
    }
    
    _doneItem.enabled = enablePay;
}

- (TGPaymentRequestedInfo *)currentPaymentInfo {
    TGPostAddress *postAddress = nil;
    if (_shippindAddressLine1 != nil) {
        postAddress = [[TGPostAddress alloc] initWithStreetLine1:_shippindAddressLine1.username streetLine2:_shippindAddressLine2.username city:_shippindAddressCity.username state:_shippindAddressState.username countryIso2:[_shippingAddressCountryId uppercaseString] postCode:_shippindAddressPostcode.username];
    }
    return [[TGPaymentRequestedInfo alloc] initWithName:_receiverName.username phone:_receiverPhone.username email:_receiverEmail.username shippingAddress:postAddress];
}

- (void)donePressed {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.1f];
    
    TGPaymentRequestedInfo *currentInfo = [self currentPaymentInfo];
    bool saveInfo = _saveInfo.isOn;
    __weak TGPaymentCheckoutInfoController *weakSelf = self;
    [_validateDisposable setDisposable:[[[[TGBotSignals validateRequestedPaymentInfo:_messageId info:currentInfo saveInfo:_saveInfo.isOn] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:^(TGValidatedRequestedInfo *next) {
        __strong TGPaymentCheckoutInfoController *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf.completed != nil) {
            [strongSelf.view endEditing:true];
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.completed(currentInfo, next, saveInfo);
            });
        }
    } error:^(id error) {
        NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        NSString *alertText = TGLocalized(@"Login.UnknownError");
        if ([errorType isEqual:@"SHIPPING_NOT_AVAILABLE"]) {
            alertText = TGLocalized(@"CheckoutInfo.ErrorShippingNotAvailable");
        } else if ([errorType isEqual:@"ADDRESS_STATE_INVALID"]) {
            alertText = TGLocalized(@"CheckoutInfo.ErrorStateInvalid");
        } else if ([errorType isEqual:@"ADDRESS_POSTCODE_INVALID"]) {
            alertText = TGLocalized(@"CheckoutInfo.ErrorPostcodeInvalid");
        } else if ([errorType isEqual:@"ADDRESS_CITY_INVALID"]) {
            alertText = TGLocalized(@"CheckoutInfo.ErrorCityInvalid");
        } else if ([errorType isEqualToString:@"REQ_INFO_NAME_INVALID"]) {
            alertText = TGLocalized(@"CheckoutInfo.ErrorNameInvalid");
        } else if ([errorType isEqualToString:@"REQ_INFO_EMAIL_INVALID"]) {
            alertText = TGLocalized(@"CheckoutInfo.ErrorEmailInvalid");
        } else if ([errorType isEqualToString:@"REQ_INFO_PHONE_INVALID"]) {
            alertText = TGLocalized(@"CheckoutInfo.ErrorPhoneInvalid");
        }
        [TGAlertView presentAlertWithTitle:nil message:alertText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
    } completed:nil]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_focus != TGPaymentCheckoutInfoControllerFocusNone) {
        TGCollectionItem *focusItem = nil;
        switch (_focus) {
            case TGPaymentCheckoutInfoControllerFocusAddress: {
                focusItem = _shippindAddressLine1;
                break;
            }
            case TGPaymentCheckoutInfoControllerFocusPhone: {
                focusItem = _receiverPhone;
                break;
            }
            case TGPaymentCheckoutInfoControllerFocusEmail: {
                focusItem = _receiverEmail;
                break;
            }
            case TGPaymentCheckoutInfoControllerFocusName: {
                focusItem = _receiverName;
                break;
            }
            default: {
                break;
            }
        }
        _focus = TGPaymentCheckoutInfoControllerFocusNone;
        if (focusItem != nil) {
            NSIndexPath *indexPath = [self indexPathForItem:focusItem];
            if (indexPath != nil) {
                [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:false];
                [self.collectionView layoutSubviews];
                if ([focusItem isKindOfClass:[TGUsernameCollectionItem class]]) {
                    [((TGUsernameCollectionItem *)focusItem) becomeFirstResponder];
                }
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:true];
}

- (void)countryPressed {
    TGLoginCountriesController *countriesController = [[TGLoginCountriesController alloc] initWithCodes:false];
    __weak TGPaymentCheckoutInfoController *weakSelf = self;
    countriesController.countrySelected = ^(__unused int code, __unused NSString *name, NSString *countryId) {
        __strong TGPaymentCheckoutInfoController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            strongSelf->_shippingAddressCountryId = countryId;
            NSString *countryName = countryId.length != 0 ? [TGLoginCountriesController countryNameByCountryId:countryId code:NULL] : nil;
            strongSelf->_shippingAddressCountry.variant = countryName;
            [strongSelf checkInputValues];
        }
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:countriesController];
    [self presentViewController:navigationController animated:true completion:nil];
}

@end
