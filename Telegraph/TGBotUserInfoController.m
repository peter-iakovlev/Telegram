#import "TGBotUserInfoController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGHacks.h"
#import "TGStringUtils.h"
#import "TGPhoneUtils.h"

#import "TGDatabase.h"
#import "TGInterfaceManager.h"
#import "TGTelegraph.h"
#import "TGNavigationBar.h"

#import "TGUserInfoCollectionItem.h"
#import "TGUserInfoPhoneCollectionItem.h"
#import "TGUserInfoEditingPhoneCollectionItem.h"
#import "TGUserInfoButtonCollectionItem.h"
#import "TGUserInfoEditingVariantCollectionItem.h"
#import "TGUserInfoAddPhoneCollectionItem.h"
#import "TGUserInfoVariantCollectionItem.h"
#import "TGUserInfoUsernameCollectionItem.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGForwardTargetController.h"
#import "TGAlertSoundController.h"
#import "TGPhoneLabelPickerController.h"
#import "TGCreateContactController.h"
#import "TGAddToExistingContactController.h"

#import "TGProgressWindow.h"
#import "TGActionSheet.h"

#import "TGRemoteImageView.h"

#import "TGOverlayControllerWindow.h"
#import "TGModernGalleryController.h"
#import "TGUserAvatarGalleryModel.h"
#import "TGUserAvatarGalleryItem.h"

#import "TGSynchronizeContactsActor.h"

#import "TGAlertView.h"

#import "TGSharedMediaController.h"

#import "TGTelegramNetworking.h"

#import "TGTimerTarget.h"

#import "TGBotSignals.h"

#import "TGUserInfoTextCollectionItem.h"

#import "TGGroupManagementSignals.h"

#import "TGPeerIdAdapter.h"

#import "TGChannelManagementSignals.h"

#import "TGAccountSignals.h"

#import "TGReportPeerOtherTextController.h"

#import "TGHashtagSearchController.h"

#import "TGShareMenu.h"
#import "TGSendMessageSignals.h"
#import "TGUserSignal.h"

#import "TGGroupsInCommonController.h"

@interface TGBotUserInfoController () <TGAlertSoundControllerDelegate, TGUserInfoEditingPhoneCollectionItemDelegate, TGPhoneLabelPickerControllerDelegate, TGCreateContactControllerDelegate, TGAddToExistingContactControllerDelegate>
{
    int32_t _uid;
    bool _editing;
    UIEdgeInsets _defaultPhonesSectionInsets;
    
    int64_t _sharedMediaPeerId;
    NSDictionary *_sharedMediaOptions;
    bool _withoutActions;
    
    TGUser *_user;
    TGPhonebookContact *_phonebookInfo;
    NSMutableDictionary *_userNotificationSettings;
    int _sharedMediaCount;
    
    TGBotInfo *_botInfo;
    
    TGCollectionMenuSection *_notificationSettingsSection;
    TGUserInfoVariantCollectionItem *_normalNotificationsItem;
    TGUserInfoEditingVariantCollectionItem *_notificationsItem;
    TGUserInfoEditingVariantCollectionItem *_soundItem;
    
    NSIndexPath *_currentLabelPickerIndexPath;
    
    TGProgressWindow *_progressWindow;
    
    NSTimer *_muteExpirationTimer;
    
    SMetaDisposable *_botInfoDisposable;
    UIActivityIndicatorView *_activityIndicator;
    
    TGUserInfoButtonCollectionItem *_shareContactItem;
    
    TGCollectionMenuSection *_blockUserSection;
    TGUserInfoButtonCollectionItem *_reportUserItem;
    TGUserInfoButtonCollectionItem *_blockUserItem;
    
    void (^_sendCommand)(NSString *);
    
    bool _isUserBlocked;
    
    bool _checked3dTouch;
    
    int32_t _groupsInCommonCount;
    NSString *_about;
    id<SDisposable> _updatedCachedDataDisposable;
    id<SDisposable> _cachedDataDisposable;
}

@property (nonatomic, strong) TGCollectionMenuSection *sharedMediaSection;
@property (nonatomic, strong) TGUserInfoVariantCollectionItem *sharedMediaItem;
@property (nonatomic, strong) TGUserInfoVariantCollectionItem *groupsInCommonItem;

@end

@implementation TGBotUserInfoController

- (instancetype)initWithUid:(int32_t)uid sendCommand:(void (^)(NSString *))sendCommand
{
    self = [super init];
    if (self != nil)
    {
        [self setTitleText:TGLocalized(@"UserInfo.Title")];
        
        _uid = uid;
        _sendCommand = [sendCommand copy];
        
        _sharedMediaPeerId = uid;
        _sharedMediaOptions = @{};
        
        _user = [TGDatabaseInstance() loadUser:_uid];
        _phonebookInfo = _user.phoneNumber.length != 0 ? [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(_user.phoneNumber)] : nil;
        
        _userNotificationSettings = [[NSMutableDictionary alloc] initWithDictionary:@{@"muteUntil": @(0), @"soundId": @(1)}];
        
        _defaultPhonesSectionInsets = self.phonesSection.insets;
        
        [self.userInfoItem setUser:_user animated:false];
        self.userInfoItem.automaticallyManageUserPresence = false;
        self.userInfoItem.customStatus = TGLocalized(@"Bot.GenericBotStatus");
        
        _notificationsItem = [[TGUserInfoEditingVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Notifications") variant:nil action:@selector(notificationsPressed)];
        _notificationsItem.deselectAutomatically = true;
        _soundItem = [[TGUserInfoEditingVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Sound") variant:nil action:@selector(soundPressed)];
        _soundItem.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        _notificationSettingsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
                                                                                        _notificationsItem,
                                                                                        _soundItem
                                                                                        ]];
        
        
        _normalNotificationsItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Notifications") variant:nil action:@selector(notificationsPressed)];
        _normalNotificationsItem.deselectAutomatically = true;
        _sharedMediaItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.SharedMedia") variant:nil action:@selector(sharedMediaPressed)];
        _groupsInCommonItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.GroupsInCommon") variant:@"" action:@selector(groupsInCommonPressed)];
        _sharedMediaSection = [[TGCollectionMenuSection alloc] initWithItems:@[_sharedMediaItem, _normalNotificationsItem]];
        _sharedMediaSection.insets = UIEdgeInsetsMake(22.0f, 0.0f, 0.0f, 0.0f);
        
        self.actionsSection.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
        _shareContactItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.ShareBot") action:@selector(shareContactPressed)];
        _shareContactItem.deselectAutomatically = true;

        _reportUserItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"ReportPeer.Report") action:@selector(reportUserPressed)];
        _reportUserItem.deselectAutomatically = true;
        
        _blockUserItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:@"" action:@selector(blockUserPressed)];
        _blockUserItem.deselectAutomatically = true;
        _blockUserItem.titleColor = TGDestructiveAccentColor();
        
        _blockUserSection = [[TGCollectionMenuSection alloc] initWithItems:@[_reportUserItem, _blockUserItem]];
        _blockUserSection.insets = UIEdgeInsetsMake(22.0f, 0.0f, 44.0f, 0.0f);
        
        [self _updatePhonesAndActions];
        [self _updateNotificationSettings:false];
        [self _updateSharedMediaCount];
        [self _updateUserBlocked];
        
        [ActionStageInstance() dispatchOnStageQueue:^
         {
             [ActionStageInstance() watchForPaths:@[
                                                    @"/tg/userdatachanges",
                                                    @"/tg/userpresencechanges",
                                                    @"/as/updateRelativeTimestamps",
                                                    @"/tg/contactlist",
                                                    @"/tg/phonebook",
                                                    @"/tg/blockedUsers",
                                                    [[NSString alloc] initWithFormat:@"/tg/sharedMediaCount/(%" PRIx64 ")", (int64_t)_uid]
                                                    ] watcher:self];
             
             [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 ")", _uid] watcher:self];
             [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 ",cachedOnly)", _uid] options:@{@"peerId": @(_uid)} watcher:self];
             
             
             [ActionStageInstance() requestActor:@"/tg/blockedUsers/(cached)" options:nil watcher:self];
         }];
        
        __weak TGBotUserInfoController *weakSelf = self;
        _botInfoDisposable = [[[TGBotSignals botInfoForUserId:_uid] deliverOn:[SQueue mainQueue]] startWithNext:^(TGBotInfo *botInfo)
        {
            __strong TGBotUserInfoController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (_activityIndicator != nil)
                {
                    [_activityIndicator removeFromSuperview];
                    _activityIndicator = nil;
                    strongSelf.collectionView.hidden = false;
                }
                
                [strongSelf setBotInfo:botInfo];
            }
        }];
        
        
        _updatedCachedDataDisposable = [[TGUserSignal updatedUserCachedDataWithUserId:_uid] startWithNext:nil];
        _cachedDataDisposable = [[[TGDatabaseInstance() userCachedData:_uid] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedUserData *data) {
            __strong TGBotUserInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (!TGStringCompare(strongSelf->_about, data.about) || strongSelf->_groupsInCommonCount != data.groupsInCommonCount) {
                    bool forceUpdate = !TGStringCompare(strongSelf->_about, data.about);
                    if ((strongSelf->_groupsInCommonCount != 0) != (data.groupsInCommonCount != 0)) {
                        forceUpdate = true;
                    }
                    strongSelf->_about = data.about;
                    strongSelf->_groupsInCommonCount = data.groupsInCommonCount;
                    [strongSelf->_groupsInCommonItem setVariant:[NSString stringWithFormat:@"%d", data.groupsInCommonCount]];
                    
                    if (forceUpdate) {
                        [strongSelf _updatePhonesAndActions];
                    }
                }
            }
        }];
    }
    return self;
}

- (void)dealloc
{
    [_botInfoDisposable dispose];
    [_updatedCachedDataDisposable dispose];
    [_cachedDataDisposable dispose];
}

- (void)_resetCollectionView
{
    [super _resetCollectionView];
    
    if ([self.collectionView respondsToSelector:@selector(setKeyboardDismissMode:)])
        self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

- (void)loadView
{
    [super loadView];
    
    if (_botInfo == nil)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        self.collectionView.hidden = true;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self check3DTouch];
}

#pragma mark -

- (void)_updatePhonesAndActions
{
    if (self.navigationItem.rightBarButtonItem == nil)
    {
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:false];
    }
    
    NSUInteger usernameSectionIndex = [self indexForSection:self.usernameSection];
    if (usernameSectionIndex != NSNotFound)
    {
        for (int i = (int)self.usernameSection.items.count - 1; i >= 0; i--)
        {
            [self.menuSections deleteItemFromSection:usernameSectionIndex atIndex:0];
        }
        
        NSString *shortDescription = _about;
        if (!_editing && shortDescription.length != 0)
        {
            TGUserInfoTextCollectionItem *infoItem = [[TGUserInfoTextCollectionItem alloc] init];
            infoItem.text = shortDescription;
            __weak TGBotUserInfoController *weakSelf = self;
            infoItem.followLink = ^(NSString *link) {
                TGBotUserInfoController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf followLink:link];
                }
            };
            [self.menuSections addItemToSection:usernameSectionIndex item:infoItem];
        }
        
        if (!_editing && _user.userName.length != 0)
        {
            TGUserInfoUsernameCollectionItem *usernameItem = [[TGUserInfoUsernameCollectionItem alloc] initWithLabel:TGLocalized(@"Profile.Username") username:[[NSString alloc] initWithFormat:@"@%@", _user.userName]];
            usernameItem.action = @selector(shareContactPressed);
            [self.menuSections addItemToSection:usernameSectionIndex item:usernameItem];
        }
    }
    
    NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
    if (phonesSectionIndex == NSNotFound)
        return;
    
    for (int i = (int)self.phonesSection.items.count - 1; i >= 0; i--)
    {
        [self.menuSections deleteItemFromSection:phonesSectionIndex atIndex:0];
    }
    
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
    
    if (_phonebookInfo != nil)
        [phoneNumbers addObjectsFromArray:_phonebookInfo.phoneNumbers];
    else if (_user.phoneNumber.length != 0)
    {
        TGPhoneNumber *phoneNumber = [[TGPhoneNumber alloc] initWithLabel:TGLocalized(@"UserInfo.GenericPhoneLabel") number:_user.phoneNumber];
        [phoneNumbers addObject:phoneNumber];
    }
    
    int index = -1;
    for (TGPhoneNumber *phoneNumber in phoneNumbers)
    {
        index++;
        
        if (_editing)
        {
            TGUserInfoEditingPhoneCollectionItem *editingPhoneItem = [[TGUserInfoEditingPhoneCollectionItem alloc] init];
            editingPhoneItem.delegate = self;
            [editingPhoneItem setLabel:phoneNumber.label];
            [editingPhoneItem setPhone:phoneNumber.number];
            [self.menuSections addItemToSection:phonesSectionIndex item:editingPhoneItem];
        }
        else
        {
            TGUserInfoPhoneCollectionItem *phoneItem = [[TGUserInfoPhoneCollectionItem alloc] initWithLabel:phoneNumber.label phone:phoneNumber.number phoneColor:_phonebookInfo.phoneNumbers.count > 1 && [[TGPhoneUtils cleanPhone:phoneNumber.number] isEqualToString:[TGPhoneUtils cleanPhone:_user.phoneNumber]] ? TGAccentColor() : [UIColor blackColor] action:@selector(phonePressed:)];
            phoneItem.lastInList = index == (int)_phonebookInfo.phoneNumbers.count - 1;
            [self.menuSections addItemToSection:phonesSectionIndex item:phoneItem];
        }
    }
    
    if (_editing)
    {
        NSUInteger actionsSectionIndex = [self indexForSection:self.actionsSection];
        if (actionsSectionIndex != NSNotFound)
            [self.menuSections deleteSection:actionsSectionIndex];
        
        NSUInteger sharedMediaSectionIndex = [self indexForSection:_sharedMediaSection];
        if (sharedMediaSectionIndex != NSNotFound)
            [self.menuSections deleteSection:sharedMediaSectionIndex];
        
        NSUInteger notificationSettingsIndex = [self indexForSection:_notificationSettingsSection];
        if (notificationSettingsIndex == NSNotFound)
        {
            NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
            if (phonesSectionIndex != NSNotFound)
                [self.menuSections insertSection:_notificationSettingsSection atIndex:phonesSectionIndex + 1];
            
            notificationSettingsIndex = [self indexForSection:_notificationSettingsSection];
        }
        
        NSUInteger blockUserSection = [self indexForSection:_blockUserSection];
        if (blockUserSection != NSNotFound)
            [self.menuSections deleteSection:blockUserSection];
    }
    else
    {
        NSUInteger notificationSettingsIndex = [self indexForSection:_notificationSettingsSection];
        if (notificationSettingsIndex != NSNotFound)
            [self.menuSections deleteSection:notificationSettingsIndex];
        
        NSUInteger actionsSectionIndex = [self indexForSection:self.actionsSection];
        if (actionsSectionIndex == NSNotFound)
        {
            NSUInteger usernameSectionIndex = [self indexForSection:self.usernameSection];
            if (usernameSectionIndex != NSNotFound)
            {
                NSUInteger usernameSectionIndex = [self indexForSection:self.usernameSection];
                if (usernameSectionIndex != NSNotFound)
                    [self.menuSections insertSection:self.actionsSection atIndex:usernameSectionIndex + 1];
            }
            else
            {
                NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
                if (phonesSectionIndex != NSNotFound)
                    [self.menuSections insertSection:self.actionsSection atIndex:phonesSectionIndex + 1];
            }
            
            actionsSectionIndex = [self indexForSection:self.actionsSection];
        }
        
        if (_groupsInCommonCount == 0) {
            [_sharedMediaSection deleteItem:_groupsInCommonItem];
        } else if ([_sharedMediaSection indexOfItem:_groupsInCommonItem] == NSNotFound) {
            [_sharedMediaSection addItem:_groupsInCommonItem];
        }
        
        NSUInteger sharedMediaSectionIndex = [self indexForSection:_sharedMediaSection];
        if (sharedMediaSectionIndex == NSNotFound)
        {
            if (actionsSectionIndex != NSNotFound)
            {
                [self.menuSections insertSection:_sharedMediaSection atIndex:actionsSectionIndex + 1];
            }
            
            sharedMediaSectionIndex = [self indexForSection:_sharedMediaSection];
        }
        
        NSUInteger blockUserSectionIndex = [self indexForSection:_blockUserSection];
        if (blockUserSectionIndex == NSNotFound)
        {
            if (sharedMediaSectionIndex != NSNotFound)
            {
                [self.menuSections insertSection:_blockUserSection atIndex:sharedMediaSectionIndex + 1];
            }
        }
        
        if (!_withoutActions)
        {
            if (actionsSectionIndex != NSNotFound)
            {
                for (int i = (int)self.actionsSection.items.count - 1; i >= 0 ; i--)
                {
                    [self.menuSections deleteItemFromSection:actionsSectionIndex atIndex:0];
                }
                
                [self.menuSections addItemToSection:actionsSectionIndex item:[[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.SendMessage") action:@selector(sendMessagePressed)]];
                
                if (_user.botKind == TGBotKindGeneric)
                {
                    TGUserInfoButtonCollectionItem *inviteToGroupItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.InviteBotToGroup") action:@selector(inviteToGroupPressed)];
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                        inviteToGroupItem.deselectAutomatically = true;
                    [self.menuSections addItemToSection:actionsSectionIndex item:inviteToGroupItem];
                }
                
                [self.menuSections addItemToSection:actionsSectionIndex item:_shareContactItem];
                
                bool hasHelp = false;
                bool hasSettings = false;
                for (TGBotComandInfo *commandInfo in _botInfo.commandList)
                {
                    if ([commandInfo.command isEqualToString:@"help"])
                    {
                        hasHelp = true;
                    }
                    else if ([commandInfo.command isEqualToString:@"settings"])
                    {
                        hasSettings = true;
                    }
                }
                
                if (hasSettings)
                {
                    [self.menuSections addItemToSection:actionsSectionIndex item:[[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.BotSettings") action:@selector(botSettingsPressed)]];
                }
                
                if (hasHelp)
                {
                    [self.menuSections addItemToSection:actionsSectionIndex item:[[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.BotHelp") action:@selector(botHelpPressed)]];
                }
            }
        }
    }
    
    UIEdgeInsets phonesSectionInsets = _defaultPhonesSectionInsets;
    self.phonesSection.insets = phonesSectionInsets;
    
    [self.collectionView reloadData];
}

- (void)_updateNotificationSettings:(bool)__unused animated
{
    [_muteExpirationTimer invalidate];
    _muteExpirationTimer = nil;
    
    NSString *variant = TGLocalized(@"UserInfo.NotificationsEnabled");
    int muteUntil = [_userNotificationSettings[@"muteUntil"] intValue];
    if (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
    {
        variant = TGLocalized(@"UserInfo.NotificationsEnabled");
    }
    else
    {
        int muteExpiration = muteUntil - (int)[[TGTelegramNetworking instance] approximateRemoteTime];
        if (muteExpiration >= 7 * 24 * 60 * 60)
            variant = TGLocalized(@"UserInfo.NotificationsDisabled");
        else
        {
            variant = [TGStringUtils stringForRemainingMuteInterval:muteExpiration];
            
            _muteExpirationTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateMuteExpiration) interval:2.0 repeat:true];
        }
    }
    
    [_notificationsItem setVariant:variant];
    [_normalNotificationsItem setVariant:variant];
    
    int privateSoundId = [[_userNotificationSettings objectForKey:@"soundId"] intValue];
    _soundItem.variant = [self soundNameFromId:privateSoundId];
}

- (void)updateMuteExpiration
{
    NSString *variant = TGLocalized(@"UserInfo.NotificationsEnabled");
    int muteUntil = [_userNotificationSettings[@"muteUntil"] intValue];
    if (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
    {
        variant = TGLocalized(@"UserInfo.NotificationsEnabled");
    }
    else
    {
        int muteExpiration = muteUntil - (int)[[TGTelegramNetworking instance] approximateRemoteTime];
        variant = [TGStringUtils stringForRemainingMuteInterval:muteExpiration];
    }
    
    if (!TGStringCompare(_normalNotificationsItem.variant, variant))
    {
        [_notificationsItem setVariant:variant];
        [_normalNotificationsItem setVariant:variant];
    }
}

- (void)_updateSharedMediaCount
{
    //_sharedMediaItem.variant = _sharedMediaCount == 0 ? TGLocalized(@"GroupInfo.SharedMediaNone") : ( TGIsLocaleArabic() ? [TGStringUtils stringWithLocalizedNumber:_sharedMediaCount] : [[NSString alloc] initWithFormat:@"%d", _sharedMediaCount]);
    _sharedMediaItem.variant = @"";
}

- (void)_updateUserBlocked
{
    if (_isUserBlocked)
        _blockUserItem.title = TGLocalized(@"Bot.Unblock");
    else
        _blockUserItem.title = TGLocalized(@"Bot.Stop");
}

#pragma mark -

- (void)editPressed
{
    if (!_editing)
    {
        _editing = true;
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)] animated:true];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)] animated:true];
        
        [self animateCollectionCrossfade];
        
        [self enterEditingMode:false];
        [self _updatePhonesAndActions];
    }
}


static UIView *_findBackArrow(UIView *view)
{
    Class backArrowClass = NSClassFromString(TGEncodeText(@"`VJObwjhbujpoCbsCbdlJoejdbupsWjfx", -1));
    
    if ([view isKindOfClass:backArrowClass])
        return view;
    
    for (UIView *subview in view.subviews)
    {
        UIView *result = _findBackArrow(subview);
        if (result != nil)
            return result;
    }
    
    return nil;
}

- (void)cancelPressed
{
    _editing = false;
    
    [self setLeftBarButtonItem:nil animated:true];
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:true];
    
    if (iosMajorVersion() >= 7)
    {
        UIView *backArrow = _findBackArrow(self.navigationController.navigationBar);
        backArrow.alpha = 0.0f;
        [UIView animateWithDuration:0.3 delay:0.17 options:0 animations:^
         {
             backArrow.alpha = 1.0f;
         } completion:nil];
    }
    
    [self animateCollectionCrossfade];
    
    [self leaveEditingMode:false];
    [self _updatePhonesAndActions];
    
    if (iosMajorVersion() >= 7)
    {
        UIView *backArrow = _findBackArrow(self.navigationController.navigationBar);
        backArrow.alpha = 0.0f;
        [UIView animateWithDuration:0.2 delay:0.17 options:0 animations:^
         {
             backArrow.alpha = 1.0f;
         } completion:nil];
    }
}

- (void)donePressed
{
    if (_editing)
    {
        [self.view endEditing:true];
        
        _phonebookInfo = [_phonebookInfo copy];
        
        if (!TGStringCompare(self.userInfoItem.editingFirstName, _user.firstName) || !(TGStringCompare(self.userInfoItem.editingLastName, _user.lastName)))
        {
            _user = [_user copy];
            _user.phonebookFirstName = self.userInfoItem.editingFirstName;
            _user.phonebookLastName = self.userInfoItem.editingLastName;
            
            [self.userInfoItem setUser:_user animated:false];
            
            [self changeContactFirstName:self.userInfoItem.editingFirstName lastName:self.userInfoItem.editingLastName];
        }
        
        if ([self havePhoneChanges])
        {
            NSString *cleanMainPhone = nil;
            if (_user.phoneNumber.length != 0)
                cleanMainPhone = [TGPhoneUtils cleanInternationalPhone:_user.phoneNumber forceInternational:false];
            
            bool removedMainPhone = cleanMainPhone == nil ? false : true;
            
            NSMutableArray *newPhoneNumbers = [[NSMutableArray alloc] init];
            for (id item in self.phonesSection.items)
            {
                if ([item isKindOfClass:[TGUserInfoEditingPhoneCollectionItem class]])
                {
                    TGUserInfoEditingPhoneCollectionItem *phoneItem = item;
                    if (phoneItem.phone.length != 0)
                    {
                        if (cleanMainPhone != nil && [[TGPhoneUtils cleanInternationalPhone:phoneItem.phone forceInternational:false] isEqualToString:cleanMainPhone])
                            removedMainPhone = false;
                        [newPhoneNumbers addObject:[[TGPhoneNumber alloc] initWithLabel:phoneItem.label number:phoneItem.phone]];
                    }
                }
            }
            
            _phonebookInfo.phoneNumbers = newPhoneNumbers;
            
            [self changePhoneNumbers:newPhoneNumbers removedMainPhone:removedMainPhone];
            
            if (removedMainPhone)
            {
                self.view.userInteractionEnabled = false;
                return;
            }
        }
        
        _editing = false;
        
        [self setLeftBarButtonItem:nil animated:true];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:true];
        
        if (iosMajorVersion() >= 7)
        {
            UIView *backArrow = _findBackArrow(self.navigationController.navigationBar);
            backArrow.alpha = 0.0f;
            [UIView animateWithDuration:0.3 delay:0.17 options:0 animations:^
             {
                 backArrow.alpha = 1.0f;
             } completion:nil];
        }
        
        [self.userInfoItem setEditing:false animated:false];
        
        [self animateCollectionCrossfade];
        
        [self leaveEditingMode:false];
        [self _updatePhonesAndActions];
    }
}

- (bool)havePhoneChanges
{
    NSMutableArray *currentPhones = [[NSMutableArray alloc] init];
    for (id item in self.phonesSection.items)
    {
        if ([item isKindOfClass:[TGUserInfoEditingPhoneCollectionItem class]])
        {
            TGUserInfoEditingPhoneCollectionItem *phoneItem = item;
            [currentPhones addObject:[[TGPhoneNumber alloc] initWithLabel:phoneItem.label number:phoneItem.phone]];
        }
    }
    
    if (currentPhones.count != _phonebookInfo.phoneNumbers.count)
        return true;
    
    for (int i = 0; i < (int)currentPhones.count; i++)
    {
        TGPhoneNumber *phoneNumber1 = currentPhones[i];
        TGPhoneNumber *phoneNumber2 = _phonebookInfo.phoneNumbers[i];
        
        if (![phoneNumber1 isEqualToPhoneNumber:phoneNumber2])
            return true;
    }
    
    return false;
}

- (void)phonePressed:(id)item
{
    for (TGUserInfoPhoneCollectionItem *phoneItem in self.phonesSection.items)
    {
        if (item == phoneItem)
        {
            [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"tel:%@", [TGPhoneUtils formatPhoneUrl:phoneItem.phone]]]];
            
            break;
        }
    }
}

- (void)sendMessagePressed
{
    [[TGInterfaceManager instance] navigateToConversationWithId:_uid conversation:nil];
}

- (void)notificationsPressed
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.NotificationsEnable") action:@"enable"]];
    
    NSArray *muteIntervals = @[
                               @(1 * 60 * 60),
                               @(8 * 60 * 60),
                               @(2 * 24 * 60 * 60),
                               ];
    
    for (NSNumber *nMuteInterval in muteIntervals)
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[TGStringUtils stringForMuteInterval:[nMuteInterval intValue]] action:[[NSString alloc] initWithFormat:@"%@", nMuteInterval]]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.NotificationsDisable") action:@"disable"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGBotUserInfoController *controller, NSString *action)
      {
          if ([action isEqualToString:@"enable"])
              [controller _commitEnableNotifications:true orMuteFor:0];
          else if ([action isEqualToString:@"disable"])
              [controller _commitEnableNotifications:false orMuteFor:0];
          else if (![action isEqualToString:@"cancel"])
          {
              [controller _commitEnableNotifications:false orMuteFor:[action intValue]];
          }
      } target:self] showInView:self.view];
}

- (void)_commitEnableNotifications:(bool)enable orMuteFor:(int)muteFor
{
    int muteUntil = 0;
    if (muteFor == 0)
    {
        if (enable)
            muteUntil = 0;
        else
            muteUntil = INT_MAX;
    }
    else
    {
        muteUntil = (int)([[TGTelegramNetworking instance] approximateRemoteTime] + muteFor);
    }
    
    if (muteUntil != [_userNotificationSettings[@"muteUntil"] intValue])
    {
        _userNotificationSettings[@"muteUntil"] = @(muteUntil);
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId32 ")/(userInfoControllerMute%d)", _uid, actionId++] options:@{
                                                                                                                                                                       @"peerId": @(_uid),
                                                                                                                                                                       @"muteUntil": @(muteUntil)
                                                                                                                                                                       } watcher:TGTelegraphInstance];
        [self _updateNotificationSettings:false];
    }
}

- (void)soundPressed
{
    TGAlertSoundController *alertSoundController = [[TGAlertSoundController alloc] initWithTitle:TGLocalized(@"GroupInfo.Sound") soundInfoList:[self _soundInfoListForSelectedSoundId:[_userNotificationSettings[@"soundId"] intValue]]];
    alertSoundController.delegate = self;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[alertSoundController] navigationBarClass:[TGWhiteNavigationBar class]];
    
    if ([self inPopover])
    {
        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
    }
    else if ([self inFormSheet])
    {
        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)alertSoundController:(TGAlertSoundController *)__unused alertSoundController didFinishPickingWithSoundInfo:(NSDictionary *)soundInfo
{
    if (soundInfo[@"soundId"] != nil && [soundInfo[@"soundId"] intValue] >= 0 && [soundInfo[@"soundId"] intValue] != [_userNotificationSettings[@"soundId"] intValue])
    {
        int soundId = [soundInfo[@"soundId"] intValue];
        _userNotificationSettings[@"soundId"] = @(soundId);
        [self _updateNotificationSettings:false];
        
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId32 ")/(userInfoControllerSound%d)", _uid, actionId++] options:@{
                                                                                                                                                                        @"peerId": @(_uid),
                                                                                                                                                                        @"soundId": @(soundId)
                                                                                                                                                                        } watcher:TGTelegraphInstance];
    }
}

- (NSString *)soundNameFromId:(int)soundId
{
    if (soundId == 0 || soundId == 1)
        return [TGAppDelegateInstance modernAlertSoundTitles][soundId];
    
    if (soundId >= 2 && soundId <= 9)
        return [TGAppDelegateInstance classicAlertSoundTitles][MAX(0, soundId - 2)];
    
    if (soundId >= 100 && soundId <= 111)
        return [TGAppDelegateInstance modernAlertSoundTitles][soundId - 100 + 2];
    return @"";
}

- (NSArray *)_soundInfoListForSelectedSoundId:(int)selectedSoundId
{
    NSMutableArray *infoList = [[NSMutableArray alloc] init];
    
    int defaultSoundId = 1;
    [TGDatabaseInstance() loadPeerNotificationSettings:INT_MAX - 1 soundId:&defaultSoundId muteUntil:NULL previewText:NULL messagesMuted:NULL notFound:NULL];
    NSString *defaultSoundTitle = [self soundNameFromId:defaultSoundId];
    
    int index = -1;
    for (NSString *soundName in [TGAppDelegateInstance modernAlertSoundTitles])
    {
        index++;
        
        int soundId = 0;
        bool isDefault = false;
        
        if (index == 1)
        {
            soundId = 1;
            isDefault = true;
        }
        else if (index == 0)
            soundId = 0;
        else
            soundId = index + 100 - 2;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"title"] = isDefault ? [[NSString alloc] initWithFormat:@"%@ (%@)", soundName, defaultSoundTitle] : soundName;
        dict[@"selected"] = @(selectedSoundId == soundId);
        dict[@"soundName"] = [[NSString alloc] initWithFormat:@"%d", isDefault ? defaultSoundId : soundId];
        dict[@"soundId"] = @(soundId);
        dict[@"groupId"] = @(0);
        [infoList addObject:dict];
    }
    
    index = -1;
    for (NSString *soundName in [TGAppDelegateInstance classicAlertSoundTitles])
    {
        index++;
        
        int soundId = index + 2;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"title"] = soundName;
        dict[@"selected"] = @(selectedSoundId == soundId);
        dict[@"soundName"] =  [[NSString alloc] initWithFormat:@"%d", soundId];
        dict[@"soundId"] = @(soundId);
        dict[@"groupId"] = @(1);
        [infoList addObject:dict];
    }
    
    return infoList;
}

- (void)shareContactPressed
{
    NSString *linkString = [NSString stringWithFormat:@"https://t.me/%@", _user.userName];
    NSString *shareString = linkString;
    NSString *externalString = shareString;
    if (_user.about.length > 0)
    {
        NSString *aboutText = _user.about;
        if (aboutText.length > 200)
            aboutText = [[aboutText substringToIndex:200] stringByAppendingString:@"..."];
        
        externalString = [NSString stringWithFormat:@"%@ %@", aboutText, externalString];
    }
    
    __weak TGBotUserInfoController *weakSelf = self;
    CGRect (^sourceRect)(void) = ^CGRect
    {
        __strong TGBotUserInfoController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        return [strongSelf->_shareContactItem.view convertRect:strongSelf->_shareContactItem.view.bounds toView:strongSelf.view];
    };
    
    [TGShareMenu presentInParentController:self menuController:nil buttonTitle:TGLocalized(@"ShareMenu.CopyShareLink") buttonAction:^
    {
        [[UIPasteboard generalPasteboard] setString:linkString];
    } shareAction:^(NSArray *peerIds, NSString *caption)
    {
        [[TGShareSignals shareText:shareString toPeerIds:peerIds caption:caption] startWithNext:nil];
        
        [[[TGProgressWindow alloc] init] dismissWithSuccess];
    } externalShareItemSignal:[SSignal single:shareString] sourceView:self.view sourceRect:sourceRect barButtonItem:nil];
}

- (void)inviteToGroupPressed
{
    TGForwardTargetController *controller = [[TGForwardTargetController alloc] initWithSelectGroup];
    controller.watcherHandle = self.actionHandle;

    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller] navigationBarClass:[TGWhiteNavigationBar class]];
    if ([self inPopover])
    {
        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
    }
    else if ([self inFormSheet])
    {
        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)sharedMediaPressed
{
    [self.navigationController pushViewController:[[TGSharedMediaController alloc] initWithPeerId:_sharedMediaPeerId accessHash:0 important:true] animated:true];
}

- (void)reportUserPressed {
    __weak TGBotUserInfoController *weakSelf = self;
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ReportPeer.ReasonSpam") action:@"spam"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ReportPeer.ReasonViolence") action:@"violence"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ReportPeer.ReasonPornography") action:@"pornography"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ReportPeer.ReasonOther") action:@"other"],
        
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(__unused id target, NSString *action) {
        __strong TGBotUserInfoController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (![action isEqualToString:@"cancel"]) {
                TGReportPeerReason reason = TGReportPeerReasonSpam;
                if ([action isEqualToString:@"spam"]) {
                    reason = TGReportPeerReasonSpam;
                } else if ([action isEqualToString:@"violence"]) {
                    reason = TGReportPeerReasonViolence;
                } else if ([action isEqualToString:@"pornography"]) {
                    reason = TGReportPeerReasonPornography;
                } else if ([action isEqualToString:@"other"]) {
                    reason = TGReportPeerReasonOther;
                }
                
                void (^reportBlock)(NSString *) = ^(NSString *otherText) {
                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                    [progressWindow showWithDelay:0.1];
                    
                    [[[[TGAccountSignals reportPeer:strongSelf->_uid accessHash:0 reason:reason otherText:otherText] deliverOn:[SQueue mainQueue]] onDispose:^{
                        TGDispatchOnMainThread(^{
                            [progressWindow dismiss:true];
                        });
                    }] startWithNext:nil error:^(__unused id error) {
                        if (NSClassFromString(@"UIAlertController") != nil) {
                            
                        } else {
                            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"TwoStepAuth.GenericError") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                        }
                    } completed:^{
                        __strong TGBotUserInfoController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            [strongSelf dismissViewControllerAnimated:true completion:nil];
                        }
                        
                        if (NSClassFromString(@"UIAlertController") != nil) {
                            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:TGLocalized(@"ReportPeer.AlertSuccess") preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:TGLocalized(@"Common.OK") style:UIAlertActionStyleDefault handler:nil];
                            [alertVC addAction:doneAction];
                            
                            [strongSelf presentViewController:alertVC animated:true completion:nil];
                        } else {
                            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"ReportPeer.AlertSuccess") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                        }
                    }];
                };
                
                if (reason == TGReportPeerReasonOther) {
                    TGReportPeerOtherTextController *controller = [[TGReportPeerOtherTextController alloc] initWithCompletion:^(NSString *text) {
                        if (text.length != 0) {
                            reportBlock(text);
                        }
                    }];
                    __strong TGBotUserInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf presentViewController:[TGNavigationController navigationControllerWithControllers:@[controller]] animated:true completion:nil];
                    }
                } else {
                    reportBlock(nil);
                }
            }
        }
    } target:self] showInView:self.view];
}

- (void)blockUserPressed
{
    _isUserBlocked = !_isUserBlocked;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        static int actionId = 0;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/changePeerBlockedStatus/(userInfo%d)", actionId++] options:@{@"peerId": @(_uid), @"block": @(_isUserBlocked)} watcher:TGTelegraphInstance];
        if (!_isUserBlocked)
        {
            TGDispatchOnMainThread(^
            {
                if (_sendCommand)
                {
                    _sendCommand(@"/start");
                    [self dismissSelf];
                }
                else
                    [self navigateToConversationSendingMessage:@"/start"];
            });
        }
    }];
    
    [self _updateUserBlocked];
}

- (void)_commitDeleteContact
{
    self.view.userInteractionEnabled = false;
    
    int nativeId = _phonebookInfo.nativeId;
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         if ([TGSynchronizeContactsManager instance].phonebookAccessStatus != TGPhonebookAccessStatusEnabled)
         {
             TGDispatchOnMainThread(^
                                    {
                                        self.view.userInteractionEnabled = true;
                                        
                                        [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Profile.PhonebookAccessDisabled") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
                                    });
         }
         else
         {
             [ActionStageInstance() removeWatcher:self fromPath:@"/tg/userdatachanges"];
             [ActionStageInstance() removeWatcher:self fromPath:@"/tg/contactlist"];
             [ActionStageInstance() removeWatcher:self fromPath:@"/tg/phonebook"];
             
             static int actionId = 0;
             [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/synchronizeContacts/(break%d,%d,breakLinkLocal)", _uid, actionId++] options:[NSDictionary dictionaryWithObjectsAndKeys:[[NSNumber alloc] initWithInt:_uid], @"uid", [[NSNumber alloc] initWithInt:nativeId], @"nativeId", nil] watcher:self];
         }
     }];
}

- (void)changeContactFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    self.view.userInteractionEnabled = false;
    
    int nativeId = _phonebookInfo.nativeId;
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         if ([TGSynchronizeContactsManager instance].phonebookAccessStatus != TGPhonebookAccessStatusEnabled)
         {
             TGDispatchOnMainThread(^
                                    {
                                        self.view.userInteractionEnabled = true;
                                        
                                        [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Profile.PhonebookAccessDisabled") delegate:nil cancelButtonTitle:TGLocalized(@"OK") otherButtonTitles:nil] show];
                                    });
         }
         else
         {
             static int actionId = 0;
             [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/synchronizeContacts/(%d,%d,changeNameLocal)", _uid, actionId++] options:[NSDictionary dictionaryWithObjectsAndKeys:[[NSNumber alloc] initWithInt:_uid], @"uid", firstName == nil ? @"" : firstName, @"firstName", lastName == nil ? @"" : lastName, @"lastName", [[NSNumber alloc] initWithInt:nativeId], @"nativeId", nil] watcher:self];
         }
     }];
}

- (void)changePhoneNumbers:(NSArray *)phoneNumbers removedMainPhone:(bool)removedMainPhone
{
    self.view.userInteractionEnabled = false;
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         if ([TGSynchronizeContactsManager instance].phonebookAccessStatus != TGPhonebookAccessStatusEnabled)
         {
             TGDispatchOnMainThread(^
                                    {
                                        self.view.userInteractionEnabled = true;
                                        
                                        [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Profile.PhonebookAccessDisabled") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
                                    });
         }
         else
         {
             TGDispatchOnMainThread(^
                                    {
                                        self.view.userInteractionEnabled = true;
                                    });
             
             static int actionId = 0;
             
             NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
             [options setObject:[[NSNumber alloc] initWithInt:_uid] forKey:@"uid"];
             [options setObject:[[NSNumber alloc] initWithInt:_phonebookInfo.nativeId] forKey:@"nativeId"];
             if (phoneNumbers != nil)
                 [options setObject:phoneNumbers forKey:@"phones"];
             
             if (removedMainPhone)
                 [options setObject:[[NSNumber alloc] initWithBool:true] forKey:@"removedMainPhone"];
             
             [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/synchronizeContacts/(%s,%d,changePhonesLocal)", removedMainPhone ? "removedMainPhone" : "", actionId++] options:options watcher:self];
         }
     }];
}

- (TGModernGalleryController *)createAvatarGalleryControllerForPreviewMode:(bool)previewMode
{
    TGUser *user = [TGDatabaseInstance() loadUser:_uid];
    
    if (user.photoUrlSmall.length != 0)
    {
        TGRemoteImageView *avatarView = [self.userInfoItem visibleAvatarView];
        
        if (user != nil && user.photoUrlBig != nil && avatarView.currentImage != nil)
        {
            TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
            modernGallery.previewMode = previewMode;
            if (previewMode)
                modernGallery.showInterface = false;
            
            modernGallery.model = [[TGUserAvatarGalleryModel alloc] initWithPeerId:_uid currentAvatarLegacyThumbnailImageUri:user.photoUrlSmall currentAvatarLegacyImageUri:user.photoUrlBig currentAvatarImageSize:CGSizeMake(640.0f, 640.0f)];
            
            __weak TGBotUserInfoController *weakSelf = self;
            __weak TGModernGalleryController *weakGallery = modernGallery;
            
            modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
            {
                __strong TGBotUserInfoController *strongSelf = weakSelf;
                __strong TGModernGalleryController *strongGallery = weakGallery;
                if (strongSelf != nil)
                {
                    if (strongGallery.previewMode)
                        return;
                    
                    if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                    {
                        if (((TGUserAvatarGalleryItem *)item).isCurrent)
                        {
                            ((UIView *)strongSelf.userInfoItem.visibleAvatarView).hidden = true;
                        }
                        else
                            ((UIView *)strongSelf.userInfoItem.visibleAvatarView).hidden = false;
                    }
                }
            };
            
            modernGallery.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
            {
                __strong TGBotUserInfoController *strongSelf = weakSelf;
                __strong TGModernGalleryController *strongGallery = weakGallery;
                if (strongSelf != nil)
                {
                    if (strongGallery.previewMode)
                        return nil;
                    
                    if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                    {
                        if (((TGUserAvatarGalleryItem *)item).isCurrent)
                        {
                            return strongSelf.userInfoItem.visibleAvatarView;
                        }
                    }
                }
                
                return nil;
            };
            
            modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
            {
                __strong TGBotUserInfoController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                    {
                        if (((TGUserAvatarGalleryItem *)item).isCurrent)
                        {
                            return strongSelf.userInfoItem.visibleAvatarView;
                        }
                    }
                }
                
                return nil;
            };
            
            modernGallery.completedTransitionOut = ^
            {
                __strong TGBotUserInfoController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    ((UIView *)strongSelf.userInfoItem.visibleAvatarView).hidden = false;
                }
            };
            
            if (!previewMode)
            {
                TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:modernGallery];
                controllerWindow.hidden = false;
            }
            else
            {
                CGFloat side = MIN(self.view.frame.size.width, self.view.frame.size.height);
                modernGallery.preferredContentSize = CGSizeMake(side, side);
            }
            
            return modernGallery;
        }
    }
    
    return nil;
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"willForwardMessages"])
    {
        __weak TGBotUserInfoController *weakSelf = self;
        TGConversation *conversation = options[@"target"];
        
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [progressWindow show:true];
        
        if (conversation.isChannel) {
            TGUser *user = _user;
            [[[[TGChannelManagementSignals inviteUsers:conversation.conversationId accessHash:conversation.accessHash users:@[_user]] deliverOn:[SQueue mainQueue]] onDispose:^{
                TGDispatchOnMainThread(^{
                    [progressWindow dismiss:true];
                });
            }] startWithNext:nil error:^(id error) {
                NSString *errorDescription = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                NSString *alertText = TGLocalized(@"ConversationProfile.UnknownAddMemberError");
                if ([errorDescription isEqualToString:@"USER_ALREADY_PARTICIPANT"])
                    alertText = TGLocalized(@"Target.InviteToGroupErrorAlreadyInvited");
                else if ([errorDescription isEqualToString:@"CHAT_ADMIN_REQUIRED"]) {
                    TGUser *botUser = [TGDatabaseInstance() loadUser:user.uid];
                    if (botUser.isBot) {
                        alertText = TGLocalized(@"Group.Members.AddMemberBotErrorNotAllowed");
                    } else {
                        alertText = TGLocalized(@"Group.Members.AddMemberErrorNotAllowed");
                    }
                }
                
                [[[TGAlertView alloc] initWithTitle:nil message:alertText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            } completed:^{
                __strong TGBotUserInfoController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf dismissViewControllerAnimated:true completion:nil];
                [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:nil];
            }];
            
        } else {
            int32_t uid = _uid;
            [[[[TGGroupManagementSignals inviteUserWithId:_uid toGroupWithId:TGGroupIdFromPeerId(conversation.conversationId)] deliverOn:[SQueue mainQueue]] onDispose:^
            {
                [progressWindow dismiss:true];
            }] startWithNext:^(__unused id next)
            {
                __strong TGBotUserInfoController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf dismissViewControllerAnimated:true completion:nil];
                [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:nil];
            } error:^(id error)
            {
                NSString *errorDescription = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                NSString *alertText = TGLocalized(@"ConversationProfile.UnknownAddMemberError");
                if ([errorDescription isEqualToString:@"USER_ALREADY_PARTICIPANT"])
                    alertText = TGLocalized(@"Target.InviteToGroupErrorAlreadyInvited");
                else if ([errorDescription isEqualToString:@"CHAT_ADMIN_REQUIRED"]) {
                    TGUser *botUser = [TGDatabaseInstance() loadUser:uid];
                    if (botUser.isBot) {
                        alertText = TGLocalized(@"Group.Members.AddMemberBotErrorNotAllowed");
                    } else {
                        alertText = TGLocalized(@"Group.Members.AddMemberErrorNotAllowed");
                    }
                }
                
                [[[TGAlertView alloc] initWithTitle:nil message:alertText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            } completed:nil];
        }
    }
    else if ([action isEqualToString:@"editingNameChanged"])
    {
        if (_editing)
        {
            self.navigationItem.rightBarButtonItem.enabled = self.userInfoItem.editingFirstName.length != 0 || self.userInfoItem.editingLastName.length != 0;
        }
    }
    if ([action isEqualToString:@"avatarTapped"])
    {
        [self createAvatarGalleryControllerForPreviewMode:false];
    }
    else
    
    [super actionStageActionRequested:action options:options];
}

#pragma mark -

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments
{
    if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"])
    {
        NSArray *users = ((SGraphObjectNode *)resource).object;
        for (TGUser *user in users)
        {
            if (user.uid == _uid)
            {
                TGDispatchOnMainThread(^
                {
                    int difference = [_user differenceFromUser:user];
                    _user = user;
                    
                    if (difference & (TGUserFieldFirstName | TGUserFieldLastName | TGUserFieldPhonebookFirstName | TGUserFieldPhonebookLastName | TGUserFieldPresenceOnline | TGUserFieldUsername))
                    {
                        [self.userInfoItem setUser:_user animated:true];
                    }
                    
                    if (difference & (TGUserFieldPhoneNumber | TGUserFieldUsername))
                        [self _updatePhonesAndActions];
                });
    
                break;
            }
        }
    }
    else if ([path isEqualToString:@"/as/updateRelativeTimestamps"])
    {
        TGDispatchOnMainThread(^
        {
            [self.userInfoItem updateTimestamp];
        });
    }
    else if ([path hasPrefix:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 "", _uid]])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/sharedMediaCount/(%" PRIx64 ")", (int64_t)_uid]])
    {
        TGDispatchOnMainThread(^
        {
            _sharedMediaCount = [resource intValue];
            [self _updateSharedMediaCount];
        });
    }
    else if ([path hasPrefix:@"/tg/blockedUsers/"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    
    [super actionStageResourceDispatched:path resource:resource arguments:arguments];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 "", _uid]])
    {
        TGDispatchOnMainThread(^
        {
            _userNotificationSettings = [((SGraphObjectNode *)result).object mutableCopy];
            [self _updateNotificationSettings:false];
        });
    }
    else if ([path hasPrefix:@"/tg/encrypted/createChat/"])
    {
        TGDispatchOnMainThread(^
        {
            [_progressWindow dismiss:true];
            _progressWindow = nil;
            
            if (status == ASStatusSuccess)
            {
                TGConversation *conversation = result[@"conversation"];
                [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:nil];
            }
            else
            {
                [[[TGAlertView alloc] initWithTitle:nil message:status == -2 ? [[NSString alloc] initWithFormat:TGLocalized(@"Profile.CreateEncryptedChatOutdatedError"), _user.displayFirstName, _user.displayFirstName] : TGLocalized(@"Profile.CreateEncryptedChatError") delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil] show];
            }
        });
    }
    else if ([path hasSuffix:@"changeNameLocal)"])
    {
        TGDispatchOnMainThread(^
        {
            self.view.userInteractionEnabled = true;
        });
    }
    else if ([path hasSuffix:@"breakLinkLocal)"])
    {
        TGDispatchOnMainThread(^
        {
            self.view.userInteractionEnabled = true;
            [self dismissSelf];
        });
    }
    else if ([path hasSuffix:@"changePhonesLocal)"])
    {
        TGDispatchOnMainThread(^
        {
            self.view.userInteractionEnabled = true;
        });
        
        if ([path hasPrefix:@"/tg/synchronizeContacts/(removedMainPhone"])
        {
            [ActionStageInstance() removeWatcher:self];
            
            TGDispatchOnMainThread(^
            {
                self.view.userInteractionEnabled = true;
                [self dismissSelf];
            });
        }
    }
    else if ([path hasPrefix:@"/tg/blockedUsers/"])
    {
        TGDispatchOnMainThread(^
        {
            id blockedResult = ((SGraphObjectNode *)result).object;
            
            bool blocked = false;
            
            if ([blockedResult respondsToSelector:@selector(boolValue)])
                blocked = [blockedResult boolValue];
            else if ([blockedResult isKindOfClass:[NSArray class]])
            {
                for (TGUser *user in blockedResult)
                {
                    if (user.uid == _uid)
                    {
                        blocked = true;
                        break;
                    }
                }
            }
            
            _isUserBlocked = blocked;
            [self _updateUserBlocked];
        });
    }
    
    [super actorCompleted:status path:path result:result];
}

- (void)dismissSelf
{
    if ([self inPopover])
        [[self popoverController] dismissPopoverAnimated:true];
    else
        [self.navigationController popViewControllerAnimated:true];
}

- (void)setBotInfo:(TGBotInfo *)botInfo
{
    _botInfo = botInfo;
    [self _updatePhonesAndActions];
    
}

- (void)botSettingsPressed
{
    if (_sendCommand)
    {
        _sendCommand(@"/settings");
        [self dismissSelf];
    }
    else
        [self navigateToConversationSendingMessage:@"/settings"];
}

- (void)botHelpPressed
{
    if (_sendCommand)
    {
        _sendCommand(@"/help");
        [self dismissSelf];
    }
    else
        [self navigateToConversationSendingMessage:@"/help"];
}

- (void)navigateToConversationSendingMessage:(NSString *)text
{
    TGMessage *message = [[TGMessage alloc] init];
    message.text = text;
    
    [[TGInterfaceManager instance] navigateToConversationWithId:_uid conversation:nil performActions:@{@"sendMessages": @[message]}];
}

- (void)followLink:(NSString *)link {
    if ([link hasPrefix:@"mention://"])
    {
        NSString *domain = [link substringFromIndex:@"mention://".length];
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/resolveDomain/(%@,profile)", domain] options:@{@"domain": domain, @"profile": @true} flags:0 watcher:TGTelegraphInstance];
    }
    else if ([link hasPrefix:@"hashtag://"])
    {
        NSString *hashtag = [link substringFromIndex:@"hashtag://".length];
        
        TGHashtagSearchController *hashtagController = [[TGHashtagSearchController alloc] initWithQuery:[@"#" stringByAppendingString:hashtag] peerId:0 accessHash:0];
        //__weak TGChannelInfoController *weakSelf = self;
        /*hashtagController.customResultBlock = ^(int32_t messageId) {
         __strong TGChannelInfoController *strongSelf = weakSelf;
         if (strongSelf != nil) {
         [strongSelf navigateToMessageId:messageId scrollBackMessageId:0 animated:true];
         TGModernConversationController *controller = strongSelf.controller;
         [controller.navigationController popToViewController:controller animated:true];
         }
         };*/
        
        [self.navigationController pushViewController:hashtagController animated:true];
    } else {
        @try {
            NSURL *url = [NSURL URLWithString:link];
            if (url != nil) {
                [[UIApplication sharedApplication] openURL:url];
            }
        } @catch (NSException *e) {
        }
    }
}

- (void)check3DTouch
{
    if (_checked3dTouch)
        return;
    
    _checked3dTouch = true;
    if (iosMajorVersion() >= 9)
    {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
        {
            [self registerForPreviewingWithDelegate:(id)self sourceView:self.userInfoItem.avatarView];
        }
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)__unused location
{
    if (_user.photoUrlSmall.length != 0)
    {
        previewingContext.sourceRect = previewingContext.sourceView.bounds;
        return [self createAvatarGalleryControllerForPreviewMode:true];
    }
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)__unused previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    if ([viewControllerToCommit isKindOfClass:[TGModernGalleryController class]])
    {
        TGModernGalleryController *controller = (TGModernGalleryController *)viewControllerToCommit;
        controller.previewMode = false;
        
        TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:controller];
        controllerWindow.hidden = false;
    }
}

- (void)groupsInCommonPressed {
    [self.navigationController pushViewController:[[TGGroupsInCommonController alloc] initWithUserId:_uid] animated:true];
}

@end
