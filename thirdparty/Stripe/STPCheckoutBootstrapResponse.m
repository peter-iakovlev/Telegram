//
//  STPCheckoutBootstrapResponse.m
//  Stripe
//
//  Created by Jack Flintermann on 5/4/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPCheckoutBootstrapResponse.h"
#import "STPAPIClient.h"
#import "STPAPIClient+Private.h"


@interface STPCheckoutBootstrapResponse()

@property(nonatomic)BOOL liveMode;
@property(nonatomic)BOOL accountsDisabled;
@property(nonatomic, nonnull)NSString *sessionID;
@property(nonatomic, nonnull)NSString *csrfToken;
@property(nonatomic, nonnull)STPAPIClient *tokenClient;

@end

@implementation STPCheckoutBootstrapResponse

+ (nullable instancetype)bootstrapResponseWithData:(NSData *)data
                                       URLResponse:( NSURLResponse *)response {
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
    NSString *checkoutPublishableKey = object[@"checkoutPublishableKey"];
    if (![checkoutPublishableKey isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString *sessionID = object[@"sessionID"];
    if (![sessionID isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *csrfToken = object[@"securityToken"];
    if (![csrfToken isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSNumber *accountsDisabled = object[@"accountsDisabled"];
    if (![accountsDisabled isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    NSString *apiURL = object[@"apiEndpoint"];
    if (![apiURL isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSNumber *liveMode = object[@"livemode"];
    if (![liveMode isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    STPCheckoutBootstrapResponse *bootstrap = [self new];
    bootstrap.accountsDisabled = [accountsDisabled boolValue];
    bootstrap.sessionID = sessionID;
    bootstrap.liveMode = [liveMode boolValue];
    bootstrap.csrfToken = csrfToken;
    bootstrap.tokenClient = [[STPAPIClient alloc] initWithPublishableKey:checkoutPublishableKey
                                                                 baseURL:apiURL];
    return bootstrap;
}

@end
