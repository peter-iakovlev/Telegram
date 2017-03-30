#import "TGShareCollectionItemView.h"
#import "TGMenuSheetController.h"

#import "TGImageUtils.h"

#import "TGDatabase.h"
#import "TGChatListSignals.h"
#import "TGRecentPeersSignals.h"
#import "TGGlobalMessageSearchSignals.h"
#import "TGChatSearchController.h"
#import "TGTelegraph.h"

#import "TGConversation.h"
#import "TGUser.h"

#import "TGDialogListRecentPeers.h"
#import "TGShareCollectionCell.h"
#import "TGShareCollectionRecentPeersCell.h"

#import "TGMenuSheetCollectionView.h"
#import "TGScrollIndicatorView.h"

const CGFloat TGShareCollectionRegularSizeClassHeight = 360.0f;

@interface TGShareCollectionItemView () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    TGMenuSheetCollectionView *_collectionView;
    UICollectionViewFlowLayout *_collectionViewLayout;
    TGScrollIndicatorView *_scrollIndicator;
    
    UIButton *_fadeView;
    UIView *_separator;
    
    CGFloat _smallActivationHeight;
    bool _smallActivated;
    
    NSArray *_recentPeers;
    NSArray *_searchPeers;
    
    NSArray *_recentSearchPeers;
    
    id<SDisposable> _chatList;
    SMetaDisposable *_recentDisposable;
    SMetaDisposable *_searchDisposable;
    
    bool _transitionedIn;    
    CGFloat _expandOffset;
    CGFloat _collapsedHeight;
    CGFloat _expandedHeight;
    
    NSMutableArray *_selectedPeerIds;
    NSArray *_foundPeers;
    
    NSArray *_currentPeers;
    bool _ignoreCurrentUpdates;

    NSMutableDictionary *_peers;
    
    NSInteger _columns;
    
    NSTimeInterval _appearanceTime;
}

@end

@implementation TGShareCollectionItemView

- (instancetype)init
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        self.clipsToBounds = true;
        self.condensable = true;
        
        _columns = 4;
        
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionViewLayout.itemSize = CGSizeMake(70, 90);
        _collectionViewLayout.minimumInteritemSpacing = 0;
        _collectionViewLayout.minimumLineSpacing = 17;
        
        _collectionView = [[TGMenuSheetCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
        _collectionView.allowSimultaneousPan = true;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.bounces = false;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.scrollsToTop = false;
        [_collectionView registerClass:[TGShareCollectionCell class] forCellWithReuseIdentifier:TGShareCollectionCellIdentifier];
        [_collectionView registerClass:[TGShareCollectionRecentPeersCell class] forCellWithReuseIdentifier:TGShareCollectionRecentPeersCellIdentifier];
        [self addSubview:_collectionView];
        
        _scrollIndicator = [[TGScrollIndicatorView alloc] init];
        [_scrollIndicator setHidden:true animated:false];
        [_collectionView addSubview:_scrollIndicator];
        
        _fadeView = [[UIButton alloc] initWithFrame:CGRectZero];
        _fadeView.alpha = 0.0f;
        _fadeView.exclusiveTouch = true;
        _fadeView.backgroundColor = UIColorRGBA(0xffffff, 0.8f);
        _fadeView.hidden = true;
        [_fadeView addTarget:self action:@selector(dismissCommentViewAction) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_fadeView];
        
        _separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, TGScreenPixel)];
        _separator.alpha = 0.0f;
        _separator.backgroundColor = TGSeparatorColor();
        [self addSubview:_separator];

        CGSize screenSize = TGScreenSize();
        _smallActivationHeight = screenSize.width;
        
        _searchDisposable = [[SMetaDisposable alloc] init];
        _foundPeers = [[NSMutableArray alloc] init];
        
        _selectedPeerIds = [[NSMutableArray alloc] init];
        _peers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    
    [_chatList dispose];
    [_searchDisposable dispose];
}

- (void)menuView:(TGMenuSheetView *)__unused menuView willAppearAnimated:(bool)__unused animated
{
    _appearanceTime = CFAbsoluteTimeGetCurrent();
    __weak TGShareCollectionItemView *weakSelf = self;
    _chatList = [[[[[TGChatListSignals chatListWithLimit:64] take:1] map:^id(NSArray<TGConversation *> *next)
    {
        __strong TGShareCollectionItemView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            return [strongSelf processedPeers:next];
        }
        return nil;
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next) {
        __strong TGShareCollectionItemView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf setPeers:next];
        }
    }];
}

- (void)dismissCommentViewAction
{
    if (self.dismissCommentView != nil)
        self.dismissCommentView();
}

#pragma mark - 

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
    
    NSArray *finalPeers = updatedPeers;
    if (finalPeers.count > 64 && (finalPeers.count % _columns) != 0)
        finalPeers = [finalPeers subarrayWithRange:NSMakeRange(0, finalPeers.count - (finalPeers.count % _columns))];
    
    return finalPeers;
}

- (id)processPeer:(id)peer existingPeerIds:(NSMutableSet *)existingPeerIds
{
    if ([peer isKindOfClass:[TGConversation class]])
    {
        TGConversation *conversation = peer;
        if ([existingPeerIds containsObject:@(conversation.conversationId)])
            return nil;
        
        [existingPeerIds addObject:@(conversation.conversationId)];
        
        if (conversation.isChannel && ![conversation currentUserCanSendMessages])
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

- (NSArray *)currentPeers
{
    if (_currentPeers == nil && !_ignoreCurrentUpdates)
    {
        NSArray *filteredPeers = _recentPeers;
        if (_foundPeers.count > 0)
        {
            NSMutableArray *peers = [[NSMutableArray alloc] init];
            NSMutableArray *foundPeers = [_foundPeers mutableCopy];
            
            for (id peer in _recentPeers)
            {
                int64_t peerId = [TGShareCollectionItemView _peerIdForPeer:peer];
                
                bool found = false;
                for (id foundPeer in foundPeers)
                {
                    int64_t foundPeerId = [TGShareCollectionItemView _peerIdForPeer:foundPeer];
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

- (void)addFoundPeer:(id)peer
{
    NSMutableArray *foundPeers = [[NSMutableArray alloc] init];
    int64_t peerId = [TGShareCollectionItemView _peerIdForPeer:peer];
    
    for (id foundPeer in _foundPeers)
    {
        int64_t foundPeerId = [TGShareCollectionItemView _peerIdForPeer:foundPeer];
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
    if (_searchPeers == nil)
        [self reloadData];
    
    for (id peer in peers)
    {
        int64_t peerId = [TGShareCollectionItemView _peerIdForPeer:peer];
        _peers[@(peerId)] = peer;
    }
}

- (void)setSearchPeers:(NSArray *)peers
{
    if (_searchPeers != peers)
    {
        _searchPeers = peers;
        [self reloadData];
        
        for (NSDictionary *section in peers)
        {
            if ([section[@"items"] isKindOfClass:[NSArray class]])
            {
                for (id peer in section[@"items"])
                {
                    int64_t peerId = [TGShareCollectionItemView _peerIdForPeer:peer];
                    _peers[@(peerId)] = peer;
                }
            }
            else if ([section[@"items"] isKindOfClass:[TGDialogListRecentPeers class]])
            {
                for (id peer in ((TGDialogListRecentPeers *)section[@"items"]).peers)
                {
                    int64_t peerId = [TGShareCollectionItemView _peerIdForPeer:peer];
                    _peers[@(peerId)] = peer;
                }
            }
        }
    }
}

+ (int64_t)_peerIdForPeer:(id)peer
{
    if (![peer isKindOfClass:[TGUser class]] && ![peer isKindOfClass:[TGConversation class]])
        return 0;
    
    return [peer isKindOfClass:[TGUser class]] ? [(TGUser *)peer uid] : [(TGConversation *)peer conversationId];
}

- (void)searchBegan
{
    if (_recentDisposable == nil)
        _recentDisposable = [[SMetaDisposable alloc] init];
    
    [UIView performWithoutAnimation:^
    {
        [_collectionView setContentOffset:CGPointZero animated:false];
    }];
    
    __weak TGShareCollectionItemView *weakSelf = self;
    __block bool firstTime = true;
    
    SSignal *updatedRecentPeers = [[TGRecentPeersSignals updateRecentPeers] mapToSignal:^SSignal *(__unused id next) {
        return [SSignal complete];
    }];
    
    [_recentDisposable setDisposable:[[[SSignal mergeSignals:@[[TGGlobalMessageSearchSignals recentPeerResults:^id (id item)
    {
        __strong TGShareCollectionItemView *strongSelf = weakSelf;
        if (strongSelf != nil)
            return [strongSelf processPeer:item existingPeerIds:nil];
        return nil;
    } ratedPeers:true], updatedRecentPeers]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *peerResults)
    {
        __strong TGShareCollectionItemView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
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

        
        strongSelf->_recentSearchPeers = searchResultsSections;
        strongSelf->_searchPeers = searchResultsSections;
        
        [strongSelf reloadData];
        
        if (firstTime)
        {
            firstTime = false;
            [strongSelf->_collectionView layoutSubviews];
        }
    }]];
}

- (void)searchEnded:(bool)reload
{
    [UIView performWithoutAnimation:^
    {
        [_collectionView setContentOffset:CGPointZero animated:false];
    }];
    
    _searchPeers = nil;
    _currentPeers = nil;
    if (reload)
    {
        [self reloadData];
        [_collectionView layoutSubviews];
    }
}

- (void)setSearchQuery:(NSString *)searchText updateActivity:(void (^)(bool))updateActivity
{
    [_searchDisposable setDisposable:nil];
    
    if (searchText.length == 0)
    {
        updateActivity(false);
        _searchPeers = _recentSearchPeers;
        [self reloadData];
    }
    else
    {
        updateActivity(true);
        
        __weak TGShareCollectionItemView *weakSelf = self;
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
            __strong TGShareCollectionItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                return [strongSelf processedPeers:next];
            }
            return nil;
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
        {
            __strong TGShareCollectionItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setSearchPeers:@[@{ @"type": @"search", @"items": next }]];
            }
        } completed:^
        {
            updateActivity(false);
        }]];
    }
}

- (void)reloadData
{
    [_collectionView reloadData];
    
    if (!_transitionedIn)
    {
        _transitionedIn = true;
        if (iosMajorVersion() < 8 || self.sizeClass == UIUserInterfaceSizeClassRegular)
            return;
        
        [_collectionView layoutSubviews];
        
        NSTimeInterval delay = 0.1;
        NSTimeInterval delta = CFAbsoluteTimeGetCurrent() - _appearanceTime;
        if (delta > 0.08)
            delay = 0.0;
        
        if (delta > 0.45)
            return;
        
        CGRect targetFrame = _collectionView.frame;
        _collectionView.frame = CGRectOffset(_collectionView.frame, 0, 35);
        UIViewAnimationOptions options = UIViewAnimationOptionAllowAnimatedContent;
        if (iosMajorVersion() >= 7)
            options = options | (7 << 16);
        
        [UIView animateWithDuration:0.3 delay:delay options:options animations:^
        {
            _collectionView.frame = targetFrame;
        } completion:nil];
        
        for (TGShareCollectionCell *cell in _collectionView.visibleCells)
            [cell performTransitionInWithDelay:MAX(0, delay - 0.06)];
    }
}

#pragma mark - 

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
        for (TGShareCollectionCell *cell in _collectionView.visibleCells)
        {
            if (cell.peerId == peerId)
                [cell setChecked:checked animated:true];
        }
    }
    
    if (self.selectionChanged != nil)
        self.selectionChanged(_selectedPeerIds, _peers);
    
    return checked;
}

#pragma mark -

- (bool)handlesPan
{
    return true;
}

- (bool)passPanOffset:(CGFloat)__unused offset
{
    if (!_collectionView.scrollEnabled)
        return true;
    
    CGFloat currentHeight = _collapsedHeight + _expandOffset;
    
    CGFloat bottomContentOffset = (_collectionView.contentSize.height - _collectionView.frame.size.height);
    
    bool atTop = (_collectionView.contentOffset.y < FLT_EPSILON);
    bool atBottom = (_collectionView.contentOffset.y - bottomContentOffset > -FLT_EPSILON);
    bool expanded = fabs(currentHeight - _expandedHeight) < FLT_EPSILON;
    
    if (atTop && (offset > FLT_EPSILON || expanded))
        return true;
    
    if (atBottom && expanded && offset < 0)
        return true;
    
    return false;
}

- (void)setExpanded
{
    _expandOffset = _expandedHeight - _collapsedHeight;
}

#pragma mark - 

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView
{
    if (_searchPeers != nil)
        return _searchPeers.count;
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_searchPeers != nil)
    {
        NSDictionary *peersSection = _searchPeers[section];
        if ([peersSection[@"items"] isKindOfClass:[TGDialogListRecentPeers class]])
            return 1;
        else if ([peersSection[@"items"] isKindOfClass:[NSArray class]])
            return [(NSArray *)peersSection[@"items"] count];
        else
            return 0;
    }
    
    return [self currentPeers].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *peersSection = _searchPeers[indexPath.section];
    
    if ([[peersSection[@"items"] firstObject] isKindOfClass:[TGDialogListRecentPeers class]])
    {
        TGShareCollectionRecentPeersCell *cell = (TGShareCollectionRecentPeersCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TGShareCollectionRecentPeersCellIdentifier forIndexPath:indexPath];
        
        [cell setRecentPeers:[peersSection[@"items"] firstObject]];
        
        __weak TGShareCollectionItemView *weakSelf = self;
        cell.isChecked = ^bool (int64_t peerId)
        {
            __strong TGShareCollectionItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return false;
            
            return [strongSelf->_selectedPeerIds containsObject:@(peerId)];
        };
        cell.toggleChecked = ^bool (int64_t peerId, id peer)
        {
            __strong TGShareCollectionItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return false;
            
            if (strongSelf.searchResultSelected != nil)
            {
                strongSelf->_ignoreCurrentUpdates = true;
                strongSelf.searchResultSelected();
            }
            
            bool selected = [strongSelf togglePeerSelected:peerId fromSearch:true];
            strongSelf->_ignoreCurrentUpdates = false;
            
            if (selected)
                [strongSelf addFoundPeer:peer];
            [strongSelf reloadData];
            
            return selected;
        };
        
        return cell;
    }
    else
    {
        TGShareCollectionCell *cell = (TGShareCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TGShareCollectionCellIdentifier forIndexPath:indexPath];
        
        id peer = (_searchPeers != nil) ? peersSection[@"items"][indexPath.row] : [self currentPeers][indexPath.row];
        int64_t peerId = [TGShareCollectionItemView _peerIdForPeer:peer];
        [cell setPeer:peer];
        [cell setChecked:[_selectedPeerIds containsObject:@(peerId)]];
        
        return cell;
    }
    
    return nil;
}

- (BOOL)collectionView:(UICollectionView *)__unused collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *peersSection = _searchPeers[indexPath.section];
    if ([[peersSection[@"items"] firstObject] isKindOfClass:[TGDialogListRecentPeers class]])
        return false;
    
    return true;
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id peer = (_searchPeers != nil) ? _searchPeers[indexPath.section][@"items"][indexPath.row] : [self currentPeers][indexPath.row];
    int64_t peerId = [TGShareCollectionItemView _peerIdForPeer:peer];
    
    bool fromSearch = (_searchPeers != nil);
    if (fromSearch)
        _currentPeers = nil;
    
    if (fromSearch && self.searchResultSelected != nil)
    {
        _ignoreCurrentUpdates = true;
        self.searchResultSelected();
    }

    bool selected = [self togglePeerSelected:peerId fromSearch:fromSearch];
    _ignoreCurrentUpdates = false;
    
    if (fromSearch)
    {
        if (selected)
            [self addFoundPeer:peer];
        [self reloadData];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSDictionary *peersSection = _searchPeers[section];
    if (section == 0 && [[peersSection[@"items"] firstObject] isKindOfClass:[TGDialogListRecentPeers class]])
        return UIEdgeInsetsZero;
    
    return UIEdgeInsetsMake(section == 1 ? 6.5f : 0.0f, 16.0f, 14.0f, 16.0f);
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *peersSection = _searchPeers[indexPath.section];
    if (indexPath.section == 0 && [[peersSection[@"items"] firstObject] isKindOfClass:[TGDialogListRecentPeers class]])
    {
        CGFloat recentHeight = 117.0f;
        if (_searchPeers.count > 1)
            recentHeight += 27.0f;
        
        return CGSizeMake(_collectionView.frame.size.width, recentHeight);
    }
    
    return CGSizeMake(70, 90);
}

#pragma mark - 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentHeight = _collapsedHeight + _expandOffset;
    CGFloat bottomContentOffset = (scrollView.contentSize.height - scrollView.frame.size.height);
    
    [_scrollIndicator updateScrollViewDidScroll];
    
    bool atTop = (scrollView.contentOffset.y < FLT_EPSILON);
    bool atBottom = (scrollView.contentOffset.y - bottomContentOffset > -FLT_EPSILON);
    bool expanded = fabs(currentHeight - _expandedHeight) < FLT_EPSILON;
    
    if (atTop || (atBottom && expanded))
        [_scrollIndicator setHidden:true animated:true];
    else if (scrollView.contentOffset.y > FLT_EPSILON && expanded)
        [_scrollIndicator setHidden:false animated:true];
    
    if ((atTop || (atBottom && expanded)) && self.sizeClass == UIUserInterfaceSizeClassCompact)
    {
        if (scrollView.isTracking && scrollView.bounces && (scrollView.contentOffset.y - bottomContentOffset) < 20.0f)
        {
            scrollView.bounces = false;
            if (atTop)
                scrollView.contentOffset = CGPointMake(0, 0);
            else if (atBottom)
                scrollView.contentOffset = CGPointMake(0, bottomContentOffset);
        }
    }
    else
    {
        scrollView.bounces = true;
    }
    
    if (currentHeight < _expandedHeight && self.sizeClass == UIUserInterfaceSizeClassCompact)
    {
        if (scrollView.contentOffset.y > FLT_EPSILON)
        {
            _expandOffset = MIN(_expandedHeight - _collapsedHeight, _expandOffset + scrollView.contentOffset.y);
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
            [self requestMenuLayoutUpdate];
        }
    }
    
    [self setSeparatorHidden:(scrollView.contentOffset.y < FLT_EPSILON) animated:true];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat currentHeight = _collapsedHeight + _expandOffset;
    CGFloat bottomContentOffset = (scrollView.contentSize.height - scrollView.frame.size.height);
    
    bool atTop = (scrollView.contentOffset.y < FLT_EPSILON);
    bool atBottom = (scrollView.contentOffset.y - bottomContentOffset > -FLT_EPSILON);
    bool expanded = fabs(currentHeight - _expandedHeight) < FLT_EPSILON;
    
    if ((atTop || (atBottom && expanded)) && scrollView.bounces && !scrollView.isTracking && self.sizeClass == UIUserInterfaceSizeClassCompact)
        scrollView.bounces = false;
    
    [_scrollIndicator updateScrollViewDidEndScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)__unused scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [_scrollIndicator updateScrollViewDidEndScrolling];
}

#pragma mark -

- (void)setSeparatorHidden:(bool)hidden animated:(bool)animated
{
    if ((hidden && _separator.alpha < FLT_EPSILON) || (!hidden && _separator.alpha > FLT_EPSILON))
        return;
    
    if (animated)
    {
        [UIView animateWithDuration:0.25f animations:^
        {
            _separator.alpha = hidden ? 0.0f : 1.0f;
        }];
    }
    else
    {
        _separator.alpha = hidden ? 0.0f : 1.0f;
    }
}

#pragma mark -

- (bool)requiresDivider
{
    return true;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)screenHeight
{
    if (width > FLT_EPSILON)
        _columns = (NSInteger)floor((width - 16.0f * 2) / (_collectionViewLayout.itemSize.width + _collectionViewLayout.minimumInteritemSpacing));
    else
        _columns = 4;
    
    if (self.sizeClass == UIUserInterfaceSizeClassRegular)
    {
        CGFloat height = TGShareCollectionRegularSizeClassHeight;
        _expandedHeight = height;
        _collapsedHeight = height;
        
        if (_selectedPeerIds.count > 0)
        {
            CGFloat compensationHeight = TGMenuSheetButtonItemViewHeight;
            if (!self.hasActionButton)
                compensationHeight *= 2;
            
            height -= compensationHeight;
        }
        
        return height;
    }
    
    _smallActivated = fabs(screenHeight - _smallActivationHeight) < FLT_EPSILON;

    CGFloat collapsedHeight = 260.0f;
    
    CGFloat height = 0.0f;
    if (_smallActivated)
    {
        CGFloat maxHeight = screenHeight - 152.0f;
        height = MIN(maxHeight, collapsedHeight);
        
        _collectionView.contentOffset = CGPointZero;
        _collectionView.scrollEnabled = (collapsedHeight > maxHeight);
    }
    else
    {
        CGFloat maxExpandedHeight = 357.0f;
        CGFloat expandedHeight = 357.0f;
        
        maxExpandedHeight = MIN(maxExpandedHeight, screenHeight - 75.0f - 68.0f - TGMenuSheetButtonItemViewHeight - self.menuController.statusBarHeight);
        
        if (_selectedPeerIds.count > 0 && ((NSInteger)screenHeight == 480 || (NSInteger)screenHeight == 568))
            maxExpandedHeight -= TGMenuSheetButtonItemViewHeight;
        
        CGFloat maxCollapsedHeight = 240.0f;
        if (fabs(maxCollapsedHeight - maxExpandedHeight) < 40.0f)
            maxCollapsedHeight = maxExpandedHeight;
        
        _expandedHeight = MIN(expandedHeight, maxExpandedHeight);
        _collapsedHeight = MIN(collapsedHeight, maxCollapsedHeight);
        
        _collectionView.scrollEnabled = true;
        
        height = MIN(_collapsedHeight + _expandOffset, _expandedHeight);
    }
    
    return height;
}

- (void)layoutSubviews
{
    _collectionView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    _separator.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, _separator.frame.size.height);
    
    _fadeView.frame = _collectionView.frame;
}

- (void)_didLayoutSubviews
{
    if (self.frame.size.height < 150.0f)
    {
        _fadeView.alpha = 1.0f;
        _fadeView.hidden = false;
    }
    else
    {
        _fadeView.alpha = 0.0f;
        _fadeView.hidden = true;
    }
}

@end
