#import "TGDebugController.h"

#import "TGAppDelegate.h"
#import "TGTelegramNetworking.h"

#import "TGSwitchCollectionItem.h"
#import "TGButtonCollectionItem.h"

#import "TGForwardTargetController.h"

#import "TL/TLMetaScheme.h"

#import "TGProgressWindow.h"
#import "TGAlertView.h"

#import "TGDatabase.h"

#import "TGNetworkOverridesController.h"

#import "TGActionSheet.h"

#import <MessageUI/MessageUI.h>

#import "TGTelegraph.h"

@interface TGDebugController () <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>
{
    TGSwitchCollectionItem *_logsEnabledItem;
}

@end

@implementation TGDebugController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _logsEnabledItem = [[TGSwitchCollectionItem alloc] initWithTitle:@"Enable Logging" isOn:[TGAppDelegateInstance enableLogging]];
        _logsEnabledItem.toggled = ^(bool logsEnabled)
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
        @"TG_didShowSilentBroadcastTooltip",
        @"TG_displayedGifsTooltip_v0",
        @"TG_displayedCameraHoldToVideoTooltip_v0",
        @"TG_displayedBotResultsPreviewTooltip_v0"
    ];

    for (NSString *key in keys)
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)mailComposeController:(MFMailComposeViewController *)__unused controller didFinishWithResult:(MFMailComposeResult)__unused result error:(NSError *)__unused error
{
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
