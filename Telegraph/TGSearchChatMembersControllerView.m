#import "TGSearchChatMembersControllerView.h"

#import "TGSearchBar.h"
#import "TGListsTableView.h"
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

static void adjustCellForSelectionEnabled(TGContactCell *contactCell, bool selectionEnabled, bool animated)
{
    UITableViewCellSelectionStyle selectionStyle = selectionEnabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
    if (contactCell.isDisabled)
        selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (contactCell.selectionStyle != selectionStyle)
        contactCell.selectionStyle = selectionStyle;
    
    [contactCell setSelectionEnabled:selectionEnabled animated:animated];
}

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

static void adjustCellForUser(TGContactCell *contactCell, TGUser *user, bool animated, __unused bool isSearch, bool isGlobalSearch, NSString *searchString)
{
    contactCell.hideAvatar = user.uid <= 0;
    contactCell.itemId = user.uid;
    contactCell.user = user;
    
    contactCell.avatarUrl = user.photoUrlSmall;
    
    if (user.firstName.length == 0)
    {
        contactCell.titleTextFirst = user.lastName;
        contactCell.titleTextSecond = nil;
    }
    else
    {
        contactCell.titleTextFirst = user.firstName;
        contactCell.titleTextSecond = user.lastName;
    }
    
    [contactCell setBoldMode:2];
    
    bool subtitleActive = false;
    
    if (isGlobalSearch || (searchString.length != 0 && isGlobalSearch && [user.userName.lowercaseString hasPrefix:[searchString lowercaseString]]))
    {
        NSString *string = [[NSString alloc] initWithFormat:@"@%@", user.userName];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: TGSystemFontOfSize(14.0f)}];
        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorRGB(0x888888) range:NSMakeRange(0, string.length)];
        if (searchString.length != 0)
        {
            NSRange range = [[string lowercaseString] rangeOfString:[searchString lowercaseString]];
            if (range.location != NSNotFound)
            {
                if (range.location == 1)
                {
                    range.location = 0;
                    range.length++;
                }
                [attributedString addAttribute:NSForegroundColorAttributeName value:TGAccentColor() range:range];
            }
        }
        contactCell.subtitleAttributedText = attributedString;
    }
    else
        contactCell.subtitleText = subtitleStringForUser(user, &subtitleActive);
    
    contactCell.subtitleActive = subtitleActive;
    
    [contactCell updateFlags:false animated:false force:true];
    contactCell.isDisabled = false;
    [contactCell resetView:animated];
}

@interface TGSearchChatMembersControllerView () <UITableViewDataSource, UITableViewDelegate, TGSearchDisplayMixinDelegate> {
    void (^_updateNavigationBarHidden)(bool hidden, bool animated);
    
    int64_t _peerId;
    int64_t _accessHash;
    void (^_completion)(TGUser *, TGCachedConversationMember *);
    bool _includeContacts;
    
    TGSearchBar *_searchBar;
    TGSearchDisplayMixin *_searchMixin;
    
    NSArray<TGUser *> *_users;
    NSDictionary<NSNumber *, TGCachedConversationMember *> *_memberDatas;
    NSArray<NSArray<TGUser *> *> *_searchResultUsers;
    NSDictionary<NSNumber *, TGCachedConversationMember *> *_searchResultsMemberDatas;
    
    NSString *_searchString;
    
    SMetaDisposable *_searchDisposable;
    
    NSArray *_reusableSectionHeaders;
}

@end

@implementation TGSearchChatMembersControllerView

- (instancetype)initWithFrame:(CGRect)frame updateNavigationBarHidden:(void (^)(bool hidden, bool animated))updateNavigationBarHidden peerId:(int64_t)peerId accessHash:(int64_t)accessHash includeContacts:(bool)includeContacts completion:(void (^)(TGUser *, TGCachedConversationMember *))completion {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _searchDisposable = [[SMetaDisposable alloc] init];
        _reusableSectionHeaders = [[NSArray alloc] initWithObjects:[[NSMutableArray alloc] init], [[NSMutableArray alloc] init], nil];
        
        _updateNavigationBarHidden = [updateNavigationBarHidden copy];
        _peerId = peerId;
        _accessHash = accessHash;
        _completion = [completion copy];
        _includeContacts = includeContacts;
        
        _tableView = [[UITableView alloc] init];
        
        self.backgroundColor = [UIColor whiteColor];
        
        _tableView = [[TGListsTableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 51.0f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (iosMajorVersion() >= 7) {
            _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            _tableView.separatorColor = TGSeparatorColor();
            _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 65.0f, 0.0f, 0.0f);
        }
        
        _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleLightPlain];
        
        [(TGListsTableView *)_tableView adjustBehaviour];
        
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchBar.placeholder = TGLocalized(@"Common.Search");
        
        for (UIView *subview in [_searchBar subviews]) {
            if ([subview conformsToProtocol:@protocol(UITextInputTraits)]) {
                @try {
                    [(id<UITextInputTraits>)subview setReturnKeyType:UIReturnKeyDone];
                    [(id<UITextInputTraits>)subview setEnablesReturnKeyAutomatically:true];
                } @catch (__unused NSException *e) {
                }
            }
        }
        
        _searchMixin = [[TGSearchDisplayMixin alloc] init];
        _searchMixin.delegate = self;
        _searchMixin.searchBar = _searchBar;
        
        _tableView.tableHeaderView = _searchBar;
        
        [self addSubview:_tableView];
        
        
    }
    return self;
}

- (void)dealloc {
    [_searchDisposable dispose];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)__unused previousInset controllerInset:(UIEdgeInsets)controllerInset navigationBarShouldBeHidden:(bool)navigationBarShouldBeHidden {
    if (navigationBarShouldBeHidden) {
        [_tableView setContentOffset:CGPointMake(0, -_tableView.contentInset.top) animated:false];
    }
    
    if (_searchMixin != nil)
        [_searchMixin controllerInsetUpdated:controllerInset];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _tableView.frame = self.bounds;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TGUser *user = nil;
    if (tableView == _tableView) {
        user = _users[indexPath.row];
    } else {
        user = _searchResultUsers[indexPath.section][indexPath.row];
    }
    
    static NSString *contactCellIdentifier = @"ContactCell";
    TGContactCell *contactCell = [tableView dequeueReusableCellWithIdentifier:contactCellIdentifier];
    if (contactCell == nil)
    {
        contactCell = [[TGContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactCellIdentifier selectionControls:false editingControls:false];
        
        //contactCell.actionHandle = _actionHandle;
    }
    
    contactCell.contactSelected = false;
    
    adjustCellForSelectionEnabled(contactCell, false, false);
    
    adjustCellForUser(contactCell, user, false, tableView != _tableView, indexPath.section == 2, _searchString);
    
    return contactCell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_tableView == tableView) {
        return 1;
    } else {
        return _searchResultUsers.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_tableView == tableView) {
        return _users.count;
    } else {
        return _searchResultUsers[section].count;
    }
}

- (UITableView *)createTableViewForSearchMixin:(TGSearchDisplayMixin *)__unused searchMixin {
    UITableView *tableView = [[UITableView alloc] init];
    
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    tableView.tableFooterView = [[UIView alloc] init];
    
    tableView.rowHeight = 51;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return tableView;
}

- (UIView *)referenceViewForSearchResults {
    return _tableView;
}

- (void)searchMixinWillActivate:(bool)animated {
    _tableView.scrollEnabled = false;
    if (_updateNavigationBarHidden) {
        _updateNavigationBarHidden(true, animated);
    }
}

- (void)searchMixinWillDeactivate:(bool)animated
{
    _tableView.scrollEnabled = true;
    if (_updateNavigationBarHidden) {
        _updateNavigationBarHidden(false, animated);
    }
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
        __weak TGSearchChatMembersControllerView *weakSelf = self;
        [_searchDisposable setDisposable:[[[SSignal combineSignals:@[[TGGlobalMessageSearchSignals searchChannelMembers:searchQuery peerId:_peerId accessHash:_accessHash section:TGGlobalMessageSearchMembersSectionMembers], _includeContacts ? [TGGlobalMessageSearchSignals searchContacts:searchQuery] : [SSignal single:@[]], [TGGlobalMessageSearchSignals searchUsersAndChannels:searchQuery]]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *values) {
            __strong TGSearchChatMembersControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSDictionary *memberData = values[0];
                NSArray *contactData = values[1];
                NSArray *globalData = values[2];
                
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

- (void)setUsers:(NSArray<TGUser *> *)users memberDatas:(NSDictionary<NSNumber *, TGCachedConversationMember *> *)memberDatas {
    NSMutableArray *filteredUsers = [[NSMutableArray alloc] init];
    for (TGUser *user in users) {
        if (user.uid != TGTelegraphInstance.clientUserId) {
            [filteredUsers addObject:user];
        }
    }
    TGDispatchOnMainThread(^{
        if (!TGObjectCompare(_users, filteredUsers)) {
            _users = filteredUsers;
            _memberDatas = memberDatas;
            [_tableView reloadData];
        }
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    TGUser *user = nil;
    if (tableView == _tableView) {
        user = _users[indexPath.row];
    } else {
        user = _searchResultUsers[indexPath.section][indexPath.row];
    }
    
    if (_completion) {
        _completion(user, _memberDatas[@(user.uid)] ?: _searchResultsMemberDatas[@(user.uid)]);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView) {
        return nil;
    } else if (section == 0) {
        return _searchResultUsers[section].count == 0 ? nil : [self generateSectionHeader:TGLocalized(@"Contacts.MemberSearchSectionTitleGroup") first:false wide:true];
    } else if (section == 1) {
        return _searchResultUsers[section].count == 0 ? nil : [self generateSectionHeader:TGLocalized(@"Contacts.Title") first:false wide:true];
    } else if (section == 2) {
        return _searchResultUsers[section].count == 0 ? nil : [self generateSectionHeader:TGLocalized(@"Contacts.GlobalSearch") first:false wide:true];
    }
    
    return nil;
}

- (UIView *)generateSectionHeader:(NSString *)title first:(bool)first wide:(bool)wide
{
    UIView *sectionContainer = nil;
    
    NSMutableArray *reusableList = [_reusableSectionHeaders objectAtIndex:first ? 0 : 1];
    
    for (UIView *view in reusableList)
    {
        if (view.superview == nil)
        {
            sectionContainer = view;
            break;
        }
    }
    
    if (sectionContainer == nil)
    {
        sectionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        
        sectionContainer.clipsToBounds = false;
        sectionContainer.opaque = false;
        
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, first ? 0 : -1, 10, first ? 10 : 11)];
        sectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        sectionView.backgroundColor = UIColorRGB(0xf2f2f2);
        [sectionContainer addSubview:sectionView];
        
        UILabel *sectionLabel = [[UILabel alloc] init];
        sectionLabel.tag = 100;
        sectionLabel.backgroundColor = sectionView.backgroundColor;
        sectionLabel.textColor = [UIColor blackColor];
        sectionLabel.numberOfLines = 1;
        
        [sectionContainer addSubview:sectionLabel];
        
        [reusableList addObject:sectionContainer];
    }
    
    UILabel *sectionLabel = (UILabel *)[sectionContainer viewWithTag:100];
    sectionLabel.font = wide ? TGMediumSystemFontOfSize(14) : TGMediumSystemFontOfSize(12);
    sectionLabel.text = title;
    sectionLabel.textColor = wide ? UIColorRGB(0x8e8e93) : UIColorRGB(0x8e8e93);
    [sectionLabel sizeToFit];
    if (wide)
    {
        sectionLabel.frame = CGRectMake(8.0f, 4.0f + TGRetinaPixel, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
    }
    else
    {
        sectionLabel.frame = CGRectMake(14.0f, 5.0 + TGRetinaPixel, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
    }
    
    return sectionContainer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView) {
            return 0.0f;
    } else if (section < (NSInteger)_searchResultUsers.count) {
        return _searchResultUsers[section].count == 0 ? 0.0f : 28.0f;
    }
    
    return 0.0f;
}

@end
