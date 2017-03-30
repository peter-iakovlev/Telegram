//
//  STPPaymentMethodTableViewCell.h
//  Stripe
//
//  Created by Ben Guo on 8/30/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPPaymentMethod.h"
#import "STPTheme.h"

@interface STPPaymentMethodTableViewCell : UITableViewCell

- (void)configureWithPaymentMethod:(id<STPPaymentMethod>)paymentMethod theme:(STPTheme *)theme;
- (void)configureForNewCardRowWithTheme:(STPTheme *)theme;

@end
