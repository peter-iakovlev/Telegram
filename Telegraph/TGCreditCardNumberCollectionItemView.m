#import "TGCreditCardNumberCollectionItemView.h"

#import "Stripe.h"

#import "TGPresentation.h"

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

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _cardField.textColor = presentation.pallete.collectionMenuTextColor;
    _cardField.placeholderColor = presentation.pallete.collectionMenuPlaceholderColor;
    _cardField.textErrorColor = presentation.pallete.collectionMenuDestructiveColor;
    _cardField.keyboardAppearance = presentation.pallete.isDark ? UIKeyboardAppearanceAlert : UIKeyboardAppearanceDefault;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _cardField.frame = CGRectInset(self.bounds, -5.0f + self.safeAreaInset.left, 0.0f);
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
