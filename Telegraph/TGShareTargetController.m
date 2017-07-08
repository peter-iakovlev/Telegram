#import "TGShareTargetController.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGModernBarButton.h"
#import "TGListsTableView.h"
#import "TGSearchBar.h"
#import "TGSearchDisplayMixin.h"


#import "TGProgressWindow.h"

#import "TGShareTargetCell.h"
#import "TGDialogListRecentPeersCell.h"
#import "TGHighlightableButton.h"

#import "TGUser.h"
#import "TGConversation.h"
#import "TGChatListSignals.h"
#import "TGRecentPeersSignals.h"
#import "TGGlobalMessageSearchSignals.h"
#import "TGDialogListRecentPeers.h"
#import "TGChatSearchController.h"

#import "TGSelectContactController.h"

@interface TGShareTargetController () <UITableViewDelegate, UITableViewDataSource, TGSearchDisplayMixinDelegate>
{
    bool _isDisplayingSearch;
    
    NSMutableDictionary *_peers;
    
    NSArray *_currentPeers;
    NSArray *_recentPeers;
    
    NSArray *_searchResultsSections;
    NSArray *_recentSearchResultsSections;
    
    id<SDisposable> _chatList;
    SMetaDisposable *_recentDisposable;
    SMetaDisposable *_searchDisposable;
    
    NSMutableArray *_selectedPeerIds;
    NSArray *_foundPeers;
    
    NSArray *_reusableSectionHeaders;
    
    TGListsTableView *_tableView;
    TGSearchBar *_searchBar;
    TGSearchDisplayMixin *_searchMixin;
    UIView *_searchTopBackgroundView;
    
    UIView *_buttonContainer;
}
@end

@implementation TGShareTargetController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _reusableSectionHeaders = [[NSArray alloc] initWithObjects:[[NSMutableArray alloc] init], [[NSMutableArray alloc] init], nil];
        
        _searchDisposable = [[SMetaDisposable alloc] init];
        _foundPeers = [[NSMutableArray alloc] init];
        
        _selectedPeerIds = [[NSMutableArray alloc] init];
        _peers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    
    [_chatList dispose];
    [_searchDisposable dispose];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect tableFrame = self.view.bounds;
    _tableView = [[TGListsTableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.opaque = true;
    _tableView.backgroundColor = nil;
    _tableView.showsVerticalScrollIndicator = true;
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleLightPlain];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _searchTopBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320.0f)];
    _searchTopBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_tableView insertSubview:_searchTopBackgroundView atIndex:0];
    
    _searchMixin = [[TGSearchDisplayMixin alloc] init];
    _searchMixin.searchBar = _searchBar;
    _searchMixin.delegate = self;
    
    _tableView.tableHeaderView = _searchBar;
    
    _searchBar.placeholder = TGLocalized(@"Common.Search");
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (iosMajorVersion() >= 7) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = TGSeparatorColor();
        _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 65.0f, 0.0f, 0.0f);
    }
    
    _tableView.alwaysBounceVertical = true;
    _tableView.bounces = true;
    
    [self setTableHidden:true];
    
    [self.view addSubview:_tableView];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewDidLoad
{
    [self setTitleText:TGLocalized(@"Share.Title")];
    
    __weak TGShareTargetController *weakSelf = self;
    _chatList = [[[[[TGChatListSignals chatListWithLimit:256] take:1] map:^id(NSArray<TGConversation *> *next)
    {
        __strong TGShareTargetController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            return [strongSelf processedPeers:next];
        }
        return nil;
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next) {
        __strong TGShareTargetController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf setPeers:next];
        }
    }];
}

- (UIBarButtonItem *)controllerRightBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Compose.NewGroup") style:UIBarButtonItemStylePlain target:self action:@selector(newGroupPressed)];
}

#pragma mark -

- (void)newGroupPressed
{
    [self.navigationController pushViewController:[[TGSelectContactController alloc] initWithCreateGroup:true createEncrypted:false createBroadcast:false createChannel:false inviteToChannel:false showLink:false] animated:true];
}

- (void)shareButtonPressed
{
    if (self.completionBlock != nil)
        self.completionBlock(_selectedPeerIds);
}

#pragma mark -

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    if (self.navigationBarShouldBeHidden)
    {
        [_tableView setContentOffset:CGPointMake(0, -_tableView.contentInset.top) animated:false];
    }
    
    if (_searchMixin != nil)
        [_searchMixin controllerInsetUpdated:self.controllerInset];
    
    [super controllerInsetUpdated:previousInset];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (_searchMixin != nil)
        [_searchMixin controllerLayoutUpdated:[TGViewController screenSizeForInterfaceOrientation:toInterfaceOrientation]];
}

#pragma mark -

- (void)setTableHidden:(bool)tableHidden
{
    _tableView.hidden = tableHidden;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView)
        return 1;
    
    return _searchResultsSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)__unused section
{
    if (tableView == _tableView)
        return [self currentPeers].count;
    else
        return [(NSArray *)_searchResultsSections[section][@"items"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        static NSString *CellIdentifier = @"TC";
        TGShareTargetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [[TGShareTargetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        TGConversation *peer = [self currentPeers][indexPath.row];
        int64_t peerId = [TGShareTargetController _peerIdForPeer:peer];
        [cell setupWithPeer:peer];
        [cell setChecked:[_selectedPeerIds containsObject:@(peerId)] animated:false];
        return cell;
    }
    else
    {
        id result = [_searchResultsSections[indexPath.section][@"items"] objectAtIndex:indexPath.row];
        if ([result isKindOfClass:[TGDialogListRecentPeers class]]) {
            TGDialogListRecentPeers *recentPeers = result;
            TGDialogListRecentPeersCell *cell = (TGDialogListRecentPeersCell *)[tableView dequeueReusableCellWithIdentifier:@"TGDialogListRecentPeersCell"];
            if (cell == nil) {
                cell = [[TGDialogListRecentPeersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGDialogListRecentPeersCell"];
                __weak TGShareTargetController *weakSelf = self;
                cell.peerSelected = ^(id peer) {
                    __strong TGShareTargetController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        int64_t peerId = 0;
                        if ([peer isKindOfClass:[TGUser class]]) {
                            peerId = ((TGUser *)peer).uid;
                        } else if ([peer isKindOfClass:[TGConversation class]]) {
                            peerId = ((TGConversation *)peer).conversationId;
                        }
                        
                        strongSelf->_currentPeers = nil;
                        
                        bool selected = [strongSelf togglePeerSelected:peerId fromSearch:true];
                        if (selected)
                            [strongSelf addFoundPeer:peer];
                            
                        [strongSelf->_searchMixin setIsActive:false animated:true];
                        [strongSelf->_tableView reloadData];
                        
                        [strongSelf updateSelectionInterface];
                    }
                };
            }
            [cell setRecentPeers:recentPeers unreadCounts:nil];
            [cell updateSelectedPeerIds:_selectedPeerIds];
            
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"TC";
            TGShareTargetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[TGShareTargetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            TGConversation *peer = result;
            int64_t peerId = [TGShareTargetController _peerIdForPeer:peer];
            [cell setupWithPeer:peer];
            [cell setChecked:[_selectedPeerIds containsObject:@(peerId)] animated:false];
            return cell;
            
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView)
        return nil;
    
    if (_searchResultsSections[section][@"title"] == nil)
        return nil;
    
    bool clear = false;
    if ([_searchResultsSections[section][@"type"] isEqual:@"recent"]) {
        NSArray *items = _searchResultsSections[section][@"items"];
        if (items.count != 0 && [items[0] isKindOfClass:[TGDialogListRecentPeers class]]) {
            clear = false;
        } else {
            clear = true;
        }
    }
    
    return [self generateSectionHeader:_searchResultsSections[section][@"title"] first:false wide:true clear:clear];
}

- (UIView *)generateSectionHeader:(NSString *)title first:(bool)first wide:(bool)wide clear:(bool)clear
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
        sectionView.backgroundColor = UIColorRGB(0xf7f7f7);
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
    sectionLabel.font = wide ? TGBoldSystemFontOfSize(12.0f) : TGBoldSystemFontOfSize(17);
    sectionLabel.text = [title uppercaseString];
    sectionLabel.textColor = wide ? UIColorRGB(0x8e8e93) : [UIColor blackColor];
    [sectionLabel sizeToFit];
    if (wide)
    {
        sectionLabel.frame = CGRectMake(14.0f, 6.0f + TGRetinaPixel, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
    }
    else
    {
        sectionLabel.frame = CGRectMake(14.0f, TGRetinaPixel, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
    }
    
    UIView *clearButton = [sectionContainer viewWithTag:200];
    clearButton.hidden = !clear;
    
    return sectionContainer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView)
        return 0.0f;
    
    if (((NSString *)_searchResultsSections[section][@"title"]).length == 0)
        return 0.0f;
    
    return 28.0f;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        return 48.0f;
    }
    else
    {
        id result = [_searchResultsSections[indexPath.section][@"items"] objectAtIndex:indexPath.row];
        if ([result isKindOfClass:[TGDialogListRecentPeers class]]) {
            return [TGDialogListRecentPeersCell heightForWidth:self.view.frame.size.width count:((TGDialogListRecentPeers *)result).peers.count expanded:false];
        }
        
        return 48.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
    bool fromSearch = false;
    id peer = nil;
    if (tableView == _tableView)
    {
        peer = [self currentPeers][indexPath.row];
    }
    else
    {
        fromSearch = true;
        peer = [_searchResultsSections[indexPath.section][@"items"] objectAtIndex:indexPath.row];
    }
    
    int64_t peerId = [TGShareTargetController _peerIdForPeer:peer];
 
    if (fromSearch)
        _currentPeers = nil;
    
    bool selected = [self togglePeerSelected:peerId fromSearch:fromSearch];
    if (fromSearch)
    {
        if (selected)
            [self addFoundPeer:peer];
        
        [_searchMixin setIsActive:false animated:true];
        [_tableView reloadData];
    }
    
    [self updateSelectionInterface];
}

- (bool)togglePeerSelected:(int64_t)peerId fromSearch:(bool)fromSearch
{
    bool checked = false;
    if ([_selectedPeerIds containsObject:@(peerId)])
    {
        NSMutableArray *updatedSelectedPeerIds = [[NSMutableArray alloc] initWithArray:_selectedPeerIds];
        [updatedSelectedPeerIds removeObject:@(peerId)];
        _selectedPeerIds = updatedSelectedPeerIds;
    }
    else
    {
        NSMutableArray *updatedSelectedPeerIds = [[NSMutableArray alloc] initWithArray:_selectedPeerIds];
        [updatedSelectedPeerIds addObject:@(peerId)];
        _selectedPeerIds = updatedSelectedPeerIds;
        checked = true;
    }
    
    if (!fromSearch)
    {
        for (TGShareTargetCell *cell in _tableView.visibleCells)
        {
            if (cell.peerId == peerId)
                [cell setChecked:checked animated:true];
        }
    }
    
    return checked;
}


//- (void)updateIsLastCell {
//    for (NSIndexPath *indexPath in _tableView.indexPathsForVisibleRows) {
//        TGCallCell *cell = (TGCallCell *)[_tableView cellForRowAtIndexPath:indexPath];
//        if ([cell isKindOfClass:[TGCallCell class]]) {
//            [cell setIsLastCell:[self isLastCell:indexPath]];
//        }
//    }
//}

- (void)reloadData
{
    [self setTableHidden:[self currentPeers].count == 0];
    [_tableView reloadData];
}

#pragma mark -

- (NSArray *)currentPeers
{
    if (_currentPeers == nil)
    {
        NSArray *filteredPeers = _recentPeers;
        if (_foundPeers.count > 0)
        {
            NSMutableArray *peers = [[NSMutableArray alloc] init];
            NSMutableArray *foundPeers = [_foundPeers mutableCopy];
            
            for (id peer in _recentPeers)
            {
                int64_t peerId = [TGShareTargetController _peerIdForPeer:peer];
                
                bool found = false;
                for (id foundPeer in foundPeers)
                {
                    int64_t foundPeerId = [TGShareTargetController _peerIdForPeer:foundPeer];
                    if (peerId == foundPeerId)
                    {
                        found = true;
                        [foundPeers removeObject:foundPeer];
                        break;
                    }
                }
                
                if (!found)
                    [peers addObject:peer];
            }
            
            filteredPeers = peers;
        }
        
        _currentPeers = [_foundPeers arrayByAddingObjectsFromArray:filteredPeers];
    }
    
    return _currentPeers;
}

+ (int64_t)_peerIdForPeer:(id)peer
{
    if (![peer isKindOfClass:[TGUser class]] && ![peer isKindOfClass:[TGConversation class]])
        return 0;
    
    return [peer isKindOfClass:[TGUser class]] ? [(TGUser *)peer uid] : [(TGConversation *)peer conversationId];
}

- (void)addFoundPeer:(id)peer
{
    NSMutableArray *foundPeers = [[NSMutableArray alloc] init];
    int64_t peerId = [TGShareTargetController _peerIdForPeer:peer];
    
    for (id foundPeer in _foundPeers)
    {
        int64_t foundPeerId = [TGShareTargetController _peerIdForPeer:foundPeer];
        if (peerId != foundPeerId)
            [foundPeers addObject:foundPeer];
    }
    
    [foundPeers insertObject:peer atIndex:0];
    _foundPeers = foundPeers;
}


- (void)setPeers:(NSArray *)peers
{
    _currentPeers = nil;
    _recentPeers = peers;
    
    for (id peer in peers)
    {
        int64_t peerId = [TGShareTargetController _peerIdForPeer:peer];
        _peers[@(peerId)] = peer;
    }
    
    [self reloadData];
}

- (void)setSearchPeers:(NSArray *)searchResultsSections query:(NSString *)query
{
    _searchResultsSections = searchResultsSections;
    
    [_searchMixin reloadSearchResults];
    
    [_searchMixin setSearchResultsTableViewHidden:query.length == 0];
    
    for (NSDictionary *section in searchResultsSections)
    {
        if ([section[@"items"] isKindOfClass:[NSArray class]])
        {
            for (id peer in section[@"items"])
            {
                int64_t peerId = [TGShareTargetController _peerIdForPeer:peer];
                _peers[@(peerId)] = peer;
            }
        }
        else if ([section[@"items"] isKindOfClass:[TGDialogListRecentPeers class]])
        {
            for (id peer in ((TGDialogListRecentPeers *)section[@"items"]).peers)
            {
                int64_t peerId = [TGShareTargetController _peerIdForPeer:peer];
                _peers[@(peerId)] = peer;
            }
        }
    }
}


- (NSArray *)peerIds
{
    return _selectedPeerIds;
}

- (NSArray<TGConversation *> *)processedPeers:(NSArray<TGConversation *> *)peers
{
    NSMutableSet *existingPeerIds = [[NSMutableSet alloc] init];
    
    NSMutableArray *updatedPeers = [[NSMutableArray alloc] init];
    for (id peer in peers)
    {
        id processedPeer = [self processPeer:peer existingPeerIds:existingPeerIds];
        if (processedPeer != nil)
            [updatedPeers addObject:processedPeer];
    }
    
    return updatedPeers;
}

- (id)processPeer:(id)peer existingPeerIds:(NSMutableSet *)existingPeerIds
{
    if ([peer isKindOfClass:[TGConversation class]])
    {
        TGConversation *conversation = peer;
        if ([existingPeerIds containsObject:@(conversation.conversationId)])
            return nil;
        
        [existingPeerIds addObject:@(conversation.conversationId)];
        
        if (![conversation currentUserCanSendMessages])
            return nil;
        
        if (conversation.isEncrypted)
            return nil;
        
        TGConversation *updatedConversation = [conversation copy];
        if (!conversation.isChat || conversation.isEncrypted)
        {
            int32_t userId = 0;
            if (conversation.isEncrypted)
            {
                if (conversation.chatParticipants.chatParticipantUids.count != 0)
                    userId = [conversation.chatParticipants.chatParticipantUids[0] intValue];
            }
            else
                userId = (int)conversation.conversationId;
            
            TGUser *user = [TGDatabaseInstance() loadUser:userId];
            if (user != nil) {
                updatedConversation.additionalProperties = @{@"user": user};
            }
        }
        return updatedConversation;
    }
    else if ([peer isKindOfClass:[TGUser class]])
    {
        TGUser *user = peer;
        if ([existingPeerIds containsObject:@(user.uid)])
            return nil;
        
        [existingPeerIds addObject:@(user.uid)];
        
        return user;
    }
    
    return nil;
}

#pragma mark -

- (UITableView *)createTableViewForSearchMixin:(TGSearchDisplayMixin *)__unused searchMixin
{
    UITableView *tableView = [[UITableView alloc] init];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (iosMajorVersion() >= 7) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorColor = TGSeparatorColor();
        tableView.separatorInset = UIEdgeInsetsMake(0.0f, 65.0f, 0.0f, 0.0f);
    }
    
    if (tableView.tableFooterView == nil)
        tableView.tableFooterView = [[UIView alloc] init];
    
    return tableView;
}

- (UIView *)referenceViewForSearchResults
{
    return _tableView;
}

- (void)searchMixinWillActivate:(bool)animated
{
    _isDisplayingSearch = true;
    _tableView.scrollEnabled = false;
    
    [self setNavigationBarHidden:true animated:animated];
    
    if (_recentDisposable == nil)
        _recentDisposable = [[SMetaDisposable alloc] init];
    
    __weak TGShareTargetController *weakSelf = self;
    SSignal *updatedRecentPeers = [[TGRecentPeersSignals updateRecentPeers] mapToSignal:^SSignal *(__unused id next) {
        return [SSignal complete];
    }];
    
    [_recentDisposable setDisposable:[[[SSignal mergeSignals:@[[TGGlobalMessageSearchSignals recentPeerResults:^id (id item) {
        __strong TGShareTargetController *strongSelf = weakSelf;
        if (strongSelf != nil)
            return [strongSelf processPeer:item existingPeerIds:nil];
        return nil;
    } ratedPeers:true], updatedRecentPeers]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *peerResults)
    {
        __strong TGShareTargetController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            NSMutableArray *searchResultsSections = [[NSMutableArray alloc] init];
            
            if (peerResults.count != 0)
            {
                NSMutableArray *genericResuts = [[NSMutableArray alloc] init];
                for (id result in peerResults) {
                    if ([result isKindOfClass:[TGDialogListRecentPeers class]]) {
                        TGDialogListRecentPeers *recentPeers = result;
                        [searchResultsSections addObject:@{@"items": @[recentPeers], @"type": @"recent"}];
                    } else {
                        [genericResuts addObject:result];
                    }
                }
                if (genericResuts.count != 0) {
                    [searchResultsSections addObject:@{@"title": TGLocalized(@"DialogList.SearchSectionRecent"), @"items": genericResuts, @"type": @"recent"}];
                }
            }
            
            strongSelf->_recentSearchResultsSections = searchResultsSections;
            
            if (strongSelf->_searchBar.text.length == 0) {
                strongSelf->_searchResultsSections = strongSelf->_recentSearchResultsSections;
                
                [strongSelf->_searchMixin reloadSearchResults];
                [strongSelf->_searchMixin setSearchResultsTableViewHidden:false animated:true];
            }
        }
    }]];
    
    [_searchMixin reloadSearchResults];
    [_searchMixin setSearchResultsTableViewHidden:false animated:true];
}

- (void)searchMixinWillDeactivate:(bool)animated
{
    _isDisplayingSearch = false;
    _tableView.scrollEnabled = true;
    
    [_recentDisposable setDisposable:nil];
    
    [self setNavigationBarHidden:false animated:animated];
}

- (void)searchMixin:(TGSearchDisplayMixin *)__unused searchMixin hasChangedSearchQuery:(NSString *)searchText withScope:(int)__unused scope
{
    [_searchDisposable setDisposable:nil];
    
    if (searchText.length == 0)
    {
        [_searchDisposable setDisposable:nil];
        _searchResultsSections = _recentSearchResultsSections;
        [_searchMixin reloadSearchResults];
        [_searchMixin setSearchResultsTableViewHidden:false];
    }
    else
    {
        _searchBar.delayActivity = false;
        _searchBar.showActivity = true;
        
        __weak TGShareTargetController *weakSelf = self;
        [_searchDisposable setDisposable:[[[[[TGGlobalMessageSearchSignals searchDialogs:searchText itemMapping:^id(id item)
        {
            if ([item isKindOfClass:[TGConversation class]])
            {
                TGConversation *conversation = item;
                if (conversation.isBroadcast)
                    return nil;
                
                [TGChatSearchController initializeDialogListData:conversation customUser:nil selfUser:[TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId]];
                return conversation;
            }
            else if ([item isKindOfClass:[TGUser class]])
            {
                return item;
            }
            return nil;
        }] takeLast] map:^id(NSArray<TGConversation *> *next)
        {
            __strong TGShareTargetController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                return [strongSelf processedPeers:next];
            }
            return nil;
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
        {
            __strong TGShareTargetController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setSearchPeers:@[@{ @"type": @"search", @"items": next }] query:searchText];
            }
        } completed:^
        {
            TGDispatchOnMainThread(^
            {
                __strong TGShareTargetController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_searchBar.showActivity = false;
                }
            });
        }]];
    }
}

#pragma mark -

- (void)updateTableFrame:(bool)animated collapseSearch:(bool)collapseSearch
{
    float tableY = 0;
    UIEdgeInsets tableInset = UIEdgeInsetsZero;
    
    tableY = 0;
    tableInset = UIEdgeInsetsMake(0, 0, (_buttonContainer == nil || _buttonContainer.frame.origin.y >= self.view.frame.size.height - FLT_EPSILON) ? 0 : _buttonContainer.frame.size.height, 0);
    
    CGRect tableFrame = CGRectMake(0, tableY, self.view.frame.size.width, self.view.frame.size.height);
    
    CGRect searchTableFrame = tableFrame;
    
    if (collapseSearch)
    {
        searchTableFrame.size.height = tableInset.top;
    }
    
    dispatch_block_t block = ^
    {
        UIEdgeInsets controllerCleanInset = self.controllerCleanInset;
        
        UIEdgeInsets compareTableInset = UIEdgeInsetsMake(tableInset.top + controllerCleanInset.top, tableInset.left + controllerCleanInset.left, tableInset.bottom + controllerCleanInset.bottom, tableInset.right + controllerCleanInset.right);
        
        if (!UIEdgeInsetsEqualToEdgeInsets(compareTableInset, _tableView.contentInset))
        {
            [self setExplicitTableInset:tableInset scrollIndicatorInset:tableInset];
        }
        
        if (!CGRectEqualToRect(tableFrame, _tableView.frame))
        {
            _tableView.frame = tableFrame;
        }
        
        if (!CGRectEqualToRect(searchTableFrame, _searchMixin.searchResultsTableView.frame))
        {
            _searchMixin.searchResultsTableView.frame = searchTableFrame;
            _searchMixin.searchResultsTableView.frame = searchTableFrame;
        }
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
             block();
        } completion:nil];
    }
    else
    {
        block();
    }
}

- (void)updateSelectionInterface
{
    NSUInteger count = _selectedPeerIds.count;
    if (count != 0)
    {
        if (_buttonContainer == nil)
        {
            _buttonContainer = [[TGHighlightableButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 46)];
            ((TGHighlightableButton *)_buttonContainer).normalBackgroundColor = UIColorRGB(0xf7f7f7);
            
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _buttonContainer.frame.size.width, TGIsRetina() ? 0.5f : 1.0f)];
            separatorView.backgroundColor = TGSeparatorColor();
            [_buttonContainer addSubview:separatorView];
            
            [((TGHighlightableButton *)_buttonContainer) addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            _buttonContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            _buttonContainer.backgroundColor = UIColorRGB(0xf7f7f7);
            [self.view insertSubview:_buttonContainer aboveSubview:_tableView];
            
            UIView *alignmentContainer = [[UIView alloc] initWithFrame:CGRectMake(floorf((float)(_buttonContainer.frame.size.width - 320) / 2), 0, 320, 46)];
            alignmentContainer.userInteractionEnabled = false;
            alignmentContainer.tag = 99;
            alignmentContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [_buttonContainer addSubview:alignmentContainer];
            
            UILabel *inviteLabel = [[UILabel alloc] init];
            inviteLabel.backgroundColor = [UIColor clearColor];
            inviteLabel.textColor = TGAccentColor();
            inviteLabel.font = TGMediumSystemFontOfSize(17);
            inviteLabel.text = TGLocalized(@"ShareMenu.Send");
            [inviteLabel sizeToFit];
            inviteLabel.tag = 100;
            [alignmentContainer addSubview:inviteLabel];
            
            static UIImage *badgeImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(24.0f, 24.0f), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 24.0f, 24.0f));
                
                badgeImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            });
            
            UIImageView *bubbleView = [[UIImageView alloc] initWithImage:[badgeImage stretchableImageWithLeftCapWidth:(int)(badgeImage.size.width / 2) topCapHeight:0]];
            bubbleView.tag = 101;
            [alignmentContainer addSubview:bubbleView];
            
            UILabel *countLabel = [[UILabel alloc] init];
            countLabel.backgroundColor = [UIColor clearColor];
            countLabel.textColor = [UIColor whiteColor];
            countLabel.font = TGSystemFontOfSize(15);
            countLabel.text = @"1";
            [countLabel sizeToFit];
            countLabel.tag = 102;
            [alignmentContainer addSubview:countLabel];
        }
        
        UIView *container = [_buttonContainer viewWithTag:99];
        
        UIView *inviteLabel = [container viewWithTag:100];
        UIView *bubbleView = [container viewWithTag:101];
        UILabel *countLabel = (UILabel *)[container viewWithTag:102];
        
        CGRect inviteLabelFrame = inviteLabel.frame;
        inviteLabelFrame.origin = CGPointMake(floorf((float)(container.frame.size.width - inviteLabelFrame.size.width) / 2) + 7.0f, 12);
        inviteLabel.frame = inviteLabelFrame;
        
        countLabel.text = [TGStringUtils stringWithLocalizedNumber:count];
        [countLabel sizeToFit];
        
        CGFloat bubbleWidth = MAX(24.0f, countLabel.frame.size.width + 14);
        
        bubbleView.frame = CGRectMake(inviteLabelFrame.origin.x - bubbleWidth - 8, 11, bubbleWidth, bubbleView.frame.size.height);
        
        CGRect countLabelFrame = countLabel.frame;
        countLabelFrame.origin = CGPointMake(bubbleView.frame.origin.x + floorf((float)(bubbleView.frame.size.width - countLabelFrame.size.width) / 2) + (TGIsRetina() ? 0.5f : 0.0f), 14);
        countLabel.frame = countLabelFrame;
        
        if (ABS(_buttonContainer.frame.origin.y - self.view.frame.size.height + 46) > FLT_EPSILON)
        {
            [UIView animateWithDuration:0.2 delay:0.0 options:7 << 16 | UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                _buttonContainer.frame = CGRectMake(0, self.view.frame.size.height - 46, self.view.frame.size.width, 46);
                 
                [self updateTableFrame:false collapseSearch:false];
            } completion:nil];
        }
    }
    else
    {
        if (_buttonContainer != nil)
        {
            if (ABS(_buttonContainer.frame.origin.y - self.view.frame.size.height) > FLT_EPSILON)
            {
                [UIView animateWithDuration:0.2 delay:0.0 options:7 << 16 | UIViewAnimationOptionBeginFromCurrentState animations:^
                {
                    _buttonContainer.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 46);
                    
                    [self updateTableFrame:false collapseSearch:false];
                } completion:nil];
            }
        }
    }
}

@end
