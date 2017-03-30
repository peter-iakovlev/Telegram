//
//  UIToolbar+Stripe_InputAccessory.h
//  Stripe
//
//  Created by Jack Flintermann on 4/22/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIToolbar (Stripe_InputAccessory)

+ (instancetype)stp_inputAccessoryToolbarWithTarget:(id)target action:(SEL)action;
- (void)stp_setEnabled:(BOOL)enabled;

@end

void linkUIToolbarInputAccessoryCategory(void);
