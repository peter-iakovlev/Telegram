//
//  STPEmailAddressValidator.m
//  Stripe
//
//  Created by Jack Flintermann on 3/23/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPEmailAddressValidator.h"

@implementation STPEmailAddressValidator

+ (BOOL)stringIsValidPartialEmailAddress:(nullable NSString *)string {
    return [[string mutableCopy] replaceOccurrencesOfString:@"@" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, string.length)] <= 1;
}

+ (BOOL)stringIsValidEmailAddress:(NSString *)string {
    if (!string) {
        return NO;
    }
    // regex from http://www.regular-expressions.info/email.html
    NSString *pattern = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [predicate evaluateWithObject:[string lowercaseString]];
}

@end
