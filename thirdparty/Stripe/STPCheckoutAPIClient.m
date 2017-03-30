//
//  STPCheckoutAPIClient.m
//  Stripe
//
//  Created by Jack Flintermann on 5/3/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPCheckoutAPIClient.h"
#import "STPCheckoutBootstrapResponse.h"
#import "NSMutableURLRequest+Stripe.h"
#import "STPAPIClient.h"
#import "STPCardValidator.h"
#import "NSBundle+Stripe_AppName.h"
#import "StripeError.h"
#import "STPWeakStrongMacros.h"
#import "STPLocalizationUtils.h"

@interface STPCheckoutAPIClient()
@property(nonatomic, copy)NSString *publishableKey;
@property(nonatomic)NSURLSession *accountSession;
@property(nonatomic)NSURLSessionTask *lookupTask;
@property(nonatomic)STPAPIClient *tokenClient;
@end

static NSString *CheckoutBaseURLString = @"https://checkout.stripe.com/api";

@implementation STPCheckoutAPIClient

- (instancetype)initWithPublishableKey:(NSString *)publishableKey {
    self = [super init];
    if (self) {
        _publishableKey = publishableKey;
        _merchantName = [NSBundle stp_applicationName];
        _bootstrapPromise = [STPVoidPromise new];
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURL *baseURL = [NSURL URLWithString:CheckoutBaseURLString];
        NSURL *url = [baseURL URLByAppendingPathComponent:@"bootstrap"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSDictionary *payload = @{
                                  @"key": _publishableKey
                                  };
        WEAK(self);
        [request stp_addParametersToURL:payload];
        [[urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse * response, NSError *error) {
            STRONG(self);
            if (error) {
                [self.bootstrapPromise fail:error];
            } else {
                STPCheckoutBootstrapResponse *bootstrap = [STPCheckoutBootstrapResponse bootstrapResponseWithData:data URLResponse:response];
                if (bootstrap && !bootstrap.accountsDisabled) {
                    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:httpResponse.allHeaderFields forURL:baseURL];
                    NSMutableDictionary *cookieHeaders = [[NSHTTPCookie requestHeaderFieldsWithCookies:cookies] mutableCopy];
                    [cookieHeaders addEntriesFromDictionary:@{
                                                            @"X-Stripe-Client": @"iossdk",
                                                            @"X-Stripe-Client-Version": STPSDKVersion,
                                                            @"X-CSRF-Token": bootstrap.csrfToken,
                                                            }];
                    configuration.HTTPAdditionalHeaders = cookieHeaders;
                    self.accountSession = [NSURLSession sessionWithConfiguration:configuration];
                    self.tokenClient = bootstrap.tokenClient;
                    [self.bootstrapPromise succeed];
                } else {
                    [self.bootstrapPromise fail:[self.class genericRememberMeErrorWithResponseData:data message:@"Bootstrap failed."]];
                }
            }
        }] resume];
    }
    return self;
}

- (BOOL)readyForLookups {
    if (self.bootstrapPromise.completed) {
        return !self.bootstrapPromise.error;
    }
    return NO;
}

- (STPPromise *)lookupEmail:(NSString *)email {
    WEAK(self);
    Class selfClass = self.class;
    return [self.bootstrapPromise voidFlatMap:^STPPromise*() {
        STRONG(self);
        if (!self) {
            return [STPPromise promiseWithError:[selfClass cancellationError]];
        }
        STPPromise<STPCheckoutAccountLookup *> *lookupPromise = [STPPromise<STPCheckoutAccountLookup *> new];
        NSURL *url = [[NSURL URLWithString:CheckoutBaseURLString] URLByAppendingPathComponent:@"account/lookup"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSDictionary *payload = @{
                                  @"key": self.publishableKey,
                                  @"email": email,
                                  };
        [request stp_addParametersToURL:payload];
        [self.lookupTask cancel];
        self.lookupTask = [self.accountSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            STPCheckoutAccountLookup *lookup = [STPCheckoutAccountLookup lookupWithData:data URLResponse:response];
            if (lookup) {
                [lookupPromise succeed:lookup];
            } else {
                [lookupPromise fail:error ?: [self.class genericRememberMeErrorWithResponseData:data message:@"Failed to parse account lookup response"]];
            }
        }];
        [self.lookupTask resume];
        return lookupPromise;
    }];
}

- (STPPromise *)sendSMSToAccountWithEmail:(NSString *)email {
    WEAK(self);
    Class selfClass = self.class;
    return [self.bootstrapPromise voidFlatMap:^STPPromise *{
        STRONG(self);
        STPPromise *smsPromise = [STPPromise new];
        if (!self) {
            return [STPPromise promiseWithError:[selfClass cancellationError]];
        }
        NSURL *url = [[NSURL URLWithString:CheckoutBaseURLString] URLByAppendingPathComponent:@"account/verifications"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        NSDictionary *payload = @{
                                  @"key": self.publishableKey,
                                  @"email": email,
                                  @"locale": @"en",
                                  };
        NSDictionary *formPayload = @{
                                      @"merchant_name": self.merchantName,
                                      };
        [request stp_addParametersToURL:payload];
        [request stp_setFormPayload:formPayload];
        [[self.accountSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            STPCheckoutAPIVerification *verification = [STPCheckoutAPIVerification verificationWithData:data URLResponse:response];
            if (verification) {
                [smsPromise succeed:verification];
            } else {
                [smsPromise fail:error ?: [self.class genericRememberMeErrorWithResponseData:data message:@"Failed to parse SMS verification"]];
            }
        }] resume];
        return smsPromise;
    }];
}

- (STPPromise *)submitSMSCode:(NSString *)code
              forVerification:(STPCheckoutAPIVerification *)verification {
    WEAK(self);
    Class selfClass = self.class;
    return [self.bootstrapPromise voidFlatMap:^STPPromise *{
        STRONG(self);
        STPPromise<STPCheckoutAccount*> *accountPromise = [STPPromise<STPCheckoutAccount *> new];
        if (!self) {
            return [STPPromise promiseWithError:[selfClass cancellationError]];
        }
        NSString *pathComponent = [@"account/verifications" stringByAppendingPathComponent:verification.verificationID];
        NSURL *url = [[NSURL URLWithString:CheckoutBaseURLString] URLByAppendingPathComponent:pathComponent];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"PUT";

        NSDictionary *formPayload = @{
                                      @"code": code,
                                      @"key": self.publishableKey,
                                      @"locale": @"en",
                                      };
        [request stp_setFormPayload:formPayload];
        [[self.accountSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            STPCheckoutAccount *account = [STPCheckoutAccount accountWithData:data URLResponse:response];
            if (account) {
                [accountPromise succeed:account];
            } else {
                [accountPromise fail:error ?: [self.class genericRememberMeErrorWithResponseData:data message:@"Failed to parse checkout account response"]];
            }
        }] resume];
        return accountPromise;
    }];
}

- (STPPromise *)createTokenWithAccount:(STPCheckoutAccount *)account {
    WEAK(self);
    Class selfClass = self.class;
    return [self.bootstrapPromise voidFlatMap:^STPPromise *{
        STRONG(self);
        STPPromise<STPToken *> *tokenPromise = [STPPromise new];
        if (!self) {
            return [STPPromise promiseWithError:[selfClass cancellationError]];
        }
        NSURL *url = [[NSURL URLWithString:CheckoutBaseURLString] URLByAppendingPathComponent:@"account/tokens"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        NSDictionary *payload = @{
                                  @"key": self.publishableKey,
                                  };
        [request stp_addParametersToURL:payload];
        [request setValue:account.sessionID forHTTPHeaderField:@"X-Rack-Session"];
        [request setValue:account.sessionID forHTTPHeaderField:@"Stripe-Checkout-Test-Session"];
        [request setValue:account.csrfToken forHTTPHeaderField:@"X-CSRF-Token"];
        [[self.accountSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            STPToken *token = [self parseTokenFromResponse:response data:data];
            if (token) {
                [tokenPromise succeed:token];
            } else {
                [tokenPromise fail:error ?: [self.class genericRememberMeErrorWithResponseData:data message:@"Failed to parse token from checkout response"]];
            }
        }] resume];
        return tokenPromise;
    }];
}

- (STPPromise *)createAccountWithCardParams:(STPCardParams *)cardParams
                                      email:(NSString *)email
                                      phone:(NSString *)phone {
    WEAK(self);
    Class selfClass = self.class;
    return [[self.bootstrapPromise voidFlatMap:^STPPromise * _Nonnull{
        STRONG(self);
        STPPromise *tokenPromise = [STPPromise new];
        [self.tokenClient createTokenWithCard:cardParams completion:^(STPToken *token, NSError *error) {
            if (error) {
                [tokenPromise fail:error];
            } else {
                [tokenPromise succeed:token];
            }
        }];
        return tokenPromise;
    }] flatMap:^STPPromise *(STPToken *token) {
        STRONG(self);
        if (!self) {
            return [STPPromise promiseWithError:[selfClass cancellationError]];
        }
        STPPromise<STPCheckoutAccount*> *accountPromise = [STPPromise<STPCheckoutAccount *> new];
        NSURL *url = [[NSURL URLWithString:CheckoutBaseURLString] URLByAppendingPathComponent:@"account"];
        NSString *internationalizedPhone = [STPCardValidator sanitizedNumericStringForString:phone];
        if  ([[[NSLocale autoupdatingCurrentLocale] localeIdentifier] isEqualToString:@"en_US"] && ![internationalizedPhone hasPrefix:@"1"]) {
            internationalizedPhone = [@"1" stringByAppendingString:internationalizedPhone];
        }
        if (![internationalizedPhone hasPrefix:@"+"]) {
            internationalizedPhone = [@"+" stringByAppendingString:internationalizedPhone];
        }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        
        NSDictionary *formPayload = @{
                                      @"token": token.tokenId,
                                      @"key": self.publishableKey,
                                      @"phone": internationalizedPhone,
                                      @"email": email,
                                      @"merchant_name": self.merchantName,
                                      };
        [request stp_setFormPayload:formPayload];
        [[self.accountSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            STPCheckoutAccount *account = [STPCheckoutAccount accountWithData:data URLResponse:response];
            if (account) {
                [accountPromise succeed:account];
            } else {
                [accountPromise fail:error ?: [self.class genericRememberMeErrorWithResponseData:data
                                                                                         message:STPLocalizedString(@"Failed to parse account response", 
                                                                                                                    @"Error message for checkout account api call")]];
            }
        }] resume];
        return accountPromise;
    }];
}

- (nullable STPToken *)parseTokenFromResponse:(NSURLResponse *)response
                                         data:(NSData *)data {
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return nil;
    }
    if (((NSHTTPURLResponse *)response).statusCode != 200) {
        return nil;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [STPToken decodedObjectFromAPIResponse:json[@"token"]];
}

+ (NSError *)cancellationError {
    return [NSError errorWithDomain:StripeDomain code:STPCancellationError userInfo:@{
      NSLocalizedDescriptionKey: STPLocalizedString(@"The operation was cancelled", 
                                                    @"Error message for network request being cancelled.")
                                                                                    }];
}

+ (NSError *)genericRememberMeErrorWithResponseData:(NSData *)responseData
                                            message:(NSString *)message {
    NSInteger code = STPCheckoutUnknownError;
    NSDictionary *json;
    id object = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    if ([object isKindOfClass:[NSDictionary class]]) {
        json = object;
        if ([json[@"reason"] isEqualToString:@"too_many_attempts"]) {
            code = STPCheckoutTooManyAttemptsError;
        }
    }
    
    return [NSError errorWithDomain:StripeDomain code:code userInfo:@{
    NSLocalizedDescriptionKey: [NSString stringWithFormat:STPLocalizedString(@"Something went wrong with Remember Me: %@", 
                                                                             @"Error message for Remember Me network error. More detailed cause of the error will be filled into the substitution."),
                                message]
    }];
}

@end
