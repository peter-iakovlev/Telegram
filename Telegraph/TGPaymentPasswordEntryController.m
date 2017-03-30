#import "TGPaymentPasswordEntryController.h"

#import "TGPaymentPasswordEntryControllerView.h"

@interface TGPaymentPasswordEntryController () {
    TGPaymentPasswordEntryControllerView *_controllerView;
    bool _hasAppeared;
    NSString *_cardTitle;
}

@end

@implementation TGPaymentPasswordEntryController

- (instancetype)initWithCardTitle:(NSString *)cardTitle {
    self = [super init];
    if (self != nil) {
        _cardTitle = cardTitle;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.opaque = false;
    self.view.backgroundColor = nil;
    
    __weak TGPaymentPasswordEntryController *weakSelf = self;
    
    _controllerView = [[TGPaymentPasswordEntryControllerView alloc] initWithCardTitle:_cardTitle];
    _controllerView.payWithPassword = ^(NSString *password) {
        __strong TGPaymentPasswordEntryController *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_payWithPassword) {
            return strongSelf->_payWithPassword(password);
        } else {
            return [SSignal fail:nil];
        }
    };
    _controllerView.frame = self.view.bounds;
    _controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_controllerView];
    
    _controllerView.dismiss = ^{
        __strong TGPaymentPasswordEntryController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf dismissAnimated];
        }
    };
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_hasAppeared) {
        _hasAppeared = true;
        [_controllerView animateIn];
    }
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    if ([self isViewLoaded]) {
        _controllerView.insets = self.controllerInset;
        [_controllerView setNeedsLayout];
        [_controllerView layoutSubviews];
    }
}

- (void)dismissAnimated {
    __weak TGPaymentPasswordEntryController *weakSelf = self;
    [_controllerView animateOut:^{
        __strong TGPaymentPasswordEntryController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf.presentingViewController dismissViewControllerAnimated:false completion:nil];
        }
    }];
}

@end
