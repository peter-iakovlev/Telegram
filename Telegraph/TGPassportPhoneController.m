#import "TGPassportPhoneController.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGPresentation.h"
#import "TGTelegramNetworking.h"

#import "TGPassportSignals.h"
#import "TGTwoStepConfig.h"
#import "TLauth_SentCode$auth_sentCode.h"

#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGCountryAndPhoneCollectionItem.h"

#import "TGCustomAlertView.h"

#import "TGPassportRequestController.h"
#import "TGPassportPhoneCodeController.h"

@interface TGPassportPhoneController ()
{
    TGCountryAndPhoneCollectionItem *_countryAndPhoneItem;
    
    NSString *_currentPhoneNumber;
    NSString *_phoneNumber;
    
    SMetaDisposable *_disposable;
    SVariable *_settings;
}
@end

@implementation TGPassportPhoneController

- (instancetype)initWithSettings:(SVariable *)settings
{
    self = [super init];
    if (self != nil)
    {
        _settings = settings;
        
        self.title = TGLocalized(@"Passport.Phone.Title");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
        self.navigationItem.rightBarButtonItem.enabled = false;
        self.disableStopScrolling = true;
        
        TGUser *user = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
        NSString *phoneNumber = [TGPhoneUtils formatPhone:user.phoneNumber forceInternational:false];
        _currentPhoneNumber = phoneNumber;
        TGButtonCollectionItem *currentItem = [[TGButtonCollectionItem alloc] initWithTitle:[NSString stringWithFormat:TGLocalized(@"Passport.Phone.UseTelegramNumber"), phoneNumber] action:@selector(currentPressed)];
        currentItem.deselectAutomatically = true;
        
        TGCollectionMenuSection *currentSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            currentItem,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Passport.Phone.UseTelegramNumberHelp")]
        ]];
        UIEdgeInsets topSectionInsets = currentSection.insets;
        topSectionInsets.top = 32.0f;
        currentSection.insets = topSectionInsets;
        [self.menuSections addSection:currentSection];
        
        _countryAndPhoneItem = [[TGCountryAndPhoneCollectionItem alloc] init];
        __weak TGPassportPhoneController *weakSelf = self;
        _countryAndPhoneItem.presentViewController = ^(UIViewController *controller)
        {
            __strong TGPassportPhoneController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf presentViewController:controller animated:true completion:nil];
        };
        _countryAndPhoneItem.phoneChanged = ^(NSString *phoneNumber)
        {
            __strong TGPassportPhoneController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf.navigationItem.rightBarButtonItem.enabled = phoneNumber.length > 1;
                strongSelf->_phoneNumber = phoneNumber;
            }
        };
        
        TGCollectionMenuSection *customSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Phone.EnterOtherNumber")],
            _countryAndPhoneItem,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Passport.Phone.Help")]
        ]];
        [self.menuSections addSection:customSection];
        
    }
    return self;
}

- (void)dealloc
{
    [_disposable dispose];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_countryAndPhoneItem becomeFirstResponder];
}

- (void)nextPressed
{
    [self proccesWithPhoneNumber:_phoneNumber];
}

- (void)currentPressed
{
    [self proccesWithPhoneNumber:_currentPhoneNumber];
}

- (void)proccesWithPhoneNumber:(NSString *)phoneNumber
{
    if (_disposable == nil)
        _disposable = [[SMetaDisposable alloc] init];
    
    phoneNumber = [TGPhoneUtils cleanPhone:phoneNumber];
    
    TGPassportDecryptedValue *value = [[TGPassportDecryptedValue alloc] initWithType:TGPassportTypePhone data:nil frontSide:nil reverseSide:nil selfie:nil files:nil plainData:[[TGPassportPhoneData alloc] initWithPhone:phoneNumber]];
    
    SSignal *signal = [[_settings.signal take:1] mapToSignal:^SSignal *(TGPassportPasswordRequest *request)
    {
        return [TGPassportSignals saveSecureValue:value secret:request.settings.secret];
    }];
    
    signal = [signal catch:^SSignal *(id error)
    {
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorText isEqualToString:@"PHONE_VERIFICATION_NEEDED"])
            return [TGPassportSignals sendPhoneVerificationCode:phoneNumber];
        
        return [SSignal fail:error];
    }];
    
    TGProgressWindow *window = [[TGProgressWindow alloc] init];
    [window showWithDelay:0.3];
    
    __weak TGPassportPhoneController *weakSelf = self;
    [_disposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(TLSecureValue *next)
    {
        __strong TGPassportPhoneController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [window dismiss:true];
        
        if ([next isKindOfClass:[TLSecureValue class]])
        {
            strongSelf.completionBlock([value updateWithValueHash:next.n_hash]);
            [strongSelf.navigationController popViewControllerAnimated:true];
        }
        else if ([next isKindOfClass:[TLauth_SentCode$auth_sentCode class]])
        {
            TLauth_SentCode$auth_sentCode *sentCode = (TLauth_SentCode$auth_sentCode *)next;
            TGPassportPhoneCodeController *controller = [[TGPassportPhoneCodeController alloc] initWithPhoneNumber:phoneNumber phoneCodeHash:sentCode.phone_code_hash callTimeout:sentCode.timeout settings:strongSelf->_settings completionBlock:strongSelf.completionBlock];
            [strongSelf.navigationController pushViewController:controller animated:true];
        }
    } error:^(id error)
    {
        [window dismiss:true];
        
        NSString *displayText = TGLocalized(@"Login.UnknownError");
        
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorText isEqualToString:@"PHONE_NUMBER_INVALID"])
            displayText = TGLocalized(@"Login.InvalidPhoneError");
        else if ([errorText hasPrefix:@"FLOOD_WAIT"])
            displayText = TGLocalized(@"Login.CodeFloodError");
        
        [TGCustomAlertView presentAlertWithTitle:nil message:displayText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
    } completed:nil]];
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
