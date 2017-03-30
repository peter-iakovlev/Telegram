//
//  UIViewController+Stripe_NavigationItemProxy.h
//  Stripe
//
//  Created by Jack Flintermann on 6/9/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Stripe_NavigationItemProxy)

@property(nonatomic)UINavigationItem *stp_navigationItemProxy;

@end

void linkUIViewControllerNavigationItemProxyCategory(void);
