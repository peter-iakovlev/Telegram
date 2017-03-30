//
//  UITableViewCell+Stripe_Borders.m
//  Stripe
//
//  Created by Jack Flintermann on 5/16/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "UITableViewCell+Stripe_Borders.h"

static NSInteger const STPTableViewCellTopBorderTag = 787473;
static NSInteger const STPTableViewCellBottomBorderTag = 787474;
static NSInteger const STPTableViewCellFakeSeparatorTag = 787475;

@implementation UITableViewCell (Stripe_Borders)

- (UIView *)stp_topBorderView {
    UIView *view = [self.contentView viewWithTag:STPTableViewCellTopBorderTag];
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5f)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        view.tag = STPTableViewCellTopBorderTag;
        view.backgroundColor = self.backgroundColor;
        view.hidden = YES;
        view.accessibilityIdentifier = @"stp_topBorderView";
        [self.contentView addSubview:view];
    }
    return view;
}

- (UIView *)stp_bottomBorderView {
    UIView *view = [self.contentView viewWithTag:STPTableViewCellBottomBorderTag];
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 0.5f, self.bounds.size.width, 0.5f)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        view.tag = STPTableViewCellBottomBorderTag;
        view.backgroundColor = self.backgroundColor;
        view.hidden = YES;
        view.accessibilityIdentifier = @"stp_bottomBorderView";
        [self.contentView addSubview:view];
    }
    return view;
}

- (UIView *)stp_fakeSeparatorView {
    UIView *view = [self.contentView viewWithTag:STPTableViewCellFakeSeparatorTag];
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 0.5f, self.bounds.size.width, 0.5f)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        view.tag = STPTableViewCellFakeSeparatorTag;
        view.backgroundColor = self.backgroundColor;
        view.accessibilityIdentifier = @"stp_fakeSeparatorView";
        [self.contentView addSubview:view];
    }
    return view;
}

- (void)stp_setBorderColor:(UIColor *)color {
    [self stp_topBorderView].backgroundColor = color;
    [self stp_bottomBorderView].backgroundColor = color;
}

- (void)stp_setTopBorderHidden:(BOOL)hidden {
    [self stp_topBorderView].hidden = hidden;
}

- (void)stp_setBottomBorderHidden:(BOOL)hidden {
    [self stp_bottomBorderView].hidden = hidden;
    [self stp_fakeSeparatorView].hidden = !hidden;
}

- (void)stp_setFakeSeparatorColor:(UIColor *)color {
    [self stp_fakeSeparatorView].backgroundColor = color;
}

- (void)stp_setFakeSeparatorLeftInset:(CGFloat)leftInset {
    [self stp_fakeSeparatorView].frame = CGRectMake(leftInset, self.bounds.size.height - 0.5f, self.bounds.size.width - leftInset, 0.5f);
}

@end

void linkUITableViewCellBordersCategory(void) {}
