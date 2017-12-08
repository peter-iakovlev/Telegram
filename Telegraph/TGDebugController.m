#import "TGDebugController.h"

#import "TGAppDelegate.h"
#import "TGTelegramNetworking.h"

#import "TGSwitchCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGVersionCollectionItem.h"

#import "TGForwardTargetController.h"

#import "TL/TLMetaScheme.h"

#import <LegacyComponents/TGProgressWindow.h>
#import "TGAlertView.h"

#import "TGDatabase.h"

#import "TGNetworkOverridesController.h"

#import "TGActionSheet.h"

#import <MessageUI/MessageUI.h>

#import "TGTelegraph.h"

#import "TGDatabase.h"

#import "TGAccountSignals.h"

@interface TGDebugController () <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, ASWatcher>
{
    TGSwitchCollectionItem *_logsEnabledItem;
    TGProgressWindow *_progressWindow;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGDebugController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        _logsEnabledItem = [[TGSwitchCollectionItem alloc] initWithTitle:@"Enable Logging" isOn:[TGAppDelegateInstance enableLogging]];
        _logsEnabledItem.toggled = ^(bool logsEnabled, __unused TGSwitchCollectionItem *item)
        {
            [TGAppDelegateInstance setEnableLogging:logsEnabled];
        };
        TGButtonCollectionItem *sendLogsItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Send Logs" action:@selector(sendLogsButtonPressed)];
        sendLogsItem.deselectAutomatically = true;
        TGButtonCollectionItem *sendMoreLogsItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Send More Logs" action:@selector(sendMoreLogsButtonPressed)];
        TGCollectionMenuSection *logsEnabledSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _logsEnabledItem,
            sendLogsItem,
            sendMoreLogsItem
        ]];
        [self.menuSections addSection:logsEnabledSection];
        
        TGButtonCollectionItem *markEverythingAsReadItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Sync Unread" action:@selector(syncUnreadPressed)];
        markEverythingAsReadItem.deselectAutomatically = true;
        TGButtonCollectionItem *resetPermissionsItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Reset Permissions" action:@selector(resetPermissionsPressed)];
        TGButtonCollectionItem *resetTooltipsItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Reset Tooltips" action:@selector(resetTooltipsPressed)];
        markEverythingAsReadItem.deselectAutomatically = true;
        TGCollectionMenuSection *unreadSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            markEverythingAsReadItem,
            resetPermissionsItem,
            resetTooltipsItem
        ]];
        [self.menuSections addSection:unreadSection];
        
        TGButtonCollectionItem *networkOverridesItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Network Overrides" action:@selector(networkOverridesPressed)];
        TGCollectionMenuSection *networkOverridesSection = [[TGCollectionMenuSection alloc] initWithItems:@[networkOverridesItem]];
        [self.menuSections addSection:networkOverridesSection];
        
        TGButtonCollectionItem *resetPaymentsItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Reset Saved Payment Info" action:@selector(resetPaymentsPressed)];
        TGCollectionMenuSection *resetPaymentsSection = [[TGCollectionMenuSection alloc] initWithItems:@[resetPaymentsItem]];
        [self.menuSections addSection:resetPaymentsSection];
        
        TGButtonCollectionItem *databaseItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Switch to WAL" action:@selector(walPressed)];
        TGCollectionMenuSection *databaseSection = [[TGCollectionMenuSection alloc] initWithItems:@[databaseItem]];
        [self.menuSections addSection:databaseSection];
        
        TGButtonCollectionItem *fetchDebugIpsItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Fetch IPs" action:@selector(fetchDebugIps)];
        TGCollectionMenuSection *fetchDebugIpsItemSection = [[TGCollectionMenuSection alloc] initWithItems:@[fetchDebugIpsItem]];
        [self.menuSections addSection:fetchDebugIpsItemSection];
        
        TGButtonCollectionItem *clearCacheItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Wipe Cache" action:@selector(clearCachePressed)];
        clearCacheItem.deselectAutomatically = true;
        TGCollectionMenuSection *clearCacheSection = [[TGCollectionMenuSection alloc] initWithItems:@[clearCacheItem]];
        [self.menuSections addSection:clearCacheSection];
        
        TGButtonCollectionItem *resetContactsItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Reset Server Contacts" action:@selector(resetContactsPressed)];
        resetContactsItem.deselectAutomatically = true;
        TGCollectionMenuSection *resetContactsItemSection = [[TGCollectionMenuSection alloc] initWithItems:@[resetContactsItem]];
        [self.menuSections addSection:resetContactsItemSection];
        
        NSString *version = [NSString stringWithFormat:@"v%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        version = [NSString stringWithFormat:@"%@ (%@)", version, [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
        TGVersionCollectionItem *versionItem = [[TGVersionCollectionItem alloc] initWithVersion:version];
        
        TGButtonCollectionItem *resetCallsTabItem = [[TGButtonCollectionItem alloc] initWithTitle:@"Reset Calls Tab" action:@selector(resetCallsTabPressed)];
        resetCallsTabItem.deselectAutomatically = true;
        TGCollectionMenuSection *callsSection = [[TGCollectionMenuSection alloc] initWithItems:@[resetCallsTabItem, versionItem]];
        [self.menuSections addSection:callsSection];
    }
    return self;
}

- (void)dealloc
{
}

- (void)sendLogsButtonPressed
{
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:@"Forward via Telegram" action:@"tg"],
        [[TGActionSheetAction alloc] initWithTitle:@"Forward via Mail" action:@"mail"],
        [[TGActionSheetAction alloc] initWithTitle:@"Cancel" action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(id target, NSString *action) {
        TGDebugController *strongSelf = target;
        
        if ([action isEqualToString:@"tg"]) {
            NSMutableArray *uploadFileArray = [[NSMutableArray alloc] init];
            
            for (NSString *filePath in TGGetLogFilePaths(4))
            {
                int64_t randomId = 0;
                arc4random_buf(&randomId, 8);
                
                NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@_%" PRId64 ".txt", [filePath lastPathComponent], randomId]];
                
                if ([[NSFileManager defaultManager] copyItemAtPath:filePath toPath:tempFilePath error:NULL])
                {
                    [uploadFileArray addObject:@{@"url": [NSURL fileURLWithPath:tempFilePath]}];
                }
            }
            
            [TGAppDelegateInstance.rootController clearContentControllers];
            
            TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithDocumentFiles:uploadFileArray];
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[forwardController]];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            [TGAppDelegateInstance.rootController presentViewController:navigationController animated:false completion:nil];
        } else if ([action isEqualToString:@"mail"]) {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *composeController = [[MFMailComposeViewController alloc] init];
                composeController.mailComposeDelegate = strongSelf;
                [composeController setSubject:@"Telegram Logs"];
                NSString *versionString = [[NSString alloc] initWithFormat:@"%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
                [composeController setMessageBody:[NSString stringWithFormat:@"User %d v %@", TGTelegraphInstance.clientUserId, versionString] isHTML:false];
                
                for (NSString *filePath in TGGetLogFilePaths(4)) {
                    NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
                    if (data != nil && data.length != 0) {
                        [composeController addAttachmentData:data mimeType:@"application/text" fileName:[filePath lastPathComponent]];
                    }
                }
                
                [strongSelf presentViewController:composeController animated:true completion:nil];
            }
            else
            {
                [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Login.EmailNotConfiguredError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
            }
        }
    } target:self] showInView:self.view];
}

- (void)sendMoreLogsButtonPressed
{
    NSMutableArray *uploadFileArray = [[NSMutableArray alloc] init];
    
    for (NSString *filePath in TGGetLogFilePaths(100))
    {
        int64_t randomId = 0;
        arc4random_buf(&randomId, 8);
        
        NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@_%" PRId64 ".txt", [filePath lastPathComponent], ABS(randomId)]];
        
        if ([[NSFileManager defaultManager] copyItemAtPath:filePath toPath:tempFilePath error:NULL])
        {
            [uploadFileArray addObject:@{@"url": [NSURL fileURLWithPath:tempFilePath]}];
        }
    }
    
    [TGAppDelegateInstance.rootController clearContentControllers];
    
    TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithDocumentFiles:uploadFileArray];
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[forwardController]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [TGAppDelegateInstance.rootController presentViewController:navigationController animated:false completion:nil];
}

- (void)syncUnreadPressed
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    [[[[[TGTelegramNetworking instance] requestSignal:[[TLRPCupdates_getState$updates_getState alloc] init]] deliverOn:[SQueue mainQueue]] onDispose:^
    {
        TGDispatchOnMainThread(^
        {
            [progressWindow dismiss:true];
        });
    }] startWithNext:^(TLupdates_State *state)
    {
        [TGDatabaseInstance() dispatchOnDatabaseThread:^
        {
            TGDatabaseState currentState = [TGDatabaseInstance() databaseState];
            if (currentState.unreadCount != state.unread_count)
            {
                [TGDatabaseInstance() applyPts:currentState.pts date:currentState.date seq:currentState.seq qts:currentState.qts unreadCount:state.unread_count];
                TGDispatchOnMainThread(^
                {
                    [[[TGAlertView alloc] initWithTitle:nil message:@"Unread count corrected" cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                });
            }
        } synchronous:false];
    }];
    
}

- (void)networkOverridesPressed {
    TGNetworkOverridesController *controller = [[TGNetworkOverridesController alloc] init];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)resetPermissionsPressed {
    TGAppDelegateInstance.allowSecretWebpages = false;
    TGAppDelegateInstance.allowSecretWebpagesInitialized = false;
    TGAppDelegateInstance.secretInlineBotsInitialized = false;
    [TGAppDelegateInstance saveSettings];
}

- (void)resetTooltipsPressed {
    NSArray *keys = @
    [
        @"TG_displayedGifsTooltip_v0",
        @"TG_displayedCameraHoldToVideoTooltip_v0",
        @"TG_displayedPrivateRecordModeTooltip_v0",
        @"TG_displayedChannelRecordModeTooltip_v0",
        @"TG_displayedPrivateRevertRecordModeTooltip_v0",
        @"TG_displayedChannelRevertRecordModeTooltip_v0",
        @"TG_lastPrivateRecordModeIsVideo_v0",
        @"TG_lastChannelRecordModeIsAudio_v0",
        @"TG_displayedMediaTimerTooltip_v0",
        @"TG_displayedGroupTooltip_v0"
    ];

    for (NSString *key in keys)
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [TGDatabaseInstance() setCustomProperty:@"checkedLocalization" value:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)__unused controller didFinishWithResult:(MFMailComposeResult)__unused result error:(NSError *)__unused error
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)resetPaymentsPressed {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    TLRPCpayments_clearSavedInfo$payments_clearSavedInfo *clearSavedInfo = [[TLRPCpayments_clearSavedInfo$payments_clearSavedInfo alloc] init];
    clearSavedInfo.flags = 1 | 2;
    
    [[[[[TGTelegramNetworking instance] requestSignal:clearSavedInfo] deliverOn:[SQueue mainQueue]] onDispose:^
    {
        TGDispatchOnMainThread(^
        {
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil];
}

- (void)resetCallsTabPressed {
    [TGAppDelegateInstance resetCallsTab];
    [TGAppDelegateInstance.rootController.mainTabsController setCallsHidden:true animated:false];
}

- (void)walPressed {
    [TGDatabaseInstance() switchToWal];
}

- (void)fetchDebugIps {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow show:true];
    [[[TGAccountSignals fetchBackupIps:false] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil completed:^{
        
    }];
}

- (void)clearCachePressed {
    [TGDatabaseInstance() setCustomProperty:@"cachedStickersByQuery" value:nil];
    
    [[TGRemoteImageView sharedCache] clearCache:TGCacheBoth];
    
    NSString *documentsPath = [TGAppDelegate documentsPath];
    
    NSString *filesPath = [[NSString alloc] initWithFormat:@"%@/files", documentsPath];
    [[NSFileManager defaultManager] removeItemAtPath:filesPath error:nil];
    
    NSString *stickerCachePath = [[NSString alloc] initWithFormat:@"%@/sticker-cache", documentsPath];
    [[NSFileManager defaultManager] removeItemAtPath:stickerCachePath error:nil];
}

- (void)resetContactsPressed {
    [_progressWindow dismiss:true];
    
    _progressWindow = [[TGProgressWindow alloc] init];
    [_progressWindow show:true];
    [[[TGTelegramNetworking instance] requestSignal:[[TLRPCcontacts_resetSaved$contacts_resetSaved alloc] init]] startWithNext:nil completed:^{
        [ActionStageInstance() requestActor:@"/tg/synchronizeContacts/(sync)" options:@{@"forceFirstTime": @(true)} watcher:self];
    }];
}

- (void)actorCompleted:(int)__unused status path:(NSString *)path result:(id)__unused result {
    if ([path isEqualToString:@"/tg/synchronizeContacts/(sync)"]) {
        TGDispatchOnMainThread(^{
            [_progressWindow dismissWithSuccess];
            _progressWindow = nil;
        });
    }
}

@end
