#import "TGPaymentReceiptController.h"

#import "TGMessage.h"
#import "TGDatabase.h"
#import "TGBotSignals.h"

#import "TGPaymentCheckoutHeaderItem.h"
#import "TGPaymentCheckoutPriceItem.h"
#import "TGSeparatorCollectionItem.h"

#import "TGModernButton.h"

#import "TGPaymentCheckoutInfoController.h"
#import "TGNavigationController.h"
#import "TGShippingMethodController.h"
#import "TGPaymentMethodController.h"

#import "TGProgressWindow.h"

#import "TGPaymentPasswordAlert.h"
#import "TGTwoStepConfigSignal.h"
#import "TGTwoStepVerifyPasswordSignal.h"

#import "TGStoredTmpPassword.h"
#import "TGTelegramNetworking.h"

#import "TGAlertView.h"

#import "TGCurrencyFormatter.h"

@interface TGPaymentReceiptController () {
    SMetaDisposable *_disposable;
    
    TGMessage *_message;
    TGUser *_bot;
    
    TGCollectionMenuSection *_headerSection;
    TGCollectionMenuSection *_priceSection;
    TGCollectionMenuSection *_dataSection;
    TGCollectionMenuSection *_footerSection;
    
    TGPaymentReceipt *_receipt;
    
    UIView *_payButtonContainer;
    TGModernButton *_payButton;
    
    UIActivityIndicatorView *_activityIndicator;
}

@end

@implementation TGPaymentReceiptController

- (instancetype)initWithMessage:(TGMessage *)message receiptMessageId:(int32_t)receiptMessageId {
    self = [super init];
    if (self != nil) {
        _bot = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
        
        bool isTest = false;
        for (id attachment in message.mediaAttachments) {
            if ([attachment isKindOfClass:[TGInvoiceMediaAttachment class]]) {
                TGInvoiceMediaAttachment *media = attachment;
                isTest = media.isTest;
                
                break;
            }
        }
        
        self.title = [TGLocalized(@"Checkout.Receipt.Title") stringByAppendingString: isTest ? @" (Test)" : @""];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        
        _message = message;
        _disposable = [[SMetaDisposable alloc] init];
        
        _headerSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
        _headerSection.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        [self.menuSections addSection:_headerSection];
        
        _priceSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
        _priceSection.insets = UIEdgeInsetsMake(8.0f, 0.0f, 8.0f, 0.0f);
        [self.menuSections addSection:_priceSection];
        
        _dataSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
        _dataSection.insets = UIEdgeInsetsMake(8.0f, 0.0f, 8.0f, 0.0f);
        [self.menuSections addSection:_dataSection];
        
        _footerSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
        _footerSection.insets = UIEdgeInsetsMake(0.0f, 0.0f, 16.0f, 0.0f);
        [self.menuSections addSection:_footerSection];
        
        [self reloadItems];
        
        __weak TGPaymentReceiptController *weakSelf = self;
        [_disposable setDisposable:[[[TGBotSignals paymentReceipt:receiptMessageId] deliverOn:[SQueue mainQueue]] startWithNext:^(TGPaymentReceipt *receipt) {
            __strong TGPaymentReceiptController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_receipt = receipt;
                
                if ([strongSelf isViewLoaded]) {
                    UIView *snapshot = [strongSelf.collectionView snapshotViewAfterScreenUpdates:false];
                    [strongSelf.view insertSubview:snapshot aboveSubview:strongSelf.collectionView];
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        snapshot.alpha = 0.0f;
                    } completion:^(__unused BOOL finished) {
                        [snapshot removeFromSuperview];
                    }];
                    strongSelf.collectionView.scrollEnabled = true;
                    
                    [strongSelf->_activityIndicator stopAnimating];
                    [strongSelf->_activityIndicator removeFromSuperview];
                    strongSelf->_activityIndicator = nil;
                }
                
                [strongSelf reloadItems];
            }
        }]];
    }
    return self;
}

- (void)dealloc {
    [_disposable dispose];
}

- (void)loadView {
    [super loadView];
    
    if (_receipt == nil) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
    }
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.scrollEnabled = _receipt != nil;
    
    _payButton = [[TGModernButton alloc] init];
    _payButton.adjustsImageWhenDisabled = false;
    _payButton.adjustsImageWhenHighlighted = false;
    _payButton.modernHighlight = true;
    [_payButton addTarget:self action:@selector(donePressed) forControlEvents:UIControlEventTouchUpInside];
    
    _payButton.frame = CGRectMake(15.0f, 14.0f, self.view.frame.size.width - 30.0f, 48.0f);
    _payButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 76.0f, self.view.frame.size.width, 76.0f)];
    _payButtonContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _payButtonContainer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75f];
    [self.view addSubview:_payButtonContainer];
    
    static UIImage *payButtonImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(48.0f, 48.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGB(0x027bff).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 48.0f, 48.0f));
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(1.0f, 1.0f, 46.0f, 46.0f));
        payButtonImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:24 topCapHeight:24];
        UIGraphicsEndImageContext();
    });
    _payButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_payButton setTitleColor:UIColorRGB(0x027bff)];
    _payButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    [_payButton setBackgroundImage:payButtonImage forState:UIControlStateNormal];
    [_payButton setTitle:TGLocalized(@"Common.Done") forState:UIControlStateNormal];
    [_payButtonContainer addSubview:_payButton];
    
    [self setExplicitTableInset:UIEdgeInsetsMake(0.0f, 0, 76.0f, 0)];
    [self setExplicitScrollIndicatorInset:UIEdgeInsetsMake(0.0f, 0, 76.0f, 0)];
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset {
    [super controllerInsetUpdated:previousInset];
    
    _activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0f, self.controllerInset.top + 163.0f + CGFloor((self.view.frame.size.height - 76.0f - (self.controllerInset.top + 163.0f)) / 2.0f));
}

- (void)layoutControllerForSize:(CGSize)size duration:(NSTimeInterval)duration {
    [super layoutControllerForSize:size duration:duration];
    
    _activityIndicator.center = CGPointMake(size.width / 2.0f, self.controllerInset.top + 163.0f + CGFloor((size.height - (self.controllerInset.top + 163.0f)) / 2.0f));
    
    _payButton.frame = CGRectMake(15.0f, 14.0f, size.width - 30.0f, 48.0f);
    _payButtonContainer.frame = CGRectMake(0.0f, size.height - 76.0f, size.width, 76.0f);
}

- (void)reloadItems {
    while (_headerSection.items.count > 0) {
        [_headerSection deleteItemAtIndex:0];
    }
    
    while (_priceSection.items.count > 0) {
        [_priceSection deleteItemAtIndex:0];
    }
    
    while (_dataSection.items.count > 0) {
        [_dataSection deleteItemAtIndex:0];
    }
    
    for (id attachment in _message.mediaAttachments) {
        if ([attachment isKindOfClass:[TGInvoiceMediaAttachment class]]) {
            TGInvoiceMediaAttachment *media = attachment;
            [_headerSection addItem:[[TGPaymentCheckoutHeaderItem alloc] initWithPhoto:[media webpage].photo title:media.title text:media.text label:_bot.displayName]];
            
            break;
        }
    }
    
    if (_receipt != nil) {
        int32_t totalPrice = 0;
        for (TGInvoicePrice *price in _receipt.invoice.prices) {
            NSString *string = [[TGCurrencyFormatter shared] formatAmount:price.amount currency:_receipt.invoice.currency];
            
            totalPrice += price.amount;
            
            [_priceSection addItem:[[TGPaymentCheckoutPriceItem alloc] initWithTitle:price.label value:string bold:false]];
        }
        if (_receipt.shippingOption != nil) {
            for (TGInvoicePrice *price in _receipt.shippingOption.prices) {
                NSString *string = [[TGCurrencyFormatter shared] formatAmount:price.amount currency:_receipt.invoice.currency];
                
                totalPrice += price.amount;
                
                [_priceSection addItem:[[TGPaymentCheckoutPriceItem alloc] initWithTitle:price.label value:string bold:false]];
            }
        }
        if (totalPrice != 0) {
            NSString *string = [[TGCurrencyFormatter shared] formatAmount:totalPrice currency:_receipt.invoice.currency];
            
            [_priceSection addItem:[[TGPaymentCheckoutPriceItem alloc] initWithTitle:TGLocalized(@"Checkout.TotalPaidAmount") value:string bold:true]];
        }
        
        [_dataSection addItem:[[TGSeparatorCollectionItem alloc] init]];
        
        [_dataSection addItem:[[TGPaymentCheckoutPriceItem alloc] initWithTitle:TGLocalized(@"Checkout.PaymentMethod") value:_receipt.credentialsTitle bold:false]];
        
        if (_receipt.info.shippingAddress != nil) {
            [_dataSection addItem:[[TGPaymentCheckoutPriceItem alloc] initWithTitle:TGLocalized(@"Checkout.ShippingAddress") value:[_receipt.info.shippingAddress descriptionWithSeparator:@", "] bold:false]];
            
            if (_receipt.shippingOption != nil) {
                [_dataSection addItem:[[TGPaymentCheckoutPriceItem alloc] initWithTitle:TGLocalized(@"Checkout.ShippingMethod") value:_receipt.shippingOption.title bold:false]];
            }
        }
        if (_receipt.info.name.length != 0) {
            [_dataSection addItem:[[TGPaymentCheckoutPriceItem alloc] initWithTitle:TGLocalized(@"Checkout.Name") value:_receipt.info.name bold:false]];
        }
        
        if (_receipt.info.email.length != 0) {
            [_dataSection addItem:[[TGPaymentCheckoutPriceItem alloc] initWithTitle:TGLocalized(@"Checkout.Email") value:_receipt.info.email bold:false]];
        }
        
        if (_receipt.info.phone.length != 0) {
            [_dataSection addItem:[[TGPaymentCheckoutPriceItem alloc] initWithTitle:TGLocalized(@"Checkout.Phone") value:_receipt.info.phone bold:false]];
        }
        
        [_footerSection addItem:[[TGSeparatorCollectionItem alloc] init]];
    }
    
    [self.collectionView reloadData];
}

- (void)donePressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)shippingMethodPressed {
}

- (void)paymentMethodPressed {
}

- (void)shippingAddressPressed {
}

- (void)namePressed {
}

- (void)emailPressed {
}

- (void)phonePressed {
}

@end
