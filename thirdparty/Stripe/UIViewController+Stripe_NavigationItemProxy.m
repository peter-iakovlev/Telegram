//
//  UIViewController+Stripe_NavigationItemProxy.m
//  Stripe
//
//  Created by Jack Flintermann on 6/9/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "UIViewController+Stripe_NavigationItemProxy.h"
#import <objc/runtime.h>

static char kSTPNavigationItemProxyKey;

@implementation UIViewController (Stripe_NavigationItemProxy)

- (void)setStp_navigationItemProxy:(UINavigationItem *)stp_navigationItemProxy {
    objc_setAssociatedObject(self, &kSTPNavigationItemProxyKey, stp_navigationItemProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.navigationItem.leftBarButtonItem) {
        stp_navigationItemProxy.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
    }
    if (self.navigationItem.rightBarButtonItem) {
        stp_navigationItemProxy.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    }
    if (self.navigationItem.title) {
        stp_navigationItemProxy.title = self.navigationItem.title;
    }
}

- (UINavigationItem *)stp_navigationItemProxy {
    return objc_getAssociatedObject(self, &kSTPNavigationItemProxyKey) ?: self.navigationItem;
}

@end

void linkUIViewControllerNavigationItemProxyCategory(void){}
