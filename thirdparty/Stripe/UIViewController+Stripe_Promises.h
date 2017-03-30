//
//  UIViewController+Stripe_Promises.h
//  Stripe
//
//  Created by Jack Flintermann on 5/20/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STPVoidPromise;

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Stripe_Promises)

@property(nonatomic, readonly)STPVoidPromise *stp_willAppearPromise;
@property(nonatomic, readonly)STPVoidPromise *stp_didAppearPromise;

@end

NS_ASSUME_NONNULL_END

void linkUIViewControllerPromisesCategory(void);
