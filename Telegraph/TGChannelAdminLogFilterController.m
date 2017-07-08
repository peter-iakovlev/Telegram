#import "TGChannelAdminLogFilterController.h"
#import "TGTelegraph.h"

#import "TGHeaderCollectionItem.h"
#import "TGGroupInfoUserCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGCheckCollectionItem.h"
#import "TGStringUtils.h"

@interface TGChannelAdminLogFilterController () {
    NSArray *_usersFilter;
    
    id<SDisposable> _disposable;
    
    NSArray<TGUser *> *_users;
    NSDictionary *_memberDatas;
    
    TGSwitchCollectionItem *_allEventsItem;
    TGCheckCollectionItem *_restrictionsItem;
    TGCheckCollectionItem *_adminsItem;
    TGCheckCollectionItem *_newMembersItem;
    TGCheckCollectionItem *_infoItem;
    TGCheckCollectionItem *_deletedMessagesItem;
    TGCheckCollectionItem *_editedMessagesItem;
    TGCheckCollectionItem *_pinnedMessagesItem;
    TGCheckCollectionItem *_leavingMembersItem;
    
    TGSwitchCollectionItem *_allUsersItem;
    TGCollectionMenuSection *_usersSection;
}

@end

@implementation TGChannelAdminLogFilterController

static bool filterIsFull(TGChannelEventFilter filter) {
    return filter.join && filter.leave && filter.invite && filter.ban && filter.unban && filter.kick && filter.unban && filter.promote && filter.demote && filter.info && filter.settings && filter.pinned && filter.edit && filter.del;
}

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash isChannel:(bool)isChannel filter:(TGChannelEventFilter)filter usersFilter:(NSArray *)usersFilter {
    self = [super init];
    if (self != nil) {
        _usersFilter = usersFilter;
        
        self.title = TGLocalized(@"Channel.AdminLogFilter.Title");
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        self.navigationItem.rightBarButtonItem.enabled = false;
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.AdminLogFilter.EventsTitle")]];
        
        __weak TGChannelAdminLogFilterController *weakSelf = self;
        
        TGCollectionMenuSection *eventsSection = [[TGCollectionMenuSection alloc] initWithItems:items];
        eventsSection.insets = UIEdgeInsetsMake(24.0f, 0.0f, 24.0f, 0.0f);
        _allEventsItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.AdminLogFilter.EventsAll") isOn:filterIsFull(filter)];
        _allEventsItem.toggled = ^(bool value, __unused TGSwitchCollectionItem *item) {
            __strong TGChannelAdminLogFilterController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf toggleAllEvens:value];
            }
        };
        [eventsSection addItem:_allEventsItem];
        
        _restrictionsItem.requiresFullSeparator = true;
        _restrictionsItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.AdminLogFilter.EventsRestrictions") action:@selector(eventsItemPressed:)];
        _restrictionsItem.isChecked = filter.ban && filter.unban;
        _restrictionsItem.alignToRight = true;
        if (!isChannel) {
            [eventsSection addItem:_restrictionsItem];
        }
        
        _adminsItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.AdminLogFilter.EventsAdmins") action:@selector(eventsItemPressed:)];
        _adminsItem.isChecked = filter.promote && filter.demote;
        _adminsItem.alignToRight = true;
        [eventsSection addItem:_adminsItem];
        
        _newMembersItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.AdminLogFilter.EventsNewMembers") action:@selector(eventsItemPressed:)];
        _newMembersItem.isChecked = filter.invite && filter.join;
        _newMembersItem.alignToRight = true;
        if (true || !isChannel) {
            [eventsSection addItem:_newMembersItem];
        }
        
        _infoItem = [[TGCheckCollectionItem alloc] initWithTitle:isChannel ? TGLocalized(@"Channel.AdminLogFilter.ChannelEventsInfo") : TGLocalized(@"Channel.AdminLogFilter.EventsInfo") action:@selector(eventsItemPressed:)];
        _infoItem.isChecked = filter.info;
        _infoItem.alignToRight = true;
        [eventsSection addItem:_infoItem];
        
        _deletedMessagesItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.AdminLogFilter.EventsDeletedMessages") action:@selector(eventsItemPressed:)];
        _deletedMessagesItem.isChecked = filter.del;
        _deletedMessagesItem.alignToRight = true;
        [eventsSection addItem:_deletedMessagesItem];
        
        _editedMessagesItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.AdminLogFilter.EventsEditedMessages") action:@selector(eventsItemPressed:)];
        _editedMessagesItem.isChecked = filter.edit;
        _editedMessagesItem.alignToRight = true;
        [eventsSection addItem:_editedMessagesItem];
        
        _pinnedMessagesItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.AdminLogFilter.EventsPinned") action:@selector(eventsItemPressed:)];
        _pinnedMessagesItem.isChecked = filter.pinned;
        _pinnedMessagesItem.alignToRight = true;
        if (!isChannel) {
            [eventsSection addItem:_pinnedMessagesItem];
        }
        
        _leavingMembersItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.AdminLogFilter.EventsLeaving") action:@selector(eventsItemPressed:)];
        _leavingMembersItem.isChecked = filter.leave;
        _leavingMembersItem.alignToRight = true;
        if (true || !isChannel) {
            [eventsSection addItem:_leavingMembersItem];
        }
        
        [self.menuSections addSection:eventsSection];
        
        _allUsersItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.AdminLogFilter.AdminsAll") isOn:_usersFilter.count == 0];
        _allUsersItem.fullSeparator = true;
        _allUsersItem.toggled = ^(bool value, __unused TGSwitchCollectionItem *item) {
            __strong TGChannelAdminLogFilterController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf toggleAllUsers:value];
            }
        };
        
        _usersSection = [[TGCollectionMenuSection alloc] initWithItems:@[[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.AdminLogFilter.AdminsTitle")], _allUsersItem]];
        [self.menuSections addSection:_usersSection];
        
        _disposable = [[[TGChannelManagementSignals channelAdmins:peerId accessHash:accessHash offset:0 count:100] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict) {
            __strong TGChannelAdminLogFilterController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setUsers:dict[@"users"] memberDatas:dict[@"memberDatas"] isFinal:true];
            }
        }];
        
        [self updateDone];
    }
    return self;
}

- (void)dealloc {
    [_disposable dispose];
}

- (void)cancelPressed {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)donePressed {
    if (_completion) {
        /*typedef struct {
            bool join;
            bool leave;
            bool invite;
            bool ban;
            bool unban;
            bool kick;
            bool unkick;
            bool promote;
            bool demote;
            bool info;
            bool settings;
            bool pinned;
            bool edit;
            bool del;
        } TGChannelEventFilter;*/
        
        TGChannelEventFilter filter;
        filter.join = _newMembersItem.isChecked;
        filter.leave = _leavingMembersItem.isChecked;
        filter.invite = _newMembersItem.isChecked;
        filter.ban = _restrictionsItem.isChecked;
        filter.unban = _restrictionsItem.isChecked;
        filter.kick = _leavingMembersItem.isChecked;
        filter.unkick = _newMembersItem.isChecked;
        filter.promote = _adminsItem.isChecked;
        filter.demote = _adminsItem.isChecked;
        filter.info = _infoItem.isChecked;
        filter.settings = _infoItem.isChecked;
        filter.pinned = _pinnedMessagesItem.isChecked;
        filter.edit = _editedMessagesItem.isChecked;
        filter.del = _deletedMessagesItem.isChecked;
        
        bool allUsersSelected = true;
        NSMutableArray *usersFilter = [[NSMutableArray alloc] init];
        for (TGGroupInfoUserCollectionItem *item in _usersSection.items) {
            if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]]) {
                if (item.checkIsOn) {
                    [usersFilter addObject:@(item.user.uid)];
                } else {
                    allUsersSelected = false;
                }
            }
        }
        
        _completion(filter, usersFilter, allUsersSelected);
    }
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)setUsers:(NSArray *)users memberDatas:(NSDictionary *)memberDatas isFinal:(bool)__unused isFinal {
    self.navigationItem.rightBarButtonItem.enabled = true;
    _users = [users sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2) {
        if (user1.uid == TGTelegraphInstance.clientUserId) {
            return NSOrderedAscending;
        } else if (user2.uid == TGTelegraphInstance.clientUserId) {
            return NSOrderedDescending;
        }
        
        TGCachedConversationMember *member1 = memberDatas[@(user1.uid)];
        TGCachedConversationMember *member2 = memberDatas[@(user2.uid)];
        
        if (member1.timestamp > member2.timestamp) {
            return NSOrderedAscending;
        } else if (member1.timestamp < member2.timestamp) {
            return NSOrderedDescending;
        }
        
        return user1.uid < user2.uid;
        
        return NSOrderedSame;
    }];
    _memberDatas = memberDatas;
    
    self.collectionView.hidden = false;
    //[_activityIndicator removeFromSuperview];
    //_activityIndicator = nil;
    
    while (_usersSection.items.count > (NSUInteger)(2)) {
        [_usersSection deleteItemAtIndex:2];
    }
    
    bool hasDisabled = false;
    bool first = true;
    for (TGUser *user in _users) {
        TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
        
        if (first) {
            first = false;
            userItem.requiresFullSeparator = true;
        }
        
        //userItem.interfaceHandle = _actionHandle;
        
        userItem.selectable = true;
        userItem.deselectAutomatically = true;
        
        [userItem setCanEdit:false];
        
        [userItem setUser:user];
        [userItem setDisabled:false];
        
        userItem.displayCheck = true;
        userItem.checkIsOn = _usersFilter.count == 0 || [_usersFilter containsObject:@(user.uid)];
        if (!userItem.checkIsOn) {
            hasDisabled = true;
        }
        __weak TGChannelAdminLogFilterController *weakSelf = self;
        userItem.pressed = ^{
            __strong TGChannelAdminLogFilterController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf toggleUserChecked:user.uid];
            }
        };
        
        TGCachedConversationMember *member = memberDatas[@(user.uid)];
        if (member != nil) {
            if (member.isCreator) {
                [userItem setCustomStatus:TGLocalized(@"Channel.Management.LabelCreator")];
            } else {
                [userItem setCustomStatus:TGLocalized(@"Channel.Management.LabelEditor")];
            }
        }
        [_usersSection insertItem:userItem atIndex:2 + _usersSection.items.count - 2];
    }
    
    _allUsersItem.isOn = !hasDisabled;
    
    [self.collectionView reloadData];
}

- (void)eventsItemPressed:(TGCheckCollectionItem *)item {
    [item setIsChecked:!item.isChecked];
    [self syncEventsChecked];
}

- (void)toggleAllEvens:(bool)value {
    _restrictionsItem.isChecked = value;
    _adminsItem.isChecked = value;
    _newMembersItem.isChecked = value;
    _infoItem.isChecked = value;
    _deletedMessagesItem.isChecked = value;
    _editedMessagesItem.isChecked = value;
    _pinnedMessagesItem.isChecked = value;
    _leavingMembersItem.isChecked = value;
    
    [self updateDone];
}

- (void)syncEventsChecked {
    bool all = true;
    if (!_restrictionsItem.isChecked) {
        all = false;
    }
    if (!_adminsItem.isChecked) {
        all = false;
    }
    if (!_newMembersItem.isChecked) {
        all = false;
    }
    if (!_infoItem.isChecked) {
        all = false;
    }
    if (!_deletedMessagesItem.isChecked) {
        all = false;
    }
    if (!_editedMessagesItem.isChecked) {
        all = false;
    }
    if (!_pinnedMessagesItem.isChecked) {
        all = false;
    }
    if (!_leavingMembersItem.isChecked) {
        all = false;
    }
    if (_allEventsItem.isOn != all) {
        [_allEventsItem setIsOn:all animated:true];
    }
    
    [self updateDone];
}

- (void)toggleAllUsers:(bool)value {
    if (value) {
        for (TGGroupInfoUserCollectionItem *item in _usersSection.items) {
            if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]]) {
                item.checkIsOn = value;
            }
        }
    } else {
        for (TGGroupInfoUserCollectionItem *item in _usersSection.items) {
            if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]]) {
                item.checkIsOn = false;
            }
        }
    }
}

- (void)toggleUserChecked:(int32_t)userId {
    bool allUsers = _users.count != 0;
    for (TGGroupInfoUserCollectionItem *item in _usersSection.items) {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]]) {
            if (item.user.uid == userId) {
                item.checkIsOn = !item.checkIsOn;
            }
            if (!item.checkIsOn) {
                allUsers = false;
            }
        }
    }
    [_allUsersItem setIsOn:allUsers animated:true];
}

- (void)updateDone {
    NSArray<TGCheckCollectionItem *> *items = @[
        _restrictionsItem,
        _adminsItem,
        _newMembersItem,
        _infoItem,
        _deletedMessagesItem,
        _editedMessagesItem,
        _pinnedMessagesItem,
        _leavingMembersItem
    ];
    bool enabled = false;
    for (TGCheckCollectionItem *item in items) {
        if (item.isChecked) {
            enabled = true;
        }
    }

    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

@end
