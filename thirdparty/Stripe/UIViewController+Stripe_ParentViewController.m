//
//  UIViewController+Stripe_ParentViewController.m
//  Stripe
//
//  Created by Jack Flintermann on 1/12/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "UIViewController+Stripe_ParentViewController.h"

@implementation UIViewController (Stripe_ParentViewController)

- (nullable UIViewController *)stp_parentViewControllerOfClass:(nonnull Class)klass {
    if ([self.parentViewController isKindOfClass:klass]) {
        return self.parentViewController;
    }
    return [self.parentViewController stp_parentViewControllerOfClass:klass];
}

- (BOOL)stp_isTopNavigationController {
    return self.navigationController.topViewController == self;
}

- (BOOL)stp_isAtRootOfNavigationController {
    UIViewController *viewController = self.navigationController.viewControllers.firstObject;
    UIViewController *tested = self;
    while (tested) {
        if (tested == viewController) {
            return YES;
        }
        tested = [tested parentViewController];
    }
    return NO;
}

- (nullable UIViewController *)stp_previousViewControllerInNavigation {
    NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
    if (index == NSNotFound || index <= 0) {
        return nil;
    }
    return self.navigationController.viewControllers[index - 1];
}

@end

void linkUIViewControllerParentViewControllerCategory(void){}
