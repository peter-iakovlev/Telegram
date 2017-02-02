#import "TGBackspaceTextField.h"

#import "TGFont.h"

@interface TGBackspaceTextField ()

@end

@implementation TGBackspaceTextField

@synthesize customPlaceholderLabel = _customPlaceholderLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _customPlaceholderLabel = [[UILabel alloc] init];
    _customPlaceholderLabel.textAlignment = NSTextAlignmentLeft;
    _customPlaceholderLabel.backgroundColor = [UIColor clearColor];
    _customPlaceholderLabel.font = [UIFont systemFontOfSize:15];
    [_customPlaceholderLabel sizeToFit];
    _customPlaceholderLabel.userInteractionEnabled = false;
    _customPlaceholderLabel.textColor = UIColorRGB(0x8e8e93);
    
    [self setTextAlignment:NSTextAlignmentLeft];
}

- (void)setShowPlaceholder:(bool)showPlaceholder animated:(bool)animated
{
    if (showPlaceholder != _customPlaceholderLabel.alpha > FLT_EPSILON)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.2 animations:^
            {
                _customPlaceholderLabel.alpha = showPlaceholder ? 1.0f : 0.0f;
            }];
        }
        else
            _customPlaceholderLabel.alpha = showPlaceholder ? 1.0f : 0.0f;
    }
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    _customPlaceholderLabel.hidden = text.length != 0;
}

- (void)deleteBackward1
{
    bool wasEmpty = self.text.length == 0;
    
    [super deleteBackward];
    
    if (wasEmpty && iosMajorVersion() >= 6)
        [self deleteLastBackward];
}

- (void)deleteLastBackward
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    id delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(textFieldDidHitLastBackspace)])
        [delegate performSelector:@selector(textFieldDidHitLastBackspace)];
#pragma clang diagnostic pop
}

- (BOOL)becomeFirstResponder
{
    if ([super becomeFirstResponder])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        id delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(textFieldDidBecomeFirstResponder)])
            [delegate performSelector:@selector(textFieldDidBecomeFirstResponder)];
#pragma clang diagnostic pop
        return true;
    }
    return false;
}

- (BOOL)resignFirstResponder
{
    if ([super resignFirstResponder])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        id delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(textFieldDidResignFirstResponder)])
            [delegate performSelector:@selector(textFieldDidResignFirstResponder)];
#pragma clang diagnostic pop
        return true;
    }
    return false;
}

- (BOOL)keyboardInputShouldDelete:(UITextField *)textField
{
    BOOL shouldDelete = YES;
    
    if ([UITextField instancesRespondToSelector:_cmd])
    {
        bool wasEmpty = self.text.length == 0;
        
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextField *) = (BOOL (*)(id, SEL, UITextField *))[UITextField instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete)
            shouldDelete = keyboardInputShouldDelete(self, _cmd, textField);
        
        if (wasEmpty)
            shouldDelete = false;
        
        if (iosMajorVersion() >= 7 && wasEmpty)
            [self deleteLastBackward];
    }
    
    return shouldDelete;
}

@end
