/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGTelegraphUserInfoController.h"

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
#import "TGUserInfoCallsCollectionItem.h"

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
#import "TGMenuView.h"

#import "TGSharedMediaController.h"

#import "TGTelegramNetworking.h"

#import "TGTimerTarget.h"

#import "TGDialogListCompanion.h"

#import "TGUserSignal.h"
#import "TGAccountSignals.h"

#import "TGUserInfoTextCollectionItem.h"
#import "TGUserInfoEditingAboutCollectionItem.h"

#import "TGHashtagSearchController.h"

#import "TGGroupsInCommonController.h"

#import "TGShareMenu.h"
#import "TGSendMessageSignals.h"
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>

#import "TGMenuSheetController.h"

@interface TGTelegraphUserInfoController () <TGAlertSoundControllerDelegate, TGUserInfoEditingPhoneCollectionItemDelegate, TGPhoneLabelPickerControllerDelegate, TGCreateContactControllerDelegate, TGAddToExistingContactControllerDelegate>
{
    bool _editing;
    UIEdgeInsets _defaultPhonesSectionInsets;
    
    int64_t _sharedMediaPeerId;
    NSDictionary *_sharedMediaOptions;
    bool _withoutActions;
    bool _withoutCompose;
    
    TGUser *_user;
    TGPhonebookContact *_phonebookInfo;
    NSMutableDictionary *_userNotificationSettings;
    int _sharedMediaCount;
    bool _isUserBlocked;
    int _userLink;
    
    bool _supportsCalls;
    bool _callsPrivate;
    
    TGCollectionMenuSection *_notificationSettingsSection;
    TGUserInfoVariantCollectionItem *_normalNotificationsItem;
    TGUserInfoEditingVariantCollectionItem *_notificationsItem;
    TGUserInfoEditingVariantCollectionItem *_soundItem;
    
    TGCollectionMenuSection *_aboutSection;
    TGUserInfoEditingAboutCollectionItem *_editAboutItem;
    
    TGUserInfoButtonCollectionItem *_shareContactItem;
    
    TGCollectionMenuSection *_deleteContactSection;
    TGUserInfoButtonCollectionItem *_startSecretChatItem;
    
    TGCollectionMenuSection *_blockUserSection;
    TGUserInfoButtonCollectionItem *_blockUserItem;
    
    NSIndexPath *_currentLabelPickerIndexPath;
    
    TGProgressWindow *_progressWindow;
    
    NSTimer *_muteExpirationTimer;
    
    NSString *_about;
    int32_t _groupsInCommonCount;
    id<SDisposable> _updatedCachedDataDisposable;
    id<SDisposable> _cachedDataDisposable;
    SMetaDisposable *_updateAboutDisposable;
    
    bool _checked3dTouch;
    
    NSArray *_callMessages;
    
    TGMenuContainerView *_tooltipContainerView;
    NSTimer *_tooltipTimer;
}

@end

@implementation TGTelegraphUserInfoController

- (instancetype)initWithUid:(int32_t)uid
{
    return [self initWithUid:uid withoutCompose:false];
}

- (instancetype)initWithUid:(int32_t)uid callMessages:(NSArray *)callMessages
{
    _callMessages = callMessages;
    return [self initWithUid:uid withoutCompose:false];
}

- (instancetype)initWithUid:(int32_t)uid withoutCompose:(bool)withoutCompose
{
    _withoutCompose = withoutCompose;
    return [self initWithUid:uid withoutActions:false sharedMediaPeerId:uid sharedMediaOptions:nil];
}

- (instancetype)initWithUid:(int32_t)uid withoutActions:(bool)withoutActions sharedMediaPeerId:(int64_t)sharedMediaPeerId sharedMediaOptions:(NSDictionary *)sharedMediaOptions
{
    self = [super init];
    if (self != nil)
    {
        [self setTitleText:TGLocalized(@"UserInfo.Title")];
        
        _uid = uid;
        _withoutActions = withoutActions;
        _sharedMediaPeerId = sharedMediaPeerId;
        _sharedMediaOptions = sharedMediaOptions;
        
        _user = [TGDatabaseInstance() loadUser:_uid];
        _phonebookInfo = _user.phoneNumber.length != 0 ? [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(_user.phoneNumber)] : nil;
        
        _userNotificationSettings = [[NSMutableDictionary alloc] initWithDictionary:@{@"muteUntil": @(0), @"soundId": @(1)}];
        
        _defaultPhonesSectionInsets = self.phonesSection.insets;
        
        [self.userInfoItem setUser:_user animated:false];
        
        if (_withoutActions)
        {
            _defaultPhonesSectionInsets.bottom = 0;
            
            UIEdgeInsets actionsSectionInsets = self.actionsSection.insets;
            actionsSectionInsets.bottom = 44.0f;
            self.actionsSection.insets = actionsSectionInsets;
        }
        
        [self _updateCalls];
        
        _notificationsItem = [[TGUserInfoEditingVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Notifications") variant:nil action:@selector(notificationsPressed)];
        _notificationsItem.deselectAutomatically = true;
        _soundItem = [[TGUserInfoEditingVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Sound") variant:nil action:@selector(soundPressed)];
        _soundItem.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        _notificationSettingsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _notificationsItem,
            _soundItem
        ]];
        
        if (_uid == TGTelegraphInstance.clientUserId)
        {
            _updateAboutDisposable = [[SMetaDisposable alloc] init];
            
            _editAboutItem = [[TGUserInfoEditingAboutCollectionItem alloc] init];
            _editAboutItem.maxLength = 70;
            _editAboutItem.disallowNewLines = true;
            _editAboutItem.placeholder = TGLocalized(@"UserInfo.About.Placeholder");
            _editAboutItem.showRemainingCount = true;
            _editAboutItem.returnKeyType = UIReturnKeyDone;
            __weak TGTelegraphUserInfoController *weakSelf = self;
            _editAboutItem.heightChanged = ^ {
                __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf.collectionLayout invalidateLayout];
                    [strongSelf.collectionView layoutSubviews];
                }
            };
            _editAboutItem.returned = ^ {
                __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf donePressed];
                }
            };
            
            _aboutSection = [[TGCollectionMenuSection alloc] initWithItems:@[ _editAboutItem ]];
            
            UIEdgeInsets notificationSettingsInsets = _notificationSettingsSection.insets;
            notificationSettingsInsets.bottom = 0;
            _notificationSettingsSection.insets = notificationSettingsInsets;
        }
        
        _startSecretChatItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.StartSecretChat") action:@selector(startSecretChatPressed)];
        _startSecretChatItem.deselectAutomatically = true;
        _startSecretChatItem.titleColor = TGAccentColor();
        
        _normalNotificationsItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Notifications") variant:nil action:@selector(notificationsPressed)];
        _normalNotificationsItem.deselectAutomatically = true;
        _sharedMediaItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.SharedMedia") variant:nil action:@selector(sharedMediaPressed)];
        _groupsInCommonItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.GroupsInCommon") variant:@"" action:@selector(groupsInCommonPressed)];
        _sharedMediaSection = [[TGCollectionMenuSection alloc] initWithItems:@[_sharedMediaItem, _normalNotificationsItem]];
        _sharedMediaSection.insets = UIEdgeInsetsMake(22.0f, 0.0f, 0.0f, 0.0f);
        
        self.actionsSection.insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
        TGUserInfoButtonCollectionItem *deleteContactItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.DeleteContact") action:@selector(deleteContactPressed)];
        deleteContactItem.editing = true;
        deleteContactItem.deselectAutomatically = true;
        deleteContactItem.titleColor = TGDestructiveAccentColor();
        _deleteContactSection = [[TGCollectionMenuSection alloc] initWithItems:@[deleteContactItem]];

        _blockUserItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:@"" action:@selector(blockUserPressed)];
        _blockUserItem.deselectAutomatically = true;
        _blockUserItem.titleColor = TGDestructiveAccentColor();
        _blockUserSection = [[TGCollectionMenuSection alloc] initWithItems:@[_blockUserItem]];
        _blockUserSection.insets = UIEdgeInsetsMake(22.0f, 0.0f, 44.0f, 0.0f);
        
        bool outdated = false;
        _userLink = [TGDatabaseInstance() loadUserLink:_uid outdated:&outdated];
        
        _about = [TGDatabaseInstance() _userCachedDataSync:_uid].about;
        
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
                @"/tg/calls/enabled",
                [[NSString alloc] initWithFormat:@"/tg/sharedMediaCount/(%" PRIx64 ")", (int64_t)_uid]
            ] watcher:self];
            
            [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 ")", _uid] watcher:self];
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 ",cachedOnly)", _uid] options:@{@"peerId": @(_uid)} watcher:self];
            
            [ActionStageInstance() requestActor:@"/tg/blockedUsers/(cached)" options:nil watcher:self];
        }];
        
        __weak TGTelegraphUserInfoController *weakSelf = self;
        _updatedCachedDataDisposable = [[TGUserSignal updatedUserCachedDataWithUserId:_uid] startWithNext:nil];
        _cachedDataDisposable = [[[TGDatabaseInstance() userCachedData:_uid] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedUserData *data) {
            __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (!TGStringCompare(strongSelf->_about, data.about) || strongSelf->_groupsInCommonCount != data.groupsInCommonCount || strongSelf->_supportsCalls != data.supportsCalls || strongSelf->_callsPrivate != data.callsPrivate) {
                    bool forceUpdate = !TGStringCompare(strongSelf->_about, data.about) || strongSelf->_supportsCalls != data.supportsCalls;
                    if ((strongSelf->_groupsInCommonCount != 0) != (data.groupsInCommonCount != 0)) {
                        forceUpdate = true;
                    }
                    strongSelf->_about = data.about;
                    strongSelf->_groupsInCommonCount = data.groupsInCommonCount;
                    [strongSelf->_groupsInCommonItem setVariant:[NSString stringWithFormat:@"%d", data.groupsInCommonCount]];
                    strongSelf->_supportsCalls = data.supportsCalls;
                    strongSelf->_callsPrivate = data.callsPrivate;
                    
                    strongSelf.userInfoItem.showCall = strongSelf->_supportsCalls;
                    
                    if (strongSelf.userInfoItem.showCall)
                    {
                        TGDispatchAfter(0.3, dispatch_get_main_queue(), ^{
                            [strongSelf setupCallTooltip];
                        });
                    }
                    
                    if (forceUpdate) {
                        [strongSelf _updatePhonesAndActions];
                    }
                }
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [_updatedCachedDataDisposable dispose];
    [_cachedDataDisposable dispose];
    [_updateAboutDisposable dispose];
}

- (void)_resetCollectionView
{
    [super _resetCollectionView];
    
    if ([self.collectionView respondsToSelector:@selector(setKeyboardDismissMode:)])
        self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self check3DTouch];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self tooltipTimerTick];
}

#pragma mark -

- (void)_updateCalls
{
    if (_callMessages != nil)
    {
        NSUInteger callsSectionIndex = [self indexForSection:self.callsSection];
        for (int i = (int)self.callsSection.items.count - 1; i >= 0; i--)
        {
            [self.menuSections deleteItemFromSection:callsSectionIndex atIndex:0];
        }
        
        if (!_editing)
        {
            if (callsSectionIndex != NSNotFound)
            {
                TGUserInfoCallsCollectionItem *callsItem = [[TGUserInfoCallsCollectionItem alloc] init];
                [callsItem setCallMessages:_callMessages];
                [self.menuSections addItemToSection:callsSectionIndex item:callsItem];
            }
        }
    }
}

- (void)_updatePhonesAndActions
{
    if (_phonebookInfo == nil)
    {
        if (_editing)
        {
            _editing = false;
            [self leaveEditingMode:false];
            
            if (self.navigationItem.leftBarButtonItem != nil)
                [self setLeftBarButtonItem:nil];
            if (self.navigationItem.rightBarButtonItem != nil)
                [self setRightBarButtonItem:nil];
        }
    }
    else
    {
        if (self.navigationItem.rightBarButtonItem == nil)
        {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:false];
        }
    }
    
    NSUInteger usernameSectionIndex = [self indexForSection:self.usernameSection];
    if (usernameSectionIndex != NSNotFound)
    {
        for (int i = (int)self.usernameSection.items.count - 1; i >= 0; i--)
        {
            [self.menuSections deleteItemFromSection:usernameSectionIndex atIndex:0];
        }
        
        for (int j = 0; j < 2; j++) {
            bool processAbout = j == 1;
            bool processUsername = j == 0;
            
            //if (_user.kind == TGUserKindBot || _user.kind == TGUserKindSmartBot) {
                processAbout = !processAbout;
                processUsername = !processUsername;
            //}
            
            if (processAbout && !_editing && _about.length != 0)
            {
                TGUserInfoTextCollectionItem *infoItem = [[TGUserInfoTextCollectionItem alloc] init];
                infoItem.highlightLinks = _user.kind == TGUserKindBot || _user.kind == TGUserKindSmartBot;
                infoItem.title = TGLocalized(@"Profile.About");
                infoItem.text = _about;
                __weak TGTelegraphUserInfoController *weakSelf = self;
                infoItem.followLink = ^(NSString *link) {
                    TGTelegraphUserInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf followLink:link];
                    }
                };
                [self.menuSections addItemToSection:usernameSectionIndex item:infoItem];
            }
            
            if (processUsername && !_editing && _user.userName.length != 0)
            {
                TGUserInfoUsernameCollectionItem *usernameItem = [[TGUserInfoUsernameCollectionItem alloc] initWithLabel:TGLocalized(@"Profile.Username") username:[[NSString alloc] initWithFormat:@"@%@", _user.userName]];
                usernameItem.action = @selector(shareUserInfoPressed);
                [self.menuSections addItemToSection:usernameSectionIndex item:usernameItem];
            }
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
        NSInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
        if (phonesSectionIndex != NSNotFound)
        {
            [self.menuSections insertItem:[[TGUserInfoAddPhoneCollectionItem alloc] initWithAction:@selector(addPhonePressed)] toSection:phonesSectionIndex atIndex:self.phonesSection.items.count];
        }
    }
    
    bool isCurrentUser = (_user.uid == TGTelegraphInstance.clientUserId);
    
    if (_editing)
    {
        NSUInteger actionsSectionIndex = [self indexForSection:self.actionsSection];
        if (actionsSectionIndex != NSNotFound)
            [self.menuSections deleteSection:actionsSectionIndex];
        
        NSUInteger sharedMediaSectionIndex = [self indexForSection:_sharedMediaSection];
        if (sharedMediaSectionIndex != NSNotFound)
            [self.menuSections deleteSection:sharedMediaSectionIndex];
        
        NSUInteger notificationSettingsIndex = [self indexForSection:_notificationSettingsSection];
        if (!isCurrentUser)
        {
            if (notificationSettingsIndex == NSNotFound)
            {
                NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
                if (phonesSectionIndex != NSNotFound)
                    [self.menuSections insertSection:_notificationSettingsSection atIndex:phonesSectionIndex + 1];
                
                notificationSettingsIndex = [self indexForSection:_notificationSettingsSection];
            }
        }
            
        NSUInteger aboutSectionIndex = [self indexForSection:_aboutSection];
        if (aboutSectionIndex == NSNotFound)
        {
            NSUInteger aboveSectionIndex = notificationSettingsIndex;
            NSUInteger phoneSectionIndex = [self indexForSection:self.phonesSection];
            if (phoneSectionIndex != NSNotFound)
                aboveSectionIndex = phoneSectionIndex;
            
            if (aboveSectionIndex != NSNotFound)
            {
                _editAboutItem.text = _about;
                
                [self.menuSections insertSection:_aboutSection atIndex:aboveSectionIndex + 1];
            }
        }
        
        NSUInteger deleteContactSectionIndex = [self indexForSection:_deleteContactSection];
        if (deleteContactSectionIndex == NSNotFound)
        {
            NSUInteger aboveSectionIndex = notificationSettingsIndex;
            NSUInteger aboutSectionIndex = [self indexForSection:_aboutSection];
            if (aboutSectionIndex != NSNotFound)
                aboveSectionIndex = aboutSectionIndex;
            
            if (aboveSectionIndex != NSNotFound)
                [self.menuSections insertSection:_deleteContactSection atIndex:aboveSectionIndex + 1];
        }
        
        NSUInteger blockUserSection = [self indexForSection:_blockUserSection];
        if (blockUserSection != NSNotFound)
            [self.menuSections deleteSection:blockUserSection];
    }
    else
    {
        if (!isCurrentUser)
        {
            NSUInteger notificationSettingsIndex = [self indexForSection:_notificationSettingsSection];
            if (notificationSettingsIndex != NSNotFound)
                [self.menuSections deleteSection:notificationSettingsIndex];
        }
        else
        {
            NSUInteger normalNotificationIndex = [_sharedMediaSection indexOfItem:_normalNotificationsItem];
            if (normalNotificationIndex != NSNotFound)
                [_sharedMediaSection deleteItemAtIndex:normalNotificationIndex];
        }
        
        NSUInteger aboutSectionIndex = [self indexForSection:_aboutSection];
        if (aboutSectionIndex != NSNotFound)
            [self.menuSections deleteSection:aboutSectionIndex];
        
        NSUInteger deleteContactSectionIndex = [self indexForSection:_deleteContactSection];
        if (deleteContactSectionIndex != NSNotFound)
            [self.menuSections deleteSection:deleteContactSectionIndex];
        
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
                if (!isCurrentUser)
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
                
                if (!_withoutCompose)
                {
                    [self.menuSections addItemToSection:actionsSectionIndex item:[[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.SendMessage") action:@selector(sendMessagePressed)]];
                }
                
                if (_phonebookInfo != nil)
                {
                    _shareContactItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.ShareContact") action:@selector(shareContactPressed)];
                    _shareContactItem.deselectAutomatically = true;
                    
                    [self.menuSections addItemToSection:actionsSectionIndex item:_shareContactItem];
                }
                else if (_user.phoneNumber.length != 0)
                {
                    TGUserInfoButtonCollectionItem *addContactItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.AddContact") action:@selector(addContactPressed)];
                    addContactItem.deselectAutomatically = true;
                    [self.menuSections addItemToSection:actionsSectionIndex item:addContactItem];
                }
            
                if (_callMessages == nil && (_userLink & TGUserLinkKnown) && !(_userLink & (TGUserLinkForeignHasPhone | TGUserLinkForeignMutual)))
                {
                    TGUserInfoButtonCollectionItem *shareContactInfoItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.ShareMyContactInfo") action:@selector(shareMyContactInfoPressed)];
                    shareContactInfoItem.deselectAutomatically = true;
                    [self.menuSections addItemToSection:actionsSectionIndex item:shareContactInfoItem];
                }
                
                if (!isCurrentUser)
                    [self.menuSections addItemToSection:actionsSectionIndex item:_startSecretChatItem];
            }
        }
    }
    
    UIEdgeInsets phonesSectionInsets = _defaultPhonesSectionInsets;
    if (_editing)
        phonesSectionInsets.top += 32.0f;
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
        _blockUserItem.title = TGLocalized(@"Conversation.UnblockUser");
    else
        _blockUserItem.title = TGLocalized(@"Conversation.BlockUser");
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
        [self _updateCalls];
        [self _updatePhonesAndActions];
        [self.userInfoItem setEditing:true animated:false];
        
        [self tooltipTimerTick];
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
    [self _updateCalls];
    [self _updatePhonesAndActions];
    [self.userInfoItem setEditing:false animated:false];
    
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
        
        if (_uid == TGTelegraphInstance.clientUserId)
        {
            NSString *text = [_editAboutItem.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![text isEqualToString:_about])
            {
                _about = text;
                
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow showWithDelay:0.2];
                
                [_updateAboutDisposable setDisposable:[[[[TGAccountSignals updateAbout:text] deliverOn:[SQueue mainQueue]] onDispose:^{
                    [progressWindow dismiss:true];
                }] startWithNext:nil error:^(__unused id error) {
                    [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Channel.About.Error") message:nil cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                } completed:nil]];
            }
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
        [self _updateCalls];
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
            NSString *phone = [TGPhoneUtils formatPhoneUrl:phoneItem.phone];
            NSURL *url = [NSURL URLWithString:phone];
            if (url == nil) {
                phone = [TGPhoneUtils cleanInternationalPhone:phone forceInternational:[phone hasPrefix:@"+"]];
                url = [NSURL URLWithString:phone];
            }
        
            
            TGMenuSheetController *controller = [[TGMenuSheetController alloc] init];
            controller.dismissesByOutsideTap = true;
            controller.hasSwipeGesture = true;
            
            __weak TGMenuSheetController *weakController = controller;
            __weak TGTelegraphUserInfoController *weakSelf = self;
            TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController != nil)
                    [strongController dismissAnimated:true];
            }];
            
            TGMenuSheetTitleItemView *titleItem = [[TGMenuSheetTitleItemView alloc] initWithTitle:nil subtitle:[TGPhoneUtils formatPhone:phoneItem.phone forceInternational:false]];
        
            if (_supportsCalls)
            {
                TGMenuSheetButtonItemView *telegramItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"UserInfo.TelegramCall") type:TGMenuSheetButtonTypeDefault action:^
                {
                    __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                        [strongSelf callPressed];
                    
                    __strong TGMenuSheetController *strongController = weakController;
                    if (strongController != nil)
                        [strongController dismissAnimated:true];
                }];
                
                TGMenuSheetButtonItemView *phoneItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"UserInfo.PhoneCall") type:TGMenuSheetButtonTypeDefault action:^
                {
                    [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"tel:%@", phone]]];
                    __strong TGMenuSheetController *strongController = weakController;
                    if (strongController != nil)
                        [strongController dismissAnimated:true];
                }];
                
                [controller setItemViews:@[ titleItem, telegramItem, phoneItem, cancelItem ]];
            }
            else
            {
                TGMenuSheetButtonItemView *phoneItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.Call") type:TGMenuSheetButtonTypeDefault action:^
                {
                    [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"tel:%@", phone]]];
                    __strong TGMenuSheetController *strongController = weakController;
                    if (strongController != nil)
                        [strongController dismissAnimated:true];
                }];
            
                [controller setItemViews:@[ titleItem, phoneItem, cancelItem ]];
            }
            
            controller.sourceRect = ^
            {
                __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return CGRectZero;
                
                return [strongSelf sourceRectForPhoneItem:item];
            };
            [controller presentInViewController:self sourceView:self.view animated:true];
            
            break;
        }
    }
}

- (CGRect)sourceRectForPhoneItem:(TGUserInfoPhoneCollectionItem *)phoneItem
{
    for (TGUserInfoPhoneCollectionItem *item in self.phonesSection.items)
    {
        if (item == phoneItem)
        {
            if (item.view != nil)
                return [item.view convertRect:item.view.bounds toView:self.view];
                
            return CGRectZero;
        }
    }
    
    return CGRectZero;
}

- (void)sendMessagePressed
{
    [[TGInterfaceManager instance] navigateToConversationWithId:_uid conversation:nil];
}

- (void)setupCallTooltip
{
    bool displayed = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TG_displayedProfileCallTooltip_v0"] boolValue];
//#if defined(INTERNAL_RELEASE)
//    displayed = false;
//#endif
    if (displayed)
        return;
    
    if (_tooltipContainerView != nil)
        return;
    
    _tooltipTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(tooltipTimerTick) interval:3.5 repeat:false];
    
    _tooltipContainerView = [[TGMenuContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    _tooltipContainerView.menuView.forceArrowOnTop = true;
    [self.view addSubview:_tooltipContainerView];
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"UserInfo.TapToCall"), @"title", nil]];
    
    [_tooltipContainerView.menuView setButtonsAndActions:actions watcherHandle:self.actionHandle];
    [_tooltipContainerView.menuView sizeToFit];
    _tooltipContainerView.menuView.buttonHighlightDisabled = true;
    
    CGRect frame = [self.view convertRect:self.userInfoItem.boundView.bounds fromView:self.userInfoItem.boundView];
    frame.origin.x = self.view.frame.size.width - 57.0f;
    frame.origin.y += 130.0f;
    frame.size.width = 44.0f;
    frame.size.height = 44.0f;
    [_tooltipContainerView showMenuFromRect:frame animated:false];
    
    [[NSUserDefaults standardUserDefaults] setObject:@true forKey:@"TG_displayedProfileCallTooltip_v0"];
}

- (void)tooltipTimerTick
{
    [_tooltipTimer invalidate];
    _tooltipTimer = nil;
    
    [_tooltipContainerView hideMenu];
}

- (void)callPressed
{
    if (_callsPrivate)
    {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Call.ConnectionErrorTitle") message:[NSString stringWithFormat:TGLocalized(@"Call.PrivacyErrorMessage"), _user.displayFirstName] cancelButtonTitle:TGLocalized(@"OK") okButtonTitle:nil completionBlock:nil] show];
    }
    else
    {
        [[TGInterfaceManager instance] callPeerWithId:_uid];
    }
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
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGTelegraphUserInfoController *controller, NSString *action)
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
    TGContactMediaAttachment *contact = [[TGContactMediaAttachment alloc] init];
    contact.uid = _user.uid;
    contact.firstName = _user.firstName;
    contact.lastName = _user.lastName;
    contact.phoneNumber = _user.formattedPhoneNumber;
    
    id externalShareItem = [SSignal single:[self _externalShareItemForUser:_user]];
    
    __weak TGTelegraphUserInfoController *weakSelf = self;
    CGRect (^sourceRect)(void) = ^CGRect
    {
        __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        return [strongSelf->_shareContactItem.view convertRect:strongSelf->_shareContactItem.view.bounds toView:strongSelf.view];
    };
    
    [TGShareMenu presentInParentController:self menuController:nil buttonTitle:nil buttonAction:nil shareAction:^(NSArray *peerIds, NSString *caption)
    {
        [[TGShareSignals shareContact:contact toPeerIds:peerIds caption:caption] startWithNext:nil];
        
        [[[TGProgressWindow alloc] init] dismissWithSuccess];
    } externalShareItemSignal:externalShareItem sourceView:self.view sourceRect:sourceRect barButtonItem:nil];
}

- (id)_externalShareItemForUser:(TGUser *)user
{
    NSData *contactData = nil;
    NSString *filename = nil;
    
    if (iosMajorVersion() >= 9)
    {
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        contact.givenName = user.firstName;
        contact.familyName = user.lastName;
        
        CNLabeledValue<CNPhoneNumber *> *phoneValue = [CNLabeledValue labeledValueWithLabel:nil value:[CNPhoneNumber phoneNumberWithStringValue:_user.formattedPhoneNumber]];
        contact.phoneNumbers = @[ phoneValue ];
        
        NSError *error;
        contactData = [CNContactVCardSerialization dataWithContacts:@[ contact ] error:&error];
        
        if (error != nil)
            return nil;
        
        filename = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
    }
    else
    {
        ABRecordRef contact = ABPersonCreate();
        
        ABMutableMultiValueRef phoneNumberMultiValue  = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFTypeRef)(user.formattedPhoneNumber), kABPersonPhoneMobileLabel, NULL);
        
        CFErrorRef error = NULL;
        if (user.firstName.length > 0)
            ABRecordSetValue(contact, kABPersonFirstNameProperty, (__bridge CFTypeRef)(user.firstName), &error);
        if (user.lastName.length > 0)
            ABRecordSetValue(contact, kABPersonLastNameProperty, (__bridge CFTypeRef)(user.lastName), &error);
        
        ABRecordSetValue(contact, kABPersonPhoneProperty, phoneNumberMultiValue, &error);
        
        if (error != NULL)
            return nil;
        
        contactData = (__bridge NSData *)(ABPersonCreateVCardRepresentationWithPeople((__bridge CFArrayRef)@[ (__bridge id)contact ]));
        
        filename = user.displayName;
    }
    
    if (contactData.length == 0)
        return nil;
    
    NSURL *tempDirectory = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.vcf", filename]]];
    
    if ([contactData writeToURL:tempDirectory atomically:true])
        return tempDirectory;
    
    return nil;
}

- (void)addContactPressed
{
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.CreateNewContact") action:@"createNew"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.AddToExisting") action:@"addToExisting"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(TGTelegraphUserInfoController *controller, NSString *action)
    {
        if ([action isEqualToString:@"createNew"])
            [controller _commitCreateNewContact];
        else if ([action isEqualToString:@"addToExisting"])
            [controller _commitAddToExistingContact];
    } target:self] showInView:self.view];
}

- (void)shareMyContactInfoPressed
{
    if (_shareVCard)
        _shareVCard();
}

- (void)_commitCreateNewContact
{
    TGCreateContactController *createContactController = [[TGCreateContactController alloc] initWithUid:_uid firstName:_user.firstName lastName:_user.lastName phoneNumber:_user.phoneNumber];
    createContactController.delegate = self;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[createContactController] navigationBarClass:[TGWhiteNavigationBar class]];
    
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

- (void)_commitAddToExistingContact
{
    TGAddToExistingContactController *addToExistingController = [[TGAddToExistingContactController alloc] initWithUid:_uid phoneNumber:_user.phoneNumber];
    addToExistingController.delegate = self;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[addToExistingController] navigationBarClass:[TGWhiteNavigationBar class]];
    
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

- (void)addToExistingContactControllerDidFinish:(TGAddToExistingContactController *)__unused addToExistingContactController
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)createContactControllerDidFinish:(TGCreateContactController *)__unused createContactController
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)addPhonePressed
{
    if (_editing)
    {
        NSMutableArray *possibleLabels = [[NSMutableArray alloc] initWithArray:[TGSynchronizeContactsManager phoneLabels]];
        
        for (id item in self.phonesSection.items)
        {
            if ([item isKindOfClass:[TGUserInfoEditingPhoneCollectionItem class]])
            {
                TGUserInfoEditingPhoneCollectionItem *phoneItem = item;
                if (phoneItem.label != nil)
                    [possibleLabels removeObject:phoneItem.label];
            }
        }
        
        TGUserInfoEditingPhoneCollectionItem *phoneItem = [[TGUserInfoEditingPhoneCollectionItem alloc] init];
        phoneItem.delegate = self;
        phoneItem.label = possibleLabels.count != 0 ? [possibleLabels firstObject] : [[TGSynchronizeContactsManager phoneLabels] lastObject];
        
        NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
        if (phonesSectionIndex != NSNotFound)
        {
            [self.menuSections beginRecordingChanges];
            [self.menuSections insertItem:phoneItem toSection:phonesSectionIndex atIndex:MAX(0, (NSInteger)self.phonesSection.items.count - 1)];
            [self.menuSections commitRecordedChanges:self.collectionView];
            
            [phoneItem makePhoneFieldFirstResponder];
        }
    }
}

- (void)editingPhoneItemRequestedDelete:(TGUserInfoEditingPhoneCollectionItem *)editingPhoneItem
{
    if (_editing)
    {
        NSIndexPath *indexPath = [self indexPathForItem:editingPhoneItem];
        if (indexPath != nil)
        {
            [self.menuSections beginRecordingChanges];
            [self.menuSections deleteItemFromSection:indexPath.section atIndex:indexPath.item];
            [self.menuSections commitRecordedChanges:self.collectionView];
        }
    }
}

- (void)editingPhoneItemRequestedLabelSelection:(TGUserInfoEditingPhoneCollectionItem *)editingPhoneItem
{
    if (_editing)
    {
        NSIndexPath *indexPath = [self indexPathForItem:editingPhoneItem];
        if (indexPath != nil)
        {
            _currentLabelPickerIndexPath = indexPath;
            
            TGPhoneLabelPickerController *labelController = [[TGPhoneLabelPickerController alloc] initWithSelectedLabel:editingPhoneItem.label];
            labelController.delegate = self;
            
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[labelController] navigationBarClass:[TGWhiteNavigationBar class]];
            
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
    }
}

- (void)phoneLabelPickerController:(TGPhoneLabelPickerController *)__unused phoneLabelPickerController didFinishWithLabel:(NSString *)label
{
    if (_editing)
    {
        TGUserInfoEditingPhoneCollectionItem *phoneItem = self.phonesSection.items[_currentLabelPickerIndexPath.item];
        phoneItem.label = label;
    }
    
    _currentLabelPickerIndexPath = nil;
}

- (void)startSecretChatPressed
{
    int64_t peerId = [TGDatabaseInstance() activeEncryptedPeerIdForUserId:_uid];
    
    if (peerId == 0)
    {
        _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_progressWindow show:true];
        
        static int actionId = 0;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/encrypted/createChat/(profile%d)", actionId++] options:@{@"uid": @(_uid)} flags:0 watcher:self];
    }
    else
    {
        [[TGInterfaceManager instance] navigateToConversationWithId:peerId conversation:nil];
    }
}

- (void)sharedMediaPressed
{
    [self.navigationController pushViewController:[[TGSharedMediaController alloc] initWithPeerId:_sharedMediaPeerId accessHash:0 important:true] animated:true];
}

- (void)deleteContactPressed
{
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.DeleteContact") action:@"deleteContact" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(TGTelegraphUserInfoController *controller, NSString *action)
    {
        if ([action isEqualToString:@"deleteContact"])
            [controller _commitDeleteContact];
    } target:self] showInView:self.view];
}

- (void)blockUserPressed
{
    _isUserBlocked = !_isUserBlocked;
    
    static int actionId = 0;
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/changePeerBlockedStatus/(userInfo%d)", actionId++] options:@{@"peerId": @(_uid), @"block": @(_isUserBlocked)} watcher:TGTelegraphInstance];
    
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
            
            __weak TGTelegraphUserInfoController *weakSelf = self;
            __weak TGModernGalleryController *weakGallery = modernGallery;
            
            modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
            {
                __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
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
                __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
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
                __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
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
                __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
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
        [self dismissViewControllerAnimated:true completion:nil];
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
    else if ([action isEqualToString:@"callTapped"])
    {
        [self callPressed];
    }
    else if ([action isEqualToString:@"menuAction"])
    {
        [_tooltipTimer invalidate];
        _tooltipTimer = nil;
        
        [_tooltipContainerView hideMenu];
    }
    
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
    else if ([path isEqualToString:@"/tg/contactlist"] || [path isEqualToString:@"/tg/phonebook"])
    {
        TGDispatchOnMainThread(^
        {
            TGPhonebookContact *phonebookInfo = _user.phoneNumber.length != 0 ? [TGDatabaseInstance() phonebookContactByPhoneId:phoneMatchHash(_user.phoneNumber)] : nil;
            
            if ((phonebookInfo != nil) != (_phonebookInfo != nil) || (_phonebookInfo != nil && ![_phonebookInfo isEqualToPhonebookContact:phonebookInfo]))
            {
                _phonebookInfo = phonebookInfo;
                
                if (!_editing)
                    [self _updatePhonesAndActions];
            }
        });
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
    else if ([path hasPrefix:@"/tg/userLink/"])
    {
        int userLink = [(NSNumber *)((SGraphObjectNode *)resource).object intValue];
        TGDispatchOnMainThread(^
        {
            if (userLink != _userLink)
            {
                _userLink = userLink;
                [self _updatePhonesAndActions];
            }
        });
    }
    else if ([path isEqualToString:@"/tg/calls/enabled"])
    {
        bool enabled = [((SGraphObjectNode *)resource).object boolValue];
        
        TGDispatchOnMainThread(^
        {
            if (enabled)
            {
                _updatedCachedDataDisposable = [[TGUserSignal updatedUserCachedDataWithUserId:_uid] startWithNext:nil];
            }
            else
            {
                _supportsCalls = false;
                self.userInfoItem.showCall = false;
            }
        });
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

- (void)shareUserInfoPressed
{
    NSString *linkString = [NSString stringWithFormat:@"https://t.me/%@", _user.userName];
    
    __weak TGTelegraphUserInfoController *weakSelf = self;
    CGRect (^sourceRect)(void) = ^CGRect
    {
        __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        return [strongSelf->_shareContactItem.view convertRect:strongSelf->_shareContactItem.view.bounds toView:strongSelf.view];
    };
    
    [TGShareMenu presentInParentController:self menuController:nil buttonTitle:TGLocalized(@"ShareMenu.CopyShareLink") buttonAction:^
    {
        [[UIPasteboard generalPasteboard] setString:linkString];
    } shareAction:^(NSArray *peerIds, NSString *caption)
    {
        [[TGShareSignals shareText:linkString toPeerIds:peerIds caption:caption] startWithNext:nil];
        
        [[[TGProgressWindow alloc] init] dismissWithSuccess];
    } externalShareItemSignal:[SSignal single:[NSURL URLWithString:linkString]] sourceView:self.view sourceRect:sourceRect barButtonItem:nil];
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
