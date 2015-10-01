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

@interface TGChannelMembersController () <ASWatcher, TGGroupInfoSelectContactControllerDelegate> {
    TGConversation *_conversation;
    TGChannelMembersMode _mode;
    id<SDisposable> _channelMembersDisposable;
    NSString *_privateLink;
    
    TGCollectionMenuSection *_adminSection;
    TGCollectionMenuSection *_addModeratorSection;
    TGCollectionMenuSection *_usersSection;
    
    NSArray *_users;
    NSDictionary *_memberDatas;
    
    UIActivityIndicatorView *_activityIndicator;
    bool _editing;
    
    id<SDisposable> _cachedDataDisposable;
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
        
        switch (mode) {
            case TGChannelMembersModeMembers:
                self.title = TGLocalized(@"Channel.Members.Title");
                break;
            case TGChannelMembersModeBlacklist:
                self.title = TGLocalized(@"Channel.BlackList.Title");
                break;
            case TGChannelMembersModeAdmins:
                self.title = TGLocalized(@"Channel.Management.Title");
                break;
        }
        
        TGButtonCollectionItem *addMemberItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Members.AddMembers") action:@selector(addMembersPressed)];
        NSMutableArray *adminSectionItems = [[NSMutableArray alloc] init];
        [adminSectionItems addObject:addMemberItem];

        if (_conversation.username.length == 0) {
            TGButtonCollectionItem *linkItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Members.InviteLink") action:@selector(linkPressed)];
            [adminSectionItems addObject:linkItem];
        }
        
        TGCommentCollectionItem *addMemberHelpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.Members.AddMembersHelp")];
        [adminSectionItems addObject:addMemberHelpItem];
        
        TGButtonCollectionItem *addModeratorItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Management.AddModerator") action:@selector(addModeratorPressed)];
        TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Channel.Management.AddModeratorHelp")];
        
        _addModeratorSection = [[TGCollectionMenuSection alloc] initWithItems:@[addModeratorItem, commentItem]];
        
        _adminSection = [[TGCollectionMenuSection alloc] initWithItems:adminSectionItems];
        
        switch (mode) {
            case TGChannelMembersModeMembers: {
                if (conversation.channelRole == TGChannelRoleCreator) {
                    [self.menuSections addSection:_adminSection];
                }
                break;
            }
            case TGChannelMembersModeAdmins: {
                if (conversation.channelRole == TGChannelRoleCreator) {
                    [self.menuSections addSection:_addModeratorSection];
                }
                break;
            }
            default:
                break;
        }
        
        _usersSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
        [self.menuSections addSection:_usersSection];
        
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
            case TGChannelMembersModeBlacklist: {
                SSignal *cachedSignal = [[[TGDatabaseInstance() channelCachedData:_conversation.conversationId] take:1] mapToSignal:^SSignal *(TGCachedConversationData *cachedData) {
                    if (cachedData.blacklistMembers.count == 0) {
                        return [SSignal complete];
                    } else {
                        NSMutableArray *users = [[NSMutableArray alloc] init];
                        NSMutableDictionary *memberDatas = [[NSMutableDictionary alloc] init];
                        
                        for (TGCachedConversationMember *member in cachedData.blacklistMembers) {
                            TGUser *user = [TGDatabaseInstance() loadUser:member.uid];
                            if (user != nil) {
                                [users addObject:user];
                                memberDatas[@(member.uid)] = member;
                            }
                        }
                        return [SSignal single:@{@"users": users, @"memberDatas": memberDatas}];
                    }
                }];
                signal = [cachedSignal then:[[TGChannelManagementSignals channelBlacklistMembers:conversation.conversationId accessHash:conversation.accessHash offset:0 count:128] onNext:^(NSDictionary *dict) {
                    NSMutableArray *userIds = [[NSMutableArray alloc] init];
                    for (TGUser *user in dict[@"users"]) {
                        [userIds addObject:@(user.uid)];
                    }
                    
                    [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                        if (data == nil) {
                            data = [[TGCachedConversationData alloc] init];
                        }
                        return [data updateBlacklistMembers:[dict[@"memberDatas"] allValues]];
                    }];
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
                [self setUsers:dict[@"users"] memberDatas:dict[@"memberDatas"]];
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
    
    if (_users.count != 0) {
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:true];
    }
}

- (void)setUsers:(NSArray *)users memberDatas:(NSDictionary *)memberDatas {
    TGDispatchOnMainThread(^{
        _users = [users sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2) {
            if (user1.uid == TGTelegraphInstance.clientUserId) {
                return NSOrderedAscending;
            } else if (user2.uid == TGTelegraphInstance.clientUserId) {
                return NSOrderedDescending;
            }
            
            TGCachedConversationMember *member1 = memberDatas[@(user1.uid)];
            TGCachedConversationMember *member2 = memberDatas[@(user2.uid)];
            
            switch (_mode) {
                case TGChannelMembersModeBlacklist: {
                    if (member1.timestamp > member2.timestamp) {
                        return NSOrderedAscending;
                    } else if (member1.timestamp < member2.timestamp) {
                        return NSOrderedDescending;
                    }
                    
                    return user1.uid < user2.uid;
                }
                case TGChannelMembersModeAdmins: {
                    return member1.role > member2.role ? NSOrderedAscending : NSOrderedDescending;
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
        
        while (_usersSection.items.count != 0) {
            [_usersSection deleteItemAtIndex:0];
        }
        
        bool canDeleteUsers = _conversation.channelRole == TGChannelRoleCreator || _conversation.channelRole == TGChannelRoleModerator || _conversation.channelRole == TGChannelRolePublisher;
        switch (_mode) {
            case TGChannelMembersModeMembers: {
                break;
            }
            case TGChannelMembersModeAdmins: {
                canDeleteUsers = _conversation.channelRole == TGChannelRoleCreator;
                break;
            }
            case TGChannelMembersModeBlacklist: {
                break;
            }
        }
        
        for (TGUser *user in _users) {
            TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
            
            userItem.interfaceHandle = _actionHandle;
            
            bool disabled = false;
            userItem.selectable = user.uid != TGTelegraphInstance.clientUserId && !disabled;
            
            bool canEditInPrinciple = user.uid != TGTelegraphInstance.clientUserId && canDeleteUsers;
            
            bool canEdit = userItem.selectable && canEditInPrinciple;
            [userItem setCanEdit:canEdit];
            
            [userItem setUser:user];
            [userItem setDisabled:disabled];
            
            TGCachedConversationMember *member = memberDatas[@(user.uid)];
            if (member != nil) {
                if (_mode == TGChannelMembersModeAdmins) {
                    switch (member.role) {
                        case TGChannelRoleCreator:
                            [userItem setCustomStatus:TGLocalized(@"Channel.Management.LabelCreator")];
                            break;
                        case TGChannelRoleModerator:
                            [userItem setCustomStatus:TGLocalized(@"Channel.Management.LabelModerator")];
                            break;
                        case TGChannelRolePublisher:
                            [userItem setCustomStatus:TGLocalized(@"Channel.Management.LabelEditor")];
                            break;
                        default:
                            break;
                    }
                }
            }
            NSString *optionTitle = nil;
            switch (_mode) {
                case TGChannelMembersModeMembers: {
                    optionTitle = TGLocalized(@"Channel.Members.Kick");
                    break;
                }
                case TGChannelMembersModeBlacklist: {
                    optionTitle = TGLocalized(@"Channel.Management.Remove");
                    break;
                }
                case TGChannelMembersModeAdmins: {
                    optionTitle = TGLocalized(@"Channel.Management.Remove");
                    break;
                }
            }
            userItem.optionTitle = optionTitle;
            [_usersSection addItem:userItem];
        }
        
        [self.collectionView reloadData];
    });
}

- (void)updateEditing {
    bool canEdit = false;
    for (TGGroupInfoUserCollectionItem *item in _usersSection.items) {
        if (item.user.uid != TGTelegraphInstance.clientUserId) {
            canEdit = true;
        }
    }
    
    if (canEdit) {
        switch (_mode) {
            case TGChannelMembersModeAdmins:
                canEdit = _conversation.channelRole == TGChannelRoleCreator;
                break;
            case TGChannelMembersModeBlacklist:
                canEdit = _conversation.channelRole == TGChannelRoleCreator || _conversation.channelRole == TGChannelRoleModerator || _conversation.channelRole == TGChannelRoleModerator;
            case TGChannelMembersModeMembers:
                canEdit = _conversation.channelRole == TGChannelRoleCreator || _conversation.channelRole == TGChannelRoleModerator || _conversation.channelRole == TGChannelRoleModerator;
        }
    }
    
    if (canEdit) {
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
    } else {
        [self setLeftBarButtonItem:nil animated:false];
        [self setRightBarButtonItem:nil animated:false];
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
}

- (void)addMembersPressed {
    TGSelectContactController *selectController = [[TGSelectContactController alloc] initWithCreateGroup:false createEncrypted:false createBroadcast:false createChannel:false inviteToChannel:true];
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
                
                updatedMemberDatas[@(user.uid)] = [[TGCachedConversationMember alloc] initWithUid:user.uid role:TGChannelRoleMember timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]];
                [updatedUsers addObject:user];
            }
            
            [strongSelf setUsers:updatedUsers memberDatas:updatedMemberDatas];
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
            [self _commitDeleteParticipant:uid];
    }
    else if ([action isEqualToString:@"openUser"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:uid];
            
            switch (_mode) {
                case TGChannelMembersModeAdmins: {
                    /*TGChannelModeratorController *controller = [[TGChannelModeratorController alloc] initWithConversation:_conversation user:user member:_memberDatas[@(user.uid)]];
                    __weak TGChannelMembersController *weakSelf = self;
                    TGConversation *conversation = _conversation;
                    controller.done = ^(TGCachedConversationMember *member) {
                        __strong TGChannelMembersController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            if (member == nil) {
                                SSignal *signal = [[TGChannelManagementSignals channelChangeRole:_conversation.conversationId accessHash:_conversation.accessHash user:user role:TGChannelRoleMember] onCompletion:^{
                                    [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                                        if (data == nil) {
                                            data = [[TGCachedConversationData alloc] init];
                                        }
                                        
                                        return [data removeManagementMember:user.uid];
                                    }];
                                }];
                                
                                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                                [progressWindow show:true];
                                
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
                                            if (user.uid == uid) {
                                                [updatedUsers removeObjectAtIndex:index];
                                                [updatedMemberDatas removeObjectForKey:@(user.uid)];
                                                [strongSelf->_usersSection deleteItemAtIndex:index];
                                                
                                                strongSelf->_users = updatedUsers;
                                                strongSelf->_memberDatas = updatedMemberDatas;
                                                
                                                [strongSelf updateEditing];
                                                
                                                [strongSelf.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:[strongSelf indexForSection:strongSelf->_usersSection]]]];
                                                [strongSelf updateItemPositions];
                                                
                                                break;
                                            }
                                            index++;
                                        }
                                        
                                        [strongSelf.navigationController popToViewController:strongSelf animated:true];
                                    }
                                }];
                            } else if (member.role != ((TGCachedConversationMember *)strongSelf->_memberDatas[@(user.uid)]).role) {
                                SSignal *signal = [[TGChannelManagementSignals channelChangeRole:_conversation.conversationId accessHash:_conversation.accessHash user:user role:member.role] onCompletion:^{
                                    [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                                        if (data == nil) {
                                            data = [[TGCachedConversationData alloc] init];
                                        }
                                        
                                        return [data addManagementMember:member];
                                    }];
                                }];
                                
                                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                                [progressWindow show:true];
                                
                                [[[signal deliverOn:[SQueue mainQueue]] onDispose:^{
                                    TGDispatchOnMainThread(^{
                                        [progressWindow dismiss:true];
                                    });
                                }] startWithNext:nil completed:^{
                                    __strong TGChannelMembersController *strongSelf = weakSelf;
                                    if (strongSelf != nil) {
                                        NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
                                        NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
                                        updatedMemberDatas[@(uid)] = [[TGCachedConversationMember alloc] initWithUid:uid role:member.role timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]];
                                        
                                        [strongSelf setUsers:updatedUsers memberDatas:updatedMemberDatas];
                                        [strongSelf.navigationController popToViewController:strongSelf animated:true];
                                    }
                                }];
                            } else {
                                [strongSelf.navigationController popToViewController:strongSelf animated:true];
                            }
                        }
                    };
                    [self.navigationController pushViewController:controller animated:true];
                    
                    break;*/
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

- (void)_commitDeleteParticipant:(int32_t)userId {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.5];
    
    TGUser *user = [TGDatabaseInstance() loadUser:userId];
    
    TGConversation *conversation = _conversation;
    
    SSignal *signal = nil;
    switch (_mode) {
        case TGChannelMembersModeMembers: {
            signal = [[TGChannelManagementSignals channelChangeMemberKicked:_conversation.conversationId accessHash:_conversation.accessHash user:user kicked:true] onCompletion:^{
                [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                    if (data == nil) {
                        data = [[TGCachedConversationData alloc] init];
                    }
                    
                    return [data blacklistMember:userId timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]];
                }];
            }];
            break;
        }
        case TGChannelMembersModeBlacklist: {
            signal = [[TGChannelManagementSignals channelChangeMemberKicked:_conversation.conversationId accessHash:_conversation.accessHash user:user kicked:false] onCompletion:^{
                [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                    if (data == nil) {
                        data = [[TGCachedConversationData alloc] init];
                    }
                    
                    return [data unblacklistMember:userId timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]];
                }];
            }];
            break;
        }
        case TGChannelMembersModeAdmins: {
            signal = [[TGChannelManagementSignals channelChangeRole:_conversation.conversationId accessHash:_conversation.accessHash user:user role:TGChannelRoleMember] onCompletion:^{
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
                    [strongSelf->_usersSection deleteItemAtIndex:index];
                    
                    strongSelf->_users = updatedUsers;
                    strongSelf->_memberDatas = updatedMemberDatas;
                    
                    [strongSelf updateEditing];
                    
                    [strongSelf.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:[strongSelf indexForSection:strongSelf->_usersSection]]]];
                    [strongSelf updateItemPositions];
                    
                    break;
                }
                index++;
            }
        }
    }];
}

- (void)linkPressed {
    TGGroupInfoShareLinkController *controller = [[TGGroupInfoShareLinkController alloc] initWithPeerId:_conversation.conversationId accessHash:_conversation.accessHash currentLink:_privateLink];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)addModeratorPressed {
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

- (SSignal *)modifyMemberRole:(TGUser *)user role:(TGChannelRole)role {
    __weak TGChannelMembersController *weakSelf = self;
    TGConversation *conversation = _conversation;
    
    return [[SSignal defer:^SSignal *{
        SSignal *changeSignal = [[TGChannelManagementSignals channelChangeRole:conversation.conversationId accessHash:conversation.accessHash user:user role:role] onCompletion:^{
            [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                if (data == nil) {
                    data = [[TGCachedConversationData alloc] init];
                }
                
                return [data addManagementMember:[[TGCachedConversationMember alloc] initWithUid:user.uid role:role timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]]];
            }];
        }];
        
        __block TGProgressWindow *progressWindow = nil;
        
        return [[[[changeSignal deliverOn:[SQueue mainQueue]] onStart:^{
            progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow show:true];
        }] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
            });
        }] onCompletion:^{
            __strong TGChannelMembersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSMutableArray *updatedUsers = [[NSMutableArray alloc] initWithArray:strongSelf->_users];
                NSMutableDictionary *updatedMemberDatas = [[NSMutableDictionary alloc] initWithDictionary:strongSelf->_memberDatas];
                if (updatedMemberDatas[@(user.uid)] == nil) {
                    [updatedUsers addObject:user];
                }
                
                updatedMemberDatas[@(user.uid)] = [[TGCachedConversationMember alloc] initWithUid:user.uid role:role timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]];
                
                [strongSelf setUsers:updatedUsers memberDatas:updatedMemberDatas];
                [strongSelf updateEditing];
            }
        }];
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

- (SSignal *)addManagementMember:(TGUser *)user role:(TGChannelRole)role {
    __weak TGChannelMembersController *weakSelf = self;
    return [[self memberRole:user] mapToSignal:^SSignal *(TGCachedConversationMember *member) {
        __strong TGChannelMembersController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (member == nil) {
                SPipe *pipe = [[SPipe alloc] init];
                [[[TGAlertView alloc] initWithTitle:nil message:[[NSString alloc] initWithFormat: TGLocalized(@"Channel.Management.ErrorNotMember"), user.displayFirstName] cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed) {
                    if (okButtonPressed) {
                        pipe.sink([[strongSelf addMember:user] then:[strongSelf modifyMemberRole:user role:role]]);
                    } else {
                        pipe.sink([SSignal fail:nil]);
                    }
                }] show];
                return [[pipe.signalProducer() take:1] switchToLatest];
            } else {
                return [strongSelf modifyMemberRole:user role:role];
            }
        } else {
            return [SSignal fail:nil];
        }
    }];
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
                    errorText = TGLocalized(@"Channel.ErrorAddBlocked");
                } else if ([errorType isEqual:@"USERS_TOO_MUCH"]) {
                    errorText = TGLocalized(@"Channel.ErrorAddTooMuch");
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
                    updatedMemberDatas[@(user.uid)] = [[TGCachedConversationMember alloc] initWithUid:user.uid role:TGChannelRoleMember timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]];
                    
                    [strongSelf setUsers:updatedUsers memberDatas:updatedMemberDatas];
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
        [[self addManagementMember:user role:TGChannelRolePublisher] startWithNext:nil completed:^{
            __strong TGChannelMembersController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf dismissViewControllerAnimated:true completion:nil];
            }
        }];
    } else {
        __unused TGChannelModeratorController *controller = [[TGChannelModeratorController alloc] initWithConversation:_conversation user:user member:nil];
        __weak TGChannelMembersController *weakSelf = self;
        controller.done = ^(TGCachedConversationMember *member) {
            if (member == nil) {
                member = [[TGCachedConversationMember alloc] initWithUid:user.uid role:TGChannelRoleModerator timestamp:0];
            }
            
            [[self addManagementMember:user role:member.role] startWithNext:nil completed:^{
                __strong TGChannelMembersController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf dismissViewControllerAnimated:true completion:nil];
                }
            }];
        };
        if ([self.presentedViewController isKindOfClass:[TGNavigationController class]]) {
            [(UINavigationController *)self.presentedViewController pushViewController:controller animated:true];
        }
    }
}

@end
