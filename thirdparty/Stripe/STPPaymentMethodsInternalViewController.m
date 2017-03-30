//
//  STPPaymentMethodsInternalViewController.m
//  Stripe
//
//  Created by Jack Flintermann on 6/9/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPPaymentMethodsInternalViewController.h"
#import "STPImageLibrary.h"
#import "STPImageLibrary+Private.h"
#import "NSArray+Stripe_BoundSafe.h"
#import "NSString+Stripe_CardBrands.h"
#import "UITableViewCell+Stripe_Borders.h"
#import "UINavigationController+Stripe_Completion.h"
#import "STPColorUtils.h"
#import "STPLocalizationUtils.h"
#import "STPPaymentMethodTableViewCell.h"

static NSString *const STPPaymentMethodCellReuseIdentifier = @"STPPaymentMethodCellReuseIdentifier";
static NSInteger STPPaymentMethodCardListSection = 0;
static NSInteger STPPaymentMethodAddCardSection = 1;

@interface STPPaymentMethodsInternalViewController()<UITableViewDataSource, UITableViewDelegate, STPAddCardViewControllerDelegate>

@property(nonatomic)STPPaymentConfiguration *configuration;
@property(nonatomic)STPTheme *theme;
@property(nonatomic)STPUserInformation *prefilledInformation;
@property(nonatomic)NSArray<id<STPPaymentMethod>> *paymentMethods;
@property(nonatomic)id<STPPaymentMethod> selectedPaymentMethod;
@property(nonatomic, weak)id<STPPaymentMethodsInternalViewControllerDelegate> delegate;
@property(nonatomic, weak)UITableView *tableView;
@property(nonatomic, weak)UIImageView *cardImageView;

@end

@implementation STPPaymentMethodsInternalViewController

- (instancetype)initWithConfiguration:(STPPaymentConfiguration *)configuration
                                theme:(STPTheme *)theme
                 prefilledInformation:(STPUserInformation *)prefilledInformation
                   paymentMethodTuple:(STPPaymentMethodTuple *)tuple
                             delegate:(id<STPPaymentMethodsInternalViewControllerDelegate>)delegate {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _configuration = configuration;
        _theme = theme;
        _prefilledInformation = prefilledInformation;
        _paymentMethods = tuple.paymentMethods;
        _selectedPaymentMethod = tuple.selectedPaymentMethod;
        _delegate = delegate;
    }
    self.title = STPLocalizedString(@"Payment Method", @"Title for Payment Method screen");
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.allowsMultipleSelectionDuringEditing = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[STPPaymentMethodTableViewCell class] forCellReuseIdentifier:STPPaymentMethodCellReuseIdentifier];
    tableView.sectionHeaderHeight = 30;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // use fake separator views
    tableView.separatorInset = UIEdgeInsetsMake(0, 18, 0, 0);
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    UIImageView *cardImageView = [[UIImageView alloc] initWithImage:[STPImageLibrary largeCardFrontImage]];
    cardImageView.contentMode = UIViewContentModeCenter;
    cardImageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, cardImageView.bounds.size.height + (57 * 2));
    self.cardImageView = cardImageView;
    self.tableView.tableHeaderView = cardImageView;
    
    self.cardImageView.image = [self.selectedPaymentMethod isKindOfClass:[STPApplePayPaymentMethod class]] ? [STPImageLibrary largeCardApplePayImage] : [STPImageLibrary largeCardFrontImage];
    
    self.tableView.backgroundColor = self.theme.primaryBackgroundColor;
    self.tableView.tintColor = self.theme.accentColor;
    self.cardImageView.tintColor = self.theme.accentColor;
    
    if ([STPColorUtils colorIsBright:self.theme.primaryBackgroundColor]) {
        self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    } else {
        self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    if (self.navigationController.navigationBar.translucent) {
        CGFloat insetTop = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        self.tableView.contentInset = UIEdgeInsetsMake(insetTop, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    } else {
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(__unused UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == STPPaymentMethodCardListSection) {
        return self.paymentMethods.count;
    } else if (section == STPPaymentMethodAddCardSection) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STPPaymentMethodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:STPPaymentMethodCellReuseIdentifier forIndexPath:indexPath];
    if (indexPath.section == STPPaymentMethodCardListSection) {
        id<STPPaymentMethod> paymentMethod = [self.paymentMethods stp_boundSafeObjectAtIndex:indexPath.row];
        [cell configureWithPaymentMethod:paymentMethod theme:self.theme];
        cell.selected = [paymentMethod isEqual:self.selectedPaymentMethod];
    } else {
        [cell configureForNewCardRowWithTheme:self.theme];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == STPPaymentMethodCardListSection) {
        id<STPPaymentMethod> paymentMethod = [self.paymentMethods stp_boundSafeObjectAtIndex:indexPath.row];
        self.selectedPaymentMethod = paymentMethod;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:STPPaymentMethodCardListSection] withRowAnimation:UITableViewRowAnimationFade];
        [self.delegate internalViewControllerDidSelectPaymentMethod:paymentMethod];
    } else if (indexPath.section == STPPaymentMethodAddCardSection) {
        STPPaymentConfiguration *config = [self.configuration copy];
        NSArray *cardPaymentMethods = [self.paymentMethods filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<STPPaymentMethod> paymentMethod, __unused NSDictionary<NSString *,id> * _Nullable bindings) {
            return [paymentMethod isKindOfClass:[STPCard class]];
        }]];
        // Disable SMS autofill if we already have a card on file
        config.smsAutofillDisabled = (config.smsAutofillDisabled || cardPaymentMethods.count > 0);
        
        STPAddCardViewController *paymentCardViewController = [[STPAddCardViewController alloc] initWithConfiguration:config theme:self.theme];
        paymentCardViewController.delegate = self;
        paymentCardViewController.prefilledInformation = self.prefilledInformation;
        [self.navigationController pushViewController:paymentCardViewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    if ([self tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0.01f;
    }
    return 27.0f;
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForHeaderInSection:(__unused NSInteger)section {
    return 0.01f;
}

- (void)addCardViewControllerDidCancel:(__unused STPAddCardViewController *)addCardViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addCardViewController:(__unused STPAddCardViewController *)addCardViewController
               didCreateToken:(STPToken *)token
                   completion:(STPErrorBlock)completion {
    [self.delegate internalViewControllerDidCreateToken:token completion:completion];
}

@end
