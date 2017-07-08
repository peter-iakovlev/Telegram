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

#import "TGModernButton.h"

#import "TGAlertView.h"

#import <MessageUI/MessageUI.h>

#import "TGLoginPasswordController.h"

#import "TGTwoStepConfigSignal.h"

#import "TGAccountSignals.h"

@interface TGLoginCodeController () <UITextFieldDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>
{
    bool _dismissing;
    bool _alreadyCountedDown;
    
    UILabel *_titleLabel;
    UIView *_fieldSeparatorView;
    
    bool _didDisappear;
    
    SMetaDisposable *_twoStepConfigDisposable;
    
    UIImageView *_otherDeviceView;
}

@property (nonatomic) NSTimeInterval phoneTimeout;

@property (nonatomic, strong) UILabel *noticeLabel;

@property (nonatomic, strong) TGTextField *codeField;

@property (nonatomic) CGRect baseInputBackgroundViewFrame;
@property (nonatomic) CGRect baseCodeFieldFrame;

@property (nonatomic, strong) UILabel *timeoutLabel;
@property (nonatomic, strong) UILabel *requestingCallLabel;
@property (nonatomic, strong) UILabel *callSentLabel;

@property (nonatomic, strong) TGModernButton *didNotReceiveCodeButton;

@property (nonatomic) bool inProgress;
@property (nonatomic) int currentActionIndex;

@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic) NSTimeInterval countdownStart;

@property (nonatomic, strong) UIAlertView *currentAlert;

@property (nonatomic, strong) TGProgressWindow *progressWindow;

@property (nonatomic) bool messageSentToTelegram;
@property (nonatomic) bool messageSentViaPhone;

@end

@implementation TGLoginCodeController

- (id)initWithShowKeyboard:(bool)__unused showKeyboard phoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash phoneTimeout:(NSTimeInterval)phoneTimeout messageSentToTelegram:(bool)messageSentToTelegram messageSentViaPhone:(bool)messageSentViaPhone
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _twoStepConfigDisposable = [[SMetaDisposable alloc] init];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _phoneNumber = phoneNumber;
        _phoneCodeHash = phoneCodeHash;
        _phoneTimeout = phoneTimeout;
        _messageSentToTelegram = messageSentToTelegram;
        _messageSentViaPhone = messageSentViaPhone;
        
#ifdef DEBUG
        _phoneTimeout = 60.0;
#endif
        
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
    
    [_twoStepConfigDisposable dispose];
}

- (bool)shouldBeRemovedFromNavigationAfterHiding
{
    return true;
}

- (void)makeLabelWithFormattedText:(UILabel *)textLabel text:(NSString *)text
{
    NSMutableArray *boldRanges = [[NSMutableArray alloc] init];
    
    NSMutableString *cleanText = [[NSMutableString alloc] initWithString:text];
    while (true)
    {
        NSRange startRange = [cleanText rangeOfString:@"**"];
        if (startRange.location == NSNotFound)
            break;
        
        [cleanText deleteCharactersInRange:startRange];
        
        NSRange endRange = [cleanText rangeOfString:@"**"];
        if (endRange.location == NSNotFound)
            break;
        
        [cleanText deleteCharactersInRange:endRange];
        
        [boldRanges addObject:[NSValue valueWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location)]];
    }
    
    if ([textLabel respondsToSelector:@selector(setAttributedText:)])
    {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 1;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentCenter;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cleanText attributes:@{
                                                                                                                               NSFontAttributeName: textLabel.font,
                                                                                                                               NSForegroundColorAttributeName: textLabel.textColor
                                                                                                                               }];
        
        [attributedString addAttributes:@{NSParagraphStyleAttributeName: style} range:NSMakeRange(0, attributedString.length)];
        
        NSDictionary *boldAttributes = @{NSFontAttributeName: TGMediumSystemFontOfSize(17.0f)};
        for (NSValue *nRange in boldRanges)
        {
            [attributedString addAttributes:boldAttributes range:[nRange rangeValue]];
        }
        
        textLabel.attributedText = attributedString;
    }
    else
        textLabel.text = cleanText;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = TGIsPad() ? TGUltralightSystemFontOfSize(48.0f) : TGLightSystemFontOfSize(30.0f);
    _titleLabel.text = [TGPhoneUtils formatPhone:_phoneNumber forceInternational:true];
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(CGCeil((screenSize.width - _titleLabel.frame.size.width) / 2), [TGViewController isWidescreen] ? 71.0f : 48.0f, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    [self.view addSubview:_titleLabel];
    
    _noticeLabel = [[UILabel alloc] init];
    _noticeLabel.font = TGSystemFontOfSize(16);
    _noticeLabel.textColor = [UIColor blackColor];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    _noticeLabel.contentMode = UIViewContentModeCenter;
    _noticeLabel.numberOfLines = 0;
    [self makeLabelWithFormattedText:_noticeLabel text:_messageSentToTelegram ? TGLocalized(@"Login.CodeSentInternal") : (_messageSentViaPhone ? TGLocalized(@"Login.CodeSentCall") : TGLocalized(@"Login.CodeSentSms"))];
   
    _noticeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_noticeLabel];
    
    CGSize noticeSize = [_noticeLabel sizeThatFits:CGSizeMake(300, screenSize.height)];
    CGRect noticeFrame = CGRectMake(0, 0, noticeSize.width, noticeSize.height);
    _noticeLabel.frame = noticeFrame;

    _fieldSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(22, 0.0f, screenSize.width - 44, TGScreenPixel)];
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
    _timeoutLabel.text = [TGStringUtils stringWithLocalizedNumberCharacters:[[NSString alloc] initWithFormat:(_messageSentViaPhone ? TGLocalized(@"Login.SmsRequestState1") : TGLocalized(@"Login.CallRequestState1")), 1, 0]];
    _timeoutLabel.backgroundColor = [UIColor clearColor];
    [_timeoutLabel sizeToFit];
    [self.view addSubview:_timeoutLabel];
    
    _requestingCallLabel = [[UILabel alloc] init];
    _requestingCallLabel.font = TGSystemFontOfSize(17);
    _requestingCallLabel.textColor = UIColorRGB(0x999999);
    _requestingCallLabel.textAlignment = NSTextAlignmentCenter;
    _requestingCallLabel.contentMode = UIViewContentModeCenter;
    _requestingCallLabel.numberOfLines = 0;
    _requestingCallLabel.text = (_messageSentViaPhone ? TGLocalized(@"Login.SmsRequestState2") : TGLocalized(@"Login.CallRequestState2"));
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
    
    _timeoutLabel.hidden = _messageSentToTelegram || _phoneTimeout >= (3600.0 - DBL_EPSILON);
    
    NSString *codeTextFormat = (_messageSentViaPhone ? TGLocalized(@"Login.SmsRequestState3") : TGLocalized(@"Login.CallRequestState3"));
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
    
    [_callSentLabel sizeToFit];
    [self.view addSubview:_callSentLabel];
    
    _didNotReceiveCodeButton = [[TGModernButton alloc] init];
    [_didNotReceiveCodeButton setTitleColor:TGAccentColor()];
    [_didNotReceiveCodeButton setTitle:TGLocalized(@"Login.HaveNotReceivedCodeInternal") forState:UIControlStateNormal];
    [_didNotReceiveCodeButton setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    _didNotReceiveCodeButton.titleLabel.font = TGSystemFontOfSize(16.0f);
    [self.view addSubview:_didNotReceiveCodeButton];
    [_didNotReceiveCodeButton addTarget:self action:@selector(didNotReceiveCodeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _didNotReceiveCodeButton.hidden = !_messageSentToTelegram;
    
    CGFloat labelAnchor = 0.0f;
    
    _timeoutLabel.frame = CGRectMake((int)((screenSize.width - _timeoutLabel.frame.size.width) / 2), labelAnchor, _timeoutLabel.frame.size.width, _timeoutLabel.frame.size.height);
    _requestingCallLabel.frame = CGRectMake((int)((screenSize.width - _requestingCallLabel.frame.size.width) / 2), labelAnchor, _requestingCallLabel.frame.size.width, _requestingCallLabel.frame.size.height);
    _callSentLabel.frame = CGRectMake((int)((screenSize.width - _callSentLabel.frame.size.width) / 2), labelAnchor, _callSentLabel.frame.size.width, _callSentLabel.frame.size.height);
    
    if (_messageSentToTelegram) {
        _otherDeviceView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginCodeOtherDevice.png"]];
        [self.view addSubview:_otherDeviceView];
    }
    
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
                [composeController setToRecipients:@[@"sms@stel.com"]];
                [composeController setSubject:[[NSString alloc] initWithFormat:TGLocalized(@"Login.EmailCodeSubject"), phoneFormatted]];
                [composeController setMessageBody:[[NSString alloc] initWithFormat:TGLocalized(@"Login.EmailCodeBody"), phoneFormatted] isHTML:false];
                [self presentViewController:composeController animated:true completion:nil];
            }
            else
            {
                [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Login.EmailNotConfiguredError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
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
    if (_countdownTimer == nil && !_alreadyCountedDown && !_messageSentToTelegram)
    {
        _countdownStart = CFAbsoluteTimeGetCurrent();
        _countdownTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateCountdown) interval:1.0 repeat:false];
    }
    
    [self updateInterface:self.interfaceOrientation];
    
    if (_didDisappear)
        [_codeField becomeFirstResponder];
    
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_dismissing)
    {
        [TGAppDelegateInstance resetLoginState];
    }
    
    _didDisappear = true;
    
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
    
    int timeout = (int)_phoneTimeout;
    
    NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
    NSTimeInterval remainingTime = (_countdownStart + timeout) - currentTime;
    
    if (remainingTime < 0)
        remainingTime = 0;
    
    _timeoutLabel.text = [TGStringUtils stringWithLocalizedNumberCharacters:[NSString stringWithFormat:(_messageSentViaPhone ? TGLocalized(@"Login.SmsRequestState1") : TGLocalized(@"Login.CallRequestState1")), ((int)remainingTime) / 60, ((int)remainingTime) % 60]];
    CGSize size = [_timeoutLabel.text sizeWithFont:_timeoutLabel.font];
    _timeoutLabel.frame = CGRectMake(_timeoutLabel.frame.origin.x, _timeoutLabel.frame.origin.y, size.width, size.height);
    [self updateInterface:self.interfaceOrientation];
    
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
    CGFloat sideInset = 0.0f;
    CGFloat didNotReceiveCodeOffset = 0.0f;
    CGFloat timeoutOffset = 0.0f;
    CGFloat otherDeviceOffset = 0.0f;
    
    if (TGIsPad())
    {
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            if (_otherDeviceView != nil) {
                otherDeviceOffset = 64.0f;
                titleLabelOffset = 94.0f + 48.0f;
                noticeLabelOffset = 175.0f + 40.0f;
                topOffset = 310.0f + 40.0f;
            } else {
                titleLabelOffset = 94.0f;
                noticeLabelOffset = 175.0f;
                topOffset = 310.0f;
            }
            if (_noticeLabel.frame.size.height < 35.0f) {
                topOffset -= 0.0f;
            }
            didNotReceiveCodeOffset = 660.0f;
            timeoutOffset = 660.0f;
        }
        else
        {
            otherDeviceOffset = -1000.0f;
            titleLabelOffset = 54.0f;
            noticeLabelOffset = 125.0f;
            topOffset = 180.0f;
        
            if (_noticeLabel.frame.size.height < 35.0f) {
                topOffset -= 8.0f;
            }
            didNotReceiveCodeOffset = 320.0f;
            timeoutOffset = 320.0f;
        }
        
        sideInset = 130.0f;
    }
    else
    {
        topOffset = [TGViewController isWidescreen] ? 131.0f : 90.0f;
        titleLabelOffset = ([TGViewController isWidescreen] ? 71.0f : 48.0f) + 9.0f;
        noticeLabelOffset = 100.0f;
        topOffset = 120.0f;
        
        if (screenSize.height < 481.0f) {
            otherDeviceOffset = -1000.0f;
            titleLabelOffset = 52.0f;
            noticeLabelOffset = 95.0f;
            topOffset = 138.0f;
            if (_noticeLabel.frame.size.height < 35.0f) {
                topOffset -= 13.0f;
            }
            didNotReceiveCodeOffset = 215.0f;
            timeoutOffset = 215.0f;
        } else if (screenSize.height < 569.0f) {
            otherDeviceOffset = -1000.0f;
            titleLabelOffset = 68.0f;
            noticeLabelOffset = 115.0f;
            topOffset = 178.0f;
            if (_noticeLabel.frame.size.height < 35.0f) {
                topOffset -= 13.0f;
            }
            didNotReceiveCodeOffset = 290.0f;
            timeoutOffset = 290.0f;
        } else if (screenSize.height < 668.0f) {
            if (_otherDeviceView != nil) {
                otherDeviceOffset = 54.0f;
                titleLabelOffset = 74.0f + 48.0f;
                noticeLabelOffset = 135.0f + 40.0f;
                topOffset = 220.0f + 40.0f;
            } else {
                titleLabelOffset = 74.0f;
                noticeLabelOffset = 135.0f;
                topOffset = 220.0f;
            }
            if (_noticeLabel.frame.size.height < 35.0f) {
                topOffset -= 8.0f;
            }
            didNotReceiveCodeOffset = 388.0f;
            timeoutOffset = 388.0f;
        } else {
            if (_otherDeviceView != nil) {
                otherDeviceOffset = 64.0f;
                titleLabelOffset = 94.0f + 48.0f;
                noticeLabelOffset = 155.0f + 40.0f;
                topOffset = 270.0f + 40.0f;
            } else {
                titleLabelOffset = 84.0f;
                noticeLabelOffset = 155.0f;
                topOffset = 270.0f;
            }
            if (_noticeLabel.frame.size.height < 35.0f) {
                topOffset -= 8.0f;
            }
            didNotReceiveCodeOffset = 460.0f;
            timeoutOffset = 460.0f;
        }
    }
    
    if (_otherDeviceView != nil) {
        _otherDeviceView.frame = CGRectMake(CGFloor((screenSize.width - _otherDeviceView.frame.size.width) / 2.0f), otherDeviceOffset, _otherDeviceView.frame.size.width, _otherDeviceView.frame.size.height);
    }
    
    _titleLabel.frame = CGRectMake(CGCeil((screenSize.width - _titleLabel.frame.size.width) / 2), titleLabelOffset, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    CGSize noticeSize = [_noticeLabel sizeThatFits:CGSizeMake(300, screenSize.height)];
    CGRect noticeFrame = CGRectMake(0, 0, noticeSize.width, noticeSize.height);
    _noticeLabel.frame = CGRectIntegral(CGRectOffset(noticeFrame, (screenSize.width - noticeFrame.size.width) / 2, noticeLabelOffset));
    
    _fieldSeparatorView.frame = CGRectMake(22 + sideInset, topOffset + 60.0f, screenSize.width - 44 - sideInset * 2.0f, TGScreenPixel);
    
    _codeField.frame = CGRectMake(sideInset, _fieldSeparatorView.frame.origin.y - 56.0f, screenSize.width - sideInset * 2.0f, 56.0f);
    
    CGFloat labelAnchor = timeoutOffset;
    
    _timeoutLabel.frame = CGRectMake((int)((screenSize.width - _timeoutLabel.frame.size.width) / 2), labelAnchor, _timeoutLabel.frame.size.width, _timeoutLabel.frame.size.height);
    _requestingCallLabel.frame = CGRectMake((int)((screenSize.width - _requestingCallLabel.frame.size.width) / 2), labelAnchor, _requestingCallLabel.frame.size.width, _requestingCallLabel.frame.size.height);
    _callSentLabel.frame = CGRectMake((int)((screenSize.width - _callSentLabel.frame.size.width) / 2), labelAnchor, _callSentLabel.frame.size.width, _callSentLabel.frame.size.height);
    
    [_didNotReceiveCodeButton sizeToFit];
    _didNotReceiveCodeButton.frame = CGRectMake(CGCeil((screenSize.width - _didNotReceiveCodeButton.frame.size.width) / 2.0f), didNotReceiveCodeOffset, _didNotReceiveCodeButton.frame.size.width, _didNotReceiveCodeButton.frame.size.height);
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
        
        int length = (int)replacementString.length;
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
        _phoneCode = newText;
        
        if (newText.length == 5)
            [self nextButtonPressed];
        
        return false;
    }
    
    return true;
}

#pragma mark -

- (void)backgroundTapped:(UITapGestureRecognizer *)__unused recognizer
{
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
            else if (resultCode == TGSignInResultPasswordRequired)
            {
                __weak TGLoginCodeController *weakSelf = self;
                [_twoStepConfigDisposable setDisposable:[[[[TGTwoStepConfigSignal twoStepConfig] deliverOn:[SQueue mainQueue]] onDispose:^
                {
                    TGDispatchOnMainThread(^
                    {
                        [_progressWindow dismiss:true];
                    });
                }] startWithNext:^(TGTwoStepConfig *config)
                {
                    __strong TGLoginCodeController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:strongSelf.navigationController.viewControllers];
                        [viewControllers removeLastObject];
                        [viewControllers addObject:[[TGLoginPasswordController alloc] initWithConfig:config phoneNumber:strongSelf.phoneNumber phoneCode:strongSelf.phoneCode phoneCodeHash:strongSelf.phoneCodeHash]];
                        [strongSelf.navigationController setViewControllers:viewControllers animated:true];
                    }
                }]];
            }
            else
            {
                self.inProgress = false;
                
                NSString *errorText = TGLocalized(@"Login.UnknownError");
                bool setDelegate = false;
                
                if (resultCode == TGSignInResultNotRegistered)
                {
                    int stateDate = [[TGAppDelegateInstance loadLoginState][@"date"] intValue];
                    [TGAppDelegateInstance saveLoginStateWithDate:stateDate phoneNumber:_phoneNumber phoneCode:_phoneCode phoneCodeHash:_phoneCodeHash codeSentToTelegram:false codeSentViaPhone:false firstName:nil lastName:nil photo:nil resetAccountState:nil];
                    
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
                    TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:errorText delegate:setDelegate ? self : nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                    [alertView show];
                }
            }
        });
    }
    else if ([path hasPrefix:@"/tg/service/auth/sendCode/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self setInProgress:false];
            
            if (_messageSentToTelegram)
            {
                if (resultCode == ASStatusSuccess)
                {
                    int stateDate = [[TGAppDelegateInstance loadLoginState][@"date"] intValue];
                    [TGAppDelegateInstance saveLoginStateWithDate:stateDate phoneNumber:_phoneNumber phoneCode:nil phoneCodeHash:_phoneCodeHash codeSentToTelegram:false codeSentViaPhone:false firstName:nil lastName:nil photo:nil resetAccountState:nil];
                    
                    bool messageSentViaPhone = [(((SGraphObjectNode *)result).object)[@"messageSentViaPhone"] intValue];
                    
                    TGLoginCodeController *controller = [[TGLoginCodeController alloc] initWithShowKeyboard:(_codeField.isFirstResponder) phoneNumber:_phoneNumber phoneCodeHash:_phoneCodeHash phoneTimeout:_phoneTimeout messageSentToTelegram:false messageSentViaPhone:messageSentViaPhone];
                    
                    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
                    [viewControllers removeLastObject];
                    [viewControllers addObject:controller];
                    [self.navigationController setViewControllers:viewControllers animated:true];
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
                    else if (resultCode == TGSendCodeErrorPhoneFlood)
                        errorText = TGLocalized(@"Login.PhoneFloodError");
                    
                    TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:errorText delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                    [alertView show];
                }
            }
            else
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
                    else if (resultCode == TGSendCodeErrorPhoneFlood)
                        errorText = TGLocalized(@"Login.PhoneFloodError");
                    
                    TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:errorText delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                    [alertView show];
                }
            }
        });
    }
}

- (void)alertView:(UIAlertView *)__unused alertView clickedButtonAtIndex:(NSInteger)__unused buttonIndex
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)didNotReceiveCodeButtonPressed
{
    [self setInProgress:true];
    
    static int actionId = 0;
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/service/auth/sendCode/(sms%d)", actionId++] options:[[NSDictionary alloc] initWithObjectsAndKeys:_phoneNumber, @"phoneNumber", _phoneCodeHash, @"phoneHash", [[NSNumber alloc] initWithBool:true], @"requestSms", nil] watcher:self];
}

- (void)termsOfServiceTapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow showWithDelay:0.1];
        
        [[[[TGAccountSignals termsOfService] deliverOn:[SQueue mainQueue]] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
            });
        }] startWithNext:^(NSString *termsText) {
            if (NSClassFromString(@"UIAlertController") != nil) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                
                NSString *headerText = TGLocalized(@"Login.TermsOfServiceHeader");
                
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 5.0;
                style.lineBreakMode = NSLineBreakByWordWrapping;
                style.alignment = NSTextAlignmentLeft;
                
                NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%@\n\n%@", headerText, termsText] attributes:@{NSFontAttributeName: TGSystemFontOfSize(13.0f)}];
                [text addAttribute:NSFontAttributeName value:TGMediumSystemFontOfSize(17.0f) range:NSMakeRange(0, headerText.length)];
                
                [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(headerText.length + 2, text.length - headerText.length - 2)];
                
                [alertVC setValue:text forKey:@"attributedTitle"];
                
                UIAlertAction *button = [UIAlertAction actionWithTitle:TGLocalized(@"Common.OK") style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                }];
                
                [alertVC addAction:button];
                [self presentViewController:alertVC animated:true completion:nil];
            } else {
                [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Login.TermsOfServiceHeader") message:termsText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            }
        }];
    }
}

@end
