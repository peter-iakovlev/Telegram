#import "TGRecentCallsController.h"

#import "TGAppDelegate.h"
#import "TGInterfaceManager.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGMessageSearchSignals.h"

#import "TGUserSignal.h"
#import "TGCallDiscardReason.h"

#import "TGModernBarButton.h"
#import "TGListsTableView.h"
#import "TGSearchBar.h"
#import "TGSearchDisplayMixin.h"
#import "TGCallCell.h"

#import "TGSelectContactController.h"

@interface TGRecentCallsController () <UITableViewDelegate, UITableViewDataSource, TGSearchDisplayMixinDelegate>
{
    bool _inSettings;
    bool _editingMode;
    bool _missed;
    
    NSArray *_listModel;
    NSArray *_filteredListModel;
    NSDictionary *_usersModel;
    
    UISegmentedControl *_segmentedControl;
    
    TGListsTableView *_tableView;
    TGSearchBar *_searchBar;
    TGSearchDisplayMixin *_searchMixin;
    UIView *_searchTopBackgroundView;
    
    SMetaDisposable *_disposable;
    SMetaDisposable *_searchDisposable;
}
@end

@implementation TGRecentCallsController

- (instancetype)initForSettings:(bool)settings
{
    self = [super init];
    if (self != nil)
    {
        _inSettings = settings;
        
        [self initialize];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *items = @[TGLocalized(@"Calls.All"), TGLocalized(@"Calls.Missed")];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    
    [_segmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlBackground.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlSelected.png"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlSelected.png"] forState:UIControlStateSelected | UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlHighlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    UIImage *dividerImage = [UIImage imageNamed:@"ModernSegmentedControlDivider.png"];
    [_segmentedControl setDividerImage:dividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    CGFloat width = 0.0f;
    for (NSString *itemName in items)
    {
        CGSize size = [[[NSAttributedString alloc] initWithString:itemName attributes:@{NSFontAttributeName: TGSystemFontOfSize(13)}] boundingRectWithSize:CGSizeMake(FLT_MAX, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        if (size.width > width)
            width = size.width;
    }
    width = (width + 34.0f) * 2.0f;
    
    _segmentedControl.frame = CGRectMake((self.view.frame.size.width - width) / 2.0f, 8, width, 29.0f);
    _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [_segmentedControl setTitleTextAttributes:@{UITextAttributeTextColor: TGAccentColor(), UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(13)} forState:UIControlStateNormal];
    [_segmentedControl setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor], UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(13)} forState:UIControlStateSelected];
    
    [_segmentedControl setSelectedSegmentIndex:0];
    [_segmentedControl addTarget:self action:@selector(segmentedControlChanged) forControlEvents:UIControlEventValueChanged];
    
    [self setTitleView:_segmentedControl];
    
    [self updateBarButtonItemsAnimated:false];
    
    
    
    CGRect tableFrame = self.view.bounds;
    _tableView = [[TGListsTableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.opaque = true;
    _tableView.backgroundColor = nil;
    _tableView.showsVerticalScrollIndicator = true;
    
    __weak TGRecentCallsController *weakSelf = self;
    ((TGListsTableView *)_tableView).onHitTest = ^(CGPoint point) {
        __strong TGRecentCallsController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            for (NSIndexPath *indexPath in [strongSelf->_tableView indexPathsForVisibleRows]) {
                //TGDialogListCell *cell = (TGDialogListCell *)[strongSelf->_tableView cellForRowAtIndexPath:indexPath];
                //if ([cell isKindOfClass:[TGDialogListCell class]]) {
                //    if ([cell isEditingControlsExpanded]) {
                //        CGRect rect = [cell convertRect:cell.bounds toView:strongSelf->_tableView];
                //        if (!CGRectContainsPoint(rect, point)) {
                //            [cell setEditingConrolsExpanded:false animated:true];
                //        }
                //    }
                //}
            }
        }
    };

    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleLightPlain];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _searchTopBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320.0f)];
    _searchTopBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_tableView insertSubview:_searchTopBackgroundView atIndex:0];
    
    _searchMixin = [[TGSearchDisplayMixin alloc] init];
    _searchMixin.searchBar = _searchBar;
    _searchMixin.delegate = self;
    
    _tableView.tableHeaderView = _searchBar;
    
    _searchBar.placeholder = TGLocalized(@"Calls.Search");
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (iosMajorVersion() >= 7) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = TGSeparatorColor();
        _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 85.0f, 0.0f, 0.0f);
    }
    
    _tableView.alwaysBounceVertical = true;
    _tableView.bounces = true;

    [self setTableHidden:_listModel.count == 0];
    
    [self resetInitialOffset];
    
    [self.view addSubview:_tableView];

    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initialize];
}

- (void)resetInitialOffset
{
    if (!TGIsPad())
        _tableView.contentOffset = CGPointMake(0.0f, -_tableView.contentInset.top + [TGSearchBar searchBarBaseHeight] + self.explicitTableInset.top);
}

- (void)setTableHidden:(bool)tableHidden
{
    _tableView.hidden = tableHidden;
}

- (UIBarButtonItem *)editBarButtonItem
{
    if (!_editingMode)
    {
        return [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)];
    }
    else
    {
        return [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    }
}

- (UIBarButtonItem *)actionBarButtonItem
{
    if (_editingMode)
    {
        return [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Calls.Clear") style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonPressed)];
    }
    return nil;
}

- (UIBarButtonItem *)controllerLeftBarButtonItem
{
    return _inSettings ? [self actionBarButtonItem] : [self editBarButtonItem];
}

- (UIBarButtonItem *)controllerRightBarButtonItem
{
    if (_inSettings)
        return [self editBarButtonItem];
    else if (_editingMode)
        return [self actionBarButtonItem];
    
    TGModernBarButton *newCallButton = [[TGModernBarButton alloc] initWithImage:TGTintedImage([UIImage imageNamed:@"TabIconCalls"], TGAccentColor())];
    newCallButton.portraitAdjustment = CGPointMake(2, -4);
    newCallButton.landscapeAdjustment = CGPointMake(2, -4);
    [newCallButton addTarget:self action:@selector(newCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:newCallButton];
}

#pragma mark - Interface Logic

- (void)segmentedControlChanged
{
    _missed = _segmentedControl.selectedSegmentIndex == 1;
    [self reloadDataAnimated:true];
}

- (void)newCallButtonPressed
{
    if ([TGAppDelegateInstance isDisplayingPasscodeWindow])
        return;
    
    TGSelectContactController *selectController = [[TGSelectContactController alloc] initWithCreateGroup:false createEncrypted:false createBroadcast:false createChannel:false inviteToChannel:false showLink:false];
    selectController.customTitle = TGLocalized(@"Calls.NewCall");
    [TGAppDelegateInstance.rootController pushContentController:selectController];
}

- (void)updateBarButtonItemsAnimated:(bool)animated
{
    [self setLeftBarButtonItem:[self controllerLeftBarButtonItem] animated:animated];
    [self setRightBarButtonItem:[self controllerRightBarButtonItem] animated:animated];
}

- (void)editButtonPressed
{
    [self setupEditingMode:!_editingMode];
    
    [self updateBarButtonItemsAnimated:true];
}

- (void)doneButtonPressed
{
    [self setupEditingMode:!_editingMode];
    
    [self updateBarButtonItemsAnimated:true];
    
    //for (UITableViewCell *cell in _tableView.visibleCells)
    //{
    //    if ([cell isKindOfClass:[TGDialogListCell class]])
    //    {
    //        [(TGDialogListCell *)cell dismissEditingControls:true];
    //    }
    //}
}

- (void)clearButtonPressed
{
    
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
    {
        return _missed ? _filteredListModel.count : _listModel.count;
    }
    else
        return 0;
        //return [(NSArray *)_searchResultsSections[section][@"items"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGMessage *message = _missed ? _filteredListModel[indexPath.row] : _listModel[indexPath.row];
    TGUser *peer = _usersModel[@(message.outgoing ? message.toUid : message.fromUid)];
    
    static NSString *CallCellIdentifier = @"CC";
    TGCallCell *cell = [tableView dequeueReusableCellWithIdentifier:CallCellIdentifier];
    if (cell == nil)
    {
        __weak TGRecentCallsController *weakSelf = self;
        cell = [[TGCallCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CallCellIdentifier];
        
        __weak TGCallCell *weakCell = cell;
        cell.infoPressed = ^
        {
            __strong TGRecentCallsController *strongSelf = weakSelf;
            __strong TGCallCell *strongCell = weakCell;
            if (strongSelf != nil && strongCell != nil)
            {
                NSIndexPath *indexPath = [strongSelf->_tableView indexPathForCell:strongCell];
                TGMessage *message = _missed ? strongSelf->_filteredListModel[indexPath.row] : strongSelf->_listModel[indexPath.row];
                TGUser *peer = _usersModel[@(message.outgoing ? message.toUid : message.fromUid)];
                
                [[TGInterfaceManager instance] navigateToProfileOfUser:peer.uid];
            }
        };
    }
    
    [cell setupWithMessage:message peer:peer];
    [cell setIsLastCell:[self isLastCell:indexPath]];
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return 48.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    TGMessage *message = _missed ? _filteredListModel[indexPath.row] : _listModel[indexPath.row];
    TGUser *peer = _usersModel[@(message.outgoing ? message.toUid : message.fromUid)];
    
    [[TGInterfaceManager instance] callPeerWithId:peer.uid];
}

- (bool)isLastCell:(NSIndexPath *)indexPath {
    return !(indexPath.row + 1 < (NSInteger)_listModel.count);
}

- (void)updateIsLastCell {
    for (NSIndexPath *indexPath in _tableView.indexPathsForVisibleRows) {
        TGCallCell *cell = (TGCallCell *)[_tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[TGCallCell class]]) {
            [cell setIsLastCell:[self isLastCell:indexPath]];
        }
    }
}

#pragma mark - Editing

- (void)setupEditingMode:(bool)editing
{
    _editingMode = editing;
    //[self setupEditingMode:editing setupTable:true];
}

#pragma mark - Data

- (void)reloadData
{
    [self setTableHidden:_listModel.count == 0];
    [_tableView reloadData];
}

- (void)reloadDataAnimated:(bool)animated
{
    NSArray *oldEntries = _missed ? _listModel : _filteredListModel;
    NSArray *newEntries = _missed ? _filteredListModel : _listModel;
    
    [self setTableHidden:_listModel.count == 0];
    if (animated)
    {
        [_tableView beginUpdates];
        
        NSMutableArray *rowsToDelete = [NSMutableArray array];
        NSMutableArray *rowsToInsert = [NSMutableArray array];
        
        for (NSUInteger i = 0; i < oldEntries.count; i++ )
        {
            TGMessage *entry = [oldEntries objectAtIndex:i];
            bool contains = false;
            for (NSUInteger j = 0; j < newEntries.count; j++ )
            {
                TGMessage *newEntry = [newEntries objectAtIndex:j];
                if (newEntry.mid == entry.mid)
                {
                    contains = true;
                    break;
                }
            }
            
            if (!contains)
                [rowsToDelete addObject: [NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        for (NSUInteger i = 0; i < newEntries.count; i++)
        {
            TGMessage *entry = [newEntries objectAtIndex:i];
            bool contains = false;
            for (NSUInteger j = 0; j < oldEntries.count; j++ )
            {
                TGMessage *oldEntry = [oldEntries objectAtIndex:j];
                if (oldEntry.mid == entry.mid)
                {
                    contains = true;
                    break;
                }
            }
            
            if (!contains)
                [rowsToInsert addObject: [NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [_tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [_tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
        
        [_tableView endUpdates];
    }
    else
    {
        [_tableView reloadData];
    }
}

- (void)initialize
{
    __weak TGRecentCallsController *weakSelf = self;
    
    _disposable = [[SMetaDisposable alloc] init];
    [_disposable setDisposable:[[[[self searchSignalWithQuery:nil maxMessageId:0] mapToSignal:^SSignal *(id messages) {
        NSMutableIndexSet *userIds = [[NSMutableIndexSet alloc] init];
        for (TGMessage *message in messages)
            [userIds addIndex:(int32_t)message.fromUid];
        
        NSMutableArray *userSignals = [[NSMutableArray alloc] init];
        [userIds enumerateIndexesUsingBlock:^(NSUInteger uid, __unused BOOL *stop)
        {
            if (uid != 0)
                [userSignals addObject:[TGUserSignal userWithUserId:(int32_t)uid]];
        }];
        
        return [[SSignal combineSignals:userSignals] map:^id(NSArray *users)
        {
            NSMutableDictionary *usersMap = [[NSMutableDictionary alloc] init];
            for (TGUser *user in users)
            {
                usersMap[@(user.uid)] = user;
            }
            
            return @{@"calls": messages, @"users": usersMap};
        }];
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        if ([next respondsToSelector:@selector(boolValue)])
        {
            //gotItems = [next boolValue];
        }
        else
        {
            __strong TGRecentCallsController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            strongSelf->_listModel = next[@"calls"];
            NSMutableArray *filtered = [[NSMutableArray alloc] init];
            for (TGMessage *message in next[@"calls"])
            {
                TGActionMediaAttachment *actionMedia = nil;
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGActionMediaAttachmentType)
                    {
                        actionMedia = (TGActionMediaAttachment *)attachment;
                        break;
                    }
                }
                
                if ([actionMedia.actionData[@"reason"] intValue] == TGCallDiscardReasonMissed)
                {
                    [filtered addObject:message];
                }
            }
            strongSelf->_filteredListModel = filtered;
            strongSelf->_usersModel = next[@"users"];

            [strongSelf reloadData];
        }
    } error:^(__unused id error)
    {
        
    } completed:^
    {
        
    }]];
}

- (void)clearData
{
    [_disposable dispose];
    _disposable = nil;
    
    _listModel = nil;
    _usersModel = nil;
    _missed = false;
    [_tableView reloadData];
}

- (SSignal *)searchSignalWithQuery:(NSString *)query maxMessageId:(int32_t)maxMessageId
{
    __weak TGRecentCallsController *weakSelf = self;
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        //__strong TGRecentCallsController *strongSelf = weakSelf;
                 
        SDisposableSet *compositeDisposable = [[SDisposableSet alloc] init];
                 
        [compositeDisposable add:[[TGMessageSearchSignals searchPeer:0 accessHash:0 query:query filter:TGMessageSearchFilterPhoneCalls maxMessageId:maxMessageId limit:128] startWithNext:^(NSArray *messages)
        {
            [subscriber putNext:messages];
        } error:^(id error)
        {
            [subscriber putError:error];
        } completed:^
        {
            [subscriber putCompletion];
        }]];
        
        return compositeDisposable;
    }];
}

@end
