//
//  NSDecimalNumber+Stripe_Currency.h
//  Stripe
//
//  Created by Jack Flintermann on 4/20/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (Stripe_Currency)

+ (NSDecimalNumber *)stp_decimalNumberWithAmount:(NSInteger)amount
                                        currency:(NSString *)currency;

- (NSInteger)stp_amountWithCurrency:(NSString *)currency;

@end

void linkNSDecimalNumberCurrencyCategory(void);
