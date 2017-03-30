//
//  STPCheckoutAPIVerification.m
//  Stripe
//
//  Created by Jack Flintermann on 5/3/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPCheckoutAPIVerification.h"

@interface STPCheckoutAPIVerification()

@property(nonatomic)NSString *verificationID;
@property(nonatomic)NSString *statusURLString;

@end

@implementation STPCheckoutAPIVerification

+ (nullable instancetype)verificationWithData:(nullable NSData *)data
                                  URLResponse:(nullable NSURLResponse *)response {
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return nil;
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode != 201) {
        return nil;
    }
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *verificationID = object[@"id"];
    if (![verificationID isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *statusURLString = object[@"status_url"];
    if (![statusURLString isKindOfClass:[NSString class]]) {
        return nil;
    }
    STPCheckoutAPIVerification *verification = [self new];
    verification.verificationID = verificationID;
    verification.statusURLString = statusURLString;
    return verification;
}

@end
