//
//  UIToolbar+Stripe_InputAccessory.m
//  Stripe
//
//  Created by Jack Flintermann on 4/22/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "UIToolbar+Stripe_InputAccessory.h"
#import "STPLocalizationUtils.h"

@implementation UIToolbar (Stripe_InputAccessory)

+ (instancetype)stp_inputAccessoryToolbarWithTarget:(id)target action:(SEL)action {
    UIToolbar *toolbar = [self new];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:STPLocalizedString(@"Next", @"Button to move to the next text entry field") style:UIBarButtonItemStyleDone target:target action:action];
    toolbar.items = @[flexibleItem, nextItem];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return toolbar;
}

- (void)stp_setEnabled:(BOOL)enabled {
    for (UIBarButtonItem *barButtonItem in self.items) {
        barButtonItem.enabled = enabled;
    }
}

@end

void linkUIToolbarInputAccessoryCategory(void){}
