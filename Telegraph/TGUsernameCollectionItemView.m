#import "TGUsernameCollectionItemView.h"

#import "TGFont.h"
#import "TGTextField.h"

#import "TGImageUtils.h"

@interface TGUsernameCollectionItemView () <UITextFieldDelegate>
{
    UILabel *_usernameLabel;
    UILabel *_prefixLabel;
    TGTextField *_textField;
    UIActivityIndicatorView *_activityIndicator;
    CGFloat _minimalInset;
}

@end

@implementation TGUsernameCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.backgroundColor = [UIColor clearColor];
        _usernameLabel.textColor = [UIColor blackColor];
        _usernameLabel.font = TGSystemFontOfSize(18.0f);
        [self.contentView addSubview:_usernameLabel];
        
        _prefixLabel = [[UILabel alloc] init];
        _prefixLabel.backgroundColor = [UIColor clearColor];
        _prefixLabel.textColor = [UIColor blackColor];
        _prefixLabel.font = TGSystemFontOfSize(18.0f);
        [self.contentView addSubview:_prefixLabel];
        
        _textField = [[TGTextField alloc] init];
        _textField.delegate = self;
        _textField.textColor = [UIColor blackColor];
        _textField.font = TGSystemFontOfSize(18.0f);
        _textField.leftInset = 20.0f;
        _textField.placeholderFont = _textField.font;
        _textField.placeholderColor = UIColorRGB(0xbfbfbf);
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.spellCheckingType = UITextSpellCheckingTypeNo;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.contentView addSubview:_textField];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidden = true;
        [self.contentView addSubview:_activityIndicator];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _usernameLabel.text = title;
    [_usernameLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _textField.placeholder = placeholder;
}

- (void)setPrefix:(NSString *)prefix
{
    _prefixLabel.text = prefix;
    [_prefixLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setSecureEntry:(bool)secureEntry
{
    _textField.secureTextEntry = secureEntry;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    _textField.keyboardType = keyboardType;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    _textField.returnKeyType = returnKeyType;
}

- (void)setUsername:(NSString *)username
{
    _textField.text = username;
}

- (void)setUsernameValid:(bool)usernameValid
{
    _textField.textColor = usernameValid ? [UIColor blackColor] : [UIColor redColor];
}

- (void)setUsernameChecking:(bool)usernameChecking
{
    if (usernameChecking)
    {
        _activityIndicator.hidden = false;
        [_activityIndicator startAnimating];
    }
    else
    {
        _activityIndicator.hidden = true;
        [_activityIndicator stopAnimating];
    }
}

- (void)setMinimalInset:(CGFloat)minimalInset {
    _minimalInset = minimalInset;
    [self setNeedsLayout];
}

- (void)setAutoCapitalize:(bool)autoCapitalize {
    if (autoCapitalize) {
        _textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    } else {
        _textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_usernameLabel.text.length != 0) {
        _usernameLabel.frame = (CGRect){{14.0f, CGFloor((self.contentView.frame.size.height - _usernameLabel.frame.size.height) / 2.0f)}, _usernameLabel.frame.size};
    } else {
        _usernameLabel.frame = (CGRect){{14.0f, CGFloor((self.contentView.frame.size.height - _usernameLabel.frame.size.height) / 2.0f)}, CGSizeMake(0.0f, _usernameLabel.frame.size.height)};
    }
    
    if (_prefixLabel.text.length != 0) {
        _prefixLabel.frame = (CGRect){{14.0f, CGFloor((self.contentView.frame.size.height - _prefixLabel.frame.size.height) / 2.0f) + TGRetinaPixel}, _prefixLabel.frame.size};
    } else {
        _prefixLabel.frame = (CGRect){{14.0f, CGFloor((self.contentView.frame.size.height - _prefixLabel.frame.size.height) / 2.0f)}, CGSizeMake(0.0f, _prefixLabel.frame.size.height)};
    }
    
    CGFloat textOffset = 14.0f;
    if (_usernameLabel.text.length != 0) {
        textOffset = CGRectGetMaxX(_usernameLabel.frame) + 2.0f;
        textOffset = MAX(_minimalInset, textOffset);
    } else if (_prefixLabel.text.length != 0) {
        textOffset = CGRectGetMaxX(_prefixLabel.frame) + 2.0f - 22.0f;
        textOffset = MAX(_minimalInset, textOffset);
    } else {
        textOffset = -5.0f;
    }
    
    _textField.frame = CGRectMake(textOffset, 0.0f, self.contentView.frame.size.width - 8.0f - 2.0f - textOffset, self.contentView.frame.size.height);
    _activityIndicator.frame = CGRectMake(self.contentView.frame.size.width - _activityIndicator.frame.size.width - 10.0f, CGFloor((self.contentView.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!_textField.secureTextEntry && [string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]].location != NSNotFound)
        return false;
    
    NSString *username = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (_usernameChanged)
        _usernameChanged(username);
    
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)__unused textField
{
    if (_returnPressed) {
        _returnPressed();
    }
    return false;
}

- (BOOL)becomeFirstResponder
{
    return [_textField becomeFirstResponder];
}

@end
