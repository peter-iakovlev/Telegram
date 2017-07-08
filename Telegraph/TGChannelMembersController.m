#import "TGChannelMembersController.h"

#import "TGTelegraph.h"

#import "TGConversation.h"
#import "TGUser.h"
#import "TGDatabase.h"
#import "TGTelegramNetworking.h"

#import "TGButtonCollectionItem.h"
#import "TGGroupInfoUserCollectionItem.h"

#import "TGSelectContactController.h"

#import "TGChannelManagementSignals.h"

#import "TGProgressWindow.h"

#import "ActionStage.h"

#import "TGBotUserInfoController.h"
#import "TGTelegraphUserInfoController.h"

#import "TGGroupInfoShareLinkController.h"

#import "TGCommentCollectionItem.h"

#import "TGGroupInfoSelectContactController.h"

#import "TGNavigationController.h"
#import "TGNavigationBar.h"

#import "TGAlertView.h"

#import "TGChannelModeratorController.h"

#import "TGChannelMembersControllerEmptyView.h"

#import "TGVariantCollectionItem.h"
#import "TGHeaderCollectionItem.h"

#import "TGActionSheet.h"
#import "TGStringUtils.h"

#import "TGChannelModeratorController.h"

#import "TGSearchChatMembersController.h"

#import "TGChannelBanController.h"

#import "TGInterfaceManager.h"

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

@interface TGChannelMembersController () <ASWatcher, TGGroupInfoSelectContactControllerDelegate, UITableViewDelegate, UITableViewDataSource, TGSearchDisplayMixinDelegate, TGSearchBarDelegate> {
    TGConversation *_conversation;
    TGChannelMembersMode _mode;
    id<SDisposable> _channelMembersDisposable;
    NSString *_privateLink;
    
    TGCollectionMenuSection *_adminSection;
    TGCollectionMenuSection *_usersSection;
    TGCollectionMenuSection *_kickedSection;
    int _usersSectionPaddingTop;
    int _usersSectionPaddingBottom;
    
    TGCollectionMenuSection *_inviteControlSection;
    TGVariantCollectionItem *_infoEventLogItem;
    TGVariantCollectionItem *_inviteControlItem;
    TGCommentCollectionItem *_inviteControlComment;
    
    NSArray *_users;
    NSDictionary *_memberDatas;
    
    UIActivityIndicatorView *_activityIndicator;
    bool _editing;
    
    id<SDisposable> _cachedDataDisposable;
    
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

@implementation TGChannelMembersController

- (instancetype)initWithConversation:(TGConversation *)conversation mode:(TGChannelMembersMode)mode {
    self = [super init];
    if (self != nil) {
        _conversation = conversation;
        _mode = mode;
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        _searchDisposable = [[SMetaDisposable alloc] init];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        
        _searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchPressed)];
        
        switch (mode) {
            case TGChannelMembersModeMembers:
                self.title = TGLocalized(@"Channel.Members.Title");
                break;
            case TGChannelMembersModeBannedAndRestricted:
                self.title = TGLocalized(@"Channel.BlackList.Title");
                break;
            case TGChannelMembersModeAdmins:
                self.title = TGLocalized(@"Channel.Management.Title");
                break;
        }
        
        if (mode == TGChannelMembersModeAdmins) {
            _infoEventLogItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Group.Info.AdminLog") variant:@"" action:@selector(eventLogPressed)];
            
            if (_conversation.isChannelGroup && _conversation.channelRole == TGChannelRoleCreator) {
                _inviteControlItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"ChannelMembers.WhoCanAddMembers") action:@selector(whoCanAddMembersPressed)];
                _inviteControlItem.deselectAutomatically = true;
                if (_conversation.everybodyCanAddMembers) {
                    _inviteControlItem.variant = TGLocalized(@"ChannelMembers.WhoCanAddMembers.AllMembers");
                } else {
                    _inviteControlItem.variant = TGLocalized(@"ChannelMembers.WhoCanAddMembers.Admins");
                }
                _inviteControlComment = [[TGCommentCollectionItem alloc] initWithText:@""];
                if (_conversation.everybodyCanAddMembers) {
                    _inviteControlComment.text = TGLocalized(@"ChannelMembers.WhoCanAddMembersAllHelp");
                } else {
                    _inviteControlComment.text = TGLocalized(@"ChannelMembers.WhoCanAddMembersAdminsHelp");
                }
                _inviteControlSection = [[TGCollectionMenuSection alloc] initWithItems:@[_infoEventLogItem, _inviteControlItem, _inviteControlComment]];
            } else {
                _inviteControlSection = [[TGCollectionMenuSection alloc] initWithItems:@[_infoEventLogItem]];
            }
            [self.menuSections addSection:_inviteControlSection];
        } else if (mode == TGChannelMembersModeBannedAndRestricted && (_conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.canBanUsers)) {
            TGButtonCollectionItem *addMemberItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.AddParticipant") action:@selector(addBlacklistPressed)];
            _inviteControlSection = [[TGCollectionMenuSection alloc] initWithItems:@[addMemberItem]];
            addMemberItem.leftInset = 65.0f;
            addMemberItem.icon = [UIImage imageNamed:@"ModernContactListAddMemberIcon.png"];
            addMemberItem.iconOffset = CGPointMake(3.0f, 0.0f);
            addMemberItem.titleColor = TGAccentColor();
            [self.menuSections addSection:_inviteControlSection];
        }
        
        TGButtonCollectionItem *addMemberItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Members.AddMembers") action:@selector(addMembersPressed)];
        NSMutableArray *adminSectionItems = [[NSMutableArray alloc] init];
        [adminSectionItems addObject:addMemberItem];

        if (_conversation.username.length == 0 && (_conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.canChangeInviteLink)) {
            TGButtonCollectionItem *linkItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Members.InviteLink") action:@selector(linkPressed)];
            [adminSectionItems addObject:linkItem];
        }
        
        TGCommentCollectionItem *addMemberHelpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.Members.AddMembersHelp")];
        [adminSectionItems addObject:addMemberHelpItem];
        
        TGHeaderCollectionItem *adminsTitleItem = [[TGHeaderCollectionItem alloc] initWithTitle:_conversation.isChannelGroup ? TGLocalized(@"ChannelMembers.GroupAdminsTitle") : TGLocalized(@"ChannelMembers.ChannelAdminsTitle")];
        TGButtonCollectionItem *addModeratorItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Management.AddModerator") action:@selector(addModeratorPressed)];
        addModeratorItem.leftInset = 65.0f;
        addModeratorItem.icon = [UIImage imageNamed:@"ModernContactListAddMemberIcon.png"];
        addModeratorItem.iconOffset = CGPointMake(3.0f, 0.0f);
        addModeratorItem.titleColor = TGAccentColor();
        addModeratorItem.deselectAutomatically = true;
        TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:_conversation.isChannelGroup ? TGLocalized(@"Group.Management.AddModeratorHelp") : TGLocalized(@"Channel.Management.AddModeratorHelp")];
        
        _adminSection = [[TGCollectionMenuSection alloc] initWithItems:adminSectionItems];
        
        switch (mode) {
            case TGChannelMembersModeMembers: {
                if (conversation.channelRole == TGChannelRoleCreator || conversation.channelAdminRights.canInviteUsers) {
                    [self.menuSections addSection:_adminSection];
                }
                break;
            }
            case TGChannelMembersModeAdmins: {
                break;
            }
            default:
                break;
        }
        
        NSMutableArray *usersSectionItems = [[NSMutableArray alloc] init];
        if (_mode == TGChannelMembersModeAdmins && (conversation.channelRole == TGChannelRoleCreator || conversation.channelAdminRights.canAddAdmins)) {
            [usersSectionItems addObject:adminsTitleItem];
            [usersSectionItems addObject:addModeratorItem];
            [usersSectionItems addObject:commentItem];
            _usersSectionPaddingTop = 2;
            _usersSectionPaddingBottom = 1;
        } else if (_mode == TGChannelMembersModeBannedAndRestricted) {
            [usersSectionItems addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.BanList.RestrictedTitle")]];
            _usersSectionPaddingTop = 1;
        }
        _usersSection = [[TGCollectionMenuSection alloc] initWithItems:usersSectionItems];
        [self.menuSections addSection:_usersSection];
        
        _kickedSection = [[TGCollectionMenuSection alloc] initWithItems:@[[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.BanList.BlockedTitle")]]];
        if (_mode == TGChannelMembersModeBannedAndRestricted) {
            [self.menuSections addSection:_kickedSection];
        }
        
        TGCollectionMenuSection *topSection = self.menuSections.sections.firstObject;
        UIEdgeInsets topSectionInsets = topSection.insets;
        topSectionInsets.top = 32.0f;
        topSection.insets = topSectionInsets;
        
        SSignal *signal = nil;
        switch (_mode) {
            case TGChannelMembersModeMembers: {
                SSignal *cachedSignal = [[[TGDatabaseInstance() channelCachedData:_conversation.conversationId] take:1] mapToSignal:^SSignal *(TGCachedConversationData *cachedData) {
                    if (cachedData.generalMembers.count == 0) {
                        return [SSignal complete];
                    } else {
                        NSMutableArray *users = [[NSMutableArray alloc] init];
                        NSMutableDictionary *memberDatas = [[NSMutableDictionary alloc] init];
                        for (TGCachedConversationMember *member in cachedData.generalMembers) {
                            TGUser *user = [TGDatabaseInstance() loadUser:member.uid];
                            if (user != nil) {
                                [users addObject:user];
                                memberDatas[@(member.uid)] = member;
                            }
                        }
                        return [SSignal single:@{@"users": users, @"memberDatas": memberDatas}];
                    }
                }];
                signal = [cachedSignal then:[[TGChannelManagementSignals channelMembers:conversation.conversationId accessHash:conversation.accessHash offset:0 count:128] onNext:^(NSDictionary *dict) {
                    
                    [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                        if (data == nil) {
                            data = [[TGCachedConversationData alloc] init];
                        }
                        return [data updateGeneralMembers:[dict[@"memberDatas"] allValues]];
                    }];
                }]];
                break;
            }
            case TGChannelMembersModeBannedAndRestricted: {
                SSignal *cachedSignal = [[[TGDatabaseInstance() channelCachedData:_conversation.conversationId] take:1] mapToSignal:^SSignal *(TGCachedConversationData *cachedData) {
                    NSMutableArray *users = [[NSMutableArray alloc] init];
                    NSMutableDictionary *memberDatas = [[NSMutableDictionary alloc] init];
                    
                    for (TGCachedConversationMember *member in cachedData.blacklistMembers) {
                        TGUser *user = [TGDatabaseInstance() loadUser:member.uid];
                        if (user != nil) {
                            [users addObject:user];
                            memberDatas[@(member.uid)] = member;
                        }
                    }
                    
                    for (TGCachedConversationMember *member in cachedData.bannedMembers) {
                        TGUser *user = [TGDatabaseInstance() loadUser:member.uid];
                        if (user != nil) {
                            [users addObject:user];
                            memberDatas[@(member.uid)] = member;
                        }
                    }
                    
                    return [SSignal single:@{@"users": users, @"memberDatas": memberDatas}];
                }];
                signal = [cachedSignal then:[[[SSignal combineSignals:@[[TGChannelManagementSignals channelBlacklistMembers:conversation.conversationId accessHash:conversation.accessHash offset:0 count:128], [TGChannelManagementSignals channelBannedMembers:conversation.conversationId accessHash:conversation.accessHash offset:0 count:128]]] map:^(NSArray *values) {
                    NSMutableArray *users = [[NSMutableArray alloc] init];
                    NSMutableDictionary *memberDatas = [[NSMutableDictionary alloc] init];
                    
                    [users addObjectsFromArray:values[0][@"users"]];
                    [users addObjectsFromArray:values[1][@"users"]];
                    
                    [memberDatas addEntriesFromDictionary:values[0][@"memberDatas"]];
                    [memberDatas addEntriesFromDictionary:values[1][@"memberDatas"]];
                    
                    [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                        if (data == nil) {
                            data = [[TGCachedConversationData alloc] init];
                        }
                        return [[data updateBlacklistMembers:[values[0][@"memberDatas"] allValues]] updateBannedMembers:[values[1][@"memberDatas"] allValues]];
                    }];
                    
                    return @{@"users": users, @"memberDatas": memberDatas};
                }] map:^id(NSDictionary *dict) {
                    NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                    updatedDict[@"final"] = @(true);
                    return updatedDict;
                }]];
                break;
            }
            case TGChannelMembersModeAdmins: {
                SSignal *cachedSignal = [[[TGDatabaseInstance() channelCachedData:_conversation.conversationId] take:1] mapToSignal:^SSignal *(TGCachedConversationData *cachedData) {
                    if (cachedData.managementMembers.count == 0) {
                        return [SSignal complete];
                    } else {
                        NSMutableArray *users = [[NSMutableArray alloc] init];
                        NSMutableDictionary *memberDatas = [[NSMutableDictionary alloc] init];
                        
                        for (TGCachedConversationMember *member in cachedData.managementMembers) {
                            TGUser *user = [TGDatabaseInstance() loadUser:member.uid];
                            if (user != nil) {
                                [users addObject:user];
                                memberDatas[@(member.uid)] = member;
                            }
                        }
                        return [SSignal single:@{@"users": users, @"memberDatas": memberDatas}];
                    }
                }];
                
                signal = [cachedSignal then:[[TGChannelManagementSignals channelAdmins:conversation.conversationId accessHash:conversation.accessHash offset:0 count:128] onNext:^(NSDictionary *dict) {
                    
                    [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                        if (data == nil) {
                            data = [[TGCachedConversationData alloc] init];
                        }
                        return [data updateManagementMembers:[dict[@"memberDatas"] allValues]];
                    }];
                }]];
                break;
            }
        }
        
        __weak TGChannelMembersController *weakSelf = self;
        _channelMembersDisposable = [[signal deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict) {
            __strong TGChannelMembersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [self setUsers:dict[@"users"] memberDatas:dict[@"memberDatas"] isFinal:[dict[@"final"] boolValue]];
            }
        }];
        
        _cachedDataDisposable = [[[TGDatabaseInstance() channelCachedData:_conversation.conversationId] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedConversationData *cachedData) {
            __strong TGChannelMembersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_privateLink = cachedData.privateLink;
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [_channelMembersDisposable dispose];
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)editPressed {
    _editing = true;
    [self enterEditingMode:true];
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)] animated:true];
    [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:@selector(noAction)] animated:true];
}

- (void)noAction {
}

- (void)donePressed {
    _editing = false;
    [self leaveEditingMode:true];
    
    [self setLeftBarButtonItem:nil animated:true];
    
    bool canEdit = [self canEditMembers];
    bool hasMembers = false;
    for (int i = _usersSectionPaddingTop; i < (int)_usersSection.items.count - _usersSectionPaddingBottom; i++) {
        TGGroupInfoUserCollectionItem *item = _usersSection.items[i];
        if (item.user.uid != TGTelegraphInstance.clientUserId) {
            hasMembers = true;
        }
    }
    
    for (int i = 1; i < (int)_kickedSection.items.count; i++) {
        hasMembers = true;
    }
    
    if (canEdit) {
        if (hasMembers) {
            [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)], _searchItem] animated:true];
        } else {
            [self.navigationItem setRightBarButtonItems:@[] animated:true];
        }
    } else {
        if (hasMembers) {
            [self.navigationItem setRightBarButtonItems:@[_searchItem] animated:true];
        } else {
            [self.navigationItem setRightBarButtonItems:@[] animated:true];
        }
    }
}

- (void)setUsers:(NSArray *)users memberDatas:(NSDictionary *)memberDatas isFinal:(bool)__unused isFinal {
    NSMutableArray *filteredUsers = [[NSMutableArray alloc] init];
    NSMutableSet *existing = [[NSMutableSet alloc] init];
    for (TGUser *user in users) {
        if (![existing containsObject:@(user.uid)]) {
            [existing addObject:@(user.uid)];
            [filteredUsers addObject:user];
        }
    }
    TGDispatchOnMainThread(^{
        _users = [filteredUsers sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2) {
            if (user1.uid == TGTelegraphInstance.clientUserId) {
                return NSOrderedAscending;
            } else if (user2.uid == TGTelegraphInstance.clientUserId) {
                return NSOrderedDescending;
            }
            
            TGCachedConversationMember *member1 = memberDatas[@(user1.uid)];
            TGCachedConversationMember *member2 = memberDatas[@(user2.uid)];
            
            switch (_mode) {
                case TGChannelMembersModeBannedAndRestricted: {
                    if (member1.bannedRights.banReadMessages != member2.bannedRights.banReadMessages) {
                        if (member1.bannedRights.banReadMessages) {
                            return NSOrderedDescending;
                        } else {
                            return NSOrderedAscending;
                        }
                    }
                    
                    if (member1.timestamp > member2.timestamp) {
                        return NSOrderedAscending;
                    } else if (member1.timestamp < member2.timestamp) {
                        return NSOrderedDescending;
                    }
                    
                    return user1.uid < user2.uid;
                }
                case TGChannelMembersModeAdmins: {
                    if (member1.isCreator) {
                        return NSOrderedAscending;
                    }
                    if (member2.isCreator) {
                        return NSOrderedDescending;
                    }
                    
                    if (member1.timestamp > member2.timestamp) {
                        return NSOrderedAscending;
                    } else if (member1.timestamp < member2.timestamp) {
                        return NSOrderedDescending;
                    }
                    
                    return user1.uid < user2.uid;
                }
                default: {
                    if (user1.botKind != user2.botKind) {
                        return user1.botKind < user2.botKind ? NSOrderedAscending : NSOrderedDescending;
                    }
                    
                    if (user1.kind != user2.kind) {
                        return user1.kind < user2.kind ? NSOrderedAscending : NSOrderedDescending;
                    }
                    
                    if (user1.presence.online != user2.presence.online)
                        return user1.presence.online ? NSOrderedAscending : NSOrderedDescending;
                    
                    if ((user1.presence.lastSeen < 0) != (user2.presence.lastSeen < 0))
                        return user1.presence.lastSeen >= 0 ? NSOrderedAscending : NSOrderedDescending;
                    
                    if (user1.presence.online) {
                        return member1.timestamp > member2.timestamp ? NSOrderedAscending : NSOrderedDescending;
                    }
                    
                    if (user1.presence.lastSeen < 0) {
                        return member1.timestamp > member2.timestamp ? NSOrderedAscending : NSOrderedDescending;
                    }
                    
                    return user1.presence.lastSeen > user2.presence.lastSeen ? NSOrderedAscending : NSOrderedDescending;
                }
            }
            
            return NSOrderedSame;
        }];
        _memberDatas = memberDatas;
        
        [self updateEditing];
        
        self.collectionView.hidden = false;
        [_activityIndicator removeFromSuperview];
        _activityIndicator = nil;
        
        while (_usersSection.items.count > (NSUInteger)(_usersSectionPaddingTop + _usersSectionPaddingBottom)) {
            [_usersSection deleteItemAtIndex:_usersSectionPaddingTop];
        }
        
        while ((int)_kickedSection.items.count > 1) {
            [_kickedSection deleteItemAtIndex:1];
        }
        
        for (TGUser *user in _users) {
            TGCachedConversationMember *member = _memberDatas[@(user.uid)];
            TGGroupInfoUserCollectionItem *userItem = [self makeItem:user member:member];
            
            if (_mode == TGChannelMembersModeBannedAndRestricted && member.bannedRights.banReadMessages) {
                [_kickedSection insertItem:userItem atIndex:_kickedSection.items.count];
            } else {
                [_usersSection insertItem:userItem atIndex:_usersSectionPaddingTop + _usersSection.items.count - _usersSectionPaddingTop - _usersSectionPaddingBottom];
            }
        }
        
        [self.menuSections deleteSectionByReference:_usersSection];
        [self.menuSections deleteSectionByReference:_kickedSection];
        
        if ((int)_usersSection.items.count > _usersSectionPaddingTop + _usersSectionPaddingBottom) {
            [self.menuSections addSection:_usersSection];
        }
        
        if ((int)_kickedSection.items.count > 1) {
            [self.menuSections addSection:_kickedSection];
        }
        
        [self.collectionView reloadData];
    });
}

- (bool)canEditMembers {
    bool canEdit = true;
    if (canEdit) {
        switch (_mode) {
            case TGChannelMembersModeAdmins:
                canEdit = _conversation.channelRole == TGChannelRoleCreator;
                break;
            case TGChannelMembersModeBannedAndRestricted:
                canEdit = _conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.canBanUsers;
                break;
            case TGChannelMembersModeMembers:
                canEdit = _conversation.channelRole == TGChannelRoleCreator || (_conversation.channelAdminRights.canBanUsers || ([_conversation.channelAdminRights hasAnyRights] && !_conversation.isChannelGroup));
                break;
        }
    }
    return canEdit;
}

- (void)updateEditing {
    bool canEdit = [self canEditMembers];
    bool hasMembers = false;
    for (int i = _usersSectionPaddingTop; i < (int)_usersSection.items.count - _usersSectionPaddingBottom; i++) {
        TGGroupInfoUserCollectionItem *item = _usersSection.items[i];
        if (item.user.uid != TGTelegraphInstance.clientUserId) {
            hasMembers = true;
        }
    }
    for (int i = 1; i < (int)_kickedSection.items.count; i++) {
        TGGroupInfoUserCollectionItem *item = _kickedSection.items[i];
        if (item.user.uid != TGTelegraphInstance.clientUserId) {
            hasMembers = true;
        }
    }
    
    if (canEdit) {
        if (hasMembers) {
            if (_editing) {
                [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)] animated:false];
            } else {
                [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)], _searchItem] animated:false];
            }
        } else {
            [self.navigationItem setRightBarButtonItems:@[] animated:false];
            if (_editing) {
                [self setLeftBarButtonItem:nil animated:true];
                [self leaveEditingMode:true];
            }
        }
    } else {
        [self setLeftBarButtonItem:nil animated:false];
        if (hasMembers) {
            [self.navigationItem setRightBarButtonItems:@[_searchItem] animated:true];
        } else {
            [self.navigationItem setRightBarButtonItems:@[] animated:true];
        }
        if (_editing) {
            [self leaveEditingMode:true];
        }
    }
}

- (void)loadView {
    [super loadView];
    
    if (_users == nil) {
        self.collectionView.hidden = true;
        
        [_activityIndicator removeFromSuperview];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.frame = CGRectMake(CGFloor((self.view.bounds.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.view.bounds.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
    }
    
    _searchReferenceView = [[UIView alloc] initWithFrame:self.view.bounds];
    _searchReferenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _searchReferenceView.userInteractionEnabled = false;
    [self.view addSubview:_searchReferenceView];
    
    _searchBarOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, 64)];
    _searchBarOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBarOverlay.backgroundColor = UIColorRGB(0xf7f7f7);
    _searchBarOverlay.userInteractionEnabled = false;
    
    _searchBarWrapper = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.navigationController.view.frame.size.width, 64)];
    _searchBarWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBarWrapper.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_searchBarWrapper];
    
    [_searchBarWrapper addSubview:_searchBarOverlay];
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0.0f, 20, _searchBarWrapper.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleHeader];
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

- (void)addMembersPressed {
    TGSelectContactController *selectController = [[TGSelectContactController alloc] initWithCreateGroup:false createEncrypted:false createBroadcast:false createChannel:false inviteToChannel:true showLink:false];
    selectController.ignoreBots = true;
    selectController.channelConversation = _conversation;
    selectController.deselectAutomatically = true;
    NSMutableArray *existingUsers = [[NSMutableArray alloc] init];
    for (TGUser *user in _users) {
        [existingUsers addObject:@(user.uid)];
    }
    selectController.disabledUsers = existingUsers;
    __weak TGChannelMembersController *weakSelf = self;
    selectController.onChannelMembersInvited = ^(NSArray *users) {
        __strong TGChannelMembersController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
            NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
            for (TGUser *user in users) {
                if (updatedMemberDatas[@(user.uid)] != nil) {
                    continue;
                }
                
                updatedMemberDatas[@(user.uid)] = [[TGCachedConversationMember alloc] initWithUid:user.uid isCreator:false adminRights:nil bannedRights:nil timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] inviterId:0 adminInviterId:0 kickedById:0 adminCanManage:false];
                [updatedUsers addObject:user];
            }
            
            [strongSelf setUsers:updatedUsers memberDatas:updatedMemberDatas isFinal:true];
        }
    };
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[selectController]];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options {
    if ([action isEqualToString:@"deleteUser"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
            [self _commitDeleteParticipant:uid completion:nil];
    }
    else if ([action isEqualToString:@"openUser"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:uid];
            
            switch (_mode) {
                case TGChannelMembersModeAdmins: {
                    bool exists = false;
                    for (TGUser *u in _users) {
                        if (u.uid == user.uid) {
                            exists = true;
                            break;
                        }
                    }
                    
                    /*if (exists && ![options[@"force"] boolValue]) {
                        
                        return;
                    }*/
                    
                    __weak TGChannelMembersController *weakSelf = self;
                    TGChannelModeratorController *controller = [[TGChannelModeratorController alloc] initWithConversation:self->_conversation user:user currentSignal:[SSignal single:_memberDatas[@(user.uid)]]];
                    controller.done = ^(TGChannelAdminRights *rights) {
                        __strong TGChannelMembersController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            if (rights != nil) {
                                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                                [progressWindow showWithDelay:0.1];
                                
                                [[[[TGChannelManagementSignals updateChannelAdminRights:strongSelf->_conversation.conversationId accessHash:strongSelf->_conversation.accessHash user:user rights:rights] deliverOn:[SQueue mainQueue]] onDispose:^{
                                    TGDispatchOnMainThread(^{
                                        [progressWindow dismiss:true];
                                    });
                                }] startWithNext:nil error:^(id error) {
                                    __strong TGChannelMembersController *strongSelf = weakSelf;
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
                                    __strong TGChannelMembersController *strongSelf = weakSelf;
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
                                        
                                        NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
                                        NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
                                        
                                        if (rights.hasAnyRights) {
                                            if (updatedMemberDatas[@(user.uid)] == nil) {
                                                [updatedUsers addObject:user];
                                            }
                                            
                                            updatedMemberDatas[@(user.uid)] = [[TGCachedConversationMember alloc] initWithUid:user.uid isCreator:false adminRights:rights bannedRights:nil timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] inviterId:TGTelegraphInstance.clientUserId adminInviterId:TGTelegraphInstance.clientUserId kickedById:0 adminCanManage:true];
                                        } else {
                                            NSUInteger index = 0;
                                            for (TGUser *current in updatedUsers) {
                                                if (current.uid == user.uid) {
                                                    [updatedUsers removeObjectAtIndex:index];
                                                    break;
                                                }
                                                index++;
                                            }
                                            [strongSelf removeParticipantFromList:user.uid];
                                        }
                                        
                                        [strongSelf setUsers:updatedUsers memberDatas:updatedMemberDatas isFinal:true];
                                        [strongSelf updateEditing];
                                        
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
                        __strong TGChannelMembersController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            [strongSelf _commitDeleteParticipant:user.uid completion:^{
                                __strong TGChannelMembersController *strongSelf = weakSelf;
                                if (strongSelf != nil) {
                                    [strongSelf dismissViewControllerAnimated:true completion:nil];
                                }
                            }];
                        }
                    };
                    
                    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller] navigationBarClass:[TGWhiteNavigationBar class]];
                    if ([self inPopover]) {
                        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
                    }
                    
                    [self presentViewController:navigationController animated:true completion:nil];
                    
                    break;
                }
                case TGChannelMembersModeBannedAndRestricted: {
                    TGCachedUserData *memberData = _memberDatas[@(user.uid)];
                    
                    TGChannelBanController *controller = [[TGChannelBanController alloc] initWithConversation:_conversation user:user current:_memberDatas[@(user.uid)] member:memberData != nil ? [SSignal single:memberData] : [TGChannelManagementSignals channelRole:_conversation.conversationId accessHash:_conversation.accessHash user:user]];
                    
                    __weak TGChannelMembersController *weakSelf = self;
                    controller.done = ^(TGChannelBannedRights *rights) {
                        __strong TGChannelMembersController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            if (rights != nil) {
                                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                                [progressWindow show:true];
                                [[[[TGChannelManagementSignals updateChannelBannedRightsAndGetMembership:strongSelf->_conversation.conversationId accessHash:strongSelf->_conversation.accessHash user:[TGDatabaseInstance() loadUser:uid] rights:rights] onDispose:^{
                                    TGDispatchOnMainThread(^{
                                        [progressWindow dismiss:true];
                                    });
                                }] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedConversationMember *updatedMember) {
                                    __strong TGChannelMembersController *strongSelf = weakSelf;
                                    if (strongSelf != nil) {
                                        [TGDatabaseInstance() updateChannelCachedData:strongSelf->_conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                                            if (data == nil) {
                                                data = [[TGCachedConversationData alloc] init];
                                            }
                                            
                                            return [data updateMemberBannedRights:user.uid rights:rights timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] isMember:updatedMember != nil kickedById:TGTelegraphInstance.clientUserId];
                                        }];
                                        
                                        if (rights.numberOfRestrictions == 0) {
                                            NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
                                            NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
                                            TGCachedConversationMember *member = updatedMemberDatas[@(user.uid)];
                                            if (updatedMember != nil) {
                                                member = updatedMember;
                                            } else {
                                                member = [member withUpdatedBannedRights:nil];
                                            }
                                            if (member != nil) {
                                                updatedMemberDatas[@(user.uid)] = member;
                                            }
                                            NSUInteger index = 0;
                                            for (TGUser *current in updatedUsers) {
                                                if (current.uid == user.uid) {
                                                    [updatedUsers removeObjectAtIndex:index];
                                                    [updatedMemberDatas removeObjectForKey:@(current.uid)];
                                                    
                                                    [strongSelf removeParticipantFromList:current.uid];
                                                    
                                                    [strongSelf setUsers:updatedUsers memberDatas:updatedMemberDatas isFinal:true];
                                                    
                                                    break;
                                                }
                                                index++;
                                            }
                                        } else {
                                            NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
                                            NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
                                            TGCachedConversationMember *member = updatedMemberDatas[@(user.uid)];
                                            if (updatedMember != nil) {
                                                member = updatedMember;
                                            } else {
                                                member = [member withUpdatedBannedRights:rights];
                                            }
                                            if (member != nil) {
                                                updatedMemberDatas[@(user.uid)] = member;
                                            }
                                            bool found = false;
                                            for (TGUser *current in updatedUsers) {
                                                if (current.uid == user.uid) {
                                                    found = true;
                                                    break;
                                                }
                                            }
                                            if (!found) {
                                                [updatedUsers addObject:user];
                                            }
                                            
                                            [strongSelf setUsers:updatedUsers memberDatas:updatedMemberDatas isFinal:true];
                                            
                                            [strongSelf updateEditing];
                                        }
                                        
                                        [strongSelf dismissViewControllerAnimated:true completion:nil];
                                    }
                                    [progressWindow dismissWithSuccess];
                                } error:^(__unused id error) {
                                    __strong TGChannelMembersController *strongSelf = weakSelf;
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
                    
                    break;
                }
                default: {
                    if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot) {
                        TGBotUserInfoController *userInfoController = [[TGBotUserInfoController alloc] initWithUid:uid sendCommand:nil];
                        [self.navigationController pushViewController:userInfoController animated:true];
                    }
                    else {
                        TGTelegraphUserInfoController *userInfoController = [[TGTelegraphUserInfoController alloc] initWithUid:uid];
                        [self.navigationController pushViewController:userInfoController animated:true];
                    }
                    
                    break;
                }
            }
        }
    }
}

- (void)_commitDeleteParticipant:(int32_t)userId completion:(void (^)())completion {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.5];
    
    TGUser *user = [TGDatabaseInstance() loadUser:userId];
    
    TGConversation *conversation = _conversation;
    
    SSignal *signal = nil;
    switch (_mode) {
        case TGChannelMembersModeMembers: {
            TGChannelBannedRights *rights = [[TGChannelBannedRights alloc] initWithBanReadMessages:true banSendMessages:false banSendMedia:false banSendStickers:false banSendGifs:false banSendGames:false banSendInline:false banEmbedLinks:false timeout:INT32_MAX];
            signal = [[TGChannelManagementSignals updateChannelBannedRightsAndGetMembership:_conversation.conversationId accessHash:_conversation.accessHash user:user rights:rights] onNext:^(TGCachedConversationMember *updatedMember) {
                [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                    if (data == nil) {
                        data = [[TGCachedConversationData alloc] init];
                    }
                    
                    return [data updateMemberBannedRights:userId rights:rights timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] isMember:updatedMember != nil kickedById:updatedMember.kickedById];
                }];
            }];
            break;
        }
        case TGChannelMembersModeBannedAndRestricted: {
            TGChannelBannedRights *rights = [[TGChannelBannedRights alloc] initWithBanReadMessages:false banSendMessages:false banSendMedia:false banSendStickers:false banSendGifs:false banSendGames:false banSendInline:false banEmbedLinks:false timeout:0];
            signal = [[TGChannelManagementSignals updateChannelBannedRightsAndGetMembership:_conversation.conversationId accessHash:_conversation.accessHash user:user rights:rights] onNext:^(TGCachedConversationMember *updatedMember) {
                [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                    if (data == nil) {
                        data = [[TGCachedConversationData alloc] init];
                    }
                    
                    return [data updateMemberBannedRights:userId rights:rights timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] isMember:updatedMember != nil kickedById:updatedMember.kickedById];
                }];
            }];
            break;
        }
        case TGChannelMembersModeAdmins: {
            signal = [[TGChannelManagementSignals updateChannelAdminRights:conversation.conversationId accessHash:conversation.accessHash user:user rights:nil] onCompletion:^{
                [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                    if (data == nil) {
                        data = [[TGCachedConversationData alloc] init];
                    }
                    
                    return [data removeManagementMember:userId];
                }];
            }];
            break;
        }
    }
    
    __weak TGChannelMembersController *weakSelf = self;
    [[[signal deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil completed:^{
        __strong TGChannelMembersController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
            NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
            NSUInteger index = 0;
            for (TGUser *user in updatedUsers) {
                if (user.uid == userId) {
                    [updatedUsers removeObjectAtIndex:index];
                    [updatedMemberDatas removeObjectForKey:@(user.uid)];
                    
                    [strongSelf removeParticipantFromList:user.uid];
                    
                    strongSelf->_users = updatedUsers;
                    strongSelf->_memberDatas = updatedMemberDatas;
                    
                    break;
                }
                index++;
            }
            
            bool found = false;
            index = 0;
            for (TGGroupInfoUserCollectionItem *item in strongSelf->_usersSection.items) {
                if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]]) {
                    if (item.user.uid == userId) {
                        [strongSelf->_usersSection deleteItemAtIndex:index];
                        if ((int)strongSelf->_usersSection.items.count == strongSelf->_usersSectionPaddingTop + strongSelf->_usersSectionPaddingBottom) {
                            NSUInteger sectionIndex = [strongSelf indexForSection:strongSelf->_usersSection];
                            [strongSelf.menuSections deleteSectionByReference:strongSelf->_usersSection];
                            [strongSelf.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                        } else {
                            [strongSelf.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:[strongSelf indexForSection:strongSelf->_usersSection]]]];
                        }
                        
                        found = true;
                        break;
                    }
                }
                
                index++;
            }
            
            if (!found) {
                index = 0;
                for (TGGroupInfoUserCollectionItem *item in strongSelf->_kickedSection.items) {
                    if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]]) {
                        if (item.user.uid == userId) {
                            [strongSelf->_kickedSection deleteItemAtIndex:index];
                            if (strongSelf->_kickedSection.items.count == 1) {
                                NSUInteger sectionIndex = [strongSelf indexForSection:strongSelf->_kickedSection];
                                [strongSelf.menuSections deleteSectionByReference:strongSelf->_kickedSection];
                                [strongSelf.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                            } else {
                                [strongSelf.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:[strongSelf indexForSection:strongSelf->_kickedSection]]]];
                            }
                            
                            found = true;
                            break;
                        }
                    }
                    
                    index++;
                }
            }
            
            [strongSelf updateEditing];
            [strongSelf updateItemPositions];
            
            if (completion) {
                completion();
            }
        }
    }];
}

- (void)linkPressed {
    TGGroupInfoShareLinkController *controller = [[TGGroupInfoShareLinkController alloc] initWithPeerId:_conversation.conversationId accessHash:_conversation.accessHash currentLink:_privateLink];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)addModeratorPressed {
    if (true) {
        __weak TGChannelMembersController *weakSelf = self;
        TGSearchChatMembersController *searchController = [[TGSearchChatMembersController alloc] initWithPeerId:_conversation.conversationId accessHash:_conversation.accessHash includeContacts:true completion:^(TGUser *user, TGCachedConversationMember *member) {
            __strong TGChannelMembersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (user != nil) {
                    switch (strongSelf->_mode) {
                        case TGChannelMembersModeAdmins: {
                            if (member == nil) {
                                if (strongSelf->_conversation.channelRole != TGChannelRoleCreator && !strongSelf->_conversation.everybodyCanAddMembers && !strongSelf->_conversation.channelAdminRights.canInviteUsers) {
                                    [TGAlertView presentAlertWithTitle:nil message:TGLocalized(@"Channel.Members.AddAdminErrorNotAMember") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                    return;
                                }
                            } else if (member.bannedRights.tlRights.flags != 0) {
                                if (strongSelf->_conversation.channelRole != TGChannelRoleCreator && !strongSelf->_conversation.channelAdminRights.canBanUsers) {
                                    [TGAlertView presentAlertWithTitle:nil message:TGLocalized(@"Channel.Members.AddAdminErrorBlacklisted") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                    
                                    return;
                                }
                            } else if (member.isCreator) {
                                return;
                            }
                            break;
                        }
                        default:
                            break;
                    }
                }
                [strongSelf dismissViewControllerAnimated:true completion:nil];
                if (user != nil) {
                    [strongSelf actionStageActionRequested:@"openUser" options:@{@"uid": @(user.uid)}];
                }
            }
        }];
        
        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[searchController] navigationBarClass:[TGWhiteNavigationBar class]];
        if ([self inPopover]) {
            navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
        }
        
        [self presentViewController:navigationController animated:true completion:nil];
        
        return;
    }
    
    int contactsMode = TGContactsModeRegistered | TGContactsModeManualFirstSection;
    contactsMode |= TGContactsModeIgnorePrivateBots;
    TGGroupInfoSelectContactController *selectContactController = [[TGGroupInfoSelectContactController alloc] initWithContactsMode:contactsMode];
    selectContactController.deselectAutomatically = true;
    selectContactController.delegate = self;
    
    NSMutableArray *disabledUsers = [[NSMutableArray alloc] init];
    
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    for (TGUser *user in _users) {
        [userIds addObject:@(user.uid)];
    }
    
    [disabledUsers addObjectsFromArray:userIds];
    
    selectContactController.disabledUsers = disabledUsers;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[selectContactController] navigationBarClass:[TGWhiteNavigationBar class]];
    if ([self inPopover]) {
        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (SSignal *)modifyMemberRole:(TGUser *)user add:(bool)__unused add {
    __weak TGChannelMembersController *weakSelf = self;
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        __strong TGChannelMembersController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            TGChannelModeratorController *controller = [[TGChannelModeratorController alloc] initWithConversation:strongSelf->_conversation user:user currentSignal:[SSignal single:nil]];
            controller.done = ^(TGChannelAdminRights *rights) {
                __strong TGChannelMembersController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (rights != nil) {
                        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                        [progressWindow showWithDelay:0.1];
                        
                        [[[[TGChannelManagementSignals updateChannelAdminRights:strongSelf->_conversation.conversationId accessHash:strongSelf->_conversation.accessHash user:user rights:rights] deliverOn:[SQueue mainQueue]] onDispose:^{
                            TGDispatchOnMainThread(^{
                                [progressWindow dismiss:true];
                            });
                        }] startWithNext:nil error:^(id error) {
                            __strong TGChannelMembersController *strongSelf = weakSelf;
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
                            __strong TGChannelMembersController *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                [TGDatabaseInstance() updateChannelCachedData:strongSelf->_conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                                    if (data == nil) {
                                        data = [[TGCachedConversationData alloc] init];
                                    }
                                    
                                    return [data addManagementMember:[[TGCachedConversationMember alloc] initWithUid:user.uid isCreator:false adminRights:rights bannedRights:nil timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] inviterId:TGTelegraphInstance.clientUserId adminInviterId:TGTelegraphInstance.clientUserId kickedById:0 adminCanManage:true]];
                                }];

                                NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
                                NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
                                if (updatedMemberDatas[@(user.uid)] == nil) {
                                    [updatedUsers addObject:user];
                                }
                                
                                updatedMemberDatas[@(user.uid)] = [[TGCachedConversationMember alloc] initWithUid:user.uid isCreator:false adminRights:rights bannedRights:nil timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] inviterId:TGTelegraphInstance.clientUserId adminInviterId:TGTelegraphInstance.clientUserId kickedById:0 adminCanManage:true];
                                
                                [strongSelf setUsers:updatedUsers memberDatas:updatedMemberDatas isFinal:true];
                                [strongSelf updateEditing];
                                
                                [strongSelf dismissViewControllerAnimated:true completion:nil];
                            }
                            [progressWindow dismissWithSuccess];
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
            
            [strongSelf presentViewController:navigationController animated:true completion:nil];
        }
        [subscriber putCompletion];
        return nil;
    }] startOn:[SQueue mainQueue]];
}

- (SSignal *)memberRole:(TGUser *)user {
    TGConversation *conversation = _conversation;
    
    return [[SSignal defer:^SSignal *{
        SSignal *roleSignal = [TGChannelManagementSignals channelRole:conversation.conversationId accessHash:conversation.accessHash user:user];
        
        __block TGProgressWindow *progressWindow = nil;
        
        return [[[roleSignal deliverOn:[SQueue mainQueue]] onStart:^{
            progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow show:true];
        }] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
            });
        }];
    }] startOn:[SQueue mainQueue]];
}

- (SSignal *)addManagementMember:(TGUser *)user {
    if (user.kind == TGUserKindGeneric) {
        bool isGroup = _conversation.isChannelGroup;
        __weak TGChannelMembersController *weakSelf = self;
        return [[self memberRole:user] mapToSignal:^SSignal *(TGCachedConversationMember *member) {
            __strong TGChannelMembersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (member == nil) {
                    SPipe *pipe = [[SPipe alloc] init];
                    [[[TGAlertView alloc] initWithTitle:nil message:[[NSString alloc] initWithFormat:isGroup ? TGLocalized(@"Group.Management.ErrorNotMember") : TGLocalized(@"Channel.Management.ErrorNotMember"), user.displayFirstName] cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed) {
                        if (okButtonPressed) {
                            pipe.sink([[strongSelf addMember:user] then:[strongSelf modifyMemberRole:user add:true]]);
                        } else {
                            pipe.sink([SSignal fail:nil]);
                        }
                    }] show];
                    return [[pipe.signalProducer() take:1] switchToLatest];
                } else {
                    return [strongSelf modifyMemberRole:user add:true];
                }
            } else {
                return [SSignal fail:nil];
            }
        }];
    } else {
        return [self modifyMemberRole:user add:true];
    }
}

- (SSignal *)addMember:(TGUser *)user {
    __weak TGChannelMembersController *weakSelf = self;
    TGConversation *conversation = _conversation;
    
    return [[SSignal defer:^SSignal *{
        SSignal *addSignal = [[[TGChannelManagementSignals inviteUsers:conversation.conversationId accessHash:conversation.accessHash users:@[user]] onCompletion:^{
            [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                if (data == nil) {
                    data = [[TGCachedConversationData alloc] init];
                }
                
                return [data addMembers:@[@(user.uid)] timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]];
            }];
        }] onError:^(id error) {
            TGDispatchOnMainThread(^{
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
                } else if ([errorType isEqualToString:@"USER_PRIVACY_RESTRICTED"]) {
                    NSString *format = conversation.isChannelGroup ? TGLocalized(@"Privacy.GroupsAndChannels.InviteToGroupError") : TGLocalized(@"Privacy.GroupsAndChannels.InviteToChannelError");
                    errorText = [[NSString alloc] initWithFormat:format, user.displayFirstName, user.displayFirstName];
                }
                [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            });
        }];
        
        __block TGProgressWindow *progressWindow = nil;
        
        return [[[[addSignal deliverOn:[SQueue mainQueue]] onStart:^{
            progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow show:true];
        }] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
            });
        }] onCompletion:^{
            __strong TGChannelMembersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_mode == TGChannelMembersModeMembers) {
                    NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
                    [updatedUsers addObject:user];
                    NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
                    updatedMemberDatas[@(user.uid)] = [[TGCachedConversationMember alloc] initWithUid:user.uid isCreator:false adminRights:nil bannedRights:nil timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] inviterId:TGTelegraphInstance.clientUserId adminInviterId:0 kickedById:0 adminCanManage:false];
                    
                    [strongSelf setUsers:updatedUsers memberDatas:updatedMemberDatas isFinal:true];
                    [strongSelf updateEditing];
                }
            }
        }];
    }] startOn:[SQueue mainQueue]];
}

- (void)selectContactControllerDidSelectUser:(TGUser *)user {
    if (user == nil) {
        [self dismissViewControllerAnimated:true completion:nil];
        return;
    }
    
    __weak TGChannelMembersController *weakSelf = self;
    if (_conversation.username.length == 0 || true) {
        [self dismissViewControllerAnimated:true completion:nil];
        [[self addManagementMember:user] startWithNext:nil completed:^{
            /*__strong TGChannelMembersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf dismissViewControllerAnimated:true completion:nil];
            }*/
        }];
    } else {
    }
}

- (void)whoCanAddMembersPressed {
    __weak TGChannelMembersController *weakSelf = self;
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ChannelMembers.WhoCanAddMembers.AllMembers") action:@"all"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ChannelMembers.WhoCanAddMembers.Admins") action:@"admins"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(__unused id target, NSString *action) {
        __strong TGChannelMembersController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if ([action isEqualToString:@"all"]) {
                [strongSelf updateWhoCanAddMembers:true];
            } else if ([action isEqualToString:@"admins"]) {
                [strongSelf updateWhoCanAddMembers:false];
            }
        }
    } target:self] showInView:self.view];
}

- (void)updateWhoCanAddMembers:(bool)allMembers {
    if (allMembers != _conversation.everybodyCanAddMembers) {
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow showWithDelay:0.2];
        __weak TGChannelMembersController *weakSelf = self;
        [[[[TGChannelManagementSignals toggleChannelEverybodyCanInviteMembers:_conversation.conversationId accessHash:_conversation.accessHash enabled:allMembers] deliverOn:[SQueue mainQueue]] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
            });
        }] startWithNext:nil completed:^{
            __strong TGChannelMembersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_conversation.everybodyCanAddMembers = allMembers;
            }
        }];
        _inviteControlItem.variant = allMembers ? TGLocalized(@"ChannelMembers.WhoCanAddMembers.AllMembers") : TGLocalized(@"ChannelMembers.WhoCanAddMembers.Admins");
        if (allMembers) {
            _inviteControlComment.text = TGLocalized(@"ChannelMembers.WhoCanAddMembersAllHelp");
        } else {
            _inviteControlComment.text = TGLocalized(@"ChannelMembers.WhoCanAddMembersAdminsHelp");
        }
    }
}

- (void)addBlacklistPressed {
    if (_mode == TGChannelMembersModeBannedAndRestricted) {
        __weak TGChannelMembersController *weakSelf = self;
        TGSearchChatMembersController *searchController = [[TGSearchChatMembersController alloc] initWithPeerId:_conversation.conversationId accessHash:_conversation.accessHash includeContacts:false completion:^(TGUser *user, TGCachedConversationMember *member) {
            __strong TGChannelMembersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                switch (strongSelf->_mode) {
                    case TGChannelMembersModeBannedAndRestricted: {
                        if (member.isCreator || member.adminRights.hasAnyRights) {
                            if (strongSelf->_conversation.channelRole != TGChannelRoleCreator && !member.adminCanManage) {
                                [TGAlertView presentAlertWithTitle:nil message:TGLocalized(@"Channel.Members.AddBannedErrorAdmin") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                
                                return;
                            }
                        }
                        break;
                    }
                    default:
                    break;
                }
                
                [strongSelf dismissViewControllerAnimated:true completion:nil];
                if (user != nil) {
                    [strongSelf actionStageActionRequested:@"openUser" options:@{@"uid": @(user.uid)}];
                }
            }
        }];
        
        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[searchController] navigationBarClass:[TGWhiteNavigationBar class]];
        if ([self inPopover]) {
            navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
        }
        
        [self presentViewController:navigationController animated:true completion:nil];
    }
}

- (void)eventLogPressed {
    [[TGInterfaceManager instance] navigateToChannelLogWithConversation:_conversation animated:true];
}

- (void)backPressed {
    [self.navigationController popViewControllerAnimated:true];
}

- (TGGroupInfoUserCollectionItem *)makeItem:(TGUser *)user member:(TGCachedConversationMember *)member {
    bool canDeleteUsers = _conversation.channelRole == TGChannelRoleCreator || (_conversation.channelAdminRights.canBanUsers || !_conversation.isChannelGroup);
    switch (_mode) {
        case TGChannelMembersModeMembers: {
            break;
        }
        case TGChannelMembersModeAdmins: {
            canDeleteUsers = (_conversation.channelRole == TGChannelRoleCreator || member.adminCanManage);
            break;
        }
        case TGChannelMembersModeBannedAndRestricted: {
            break;
        }
    }
    
    TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
    
    userItem.interfaceHandle = _actionHandle;
    
    bool disabled = false;
    userItem.selectable = (_mode == TGChannelMembersModeAdmins || user.uid != TGTelegraphInstance.clientUserId) && !disabled;
    
    bool canEditInPrinciple = user.uid != TGTelegraphInstance.clientUserId && canDeleteUsers;
    
    bool canEdit = userItem.selectable && canEditInPrinciple;
    
    if (userItem.selectable) {
        if (_mode == TGChannelMembersModeMembers) {
            if (!_conversation.isCreator && (([member.adminRights hasAnyRights] && !member.adminCanManage) || member.isCreator)) {
                canEdit = false;
            }
            
        }
    }
    
    
    [userItem setCanEdit:canEdit];
    userItem.canDelete = canEdit;
    
    [userItem setUser:user];
    [userItem setDisabled:disabled];
    
    if (member != nil) {
        if (_mode == TGChannelMembersModeAdmins) {
            if (member.isCreator) {
                userItem.selectable = false;
                [userItem setCustomStatus:TGLocalized(@"Channel.Management.LabelCreator")];
            } else {
                [userItem setCanEdit:member.adminCanManage];
                TGChannelAdminRights *filtered = nil;
                if (_conversation.isChannelGroup) {
                    filtered = [[TGChannelAdminRights alloc] initWithCanChangeInfo:member.adminRights.canChangeInfo canPostMessages:false canEditMessages:member.adminRights.canEditMessages canDeleteMessages:member.adminRights.canDeleteMessages canBanUsers:member.adminRights.canBanUsers canInviteUsers:member.adminRights.canInviteUsers canChangeInviteLink:member.adminRights.canChangeInviteLink canPinMessages:member.adminRights.canPinMessages canAddAdmins:member.adminRights.canAddAdmins];
                } else {
                    filtered = [[TGChannelAdminRights alloc] initWithCanChangeInfo:member.adminRights.canChangeInfo canPostMessages:member.adminRights.canPostMessages canEditMessages:member.adminRights.canEditMessages canDeleteMessages:member.adminRights.canDeleteMessages canBanUsers:false canInviteUsers:false canChangeInviteLink:false canPinMessages:false canAddAdmins:member.adminRights.canAddAdmins];
                }
                
                TGUser *inviter = [TGDatabaseInstance() loadUser:member.adminInviterId];
                if (member.adminInviterId != 0 && inviter != nil) {
                    [userItem setCustomStatus:[NSString stringWithFormat:TGLocalized(@"Channel.Management.PromotedBy"), inviter.displayName]];
                } else {
                    NSString *format = [TGStringUtils integerValueFormat:@"Channel.Management.LabelRights_" value:member.adminRights.numberOfRights];
                    [userItem setCustomStatus:[NSString stringWithFormat:TGLocalized(format), [NSString stringWithFormat:@"%d", filtered.numberOfRights]]];
                }
            }
        } else if (_mode == TGChannelMembersModeBannedAndRestricted) {
            TGUser *inviter = [TGDatabaseInstance() loadUser:member.kickedById];
            if (member.kickedById != 0 && inviter != nil) {
                [userItem setCustomStatus:[NSString stringWithFormat:TGLocalized(@"Channel.Management.RestrictedBy"), inviter.displayName]];
            }
        }
    }
    NSString *optionTitle = nil;
    switch (_mode) {
        case TGChannelMembersModeMembers: {
            optionTitle = TGLocalized(@"Channel.Members.Kick");
            break;
        }
        case TGChannelMembersModeBannedAndRestricted: {
            optionTitle = TGLocalized(@"Channel.Management.Remove");
            break;
        }
        case TGChannelMembersModeAdmins: {
            optionTitle = TGLocalized(@"Channel.Management.Remove");
            break;
        }
    }
    userItem.optionTitle = optionTitle;
    return userItem;
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
        __weak TGChannelMembersController *weakSelf = self;
        
        SSignal *signal = nil;
        switch (_mode) {
            case TGChannelMembersModeMembers: {
                signal = [TGGlobalMessageSearchSignals searchChannelMembers:searchQuery peerId:_conversation.conversationId accessHash:_conversation.accessHash section:TGGlobalMessageSearchMembersSectionMembers];
                break;
            }
            case TGChannelMembersModeAdmins: {
                NSArray *filteredAdmins = [TGDatabase searchUsersInArray:_users query:searchQuery];
                signal = [SSignal single:@{@"users": filteredAdmins, @"memberDatas": _memberDatas}];
                break;
            }
            case TGChannelMembersModeBannedAndRestricted: {
                signal = [[SSignal combineSignals:@[
                    [TGGlobalMessageSearchSignals searchChannelMembers:searchQuery peerId:_conversation.conversationId accessHash:_conversation.accessHash section:TGGlobalMessageSearchMembersSectionRestricted],
                    [TGGlobalMessageSearchSignals searchChannelMembers:searchQuery peerId:_conversation.conversationId accessHash:_conversation.accessHash section:TGGlobalMessageSearchMembersSectionBanned]
                ]] map:^id(NSArray *items) {
                    NSDictionary *restricted = items[0];
                    NSDictionary *banned = items[1];
                    
                    NSMutableArray *users = [[NSMutableArray alloc] init];
                    NSMutableDictionary *memberDatas = [[NSMutableDictionary alloc] init];
                    
                    NSMutableSet *userIds = [[NSMutableSet alloc] init];
                    for (NSArray *set in @[restricted[@"users"], banned[@"users"]]) {
                        for (TGUser *user in set) {
                            if (![userIds containsObject:@(user.uid)]) {
                                [userIds addObject:@(user.uid)];
                                [users addObject:user];
                            }
                        }
                    }
                    
                    for (NSDictionary *dict in @[restricted[@"memberDatas"], banned[@"memberDatas"]]) {
                        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id value, __unused BOOL *stop) {
                            if (memberDatas[key] == nil) {
                                memberDatas[key] = value;
                            }
                        }];
                    }
                    
                    return @{@"users": users, @"memberDatas": memberDatas};
                }];
                break;
            }
        }
        
        [_searchDisposable setDisposable:[[[SSignal combineSignals:@[signal]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *values) {
            __strong TGChannelMembersController *strongSelf = weakSelf;
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
    
    TGGroupInfoUserCollectionItem *item = [self makeItem:user member:_searchResultsMemberDatas[@(user.uid)]];
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

- (void)removeParticipantFromList:(int32_t)uid {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    TGUser *user = _searchResultUsers[indexPath.section][indexPath.row];
    [self actionStageActionRequested:@"openUser" options:@{@"uid": @(user.uid), @"force": @true}];
}


@end
