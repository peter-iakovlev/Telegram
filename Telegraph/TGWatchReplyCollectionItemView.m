#import "TGWatchReplyCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGTextField.h>

@interface TGWatchReplyCollectionItemView () <UITextFieldDelegate>
{
    TGTextField *_textField;
}
@end

@implementation TGWatchReplyCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _textField = [[TGTextField alloc] init];
        _textField.delegate = self;
        _textField.textColor = [UIColor blackColor];
        _textField.font = TGSystemFontOfSize(18.0f);
        _textField.leftInset = 0.0f;
        _textField.placeholderFont = _textField.font;
        _textField.placeholderColor = UIColorRGB(0xbfbfbf);
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.spellCheckingType = UITextSpellCheckingTypeNo;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.contentView addSubview:_textField];
    }
    return self;
}

- (void)setValue:(NSString *)value
{
    _textField.text = value;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _textField.placeholder = placeholder;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat textOffset = 14.0f;
    _textField.frame = CGRectMake(textOffset + self.safeAreaInset.left, 0.0f, self.contentView.frame.size.width - 8.0f - 2.0f - textOffset - self.safeAreaInset.left - self.safeAreaInset.right, self.contentView.frame.size.height);
}

- (void)becomeFirstResponder
{
    [_textField becomeFirstResponder];
}

- (void)resignFirstResponder
{
    [_textField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *value = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (_valueChanged != nil)
        _valueChanged(value);
    
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)__unused textField
{
    if (self.inputReturned != nil)
        self.inputReturned();
    
    return false;
}

@end
