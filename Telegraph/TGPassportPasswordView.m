#import "TGPassportPasswordView.h"

#import <LegacyComponents/LegacyComponents.h>
#import <LegacyComponents/TGTextField.h>

#import "TGPresentation.h"

@interface TGPassportPasswordView () <UITextFieldDelegate>
{
    UILabel *_label;
    UILabel *_deniedLabel;
    UIImageView *_fieldView;
    TGTextField *_textField;
    TGModernButton *_button;
    TGModernButton *_forgetButton;
    UIActivityIndicatorView *_activityIndicator;
}
@end

@implementation TGPassportPasswordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _label = [[UILabel alloc] init];
        _label.font = TGSystemFontOfSize(13.0f);
        _label.numberOfLines = 3;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.text = TGLocalized(@"Passport.PasswordHelp");
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        _deniedLabel = [[UILabel alloc] init];
        _deniedLabel.alpha = 0.0f;
        _deniedLabel.font = TGSystemFontOfSize(13.0f);
        _deniedLabel.numberOfLines = 3;
        _deniedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _deniedLabel.text = TGLocalized(@"Passport.InvalidPasswordError");
        _deniedLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_deniedLabel];
        
        _fieldView = [[UIImageView alloc] init];
        [self addSubview:_fieldView];
        
        _textField = [[TGTextField alloc] init];
        _textField.font = TGSystemFontOfSize(16.0f);
        _textField.delegate = self;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.secureTextEntry = true;
        _textField.placeholder = TGLocalized(@"Passport.PasswordPlaceholder");
        [self addSubview:_textField];
        
        _forgetButton = [[TGModernButton alloc] init];
        _forgetButton.adjustsImageWhenHighlighted = false;
        [_forgetButton setImage:TGImageNamed(@"PassportForgetIcon") forState:UIControlStateNormal];
        [_forgetButton addTarget:self action:@selector(forgottenButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_forgetButton];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.userInteractionEnabled = false;
        [self addSubview:_activityIndicator];
        
        if ((int)TGScreenSize().width != 320)
        {
            _button = [[TGModernButton alloc] init];
            _button.adjustsImageWhenHighlighted = false;
            _button.adjustsImageWhenDisabled = false;
            _button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
            _button.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f);
            [_button setTitle:TGLocalized(@"Passport.PasswordNext") forState:UIControlStateNormal];
            [_button addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [_button sizeToFit];
            [self addSubview:_button];
        }
    }
    return self;
}

- (void)setHint:(NSString *)hint
{
    _textField.placeholder = hint.length == 0 ? TGLocalized(@"Passport.PasswordPlaceholder") : hint;
}

- (void)setAccessDenied:(bool)accessDenied text:(NSString *)text animated:(bool)animated
{
    _deniedLabel.text = text;
    [self setNeedsLayout];
    
    if (_deniedLabel.alpha > FLT_EPSILON)
        [self shakeLabel];
    
    void (^changeBlock)(void) = ^
    {
        _label.alpha = accessDenied ? 0.0f : 1.0;
        _deniedLabel.alpha = accessDenied ? 1.0f : 0.0;
    };
    
    if (animated)
        [UIView animateWithDuration:0.2 animations:changeBlock];
    else
        changeBlock();
}

- (void)shakeLabel
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 6; i++)
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(i % 2 == 0 ? -3.0f : 3.0f, 0.0f, 0.0f)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f)]];
    animation.values = values;
    NSMutableArray *keyTimes = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < animation.values.count; i++)
        [keyTimes addObject:@((NSTimeInterval)i / (animation.values.count - 1.0))];
    animation.keyTimes = keyTimes;
    animation.duration = 0.3;
    [_deniedLabel.layer addAnimation:animation forKey:@"transform"];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _label.textColor = presentation.pallete.collectionMenuCommentColor;
    _deniedLabel.textColor = presentation.pallete.collectionMenuDestructiveColor;
    
    UIColor *insideColor = [presentation.pallete.paymentsPayButtonDisabledColor colorWithHueMultiplier:1.0 saturationMultiplier:1.0 brightnessMultiplier:0.6];
    
    _textField.keyboardAppearance = presentation.pallete.isDark ? UIKeyboardAppearanceAlert : UIKeyboardAppearanceDefault;
    _textField.placeholderFont = TGSystemFontOfSize(14.0f);
    _textField.placeholderColor = insideColor;
    
    UIImage *fieldImage;
    UIImage *payButtonImage;
    UIImage *payButtonHighlightedImage;
    UIImage *payDisabledButtonImage;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(16.0f, 16.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, presentation.pallete.paymentsPayButtonColor.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 16.0f, 16.0f));
    payButtonImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(16.0f, 16.0f), false, 0.0f);
    context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [presentation.pallete.paymentsPayButtonColor colorWithHueMultiplier:1.0f saturationMultiplier:1.0f brightnessMultiplier:0.8f].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 16.0f, 16.0f));
    payButtonHighlightedImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(16.0f, 16.0f), false, 0.0f);
    context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, presentation.pallete.paymentsPayButtonDisabledColor.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 16.0f, 16.0f));
    payDisabledButtonImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(16.0f, 16.0f), false, 0.0f);
    context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [presentation.pallete.paymentsPayButtonDisabledColor colorWithHueMultiplier:1.0 saturationMultiplier:1.0 brightnessMultiplier:1.07].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 16.0f, 16.0f));
    fieldImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    UIGraphicsEndImageContext();
    
    _fieldView.image = fieldImage;
    
    [_button setBackgroundImage:payButtonImage forState:UIControlStateNormal];
    [_button setBackgroundImage:payButtonHighlightedImage forState:UIControlStateHighlighted];
    [_button setBackgroundImage:payDisabledButtonImage forState:UIControlStateDisabled];
    
    [_button setTitleColor:presentation.pallete.accentContrastColor];
    
    [_forgetButton setImage:TGTintedImage(TGImageNamed(@"PassportForgetIcon"), insideColor) forState:UIControlStateNormal];
    _activityIndicator.color = insideColor;
}

- (void)nextButtonPressed
{
    if (_textField.text.length == 0)
        return;
    
    if (self.nextPressed != nil)
        self.nextPressed(_textField.text);
}

- (void)forgottenButtonPressed
{
    if (self.forgottenPressed != nil)
        self.forgottenPressed();
}

- (void)setRecoverable:(bool)recoverable
{
    _forgetButton.hidden = !recoverable;
}

- (void)setProgress:(bool)progress
{
    if (progress)
    {
        _forgetButton.userInteractionEnabled = false;
        _forgetButton.alpha = 0.0f;
        [_activityIndicator startAnimating];
    }
    else
    {
        _forgetButton.userInteractionEnabled = true;
        _forgetButton.alpha = 1.0f;
        [_activityIndicator stopAnimating];
    }
}

- (BOOL)textField:(UITextField *)__unused textField shouldChangeCharactersInRange:(NSRange)__unused range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        [self nextButtonPressed];
        return false;
    }
    
    if (!(string.length == 0 && range.length == 1) && _textField.clearAllOnNextBackspace)
    {
        _textField.text = string;
        return false;
    }
    
    return true;
}

- (void)focus
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
       [_textField becomeFirstResponder];
    });
}

- (void)setFailed
{
    _textField.clearAllOnNextBackspace = true;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat inset = ![TGViewController hasLargeScreen] ? 30.0f : 60.0f;
    CGSize textSize = [_label.attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width - inset, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    _label.frame = CGRectMake(floor((self.frame.size.width - textSize.width) / 2.0f), -14.0f - textSize.height, textSize.width, textSize.height);
    
    textSize = [_deniedLabel.attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width - inset, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    _deniedLabel.frame = CGRectMake(floor((self.frame.size.width - textSize.width) / 2.0f), -14.0f - textSize.height, textSize.width, textSize.height);
    
    CGFloat fieldWidth = MAX(266, self.frame.size.width - 100.0f);
    
    _fieldView.frame = CGRectMake(round((self.frame.size.width - fieldWidth) / 2.0f), 0.0f, fieldWidth, 31.0f);
    _forgetButton.frame = CGRectMake(CGRectGetMaxX(_fieldView.frame) - 31.0f, CGRectGetMinY(_fieldView.frame), 31.0f, 31.0f);
    _textField.frame = CGRectMake(_fieldView.frame.origin.x + 8.0f, _fieldView.frame.origin.y, _fieldView.frame.size.width - 8.0f - 31.0f, _fieldView.frame.size.height);
    
    _activityIndicator.center = CGPointMake(CGRectGetMidX(_forgetButton.frame), CGRectGetMidY(_forgetButton.frame));
    
    CGFloat buttonWidth = MAX(100.0f, _button.frame.size.width);
    _button.frame = CGRectMake(round((self.frame.size.width - buttonWidth) / 2.0f), _fieldView.frame.origin.y + 48.0f, buttonWidth, 35.0f);
}

@end
