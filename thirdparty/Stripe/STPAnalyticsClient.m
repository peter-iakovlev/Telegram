//
//  STPAnalyticsClient.m
//  Stripe
//
//  Created by Ben Guo on 4/22/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPAnalyticsClient.h"
#import "NSMutableURLRequest+Stripe.h"
#import "STPAPIClient.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "STPToken.h"
#import "STPCard.h"
#import "STPPaymentConfiguration.h"
#import "STPFormEncodable.h"
#import "STPAspects.h"
#import "STPPaymentCardTextField.h"
#import "STPPaymentContext.h"
#import "STPAddCardViewController.h"
#import "STPAddCardViewController+Private.h"
#import "STPPaymentMethodsViewController.h"
#import "STPPaymentMethodsViewController+Private.h"
#import "STPAPIClient+ApplePay.h"

static BOOL STPAnalyticsCollectionDisabled = NO;

@interface STPAnalyticsClient()

@property (nonatomic) NSSet *apiUsage;
@property (nonatomic, readwrite) NSURLSession *urlSession;

@end

@implementation STPAnalyticsClient

+ (instancetype)sharedClient {
    static id sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [self new];
    });
    return sharedClient;
}

+ (void)initialize {
    [self initializeIfNeeded];
}

+ (void)initializeIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [STPPaymentCardTextField stp_aspect_hookSelector:@selector(commonInit)
                                             withOptions:STPAspectPositionAfter
                                              usingBlock:^{
                                                  STPAnalyticsClient *client = [self sharedClient];
                                                  [client setApiUsage:[client.apiUsage setByAddingObject:NSStringFromClass([STPPaymentCardTextField class])]];
                                              } error:nil];
        
        [STPPaymentContext stp_aspect_hookSelector:@selector(initWithAPIAdapter:configuration:theme:)
                                       withOptions:STPAspectPositionAfter
                                        usingBlock:^{
                                            STPAnalyticsClient *client = [self sharedClient];
                                            [client setApiUsage:[client.apiUsage setByAddingObject:NSStringFromClass([STPPaymentContext class])]];
                                        } error:nil];
        
        
        [STPAddCardViewController stp_aspect_hookSelector:@selector(commonInitWithConfiguration:theme:)
                                              withOptions:STPAspectPositionAfter
                                               usingBlock:^{
                                                   STPAnalyticsClient *client = [self sharedClient];
                                                   [client setApiUsage:[client.apiUsage setByAddingObject:NSStringFromClass([STPAddCardViewController class])]];
                                               } error:nil];
        
        [STPPaymentMethodsViewController stp_aspect_hookSelector:@selector(initWithConfiguration:apiAdapter:loadingPromise:theme:delegate:)
                                                     withOptions:STPAspectPositionAfter
                                                      usingBlock:^{
                                                          STPAnalyticsClient *client = [self sharedClient];
                                                          [client setApiUsage:[client.apiUsage setByAddingObject:NSStringFromClass([STPPaymentMethodsViewController class])]];
                                                      } error:nil];
    });
}

+ (void)disableAnalytics {
    STPAnalyticsCollectionDisabled = YES;
}

+ (BOOL)shouldCollectAnalytics {
#if TARGET_OS_SIMULATOR
    return NO;
#endif
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
    return NSClassFromString(@"XCTest") == nil && !STPAnalyticsCollectionDisabled;
#pragma clang diagnostic pop
}

+ (NSNumber *)timestampWithDate:(NSDate *)date {
    return @((NSInteger)([date timeIntervalSince1970]*1000));
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config];
        _apiUsage = [NSSet set];
    }
    return self;
}

- (void)logRememberMeConversion:(BOOL)selected {
    NSMutableDictionary *payload = [self.class commonPayload];
    [payload addEntriesFromDictionary:@{
                                        @"event": @"stripeios.remember_me",
                                        @"selected": @(selected),
                                        }];
    [self logPayload:payload];
}

- (void)logTokenCreationAttemptWithConfiguration:(STPPaymentConfiguration *)configuration {
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(description)) ascending:YES];
    NSArray *productUsage = [self.apiUsage sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSDictionary *configurationDictionary = [self.class serializeConfiguration:configuration];
    NSMutableDictionary *payload = [self.class commonPayload];
    [payload addEntriesFromDictionary:@{
                                        @"event": @"stripeios.token_creation",
                                        @"apple_pay_enabled": @([Stripe deviceSupportsApplePay]),
                                        @"product_usage": productUsage ?: @[],
                                        }];
    [payload addEntriesFromDictionary:configurationDictionary];
    [self logPayload:payload];
}

- (void)logRUMWithToken:(STPToken *)token
          configuration:(STPPaymentConfiguration *)configuration
               response:(NSHTTPURLResponse *)response
                  start:(NSDate *)startTime
                    end:(NSDate *)endTime {
    NSString *tokenTypeString = @"unknown";
    if (token.bankAccount) {
        tokenTypeString = @"bank_account";
    } else if (token.card) {
        if (token.card.isApplePayCard) {
            tokenTypeString = @"apple_pay";
        } else {
            tokenTypeString = @"card";
        }
    }
    NSNumber *start = [[self class] timestampWithDate:startTime];
    NSNumber *end = [[self class] timestampWithDate:endTime];
    NSMutableDictionary *payload = [self.class commonPayload];
    [payload addEntriesFromDictionary:@{
                                        @"event": @"rum.stripeios",
                                        @"tokenType": tokenTypeString,
                                        @"url": response.URL.absoluteString ?: @"unknown",
                                        @"status": @(response.statusCode),
                                        @"publishable_key": configuration.publishableKey ?: @"unknown",
                                        @"start": start,
                                        @"end": end,
                                        }];
    [self logPayload:payload];
}

+ (NSMutableDictionary *)commonPayload {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"bindings_version"] = STPSDKVersion;
    payload[@"analytics_ua"] = @"analytics.stripeios-1.0";
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version) {
        payload[@"os_version"] = version;
    }
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceType = @(systemInfo.machine);
    if (deviceType) {
        payload[@"device_type"] = deviceType;
    }
    return payload;
}

+ (NSDictionary *)serializeConfiguration:(STPPaymentConfiguration *)configuration {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[@"publishable_key"] = configuration.publishableKey ?: @"unknown";
    switch (configuration.additionalPaymentMethods) {
        case STPPaymentMethodTypeAll:
            dictionary[@"additional_payment_methods"] = @"all";
        case STPPaymentMethodTypeNone:
            dictionary[@"additional_payment_methods"] = @"none";
    }
    switch (configuration.requiredBillingAddressFields) {
        case STPBillingAddressFieldsNone:
            dictionary[@"required_billing_address_fields"] = @"none";
        case STPBillingAddressFieldsZip:
            dictionary[@"required_billing_address_fields"] = @"zip";
        case STPBillingAddressFieldsFull:
            dictionary[@"required_billing_address_fields"] = @"full";
    }
    dictionary[@"company_name"] = configuration.companyName ?: @"unknown";
    dictionary[@"apple_merchant_identifier"] = configuration.appleMerchantIdentifier ?: @"unknown";
    dictionary[@"sms_autofill_disabled"] = @(configuration.smsAutofillDisabled);
    return [dictionary copy];
}

- (void)logPayload:(NSDictionary *)payload {
    if (![[self class] shouldCollectAnalytics]) {
        return;
    }
    NSURL *url = [NSURL URLWithString:@"https://q.stripe.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request stp_addParametersToURL:payload];
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request];
    [task resume];
}

@end
