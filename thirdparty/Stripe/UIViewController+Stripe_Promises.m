//
//  UIViewController+Stripe_Promises.m
//  Stripe
//
//  Created by Jack Flintermann on 5/20/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "UIViewController+Stripe_Promises.h"
#import "STPPromise.h"
#import <objc/runtime.h>
#import "STPAspects.h"

@implementation UIViewController (Stripe_Promises)

- (STPVoidPromise *)stp_willAppearPromise {
    STPVoidPromise *promise = objc_getAssociatedObject(self, @selector(stp_willAppearPromise));
    if (!promise) {
        promise = [STPVoidPromise new];
        if (self.isViewLoaded && self.view.window) {
            [promise succeed];
        } else {
            [self stp_aspect_hookSelector:@selector(viewWillAppear:) withOptions:(STPAspectPositionAfter) usingBlock:^{
                if (!promise.completed) {
                    [promise succeed];
                }
            } error:nil];
        }
        objc_setAssociatedObject(self, @selector(stp_willAppearPromise), promise, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return promise;
}

- (STPVoidPromise *)stp_didAppearPromise {
    STPVoidPromise *promise = objc_getAssociatedObject(self, @selector(stp_didAppearPromise));
    if (!promise) {
        promise = [STPVoidPromise new];
        if (self.isViewLoaded && self.view.window) {
            [promise succeed];
        } else {
            [self stp_aspect_hookSelector:@selector(viewDidAppear:) withOptions:(STPAspectPositionAfter) usingBlock:^{
                if (!promise.completed) {
                    [promise succeed];
                }
            } error:nil];
        }
        objc_setAssociatedObject(self, @selector(stp_didAppearPromise), promise, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return promise;
}

@end

void linkUIViewControllerPromisesCategory(void){}
