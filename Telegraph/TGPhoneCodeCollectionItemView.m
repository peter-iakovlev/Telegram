#import "TGPhoneCodeCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGTextField.h>

#import "TGPresentation.h"

@interface TGPhoneCodeCollectionItemView () <UITextFieldDelegate>
{
    TGTextField *_textField;
}

@end

@implementation TGPhoneCodeCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _textField = [[TGTextField alloc] init];
        _textField.font = TGSystemFontOfSize(17.0f);
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.textColor = [UIColor blackColor];
        _textField.placeholder = TGLocalized(@"ChangePhoneNumberCode.CodePlaceholder");
        _textField.placeholderFont = _textField.font;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.delegate = self;
        [self addSubview:_textField];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _textField.textColor = presentation.pallete.collectionMenuTextColor;
    _textField.placeholderColor = presentation.pallete.collectionMenuPlaceholderColor;
    _textField.keyboardAppearance = presentation.pallete.isDark ? UIKeyboardAppearanceAlert : UIKeyboardAppearanceDefault;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _textField.frame = (CGRect){{0.0f, 0.0f}, {self.frame.size.width, self.frame.size.height}};
}

- (void)resignCodeFieldFirstResponder
{
    [_textField resignFirstResponder];
}

- (void)makeCodeFieldFirstResponder
{
    [_textField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    for (NSUInteger i = 0; i < string.length; i++)
    {
        unichar c = [string characterAtIndex:i];
        if (c < '0' || c > '9')
            return false;
    }
    
    NSString *code = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (_codeChanged)
        _codeChanged(code);
    
    return true;
}

@end
