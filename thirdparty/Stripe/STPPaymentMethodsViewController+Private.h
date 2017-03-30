//
//  STPPaymentMethodsViewController+Private.h
//  Stripe
//
//  Created by Jack Flintermann on 5/18/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "Stripe.h"
#import "STPPromise.h"
#import "STPPaymentMethod.h"
#import "STPBackendAPIAdapter.h"
#import "STPPaymentMethodTuple.h"
#import "STPPaymentConfiguration.h"

@interface STPPaymentMethodsViewController (Private)

- (instancetype)initWithConfiguration:(STPPaymentConfiguration *)configuration
                           apiAdapter:(id<STPBackendAPIAdapter>)apiAdapter
                       loadingPromise:(STPPromise<STPPaymentMethodTuple *> *)loadingPromise
                                theme:(STPTheme *)theme
                             delegate:(id<STPPaymentMethodsViewControllerDelegate>)delegate;

@end
