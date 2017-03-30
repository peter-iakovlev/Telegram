//
//  UITableViewCell+Stripe_Borders.h
//  Stripe
//
//  Created by Jack Flintermann on 5/16/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Stripe_Borders)

- (void)stp_setBorderColor:(UIColor *)color;
- (void)stp_setTopBorderHidden:(BOOL)hidden;
- (void)stp_setBottomBorderHidden:(BOOL)hidden;
- (void)stp_setFakeSeparatorLeftInset:(CGFloat)leftInset;
- (void)stp_setFakeSeparatorColor:(UIColor *)color;

@end

void linkUITableViewCellBordersCategory(void);
