//
//  NSArray+Stripe_BoundSafe.m
//  Stripe
//
//  Created by Jack Flintermann on 1/19/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "NSArray+Stripe_BoundSafe.h"

@implementation NSArray (Stripe_BoundSafe)

- (nullable id)stp_boundSafeObjectAtIndex:(NSInteger)index {
    if (index + 1 > (NSInteger)self.count || index < 0) {
        return nil;
    }
    return self[index];
}

@end

void linkNSArrayBoundSafeCategory(void){}
