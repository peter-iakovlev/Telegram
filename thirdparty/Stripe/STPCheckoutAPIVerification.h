//
//  STPCheckoutAPIVerification.h
//  Stripe
//
//  Created by Jack Flintermann on 5/3/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STPCheckoutAPIVerification : NSObject

+ (nullable instancetype)verificationWithData:(nullable NSData *)data
                                  URLResponse:(nullable NSURLResponse *)response;

@property(nonatomic, readonly)NSString *verificationID;
@property(nonatomic, readonly)NSString *statusURLString;

@end

NS_ASSUME_NONNULL_END
