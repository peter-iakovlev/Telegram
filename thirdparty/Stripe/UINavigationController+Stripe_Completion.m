//
//  UINavigationController+Stripe_Completion.m
//  Stripe
//
//  Created by Jack Flintermann on 3/23/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "UINavigationController+Stripe_Completion.h"

// See http://stackoverflow.com/questions/9906966/completion-handler-for-uinavigationcontroller-pushviewcontrolleranimated/33767837#33767837 for some discussion around why using CATransaction is unreliable here.

@implementation UINavigationController (Stripe_Completion)

- (void)stp_pushViewController:(UIViewController *)viewController
                      animated:(BOOL)animated
                    completion:(STPVoidBlock)completion {
    [self pushViewController:viewController animated:animated];
    if (!completion) {
        return;
    }
    if (self.transitionCoordinator && animated) {
        [self.transitionCoordinator animateAlongsideTransition:nil completion:^(__unused id<UIViewControllerTransitionCoordinatorContext> context) {
            completion();
        }];
    } else {
        completion();
    }
}

- (void)stp_popViewControllerAnimated:(BOOL)animated
                           completion:(STPVoidBlock)completion {
    [self popViewControllerAnimated:animated];
    if (!completion) {
        return;
    }
    if (self.transitionCoordinator && animated) {
        [self.transitionCoordinator animateAlongsideTransition:nil completion:^(__unused id<UIViewControllerTransitionCoordinatorContext> context) {
            completion();
        }];
    } else {
        completion();
    }
}

- (void)stp_popToViewController:(UIViewController *)viewController
                       animated:(BOOL)animated
                     completion:(STPVoidBlock)completion {
    [self popToViewController:viewController animated:animated];
    if (!completion) {
        return;
    }
    if (self.transitionCoordinator && animated) {
        [self.transitionCoordinator animateAlongsideTransition:nil completion:^(__unused id<UIViewControllerTransitionCoordinatorContext> context) {
            completion();
        }];
    } else {
        completion();
    }
}

@end

void linkUINavigationControllerCompletionCategory(void){}
