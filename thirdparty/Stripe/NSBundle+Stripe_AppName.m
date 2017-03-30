//
//  NSBundle+Stripe_AppName.m
//  Stripe
//
//  Created by Jack Flintermann on 4/20/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "NSBundle+Stripe_AppName.h"

@implementation NSBundle (Stripe_AppName)

+ (nullable NSString *)stp_applicationName {
    return [[self mainBundle] infoDictionary][(NSString *)kCFBundleNameKey];
}

@end

void linkNSBundleAppNameCategory(void){}
