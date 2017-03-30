//
//  STPPaymentMethodsViewController.m
//  Stripe
//
//  Created by Jack Flintermann on 1/12/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPPaymentMethodsViewController.h"
#import "STPAPIClient.h"
#import "STPToken.h"
#import "STPCard.h"
#import "UIViewController+Stripe_ParentViewController.h"
#import "STPAddCardViewController.h"
#import "STPPaymentContext.h"
#import "STPPaymentMethodTuple.h"
#import "STPPaymentActivityIndicatorView.h"
#import "STPPaymentMethodsViewController+Private.h"
#import "STPPaymentContext+Private.h"
#import "UIBarButtonItem+Stripe.h"
#import "UIViewController+Stripe_Promises.h"
#import "STPPaymentConfiguration+Private.h"
#import "STPPaymentMethodsInternalViewController.h"
#import "UIViewController+Stripe_NavigationItemProxy.h"
#import "STPTheme.h"
#import "STPColorUtils.h"
#import "STPWeakStrongMacros.h"
#import "STPLocalizationUtils.h"
#import "STPDispatchFunctions.h"

@interface STPPaymentMethodsViewController()<STPPaymentMethodsInternalViewControllerDelegate, STPAddCardViewControllerDelegate>

@property(nonatomic)STPPaymentConfiguration *configuration;
@property(nonatomic)STPTheme *theme;
@property(nonatomic)id<STPBackendAPIAdapter> apiAdapter;
@property(nonatomic)STPAPIClient *apiClient;
@property(nonatomic)STPPromise<STPPaymentMethodTuple *> *loadingPromise;
@property(nonatomic)NSArray<id<STPPaymentMethod>> *paymentMethods;
@property(nonatomic)id<STPPaymentMethod> selectedPaymentMethod;
@property(nonatomic, weak)STPPaymentActivityIndicatorView *activityIndicator;
@property(nonatomic, weak)UIViewController *internalViewController;
@property(nonatomic)UIBarButtonItem *backItem;
@property(nonatomic)UIBarButtonItem *cancelItem;
@property(nonatomic)BOOL loading;

@end

@implementation STPPaymentMethodsViewController

- (instancetype)initWithPaymentContext:(STPPaymentContext *)paymentContext {
    return [self initWithConfiguration:paymentContext.configuration
                            apiAdapter:paymentContext.apiAdapter
                        loadingPromise:paymentContext.currentValuePromise
                                 theme:paymentContext.theme
                              delegate:paymentContext];
}

- (instancetype)initWithConfiguration:(STPPaymentConfiguration *)configuration
                                theme:(STPTheme *)theme
                           apiAdapter:(id<STPBackendAPIAdapter>)apiAdapter
                             delegate:(id<STPPaymentMethodsViewControllerDelegate>)delegate {
    STPPromise<STPPaymentMethodTuple *> *promise = [STPPromise new];
    [apiAdapter retrieveCustomer:^(STPCustomer * _Nullable customer, NSError * _Nullable error) {
        stpDispatchToMainThreadIfNecessary(^{
            if (error) {
                [promise fail:error];
            } else {
                STPCard *selectedCard;
                NSMutableArray<STPCard *> *cards = [NSMutableArray array];
                for (id<STPSource> source in customer.sources) {
                    if ([source isKindOfClass:[STPCard class]]) {
                        STPCard *card = (STPCard *)source;
                        [cards addObject:card];
                        if ([card.stripeID isEqualToString:customer.defaultSource.stripeID]) {
                            selectedCard = card;
                        }
                    }
                }
                STPCardTuple *cardTuple = [STPCardTuple tupleWithSelectedCard:selectedCard cards:cards];
                STPPaymentMethodTuple *tuple = [STPPaymentMethodTuple tupleWithCardTuple:cardTuple
                                                                         applePayEnabled:configuration.applePayEnabled];
                [promise succeed:tuple];
            }
        });
    }];
    return [self initWithConfiguration:configuration
                            apiAdapter:apiAdapter
                        loadingPromise:promise
                                 theme:theme
                              delegate:delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    STPPaymentActivityIndicatorView *activityIndicator = [STPPaymentActivityIndicatorView new];
    activityIndicator.animating = YES;
    [self.view addSubview:activityIndicator];
    self.activityIndicator = activityIndicator;
    
    self.navigationItem.title = STPLocalizedString(@"Loading…", @"Title for screen when data is still loading from the network.");
    
    self.backItem = [UIBarButtonItem stp_backButtonItemWithTitle:STPLocalizedString(@"Back", @"Text for back button") 
                                                           style:UIBarButtonItemStylePlain 
                                                          target:self
                                                          action:@selector(cancel:)];
    self.cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:STPLocalizedString(@"Back", @"Text for back button") 
                                                                             style:UIBarButtonItemStylePlain 
                                                                            target:nil 
                                                                            action:nil];
    WEAK(self);
    [self.loadingPromise onSuccess:^(STPPaymentMethodTuple *tuple) {
        STRONG(self);
        UIViewController *internal;
        if (tuple.paymentMethods.count > 0) {
            internal = [[STPPaymentMethodsInternalViewController alloc] initWithConfiguration:self.configuration
                                                                                        theme:self.theme prefilledInformation:self.prefilledInformation
                                                                           paymentMethodTuple:tuple
                                                                                     delegate:self];
        } else {
            STPAddCardViewController *addCardViewController = [[STPAddCardViewController alloc] initWithConfiguration:self.configuration theme:self.theme];
            addCardViewController.delegate = self;
            addCardViewController.prefilledInformation = self.prefilledInformation;
            internal = addCardViewController;
            
        }
        internal.stp_navigationItemProxy = self.navigationItem;
        [self addChildViewController:internal];
        internal.view.alpha = 0;
        [self.view insertSubview:internal.view belowSubview:self.activityIndicator];
        [self.view addSubview:internal.view];
        internal.view.frame = self.view.bounds;
        [internal didMoveToParentViewController:self];
        [UIView animateWithDuration:0.2 animations:^{
            self.activityIndicator.alpha = 0;
            internal.view.alpha = 1;
        } completion:^(__unused BOOL finished) {
            self.activityIndicator.animating = NO;
        }];
        [self.navigationItem setRightBarButtonItem:internal.stp_navigationItemProxy.rightBarButtonItem animated:YES];
    }];
    self.loading = YES;
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [self stp_isAtRootOfNavigationController] ? self.cancelItem : self.backItem;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat centerX = (self.view.frame.size.width - self.activityIndicator.frame.size.width) / 2;
    CGFloat centerY = (self.view.frame.size.height - self.activityIndicator.frame.size.height) / 2;
    self.activityIndicator.frame = CGRectMake(centerX, centerY, self.activityIndicator.frame.size.width, self.activityIndicator.frame.size.height);
    self.internalViewController.view.frame = self.view.bounds;
}

- (void)updateAppearance {
    [self.navigationItem.backBarButtonItem stp_setTheme:self.theme];
    [self.backItem stp_setTheme:self.theme];
    [self.cancelItem stp_setTheme:self.theme];
    self.activityIndicator.tintColor = self.theme.accentColor;
    self.view.backgroundColor = self.theme.primaryBackgroundColor;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return ([STPColorUtils colorIsBright:self.theme.primaryBackgroundColor] 
            ? UIStatusBarStyleDefault
            : UIStatusBarStyleLightContent);
}

- (void)cancel:(__unused id)sender {
    [self.delegate paymentMethodsViewControllerDidFinish:self];
}

- (void)finishWithPaymentMethod:(id<STPPaymentMethod>)paymentMethod {
    if ([paymentMethod isKindOfClass:[STPCard class]]) {
        [self.apiAdapter selectDefaultCustomerSource:(STPCard *)paymentMethod completion:^(__unused NSError *error) {
        }];
    }
    [self.delegate paymentMethodsViewController:self didSelectPaymentMethod:paymentMethod];
    [self.delegate paymentMethodsViewControllerDidFinish:self];
}

- (void)internalViewControllerDidSelectPaymentMethod:(id<STPPaymentMethod>)paymentMethod {
    [self finishWithPaymentMethod:paymentMethod];
}

- (void)internalViewControllerDidCreateToken:(STPToken *)token completion:(STPErrorBlock)completion {
    [self.apiAdapter attachSourceToCustomer:token completion:^(NSError * _Nullable error) {
        stpDispatchToMainThreadIfNecessary(^{
            completion(error);
            if (!error) {
                [self finishWithPaymentMethod:token.card];
            }
        });
    }];
}

- (void)addCardViewControllerDidCancel:(__unused STPAddCardViewController *)addCardViewController {
    [self.delegate paymentMethodsViewControllerDidFinish:self];
}

- (void)addCardViewController:(__unused STPAddCardViewController *)addCardViewController
               didCreateToken:(STPToken *)token
                   completion:(STPErrorBlock)completion {
    [self internalViewControllerDidCreateToken:token completion:completion];
}

@end

@implementation STPPaymentMethodsViewController (Private)

- (instancetype)initWithConfiguration:(STPPaymentConfiguration *)configuration
                           apiAdapter:(id<STPBackendAPIAdapter>)apiAdapter
                       loadingPromise:(STPPromise<STPPaymentMethodTuple *> *)loadingPromise
                                theme:(STPTheme *)theme
                             delegate:(id<STPPaymentMethodsViewControllerDelegate>)delegate {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _configuration = configuration;
        _theme = theme;
        _apiClient = [[STPAPIClient alloc] initWithPublishableKey:configuration.publishableKey];
        _apiAdapter = apiAdapter;
        _loadingPromise = loadingPromise;
        _delegate = delegate;
        WEAK(self);
        [loadingPromise onSuccess:^(STPPaymentMethodTuple *tuple) {
            STRONG(self);
            self.paymentMethods = tuple.paymentMethods;
            self.selectedPaymentMethod = tuple.selectedPaymentMethod;
        }];
        [[[self.stp_didAppearPromise voidFlatMap:^STPPromise * _Nonnull{
            return loadingPromise;
        }] onSuccess:^(STPPaymentMethodTuple *tuple) {
            STRONG(self);
            if (tuple.selectedPaymentMethod) {
                [self.delegate paymentMethodsViewController:self
                                         didSelectPaymentMethod:tuple.selectedPaymentMethod];
            }
        }] onFailure:^(NSError *error) {
            STRONG(self);
            [self.delegate paymentMethodsViewController:self didFailToLoadWithError:error];
        }];
    }
    return self;
}

@end
