#import "TGCallSettingsController.h"

#import "TGAppDelegate.h"

#import "TGDisclosureActionCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "ActionStage.h"

#import "TGRecentCallsController.h"
#import "TGCallDataSettingsController.h"

@interface TGCallSettingsController ()
{
    TGDisclosureActionCollectionItem *_recentCallsItem;
    TGSwitchCollectionItem *_tabIconItem;
    
    TGVariantCollectionItem *_useLessDataItem;
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
        
        //UIEdgeInsets topSectionInsets = mainSection.insets;
        //topSectionInsets.top = 32.0f;
        //mainSection.insets = topSectionInsets;
        
        //[self.menuSections addSection:mainSection];
        
        _useLessDataItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"CallSettings.UseLessData") action:@selector(useLessDataPressed)];
        _useLessDataItem.variant = [self labelForDataMode:TGAppDelegateInstance.callsDataUsageMode];
        
        TGCollectionMenuSection *dataSection = [[TGCollectionMenuSection alloc] initWithItems:@
        [
            _useLessDataItem,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"CallSettings.UseLessDataDescription")]
        ]];
        
        UIEdgeInsets topSectionInsets = dataSection.insets;
        topSectionInsets.top = 32.0f;
        dataSection.insets = topSectionInsets;

        
        [self.menuSections addSection:dataSection];

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

#pragma mark -

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)recentCallsPressed
{
    [self.navigationController pushViewController:[[TGRecentCallsController alloc] initForSettings:true] animated:true];
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

- (void)actorCompleted:(int)__unused status path:(NSString *)__unused path result:(id)__unused result
{
}

@end
