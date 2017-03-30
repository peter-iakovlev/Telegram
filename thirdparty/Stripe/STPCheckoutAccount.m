//
//  STPCheckoutAccount.m
//  Stripe
//
//  Created by Jack Flintermann on 5/3/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPCheckoutAccount.h"

@interface STPCheckoutAccount()

@property(nonatomic, nonnull)NSString *email;
@property(nonatomic, nonnull)NSString *phone;
@property(nonatomic, nonnull)NSString *csrfToken;
@property(nonatomic, nonnull)NSString *sessionID;
@property(nonatomic, nonnull)STPCard *card;

@end

@implementation STPCheckoutAccount

+ (nullable instancetype)accountWithData:(nullable NSData *)data
                             URLResponse:(nullable NSURLResponse *)response {
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return nil;
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode != 200 && httpResponse.statusCode != 201) {
        return nil;
    }
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSDictionary *accountHash = object[@"account"];
    if (![accountHash isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *email = accountHash[@"email"];
    if (![email isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *phone = accountHash[@"phone"];
    if (![phone isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *csrfToken = object[@"securityToken"];
    if (![csrfToken isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *sessionID = object[@"sessionID"];
    if (![sessionID isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSDictionary *cardHash = accountHash[@"card"];
    if (![cardHash isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *last4 = cardHash[@"last4"];
    if (![last4 isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *brandString = cardHash[@"brand"];
    if (![brandString isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSNumber *expMonthNumber = cardHash[@"exp_month"];
    if (![expMonthNumber isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    NSNumber *expYearNumber = cardHash[@"exp_year"];
    if (![expYearNumber isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    STPCheckoutAccount *account = [self new];
    account.email = email;
    account.phone = phone;
    account.csrfToken = csrfToken;
    account.sessionID = sessionID;
    account.card = [[STPCard alloc] initWithID:@"" brand:[STPCard brandFromString:brandString] last4:last4 expMonth:expMonthNumber.unsignedIntegerValue expYear:expYearNumber.unsignedIntegerValue funding:STPCardFundingTypeOther];
    return account;
}

@end
