#import "TGPasswordSetupView.h"

#import "TGTextField.h"
#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGPasswordSetupView () <UITextFieldDelegate>
{
    UIEdgeInsets _contentInsets;
    
    UIView *_textFieldBackground;
    UIView *_topSeparator;
    UIView *_bottomSeparator;
    TGTextField *_textField;
    UILabel *_titleLabel;
}

@end

@implementation TGPasswordSetupView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _textFieldBackground = [[UIView alloc] init];
        _textFieldBackground.backgroundColor = [UIColor whiteColor];
        [self addSubview:_textFieldBackground];
        
        _topSeparator = [[UIView alloc] init];
        _topSeparator.backgroundColor = UIColorRGB(0xc8c7cc);
        [_textFieldBackground addSubview:_topSeparator];
        
        _bottomSeparator = [[UIView alloc] init];
        _bottomSeparator.backgroundColor = UIColorRGB(0xc8c7cc);
        [_textFieldBackground addSubview:_bottomSeparator];
        
        _textField = [[TGTextField alloc] init];
        _textField.leftInset = 15.0f;
        _textField.rightInset = 15.0f;
        _textField.delegate = self;
        _textField.font = TGSystemFontOfSize(16.0f);
        _textField.secureTextEntry = true;
        [_textField addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:_textField];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = UIColorRGB(0x6d6d72);
        _titleLabel.font = TGSystemFontOfSize(14.0f);
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setSecureEntry:(bool)secureEntry
{
    _secureEntry = secureEntry;
    _textField.secureTextEntry = secureEntry;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    [self layoutSubviews];
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    [self setNeedsLayout];
}

- (void)clearInput
{
    [self setText:@""];
}

- (void)setText:(NSString *)text
{
    _textField.text = text;
    if (_passwordChanged)
        _passwordChanged(text);
}

- (void)becomeFirstResponder
{
    [_textField becomeFirstResponder];
}

- (void)textFieldChanged
{
    if (_passwordChanged)
        _passwordChanged(_textField.text);
}

- (NSString *)password
{
    return _textField.text;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat fieldHeight = 44.0f;
    _textFieldBackground.frame = CGRectMake(0.0f, _contentInsets.top + CGFloor((self.frame.size.height - _contentInsets.top - _contentInsets.bottom - fieldHeight) / 2.0f), self.frame.size.width, fieldHeight);
    
    _textField.frame = _textFieldBackground.frame;
    
    CGFloat separatorHeight = TGScreenPixel;
    _topSeparator.frame = CGRectMake(0.0f, 0.0f, _textFieldBackground.frame.size.width, separatorHeight);
    _bottomSeparator.frame = CGRectMake(0.0f, _textFieldBackground.frame.size.height - separatorHeight, _textFieldBackground.frame.size.width, separatorHeight);
    
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(CGFloor((self.frame.size.width - _titleLabel.frame.size.width) / 2.0f), _textFieldBackground.frame.origin.y - _titleLabel.frame.size.height - 18.0f, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
}

@end
