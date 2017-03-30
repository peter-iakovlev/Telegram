#import "TGCallSettingsController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGAppDelegate.h"

#import "TGAccountSettings.h"
#import "TGAccountSettingsActor.h"

#import "TGDisclosureActionCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGProgressWindow.h"
#import "TGAlertView.h"

#import "TGRecentCallsController.h"
#import "TGCallDataSettingsController.h"
#import "TGPrivacyLastSeenController.h"

@interface TGCallSettingsController ()
{
    TGDisclosureActionCollectionItem *_recentCallsItem;
    TGSwitchCollectionItem *_tabIconItem;
    
    TGVariantCollectionItem *_useLessDataItem;
    
    bool _receivedAccountSettings;
    TGAccountSettings *_accountSettings;
    
    TGProgressWindow *_progressWindow;
}
@end

@implementation TGCallSettingsController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        [self setTitleText:TGLocalized(@"CallSettings.Title")];
        
        _recentCallsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"CallSettings.RecentCalls") action:@selector(recentCallsPressed)];
        
        _tabIconItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"CallSettings.TabIcon") isOn:TGAppDelegateInstance.showCallsTab];
        _tabIconItem.interfaceHandle = _actionHandle;
        
        TGCollectionMenuSection *mainSection = [[TGCollectionMenuSection alloc] initWithItems:@
        [
            _recentCallsItem,
            _tabIconItem,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"CallSettings.TabIconDescription")]
        ]];
        
        UIEdgeInsets topSectionInsets = mainSection.insets;
        topSectionInsets.top = 32.0f;
        mainSection.insets = topSectionInsets;
        
        [self.menuSections addSection:mainSection];
        
        _useLessDataItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"CallSettings.UseLessData") action:@selector(useLessDataPressed)];
        _useLessDataItem.variant = [self labelForDataMode:TGAppDelegateInstance.callsDataUsageMode];
        
        __weak TGCallSettingsController *weakSelf = self;
        TGCommentCollectionItem *hintItem = [[TGCommentCollectionItem alloc] init];
        hintItem.action = ^
        {
            __strong TGCallSettingsController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf privacySettingsPressed];
        };
        [hintItem setFormattedText:TGLocalized(@"CallSettings.PrivacyDescription")];
        
        TGCollectionMenuSection *dataSection = [[TGCollectionMenuSection alloc] initWithItems:@
        [
            _useLessDataItem,
            hintItem
        ]];
        
        [self.menuSections addSection:dataSection];

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        
        TGAccountSettings *accountSettings = [TGAccountSettingsActor accountSettingsFotCurrentStateId];
        if (accountSettings != nil)
            _receivedAccountSettings = true;
        else
            accountSettings = [[TGAccountSettings alloc] initWithDefaultValues];
        [self setAccountSettings:accountSettings];

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
        
        [ActionStageInstance() requestActor:@"/accountSettings" options:@{} flags:0 watcher:self];
    }
}

#pragma mark -

- (void)setAccountSettings:(TGAccountSettings *)accountSettings
{
    _accountSettings = accountSettings;
}

#pragma mark -

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)privacySettingsPressed
{
    if (_accountSettings == nil)
        return;
    
    __weak TGCallSettingsController *weakSelf = self;
    [self.navigationController pushViewController:[[TGPrivacyLastSeenController alloc] initWithMode:TGPrivacySettingsModeCalls privacySettings:_accountSettings.callSettings privacySettingsChanged:^(TGNotificationPrivacyAccountSetting *privacySettings)
    {
        __strong TGCallSettingsController *strongSelf = weakSelf;
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

- (void)recentCallsPressed
{
    [self.navigationController pushViewController:[[TGRecentCallsController alloc] initWithController:TGAppDelegateInstance.rootController.callsController] animated:true];
}

- (void)useLessDataPressed
{
    __weak TGCallSettingsController *weakSelf = self;
    TGCallDataSettingsController *controller = [[TGCallDataSettingsController alloc] init];
    controller.onModeChanged = ^(int mode)
    {
        __strong TGCallSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
            strongSelf->_useLessDataItem.variant = [strongSelf labelForDataMode:mode];
    };
    [self.navigationController pushViewController:controller animated:true];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"switchItemChanged"])
    {
        TGSwitchCollectionItem *switchItem = options[@"item"];
        
        if (switchItem == _tabIconItem)
        {
            TGAppDelegateInstance.showCallsTab = switchItem.isOn;
            [TGAppDelegateInstance saveSettings];
            
            [TGAppDelegateInstance.rootController.mainTabsController setCallsHidden:!switchItem.isOn animated:false];
        }
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
}

- (NSString *)labelForDataMode:(int)dataMode
{
    switch (dataMode)
    {
        case 1:
            return TGLocalized(@"CallSettings.OnMobile");
            
        case 2:
            return TGLocalized(@"CallSettings.Always");
            
        default:
            return TGLocalized(@"CallSettings.Never");
    }
}

@end
