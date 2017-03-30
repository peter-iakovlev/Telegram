//
//  STPAddCardViewController+Private.h
//  Stripe
//
//  Created by Jack Flintermann on 6/29/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPAddCardViewController.h"

@class STPPaymentConfiguration, STPTheme;

@interface STPAddCardViewController (Private)

- (void)commonInitWithConfiguration:(STPPaymentConfiguration *)configuration
                              theme:(STPTheme *)theme;

@end
