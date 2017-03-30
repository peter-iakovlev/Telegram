//
//  STPRememberMePaymentCell.m
//  Stripe
//
//  Created by Jack Flintermann on 6/16/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPRememberMePaymentCell.h"

@interface STPRememberMePaymentCell()<STPObscuredCardViewDelegate>

@property(nonatomic, weak)STPPaymentCardTextField *paymentField;
@property(nonatomic, weak)STPObscuredCardView *obscuredCardView;

@end

@implementation STPRememberMePaymentCell

- (instancetype)init {
    self = [super init];
    if (self) {
        STPPaymentCardTextField *paymentField = [[STPPaymentCardTextField alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:paymentField];
        _paymentField = paymentField;
        
        STPObscuredCardView *obscuredView = [[STPObscuredCardView alloc] initWithFrame:self.bounds];
        obscuredView.hidden = YES;
        obscuredView.delegate = self;
        [self.contentView addSubview:obscuredView];
        _obscuredCardView = obscuredView;
        _theme = [STPTheme defaultTheme];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.paymentField.frame = self.bounds;
    self.obscuredCardView.frame = self.bounds;
}

- (void)setTheme:(STPTheme *)theme {
    _theme = theme;
    [self updateAppearance];
}

- (void)updateAppearance {
    self.paymentField.backgroundColor = [UIColor clearColor];
    self.paymentField.placeholderColor = self.theme.tertiaryForegroundColor;
    self.paymentField.borderColor = [UIColor clearColor];
    self.paymentField.textColor = self.theme.primaryForegroundColor;
    self.paymentField.textErrorColor = self.theme.errorColor;
    self.paymentField.font = self.theme.font;
    self.obscuredCardView.theme = self.theme;
    self.backgroundColor = self.theme.secondaryBackgroundColor;
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
    _inputAccessoryView = inputAccessoryView;
    self.paymentField.inputAccessoryView = inputAccessoryView;
    self.obscuredCardView.inputAccessoryView = inputAccessoryView;
}

- (BOOL)isEmpty {
    return self.paymentField.cardNumber.length == 0 && self.obscuredCardView.isEmpty;
}

- (void)configureWithCard:(STPCard *)card {
    [self.paymentField clear];
    self.obscuredCardView.hidden = NO;
    [self.obscuredCardView configureWithCard:card];
}

- (BOOL)becomeFirstResponder {
    if (self.obscuredCardView.hidden) {
        return [self.paymentField becomeFirstResponder];
    } else {
        return [self.obscuredCardView becomeFirstResponder];
    }
}

- (void)obscuredCardViewDidClear:(__unused STPObscuredCardView *)cardView {
    self.obscuredCardView.hidden = YES;
    [self.paymentField becomeFirstResponder];
    [self.delegate paymentCellDidClear:self];
}

- (void)clear {
    [self.obscuredCardView clear];
}

@end
