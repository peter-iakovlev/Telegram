//
//  STPPaymentMethodsInternalViewController.h
//  Stripe
//
//  Created by Jack Flintermann on 6/9/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPPaymentMethodTuple.h"
#import "STPPaymentConfiguration.h"
#import "STPPaymentConfiguration+Private.h"

@protocol STPPaymentMethodsInternalViewControllerDelegate

- (void)internalViewControllerDidSelectPaymentMethod:(id<STPPaymentMethod>)paymentMethod;
- (void)internalViewControllerDidCreateToken:(STPToken *)token
                                  completion:(STPErrorBlock)completion;

@end

@interface STPPaymentMethodsInternalViewController : UIViewController

- (instancetype)initWithConfiguration:(STPPaymentConfiguration *)configuration
                                theme:(STPTheme *)theme
                 prefilledInformation:(STPUserInformation *)prefilledInformation
                   paymentMethodTuple:(STPPaymentMethodTuple *)tuple
                             delegate:(id<STPPaymentMethodsInternalViewControllerDelegate>)delegate;

@end
