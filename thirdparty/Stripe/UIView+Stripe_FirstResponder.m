//
//  UIView+Stripe_FirstResponder.m
//  Stripe
//
//  Created by Jack Flintermann on 4/15/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "UIView+Stripe_FirstResponder.h"

@implementation UIView (Stripe_FirstResponder)

- (nullable UIView *)stp_findFirstResponder {
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        UIView *responder = [subView stp_findFirstResponder];
        if (responder) {
            return responder;
        }
    }
    return nil;
}

@end

void linkUIViewFirstResponderCategory(void){}
