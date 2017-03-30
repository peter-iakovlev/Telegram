//
//  PKPaymentAuthorizationViewController+Stripe_Blocks.m
//  Stripe
//
//  Created by Ben Guo on 4/19/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "PKPaymentAuthorizationViewController+Stripe_Blocks.h"
#import "STPAPIClient+ApplePay.h"

FAUXPAS_IGNORED_IN_FILE(APIAvailability)

static char kSTPBlockBasedApplePayDelegateAssociatedObjectKey;

@interface STPBlockBasedApplePayDelegate : NSObject <PKPaymentAuthorizationViewControllerDelegate>
@property (nonatomic) STPAPIClient *apiClient;
@property (nonatomic, copy) STPApplePayTokenHandlerBlock onTokenCreation;
@property (nonatomic, copy) STPPaymentCompletionBlock onFinish;
@property (nonatomic) NSError *lastError;
@property (nonatomic) BOOL didSucceed;
@end

typedef void (^STPPaymentAuthorizationStatusCallback)(PKPaymentAuthorizationStatus status);

@implementation STPBlockBasedApplePayDelegate

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(STPPaymentAuthorizationStatusCallback)completion {
    [self.apiClient createTokenWithPayment:payment completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
        if (error) {
            self.lastError = error;
            completion(PKPaymentAuthorizationStatusFailure);
            return;
        }
        self.onTokenCreation(token, ^(NSError *tokenCreationError){
            if (tokenCreationError) {
                self.lastError = tokenCreationError;
                completion(PKPaymentAuthorizationStatusFailure);
                return;
            }
            self.didSucceed = YES;
            completion(PKPaymentAuthorizationStatusSuccess);
        });
    }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(__unused PKPaymentAuthorizationViewController *)controller {
    if (self.didSucceed) {
        self.onFinish(STPPaymentStatusSuccess, nil);
    }
    else if (self.lastError) {
        self.onFinish(STPPaymentStatusError, self.lastError);
    }
    else {
        self.onFinish(STPPaymentStatusUserCancellation, nil);
    }
}

@end

@interface PKPaymentAuthorizationViewController()

@end

@implementation PKPaymentAuthorizationViewController (Stripe_Blocks)

+ (instancetype)stp_controllerWithPaymentRequest:(PKPaymentRequest *)paymentRequest
                                       apiClient:(STPAPIClient *)apiClient
                             onTokenCreation:(STPApplePayTokenHandlerBlock)onTokenCreation
                                    onFinish:(STPPaymentCompletionBlock)onFinish {
    STPBlockBasedApplePayDelegate *delegate = [STPBlockBasedApplePayDelegate new];
    delegate.apiClient = apiClient;
    delegate.onTokenCreation = onTokenCreation;
    delegate.onFinish = onFinish;
    PKPaymentAuthorizationViewController *viewController = [[self alloc] initWithPaymentRequest:paymentRequest];
    viewController.delegate = delegate;
    objc_setAssociatedObject(viewController, &kSTPBlockBasedApplePayDelegateAssociatedObjectKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return viewController;
}

@end

void linkPKPaymentAuthorizationViewControllerBlocksCategory(void){}
