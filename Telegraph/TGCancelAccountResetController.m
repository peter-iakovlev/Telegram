#import "TGCancelAccountResetController.h"

#import "TGHeaderCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGPhoneCodeCollectionItem.h"

#import "TGStringUtils.h"
#import "TGPhoneUtils.h"

#import "TGProgressWindow.h"

#import "TGTelegramNetworking.h"
#import "TGAccountSignals.h"

#import "TGAlertView.h"
#import "TGTimerTarget.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

@interface TGCancelAccountResetController () {
    NSString *_phoneHash;
    NSString *_code;
    
    UIBarButtonItem *_doneItem;
    
    TGPhoneCodeCollectionItem *_codeItem;
    TGCommentCollectionItem *_timerItem;
    NSUInteger _remainingCallTimeout;
    NSTimer *_callTimeoutTimer;
    
    SMetaDisposable *_nextCodeRequestDisposable;
}

@end

@implementation TGCancelAccountResetController

- (instancetype)initWithPhoneHash:(NSString *)phoneHash timeout:(int32_t)timeout {
    self = [super init];
    if (self != nil) {
        _phoneHash = phoneHash;
        _remainingCallTimeout = (NSUInteger)timeout;
#ifdef DEBUG
        _remainingCallTimeout = 10;
#endif
        
        self.title = TGLocalized(@"CancelResetAccount.Title");
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        [self setRightBarButtonItem:_doneItem];
        _doneItem.enabled = false;
        
        _codeItem = [[TGPhoneCodeCollectionItem alloc] init];
        __weak TGCancelAccountResetController *weakSelf = self;
        _codeItem.codeChanged = ^(NSString *code) {
            __strong TGCancelAccountResetController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                bool autoPressDone = false;
                if (strongSelf->_code.length != 5 && code.length == 5) {
                    autoPressDone = true;
                }
                strongSelf->_code = code;
                strongSelf->_doneItem.enabled = code.length != 0;
                if (autoPressDone) {
                    [strongSelf donePressed];
                }
            }
        };
        
        _timerItem = [[TGCommentCollectionItem alloc] initWithText:[self stringForTimerTimeout:_remainingCallTimeout]];
        _timerItem.textColor = UIColorRGB(0xadadb5);
        _timerItem.topInset = 3.0f;
        
        NSString *phoneNumber = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId].phoneNumber;
        phoneNumber = [TGPhoneUtils formatPhone:phoneNumber forceInternational:true];
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:@[
            _codeItem,
            [[TGCommentCollectionItem alloc] initWithFormattedText:[NSString stringWithFormat:TGLocalized(@"CancelResetAccount.TextSMS"), phoneNumber == nil ? @"" : phoneNumber]],
            _timerItem
        ]];
        section.insets = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0f);
        [self.menuSections addSection:section];
        
        _nextCodeRequestDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_nextCodeRequestDisposable dispose];
}

- (NSString *)stringForTimerTimeout:(NSUInteger)timeout
{
    int minutes = ((int)timeout) / 60;
    int seconds = ((int)timeout) % 60;
    
    NSString *timeValue = [[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds];
    
    return [[NSString alloc] initWithFormat:TGLocalized(@"ChangePhoneNumberCode.CallTimer"), timeValue];
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_callTimeoutTimer invalidate];
    _callTimeoutTimer = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_remainingCallTimeout != 0)
    {
        _callTimeoutTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(timerEvent) interval:1.0 repeat:true];
    }
    
    [_codeItem becomeFirstResponder];
    
    [self.collectionView layoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [_codeItem becomeFirstResponder];
    
    [super viewDidLayoutSubviews];
}

- (void)timerEvent
{
    if (_remainingCallTimeout == 0)
    {
        [_callTimeoutTimer invalidate];
        _callTimeoutTimer = nil;
        
        _timerItem.text = TGLocalized(@"ChangePhoneNumberCode.RequestingACall");
        
        __weak TGCancelAccountResetController *weakSelf = self;
        [_nextCodeRequestDisposable setDisposable:[[[TGAccountSignals resendCodeWithHash:_phoneHash] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(__unused id error) {
            
        } completed:^{
            __strong TGCancelAccountResetController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_timerItem.text = TGLocalized(@"ChangePhoneNumberCode.Called");
            }
        }]];
    }
    else
    {
        _remainingCallTimeout--;
        _timerItem.text = [self stringForTimerTimeout:_remainingCallTimeout];
    }
}

- (void)donePressed {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.1];
    
    __weak TGCancelAccountResetController *weakSelf = self;
    [[[[TGAccountSignals confirmPhoneWithHash:_phoneHash code:_code] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil error:^(id error) {
        NSString *errorText = TGLocalized(@"Login.UnknownError");
        NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorType isEqualToString:@"PHONE_CODE_INVALID"]) {
            errorText = TGLocalized(@"Login.InvalidCodeError");
        } else if ([errorType isEqualToString:@"PHONE_CODE_EXPIRED"]) {
            errorText = TGLocalized(@"Login.CodeExpiredError");
        }
        [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
    } completed:^{
        __strong TGCancelAccountResetController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf cancelPressed];
            NSString *phoneNumber = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId].phoneNumber;
            phoneNumber = [TGPhoneUtils formatPhone:phoneNumber forceInternational:true];
            [[[TGAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:TGLocalized(@"CancelResetAccount.Success"), phoneNumber] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        }
    }];
}

@end
