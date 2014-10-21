#import "TGUsernameCollectionItemView.h"

#import "TGFont.h"
#import "TGTextField.h"

@interface TGUsernameCollectionItemView () <UITextFieldDelegate>
{
    UILabel *_usernameLabel;
    TGTextField *_textField;
    UIActivityIndicatorView *_activityIndicator;
}

@end

@implementation TGUsernameCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.text = TGLocalized(@"Settings.Username");
        _usernameLabel.backgroundColor = [UIColor clearColor];
        _usernameLabel.textColor = [UIColor blackColor];
        _usernameLabel.font = TGSystemFontOfSize(18.0f);
        [_usernameLabel sizeToFit];
        [self.contentView addSubview:_usernameLabel];
        
        _textField = [[TGTextField alloc] init];
        _textField.delegate = self;
        _textField.textColor = [UIColor blackColor];
        _textField.font = TGSystemFontOfSize(18.0f);
        _textField.leftInset = 20.0f;
        _textField.placeholder = TGLocalized(@"Username.Placeholder");
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _usernameLabel.frame = (CGRect){{14.0f, CGFloor((self.contentView.frame.size.height - _usernameLabel.frame.size.height) / 2.0f)}, _usernameLabel.frame.size};
    
    _textField.frame = CGRectMake(CGRectGetMaxX(_usernameLabel.frame) + 2.0f, 0.0f, self.contentView.frame.size.width - 8.0f - 2.0f - CGRectGetMaxX(_usernameLabel.frame), self.contentView.frame.size.height);
    _activityIndicator.frame = CGRectMake(self.contentView.frame.size.width - _activityIndicator.frame.size.width - 10.0f, CGFloor((self.contentView.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *username = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (_usernameChanged)
        _usernameChanged(username);
    
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)__unused textField
{
    return false;
}

@end
