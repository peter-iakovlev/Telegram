#import "TGAccountSettingsController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTimelineItem.h"
#import "TGTimelineUploadPhotoRequestBuilder.h"
#import "TGDeleteProfilePhotoActor.h"

#import "TGNotificationSettingsController.h"
#import "TGChatSettingsController.h"
#import "TGPrivacySettingsController.h"

#import "TGAccountInfoCollectionItem.h"
#import "TGDisclosureActionCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGWallpapersCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGVersionCollectionItem.h"

#import "TGWallpaperListController.h"
#import "TGWallpaperController.h"
#import "TGWallpaperManager.h"

#import "TGActionSheet.h"
#import "TGProgressWindow.h"
#import "TGRemoteImageView.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGAppDelegate.h"
#import "TGHacks.h"
#import "TGInterfaceManager.h"
#import "TGAlertView.h"
#import "TGPhoneUtils.h"
#import "TGImageUtils.h"

#import "TGOverlayControllerWindow.h"
#import "TGModernGalleryController.h"
#import "TGProfileUserAvatarGalleryModel.h"
#import "TGProfileUserAvatarGalleryItem.h"

#import "TGSettingsController.h"

#import "TGUsernameController.h"

#import "TGAlertView.h"

#import "TGAccountSettingsActor.h"

#import "TGChangePhoneNumberHelpController.h"

#import "TGFaqController.h"

#import "TGBridgeServer.h"
#import "TGWatchController.h"

#import "TGMediaAvatarMenuMixin.h"

#import "TGUserAboutSetupController.h"

#import "TGStickerPacksSettingsController.h"
#import "TGRecentCallsController.h"

#import "TGStickersSignals.h"
#import "TGUserSignal.h"

#import "TGLocalizationSelectionController.h"

@interface TGAccountSettingsController () <TGWallpaperControllerDelegate>
{
    int32_t _uid;
    
    bool _editing;
    
    TGCollectionMenuSection *_settingsSection;
    
    TGAccountInfoCollectionItem *_profileDataItem;
    TGButtonCollectionItem *_setProfilePhotoItem;
    
    TGWallpapersCollectionItem *_wallpapersItem;
    
    TGVariantCollectionItem *_usernameItem;
    TGVariantCollectionItem *_phoneNumberItem;
    TGVariantCollectionItem *_aboutItem;
    TGVariantCollectionItem *_languageItem;
    
    TGDisclosureActionCollectionItem *_notificationsItem;
    TGDisclosureActionCollectionItem *_privacySettingsItem;
    TGDisclosureActionCollectionItem *_chatSettingsItem;
    TGDisclosureActionCollectionItem *_callSettingsItem;
    TGDisclosureActionCollectionItem *_stickerSettingsItem;
    TGDisclosureActionCollectionItem *_supportItem;
    TGDisclosureActionCollectionItem *_faqItem;
    TGVersionCollectionItem *_versionItem;
    
    UIBarButtonItem *_accountEditingBarButtonItem;
    
    TGCollectionMenuSection *_watchSection;
    TGDisclosureActionCollectionItem *_watchItem;
    SMetaDisposable *_watchAppInstalledDisposable;
    
    id<SDisposable> _stickerPacksDisposable;
    id<SDisposable> _updatedFeaturedStickerPacksDisposable;
    id<SDisposable> _userCachedDataDisposable;
    
    TGMediaAvatarMenuMixin *_avatarMixin;
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
            @"/tg/service/synchronizationstate",
            @"/tg/calls/enabled"
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
        _languageItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.AppLanguage") variant:TGLocalized(@"Localization.LanguageName") action:@selector(languagePressed)];
        
        NSMutableArray *settingsItems = [[NSMutableArray alloc] init];
        [settingsItems addObject:(_notificationsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.NotificationsAndSounds") action:@selector(notificationsAndSoundsPressed)])];
        [settingsItems addObject:(_privacySettingsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.PrivacySettings") action:@selector(privacySettingsPressed)])];
        [settingsItems addObject:(_chatSettingsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.ChatSettings") action:@selector(chatSettingsPressed)])];
        [settingsItems addObject:(_stickerSettingsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Stickers") action:@selector(stickerSettingsPressed)])];
        [settingsItems addObject:_wallpapersItem];
        [settingsItems addObject:_languageItem];
        
        _settingsSection = [[TGCollectionMenuSection alloc] initWithItems:settingsItems];
        [self.menuSections addSection:_settingsSection];
        
        [TGDatabaseInstance() customProperty:@"phoneCallsEnabled" completion:^(NSData *value)
        {
            TGDispatchOnMainThread(^
            {
                int32_t phoneCallsEnabled = false;
                if (value.length == 4) {
                    [value getBytes:&phoneCallsEnabled];
                }
                [self updatePhoneCallsEnabled:phoneCallsEnabled];
            });
        }];
        
        _watchItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.AppleWatch") action:@selector(watchPressed)];
        
        __weak TGAccountSettingsController *weakSelf = self;
        _watchAppInstalledDisposable = [[SMetaDisposable alloc] init];
        [_watchAppInstalledDisposable setDisposable:[[[[TGBridgeServer instanceSignal] mapToSignal:^SSignal *(TGBridgeServer *bridgeServer) {
            return [bridgeServer watchAppInstalledSignal];
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *next)
        {
            __strong TGAccountSettingsController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf.menuSections beginRecordingChanges];
            if (next.boolValue)
            {
                if (strongSelf->_watchSection == nil)
                {
                    strongSelf->_watchSection = [[TGCollectionMenuSection alloc] initWithItems:@[strongSelf->_watchItem]];
                    [strongSelf.menuSections insertSection:strongSelf->_watchSection atIndex:2];
                }
            }
            else
            {
                if (strongSelf->_watchSection != nil)
                {
                    [strongSelf.menuSections deleteSection:2];
                    strongSelf->_watchSection = nil;
                }
            }

            [strongSelf.menuSections commitRecordedChanges:strongSelf.collectionView];
        }]];
        
        _phoneNumberItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.PhoneNumber") action:@selector(phoneNumberPressed)];
        _usernameItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.Username") action:@selector(usernamePressed)];
        _aboutItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.About") action:@selector(aboutPressed)];
        _aboutItem.flexibleLayout = true;
        TGCollectionMenuSection *usernameSection = [[TGCollectionMenuSection alloc] initWithItems:@[_phoneNumberItem, _usernameItem, _aboutItem]];
        [self.menuSections addSection:usernameSection];
        
        _supportItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.Support") action:@selector(supportPressed)];
        _supportItem.deselectAutomatically = true;
        
        _faqItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.FAQ") action:@selector(faqPressed)];
        _faqItem.deselectAutomatically = true;
        
        NSString *version = [NSString stringWithFormat:@"v%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
#ifdef INTERNAL_RELEASE
        version = [NSString stringWithFormat:@"%@ (%@)", version, [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
#endif
        
        _versionItem = [[TGVersionCollectionItem alloc] initWithVersion:version];
        
        TGCollectionMenuSection *infoSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _supportItem,
            _faqItem,
            //_versionItem
        ]];
        [self.menuSections addSection:infoSection];
        
        [ActionStageInstance() watchForPath:@"/tg/loggedOut" watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_watchAppInstalledDisposable dispose];
    [_stickerPacksDisposable dispose];
    [_updatedFeaturedStickerPacksDisposable dispose];
    [_userCachedDataDisposable dispose];
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [_progressWindow dismiss:true];
}

- (void)loadView
{
    [super loadView];
    
    _editing = false;
    
    TGUser *user = [TGDatabaseInstance() loadUser:_uid];
    
    [_profileDataItem setUser:user animated:false];
    [_usernameItem setVariant:user.userName.length == 0 ? TGLocalized(@"Settings.UsernameEmpty") : [[NSString alloc] initWithFormat:@"@%@", user.userName]];
    [_phoneNumberItem setVariant:user.phoneNumber.length == 0 ? @"" : [TGPhoneUtils formatPhone:user.phoneNumber forceInternational:true]];
    
    [self setTitleText:TGLocalized(@"Settings.Title")];
    
    _accountEditingBarButtonItem = nil;;
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)]];
    
    __weak TGAccountSettingsController *weakSelf = self;
    _stickerPacksDisposable = [[[TGStickersSignals stickerPacks] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict)
    {
        __strong TGAccountSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil && ((NSArray *)dict[@"packs"]).count != 0)
        {
            NSUInteger unreadFeaturedCount = ((NSArray *)dict[@"featuredPacksUnreadIds"]).count;
            [strongSelf->_stickerSettingsItem setBadge:unreadFeaturedCount == 0 ? nil : [NSString stringWithFormat:@"%d", (int)unreadFeaturedCount]];
        }
    }];
    
    [[TGUserSignal updatedUserCachedDataWithUserId:_uid] startWithNext:nil];
    _userCachedDataDisposable = [[[TGDatabaseInstance() userCachedData:_uid] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedUserData *next)
    {
        __strong TGAccountSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_aboutItem setVariant:next.about.length == 0 ? TGLocalized(@"Settings.AboutEmpty") : [strongSelf _shortStringForAbout:next.about]];
        }
    }];
    
    _updatedFeaturedStickerPacksDisposable = [[TGStickersSignals updatedFeaturedStickerPacks] startWithNext:nil];
}

- (NSString *)_shortStringForAbout:(NSString *)about
{
    const NSInteger maxLength = 200;
    
    static NSString *tokenString = nil;
    if (tokenString == nil)
    {
        unichar tokenChar = 0x2026;
        tokenString = [[NSString alloc] initWithCharacters:&tokenChar length:1];
    }

    if (about.length > maxLength)
        about = [NSString stringWithFormat:@"%@%@", [[about substringToIndex:maxLength] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], tokenString];
    
    return about;
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
        
        if ([TGAccountSettingsActor accountSettingsFotCurrentStateId] == nil)
            [ActionStageInstance() requestActor:@"/accountSettings" options:@{} flags:0 watcher:self];
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
    if (_editing)
        [self editButtonPressed];
    
    __weak TGAccountSettingsController *weakSelf = self;
    _avatarMixin = [[TGMediaAvatarMenuMixin alloc] initWithParentController:self hasDeleteButton:false personalPhoto:true];
    _avatarMixin.didFinishWithImage = ^(UIImage *image)
    {
        __strong TGAccountSettingsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _updateProfileImage:image];
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.didDismiss = ^
    {
        __strong TGAccountSettingsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_avatarMixin = nil;        
    };
    [_avatarMixin present];
}

- (void)_updateProfileImage:(UIImage *)image
{
    if (image == nil)
        return;
    
    if (MIN(image.size.width, image.size.height) < 160.0f)
        image = TGScaleImageToPixelSize(image, CGSizeMake(160, 160));

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
    
    NSString *tmpImagesPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"upload"];
    static NSFileManager *fileManager = nil;
    if (fileManager == nil)
        fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    [fileManager createDirectoryAtPath:tmpImagesPath withIntermediateDirectories:true attributes:nil error:&error];
    NSString *absoluteFilePath = [tmpImagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bin", filePath]];
    [imageData writeToFile:absoluteFilePath atomically:true];
    
    [options setObject:filePath forKey:@"originalFileUrl"];
    
    [options setObject:avatarImage forKey:@"currentPhoto"];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSString *action = [[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/uploadPhoto/(%@)", _uid, filePath];
        [ActionStageInstance() requestActor:action options:options watcher:self];
        [ActionStageInstance() requestActor:action options:options watcher:TGTelegraphInstance];
    }];
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
    [_profileDataItem setHasUpdatingAvatar:true];
    [_setProfilePhotoItem setEnabled:false];
    
    static int actionId = 0;
    
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:_uid], @"uid", nil];
    NSString *action = [[NSString alloc] initWithFormat:@"/tg/timeline/(%" PRId32 ")/deleteAvatar/(%d)", _uid, actionId++];
    [ActionStageInstance() requestActor:action options:options watcher:self];
    [ActionStageInstance() requestActor:action options:options watcher:TGTelegraphInstance];
}

- (void)updatePhoneCallsEnabled:(bool)enabled
{
    if (enabled && _callSettingsItem == nil) {
        _callSettingsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"CallSettings.RecentCalls") action:@selector(callSettingsPressed)];
        [_settingsSection insertItem:_callSettingsItem atIndex:3];
        [self.collectionView reloadData];
    } else if (!enabled && _callSettingsItem != nil) {
        [_settingsSection deleteItem:_callSettingsItem];
        _callSettingsItem = nil;
        [self.collectionView reloadData];
    }
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
    //_profileDataItem.additinalHeight = _editing ? 30.0f : 0.0f;
    
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

- (void)privacySettingsPressed
{
    [self.navigationController pushViewController:[[TGPrivacySettingsController alloc] init] animated:true];
}

- (void)chatSettingsPressed
{
    [self.navigationController pushViewController:[[TGChatSettingsController alloc] init] animated:true];
}

- (void)callSettingsPressed
{
    [self.navigationController pushViewController:[[TGRecentCallsController alloc] initWithController:TGAppDelegateInstance.rootController.callsController] animated:true];
}

- (void)stickerSettingsPressed {
    [self.navigationController pushViewController:[[TGStickerPacksSettingsController alloc] initWithEditing:false masksMode:false] animated:true];
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
            //NSData *data = [TGDatabaseInstance() customProperty:@"supportAccountUid"];
            //if (data.length != 4)
            {
                _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [_progressWindow show:true];
                
                [ActionStageInstance() requestActor:@"/tg/support/preferredPeer" options:nil flags:0 watcher:self];
            }
            /*else
            {
                int32_t uid = 0;
                [data getBytes:&uid];
                [[TGInterfaceManager instance] navigateToConversationWithId:uid conversation:nil performActions:nil atMessage:nil clearStack:true openKeyboard:true animated:true];
            }*/
        }
        else
        {
            [self faqPressed];
        }
    }] show];
}

- (void)faqPressed
{
    //[self.navigationController pushViewController:[[TGFaqController alloc] init] animated:true];
    NSString *faqUrl = TGLocalized(@"Settings.FAQ_URL");
    if (faqUrl.length == 0)
        faqUrl = @"http://telegram.org/faq#general";
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:faqUrl]];
}

- (void)logoutPressed
{
    __weak TGAccountSettingsController *weakSelf = self;
    
    [[TGInterfaceManager instance] dismissAllCalls];
    
    /*[[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Settings.Logout") action:@"logout" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel],
    ] actionBlock:^(__unused TGAccountSettingsController *target, NSString *action)
    {
        if ([action isEqualToString:@"logout"])
        {*/
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Settings.LogoutConfirmationTitle") message:TGLocalized(@"Settings.LogoutConfirmationText") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
            {
                if (okButtonPressed)
                {
                    __strong TGAccountSettingsController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        strongSelf.progressWindow = [[TGProgressWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                        [strongSelf.progressWindow show:true];
                        
                        static int actionId = 0;
                        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/auth/logout/(%d)", actionId++] options:nil watcher:strongSelf];
                    }
                }
            }] show];
        /*}
    } target:self] showInView:self.tabBarController.view];*/
}

#pragma mark -

- (void)wallpaperController:(TGWallpaperController *)wallpaperController didSelectWallpaperWithInfo:(TGWallpaperInfo *)wallpaperInfo
{
    [[TGWallpaperManager instance] setCurrentWallpaperWithInfo:wallpaperInfo];
    [_wallpapersItem setCurrentWallpaperInfo:wallpaperInfo];
    [wallpaperController.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

#pragma mark -

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/loggedOut"]) {
        TGDispatchOnMainThread(^{
            [_progressWindow dismiss:true];
            _progressWindow = nil;
        });
    } else if ([path isEqualToString:@"/tg/service/synchronizationstate"])
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
                    [_usernameItem setVariant:user.userName.length == 0 ? TGLocalized(@"Settings.UsernameEmpty") : [[NSString alloc] initWithFormat:@"@%@", user.userName]];
                    [_phoneNumberItem setVariant:user.phoneNumber.length == 0 ? @"" : [TGPhoneUtils formatPhone:user.phoneNumber forceInternational:true]];
                });
                
                break;
            }
        }
    } else if ([path isEqualToString:@"/tg/calls/enabled"]) {
        bool enabled = [((SGraphObjectNode *)resource).object boolValue];
        TGDispatchOnMainThread(^{
            [self updatePhoneCallsEnabled:enabled];
        });
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
                [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Settings.LogoutError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
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
        TGImageInfo *imageInfo = ((TGTimelineItem *)((SGraphObjectNode *)result).object).imageInfo;
        
        TGDispatchOnMainThread(^
        {
            [_setProfilePhotoItem setEnabled:true];
            
            if (status == ASStatusSuccess)
            {
                NSString *photoUrl = [imageInfo closestImageUrlWithSize:CGSizeMake(160, 160) resultingSize:NULL];
                
                if (photoUrl != nil)
                    [_profileDataItem copyUpdatingAvatarToCacheWithUri:photoUrl];
                
                [_profileDataItem resetUpdatingAvatar:photoUrl];
            }
            else
            {
                [_profileDataItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
                
                TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Profile.ImageUploadError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
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
                [[TGInterfaceManager instance] navigateToConversationWithId:user.uid conversation:nil performActions:nil atMessage:nil clearStack:true openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
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
            if (!_editing)
            {
                TGRemoteImageView *avatarView = [_profileDataItem visibleAvatarView];
                
                if (user != nil && user.photoUrlBig != nil && avatarView.currentImage != nil)
                {
                    TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
                    
                    TGProfileUserAvatarGalleryModel *model = [[TGProfileUserAvatarGalleryModel alloc] initWithCurrentAvatarLegacyThumbnailImageUri:user.photoUrlSmall currentAvatarLegacyImageUri:user.photoUrlBig currentAvatarImageSize:CGSizeMake(640.0f, 640.0f)];
                    
                    __weak TGAccountSettingsController *weakSelf = self;
                    
                    model.deleteCurrentAvatar = ^
                    {
                        __strong TGAccountSettingsController *strongSelf = weakSelf;
                        [strongSelf _commitDeleteAvatar];
                    };
                    
                    modernGallery.model = model;
                    
                    modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
                    {
                        __strong TGAccountSettingsController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                            {
                                if (((TGUserAvatarGalleryItem *)item).isCurrent)
                                {
                                    ((UIView *)strongSelf->_profileDataItem.visibleAvatarView).hidden = true;
                                }
                                else
                                    ((UIView *)strongSelf->_profileDataItem.visibleAvatarView).hidden = false;
                            }
                        }
                    };
                    
                    modernGallery.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
                    {
                        __strong TGAccountSettingsController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                            {
                                if (((TGUserAvatarGalleryItem *)item).isCurrent)
                                {
                                    return strongSelf->_profileDataItem.visibleAvatarView;
                                }
                            }
                        }
                        
                        return nil;
                    };
                    
                    modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
                    {
                        __strong TGAccountSettingsController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                            {
                                if (((TGUserAvatarGalleryItem *)item).isCurrent)
                                {
                                    return strongSelf->_profileDataItem.visibleAvatarView;
                                }
                            }
                        }
                        
                        return nil;
                    };
                    
                    modernGallery.completedTransitionOut = ^
                    {
                        __strong TGAccountSettingsController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            ((UIView *)strongSelf->_profileDataItem.visibleAvatarView).hidden = false;
                        }
                    };
                    
                    TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:modernGallery];
                    controllerWindow.hidden = false;
                }
            }
            else
            {
                [self setProfilePhotoPressed];
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
}

- (void)watchPressed
{
    TGWatchController *controller = [[TGWatchController alloc] init];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)phoneNumberPressed
{
    TGChangePhoneNumberHelpController *phoneNumberController = [[TGChangePhoneNumberHelpController alloc] init];
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[phoneNumberController]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        navigationController.restrictLandscape = true;
    else
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)usernamePressed
{
    TGUsernameController *usernameController = [[TGUsernameController alloc] init];
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[usernameController]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        navigationController.restrictLandscape = false;
    else
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
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
    _privacySettingsItem.title = TGLocalized(@"Settings.PrivacySettings");
    _chatSettingsItem.title = TGLocalized(@"Settings.ChatSettings");
    
    _stickerSettingsItem.title = TGLocalized(@"ChatSettings.Stickers");
    
    _setProfilePhotoItem.title = TGLocalized(@"Settings.SetProfilePhoto");
    _wallpapersItem.title = TGLocalized(@"Settings.ChatBackground");
    _usernameItem.title = TGLocalized(@"Settings.Username");
    _aboutItem.title = TGLocalized(@"Settings.About");
    _phoneNumberItem.title = TGLocalized(@"Settings.PhoneNumber");
    _supportItem.title = TGLocalized(@"Settings.Support");
    _callSettingsItem.title = TGLocalized(@"CallSettings.RecentCalls");
    
    _faqItem.title = TGLocalized(@"Settings.FAQ");
    
    _languageItem.title = TGLocalized(@"Settings.AppLanguage");
    _languageItem.variant = TGLocalized(@"Localization.LanguageName");
    
    [_profileDataItem localizationUpdated];
}

- (void)aboutPressed {
    TGUserAboutSetupController *controller = [[TGUserAboutSetupController alloc] init];
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        navigationController.restrictLandscape = true;
    else
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:navigationController animated:true completion:nil];
}
    
- (void)languagePressed {
    [self.navigationController pushViewController:[[TGLocalizationSelectionController alloc] init] animated:true];
}

@end
