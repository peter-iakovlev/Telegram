//
//  STPUserInformation.m
//  Stripe
//
//  Created by Jack Flintermann on 6/15/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPUserInformation.h"
#import "STPCardValidator.h"


@implementation STPUserInformation

- (void)setPhone:(NSString *)phone {
    _phone = [STPCardValidator sanitizedNumericStringForString:phone];
}

@end
