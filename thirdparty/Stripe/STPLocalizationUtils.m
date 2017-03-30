//
//  STPLocalizationUtils.m
//  Stripe
//
//  Created by Brian Dorfman on 8/11/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPLocalizationUtils.h"
#import "STPBundleLocator.h"

@implementation STPLocalizationUtils

+ (NSString *)localizedStripeStringForKey:(NSString *)key {
    NSBundle *bundle = [STPBundleLocator stripeResourcesBundle];

    return [bundle localizedStringForKey:key value:nil table:nil];
}

@end
