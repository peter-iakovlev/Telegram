#import "TGPassportEmailCodeController.h"

#import "TLMetaScheme.h"

#import "TGTelegramNetworking.h"
#import <LegacyComponents/TGProgressWindow.h>
#import "TGPassportSignals.h"

#import "TGTwoStepConfig.h"

#import "TGUsernameCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGCustomAlertView.h"

#import "TGPassportRequestController.h"

@interface TGPassportEmailCodeController ()
{
    NSString *_email;
    SVariable *_settings;
    SMetaDisposable *_disposable;
    bool _dismissed;
    
    UIBarButtonItem *_nextItem;
    
    TGUsernameCollectionItem *_codeItem;
}

@property (nonatomic, strong) void (^completionBlock)(TGPassportDecryptedValue *);

@end

@implementation TGPassportEmailCodeController

- (instancetype)initWithEmail:(NSString *)email settings:(SVariable *)settings completionBlock:(void (^)(TGPassportDecryptedValue *))completionBlock
{
    self = [super init];
    if (self != nil)
    {
        _email = email;
        _settings = settings;
        self.completionBlock = completionBlock;
        
        self.title = TGLocalized(@"Passport.Email.Title");
        
        _nextItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        _nextItem.enabled = false;
        [self setRightBarButtonItem:_nextItem];

        __weak TGPassportEmailCodeController *weakSelf = self;
        _codeItem = [[TGUsernameCollectionItem alloc] init];
        _codeItem.keyboardType = UIKeyboardTypeNumberPad;
        _codeItem.secureEntry = false;
        _codeItem.placeholder = TGLocalized(@"TwoStepAuth.RecoveryCode");
        _codeItem.title = TGLocalized(@"TwoStepAuth.RecoveryCode");
        _codeItem.username = @"";
        _codeItem.usernameChanged = ^(NSString *code)
        {
            __strong TGPassportEmailCodeController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf.navigationItem.rightBarButtonItem.enabled = code.length > 0;
                
                if (code.length == 6)
                    [strongSelf donePressed];
            }
        };
        _codeItem.usernameValid = true;
        _codeItem.returnPressed = ^(__unused id item) {
            __strong TGPassportEmailCodeController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf donePressed];
            }
        };
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:@[
            _codeItem,
            [[TGCommentCollectionItem alloc] initWithText:[NSString stringWithFormat:TGLocalized(@"Passport.Email.CodeHelp"), email]]
        ]];
        section.insets = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0f);
        [self.menuSections addSection:section];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _dismissed = true;
}

- (void)viewDidLayoutSubviews
{
    if (!_dismissed)
        [_codeItem becomeFirstResponder];
    
    [super viewDidLayoutSubviews];
}

- (void)donePressed
{
    if (_codeItem.username.length == 0)
        return;
    
    if (_disposable == nil)
        _disposable = [[SMetaDisposable alloc] init];
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow showWithDelay:0.3];
    
    NSString *email = _email;
    TGPassportDecryptedValue *value = [[TGPassportDecryptedValue alloc] initWithType:TGPassportTypeEmail data:nil frontSide:nil reverseSide:nil selfie:nil files:nil plainData:[[TGPassportEmailData alloc] initWithEmail:email]];
    
    SSignal *signal = [TGPassportSignals verifyEmail:email code:_codeItem.username];
    signal = [signal mapToSignal:^SSignal *(id next)
    {
        if ([next isKindOfClass:[NSNumber class]])
        {
            if ([next boolValue])
            {
                return [[_settings.signal take:1] mapToSignal:^SSignal *(TGPassportPasswordRequest *request)
                {
                    return [TGPassportSignals saveSecureValue:value secret:request.settings.secret];
                }];
            }
            else
            {
                return [SSignal fail:nil];
            }
        }
        
        return [SSignal single:next];
    }];
    
    __weak TGPassportEmailCodeController *weakSelf = self;
    [[signal deliverOn:[SQueue mainQueue]] startWithNext:^(TLSecureValue *next) {
        __strong TGPassportEmailCodeController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if ([next isKindOfClass:[TLSecureValue class]])
        {
            [progressWindow dismiss:true];
            
            strongSelf.completionBlock([value updateWithValueHash:next.n_hash]);
            
            TGPassportRequestController *passportRootController = nil;
            for (TGViewController *controller in strongSelf.navigationController.viewControllers)
            {
                if ([controller isKindOfClass:[TGPassportRequestController class]])
                {
                    passportRootController = (TGPassportRequestController *)controller;
                    break;
                }
            }
            if (passportRootController != nil)
                [strongSelf.navigationController popToViewController:passportRootController animated:true];
            else
                [strongSelf.navigationController popToRootViewControllerAnimated:true];
        }
    } error:^(id error)
    {
        [progressWindow dismiss:true];
        
        NSString *displayText = TGLocalized(@"TwoStepAuth.RecoveryCodeInvalid");
        
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorText hasPrefix:@"FLOOD_WAIT"])
            errorText = TGLocalized(@"TwoStepAuth.FloodError");
        //if ([error intValue] == TGTwoStepRecoveryErrorCodeExpired)
        //    errorText = TGLocalized(@"TwoStepAuth.RecoveryCodeExpired");
        
        [TGCustomAlertView presentAlertWithTitle:nil message:displayText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
    } completed:nil];
}

- (BOOL)shouldAutorotate
{
    return false;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
