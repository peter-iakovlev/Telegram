//
//  UINavigationController+Stripe_Completion.h
//  Stripe
//
//  Created by Jack Flintermann on 3/23/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPBlocks.h"

@interface UINavigationController (Stripe_Completion)

- (void)stp_pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                completion:(STPVoidBlock)completion;

- (void)stp_popViewControllerAnimated:(BOOL)animated
                           completion:(STPVoidBlock)completion;

- (void)stp_popToViewController:(UIViewController *)viewController
                       animated:(BOOL)animated
                     completion:(STPVoidBlock)completion;

@end

void linkUINavigationControllerCompletionCategory(void);
