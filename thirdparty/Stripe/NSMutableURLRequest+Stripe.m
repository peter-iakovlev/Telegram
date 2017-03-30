//
//  NSMutableURLRequest+Stripe.m
//  Stripe
//
//  Created by Ben Guo on 4/22/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "NSMutableURLRequest+Stripe.h"
#import "STPFormEncoder.h"

@implementation NSMutableURLRequest (Stripe)

- (void)stp_addParametersToURL:(NSDictionary *)parameters {
    NSString *query = [STPFormEncoder queryStringFromParameters:parameters];
    NSString *urlString = [self.URL absoluteString];
    self.URL = [NSURL URLWithString:[urlString stringByAppendingFormat:self.URL.query ? @"&%@" : @"?%@", query]];
}

- (void)stp_setFormPayload:(NSDictionary *)formPayload {
    NSData *formData = [[STPFormEncoder queryStringFromParameters:formPayload] dataUsingEncoding:NSUTF8StringEncoding];
    self.HTTPBody = formData;
    [self setValue:[NSString stringWithFormat:@"%lu", (unsigned long)formData.length] forHTTPHeaderField:@"Content-Length"];
    [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
}

@end

void linkNSMutableURLRequestCategory(void){}
