#import "TGCreateFeedController.h"

#include <set>
#include <map>

#import "TGDatabase.h"
#import <LegacyComponents/TGConversation.h>
#import "TGFeedManagementSignals.h"

#import "TGAppDelegate.h"
#import "TGTelegraphDialogListCompanion.h"

#import "TGModernConversationTitleView.h"
#import "TGTokenFieldView.h"

#import "TGShareTargetCell.h"

#import "TGPresentation.h"

@interface TGCreateFeedController () <UITableViewDelegate, UITableViewDataSource, TGTokenFieldViewDelegate>
{
    TGPresentation *_presentation;
    
    id<SDisposable> _channelsDisposable;
    std::map<int64_t, TGConversation *> _selectedChannels;
    
    NSArray *_channels;
    NSArray *_searchResults;
    NSDictionary *_searchCache;
    
    TGModernConversationTitleView *_titleView;
    UIBarButtonItem *_createItem;
    TGListsTableView *_tableView;
    TGTokenFieldView *_tokenFieldView;
}
@end

@implementation TGCreateFeedController

- (instancetype)initWithConversation:(TGConversation *)conversation
{
    self = [super init];
    if (self != nil)
    {
        _presentation = TGPresentation.current;
        
        _createItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Create") style:UIBarButtonItemStyleDone target:self action:@selector(createPressed)];
        _createItem.enabled = false;
        [self setRightBarButtonItem:_createItem];
        
        _selectedChannels.insert(std::pair<int64_t, TGConversation *>(conversation.conversationId, conversation));
    }
    return self;
}

- (void)dealloc
{
    [_channelsDisposable dispose];
    
    //[_actionHandle reset];
    //[ActionStageInstance() removeWatcher:self];
    
    _tokenFieldView.delegate = nil;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = _presentation.pallete.backgroundColor;
    
    CGRect tableFrame = self.view.bounds;
    _tableView = [[TGListsTableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    if (iosMajorVersion() >= 11)
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.opaque = true;
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.showsVerticalScrollIndicator = true;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (iosMajorVersion() >= 7) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = _presentation.pallete.separatorColor;
        _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 99.0f, 0.0f, 0.0f);
    }
    
    _tableView.alwaysBounceVertical = true;
    _tableView.bounces = true;
    _tableView.tableFooterView = [[UIView alloc] init];
    
    [self.view addSubview:_tableView];
    
    _tokenFieldView = [[TGTokenFieldView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _tokenFieldView.presentation = _presentation;
    _tokenFieldView.safeAreaInset = self.controllerSafeAreaInset;
    _tokenFieldView.placeholder = TGLocalized(@"Feed.CreateNewPlaceholder");
    _tokenFieldView.frame = CGRectMake(0, [self tokenFieldOffset], self.view.frame.size.width, [_tokenFieldView preferredHeight]);
    _tokenFieldView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tokenFieldView.delegate = self;
    [self.view addSubview:_tokenFieldView];
    
    [self updateTokenField];
    
    _titleView = [[TGModernConversationTitleView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _titleView.presentation = _presentation;
    _titleView.title = TGLocalized(@"Feed.NewFeedTitle");
    _titleView.status = TGLocalized(@"Feed.NewFeedSubtitle");
    [self setTitleView:_titleView];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
    
    [self updateTableFrame:false collapseSearch:false];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak TGCreateFeedController *weakSelf = self;
    _channelsDisposable = [[[TGDatabaseInstance() channelList] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next)
    {
        __strong TGCreateFeedController *strongSelf = weakSelf;
        if (strongSelf != nil)
            
            next = [next sortedArrayUsingComparator:^NSComparisonResult(TGConversation *conversation1, TGConversation *conversation2)
            {
                return conversation1.date > conversation2.date ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            [strongSelf setChannels:next];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_titleView setOrientation:self.interfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_titleView setOrientation:toInterfaceOrientation];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)createPressed
{
    int32_t feedId = 1;
    
    NSMutableArray *channels = [[NSMutableArray alloc] init];
    NSMutableSet *peerIds = [[NSMutableSet alloc] init];
    for (std::map<int64_t, TGConversation *>::iterator it = _selectedChannels.begin(); it != _selectedChannels.end(); it++)
    {
        [channels addObject:it->second];
        [peerIds addObject:@(it->first)];
    }
    
    [ActionStageInstance() dispatchResource:@"/tg/conversationsGrouped" resource:[[SGraphObjectNode alloc] initWithObject:channels]];
    
    [[TGFeedManagementSignals createFeed:feedId peerIds:peerIds] startWithNext:nil];
    
    [self.navigationController popViewControllerAnimated:true];
}

- (void)setChannels:(NSArray *)channels
{
    NSMutableArray *filteredChannels = [[NSMutableArray alloc] init];
    for (TGConversation *channel in channels)
    {
        if (channel.kind == TGConversationKindPersistentChannel && channel.feedId.intValue == 0 && !channel.isChannelGroup && !channel.restrictionReason)
            [filteredChannels addObject:channel];
    }
    _channels = filteredChannels;
    [_tableView reloadData];
    
    [[SQueue concurrentDefaultQueue] dispatch:^
    {
        NSMutableString *testString = [[NSMutableString alloc] initWithCapacity:256];
        
        NSMutableDictionary *cache = [[NSMutableDictionary alloc] init];
        
        for (TGConversation *conversation in channels)
        {
            [testString deleteCharactersInRange:NSMakeRange(0, testString.length)];
            if (conversation.chatTitle.length != 0)
            {
                [testString appendString:conversation.chatTitle];
                [testString appendString:@" "];
            }
            if (conversation.username != 0)
                [testString appendString:conversation.username];
            
            NSArray *testParts = [cache objectForKey:testString];
            if (testParts == nil)
            {
                CFStringTransform((CFMutableStringRef)testString, NULL, kCFStringTransformStripCombiningMarks, false);
                
                testParts = [[testString lowercaseString] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (testParts != nil)
                    [cache setObject:testParts forKey:@(conversation.conversationId)];
            }
        }
    
        _searchCache = cache;
    }];
}

- (NSArray *)beginSearch:(NSString *)query
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSMutableString *mutableQuery = [[NSMutableString alloc] initWithString:query];
    CFStringTransform((CFMutableStringRef)mutableQuery, NULL, kCFStringTransformStripCombiningMarks, false);
    
    NSArray *queryParts = [query componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (queryParts.count == 0 || ((NSString *)queryParts.firstObject).length == 0)
        return nil;
    
    for (TGConversation *conversation in _channels)
    {
        bool failed = true;
    
        NSArray *testParts = [_searchCache objectForKey:@(conversation.conversationId)];
        
        bool everyPartMatches = true;
        for (NSString *queryPart in queryParts)
        {
            bool hasMatches = false;
            for (NSString *testPart in testParts)
            {
                if ([testPart hasPrefix:queryPart])
                {
                    hasMatches = true;
                    break;
                }
            }
            
            if (!hasMatches)
            {
                everyPartMatches = false;
                break;
            }
        }
        if (everyPartMatches)
            failed = false;
        
        if (!failed)
            [result addObject:conversation];
    }
    
    return result;
}

- (void)updateTokenField
{
    std::set<int64_t> existingPeerIds;
    
    NSMutableIndexSet *removeIndexes = [[NSMutableIndexSet alloc] init];
    
    int index = -1;
    for (id tokenId in [_tokenFieldView tokenIds])
    {
        index++;
        
        if ([tokenId isKindOfClass:[NSNumber class]])
        {
            int64_t peerId = [tokenId int64Value];
            if (_selectedChannels.find(peerId) == _selectedChannels.end())
                [removeIndexes addIndex:index];
            else
                existingPeerIds.insert(peerId);
        }
    }
    
    [_tokenFieldView removeTokensAtIndexes:removeIndexes];
    
    for (std::map<int64_t, TGConversation *>::iterator it = _selectedChannels.begin(); it != _selectedChannels.end(); it++)
    {
        if (existingPeerIds.find(it->first) != existingPeerIds.end())
            continue;
        
        [_tokenFieldView addToken:it->second.chatTitle tokenId:@(it->second.conversationId) animated:true];
    }
    
    _createItem.enabled = _selectedChannels.size() >= 4;
}

- (CGFloat)tokenFieldOffset
{
    CGFloat tokenFieldY = 0;
    tokenFieldY = self.controllerCleanInset.top;
    
    return tokenFieldY;
}

- (void)updateTableFrame:(bool)animated collapseSearch:(bool)collapseSearch
{
    float tableY = 0;
    UIEdgeInsets tableInset = UIEdgeInsetsZero;
    
    tableY = 0;
    tableInset = UIEdgeInsetsMake(_tokenFieldView.frame.size.height, 0.0f, 0.0f, 0.0f);
    
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

- (void)tokenFieldView:(TGTokenFieldView *)tokenFieldView didChangeHeight:(float)height
{
    if (tokenFieldView == _tokenFieldView)
    {
        bool animated = true;
        
        CGRect tokenFieldFrame = CGRectMake(0, [self tokenFieldOffset], _tokenFieldView.frame.size.width, height);
        
        if (animated)
        {
            [UIView animateWithDuration:0.2 animations:^
             {
                 _tokenFieldView.frame = tokenFieldFrame;
                 [_tokenFieldView scrollToTextField:false];
             }];
        }
        else
        {
            _tokenFieldView.frame = tokenFieldFrame;
            [_tokenFieldView scrollToTextField:false];
        }
        
        [self updateTableFrame:animated collapseSearch:false];
    }
}

- (void)tokenFieldView:(TGTokenFieldView *)tokenFieldView didChangeText:(NSString *)text
{
    if (tokenFieldView == _tokenFieldView)
    {
        _searchResults = [self beginSearch:text];
        [_tableView reloadData];
    }
}

- (void)tokenFieldView:(TGTokenFieldView *)tokenFieldView didChangeSearchStatus:(bool)searchIsActive byClearingTextField:(bool)byClearingTextField
{
    if (tokenFieldView == _tokenFieldView)
    {
        CGRect tokenFieldFrame = _tokenFieldView.frame;
        
        bool animated = true;
        
        bool collapseSearchTable = false;
        
        if (!searchIsActive)
        {
            if (!byClearingTextField)
            {
//                [UIView animateWithDuration:0.1 animations:^
//                 {
//                     _searchTableView.alpha = 0.0f;
//                 } completion:^(BOOL finished)
//                 {
//                     if (finished)
//                     {
//                         [UIView animateWithDuration:0.1 animations:^
//                          {
//                              _searchTableViewBackground.alpha = 0.0f;
//                          } completion:^(BOOL finished)
//                          {
//                              if (finished)
//                              {
//                                  [_searchTableView removeFromSuperview];
//                                  [_searchTableViewBackground removeFromSuperview];
//                                  _localSearchResults = nil;
//                                  [_searchTableView reloadData];
//                              }
//                          }];
//                     }
//                 }];
            }
            else
            {
//                _searchTableView.alpha = 0.0f;
//                _searchTableViewBackground.alpha = 0.0f;
//                [_searchTableView removeFromSuperview];
//                [_searchTableViewBackground removeFromSuperview];
            }
            
            _tokenFieldView.scrollView.scrollEnabled = true;
            tokenFieldFrame.origin.y = [self tokenFieldOffset];
        }
        else
        {
//            if (_searchTableView.superview == nil)
//                [self.view insertSubview:_searchTableView aboveSubview:_tableView];
//            if (_searchTableViewBackground.superview == nil)
//                [self.view insertSubview:_searchTableViewBackground belowSubview:_searchTableView];
//
//            _searchTableView.frame = _tableView.frame;
//            _searchTableViewBackground.frame = _tableView.frame;
//
//            _searchTableView.alpha = 1.0f;
//            _searchTableViewBackground.alpha = 1.0f;
            
            _tokenFieldView.scrollView.scrollEnabled = false;
            tokenFieldFrame.origin.y = [self tokenFieldOffset];// + 44 - tokenFieldFrame.size.height;
        }
        
        if (!CGRectEqualToRect(tokenFieldFrame, _tokenFieldView.frame))
        {
            if (animated)
            {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
                 {
                     _tokenFieldView.frame = tokenFieldFrame;
                 } completion:nil];
            }
            else
                _tokenFieldView.frame = tokenFieldFrame;
        }
        
        [self updateTableFrame:animated collapseSearch:collapseSearchTable];
    }
}

- (void)tokenFieldView:(TGTokenFieldView *)tokenFieldView didDeleteTokenWithId:(id)tokenId
{
    if (tokenFieldView == _tokenFieldView)
    {
        if ([tokenId isKindOfClass:[NSNumber class]])
        {
            std::map<int64_t, TGConversation *>::iterator it = _selectedChannels.find([tokenId int64Value]);
            if (it != _selectedChannels.end())
            {
                [self setChannelsSelected:@[it->second] selected:@[@false]];
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section
{
    return _searchResults != nil ? _searchResults.count : _channels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TC";
    TGShareTargetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[TGShareTargetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.presentation = _presentation;
    
    TGConversation *peer = _searchResults != nil ? _searchResults[indexPath.row] : _channels[indexPath.row];
    
    int64_t peerId = peer.conversationId;
    [cell setupWithPeer:peer feed:true];
    
    std::map<int64_t, TGConversation *>::iterator it = _selectedChannels.find(peerId);
    bool checked = it != _selectedChannels.end();
    
    [cell setChecked:checked animated:false];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return 48.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGConversation *conversation = _searchResults != nil ? _searchResults[indexPath.row] : _channels[indexPath.row];
    if (conversation != nil)
    {
        std::map<int64_t, TGConversation *>::iterator it = _selectedChannels.find(conversation.conversationId);
        bool checked = it != _selectedChannels.end();
        
        [self setChannelsSelected:@[conversation] selected:@[@(!checked)]];
        
        TGShareTargetCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setChecked:!checked animated:true];
        
        if (!checked)
        {
            [_tokenFieldView clearText];
        }
    }
}

- (void)setChannelsSelected:(NSArray *)users selected:(NSArray *)selected
{
    std::vector<int> deselectedUids;
    std::vector<int> selectedUids;
    
    int index = -1;
    for (TGConversation *user in users)
    {
        index++;
        int64_t uid = user.conversationId;
        
        bool wasSelected = false;
        bool becameSelected = selected == nil ? false : [[selected objectAtIndex:index] boolValue];
        
        std::map<int64_t, TGConversation *>::iterator it = _selectedChannels.find(uid);
        if (it == _selectedChannels.end())
        {
            if (becameSelected && selected != nil)
                _selectedChannels.insert(std::pair<int64_t, TGConversation *>(uid, user));
        }
        else
        {
            wasSelected = true;
            
            if (!becameSelected)
                _selectedChannels.erase(it);
        }
    }
    
    
    
//    if (updateView)
//    {
//        Class contactCellClass = [TGContactCell class];
//
//        std::map<int, bool> *pUpdateViewItems = &updateViewItems;
//
//        void (^updateBlock)(id, NSUInteger, BOOL *) = ^(UITableViewCell *cell, __unused NSUInteger idx, __unused BOOL *stop)
//        {
//            if ([cell isKindOfClass:contactCellClass])
//            {
//                TGContactCell *contactCell = (TGContactCell *)cell;
//                std::map<int, bool>::iterator it = pUpdateViewItems->find(contactCell.itemId);
//                if (it != updateViewItems.end())
//                {
//                    std::map<int, TGUser *>::iterator itemIt = _selectedUsers.find(contactCell.itemId);
//                    if (itemIt == _selectedUsers.end())
//                        [contactCell updateFlags:false];
//                    else
//                        [contactCell updateFlags:true];
//                }
//            }
//        };
//
//        [[_tableView visibleCells] enumerateObjectsUsingBlock:updateBlock];
//
//        if (updateSearchTable)
//        {
//            if ((_contactsMode & TGContactsModeCompose) == TGContactsModeCompose)
//                [[_searchTableView visibleCells] enumerateObjectsUsingBlock:updateBlock];
//            else
//            {
//                if (_searchMixin.isActive)
//                    [_searchMixin.searchResultsTableView.visibleCells enumerateObjectsUsingBlock:updateBlock];
//            }
//        }
//    }

    
    [self updateTokenField];
    [self updateTableFrame:true collapseSearch:false];
}

@end
