#import "TGCountryAndPhoneCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"
#import "TGBackspaceTextField.h"
#import "TGTextField.h"
#import "TGPhoneUtils.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "TGLoginCountriesController.h"
#import "TGNavigationController.h"

@interface TGCountryAndPhoneCollectionItemView () <UITextFieldDelegate>
{
    UIButton *_countryButton;
    TGTextField *_countryTextField;
    TGTextField *_phoneTextField;
}

@end

@implementation TGCountryAndPhoneCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        UIImage *buttonImage = nil;
        UIImage *buttonHighlightedImage = nil;
        for (int i = 0; i < 2; i++)
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f, 51.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            if (i == 0)
            {
                CGFloat lineWidth = TGScreenPixel;
                CGFloat verticalOffset = 44.0f;
                CGContextSetLineWidth(context, lineWidth);
                CGContextSetStrokeColorWithColor(context, TGSeparatorColor().CGColor);
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, 16.0f, verticalOffset + lineWidth / 2.0f);
                CGContextAddLineToPoint(context, 32.0f, verticalOffset + lineWidth / 2.0f);
                CGContextAddLineToPoint(context, 32.0f + 6.0f + lineWidth / 2.0f, verticalOffset + lineWidth / 2.0f + 6.0f + lineWidth / 2.0f);
                CGContextAddLineToPoint(context, 32.0f + 12.0f + lineWidth / 2.0f, verticalOffset + lineWidth / 2.0f);
                CGContextAddLineToPoint(context, 50.0f, verticalOffset + lineWidth / 2.0f);
                CGContextStrokePath(context);
            }
            else
            {
                CGFloat lineWidth = TGScreenPixel;
                CGFloat verticalOffset = 44.0f;
                CGContextSetFillColorWithColor(context, TGSelectionColor().CGColor);
                CGContextSetStrokeColorWithColor(context, TGSeparatorColor().CGColor);
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, 0.0f, verticalOffset + lineWidth);
                CGContextAddLineToPoint(context, 32.0f, verticalOffset + lineWidth);
                CGContextAddLineToPoint(context, 32.0f + 6.0f + lineWidth, verticalOffset + 6.0f + lineWidth);
                CGContextAddLineToPoint(context, 32.0f + 12.0f + lineWidth, verticalOffset + lineWidth);
                CGContextAddLineToPoint(context, 50.0f, verticalOffset + lineWidth);
                CGContextAddLineToPoint(context, 50.0f, 0.0f);
                CGContextAddLineToPoint(context, 0.0f, 0.0f);
                CGContextClosePath(context);
                CGContextFillPath(context);
            }
            
            UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:49.0f topCapHeight:0.0f];
            if (i == 0)
                buttonImage = image;
            else
                buttonHighlightedImage = image;
            UIGraphicsEndImageContext();
        }
        
        _countryButton = [[UIButton alloc] init];
        [_countryButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [_countryButton setBackgroundImage:buttonHighlightedImage forState:UIControlStateHighlighted];
        [_countryButton setTitle:@"Lithuania" forState:UIControlStateNormal];
        _countryButton.titleLabel.font = TGSystemFontOfSize(17.0f);
        [_countryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_countryButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_countryButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 15.0f, 4.0f, 44.0f)];
        [_countryButton addTarget:self action:@selector(countryButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_countryButton];
        
        UIImageView *disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernListsDisclosureIndicator.png"]];
        disclosureIndicator.frame = (CGRect){{_countryButton.frame.size.width - 15.0f - disclosureIndicator.frame.size.width, 15.0f}, disclosureIndicator.frame.size};
        disclosureIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_countryButton addSubview:disclosureIndicator];
        
        _countryTextField = [[TGTextField alloc] init];
        _countryTextField.font = TGSystemFontOfSize(17.0f);
        _countryTextField.backgroundColor = [UIColor clearColor];
        _countryTextField.textAlignment = NSTextAlignmentCenter;
        _countryTextField.textColor = [UIColor blackColor];
        _countryTextField.text = @"+370";
        _countryTextField.keyboardType = UIKeyboardTypeNumberPad;
        _countryTextField.delegate = self;
        [self addSubview:_countryTextField];
        
        _phoneTextField = [[TGBackspaceTextField alloc] init];
        _phoneTextField.font = TGSystemFontOfSize(17.0f);
        _phoneTextField.backgroundColor = [UIColor clearColor];
        _phoneTextField.textAlignment = NSTextAlignmentLeft;
        _phoneTextField.textColor = [UIColor blackColor];
        _phoneTextField.placeholder = TGLocalized(@"ChangePhoneNumberNumber.NumberPlaceholder");
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.delegate = self;
        [self addSubview:_phoneTextField];
        
        NSString *countryId = nil;
        
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [networkInfo subscriberCellularProvider];
        if (carrier != nil)
        {
            NSString *mcc = [carrier isoCountryCode];
            if (mcc != nil)
                countryId = mcc;
        }
        if (countryId == nil)
        {
            NSLocale *locale = [NSLocale currentLocale];
            countryId = [locale objectForKey:NSLocaleCountryCode];
        }
        
        int code = 0;
        [TGLoginCountriesController countryNameByCountryId:countryId code:&code];
        if (code == 0)
            code = 1;
        
        _countryTextField.text = [NSString stringWithFormat:@"+%d", code];
        
        [self updatePhoneTextForCountryFieldText:_countryTextField.text];
        
        [self updateCountry];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _countryButton.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 51.0f);
    _countryTextField.frame = CGRectMake(0.0f, 44.0f + TGRetinaPixel, 70.0f, 44.0f);
    _phoneTextField.frame = CGRectMake(73.0f + TGRetinaPixel, 44 + TGRetinaPixel, self.frame.size.width - 72.0f, 44.0f);
}

- (void)makeCountryFieldFirstResponder
{
    if (_countryTextField.text.length == 1)
        [_countryTextField becomeFirstResponder];
    else
        [_phoneTextField becomeFirstResponder];
}

- (void)textFieldDidHitLastBackspace
{
    [_countryTextField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _countryTextField)
    {
        int length = (int)string.length;
        unichar replacementCharacters[length];
        int filteredLength = 0;
        
        for (int i = 0; i < length; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (c >= '0' && c <= '9')
                replacementCharacters[filteredLength++] = c;
        }
        
        if (filteredLength == 0 && (range.length == 0 || range.location == 0))
            return false;
        
        if (range.location == 0)
            range.location++;
        
        NSString *replacementString = [[NSString alloc] initWithCharacters:replacementCharacters length:filteredLength];
        
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:replacementString];
        if (newText.length > 5)
        {
            for (int i = 0; i < (int)newText.length - 1; i++)
            {
                int countryCode = [[newText substringWithRange:NSMakeRange(1, newText.length - 1 - i)] intValue];
                NSString *countryName = [TGLoginCountriesController countryNameByCode:countryCode];
                if (countryName != nil)
                {
                    _phoneTextField.text = [self filterPhoneText:[[NSString alloc] initWithFormat:@"%@%@", [newText substringFromIndex:newText.length - i], _phoneTextField.text]];
                    newText = [newText substringToIndex:newText.length - i];
                    [_phoneTextField becomeFirstResponder];
                }
            }
            
            if (newText.length > 5)
                newText = [newText substringToIndex:5];
        }
        
        textField.text = newText;
        
        [self updatePhoneTextForCountryFieldText:newText];
        
        [self updateCountry];
        
        [self _notifyPhoneChanged];
        
        return false;
    }
    else if (textField == _phoneTextField)
    {
        if (true)
        {
            int stringLength = (int)string.length;
            unichar replacementCharacters[stringLength];
            int filteredLength = 0;
            
            for (int i = 0; i < stringLength; i++)
            {
                unichar c = [string characterAtIndex:i];
                if (c >= '0' && c <= '9')
                    replacementCharacters[filteredLength++] = c;
            }
            
            NSString *replacementString = [[NSString alloc] initWithCharacters:replacementCharacters length:filteredLength];
            
            unichar rawNewString[replacementString.length];
            int rawNewStringLength = 0;
            
            int replacementLength = (int)replacementString.length;
            for (int i = 0; i < replacementLength; i++)
            {
                unichar c = [replacementString characterAtIndex:i];
                if ((c >= '0' && c <= '9'))
                    rawNewString[rawNewStringLength++] = c;
            }
            
            NSString *string = [[NSString alloc] initWithCharacters:rawNewString length:rawNewStringLength];
            
            NSMutableString *rawText = [[NSMutableString alloc] initWithCapacity:16];
            NSString *currentText = textField.text;
            int length = (int)currentText.length;
            
            int originalLocation = (int)range.location;
            int originalEndLocation = (int)range.location + (int)range.length;
            int endLocation = originalEndLocation;
            
            for (int i = 0; i < length; i++)
            {
                unichar c = [currentText characterAtIndex:i];
                if ((c >= '0' && c <= '9'))
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
                int caretPosition = (int)range.location + (int)string.length;
                
                [rawText replaceCharactersInRange:range withString:string];
                
                NSString *countryCodeText = _countryTextField.text.length > 1 ? _countryTextField.text : @"";
                
                NSString *formattedText = [TGPhoneUtils formatPhone:[[NSString alloc] initWithFormat:@"%@%@", countryCodeText, rawText] forceInternational:false];
                if (countryCodeText.length > 1)
                {
                    int i = 0;
                    int j = 0;
                    while (i < (int)formattedText.length && j < (int)countryCodeText.length)
                    {
                        unichar c1 = [formattedText characterAtIndex:i];
                        unichar c2 = [countryCodeText characterAtIndex:j];
                        if (c1 == c2)
                            j++;
                        i++;
                    }
                    
                    formattedText = [formattedText substringFromIndex:i];
                    
                    i = 0;
                    while (i < (int)formattedText.length)
                    {
                        unichar c = [formattedText characterAtIndex:i];
                        if ((c == ')' && i != 0) || c == '(' || (c >= '0' && c <= '9'))
                            break;
                        
                        i++;
                    }
                    
                    formattedText = [self filterPhoneText:[formattedText substringFromIndex:i]];
                }
                
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
                
                textField.text = formattedText;
                
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
            
            [self _notifyPhoneChanged];
            
            return false;
        }
        else
        {
            int length = (int)string.length;
            unichar replacementCharacters[length];
            int filteredLength = 0;
            
            for (int i = 0; i < length; i++)
            {
                unichar c = [string characterAtIndex:i];
                if (c >= '0' && c <= '9')
                    replacementCharacters[filteredLength++] = c;
            }
            
            NSString *replacementString = [[NSString alloc] initWithCharacters:replacementCharacters length:filteredLength];
            
            NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:replacementString];
            if (newText.length > 19)
                newText = [newText substringToIndex:19];
            
            textField.text = newText;
            
            [self _notifyPhoneChanged];
            
            return false;
        }
    }
    
    return true;
}

- (NSString *)filterPhoneText:(NSString *)text
{
    int i = 0;
    while (i < (int)text.length)
    {
        unichar c = [text characterAtIndex:i];
        if ((c >= '0' && c <= '9'))
            return text;
        
        i++;
    }
    
    return @"";
}

- (void)updatePhoneTextForCountryFieldText:(NSString *)countryCodeText
{
    NSString *rawText = _phoneTextField.text;
    
    NSString *formattedText = [TGPhoneUtils formatPhone:[[NSString alloc] initWithFormat:@"%@%@", countryCodeText, rawText] forceInternational:false];
    if (countryCodeText.length > 1)
    {
        int i = 0;
        int j = 0;
        while (i < (int)formattedText.length && j < (int)countryCodeText.length)
        {
            unichar c1 = [formattedText characterAtIndex:i];
            unichar c2 = [countryCodeText characterAtIndex:j];
            if (c1 == c2)
                j++;
            i++;
        }
        
        formattedText = [formattedText substringFromIndex:i];
        
        i = 0;
        while (i < (int)formattedText.length)
        {
            unichar c = [formattedText characterAtIndex:i];
            if (c == '(' || c == ')' || (c >= '0' && c <= '9'))
                break;
            
            i++;
        }
        
        formattedText = [formattedText substringFromIndex:i];
        _phoneTextField.text = [self filterPhoneText:formattedText];
    }
    else
        _phoneTextField.text = [self filterPhoneText:[TGPhoneUtils formatPhone:[[NSString alloc] initWithFormat:@"%@", _phoneTextField.text] forceInternational:false]];
    
    [self _notifyPhoneChanged];
}

- (void)updateCountry
{
    int countryCode = [[_countryTextField.text substringFromIndex:1] intValue];
    NSString *countryName = [TGLoginCountriesController countryNameByCode:countryCode];
    
    if (countryName != nil)
    {
        //[_countryButton setTitleColor:UIColorRGB(0xf0f0f0) forState:UIControlStateNormal];
        [_countryButton setTitle:countryName forState:UIControlStateNormal];
    }
    else
    {
        //[_countryButton setTitleColor:UIColorRGBA(0xf0f0f0, 0.7f) forState:UIControlStateNormal];
        [_countryButton setTitle:_countryTextField.text.length <= 1 ? TGLocalized(@"Login.CountryCode") : TGLocalized(@"Login.InvalidCountryCode") forState:UIControlStateNormal];
    }
}

- (void)countryButtonPressed
{
    TGLoginCountriesController *countriesController = [[TGLoginCountriesController alloc] init];
    __weak TGCountryAndPhoneCollectionItemView *weakSelf = self;
    countriesController.countrySelected = ^(int code, NSString *name, __unused NSString *countryId)
    {
        __strong TGCountryAndPhoneCollectionItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [UIView performWithoutAnimation:^
            {
                [strongSelf->_countryButton setTitle:name forState:UIControlStateNormal];
                strongSelf->_countryTextField.text = [NSString stringWithFormat:@"+%d", code];
                
                [self _notifyPhoneChanged];
                
                [strongSelf updatePhoneTextForCountryFieldText:_countryTextField.text];
                
                [strongSelf->_countryButton layoutSubviews];
                [strongSelf->_countryTextField layoutSubviews];
                [strongSelf->_phoneTextField layoutSubviews];
            }];
        }
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:countriesController];
    if (_presentViewController)
        _presentViewController(navigationController);
}

- (void)_notifyPhoneChanged
{
    NSString *phoneNumber = [NSString stringWithFormat:@"%@%@", [_countryTextField.text substringFromIndex:1], _phoneTextField.text];
    phoneNumber = [TGPhoneUtils cleanPhone:phoneNumber];
    if (_phoneChanged)
        _phoneChanged(phoneNumber);
}

@end
