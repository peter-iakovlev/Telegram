//
//  STPApplePayPaymentMethod.m
//  Stripe
//
//  Created by Ben Guo on 4/19/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPApplePayPaymentMethod.h"
#import "STPImageLibrary.h"
#import "STPImageLibrary+Private.h"
#import "STPLocalizationUtils.h"

@implementation STPApplePayPaymentMethod

- (UIImage *)image {
    return [STPImageLibrary applePayCardImage];
}

- (UIImage *)templateImage {
    return [STPImageLibrary safeImageNamed:@"stp_card_applepay_template" 
                       templateIfAvailable:YES];
}

- (NSString *)label {
    return STPLocalizedString(@"Apple Pay", @"Text for Apple Pay payment method");
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[STPApplePayPaymentMethod class]];
}

- (NSUInteger)hash {
    return [NSStringFromClass(self.class) hash];
}

@end
