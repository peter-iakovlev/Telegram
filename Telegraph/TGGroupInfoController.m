/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGGroupInfoController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGConversation.h"
#import "TGDatabase.h"

#import "TGHacks.h"
#import "TGFont.h"
#import "TGStringUtils.h"
#import "UIDevice+PlatformInfo.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGInterfaceManager.h"
#import "TGNavigationBar.h"
#import "TGTelegraphDialogListCompanion.h"
#import "TGConversationChangeTitleRequestActor.h"
#import "TGConversationChangePhotoActor.h"

#import "TGHeaderCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGGroupInfoCollectionItem.h"
#import "TGGroupInfoUserCollectionItem.h"

#import "TGTelegraphUserInfoController.h"
#import "TGGroupInfoSelectContactController.h"
#import "TGBotUserInfoController.h"
#import "TGAlertSoundController.h"

#import "TGRemoteImageView.h"

#import "TGImageUtils.h"

#import "TGAlertView.h"
#import "TGActionSheet.h"

#import "TGModernGalleryController.h"
#import "TGGroupAvatarGalleryItem.h"
#import "TGGroupAvatarGalleryModel.h"
#import "TGOverlayControllerWindow.h"

#import "TGSharedMediaController.h"

#import "TGTimerTarget.h"

#import "TGGroupManagementSignals.h"
#import "TGProgressWindow.h"

#import "TGGroupInfoShareLinkController.h"

#import "TGGroupAdminsController.h"

#import "TGMediaAvatarMenuMixin.h"

#import "TGConvertToSupergroupController.h"

#import "TGLocalization.h"

@interface TGGroupInfoController () <TGGroupInfoSelectContactControllerDelegate, TGAlertSoundControllerDelegate>
{
    bool _editing;
    bool _haveEditableUsers;
    
    int64_t _conversationId;
    TGConversation *_conversation;
    
    TGCollectionMenuSection *_groupInfoSection;
    
    TGGroupInfoCollectionItem *_groupInfoItem;
    TGButtonCollectionItem *_setGroupPhotoItem;
    
    TGCollectionMenuSection *_notificationsAndMediaSection;
    TGSwitchCollectionItem *_notificationsItem;
    TGVariantCollectionItem *_chatAdminsItem;
    TGVariantCollectionItem *_sharedMediaItem;
    TGVariantCollectionItem *_soundItem;
    
    TGCollectionMenuSection *_usersSection;
    TGHeaderCollectionItem *_usersSectionHeader;
    TGCommentCollectionItem *_usersSectionUpgradeNotice1;
    TGCommentCollectionItem *_usersSectionUpgradeNotice2;
    TGButtonCollectionItem *_addParticipantItem;
    
    NSMutableDictionary *_groupNotificationSettings;
    NSInteger _sharedMediaCount;
    
    NSMutableArray *_soonToBeAddedUserIds;
    NSMutableArray *_soonToBeRemovedUserIds;
    NSMutableArray *_toBeUpdatedUserIds;
    
    UILabel *_leftLabel;
    
    NSTimer *_muteExpirationTimer;
    
    int _upgradeNoticeMemberLimit;
    
    bool _ignoreUpdates;
    
    TGMediaAvatarMenuMixin *_avatarMixin;
    
    TGCollectionMenuSection *_leaveSection;
    TGButtonCollectionItem *_convertToSupergroupItem;
    
    bool _checked3dTouch;
}

@end

@implementation TGGroupInfoController

- (instancetype)initWithConversationId:(int64_t)conversationId
{
    self = [super init];
    if (self != nil)
    {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _soonToBeAddedUserIds = [[NSMutableArray alloc] init];
        _soonToBeRemovedUserIds = [[NSMutableArray alloc] init];
        _toBeUpdatedUserIds = [[NSMutableArray alloc] init];
        
        _conversationId = conversationId;
        _groupNotificationSettings = [[NSMutableDictionary alloc] initWithDictionary:@{@"muteUntil": @(0), @"soundId": @(1)}];
        
        [self setTitleText:TGLocalized(@"GroupInfo.Title")];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:false];
        
        _groupInfoItem = [[TGGroupInfoCollectionItem alloc] init];
        _groupInfoItem.interfaceHandle = _actionHandle;
        
        _setGroupPhotoItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhoto") action:@selector(setGroupPhotoPressed)];
        _setGroupPhotoItem.titleColor = TGAccentColor();
        _setGroupPhotoItem.deselectAutomatically = true;
        
        _groupInfoSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _groupInfoItem,
            _setGroupPhotoItem
        ]];
        
        [self.menuSections addSection:_groupInfoSection];
        
        _notificationsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Notifications") isOn:false];
        __weak TGGroupInfoController *weakSelf = self;
        _notificationsItem.toggled = ^(bool value, __unused TGSwitchCollectionItem *item) {
            __strong TGGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf _commitEnableNotifications:value orMuteFor:0];
            }
        };
        _notificationsItem.deselectAutomatically = true;
        _soundItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Sound") variant:nil action:@selector(soundPressed)];
        _soundItem.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        _sharedMediaItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.SharedMedia") variant:nil action:@selector(sharedMediaPressed)];
        
        _chatAdminsItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.ChatAdmins") action:@selector(chatAdminsPressed)];
        
        _notificationsAndMediaSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _notificationsItem,
            _sharedMediaItem
        ]];
        UIEdgeInsets notificationsAndMediaSectionInsets = _notificationsAndMediaSection.insets;
        notificationsAndMediaSectionInsets.bottom = 18.0f;
        _notificationsAndMediaSection.insets = notificationsAndMediaSectionInsets;
        [self.menuSections addSection:_notificationsAndMediaSection];
        
        _usersSectionHeader = [[TGHeaderCollectionItem alloc] initWithTitle:@""];
        _addParticipantItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.AddParticipant") action:@selector(addParticipantPressed)];
        _addParticipantItem.leftInset = 65.0f;
        _addParticipantItem.icon = [UIImage imageNamed:@"ModernContactListAddMemberIcon.png"];
        _addParticipantItem.iconOffset = CGPointMake(3.0f, 0.0f);
        _addParticipantItem.titleColor = TGAccentColor();
        _addParticipantItem.deselectAutomatically = true;
        _usersSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _usersSectionHeader,
            _addParticipantItem
        ]];
        [self.menuSections addSection:_usersSection];
        
        _usersSectionUpgradeNotice1 = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Group.UpgradeNoticeText1")];
        _usersSectionUpgradeNotice1.topInset = -2.0f;
        
        int channelGroupMemberLimit = 1000;
        NSData *data = [TGDatabaseInstance() customProperty:@"maxChannelGroupMembers"];
        if (data.length >= 4)
        {
            int32_t maxChannelGroupMembers = 0;
            [data getBytes:&maxChannelGroupMembers length:4];
            if (maxChannelGroupMembers != 0) {
                channelGroupMemberLimit = MAX(0, maxChannelGroupMembers);
            }
        }
        
        data = [TGDatabaseInstance() customProperty:@"maxChatParticipants"];
        if (data.length >= 4)
        {
            int32_t maxChatParticipants = 0;
            [data getBytes:&maxChatParticipants length:4];
            if (maxChatParticipants == 0) {
                _upgradeNoticeMemberLimit = 99;
            } else {
                _upgradeNoticeMemberLimit = maxChatParticipants - 1;
            }
        }
        
        _usersSectionUpgradeNotice2 = [[TGCommentCollectionItem alloc] initWithFormattedText:[TGLocalized(@"Group.UpgradeNoticeText2") stringByReplacingOccurrencesOfString:@"{supergroup_member_limit}" withString:[[NSString alloc] initWithFormat:@"%d", channelGroupMemberLimit]]];
        _usersSectionUpgradeNotice2.topInset = -5.0f;
        _usersSectionUpgradeNotice2.bottomInset = 5.0f;
        
        TGButtonCollectionItem *leaveGroupItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.DeleteAndExit") action:@selector(leaveGroupPressed)];
        leaveGroupItem.titleColor = TGDestructiveAccentColor();
        leaveGroupItem.alignment = NSTextAlignmentCenter;
        leaveGroupItem.deselectAutomatically = true;
        
        NSMutableArray *leaveSectionItems = [[NSMutableArray alloc] init];
        [leaveSectionItems addObject:leaveGroupItem];
        
        _convertToSupergroupItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.ConvertToSupergroup") action:@selector(convertGroupPressed)];
        _convertToSupergroupItem.alignment = NSTextAlignmentCenter;
        _convertToSupergroupItem.deselectAutomatically = true;
        
        _leaveSection = [[TGCollectionMenuSection alloc] initWithItems:leaveSectionItems];
        
        [self.menuSections addSection:_leaveSection];
        
        [self _loadUsersAndUpdateConversation:[TGDatabaseInstance() loadConversationWithIdCached:_conversationId]];
            
        [self _updateNotificationItems:false];
        [self _updateSharedMediaCount];
        
        [self resetSections];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() watchForPaths:@[
                [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId],
                @"/tg/userdatachanges",
                @"/tg/userpresencechanges",
                @"/as/updateRelativeTimestamps",
                [[NSString alloc] initWithFormat:@"/tg/sharedMediaCount/(%" PRIx64 ")", (int64_t)_conversationId]
            ] watcher:self];
            
            [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId64 ")", _conversationId] watcher:self];
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId64 ",cachedOnly)", _conversationId] options:@{@"peerId": @(_conversationId)} watcher:self];
            
            NSArray *addActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/conversation/@/addMember/@" prefix:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")", _conversationId] watcher:self];
            NSArray *deleteActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/conversation/@/deleteMember/@" prefix:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")", _conversationId] watcher:self];
            NSArray *changeTitleActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/conversation/@/changeTitle/@" prefix:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")", _conversationId] watcher:self];
            NSArray *changeAvatarActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/conversation/@/updateAvatar/@" prefix:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")", _conversationId] watcher:self];
            
            NSString *updatingTitle = nil;
            if (changeTitleActions.count != 0)
            {
                NSString *action = [changeTitleActions lastObject];
                TGConversationChangeTitleRequestActor *actor = (TGConversationChangeTitleRequestActor *)[ActionStageInstance() executingActorWithPath:action];
                if (actor != nil)
                    updatingTitle = actor.currentTitle;
            }
            
            UIImage *updatingAvatar = nil;
            bool haveUpdatingAvatar = false;
            if (changeAvatarActions.count != 0)
            {
                NSString *action = [changeAvatarActions lastObject];
                TGConversationChangePhotoActor *actor = (TGConversationChangePhotoActor *)[ActionStageInstance() executingActorWithPath:action];
                if (actor != nil)
                {
                    updatingAvatar = actor.currentImage;
                    haveUpdatingAvatar = true;
                }
            }

            if (addActions.count != 0 || deleteActions.count != 0 || changeTitleActions.count != 0 || changeAvatarActions.count != 0)
            {
                TGDispatchOnMainThread(^
                {
                    for (NSString *path in addActions)
                    {
                        NSRange range = [path rangeOfString:@"/addMember/("];
                        int32_t uid = (int32_t)[[path substringFromIndex:(range.location + range.length)] intValue];
                        
                        [_soonToBeAddedUserIds addObject:@(uid)];
                    }
                    
                    for (NSString *path in deleteActions)
                    {
                        NSRange range = [path rangeOfString:@"/deleteMember/("];
                        int32_t uid = (int32_t)[[path substringFromIndex:(range.location + range.length)] intValue];
                        
                        [_soonToBeRemovedUserIds addObject:@(uid)];
                    }
                    
                    [_groupInfoItem setUpdatingTitle:updatingTitle];
                    
                    [_groupInfoItem setUpdatingAvatar:updatingAvatar hasUpdatingAvatar:haveUpdatingAvatar];
                    [_setGroupPhotoItem setEnabled:!haveUpdatingAvatar];
                    
                    [self _loadUsersAndUpdateConversation:_conversation];
                });
            }
        }];
    }
    return self;
}

- (void)resetSections {
    bool reload = false;
    
    if (_editing) {
        if (_conversation.isCreator) {
            if ([_notificationsAndMediaSection indexOfItem:_chatAdminsItem] == NSNotFound) {
                [_notificationsAndMediaSection insertItem:_chatAdminsItem atIndex:1];
                reload = true;
            }
        } else {
            if ([_notificationsAndMediaSection indexOfItem:_chatAdminsItem] != NSNotFound) {
                [_notificationsAndMediaSection deleteItem:_chatAdminsItem];
                reload = true;
            }
        }
    }
    
    bool canAddParticipants = _conversation.isCreator || !_conversation.hasAdmins || (_conversation.hasAdmins && _conversation.isAdmin);
    bool canEditGroup = canAddParticipants;
    
    if (canAddParticipants) {
        if ([_usersSection indexOfItem:_addParticipantItem] == NSNotFound) {
            [_usersSection insertItem:_addParticipantItem atIndex:1];
            reload = true;
        }
    } else {
        if ([_usersSection deleteItem:_addParticipantItem]) {
            reload = true;
        }
    }
    
    if (canEditGroup) {
        if ([_groupInfoSection indexOfItem:_setGroupPhotoItem] == NSNotFound) {
            [_groupInfoSection addItem:_setGroupPhotoItem];
            reload = true;
        }
    } else {
        if ([_groupInfoSection deleteItem:_setGroupPhotoItem]) {
            reload = true;
        }
    }
    
    if (reload) {
        [self.collectionView reloadData];
    }
    
    if (!canEditGroup && _editing) {
        [self leaveEditingMode:false];
    }
    
    if (!(_conversation.kickedFromChat || _conversation.leftChat || _conversation.isDeactivated)) {
        if (canEditGroup) {
            if (self.navigationItem.rightBarButtonItem == nil) {
                [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:false];
            }
        } else {
            if (self.navigationItem.rightBarButtonItem != nil) {
                [self setRightBarButtonItem:nil];
            }
        }
    }
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

#pragma mark -

- (void)_resetCollectionView
{
    [super _resetCollectionView];
    
    [self _updateLeftState];
    
    [self.collectionView setAllowEditingCells:_haveEditableUsers animated:false];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self _layoutLeftLabel:self.interfaceOrientation];
    
    [self check3DTouch];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self _layoutLeftLabel:toInterfaceOrientation];
}

#pragma mark -

- (void)editPressed
{
    if (!_editing)
    {
        _editing = true;
        
        [_groupInfoItem setEditing:true animated:true];
        
        NSIndexPath *sharedMediaIndexPath = [self indexPathForItem:_sharedMediaItem];
        if (sharedMediaIndexPath != nil)
        {
            [self.menuSections beginRecordingChanges];
            if (_conversation.isCreator && [_leaveSection indexOfItem:_convertToSupergroupItem] == NSNotFound) {
                [self.menuSections insertItem:_convertToSupergroupItem toSection:[self indexForSection:_leaveSection] atIndex:0];
            }
            [self.menuSections commitRecordedChanges:self.collectionView];
            
            [self.menuSections beginRecordingChanges];
            [self.menuSections replaceItemInSection:sharedMediaIndexPath.section atIndex:sharedMediaIndexPath.item withItem:_soundItem];
            if (_conversation.isCreator) {
                if ([_notificationsAndMediaSection indexOfItem:_chatAdminsItem] == NSNotFound) {
                    [self.menuSections insertItem:_chatAdminsItem toSection:[self indexForSection:_notificationsAndMediaSection] atIndex:2];
                }
            }
            [self.menuSections commitRecordedChanges:self.collectionView];
        }
        
        [self enterEditingMode:true];
    }
}

- (void)donePressed
{
    if (_editing)
    {
        _editing = false;
        
        if (!TGStringCompare(_conversation.chatTitle, [_groupInfoItem editingTitle]) && [_groupInfoItem editingTitle] != nil)
            [self _commitUpdateTitle:[_groupInfoItem editingTitle]];
        
        [_groupInfoItem setEditing:false animated:true];
    }
    
    NSIndexPath *soundIndexPath = [self indexPathForItem:_soundItem];
    if (soundIndexPath != nil)
    {
        [self.menuSections beginRecordingChanges];
        NSUInteger convertIndex = [_leaveSection indexOfItem:_convertToSupergroupItem];
        if (convertIndex != NSNotFound) {
            [self.menuSections deleteItemFromSection:[self indexForSection:_leaveSection] atIndex:convertIndex];
        }
        [self.menuSections commitRecordedChanges:self.collectionView];
        
        [self.menuSections beginRecordingChanges];
        [self.menuSections replaceItemInSection:soundIndexPath.section atIndex:soundIndexPath.item withItem:_sharedMediaItem];
        if ([_notificationsAndMediaSection indexOfItem:_chatAdminsItem] != NSNotFound) {
            [self.menuSections deleteItemFromSection:[self indexForSection:_notificationsAndMediaSection] atIndex:[_notificationsAndMediaSection indexOfItem:_chatAdminsItem]];
        }
        [self.menuSections commitRecordedChanges:self.collectionView];
    }
    
    [self leaveEditingMode:true];
}

- (void)didEnterEditingMode:(bool)animated
{
    [super didEnterEditingMode:animated];
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)] animated:true];
}

- (void)didLeaveEditingMode:(bool)animated
{
    [super didLeaveEditingMode:animated];
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:animated];
}

- (void)setGroupPhotoPressed
{
    if ([_groupInfoSection indexOfItem:_setGroupPhotoItem] == NSNotFound)
        return;
    
    __weak TGGroupInfoController *weakSelf = self;
    _avatarMixin = [[TGMediaAvatarMenuMixin alloc] initWithParentController:self hasDeleteButton:(_conversation.chatPhotoSmall.length != 0)];
    _avatarMixin.didFinishWithImage = ^(UIImage *image)
    {
        __strong TGGroupInfoController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _updateGroupProfileImage:image];
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.didFinishWithDelete = ^
    {
        __strong TGGroupInfoController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _commitDeleteAvatar];
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.didDismiss = ^
    {
        __strong TGGroupInfoController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_avatarMixin = nil;
    };
    [_avatarMixin present];
}

- (void)_updateGroupProfileImage:(UIImage *)image
{
    if (image == nil)
        return;
    
    if (MIN(image.size.width, image.size.height) < 160.0f)
        image = TGScaleImageToPixelSize(image, CGSizeMake(160, 160));

    NSData *imageData = UIImageJPEGRepresentation(image, 0.6f);
    if (imageData == nil)
        return;
    
    TGImageProcessor filter = [TGRemoteImageView imageProcessorForName:@"circle:64x64"];
    UIImage *avatarImage = filter(image);
    
    [_groupInfoItem setUpdatingAvatar:avatarImage hasUpdatingAvatar:true];
    [_setGroupPhotoItem setEnabled:false];
    
    NSMutableDictionary *uploadOptions = [[NSMutableDictionary alloc] init];
    [uploadOptions setObject:imageData forKey:@"imageData"];
    [uploadOptions setObject:[NSNumber numberWithLongLong:_conversation.conversationId] forKey:@"conversationId"];
    [uploadOptions setObject:avatarImage forKey:@"currentImage"];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(updateAvatar%d)", _conversationId, actionId] options:uploadOptions watcher:self];
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(updateAvatar%d)", _conversationId, actionId++] options:uploadOptions watcher:TGTelegraphInstance];
    }];
}

- (void)_commitDeleteAvatar
{
    [_groupInfoItem setUpdatingAvatar:nil hasUpdatingAvatar:true];
    [_setGroupPhotoItem setEnabled:false];
    
    NSMutableDictionary *uploadOptions = [[NSMutableDictionary alloc] init];
    [uploadOptions setObject:[NSNumber numberWithLongLong:_conversation.conversationId] forKey:@"conversationId"];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(deleteAvatar%d)", _conversationId, actionId] options:uploadOptions watcher:self];
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(deleteAvatar%d)", _conversationId, actionId++] options:uploadOptions watcher:TGTelegraphInstance];
    }];
}

- (void)_commitCancelAvatarUpdate
{
    [_groupInfoItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
    [_setGroupPhotoItem setEnabled:true];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSArray *actors = [ActionStageInstance() executingActorsWithPathPrefix:[NSString stringWithFormat:@"/tg/conversation/(%lld)/updateAvatar/", _conversationId]];
        for (ASActor *actor in actors)
        {
            [ActionStageInstance() removeAllWatchersFromPath:actor.path];
        }
    }];
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
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGGroupInfoController *controller, NSString *action)
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
    
    if (muteUntil != [_groupNotificationSettings[@"muteUntil"] intValue])
    {
        _groupNotificationSettings[@"muteUntil"] = @(muteUntil);
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(userInfoControllerMute%d)", _conversationId, actionId++] options:@{
                                                                                                                                                                       @"peerId": @(_conversationId),
                                                                                                                                                                       @"muteUntil": @(muteUntil)
                                                                                                                                                                       } watcher:TGTelegraphInstance];
        [self _updateNotificationItems:false];
    }
}

- (void)addParticipantPressed
{
    if ([self inPopover])
        [self.presentingViewController.view endEditing:true];
    
    if ([self showGroupUpgradeNotice]) {
        int64_t conversationId = _conversationId;
        __weak TGGroupInfoController *weakSelf = self;
        [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Group.UpgradeConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed) {
            if (okButtonPressed) {
                __strong TGGroupInfoController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_ignoreUpdates = true;
                }
                
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow show:true];
                
                [[[[TGGroupManagementSignals migrateGroup:conversationId] deliverOn:[SQueue mainQueue]] onDispose:^{
                    TGDispatchOnMainThread(^{
                        [progressWindow dismiss:true];
                    });
                }] startWithNext:^(TGConversation *conversation) {
                    [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:conversation];
                } error:^(__unused id error) {
                    __strong TGGroupInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        strongSelf->_ignoreUpdates = false;
                    }
                } completed:nil];
            }
        }] show];
    } else {
        int contactsMode = TGContactsModeRegistered | TGContactsModeManualFirstSection;
        if (_conversation.chatParticipants.chatAdminId == TGTelegraphInstance.clientUserId)
            contactsMode |= TGContactsModeCreateGroupLink;
        contactsMode |= TGContactsModeIgnorePrivateBots;
        TGGroupInfoSelectContactController *selectContactController = [[TGGroupInfoSelectContactController alloc] initWithContactsMode:contactsMode];
        selectContactController.delegate = self;
        
        NSMutableArray *disabledUsers = [[NSMutableArray alloc] init];
        [disabledUsers addObjectsFromArray:_conversation.chatParticipants.chatParticipantUids];
        [disabledUsers addObjectsFromArray:_soonToBeAddedUserIds];
        
        selectContactController.disabledUsers = disabledUsers;
        
        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[selectContactController] navigationBarClass:[TGWhiteNavigationBar class]];
        if ([self inPopover])
        {
            navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
        }
        
        [self presentViewController:navigationController animated:true completion:nil];
    }
}

- (void)selectContactControllerDidSelectUser:(TGUser *)user
{
    if (user.uid != 0 && ![_conversation.chatParticipants.chatParticipantUids containsObject:@(user.uid)])
    {
        __weak typeof(self) weakSelf = self;
        [[[TGAlertView alloc] initWithTitle:nil message:[[NSString alloc] initWithFormat:TGLocalized(@"GroupInfo.AddParticipantConfirmation"), user.displayFirstName] cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
        {
            if (okButtonPressed)
            {
                TGGroupInfoController *strongSelf = weakSelf;
                [strongSelf _commitAddParticipant:user];
            }
        }] show];
    }
}

- (void)selectContactControllerDidSelectCreateLink
{
    if ([self.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        TGGroupInfoShareLinkController *controller = [[TGGroupInfoShareLinkController alloc] initWithPeerId:_conversationId accessHash:0 currentLink:_conversation.chatParticipants.exportedChatInviteString];
        [(UINavigationController *)self.presentedViewController pushViewController:controller animated:true];
    }
}

- (void)_commitAddParticipant:(TGUser *)user
{
    if (![_soonToBeAddedUserIds containsObject:@(user.uid)])
    {
        [_soonToBeAddedUserIds addObject:@(user.uid)];
        [self _loadUsersAndUpdateConversation:_conversation];
        
        for (id item in _usersSection.items)
        {
            if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
            {
                if (((TGGroupInfoUserCollectionItem *)item).user.uid == user.uid)
                {
                    NSIndexPath *indexPath = [self indexPathForItem:item];
                    if (indexPath != nil && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
                        [self.collectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:UICollectionViewScrollPositionTop];
                    
                    break;
                }
            }
        }
        
        NSString *path = [NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/addMember/(%d)", _conversation.conversationId, user.uid];
        NSDictionary *options = @{@"conversationId": @(_conversationId), @"uid": @(user.uid)};
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() requestActor:path options:options watcher:self];
            [ActionStageInstance() requestActor:path options:options watcher:TGTelegraphInstance];
        }];
    }
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)_commitDeleteParticipant:(int32_t)uid
{
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]] && ((TGGroupInfoUserCollectionItem *)item).user.uid == uid)
        {
            [_soonToBeRemovedUserIds addObject:@(uid)];
            [(TGGroupInfoUserCollectionItem *)item setDisabled:true];
            [(TGGroupInfoUserCollectionItem *)item setCanEdit:false animated:true];
            
            NSDictionary *options = @{@"conversationId": @(_conversationId), @"uid": @(uid)};
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/deleteMember/(%d)", _conversationId, uid] options:options watcher:self];
            
            break;
        }
    }
}

- (void)_commitUpdateTitle:(NSString *)title
{
    [_groupInfoItem setUpdatingTitle:title];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        static int actionId = 0;
        NSString *path = [[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/changeTitle/(groupInfoController%d)", _conversation.conversationId, actionId++];
        NSDictionary *options = @{@"conversationId": @(_conversationId), @"title": title == nil ? @"" : title};
        
        [ActionStageInstance() requestActor:path options:options watcher:self];
        [ActionStageInstance() requestActor:path options:options watcher:TGTelegraphInstance];
    }];
}

- (void)leaveGroupPressed
{
    __weak typeof(self) weakSelf = self;
    
    [[[TGActionSheet alloc] initWithTitle:TGLocalized(@"GroupInfo.DeleteAndExitConfirmation") actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.DeleteAndExit") action:@"leave" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(__unused id target, NSString *action)
    {
        if ([action isEqualToString:@"leave"])
        {
            TGGroupInfoController *strongSelf = weakSelf;
            [strongSelf _commitLeaveGroup];
        }
    } target:self] showInView:self.view];
}

- (void)_commitLeaveGroup
{
    [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_conversationId unreadCount:0 serviceUnreadCount:0] animated:false];
    
    if (self.popoverController != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.popoverController dismissPopoverAnimated:true];
        });
    }
    else
        [self.navigationController popToRootViewControllerAnimated:true];
}

- (void)_changeNotificationSettings:(bool)enableNotifications
{
    _groupNotificationSettings[@"muteUntil"] = @(!enableNotifications ? INT_MAX : 0);
    
    static int actionId = 0;
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(groupInfoController%d)", _conversation.conversationId, actionId++] options:@{@"peerId": @(_conversationId), @"muteUntil": @(!enableNotifications ? INT_MAX : 0)} watcher:TGTelegraphInstance];
}

- (void)soundPressed
{
    TGAlertSoundController *alertSoundController = [[TGAlertSoundController alloc] initWithTitle:TGLocalized(@"GroupInfo.Sound") soundInfoList:[self _soundInfoListForSelectedSoundId:[_groupNotificationSettings[@"soundId"] intValue]]];
    alertSoundController.delegate = self;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[alertSoundController] navigationBarClass:[TGWhiteNavigationBar class]];
    if ([self inPopover])
    {
        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)alertSoundController:(TGAlertSoundController *)__unused alertSoundController didFinishPickingWithSoundInfo:(NSDictionary *)soundInfo
{
    if (soundInfo[@"soundId"] != nil && [soundInfo[@"soundId"] intValue] >= 0 && [soundInfo[@"soundId"] intValue] != [_groupNotificationSettings[@"soundId"] intValue])
    {
        int soundId = [soundInfo[@"soundId"] intValue];
        _groupNotificationSettings[@"soundId"] = @(soundId);
        [self _updateNotificationItems:false];
        
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(groupInfoController%d)", _conversationId, actionId++] options:@{
            @"peerId": @(_conversationId),
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
    [TGDatabaseInstance() loadPeerNotificationSettings:INT_MAX - 2 soundId:&defaultSoundId muteUntil:NULL previewText:NULL messagesMuted:NULL notFound:NULL];
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

- (void)sharedMediaPressed
{
    [self.navigationController pushViewController:[[TGSharedMediaController alloc] initWithPeerId:_conversationId accessHash:0 important:true] animated:true];
}

#pragma mark -

- (void)_updateNotificationItems:(bool)__unused animated
{
    [_muteExpirationTimer invalidate];
    _muteExpirationTimer = nil;
    
    bool enabled = false;
    int muteUntil = [_groupNotificationSettings[@"muteUntil"] intValue];
    if (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime]) {
        enabled = true;
    } else {
        int muteExpiration = muteUntil - (int)[[TGTelegramNetworking instance] approximateRemoteTime];
        if (muteExpiration >= 7 * 24 * 60 * 60) {
            
        } else {
            _muteExpirationTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(updateMuteExpiration) interval:2.0 repeat:true];
        }
    }
    
    _notificationsItem.isOn = enabled;
    
    int groupSoundId = [[_groupNotificationSettings objectForKey:@"soundId"] intValue];
    _soundItem.variant = [self soundNameFromId:groupSoundId];
}

- (void)updateMuteExpiration
{
    bool enabled = false;
    int muteUntil = [_groupNotificationSettings[@"muteUntil"] intValue];
    if (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime]) {
        enabled = true;
    }
    
    if (_notificationsItem.isOn != enabled) {
        _notificationsItem.isOn = enabled;
    }
}

- (void)_updateSharedMediaCount
{
    //_sharedMediaItem.variant = _sharedMediaCount == 0 ? TGLocalized(@"GroupInfo.SharedMediaNone") : ( TGIsLocaleArabic() ? [TGStringUtils stringWithLocalizedNumber:_sharedMediaCount] : [[NSString alloc] initWithFormat:@"%d", _sharedMediaCount]);
    _sharedMediaItem.variant = @"";
}

- (void)_loadUsersAndUpdateConversation:(TGConversation *)conversation
{
    NSMutableArray *participantUsers = [[NSMutableArray alloc] init];
    for (NSNumber *nUid in conversation.chatParticipants.chatParticipantUids)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:[nUid int32Value]];
        if (user != nil)
            [participantUsers addObject:user];
    }
    
    TGDispatchOnMainThread(^
    {
        if (_ignoreUpdates) {
            return;
        }
        
        for (NSNumber *nUid in _soonToBeAddedUserIds)
        {
            if (![conversation.chatParticipants.chatParticipantUids containsObject:nUid])
            {
                TGUser *user = [TGDatabaseInstance() loadUser:[nUid int32Value]];
                if (user != nil)
                    [participantUsers addObject:user];
            }
        }
        
        bool forceReload = false;
        
        if (_conversation.hasAdmins != conversation.hasAdmins) {
            forceReload = true;
        }
        
        if (!TGObjectCompare(_conversation.chatParticipants.chatAdminUids, conversation.chatParticipants.chatAdminUids)) {
            forceReload = true;
        }
        
        _conversation = conversation;
        [_groupInfoItem setConversation:_conversation];
        
        [self _updateLeftState];
        [self _updateConversationWithLoadedUsers:participantUsers forceReload:forceReload];
        
        [self resetSections];
    });
}

- (bool)showGroupUpgradeNotice {
    if (_conversation.isCreator) {
#ifdef INTERNAL_RELEASE
        //return _conversation.chatParticipantCount >= 2;
#endif
        
        if (_upgradeNoticeMemberLimit != 0) {
            return _conversation.chatParticipantCount >= _upgradeNoticeMemberLimit;
        }
    }
    return false;
}

- (void)_updateConversationWithLoadedUsers:(NSArray *)participantUsers forceReload:(bool)forceReload
{
    NSDictionary *invitedDates = _conversation.chatParticipants.chatInvitedDates;
    
    int32_t selfUid = TGTelegraphInstance.clientUserId;
    NSArray *sortedUsers = [participantUsers sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2)
    {
        if (user1.botKind != user2.botKind)
        {
            return user1.botKind < user2.botKind ? NSOrderedAscending : NSOrderedDescending;
        }
        
        if (user1.kind != user2.kind)
        {
            return user1.kind < user2.kind ? NSOrderedAscending : NSOrderedDescending;
        }
        
        if (user1.uid == selfUid)
            return NSOrderedAscending;
        else if (user2.uid == selfUid)
            return NSOrderedDescending;
        
        if (user1.presence.online != user2.presence.online)
            return user1.presence.online ? NSOrderedAscending : NSOrderedDescending;
        
        if ((user1.presence.lastSeen < 0) != (user2.presence.lastSeen < 0))
            return user1.presence.lastSeen >= 0 ? NSOrderedAscending : NSOrderedDescending;
        
        if (user1.presence.online)
        {
            NSNumber *nDate1 = invitedDates[[[NSNumber alloc] initWithInt:user1.uid]];
            NSNumber *nDate2 = invitedDates[[[NSNumber alloc] initWithInt:user2.uid]];
            
            if (nDate1 != nil && nDate2 != nil)
                return [nDate1 intValue] < [nDate2 intValue] ? NSOrderedAscending : NSOrderedDescending;
            else if (nDate1 != nil)
                return NSOrderedAscending;
            else if (nDate2 != nil)
                return NSOrderedDescending;
            else
                return user1.uid < user2.uid ? NSOrderedAscending : NSOrderedDescending;
        }
        
        if (user1.presence.lastSeen < 0)
        {
            NSNumber *nDate1 = invitedDates[[[NSNumber alloc] initWithInt:user1.uid]];
            NSNumber *nDate2 = invitedDates[[[NSNumber alloc] initWithInt:user2.uid]];
            
            if (nDate1 != nil && nDate2 != nil)
                return [nDate1 intValue] < [nDate2 intValue] ? NSOrderedAscending : NSOrderedDescending;
            else
                return user1.uid < user2.uid ? NSOrderedAscending : NSOrderedDescending;
        }
        
        return user1.presence.lastSeen > user2.presence.lastSeen ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    if ([self showGroupUpgradeNotice]) {
        [_usersSectionHeader setTitle:TGLocalized(@"Group.UpgradeNoticeHeader")];
        
        if ([_usersSection indexOfItem:_usersSectionUpgradeNotice1] == NSNotFound) {
            [_usersSection insertItem:_usersSectionUpgradeNotice1 atIndex:1];
            [_usersSection insertItem:_usersSectionUpgradeNotice2 atIndex:2];
            forceReload = true;
        }
        
        _addParticipantItem.title = TGLocalized(@"GroupInfo.UpgradeButton");
        _addParticipantItem.icon = [UIImage imageNamed:@"GroupInfoIconUpgrade"];

    } else {
        _addParticipantItem.title = TGLocalized(@"GroupInfo.AddParticipant");
        _addParticipantItem.icon = [UIImage imageNamed:@"ModernContactListAddMemberIcon.png"];
        
        if ([_usersSection indexOfItem:_usersSectionUpgradeNotice1] != NSNotFound) {
            [_usersSection deleteItem:_usersSectionUpgradeNotice1];
            [_usersSection deleteItem:_usersSectionUpgradeNotice2];
            forceReload = true;
        }
        
        NSString *title = [effectiveLocalization() getPluralized:@"GroupInfo.ParticipantCount" count:(int32_t)sortedUsers.count];
        [_usersSectionHeader setTitle:title];
    }
    
    NSUInteger sectionIndex = [self indexForSection:_usersSection];
    if (sectionIndex != NSNotFound)
    {
        bool haveChanges = false;
        
        NSInteger headButtonCount = 0;
        NSInteger tailButtonCount = 0;
        for (NSInteger i = 0; i < (NSInteger)_usersSection.items.count; i++) {
            if ([_usersSection.items[i] isKindOfClass:[TGGroupInfoUserCollectionItem class]]) {
                break;
            } else {
                headButtonCount++;
            }
        }

        if (_usersSection.items.count - headButtonCount - tailButtonCount != sortedUsers.count)
            haveChanges = true;
        else
        {
            for (int i = (int)headButtonCount, j = 0; i < (int)_usersSection.items.count - tailButtonCount; i++, j++)
            {
                TGGroupInfoUserCollectionItem *userItem = _usersSection.items[i];
                if ([_toBeUpdatedUserIds containsObject:@(userItem.user.uid)])
                {
                    haveChanges = true;
                    [_toBeUpdatedUserIds removeAllObjects];
                    break;
                }
                
                TGUser *user = sortedUsers[j];
                if (user.uid != userItem.user.uid)
                {
                    haveChanges = true;
                    break;
                }
            }
        }
        
        if (haveChanges || forceReload)
        {
            int count = (int)(_usersSection.items.count - headButtonCount - tailButtonCount);
            while (count > 0)
            {
                [self.menuSections deleteItemFromSection:sectionIndex atIndex:headButtonCount];
                count--;
            }
            
            NSInteger insertIndex = headButtonCount;
            for (TGUser *user in sortedUsers)
            {
                TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
                userItem.interfaceHandle = _actionHandle;
                
                bool disabled = ![_conversation.chatParticipants.chatParticipantUids containsObject:@(user.uid)] || [_soonToBeRemovedUserIds containsObject:@(user.uid)];
                userItem.selectable = user.uid != selfUid && !disabled;
                if (_conversation.chatParticipants.chatAdminId == user.uid || (_conversation.hasAdmins && [_conversation.chatParticipants.chatAdminUids containsObject:@(user.uid)])) {
                    userItem.customLabel = TGLocalized(@"GroupInfo.LabelAdmin");
                } else {
                    userItem.customLabel = nil;
                }
                
                bool canEditInPrinciple = false;
                if (user.uid != selfUid) {
                    canEditInPrinciple = ((_conversation.chatParticipants.chatAdminId == selfUid || [_conversation.chatParticipants.chatInvitedBy[@(user.uid)] int32Value] == selfUid));
                    if (!canEditInPrinciple) {
                        if (_conversation.isCreator) {
                            canEditInPrinciple = true;
                        } else if (_conversation.hasAdmins) {
                            canEditInPrinciple = _conversation.isAdmin && ![_conversation.chatParticipants.chatAdminUids containsObject:@(user.uid)] && _conversation.chatParticipants.chatAdminId != user.uid;
                        }
                    }
                }
                
                bool canEdit = userItem.selectable && canEditInPrinciple;
                [userItem setCanEdit:canEdit];
                userItem.canDelete = canEdit;
                
                [userItem setUser:user];
                [userItem setDisabled:disabled];
                
                [self.menuSections insertItem:userItem toSection:sectionIndex atIndex:insertIndex];
                insertIndex++;
            }
            
            /*self.collectionLayout.withoutAnimation = true;
            [UIView performWithoutAnimation:^
            {
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            self.collectionLayout.withoutAnimation = false;*/
            
            [self.collectionView reloadData];
            
            [self _updateAllowCellEditing:false];
        }
    }
}

- (void)_updateAllowCellEditing:(bool)animated
{
    bool anyCanEdit = false;
    int32_t selfUid = TGTelegraphInstance.clientUserId;
    
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
        {
            TGUser *user = ((TGGroupInfoUserCollectionItem *)item).user;
            
            bool canEditInPrinciple = false;
            if (user.uid != selfUid) {
                canEditInPrinciple = ((_conversation.chatParticipants.chatAdminId == selfUid || [_conversation.chatParticipants.chatInvitedBy[@(user.uid)] int32Value] == selfUid));
                if (!canEditInPrinciple) {
                    if (_conversation.isCreator) {
                        canEditInPrinciple = true;
                    } else if (_conversation.hasAdmins) {
                        canEditInPrinciple = _conversation.isAdmin && ![_conversation.chatParticipants.chatAdminUids containsObject:@(user.uid)] && _conversation.chatParticipants.chatAdminId != user.uid;
                    }
                }
            }
            
            anyCanEdit |= canEditInPrinciple;
        }
    }
    
    _haveEditableUsers = anyCanEdit;
    [self.collectionView setAllowEditingCells:anyCanEdit animated:animated];
}

- (void)_updateRelativeTimestamps
{
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
        {
            [(TGGroupInfoUserCollectionItem *)item updateTimestamp];
        }
    }
}

- (void)_updateUsers:(NSArray *)users
{
    bool updatedAnyUser = false;
    
    NSMutableDictionary *userIdToUser = [[NSMutableDictionary alloc] init];
    for (TGUser *user in users)
    {
        userIdToUser[@(user.uid)] = user;
    }
    
    NSMutableArray *participantUsers = [[NSMutableArray alloc] init];
    
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
        {
            TGGroupInfoUserCollectionItem *userItem = item;
            
            TGUser *user = userIdToUser[@(userItem.user.uid)];
            if (user != nil)
            {
                updatedAnyUser = true;
                [userItem setUser:user];
            }
            
            [participantUsers addObject:userItem.user];
        }
    }
    
    if (updatedAnyUser)
    {
        [self _updateConversationWithLoadedUsers:participantUsers forceReload:false];
    }
}

- (void)_layoutLeftLabel:(UIInterfaceOrientation)orientation
{
    if (_leftLabel != nil)
    {
        CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:orientation];
        CGSize labelSize = [_leftLabel sizeThatFits:CGSizeMake(screenSize.width - 10, screenSize.height)];
        _leftLabel.frame = CGRectMake(CGFloor((screenSize.width - labelSize.width) / 2.0f), CGFloor((screenSize.height - labelSize.height) / 2.0f), labelSize.width, labelSize.height);
    }
}

- (void)_updateLeftState
{
    if ((_conversation.kickedFromChat || _conversation.leftChat || _conversation.isDeactivated) != (_leftLabel != nil))
    {
        if (_conversation.kickedFromChat || _conversation.leftChat || _conversation.isDeactivated)
        {
            _leftLabel = [[UILabel alloc] init];
            _leftLabel.backgroundColor = [UIColor clearColor];
            _leftLabel.textColor = UIColorRGB(0x999999);
            if (_conversation.isDeactivated) {
                _leftLabel.text = TGLocalized(@"GroupInfo.DeactivatedStatus");
            } else {
                _leftLabel.text = _conversation.kickedFromChat ? TGLocalized(@"GroupInfo.KickedStatus") : TGLocalized(@"GroupInfo.LeftStatus");
            }
            _leftLabel.font = TGSystemFontOfSize(17.0f);
            _leftLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _leftLabel.numberOfLines = 0;
            [self.view addSubview:_leftLabel];
            
            [self _layoutLeftLabel:self.interfaceOrientation];
            
            [self setRightBarButtonItem:nil];
        }
        else
        {
            [_leftLabel removeFromSuperview];
            _leftLabel = nil;
            
            if (_editing)
            {
                [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)] animated:false];
            }
            else
            {
                [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:false];
            }
        }
    }
    
    self.collectionView.hidden = _conversation.kickedFromChat || _conversation.leftChat || _conversation.isDeactivated;
}

- (TGModernGalleryController *)createAvatarGalleryControllerForPreviewMode:(bool)previewMode
{
    TGRemoteImageView *avatarView = [_groupInfoItem avatarView];
    
    if (avatarView != nil && avatarView.image != nil)
    {
        TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
        modernGallery.previewMode = previewMode;
        if (previewMode)
            modernGallery.showInterface = false;
        
        modernGallery.model = [[TGGroupAvatarGalleryModel alloc] initWithPeerId:_conversationId accessHash:_conversation.accessHash messageId:0 legacyThumbnailUrl:_conversation.chatPhotoSmall legacyUrl:_conversation.chatPhotoBig imageSize:CGSizeMake(640.0f, 640.0f)];
        
        __weak TGGroupInfoController *weakSelf = self;
        __weak TGModernGalleryController *weakGallery = modernGallery;
        
        modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
        {
            __strong TGGroupInfoController *strongSelf = weakSelf;
            __strong TGModernGalleryController *strongGallery = weakGallery;
            if (strongSelf != nil)
            {
                if (strongGallery.previewMode)
                    return;
                
                if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
                {
                    ((UIView *)strongSelf->_groupInfoItem.avatarView).hidden = true;
                }
            }
        };
        
        modernGallery.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
        {
            __strong TGGroupInfoController *strongSelf = weakSelf;
            __strong TGModernGalleryController *strongGallery = weakGallery;
            if (strongSelf != nil)
            {
                if (strongGallery.previewMode)
                    return nil;
                
                if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
                {
                    return strongSelf->_groupInfoItem.avatarView;
                }
            }
            
            return nil;
        };
        
        modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
        {
            __strong TGGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
                {
                    return strongSelf->_groupInfoItem.avatarView;
                }
            }
            
            return nil;
        };
        
        modernGallery.completedTransitionOut = ^
        {
            __strong TGGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                ((UIView *)strongSelf->_groupInfoItem.avatarView).hidden = false;
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
    
    return nil;
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"deleteUser"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
            [self _commitDeleteParticipant:uid];
    }
    else if ([action isEqualToString:@"openUser"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:uid];
            if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
            {
                TGBotUserInfoController *userInfoController = [[TGBotUserInfoController alloc] initWithUid:uid sendCommand:nil];
                [self.navigationController pushViewController:userInfoController animated:true];
            }
            else
            {
                TGTelegraphUserInfoController *userInfoController = [[TGTelegraphUserInfoController alloc] initWithUid:uid];
                [self.navigationController pushViewController:userInfoController animated:true];
            }
        }
    }
    else if ([action isEqualToString:@"editedTitleChanged"])
    {
        NSString *title = options[@"title"];
        
        if (_editing)
            self.navigationItem.rightBarButtonItem.enabled = title.length != 0;
    }
    else if ([action isEqualToString:@"openAvatar"])
    {
        if (_conversation.chatPhotoSmall.length == 0)
        {
            if (_setGroupPhotoItem.enabled)
                [self setGroupPhotoPressed];
        }
        else
        {
            [self createAvatarGalleryControllerForPreviewMode:false];
        }
    }
    else if ([action isEqualToString:@"showUpdatingAvatarOptions"])
    {
        [[[TGActionSheet alloc] initWithTitle:nil actions:@[
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhotoStop") action:@"stop" type:TGActionSheetActionTypeDestructive],
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
        ] actionBlock:^(TGGroupInfoController *controller, NSString *action)
        {
            if ([action isEqualToString:@"stop"])
                [controller _commitCancelAvatarUpdate];
        } target:self] showInView:self.view];
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId]])
    {
        TGConversation *conversation = ((SGraphObjectNode *)resource).object;
        
        if (conversation != nil)
            [self _loadUsersAndUpdateConversation:conversation];
    }
    else if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    else if ([path isEqualToString:@"/as/updateRelativeTimestamps"])
    {
        TGDispatchOnMainThread(^
        {
            [self _updateRelativeTimestamps];
        });
    }
    else if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"])
    {
        NSArray *users = ((SGraphObjectNode *)resource).object;
        
        TGDispatchOnMainThread(^
        {
            [self _updateUsers:users];
        });
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/sharedMediaCount/(%" PRIx64 ")", (int64_t)_conversationId]])
    {
        TGDispatchOnMainThread(^
        {
            _sharedMediaCount = [resource intValue];
            [self _updateSharedMediaCount];
        });
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        if (status == ASStatusSuccess)
        {
            NSDictionary *notificationSettings = ((SGraphObjectNode *)result).object;
            
            TGDispatchOnMainThread(^
            {
                _groupNotificationSettings = [notificationSettings mutableCopy];
                [self _updateNotificationItems:false];
            });
        }
    }
    else if ([path hasPrefix:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/addMember/", _conversation.conversationId]])
    {
        TGDispatchOnMainThread(^
        {
            NSRange range = [path rangeOfString:@"/addMember/("];
            int32_t uid = (int32_t)[[path substringFromIndex:(range.location + range.length)] intValue];
            
            [_soonToBeAddedUserIds removeObject:@(uid)];
            [_toBeUpdatedUserIds addObject:@(uid)];
            
            if (status == ASStatusSuccess)
            {
                TGConversation *updatedConversation = [_conversation copy];
                updatedConversation.chatParticipants = [_conversation.chatParticipants copy];
                int32_t currentDate = (int32_t)[[TGTelegramNetworking instance] approximateRemoteTime];
                [updatedConversation.chatParticipants addParticipantWithId:uid invitedBy:TGTelegraphInstance.clientUserId date:currentDate];
                _conversation = updatedConversation;
                
                [self _updateLeftState];
                
                for (id item in _usersSection.items)
                {
                    if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]] && ((TGGroupInfoUserCollectionItem *)item).user.uid == uid)
                    {
                        [(TGGroupInfoUserCollectionItem *)item setDisabled:false];
                        [(TGGroupInfoUserCollectionItem *)item setCanEdit:true animated:true];
                        
                        break;
                    }
                }
            }
            else
            {
                [self _loadUsersAndUpdateConversation:_conversation];
                
                NSString *errorText = TGLocalized(@"ConversationProfile.UnknownAddMemberError");
                if (status == -2)
                {
                    TGUser *user = [TGDatabaseInstance() loadUser:uid];
                    if (user != nil)
                        errorText = [[NSString alloc] initWithFormat:TGLocalized(@"ConversationProfile.UserLeftChatError"), user.displayName];
                }
                else if (status == -3)
                {
                    errorText = TGLocalized(@"ConversationProfile.UsersTooMuchError");
                }
                else if (status == -4)
                    errorText = TGLocalized(@"GroupInfo.AddUserLeftError");
                else if (status == -5) {
                    NSString *format = TGLocalized(@"Privacy.GroupsAndChannels.InviteToGroupError");
                    TGUser *user = [TGDatabaseInstance() loadUser:uid];
                    errorText = [[NSString alloc] initWithFormat:format, user.displayFirstName, user.displayFirstName];
                }
                
                [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            }
        });
    }
    else if ([path hasPrefix:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/deleteMember/", _conversationId]])
    {
        NSRange range = [path rangeOfString:@"/deleteMember/("];
        int32_t uid = (int32_t)[[path substringFromIndex:(range.location + range.length)] intValue];
        
        TGDispatchOnMainThread(^
        {
            [_soonToBeRemovedUserIds removeObject:@(uid)];
            
            if (status == ASStatusSuccess)
            {
                TGConversation *updatedConversation = [_conversation copy];
                updatedConversation.chatParticipants = [_conversation.chatParticipants copy];
                [updatedConversation.chatParticipants removeParticipantWithId:uid];
                _conversation = updatedConversation;
                
                [self _updateLeftState];
                
                for (id item in _usersSection.items)
                {
                    if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]] && ((TGGroupInfoUserCollectionItem *)item).user.uid == uid)
                    {
                        NSIndexPath *indexPath = [self indexPathForItem:item];
                        if (indexPath != nil)
                        {
                            [self.menuSections beginRecordingChanges];
                            [self.menuSections deleteItemFromSection:indexPath.section atIndex:indexPath.item];
                            [self.menuSections commitRecordedChanges:self.collectionView];
                            
                            [self _updateAllowCellEditing:true];
                        }
                        
                        break;
                    }
                }
            }
            else
            {
                for (id item in _usersSection.items)
                {
                    if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]] && ((TGGroupInfoUserCollectionItem *)item).user.uid == uid)
                    {
                        [(TGGroupInfoUserCollectionItem *)item setDisabled:false];
                        
                        break;
                    }
                }
            }
        });
    }
    else if ([path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/changeTitle/", _conversation.conversationId]])
    {
        TGDispatchOnMainThread(^
        {
            [_groupInfoItem setUpdatingTitle:nil];
            
            if (status == ASStatusSuccess)
            {
                TGConversation *resultConversation = ((SGraphObjectNode *)result).object;
                
                TGConversation *updatedConversation = [_conversation copy];
                updatedConversation.chatTitle = resultConversation.chatTitle;
                _conversation = updatedConversation;
                
                [self _updateLeftState];
                
                [_groupInfoItem setConversation:_conversation];
            }
        });
    }
    else if ([path hasPrefix:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/", _conversation.conversationId]])
    {
        TGDispatchOnMainThread(^
        {
            if (status == ASStatusSuccess)
            {
                TGConversation *resultConversation = ((SGraphObjectNode *)result).object;
                
                TGConversation *updatedConversation = [_conversation copy];
                updatedConversation.chatPhotoSmall = resultConversation.chatPhotoSmall;
                updatedConversation.chatPhotoMedium = resultConversation.chatPhotoMedium;
                updatedConversation.chatPhotoBig = resultConversation.chatPhotoBig;
                _conversation = updatedConversation;
                
                [self _updateLeftState];
                
                [_groupInfoItem copyUpdatingAvatarToCacheWithUri:_conversation.chatPhotoSmall];
                [_groupInfoItem setConversation:_conversation];
                
                [_groupInfoItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
                [_setGroupPhotoItem setEnabled:true];
            }
            else
            {
                [_groupInfoItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
                [_setGroupPhotoItem setEnabled:true];
            }
        });
    }
}

- (void)chatAdminsPressed {
    TGGroupAdminsController *controller = [[TGGroupAdminsController alloc] initWithPeerId:_conversationId];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)convertGroupPressed {
    TGConvertToSupergroupController *controller = [[TGConvertToSupergroupController alloc] initWithConversation:_conversation];
    [self.navigationController pushViewController:controller animated:true];
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
            [self registerForPreviewingWithDelegate:(id)self sourceView:_groupInfoItem.avatarView];
        }
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)__unused location
{
    if (_conversation.chatPhotoSmall.length > 0)
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

@end
