#import "TGLoginPasswordController.h"

#import "ActionStage.h"

#import "TGLoginPasswordView.h"

#import "TGProgressWindow.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTContext.h>

#import "TGCheckPasswordActor.h"

#import "TGAlertView.h"

#import "TGLoginCodeController.h"
#import "TGLoginProfileController.h"

#import "TGPhoneUtils.h"

#import "TGPasswordRecoveryController.h"

#import "TGTwoStepConfigSignal.h"
#import "TGTwoStepRecoverySignals.h"
#import "TGAccountSignals.h"

#import "TGLoginResetAccountProtectedController.h"

@interface TGLoginPasswordController () <ASWatcher>
{
    TGTwoStepConfig *_config;
    NSString *_phoneNumber;
    NSString *_phoneCode;
    NSString *_phoneCodeHash;
    
    TGLoginPasswordView *_view;
    UIBarButtonItem *_doneItem;
    NSString *_currentPassword;
    
    TGProgressWindow *_progressWindow;
    
    SMetaDisposable *_requestRecoveryDisposable;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGLoginPasswordController

- (instancetype)init
{
    return [self initWithConfig:nil phoneNumber:nil phoneCode:nil phoneCodeHash:nil];
}

- (instancetype)initWithConfig:(TGTwoStepConfig *)config phoneNumber:(NSString *)phoneNumber phoneCode:(NSString *)phoneCode phoneCodeHash:(NSString *)phoneCodeHash
{
    self = [super init];
    if (self != nil)
    {
        _requestRecoveryDisposable = [[SMetaDisposable alloc] init];
        
        _config = config;
        _phoneNumber = phoneNumber;
        _phoneCode = phoneCode;
        _phoneCodeHash = phoneCodeHash;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        _doneItem.enabled = false;
        [self setRightBarButtonItem:_doneItem];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [_requestRecoveryDisposable dispose];
}

- (void)donePressed
{
    _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_progressWindow show:true];
    
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/checkPassword/(%d)", (int)_currentPassword.hash] options:@{@"password": _currentPassword == nil ? @"" : _currentPassword} flags:0 watcher:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_view setFirstReponder];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_view setFirstReponder];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _view = [[TGLoginPasswordView alloc] initWithFrame:self.view.bounds];
    _view.hint = _config.currentHint;
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    __weak TGLoginPasswordController *weakSelf = self;
    _view.passwordChanged = ^(NSString *password)
    {
        __strong TGLoginPasswordController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf->_currentPassword = password;
            strongSelf->_doneItem.enabled = password.length != 0;
        }
    };
    _view.forgotPassword = ^
    {
        __strong TGLoginPasswordController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf forgotPressed];
    };
    _view.resetPassword = ^
    {
        __strong TGLoginPasswordController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf resetPressed];
    };
    _view.checkPassword = ^
    {
        __strong TGLoginPasswordController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf donePressed];
    };
    [self.view addSubview:_view];
}

- (void)forgotPressed
{
    if (_config.hasRecovery)
    {
        __weak TGLoginPasswordController *weakSelf = self;
        
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [progressWindow show:true];
        
        [_requestRecoveryDisposable setDisposable:[[[[TGTwoStepRecoverySignals requestPasswordRecovery] deliverOn:[SQueue mainQueue]] onDispose:^
        {
            TGDispatchOnMainThread(^
            {
                [progressWindow dismiss:true];
            });
        }] startWithNext:^(NSString *emailPattern)
        {
            __strong TGLoginPasswordController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                TGPasswordRecoveryController *controller = [[TGPasswordRecoveryController alloc] initWithEmailPattern:emailPattern];
                controller.completion = ^(bool success, int32_t userId)
                {
                    __strong TGLoginPasswordController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        if (success)
                        {
                            [strongSelf dismissViewControllerAnimated:true completion:^
                            {
                                __strong TGLoginPasswordController *strongSelf = weakSelf;
                                [strongSelf _completedRestore:userId];
                            }];
                        }
                        else
                        {
                            [strongSelf dismissViewControllerAnimated:true completion:nil];
                            
                            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"TwoStepAuth.RecoveryFailed") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                            
                            strongSelf->_view.resetMode = true;
                        }
                    }
                };
                controller.cancelled = ^
                {
                    __strong TGLoginPasswordController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [strongSelf dismissViewControllerAnimated:true completion:nil];
                    }
                };
                
                TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
                [strongSelf presentViewController:navigationController animated:true completion:nil];
            }
        } error:^(id error)
        {
            NSString *errorText = TGLocalized(@"TwoStepAuth.GenericError");
            if ([error hasPrefix:@"FLOOD_WAIT"])
                errorText = TGLocalized(@"TwoStepAuth.FloodError");
            [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        } completed:nil]];
    }
    else
    {
        [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"TwoStepAuth.RecoveryUnavailable") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        
        _view.resetMode = true;
    }
}

- (void)resetPressed
{
    __weak TGLoginPasswordController *weakSelf = self;
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"TwoStepAuth.ResetAccountConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
    {
        __strong TGLoginPasswordController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (okButtonPressed)
            {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [progressWindow show:true];
                
                [[[[TGAccountSignals deleteAccount] deliverOn:[SQueue mainQueue]] onDispose:^
                {
                    [progressWindow dismiss:true];
                }] startWithNext:nil error:^(id error) {
                    __strong TGLoginPasswordController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                        if ([errorType hasPrefix:@"2FA_CONFIRM_WAIT_"]) {
                            int32_t waitSeconds = [[errorType substringFromIndex:@"2FA_CONFIRM_WAIT_".length] intValue];
                            int stateDate = [[TGAppDelegateInstance loadLoginState][@"date"] intValue];
                            NSTimeInterval protectedUntilDate = CFAbsoluteTimeGetCurrent() + waitSeconds;
                            [TGAppDelegateInstance saveLoginStateWithDate:stateDate phoneNumber:_phoneNumber phoneCode:_phoneCode phoneCodeHash:_phoneCodeHash codeSentToTelegram:false codeSentViaPhone:false firstName:nil lastName:nil photo:nil resetAccountState:[[TGResetAccountState alloc] initWithPhoneNumber:_phoneNumber protectedUntilDate:protectedUntilDate]];
                            [strongSelf.navigationController pushViewController:[[TGLoginResetAccountProtectedController alloc] initWithPhoneNumber:_phoneNumber protectedUntilDate:protectedUntilDate] animated:true];
                        } else if ([errorType isEqualToString:@"2FA_RECENT_CONFIRM"]) {
                            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Login.ResetAccountProtected.LimitExceeded") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                        }
                    }
                } completed:^
                {
                    __strong TGLoginPasswordController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [strongSelf _completedDeletion];
                    }
                }];
            }
        }
    }] show];
}

- (bool)loginPhoneNumber:(__autoreleasing NSString **)phoneNumber phoneCode:(__autoreleasing NSString **)phoneCode phoneCodeHash:(__autoreleasing NSString **)phoneCodeHash
{
    if (_phoneNumber != nil)
    {
        if (phoneNumber)
            *phoneNumber = _phoneNumber;
        if (phoneCode)
            *phoneCode = _phoneCode;
        if (phoneCodeHash)
            *phoneCodeHash = _phoneCodeHash;
        
        return true;
    }
    else
    {
        for (id controller in self.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[TGLoginCodeController class]])
            {
                TGLoginCodeController *loginCodeController = controller;
                
                if (phoneNumber)
                    *phoneNumber = loginCodeController.phoneNumber;
                if (phoneCode)
                    *phoneCode = loginCodeController.phoneCode;
                if (phoneCodeHash)
                    *phoneCodeHash = loginCodeController.phoneCodeHash;
                
                return true;
            }
        }
        return false;
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/checkPassword/"])
    {
        TGDispatchOnMainThread(^
        {
            [_progressWindow dismiss:true];
            _progressWindow = nil;
            
            if (status == ASStatusSuccess)
            {
                [self _completedRestore:[result[@"userId"] intValue]];
            }
            else
            {
                NSString *errorText = TGLocalized(@"LoginPassword.InvalidPasswordError");
                if (status == TGCheckPasswordErrorCodeFlood)
                    errorText = TGLocalized(@"LoginPassword.FloodError");
                
                [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil completionBlock:nil] show];
            }
        });
    }
    else if ([path isEqualToString:@"/deleteAccount"])
    {
        TGDispatchOnMainThread(^
        {
            [_progressWindow dismiss:true];
            _progressWindow = nil;
            
            if (status == ASStatusSuccess)
            {
                [self _completedDeletion];
            }
            else
            {
                
            }
        });
    }
}

- (void)_completedRestore:(int32_t)userId
{
    [_view clearFirstResponder];
    
    [[[TGTelegramNetworking instance] context] updatePasswordInputRequiredForDatacenterWithId:[[TGTelegramNetworking instance] mtProto].datacenterId required:false];
    
    if ([self loginPhoneNumber:NULL phoneCode:NULL phoneCodeHash:NULL])
    {
        [TGTelegraphInstance processAuthorizedWithUserId:userId clientIsActivated:true];
        [TGAppDelegateInstance presentMainController];
    }
}

- (void)_completedDeletion
{
    NSString *phoneNumber = nil;
    NSString *phoneCode = nil;
    NSString *phoneCodeHash = nil;
    if ([self loginPhoneNumber:&phoneNumber phoneCode:&phoneCode phoneCodeHash:&phoneCodeHash])
    {
        [self.navigationController pushViewController:[[TGLoginProfileController alloc] initWithShowKeyboard:true phoneNumber:phoneNumber phoneCodeHash:phoneCodeHash phoneCode:phoneCode] animated:true];
    }
    else
    {
        NSString *phone = [TGPhoneUtils cleanPhone:[TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId].phoneNumber];
        [TGTelegraphInstance doLogout:phone];
    }
}

@end
