//
//  STPPaymentMethodTuple.h
//  Stripe
//
//  Created by Jack Flintermann on 5/17/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPCardTuple.h"
#import "STPPaymentMethod.h"

NS_ASSUME_NONNULL_BEGIN

@interface STPPaymentMethodTuple : NSObject

+ (instancetype)tupleWithPaymentMethods:(NSArray<id<STPPaymentMethod>> *)paymentMethods
                  selectedPaymentMethod:(id<STPPaymentMethod>)selectedPaymentMethod;

+ (instancetype)tupleWithCardTuple:(STPCardTuple *)cardTuple
                   applePayEnabled:(BOOL)applePayEnabled;

@property(nonatomic, nullable, readonly)id<STPPaymentMethod> selectedPaymentMethod;
@property(nonatomic, readonly)NSArray<id<STPPaymentMethod>> *paymentMethods;

@end

NS_ASSUME_NONNULL_END
