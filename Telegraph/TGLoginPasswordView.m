#import "TGLoginPasswordView.h"

#import "TGTextField.h"

#import "TGImageUtils.h"
#import "TGFont.h"
#import "TGModernButton.h"

#import "TGViewController.h"

@interface TGLoginPasswordView () <UITextFieldDelegate>
{
    UIView *_grayBackground;
    UIView *_grayBackgroundSeparator;
    TGTextField *_passwordField;
    UIView *_passwordSeparatorView;
    UILabel *_titleLabel;
    UILabel *_helpLabel;
    TGModernButton *_forgotPasswordButton;
    TGModernButton *_resetButton;
}

@end

@implementation TGLoginPasswordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _grayBackground = [[UIView alloc] init];
        _grayBackground.backgroundColor = UIColorRGB(0xf2f2f2);
        [self addSubview:_grayBackground];
        
        _grayBackgroundSeparator = [[UIView alloc] init];
        _grayBackgroundSeparator.backgroundColor = TGSeparatorColor();
        [self addSubview:_grayBackgroundSeparator];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGIsPad() ? TGUltralightSystemFontOfSize(48.0f) : TGSystemFontOfSize(26.0f);
        _titleLabel.text = TGLocalized(@"LoginPassword.Title");
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
        
        _helpLabel = [[UILabel alloc] init];
        _helpLabel.backgroundColor = [UIColor clearColor];
        _helpLabel.textColor = [UIColor blackColor];
        _helpLabel.font = TGSystemFontOfSize(16.0f);
        _helpLabel.text = TGLocalized(@"LoginPassword.PasswordHelp");
        _helpLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _helpLabel.numberOfLines = 0;
        _helpLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_helpLabel];
        
        _passwordSeparatorView = [[UIView alloc] init];
        _passwordSeparatorView.backgroundColor = TGSeparatorColor();
        [self addSubview:_passwordSeparatorView];
        
        _passwordField = [[TGTextField alloc] init];
        _passwordField.font = TGSystemFontOfSize(18.0f);
        _passwordField.placeholderFont = _passwordField.font;
        _passwordField.placeholderColor = UIColorRGB(0x999999);
        _passwordField.backgroundColor = [UIColor clearColor];
        _passwordField.textAlignment = NSTextAlignmentLeft;
        _passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _passwordField.placeholder = TGLocalized(@"LoginPassword.PasswordPlaceholder");
        _passwordField.secureTextEntry = true;
        _passwordField.delegate = self;
        [self addSubview:_passwordField];
        
        _forgotPasswordButton = [[TGModernButton alloc] init];
        [_forgotPasswordButton setTitleColor:TGAccentColor()];
        [_forgotPasswordButton setTitle:TGLocalized(@"LoginPassword.ForgotPassword") forState:UIControlStateNormal];
        [_forgotPasswordButton setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        _forgotPasswordButton.titleLabel.font = TGSystemFontOfSize(16.0f);
        [self addSubview:_forgotPasswordButton];
        [_forgotPasswordButton addTarget:self action:@selector(forgotPasswordPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _resetButton = [[TGModernButton alloc] init];
        [_resetButton setTitleColor:TGDestructiveAccentColor()];
        [_resetButton setTitle:TGLocalized(@"LoginPassword.ResetAccount") forState:UIControlStateNormal];
        [_resetButton setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        _resetButton.titleLabel.font = TGSystemFontOfSize(16.0f);
        [self addSubview:_resetButton];
        _resetButton.hidden = true;
        [_resetButton addTarget:self action:@selector(resetPasswordPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setHint:(NSString *)hint
{
    _hint = hint;
    _passwordField.placeholder = hint;
}

- (void)setResetMode:(bool)resetMode
{
    _resetMode = resetMode;
    _helpLabel.hidden = resetMode;
    _resetButton.hidden = !resetMode;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat topOffset = 0.0f;
    CGFloat titleLabelOffset = 0.0f;
    CGFloat noticeLabelOffset = 0.0f;
    CGFloat sideInset = 0.0f;
    CGFloat hintOffset = 0.0f;
    CGFloat helpOffset = 0.0f;
    CGFloat buttonOffset = 0.0f;
    
    CGFloat resetFirstButtonOffset = 0.0f;
    CGFloat resetSecondButtonOffset = 0.0f;
    
    if (TGIsPad())
    {
        if (self.frame.size.width < self.frame.size.height)
        {
            topOffset = 305.0f;
            titleLabelOffset = topOffset - 108.0f;
        }
        else
        {
            topOffset = 135.0f;
            titleLabelOffset = topOffset - 78.0f;
        }
        
        noticeLabelOffset = topOffset + 143.0f;
        sideInset = 130.0f;
        hintOffset = 13.0f;
        helpOffset = 24.0f;
        buttonOffset = 0.0f;
        resetFirstButtonOffset = 24.0f;
        resetSecondButtonOffset = 6.0f;
    }
    else
    {
        topOffset = [TGViewController isWidescreen] ? 131.0f : 90.0f;
        titleLabelOffset = ([TGViewController isWidescreen] ? 66.0f : 48.0f) + 9.0f;
        noticeLabelOffset = [TGViewController isWidescreen] ? 274.0f : 214.0f;
        hintOffset = [TGViewController isWidescreen] ? 13.0f : 13.0f;
        helpOffset = [TGViewController isWidescreen] ? 24.0f : 24.0f;
        buttonOffset = [TGViewController isWidescreen] ? 0.0f : 0.0f;
        sideInset = 32.0f;
        resetFirstButtonOffset = 24.0f;
        resetSecondButtonOffset = 6.0f;
    }
    
    _grayBackground.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, topOffset);
    _grayBackgroundSeparator.frame = CGRectMake(0.0f, topOffset, self.frame.size.width, TGIsRetina() ? 0.5f : 1.0f);
    
    _titleLabel.frame = CGRectMake(CGFloor((self.frame.size.width - _titleLabel.frame.size.width) / 2), titleLabelOffset, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    _passwordSeparatorView.frame = CGRectMake(sideInset, _grayBackgroundSeparator.frame.origin.y + 60.0f, self.frame.size.width - sideInset * 2.0f, TGIsRetina() ? 0.5f : 1.0f);
    
    _passwordField.frame = CGRectMake(sideInset, _passwordSeparatorView.frame.origin.y - 46.0f, self.frame.size.width - sideInset * 2.0f, 56.0f);
    
    CGSize helpSize = [_helpLabel.text sizeWithFont:_helpLabel.font constrainedToSize:CGSizeMake(250.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    helpSize.width = CGCeil(helpSize.width);
    helpSize.height = CGCeil(helpSize.height);
    _helpLabel.frame = CGRectMake(CGFloor((self.frame.size.width - helpSize.width) / 2.0f), CGRectGetMaxY(_passwordSeparatorView.frame) + helpOffset, helpSize.width, helpSize.height);
    
    [_forgotPasswordButton sizeToFit];
    _forgotPasswordButton.frame = CGRectMake(CGFloor((self.frame.size.width - _forgotPasswordButton.frame.size.width) / 2.0f), (_resetMode ? CGRectGetMaxY(_passwordSeparatorView.frame) : CGRectGetMaxY(_helpLabel.frame)) + (_resetMode ? resetFirstButtonOffset : buttonOffset), _forgotPasswordButton.frame.size.width, _forgotPasswordButton.frame.size.height);
    
    [_resetButton sizeToFit];
    _resetButton.frame = CGRectMake(CGFloor((self.frame.size.width - _resetButton.frame.size.width) / 2.0f), CGRectGetMaxY(_forgotPasswordButton.frame) + resetSecondButtonOffset, _resetButton.frame.size.width, _resetButton.frame.size.height);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (_passwordChanged)
        _passwordChanged(text);
    
    return true;
}

- (void)forgotPasswordPressed
{
    if (_forgotPassword)
        _forgotPassword();
}

- (void)resetPasswordPressed
{
    if (_resetPassword)
        _resetPassword();
}

- (void)setFirstReponder
{
    [_passwordField becomeFirstResponder];
}

- (void)clearFirstResponder
{
    [_passwordField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length != 0)
    {
        if (_checkPassword)
            _checkPassword();
    }
    return false;
}

@end
