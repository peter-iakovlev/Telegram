#import "TGPrivacySettingsController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGVariantCollectionItem.h"
#import "TGDisclosureActionCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGAccountSettings.h"

#import "TGPrivacyLastSeenController.h"
#import "TGBlockedController.h"
#import "TGDeleteAccountController.h"

#import "TGStringUtils.h"

#import "TGAlertView.h"
#import "TGPickerSheet.h"
#import "TGProgressWindow.h"

#import "TGAccountSettingsActor.h"

#import "TGDatabase.h"

@interface TGPrivacySettingsController () <ASWatcher>
{
    bool _receivedAccountSettings;
    UIActivityIndicatorView *_activityIndicator;
    TGProgressWindow *_progressWindow;
    
    TGVariantCollectionItem *_blockedUsersItem;
    TGAccountSettings *_accountSettings;
    TGVariantCollectionItem *_lastSeenItem;
    TGVariantCollectionItem *_accountExpirationItem;
    
    TGPickerSheet *_pickerSheet;
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
    
    return TGLocalized(@"PrivacySettings.DeleteAccountNever");
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.title = TGLocalized(@"PrivacySettings.Title");
        
        _lastSeenItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.LastSeen") action:@selector(lastSeenPressed)];
        _blockedUsersItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.BlockedUsers") action:@selector(blockedUsersPressed)];
        TGCollectionMenuSection *lastSeenSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.PrivacyTitle")],
            _blockedUsersItem,
            _lastSeenItem,
            [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"PrivacyLastSeenSettings.LastSeenHelp")]
        ]];
        UIEdgeInsets topSectionInsets = lastSeenSection.insets;
        topSectionInsets.top = 32.0f;
        lastSeenSection.insets = topSectionInsets;
        [self.menuSections addSection:lastSeenSection];
        
        TGButtonCollectionItem *terminateSessionsItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.ClearOtherSessions") action:@selector(terminateSessionsPressed)];
        terminateSessionsItem.titleColor = [UIColor blackColor];
        terminateSessionsItem.deselectAutomatically = true;
        
        TGCommentCollectionItem *clearOtherSessionsHelpItem = [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"ChatSettings.ClearOtherSessionsHelp")];
        
        TGCollectionMenuSection *securitySection = [[TGCollectionMenuSection alloc] initWithItems:@[
            [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"PrivacySettings.SecurityTitle")],
            terminateSessionsItem,
            clearOtherSessionsHelpItem
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
    _accountExpirationItem.variant = [self accountExpirationTimeVariantForAccountTTLSetting:_accountSettings.accountTTLSetting];
}

- (void)lastSeenPressed
{
    __weak TGPrivacySettingsController *weakSelf = self;
    [self.navigationController pushViewController:[[TGPrivacyLastSeenController alloc] initWithPrivacySettings:_accountSettings.notificationSettings privacySettingsChanged:^(TGNotificationPrivacyAccountSetting *privacySettings)
    {
        __strong TGPrivacySettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf->_progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [strongSelf->_progressWindow show:true];
            
            TGAccountSettings *accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:privacySettings accountTTLSetting:strongSelf->_accountSettings.accountTTLSetting];
            [strongSelf setAccountSettings:accountSettings];
            [ActionStageInstance() requestActor:@"/updateAccountSettings" options:@{@"settingList": @[privacySettings]} flags:0 watcher:strongSelf];
        }
    }] animated:true];
}

- (void)blockedUsersPressed
{
    [self.navigationController pushViewController:[[TGBlockedController alloc] init] animated:true];
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
    
    NSUInteger selectedIndex = 0;
    if (_accountSettings.accountTTLSetting.accountTTL != nil)
    {
        NSInteger closestMatchIndex = 0;
        NSInteger index = -1;
        for (NSNumber *nValue in timerValues)
        {
            index++;
            if ([nValue intValue] != 0 && ABS([nValue intValue] - [_accountSettings.accountTTLSetting.accountTTL intValue]) < ABS([timerValues[closestMatchIndex] intValue] - [_accountSettings.accountTTLSetting.accountTTL intValue]))
            {
                closestMatchIndex = index;
            }
        }
        selectedIndex = closestMatchIndex;
    }
    
    __weak TGPrivacySettingsController *weakSelf = self;
    _pickerSheet = [[TGPickerSheet alloc] initWithItems:timerValues selectedIndex:selectedIndex action:^(NSNumber *item)
    {
        __strong TGPrivacySettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGAccountTTLSetting *accountTTLSetting = [[TGAccountTTLSetting alloc] initWithAccountTTL:[item intValue] == 0 ? nil : item];
            
            TGAccountSettings *accountSettings = [[TGAccountSettings alloc] initWithNotificationSettings:strongSelf->_accountSettings.notificationSettings accountTTLSetting:accountTTLSetting];
            
            if (![strongSelf->_accountSettings.accountTTLSetting isEqual:accountTTLSetting])
            {
                strongSelf->_progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [strongSelf->_progressWindow show:true];
                
                [strongSelf setAccountSettings:accountSettings];
                [ActionStageInstance() requestActor:@"/updateAccountSettings" options:@{@"settingList": @[accountTTLSetting]} flags:0 watcher:strongSelf];
            }
        }
    }];
    _pickerSheet.emptyValue = TGLocalized(@"PrivacySettings.DeleteAccountNever");
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        [_pickerSheet show];
    else
    {
        NSIndexPath *indexPath = [self indexPathForItem:_accountExpirationItem];
        if (indexPath != nil)
        {
            UIView *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if (cell != nil)
                [_pickerSheet showFromRect:[cell convertRect:cell.bounds toView:self.view] inView:self.view];
        }
    }
}


- (void)terminateSessionsPressed
{
    __weak TGPrivacySettingsController *weakSelf = self;
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"ChatSettings.ClearOtherSessionsConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
    {
        if (okButtonPressed)
        {
            TGPrivacySettingsController *strongSelf = weakSelf;
            [strongSelf _commitTerminateSessions];
        }
    }] show];
}

- (void)_commitTerminateSessions
{
    _progressWindow = [[TGProgressWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_progressWindow show:true];
    
    [ActionStageInstance() requestActor:@"/tg/service/revokesessions" options:nil watcher:self];
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
                
                [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"PrivacySettings.FloodControlError") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
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
                
                [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"ChatSettings.ClearOtherSessionsFailed") cancelButtonTitle:nil okButtonTitle:TGLocalized(@"Common.OK") completionBlock:nil] show];
            }
        });
    }
}

@end
