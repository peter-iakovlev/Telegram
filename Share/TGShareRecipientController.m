#import "TGShareRecipientController.h"
#import "TGShareController.h"

#import "TGChatListSignal.h"
#import "TGSearchSignals.h"
#import "TGShareRecentPeersSignals.h"

#import "TGShareChatListCell.h"
#import "TGShareToolbarView.h"
#import "TGShareButton.h"

#import "TGChatModel.h"
#import "TGPrivateChatModel.h"
#import "TGGroupChatModel.h"
#import "TGChannelChatModel.h"
#import "TGUserModel.h"

#import "TGColor.h"

#import <objc/runtime.h>

const CGFloat TGShareBottomInset = 44.0f - 0.5f;

@interface TGShareRecipientController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    TGShareContext *_shareContext;
    
    NSArray *_chatModels;
    NSArray *_userModels;
    
    NSArray *_searchSections;
    
    UIActivityIndicatorView *_activityIndicator;
    
    UITableView *_tableView;
    UITableView *_searchResultsTableView;
    
    UIView *_fadeView;
    
    UISearchBar *_searchBar;
    UIView *_searchDimView;
    
    SMetaDisposable *_chatListDisposable;
    SMetaDisposable *_searchDisposable;
    SMetaDisposable *_recentItemsDisposable;
    
    bool _showRecents;
    NSArray *_recentModels;
    
    bool _selecting;
    NSMutableArray *_recipients;
    
    CGFloat _bottomInset;
}
@end

@implementation TGShareRecipientController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = NSLocalizedString(@"Share.Title", nil);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share.Select", nil) style:UIBarButtonItemStylePlain target:self action:@selector(selectPressed)];
        
        _recipients = [[NSMutableArray alloc] init];
        
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

- (void)selectPressed
{
    [self setSelecting:!_selecting];
}

- (UITextField *)findTextField:(UIView *)view
{
    if ([view isKindOfClass:[UITextField class]])
        return (UITextField *)view;
    
    for (UIView *subview in view.subviews)
    {
        UITextField *result = [self findTextField:subview];
        if (result != nil)
            return result;
    }
    
    return nil;
}

static CGRect UISearchBarTextField_editingRectForBounds(__unused id self, __unused SEL cmd, CGRect bounds)
{
    bounds.origin.x += 28.0f;
    bounds.size.width -= 10.0f;
    return bounds;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 50.0f;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, TGShareBottomInset, 0);
    _tableView.scrollIndicatorInsets = _tableView.contentInset;
    [self.view addSubview:_tableView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.frame.size.width, 44.0f)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar setPlaceholder:NSLocalizedString(@"Share.Search", nil)];
    _searchBar.delegate = self;

    static UIImage *searchBarBackgroundImage = nil;
    static UIImage *searchFieldBackgroundImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        {
            CGFloat radius = 6.0f;
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f + 2.0f, 28.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGColorWithHex(0xededed).CGColor);
            CGContextFillRect(context, CGRectMake(radius, 0.0f, 2.0f, 28.0f));
            CGContextFillRect(context, CGRectMake(0.0f, radius, radius * 2.0f + 2.0f, 28.0f - radius * 2.0f));
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius * 2.0f, radius * 2.0f));
            CGContextFillEllipseInRect(context, CGRectMake(radius * 2.0f + 2.0f - radius * 2.0f, 0.0f, radius * 2.0f, radius * 2.0f));
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 28.0f - radius * 2.0f, radius * 2.0f, radius * 2.0f));
            CGContextFillEllipseInRect(context, CGRectMake(radius * 2.0f + 2.0f - radius * 2.0f, 28.0f - radius * 2.0f, radius * 2.0f, radius * 2.0f));
            searchFieldBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(2.0f, 44.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 2.0f, 44.0f));
            searchBarBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    });
    [_searchBar setBackgroundImage:searchBarBackgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [_searchBar setSearchFieldBackgroundImage:searchFieldBackgroundImage forState:UIControlStateNormal];
    UITextField *searchTextField = [self findTextField:_searchBar];
    if (searchTextField != nil)
    {
        Class newClass = objc_allocateClassPair([searchTextField class], "UISearchBarTextFieldWithInset", 0);
        Method method_editingRectForBounds = class_getInstanceMethod([UITextField class], @selector(editingRectForBounds:));
        if (method_editingRectForBounds != NULL)
        {
            if (!class_addMethod(newClass, @selector(editingRectForBounds:), (IMP)&UISearchBarTextField_editingRectForBounds, method_getTypeEncoding(method_editingRectForBounds)))
            {
                NSLog(@"failed to swizzle");
            }
        }
        object_setClass(searchTextField, newClass);
    }
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateToolbar];
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
    _chatModels = chatModels;
    _userModels = userModels;
    
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
            return 1;
        else
            return _searchSections.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
    {
        return _chatModels.count;
    }
    else if (tableView == _searchResultsTableView)
    {
        if (_showRecents)
            return _recentModels.count;
        else
            return [(NSArray *)(_searchSections[section][@"chats"]) count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGShareChatListCell *cell = (TGShareChatListCell *)[tableView dequeueReusableCellWithIdentifier:@"TGShareChatListCell"];
    if (cell == nil)
        cell = [[TGShareChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGShareChatListCell"];
    
    TGChatModel *chatModel = nil;
    NSArray *users = nil;
    if (tableView == _tableView)
    {
        chatModel = _chatModels[indexPath.row];
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
    
    bool selecting = _selecting && tableView != _searchResultsTableView;
    [cell setSelectionEnabled:selecting animated:false];
    
    if (selecting)
        [cell setChecked:[_recipients containsObject:chatModel] animated:false];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:!_selecting];
    
    TGChatModel *chatModel = nil;
    if (tableView == _tableView)
    {
        chatModel = _chatModels[indexPath.row];
    }
    else if (tableView == _searchResultsTableView)
    {
        if (_showRecents)
            chatModel = _recentModels[indexPath.row];
        else
            chatModel = _searchSections[indexPath.section][@"chats"][indexPath.row];
    }
    
    if (chatModel == nil)
        return;
    
    bool selecting = _selecting && tableView != _searchResultsTableView;
    if (selecting)
    {
        bool selected = [_recipients containsObject:chatModel];
        
        if (selected)
            [_recipients removeObject:chatModel];
        else
            [_recipients addObject:chatModel];
        
        TGShareChatListCell *cell = (TGShareChatListCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell setChecked:!selected animated:true];
        
        [self updateToolbar];
    }
    else
    {
        [_recipients removeAllObjects];
        [_recipients addObject:chatModel];
        
        [self proceed];
    }
}

- (void)proceed
{
    NSString *format = @"";
    NSString *title = @"";
    
    if (_recipients.count == 1)
    {
        TGChatModel *selectedModel = _recipients.firstObject;
        if ([selectedModel isKindOfClass:[TGPrivateChatModel class]])
        {
            format = NSLocalizedString(@"Share.ShareWithPerson", nil);
            for (id model in _userModels)
            {
                if ([model isKindOfClass:[TGUserModel class]] && ((TGUserModel *)model).userId == selectedModel.peerId.peerId)
                {
                    title = ((TGUserModel *)model).displayName;
                    break;
                }
            }
        }
        else if ([selectedModel isKindOfClass:[TGGroupChatModel class]])
        {
            format = NSLocalizedString(@"Share.ShareWithGroup", nil);
            title = ((TGGroupChatModel *)selectedModel).title;
        }
        else if ([selectedModel isKindOfClass:[TGChannelChatModel class]])
        {
            format = NSLocalizedString(@"Share.ShareWithGroup", nil);
            title = ((TGChannelChatModel *)selectedModel).title;
        }
    }
    else
    {
        format = NSLocalizedString(@"Share.ShareWithMultiple", nil);
        title = [NSString stringWithFormat:@"%d", (int)_recipients.count];
    }
    
    NSString *message = [[NSString alloc] initWithFormat:format, title];
    
    __weak TGShareRecipientController *weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Share.Cancel", nil) style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction *action)
    {
        
    }]];    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Share.OK", nil) style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action)
    {
        __strong TGShareRecipientController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        NSMutableArray *peerIds = [[NSMutableArray alloc] init];
        for (TGChatModel *chatModel in strongSelf->_recipients)
        {
            TGPeerId peerId = chatModel.peerId;
            [peerIds addObject:[NSValue valueWithBytes:&peerId objCType:@encode(TGPeerId)]];
        }
        
        [(TGShareController *)strongSelf.navigationController sendToPeers:peerIds models:strongSelf->_userModels];
    }]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)setSearching:(bool)searching
{
    if (searching)
    {
        _searchResultsTableView.hidden = false;
        _searchResultsTableView.alpha = 0.0f;
        _searchResultsTableView.frame = CGRectMake(0.0f, 64.0f + 44.0f, _searchDimView.frame.size.width, _searchDimView.frame.size.height - 64.0f);
        [UIView animateWithDuration:0.25 animations:^
        {
            [self.navigationController setNavigationBarHidden:true animated:false];
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
}

- (void)setSelecting:(bool)selecting
{
    if (_selecting == selecting)
        return;
    
    [_recipients removeAllObjects];
    
    _selecting = selecting;
    
    if (selecting)
    {
        [self.navigationItem setRightBarButtonItem:nil animated:true];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share.Select", nil) style:UIBarButtonItemStylePlain target:self action:@selector(selectPressed)] animated:true];
    }
    
    for (TGShareChatListCell *cell in _tableView.visibleCells)
        [cell setSelectionEnabled:selecting animated:true];
    
    [self updateToolbar];
}

- (void)updateToolbar
{
    TGShareToolbarView *toolbarView = ((TGShareController *)self.navigationController).toolbarView;
    
    if (_selecting)
    {
        toolbarView.rightButtonTitle = NSLocalizedString(@"Share.Done", nil);
        [toolbarView setRightButtonEnabled:(_recipients.count > 0) animated:true];
    }
    else
    {
        toolbarView.rightButtonTitle = nil;
    }
    
    [toolbarView setToolbarTabs:TGShareToolbarTabNone animated:true];
}
    
- (void)searchDimViewTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
        [self searchBarCancelButtonClicked:_searchBar];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:true animated:true];
    [self setSearching:true];
    
    if (_recentItemsDisposable == nil)
        _recentItemsDisposable = [[SMetaDisposable alloc] init];
    
    __weak TGShareRecipientController *weakSelf = self;
    [_recentItemsDisposable setDisposable:[[TGShareRecentPeersSignals recentPeerResultsWithChats:_chatModels] startWithNext:^(id next)
    {
        __strong TGShareRecipientController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_recentModels = next;
        [strongSelf updateRecents];
    }]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
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
        
        SSignal *searchChatsSignal = [TGSearchSignals searchChatsWithContext:_shareContext chats:_chatModels users:_userModels query:text];
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
    if (scrollView == _searchResultsTableView && !_showRecents)
    {
        [self.view endEditing:true];
    }
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)__unused section
{
    if (tableView == _searchResultsTableView && _showRecents && _recentModels.count > 0)
        return 28.0f;
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)__unused section
{
    if (tableView == _tableView)
        return nil;
    
    if (!_showRecents || _recentModels.count == 0)
        return nil;
    
    UIView *sectionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    sectionContainer.clipsToBounds = false;
    sectionContainer.opaque = false;
    
    bool first = true;
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, first ? 0 : -1, 10, first ? 10 : 11)];
    sectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    sectionView.backgroundColor = TGColorWithHex(0xf7f7f7);
    [sectionContainer addSubview:sectionView];
    
    CGFloat separatorHeight = 0.5f;
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10, separatorHeight)];
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    separatorView.backgroundColor = TGSeparatorColor();
    [sectionContainer addSubview:separatorView];
    
    UILabel *sectionLabel = [[UILabel alloc] init];
    sectionLabel.tag = 100;
    sectionLabel.backgroundColor = sectionView.backgroundColor;
    sectionLabel.numberOfLines = 1;
    sectionLabel.font = [UIFont systemFontOfSize:14.5f weight:UIFontWeightMedium];
    sectionLabel.text = NSLocalizedString(@"Share.RecentSection", nil);
    sectionLabel.textColor = TGColorWithHex(0x8e8e93);
    [sectionLabel sizeToFit];
    sectionLabel.frame = CGRectMake(8.0f, 4.5f, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
    [sectionContainer addSubview:sectionLabel];
    
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
    
    return sectionContainer;
}

- (void)clearButtonPressed
{
    [TGShareRecentPeersSignals clearRecentResults];
    _recentModels = nil;
    [_searchResultsTableView reloadData];
}
- (void)viewControllerKeyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = MIN(keyboardFrame.size.height, keyboardFrame.size.width);
    
    _bottomInset = MAX(TGShareBottomInset, keyboardHeight + 44.0f);
    
    if ([self isViewLoaded])
    {
        _searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, _bottomInset, 0);
        _searchResultsTableView.scrollIndicatorInsets = _searchResultsTableView.contentInset;
    }
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

@end
