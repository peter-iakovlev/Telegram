//
//  STPCategoryLoader.m
//  Stripe
//
//  Created by Jack Flintermann on 10/19/15.
//  Copyright © 2015 Stripe, Inc. All rights reserved.
//

#ifdef STP_STATIC_LIBRARY_BUILD

#import "STPCategoryLoader.h"
#import "PKPayment+Stripe.h"
#import "NSDictionary+Stripe.h"
#import "NSString+Stripe.h"
#import "NSMutableURLRequest+Stripe.h"
#import "STPAPIClient+ApplePay.h"
#import "UINavigationBar+Stripe_Theme.h"
#import "UIBarButtonItem+Stripe.h"
#import "PKPaymentAuthorizationViewController+Stripe_Blocks.h"
#import "UIToolbar+Stripe_InputAccessory.h"
#import "UITableViewCell+Stripe_Borders.h"
#import "UIViewController+Stripe_Promises.h"
#import "UIViewController+Stripe_NavigationItemProxy.h"
#import "NSString+Stripe_CardBrands.h"
#import "NSArray+Stripe_BoundSafe.h"
#import "UIViewController+Stripe_ParentViewController.h"
#import "UINavigationController+Stripe_Completion.h"
#import "UIView+Stripe_FirstResponder.h"
#import "UIViewController+Stripe_KeyboardAvoiding.h"
#import "NSDecimalNumber+Stripe_Currency.h"
#import "NSBundle+Stripe_AppName.h"
#import "STPAspects.h"

@implementation STPCategoryLoader

+ (void)loadCategories {
    linkPKPaymentCategory();
    linkNSDictionaryCategory();
    linkSTPAPIClientApplePayCategory();
    linkNSStringCategory();
    linkNSMutableURLRequestCategory();
    linkUINavigationBarThemeCategory();
    linkUIBarButtonItemCategory();
    linkPKPaymentAuthorizationViewControllerBlocksCategory();
    linkUIToolbarInputAccessoryCategory();
    linkUITableViewCellBordersCategory();
    linkUIViewControllerPromisesCategory();
    linkUIViewControllerNavigationItemProxyCategory();
    linkNSStringCardBrandsCategory();
    linkNSArrayBoundSafeCategory();
    linkUIViewControllerParentViewControllerCategory();
    linkUINavigationControllerCompletionCategory();
    linkUIViewFirstResponderCategory();
    linkUIViewControllerKeyboardAvoidingCategory();
    linkNSDecimalNumberCurrencyCategory();
    linkNSBundleAppNameCategory();
    linkAspectsCategory();
}

@end

#endif
