#import "TGSettingsController.h"

#import "TGMenuSection.h"

#import "TGAppDelegate.h"

#import "TGActionMenuItemCell.h"
#import "TGSwitchItemCell.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGInterfaceAssets.h"

#import "TGRemoteImageView.h"

#import <MessageUI/MessageUI.h>

#import "TGForwardTargetController.h"

@interface TGSettingsController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sectionList;

@end

@implementation TGSettingsController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _sectionList = [[NSMutableArray alloc] init];
        
#ifndef EXTERNAL_INTERNAL_RELEASE
        TGMenuSection *sessionSection = [[TGMenuSection alloc] init];
        sessionSection.tag = 1;
        sessionSection.title = @"Security";
        [_sectionList addObject:sessionSection];
        
        TGMenuSection *accountSection = [[TGMenuSection alloc] init];
        accountSection.title = @"Account";
        [_sectionList addObject:accountSection];
        
        /*TGSwitchItem *displayMids = [[TGSwitchItem alloc] initWithTitle:@"Show message IDs"];
        displayMids.isOn = [TGConversationMessageItemView displayMids];
        displayMids.action = @selector(switchDisplayMids);
        [accountSection.items addObject:displayMids];
        
#ifndef DEBUG
        if (TGTelegraphInstance.clientUserId == 333000)
#endif
        {
            TGSwitchItem *doNotRead = [[TGSwitchItem alloc] initWithTitle:@"Don't read"];
            doNotRead.isOn = [TGTelegraphConversationCompanion doNotRead];
            doNotRead.action = @selector(switchDoNotRead);
            [accountSection.items addObject:doNotRead];
        }*/
        
        TGSwitchItem *doNotJump = [[TGSwitchItem alloc] initWithTitle:@"Don't jump in dialogs"];
        doNotJump.isOn = [TGDialogListController debugDoNotJump];
        doNotJump.action = @selector(switchDoNotJump);
        [accountSection.items addObject:doNotJump];
        
        TGSwitchItem *disableBackgroundItem = [[TGSwitchItem alloc] initWithTitle:@"Disable background mode"];
        disableBackgroundItem.isOn = TGAppDelegateInstance.disableBackgroundMode;
        disableBackgroundItem.action = @selector(switchDisableBackground);
        [accountSection.items addObject:disableBackgroundItem];
#endif
        
        TGMenuSection *miscSection = [[TGMenuSection alloc] init];
        miscSection.title = @"Misc";
        [_sectionList addObject:miscSection];
        
#ifndef EXTERNAL_INTERNAL_RELEASE
        TGActionMenuItem *clearItemUriCacheItem = [[TGActionMenuItem alloc] initWithTitle:@"Clear item uri cache"];
        clearItemUriCacheItem.action = @selector(clearItemUriButtonPressed);
        [miscSection.items addObject:clearItemUriCacheItem];
        
        TGActionMenuItem *clearAssetCacheItem = [[TGActionMenuItem alloc] initWithTitle:@"Clear asset cache"];
        clearAssetCacheItem.action = @selector(clearAssetCacheButtonPressed);
        [miscSection.items addObject:clearAssetCacheItem];
        
        TGActionMenuItem *clearAvatarCacheItem = [[TGActionMenuItem alloc] initWithTitle:@"Clear avatar list cache"];
        clearAvatarCacheItem.action = @selector(clearAvatarCacheButtonPressed);
        [miscSection.items addObject:clearAvatarCacheItem];
        
        TGActionMenuItem *clearCacheItem = [[TGActionMenuItem alloc] initWithTitle:@"Clear both caches"];
        clearCacheItem.action = @selector(clearCacheButtonPressed);
        [miscSection.items addObject:clearCacheItem];
        
        TGActionMenuItem *clearMemoryCacheItem = [[TGActionMenuItem alloc] initWithTitle:@"Clear memory cache"];
        clearMemoryCacheItem.action = @selector(clearMemoryCacheButtonPressed);
        [miscSection.items addObject:clearMemoryCacheItem];
        
        TGActionMenuItem *clearVideoCacheItem = [[TGActionMenuItem alloc] initWithTitle:@"Clear video cache"];
        clearVideoCacheItem.action = @selector(clearVideoCacheButtonPressed);
        [miscSection.items addObject:clearVideoCacheItem];
#endif
        
        TGActionMenuItem *sendLogsItem = [[TGActionMenuItem alloc] initWithTitle:@"Send logs"];
        sendLogsItem.action = @selector(sendLogsButtonPressed);
        [miscSection.items addObject:sendLogsItem];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)loadView
{
    [super loadView];
    
    self.titleText = TGLocalized(@"Settings.Title");
    
    self.view.backgroundColor = [[TGInterfaceAssets instance] linesBackground];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
}

- (void)doUnloadView
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return true;
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView
{
    return [_sectionList count];
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)section
{
    return [[(TGMenuSection *)[_sectionList objectAtIndex:section] items] count];
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < (int)_sectionList.count)
    {
        TGMenuSection *section = [_sectionList objectAtIndex:indexPath.section];
        if (indexPath.row < (int)section.items.count)
        {
            TGMenuItem *item = [section.items objectAtIndex:indexPath.row];
            
            if (item.type == TGActionMenuItemType || item.type == TGSwitchItemType)
                return 44;
        }
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)__unused tableView titleForHeaderInSection:(NSInteger)section
{
    return ((TGMenuSection *)[_sectionList objectAtIndex:section]).title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGMenuItem *item = nil;
    bool firstInSection = false;
    bool lastInSection = false;
    
    if (indexPath.section < (int)_sectionList.count)
    {
        TGMenuSection *section = [_sectionList objectAtIndex:indexPath.section];
        if (indexPath.row < (int)section.items.count)
        {
            item = [section.items objectAtIndex:indexPath.row];
            
            if (indexPath.row == 0)
                firstInSection = true;
            if (indexPath.row + 1 == (int)section.items.count)
                lastInSection = true;
        }
    }
    
    if (item != nil)
    {
        UITableViewCell *cell = nil;
        
        if (item.type == TGActionMenuItemType)
        {
            static NSString *actionItemCellIdentifier = @"AI";
            TGActionMenuItemCell *actionItemCell = (TGActionMenuItemCell *)[tableView dequeueReusableCellWithIdentifier:actionItemCellIdentifier];
            if (actionItemCell == nil)
            {
                actionItemCell = [[TGActionMenuItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:actionItemCellIdentifier];
                
                UIImageView *backgroundView = [[UIImageView alloc] init];
                actionItemCell.backgroundView = backgroundView;
                UIImageView *selectedBackgroundView = [[UIImageView alloc] init];
                actionItemCell.selectedBackgroundView = selectedBackgroundView;
            }
            
            TGActionMenuItem *actionItem = (TGActionMenuItem *)item;
            
            actionItemCell.title = actionItem.title;
            
            cell = actionItemCell;
        }
        else if (item.type == TGSwitchItemType)
        {
            static NSString *switchItemCellIdentifier = @"SI";
            TGSwitchItemCell *switchItemCell = (TGSwitchItemCell *)[tableView dequeueReusableCellWithIdentifier:switchItemCellIdentifier];
            if (switchItemCell == nil)
            {
                switchItemCell = [[TGSwitchItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:switchItemCellIdentifier];
                
                UIImageView *backgroundView = [[UIImageView alloc] init];
                switchItemCell.backgroundView = backgroundView;
                UIImageView *selectedBackgroundView = [[UIImageView alloc] init];
                switchItemCell.selectedBackgroundView = selectedBackgroundView;
                
                switchItemCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                switchItemCell.watcherHandle = _actionHandle;
            }
            
            TGSwitchItem *switchItem = (TGSwitchItem *)item;
            
            switchItemCell.title = switchItem.title;
            switchItemCell.isOn = switchItem.isOn;
            
            switchItemCell.itemId = switchItem;
            
            cell = switchItemCell;
        }
        
        if (cell != nil)
        {
            if (firstInSection && lastInSection)
            {
                [(TGGroupedCell *)cell setGroupedCellPosition:TGGroupedCellPositionFirst | TGGroupedCellPositionLast];
                [(TGGroupedCell *)cell setExtendSelectedBackground:false];
                
                ((UIImageView *)cell.backgroundView).image = [TGInterfaceAssets groupedCellSingle];
                ((UIImageView *)cell.selectedBackgroundView).image = [TGInterfaceAssets groupedCellSingleHighlighted];
            }
            else if (firstInSection)
            {
                [(TGGroupedCell *)cell setGroupedCellPosition:TGGroupedCellPositionFirst];
                [(TGGroupedCell *)cell setExtendSelectedBackground:true];
                
                ((UIImageView *)cell.backgroundView).image = [TGInterfaceAssets groupedCellTop];
                ((UIImageView *)cell.selectedBackgroundView).image = [TGInterfaceAssets groupedCellTopHighlighted];
            }
            else if (lastInSection)
            {
                [(TGGroupedCell *)cell setGroupedCellPosition:TGGroupedCellPositionLast];
                [(TGGroupedCell *)cell setExtendSelectedBackground:true];
                
                ((UIImageView *)cell.backgroundView).image = [TGInterfaceAssets groupedCellBottom];
                ((UIImageView *)cell.selectedBackgroundView).image = [TGInterfaceAssets groupedCellBottomHighlighted];
            }
            else
            {
                [(TGGroupedCell *)cell setGroupedCellPosition:0];
                [(TGGroupedCell *)cell setExtendSelectedBackground:true];
                
                ((UIImageView *)cell.backgroundView).image = [TGInterfaceAssets groupedCellMiddle];
                ((UIImageView *)cell.selectedBackgroundView).image = [TGInterfaceAssets groupedCellMiddleHighlighted];
            }
            
            return cell;
        }
    }
    
    static NSString *emptyCellIdentifier = @"EC";
    UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:emptyCellIdentifier];
    if (emptyCell == nil)
        emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emptyCellIdentifier];
    return emptyCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGMenuItem *item = nil;
    
    if (indexPath.section < (int)_sectionList.count)
    {
        TGMenuSection *section = [_sectionList objectAtIndex:indexPath.section];
        if (indexPath.row < (int)section.items.count)
        {
            item = [section.items objectAtIndex:indexPath.row];
        }
    }
    
    if (item != nil)
    {
        if (item.type == TGActionMenuItemType)
        {
            TGActionMenuItem *actionItem = (TGActionMenuItem *)item;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([self respondsToSelector:actionItem.action])
                [self performSelector:actionItem.action];
#pragma clang diagnostic pop
            
            [tableView deselectRowAtIndexPath:indexPath animated:true];
        }
        else if (item.type == TGSwitchItemType)
        {
            TGSwitchItem *switchItem = (TGSwitchItem *)item;
            switchItem.isOn = !switchItem.isOn;
            [(TGSwitchItemCell *)[tableView cellForRowAtIndexPath:indexPath] setIsOn:switchItem.isOn animated:true];
            [(TGSwitchItemCell *)[tableView cellForRowAtIndexPath:indexPath] fireChangeEvent];
        }
    }
}

#pragma mark - Actions

- (void)logoutButtonPressed
{
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/auth/logout/(%d)", TGTelegraphInstance.clientUserId] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:true] forKey:@"force"] watcher:TGTelegraphInstance];
}

- (void)revokeButtonPressed
{
    [ActionStageInstance() requestActor:@"/tg/service/revokesessions" options:nil watcher:self];
}

- (void)clearItemUriButtonPressed
{
    [TGDatabaseInstance() clearServerAssetData];
}

- (void)clearAssetCacheButtonPressed
{
    NSArray *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *assetsPath = [[NSString alloc] initWithFormat:@"%@/assets", documentsPath];
    [[NSFileManager defaultManager] removeItemAtPath:assetsPath error:nil];
}

- (void)clearAvatarCacheButtonPressed
{
    [TGDatabaseInstance() clearPeerProfilePhotos];
}

- (void)clearCacheButtonPressed
{
    [[TGRemoteImageView sharedCache] clearCache:TGCacheBoth];
}

- (void)clearMemoryCacheButtonPressed
{
    [[TGRemoteImageView sharedCache] clearCache:TGCacheMemory];
}

- (void)clearVideoCacheButtonPressed
{
    dispatch_async([TGCache diskCacheQueue], ^
    {
        NSString *videosPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0] stringByAppendingPathComponent:@"video"];
        
        for (NSString *fileName in [[TGCache diskFileManager] contentsOfDirectoryAtPath:videosPath error:nil])
        {
            if ([fileName hasPrefix:@"remote"])
                [[TGCache diskFileManager] removeItemAtPath:[videosPath stringByAppendingPathComponent:fileName] error:nil];
        }
    });
}

- (void)sendLogsButtonPressed
{
    NSMutableArray *uploadFileArray = [[NSMutableArray alloc] init];
    
    for (NSString *filePath in TGGetLogFilePaths())
    {
        int64_t randomId = 0;
        arc4random_buf(&randomId, 8);
        
        NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@_%" PRId64 ".txt", [filePath lastPathComponent], randomId]];
        
        if ([[NSFileManager defaultManager] copyItemAtPath:filePath toPath:tempFilePath error:NULL])
        {
            [uploadFileArray addObject:@{@"url": [NSURL fileURLWithPath:tempFilePath]}];
        }
    }
    
    [TGAppDelegateInstance.mainNavigationController popToRootViewControllerAnimated:false];
    
    TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithDocumentFiles:uploadFileArray];
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[forwardController]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [TGAppDelegateInstance.mainTabsController presentViewController:navigationController animated:false completion:nil];
    
    /*if ([MFMailComposeViewController canSendMail])
    {
        NSArray *logsData = TGGetPackedLogs();
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        
        [mailViewController setSubject:[NSString stringWithFormat:@"Logs from %@ (%@)", [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId].displayName, [NSDate date]]];
        [mailViewController setMessageBody:@"Application logs" isHTML:false];
        
        int index = 0;
        for (NSData *data in logsData)
        {
            [mailViewController addAttachmentData:data mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"application-%d.log", index++]];
        }
        
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"logs@telegram.org"]];
        
        [self presentViewController:mailViewController animated:true completion:nil];
    }
    else
    {
        [[[TGAlertView alloc] initWithTitle:nil message:@"Please configure at least one email account" delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
    }*/
}

- (void)mailComposeController:(MFMailComposeViewController *)__unused controller didFinishWithResult:(MFMailComposeResult)__unused result error:(NSError *)__unused error
{
    [self dismissViewControllerAnimated:true completion:nil];
}

/*- (void)switchDisplayMids
{
    [TGConversationMessageItemView setDisplayMids:![TGConversationMessageItemView displayMids]];
}

- (void)switchDoNotRead
{
    [TGTelegraphConversationCompanion setDoNotRead:![TGTelegraphConversationCompanion doNotRead]];
}*/

- (void)switchDoNotJump
{
    [TGDialogListController setDebugDoNotJump:![TGDialogListController debugDoNotJump]];
}

- (void)switchDisableBackground
{
    TGAppDelegateInstance.disableBackgroundMode = !TGAppDelegateInstance.disableBackgroundMode;
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)__unused result
{
    if ([path isEqualToString:@"/tg/service/revokesessions"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (resultCode == ASStatusSuccess)
            {
                TGLog(@"===== Other sessions revoked");
            }
            else
            {
                TGLog(@"***** Failed to revoke other sessions");                
            }
        });
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(NSDictionary *)options
{
    if ([action isEqualToString:@"toggleSwitchItem"])
    {
        TGSwitchItem *switchItem = [options objectForKey:@"itemId"];
        if (switchItem == nil)
            return;
        
        NSNumber *nValue = [options objectForKey:@"value"];
        
        switchItem.isOn = [nValue boolValue];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([self respondsToSelector:switchItem.action])
            [self performSelector:switchItem.action];
#pragma clang diagnostic pop
    }
}

@end
