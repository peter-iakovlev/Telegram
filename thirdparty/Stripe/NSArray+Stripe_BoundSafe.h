//
//  NSArray+Stripe_BoundSafe.h
//  Stripe
//
//  Created by Jack Flintermann on 1/19/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Stripe_BoundSafe)

- (nullable id)stp_boundSafeObjectAtIndex:(NSInteger)index;

@end

void linkNSArrayBoundSafeCategory(void);
