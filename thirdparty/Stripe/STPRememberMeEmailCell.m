//
//  STPRememberMeEmailCell.m
//  Stripe
//
//  Created by Jack Flintermann on 5/20/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPRememberMeEmailCell.h"
#import "STPAddress.h"

@interface STPRememberMeEmailCell()
@property(nonatomic, weak)STPPaymentActivityIndicatorView *activityIndicator;
@end

@implementation STPRememberMeEmailCell

- (instancetype)initWithDelegate:(id<STPAddressFieldTableViewCellDelegate>)delegate {
    return [super initWithType:STPAddressFieldTypeEmail contents:nil lastInList:NO delegate:delegate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat indicatorSize = 16.0f;
    CGFloat padding = 10.0f;
    self.activityIndicator.frame = CGRectMake(
                                              self.bounds.size.width - indicatorSize - padding,
                                              (self.bounds.size.height - indicatorSize) / 2,
                                              indicatorSize,
                                              indicatorSize
                                              );
    CGRect fieldRect = self.textField.frame;
    fieldRect.size.width -= (indicatorSize + padding * 2);
    self.textField.frame = fieldRect;
}

- (void)setTheme:(STPTheme *)theme {
    [super setTheme:theme];
    self.activityIndicator.tintColor = theme.accentColor;
}

- (STPPaymentActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        STPPaymentActivityIndicatorView *paymentIndicator = [[STPPaymentActivityIndicatorView alloc] init];
        [self addSubview:paymentIndicator];
        _activityIndicator = paymentIndicator;
    }
    return _activityIndicator;
}

@end
