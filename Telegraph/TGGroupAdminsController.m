#import "TGGroupAdminsController.h"

#import "ActionStage.h"
#import "TGGroupManagementSignals.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGSwitchCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGGroupInfoUserCollectionItem.h"

#import "TGSearchBar.h"
#import "TGSearchDisplayMixin.h"

#import "TGBotUserInfoController.h"
#import "TGTelegraphUserInfoController.h"

@interface TGGroupAdminsController () <ASWatcher, TGSearchBarDelegate> {
    int64_t _peerId;
    TGConversation *_conversation;
    NSSet *_referenceChatAdminUids;
    
    TGCollectionMenuSection *_allMembersSection;
    TGSwitchCollectionItem *_allMembersSwitchItem;
    TGCommentCollectionItem *_allMembersCommentItem;
    
    TGCollectionMenuSection *_usersSection;
    
    UIView *_progressView;

    SMetaDisposable *_toggleAdminsDisposable;
    
    UIView *_searchBarOverlay;
    UIBarButtonItem *_searchButtonItem;
    UIView *_searchReferenceView;
    UIView *_searchBarWrapper;
    TGSearchBar *_searchBar;
    
    NSString *_filterText;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGGroupAdminsController

- (instancetype)initWithPeerId:(int64_t)peerId {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        
        self.title = TGLocalized(@"ChatAdmins.Title");
        
        _searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchPressed)];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _toggleAdminsDisposable = [[SMetaDisposable alloc] init];
        
        _allMembersSwitchItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"ChatAdmins.AllMembersAreAdmins") isOn:true];
        __weak TGGroupAdminsController *weakSelf = self;
        _allMembersSwitchItem.toggled = ^(bool value, __unused TGSwitchCollectionItem *item) {
            __strong TGGroupAdminsController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf toggleAllMembersAreAdmins:value];
            }
        };
        _allMembersCommentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"ChatAdmins.AllMembersAreAdminsOnHelp")];
        _allMembersSection = [[TGCollectionMenuSection alloc] initWithItems:@[_allMembersSwitchItem, _allMembersCommentItem]];
        _allMembersSection.insets = UIEdgeInsetsMake(35.0, 0.0, 31.0, 0.0);
        [self.menuSections addSection:_allMembersSection];
        
        _usersSection = [[TGCollectionMenuSection alloc] init];
        [self.menuSections addSection:_usersSection];
        
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:_peerId];
        _referenceChatAdminUids = conversation.chatParticipants.chatAdminUids;
        [self setConversation:conversation];
        
        [ActionStageInstance() watchForPaths:@[
            [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _peerId],
            @"/tg/userdatachanges",
            @"/tg/userpresencechanges",
            @"/as/updateRelativeTimestamps"
        ] watcher:self];
        
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversationExtended/(%lld)", _peerId] options:@{@"conversationId": @(_peerId)} watcher:TGTelegraphInstance];
    }
    return self;
}

- (void)dealloc {
    [ActionStageInstance() removeWatcher:self];
    [_toggleAdminsDisposable dispose];
}

- (void)loadView {
    [super loadView];
    
    _progressView = [[UIView alloc] initWithFrame:self.view.bounds];
    _progressView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    _progressView.alpha = 0.0f;
    [self.view addSubview:_progressView];
    
    _searchBarOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, 63)];
    _searchBarOverlay.alpha = 0.0f;
    _searchBarOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBarOverlay.backgroundColor = [UIColor whiteColor];
    _searchBarOverlay.userInteractionEnabled = false;
    
    _searchBarWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, 63)];
    _searchBarWrapper.clipsToBounds = true;
    _searchBarWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBarWrapper.backgroundColor = [UIColor whiteColor];
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0.0f, 20, _searchBarWrapper.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleLightPlain];
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
    
    _searchReferenceView = [[UIView alloc] initWithFrame:self.view.bounds];
    _searchReferenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _searchReferenceView.userInteractionEnabled = false;
    [self.view addSubview:_searchReferenceView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.view addSubview:_searchBarWrapper];
    [UIView animateWithDuration:0.3 animations:^{
        _searchBarWrapper.alpha = 1.0f;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [UIView animateWithDuration:0.3 animations:^{
        _searchBarWrapper.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [_searchBarWrapper removeFromSuperview];
        }
    }];

}

- (void)setInProgress:(bool)inProgress {
    [UIView animateWithDuration:0.4 delay:0.2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _progressView.alpha = inProgress ? 1.0f : 0.0f;
    } completion:nil];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments {
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _peerId]]) {
        [self setConversation:((SGraphObjectNode *)resource).object];
    }
}

- (void)setConversation:(TGConversation *)conversation {
    NSMutableArray *users = [[NSMutableArray alloc] init];
    for (NSNumber *nUid in conversation.chatParticipants.chatParticipantUids) {
        TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
        if (user != nil) {
            [users addObject:user];
        }
    }
    
    TGDispatchOnMainThread(^{
        [self setConversation:conversation andUsers:users];
    });
}

- (NSArray *)sortedUsers:(NSArray *)users chatAdminUids:(NSSet *)chatAdminUids {
    int32_t selfUid = TGTelegraphInstance.clientUserId;
    return [users sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2)
    {
        if (user1.botKind != user2.botKind) {
            return user1.botKind < user2.botKind ? NSOrderedAscending : NSOrderedDescending;
        }
        
        if (user1.kind != user2.kind) {
            return user1.kind < user2.kind ? NSOrderedAscending : NSOrderedDescending;
        }
        
        if (user1.uid == selfUid) {
            return NSOrderedAscending;
        } else if (user2.uid == selfUid) {
            return NSOrderedDescending;
        }
        
        bool isAdmin1 = [chatAdminUids containsObject:@(user1.uid)];
        bool isAdmin2 = [chatAdminUids containsObject:@(user2.uid)];
        
        if (isAdmin1 != isAdmin2) {
            if (isAdmin1) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }
        
        if (user1.presence.online != user2.presence.online)
            return user1.presence.online ? NSOrderedAscending : NSOrderedDescending;
        
        if ((user1.presence.lastSeen < 0) != (user2.presence.lastSeen < 0))
            return user1.presence.lastSeen >= 0 ? NSOrderedAscending : NSOrderedDescending;
        
        return user1.presence.lastSeen > user2.presence.lastSeen ? NSOrderedAscending : NSOrderedDescending;
    }];
}

- (void)setConversation:(TGConversation *)conversation andUsers:(NSArray *)users {
    _conversation = conversation;
    
    NSArray *filteredUsers = users;
    if (_filterText.length != 0) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        NSString *query = [_filterText lowercaseString];
        for (TGUser *user in users) {
            if ([[user.firstName lowercaseString] hasPrefix:query] || [[user.lastName lowercaseString] hasPrefix:query]) {
                [result addObject:user];
            }
        }
        
        filteredUsers = result;
    }
    
    if (_conversation.hasAdmins) {
        if (self.navigationItem.rightBarButtonItem != _searchButtonItem) {
            [self setRightBarButtonItem:_searchButtonItem];
        }
    } else {
        if (self.navigationItem.rightBarButtonItem == _searchButtonItem) {
            [self setRightBarButtonItem:nil];
        }
    }
    
    _allMembersSwitchItem.isOn = !_conversation.hasAdmins;
    _allMembersCommentItem.text = !_conversation.hasAdmins ? TGLocalized(@"ChatAdmins.AllMembersAreAdminsOnHelp") : TGLocalized(@"ChatAdmins.AllMembersAreAdminsOffHelp");
    
    NSMutableArray *currentUserIds = [[NSMutableArray alloc] init];
    for (TGGroupInfoUserCollectionItem *userItem in _usersSection.items) {
        [currentUserIds addObject:@(userItem.user.uid)];
    }
    
    NSMutableArray *updatedUserIds = [[NSMutableArray alloc] init];
    for (TGUser *user in [self sortedUsers:filteredUsers chatAdminUids:_referenceChatAdminUids]) {
        [updatedUserIds addObject:@(user.uid)];
    }
    
    if ([currentUserIds isEqualToArray:updatedUserIds]) {
        for (TGGroupInfoUserCollectionItem *userItem in _usersSection.items) {
            userItem.selectable = false;//userItem.user.uid != TGTelegraphInstance.clientUserId;
            userItem.displaySwitch = true;
            if (userItem.user.uid == TGTelegraphInstance.clientUserId) {
                userItem.enableSwitch = false;
                [userItem setSwitchIsOn:true animated:true];
                userItem.customStatus = TGLocalized(@"ChatAdmins.AdminLabel");
            } else {
                userItem.enableSwitch = conversation.hasAdmins;
                if (conversation.hasAdmins) {
                    bool isAdmin = [conversation.chatParticipants.chatAdminUids containsObject:@(userItem.user.uid)];
                    [userItem setSwitchIsOn:isAdmin animated:false];
                    userItem.customStatus = isAdmin ? TGLocalized(@"ChatAdmins.AdminLabel") : nil;
                } else {
                    [userItem setSwitchIsOn:!conversation.hasAdmins animated:false];
                    userItem.customStatus = nil;
                }
            }
        }
    } else {
        while (_usersSection.items.count != 0) {
            [_usersSection deleteItemAtIndex:0];
        }
        
        __weak TGGroupAdminsController *weakSelf = self;
        for (TGUser *user in [self sortedUsers:filteredUsers chatAdminUids:_referenceChatAdminUids]) {
            TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
            userItem.interfaceHandle = _actionHandle;
            
            userItem.selectable = false;//user.uid != TGTelegraphInstance.clientUserId;
            userItem.displaySwitch = true;
            if (user.uid == TGTelegraphInstance.clientUserId) {
                userItem.enableSwitch = false;
                userItem.switchIsOn = true;
                userItem.customStatus = TGLocalized(@"ChatAdmins.AdminLabel");
            } else {
                userItem.enableSwitch = conversation.hasAdmins;
                if (conversation.hasAdmins) {
                    bool isAdmin = [conversation.chatParticipants.chatAdminUids containsObject:@(user.uid)];
                    userItem.switchIsOn = isAdmin;
                    userItem.customStatus = isAdmin ? TGLocalized(@"ChatAdmins.AdminLabel") : nil;
                } else {
                    userItem.switchIsOn = !conversation.hasAdmins;
                    userItem.customStatus = nil;
                }
                userItem.toggled = ^(bool value) {
                    __strong TGGroupAdminsController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf toggleUserIsAdmin:user isAdmin:value];
                    }
                };
            }
            
            [userItem setCanEdit:false];
            
            [userItem setUser:user];
            [_usersSection addItem:userItem];
        }
        
        [self.collectionView reloadData];
    }
}

- (void)toggleAllMembersAreAdmins:(bool)allMembersAreAdmins {
    [self setInProgress:true];
    
    __weak TGGroupAdminsController *weakSelf = self;
    [_toggleAdminsDisposable setDisposable:[[[TGGroupManagementSignals toggleGroupHasAdmins:_peerId hasAdmins:!allMembersAreAdmins] onDispose:^{
        TGDispatchOnMainThread(^{
            __strong TGGroupAdminsController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setInProgress:false];
            }
        });
    }] startWithNext:nil]];
}

- (void)toggleUserIsAdmin:(TGUser *)user isAdmin:(bool)isAdmin {
    [self setInProgress:true];
    
    __weak TGGroupAdminsController *weakSelf = self;
    [_toggleAdminsDisposable setDisposable:[[[TGGroupManagementSignals toggleUserIsAdmin:_peerId user:user isAdmin:isAdmin] onDispose:^{
        TGDispatchOnMainThread(^{
            __strong TGGroupAdminsController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setInProgress:false];
            }
        });
    }] startWithNext:nil]];
}

- (void)searchPressed {
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
            frame.origin.y = -64;
            _searchBarOverlay.alpha = 0.0f;
        }
        else
        {
            frame.origin.y = 0;
            if (self.navigationController.modalPresentationStyle == UIModalPresentationFormSheet)
                frame.origin.y -= 20;
            
            _searchBarOverlay.alpha = 1.0f;
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

- (void)searchBar:(UISearchBar *)__unused searchBar textDidChange:(NSString *)searchText {
    if (!TGStringCompare(searchText, _filterText)) {
        _filterText = searchText;
        
        [self setConversation:_conversation];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)__unused searchBar {
    [self setSearchHidden:false animated:true];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)__unused searchBar {
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    if (_filterText.length != 0) {
        _filterText = nil;
        
        [self setConversation:_conversation];
    }
    
    [self setSearchHidden:true animated:true];
}

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
}

@end
