#import "TGLoginCodeController.h"

#import "TGToolbarButton.h"

#import "TGImageUtils.h"
#import "TGPhoneUtils.h"

#import "TGHacks.h"
#import "TGFont.h"

#import "TGProgressWindow.h"

#import "TGStringUtils.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGLoginProfileController.h"

#import "TGAppDelegate.h"

#import "TGSignInRequestBuilder.h"
#import "TGSendCodeRequestBuilder.h"

#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGLoginInactiveUserController.h"

#import "TGActivityIndicatorView.h"

#import "TGTextField.h"

#import "TGTimerTarget.h"

#import <MessageUI/MessageUI.h>

@interface TGLoginCodeController () <UITextFieldDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>
{
    bool _dismissing;
    bool _alreadyCountedDown;
    
    UIView *_grayBackground;
    UIView *_separatorView;
    UILabel *_titleLabel;
    UIView *_fieldSeparatorView;
}

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *phoneCodeHash;
@property (nonatomic) NSTimeInterval phoneTimeout;

@property (nonatomic, strong) UILabel *noticeLabel;

@property (nonatomic, strong) TGTextField *codeField;

@property (nonatomic) CGRect baseInputBackgroundViewFrame;
@property (nonatomic) CGRect baseCodeFieldFrame;

@property (nonatomic, strong) UILabel *timeoutLabel;
@property (nonatomic, strong) UILabel *requestingCallLabel;
@property (nonatomic, strong) UILabel *callSentLabel;

@property (nonatomic) bool inProgress;
@property (nonatomic) int currentActionIndex;

@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic) NSTimeInterval countdownStart;

@property (nonatomic, strong) NSString *phoneCode;

@property (nonatomic, strong) UIAlertView *currentAlert;

@property (nonatomic, strong) TGProgressWindow *progressWindow;

@end

@implementation TGLoginCodeController

- (id)initWithShowKeyboard:(bool)__unused showKeyboard phoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash phoneTimeout:(NSTimeInterval)phoneTimeout
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _phoneNumber = phoneNumber;
        _phoneCodeHash = phoneCodeHash;
        _phoneTimeout = phoneTimeout;
        
        self.style = TGViewControllerStyleBlack;
        
        [ActionStageInstance() watchForPath:@"/tg/activation" watcher:self];
        [ActionStageInstance() watchForPath:@"/tg/contactListSynchronizationState" watcher:self];
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextButtonPressed)]];
    }
    return self;
}

- (void)dealloc
{
    [self doUnloadView];
    
    _codeField.delegate = nil;
    
    _currentAlert.delegate = nil;
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (bool)shouldBeRemovedFromNavigationAfterHiding
{
    return true;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    _grayBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenSize.width, [TGViewController isWidescreen] ? 131.0f : 90.0f)];
    _grayBackground.backgroundColor = UIColorRGB(0xf2f2f2);
    [self.view addSubview:_grayBackground];
    
    _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _grayBackground.frame.origin.y + _grayBackground.frame.size.height, screenSize.width, TGIsRetina() ? 0.5f : 1.0f)];
    _separatorView.backgroundColor = TGSeparatorColor();
    [self.view addSubview:_separatorView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = TGIsPad() ? TGUltralightSystemFontOfSize(48.0f) : TGLightSystemFontOfSize(30.0f);
    _titleLabel.text = TGLocalized(@"Login.CodeTitle");
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(CGFloor((screenSize.width - _titleLabel.frame.size.width) / 2), [TGViewController isWidescreen] ? 71.0f : 48.0f, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    [self.view addSubview:_titleLabel];
    
    _noticeLabel = [[UILabel alloc] init];
    _noticeLabel.font = TGSystemFontOfSize(17);
    _noticeLabel.textColor = UIColorRGB(0x999999);
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    _noticeLabel.contentMode = UIViewContentModeCenter;
    _noticeLabel.numberOfLines = 0;
    
    NSString *textFormat = TGLocalized(@"Login.CodeHelp");
    NSString *phoneFormatted = [TGPhoneUtils formatPhone:_phoneNumber forceInternational:true];
    if (TGIsArabic())
    {
        phoneFormatted = [[NSString alloc] initWithFormat:@"%s%@%s", TGIsArabic() ? "" : "+", [TGStringUtils stringWithLocalizedNumberCharacters:[TGPhoneUtils cleanPhone:_phoneNumber]], TGIsArabic() ? "+" : ""];
    }
    
    NSString *baseText = [[NSString alloc] initWithFormat:textFormat, phoneFormatted];
    NSRange phoneRange = [textFormat rangeOfString:@"%@"];
    if (phoneRange.location != NSNotFound)
        phoneRange.length = phoneFormatted.length;
    _noticeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_noticeLabel];
    
    if ([_noticeLabel respondsToSelector:@selector(setAttributedText:)] && phoneRange.location != NSNotFound)
    {
        UIColor *foregroundColor = [UIColor blackColor];
        
        NSDictionary *attrs = @{NSFontAttributeName: _noticeLabel.font, NSForegroundColorAttributeName: _noticeLabel.textColor};
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:foregroundColor, NSForegroundColorAttributeName, nil];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:baseText attributes:attrs];
        [attributedText setAttributes:subAttrs range:phoneRange];
        [_noticeLabel setAttributedText:attributedText];
    }
    else
        _noticeLabel.text = baseText;
    
    CGSize noticeSize = [_noticeLabel sizeThatFits:CGSizeMake(300, screenSize.height)];
    CGRect noticeFrame = CGRectMake(0, 0, noticeSize.width, noticeSize.height);
    _noticeLabel.frame = CGRectIntegral(CGRectOffset(noticeFrame, (screenSize.width - noticeFrame.size.width) / 2, _separatorView.frame.origin.y + ([TGViewController isWidescreen] ? 85.0f : 70.0f)));

    _fieldSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(22, _separatorView.frame.origin.y + 60.0f, screenSize.width - 44, TGIsRetina() ? 0.5f : 1.0f)];
    _fieldSeparatorView.backgroundColor = TGSeparatorColor();
    [self.view addSubview:_fieldSeparatorView];
    
    _codeField = [[TGTextField alloc] init];
    _codeField.font = TGSystemFontOfSize(24);
    _codeField.placeholderFont = _codeField.font;
    _codeField.placeholderColor = UIColorRGB(0xc7c7cd);
    _codeField.backgroundColor = [UIColor clearColor];
    _codeField.textAlignment = NSTextAlignmentCenter;
    _codeField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _codeField.placeholder = TGLocalized(@"Login.Code");
    _codeField.keyboardType = UIKeyboardTypeNumberPad;
    _codeField.delegate = self;
    _codeField.frame = CGRectMake(0.0f, _fieldSeparatorView.frame.origin.y - 56.0f, screenSize.width, 56.0f);
    [self.view addSubview:_codeField];
    
    _timeoutLabel = [[UILabel alloc] init];
    _timeoutLabel.font =  TGSystemFontOfSize(17);
    _timeoutLabel.textColor = UIColorRGB(0x999999);
    _timeoutLabel.textAlignment = NSTextAlignmentCenter;
    _timeoutLabel.contentMode = UIViewContentModeCenter;
    _timeoutLabel.numberOfLines = 0;
    _timeoutLabel.text = [TGStringUtils stringWithLocalizedNumberCharacters:[[NSString alloc] initWithFormat:TGLocalized(@"Login.CallRequestState1"), 1, 0]];
    _timeoutLabel.backgroundColor = [UIColor clearColor];
    [_timeoutLabel sizeToFit];
    [self.view addSubview:_timeoutLabel];
    
    _requestingCallLabel = [[UILabel alloc] init];
    _requestingCallLabel.font = TGSystemFontOfSize(17);
    _requestingCallLabel.textColor = UIColorRGB(0x999999);
    _requestingCallLabel.textAlignment = NSTextAlignmentCenter;
    _requestingCallLabel.contentMode = UIViewContentModeCenter;
    _requestingCallLabel.numberOfLines = 0;
    _requestingCallLabel.text = TGLocalized(@"Login.CallRequestState2");
    _requestingCallLabel.backgroundColor = [UIColor clearColor];
    _requestingCallLabel.alpha = 0.0f;
    [_requestingCallLabel sizeToFit];
    [self.view addSubview:_requestingCallLabel];
    
    _callSentLabel = [[UILabel alloc] init];
    _callSentLabel.font = TGSystemFontOfSize(17);
    _callSentLabel.textColor = UIColorRGB(0x999999);
    _callSentLabel.textAlignment = NSTextAlignmentCenter;
    _callSentLabel.contentMode = UIViewContentModeCenter;
    _callSentLabel.numberOfLines = 0;
    _callSentLabel.backgroundColor = [UIColor clearColor];
    _callSentLabel.alpha = 0.0f;
    
    NSString *codeTextFormat = TGLocalized(@"Login.CallRequestState3");
    NSRange linkRange = NSMakeRange(NSNotFound, 0);
    
    NSMutableString *codeText = [[NSMutableString alloc] init];
    for (int i = 0; i < (int)codeTextFormat.length; i++)
    {
        unichar c = [codeTextFormat characterAtIndex:i];
        if (c == '[')
        {
            if (linkRange.location == NSNotFound)
                linkRange.location = i;
        }
        else if (c == ']')
        {
            if (linkRange.location != NSNotFound && linkRange.length == 0)
                linkRange.length = i - linkRange.location - 1;
        }
        else
            [codeText appendString:[NSString stringWithCharacters:&c length:1]];
    }
    
    if ([_callSentLabel respondsToSelector:@selector(setAttributedText:)])
    {
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:_callSentLabel.font, NSFontAttributeName, nil];
        NSDictionary *linkAtts = @{NSForegroundColorAttributeName: TGAccentColor()};
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:codeText attributes:attrs];
        
        [attributedText setAttributes:linkAtts range:linkRange];
        
        [_callSentLabel setAttributedText:attributedText];
        
        [_callSentLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callSentTapGesture:)]];
        _callSentLabel.userInteractionEnabled = true;
    }
    else
        [_callSentLabel setText:baseText];
    
    [_callSentLabel sizeToFit];
    [self.view addSubview:_callSentLabel];
    
    CGFloat labelAnchor = _separatorView.frame.origin.y + ([TGViewController isWidescreen] ? 160 : 134);
    
    _timeoutLabel.frame = CGRectMake((int)((screenSize.width - _timeoutLabel.frame.size.width) / 2), labelAnchor, _timeoutLabel.frame.size.width, _timeoutLabel.frame.size.height);
    _requestingCallLabel.frame = CGRectMake((int)((screenSize.width - _requestingCallLabel.frame.size.width) / 2), labelAnchor, _requestingCallLabel.frame.size.width, _requestingCallLabel.frame.size.height);
    _callSentLabel.frame = CGRectMake((int)((screenSize.width - _callSentLabel.frame.size.width) / 2), labelAnchor, _callSentLabel.frame.size.width, _callSentLabel.frame.size.height);
    
    [self updateInterface:self.interfaceOrientation];
}

- (void)callSentTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        UILabel *label = (UILabel *)recognizer.view;
        if ([recognizer locationInView:label].y >= label.frame.size.height - [@"A" sizeWithFont:label.font].height - 2)
        {
            if ([MFMailComposeViewController canSendMail])
            {
                NSString *phoneFormatted = [TGPhoneUtils formatPhone:_phoneNumber forceInternational:true];
                
                MFMailComposeViewController *composeController = [[MFMailComposeViewController alloc] init];
                composeController.mailComposeDelegate = self;
                [composeController setToRecipients:@[@"sms@telegram.org"]];
                [composeController setSubject:[[NSString alloc] initWithFormat:TGLocalized(@"Login.EmailCodeSubject"), phoneFormatted]];
                [composeController setMessageBody:[[NSString alloc] initWithFormat:TGLocalized(@"Login.EmailCodeBody"), phoneFormatted] isHTML:false];
                [self presentViewController:composeController animated:true completion:nil];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:nil message:TGLocalized(@"Login.EmailNotConfiguredError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
            }
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)__unused controller didFinishWithResult:(MFMailComposeResult)__unused result error:(NSError *)__unused error
{
    [self dismissViewControllerAnimated:true completion:nil];
    
    [_codeField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (void)doUnloadView
{
    _codeField.delegate = nil;
}

- (void)viewDidUnload
{
    [self doUnloadView];
    
    [super viewDidUnload];
}

- (void)viewDidLayoutSubviews
{
    [_codeField becomeFirstResponder];
    
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_countdownTimer == nil && !_alreadyCountedDown)
    {
        _countdownStart = CFAbsoluteTimeGetCurrent();
        _countdownTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateCountdown) interval:1.0 repeat:false];
    }
    
    [self updateInterface:self.interfaceOrientation];
    
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_dismissing)
    {
        [TGAppDelegateInstance resetLoginState];
    }
    
    [super viewDidDisappear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateInterface:self.interfaceOrientation];
}

- (void)updateCountdown
{
    [_countdownTimer invalidate];
    _countdownTimer = nil;
    
    int timeout = MAX(30, (int)_phoneTimeout);
    
    NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
    NSTimeInterval remainingTime = (_countdownStart + timeout) - currentTime;
    
    if (remainingTime < 0)
        remainingTime = 0;
    
    _timeoutLabel.text = [TGStringUtils stringWithLocalizedNumberCharacters:[NSString stringWithFormat:TGLocalized(@"Login.CallRequestState1"), ((int)remainingTime) / 60, ((int)remainingTime) % 60]];
    
    if (remainingTime <= 0)
    {
        _alreadyCountedDown = true;
        
        [UIView animateWithDuration:0.2 animations:^
        {
            _timeoutLabel.alpha = 0.0f;
        }];
        
        [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^
        {
            _requestingCallLabel.alpha = 1.0f;
        } completion:nil];
        
        static int actionId = 0;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/service/auth/sendCode/(call%d)", actionId++] options:[[NSDictionary alloc] initWithObjectsAndKeys:_phoneNumber, @"phoneNumber", _phoneCodeHash, @"phoneHash", [[NSNumber alloc] initWithBool:true], @"requestCall", nil] watcher:self];
    }
    else
    {
        _countdownTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateCountdown) interval:1.0 repeat:false];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _dismissing = ![((TGNavigationController *)self.navigationController).viewControllers containsObject:self];
    
    [_countdownTimer invalidate];
    _countdownTimer = nil;
    
    [super viewWillDisappear:animated];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    //[self updateInterface:UIInterfaceOrientationPortrait];
}

- (void)updateInterface:(UIInterfaceOrientation)orientation
{
    CGSize screenSize = [self referenceViewSizeForOrientation:orientation];
    
    CGFloat topOffset = 0.0f;
    CGFloat titleLabelOffset = 0.0f;
    CGFloat noticeLabelOffset = 0.0f;
    CGFloat countryButtonOffset = 0.0f;
    CGFloat sideInset = 0.0f;
    
    if (TGIsPad())
    {
        if (UIInterfaceOrientationIsPortrait(orientation))
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
        countryButtonOffset = topOffset;
        sideInset = 130.0f;
    }
    else
    {
        topOffset = [TGViewController isWidescreen] ? 131.0f : 90.0f;
        titleLabelOffset = [TGViewController isWidescreen] ? 71.0f : 48.0f;
        noticeLabelOffset = [TGViewController isWidescreen] ? 274.0f : 214.0f;
        countryButtonOffset = [TGViewController isWidescreen] ? 131.0f : 90.0f;
    }
    
    _grayBackground.frame = CGRectMake(0.0f, 0.0f, screenSize.width, topOffset);
    _separatorView.frame = CGRectMake(0.0f, topOffset, screenSize.width, _separatorView.frame.size.height);
    
    _titleLabel.frame = CGRectMake(CGFloor((screenSize.width - _titleLabel.frame.size.width) / 2), titleLabelOffset, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    CGSize noticeSize = [_noticeLabel sizeThatFits:CGSizeMake(300, screenSize.height)];
    CGRect noticeFrame = CGRectMake(0, 0, noticeSize.width, noticeSize.height);
    _noticeLabel.frame = CGRectIntegral(CGRectOffset(noticeFrame, (screenSize.width - noticeFrame.size.width) / 2, _separatorView.frame.origin.y + ([TGViewController isWidescreen] ? 85.0f : 70.0f)));
    
    _fieldSeparatorView.frame = CGRectMake(22 + sideInset, _separatorView.frame.origin.y + 60.0f, screenSize.width - 44 - sideInset * 2.0f, TGIsRetina() ? 0.5f : 1.0f);
    
    _codeField.frame = CGRectMake(sideInset, _fieldSeparatorView.frame.origin.y - 56.0f, screenSize.width - sideInset * 2.0f, 56.0f);
    
    CGFloat labelAnchor = _separatorView.frame.origin.y + ([TGViewController isWidescreen] ? 160 : 134);
    
    _timeoutLabel.frame = CGRectMake((int)((screenSize.width - _timeoutLabel.frame.size.width) / 2), labelAnchor, _timeoutLabel.frame.size.width, _timeoutLabel.frame.size.height);
    _requestingCallLabel.frame = CGRectMake((int)((screenSize.width - _requestingCallLabel.frame.size.width) / 2), labelAnchor, _requestingCallLabel.frame.size.width, _requestingCallLabel.frame.size.height);
    _callSentLabel.frame = CGRectMake((int)((screenSize.width - _callSentLabel.frame.size.width) / 2), labelAnchor, _callSentLabel.frame.size.width, _callSentLabel.frame.size.height);
}

- (void)setInProgress:(bool)inProgress
{
    if (_inProgress != inProgress)
    {
        _inProgress = inProgress;
        
        if (inProgress)
        {
            if (_progressWindow == nil)
            {
                _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [_progressWindow show:true];
            }
        }
        else
        {
            if (_progressWindow != nil)
            {
                [_progressWindow dismiss:true];
                _progressWindow = nil;
            }
        }
    }
}

#pragma mark -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_inProgress)
        return false;
    
    if (textField == _codeField)
    {
        NSString *replacementString = string;
        
        int length = replacementString.length;
        for (int i = 0; i < length; i++)
        {
            unichar c = [replacementString characterAtIndex:i];
            if (c < '0' || c > '9')
                return false;
        }
        
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:replacementString];
        if (newText.length > 5)
            return false;
        
        textField.text = newText;
        
        if (newText.length == 5)
            [self nextButtonPressed];
        
        return false;
    }
    
    return true;
}

#pragma mark -

- (void)backgroundTapped:(UITapGestureRecognizer *)recognizer
{
    return;
    
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_codeField resignFirstResponder];
    }
}

- (void)inputBackgroundTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_codeField becomeFirstResponder];
    }
}

- (void)shakeView:(UIView *)v originalX:(CGFloat)originalX
{
    CGRect r = v.frame;
    r.origin.x = originalX;
    CGRect originalFrame = r;
    CGRect rFirst = r;
    rFirst.origin.x = r.origin.x + 4;
    r.origin.x = r.origin.x - 4;
    
    v.frame = v.frame;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionAutoreverse animations:^
    {
        v.frame = rFirst;
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            [UIView animateWithDuration:0.05 delay:0.0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse) animations:^
            {
                [UIView setAnimationRepeatCount:3];
                v.frame = r;
            } completion:^(__unused BOOL finished)
            {
                v.frame = originalFrame;
            }];
        }
        else
            v.frame = originalFrame;
    }];
}

- (void)applyCode:(NSString *)code
{
    _codeField.text = code;
    [self nextButtonPressed];
}

- (void)nextButtonPressed
{
    if (_inProgress)
        return;
    
    if (_codeField.text.length == 0)
    {
        CGFloat sideInset = 0.0f;
        if (TGIsPad())
        {
            sideInset = 130.0f;
        }

        [self shakeView:_codeField originalX:sideInset];
    }
    else
    {
        self.inProgress = true;
        
        static int actionIndex = 0;
        _currentActionIndex = actionIndex++;
        _phoneCode = _codeField.text;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/service/auth/signIn/(%d)", _currentActionIndex] options:[NSDictionary dictionaryWithObjectsAndKeys:_phoneNumber, @"phoneNumber", _codeField.text, @"phoneCode", _phoneCodeHash, @"phoneCodeHash", nil] watcher:self];
    }
}

#pragma mark -

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/activation"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.inProgress = false;
            
            if ([((SGraphObjectNode *)resource).object boolValue])
                [TGAppDelegateInstance presentMainController];
            else
            {
                if (![[self.navigationController.viewControllers lastObject] isKindOfClass:[TGLoginInactiveUserController class]])
                {
                    TGLoginInactiveUserController *inactiveUserController = [[TGLoginInactiveUserController alloc] init];
                    [self pushControllerRemovingSelf:inactiveUserController];
                }
            }
        });
    }
    else if ([path isEqualToString:@"/tg/contactListSynchronizationState"])
    {
        if (![((SGraphObjectNode *)resource).object boolValue])
        {
            bool activated = [TGDatabaseInstance() haveRemoteContactUids];
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                self.inProgress = false;
                
                if (activated)
                    [TGAppDelegateInstance presentMainController];
                else
                {
                    if (![[self.navigationController.viewControllers lastObject] isKindOfClass:[TGLoginInactiveUserController class]])
                    {
                        TGLoginInactiveUserController *inactiveUserController = [[TGLoginInactiveUserController alloc] init];
                        [self pushControllerRemovingSelf:inactiveUserController];
                    }
                }
            });
        }
    }
}

- (void)pushControllerRemovingSelf:(UIViewController *)controller
{
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[self.navigationController viewControllers]];
    [viewControllers removeObject:self];
    [viewControllers addObject:controller];
    [self.navigationController setViewControllers:viewControllers animated:true];
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    if ([path isEqualToString:[NSString stringWithFormat:@"/tg/service/auth/signIn/(%d)", _currentActionIndex]])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {   
            if (resultCode == ASStatusSuccess)
            {
                if ([[((SGraphObjectNode *)result).object objectForKey:@"activated"] boolValue])
                    [TGAppDelegateInstance presentMainController];
            }
            else
            {
                self.inProgress = false;
                
                NSString *errorText = TGLocalized(@"Login.UnknownError");
                bool setDelegate = false;
                
                if (resultCode == TGSignInResultNotRegistered)
                {
                    int stateDate = [[TGAppDelegateInstance loadLoginState][@"date"] intValue];
                    [TGAppDelegateInstance saveLoginStateWithDate:stateDate phoneNumber:_phoneNumber phoneCode:_phoneCode phoneCodeHash:_phoneCodeHash firstName:nil lastName:nil photo:nil];
                    
                    errorText = nil;
                    [self pushControllerRemovingSelf:[[TGLoginProfileController alloc] initWithShowKeyboard:_codeField.isFirstResponder phoneNumber:_phoneNumber phoneCodeHash:_phoneCodeHash phoneCode:_phoneCode]];
                }
                else if (resultCode == TGSignInResultTokenExpired)
                {
                    errorText = TGLocalized(@"Login.CodeExpiredError");
                    setDelegate = true;
                }
                else if (resultCode == TGSignInResultFloodWait)
                {
                    errorText = TGLocalized(@"Login.CodeFloodError");
                }
                else if (resultCode == TGSignInResultInvalidToken)
                {
                    errorText = TGLocalized(@"Login.InvalidCodeError");
                }
                
                if (errorText != nil)
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errorText delegate:setDelegate ? self : nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                    [alertView show];
                }
            }
        });
    }
    else if ([path hasPrefix:@"/tg/service/auth/sendCode/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (resultCode == ASStatusSuccess)
            {
                [UIView animateWithDuration:0.2 animations:^
                {
                    _requestingCallLabel.alpha = 0.0f;
                }];
                
                [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^
                {
                    _callSentLabel.alpha = 1.0f;
                } completion:nil];
            }
            else
            {
                NSString *errorText = TGLocalized(@"Login.NetworkError");
                
                if (resultCode == TGSendCodeErrorInvalidPhone)
                    errorText = TGLocalized(@"Login.InvalidPhoneError");
                else if (resultCode == TGSendCodeErrorFloodWait)
                    errorText = TGLocalized(@"Login.CodeFloodError");
                else if (resultCode == TGSendCodeErrorNetwork)
                    errorText = TGLocalized(@"Login.NetworkError");
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errorText delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                [alertView show];
            }
        });
    }
}

- (void)alertView:(UIAlertView *)__unused alertView clickedButtonAtIndex:(NSInteger)__unused buttonIndex
{
    [self.navigationController popViewControllerAnimated:true];
}

@end
