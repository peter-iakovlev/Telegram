#import "TGSharePasscodeView.h"

#import <LegacyDatabase/LegacyDatabase.h>

#import <LocalAuthentication/LocalAuthentication.h>

@interface TGSharePasscodeView () <UITextFieldDelegate>
{
    bool _simpleMode;
    void (^_cancel)();
    TGSharePasscodeViewVerifyBlock _verify;
    
    UINavigationBar *_navigationBar;
    UINavigationItem *_navigationItem;
    UIBarButtonItem *_cancelItem;
    UIBarButtonItem *_nextItem;
    
    UILabel *_titleLabel;
    UITextField *_textField;
    UIView *_textFieldBackground;
    
    id _keyboardObserver;
    CGFloat _keyboardHeight;
    
    __weak UIViewController *_alertPresentationController;
    
    bool _allowTouchId;
    bool _usingTouchId;
    bool _alternativeMethodSelected;
}

@end

@implementation TGSharePasscodeView

- (instancetype)initWithSimpleMode:(bool)simpleMode cancel:(void (^)())cancel verify:(TGSharePasscodeViewVerifyBlock)verify alertPresentationController:(UIViewController *)alertPresentationController allowTouchId:(bool)allowTouchId
{
    self = [super init];
    if (self != nil)
    {
        _simpleMode = simpleMode;
        _cancel = [cancel copy];
        _verify = [verify copy];
        _alertPresentationController = alertPresentationController;
        
        _allowTouchId = allowTouchId;
        
        self.backgroundColor = TGColorWithHex(0xefeff4);
        
        _navigationBar = [[UINavigationBar alloc] init];
        _navigationBar.shadowImage = [[UIImage alloc] init];
        _navigationBar.translucent = false;
        _navigationItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Share.PasscodeTitle", nil)];
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share.Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
        _nextItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share.Next", nil) style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
        [_navigationItem setLeftBarButtonItem:_cancelItem];
        if (!_simpleMode)
            [_navigationItem setRightBarButtonItem:_nextItem];
        [_navigationBar pushNavigationItem:_navigationItem animated:false];
        [self addSubview:_navigationBar];
        _nextItem.enabled = false;
        
        _textFieldBackground = [[UIView alloc] init];
        _textFieldBackground.backgroundColor = [UIColor whiteColor];
        UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.5f)];
        topSeparator.backgroundColor = TGColorWithHex(0xc8c7cc);
        topSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_textFieldBackground addSubview:topSeparator];
        UIView *bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -0.5f, 0.0f, 0.5f)];
        bottomSeparator.backgroundColor = TGColorWithHex(0xc8c7cc);
        bottomSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [_textFieldBackground addSubview:bottomSeparator];
        [self addSubview:_textFieldBackground];
        
        _textField = [[UITextField alloc] init];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.font = [UIFont systemFontOfSize:16.0f];
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textField.secureTextEntry = true;
        _textField.keyboardType = _simpleMode ? UIKeyboardTypeDecimalPad : UIKeyboardTypeDefault;
        _textField.textAlignment = _simpleMode ? NSTextAlignmentCenter : NSTextAlignmentLeft;
        _textField.delegate = self;
        [self addSubview:_textField];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.text = NSLocalizedString(@"Share.EnterPasscode", nil);
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
        
        __weak TGSharePasscodeView *weakSelf = self;
        _keyboardObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
        {
            __strong TGSharePasscodeView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                CGRect keyboardFrame = [(NSValue *)notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
                CGFloat keyboardHeight = MAX(0.0f, [UIScreen mainScreen].bounds.size.height - keyboardFrame.origin.y);
                strongSelf->_keyboardHeight = keyboardHeight;
                [self layoutSubviews];
            }
        }];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_keyboardObserver];
}

- (void)showKeyboard
{
    [_textField becomeFirstResponder];
}

- (void)nextPressed
{
    if (_verify)
    {
        __weak TGSharePasscodeView *weakSelf = self;
        _verify(_textField.text, ^(bool result)
        {
            if (!result)
            {
                __strong TGSharePasscodeView *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf showInvalidPasscodeAlert];
            }
        });
    }
}

- (void)cancelPressed
{
    if (_cancel)
        _cancel();
}

- (BOOL)textField:(UITextField *)__unused textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_simpleMode && [_textField.text stringByReplacingCharactersInRange:range withString:string].length > 4)
        return false;
    
    return true;
}

- (void)textFieldDidChange:(UITextField *)__unused textField
{
    if (_simpleMode)
    {
        if (_textField.text.length == 4)
        {
            if (_verify)
            {
                __weak TGSharePasscodeView *weakSelf = self;
                _verify(_textField.text, ^(bool result)
                {
                    if (!result)
                    {
                        __strong TGSharePasscodeView *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf showInvalidPasscodeAlert];
                    }
                });
            }
        }
    }
    
    _nextItem.enabled = _textField.text.length != 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)__unused textField
{
    if (_verify)
    {
        __weak TGSharePasscodeView *weakSelf = self;
        _verify(_textField.text, ^(bool result)
        {
            if (!result)
            {
                __strong TGSharePasscodeView *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf showInvalidPasscodeAlert];
            }
        });
    }
    
    return false;
}

- (void)showInvalidPasscodeAlert
{
    UIViewController *alertPresentationController = _alertPresentationController;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Share.ErrorInvalidPasscode", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Share.OK", nil) style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action)
    {
    }]];
    [alertPresentationController presentViewController:alertController animated:true completion:nil];
}

- (bool)supportsTouchId
{
    return [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
}

- (void)refreshTouchId
{
    [self resignFirstResponder];
    [self becomeFirstResponder];
    
    if (!_usingTouchId && !_alternativeMethodSelected && _allowTouchId && [self supportsTouchId])
    {
        LAContext *context = [[LAContext alloc] init];
        
        NSError *error = nil;
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error])
        {
            _usingTouchId = true;
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"Share.TouchId", nil) reply:^(BOOL success, NSError *error)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    if (error != nil)
                    {
                        _usingTouchId = false;
                        _alternativeMethodSelected = true;
                    }
                    else
                    {
                        if (success)
                        {
                            _usingTouchId = false;
                            //
                        }
                        else
                        {
                            _usingTouchId = false;
                        }
                    }
                });
            }];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _navigationBar.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 20.0f + 44.0f);
    
    CGFloat contentHeight = self.frame.size.height - _navigationBar.frame.size.height - _keyboardHeight;
    
    CGFloat textFieldHeight = 44.0f;
    CGFloat textFieldInset = 8.0f;
    
    CGFloat topOffset = 0.0f;
    if (contentHeight > 320.0f)
    {
        topOffset = (CGFloat)floor((contentHeight - textFieldHeight) / 2.0f) + _navigationBar.frame.size.height;
    }
    else
    {
        topOffset = (CGFloat)floor((contentHeight - textFieldHeight - 80.0f) / 2.0f) + _navigationBar.frame.size.height + 40.0f;
    }
    
    _textFieldBackground.frame = CGRectMake(0.0f, topOffset, self.frame.size.width, textFieldHeight);
    _textField.frame = CGRectMake(textFieldInset, topOffset, self.frame.size.width - textFieldInset * 2.0f, textFieldHeight);
    
    _titleLabel.frame = CGRectMake((CGFloat)floor((self.frame.size.width - _titleLabel.frame.size.width) / 2.0f), topOffset - 35.0f, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
}

@end
