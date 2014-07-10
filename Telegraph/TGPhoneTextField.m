/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPhoneTextField.h"

#import "TGPhoneUtils.h"

@interface TGPhoneTextField () <UITextFieldDelegate>

@property (nonatomic, strong) NSString *phone;

@end

@implementation TGPhoneTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.delegate = self;
        self.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (iosMajorVersion() == 7)
    {
        const char *name = sel_getName(aSelector);
        if (name != NULL && !strncmp(name, "customOverlayContainer", 22))
            return false;
    }
    return [super respondsToSelector:aSelector];
}

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    [self setText:[TGPhoneUtils formatPhone:phoneNumber forceInternational:false]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    unichar rawNewString[replacementString.length];
    int rawNewStringLength = 0;
    
    int replacementLength = (int)replacementString.length;
    for (int i = 0; i < replacementLength; i++)
    {
        unichar c = [replacementString characterAtIndex:i];
        if (c == '+' || (c >= '0' && c <= '9'))
            rawNewString[rawNewStringLength++] = c;
    }
    
    NSString *string = [[NSString alloc] initWithCharacters:rawNewString length:rawNewStringLength];
    
    NSMutableString *rawText = [[NSMutableString alloc] initWithCapacity:16];
    NSString *currentText = textField.text;
    int length = (int)currentText.length;
    
    int originalLocation = (int)range.location;
    int originalEndLocation = (int)(range.location + range.length);
    int endLocation = originalEndLocation;
    
    for (int i = 0; i < length; i++)
    {
        unichar c = [currentText characterAtIndex:i];
        if (c == '+' || (c >= '0' && c <= '9'))
            [rawText appendString:[[NSString alloc] initWithCharacters:&c length:1]];
        else
        {
            if (originalLocation > i)
            {
                if (range.location > 0)
                    range.location--;
            }
            
            if (originalEndLocation > i)
                endLocation--;
        }
    }
    
    int newLength = endLocation - (int)range.location;
    if (newLength == 0 && range.length == 1 && range.location > 0)
    {
        range.location--;
        newLength = 1;
    }
    if (newLength < 0)
        return false;
    
    range.length = newLength;
    
    @try
    {
        //caretPosition += string.length;
        int caretPosition = (int)range.location + (int)string.length;
        
        [rawText replaceCharactersInRange:range withString:string];
        
        NSString *formattedText = [TGPhoneUtils formatPhone:rawText forceInternational:false];
        int formattedTextLength = (int)formattedText.length;
        int rawTextLength = (int)rawText.length;
        
        int newCaretPosition = caretPosition;
        
        for (int j = 0, k = 0; j < formattedTextLength && k < rawTextLength; )
        {
            unichar c1 = [formattedText characterAtIndex:j];
            unichar c2 = [rawText characterAtIndex:k];
            if (c1 != c2)
                newCaretPosition++;
            else
                k++;
            
            if (k == caretPosition)
            {
                break;
            }
            
            j++;
        }
        
        textField.text = [TGPhoneUtils formatPhone:rawText forceInternational:false];
        self.phone = textField.text;
        
        id<TGPhoneTextFieldDelegate> delegate = _phoneDelegate;
        if ([delegate respondsToSelector:@selector(phoneTextField:hasChangedPhone:)])
            [delegate phoneTextField:self hasChangedPhone:_phone];
        
        if (caretPosition >= (int)textField.text.length)
            caretPosition = (int)textField.text.length;
        
        UITextPosition *startPosition = [textField positionFromPosition:textField.beginningOfDocument offset:newCaretPosition];
        UITextPosition *endPosition = [textField positionFromPosition:textField.beginningOfDocument offset:newCaretPosition];
        UITextRange *selection = [textField textRangeFromPosition:startPosition toPosition:endPosition];
        textField.selectedTextRange = selection;
    }
    @catch (NSException *e)
    {
        TGLog(@"%@", e);
    }
    
    return false;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return false;
}

@end
