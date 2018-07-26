#import "TGAccountSettingsController.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGLegacyComponentsContext.h"

#import <LegacyComponents/ActionStage.h>
#import <LegacyComponents/SGraphObjectNode.h>

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
#import "TGWallpaperManager.h"

#import "TGCustomAlertView.h"
#import "TGCustomActionSheet.h"
#import <LegacyComponents/TGProgressWindow.h>
#import <LegacyComponents/TGRemoteImageView.h>

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGAppDelegate.h"
#import "TGInterfaceManager.h"
#import "TGAlertView.h"

#import <LegacyComponents/TGModernGalleryController.h>
#import "TGProfileUserAvatarGalleryModel.h"
#import "TGProfileUserAvatarGalleryItem.h"

#import "TGSettingsController.h"

#import "TGUsernameController.h"

#import "TGCustomAlertView.h"

#import "TGAccountSettingsActor.h"

#import "TGChangePhoneNumberHelpController.h"

#import "TGFaqController.h"

#import "TGBridgeServer.h"
#import "TGWatchController.h"

#import <LegacyComponents/TGMediaAvatarMenuMixin.h>
#import "TGWebSearchController.h"

#import "TGUserAboutSetupController.h"

#import "TGStickerPacksSettingsController.h"
#import "TGRecentCallsController.h"

#import "TGStickersSignals.h"
#import "TGUserSignal.h"
#import "TGProxySignals.h"
#import "TGPassportSignals.h"

#import "TGLocalizationSelectionController.h"
#import "TGEditProfileController.h"

#import "TGAppearanceController.h"
#import "TGProxySetupController.h"
#import "TGPassportRequestController.h"

#import "TGTwoStepConfigSignal.h"

#import "TGLegacyComponentsContext.h"

@interface TGAccountSettingsController ()
{
    int32_t _uid;
    
    bool _editing;
    
    TGCollectionMenuSection *_headerSection;
    TGCollectionMenuSection *_settingsSection;
    TGCollectionMenuSection *_shortcutSection;
    
    SMetaDisposable *_proxyListDisposable;
    SMetaDisposable *_proxyStatusDisposable;
    TGCollectionMenuSection *_proxySection;
    TGVariantCollectionItem *_proxyItem;
    
    TGAccountInfoCollectionItem *_profileDataItem;
    TGButtonCollectionItem *_setProfilePhotoItem;
    TGButtonCollectionItem *_setUsernameItem;
    
    TGDisclosureActionCollectionItem *_wallpapersItem;
    TGVariantCollectionItem *_languageItem;
    
    TGDisclosureActionCollectionItem *_notificationsItem;
    TGDisclosureActionCollectionItem *_privacySettingsItem;
    TGDisclosureActionCollectionItem *_chatSettingsItem;
    TGDisclosureActionCollectionItem *_callSettingsItem;
    TGDisclosureActionCollectionItem *_savedMessagesItem;
    TGDisclosureActionCollectionItem *_stickerSettingsItem;
    TGDisclosureActionCollectionItem *_supportItem;
    TGDisclosureActionCollectionItem *_faqItem;
    
    TGCollectionMenuSection *_otherSection;
    TGDisclosureActionCollectionItem *_passportItem;
    TGDisclosureActionCollectionItem *_watchItem;
    SMetaDisposable *_watchAppInstalledDisposable;
    
    id<SDisposable> _stickerPacksDisposable;
    id<SDisposable> _updatedFeaturedStickerPacksDisposable;
    
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
            @"/tg/calls/enabled"
        ] watcher:self];
        
        _uid = uid;
        
        _profileDataItem = [[TGAccountInfoCollectionItem alloc] init];
        _profileDataItem.hasDisclosureIndicator = true;
        _profileDataItem.selectable = true;
        _profileDataItem.highlightable = true;
        _profileDataItem.action = @selector(editButtonPressed);
        _profileDataItem.interfaceHandle = _actionHandle;
        
        _headerSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _profileDataItem
        ]];
        [self.menuSections addSection:_headerSection];
        
        _proxyItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.Proxy") action:@selector(proxyPressed)];
        _proxySection = [[TGCollectionMenuSection alloc] initWithItems:@[_proxyItem]];
        
        _wallpapersItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.Appearance") action:@selector(wallpapersPressed)];
        _languageItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.AppLanguage") variant:TGLocalized(@"Localization.LanguageName") action:@selector(languagePressed)];
        
        NSMutableArray *settingsItems = [[NSMutableArray alloc] init];
        [settingsItems addObject:(_notificationsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.NotificationsAndSounds") action:@selector(notificationsAndSoundsPressed)])];
        [settingsItems addObject:(_privacySettingsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.PrivacySettings") action:@selector(privacySettingsPressed)])];
        [settingsItems addObject:(_chatSettingsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.ChatSettings") action:@selector(chatSettingsPressed)])];
        [settingsItems addObject:_wallpapersItem];
        [settingsItems addObject:_languageItem];
        
        NSMutableArray *shortcutItems = [[NSMutableArray alloc] init];
        [shortcutItems addObject:(_savedMessagesItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.SavedMessages") action:@selector(savedMessagesPressed)])];
        [shortcutItems addObject:(_stickerSettingsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"ChatSettings.Stickers") action:@selector(stickerSettingsPressed)])];
        
        _shortcutSection = [[TGCollectionMenuSection alloc] initWithItems:shortcutItems];
        [self.menuSections addSection:_shortcutSection];
        
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
        
        _passportItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.Passport") action:@selector(passportPressed)];
        _watchItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.AppleWatch") action:@selector(watchPressed)];
        
        _otherSection =  [[TGCollectionMenuSection alloc] initWithItems:@[]];
        _otherSection.insets = UIEdgeInsetsZero;
        [self.menuSections addSection:_otherSection];
        
        SSignal *blockedModeSignal = [[TGDatabaseInstance() customPropertySignal:@"blockedMode"] map:^NSNumber *(NSData *data)
        {
            int32_t value = 0;
            [data getBytes:&value];
            
            return @(value);
        }];
        
        __weak TGAccountSettingsController *weakSelf = self;
        _proxyListDisposable = [[SMetaDisposable alloc] init];
        _proxyStatusDisposable = [[SMetaDisposable alloc] init];
        [_proxyListDisposable setDisposable:[[[SSignal combineSignals:@[[TGProxySignals listSignal], blockedModeSignal] withInitialStates:@[ @[], @false ]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next)
        {
            __strong TGAccountSettingsController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            NSArray *list = next.firstObject;
            bool alwaysShowProxy = [next.lastObject boolValue];
            
            [strongSelf.menuSections beginRecordingChanges];
            if (list.count == 0 && !alwaysShowProxy)
            {
                NSUInteger sectionIndex = [strongSelf.menuSections.sections indexOfObject:strongSelf->_proxySection];
                if (sectionIndex != NSNotFound)
                    [strongSelf.menuSections deleteSection:sectionIndex];
                
                [strongSelf->_proxyStatusDisposable setDisposable:nil];
            }
            else
            {
                NSUInteger sectionIndex = [strongSelf.menuSections.sections indexOfObject:strongSelf->_proxySection];
                if (sectionIndex == NSNotFound)
                {
                    [strongSelf.menuSections insertSection:strongSelf->_proxySection atIndex:1];
                    
                    [strongSelf setupProxyStatus];
                }
            }
            [strongSelf.menuSections commitRecordedChanges:strongSelf.collectionView];
        }]];
        
        _supportItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.Support") action:@selector(supportPressed)];
        _supportItem.deselectAutomatically = true;
        
        _faqItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.FAQ") action:@selector(faqPressed)];
        _faqItem.deselectAutomatically = true;
        
        TGCollectionMenuSection *infoSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _supportItem,
            _faqItem
        ]];
        [self.menuSections addSection:infoSection];
   
#ifdef INTERNAL_RELEASE
        //TGCollectionMenuSection *debugSection = [[TGCollectionMenuSection alloc] initWithItems:@[[[TGButtonCollectionItem alloc] initWithTitle:@"Debug Settings" action:@selector(mySettingsPressed)]]];
        //[self.menuSections addSection:debugSection];
#endif
        
        [ActionStageInstance() watchForPath:@"/tg/loggedOut" watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_watchAppInstalledDisposable dispose];
    [_stickerPacksDisposable dispose];
    [_updatedFeaturedStickerPacksDisposable dispose];
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [_progressWindow dismiss:true];
}

- (void)loadView
{
    [super loadView];
   
    _proxyItem.icon = TGImageNamed(@"SettingsProxyIcon.png");
    _savedMessagesItem.icon = TGImageNamed(@"SettingsSavedMessagesIcon.png");
    _notificationsItem.icon = TGImageNamed(@"SettingsNotificationsIcon.png");
    _privacySettingsItem.icon = TGImageNamed(@"SettingsPrivacyIcon.png");
    _chatSettingsItem.icon = TGImageNamed(@"SettingsDataIcon.png");
    _wallpapersItem.icon = TGImageNamed(@"SettingsWallpaperIcon.png");
    _stickerSettingsItem.icon = TGImageNamed(@"SettingsStickersIcon.png");
    _languageItem.icon = TGImageNamed(@"SettingsLanguageIcon.png");
    _passportItem.icon = TGImageNamed(@"SettingsPassportIcon.png");
    _watchItem.icon = TGImageNamed(@"SettingsWatchIcon.png");
    _supportItem.icon = TGImageNamed(@"SettingsSupportIcon.png");
    _faqItem.icon = TGImageNamed(@"SettingsFaqIcon.png");
    if (_callSettingsItem != nil)
        _callSettingsItem.icon = TGImageNamed(@"SettingsCallsIcon.png");
    
    _editing = false;
    
    TGUser *user = [TGDatabaseInstance() loadUser:_uid];
    
    [_profileDataItem setUser:user animated:false];
    [self updateSubtitleWithPhoneNumber:user.phoneNumber username:user.userName];
    [self updateSuggestedSetProfilePhoto:user.photoUrlSmall.length == 0 setUsername:user.userName.length == 0];
    
    [self setTitleText:TGLocalized(@"Settings.Title")];
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)]];
    
    __weak TGAccountSettingsController *weakSelf = self;
    _stickerPacksDisposable = [[[[TGStickersSignals stickerPacks] startOn:[SQueue concurrentDefaultQueue]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict)
    {
        __strong TGAccountSettingsController *strongSelf = weakSelf;
        if (strongSelf != nil && ((NSArray *)dict[@"packs"]).count != 0)
        {
            NSUInteger unreadFeaturedCount = ((NSArray *)dict[@"featuredPacksUnreadIds"]).count;
            [strongSelf->_stickerSettingsItem setBadge:unreadFeaturedCount == 0 ? nil : [NSString stringWithFormat:@"%d", (int)unreadFeaturedCount]];
        }
    }];

    _updatedFeaturedStickerPacksDisposable = [[[TGStickersSignals updatedFeaturedStickerPacks] startOn:[SQueue concurrentDefaultQueue]] startWithNext:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak TGAccountSettingsController *weakSelf = self;
    
    SSignal *watchAppSignal = [[TGBridgeServer instanceSignal] mapToSignal:^SSignal *(TGBridgeServer *bridgeServer) {
        return [bridgeServer watchAppInstalledSignal];
    }];
    
    _watchAppInstalledDisposable = [[SMetaDisposable alloc] init];
    [_watchAppInstalledDisposable setDisposable:[[[SSignal combineSignals:@[[TGPassportSignals hasPassport], watchAppSignal] withInitialStates:@[@false, @false]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray<NSNumber *> *next)
    {
        __strong TGAccountSettingsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        NSUInteger otherSectionIndex = [strongSelf.menuSections.sections indexOfObject:strongSelf->_otherSection];
        if (otherSectionIndex == NSNotFound)
            return;
        
        bool hasPassport = next.firstObject.boolValue;
        NSUInteger indexOfPassportItem = [strongSelf.menuSections.sections[otherSectionIndex] indexOfItem:strongSelf->_passportItem];
        bool hasPassportItem = indexOfPassportItem != NSNotFound;
        
        bool hasWatchApp = next.lastObject.boolValue;
        NSUInteger indexOfWatchItem = [strongSelf.menuSections.sections[otherSectionIndex] indexOfItem:strongSelf->_watchItem];
        bool hasWatchItem = indexOfWatchItem != NSNotFound;
        
        if (hasPassport != hasPassportItem)
        {
            [strongSelf.menuSections beginRecordingChanges];
            if (hasPassport) {
                [strongSelf.menuSections insertItem:strongSelf->_passportItem toSection:otherSectionIndex atIndex:0];
            }
            else {
                [strongSelf.menuSections deleteItemFromSection:otherSectionIndex atIndex:indexOfPassportItem];
            }
            [strongSelf.menuSections commitRecordedChanges:strongSelf.collectionView];
        }
        
        if (hasWatchApp != hasWatchItem)
        {
            indexOfWatchItem = [strongSelf.menuSections.sections[otherSectionIndex] indexOfItem:strongSelf->_watchItem];
            [strongSelf.menuSections beginRecordingChanges];
            if (hasWatchApp) {
                [strongSelf.menuSections insertItem:strongSelf->_watchItem toSection:otherSectionIndex atIndex:strongSelf->_otherSection.items.count];
            }
            else {
                [strongSelf.menuSections deleteItemFromSection:otherSectionIndex atIndex:indexOfWatchItem];
            }
            [strongSelf.menuSections commitRecordedChanges:strongSelf.collectionView];
        }
        
        UIEdgeInsets targetInsets = hasPassport || hasWatchApp ? UIEdgeInsetsMake(0.0f, 0.0f, 35.0f, 0.0f) : UIEdgeInsetsZero;
        if (!UIEdgeInsetsEqualToEdgeInsets(strongSelf->_otherSection.insets, targetInsets)) {
            strongSelf->_otherSection.insets = targetInsets;
            [UIView animateWithDuration:0.3 animations:^{
                [strongSelf.collectionView.collectionViewLayout invalidateLayout];
            }];
        }
    }]];
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

#pragma mark -

- (void)editButtonPressed
{
    TGEditProfileController *controller = [[TGEditProfileController alloc] init];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)setUsernamePressed
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

- (void)setupProxyStatus
{
    __weak TGAccountSettingsController *weakSelf = self;
    [_proxyStatusDisposable setDisposable:[[[TGProxySignals stateSignal] deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *next)
    {
        __strong TGAccountSettingsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGConnectionState state = (TGConnectionState)next.integerValue;
        
        NSString *string = TGLocalized(@"Settings.ProxyDisabled");
        switch (state) {
            case TGConnectionStateTimedOut:
            case TGConnectionStateConnecting:
            case TGConnectionStateUpdating:
            case TGConnectionStateWaitingForNetwork:
                string = TGLocalized(@"Settings.ProxyConnecting");
                break;
                
            case TGConnectionStateNormal:
                string = TGLocalized(@"Settings.ProxyConnected");
                break;
                
            default:
                string = TGLocalized(@"Settings.ProxyDisabled");
                break;
        }
        
        strongSelf->_proxyItem.variant = string;
    }]];
}

- (void)setProfilePhotoPressed
{
    __weak TGAccountSettingsController *weakSelf = self;
    _avatarMixin = [[TGMediaAvatarMenuMixin alloc] initWithContext:[TGLegacyComponentsContext shared] parentController:self hasDeleteButton:false personalPhoto:true saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos saveCapturedMedia:TGAppDelegateInstance.saveCapturedMedia];
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
    _avatarMixin.requestSearchController = ^TGViewController *(TGMediaAssetsController *assetsController) {
        __strong TGAccountSettingsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        TGWebSearchController *searchController = [[TGWebSearchController alloc] initWithContext:[TGLegacyComponentsContext shared] forAvatarSelection:true embedded:true allowGrouping:false];
        searchController.presentation = strongSelf.presentation;
        
        __weak TGMediaAssetsController *weakAssetsController = assetsController;
        __weak TGWebSearchController *weakController = searchController;
        searchController.avatarCompletionBlock = ^(UIImage *image) {
            __strong TGMediaAssetsController *strongAssetsController = weakAssetsController;
            if (strongAssetsController.avatarCompletionBlock == nil)
                return;
            
            strongAssetsController.avatarCompletionBlock(image);
        };
        searchController.dismiss = ^
        {
            __strong TGWebSearchController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissEmbeddedAnimated:true];
        };
        searchController.parentNavigationController = assetsController;
        [searchController presentEmbeddedInController:assetsController animated:true];
        
        return searchController;
    };
    _avatarMixin.sourceRect = ^CGRect
    {
        __strong TGAccountSettingsController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        return [strongSelf frameForItem:strongSelf->_setProfilePhotoItem];
    };
    [_avatarMixin present];
}

- (CGRect)frameForItem:(TGCollectionItem *)item
{
    for (TGCollectionItemView *itemView in self.collectionView.visibleCells)
    {
        if (![itemView isKindOfClass:[TGCollectionItemView class]])
            continue;
        
        if (itemView.boundItem == item)
            return [itemView convertRect:itemView.bounds toView:self.view];
    }
    return CGRectZero;
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
    
    TGUser *user = [TGDatabaseInstance() loadUser:_uid];
    [self updateSuggestedSetProfilePhoto:false setUsername:user.userName.length == 0];
    
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
    
    TGUser *user = [TGDatabaseInstance() loadUser:_uid];
    [self updateSuggestedSetProfilePhoto:user.photoUrlSmall.length == 0 setUsername:user.userName.length == 0];
    
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
    NSUInteger shortcutSectionIndex = [self.menuSections.sections indexOfObject:_shortcutSection];
    if (shortcutSectionIndex == NSNotFound)
        return;
    
    if (enabled && _callSettingsItem == nil) {
        _callSettingsItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"CallSettings.RecentCalls") action:@selector(callSettingsPressed)];
        if ([self isViewLoaded])
            _callSettingsItem.icon = TGImageNamed(@"SettingsCallsIcon.png");
        [self.menuSections insertItem:_callSettingsItem toSection:shortcutSectionIndex atIndex:1];
        [self.collectionView reloadData];
    } else if (!enabled && _callSettingsItem != nil) {
        [self.menuSections deleteItemFromSection:shortcutSectionIndex atIndex:1];
        _callSettingsItem = nil;
        [self.collectionView reloadData];
    }
}

- (void)updateSuggestedSetProfilePhoto:(bool)setProfilePhoto setUsername:(bool)setUsername
{
    bool changed = false;
    bool hasSetProfilePhoto = _setProfilePhotoItem != nil;
    if (setProfilePhoto && _setProfilePhotoItem == nil)
    {
        _setProfilePhotoItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.SetProfilePhoto") action:@selector(setProfilePhotoPressed)];
        _setProfilePhotoItem.deselectAutomatically = true;
        [self.menuSections insertItem:_setProfilePhotoItem toSection:0 atIndex:1];
        
        hasSetProfilePhoto = true;
        changed = true;
    }
    else if (!setProfilePhoto && _setProfilePhotoItem != nil)
    {
        [self.menuSections deleteItemFromSection:0 atIndex:1];
        _setProfilePhotoItem = nil;
        
        hasSetProfilePhoto = false;
        changed = true;
    }
    
    if (setUsername && _setUsernameItem == nil)
    {
        _setUsernameItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.SetUsername") action:@selector(setUsernamePressed)];
        [self.menuSections addItemToSection:0 item:_setUsernameItem];
        
        changed = true;
    }
    else if (!setUsername && _setUsernameItem != nil)
    {
        [self.menuSections deleteItemFromSection:0 atIndex:hasSetProfilePhoto ? 2 : 1];
        _setUsernameItem = nil;
        
        changed = true;
    }
    
    if (changed)
        [self.collectionView reloadData];
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

- (void)savedMessagesPressed
{
    [[TGInterfaceManager instance] navigateToConversationWithId:TGTelegraphInstance.clientUserId conversation:nil performActions:nil atMessage:nil clearStack:false openKeyboard:false canOpenKeyboardWhileInTransition:false navigationController:nil selectChat:false animated:true];
}

- (void)callSettingsPressed
{
    TGRecentCallsController *controller = [[TGRecentCallsController alloc] initWithController:TGAppDelegateInstance.rootController.callsController];
    controller.presentation = self.presentation;
    [self.navigationController pushViewController:controller animated:true];
}

- (void)stickerSettingsPressed {
    [self.navigationController pushViewController:[[TGStickerPacksSettingsController alloc] initWithEditing:false masksMode:false] animated:true];
}

- (void)wallpapersPressed
{
    [self.navigationController pushViewController:[[TGAppearanceController alloc] init] animated:true];
}

- (void)mySettingsPressed
{
    [self.navigationController pushViewController:[[TGSettingsController alloc] init] animated:true];
}

- (void)supportPressed
{
    TGCustomAlertView *alertView = [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"Settings.FAQ_Intro") cancelButtonTitle:TGLocalized(@"Settings.FAQ_Button") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
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
    }];
    alertView.noActionOnDimTap = true;
}

- (void)faqPressed
{
    [TGAppDelegateInstance handleOpenInstantView:TGLocalized(@"Settings.FAQ_URL") disableActions:false];
}

#pragma mark -

- (void)updateSubtitleWithPhoneNumber:(NSString *)phoneNumber username:(NSString *)username
{
    NSString *phone = phoneNumber.length == 0 ? @"" : [TGPhoneUtils formatPhone:phoneNumber forceInternational:true];
    NSString *finalUsername = username.length > 0 ? [NSString stringWithFormat:@"@%@", username] : @"";
    [_profileDataItem setPhoneNumber:phone];
    [_profileDataItem setUsername:finalUsername];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/loggedOut"]) {
        TGDispatchOnMainThread(^{
            [_progressWindow dismiss:true];
            _progressWindow = nil;
        });
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
                    [self updateSubtitleWithPhoneNumber:user.phoneNumber username:user.userName];
                    [self updateSuggestedSetProfilePhoto:user.photoUrlSmall.length == 0 setUsername:user.userName.length == 0];
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
    if ([path hasPrefix:@"/tg/changeUserName/"])
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
                
                [TGCustomAlertView presentAlertWithTitle:nil message:TGLocalized(@"Login.UnknownError") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
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
            TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:nil actions:@[
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
                    TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] initWithContext:[TGLegacyComponentsContext shared]];
                    
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
                    
                    TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithManager:[[TGLegacyComponentsContext shared] makeOverlayWindowManager] parentController:self contentController:modernGallery];
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
//    else if ([action isEqualToString:@"editingNameChanged"])
//    {
//        _accountEditingBarButtonItem.enabled = [_profileDataItem editingFirstName].length != 0;
//    }
}

- (void)passportPressed
{
    if (!TGIsPad())
    {
        //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UINavigationController attemptRotationToDeviceOrientation];
    }
    
    TGPassportRequestController *controller = [[TGPassportRequestController alloc] initWithFormRequest:nil];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)watchPressed
{
    TGWatchController *controller = [[TGWatchController alloc] init];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)proxyPressed
{
    TGProxySetupController *controller = [[TGProxySetupController alloc] init];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)localizationUpdated
{
    [self setTitleText:TGLocalized(@"Settings.Title")];
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)] animated:false];
    
    _savedMessagesItem.title = TGLocalized(@"Settings.SavedMessages");
    _notificationsItem.title = TGLocalized(@"Settings.NotificationsAndSounds");
    _privacySettingsItem.title = TGLocalized(@"Settings.PrivacySettings");
    _chatSettingsItem.title = TGLocalized(@"Settings.ChatSettings");
    
    _stickerSettingsItem.title = TGLocalized(@"ChatSettings.Stickers");
    
    _setProfilePhotoItem.title = TGLocalized(@"Settings.SetProfilePhoto");
    _setUsernameItem.title = TGLocalized(@"Settings.SetUsername");
    _wallpapersItem.title = TGLocalized(@"Settings.Appearance");
    _supportItem.title = TGLocalized(@"Settings.Support");
    _callSettingsItem.title = TGLocalized(@"CallSettings.RecentCalls");
    
    _faqItem.title = TGLocalized(@"Settings.FAQ");
    
    _languageItem.title = TGLocalized(@"Settings.AppLanguage");
    _languageItem.variant = TGLocalized(@"Localization.LanguageName");
    
    _proxyItem.title = TGLocalized(@"Settings.Proxy");
    _passportItem.title = TGLocalized(@"Settings.Passport");
    _watchItem.title = TGLocalized(@"Settings.AppleWatch");
    
    NSUInteger sectionIndex = [self.menuSections.sections indexOfObject:_proxySection];
    if (sectionIndex != NSNotFound)
        [self setupProxyStatus];
    
    [_profileDataItem localizationUpdated];
}
    
- (void)languagePressed {
    TGLocalizationSelectionController *controller = [[TGLocalizationSelectionController alloc] init];
    controller.presentation = self.presentation;
    [self.navigationController pushViewController:controller animated:true];
}

- (void)scrollToTopRequested
{
    [self.collectionView setContentOffset:CGPointMake(0.0f, -self.collectionView.contentInset.top) animated:true];
}

@end
