#import "TGPrivacySettingsController.h"

#import <LegacyComponents/LegacyComponents.h>
#import <LegacyComponents/ActionStage.h>
#import <LegacyComponents/SGraphObjectNode.h>

#import <LocalAuthentication/LocalAuthentication.h>

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGVariantCollectionItem.h"
#import "TGDisclosureActionCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGSwitchCollectionItem.h"

#import "TGAccountSettings.h"
#import "TGAccountSettingsActor.h"

#import "TGPrivacyLastSeenController.h"
#import "TGBlockedController.h"
#import "TGDeleteAccountController.h"
#import "TGPasswordSettingsController.h"
#import "TGPasscodeSettingsController.h"
#import "TGPasswordConfirmationController.h"
#import "TGPrivateDataSettingsController.h"
#import "TGAuthSessionsController.h"
#import "TGPasswordEntryController.h"

#import "TGCustomAlertView.h"
#import "TGCustomActionSheet.h"
#import <LegacyComponents/TGProgressWindow.h>

#import "TGTwoStepConfigSignal.h"
#import "TGTwoStepSetPaswordSignal.h"

#import "TGPresentation.h"

@interface TGPrivacySettingsController () <ASWatcher>
{
    bool _receivedAccountSettings;
    UIActivityIndicatorView *_activityIndicator;
    TGProgressWindow *_progressWindow;
    
    TGVariantCollectionItem *_blockedUsersItem;
    TGVariantCollectionItem *_groupsAndChannelsItem;
    TGVariantCollectionItem *_callsItem;
    TGAccountSettings *_accountSettings;
    TGVariantCollectionItem *_lastSeenItem;
    TGVariantCollectionItem *_accountExpirationItem;
    
    SMetaDisposable *_twoStepConfigDisposable;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGPrivacySettingsController

- (NSString *)lastSeenVariantForPrivacySettings:(TGNotificationPrivacyAccountSetting *)privacySettings
{
    NSNumber *minusValue = privacySettings.neverShareWithUserIds.count == 0 ? nil : @(privacySettings.neverShareWithUserIds.count);
    NSNumber *plusValue = privacySettings.alwaysShareWithUserIds.count == 0 ? nil : @(privacySettings.alwaysShareWithUserIds.count);
    
    if (privacySettings.lastSeenPrimarySetting == TGPrivacySettingsLastSeenPrimarySettingEverybody)
    {
        if (minusValue != nil)
            return [[NSString alloc] initWithFormat:TGLocalized(@"PrivacySettings.LastSeenEverybodyMinus"), minusValue];
        else
            return TGLocalized(@"PrivacySettings.LastSeenEverybody");
    }
    else if (privacySettings.lastSeenPrimarySetting == TGPrivacySettingsLastSeenPrimarySettingContacts
             )
    {
        if (plusValue != nil && minusValue == nil)
            return [[NSString alloc] initWithFormat:TGLocalized(@"PrivacySettings.LastSeenContactsPlus"), plusValue];
        else if (minusValue != nil && plusValue == nil)
            return [[NSString alloc] initWithFormat:TGLocalized(@"PrivacySettings.LastSeenContactsMinus"), minusValue];
        if (plusValue != nil && minusValue != nil)
            return [[NSString alloc] initWithFormat:TGLocalized(@"PrivacySettings.LastSeenContactsMinusPlus"), minusValue, plusValue];
        else
            return TGLocalized(@"PrivacySettings.LastSeenContacts");
    }
    else if (privacySettings.lastSeenPrimarySetting == TGPrivacySettingsLastSeenPrimarySettingNobody)
    {
        if (plusValue != nil)
            return [[NSString alloc] initWithFormat:TGLocalized(@"PrivacySettings.LastSeenNobodyPlus"), plusValue];
        else
            return TGLocalized(@"PrivacySettings.LastSeenNobody");
    }
    
    return @"";
}

- (NSString *)accountExpirationTimeVariantForAccountTTLSetting:(TGAccountTTLSetting *)accountTTLSetting
{
    if (accountTTLSetting.accountTTL != nil)
        return [TGStringUtils stringForMessageTimerSeconds:[accountTTLSetting.accountTTL unsignedIntegerValue]];
    
    return @"";
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.title = TGLocalized(@"PrivacySettings.Title");
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:nil action:nil];
        
        _lastSeenItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.LastSeen") action:@selector(lastSeenPressed)];
        _blockedUsersItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.BlockedUsers") action:@selector(blockedUsersPressed)];
        _groupsAndChannelsItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.GroupsAndChannels") action:@selector(groupsAndChannelsPressed)];
        _callsItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Privacy.Calls") action:@selector(callsPressed)];
        NSMutableArray *lastSeenSectionItems = [[NSMutableArray alloc] init];
        NSData *phoneCallsEnabledData = [TGDatabaseInstance() customProperty:@"phoneCallsEnabled"];
        int32_t phoneCallsEnabled = false;
        if (phoneCallsEnabledData.length == 4) {
            [phoneCallsEnabledData getBytes:&phoneCallsEnabled];
        }
        [lastSeenSectionItems addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.PrivacyTitle")]];
        [lastSeenSectionItems addObject:_blockedUsersItem];
        [lastSeenSectionItems addObject:_lastSeenItem];
        if (phoneCallsEnabled != 0) {
            [lastSeenSectionItems addObject:_callsItem];
        }
        [lastSeenSectionItems addObject:_groupsAndChannelsItem];
        [lastSeenSectionItems addObject:[[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"PrivacyLastSeenSettings.GroupsAndChannelsHelp")]];
        
        TGCollectionMenuSection *lastSeenSection = [[TGCollectionMenuSection alloc] initWithItems:lastSeenSectionItems];
        UIEdgeInsets topSectionInsets = lastSeenSection.insets;
        topSectionInsets.top = 32.0f;
        lastSeenSection.insets = topSectionInsets;
        [self.menuSections addSection:lastSeenSection];
        
        TGButtonCollectionItem *terminateSessionsItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.ClearOtherSessions") action:@selector(terminateSessionsPressed)];
        terminateSessionsItem.titleColor = [UIColor blackColor];
        terminateSessionsItem.deselectAutomatically = true;
        
        NSString *passcodeTitle = TGLocalized(@"PrivacySettings.Passcode");
        bool hasFaceId = false;
        bool hasBiometrics = [TGPasscodeSettingsController supportsBiometrics:&hasFaceId];
        if (hasFaceId)
            passcodeTitle = TGLocalized(@"PrivacySettings.PasscodeAndFaceId");
        else if (hasBiometrics)
            passcodeTitle = TGLocalized(@"PrivacySettings.PasscodeAndTouchId");
        
        TGCollectionMenuSection *securitySection = [[TGCollectionMenuSection alloc] initWithItems:@[
                                                                                                    [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.SecurityTitle")],
                                                                                                    [[TGDisclosureActionCollectionItem alloc] initWithTitle:passcodeTitle action:@selector(passcodePressed)],
                                                                                                    [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.TwoStepAuth") action:@selector(passwordPressed)],
                                                                                                    [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.AuthSessions") action:@selector(authSessionsPressed)]
                                                                                                    ]];
        [self.menuSections addSection:securitySection];
        
        _accountExpirationItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.DeleteAccountIfAwayFor") action:@selector(deleteAccountExpirationPressed)];
        _accountExpirationItem.deselectAutomatically = true;
        TGCollectionMenuSection *deleteAccountSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                                                                                                         [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.DeleteAccountTitle")],
                                                                                                         _accountExpirationItem,
                                                                                                         [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"PrivacySettings.DeleteAccountHelp")]
                                                                                                         ]];
        [self.menuSections addSection:deleteAccountSection];
        
        TGDisclosureActionCollectionItem *dataItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.DataSettings") action:@selector(dataSettingsPressed)];
        TGCollectionMenuSection *dataSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                                                                                                dataItem,
                                                                                                [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"PrivacySettings.DataSettingsHelp")]
                                                                                                ]];
        [self.menuSections addSection:dataSection];
        
        TGAccountSettings *accountSettings = [TGAccountSettingsActor accountSettingsFotCurrentStateId];
        if (accountSettings != nil)
            _receivedAccountSettings = true;
        else
            accountSettings = [[TGAccountSettings alloc] initWithDefaultValues];
        [self setAccountSettings:accountSettings];
        
        __block NSUInteger count = 0;
        [TGDatabaseInstance() dispatchOnDatabaseThread:^{
            [TGDatabaseInstance() loadBlockedList:^(NSArray *blockedList)
             {
                 count = blockedList.count;
             }];
        } synchronous:true];
        _blockedUsersItem.variant = count == 0 ? @"" : [TGStringUtils stringForUserCount:count];
        
        [ActionStageInstance() watchForPath:@"/tg/blockedUsers" watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [_twoStepConfigDisposable dispose];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_receivedAccountSettings)
    {
        _receivedAccountSettings = true;
        if (_activityIndicator == nil)
        {
            _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _activityIndicator.color = self.presentation.pallete.collectionMenuCommentColor;
            _activityIndicator.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
            _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
            [_activityIndicator startAnimating];
            [self.view addSubview:_activityIndicator];
        }
        
        self.collectionView.alpha = 0.0f;
        
        [ActionStageInstance() requestActor:@"/accountSettings" options:@{} flags:0 watcher:self];
    }
}

- (void)setAccountSettings:(TGAccountSettings *)accountSettings
{
    _accountSettings = accountSettings;
    
    _lastSeenItem.variant = [self lastSeenVariantForPrivacySettings:_accountSettings.notificationSettings];
    _groupsAndChannelsItem.variant = [self lastSeenVariantForPrivacySettings:_accountSettings.groupsAndChannelsSettings];
    _callsItem.variant = [self lastSeenVariantForPrivacySettings:_accountSettings.callSettings];
    _accountExpirationItem.variant = [self accountExpirationTimeVariantForAccountTTLSetting:_accountSettings.accountTTLSetting];
}

- (void)lastSeenPressed
{
    __weak TGPrivacySettingsController *weakSelf = self;
    [self.navigationController pushViewController:[[TGPrivacyLastSeenController alloc] initWithMode:TGPrivacySettingsModeLastSeen privacySettings:_accountSettings.notificationSettings privacySettingsChanged:^(TGNotificationPrivacyAccountSetting *privacySettings)
                                                   {
                                                       __strong TGPrivacySettingsController *strongSelf = weakSelf;
                                                       if (strongSelf != nil)
                                                       {
                                                           strongSelf->_progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                           [strongSelf->_progressWindow show:true];
                                                           
                                                           TGAccountSettings *accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:privacySettings groupsAndChannelsSettings:strongSelf->_accountSettings.groupsAndChannelsSettings callSettings:strongSelf->_accountSettings.callSettings accountTTLSetting:strongSelf->_accountSettings.accountTTLSetting];
                                                           [strongSelf setAccountSettings:accountSettings];
                                                           [ActionStageInstance() requestActor:@"/updateAccountSettings" options:@{@"settingList": @[@{@"notifications": privacySettings}]} flags:0 watcher:strongSelf];
                                                       }
                                                   }] animated:true];
}

- (void)blockedUsersPressed
{
    [self.navigationController pushViewController:[[TGBlockedController alloc] init] animated:true];
}

- (void)groupsAndChannelsPressed {
    __weak TGPrivacySettingsController *weakSelf = self;
    [self.navigationController pushViewController:[[TGPrivacyLastSeenController alloc] initWithMode:TGPrivacySettingsModeGroupsAndChannels privacySettings:_accountSettings.groupsAndChannelsSettings privacySettingsChanged:^(TGNotificationPrivacyAccountSetting *privacySettings)
                                                   {
                                                       __strong TGPrivacySettingsController *strongSelf = weakSelf;
                                                       if (strongSelf != nil)
                                                       {
                                                           strongSelf->_progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                           [strongSelf->_progressWindow show:true];
                                                           
                                                           TGAccountSettings *accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:strongSelf->_accountSettings.notificationSettings groupsAndChannelsSettings:privacySettings callSettings:_accountSettings.callSettings accountTTLSetting:strongSelf->_accountSettings.accountTTLSetting];
                                                           [strongSelf setAccountSettings:accountSettings];
                                                           [ActionStageInstance() requestActor:@"/updateAccountSettings" options:@{@"settingList": @[@{@"groupsAndChannels": privacySettings}]} flags:0 watcher:strongSelf];
                                                       }
                                                   }] animated:true];
}

- (void)callsPressed {
    __weak TGPrivacySettingsController *weakSelf = self;
    [self.navigationController pushViewController:[[TGPrivacyLastSeenController alloc] initWithMode:TGPrivacySettingsModeCalls privacySettings:_accountSettings.callSettings privacySettingsChanged:^(TGNotificationPrivacyAccountSetting *privacySettings)
                                                   {
                                                       __strong TGPrivacySettingsController *strongSelf = weakSelf;
                                                       if (strongSelf != nil)
                                                       {
                                                           strongSelf->_progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                           [strongSelf->_progressWindow show:true];
                                                           
                                                           TGAccountSettings *accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:strongSelf->_accountSettings.notificationSettings groupsAndChannelsSettings:strongSelf->_accountSettings.groupsAndChannelsSettings callSettings:privacySettings accountTTLSetting:strongSelf->_accountSettings.accountTTLSetting];
                                                           [strongSelf setAccountSettings:accountSettings];
                                                           [ActionStageInstance() requestActor:@"/updateAccountSettings" options:@{@"settingList": @[@{@"calls": privacySettings}]} flags:0 watcher:strongSelf];
                                                       }
                                                   }] animated:true];
}


- (void)deleteAccountNowPressed
{
    [self.navigationController pushViewController:[[TGDeleteAccountController alloc] init] animated:true];
}

- (void)deleteAccountExpirationPressed
{
    NSMutableArray *timerValues = [[NSMutableArray alloc] init];
    [timerValues addObject:@(1 * 60 * 60 * 24 * 30)];
    [timerValues addObject:@(1 * 60 * 60 * 24 * 91)];
    [timerValues addObject:@(1 * 60 * 60 * 24 * 182)];
    [timerValues addObject:@(1 * 60 * 60 * 24 * 365)];
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[effectiveLocalization() getPluralized:@"MessageTimer.Months" count:1] action:@"30"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[effectiveLocalization() getPluralized:@"MessageTimer.Months" count:3] action:@"91"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[effectiveLocalization() getPluralized:@"MessageTimer.Months" count:6] action:@"182"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[effectiveLocalization() getPluralized:@"MessageTimer.Months" count:12] action:@"365"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    __weak TGPrivacySettingsController *weakSelf = self;
    TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
                                        {
                                            __strong TGPrivacySettingsController *strongSelf = weakSelf;
                                            if (strongSelf != nil)
                                            {
                                                if (![action isEqualToString:@"cancel"])
                                                {
                                                    int value = [action intValue] * 60 * 60 * 24;
                                                    TGAccountTTLSetting *accountTTLSetting = [[TGAccountTTLSetting alloc] initWithAccountTTL:value == 0 ? nil : @(value)];
                                                    
                                                    TGAccountSettings *accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:strongSelf->_accountSettings.notificationSettings groupsAndChannelsSettings:strongSelf->_accountSettings.groupsAndChannelsSettings callSettings:strongSelf->_accountSettings.callSettings accountTTLSetting:accountTTLSetting];
                                                    
                                                    if (![strongSelf->_accountSettings.accountTTLSetting isEqual:accountTTLSetting])
                                                    {
                                                        strongSelf->_progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                        [strongSelf->_progressWindow show:true];
                                                        
                                                        [strongSelf setAccountSettings:accountSettings];
                                                        [ActionStageInstance() requestActor:@"/updateAccountSettings" options:@{@"settingList": @[@{@"accountTTL": accountTTLSetting}]} flags:0 watcher:strongSelf];
                                                    }
                                                }
                                            }
                                        } target:self];
    
    if (TGAppDelegateInstance.rootController.currentSizeClass == UIUserInterfaceSizeClassCompact) {
        [actionSheet showInView:self.view];
    } else {
        NSIndexPath *indexPath = [self indexPathForItem:_accountExpirationItem];
        if (indexPath != nil)
        {
            UIView *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if (cell != nil)
                [actionSheet showFromRect:[cell convertRect:cell.bounds toView:self.view] inView:self.view animated:true];
        }
    }
}

- (void)passwordPressed
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    if (_twoStepConfigDisposable == nil)
        _twoStepConfigDisposable = [[SMetaDisposable alloc] init];
    __weak TGPrivacySettingsController *weakSelf = self;
    [_twoStepConfigDisposable setDisposable:[[[[TGTwoStepConfigSignal twoStepConfig] deliverOn:[SQueue mainQueue]] onDispose:^
                                              {
                                                  TGDispatchOnMainThread(^
                                                                         {
                                                                             [progressWindow dismiss:true];
                                                                         });
                                              }] startWithNext:^(TGTwoStepConfig *next)
                                             {
                                                 __strong TGPrivacySettingsController *strongSelf = weakSelf;
                                                 if (strongSelf != nil)
                                                 {
                                                     if (next.currentSalt.length != 0)
                                                     {
                                                         [strongSelf displayPasswordEntryControllerWithConfig:next replaceController:false];
                                                     }
                                                     else if (next.unconfirmedEmailPattern.length != 0)
                                                     {
                                                         TGPasswordConfirmationController *confirmationController = [[TGPasswordConfirmationController alloc] initWithEmail:next.unconfirmedEmailPattern];
                                                         confirmationController.completion = ^
                                                         {
                                                             __strong TGPrivacySettingsController *strongSelf = weakSelf;
                                                             if (strongSelf != nil)
                                                             {
                                                                 TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                                 [progressWindow show:true];
                                                                 
                                                                 [strongSelf->_twoStepConfigDisposable setDisposable:[[[[TGTwoStepConfigSignal twoStepConfig] deliverOn:[SQueue mainQueue]] onDispose:^
                                                                                                                       {
                                                                                                                           TGDispatchOnMainThread(^
                                                                                                                                                  {
                                                                                                                                                      [progressWindow dismiss:true];
                                                                                                                                                  });
                                                                                                                       }] startWithNext:^(TGTwoStepConfig *next)
                                                                                                                      {
                                                                                                                          __strong TGPrivacySettingsController *strongSelf = weakSelf;
                                                                                                                          if (strongSelf != nil)
                                                                                                                              [strongSelf displayPasswordEntryControllerWithConfig:next replaceController:true];
                                                                                                                      }]];
                                                             }
                                                         };
                                                         confirmationController.changeEmail = ^
                                                         {
                                                         };
                                                         confirmationController.removePassword = ^
                                                         {
                                                             __strong TGPrivacySettingsController *strongSelf = weakSelf;
                                                             if (strongSelf != nil)
                                                                 [strongSelf removePasswordWhileWaitingForActivationWithConfig:next];
                                                         };
                                                         [strongSelf.navigationController pushViewController:confirmationController animated:true];
                                                     }
                                                     else
                                                     {
                                                         [strongSelf.navigationController pushViewController:[[TGPasswordSettingsController alloc] initWithConfig:next currentPassword:nil] animated:true];
                                                     }
                                                 }
                                             }]];
}

- (void)displayPasswordEntryControllerWithConfig:(TGTwoStepConfig *)config replaceController:(bool)replaceController
{
    __weak TGPrivacySettingsController *weakSelf = self;
    TGPasswordEntryController *controller = [[TGPasswordEntryController alloc] initWithConfig:config];
    controller.completion = ^(NSString *password)
    {
        __strong TGPrivacySettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [progressWindow show:true];
            
            [_twoStepConfigDisposable setDisposable:[[[[TGTwoStepConfigSignal twoStepConfig] deliverOn:[SQueue mainQueue]] onDispose:^
                                                      {
                                                          TGDispatchOnMainThread(^
                                                                                 {
                                                                                     [progressWindow dismiss:true];
                                                                                 });
                                                      }] startWithNext:^(TGTwoStepConfig *next)
                                                     {
                                                         __strong TGPrivacySettingsController *strongSelf = weakSelf;
                                                         if (strongSelf != nil)
                                                         {
                                                             NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:strongSelf.navigationController.viewControllers];
                                                             [viewControllers replaceObjectAtIndex:viewControllers.count - 1 withObject:[[TGPasswordSettingsController alloc] initWithConfig:next currentPassword:password]];
                                                             [strongSelf.navigationController setViewControllers:viewControllers animated:true];
                                                         }
                                                     }]];
        }
    };
    
    if (replaceController)
    {
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        [viewControllers replaceObjectAtIndex:viewControllers.count - 1 withObject:controller];
        [self.navigationController setViewControllers:viewControllers animated:true];
    }
    else
        [self.navigationController pushViewController:controller animated:true];
}

- (void)removePasswordWhileWaitingForActivationWithConfig:(TGTwoStepConfig *)config
{
    __weak TGPrivacySettingsController *weakSelf = self;
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    [_twoStepConfigDisposable setDisposable:[[[[TGTwoStepSetPaswordSignal setPasswordWithCurrentSalt:nil currentPassword:nil currentSecret:nil nextSalt:config.nextSalt nextPassword:@"" nextHint:nil email:nil secretRandom:nil nextSecureSalt:nil] deliverOn:[SQueue mainQueue]] onDispose:^
                                              {
                                                  TGDispatchOnMainThread(^
                                                                         {
                                                                             [progressWindow dismiss:true];
                                                                         });
                                              }] startWithNext:nil error:^(id error)
                                             {
                                                 NSString *errorText = TGLocalized(@"Login.UnknownError");
                                                 if ([error hasPrefix:@"FLOOD_WAIT"])
                                                     errorText = TGLocalized(@"TwoStepAuth.FloodError");
                                                 [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                             } completed:^
                                             {
                                                 __strong TGPrivacySettingsController *strongSelf = weakSelf;
                                                 if (strongSelf != nil)
                                                     [strongSelf.navigationController popToViewController:strongSelf animated:true];
                                             }]];
}

- (void)authSessionsPressed
{
    [self.navigationController pushViewController:[[TGAuthSessionsController alloc] init] animated:true];
}

- (void)passcodePressed
{
    [self.navigationController pushViewController:[[TGPasscodeSettingsController alloc] init] animated:true];
}

- (void)terminateSessionsPressed
{
    __weak TGPrivacySettingsController *weakSelf = self;
    [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"ChatSettings.ClearOtherSessionsConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
     {
         if (okButtonPressed)
         {
             TGPrivacySettingsController *strongSelf = weakSelf;
             [strongSelf _commitTerminateSessions];
         }
     }];
}

- (void)_commitTerminateSessions
{
    _progressWindow = [[TGProgressWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_progressWindow show:true];
    
    [ActionStageInstance() requestActor:@"/tg/service/revokesessions" options:nil watcher:self];
}

- (void)dataSettingsPressed
{
    [self.navigationController pushViewController:[[TGPrivateDataSettingsController alloc] init] animated:true];
}

- (void)touchIdToggle:(bool)enable
{
    if (iosMajorVersion() >= 8)
    {
        if (enable)
        {
            LAContext *context = [[LAContext alloc] init];
            
            NSError *error = nil;
            
            if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error])
            {
                [[NSUserDefaults standardUserDefaults] setObject:@(true) forKey:@"enableTouchId"];
            } else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@(false) forKey:@"enableTouchId"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Your device cannot authenticate using TouchID."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        else
            [[NSUserDefaults standardUserDefaults] setObject:@(false) forKey:@"enableTouchId"];
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/blockedUsers"])
    {
        NSArray *array = ((SGraphObjectNode *)resource).object;
        TGDispatchOnMainThread(^
                               {
                                   _blockedUsersItem.variant = array.count == 0 ? @"" : [TGStringUtils stringForUserCount:array.count];
                               });
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path isEqualToString:@"/accountSettings"])
    {
        TGDispatchOnMainThread(^
                               {
                                   if (status == ASStatusSuccess)
                                   {
                                       [self setAccountSettings:result];
                                   }
                                   
                                   [UIView animateWithDuration:0.3 animations:^
                                    {
                                        _activityIndicator.alpha = 0.0f;
                                        self.collectionView.alpha = 1.0f;
                                    } completion:^(__unused BOOL finished) {
                                        [_activityIndicator removeFromSuperview];
                                        _activityIndicator = nil;
                                    }];
                               });
    }
    else if ([path isEqualToString:@"/updateAccountSettings"])
    {
        TGDispatchOnMainThread(^
                               {
                                   [_progressWindow dismiss:true];
                                   _progressWindow = nil;
                                   
                                   if (status == ASStatusSuccess)
                                   {
                                       
                                   }
                                   else
                                   {
                                       TGAccountSettings *accountSettings = [TGAccountSettingsActor accountSettingsFotCurrentStateId];
                                       if (accountSettings == nil)
                                           accountSettings = [[TGAccountSettings alloc] initWithDefaultValues];
                                       [self setAccountSettings:accountSettings];
                                       
                                       [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"Login.UnknownError") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                   }
                               });
    }
    else if ([path isEqualToString:@"/tg/service/revokesessions"])
    {
        TGDispatchOnMainThread(^
                               {
                                   if (status == ASStatusSuccess)
                                   {
                                       [_progressWindow dismissWithSuccess];
                                       _progressWindow = nil;
                                   }
                                   else
                                   {
                                       [_progressWindow dismiss:true];
                                       _progressWindow = nil;
                                       
                                       [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"ChatSettings.ClearOtherSessionsFailed") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                   }
                               });
    }
}

@end
