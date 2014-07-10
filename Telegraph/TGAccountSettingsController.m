#import "TGAccountSettingsController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTimelineUploadPhotoRequestBuilder.h"
#import "TGDeleteProfilePhotoActor.h"

#import "TGNotificationSettingsController.h"
#import "TGChatSettingsController.h"
#import "TGBlockedController.h"

#import "TGAccountInfoCollectionItem.h"
#import "TGDisclosureActionCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGWallpapersCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGWallpaperListController.h"
#import "TGWallpaperController.h"
#import "TGWallpaperManager.h"

#import "TGActionSheet.h"
#import "TGProgressWindow.h"
#import "TGRemoteImageView.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGTelegraphProfileImageViewCompanion.h"
#import "TGImageViewController.h"
#import "TGAppDelegate.h"
#import "TGHacks.h"
#import "TGInterfaceManager.h"
#import "TGAlertView.h"

#import "TGLegacyCameraController.h"
#import "TGImagePickerController.h"
#import "TGImageSearchController.h"

#import "TGSettingsController.h"

@interface TGAccountSettingsController () <TGImagePickerControllerDelegate, TGLegacyCameraControllerDelegate, TGWallpaperControllerDelegate>
{
    int32_t _uid;
    
    bool _editing;
    
    TGAccountInfoCollectionItem *_profileDataItem;
    TGButtonCollectionItem *_setProfilePhotoItem;
    
    TGSwitchCollectionItem *_autosavePhotosItem;
    
    TGWallpapersCollectionItem *_wallpapersItem;
    
    TGDisclosureActionCollectionItem *_notificationsItem;
    TGDisclosureActionCollectionItem *_blockedUsersItem;
    TGDisclosureActionCollectionItem *_chatSettingsItem;
    TGDisclosureActionCollectionItem *_supportItem;
    TGDisclosureActionCollectionItem *_faqItem;
    
    UIBarButtonItem *_accountEditingBarButtonItem;
}

@property (nonatomic, strong) TGProgressWindow *progressWindow;

@end

@implementation TGAccountSettingsController

- (id)initWithUid:(int32_t)uid
{
    self = [super init];
    if (self)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        [ActionStageInstance() watchForPaths:@[
            @"/tg/userdatachanges",
            @"/tg/userpresencechanges",
            @"/tg/service/synchronizationstate"
        ] watcher:self];
        
        [ActionStageInstance() requestActor:@"/tg/service/synchronizationstate" options:nil flags:0 watcher:self];
        
        _uid = uid;
        
        _profileDataItem = [[TGAccountInfoCollectionItem alloc] init];
        _profileDataItem.interfaceHandle = _actionHandle;
        _setProfilePhotoItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.SetProfilePhoto") action:@selector(setProfilePhotoPressed)];
        _setProfilePhotoItem.deselectAutomatically = true;
        
        TGCollectionMenuSection *headerSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _profileDataItem,
            _setProfilePhotoItem
        ]];
        [self.menuSections addSection:headerSection];
        
        _wallpapersItem = [[TGWallpapersCollectionItem alloc] initWithAction:@selector(wallpapersPressed) title:TGLocalized(@"Settings.ChatBackground")];
        _wallpapersItem.interfaceHandle = _actionHandle;
        
        TGCollectionMenuSection *settingsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            (_notificationsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.NotificationsAndSounds") action:@selector(notificationsAndSoundsPressed)]),
            (_blockedUsersItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.BlockedUsers") action:@selector(blockedUsersPressed)]),
            (_chatSettingsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.ChatSettings") action:@selector(chatSettingsPressed)]),
            _wallpapersItem
        ]];
        [self.menuSections addSection:settingsSection];
        
        _autosavePhotosItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.SaveIncomingPhotos") isOn:TGAppDelegateInstance.autosavePhotos];
        _autosavePhotosItem.interfaceHandle = _actionHandle;
        
        _supportItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.Support") action:@selector(supportPressed)];
        _supportItem.deselectAutomatically = true;
        
        _faqItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.FAQ") action:@selector(faqPressed)];
        _faqItem.deselectAutomatically = true;
        
        TGCollectionMenuSection *downloadSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _supportItem,
            _faqItem,
            _autosavePhotosItem,
            [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"Settings.SaveIncomingPhotosHelp")]
        ]];
        [self.menuSections addSection:downloadSection];
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
    
    _editing = false;
    
    [_profileDataItem setUser:[TGDatabaseInstance() loadUser:_uid] animated:false];
    
    [self setTitleText:TGLocalized(@"Settings.Title")];
    
    _accountEditingBarButtonItem = nil;;
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSArray *uploadActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/uploadPhoto/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/uploadPhoto/", _uid] watcher:self];
        NSArray *deleteActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/deleteAvatar/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/deleteAvatar/", _uid] watcher:self];
        if (uploadActions.count != 0)
        {
            TGTimelineUploadPhotoRequestBuilder *actor = (TGTimelineUploadPhotoRequestBuilder *)[ActionStageInstance() executingActorWithPath:uploadActions.lastObject];
            if (actor != nil)
            {
                TGDispatchOnMainThread(^
                {
                    [_profileDataItem setUpdatingAvatar:actor.currentPhoto hasUpdatingAvatar:true];
                    [_setProfilePhotoItem setEnabled:false];
                });
            }
        }
        else if (deleteActions.count != 0)
        {
            TGDeleteProfilePhotoActor *actor = (TGDeleteProfilePhotoActor *)[ActionStageInstance() executingActorWithPath:deleteActions.lastObject];
            if (actor != nil)
            {
                TGDispatchOnMainThread(^
                {
                    [_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:true];
                    [_setProfilePhotoItem setEnabled:false];
                });
            }
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_editing)
    {
        [self setEditing:false animated:false];
        [_profileDataItem setUser:[TGDatabaseInstance() loadUser:_uid] animated:false];
    }
}

#pragma mark -

- (void)editButtonPressed
{
    if (_editing)
    {
        if ([_profileDataItem editingFirstName].length == 0 && [_profileDataItem editingLastName].length == 0)
            return;
    }
        
    [self setEditing:!_editing animated:true];
    
    [self.collectionView updateVisibleItemsNow];
    
    if (!_editing)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:_uid];
        if (!TGStringCompare(user.firstName, [_profileDataItem editingFirstName]) || !TGStringCompare(user.lastName, [_profileDataItem editingLastName]))
        {
            [_profileDataItem setUpdatingFirstName:[_profileDataItem editingFirstName] updatingLastName:[_profileDataItem editingLastName]];
            
            static int actionId = 0;
            NSString *action = [[NSString alloc] initWithFormat:@"/tg/changeUserName/(%d)", actionId++];
            NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[_profileDataItem editingFirstName], @"firstName", [_profileDataItem editingLastName], @"lastName", nil];
            [ActionStageInstance() requestActor:action options:options flags:0 watcher:self];
        }
    }
}

- (void)cancelButtonPressed
{
    [self setEditing:false animated:true];
    
    [_profileDataItem setUser:[TGDatabaseInstance() loadUser:_uid] animated:false];
}

- (void)setProfilePhotoPressed
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.TakePhoto") action:@"camera"]];
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.ChoosePhoto") action:@"choosePhoto"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.SearchWebImages") action:@"searchWeb"]];
    
    /*TGUser *user = [TGDatabaseInstance() loadUser:_uid];
    if (user.photoUrlSmall.length != 0)
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoDelete") action:@"delete" type:TGActionSheetActionTypeDestructive]];*/
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGAccountSettingsController *controller, NSString *action)
    {
        if ([action isEqualToString:@"camera"])
            [controller _displayCamera];
        else if ([action isEqualToString:@"choosePhoto"])
            [controller _displayImagePicker:false];
        else if ([action isEqualToString:@"searchWeb"])
            [controller _displayImagePicker:true];
        else if ([action isEqualToString:@"delete"])
            [controller _commitDeleteAvatar];
    } target:self];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [actionSheet showInView:self.view];
    else
    {
        NSIndexPath *indexPath = [self indexPathForItem:_setProfilePhotoItem];
        UIView *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        [actionSheet showFromRect:CGRectInset([cell convertRect:cell.bounds toView:self.view], 0.0f, -4.0f) inView:self.view animated:true];
    }
}

- (void)_displayCamera
{
    TGLegacyCameraController *legacyCameraController = [[TGLegacyCameraController alloc] init];
    legacyCameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    legacyCameraController.avatarMode = true;
    legacyCameraController.completionDelegate = self;
    
    [self presentViewController:legacyCameraController animated:true completion:nil];
}

- (void)_displayImagePicker:(bool)openWebSearch
{
    NSMutableArray *controllerList = [[NSMutableArray alloc] init];
    
    TGImageSearchController *searchController = [[TGImageSearchController alloc] initWithAvatarSelection:true];
    searchController.autoActivateSearch = openWebSearch;
    searchController.delegate = self;
    [controllerList addObject:searchController];
    
    if (!openWebSearch)
    {
        TGImagePickerController *imagePicker = [[TGImagePickerController alloc] initWithGroupUrl:nil groupTitle:nil avatarSelection:true];
        imagePicker.delegate = self;
        
        [controllerList addObject:imagePicker];
    }
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:controllerList];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        navigationController.restrictLandscape = true;
    else
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)imagePickerController:(TGImagePickerController *)__unused imagePicker didFinishPickingWithAssets:(NSArray *)assets
{
    UIImage *image = nil;
    
    if (assets.count != 0)
    {
        if ([assets[0] isKindOfClass:[UIImage class]])
            image = assets[0];
    }
    
    [self _updateProfileImage:image];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)legacyCameraControllerCompletedWithNoResult
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)_updateProfileImage:(UIImage *)image
{
    if (image != nil)
    {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.6f);
        if (imageData == nil)
            return;
        
        [(UIView *)[_profileDataItem visibleAvatarView] setHidden:false];
        
        TGImageProcessor filter = [TGRemoteImageView imageProcessorForName:@"circle:64x64"];
        UIImage *avatarImage = filter(image);
        
        [_profileDataItem setUpdatingAvatar:avatarImage hasUpdatingAvatar:true];
        [_setProfilePhotoItem setEnabled:false];
        
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        
        uint8_t fileId[32];
        arc4random_buf(&fileId, 32);
        
        NSMutableString *filePath = [[NSMutableString alloc] init];
        for (int i = 0; i < 32; i++)
        {
            [filePath appendFormat:@"%02x", fileId[i]];
        }
        
        NSString *tmpImagesPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) objectAtIndex:0] stringByAppendingPathComponent:@"upload"];
        static NSFileManager *fileManager = nil;
        if (fileManager == nil)
            fileManager = [[NSFileManager alloc] init];
        NSError *error = nil;
        [fileManager createDirectoryAtPath:tmpImagesPath withIntermediateDirectories:true attributes:nil error:&error];
        NSString *absoluteFilePath = [tmpImagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bin", filePath]];
        [imageData writeToFile:absoluteFilePath atomically:false];
        
        [options setObject:filePath forKey:@"originalFileUrl"];
        
        [options setObject:avatarImage forKey:@"currentPhoto"];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            NSString *action = [[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/uploadPhoto/(%@)", _uid, filePath];
            [ActionStageInstance() requestActor:action options:options watcher:self];
            [ActionStageInstance() requestActor:action options:options watcher:TGTelegraphInstance];
        }];
    }
}

- (void)_commitCancelAvatarUpdate
{
    [_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
    [_setProfilePhotoItem setEnabled:true];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSArray *deleteActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/deleteAvatar/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")", _uid] watcher:self];
        NSArray *uploadActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/timeline/@/uploadPhoto/@" prefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")", _uid] watcher:self];
        
        for (NSString *action in deleteActions)
        {
            [ActionStageInstance() removeAllWatchersFromPath:action];
        }
        
        for (NSString *action in uploadActions)
        {
            [ActionStageInstance() removeAllWatchersFromPath:action];
        }
    }];
}

- (void)_commitDeleteAvatar
{
    [_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:true];
    [_setProfilePhotoItem setEnabled:false];
    
    static int actionId = 0;
    
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:_uid], @"uid", nil];
    NSString *action = [[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/deleteAvatar/(%d)", _uid, actionId++];
    [ActionStageInstance() requestActor:action options:options watcher:self];
    [ActionStageInstance() requestActor:action options:options watcher:TGTelegraphInstance];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)__unused animated
{
    _editing = editing;
    
    if (_editing)
    {
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)] animated:true];
        
        _accountEditingBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(editButtonPressed)];
        [self setRightBarButtonItem:_accountEditingBarButtonItem animated:true];
    }
    else
    {
        [self setLeftBarButtonItem:nil animated:true];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)] animated:true];
        _accountEditingBarButtonItem = nil;
    }
    
    [self.menuSections beginRecordingChanges];
    
    TGButtonCollectionItem *logoutItem = nil;
    
    if (_editing)
    {
        logoutItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.Logout") action:@selector(logoutPressed)];
        logoutItem.alignment = NSTextAlignmentCenter;
        logoutItem.titleColor = TGDestructiveAccentColor();
        logoutItem.deselectAutomatically = true;
        
        NSMutableArray *logoutSectionItems = [[NSMutableArray alloc] init];
        [logoutSectionItems addObject:logoutItem];
        
#ifdef INTERNAL_RELEASE
        [logoutSectionItems addObject:[[TGButtonCollectionItem alloc] initWithTitle:@"Debug Settings" action:@selector(mySettingsPressed)]];
#endif
        
        TGCollectionMenuSection *logoutSection = [[TGCollectionMenuSection alloc] initWithItems:logoutSectionItems];
        [self.menuSections addSection:logoutSection];
    }
    else
    {
        [self.menuSections deleteSection:self.menuSections.sections.count - 1];
    }
    
    [_profileDataItem setEditing:_editing animated:true];
    _profileDataItem.additinalHeight = _editing ? 30.0f : 0.0f;
    
    if (![self.menuSections commitRecordedChanges:self.collectionView])
        [self _resetCollectionView];
    
    if (_editing && self.collectionView.contentOffset.y + self.collectionView.contentInset.top + (self.collectionView.frame.size.height - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom) - (self.collectionView.contentSize.height) > -30.0f)
    {
        NSIndexPath *indexPath = [self indexPathForItem:logoutItem];
        if (indexPath != nil)
        {
            //[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:true];
            
            //[self.collectionView scrollRectToVisible:CGRectMake(0.0f, self.collectionView.contentSize.height - 1.0f, 1.0f, 1.0f) animated:true];
        }
    }
}

- (void)notificationsAndSoundsPressed
{
    [self.navigationController pushViewController:[[TGNotificationSettingsController alloc] init] animated:true];
}

- (void)blockedUsersPressed
{
    [self.navigationController pushViewController:[[TGBlockedController alloc] init] animated:true];
}

- (void)chatSettingsPressed
{
    [self.navigationController pushViewController:[[TGChatSettingsController alloc] init] animated:true];
}

- (void)wallpapersPressed
{
    [self.navigationController pushViewController:[[TGWallpaperListController alloc] init] animated:true];
}

- (void)mySettingsPressed
{
    [self.navigationController pushViewController:[[TGSettingsController alloc] init] animated:true];
}

- (void)supportPressed
{
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Settings.FAQ_Intro") cancelButtonTitle:TGLocalized(@"Settings.FAQ_Button") otherButtonTitles:@[TGLocalized(@"Common.OK")] completionBlock:^(bool okButtonPressed)
    {
        if (okButtonPressed)
        {
            NSData *data = [TGDatabaseInstance() customProperty:@"supportAccountUid"];
            if (data.length != 4)
            {
                _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [_progressWindow show:true];
                
                [ActionStageInstance() requestActor:@"/tg/support/preferredPeer" options:nil flags:0 watcher:self];
            }
            else
            {
                int32_t uid = 0;
                [data getBytes:&uid];
                [[TGInterfaceManager instance] navigateToConversationWithId:uid conversation:nil performActions:nil atMessage:nil clearStack:true openKeyboard:true animated:true];
            }
        }
        else
        {
            [self faqPressed];
        }
    }] show];
}

- (void)faqPressed
{
    NSString *faqUrl = TGLocalized(@"Settings.FAQ_URL");
    if (faqUrl.length == 0)
        faqUrl = @"http://telegram.org/faq#general";
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:faqUrl]];
}

- (void)logoutPressed
{
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Settings.Logout") action:@"logout" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel],
    ] actionBlock:^(TGAccountSettingsController *target, NSString *action)
    {
        if ([action isEqualToString:@"logout"])
        {
            target.progressWindow = [[TGProgressWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [target.progressWindow show:true];
            
            static int actionId = 0;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/auth/logout/(%d)", actionId++] options:nil watcher:target];
        }
    } target:self] showInView:self.tabBarController.view];
}

#pragma mark -

- (void)wallpaperController:(TGWallpaperController *)__unused wallpaperController didSelectWallpaperWithInfo:(TGWallpaperInfo *)wallpaperInfo
{
    [[TGWallpaperManager instance] setCurrentWallpaperWithInfo:wallpaperInfo];
    [_wallpapersItem setCurrentWallpaperInfo:wallpaperInfo];
}

#pragma mark -

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/service/synchronizationstate"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    else if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"])
    {
        NSArray *users = ((SGraphObjectNode *)resource).object;
        
        for (TGUser *user in users)
        {
            if (user.uid == _uid)
            {
                TGDispatchOnMainThread(^
                {
                    [_profileDataItem setUser:user animated:true];
                });
                
                break;
            }
        }
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path isEqualToString:@"/tg/service/synchronizationstate"])
    {
        if (status == ASStatusSuccess)
        {
            int state = [((SGraphObjectNode *)result).object intValue];
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                int synchronizationState = 0;
                
                if (state & 2)
                    synchronizationState = 1;
                else if (state & 1)
                    synchronizationState = 2;
                else
                    synchronizationState = 0;
                
                [_profileDataItem setSynchronizationStatus:synchronizationState];
            });
        }
    }
    else if ([path hasPrefix:@"/tg/auth/logout/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [_progressWindow dismiss:true];
            _progressWindow = nil;
            
            if (status != ASStatusSuccess)
            {
                [[[UIAlertView alloc] initWithTitle:nil message:TGLocalized(@"Settings.LogoutError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
            }
        });
    }
    else if ([path hasPrefix:@"/tg/changeUserName/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [_profileDataItem setUpdatingFirstName:nil updatingLastName:nil];
            [_profileDataItem setUser:[TGDatabaseInstance() loadUser:_uid] animated:false];
        });
    }
    else if ([path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/uploadPhoto", _uid]] || [path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/deleteAvatar/", _uid]])
    {
        TGUser *user = [TGDatabaseInstance() loadUser:_uid];
        
        TGDispatchOnMainThread(^
        {
            [_setProfilePhotoItem setEnabled:true];
            
            if (status == ASStatusSuccess)
            {
                [_profileDataItem copyUpdatingAvatarToCacheWithUri:user.photoUrlSmall];
                [_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
                [_profileDataItem setUser:user animated:false];
            }
            else
            {
                [_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:TGLocalized(@"Profile.ImageUploadError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                [alertView show];
            }
        });
    }
    else if ([path isEqualToString:@"/tg/support/preferredPeer"])
    {
        TGUser *user = status == ASStatusSuccess ? [TGDatabaseInstance() loadUser:[result[@"uid"] intValue]] : nil;
        
        TGDispatchOnMainThread(^
        {
            [_progressWindow dismiss:true];
            
            if (user != nil)
            {
                [[TGInterfaceManager instance] navigateToConversationWithId:user.uid conversation:nil performActions:nil atMessage:nil clearStack:true openKeyboard:true animated:true];
            }
        });
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"avatarTapped"])
    {
        TGUser *user = [TGDatabaseInstance() loadUser:_uid];
        
        if ([_profileDataItem hasUpdatingAvatar])
        {
            TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:@[
                [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoStop") action:@"stop" type:TGActionSheetActionTypeDestructive],
                [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel],
            ] actionBlock:^(id target, NSString *action)
            {
                if ([action isEqualToString:@"stop"])
                {
                    [(TGAccountSettingsController *)target _commitCancelAvatarUpdate];
                }
            } target:self];
            [actionSheet showInView:self.view];
        }
        else if (user.photoUrlSmall.length == 0)
        {
            if (_setProfilePhotoItem.enabled)
                [self setProfilePhotoPressed];
        }
        else
        {
            TGRemoteImageView *avatarView = [_profileDataItem visibleAvatarView];
            
            if (user != nil && user.photoUrlBig != nil && avatarView.currentImage != nil)
            {
                UIImage *placeholder = [[TGRemoteImageView sharedCache] cachedImage:user.photoUrlSmall availability:TGCacheBoth];
                
                if (placeholder == nil)
                    placeholder = [avatarView currentImage];
                
                TGImageInfo *imageInfo = [[TGImageInfo alloc] init];
                [imageInfo addImageWithSize:CGSizeMake(160, 160) url:user.photoUrlSmall];
                [imageInfo addImageWithSize:CGSizeMake(640, 640) url:user.photoUrlBig];
                
                TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
                imageAttachment.imageInfo = imageInfo;
                
                TGProfileImageItem *imageItem = [[TGProfileImageItem alloc] initWithProfilePhoto:imageAttachment];
                TGImageViewController *imageViewController = [[TGImageViewController alloc] initWithImageItem:imageItem placeholder:placeholder];
                
                imageViewController.hideDates = true;
                imageViewController.reverseOrder = true;
                
                TGTelegraphProfileImageViewCompanion *companion = [[TGTelegraphProfileImageViewCompanion alloc] initWithUid:_uid photoItem:imageItem loadList:true];
                companion.watcherHandle = _actionHandle;
                imageViewController.imageViewCompanion = companion;
                companion.imageViewController = imageViewController;
                
                CGRect windowSpaceFrame = [avatarView convertRect:avatarView.bounds toView:avatarView.window];
                
                if (iosMajorVersion() >= 7)
                    [TGHacks animateApplicationStatusBarStyleTransitionWithDuration:0.3];
                
                [imageViewController animateAppear:self.view anchorForImage:self.collectionView fromRect:windowSpaceFrame fromImage:avatarView.currentImage start:^
                {
                    avatarView.hidden = true;
                }];
                imageViewController.watcherHandle = _actionHandle;
                
                [TGAppDelegateInstance presentContentController:imageViewController];
            }
        }
    }
    else if ([action isEqualToString:@"closeImage"])
    {
        TGImageViewController *imageViewController = [options objectForKey:@"sender"];
        TGRemoteImageView *avatarView = [_profileDataItem visibleAvatarView];
        
        CGRect targetRect = [avatarView convertRect:avatarView.bounds toView:self.view.window];
        UIImage *targetImage = [avatarView currentImage];
        
        TGImageInfo *imageInfo = options[@"imageInfo"];
        
        if (targetImage == nil || [options[@"forceSwipe"] boolValue] || (imageInfo != nil && ![imageInfo containsSizeWithUrl:[avatarView currentUrl]]))
            targetRect = CGRectZero;
        
        if ([options[@"forceSwipe"] boolValue])
            avatarView.hidden = false;
        
        if (iosMajorVersion() >= 7)
            [TGHacks animateApplicationStatusBarStyleTransitionWithDuration:0.3];
        
        [imageViewController animateDisappear:self.view anchorForImage:self.collectionView toRect:targetRect toImage:targetImage swipeVelocity:0.0f completion:^
        {
            avatarView.hidden = false;
            
            [TGAppDelegateInstance dismissContentController];
        }];
        
        [((TGNavigationController *)self.navigationController) updateControllerLayout:false];
    }
    else if ([action isEqualToString:@"hideImage"])
    {
        TGRemoteImageView *avatarView = [_profileDataItem visibleAvatarView];
        
        if ([[options objectForKey:@"hide"] boolValue])
        {
            TGImageInfo *imageInfo = options[@"imageInfo"];
            if (imageInfo != nil)
            {
                if (avatarView.currentUrl != nil && [imageInfo containsSizeWithUrl:avatarView.currentUrl])
                    avatarView.hidden = true;
                else
                    avatarView.hidden = false;
            }
        }
    }
    else if ([action isEqualToString:@"deleteAvatar"])
    {
        [self _commitDeleteAvatar];
    }
    else if ([action isEqualToString:@"wallpaperImagePressed"])
    {   
        if (options[@"wallpaperInfo"] != nil)
        {
            TGWallpaperController *wallpaperController = [[TGWallpaperController alloc] initWithWallpaperInfo:options[@"wallpaperInfo"] thumbnailImage:nil];
            wallpaperController.delegate = self;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                wallpaperController.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [self presentViewController:wallpaperController animated:true completion:nil];
        }
    }
    else if ([action isEqualToString:@"editingNameChanged"])
    {
        _accountEditingBarButtonItem.enabled = [_profileDataItem editingFirstName].length != 0;
    }
    else if ([action isEqualToString:@"switchItemChanged"])
    {
        if (options[@"item"] == _autosavePhotosItem)
        {
            TGAppDelegateInstance.autosavePhotos = [options[@"value"] boolValue];
            [TGAppDelegateInstance saveSettings];
        }
    }
}

- (void)localizationUpdated
{
    [self setTitleText:TGLocalized(@"Settings.Title")];
    
    if (_editing)
    {
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)] animated:true];
        
        _accountEditingBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(editButtonPressed)];
        [self setRightBarButtonItem:_accountEditingBarButtonItem animated:false];
    }
    else
    {
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)] animated:false];
        _accountEditingBarButtonItem = nil;
    }
    
    _notificationsItem.title = TGLocalized(@"Settings.NotificationsAndSounds");
    _blockedUsersItem.title = TGLocalized(@"Settings.BlockedUsers");
    _chatSettingsItem.title = TGLocalized(@"Settings.ChatSettings");
    
    _setProfilePhotoItem.title = TGLocalized(@"Settings.SetProfilePhoto");
    _autosavePhotosItem.title = TGLocalized(@"Settings.SaveIncomingPhotos");
    _wallpapersItem.title = TGLocalized(@"Settings.ChatBackground");
    _supportItem.title = TGLocalized(@"Settings.Support");
    
    [_profileDataItem localizationUpdated];
}

@end
