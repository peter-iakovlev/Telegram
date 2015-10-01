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

@interface TGDebugController ()
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
        TGCollectionMenuSection *unreadSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            markEverythingAsReadItem
        ]];
        [self.menuSections addSection:unreadSection];
    }
    return self;
}

- (void)dealloc
{
}

- (void)sendLogsButtonPressed
{
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

@end
