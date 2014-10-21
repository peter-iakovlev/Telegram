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

@interface TGTelegraphUserInfoController () <TGAlertSoundControllerDelegate, TGUserInfoEditingPhoneCollectionItemDelegate, TGPhoneLabelPickerControllerDelegate, TGCreateContactControllerDelegate, TGAddToExistingContactControllerDelegate>
{
    bool _editing;
    UIEdgeInsets _defaultPhonesSectionInsets;
    
    int64_t _sharedMediaPeerId;
    NSDictionary *_sharedMediaOptions;
    bool _withoutActions;
    
    TGUser *_user;
    TGPhonebookContact *_phonebookInfo;
    NSMutableDictionary *_userNotificationSettings;
    int _sharedMediaCount;
    
    TGCollectionMenuSection *_notificationSettingsSection;
    TGUserInfoEditingVariantCollectionItem *_notificationsItem;
    TGUserInfoEditingVariantCollectionItem *_soundItem;
    
    TGCollectionMenuSection *_startSecretChatSection;
    
    TGCollectionMenuSection *_deleteContactSection;
    
    NSIndexPath *_currentLabelPickerIndexPath;
    
    TGProgressWindow *_progressWindow;
}

@end

@implementation TGTelegraphUserInfoController

- (instancetype)initWithUid:(int32_t)uid
{
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
        
        _notificationsItem = [[TGUserInfoEditingVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Notifications") variant:nil action:@selector(notificationsPressed)];
        _notificationsItem.deselectAutomatically = true;
        _soundItem = [[TGUserInfoEditingVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Sound") variant:nil action:@selector(soundPressed)];
        _soundItem.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        _notificationSettingsSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _notificationsItem,
            _soundItem
        ]];
        
        TGUserInfoButtonCollectionItem *startSecretChatItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.StartSecretChat") action:@selector(startSecretChatPressed)];
        startSecretChatItem.deselectAutomatically = true;
        startSecretChatItem.titleColor = UIColorRGB(0x12b200);
        _startSecretChatSection = [[TGCollectionMenuSection alloc] initWithItems:@[startSecretChatItem]];
        UIEdgeInsets startSecretChatSectionInsets = _startSecretChatSection.insets;
        startSecretChatSectionInsets.bottom = 44.0f;
        _startSecretChatSection.insets = startSecretChatSectionInsets;
        
        _sharedMediaItem = [[TGUserInfoVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.SharedMedia") variant:nil action:@selector(sharedMediaPressed)];
        _sharedMediaSection = [[TGCollectionMenuSection alloc] initWithItems:@[_sharedMediaItem]];
        
        TGUserInfoButtonCollectionItem *deleteContactItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.DeleteContact") action:@selector(deleteContactPressed)];
        deleteContactItem.deselectAutomatically = true;
        deleteContactItem.titleColor = TGDestructiveAccentColor();
        _deleteContactSection = [[TGCollectionMenuSection alloc] initWithItems:@[deleteContactItem]];
        
        [self _updatePhonesAndActions];
        [self _updateNotificationSettings:false];
        [self _updateSharedMediaCount];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() watchForPaths:@[
                @"/tg/userdatachanges",
                @"/tg/userpresencechanges",
                @"/as/updateRelativeTimestamps",
                @"/tg/contactlist",
                @"/tg/phonebook",
                [[NSString alloc] initWithFormat:@"/tg/sharedMediaCount/(%" PRIx64 ")", (int64_t)_uid]
            ] watcher:self];
            
            [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 ")", _uid] watcher:self];
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId32 ",cachedOnly)", _uid] options:@{@"peerId": @(_uid)} watcher:self];
            
            NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:_sharedMediaOptions];
            options[@"limit"] = @(5);
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversations/(%" PRId64 ")/mediahistory/(0)", _sharedMediaPeerId] options:options watcher:self];
        }];
    }
    return self;
}

- (void)_resetCollectionView
{
    [super _resetCollectionView];
    
    if ([self.collectionView respondsToSelector:@selector(setKeyboardDismissMode:)])
        self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

#pragma mark -

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
        for (int i = self.usernameSection.items.count - 1; i >= 0; i--)
        {
            [self.menuSections deleteItemFromSection:usernameSectionIndex atIndex:0];
        }
        
        if (!_editing && _user.userName.length != 0)
        {
            TGUserInfoUsernameCollectionItem *usernameItem = [[TGUserInfoUsernameCollectionItem alloc] initWithLabel:TGLocalized(@"Profile.Username") username:[[NSString alloc] initWithFormat:@"@%@", _user.userName]];
            [self.menuSections addItemToSection:usernameSectionIndex item:usernameItem];
        }
    }
    
    NSUInteger phonesSectionIndex = [self indexForSection:self.phonesSection];
    if (phonesSectionIndex == NSNotFound)
        return;
    
    for (int i = self.phonesSection.items.count - 1; i >= 0; i--)
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
    
    if (_editing)
    {
        NSUInteger actionsSectionIndex = [self indexForSection:self.actionsSection];
        if (actionsSectionIndex != NSNotFound)
            [self.menuSections deleteSection:actionsSectionIndex];
        
        NSUInteger secretChatSectionIndex = [self indexForSection:_startSecretChatSection];
        if (secretChatSectionIndex != NSNotFound)
            [self.menuSections deleteSection:secretChatSectionIndex];
        
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
        
        NSUInteger deleteContactSectionIndex = [self indexForSection:_deleteContactSection];
        if (deleteContactSectionIndex == NSNotFound)
        {
            if (notificationSettingsIndex != NSNotFound)
                [self.menuSections insertSection:_deleteContactSection atIndex:notificationSettingsIndex + 1];
        }
    }
    else
    {
        NSUInteger notificationSettingsIndex = [self indexForSection:_notificationSettingsSection];
        if (notificationSettingsIndex != NSNotFound)
            [self.menuSections deleteSection:notificationSettingsIndex];
        
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
        
        NSUInteger secretChatSectionIndex = [self indexForSection:_startSecretChatSection];
        if (!_withoutActions)
        {
            if (secretChatSectionIndex == NSNotFound)
            {
                if (actionsSectionIndex != NSNotFound)
                    [self.menuSections insertSection:_startSecretChatSection atIndex:actionsSectionIndex + 1];
                
                secretChatSectionIndex = [self indexForSection:_startSecretChatSection];
            }
        }
        
        NSUInteger sharedMediaSectionIndex = [self indexForSection:_sharedMediaSection];
        if (sharedMediaSectionIndex == NSNotFound)
        {
            if (secretChatSectionIndex != NSNotFound)
                [self.menuSections insertSection:_sharedMediaSection atIndex:secretChatSectionIndex + 1];
            else if (actionsSectionIndex != NSNotFound)
                [self.menuSections insertSection:_sharedMediaSection atIndex:actionsSectionIndex + 1];
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

                if (_phonebookInfo != nil)
                {
                    TGUserInfoButtonCollectionItem *shareContactItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.ShareContact") action:@selector(shareContactPressed)];
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                        shareContactItem.deselectAutomatically = true;
                    
                    [self.menuSections addItemToSection:actionsSectionIndex item:shareContactItem];
                }
                else if (_user.phoneNumber.length != 0)
                {
                    TGUserInfoButtonCollectionItem *addContactItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"UserInfo.AddContact") action:@selector(addContactPressed)];
                    addContactItem.deselectAutomatically = true;
                    [self.menuSections addItemToSection:actionsSectionIndex item:addContactItem];
                }
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
    [_notificationsItem setVariant:[_userNotificationSettings[@"muteUntil"] intValue] == 0 ? TGLocalized(@"UserInfo.NotificationsEnabled") : TGLocalized(@"UserInfo.NotificationsDisabled")];

    int privateSoundId = [[_userNotificationSettings objectForKey:@"soundId"] intValue];
    _soundItem.variant = [self soundNameFromId:privateSoundId];
}

- (void)_updateSharedMediaCount
{
    _sharedMediaItem.variant = _sharedMediaCount == 0 ? TGLocalized(@"GroupInfo.SharedMediaNone") : ( TGIsLocaleArabic() ? [TGStringUtils stringWithLocalizedNumber:_sharedMediaCount] : [[NSString alloc] initWithFormat:@"%d", _sharedMediaCount]);
}

#pragma mark -

- (void)editPressed
{
    if (!_editing)
    {
        _editing = true;

        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)] animated:true];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)] animated:true];
        
        [self _animateCollectionCrossfade];
        
        [self enterEditingMode:false];
        [self _updatePhonesAndActions];
        [self.userInfoItem setEditing:true animated:false];
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
    
    [self _animateCollectionCrossfade];
    
    [self leaveEditingMode:false];
    [self _updatePhonesAndActions];
    [self.userInfoItem setEditing:false animated:false];
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
        
        [self _animateCollectionCrossfade];

        [self leaveEditingMode:false];
        [self _updatePhonesAndActions];
        [self.userInfoItem setEditing:false animated:false];
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

- (void)_animateCollectionCrossfade
{
    UIView *snapshotView = [self.collectionView snapshotViewAfterScreenUpdates:false];
    [self.view insertSubview:snapshotView aboveSubview:self.collectionView];
    
    [UIView animateWithDuration:0.3 animations:^
    {
        snapshotView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [snapshotView removeFromSuperview];
    }];
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
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.NotificationsEnable") action:@"enable"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.NotificationsDisable") action:@"disable"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(TGTelegraphUserInfoController *controller, NSString *action)
    {
        if ([action isEqualToString:@"enable"])
            [controller _commitEnableNotifications:true];
        else if ([action isEqualToString:@"disable"])
            [controller _commitEnableNotifications:false];
    } target:self] showInView:self.view];
}

- (void)_commitEnableNotifications:(bool)enable
{
    if (enable != ([_userNotificationSettings[@"muteUntil"] intValue] == 0))
    {
        int muteUntil = enable ? 0 : INT_MAX;
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
    [TGDatabaseInstance() loadPeerNotificationSettings:INT_MAX - 1 soundId:&defaultSoundId muteUntil:NULL previewText:NULL photoNotificationsEnabled:NULL notFound:NULL];
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
    TGMessage *message = [[TGMessage alloc] init];
    
    TGContactMediaAttachment *contactAttachment = [[TGContactMediaAttachment alloc] init];
    contactAttachment.uid = _user.uid;
    contactAttachment.firstName = _user.firstName;
    contactAttachment.lastName = _user.lastName;
    contactAttachment.phoneNumber = _user.formattedPhoneNumber;
    
    message.mediaAttachments = [[NSArray alloc] initWithObjects:contactAttachment, nil];
    
    TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:nil sendMessages:[[NSArray alloc] initWithObjects:message, nil]];
    forwardController.watcherHandle = self.actionHandle;
    forwardController.controllerTitle = TGLocalized(@"Profile.ShareContactButton");
    forwardController.confirmationDefaultPersonFormat = TGLocalized(@"Profile.ShareContactPersonFormat");
    forwardController.confirmationDefaultGroupFormat = TGLocalized(@"Profile.ShareContactGroupFormat");
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[forwardController] navigationBarClass:[TGWhiteNavigationBar class]];
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
    [[TGInterfaceManager instance] navigateToMediaListOfConversation:_sharedMediaPeerId navigationController:self.navigationController];
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
        TGUser *user = [TGDatabaseInstance() loadUser:_uid];
        
        if (user.photoUrlSmall.length != 0)
        {
            TGRemoteImageView *avatarView = [self.userInfoItem visibleAvatarView];
            
            if (user != nil && user.photoUrlBig != nil && avatarView.currentImage != nil)
            {
                TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
                
                modernGallery.model = [[TGUserAvatarGalleryModel alloc] initWithPeerId:_uid currentAvatarLegacyThumbnailImageUri:user.photoUrlSmall currentAvatarLegacyImageUri:user.photoUrlBig currentAvatarImageSize:CGSizeMake(640.0f, 640.0f)];
                
                __weak TGTelegraphUserInfoController *weakSelf = self;
                
                modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
                {
                    __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                        {
                            if (TGStringCompare(((TGUserAvatarGalleryItem *)item).legacyThumbnailUrl, strongSelf->_user.photoUrlSmall))
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
                    if (strongSelf != nil)
                    {
                        if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                        {
                            if (TGStringCompare(((TGUserAvatarGalleryItem *)item).legacyThumbnailUrl, strongSelf->_user.photoUrlSmall))
                            {
                                return strongSelf.userInfoItem.visibleAvatarView;
                            }
                        }
                    }
                    
                    return nil;
                };
                
                modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item)
                {
                    __strong TGTelegraphUserInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
                        {
                            if (TGStringCompare(((TGUserAvatarGalleryItem *)item).legacyThumbnailUrl, strongSelf->_user.photoUrlSmall))
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
                
                TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:modernGallery];
                controllerWindow.hidden = false;
            }
        }
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
    else if ([path hasPrefix:[NSString stringWithFormat:@"/tg/conversations/(%" PRId64 ")/mediahistory/", _sharedMediaPeerId]])
    {
        if (status == ASStatusSuccess)
        {
            NSDictionary *dict = ((SGraphObjectNode *)result).object;
            TGDispatchOnMainThread(^
            {
                _sharedMediaCount = MAX(0, [[dict objectForKey:@"count"] intValue]);
                [self _updateSharedMediaCount];
            });
        }
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
    
    [super actorCompleted:status path:path result:result];
}

- (void)dismissSelf
{
    if ([self inPopover])
        [[self popoverController] dismissPopoverAnimated:true];
    else
        [self.navigationController popViewControllerAnimated:true];
}

@end
