#import "TGShareRecipientController.h"
#import "TGShareController.h"

#import <LegacyDatabase/LegacyDatabase.h>

#import "TGChatListSignal.h"
#import "TGSearchSignals.h"
#import "TGShareRecentPeersSignals.h"

#import "TGShareChatListCell.h"
#import "TGShareTopPeersCell.h"
#import "TGShareToolbarView.h"
#import "TGShareButton.h"
#import "TGShareSearchBar.h"

#import "TGChatModel.h"
#import "TGPrivateChatModel.h"
#import "TGGroupChatModel.h"
#import "TGChannelChatModel.h"
#import "TGUserModel.h"

#import "TGShareCaptionPanel.h"

#import "TGColor.h"

#import <objc/runtime.h>

const CGFloat TGShareBottomInset = 0.0f;

@interface TGShareRecipientController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, TGShareCaptionPanelDelegate>
{
    TGShareContext *_shareContext;
    
    NSArray *_currentPeers;
    NSArray *_foundPeers;
    
    NSArray *_chatModels;
    NSDictionary *_userModels;
    
    NSArray *_searchSections;
    
    UIActivityIndicatorView *_activityIndicator;
    
    UITableView *_tableView;
    UITableView *_searchResultsTableView;
    
    UIView *_fadeView;
    
    TGShareSearchBar *_searchBar;
    UIView *_searchDimView;
    TGShareCaptionPanel *_captionPanel;
    
    SMetaDisposable *_chatListDisposable;
    SMetaDisposable *_searchDisposable;
    SMetaDisposable *_recentItemsDisposable;
    
    bool _showRecents;
    NSArray *_topModels;
    NSArray *_recentModels;
    
    bool _selecting;
    NSMutableArray *_recipients;
    
    bool _searching;
    
    CGFloat _bottomInset;
    CGFloat _keyboardHeight;
    CGFloat _contentAreaHeight;
    
    bool _appeared;
}
@end

@implementation TGShareRecipientController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = NSLocalizedString(@"Share.Title", nil);
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share.Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share.Send", nil) style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)];
        
        self.navigationItem.rightBarButtonItem.enabled = false;
        
        _recipients = [[NSMutableArray alloc] init];
        _foundPeers = [[NSMutableArray alloc] init];        
        
        _bottomInset = 44.0f - 0.5f;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [_chatListDisposable dispose];
    [_searchDisposable dispose];
    [_recentItemsDisposable dispose];
}

- (void)cancelPressed
{
    [(TGShareController *)self.navigationController dismissForCancel:true];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, TGShareBottomInset, 0);
    _tableView.scrollIndicatorInsets = _tableView.contentInset;
    [self.view addSubview:_tableView];
    
    _searchBar = [[TGShareSearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.frame.size.width, [TGShareSearchBar searchBarBaseHeight])];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar setPlaceholder:NSLocalizedString(@"Share.Search", nil)];
    _searchBar.delegate = self;
    
    _tableView.tableHeaderView = _searchBar;
    
    _fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, _searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    _fadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _fadeView.backgroundColor = [UIColor whiteColor];
    _fadeView.userInteractionEnabled = false;
    [_tableView addSubview:_fadeView];
    
    _searchDimView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, self.view.frame.size.width, self.view.frame.size.height + 44.0f)];
    _searchDimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    _searchDimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_searchDimView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchDimViewTapped:)]];
     _searchDimView.alpha = 0.0f;
    [_tableView addSubview:_searchDimView];
    
    _searchResultsTableView = [[UITableView alloc] initWithFrame:_searchDimView.frame style:UITableViewStylePlain];
    _searchResultsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _searchResultsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, _bottomInset, 0.0f);
    _searchResultsTableView.scrollIndicatorInsets = _searchResultsTableView.contentInset;
    _searchResultsTableView.dataSource = self;
    _searchResultsTableView.delegate = self;
    _searchResultsTableView.rowHeight = 50.0f;
    _searchResultsTableView.tableFooterView = [[UIView alloc] init];
    _searchResultsTableView.hidden = true;
    [self.view addSubview:_searchResultsTableView];
    
    if ([_tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _tableView.cellLayoutMarginsFollowReadableWidth = false;
        _searchResultsTableView.cellLayoutMarginsFollowReadableWidth = false;
    }
    
    if (_chatModels == nil)
    {
        _tableView.userInteractionEnabled = false;
        _searchBar.hidden = true;
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activityIndicator.frame = CGRectMake((CGFloat)floor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), (CGFloat)floor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
    }
    
    _captionPanel = [[TGShareCaptionPanel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, [_captionPanel heightForInputFieldHeight:0])];
    _captionPanel.delegate = self;
    [self.view addSubview:_captionPanel];
}

- (void)updateCaptionPanelWithFrame:(CGRect)frame edgeInsets:(UIEdgeInsets)edgeInsets
{
    _captionPanel.frame = CGRectMake(edgeInsets.left, _captionPanel.frame.origin.y, frame.size.width, _captionPanel.frame.size.height);
    [_captionPanel adjustForOrientation:UIInterfaceOrientationPortrait keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _contentAreaHeight = self.view.bounds.size.height;
    [_captionPanel setContentAreaHeight:_contentAreaHeight - _keyboardHeight];
    [self updateCaptionPanelWithFrame:self.view.bounds edgeInsets:UIEdgeInsetsZero];
    
    if (!_appeared)
    {
        _appeared = true;
        [self updateSelection:false];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)setShareContext:(TGShareContext *)shareContext
{
    _shareContext = shareContext;
    
    _chatListDisposable = [[SMetaDisposable alloc] init];
    
    __weak TGShareRecipientController *weakSelf = self;
    [_chatListDisposable setDisposable:[[[TGChatListSignal remoteChatListWithContext:_shareContext] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *next)
    {
        __strong TGShareRecipientController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            _searchBar.hidden = false;
            [_activityIndicator stopAnimating];
            [_activityIndicator removeFromSuperview];
            _tableView.userInteractionEnabled = true;
            
            [strongSelf setChatModels:next[@"chats"] userModels:next[@"users"]];
        }
    }]];
}

- (void)setChatModels:(NSArray *)chatModels userModels:(NSArray *)userModels
{
    _currentPeers = nil;
    _chatModels = chatModels;
    
    NSMutableDictionary *users = [[NSMutableDictionary alloc] init];
    for (TGUserModel *user in userModels)
    {
        if ([user isKindOfClass:[TGUserModel class]])
            users[@(user.userId)] = user;
    }
    
    _userModels = users;
    
    [_tableView reloadData];
    
    if (!_fadeView.hidden && _chatModels.count > 0)
    {
        [_fadeView.superview bringSubviewToFront:_fadeView];
        [UIView animateWithDuration:0.3 animations:^
        {
            _fadeView.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
            _fadeView.hidden = true;
        }];
    }
}

- (void)setSearchResultsSections:(NSArray *)sections
{
    _searchSections = sections;
    [_searchResultsTableView reloadData];
}

- (BOOL)isContentValid
{
    return true;
}

- (NSArray *)configurationItems
{
    return @[];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView)
    {
        return 1;
    }
    else if (tableView == _searchResultsTableView)
    {
        if (_showRecents)
        {
            return (_topModels.count > 0) + (_recentModels.count > 0);
        }
        else
            return _searchSections.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
    {
        return [self currentPeers].count;
    }
    else if (tableView == _searchResultsTableView)
    {
        if (_showRecents) {
            if (_topModels.count > 0 && section == 0)
                return 1;
            else
                return _recentModels.count;
        }
        else
            return [(NSArray *)(_searchSections[section][@"chats"]) count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _searchResultsTableView && _showRecents && _topModels.count > 0 && indexPath.section == 0)
        return 92.0f + 28.0f;
    
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _searchResultsTableView && _showRecents && _topModels.count > 0 && indexPath.section == 0)
    {
        TGShareTopPeersCell *cell = (TGShareTopPeersCell *)[tableView dequeueReusableCellWithIdentifier:@"TGShareTopPeersCell"];
        if (cell == nil)
            cell = [[TGShareTopPeersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGShareTopPeersCell"];
        
        [cell setPeers:_topModels shareContext:_shareContext];
        
        __weak TGShareRecipientController *weakSelf = self;
        cell.isChecked = ^bool(int64_t peerId) {
            __strong TGShareRecipientController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return false;
            
            for (TGChatModel *model in strongSelf->_recipients)
            {
                if (model.peerId.namespaceId == TGPeerIdPrivate && model.peerId.peerId == peerId)
                    return true;
            }
            
            return false;
        };
        cell.checked = ^(int64_t peerId) {
            __strong TGShareRecipientController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            bool selected = false;
            TGPrivateChatModel *chatModel = nil;
            for (TGUserModel *model in strongSelf->_topModels)
            {
                if (model.userId == peerId)
                {
                    chatModel = [model chatModel];
                    bool exists = [strongSelf->_recipients containsObject:chatModel];
                    if (exists)
                    {
                        [strongSelf->_recipients removeObject:chatModel];
                    }
                    else
                    {
                        [strongSelf->_recipients addObject:chatModel];
                        
                        
                        if (strongSelf->_userModels[@(peerId)] == nil)
                        {
                            NSMutableDictionary *updatedUserModels = [_userModels mutableCopy];
                            updatedUserModels[@(model.userId)] = model;
                            strongSelf->_userModels = updatedUserModels;
                            break;
                        }
                    }
                    selected = !exists;
                    
                    break;
                }
            }
            
            if (selected)
                [strongSelf addFoundPeer:chatModel];
            strongSelf->_currentPeers = nil;
            
            [strongSelf searchBarCancelButtonClicked:(UISearchBar *)strongSelf->_searchBar];
            [strongSelf->_tableView reloadData];
            
            [strongSelf updateSelection:true];
        };
        
        cell.layoutMargins = UIEdgeInsetsZero;
        
        return cell;
    }
    else
    {
        TGShareChatListCell *cell = (TGShareChatListCell *)[tableView dequeueReusableCellWithIdentifier:@"TGShareChatListCell"];
        if (cell == nil)
            cell = [[TGShareChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGShareChatListCell"];
        
        TGChatModel *chatModel = nil;
        NSDictionary *users = nil;
        if (tableView == _tableView)
        {
            chatModel = [self currentPeers][indexPath.row];
            users = _userModels;
        }
        else if (tableView == _searchResultsTableView)
        {
            if (_showRecents)
            {
                chatModel = _recentModels[indexPath.row];
                users = _userModels;
            }
            else
            {
                chatModel = _searchSections[indexPath.section][@"chats"][indexPath.row];
                users = _searchSections[indexPath.section][@"users"];
            }
        }
        
        [cell setChatModel:chatModel associatedUsers:users shareContext:_shareContext];
        [cell setChecked:[_recipients containsObject:chatModel] animated:false];
        
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _searchResultsTableView && _showRecents && _topModels.count > 0 && indexPath.section == 0)
    {
        return false;
    }
    
    return true;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:!_selecting];
    
    bool fromSearch = false;
    TGChatModel *chatModel = nil;
    if (tableView == _tableView)
    {
        chatModel = [self currentPeers][indexPath.row];
    }
    else if (tableView == _searchResultsTableView)
    {
        if (_showRecents)
        {
            chatModel = _recentModels[indexPath.row];
        }
        else
        {
            chatModel = _searchSections[indexPath.section][@"chats"][indexPath.row];

            if (_userModels[@(chatModel.peerId.peerId)] == nil)
            {
                for (TGUserModel *user in _searchSections[indexPath.section][@"users"])
                {
                    if (user.userId == chatModel.peerId.peerId)
                    {
                        NSMutableDictionary *updatedUserModels = [_userModels mutableCopy];
                        updatedUserModels[@(user.userId)] = user;
                        _userModels = updatedUserModels;
                        break;
                    }
                }
            }
        }
        
        fromSearch = true;
    }
    
    if (chatModel == nil)
        return;
    
    bool exists = [_recipients containsObject:chatModel];
    if (exists)
        [_recipients removeObject:chatModel];
    else
        [_recipients addObject:chatModel];
    
    [self updateSelection:true];
    
    if (fromSearch)
    {
        if (!exists)
            [self addFoundPeer:chatModel];
        
        _currentPeers = nil;
        [self searchBarCancelButtonClicked:(UISearchBar *)_searchBar];
        [_tableView reloadData];
        return;
    }
    else
    {
        [_searchResultsTableView reloadData];
    }
    
    TGShareChatListCell *cell = (TGShareChatListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setChecked:!exists animated:true];
}

- (NSArray *)currentPeers
{
    if (_currentPeers == nil)
    {
        NSArray *filteredPeers = _chatModels;
        if (_foundPeers.count > 0)
        {
            NSMutableArray *peers = [[NSMutableArray alloc] init];
            NSMutableArray *foundPeers = [_foundPeers mutableCopy];
            
            for (TGChatModel *peer in _chatModels)
            {
                TGPeerId peerId = peer.peerId;
            
                bool found = false;
                for (TGChatModel *foundPeer in foundPeers)
                {
                    TGPeerId foundPeerId = foundPeer.peerId;
                    if (peerId.namespaceId == foundPeerId.namespaceId && peerId.peerId == foundPeerId.peerId)
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

- (void)addFoundPeer:(TGChatModel *)peer
{
    NSMutableArray *foundPeers = [[NSMutableArray alloc] init];
    TGPeerId peerId = peer.peerId;
    
    for (TGChatModel *foundPeer in _foundPeers)
    {
        TGPeerId foundPeerId = foundPeer.peerId;
        if (peerId.namespaceId != foundPeerId.namespaceId || peerId.peerId != foundPeerId.peerId)
            [foundPeers addObject:foundPeer];
    }
    
    [foundPeers insertObject:peer atIndex:0];
    _foundPeers = foundPeers;
}

- (void)updateSelection:(bool)animated
{
    if (_recipients.count == 0 && _captionPanel.isFirstResponder)
        [_captionPanel dismiss];
    
    [_captionPanel setCollapsed:_recipients.count == 0 animated:animated];
    
    self.navigationItem.rightBarButtonItem.enabled = _recipients.count > 0;

    [self updateTableInset];
}

- (void)updateTableInset
{
    _tableView.contentInset = UIEdgeInsetsMake(_tableView.contentInset.top, 0.0f, _recipients.count > 0 ? _captionPanel.frame.size.height : 0.0f, 0.0f);
    _tableView.scrollIndicatorInsets = _tableView.contentInset;
}

- (void)setSearching:(bool)searching
{
    if (_searching == searching)
        return;
    
    _searching = searching;
    
    if (searching)
    {
        _searchResultsTableView.hidden = false;
        _searchResultsTableView.alpha = 0.0f;
        _searchResultsTableView.frame = CGRectMake(0.0f, 64.0f + 44.0f, _searchDimView.frame.size.width, _searchDimView.frame.size.height - 64.0f);
        [UIView animateWithDuration:0.25 animations:^
        {
            [self.navigationController setNavigationBarHidden:true animated:true];
            [_tableView setScrollEnabled:false];
            [_tableView setContentOffset:CGPointMake(0.0f, -20.0f) animated:false];
            _searchResultsTableView.frame = CGRectMake(0.0f, 64.0f, _searchDimView.frame.size.width, _searchDimView.frame.size.height - 64.0f);
            _searchResultsTableView.alpha = 1.0f;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^
        {
            [self.navigationController setNavigationBarHidden:false animated:false];
            [_tableView setScrollEnabled:true];
            [_tableView setContentOffset:CGPointMake(0.0f, -64.0f) animated:false];
            _searchResultsTableView.frame = CGRectMake(0.0f, 64.0f + 44.0f, _searchDimView.frame.size.width, _searchDimView.frame.size.height - 64.0f);
            _searchResultsTableView.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
            _searchResultsTableView.hidden = true;
            _searchSections = nil;
            [_searchResultsTableView reloadData];
            [_searchDisposable setDisposable:nil];
        }];
    }
    
    if (searching)
        [_captionPanel setCollapsed:true animated:true];
    else
        [self updateSelection:true];
}
    
- (void)searchDimViewTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
        [self searchBarCancelButtonClicked:(UISearchBar *)_searchBar];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:true animated:true];
    [self setSearching:true];
    
    if (_recentItemsDisposable == nil)
        _recentItemsDisposable = [[SMetaDisposable alloc] init];
    
    __weak TGShareRecipientController *weakSelf = self;
    [_recentItemsDisposable setDisposable:[[TGShareRecentPeersSignals recentPeerResultsWithContext:_shareContext cachedChats:_chatModels] startWithNext:^(NSDictionary *next)
    {
        __strong TGShareRecipientController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_topModels = next[@"top"];
        strongSelf->_recentModels = next[@"recent"];
        [strongSelf updateRecents];
    }]];
}

- (void)searchBarCancelButtonClicked:(TGShareSearchBar *)searchBar
{
    [searchBar setText:@""];
    [searchBar endEditing:true];
    [searchBar setShowsCancelButton:false animated:true];
    [self setSearching:false];
}

- (void)searchBar:(UISearchBar *)__unused searchBar textDidChange:(NSString *)searchText
{
    NSString *text = searchText;
    if (text.length == 0)
    {
        _searchSections = nil;
        [_searchDisposable setDisposable:nil];
    }
    else
    {
        if (_searchDisposable == nil)
            _searchDisposable = [[SMetaDisposable alloc] init];
        
        __weak TGShareRecipientController *weakSelf = self;
        
        SSignal *searchChatsSignal = [TGSearchSignals searchChatsWithContext:_shareContext chats:_chatModels users:[_userModels allValues] query:text];
        SSignal *searchRemoteSignal = [[[SSignal complete] delay:0.1 onQueue:[SQueue concurrentDefaultQueue]] then:[TGSearchSignals searchUsersWithContext:_shareContext query:text]];
        SSignal *searchSignal = [SSignal combineSignals:@[searchRemoteSignal, searchChatsSignal] withInitialStates:@[@{@"chats": @[], @"users": @[]}]];
        
        [_searchDisposable setDisposable:[[searchSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *results)
        {
            __strong TGShareRecipientController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                NSMutableArray *sections = [[NSMutableArray alloc] init];
                if (((NSArray *)results[1][@"chats"]).count != 0)
                    [sections addObject:@{@"chats": results[1][@"chats"], @"users": results[1][@"users"]}];
                if (((NSArray *)results[0][@"chats"]).count != 0)
                    [sections addObject:@{@"chats": results[0][@"chats"], @"users": results[0][@"users"]}];
                
                [strongSelf setSearchResultsSections:sections];
            }
        }]];
    }
    
    [self updateRecents];
}

- (void)updateRecents
{
    bool showRecents = (_searchBar.text.length == 0);
    if (showRecents != _showRecents)
    {
        _showRecents = showRecents;
        [_searchResultsTableView reloadData];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _searchResultsTableView)
        [self.view endEditing:true];
    else if (scrollView == _tableView && _captionPanel.isFirstResponder)
        [_captionPanel dismiss];
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _searchResultsTableView && _showRecents && _recentModels.count > 0 && (section == 1 || (_topModels.count == 0 && section == 0)))
        return 28.0f;
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)__unused section
{
    if (tableView == _tableView)
        return nil;
    
    bool isRecents = true;
    if (!_showRecents || _recentModels.count == 0)
        return nil;
    
    if (section == 0 && _topModels.count > 0)
        isRecents = false;
    
    if (!isRecents)
        return nil;
    
    UIView *sectionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    sectionContainer.clipsToBounds = false;
    sectionContainer.opaque = false;
    
    bool first = true;
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, first ? 0 : -1, 10, first ? 10 : 11)];
    sectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    sectionView.backgroundColor = TGColorWithHex(0xf7f7f7);
    [sectionContainer addSubview:sectionView];
    
    UILabel *sectionLabel = [[UILabel alloc] init];
    sectionLabel.tag = 100;
    sectionLabel.backgroundColor = sectionView.backgroundColor;
    sectionLabel.numberOfLines = 1;
    sectionLabel.font = [UIFont systemFontOfSize:12.0f weight:UIFontWeightSemibold];
    
    NSString *title = isRecents ? NSLocalizedString(@"Share.RecentSection", nil) : NSLocalizedString(@"Share.PeopleSection", nil);
    sectionLabel.text = [title uppercaseString];
    sectionLabel.textColor = TGColorWithHex(0x8e8e93);
    [sectionLabel sizeToFit];
    sectionLabel.frame = CGRectMake(14.0f, 6.0f, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
    [sectionContainer addSubview:sectionLabel];
    
    if (isRecents)
    {
        TGShareButton *clearButton = [[TGShareButton alloc] init];
        [clearButton setTitle:NSLocalizedString(@"Share.RecentSectionClear", nil) forState:UIControlStateNormal];
        [clearButton setTitleColor:TGColorWithHex(0x8e8e93)];
        clearButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [clearButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f)];
        [clearButton addTarget:self action:@selector(clearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [clearButton sizeToFit];
        clearButton.frame = CGRectMake(sectionContainer.frame.size.width - clearButton.frame.size.width, 0.0f, clearButton.frame.size.width, 28.0f);
        clearButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [sectionContainer addSubview:clearButton];
    }
    
    return sectionContainer;
}

- (void)clearButtonPressed
{
    [TGShareRecentPeersSignals clearRecentResults];
    _recentModels = nil;
    [_searchResultsTableView reloadData];
}

- (void)setContentAreaHeight:(CGFloat)contentAreaHeight
{
    _contentAreaHeight = contentAreaHeight;
    
    CGFloat finalHeight = _contentAreaHeight - _keyboardHeight;
    [_captionPanel setContentAreaHeight:finalHeight];
}

- (void)viewControllerKeyboardWillChangeFrame:(NSNotification *)notification
{
    NSTimeInterval duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil ? 0.3 : [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0.0f : (self.view.frame.size.height - keyboardFrame.origin.y);
    keyboardHeight = MAX(keyboardHeight, 0.0f);
    
    _keyboardHeight = keyboardHeight;

    
    _bottomInset = MAX(TGShareBottomInset, keyboardHeight + 44.0f);
    
    if ([self isViewLoaded])
    {
        _searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, _bottomInset, 0);
        _searchResultsTableView.scrollIndicatorInsets = _searchResultsTableView.contentInset;
    }
    
    keyboardHeight = MAX(keyboardHeight, 0.0f);
    _keyboardHeight = keyboardHeight;
    
    [_captionPanel adjustForOrientation:UIInterfaceOrientationPortrait keyboardHeight:keyboardHeight duration:duration animationCurve:curve];
    
    CGFloat finalHeight = _contentAreaHeight - _keyboardHeight;
    [_captionPanel setContentAreaHeight:finalHeight];
}

- (void)viewControllerKeyboardWillHide:(NSNotification *)notification
{
    CGFloat keyboardHeight = 0.0f;
    
    _bottomInset = MAX(TGShareBottomInset, keyboardHeight);
    
    if ([self isViewLoaded])
    {
        _searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, _bottomInset, 0);
        _searchResultsTableView.scrollIndicatorInsets = _searchResultsTableView.contentInset;
    }
}

- (bool)inputPanelShouldBecomeFirstResponder:(TGShareCaptionPanel *)inputPanel
{
    return true;
}

- (void)inputPanelWillChangeHeight:(TGShareCaptionPanel *)inputPanel height:(CGFloat)__unused height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    [inputPanel adjustForOrientation:UIInterfaceOrientationPortrait keyboardHeight:_keyboardHeight duration:duration animationCurve:animationCurve];
    
    [self updateTableInset];
}

- (void)inputPanelRequestedSend:(TGShareCaptionPanel *)inputPanel text:(NSString *)text
{
    [self donePressed];
}

- (void)inputPanelFocused:(TGShareCaptionPanel *)inputPanel
{
    
}

- (void)donePressed
{
    NSMutableArray *peerIds = [[NSMutableArray alloc] init];
    for (TGChatModel *chatModel in _recipients)
    {
        TGPeerId peerId = chatModel.peerId;
        [peerIds addObject:[NSValue valueWithBytes:&peerId objCType:@encode(TGPeerId)]];
    }
    
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (id model in _currentPeers)
    {
        if ([model isKindOfClass:[TGChannelChatModel class]])
        {
            [models addObject:model];
        }
    }
    [models addObjectsFromArray:[_userModels allValues]];
    
    [(TGShareController *)self.navigationController sendToPeers:peerIds models:models caption:_captionPanel.inputField.text];
}

@end
