#import "TGPaymentMethodController.h"

#import "TGPaymentForm.h"

#import "TGCheckCollectionItem.h"
#import "TGButtonCollectionItem.h"

#import "TGNavigationController.h"

#import "Stripe.h"

#import "TGPaymentWebController.h"
#import "TGAddPaymentCardController.h"

#import <PassKit/PassKit.h>

#import "NSString+Stripe_CardBrands.h"

@implementation TGPaymentMethodSavedCredentialsCard

- (instancetype)initWithCard:(TGPaymentSavedCredentialsCard *)card {
    self = [super init];
    if (self != nil) {
        _card = card;
    }
    return self;
}

- (NSString *)title {
    return _card.title;
}

@end

@implementation TGPaymentMethodStripeToken

- (instancetype)initWithToken:(TGPaymentCredentialsStripeToken *)token {
    self = [super init];
    if (self != nil) {
        _token = token;
    }
    return self;
}

- (NSString *)title {
    return _token.title;
}

@end

@implementation TGPaymentMethodApplePay

- (NSString *)title {
    return @"Apple Pay";
}

@end

@implementation TGPaymentMethodWebToken

- (instancetype)initWithJsonData:(NSString *)jsonData title:(NSString *)title saveCredentials:(bool)saveCredentials {
    self = [super init];
    if (self != nil) {
        _jsonData = jsonData;
        _title = title;
        _saveCredentials = saveCredentials;
    }
    return self;
}

@end

@implementation TGPaymentMethods

- (instancetype)initWithMethods:(NSArray<id<TGPaymentMethod>> *)methods selectedIndex:(NSUInteger)selectedIndex {
    self = [super init];
    if (self != nil) {
        _methods = methods;
        _selectedIndex = selectedIndex;
    }
    return self;
}

@end

@interface TGPaymentMethodController () <STPAddCardViewControllerDelegate> {
    UIBarButtonItem *_doneItem;
    
    TGPaymentMethods *_paymentMethods;
    NSString *_useWebviewUrl;
    NSString *_botName;
    bool _canSave;
    bool _allowSaving;
    bool _enableApplePay;
    NSString *_nativeParams;
}

@end

@implementation TGPaymentMethodController

+ (bool)supportsApplePay {
    if (iosMajorVersion() >= 8) {
        if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]]) {
            return true;
        }
    }
    
    return false;
}

- (instancetype)initWithPaymentMethods:(TGPaymentMethods *)paymentMethods useWebviewUrl:(NSString *)useWebviewUrl botName:(NSString *)botName canSave:(bool)canSave allowSaving:(bool)allowSaving nativeParams:(NSString *)nativeParams {
    self = [super init];
    if (self != nil) {
        _useWebviewUrl = useWebviewUrl;
        _nativeParams = nativeParams;
        _botName = botName;
        _canSave = canSave;
        _allowSaving = allowSaving;
        
        self.title = TGLocalized(@"Checkout.PaymentMethod.Title");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        self.navigationItem.rightBarButtonItem = _doneItem;
        
        NSMutableArray *updatedPaymentMethods = [[NSMutableArray alloc] initWithArray:paymentMethods.methods];
        NSUInteger updatedSelectedIndex = paymentMethods.selectedIndex;
        bool found = false;
        for (id method in updatedPaymentMethods) {
            if ([method isKindOfClass:[TGPaymentMethodApplePay class]]) {
                found = true;
                break;
            }
        }
        if (iosMajorVersion() >= 8) {
            if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]]) {
                _enableApplePay = true;
            }
        }
        if (!found && _enableApplePay) {
            [updatedPaymentMethods insertObject:[[TGPaymentMethodApplePay alloc] init] atIndex:0];
            updatedSelectedIndex += 1;
        }
        _paymentMethods = [[TGPaymentMethods alloc] initWithMethods:updatedPaymentMethods selectedIndex:updatedSelectedIndex];
        
        [self reloadItems];
    }
    return self;
}

- (void)reloadItems {
    while (self.menuSections.sections.count != 0) {
        [self.menuSections deleteSection:0];
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    NSUInteger index = 0;
    for (id<TGPaymentMethod> method in _paymentMethods.methods) {
        TGCheckCollectionItem *item = [[TGCheckCollectionItem alloc] initWithTitle:[method title] action:@selector(optionSelected:)];
        item.isChecked = index == _paymentMethods.selectedIndex;
        [items addObject:item];
        index += 1;
    }
    
    TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:items];
    section.insets = UIEdgeInsetsMake(32.0f, 0.0f, 16.0f, 0.0f);
    
    _doneItem.enabled = items.count != 0;
    [self.menuSections addSection:section];
    
    TGCollectionMenuSection *newSection = [[TGCollectionMenuSection alloc] initWithItems:@[[[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Checkout.PaymentMethod.New") action:@selector(enterPressed)]]];
    [self.menuSections addSection:newSection];
    newSection.insets = UIEdgeInsetsMake(16.0f, 0.0f, 16.0f, 0.0f);
    
    [self.collectionView reloadData];
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed {
    if(_completed) {
        _completed(_paymentMethods);
    }
}

- (void)optionSelected:(TGCheckCollectionItem *)item {
    NSUInteger index = 0;
    for (TGCheckCollectionItem *checkItem in ((TGCollectionMenuSection *)self.menuSections.sections[0]).items) {
        if (checkItem == item) {
            checkItem.isChecked = true;
            _paymentMethods = [[TGPaymentMethods alloc] initWithMethods:_paymentMethods.methods selectedIndex:index];
        } else {
            checkItem.isChecked = false;
        }
        index += 1;
    }
}
                                               
- (void)enterPressed {
    if (_useWebviewUrl != nil) {
        TGPaymentWebController *controller = [[TGPaymentWebController alloc] initWithUrl:_useWebviewUrl confirmation:false canSave:false allowSaving:false];
        __weak TGPaymentMethodController *weakSelf = self;
        controller.completed = ^(NSString *data, NSString *title, __unused bool save) {
            __strong TGPaymentMethodController *strongSelf = weakSelf;
            if (strongSelf != nil && data != nil && title != nil) {
                id<TGPaymentMethod> addedMethod = [[TGPaymentMethodWebToken alloc] initWithJsonData:data title:title saveCredentials:true];
                
                NSMutableArray *updatedMethods = [[NSMutableArray alloc] init];
                [updatedMethods addObject:addedMethod];
                
                if (strongSelf->_enableApplePay) {
                    [updatedMethods insertObject:[[TGPaymentMethodApplePay alloc] init] atIndex:0];
                }
                
                _paymentMethods = [[TGPaymentMethods alloc] initWithMethods:updatedMethods selectedIndex:updatedMethods.count - 1];
                
                [self dismissViewControllerAnimated:true completion:nil];
                [self reloadItems];
            }
        };
        [self presentViewController:[TGNavigationController navigationControllerWithRootController:controller] animated:true completion:nil];
    } else if (_nativeParams != nil) {
        __weak TGPaymentMethodController *weakSelf = self;
        void (^addCard)() = ^{
            __strong TGPaymentMethodController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[_nativeParams dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                if (dict != nil) {
                    TGAddPaymentCardController *addController = [[TGAddPaymentCardController alloc] initWithCanSave:strongSelf->_canSave allowSaving:strongSelf->_allowSaving requestCountry:[dict[@"need_country"] boolValue] requestPostcode:[dict[@"need_zip"] boolValue] requestName:[dict[@"need_cardholder_name"] boolValue] publishableKey:dict[@"publishable_key"]];
                    addController.completion = ^(TGPaymentMethodStripeToken *token) {
                        __strong TGPaymentMethodController *strongSelf = weakSelf;
                        if (strongSelf != nil && token != nil) {
                            id<TGPaymentMethod> addedMethod = token;
                            
                            NSMutableArray *updatedMethods = [[NSMutableArray alloc] init];
                            [updatedMethods addObject:addedMethod];
                            
                            if (strongSelf->_enableApplePay) {
                                [updatedMethods insertObject:[[TGPaymentMethodApplePay alloc] init] atIndex:0];
                            }
                            
                            strongSelf->_paymentMethods = [[TGPaymentMethods alloc] initWithMethods:updatedMethods selectedIndex:updatedMethods.count - 1];
                            
                            [strongSelf reloadItems];
                        }
                    };
                    [strongSelf presentViewController:[TGNavigationController navigationControllerWithRootController:addController] animated:true completion:nil];
                }
            }
        };
        
        addCard();
    }
}

- (void)addCardViewControllerDidCancel:(STPAddCardViewController *)__unused addCardViewController {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)addCardViewController:(STPAddCardViewController *)__unused addCardViewController
               didCreateToken:(STPToken *)token
                   completion:(STPErrorBlock)completion {
    NSString *last4 = token.card.last4;
    NSString *brand = [NSString stp_stringWithCardBrand:token.card.brand];
    
    TGPaymentCredentialsStripeToken *stripeToken = [[TGPaymentCredentialsStripeToken alloc] initWithTokenId:token.tokenId title:[[brand stringByAppendingString:@"*"] stringByAppendingString:last4] saveCredentials:true];
    
    id<TGPaymentMethod> addedMethod = [[TGPaymentMethodStripeToken alloc] initWithToken:stripeToken];
    
    NSMutableArray *updatedMethods = [[NSMutableArray alloc] init];
    /*for (id<TGPaymentMethod> method in _paymentMethods.methods) {
        if ([method class] != [addedMethod class]) {
            [updatedMethods addObject:method];
        }
    }*/
    
    [updatedMethods addObject:addedMethod];
    _paymentMethods = [[TGPaymentMethods alloc] initWithMethods:updatedMethods selectedIndex:updatedMethods.count - 1];
    
    completion(nil);
    [self dismissViewControllerAnimated:true completion:nil];
    [self reloadItems];
}

@end
