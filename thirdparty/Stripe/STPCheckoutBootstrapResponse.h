//
//  STPCheckoutBootstrapResponse.h
//  Stripe
//
//  Created by Jack Flintermann on 5/4/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STPAPIClient;

@interface STPCheckoutBootstrapResponse : NSObject

+ (nullable instancetype)bootstrapResponseWithData:(nullable NSData *)data
                                       URLResponse:(nullable NSURLResponse *)response;

@property(nonatomic, readonly)BOOL liveMode;
@property(nonatomic, readonly)BOOL accountsDisabled;
@property(nonatomic, readonly, nonnull)NSString *sessionID;
@property(nonatomic, readonly, nonnull)NSString *csrfToken;
@property(nonatomic, readonly, nonnull)STPAPIClient *tokenClient;

@end
