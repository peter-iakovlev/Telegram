#import "TGPassportEmailController.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGPresentation.h"
#import "TGTelegramNetworking.h"

#import "TGPassportSignals.h"
#import "TGTwoStepConfig.h"
#import "TLauth_SentCode$auth_sentCode.h"

#import "TGButtonCollectionItem.h"
#import "TGUsernameCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGHeaderCollectionItem.h"

#import "TGCustomAlertView.h"

#import "TGPassportRequestController.h"
#import "TGPassportEmailCodeController.h"

@interface TGPassportEmailController ()
{
    NSString *_currentEmail;
    SVariable *_settings;
    SMetaDisposable *_disposable;
    
    TGUsernameCollectionItem *_emailItem;
}
@end

@implementation TGPassportEmailController

- (instancetype)initWithSettings:(SVariable *)settings email:(NSString *)email
{
    self = [super init];
    if (self != nil)
    {
        _settings = settings;
        _currentEmail = email;
        
        self.title = TGLocalized(@"Passport.Email.Title");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextPressed)];
        self.navigationItem.rightBarButtonItem.enabled = false;
        
        if (email.length > 0)
        {
            TGButtonCollectionItem *currentItem = [[TGButtonCollectionItem alloc] initWithTitle:[NSString stringWithFormat:TGLocalized(@"Passport.Email.UseTelegramEmail"), email] action:@selector(currentPressed)];
            currentItem.deselectAutomatically = true;
            
            TGCollectionMenuSection *currentSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                currentItem,
                [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Passport.Email.UseTelegramEmailHelp")]
            ]];
            UIEdgeInsets topSectionInsets = currentSection.insets;
            topSectionInsets.top = 32.0f;
            currentSection.insets = topSectionInsets;
            [self.menuSections addSection:currentSection];
        }
        
        __weak TGPassportEmailController *weakSelf = self;
        _emailItem = [[TGUsernameCollectionItem alloc] init];
        _emailItem.secureEntry = false;
        _emailItem.title = @"";
        _emailItem.keyboardType = UIKeyboardTypeEmailAddress;
        _emailItem.username = @"";
        _emailItem.placeholder = TGLocalized(@"Passport.Email.EmailPlaceholder");
        _emailItem.usernameChanged = ^(NSString *email)
        {
            __strong TGPassportEmailController *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf.navigationItem.rightBarButtonItem.enabled = email.length > 4;
        };
        _emailItem.usernameValid = true;
        _emailItem.returnPressed = ^(__unused id item) {
            __strong TGPassportEmailController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf nextPressed];
            }
        };
        
        NSMutableArray *items = [[NSMutableArray alloc] initWithArray:@[_emailItem, [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Passport.Email.Help")]]];
        if (email.length > 0)
            [items insertObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Passport.Email.EnterOtherEmail")] atIndex:0];
        
        TGCollectionMenuSection *customSection = [[TGCollectionMenuSection alloc] initWithItems:items];
        if (email.length == 0)
        {
            UIEdgeInsets topSectionInsets = customSection.insets;
            topSectionInsets.top = 32.0f;
            customSection.insets = topSectionInsets;
        }
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
    
    [_emailItem becomeFirstResponder];
}

- (void)nextPressed
{
    [self proccesWithEmail:_emailItem.username];
}

- (void)currentPressed
{
    [self proccesWithEmail:_currentEmail];
}

- (void)proccesWithEmail:(NSString *)email
{
    if (email.length == 0)
        return;
    
    if (_disposable == nil)
        _disposable = [[SMetaDisposable alloc] init];
    
    TGPassportDecryptedValue *value = [[TGPassportDecryptedValue alloc] initWithType:TGPassportTypeEmail data:nil frontSide:nil reverseSide:nil selfie:nil files:nil plainData:[[TGPassportEmailData alloc] initWithEmail:email]];
    
    SSignal *signal = [[_settings.signal take:1] mapToSignal:^SSignal *(TGPassportPasswordRequest *request)
    {
        return [TGPassportSignals saveSecureValue:value secret:request.settings.secret];
    }];
    
    signal = [signal catch:^SSignal *(id error)
    {
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorText isEqualToString:@"EMAIL_VERIFICATION_NEEDED"])
            return [TGPassportSignals sendEmailVerificationCode:email];
        
        return [SSignal fail:error];
    }];
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.3];
    
    __weak TGPassportEmailController *weakSelf = self;
    [_disposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(TLSecureValue *next)
    {
        __strong TGPassportEmailController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [progressWindow dismiss:true];
        
        if ([next isKindOfClass:[TLSecureValue class]])
        {
            strongSelf.completionBlock([value updateWithValueHash:next.n_hash]);
            [strongSelf.navigationController popViewControllerAnimated:true];
        }
        else if ([next isKindOfClass:[TLaccount_SentEmailCode$account_sentEmailCode class]])
        {
            TGPassportEmailCodeController *controller = [[TGPassportEmailCodeController alloc] initWithEmail:email settings:strongSelf->_settings completionBlock:strongSelf.completionBlock];
            [strongSelf.navigationController pushViewController:controller animated:true];
        }
    } error:^(id error)
    {
        [progressWindow dismiss:true];
        
        NSString *displayText = TGLocalized(@"Login.UnknownError");
        
        NSString *errorText = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorText isEqualToString:@"EMAIL_INVALID"])
            displayText = TGLocalized(@"TwoStepAuth.EmailInvalid");
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
