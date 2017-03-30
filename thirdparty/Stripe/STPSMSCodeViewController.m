//
//  STPSMSCodeViewController.m
//  Stripe
//
//  Created by Jack Flintermann on 5/10/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPSMSCodeViewController.h"
#import "STPSMSCodeTextField.h"
#import "STPCheckoutAPIClient.h"
#import "STPTheme.h"
#import "STPPaymentActivityIndicatorView.h"
#import "StripeError.h"
#import "UIBarButtonItem+Stripe.h"
#import "UIViewController+Stripe_KeyboardAvoiding.h"
#import "STPPhoneNumberValidator.h"
#import "STPColorUtils.h"
#import "STPWeakStrongMacros.h"
#import "STPLocalizationUtils.h"

@interface STPSMSCodeViewController()<STPSMSCodeTextFieldDelegate>

@property(nonatomic)STPCheckoutAPIClient *checkoutAPIClient;
@property(nonatomic)STPCheckoutAPIVerification *verification;
@property(nonatomic)NSString *redactedPhone;
@property(nonatomic)NSTimer *hideSMSSentLabelTimer;

@property(nonatomic, weak)UIScrollView *scrollView;
@property(nonatomic, weak)UILabel *topLabel;
@property(nonatomic, weak)STPSMSCodeTextField *codeField;
@property(nonatomic, weak)UILabel *bottomLabel;
@property(nonatomic, weak)UIButton *cancelButton;
@property(nonatomic, weak)UILabel *errorLabel;
@property(nonatomic, weak)UILabel *smsSentLabel;
@property(nonatomic, weak)UIButton *pasteFromClipboardButton;
@property(nonatomic, weak)STPPaymentActivityIndicatorView *activityIndicator;
@property(nonatomic)BOOL loading;

@end

@implementation STPSMSCodeViewController

- (instancetype)initWithCheckoutAPIClient:(STPCheckoutAPIClient *)checkoutAPIClient
                             verification:(STPCheckoutAPIVerification *)verification
                            redactedPhone:(NSString *)redactedPhone {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _checkoutAPIClient = checkoutAPIClient;
        _verification = verification;
        _redactedPhone = redactedPhone;
        _theme = [STPTheme new];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.title = STPLocalizedString(@"Verification Code", 
                                                   @"Title for SMS verification code screen");
    
    UIScrollView *scrollView = [UIScrollView new];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    UILabel *topLabel = [UILabel new];
    topLabel.text = STPLocalizedString(@"Enter the verification code to use the payment info you stored with Stripe.", nil);
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.numberOfLines = 0;
    [self.scrollView addSubview:topLabel];
    self.topLabel = topLabel;
    
    STPSMSCodeTextField *codeField = [STPSMSCodeTextField new];
    [self.scrollView addSubview:codeField];
    codeField.delegate = self;
    self.codeField = codeField;
    
    UILabel *bottomLabel = [UILabel new];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.text = STPLocalizedString(@"Didn't receive the code?", 
                                          @"Button on SMS verification screen if the user did not receive the SMS code.");
    bottomLabel.alpha = 0;
    [self.scrollView addSubview:bottomLabel];
    self.bottomLabel = bottomLabel;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [cancelButton setTitle:STPLocalizedString(@"Fill in your card details manually", 
                                              @"Cancel button for Remember Me SMS verification screen.") 
                  forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.alpha = 0;
    [self.scrollView addSubview:cancelButton];
    self.cancelButton = cancelButton;
    
    UILabel *errorLabel = [UILabel new];
    errorLabel.textAlignment = NSTextAlignmentCenter;
    errorLabel.alpha = 0;
    errorLabel.text = STPLocalizedString(@"Invalid Code", 
                                         @"Message shown when the user enters an incorrect SMS verification code.");
    [self.scrollView addSubview:errorLabel];
    self.errorLabel = errorLabel;

    UILabel *smsSentLabel = [UILabel new];
    smsSentLabel.textAlignment = NSTextAlignmentCenter;
    smsSentLabel.numberOfLines = 2;
    NSString *sentString = STPLocalizedString(@"We just sent a text message to: %@", 
                                              @"Message shown after sending SMS verification code. The substitution is a phone number.");
    smsSentLabel.text = [NSString stringWithFormat:sentString, 
                         [STPPhoneNumberValidator formattedRedactedPhoneNumberForString:self.redactedPhone]];
    [self.scrollView addSubview:smsSentLabel];
    self.smsSentLabel = smsSentLabel;
    
    UIButton *pasteFromClipboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    pasteFromClipboardButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [pasteFromClipboardButton setTitle:STPLocalizedString(@"Paste copied code?", 
                                                          @"Button to paste a copied SMS code into the verification field.") 
                              forState:UIControlStateNormal];
    [pasteFromClipboardButton addTarget:self action:@selector(pasteCodeFromClipboard) forControlEvents:UIControlEventTouchUpInside];
    pasteFromClipboardButton.alpha = 0;
    pasteFromClipboardButton.hidden = YES;
    [self.scrollView addSubview:pasteFromClipboardButton];
    self.pasteFromClipboardButton = pasteFromClipboardButton;
    
    STPPaymentActivityIndicatorView *activityIndicator = [STPPaymentActivityIndicatorView new];
    [self.scrollView addSubview:activityIndicator];
    _activityIndicator = activityIndicator;
    [self updateAppearance];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self 
                           selector:@selector(applicationDidBecomeActive) 
                               name:UIApplicationDidBecomeActiveNotification 
                             object:nil];
}

- (void)applicationDidBecomeActive {
    if (self.view.superview != nil) {
        NSString *pasteboardString = [UIPasteboard generalPasteboard].string;
        BOOL clipboardIsCode = NO;
        if (pasteboardString.length == 6) {
            NSCharacterSet *invalidCharacterset = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"].invertedSet;
            clipboardIsCode = [pasteboardString rangeOfCharacterFromSet:invalidCharacterset].location == NSNotFound;
        }

        [self setPasteFromClipboardButtonVisible:clipboardIsCode];
    }
}

- (void)setTheme:(STPTheme *)theme {
    _theme = theme;
    [self updateAppearance];
}

- (void)updateAppearance {
    [self.navigationItem.leftBarButtonItem stp_setTheme:self.theme];
    [self.navigationItem.rightBarButtonItem stp_setTheme:self.theme];
    self.view.backgroundColor = self.theme.primaryBackgroundColor;
    self.topLabel.font = self.theme.smallFont;
    self.topLabel.textColor = self.theme.secondaryForegroundColor;
    self.codeField.theme = self.theme;
    self.bottomLabel.font = self.theme.smallFont;
    self.bottomLabel.textColor = self.theme.secondaryForegroundColor;
    self.cancelButton.tintColor = self.theme.accentColor;
    self.cancelButton.titleLabel.font = self.theme.smallFont;
    self.errorLabel.font = self.theme.smallFont;
    self.errorLabel.textColor = self.theme.errorColor;
    self.smsSentLabel.font = self.theme.smallFont;
    self.smsSentLabel.textColor = self.theme.secondaryForegroundColor;
    self.pasteFromClipboardButton.tintColor = self.theme.accentColor;
    self.pasteFromClipboardButton.titleLabel.font = self.theme.smallFont;
    self.activityIndicator.tintColor = self.theme.accentColor;
    if ([STPColorUtils colorIsBright:self.theme.primaryBackgroundColor]) {
        self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    } else {
        self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return ([STPColorUtils colorIsBright:self.theme.primaryBackgroundColor] 
            ? UIStatusBarStyleDefault
            : UIStatusBarStyleLightContent);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    
    CGFloat padding = 20.0f;
    CGFloat contentWidth = self.view.bounds.size.width - (padding * 2);
    
    CGSize topLabelSize = [self.topLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    self.topLabel.frame = CGRectMake(padding, 40, contentWidth, topLabelSize.height);
    
    self.codeField.frame = CGRectMake(padding, CGRectGetMaxY(self.topLabel.frame) + padding, contentWidth, 76);
    
    CGSize pasteFromClipboardButtonSize = [self.pasteFromClipboardButton sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    self.pasteFromClipboardButton.frame = CGRectMake(padding, CGRectGetMaxY(self.codeField.frame) + padding, contentWidth, pasteFromClipboardButtonSize.height);
    
    CGFloat bottomLabelTop = (CGRectGetMaxY(self.pasteFromClipboardButton.hidden 
                                            ? self.codeField.frame
                                            : self.pasteFromClipboardButton.frame)
                              + padding);
    
    CGSize bottomLabelSize = [self.bottomLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    self.bottomLabel.frame = CGRectMake(padding, 
                                        bottomLabelTop, 
                                        contentWidth, 
                                        bottomLabelSize.height);
    self.errorLabel.frame = self.bottomLabel.frame;
    
    self.cancelButton.frame = CGRectOffset(self.errorLabel.frame, 0, self.errorLabel.frame.size.height + 2);

    CGSize smsSentLabelSize = [self.smsSentLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    self.smsSentLabel.frame = CGRectMake(padding, self.bottomLabel.frame.origin.y, contentWidth, smsSentLabelSize.height);
    
    CGFloat activityIndicatorWidth = 30.0f;
    self.activityIndicator.frame = CGRectMake((self.view.bounds.size.width - activityIndicatorWidth) / 2, CGRectGetMaxY(self.cancelButton.frame) + 20, activityIndicatorWidth, activityIndicatorWidth);
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), 
                                             [self contentMaxY]);
}

- (CGFloat)contentMaxY {
    return ((self.activityIndicator.animating 
             ? CGRectGetMaxY(self.activityIndicator.frame) 
             : CGRectGetMaxY(self.cancelButton.frame)) 
            + 2);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    WEAK(self);
    [self stp_beginObservingKeyboardAndInsettingScrollView:self.scrollView
                                             onChangeBlock:^(__unused CGRect keyboardFrame, __unused UIView * _Nullable currentlyEditedField) {
                                                 STRONG(self);
                                                 CGFloat scrollOffsetY = self.scrollView.contentOffset.y + self.scrollView.contentInset.top;
                                                 CGFloat topLabelDistanceFromOffset = CGRectGetMinY(self.topLabel.frame) - scrollOffsetY;
                                                 
                                                 if (topLabelDistanceFromOffset > 0
                                                     && [self contentMaxY] > self.scrollView.contentOffset.y + CGRectGetHeight(self.scrollView.bounds) - self.scrollView.contentInset.bottom) {
                                                     // We have extra whitespace on top but the bottom of our content is cut off, so scroll a bit
                                                     
                                                     CGPoint contentOffset = self.scrollView.contentOffset;
                                                     contentOffset.y += (topLabelDistanceFromOffset - 2);
                                                     self.scrollView.contentOffset = contentOffset;
                                                 }
                                             }];
    [self.codeField becomeFirstResponder];
    self.hideSMSSentLabelTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(hideSMSSentLabel) userInfo:nil repeats:NO];
}

- (void)hideSMSSentLabel {
    [UIView animateWithDuration:0.2f delay:0 options:0 animations:^{
        self.bottomLabel.alpha = 1.0f;
        self.cancelButton.alpha = 1.0f;
        self.smsSentLabel.alpha = 0;
    } completion:nil];
}

- (void)codeTextField:(STPSMSCodeTextField *)codeField
         didEnterCode:(NSString *)code {
    WEAK(self);
    self.loading = YES;
    [self.codeField resignFirstResponder];
    STPCheckoutAPIClient *client = self.checkoutAPIClient;
    [[[client submitSMSCode:code forVerification:self.verification] onSuccess:^(STPCheckoutAccount *account) {
        STRONG(self);
        [self.delegate smsCodeViewController:self didAuthenticateAccount:account];
    }] onFailure:^(NSError *error) {
        STRONG(self);
        if (!self) {
            return;
        }
        self.loading = NO;
        BOOL tooManyTries = error.code == STPCheckoutTooManyAttemptsError;
        if (tooManyTries) {
            self.errorLabel.text = STPLocalizedString(@"Too many incorrect attempts", 
                                                      @"Error message when failing to type in SMS code for Remember me too many times.");
        }
        [codeField shakeAndClear];
        [self.hideSMSSentLabelTimer invalidate];
        [UIView animateWithDuration:0.2f animations:^{
            self.smsSentLabel.alpha = 0;
            self.bottomLabel.alpha = 0;
            self.cancelButton.alpha = 0;
            self.errorLabel.alpha = 1.0f;
        }];
        [UIView animateWithDuration:0.2f delay:0.3f options:0 animations:^{
            self.bottomLabel.alpha = 1.0f;
            self.cancelButton.alpha = 1.0f;
            self.errorLabel.alpha = 0;
        } completion:^(__unused BOOL finished) {
            [self.codeField becomeFirstResponder];
            if (tooManyTries) {
                [self.delegate smsCodeViewControllerDidCancel:self];
            }
        }];
    }];
}

- (void)setLoading:(BOOL)loading {
    if (loading == _loading) {
        return;
    }
    _loading = loading;
    [self.activityIndicator setAnimating:loading animated:YES];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), 
                                             [self contentMaxY]);
    self.navigationItem.leftBarButtonItem.enabled = !loading;
    self.cancelButton.enabled = !loading;
}

- (void)cancel {
    [self.codeField resignFirstResponder];
    [self.delegate smsCodeViewControllerDidCancel:self];
}

- (void)setPasteFromClipboardButtonVisible:(BOOL)isVisible {
    if (isVisible == self.pasteFromClipboardButton.hidden) {
        [UIView animateWithDuration:0.2f delay:0 options:0 animations:^{
            self.pasteFromClipboardButton.hidden = !isVisible;
            self.pasteFromClipboardButton.alpha = isVisible ? 1 : 0;
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

- (void)pasteCodeFromClipboard {
    self.codeField.code = [UIPasteboard generalPasteboard].string;
    [UIPasteboard generalPasteboard].string = @"";
    [self setPasteFromClipboardButtonVisible:NO];
    [self codeTextField:self.codeField
           didEnterCode:self.codeField.code];
}

@end
