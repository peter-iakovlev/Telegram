//
//  STPCheckoutAccount.h
//  Stripe
//
//  Created by Jack Flintermann on 5/3/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPCard.h"

@interface STPCheckoutAccount : NSObject

+ (nullable instancetype)accountWithData:(nullable NSData *)data
                             URLResponse:(nullable NSURLResponse *)response;

@property(nonatomic, nonnull, readonly)NSString *email;
@property(nonatomic, nonnull, readonly)NSString *phone;
@property(nonatomic, nonnull, readonly)NSString *csrfToken;
@property(nonatomic, nonnull, readonly)NSString *sessionID;
@property(nonatomic, nonnull, readonly)STPCard *card;

@end
