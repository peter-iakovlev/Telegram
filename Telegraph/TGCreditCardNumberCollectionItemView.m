#import "TGCreditCardNumberCollectionItemView.h"

#import "Stripe.h"

@interface TGCreditCardNumberCollectionItemView () <STPPaymentCardTextFieldDelegate> {
    STPPaymentCardTextField *_cardField;
}

@end

@implementation TGCreditCardNumberCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _cardField = [[STPPaymentCardTextField alloc] init];
        _cardField.borderColor = [UIColor clearColor];
        _cardField.delegate = self;
        _cardField.placeholderColor = UIColorRGB(0xbfbfbf);
        _cardField.borderWidth = 0.0f;
        [self.contentView addSubview:_cardField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _cardField.frame = CGRectInset(self.bounds, -5.0f, 0.0f);
}

- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    if (textField.valid) {
        if (_cardChanged) {
            _cardChanged(textField.cardParams);
        }
    } else {
        if (_cardChanged) {
            _cardChanged(nil);
        }
    }
}

- (void)focusInput {
    [_cardField becomeFirstResponder];
}

@end
