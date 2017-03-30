//
//  STPCheckoutAccountLookup.m
//  Stripe
//
//  Created by Jack Flintermann on 5/4/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPCheckoutAccountLookup.h"

@interface STPCheckoutAccountLookup()

@property(nonatomic)NSString *email;
@property(nonatomic)NSString *redactedPhone;

@end

@implementation STPCheckoutAccountLookup

+ (nullable instancetype)lookupWithData:(nullable NSData *)data
                            URLResponse:(nullable NSURLResponse *)response {
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return nil;
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode != 200) {
        return nil;
    }
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSDictionary *account = object[@"account"];
    if (![account isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *email = account[@"email"];
    if (![email isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *redactedPhone = account[@"phone"];
    if (![redactedPhone isKindOfClass:[NSString class]]) {
        return nil;
    }
    STPCheckoutAccountLookup *lookup = [self new];
    lookup.email = email;
    lookup.redactedPhone = redactedPhone;
    return lookup;
}

@end
