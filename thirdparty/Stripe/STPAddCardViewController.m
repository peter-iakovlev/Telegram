//
//  STPAddCardViewController.m
//  Stripe
//
//  Created by Jack Flintermann on 3/23/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPAddCardViewController.h"
#import "STPPaymentCardTextField.h"
#import "STPToken.h"
#import "STPImageLibrary.h"
#import "STPImageLibrary+Private.h"
#import "STPAddressFieldTableViewCell.h"
#import "STPAddressViewModel.h"
#import "NSArray+Stripe_BoundSafe.h"
#import "UIViewController+Stripe_KeyboardAvoiding.h"
#import "UIViewController+Stripe_ParentViewController.h"
#import "UIToolbar+Stripe_InputAccessory.h"
#import "STPCheckoutAPIClient.h"
#import "STPEmailAddressValidator.h"
#import "STPSwitchTableViewCell.h"
#import "STPPhoneNumberValidator.h"
#import "STPSMSCodeViewController.h"
#import "STPObscuredCardView.h"
#import "STPPaymentActivityIndicatorView.h"
#import "UITableViewCell+Stripe_Borders.h"
#import "STPRememberMeEmailCell.h"
#import "STPRememberMeTermsView.h"
#import "UIBarButtonItem+Stripe.h"
#import "UINavigationBar+Stripe_Theme.h"
#import "StripeError.h"
#import "UIViewController+Stripe_Promises.h"
#import "UIView+Stripe_FirstResponder.h"
#import "UIViewController+Stripe_NavigationItemProxy.h"
#import "STPRememberMePaymentCell.h"
#import "STPAnalyticsClient.h"
#import "STPColorUtils.h"
#import "STPWeakStrongMacros.h"
#import "STPLocalizationUtils.h"
#import "STPDispatchFunctions.h"

@interface STPAddCardViewController ()<STPPaymentCardTextFieldDelegate, STPAddressViewModelDelegate, STPAddressFieldTableViewCellDelegate, STPSwitchTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource, STPSMSCodeViewControllerDelegate, STPRememberMePaymentCellDelegate>
@property(nonatomic)STPPaymentConfiguration *configuration;
@property(nonatomic)STPTheme *theme;
@property(nonatomic)STPAPIClient *apiClient;
@property(nonatomic, weak)UITableView *tableView;
@property(nonatomic, weak)UIImageView *cardImageView;
@property(nonatomic)UIBarButtonItem *doneItem;
@property(nonatomic)UIBarButtonItem *backItem;
@property(nonatomic)UIBarButtonItem *cancelItem;
@property(nonatomic)STPRememberMeEmailCell *emailCell;
@property(nonatomic)STPSwitchTableViewCell *rememberMeCell;
@property(nonatomic)STPAddressFieldTableViewCell *rememberMePhoneCell;
@property(nonatomic)STPRememberMePaymentCell *paymentCell;
@property(nonatomic)BOOL loading;
@property(nonatomic)STPPaymentActivityIndicatorView *activityIndicator;
@property(nonatomic, weak)STPPaymentActivityIndicatorView *lookupActivityIndicator;
@property(nonatomic)STPAddressViewModel *addressViewModel;
@property(nonatomic)UIToolbar *inputAccessoryToolbar;
@property(nonatomic)STPCheckoutAPIClient *checkoutAPIClient;
@property(nonatomic)STPCheckoutAccount *checkoutAccount;
@property(nonatomic)STPCheckoutAccountLookup *checkoutLookup;
@property(nonatomic)STPCard *checkoutAccountCard;
@property(nonatomic)BOOL lookupSucceeded;
@property(nonatomic)STPRememberMeTermsView *rememberMeTermsView;
@property(nonatomic)BOOL showingRememberMePhoneAndTerms;
#ifdef STRIPE_UNIT_TESTS_ENABLED
@property(nonatomic)BOOL forceEnableRememberMeForTesting;
#endif
@end

static NSString *const STPPaymentCardCellReuseIdentifier = @"STPPaymentCardCellReuseIdentifier";
static NSInteger STPPaymentCardEmailSection = 0;
static NSInteger STPPaymentCardNumberSection = 1;
static NSInteger STPPaymentCardBillingAddressSection = 2;
static NSInteger STPPaymentCardRememberMeSection = 3;

@implementation STPAddCardViewController

- (instancetype)init {
    return [self initWithConfiguration:[STPPaymentConfiguration sharedConfiguration] theme:[STPTheme defaultTheme]];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInitWithConfiguration:[STPPaymentConfiguration sharedConfiguration] theme:[STPTheme defaultTheme]];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitWithConfiguration:[STPPaymentConfiguration sharedConfiguration] theme:[STPTheme defaultTheme]];
    }
    return self;
}

- (instancetype)initWithConfiguration:(STPPaymentConfiguration *)configuration theme:(STPTheme *)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self commonInitWithConfiguration:configuration theme:theme];
    }
    return self;
}

- (void)commonInitWithConfiguration:(STPPaymentConfiguration *)configuration theme:(STPTheme *)theme {
    _configuration = configuration;
    _theme = theme;
    _apiClient = [[STPAPIClient alloc] initWithConfiguration:configuration];
    _addressViewModel = [[STPAddressViewModel alloc] initWithRequiredBillingFields:configuration.requiredBillingAddressFields];
    _addressViewModel.delegate = self;
    _checkoutAPIClient = [[STPCheckoutAPIClient alloc] initWithPublishableKey:configuration.publishableKey];
    self.title = STPLocalizedString(@"Add a Card", @"Title for Add a Card view");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.sectionHeaderHeight = 30;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    self.backItem = [UIBarButtonItem stp_backButtonItemWithTitle:STPLocalizedString(@"Back", @"Text for back button") style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(nextPressed:)];
    self.doneItem = doneItem;
    self.stp_navigationItemProxy.rightBarButtonItem = doneItem;
    
    self.stp_navigationItemProxy.rightBarButtonItem.enabled = NO;
    
    UIImageView *cardImageView = [[UIImageView alloc] initWithImage:[STPImageLibrary largeCardFrontImage]];
    cardImageView.contentMode = UIViewContentModeCenter;
    cardImageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, cardImageView.bounds.size.height + (57 * 2));
    self.cardImageView = cardImageView;
    self.tableView.tableHeaderView = cardImageView;
    self.emailCell = [[STPRememberMeEmailCell alloc] initWithDelegate:self];
    if ([STPEmailAddressValidator stringIsValidEmailAddress:self.prefilledInformation.email]) {
        self.emailCell.contents = self.prefilledInformation.email;
    }
    
    STPRememberMePaymentCell *paymentCell = [[STPRememberMePaymentCell alloc] init];
    paymentCell.paymentField.delegate = self;
    self.paymentCell = paymentCell;
    
    self.addressViewModel.previousField = paymentCell;
    
    self.rememberMeCell = [[STPSwitchTableViewCell alloc] init];
    [self.rememberMeCell configureWithLabel:STPLocalizedString(@"Save for use in other apps", @"Label for the switch to enable Remember Me") delegate:self];
    [self reloadRememberMeCellAnimated:NO];
    
    self.rememberMePhoneCell = [[STPAddressFieldTableViewCell alloc] initWithType:STPAddressFieldTypePhone contents:nil lastInList:YES delegate:self];
    self.rememberMePhoneCell.caption = STPLocalizedString(@"Phone", nil);
    self.rememberMePhoneCell.contents = self.prefilledInformation.phone;
    
    self.rememberMeTermsView = [STPRememberMeTermsView new];
    self.rememberMeTermsView.textView.alpha = 0;
    WEAK(self);
    self.rememberMeTermsView.pushViewControllerBlock = ^(UIViewController *vc) {
        STRONG(self);
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    self.activityIndicator = [[STPPaymentActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
    
    self.inputAccessoryToolbar = [UIToolbar stp_inputAccessoryToolbarWithTarget:self action:@selector(paymentFieldNextTapped)];
    [self.inputAccessoryToolbar stp_setEnabled:NO];
    if (self.configuration.requiredBillingAddressFields != STPBillingAddressFieldsNone) {
        paymentCell.inputAccessoryView = self.inputAccessoryToolbar;
    }
    tableView.dataSource = self;
    tableView.delegate = self;
    [self updateAppearance];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)]];

    [self.checkoutAPIClient.bootstrapPromise onCompletion:^(__unused id value, __unused NSError *error) {
        STRONG(self);
        [self reloadRememberMeCellAnimated:YES];
    }];
}

- (void)endEditing {
    [self.view endEditing:NO];
}

- (void)updateAppearance {
    self.view.backgroundColor = self.theme.primaryBackgroundColor;
    [self.doneItem stp_setTheme:self.theme];
    [self.backItem stp_setTheme:self.theme];
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // handle this with fake separator views for flexibility
    self.tableView.backgroundColor = self.theme.primaryBackgroundColor;
    if ([STPColorUtils colorIsBright:self.theme.primaryBackgroundColor]) {
        self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    } else {
        self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    }
    
    self.cardImageView.tintColor = self.theme.accentColor;
    self.activityIndicator.tintColor = self.theme.accentColor;
    self.emailCell.theme = self.theme;
    
    self.paymentCell.theme = self.theme;
    
    for (STPAddressFieldTableViewCell *cell in self.addressViewModel.addressCells) {
        cell.theme = self.theme;
    }
    self.rememberMeCell.theme = self.theme;
    self.rememberMePhoneCell.theme = self.theme;
    self.rememberMeTermsView.theme = self.theme;
    [self reloadRememberMeSectionForFooterSizeChangeIfNecessary];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return ([STPColorUtils colorIsBright:self.theme.primaryBackgroundColor] 
            ? UIStatusBarStyleDefault
            : UIStatusBarStyleLightContent);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    [self reloadRememberMeSectionForFooterSizeChangeIfNecessary];
}

- (void)reloadRememberMeSectionForFooterSizeChangeIfNecessary {
    
    if (self.showingRememberMePhoneAndTerms
        && self.rememberMeTermsView.superview != nil) {
        
        // This should force the table to recalc all of its heights
        // And therefore render the footer appropriately if its height changed
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
    }
}

- (void)setLoading:(BOOL)loading {
    if (loading == _loading) {
        return;
    }
    _loading = loading;
    [self.stp_navigationItemProxy setHidesBackButton:loading animated:YES];
    self.stp_navigationItemProxy.leftBarButtonItem.enabled = !loading;
    self.activityIndicator.animating = loading;
    if (loading) {
        [self.tableView endEditing:YES];
        UIBarButtonItem *loadingItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
        [self.stp_navigationItemProxy setRightBarButtonItem:loadingItem animated:YES];
    } else {
        [self.stp_navigationItemProxy setRightBarButtonItem:self.doneItem animated:YES];
    }
    NSArray *cells = self.addressViewModel.addressCells;
    for (UITableViewCell *cell in [cells arrayByAddingObjectsFromArray:@[self.emailCell, self.paymentCell, self.rememberMeCell, self.rememberMePhoneCell]] ) {
        cell.userInteractionEnabled = !loading;
        [UIView animateWithDuration:0.1f animations:^{
            cell.alpha = loading ? 0.7f : 1.0f;
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadRememberMeCellAnimated:NO];
    self.stp_navigationItemProxy.leftBarButtonItem = [self stp_isAtRootOfNavigationController] ? self.cancelItem : self.backItem;
    [self.tableView reloadData];
    if (self.navigationController.navigationBar.translucent) {
        CGFloat insetTop = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        self.tableView.contentInset = UIEdgeInsetsMake(insetTop, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    } else {
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    CGPoint offset = self.tableView.contentOffset;
    offset.y = -self.tableView.contentInset.top;
    self.tableView.contentOffset = offset;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self stp_beginObservingKeyboardAndInsettingScrollView:self.tableView
                                             onChangeBlock:nil];
    [[self firstEmptyField] becomeFirstResponder];
}

- (UIResponder *)firstEmptyField {
    if (!self.emailCell.contents && !self.configuration.smsAutofillDisabled) {
        return self.emailCell;
    }
    if (self.paymentCell.isEmpty) {
        return self.paymentCell;
    }
    for (STPAddressFieldTableViewCell *cell in self.addressViewModel.addressCells) {
        if (cell.contents.length == 0) {
            return cell;
        }
    }
    return nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)cancel:(__unused id)sender {
    [self.delegate addCardViewControllerDidCancel:self];
}

- (void)nextPressed:(__unused id)sender {
    self.loading = YES;
    STPCardParams *cardParams = self.paymentCell.paymentField.cardParams;
    cardParams.address = self.addressViewModel.address;
    cardParams.currency = self.managedAccountCurrency;
    if (self.checkoutAccountCard) {
        WEAK(self);
        [[[self.checkoutAPIClient createTokenWithAccount:self.checkoutAccount] onSuccess:^(STPToken *token) {
            STRONG(self);
            [self.delegate addCardViewController:self didCreateToken:token completion:^(NSError * _Nullable error) {
                stpDispatchToMainThreadIfNecessary(^{
                    if (error) {
                        [self handleCheckoutTokenError:error];
                    }
                    else {
                        self.loading = NO;
                    }
                });
            }];
        }] onFailure:^(NSError *error) {
            STRONG(self);
            [self handleCardTokenError:error];
        }];
    } else if (cardParams) {
        [self.apiClient createTokenWithCard:cardParams completion:^(STPToken *token, NSError *tokenError) {
            if (tokenError) {
                [self handleCardTokenError:tokenError];
            } else {
                NSString *phone = self.rememberMePhoneCell.contents;
                NSString *email = self.emailCell.contents;
                BOOL rememberMeSelected = [STPEmailAddressValidator stringIsValidEmailAddress:email] && [STPPhoneNumberValidator stringIsValidPhoneNumber:phone] && self.showingRememberMePhoneAndTerms;
                [[STPAnalyticsClient sharedClient] logRememberMeConversion:rememberMeSelected];
                if (rememberMeSelected) {
                    [self.checkoutAPIClient createAccountWithCardParams:cardParams email:email phone:phone];
                }
                [self.delegate addCardViewController:self didCreateToken:token completion:^(NSError * _Nullable error) {
                    stpDispatchToMainThreadIfNecessary(^{
                        if (error) {
                            [self handleCardTokenError:error];
                        }
                        else {
                            self.loading = NO;
                        }
                    });
                }];
            }
        }];
    }
}

- (void)handleCheckoutTokenError:(__unused NSError *)error {
    self.loading = NO;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:STPLocalizedString(@"There was an error submitting your autofilled card details.", nil)
                                                                             message:nil 
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:STPLocalizedString(@"Enter card details manually", nil) 
                                                        style:UIAlertActionStyleDefault 
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          [self.paymentCell clear];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleCardTokenError:(NSError *)error {
    self.loading = NO;
    [[self firstEmptyField] becomeFirstResponder];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:error.localizedDescription
                                                                             message:error.localizedFailureReason 
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:STPLocalizedString(@"OK", nil) 
                                                        style:UIAlertActionStyleCancel 
                                                      handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setCheckoutAccountCard:(STPCard *)checkoutAccountCard {
    _checkoutAccountCard = checkoutAccountCard;
    [self updateDoneButton];
}

- (void)updateDoneButton {
    self.stp_navigationItemProxy.rightBarButtonItem.enabled = (self.paymentCell.paymentField.isValid || self.checkoutAccountCard) &&
    self.addressViewModel.isValid &&
    (self.configuration.smsAutofillDisabled || [STPEmailAddressValidator stringIsValidEmailAddress:self.emailCell.contents]);
}

- (void)smsCodeViewControllerDidCancel:(__unused STPSMSCodeViewController *)smsCodeViewController {
    [self reloadRememberMeCellAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)smsCodeViewController:(__unused STPSMSCodeViewController *)smsCodeViewController didAuthenticateAccount:(STPCheckoutAccount *)account {
    self.checkoutAccount = account;
    self.checkoutAccountCard = account.card;
    [self reloadRememberMeCellAnimated:NO];
    [self.paymentCell configureWithCard:account.card];
    self.addressViewModel.address = account.card.address;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentCellDidClear:(__unused STPRememberMePaymentCell *)cell {
    self.checkoutAccountCard = nil;
}

#pragma mark - STPPaymentCardTextField

- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
    [self.inputAccessoryToolbar stp_setEnabled:textField.isValid];
    [self updateDoneButton];
}

- (void)paymentFieldNextTapped {
    [[self.addressViewModel.addressCells stp_boundSafeObjectAtIndex:0] becomeFirstResponder];
}

- (void)paymentCardTextFieldDidBeginEditingCVC:(__unused STPPaymentCardTextField *)textField {
    [UIView transitionWithView:self.cardImageView
                      duration:0.25
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        self.cardImageView.image = [STPImageLibrary largeCardBackImage];
                    } completion:nil];
}

- (void)paymentCardTextFieldDidEndEditingCVC:(__unused STPPaymentCardTextField *)textField {
    [UIView transitionWithView:self.cardImageView
                      duration:0.25
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.cardImageView.image = [STPImageLibrary largeCardFrontImage];
                    } completion:nil];
}

#pragma mark - STPAddressViewModelDelegate

- (void)addressViewModel:(__unused STPAddressViewModel *)addressViewModel addedCellAtIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:STPPaymentCardBillingAddressSection];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addressViewModel:(__unused STPAddressViewModel *)addressViewModel removedCellAtIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:STPPaymentCardBillingAddressSection];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addressViewModelDidChange:(__unused STPAddressViewModel *)addressViewModel {
    [self updateDoneButton];
}

- (void)addressFieldTableViewCellDidReturn:(STPAddressFieldTableViewCell *)cell {
    if (cell == self.emailCell) {
        [self.paymentCell becomeFirstResponder];
    }
}

- (void)addressFieldTableViewCellDidUpdateText:(STPAddressFieldTableViewCell *)cell {
    if (cell == self.emailCell) {
        [self lookupAndSendSMS:cell.contents];
        [self updateDoneButton];
    }
}

- (void)lookupAndSendSMS:(NSString *)email {
    if (self.checkoutAccount || self.configuration.smsAutofillDisabled || self.lookupSucceeded) {
        return;
    }
    WEAK(self);
    if ([STPEmailAddressValidator stringIsValidEmailAddress:email]) {
        [self.emailCell.activityIndicator setAnimating:YES animated:YES];
        [[[[self.stp_didAppearPromise voidFlatMap:^STPPromise * _Nonnull{
            STRONG(self);
            return [self.checkoutAPIClient lookupEmail:email];
        }] flatMap:^STPPromise * _Nonnull(STPCheckoutAccountLookup *lookup) {
            STRONG(self);
            self.lookupSucceeded = YES;
            self.checkoutLookup = lookup;
            return [self.checkoutAPIClient sendSMSToAccountWithEmail:lookup.email];
        }] onSuccess:^(STPCheckoutAPIVerification *verification) {
            STRONG(self);
            STPSMSCodeViewController *codeViewController = [[STPSMSCodeViewController alloc] initWithCheckoutAPIClient:self.checkoutAPIClient 
                                                                                                          verification:verification 
                                                                                                         redactedPhone:self.checkoutLookup.redactedPhone];
            codeViewController.theme = self.theme;
            codeViewController.delegate = self;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:codeViewController];
            [nav.navigationBar stp_setTheme:self.theme];
            nav.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:nav animated:YES completion:nil];
        }] onCompletion:^(__unused id value, NSError *error) {
            STRONG(self);
            if (![error stp_isURLSessionCancellationError]) {
                [self.emailCell.activityIndicator setAnimating:NO animated:YES];
            }
        }];
    }
}

- (void)addressFieldTableViewCellDidBackspaceOnEmpty:(__unused STPAddressFieldTableViewCell *)cell {
    // this is the email cell; do nothing.
}

- (void)switchTableViewCell:(__unused STPSwitchTableViewCell *)cell didToggleSwitch:(BOOL)on {
    self.showingRememberMePhoneAndTerms = on;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1
                                                inSection:STPPaymentCardRememberMeSection];
    [self.tableView beginUpdates];
    if (on) {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.tableView endUpdates];

    [UIView animateWithDuration:0.1 animations:^{
        self.rememberMeTermsView.textView.alpha = on ? 1.0f : 0.0f;
    }];
    
    // This updates the section borders so they're not drawn in both cells.
    NSIndexPath *switchIndexPath = [self.tableView indexPathForCell:cell];
    [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:switchIndexPath];
    
    if (on) {
        [self.rememberMePhoneCell becomeFirstResponder];
    }
}

#pragma mark - UITableView

#ifdef STRIPE_UNIT_TESTS_ENABLED

/**
 This method/property is used by unit tests to force the view into having remember me
 being enabled for snapshot testing purposes.
 
 It also bypasses the checks for seeing if the remember me switch
 can be show below in `reloadRememberMeCellAnimated`
 */
- (void)setForceEnableRememberMeForTesting:(BOOL)forceEnableRememberMeForTesting {
    // force view load
    __unused UIView *view = self.view;
    
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    _forceEnableRememberMeForTesting = forceEnableRememberMeForTesting;
    [self reloadRememberMeCellAnimated:NO];
    self.rememberMeCell.on = forceEnableRememberMeForTesting;
    [self switchTableViewCell:self.rememberMeCell didToggleSwitch:forceEnableRememberMeForTesting];
}
#endif

- (void)reloadRememberMeCellAnimated:(BOOL)animated {
    BOOL disabled = (!self.checkoutAPIClient.readyForLookups || self.checkoutAccount || self.configuration.smsAutofillDisabled || self.lookupSucceeded || self.managedAccountCurrency) && (self.rememberMePhoneCell.contentView.alpha < FLT_EPSILON || self.rememberMePhoneCell.superview == nil);
#ifdef STRIPE_UNIT_TESTS_ENABLED
    if (self.forceEnableRememberMeForTesting) {
        disabled = NO;
    }
#endif
    [UIView animateWithDuration:(0.2f * animated) animations:^{
        self.rememberMeCell.contentView.alpha = disabled ? 0 : 1;
    } completion:^(__unused BOOL finished) {
        [self tableView:self.tableView willDisplayCell:self.rememberMeCell forRowAtIndexPath:[self.tableView indexPathForCell:self.rememberMeCell]];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(__unused UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == STPPaymentCardEmailSection) {
        if (self.configuration.smsAutofillDisabled) {
            return 0;
        }
        return 1;
    }
    else if (section == STPPaymentCardNumberSection) {
        return 1;
    } else if (section == STPPaymentCardBillingAddressSection) {
        return self.addressViewModel.addressCells.count;
    } else if (section == STPPaymentCardRememberMeSection) {
        return self.showingRememberMePhoneAndTerms ? 2 : 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(__unused UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == STPPaymentCardEmailSection) {
        return self.emailCell;
    }
    else if (indexPath.section == STPPaymentCardNumberSection) {
        cell = self.paymentCell;
    } else if (indexPath.section == STPPaymentCardBillingAddressSection) {
        cell = [self.addressViewModel.addressCells stp_boundSafeObjectAtIndex:indexPath.row];
    } else if (indexPath.section == STPPaymentCardRememberMeSection) {
        if (indexPath.row == 0) {
            cell = self.rememberMeCell;
        } else {
            cell = self.rememberMePhoneCell;
        }
        
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = self.theme.secondaryBackgroundColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL topRow = (indexPath.row == 0);
    BOOL bottomRow = ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 1 == indexPath.row);
    [cell stp_setBorderColor:self.theme.tertiaryBackgroundColor];
    [cell stp_setTopBorderHidden:!topRow];
    [cell stp_setBottomBorderHidden:!bottomRow];
    [cell stp_setFakeSeparatorColor:self.theme.quaternaryBackgroundColor];
    [cell stp_setFakeSeparatorLeftInset:15.0f];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == STPPaymentCardRememberMeSection 
        && self.showingRememberMePhoneAndTerms) {
        return [self.rememberMeTermsView heightForWidth:CGRectGetWidth(self.tableView.frame)];
    } else if ([self tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0.01f;
    }
    return 27.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == STPPaymentCardEmailSection) {
        return 0.01f;
    }
    if (section == STPPaymentCardRememberMeSection || [self tableView:tableView numberOfRowsInSection:section] != 0) {
        return tableView.sectionHeaderHeight;
    }
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == STPPaymentCardEmailSection || section == STPPaymentCardRememberMeSection) {
        return [UIView new];
    } else if ([self tableView:tableView numberOfRowsInSection:section] == 0) {
        return [UIView new];
    } else {
        UILabel *label = [UILabel new];
        label.font = self.theme.smallFont;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.firstLineHeadIndent = 15;
        NSDictionary *attributes = @{NSParagraphStyleAttributeName: style};
        label.textColor = self.theme.secondaryForegroundColor;
        if (section == STPPaymentCardNumberSection) {
            label.attributedText = [[NSAttributedString alloc] initWithString:STPLocalizedString(@"Card", @"Title for credit card number entry field") 
                                                                   attributes:attributes];
            return label;
        } else if (section == STPPaymentCardBillingAddressSection) {
            label.attributedText = [[NSAttributedString alloc] initWithString:STPLocalizedString(@"Billing Address", @"Title for billing address entry section")
                                                                   attributes:attributes];
            return label;
        }
    }
    return nil;
}

- (UIView *)tableView:(__unused UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == STPPaymentCardRememberMeSection) {
        return self.rememberMeTermsView;
    }
    else {
        return [UIView new];
    }
}

@end
