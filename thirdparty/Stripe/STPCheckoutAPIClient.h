//
//  STPCheckoutAPIClient.h
//  Stripe
//
//  Created by Jack Flintermann on 5/3/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPCheckoutAPIVerification.h"
#import "STPCheckoutAccount.h"
#import "STPCheckoutAccountLookup.h"
#import "STPBlocks.h"
#import "STPPromise.h"
#import "STPToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface STPCheckoutAPIClient : NSObject

@property(nonatomic, copy)NSString *merchantName;
@property(nonatomic)STPVoidPromise *bootstrapPromise;
@property(nonatomic, readonly)BOOL readyForLookups;

- (instancetype)initWithPublishableKey:(NSString *)publishableKey;

- (STPPromise<STPCheckoutAccountLookup *> *)lookupEmail:(NSString *)email;

- (STPPromise<STPCheckoutAPIVerification *> *)sendSMSToAccountWithEmail:(NSString *)email;

- (STPPromise<STPCheckoutAccount *> *)submitSMSCode:(NSString *)code
                                    forVerification:(STPCheckoutAPIVerification *)verification;

- (STPPromise<STPToken *> *)createTokenWithAccount:(STPCheckoutAccount *)account;

- (STPPromise<STPCheckoutAccount *> *)createAccountWithCardParams:(STPCardParams *)cardParams
                                                            email:(NSString *)email
                                                            phone:(NSString *)phone;

@end

NS_ASSUME_NONNULL_END
