#import "TGLoginResetAccountProtectedController.h"

#import "TGLoginResetAccountControllerView.h"

#import "TGPhoneUtils.h"

#import "TGAlertView.h"
#import "TGProgressWindow.h"

#import "TGAccountSignals.h"

#import "TGAppDelegate.h"

#import "TGTelegramNetworking.h"

@interface TGLoginResetAccountProtectedController () {
    NSString *_phoneNumber;
    NSTimeInterval _protectedUntilDate;
}

@end

@implementation TGLoginResetAccountProtectedController

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber protectedUntilDate:(NSTimeInterval)protectedUntilDate {
    self = [super init];
    if (self != nil) {
        _phoneNumber = phoneNumber;
        _protectedUntilDate = protectedUntilDate;
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:@selector(emptyAction)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"WelcomeScreen.Logout") style:UIBarButtonItemStylePlain target:self action:@selector(logOut)]];
    }
    return self;
}
         
- (void)emptyAction {
}

- (void)logOut {
    int stateDate = [[TGAppDelegateInstance loadLoginState][@"date"] intValue];
    [TGAppDelegateInstance saveLoginStateWithDate:stateDate phoneNumber:_phoneNumber phoneCode:nil phoneCodeHash:nil codeSentToTelegram:false codeSentViaPhone:false firstName:nil lastName:nil photo:nil resetAccountState:nil];
    
    [TGAppDelegateInstance presentLoginController:true animated:true showWelcomeScreen:false phoneNumber:_phoneNumber phoneCode:nil phoneCodeHash:nil codeSentToTelegram:false codeSentViaPhone:false profileFirstName:nil profileLastName:nil resetAccountState:nil];
}

- (void)loadView {
    [super loadView];
    
    TGLoginResetAccountControllerView *view = [[TGLoginResetAccountControllerView alloc] initWithFrame:self.view.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view setPhoneNumber:[TGPhoneUtils formatPhone:_phoneNumber forceInternational:true]];
    [view setProtectedUntilDate:_protectedUntilDate];
    __weak TGLoginResetAccountProtectedController *weakSelf = self;
    view.resetAccount = ^{
        __strong TGLoginResetAccountProtectedController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf resetAccount];
        }
    };
    [self.view addSubview:view];
}

- (void)resetAccount {
    __weak TGLoginResetAccountProtectedController *weakSelf = self;
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"TwoStepAuth.ResetAccountConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
    {
        __strong TGLoginResetAccountProtectedController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (okButtonPressed) {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [progressWindow show:true];
                
                [[[[TGAccountSignals deleteAccount] deliverOn:[SQueue mainQueue]] onDispose:^ {
                    [progressWindow dismiss:true];
                }] startWithNext:nil error:^(id error) {
                    __strong TGLoginResetAccountProtectedController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                        if ([errorType isEqualToString:@"2FA_RECENT_CONFIRM"]) {
                            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Login.ResetAccountProtected.LimitExceeded") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                        } else {
                            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Login.UnknownError") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                        }
                    }
                } completed:^ {
                    __strong TGLoginResetAccountProtectedController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf _completedDeletion];
                    }
                }];
            }
        }
    }] show];
}

- (void)_completedDeletion {
    [TGAppDelegateInstance presentLoginController:true animated:true showWelcomeScreen:false phoneNumber:_phoneNumber phoneCode:nil phoneCodeHash:nil codeSentToTelegram:false codeSentViaPhone:false profileFirstName:nil profileLastName:nil resetAccountState:nil];
}

@end
