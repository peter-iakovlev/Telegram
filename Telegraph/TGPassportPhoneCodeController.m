#import "TGPassportPhoneCodeController.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGTelegramNetworking.h"
#import "TGPassportSignals.h"
#import "TGTwoStepConfig.h"
#import "TLMetaScheme.h"

#import "TGHeaderCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGPhoneCodeCollectionItem.h"

#import <LegacyComponents/TGTimerTarget.h>

#import <LegacyComponents/TGProgressWindow.h>
#import "TGCustomAlertView.h"

#import "TGPassportRequestController.h"

#import <LegacyComponents/ActionStage.h>

@interface TGPassportPhoneCodeController () <ASWatcher>
{
    NSString *_phoneNumber;
    NSString *_phoneCodeHash;
    NSString *_code;
    SVariable *_settings;
    SMetaDisposable *_disposable;
    bool _dismissed;
    
    UIBarButtonItem *_nextItem;
    
    TGPhoneCodeCollectionItem *_codeItem;
    TGCommentCollectionItem *_timerItem;
    NSUInteger _remainingCallTimeout;
    NSTimer *_callTimeoutTimer;
    
    TGProgressWindow *_progressWindow;
}

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) void (^completionBlock)(TGPassportDecryptedValue *);

@end

@implementation TGPassportPhoneCodeController

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash callTimeout:(NSTimeInterval)callTimeout settings:(SVariable *)settings completionBlock:(void (^)(TGPassportDecryptedValue *))completionBlock
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _settings = settings;
        _phoneNumber = phoneNumber;
        _phoneCodeHash = phoneCodeHash;
        _remainingCallTimeout = (NSUInteger)callTimeout;
        self.completionBlock = completionBlock;
        
        self.title = [TGPhoneUtils formatPhone:phoneNumber forceInternational:true];
        
        _nextItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        _nextItem.enabled = false;
        [self setRightBarButtonItem:_nextItem];
        
        _codeItem = [[TGPhoneCodeCollectionItem alloc] init];
        __weak TGPassportPhoneCodeController *weakSelf = self;
        _codeItem.codeChanged = ^(NSString *code)
        {
            __strong TGPassportPhoneCodeController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_code = code;
                strongSelf->_nextItem.enabled = code.length != 0;
                
                if (code.length == 5)
                    [strongSelf donePressed];
            }
        };
        
        _timerItem = [[TGCommentCollectionItem alloc] initWithText:[self stringForTimerTimeout:_remainingCallTimeout]];
        _timerItem.textColor = UIColorRGB(0xadadb5);
        _timerItem.topInset = 3.0f;
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"ChangePhoneNumberCode.Code")],
            _codeItem,
            [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"ChangePhoneNumberCode.Help")],
            _timerItem
        ]];
        section.insets = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0f);
        [self.menuSections addSection:section];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [_disposable dispose];
}

- (NSString *)stringForTimerTimeout:(NSUInteger)timeout
{
    int minutes = ((int)timeout) / 60;
    int seconds = ((int)timeout) % 60;
    
    NSString *timeValue = [[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds];
    
    return [[NSString alloc] initWithFormat:TGLocalized(@"ChangePhoneNumberCode.CallTimer"), timeValue];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _dismissed = true;
    [_codeItem resignFirstResponder];
    
    [_callTimeoutTimer invalidate];
    _callTimeoutTimer = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_remainingCallTimeout != 0)
        _callTimeoutTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(timerEvent) interval:1.0 repeat:true];

    [_codeItem becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)timerEvent
{
    if (_remainingCallTimeout == 0)
    {
        [_callTimeoutTimer invalidate];
        _callTimeoutTimer = nil;
        
        _timerItem.text = TGLocalized(@"ChangePhoneNumberCode.RequestingACall");
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/verifyChangePhoneNumber/(%@)", _phoneNumber] options:@{@"phoneNumber": _phoneNumber, @"phoneCodeHash": _phoneCodeHash, @"requestCall": @true} flags:0 watcher:self];
    }
    else
    {
        _remainingCallTimeout--;
        _timerItem.text = [self stringForTimerTimeout:_remainingCallTimeout];
    }
}

- (void)donePressed
{
    if (_disposable == nil)
        _disposable = [[SMetaDisposable alloc] init];
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    NSString *phoneNumber = _phoneNumber;
    TGPassportDecryptedValue *value = [[TGPassportDecryptedValue alloc] initWithType:TGPassportTypePhone data:nil frontSide:nil reverseSide:nil selfie:nil files:nil plainData:[[TGPassportPhoneData alloc] initWithPhone:phoneNumber]];
    
    SSignal *signal = [TGPassportSignals verifyPhone:_phoneNumber code:_code hash:_phoneCodeHash];
    signal = [signal mapToSignal:^SSignal *(id next)
    {
        if ([next isKindOfClass:[NSNumber class]] && [next boolValue])
        {
            return [[_settings.signal take:1] mapToSignal:^SSignal *(TGPassportPasswordRequest *request)
            {
                return [TGPassportSignals saveSecureValue:value secret:request.settings.secret];
            }];
        }
    
        return [SSignal single:next];
    }];
    
    __weak TGPassportPhoneCodeController *weakSelf = self;
    [[signal deliverOn:[SQueue mainQueue]] startWithNext:^(TLSecureValue *next) {
        __strong TGPassportPhoneCodeController *strongSelf = weakSelf;
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
        
        NSString *displayText = TGLocalized(@"Login.UnknownError");
        
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorText isEqualToString:@"PHONE_CODE_INVALID"])
            displayText = TGLocalized(@"Login.InvalidCodeError");
        else if ([errorText hasPrefix:@"FLOOD_WAIT"])
            displayText = TGLocalized(@"Login.CodeFloodError");
        else if ([errorText isEqualToString:@"PHONE_CODE_EXPIRED"])
            displayText = TGLocalized(@"Login.CodeExpiredError");
        
        [TGCustomAlertView presentAlertWithTitle:nil message:displayText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
    } completed:nil];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/verifyChangePhoneNumber/"])
    {
        TGDispatchOnMainThread(^
        {
            if (status == ASStatusSuccess)
                _timerItem.text = TGLocalized(@"ChangePhoneNumberCode.Called");
        });
    }
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
