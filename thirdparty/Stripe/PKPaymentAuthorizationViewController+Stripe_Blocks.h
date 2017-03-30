//
//  PKPaymentAuthorizationViewController+Stripe_Blocks.h
//  Stripe
//
//  Created by Ben Guo on 4/19/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <PassKit/PassKit.h>
#import "STPAPIClient.h"
#import "STPPaymentContext.h"

#define FAUXPAS_IGNORED_IN_FILE(...)
FAUXPAS_IGNORED_IN_FILE(APIAvailability)

typedef void(^STPApplePayTokenHandlerBlock)(STPToken *token, STPErrorBlock completion);
typedef void (^STPPaymentCompletionBlock)(STPPaymentStatus status, NSError *error);

@interface PKPaymentAuthorizationViewController (Stripe_Blocks)

+ (instancetype)stp_controllerWithPaymentRequest:(PKPaymentRequest *)paymentRequest
                                       apiClient:(STPAPIClient *)apiClient
                                 onTokenCreation:(STPApplePayTokenHandlerBlock)onTokenCreation
                                        onFinish:(STPPaymentCompletionBlock)onFinish;


@end

void linkPKPaymentAuthorizationViewControllerBlocksCategory(void);
