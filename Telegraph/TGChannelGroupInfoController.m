#import "TGChannelGroupInfoController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGConversation.h"
#import "TGDatabase.h"

#import "TGHacks.h"
#import "TGFont.h"
#import "TGStringUtils.h"
#import "UIDevice+PlatformInfo.h"
#import "TGInterfaceAssets.h"

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

#import "TGUserInfoVariantCollectionItem.h"
#import "TGUserInfoTextCollectionItem.h"
#import "TGUserInfoUsernameCollectionItem.h"
#import "TGUserInfoButtonCollectionItem.h"

#import "TGSharedMediaController.h"

#import "TGTimerTarget.h"

#import "TGGroupManagementSignals.h"
#import "TGProgressWindow.h"

#import "TGGroupInfoShareLinkController.h"

#import "TGChannelLinkSetupController.h"
#import "TGChannelAboutSetupController.h"

#import "TGChannelManagementSignals.h"

#import "TGChannelMembersController.h"

#import "TGSelectContactController.h"

#import "TGCollectionMultilineInputItem.h"

#import "TGMediaAvatarMenuMixin.h"

#import "TGCollectionStaticMultilineTextItem.h"

#import "TGHashtagSearchController.h"

#import "TGSetupChannelAfterCreationController.h"

#import "TGShareMenu.h"
#import "TGSendMessageSignals.h"

#import "TGChannelBanController.h"

#import "TGLocalization.h"

#import "TGChannelModeratorController.h"

#import "TGSearchBar.h"
#import "TGSearchDisplayMixin.h"

#import "TGUser.h"

#import "TGContactCell.h"
#import "TGFont.h"

#import "TGDateUtils.h"

#import "TGChannelManagementSignals.h"
#import "TGGlobalMessageSearchSignals.h"

#import "TGTelegraph.h"

#import "TGImageUtils.h"

#import "TGCachedConversationData.h"

#import "TGGroupInfoUserCell.h"

static const NSUInteger keepCachedMemberCount = 200;
static const NSUInteger loadMoreMemberCount = 100;

static inline NSString *subtitleStringForUser(TGUser *user, bool *subtitleActive)
{
    NSString *subtitleText = @"";
    bool localSubtitleActive = false;
    
    if (user.uid > 0)
    {
        int lastSeen = user.presence.lastSeen;
        if (user.presence.online)
        {
            localSubtitleActive = true;
            subtitleText = TGLocalized(@"Presence.online");
        }
        else
            subtitleText = [TGDateUtils stringForRelativeLastSeen:lastSeen];
    }
    else
    {
        subtitleText = [user.customProperties objectForKey:@"label"];
    }
    
    *subtitleActive = localSubtitleActive;
    
    return subtitleText;
}

@interface TGChannelGroupInfoController () <TGGroupInfoSelectContactControllerDelegate, TGAlertSoundControllerDelegate, ASWatcher, TGSearchBarDelegate, TGSearchDisplayMixinDelegate, UITableViewDelegate, UITableViewDataSource>
{
    bool _editing;
    
    int64_t _peerId;
    TGConversation *_conversation;
    
    TGCollectionMenuSection *_groupInfoSection;
    
    TGGroupInfoCollectionItem *_groupInfoItem;
    TGButtonCollectionItem *_setGroupPhotoItem;
    
    TGCollectionMenuSection *_leaveSection;
    TGUserInfoButtonCollectionItem *_leaveItem;
    
    TGCollectionMenuSection *_adminInfoSection;
    TGVariantCollectionItem *_infoManagementItem;
    TGVariantCollectionItem *_infoBlacklistItem;
    
    TGCollectionMenuSection *_descriptionSection;
    TGCollectionStaticMultilineTextItem *_descriptionItem;
    
    TGCollectionMenuSection *_editDescriptionSection;
    TGVariantCollectionItem *_editGroupTypeItem;
    TGCollectionMultilineInputItem *_editDescriptionItem;
    
    TGCollectionMultilineInputItem *_linkItem;
    TGCollectionMenuSection *_linkSection;
    
    TGCollectionMenuSection *_deleteChannelSection;
    
    TGCollectionMenuSection *_notificationsAndMediaSection;
    TGSwitchCollectionItem *_notificationsItem;
    TGVariantCollectionItem *_soundItem;
    TGVariantCollectionItem *_sharedMediaItem;
    
    NSMutableDictionary *_groupNotificationSettings;
    
    NSTimer *_muteExpirationTimer;
    
    id<SDisposable> _completeInfoDisposable;
    id<SDisposable> _cachedDataDisposable;
    id<SDisposable> _cachedMembersDisposable;
    
    NSString *_privateLink;
    
    TGCollectionMenuSection *_usersSection;
    TGHeaderCollectionItem *_usersHeaderItem;
    TGButtonCollectionItem *_usersAddMemberItem;
    
    NSArray *_users;
    NSDictionary *_memberDatas;
    bool _sortUsersByPresence;
    
    SDisposableSet *_kickDisposables;
    SPipe *_loadMoreMembersPipe;
    
    bool _canLoadMore;
    bool _shouldLoadMore;
    
    TGMediaAvatarMenuMixin *_avatarMixin;
    
    bool _checked3dTouch;
    
    int32_t _bannedCount;
    int32_t _memberCount;
    
    UIBarButtonItem *_searchItem;
    
    UIView *_searchBarOverlay;
    UIBarButtonItem *_searchButtonItem;
    UIView *_searchReferenceView;
    UIView *_searchBarWrapper;
    TGSearchBar *_searchBar;
    TGSearchDisplayMixin *_searchMixin;
    
    SMetaDisposable *_searchDisposable;
    
    NSArray<NSArray<TGUser *> *> *_searchResultUsers;
    NSDictionary<NSNumber *, TGCachedConversationMember *> *_searchResultsMemberDatas;
    
    NSString *_searchString;
    
    NSArray *_reusableSectionHeaders;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGChannelGroupInfoController

- (instancetype)initWithPeerId:(int64_t)peerId
{
    self = [super init];
    if (self != nil)
    {
        __weak TGChannelGroupInfoController *weakSelf = self;
        
        _kickDisposables = [[SDisposableSet alloc] init];
        _searchDisposable = [[SMetaDisposable alloc] init];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _peerId = peerId;
        _groupNotificationSettings = [[NSMutableDictionary alloc] initWithDictionary:@{@"muteUntil": @(0), @"soundId": @(1)}];
        
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:_peerId];
        
        [self setTitleText:TGLocalized(@"GroupInfo.Title")];
        
        _searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchPressed)];
        
        _groupInfoItem = [[TGGroupInfoCollectionItem alloc] init];
        _groupInfoItem.interfaceHandle = _actionHandle;
        _groupInfoItem.isChannel = true;
        
        _setGroupPhotoItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.SetGroupPhoto") action:@selector(setGroupPhotoPressed)];
        _setGroupPhotoItem.titleColor = TGAccentColor();
        _setGroupPhotoItem.deselectAutomatically = true;
        
        _groupInfoSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
        _groupInfoSection.insets = UIEdgeInsetsMake(0.0f, 0.0f, 35.0f, 0.0f);
        
        TGHeaderCollectionItem *descriptionHeaderItem = [[TGHeaderCollectionItem alloc] initWithTitle:[TGLocalized(@"Channel.Info.Description") uppercaseString]];
        _descriptionItem = [[TGCollectionStaticMultilineTextItem alloc] init];
        _descriptionItem.deselectAutomatically = true;
        _descriptionItem.followLink = ^(NSString *link) {
            TGChannelGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf followLink:link];
            }
        };
        
        _descriptionSection = [[TGCollectionMenuSection alloc] initWithItems:@[descriptionHeaderItem, _descriptionItem]];
        
        _editGroupTypeItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.GroupType") action:@selector(editGroupTypePressed)];
        
        _editDescriptionItem = [[TGCollectionMultilineInputItem alloc] init];
        _editDescriptionItem.selectable = false;
        _editDescriptionItem.editable = true;
        _editDescriptionItem.placeholder = TGLocalized(@"Channel.About.Placeholder");
        _editDescriptionItem.textChanged = ^(__unused NSString *text) {
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf.collectionLayout invalidateLayout];
                [strongSelf.collectionView layoutSubviews];
            }
        };
        _editDescriptionItem.maxLength = 200;
        
        TGCommentCollectionItem *editDescriptionComment = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Group.About.Help")];
        
        _editDescriptionSection = [[TGCollectionMenuSection alloc] initWithItems:@[_editDescriptionItem, editDescriptionComment]];
        
        _linkItem = [[TGCollectionMultilineInputItem alloc] init];
        _linkItem.editable = false;
        _linkItem.deselectAutomatically = true;
        _linkItem.selected = ^{
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf sharePressed];
            }
        };
        _linkSection = [[TGCollectionMenuSection alloc] initWithItems:@[_linkItem]];
        
        _leaveItem = [[TGUserInfoButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.LeaveChannel") action:@selector(leavePressed)];
        _leaveItem.titleColor = TGDestructiveAccentColor();
        _leaveItem.deselectAutomatically = true;
        _leaveSection = [[TGCollectionMenuSection alloc] initWithItems:@[_leaveItem]];
        
        TGButtonCollectionItem *deleteChannelItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"ChannelInfo.DeleteChannel") action:@selector(deleteChannelPressed)];
        deleteChannelItem.titleColor = TGDestructiveAccentColor();
        deleteChannelItem.deselectAutomatically = true;
        _deleteChannelSection = [[TGCollectionMenuSection alloc] initWithItems:@[deleteChannelItem]];
        
        _infoManagementItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Info.Management") variant:@"" action:@selector(infoManagementPressed)];
        _infoBlacklistItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Info.BlackList") variant:@"" action:@selector(infoBlacklistPressed)];
        _adminInfoSection = [[TGCollectionMenuSection alloc] initWithItems:@[_infoManagementItem, _infoBlacklistItem]];
        
        _notificationsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Notifications") isOn:false];
        
        _notificationsItem.toggled = ^(bool value, __unused TGSwitchCollectionItem *item) {
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf _commitEnableNotifications:value orMuteFor:0];
            }
        };
        _soundItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.Sound") variant:nil action:@selector(soundPressed)];
        _soundItem.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        
        _sharedMediaItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.SharedMedia") variant:@"" action:@selector(sharedMediaPressed)];
        
        _notificationsAndMediaSection = [[TGCollectionMenuSection alloc] initWithItems:@[_notificationsItem, _sharedMediaItem]];
        UIEdgeInsets notificationsAndMediaSectionInsets = _notificationsAndMediaSection.insets;
        notificationsAndMediaSectionInsets.bottom = 18.0f;
        _notificationsAndMediaSection.insets = notificationsAndMediaSectionInsets;
        
        _usersHeaderItem = [[TGHeaderCollectionItem alloc] initWithTitle:@""];
        _usersAddMemberItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.AddParticipant") action:@selector(addMemberPressed)];
        _usersAddMemberItem.icon = [UIImage imageNamed:@"ModernContactListAddMemberIcon.png"];
        _usersAddMemberItem.iconOffset = CGPointMake(3.0f, 0.0f);
        _usersAddMemberItem.leftInset = 65.0f;
        
        _usersSection = [[TGCollectionMenuSection alloc] initWithItems:@[_usersHeaderItem, _usersAddMemberItem]];
        
        [self _setConversation:conversation];
        
        [self _updateNotificationItems:false];
        
        int64_t accessHash = _conversation.accessHash;
        [ActionStageInstance() dispatchOnStageQueue:^
         {
             [ActionStageInstance() watchForPaths:@[
                                                    [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _peerId],
                                                    @"/tg/userdatachanges",
                                                    @"/tg/userpresencechanges",
                                                    @"/as/updateRelativeTimestamps",
                                                    ] watcher:self];
             
             [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId64 ")", _peerId] watcher:self];
             [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId64 ",cachedOnly)", _peerId] options:@{@"peerId": @(_peerId), @"accessHash": @(accessHash)} watcher:self];
             
             NSArray *changeTitleActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/conversation/@/changeTitle/@" prefix:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")", _peerId] watcher:self];
             NSArray *changeAvatarActions = [ActionStageInstance() rejoinActionsWithGenericPathNow:@"/tg/conversation/@/updateAvatar/@" prefix:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")", _peerId] watcher:self];
             
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
             
             if (changeTitleActions.count != 0 || changeAvatarActions.count != 0)
             {
                 TGDispatchOnMainThread(^ {
                     [_groupInfoItem setUpdatingTitle:updatingTitle];
                     
                     [_groupInfoItem setUpdatingAvatar:updatingAvatar hasUpdatingAvatar:haveUpdatingAvatar];
                     [_setGroupPhotoItem setEnabled:!haveUpdatingAvatar];
                     
                     [self _setConversation:_conversation];
                 });
             }
         }];
        
        _completeInfoDisposable = [[TGChannelManagementSignals updateChannelExtendedInfo:_conversation.conversationId accessHash:_conversation.accessHash updateUnread:true] startWithNext:nil];
        
        _cachedDataDisposable = [[[TGDatabaseInstance() channelCachedData:_conversation.conversationId] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedConversationData *cachedData) {
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil && cachedData != nil) {
                [strongSelf->_infoManagementItem setVariant:[[NSString alloc] initWithFormat:@"%d", cachedData.managementCount]];
                [strongSelf->_infoBlacklistItem setVariant:[[NSString alloc] initWithFormat:@"%d", cachedData.blacklistCount + cachedData.bannedCount]];
                strongSelf->_privateLink = cachedData.privateLink;
                
                [strongSelf->_usersHeaderItem setTitle:[strongSelf titleStringForMemberCount:cachedData.memberCount]];
                
                strongSelf->_memberCount = cachedData.memberCount;
                
                bool sortUsersByPresence = cachedData.memberCount != 0 && cachedData.memberCount <= 200;
                if (strongSelf->_sortUsersByPresence != sortUsersByPresence) {
                    strongSelf->_sortUsersByPresence = sortUsersByPresence;
                    [strongSelf _setUsers:strongSelf->_users memberDatas:strongSelf->_memberDatas];
                } else {
                    NSMutableDictionary *memberDatas = [[NSMutableDictionary alloc] init];
                    for (TGCachedConversationMember *member in cachedData.generalMembers) {
                        memberDatas[@(member.uid)] = member;
                    }
                    [strongSelf _updateMemberDatas:memberDatas];
                }
                
                if (strongSelf->_bannedCount != cachedData.bannedCount) {
                    strongSelf->_bannedCount = cachedData.bannedCount;
                    //[strongSelf _setupSections:strongSelf->_editing];
                }
            }
        }];
        
        SSignal *updatedMembersSignal = [[[[TGDatabaseInstance() channelCachedData:_conversation.conversationId] deliverOn:[SQueue mainQueue]] mapToSignal:^SSignal *(TGCachedConversationData *cachedData) {
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                bool sortUsersByPresence = cachedData.memberCount != 0 && cachedData.memberCount <= 200;
                if (strongSelf->_sortUsersByPresence != sortUsersByPresence) {
                    strongSelf->_sortUsersByPresence = sortUsersByPresence;
                    [strongSelf _setUsers:strongSelf->_users memberDatas:strongSelf->_memberDatas];
                }
                
                NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
                
                NSMutableArray *users = [[NSMutableArray alloc] init];
                for (TGCachedConversationMember *member in cachedData.generalMembers) {
                    TGUser *user = [TGDatabaseInstance() loadUser:member.uid];
                    if (user != nil) {
                        [users addObject:user];
                    }
                }
                
                bool updated = false;
                if (updatedUsers.count >= users.count) {
                    for (NSUInteger i = 0; i < users.count; i++) {
                        TGUser *user1 = users[i];
                        TGUser *user2 = updatedUsers[i];
                        if (user1.uid != user2.uid) {
                            updated = true;
                            break;
                        }
                    }
                } else {
                    updated = true;
                }
                
                if (updated) {
                    return [SSignal single:cachedData];
                }
            }
            
            return [SSignal single:nil];
        }] filter:^bool(id next) {
            return next != nil;
        }];
        
        SSignal *cachedMembersSignal = [[[[TGDatabaseInstance() channelCachedData:_conversation.conversationId] take:1] then:updatedMembersSignal] mapToSignal:^SSignal *(TGCachedConversationData *cachedData) {
            NSMutableArray *users = [[NSMutableArray alloc] init];
            NSMutableDictionary *memberDatas = [[NSMutableDictionary alloc] init];
            for (TGCachedConversationMember *member in cachedData.generalMembers) {
                TGUser *user = [TGDatabaseInstance() loadUser:member.uid];
                if (user != nil) {
                    [users addObject:user];
                    memberDatas[@(member.uid)] = member;
                }
            }
            return [SSignal single:@{@"users": users, @"memberDatas": memberDatas, @"count": @(cachedData.memberCount)}];
        }];
        
        _loadMoreMembersPipe = [[SPipe alloc] init];
        SSignal *loadMoreMembersSignal = [SSignal defer:^SSignal *{
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_canLoadMore = true;
            }
            
            return [[[_loadMoreMembersPipe.signalProducer() mapToSignal:^SSignal *(__unused id next) {
                return [[SSignal defer:^SSignal *{
                    __strong TGChannelGroupInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        return [[TGChannelManagementSignals channelMembers:conversation.conversationId accessHash:conversation.accessHash offset:strongSelf->_users.count count:loadMoreMemberCount] mapToSignal:^SSignal *(NSDictionary *dict) {
                            return [[SSignal defer:^SSignal *{
                                __strong TGChannelGroupInfoController *strongSelf = weakSelf;
                                if (strongSelf != nil) {
                                    NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
                                    NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
                                    
                                    NSDictionary *memberDatas = dict[@"memberDatas"];
                                    for (TGUser *user in dict[@"users"]) {
                                        if (updatedMemberDatas[@(user.uid)] == nil) {
                                            TGCachedConversationMember *member = memberDatas[@(user.uid)];
                                            if (member != nil) {
                                                updatedMemberDatas[@(user.uid)] = member;
                                                [updatedUsers addObject:user];
                                            }
                                        }
                                    }
                                    
                                    return [SSignal single:@{@"users": updatedUsers, @"memberDatas": updatedMemberDatas, @"count": @([dict[@"count"] intValue]), @"canLoadMore": @([memberDatas count] != 0)}];
                                }
                                
                                return [SSignal single:@[]];
                            }] startOn:[SQueue mainQueue]];
                        }];
                    }
                    
                    return [SSignal single:@{}];
                }] startOn:[SQueue mainQueue]];
            }] startOn:[SQueue mainQueue]] onNext:^(NSDictionary *dict) {
                TGDispatchOnMainThread(^{
                    __strong TGChannelGroupInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        strongSelf->_canLoadMore = [dict[@"canLoadMore"] boolValue];
                        if (strongSelf->_canLoadMore) {
                            [strongSelf loadMoreIfNeeded];
                        }
                    }
                });
            }];
        }];
        
        SSignal *membersSignal = [cachedMembersSignal mapToSignal:^SSignal *(NSDictionary *dict) {
            return [[[SSignal single:dict] then:[[TGChannelManagementSignals channelMembers:conversation.conversationId accessHash:conversation.accessHash offset:0 count:keepCachedMemberCount] onNext:^(NSDictionary *dict) {
                [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                    if (data == nil) {
                        data = [[TGCachedConversationData alloc] init];
                    }
                    
                    NSMutableArray *sortedMemberDatas = [[NSMutableArray alloc] init];
                    NSDictionary *memberDatas = dict[@"memberDatas"];
                    for (TGUser *user in dict[@"users"]) {
                        TGCachedConversationMember *member = memberDatas[@(user.uid)];
                        if (member != nil) {
                            [sortedMemberDatas addObject:member];
                        }
                    }
                    
                    return [data updateGeneralMembers:sortedMemberDatas];
                }];
            }]] then:loadMoreMembersSignal];
        }];
        
        _cachedMembersDisposable = [[membersSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict) {
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf->_usersHeaderItem setTitle:[strongSelf titleStringForMemberCount:[dict[@"count"] intValue]]];
                
                NSInteger memberCount = [dict[@"count"] integerValue];
                
                bool sortUsersByPresence = memberCount != 0 && memberCount <= 200;
                if (strongSelf->_sortUsersByPresence != sortUsersByPresence) {
                    strongSelf->_sortUsersByPresence = sortUsersByPresence;
                }
                [strongSelf _setUsers:dict[@"users"] memberDatas:dict[@"memberDatas"]];
            }
        }];
        
        [self _setupSections:false];
    }
    return self;
}

- (NSString *)titleStringForMemberCount:(NSUInteger)count {
    return [effectiveLocalization() getPluralized:@"GroupInfo.ParticipantCount" count:(int32_t)count];
}

- (void)_setupSections:(bool)editing {
    while (self.menuSections.sections.count != 0) {
        [self.menuSections deleteSection:0];
    }
    
    _groupInfoSection.insets = UIEdgeInsetsMake(0.0f, 0.0f, 35.0f, 0.0f);
    
    if (editing) {
        if ([self canEditChannel] && (_conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.canChangeInfo)) {
            [_groupInfoSection replaceItems:@[_groupInfoItem, _setGroupPhotoItem]];
        } else {
            [_groupInfoSection replaceItems:@[_groupInfoItem]];
        }
        
        [self.menuSections addSection:_groupInfoSection];
        
        while (_editDescriptionSection.items.count != 0) {
            [_editDescriptionSection deleteItemAtIndex:0];
        }
        
        if (_conversation.channelRole == TGChannelRoleCreator) {
            [_editDescriptionSection addItem:_editGroupTypeItem];
        }
        
        if (_conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.canChangeInfo) {
            [_editDescriptionSection addItem:_editDescriptionItem];
            TGCommentCollectionItem *editDescriptionComment = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Group.About.Help")];
            [_editDescriptionSection addItem:editDescriptionComment];
        }
        
        if (_editDescriptionSection.items.count != 0) {
            [self.menuSections addSection:_editDescriptionSection];
        }
        
        while (_notificationsAndMediaSection.items.count != 0) {
            [_notificationsAndMediaSection deleteItemAtIndex:0];
        }
        
        [_notificationsAndMediaSection addItem:_notificationsItem];
        [_notificationsAndMediaSection addItem:_soundItem];
        
        {
            UIEdgeInsets previousInsets = ((TGCollectionMenuSection *)self.menuSections.sections.lastObject).insets;
            
            UIEdgeInsets notificationsAndMediaSectionInsets = _notificationsAndMediaSection.insets;
            if (previousInsets.bottom < 16.0f) {
                notificationsAndMediaSectionInsets.top = 16.0f - previousInsets.bottom;
            }
            notificationsAndMediaSectionInsets.bottom = 32.0f;
            _notificationsAndMediaSection.insets = notificationsAndMediaSectionInsets;
            
            [self.menuSections addSection:_notificationsAndMediaSection];
        }
        
        while (_adminInfoSection.items.count != 0) {
            [_adminInfoSection deleteItemAtIndex:0];
        }
        
        if (_conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.hasAnyRights) {
            [_adminInfoSection addItem:_infoManagementItem];
            [_adminInfoSection addItem:_infoBlacklistItem];
        }
        
        if (_adminInfoSection.items.count != 0) {
            [self.menuSections addSection:_adminInfoSection];
        }
        
        self.collectionView.backgroundColor = [TGInterfaceAssets listsBackgroundColor];
    } else {
        [_groupInfoSection replaceItems:@[_groupInfoItem]];
        
        [self.menuSections addSection:_groupInfoSection];
        
        if (_descriptionItem.text.length != 0 || _conversation.username.length != 0) {
            _groupInfoSection.insets = UIEdgeInsetsMake(0.0f, 0.0f, 18.0f, 0.0f);
        }
        
        if (_descriptionItem.text.length != 0) {
            [self.menuSections addSection:_descriptionSection];
        }
        
        if (_conversation.username.length != 0) {
            UIEdgeInsets linkSectionInsets = _linkSection.insets;
            if (_descriptionItem.text.length != 0) {
                linkSectionInsets.top = 0.0;                
            } else {
                linkSectionInsets.top = 17.0;
            }
            _linkSection.insets = linkSectionInsets;
            [self.menuSections addSection:_linkSection];
        }
        
        while (_notificationsAndMediaSection.items.count != 0) {
            [_notificationsAndMediaSection deleteItemAtIndex:0];
        }
        
        [_notificationsAndMediaSection addItem:_notificationsItem];
        [_notificationsAndMediaSection addItem:_sharedMediaItem];
        
        {
            UIEdgeInsets previousInsets = ((TGCollectionMenuSection *)self.menuSections.sections.lastObject).insets;
            
            UIEdgeInsets notificationsAndMediaSectionInsets = _notificationsAndMediaSection.insets;
            if (previousInsets.bottom < 16.0f) {
                notificationsAndMediaSectionInsets.top = 16.0f - previousInsets.bottom;
            }
            notificationsAndMediaSectionInsets.bottom = 18.0f;
            _notificationsAndMediaSection.insets = notificationsAndMediaSectionInsets;
            
            [self.menuSections addSection:_notificationsAndMediaSection];
        }
        
        /*if (_conversation.kind == TGConversationKindPersistentChannel && _conversation.channelRole != TGChannelRoleCreator) {
            [self.menuSections addSection:_leaveSection];
        }*/
    }
    
    if ([self canInviteToChannel]) {
        if ([_usersSection indexOfItem:_usersAddMemberItem] == NSNotFound) {
            [_usersSection insertItem:_usersAddMemberItem atIndex:1];
        }
    } else {
        [_usersSection deleteItem:_usersAddMemberItem];
    }
    
    [self.menuSections addSection:_usersSection];
    
    if (!_editing && ![self.navigationItem.rightBarButtonItem.title isEqualToString:TGLocalized(@"Common.Edit")]) {
        [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)], _searchItem] animated:false];
    }
    
    [self.collectionView reloadData];
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [_completeInfoDisposable dispose];
    [_cachedDataDisposable dispose];
    [_kickDisposables dispose];
}

#pragma mark -

- (void)_resetCollectionView
{
    [super _resetCollectionView];
    
    self.collectionView.backgroundColor = self.view.backgroundColor;
    [self.collectionView setAllowEditingCells:true animated:false];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self check3DTouch];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (_searchMixin != nil) {
        [_searchMixin controllerLayoutUpdated:[TGViewController screenSizeForInterfaceOrientation:toInterfaceOrientation]];
    }
}

#pragma mark -

- (void)editPressed
{
    if (!_editing)
    {
        _editing = true;
        
        if (_conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.canChangeInfo) {
            [_groupInfoItem setEditing:true animated:false];
        }
        [self _setupSections:true];
        [self enterEditingMode:false];
        
        [self animateCollectionCrossfade];
    }
}

- (void)donePressed
{
    if (_editing)
    {
        _editing = false;
        
        NSMutableArray *applySignals = [[NSMutableArray alloc] init];
        
        if (!TGStringCompare(_editDescriptionItem.text, _conversation.about)) {
            SSignal *signal = [TGChannelManagementSignals updateChannelAbout:_conversation.conversationId accessHash:_conversation.accessHash about:_editDescriptionItem.text];
            [applySignals addObject:signal];
        }
        
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow showWithDelay:0.2];
        [[[[[SSignal combineSignals:applySignals] timeout:5.0 onQueue:[SQueue mainQueue] orSignal:[SSignal fail:@"timeout"]] deliverOn:[SQueue mainQueue]] onDispose:^{
            [progressWindow dismiss:true];
        }] startWithNext:nil error:^(__unused id error) {
            
        } completed:^{
            if (!TGStringCompare(_conversation.chatTitle, [_groupInfoItem editingTitle]) && [_groupInfoItem editingTitle] != nil)
                [self _commitUpdateTitle:[_groupInfoItem editingTitle]];
            
            [_groupInfoItem setEditing:false animated:false];
            [self _setupSections:false];
            [self leaveEditingMode:false];
            
            [self animateCollectionCrossfade];
        }];
    }
    
    [self leaveEditingMode:true];
}

- (void)didEnterEditingMode:(bool)animated
{
    [super didEnterEditingMode:animated];
    
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]] animated:true];
}

- (void)didLeaveEditingMode:(bool)animated
{
    [super didLeaveEditingMode:animated];
    
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)], _searchItem] animated:animated];
}

- (bool)canEditChannel {
    return _conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.hasAnyRights;
}

- (bool)canInviteToChannel {
    return (_conversation.everybodyCanAddMembers || _conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.canInviteUsers) && !_conversation.channelBannedRights.banSendMessages;
}

- (bool)canKickMembers {
    return _conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.canBanUsers;
}

- (void)setGroupPhotoPressed
{
    if (![self canEditChannel])
        return;
    
    __weak TGChannelGroupInfoController *weakSelf = self;
    _avatarMixin = [[TGMediaAvatarMenuMixin alloc] initWithParentController:self hasDeleteButton:(_conversation.chatPhotoSmall.length != 0)];
    _avatarMixin.didFinishWithImage = ^(UIImage *image)
    {
        __strong TGChannelGroupInfoController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _updateGroupProfileImage:image];
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.didFinishWithDelete = ^
    {
        __strong TGChannelGroupInfoController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _commitDeleteAvatar];
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.didDismiss = ^
    {
        __strong TGChannelGroupInfoController *strongSelf = weakSelf;
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
    uploadOptions[@"accessHash"] = @(_conversation.accessHash);
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         static int actionId = 0;
         [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(updateAvatar%d)", _peerId, actionId] options:uploadOptions watcher:self];
         [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(updateAvatar%d)", _peerId, actionId++] options:uploadOptions watcher:TGTelegraphInstance];
     }];
}

- (void)_commitDeleteAvatar
{
    [_groupInfoItem setUpdatingAvatar:nil hasUpdatingAvatar:true];
    [_setGroupPhotoItem setEnabled:false];
    
    NSMutableDictionary *uploadOptions = [[NSMutableDictionary alloc] init];
    [uploadOptions setObject:[NSNumber numberWithLongLong:_conversation.conversationId] forKey:@"conversationId"];
    uploadOptions[@"accessHash"] = @(_conversation.accessHash);
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         static int actionId = 0;
         [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(deleteAvatar%d)", _peerId, actionId] options:uploadOptions watcher:self];
         [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%" PRId64 ")/updateAvatar/(deleteAvatar%d)", _peerId, actionId++] options:uploadOptions watcher:TGTelegraphInstance];
     }];
}

- (void)_commitCancelAvatarUpdate
{
    [_groupInfoItem setUpdatingAvatar:nil hasUpdatingAvatar:false];
    [_setGroupPhotoItem setEnabled:true];
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         NSArray *actors = [ActionStageInstance() executingActorsWithPathPrefix:[NSString stringWithFormat:@"/tg/conversation/(%lld)/updateAvatar/", _peerId]];
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
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGChannelGroupInfoController *controller, NSString *action)
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
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(userInfoControllerMute%d)", _peerId, actionId++] options:@{@"peerId": @(_peerId), @"accessHash": @(_conversation.accessHash), @"muteUntil": @(muteUntil)} watcher:TGTelegraphInstance];
        [self _updateNotificationItems:false];
    }
}
- (void)_commitUpdateTitle:(NSString *)title
{
    [_groupInfoItem setUpdatingTitle:title];
    
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         static int actionId = 0;
         NSString *path = [[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/changeTitle/(groupInfoController%d)", _conversation.conversationId, actionId++];
         NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:@{@"conversationId": @(_peerId), @"title": title == nil ? @"" : title}];
         options[@"accessHash"] = @(_conversation.accessHash);
         
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
              TGChannelGroupInfoController *strongSelf = weakSelf;
              [strongSelf _commitLeaveGroup];
          }
      } target:self] showInView:self.view];
}

- (void)_commitLeaveGroup
{
    [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_peerId unreadCount:0 serviceUnreadCount:0] animated:false];
    
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
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(groupInfoController%d)", _conversation.conversationId, actionId++] options:@{@"peerId": @(_peerId), @"accessHash": @(_conversation.accessHash), @"muteUntil": @(!enableNotifications ? INT_MAX : 0)} watcher:TGTelegraphInstance];
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
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(groupInfoController%d)", _peerId, actionId++] options:@{@"peerId": @(_peerId), @"accessHash": @(_conversation.accessHash), @"soundId": @(soundId)} watcher:TGTelegraphInstance];
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

#pragma mark -

- (void)_updateNotificationItems:(bool)__unused animated
{
    [_muteExpirationTimer invalidate];
    _muteExpirationTimer = nil;
    
    int muteUntil = [_groupNotificationSettings[@"muteUntil"] intValue];
    bool enabled = false;
    if (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime]) {
        enabled = true;
    }
    else
    {
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
    int muteUntil = [_groupNotificationSettings[@"muteUntil"] intValue];
    bool enabled = false;
    if (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime]) {
        enabled = true;
    } else {
        enabled = false;
    }
    
    if (_notificationsItem.isOn != enabled) {
        _notificationsItem.isOn = enabled;
    }
}

- (void)_setConversation:(TGConversation *)conversation
{
    TGDispatchOnMainThread(^
    {
        bool reloadData = false;
        
        if (_conversation.channelRole != conversation.channelRole) {
            reloadData = true;
        }
        
        _conversation = conversation;
        
        if (!TGStringCompare(_conversation.about, _descriptionItem.text)) {
            _descriptionItem.text = _conversation.about;
            reloadData = true;
        }
        
        if (!_editing) {
            _editDescriptionItem.text = _conversation.about;
        }
        
        NSString *linkText = @"";
        if (_conversation.username.length != 0) {
            linkText = [@"https://t.me/" stringByAppendingString:_conversation.username];
        }
        if (!TGStringCompare(linkText, _linkItem.text)) {
            _linkItem.text = linkText;
            if (!_editing) {
                reloadData = true;
            }
        }
        
        _editGroupTypeItem.variant = _conversation.username.length == 0 ? TGLocalized(@"Channel.Setup.TypePrivate") : TGLocalized(@"Channel.Setup.TypePublic");
        
        [_groupInfoItem setConversation:_conversation];
        
        if (reloadData) {
            [self _setupSections:_editing];
        }
    });
}

- (NSArray *)sortedUsers:(NSArray *)users {
    if (_sortUsersByPresence) {
        int32_t selfUid = TGTelegraphInstance.clientUserId;
        return [users sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2) {
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
                return user1.uid < user2.uid ? NSOrderedAscending : NSOrderedDescending;
            }
            
            if (user1.presence.lastSeen < 0)
            {
                return user1.uid < user2.uid ? NSOrderedAscending : NSOrderedDescending;
            }
            
            return user1.presence.lastSeen > user2.presence.lastSeen ? NSOrderedAscending : NSOrderedDescending;
        }];
    } else {
        return users;
    }
}

- (void)_setUsers:(NSArray *)filteredUsers memberDatas:(NSDictionary *)memberDatas {
    _users = filteredUsers;
    _memberDatas = memberDatas;
    
    NSInteger headButtonCount = 0;
    for (NSInteger i = 0; i < (NSInteger)_usersSection.items.count; i++) {
        id item = _usersSection.items[i];
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]]) {
            break;
        } else {
            headButtonCount++;
        }
    }
    
    NSMutableSet *currentUserIds = [[NSMutableSet alloc] init];
    for (id item in _usersSection.items) {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]]) {
            [currentUserIds addObject:@(((TGGroupInfoUserCollectionItem *)item).user.uid)];
        }
    }
    
    NSMutableSet *updatedUserIds = [[NSMutableSet alloc] init];
    for (TGUser *user in filteredUsers) {
        [updatedUserIds addObject:@(user.uid)];
    }
    
    if ([currentUserIds isEqualToSet:updatedUserIds]) {
        NSArray *sortedUsers = [self sortedUsers:filteredUsers];
        //NSUInteger sectionIndex = [self indexForSection:_usersSection];
        NSInteger index = -1 + headButtonCount;
        bool hadUpdates = false;
        for (TGUser *user in sortedUsers) {
            index++;
            
            for (NSInteger currentIndex = headButtonCount; currentIndex < (NSInteger)_usersSection.items.count; currentIndex++) {
                TGGroupInfoUserCollectionItem *userItem = _usersSection.items[currentIndex];
                
                if (userItem.user.uid == user.uid) {
                    if (userItem.user != nil) {
                        TGCachedConversationMember *member = memberDatas[@(userItem.user.uid)];
                        if (member != nil && member.adminRights.hasAnyRights) {
                            userItem.customLabel = TGLocalized(@"GroupInfo.LabelAdmin");
                        } else {
                            userItem.customLabel = nil;
                        }
                        
                        userItem.user = user;
                    }
                    
                    if (currentIndex != index) {
                        [_usersSection deleteItemAtIndex:currentIndex];
                        [_usersSection insertItem:userItem atIndex:index];
                        hadUpdates = true;
                        
                        /*[self.collectionView layoutSubviews];
                        [UIView performWithoutAnimation:^{
                            [self.collectionView performBatchUpdates:^{
                                [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:sectionIndex] toIndexPath:[NSIndexPath indexPathForItem:index inSection:sectionIndex]];
                            } completion:nil];
                        }];*/
                    }
                    
                    break;
                }
            }
        }
        if (hadUpdates) {
            [self.collectionView reloadData];
            [self.collectionView setNeedsLayout];
            [self.collectionView layoutSubviews];
        }
        
        [self updateItemPositions];
    } else {
        while ((NSInteger)_usersSection.items.count != headButtonCount) {
            [_usersSection deleteItemAtIndex:_usersSection.items.count - 1];
        }
        
        NSArray *sortedUsers = [self sortedUsers:filteredUsers];
        
        for (TGUser *user in sortedUsers) {
            TGGroupInfoUserCollectionItem *userItem = [self makeItemForUser:user member:_memberDatas[@(user.uid)]];
            
            [_usersSection addItem:userItem];
        }
        
        [self.collectionView reloadData];
    }
}

- (void)_updateMemberDatas:(NSDictionary *)memberDatas {
    NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:_memberDatas];
    [memberDatas enumerateKeysAndObjectsUsingBlock:^(NSNumber *nUid, TGCachedConversationMember *member, __unused BOOL *stop) {
        if (updatedMemberDatas[nUid] != nil) {
            updatedMemberDatas[nUid] = member;
        }
    }];
    _memberDatas = updatedMemberDatas;
    
    NSInteger headButtonCount = 0;
    for (NSInteger i = 0; i < (NSInteger)_usersSection.items.count; i++) {
        id item = _usersSection.items[i];
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]]) {
            break;
        } else {
            headButtonCount++;
        }
    }
    
    for (NSInteger currentIndex = headButtonCount; currentIndex < (NSInteger)_usersSection.items.count; currentIndex++) {
        TGGroupInfoUserCollectionItem *userItem = _usersSection.items[currentIndex];
        
        if (userItem.user != nil) {
            TGCachedConversationMember *member = _memberDatas[@(userItem.user.uid)];
            if (member != nil && (member.isCreator || member.adminRights.hasAnyRights)) {
                userItem.customLabel = TGLocalized(@"GroupInfo.LabelAdmin");
            } else {
                userItem.customLabel = nil;
            }
            
            bool canEdit = false;
            if ([self canKickMembers] && userItem.user.uid != TGTelegraphInstance.clientUserId) {
                if (_conversation.channelRole == TGChannelRoleCreator) {
                    canEdit = true;
                } else {
                    canEdit = !member.adminRights.hasAnyRights;
                }
            }
            [userItem setCanEdit:canEdit];
        }
    }
}

- (void)_updateRelativeTimestamps
{
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
        
        modernGallery.model = [[TGGroupAvatarGalleryModel alloc] initWithPeerId:_conversation.conversationId accessHash:_conversation.accessHash messageId:0 legacyThumbnailUrl:_conversation.chatPhotoSmall legacyUrl:_conversation.chatPhotoBig imageSize:CGSizeMake(640.0f, 640.0f)];
        
        __weak TGChannelGroupInfoController *weakSelf = self;
        __weak TGModernGalleryController *weakGallery = modernGallery;
        
        modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
        {
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
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
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
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
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
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
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
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
    if ([action isEqualToString:@"openUser"])
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
    else if ([action isEqualToString:@"deleteUser"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
            [self _commitDeleteParticipant:uid tryRestrict:false];
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
                                                            ] actionBlock:^(TGChannelGroupInfoController *controller, NSString *action)
          {
              if ([action isEqualToString:@"stop"])
                  [controller _commitCancelAvatarUpdate];
          } target:self] showInView:self.view];
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _peerId]])
    {
        TGConversation *conversation = ((SGraphObjectNode *)resource).object;
        
        if (conversation != nil) {
            [self _setConversation:conversation];
        }
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
            NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:_users];
            NSMutableDictionary *userIdToIndex = [[NSMutableDictionary alloc] init];
            NSUInteger index = 0;
            for (TGUser *user in updatedUsers) {
                userIdToIndex[@(user.uid)] = @(index);
                index++;
            }
            
            bool hadUpdates = false;
            for (TGUser *user in users) {
                NSNumber *nIndex = userIdToIndex[@(user.uid)];
                if (nIndex != nil) {
                    updatedUsers[[nIndex intValue]] = user;
                    hadUpdates = true;
                }
            }
            if (hadUpdates) {
                [self _setUsers:updatedUsers memberDatas:_memberDatas];
            }
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

- (void)aboutPressed {
    if ([self canInviteToChannel]) {
        TGChannelAboutSetupController *aboutController = [[TGChannelAboutSetupController alloc] initWithConversation:_conversation];
        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[aboutController]];
        [self presentViewController:navigationController animated:true completion:nil];
    }
}

- (void)linkPressed {
    TGChannelLinkSetupController *linkController = [[TGChannelLinkSetupController alloc] initWithConversation:_conversation];
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[linkController]];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)sharePressed
{
    __weak TGChannelGroupInfoController *weakSelf = self;
    if (_conversation.username.length != 0)
    {
        NSString *linkString = [NSString stringWithFormat:@"https://t.me/%@", _conversation.username];
        NSString *shareString = linkString;

        CGRect (^sourceRect)(void) = ^CGRect
        {
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return CGRectZero;
            
            return [strongSelf->_linkItem.view convertRect:strongSelf->_linkItem.view.bounds toView:strongSelf.view];
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
    else
    {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Channel.ShareNoLink") message:nil cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:^(__unused bool okButtonPressed)
          {
              __strong TGChannelGroupInfoController *strongSelf = weakSelf;
              if (strongSelf != nil)
                  [strongSelf linkPressed];
          }] show];
    }
}

- (void)leavePressed {
    __weak typeof(self) weakSelf = self;
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
                                                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ChannelInfo.ConfirmLeave") action:@"leave" type:TGActionSheetActionTypeDestructive],
                                                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
                                                        ] actionBlock:^(__unused id target, NSString *action)
      {
          if ([action isEqualToString:@"leave"])
          {
              TGChannelGroupInfoController *strongSelf = weakSelf;
              [strongSelf _commitLeaveChannel];
          }
      } target:self] showInView:self.view];
}

- (void)_commitLeaveChannel
{
    [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_peerId unreadCount:0 serviceUnreadCount:0] animated:false];
    
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

- (void)_commitDeleteChannel
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow show:true];
    
    [[[[TGChannelManagementSignals deleteChannel:_conversation.conversationId accessHash:_conversation.accessHash] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil completed:^{
        [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_peerId unreadCount:0 serviceUnreadCount:0] animated:false];
        
        if (self.popoverController != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [self.popoverController dismissPopoverAnimated:true];
                           });
        }
        else
            [self.navigationController popToRootViewControllerAnimated:true];
    }];
}

- (void)infoManagementPressed {
    [self.navigationController pushViewController:[[TGChannelMembersController alloc] initWithConversation:_conversation mode:TGChannelMembersModeAdmins] animated:true];
}

- (void)infoBlacklistPressed {
    [self.navigationController pushViewController:[[TGChannelMembersController alloc] initWithConversation:_conversation mode:TGChannelMembersModeBannedAndRestricted] animated:true];
}

- (void)sharedMediaPressed {
    TGSharedMediaController *controller = [[TGSharedMediaController alloc] initWithPeerId:_peerId accessHash:_conversation.accessHash important:false];
    controller.channelAllowDelete = _conversation.channelRole == TGChannelRoleCreator;
    controller.isChannelGroup = true;
    [self.navigationController pushViewController:controller animated:true];
}

- (void)deleteChannelPressed {
    __weak typeof(self) weakSelf = self;
    
    [[[TGActionSheet alloc] initWithTitle:TGLocalized(@"ChannelInfo.DeleteChannelConfirmation") actions:@[
                                                                                                          [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ChannelInfo.DeleteChannel") action:@"leave" type:TGActionSheetActionTypeDestructive],
                                                                                                          [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
                                                                                                          ] actionBlock:^(__unused id target, NSString *action)
      {
          if ([action isEqualToString:@"leave"])
          {
              TGChannelGroupInfoController *strongSelf = weakSelf;
              [strongSelf _commitDeleteChannel];
          }
      } target:self] showInView:self.view];
}

- (void)addMemberPressed {
    if ([self inPopover])
        [self.presentingViewController.view endEditing:true];
    
    TGSelectContactController *selectController = [[TGSelectContactController alloc] initWithCreateGroup:false createEncrypted:false createBroadcast:false createChannel:false inviteToChannel:true showLink:_conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.canChangeInviteLink];
    selectController.composePlaceholder = TGLocalized(@"Compose.GroupTokenListPlaceholder");
    selectController.channelConversation = _conversation;
    selectController.deselectAutomatically = true;
    
    __weak TGChannelGroupInfoController *weakSelf = self;
    selectController.onCreateLink = ^{
        __strong TGChannelGroupInfoController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if ([strongSelf.presentedViewController isKindOfClass:[UINavigationController class]])
            {
                TGGroupInfoShareLinkController *controller = [[TGGroupInfoShareLinkController alloc] initWithPeerId:strongSelf->_peerId accessHash:strongSelf->_conversation.accessHash currentLink:strongSelf->_privateLink];
                [(UINavigationController *)strongSelf.presentedViewController pushViewController:controller animated:true];
            }
        }
    };
    
    NSMutableArray *existingUsers = [[NSMutableArray alloc] init];
    
    for (TGUser *user in _users) {
        [existingUsers addObject:@(user.uid)];
    }
    
    selectController.disabledUsers = existingUsers;
    
    selectController.onChannelMembersInvited = ^(NSArray *users) {
        __strong TGChannelGroupInfoController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
            NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
            bool hasBots = false;
            for (TGUser *user in users) {
                if (updatedMemberDatas[@(user.uid)] != nil) {
                    continue;
                }
                
                if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot) {
                    hasBots = true;
                }
                
                updatedMemberDatas[@(user.uid)] = [[TGCachedConversationMember alloc] initWithUid:user.uid isCreator:false adminRights:nil bannedRights:nil timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] inviterId:0 adminInviterId:0 kickedById:0 adminCanManage:false];
                [updatedUsers insertObject:user atIndex:0];
            }
            
            [strongSelf _setUsers:updatedUsers memberDatas:updatedMemberDatas];
            
            if (hasBots) {
                SMetaDisposable *metaDisposable = [[SMetaDisposable alloc] init];
                __weak SMetaDisposable *weakMetaDisposable = metaDisposable;
                id<SDisposable> disposable = [[TGChannelManagementSignals updateChannelExtendedInfo:strongSelf->_peerId accessHash:strongSelf->_conversation.accessHash updateUnread:false] startWithNext:nil error:^(__unused id error) {
                    __strong SMetaDisposable *strongMetaDisposable = weakMetaDisposable;
                    if (strongMetaDisposable != nil) {
                        [TGTelegraphInstance.disposeOnLogout remove:strongMetaDisposable];
                    }
                } completed:^{
                    __strong SMetaDisposable *strongMetaDisposable = weakMetaDisposable;
                    if (strongMetaDisposable != nil) {
                        [TGTelegraphInstance.disposeOnLogout remove:strongMetaDisposable];
                    }
                }];
                [metaDisposable setDisposable:disposable];
                [TGTelegraphInstance.disposeOnLogout add:metaDisposable];
            }
        }
    };
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[selectController]];
    if ([self inPopover])
    {
        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)updateParticipant:(int32_t)uid member:(TGCachedConversationMember *)member {
    NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:_memberDatas];
    
    if (member != nil) {
        updatedMemberDatas[@(uid)] = member;
    } else {
        [updatedMemberDatas removeObjectForKey:member];
    }
    
    NSUInteger sectionIndex = [self indexForSection:_usersSection];
    if (sectionIndex != NSNotFound) {
        NSUInteger itemIndex = 0;
        for (TGGroupInfoUserCollectionItem *item in _usersSection.items) {
            if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]] && item.user.uid == uid) {
                TGGroupInfoUserCollectionItem *updatedItem = [self makeItemForUser:item.user member:member];
                [_usersSection replaceItemAtIndex:itemIndex withItem:updatedItem];
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:itemIndex inSection:sectionIndex]]];
                
                break;
            }
            itemIndex += 1;
        }
    }
    
    if (_searchResultUsers != nil) {
        NSMutableDictionary *updatedSearchResultMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:_searchResultsMemberDatas];
        
        if (member != nil) {
            updatedSearchResultMemberDatas[@(uid)] = member;
        } else {
            [updatedSearchResultMemberDatas removeObjectForKey:member];
        }
        
        NSIndexPath *indexPath = nil;
        NSUInteger sectionIndex = 0;
        for (NSArray<TGUser *> *section in _searchResultUsers) {
            NSUInteger index = 0;
            for (TGUser *user in section) {
                if (user.uid == uid) {
                    indexPath = [NSIndexPath indexPathForRow:index inSection:sectionIndex];
                    break;
                }
                index += 1;
            }
            
            sectionIndex += 1;
            if (indexPath != nil) {
                break;
            }
        }
        
        _searchResultsMemberDatas = updatedSearchResultMemberDatas;
        
        if (indexPath != nil) {
            [_searchMixin.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    _memberDatas = updatedMemberDatas;
}

- (void)removeParticipantFromList:(int32_t)uid {
    TGChannelGroupInfoController *strongSelf = self;
    NSUInteger index = 0;
    for (TGUser *user in strongSelf->_users) {
        if (user.uid == uid) {
            NSMutableArray *users = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
            [users removeObjectAtIndex:index];
            
            NSMutableDictionary *memberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
            [memberDatas removeObjectForKey:@(uid)];
            
            strongSelf->_users = users;
            strongSelf->_memberDatas = memberDatas;
            
            NSUInteger itemIndex = 0;
            for (id item in strongSelf->_usersSection.items) {
                if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]] && ((TGGroupInfoUserCollectionItem *)item).user.uid == uid)
                {
                    NSUInteger sectionIndex = [strongSelf indexForSection:strongSelf->_usersSection];
                    if (sectionIndex != NSNotFound) {
                        [strongSelf.menuSections beginRecordingChanges];
                        [strongSelf.menuSections deleteItemFromSection:sectionIndex atIndex:itemIndex];
                        [strongSelf.menuSections commitRecordedChanges:strongSelf.collectionView];
                    }
                    
                    break;
                }
                itemIndex++;
            }
            
            break;
        }
        index++;
    }
    
    if (_searchResultUsers != nil) {
        NSMutableArray *updatedSearchResultUsers = [[NSMutableArray alloc] initWithArray:_searchResultUsers];
        NSMutableDictionary *updatedSearchResultMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:_searchResultsMemberDatas];
        
        NSIndexPath *indexPath = nil;
        NSUInteger sectionIndex = 0;
        for (NSArray<TGUser *> *section in updatedSearchResultUsers) {
            NSUInteger index = 0;
            for (TGUser *user in section) {
                if (user.uid == uid) {
                    NSMutableArray *updatedSection = [[NSMutableArray alloc] initWithArray:section];
                    [updatedSection removeObjectAtIndex:index];
                    updatedSearchResultUsers[sectionIndex] = updatedSection;
                    
                    indexPath = [NSIndexPath indexPathForRow:index inSection:sectionIndex];
                    break;
                }
                index += 1;
            }
            
            sectionIndex += 1;
            if (indexPath != nil) {
                break;
            }
        }
        
        [updatedSearchResultMemberDatas removeObjectForKey:@(uid)];
        
        _searchResultUsers = updatedSearchResultUsers;
        _searchResultsMemberDatas = updatedSearchResultMemberDatas;
        
        if (indexPath != nil) {
            [_searchMixin.searchResultsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)_commitDeleteParticipant:(int32_t)uid tryRestrict:(bool)tryRestrict {
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]] && ((TGGroupInfoUserCollectionItem *)item).user.uid == uid)
        {
            if (tryRestrict) {
                TGChannelBanController *controller = [[TGChannelBanController alloc] initWithConversation:_conversation user:((TGGroupInfoUserCollectionItem *)item).user current:nil member:[TGChannelManagementSignals channelRole:_conversation.conversationId accessHash:_conversation.accessHash user:((TGGroupInfoUserCollectionItem *)item).user]];
                
                __weak TGChannelGroupInfoController *weakSelf = self;
                controller.done = ^(TGChannelBannedRights *rights) {
                    __strong TGChannelGroupInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        if (rights != nil) {
                            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                            [progressWindow show:true];
                            [[[[TGChannelManagementSignals updateChannelBannedRightsAndGetMembership:strongSelf->_conversation.conversationId accessHash:strongSelf->_conversation.accessHash user:[TGDatabaseInstance() loadUser:uid] rights:rights] onDispose:^{
                                TGDispatchOnMainThread(^{
                                    [progressWindow dismiss:true];
                                });
                            }] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedConversationMember *updatedMember) {
                                __strong TGChannelGroupInfoController *strongSelf = weakSelf;
                                if (strongSelf != nil) {
                                    [TGDatabaseInstance() updateChannelCachedData:_conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                                        if (data == nil) {
                                            data = [[TGCachedConversationData alloc] init];
                                        }
                                        
                                        return [data updateMemberBannedRights:uid rights:rights timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] isMember:updatedMember != nil kickedById:TGTelegraphInstance.clientUserId];
                                    }];
                                    
                                    if (rights.banReadMessages) {
                                        [strongSelf removeParticipantFromList:uid];
                                    }
                                    
                                    [strongSelf dismissViewControllerAnimated:true completion:nil];
                                }
                            } error:^(id error) {
                                __strong TGChannelGroupInfoController *strongSelf = weakSelf;
                                if (strongSelf != nil) {
                                }
                            } completed:^{
                            }];
                        } else {
                            [strongSelf dismissViewControllerAnimated:true completion:nil];
                        }
                    }
                };
                
                TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller] navigationBarClass:[TGWhiteNavigationBar class]];
                if ([self inPopover]) {
                    navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
                    navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
                }
                
                [self presentViewController:navigationController animated:true completion:nil];
                
                return;
            } else {
                __weak TGChannelGroupInfoController *weakSelf = self;
                TGChannelBannedRights *rights = [[TGChannelBannedRights alloc] initWithBanReadMessages:true banSendMessages:true banSendMedia:true banSendStickers:true banSendGifs:true banSendGames:true banSendInline:true banEmbedLinks:true timeout:true];
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow show:true];
                [[[[TGChannelManagementSignals updateChannelBannedRightsAndGetMembership:self->_conversation.conversationId accessHash:self->_conversation.accessHash user:[TGDatabaseInstance() loadUser:uid] rights:rights] onDispose:^{
                    TGDispatchOnMainThread(^{
                        [progressWindow dismiss:true];
                    });
                }] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedConversationMember *updatedMember) {
                    __strong TGChannelGroupInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [TGDatabaseInstance() updateChannelCachedData:_conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                            if (data == nil) {
                                data = [[TGCachedConversationData alloc] init];
                            }
                            
                            return [data updateMemberBannedRights:uid rights:rights timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] isMember:updatedMember != nil kickedById:TGTelegraphInstance.clientUserId];
                        }];
                        
                        if (rights.banReadMessages) {
                            [strongSelf removeParticipantFromList:uid];
                        }
                        
                        [strongSelf dismissViewControllerAnimated:true completion:nil];
                    }
                } error:^(id error) {
                    __strong TGChannelGroupInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                    }
                } completed:^{
                }];
            }
            break;
        }
    }
}

- (void)loadMore {
    if (_canLoadMore) {
        _shouldLoadMore = false;
        _canLoadMore = false;
        _loadMoreMembersPipe.sink(@true);
    } else {
        _shouldLoadMore = true;
    }
}

- (void)loadMoreIfNeeded {
    if (_shouldLoadMore) {
        _shouldLoadMore = false;
        
        if (_canLoadMore) {
            _canLoadMore = false;
            _loadMoreMembersPipe.sink(@true);
        }
    }
}

- (void)editGroupTypePressed {
    int64_t conversationId = _conversation.conversationId;
    int64_t accessHash = _conversation.accessHash;
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.2];
    
    __weak TGChannelGroupInfoController *weakSelf = self;
    [[[[[[[TGDatabaseInstance() channelCachedData:_conversation.conversationId] take:1] mapToSignal:^SSignal *(TGCachedConversationData *cachedData) {
        if (cachedData.privateLink.length != 0) {
            return [SSignal single:cachedData.privateLink];
        } else {
            return [TGChannelManagementSignals exportChannelInvitationLink:conversationId accessHash:accessHash];
        }
    }] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] timeout:5.0 onQueue:[SQueue mainQueue] orSignal:[SSignal fail:nil]] startWithNext:^(NSString *link) {
        __strong TGChannelGroupInfoController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            TGSetupChannelAfterCreationController *controller = [[TGSetupChannelAfterCreationController alloc] initWithConversation:strongSelf->_conversation exportedLink:link modal:true conversationsToDeleteForPublicUsernames:@[] checkConversationsToDeleteForPublicUsernames:true];
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller] navigationBarClass:[TGWhiteNavigationBar class]];
            if ([strongSelf inPopover])
            {
                navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
                navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
            }
            [strongSelf presentViewController:navigationController animated:true completion:nil];
        }
    }];
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

- (void)promote:(TGUser *)user {
    __weak TGChannelGroupInfoController *weakSelf = self;
    TGChannelModeratorController *controller = [[TGChannelModeratorController alloc] initWithConversation:self->_conversation user:user currentSignal:[TGChannelManagementSignals channelRole:_conversation.conversationId accessHash:_conversation.accessHash user:user]];
    controller.done = ^(TGChannelAdminRights *rights) {
        __strong TGChannelGroupInfoController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (rights != nil) {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow showWithDelay:0.1];
                
                [[[[TGChannelManagementSignals updateChannelAdminRights:strongSelf->_conversation.conversationId accessHash:strongSelf->_conversation.accessHash user:user rights:rights] deliverOn:[SQueue mainQueue]] onDispose:^{
                    TGDispatchOnMainThread(^{
                        [progressWindow dismiss:true];
                    });
                }] startWithNext:nil error:^(id error) {
                    __strong TGChannelGroupInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        TGConversation *conversation = strongSelf->_conversation;
                        NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                        NSString *errorText = TGLocalized(@"Profile.CreateEncryptedChatError");
                        if ([errorType isEqual:@"USER_BLOCKED"]) {
                            errorText = conversation.isChannelGroup ? TGLocalized(@"Group.ErrorAddBlocked") : TGLocalized(@"Channel.ErrorAddBlocked");
                        } else if ([errorType isEqual:@"USERS_TOO_MUCH"]) {
                            errorText = conversation.isChannelGroup ? TGLocalized(@"Group.ErrorAddTooMuch") : TGLocalized(@"Channel.ErrorAddTooMuch");
                        } else if ([errorType isEqual:@"USER_NOT_MUTUAL_CONTACT"]) {
                            errorText = TGLocalized(@"Group.ErrorNotMutualContact");
                        } else if ([errorType isEqual:@"ADMINS_TOO_MUCH"]) {
                            errorText = TGLocalized(@"Group.ErrorAddTooMuchAdmins");
                        } else if ([errorType isEqual:@"USER_PRIVACY_RESTRICTED"]) {
                            NSString *format = conversation.isChannelGroup ? TGLocalized(@"Privacy.GroupsAndChannels.InviteToGroupError") : TGLocalized(@"Privacy.GroupsAndChannels.InviteToChannelError");
                            errorText = [[NSString alloc] initWithFormat:format, user.displayFirstName, user.displayFirstName];
                        }
                        [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                    }
                } completed:^{
                    __strong TGChannelGroupInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [TGDatabaseInstance() updateChannelCachedData:strongSelf->_conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                            if (data == nil) {
                                data = [[TGCachedConversationData alloc] init];
                            }
                            
                            if (rights.hasAnyRights) {
                                return [data addManagementMember:[[TGCachedConversationMember alloc] initWithUid:user.uid isCreator:false adminRights:rights bannedRights:nil timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] inviterId:TGTelegraphInstance.clientUserId adminInviterId:TGTelegraphInstance.clientUserId kickedById:0 adminCanManage:true]];
                            } else {
                                return [data removeManagementMember:user.uid];
                            }
                        }];
                        
                        TGCachedConversationMember *currentMember = strongSelf->_memberDatas[@(user.uid)];
                        if (currentMember != nil) {
                            TGCachedConversationMember *updatedMember = nil;
                            if (rights.hasAnyRights) {
                                updatedMember = [currentMember withUpdatedAdminRights:rights adminInviterId:TGTelegraphInstance.clientUserId adminCanManage:true];
                            } else {
                                updatedMember = [currentMember withUpdatedAdminRights:nil adminInviterId:0 adminCanManage:false];
                            }
                            [strongSelf updateParticipant:user.uid member:updatedMember];
                        }
                        
                        [strongSelf dismissViewControllerAnimated:true completion:nil];
                    }
                    [progressWindow dismissWithSuccess];
                }];
            } else {
                [strongSelf dismissViewControllerAnimated:true completion:nil];
            }
        }
    };
    controller.revoke = ^{
        __strong TGChannelGroupInfoController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow show:true];
            TGConversation *conversation = strongSelf->_conversation;
            [[[[[TGChannelManagementSignals updateChannelAdminRights:conversation.conversationId accessHash:conversation.accessHash user:user rights:nil] onCompletion:^{
                [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                    if (data == nil) {
                        data = [[TGCachedConversationData alloc] init];
                    }
                    
                    return [data removeManagementMember:user.uid];
                }];
            }] deliverOn:[SQueue mainQueue]] onDispose:^{
                TGDispatchOnMainThread(^{
                    __strong TGChannelGroupInfoController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        TGCachedConversationMember *currentMember = strongSelf->_memberDatas[@(user.uid)];
                        if (currentMember != nil) {
                            TGCachedConversationMember *updatedMember = nil;
                            updatedMember = [currentMember withUpdatedAdminRights:nil adminInviterId:0 adminCanManage:false];
                            [strongSelf updateParticipant:user.uid member:updatedMember];
                        }
                        
                        [strongSelf dismissViewControllerAnimated:true completion:nil];
                    }
                });
            }] startWithNext:nil];
        }
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller] navigationBarClass:[TGWhiteNavigationBar class]];
    if ([self inPopover]) {
        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)loadView {
    [super loadView];
    
    CGRect referenceFrame = TGIsPad() ? CGRectMake(0.0f, -20.0f, self.view.bounds.size.width, self.view.bounds.size.height) : self.view.bounds;
    _searchReferenceView = [[UIView alloc] initWithFrame:referenceFrame];
    _searchReferenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _searchReferenceView.userInteractionEnabled = false;
    [self.view addSubview:_searchReferenceView];
    
    CGFloat searchBarHeight = TGIsPad() ? 44.0f : 64.0f;
    
    _searchBarOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, searchBarHeight)];
    _searchBarOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBarOverlay.backgroundColor = UIColorRGB(0xf7f7f7);
    _searchBarOverlay.userInteractionEnabled = false;
    
    _searchBarWrapper = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.navigationController.view.frame.size.width, searchBarHeight)];
    _searchBarWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBarWrapper.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_searchBarWrapper];
    
    [_searchBarWrapper addSubview:_searchBarOverlay];
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0.0f, TGIsPad() ? 0.0f : 20.0f, _searchBarWrapper.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleHeader];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.customBackgroundView.image = nil;
    _searchBar.customActiveBackgroundView.image = nil;
    _searchBar.delegate = self;
    [_searchBar setShowsCancelButton:true animated:false];
    [_searchBar setAlwaysExtended:true];
    _searchBar.placeholder = TGLocalized(@"Common.Search");
    [_searchBar sizeToFit];
    _searchBar.delayActivity = false;
    [_searchBarWrapper addSubview:_searchBar];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _searchBarWrapper.frame.size.height - TGScreenPixel, _searchBarWrapper.frame.size.width, TGScreenPixel)];
    separatorView.backgroundColor = UIColorRGB(0xb2b2b2);
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_searchBarWrapper addSubview:separatorView];
    
    _searchMixin = [[TGSearchDisplayMixin alloc] init];
    _searchMixin.simpleLayout = true;
    _searchMixin.searchBar = _searchBar;
    _searchMixin.alwaysShowsCancelButton = true;
    _searchMixin.delegate = self;
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    if ([self isViewLoaded]) {
        UIEdgeInsets inset = self.controllerInset;
        inset.top = MAX(inset.top, 64.0f);
        inset.top -= 1.0f;
        [_searchMixin controllerInsetUpdated:inset];
        
        CGRect frame = _searchBarWrapper.frame;
        if (!_searchMixin.isActive) {
            frame.origin.y = self.controllerInset.top - 64.0f;
        } else {
            frame.origin.y = 0.0f;
            if (self.navigationController.modalPresentationStyle == UIModalPresentationFormSheet) {
                frame.origin.y -= 20;
            }
        }
        _searchBarWrapper.frame = frame;
    }
}

- (void)searchPressed
{
    [self setSearchHidden:false animated:true];
    [_searchBar becomeFirstResponder];
}

- (void)setSearchHidden:(bool)hidden animated:(bool)animated
{
    void (^changeBlock)(void) = ^
    {
        CGRect frame = _searchBarWrapper.frame;
        if (hidden)
        {
            frame.origin.y = self.controllerInset.top - 64.0f;
        }
        else
        {
            frame.origin.y = 0.0f;
            if (self.navigationController.modalPresentationStyle == UIModalPresentationFormSheet)
                frame.origin.y -= 20;
        }
        _searchBarWrapper.frame = frame;
    };
    
    if (animated)
        [UIView animateWithDuration:0.2f animations:changeBlock];
    else
        changeBlock();
}

- (void)searchBar:(TGSearchBar *)__unused searchBar willChangeHeight:(CGFloat)__unused newHeight
{
    
}

- (void)searchMixin:(TGSearchDisplayMixin *)searchMixin hasChangedSearchQuery:(NSString *)searchQuery withScope:(int)__unused scope {
    _searchString = searchQuery;
    if (_searchString.length == 0) {
        [_searchBar setShowActivity:false];
        _searchResultUsers = @[];
        _searchResultsMemberDatas = @{};
        [_searchDisposable setDisposable:nil];
        [searchMixin reloadSearchResults];
        [searchMixin setSearchResultsTableViewHidden:true];
    } else {
        [_searchBar setShowActivity:true];
        __weak TGChannelGroupInfoController *weakSelf = self;
        
        SSignal *signal = nil;
        if (_memberCount != 0 && _memberCount <= 100) {
            NSArray *filteredMembers = [TGDatabase searchUsersInArray:_users query:searchQuery];
            signal = [SSignal single:@{@"users": filteredMembers, @"memberDatas": _memberDatas}];
        } else {
            signal = [TGGlobalMessageSearchSignals searchChannelMembers:searchQuery peerId:_conversation.conversationId accessHash:_conversation.accessHash section:TGGlobalMessageSearchMembersSectionMembers];
        }
        
        [_searchDisposable setDisposable:[[[SSignal combineSignals:@[signal]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *values) {
            __strong TGChannelGroupInfoController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSDictionary *memberData = values[0];
                NSArray *contactData = @[];
                NSArray *globalData = @[];
                
                NSMutableSet *processedUserIds = [[NSMutableSet alloc] init];
                
                NSMutableArray *members = [[NSMutableArray alloc] init];
                NSMutableArray *contacts = [[NSMutableArray alloc] init];
                NSMutableArray *global = [[NSMutableArray alloc] init];
                
                for (TGUser *user in memberData[@"users"]) {
                    if (![processedUserIds containsObject:user] && user.uid != TGTelegraphInstance.clientUserId) {
                        [processedUserIds addObject:@(user.uid)];
                        [members addObject:user];
                    }
                }
                
                for (TGUser *user in contactData) {
                    if ([user isKindOfClass:[TGUser class]] && ![processedUserIds containsObject:user] && user.uid != TGTelegraphInstance.clientUserId) {
                        [processedUserIds addObject:@(user.uid)];
                        [contacts addObject:user];
                    }
                }
                
                for (TGUser *user in globalData) {
                    if ([user isKindOfClass:[TGUser class]] && ![processedUserIds containsObject:user] && user.uid != TGTelegraphInstance.clientUserId) {
                        [processedUserIds addObject:@(user.uid)];
                        [global addObject:user];
                    }
                }
                
                strongSelf->_searchResultUsers = @[members, contacts, global];
                strongSelf->_searchResultsMemberDatas = memberData[@"memberDatas"];
                [searchMixin reloadSearchResults];
                [searchMixin setSearchResultsTableViewHidden:false];
                [strongSelf->_searchBar setShowActivity:false];
            }
        }]];
    }
}

- (void)searchMixinWillActivate:(bool)__unused animated
{
    [self setNavigationBarHidden:true animated:true];
    
    [UIView animateWithDuration:0.2f animations:^{
        [self setExplicitTableInset:UIEdgeInsetsMake(44.0f, 0.0f, 0.0f, 0.0f)];
    }];
}

- (void)searchMixinWillDeactivate:(bool)animated
{
    [UIView animateWithDuration:0.2f animations:^{
        [self setExplicitTableInset:UIEdgeInsetsZero];
    }];
    [self setNavigationBarHidden:false animated:true];
    [_searchDisposable setDisposable:nil];
    
    [self setSearchHidden:true animated:animated];
}

- (UIView *)referenceViewForSearchResults
{
    return _searchReferenceView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TGUser *user = nil;
    user = _searchResultUsers[indexPath.section][indexPath.row];
    
    static NSString *cellIdentifier = @"TGGroupInfoUserCell";
    TGGroupInfoUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[TGGroupInfoUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    TGGroupInfoUserCollectionItem *item = [self makeItemForUser:user member:_searchResultsMemberDatas[@(user.uid)]];
    [cell setItem:item];
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    return _searchResultUsers.count;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResultUsers[section].count;
}

- (UITableView *)createTableViewForSearchMixin:(TGSearchDisplayMixin *)__unused searchMixin {
    UITableView *tableView = [[UITableView alloc] init];
    
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    tableView.tableFooterView = [[UIView alloc] init];
    
    tableView.rowHeight = 48.0f;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return tableView;
}

- (TGGroupInfoUserCollectionItem *)makeItemForUser:(TGUser *)user member:(TGCachedConversationMember *)member {
    TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
    userItem.interfaceHandle = _actionHandle;
    
    userItem.selectable = user.uid != TGTelegraphInstance.clientUserId;
    
    bool canEdit = false;
    bool canBan = false;
    bool canPromote = false;
    if ([self canKickMembers] && user.uid != TGTelegraphInstance.clientUserId) {
        if (_conversation.channelRole == TGChannelRoleCreator) {
            canEdit = true;
        } else {
            canEdit = (!member.adminRights.hasAnyRights || member.adminInviterId == TGTelegraphInstance.clientUserId) && !member.isCreator;
        }
    }
    canBan = canEdit;
    if (canEdit) {
        if (_conversation.channelRole == TGChannelRoleCreator) {
            canPromote = true;
        } else if (_conversation.channelAdminRights.canAddAdmins) {
            if (member.adminRights == nil || member.adminInviterId == TGTelegraphInstance.clientUserId) {
                canPromote = true;
            }
        }
    }
    
    [userItem setCanEdit:canEdit];
    userItem.canDelete = canBan;
    userItem.canRestrict = canBan;
    userItem.canPromote = canPromote;
    
    __weak TGChannelGroupInfoController *weakSelf = self;
    userItem.requestPromote = ^{
        __strong TGChannelGroupInfoController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf promote:user];
        }
    };
    
    userItem.requestRestrict = ^{
        __strong TGChannelGroupInfoController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf _commitDeleteParticipant:user.uid tryRestrict:true];
        }
    };
    
    [userItem setUser:user];
    
    if (member != nil && (member.adminRights.hasAnyRights || member.isCreator)) {
        userItem.customLabel = TGLocalized(@"GroupInfo.LabelAdmin");
    } else {
        userItem.customLabel = nil;
    }
    return userItem;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    TGUser *user = _searchResultUsers[indexPath.section][indexPath.row];
    [self actionStageActionRequested:@"openUser" options:@{@"uid": @(user.uid), @"force": @true}];
}

@end
