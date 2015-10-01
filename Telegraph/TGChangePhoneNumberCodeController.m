#import "TGChangePhoneNumberCodeController.h"

#import "TGHeaderCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGPhoneCodeCollectionItem.h"

#import "TGPhoneUtils.h"
#import "TGTimerTarget.h"

#import "TGProgressWindow.h"
#import "TGAlertView.h"

#import "ActionStage.h"
#import "TGSignInRequestBuilder.h"

@interface TGChangePhoneNumberCodeController () <ASWatcher>
{
    NSString *_phoneNumber;
    NSString *_phoneCodeHash;
    NSString *_code;
    
    UIBarButtonItem *_nextItem;
    
    TGPhoneCodeCollectionItem *_codeItem;
    TGCommentCollectionItem *_timerItem;
    NSUInteger _remainingCallTimeout;
    NSTimer *_callTimeoutTimer;
    
    TGProgressWindow *_progressWindow;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGChangePhoneNumberCodeController

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash callTimeout:(NSTimeInterval)callTimeout
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _phoneNumber = phoneNumber;
        _phoneCodeHash = phoneCodeHash;
        _remainingCallTimeout = (NSUInteger)callTimeout;
        
        self.title = [TGPhoneUtils formatPhone:phoneNumber forceInternational:true];
        
        _nextItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
        _nextItem.enabled = false;
        [self setRightBarButtonItem:_nextItem];
        
        _codeItem = [[TGPhoneCodeCollectionItem alloc] init];
        __weak TGChangePhoneNumberCodeController *weakSelf = self;
        _codeItem.codeChanged = ^(NSString *code)
        {
            __strong TGChangePhoneNumberCodeController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_code = code;
                strongSelf->_nextItem.enabled = code.length != 0;
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
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/verifyChangePhoneNumber/(%@)", _phoneNumber] options:@{@"phoneNumber": _phoneNumber, @"phoneCodeHash": _phoneCodeHash, @"requestCall": @true} flags:0 watcher:self];
    }
    else
    {
        _remainingCallTimeout--;
        _timerItem.text = [self stringForTimerTimeout:_remainingCallTimeout];
    }
}

- (void)nextPressed
{
    _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_progressWindow show:true];
    
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/changePhoneNumber/(%@)", _phoneNumber] options:@{@"phoneNumber": _phoneNumber, @"phoneCodeHash": _phoneCodeHash, @"phoneCode": _code} flags:0 watcher:self];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/changePhoneNumber/"])
    {
        TGDispatchOnMainThread(^
        {
            [_progressWindow dismiss:true];
            
            if (status == ASStatusSuccess)
            {
                [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
            }
            else
            {
                NSString *errorText = TGLocalized(@"Login.UnknownError");
                
                if (status == TGSignInResultTokenExpired)
                {
                    errorText = TGLocalized(@"Login.CodeExpiredError");
                }
                else if (status == TGSignInResultFloodWait)
                {
                    errorText = TGLocalized(@"Login.CodeFloodError");
                }
                else if (status == TGSignInResultInvalidToken)
                {
                    errorText = TGLocalized(@"Login.InvalidCodeError");
                }
                
                if (errorText != nil)
                {
                    TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:errorText delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                    [alertView show];
                }
            }
        });
    }
    else if ([path hasPrefix:@"/verifyChangePhoneNumber/"])
    {
        TGDispatchOnMainThread(^
        {
            if (status == ASStatusSuccess)
            {
                _timerItem.text = TGLocalized(@"ChangePhoneNumberCode.Called");
            }
            else
            {
            }
        });
    }
}

@end
