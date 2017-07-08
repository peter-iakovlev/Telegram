#import "TGLoginPasswordView.h"

#import "TGTextField.h"

#import "TGImageUtils.h"
#import "TGFont.h"
#import "TGModernButton.h"

#import "TGViewController.h"

@interface TGLoginPasswordView () <UITextFieldDelegate>
{
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
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGIsPad() ? TGUltralightSystemFontOfSize(48.0f) : TGLightSystemFontOfSize(30.0f);
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
    
    CGSize screenSize = CGSizeZero;
    screenSize = [TGViewController screenSize:(self.frame.size.width < self.frame.size.height) ? UIDeviceOrientationPortrait : UIDeviceOrientationLandscapeLeft];
    
    CGFloat topOffset = 0.0f;
    CGFloat titleLabelOffset = 0.0f;
    CGFloat noticeLabelOffset = 0.0f;
    CGFloat sideInset = 0.0f;
    CGFloat hintOffset = 0.0f;
    CGFloat helpOffset = 0.0f;
    CGFloat buttonOffset = 0.0f;
    
    CGFloat resetFirstButtonOffset = 0.0f;
    CGFloat resetSecondButtonOffset = 0.0f;
    
    CGFloat didNotReceiveCodeOffset = 0.0f;
    CGFloat timeoutOffset = 0.0f;
    
    if (TGIsPad())
    {
        if (screenSize.width < screenSize.height)
        {
            titleLabelOffset = 94.0f;
            noticeLabelOffset = 175.0f;
            topOffset = 310.0f;
            
            didNotReceiveCodeOffset = 660.0f;
            timeoutOffset = 660.0f;
        }
        else
        {
            titleLabelOffset = 54.0f;
            noticeLabelOffset = 125.0f;
            topOffset = 180.0f;
            
            didNotReceiveCodeOffset = 320.0f;
            timeoutOffset = 320.0f;
        }
        
        sideInset = 130.0f;
        resetFirstButtonOffset = 24.0f;
        resetSecondButtonOffset = 6.0f;
        
        if (_resetMode) {
            topOffset -= 40.0f;
            didNotReceiveCodeOffset -= 35.0f;
        }
    }
    else
    {
        topOffset = [TGViewController isWidescreen] ? 131.0f : 90.0f;
        titleLabelOffset = ([TGViewController isWidescreen] ? 71.0f : 48.0f) + 9.0f;
        noticeLabelOffset = 100.0f;
        topOffset = 120.0f;
        
        if (screenSize.height < 481.0f) {
            titleLabelOffset = 52.0f;
            noticeLabelOffset = 95.0f;
            topOffset = 138.0f;
            didNotReceiveCodeOffset = 215.0f;
            timeoutOffset = 215.0f;
            if (_resetMode) {
                topOffset -= 35.0f;
                didNotReceiveCodeOffset -= 35.0f;
            }
        } else if (screenSize.height < 569.0f) {
            titleLabelOffset = 68.0f;
            noticeLabelOffset = 115.0f;
            topOffset = 170.0f;
            didNotReceiveCodeOffset = 300.0f;
            timeoutOffset = 290.0f;
            if (_resetMode) {
                topOffset -= 35.0f;
                didNotReceiveCodeOffset -= 35.0f;
            }
        } else if (screenSize.height < 668.0f) {
            titleLabelOffset = 74.0f;
            noticeLabelOffset = 135.0f;
            topOffset = 220.0f;
            didNotReceiveCodeOffset = 388.0f;
            timeoutOffset = 388.0f;
            if (_resetMode) {
                topOffset -= 40.0f;
                didNotReceiveCodeOffset -= 35.0f;
            }
        } else {
            titleLabelOffset = 84.0f;
            noticeLabelOffset = 145.0f;
            topOffset = 260.0f;
            didNotReceiveCodeOffset = 460.0f;
            timeoutOffset = 460.0f;
            if (_resetMode) {
                topOffset -= 35.0f;
                didNotReceiveCodeOffset -= 35.0f;
            }
        }
        resetFirstButtonOffset = 24.0f;
        resetSecondButtonOffset = 6.0f;
        sideInset = 32.0f;
    }
    
    /*if (TGIsPad())
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
    }*/
    
    _titleLabel.frame = CGRectMake(CGFloor((self.frame.size.width - _titleLabel.frame.size.width) / 2), titleLabelOffset, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    _passwordSeparatorView.frame = CGRectMake(sideInset, topOffset + 60.0f, self.frame.size.width - sideInset * 2.0f, TGScreenPixel);
    
    _passwordField.frame = CGRectMake(sideInset, _passwordSeparatorView.frame.origin.y - 46.0f, self.frame.size.width - sideInset * 2.0f, 56.0f);
    
    CGSize helpSize = [_helpLabel.text sizeWithFont:_helpLabel.font constrainedToSize:CGSizeMake(250.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    helpSize.width = CGCeil(helpSize.width);
    helpSize.height = CGCeil(helpSize.height);
    _helpLabel.frame = CGRectMake(CGFloor((self.frame.size.width - helpSize.width) / 2.0f), noticeLabelOffset, helpSize.width, helpSize.height);
    
    [_forgotPasswordButton sizeToFit];
    _forgotPasswordButton.frame = CGRectMake(CGFloor((self.frame.size.width - _forgotPasswordButton.frame.size.width) / 2.0f), _resetMode ? (didNotReceiveCodeOffset - resetSecondButtonOffset) : didNotReceiveCodeOffset, _forgotPasswordButton.frame.size.width, _forgotPasswordButton.frame.size.height);
    
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
