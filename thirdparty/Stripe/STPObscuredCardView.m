//
//  STPObscuredCardView.m
//  Stripe
//
//  Created by Jack Flintermann on 5/11/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPObscuredCardView.h"
#import "STPImageLibrary.h"
#import "STPImageLibrary+Private.h"
#import "STPLocalizationUtils.h"

@interface STPObscuredCardView()<UITextFieldDelegate>

@property(nonatomic, weak) UIImageView *brandImageView;
@property(nonatomic, weak) UITextField *last4Field;
@property(nonatomic, weak) UITextField *expField;
@property(nonatomic, weak) UITextField *cvcField;

@end

@implementation STPObscuredCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *cardImage = [STPImageLibrary unknownCardCardImage];
        UIImageView *brandImageView = [[UIImageView alloc] initWithImage:cardImage];
        brandImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:brandImageView];
        _brandImageView = brandImageView;
        
        UITextField *last4Field = [UITextField new];
        last4Field.delegate = self;
        last4Field.keyboardType = UIKeyboardTypePhonePad;
        [self addSubview:last4Field];
        _last4Field = last4Field;
        
        UITextField *expField = [UITextField new];
        expField.delegate = self;
        expField.keyboardType = UIKeyboardTypePhonePad;
        [self addSubview:expField];
        _expField = expField;
        
        UITextField *cvcField = [UITextField new];
        cvcField.delegate = self;
        cvcField.keyboardType = UIKeyboardTypePhonePad;
        cvcField.secureTextEntry = YES;
        [self addSubview:cvcField];
        _cvcField = cvcField;
        
        _theme = [STPTheme new];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.brandImageView.frame = CGRectMake(10, 2, self.brandImageView.image.size.width, self.bounds.size.height - 2);
    
    [self.last4Field sizeToFit];
    self.last4Field.frame = CGRectMake(CGRectGetMaxX(self.brandImageView.frame) + 8, 0, self.last4Field.frame.size.width + 20, self.bounds.size.height);
    
    [self.cvcField sizeToFit];
    CGRect cvcFrame = self.cvcField.frame;
    cvcFrame.size.width += 20;
    cvcFrame.origin.y = 0;
    cvcFrame.origin.x = CGRectGetMaxX(self.bounds) - cvcFrame.size.width;
    cvcFrame.size.height = CGRectGetHeight(self.bounds);
    self.cvcField.frame = cvcFrame;
    
    [self.expField sizeToFit];
    CGRect expFrame = self.expField.frame;
    expFrame.size.width += 20;
    self.expField.frame = expFrame;
    self.expField.center = CGPointMake(
                                       (CGRectGetMinX(cvcFrame) + CGRectGetMaxX(self.last4Field.frame)) / 2,
                                       self.bounds.size.height / 2
                                       );
    
}

- (void)setTheme:(STPTheme *)theme {
    _theme = theme;
    [self updateAppearance];
}

- (void)updateAppearance {
    self.backgroundColor = self.theme.secondaryBackgroundColor;
    self.last4Field.backgroundColor = [UIColor clearColor];
    self.last4Field.font = self.theme.font;
    self.last4Field.textColor = self.theme.primaryForegroundColor;
    
    self.expField.backgroundColor = [UIColor clearColor];
    self.expField.font = self.theme.font;
    self.expField.textColor = self.theme.primaryForegroundColor;
    
    self.cvcField.backgroundColor = [UIColor clearColor];
    self.cvcField.font = self.theme.font;
    self.cvcField.textColor = self.theme.primaryForegroundColor;
}

- (void)configureWithCard:(STPCard *)card {
    UIImage *image = [STPImageLibrary brandImageForCardBrand:card.brand];
    self.brandImageView.image = image;
    self.last4Field.text = card.last4;
    self.expField.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)card.expMonth, (unsigned long)(card.expYear % 100)];
    if (card.brand == STPCardBrandAmex) {
        self.cvcField.text = STPLocalizedString(@"XXXX", @"Placeholder text for Amex CVC field (4 digits)");
    } else {
        self.cvcField.text = STPLocalizedString(@"XXX", @"Placeholder text for non-Amex CVC field (3 digits)");
    }
    [self setNeedsLayout];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL deleting = (range.location == textField.text.length - 1 && range.length == 1 && [string isEqualToString:@""]);
    if (deleting) {
        [self clear];
    }
    return NO;
}

- (void)clear {
    self.last4Field.text = @"";
    self.expField.text = @"";
    [self.delegate obscuredCardViewDidClear:self];
}

- (BOOL)isEmpty {
    return self.last4Field.text.length == 0;
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
    _inputAccessoryView = inputAccessoryView;
    self.last4Field.inputAccessoryView = inputAccessoryView;
    self.expField.inputAccessoryView = inputAccessoryView;
    self.cvcField.inputAccessoryView = inputAccessoryView;
}

- (BOOL)becomeFirstResponder {
    return [self.cvcField becomeFirstResponder];
}

@end
