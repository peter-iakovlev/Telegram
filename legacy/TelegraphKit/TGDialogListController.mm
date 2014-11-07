#import "TGDialogListController.h"

#import "Freedom.h"

#import "TGDialogListCompanion.h"

#import "TGSearchDisplayMixin.h"

#import "TGConversation.h"
#import "TGUser.h"
#import "TGMessage.h"

#import "TGListsTableView.h"

#import "SGraphObjectNode.h"

#import "TGRemoteImageView.h"

#import "TGDialogListCell.h"
#import "TGDialogListSearchCell.h"

#import "TGToolbarButton.h"

#import "TGActionTableView.h"

#import "TGHacks.h"
#import "TGSearchBar.h"
#import "TGImageUtils.h"
#import "TGLabel.h"

#import "TGObserverProxy.h"

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "TGActivityIndicatorView.h"

#import "TGModernBarButton.h"

#import "TGFont.h"

#import "TGDialogListBroadcastsMenuCell.h"

#include <map>
#include <set>

static bool _debugDoNotJump = false;

static int64_t lastAppearedConversationId = 0;

#pragma mark -

@interface TGDialogListController () <TGViewControllerNavigationBarAppearance, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, TGSearchDisplayMixinDelegate>
{
    std::map<int64_t, NSString *> _usersTypingInConversation;
    
    UIView *_headerBackgroundView;
}

@property (nonatomic, strong) TGSearchBar *searchBar;
@property (nonatomic, strong) TGSearchDisplayMixin *searchMixin;
@property (nonatomic) bool searchControllerWasLoaded;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) bool editingMode;
@property (nonatomic) CGFloat draggingStartOffset;

@property (nonatomic, strong) NSMutableArray *listModel;

@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) NSMutableArray *preparedCellQueue;

@property (nonatomic) bool isLoading;

@property (nonatomic, strong) UIView *titleContainer;
@property (nonatomic, strong) UILabel *titleStatusLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *titleStatusIndicator;

@property (nonatomic) int64_t conversationIdToDelete;

@property (nonatomic, strong) UIActionSheet *currentActionSheet;

@property (nonatomic, strong) UIView *emptyListContainer;

@property (nonatomic, strong) TGObserverProxy *significantTimeChangeProxy;
@property (nonatomic, strong) TGObserverProxy *didEnterBackgroundProxy;
@property (nonatomic, strong) TGObserverProxy *willEnterForegroundProxy;

@end

NSString *authorNameYou = @"  __TGLocalized__YOU";

@implementation TGDialogListController

+ (void)setLastAppearedConversationId:(int64_t)conversationId
{
    lastAppearedConversationId = conversationId;
}

+ (void)setDebugDoNotJump:(bool)debugDoNotJump
{
    _debugDoNotJump = debugDoNotJump;
}

+ (bool)debugDoNotJump
{
    return _debugDoNotJump;
}

- (id)initWithCompanion:(TGDialogListCompanion *)companion
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.automaticallyManageScrollViewInsets = true;
        self.ignoreKeyboardWhenAdjustingScrollViewInsets = true;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _listModel = [[NSMutableArray alloc] init];
        
        _searchResults = [[NSMutableArray alloc] init];
        
        _dialogListCompanion = companion;
        _dialogListCompanion.dialogListController = self;
        
        _significantTimeChangeProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(significantTimeChange:) name:UIApplicationSignificantTimeChangeNotification];
        _didEnterBackgroundProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification];
        _willEnterForegroundProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification];
        
        _doNotHideSearchAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    _dialogListCompanion.dialogListController = nil;
    
    [self doUnloadView];
    
    _currentActionSheet.delegate = nil;
}

- (void)_loadStatusViews
{
    if (_titleStatusLabel == nil)
    {
        _titleStatusLabel = [[UILabel alloc] init];
        _titleStatusLabel.clipsToBounds = false;
        _titleStatusLabel.backgroundColor = [UIColor clearColor];
        _titleStatusLabel.textColor = [UIColor blackColor];
        _titleStatusLabel.font = TGBoldSystemFontOfSize(16.0f);
        [_titleContainer addSubview:_titleStatusLabel];
        
        _titleStatusIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_titleContainer addSubview:_titleStatusIndicator];
    }
}

- (UIBarButtonItem *)controllerLeftBarButtonItem
{
    if (![_dialogListCompanion showListEditingControl])
        return nil;
    
    if (!_editingMode)
    {
        return [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)];
    }
    else
    {
        return [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    }
    
    return nil;
}

- (void)scrollToTopRequested
{
    [_tableView setContentOffset:CGPointMake(0, -_tableView.contentInset.top) animated:true];
}

- (void)titleStateUpdated:(NSString *)text isLoading:(bool)__unused isLoading
{
    if (text == nil)
    {
        _titleStatusLabel.hidden = true;
        _titleStatusIndicator.hidden = true;
        _titleLabel.hidden = false;
        
        [_titleStatusIndicator stopAnimating];
    }
    else
    {
        [self _loadStatusViews];
        
        _titleStatusLabel.hidden = false;
        _titleStatusIndicator.hidden = false;
        _titleLabel.hidden = true;
        
        _titleStatusLabel.text = text;
        [_titleStatusLabel sizeToFit];
        
        [self _layoutTitleViews:self.interfaceOrientation];
        
        if (!_titleStatusIndicator.isAnimating)
            [_titleStatusIndicator startAnimating];
    }
}

- (void)userTypingInConversationUpdated:(int64_t)conversationId typingString:(NSString *)typingString
{
    bool updated = false;
    
    if (typingString.length != 0)
    {
        std::map<int64_t, NSString *>::iterator conversationIt = _usersTypingInConversation.find(conversationId);
        
        if (conversationIt == _usersTypingInConversation.end())
        {
            updated = true;
            _usersTypingInConversation.insert(std::pair<int64_t, NSString *>(conversationId, typingString));
        }
        else
        {
            if (![conversationIt->second isEqualToString:typingString])
            {
                updated = true;
                _usersTypingInConversation[conversationId] = typingString;
            }
        }
    }
    else if (typingString.length == 0 && _usersTypingInConversation.find(conversationId) != _usersTypingInConversation.end())
    {
        updated = true;
        _usersTypingInConversation.erase(conversationId);
    }
    
    if (updated)
    {
        Class dialogListCellClass = [TGDialogListCell class];
        for (UITableViewCell *cell in [_tableView visibleCells])
        {
            if ([cell isKindOfClass:dialogListCellClass])
            {
                TGDialogListCell *dialogCell = (TGDialogListCell *)cell;
                if (dialogCell.conversationId == conversationId)
                {
                    [dialogCell setTypingString:typingString animated:true];
                    
                    break;
                }
            }
        }
    }
}

- (UIBarButtonItem *)controllerRightBarButtonItem
{
    if (_editingMode)
        return nil;
    
    if (iosMajorVersion() < 7)
    {
        TGModernBarButton *composeButton = [[TGModernBarButton alloc] initWithImage:[UIImage imageNamed:@"ModernNavigationComposeButtonIcon.png"]];
        composeButton.portraitAdjustment = CGPointMake(-7, -5);
        composeButton.landscapeAdjustment = CGPointMake(-7, -4);
        [composeButton addTarget:self action:@selector(composeMessageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        return [[UIBarButtonItem alloc] initWithCustomView:composeButton];
    }

    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeMessageButtonPressed:)];
}

- (UIBarStyle)requiredNavigationBarStyle
{
    return UIBarStyleDefault;
}

- (void)_layoutTitleViews:(UIInterfaceOrientation)orientation
{
    CGFloat portraitOffset = 0.0f;
    CGFloat landscapeOffset = 0.0f;
    CGFloat indicatorOffset = 0.0f;
    if (iosMajorVersion() >= 7)
    {
        portraitOffset = 1.0f;
        landscapeOffset = 0.0f;
        indicatorOffset = -1.0f;
    }
    else
    {
        portraitOffset = -1.0f;
        landscapeOffset = 1.0f;
        indicatorOffset = 0.0f;
    }
    
    CGRect titleLabelFrame = _titleLabel.frame;
    titleLabelFrame.origin = CGPointMake(CGFloor((_titleContainer.frame.size.width - titleLabelFrame.size.width) / 2.0f), CGFloor((_titleContainer.frame.size.height - titleLabelFrame.size.height) / 2.0f) + (UIInterfaceOrientationIsPortrait(orientation) ? portraitOffset : landscapeOffset));
    _titleLabel.frame = titleLabelFrame;
    
    if (_titleStatusLabel != nil)
    {
        CGRect titleStatusLabelFrame = _titleStatusLabel.frame;
        titleStatusLabelFrame.origin = CGPointMake(CGFloor((_titleContainer.frame.size.width - titleStatusLabelFrame.size.width) / 2.0f) + 16.0f, CGFloor((_titleContainer.frame.size.height - titleStatusLabelFrame.size.height) / 2.0f) + (UIInterfaceOrientationIsPortrait(orientation) ? portraitOffset : landscapeOffset));
        _titleStatusLabel.frame = titleStatusLabelFrame;

        CGRect titleIndicatorFrame = _titleStatusIndicator.frame;
        titleIndicatorFrame.origin = CGPointMake(titleStatusLabelFrame.origin.x - titleIndicatorFrame.size.width - 4.0f, titleStatusLabelFrame.origin.y  + indicatorOffset);
        _titleStatusIndicator.frame = titleIndicatorFrame;
    }
}

- (void)loadView
{
    [super loadView];
    
    [self setTitleText:TGLocalized(@"DialogList.Title")];
    
    _titleContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2.0f, 2.0f)];
    [self setTitleView:_titleContainer];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = TGBoldSystemFontOfSize(17.0f);
    _titleLabel.text = TGLocalized(@"DialogList.Title");
    [_titleLabel sizeToFit];
    [_titleContainer addSubview:_titleLabel];
    
    [self _layoutTitleViews:self.interfaceOrientation];
    
    [self setLeftBarButtonItem:[self controllerLeftBarButtonItem]];
    [self setRightBarButtonItem:[self controllerRightBarButtonItem]];
    
    self.view.backgroundColor = [_dialogListCompanion.dialogListCellAssetsSource dialogListBackgroundColor];
    
    _headerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.controllerInset.top)];
    _headerBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_headerBackgroundView];
    
    CGRect tableFrame = self.view.bounds;
    _tableView = [[TGListsTableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.opaque = true;
    _tableView.backgroundColor = nil;
    
    //[self setExplicitTableInset:UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f)];

    [(TGListsTableView *)_tableView adjustBehaviour];
    
    _tableView.showsVerticalScrollIndicator = true;
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGIsPad() ? TGSearchBarStyleLightPlain : TGSearchBarStyleLightPlain];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _searchMixin = [[TGSearchDisplayMixin alloc] init];
    _searchMixin.searchBar = _searchBar;
    _searchMixin.delegate = self;
    
    if (!_dialogListCompanion.forwardMode && !_dialogListCompanion.privacyMode)
        _searchBar.customScopeButtonTitles = @[TGLocalized(@"DialogList.Conversations"), TGLocalized(@"DialogList.Messages")];
    
    _tableView.tableHeaderView = _searchBar;
    
    _searchBar.placeholder = TGLocalized(@"DialogList.SearchLabel");
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.alwaysBounceVertical = true;
    _tableView.bounces = true;
    
    [self setTableHidden:_listModel.count == 0];
    
    [self resetInitialOffset];
    
    [self.view addSubview:_tableView];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)doUnloadView
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    
    _searchBar = nil;
    
    _searchMixin.delegate = nil;
    [_searchMixin unload];
}

- (void)viewDidUnload
{
    [self doUnloadView];
    
    [super viewDidUnload];
}

- (void)resetInitialOffset
{
    if (!_doNotHideSearchAutomatically)
        _tableView.contentOffset = CGPointMake(0.0f, -_tableView.contentInset.top + [TGSearchBar searchBarBaseHeight] + self.explicitTableInset.top);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self _layoutTitleViews:self.interfaceOrientation];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if (lastAppearedConversationId != 0 && !_debugDoNotJump && !_dialogListCompanion.forwardMode && !_dialogListCompanion.privacyMode)
        {
            int64_t conversationId = lastAppearedConversationId;
            lastAppearedConversationId = 0;
            
            if (animated && !_searchMixin.isActive)
            {
                bool found = false;
                
                int index = -1;
                for (TGConversation *conversation in _listModel)
                {
                    index++;
                    
                    if (conversation.conversationId == conversationId)
                    {
                        UITableViewScrollPosition scrollPosition = UITableViewScrollPositionNone;
                        
                        CGRect convertRect = [_tableView convertRect:[_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]] toView:self.view];
                        if (convertRect.origin.y + convertRect.size.height > self.view.frame.size.height - self.controllerInset.bottom)
                            scrollPosition = UITableViewScrollPositionBottom;
                        else if (convertRect.origin.y < self.controllerInset.top)
                            scrollPosition = UITableViewScrollPositionTop;
                        
                        if (_searchMixin.isActive)
                            scrollPosition = UITableViewScrollPositionNone;
                        
                        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1] animated:false scrollPosition:scrollPosition];
                        
                        found = true;
                        
                        break;
                    }
                }
            }
            else
            {
                if ([_tableView indexPathForSelectedRow] != nil)
                    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];
            }
        }
        
        if ([_tableView indexPathForSelectedRow] != nil)
            [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];
    }
    
    if (_searchMixin.isActive)
    {
        [_searchMixin controllerLayoutUpdated:[TGViewController screenSizeForInterfaceOrientation:self.interfaceOrientation]];
        
        UITableView *searchTableView = _searchMixin.searchResultsTableView;
        
        if ([searchTableView indexPathForSelectedRow] != nil)
            [searchTableView deselectRowAtIndexPath:[searchTableView indexPathForSelectedRow] animated:true];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        TGLog(@"===== Dialog list did appear");
    });
    
    [_dialogListCompanion wakeUp];
    
    for (id cell in _tableView.visibleCells)
    {
        if ([cell isKindOfClass:[TGDialogListCell class]])
        {
            [(TGDialogListCell *)cell restartAnimations:false];
        }
    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (iosMajorVersion() >= 7)
        [_searchMixin resignResponderIfAny];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (animated)
    {
        for (NSIndexPath *indexPath in _tableView.indexPathsForVisibleRows)
        {
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            
            if ([cell isKindOfClass:[TGDialogListCell class]])
            {
                TGDialogListCell *dialogCell = (TGDialogListCell *)cell;
                [dialogCell dismissEditingControls:false];
                [dialogCell stopAnimations];
            }
        }
        
        if (_searchMixin.isActive && _searchBar.selectedScopeButtonIndex == 0)
            [_searchMixin setIsActive:false animated:false];
    }
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    if (self.navigationBarShouldBeHidden)
    {
        [_tableView setContentOffset:CGPointMake(0, -_tableView.contentInset.top) animated:false];
    }
    
    if (_searchMixin != nil)
        [_searchMixin controllerInsetUpdated:self.controllerInset];
    
    _headerBackgroundView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.controllerInset.top);
    
    [super controllerInsetUpdated:previousInset];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self _layoutTitleViews:toInterfaceOrientation];
    
    if (_searchMixin != nil)
        [_searchMixin controllerLayoutUpdated:[TGViewController screenSizeForInterfaceOrientation:toInterfaceOrientation]];
    
    if (_emptyListContainer != nil)
    {
        _emptyListContainer.frame = CGRectMake(floorf((self.view.frame.size.width - 250) / 2), floorf((self.view.frame.size.height - _emptyListContainer.frame.size.height) / 2), _emptyListContainer.frame.size.width, _emptyListContainer.frame.size.height);
    }
}

- (void)significantTimeChange:(NSNotification *)__unused notification
{
    for (UITableViewCell *cell in _tableView.visibleCells)
    {
        if ([cell isKindOfClass:[TGDialogListCell class]])
        {
            TGDialogListCell *dialogCell = (TGDialogListCell *)cell;
            [dialogCell resetView:true];
        }
    }
}

- (void)didEnterBackground:(NSNotification *)__unused notification
{
    for (UITableViewCell *cell in _tableView.visibleCells)
    {
        if ([cell isKindOfClass:[TGDialogListCell class]])
        {
            TGDialogListCell *dialogCell = (TGDialogListCell *)cell;
            [dialogCell stopAnimations];
        }
    }
}

- (void)willEnterForeground:(NSNotification *)__unused notification
{
    for (UITableViewCell *cell in _tableView.visibleCells)
    {
        if ([cell isKindOfClass:[TGDialogListCell class]])
        {
            TGDialogListCell *dialogCell = (TGDialogListCell *)cell;
            [dialogCell restartAnimations:true];
        }
    }
}

#pragma mark - List management

- (void)reloadData
{
    NSMutableDictionary *temporaryImageCache = [[NSMutableDictionary alloc] init];
    for (UITableViewCell *cell in _tableView.visibleCells)
    {
        if ([cell isKindOfClass:[TGDialogListCell class]])
        {
            [((TGDialogListCell *)cell) collectCachedPhotos:temporaryImageCache];
        }
    }
    [[TGRemoteImageView sharedCache] addTemporaryCachedImagesSource:temporaryImageCache autoremove:true];
    [_tableView reloadData];
}

- (void)resetState
{
    [self setTableHidden:true];
    [_emptyListContainer removeFromSuperview];
    _emptyListContainer = nil;
}

- (void)dialogListFullyReloaded:(NSArray *)items
{
    if (_listModel.count == 0)
        [self resetInitialOffset];
    
    _isLoading = false;
    
    int64_t selectedConversation = INT64_MAX;
    NSIndexPath *selectedIndexPath = [_tableView indexPathForSelectedRow];
    if (selectedIndexPath != nil)
    {
        if (selectedIndexPath.row < _listModel.count)
        {
            TGConversation *conversation = [_listModel objectAtIndex:selectedIndexPath.row];
            selectedConversation = conversation.conversationId;
        }
    }
    
    [_listModel removeAllObjects];
    [_listModel addObjectsFromArray:items];
    
    [self reloadData];
    
    if (selectedConversation != INT64_MAX)
    {
        int index = -1;
        for (TGConversation *conversation in _listModel)
        {
            index++;
            int64_t conversationId = conversation.conversationId;
            if (conversationId == selectedConversation)
            {
                [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1] animated:false scrollPosition:UITableViewScrollPositionNone];
                
                break;
            }
        }
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        TGLog(@"===== Dialog list reloaded");
    });
    
    [self updateEmptyListContainer];
}

- (void)updateEmptyListContainer
{
    if (_listModel.count == 0 && _emptyListContainer == nil)
    {
        _emptyListContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 0)];
        [self.view insertSubview:_emptyListContainer belowSubview:_tableView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = UIColorRGB(0x999999);
        titleLabel.font = TGSystemFontOfSize(20);
        titleLabel.text = TGLocalized(@"DialogList.NoMessagesTitle");
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectOffset(titleLabel.frame, floorf((_emptyListContainer.frame.size.width - titleLabel.frame.size.width) / 2), 0.0f);
        [_emptyListContainer addSubview:titleLabel];
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        textLabel.numberOfLines = 0;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = UIColorRGB(0x999999);
        textLabel.font = TGSystemFontOfSize(15);
        textLabel.text = TGLocalized(@"DialogList.NoMessagesText");
        CGSize textLabelSize = [textLabel sizeThatFits:CGSizeMake(300, 1000)];
        textLabel.frame = CGRectMake(floorf((_emptyListContainer.frame.size.width - textLabelSize.width) / 2), titleLabel.frame.origin.y + titleLabel.frame.size.height + 14, textLabelSize.width, textLabelSize.height);
        [_emptyListContainer addSubview:textLabel];
        
        float containerHeight = textLabel.frame.origin.y + textLabel.frame.size.height;
        
        _emptyListContainer.frame = CGRectMake(floorf((self.view.frame.size.width - 250) / 2), floorf((self.view.frame.size.height - containerHeight) / 2), _emptyListContainer.frame.size.width, containerHeight);
    }
    else if (_emptyListContainer != nil && _listModel.count != 0)
    {
        [_emptyListContainer removeFromSuperview];
        _emptyListContainer = nil;
    }
    
    [self setTableHidden:_listModel.count == 0];

    if (_emptyListContainer != nil)
        _emptyListContainer.hidden = ![_dialogListCompanion shouldDisplayEmptyListPlaceholder];
}

- (void)setTableHidden:(bool)tableHidden
{
    _tableView.hidden = tableHidden;
    self.view.backgroundColor = tableHidden ? [UIColor whiteColor] : [_dialogListCompanion.dialogListCellAssetsSource dialogListBackgroundColor];
}

- (void)dialogListItemsChanged:(NSArray *)__unused insertedIndices insertedItems:(NSArray *)__unused insertedItems updatedIndices:(NSArray *)__unused updatedIndices updatedItems:(NSArray *)__unused updatedItems removedIndices:(NSArray *)__unused removedIndices
{
    int countBefore = _listModel.count;
    
    NSMutableArray *removedIndexPaths = [[NSMutableArray alloc] init];
    for (NSNumber *nRemovedIndex in removedIndices)
    {
        [_listModel removeObjectAtIndex:[nRemovedIndex intValue]];
        [removedIndexPaths addObject:[NSIndexPath indexPathForRow:[nRemovedIndex intValue] inSection:1]];
    }
    
    if (removedIndexPaths.count != 0)
    {
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:removedIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [_tableView endUpdates];
    }
    
    int index = -1;
    for (NSNumber *nUpdatedIndex in updatedIndices)
    {
        index++;
        [_listModel replaceObjectAtIndex:[nUpdatedIndex intValue] withObject:[updatedItems objectAtIndex:index]];
    }
    
    for (NSNumber *nUpdatedIndex in updatedIndices)
    {
        TGDialogListCell *cell = (TGDialogListCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[nUpdatedIndex intValue] inSection:1]];
        if (cell != nil)
        {
            TGConversation *conversation = [_listModel objectAtIndex:[nUpdatedIndex intValue]];
            
            [self prepareCell:cell forConversation:conversation animated:true isSearch:false];
        }
    }
    
    if ((countBefore == 0) != (_listModel.count == 0))
    {
        [self updateEmptyListContainer];
        
        if (_listModel.count == 0)
            [self setupEditingMode:false setupTable:true];
    }
}

- (void)selectConversationWithId:(int64_t)conversationId
{
    bool found = false;
    
    int index = -1;
    for (TGConversation *conversation in _listModel)
    {
        index++;
        
        if (conversation.conversationId == conversationId)
        {
            UITableViewScrollPosition scrollPosition = UITableViewScrollPositionNone;
            
            CGRect convertRect = [_tableView convertRect:[_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]] toView:self.view];
            if (convertRect.origin.y + convertRect.size.height > self.view.frame.size.height - self.controllerInset.bottom)
                scrollPosition = UITableViewScrollPositionBottom;
            else if (convertRect.origin.y < self.controllerInset.top)
                scrollPosition = UITableViewScrollPositionTop;
            
            if (_searchMixin.isActive)
                scrollPosition = UITableViewScrollPositionNone;
            
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1] animated:false scrollPosition:scrollPosition];
            
            found = true;
            
            break;
        }
    }
    
    if (!found && [_tableView indexPathForSelectedRow] != nil)
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:false];
}

- (void)searchResultsReloaded:(NSArray *)items searchString:(NSString *)searchString
{
    [_searchResults removeAllObjects];
    if (items != nil)
        [_searchResults addObjectsFromArray:items];
    
    [_searchMixin reloadSearchResults];
    
    [_searchMixin setSearchResultsTableViewHidden:searchString.length == 0];
}

#pragma mark - Interface logic

- (void)editButtonPressed
{
    [self setupEditingMode:!_editingMode];
    
    [self setLeftBarButtonItem:[self controllerLeftBarButtonItem] animated:true];
    [self setRightBarButtonItem:[self controllerRightBarButtonItem] animated:true];
}

- (void)doneButtonPressed
{
    [self setupEditingMode:!_editingMode];
    
    [self setLeftBarButtonItem:[self controllerLeftBarButtonItem] animated:true];
    [self setRightBarButtonItem:[self controllerRightBarButtonItem] animated:true];
    
    for (UITableViewCell *cell in _tableView.visibleCells)
    {
        if ([cell isKindOfClass:[TGDialogListCell class]])
        {
            [(TGDialogListCell *)cell dismissEditingControls:true];
        }
    }
}

- (void)setupEditingMode:(bool)editing
{
    [self setupEditingMode:editing setupTable:true];
}

- (void)setupEditingMode:(bool)editing setupTable:(bool)setupTable
{
    _editingMode = editing;
    if (setupTable)
        [_tableView setEditing:editing animated:true];
    
    if (!editing)
        [self selectCurrentConversation];
}

- (void)dismissEditingControls
{
    if (_editingMode && !_tableView.editing)
        [self setupEditingMode:false setupTable:false];
}

- (void)composeMessageButtonPressed:(id)__unused sender
{
    [_dialogListCompanion composeMessage];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static bool canSelect = true;
    if (canSelect)
    {
        canSelect = false;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            canSelect = true;
        });
    }
    else
        return;
    
    if (TGIsPad())
        [self.view endEditing:true];
    
    if (tableView == _tableView)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.selectionStyle != UITableViewCellSelectionStyleNone)
        {
            TGConversation *conversation = nil;
            if (indexPath.row < _listModel.count)
                conversation = [_listModel objectAtIndex:indexPath.row];
            
            if (conversation != nil)
            {
                [_dialogListCompanion conversationSelected:conversation];
            }
            
            if (_dialogListCompanion.forwardMode || _dialogListCompanion.privacyMode)
                [_tableView deselectRowAtIndexPath:indexPath animated:true];
        }
    }
    else
    {
        id result = nil;
        if (indexPath.row < _searchResults.count)
            result = [_searchResults objectAtIndex:indexPath.row];
        
        if ([result isKindOfClass:[TGConversation class]])
        {
            TGConversation *conversation = (TGConversation *)result;
            if ([conversation.additionalProperties objectForKey:@"searchMessageId"] != nil)
                [_dialogListCompanion searchResultSelectedConversation:(TGConversation *)result atMessageId:[[conversation.additionalProperties objectForKey:@"searchMessageId"] intValue]];
            else
                [_dialogListCompanion searchResultSelectedConversation:(TGConversation *)result];
        }
        else if ([result isKindOfClass:[TGUser class]])
        {
            [_dialogListCompanion searchResultSelectedUser:(TGUser *)result];
        }
        else if ([result isKindOfClass:[TGMessage class]])
        {
            [_dialogListCompanion searchResultSelectedMessage:(TGMessage *)result];
        }
    }
    
    if (_dialogListCompanion.forwardMode)
        [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark - Table logic

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView)
        return 2;
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
    {
        if (section == 0)
            return (TGIsPad() && _dialogListCompanion.showBroadcastsMenu) ? 1 : 0;
        
        return _listModel.count;
    }
    else
    {
        return _searchResults.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        if (indexPath.section == 0)
            return 45.0f;
        
        int row = indexPath.row;
        if (row >= 0 && row < _listModel.count)
            return 76;
        
        return 0;
    }
    else
    {
        return _searchBar.selectedScopeButtonIndex == 0 ? 51 : 76;
    }
}

- (void)prepareCell:(TGDialogListCell *)cell forConversation:(TGConversation *)conversation animated:(bool)animated isSearch:(bool)isSearch
{
    if (cell.reuseTag != (int)conversation || cell.conversationId != conversation.conversationId)
    {
        cell.reuseTag = (int)conversation;
        cell.conversationId = conversation.conversationId;
    
        cell.date = conversation.date;
        
        if (conversation.deliveryError)
            cell.deliveryState = TGMessageDeliveryStateFailed;
        else
            cell.deliveryState = conversation.deliveryState;
        
        NSDictionary *dialogListData = conversation.dialogListData;
        
        cell.titleText = [dialogListData objectForKey:@"title"];
        cell.titleLetters = [dialogListData objectForKey:@"titleLetters"];
        
        cell.isBroadcast = [dialogListData[@"isBroadcast"] boolValue];
        
        cell.isEncrypted = [dialogListData[@"isEncrypted"] boolValue];
        cell.encryptionStatus = [dialogListData[@"encryptionStatus"] intValue];
        cell.encryptedUserId = [dialogListData[@"encryptedUserId"] intValue];
        cell.encryptionOutgoing = [dialogListData[@"encryptionOutgoing"] boolValue];
        cell.encryptionFirstName = dialogListData[@"encryptionFirstName"];
        
        NSNumber *nIsChat = [dialogListData objectForKey:@"isChat"];
        if (nIsChat != nil && [nIsChat boolValue])
        {
            NSArray *chatAvatarUrls = [dialogListData objectForKey:@"chatAvatarUrls"];
            cell.groupChatAvatarCount = chatAvatarUrls.count;
            cell.groupChatAvatarUrls = chatAvatarUrls;
            cell.isGroupChat = true;
            cell.avatarUrl = [dialogListData objectForKey:@"avatarUrl"];
            
            NSString *authorName = [dialogListData objectForKey:@"authorName"];
            cell.authorName = [authorName isEqualToString:authorNameYou] ? TGLocalized(@"DialogList.You") : authorName;
        }
        else
        {
            cell.avatarUrl = [dialogListData objectForKey:@"avatarUrl"];
            cell.isGroupChat = false;
            
            NSString *authorName = [dialogListData objectForKey:@"authorName"];
            cell.authorName = [authorName isEqualToString:authorNameYou] ? TGLocalized(@"DialogList.You") : authorName;
        }
        
        cell.isMuted = [[dialogListData objectForKey:@"mute"] boolValue];
        
        cell.unread = conversation.unread;
        if (!isSearch)
        {
            if ([_dialogListCompanion isConversationOpened:conversation.conversationId])
            {
                cell.unreadCount = 0;
                cell.serviceUnreadCount = 0;
            }
            else
            {
                cell.unreadCount = conversation.unreadCount;
                cell.serviceUnreadCount = conversation.serviceUnreadCount;
            }
        }
        cell.outgoing = conversation.outgoing;
        
        cell.messageText = conversation.text;
        cell.messageAttachments = conversation.media;
        cell.users = [dialogListData objectForKey:@"users"];
        
        [cell resetView:animated];
    }
    
    if (!isSearch)
    {
        std::map<int64_t, NSString *>::iterator typingIt = _usersTypingInConversation.find(conversation.conversationId);
        if (typingIt == _usersTypingInConversation.end())
            [cell setTypingString:nil];
        else
            [cell setTypingString:typingIt->second];
    }
    
    [cell restartAnimations:false];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGUser *user = nil;
    TGConversation *conversation = nil;
    TGMessage *message = nil;
    
    if (tableView == _tableView)
    {
        if (indexPath.section == 0)
        {
            static NSString *TGDialogListBroadcastsMenuCellIdentifier = @"TGDialogListBroadcastsMenuCell";
            TGDialogListBroadcastsMenuCell *cell = (TGDialogListBroadcastsMenuCell *)[tableView dequeueReusableCellWithIdentifier:TGDialogListBroadcastsMenuCellIdentifier];
            if (cell == nil)
            {
                cell = [[TGDialogListBroadcastsMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TGDialogListBroadcastsMenuCellIdentifier];
                
                __weak TGDialogListController *weakSelf = self;
                cell.broadcastListsPressed = ^
                {
                    __strong TGDialogListController *strongSelf = weakSelf;
                    [strongSelf.dialogListCompanion navigateToBroadcastLists];
                };
                
                cell.newGroupPressed = ^
                {
                    __strong TGDialogListController *strongSelf = weakSelf;
                    [strongSelf.dialogListCompanion navigateToNewGroup];
                };
            }
            
            return cell;
        }
        else
        {
            if (indexPath.row < _listModel.count)
                conversation = [_listModel objectAtIndex:indexPath.row];
        }
    }
    else
    {
        if (indexPath.row < _searchResults.count)
        {
            id result = [_searchResults objectAtIndex:indexPath.row];
            if ([result isKindOfClass:[TGConversation class]])
                conversation = result;
            else if ([result isKindOfClass:[TGUser class]])
                user = result;
            else if ([result isKindOfClass:[TGMessage class]])
                message = result;
        }
    }
    
    if (tableView == _tableView)
    {
        if (conversation != nil)
        {
            static NSString *MessageCellIdentifier = @"MC";
            TGDialogListCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
            
            if (cell == nil)
            {
                if (_preparedCellQueue != nil && _preparedCellQueue.count != 0)
                {
                    cell = [_preparedCellQueue lastObject];
                    [_preparedCellQueue removeLastObject];
                }
                if (cell == nil)
                {
                    cell = [[TGDialogListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageCellIdentifier assetsSource:[_dialogListCompanion dialogListCellAssetsSource]];
                    cell.watcherHandle = _actionHandle;
                    cell.enableEditing = ![_dialogListCompanion forwardMode] && !_dialogListCompanion.privacyMode;
                }
            }
            
            [self prepareCell:cell forConversation:conversation animated:false isSearch:false];
            
            return cell;
        }
        
        static NSString *PlaceholderCellIdentifier = @"LC";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PlaceholderCellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.contentView.backgroundColor = [UIColor clearColor];
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.tag = 10000;
            spinner.frame = CGRectMake(0, 0, 24, 24);
            spinner.center = cell.center;
            spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
            [cell.contentView addSubview:spinner];
        }
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:10000];
        if (_canLoadMore)
        {
            spinner.hidden = false;
            [spinner startAnimating];
        }
        else
        {
            spinner.hidden = true;
            [spinner stopAnimating];
        }
        return cell;
    }
    else
    {
        if ((conversation != nil || user != nil) && _searchBar.selectedScopeButtonIndex == 0)
        {
            static NSString *SearchCellIdentifier = @"UC";
            TGDialogListSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
            if (cell == nil)
            {
                cell = [[TGDialogListSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier assetsSource:[_dialogListCompanion dialogListCellAssetsSource]];
            }
            
            cell.isEncrypted = false;
            cell.encryptedUserId = 0;
            
            if (conversation != nil)
            {
                NSDictionary *dialogListData = conversation.dialogListData;
                
                cell.isEncrypted = [dialogListData[@"isEncrypted"] boolValue];
                
                if (cell.isEncrypted)
                {
                    cell.titleTextFirst = dialogListData[@"firstName"];
                    cell.titleTextSecond = dialogListData[@"lastName"];
                }
                else
                {
                    cell.titleTextFirst = [dialogListData objectForKey:@"title"];
                    cell.titleTextSecond = nil;
                }
                
                NSNumber *nIsChat = [dialogListData objectForKey:@"isChat"];
                if (nIsChat != nil && [nIsChat boolValue])
                    cell.isChat = true;
                
                cell.avatarUrl = [dialogListData objectForKey:@"avatarUrl"];
                
                cell.subtitleText = nil;
                
                cell.conversationId = conversation.conversationId;
                cell.encryptedUserId = [dialogListData[@"encryptedUserId"] intValue];
            }
            else if (user != nil)
            {
                cell.isChat = false;
                
                cell.avatarUrl = user.photoUrlSmall;
                if (user.firstName.length == 0)
                {
                    cell.titleTextFirst = user.lastName;
                    cell.titleTextSecond = nil;
                }
                else
                {
                    cell.titleTextFirst = user.firstName;
                    cell.titleTextSecond = user.lastName;
                }
                
                cell.subtitleText = nil;
                
                cell.conversationId = user.uid;
            }
            
            [cell resetView:false];
            return cell;
        }
        else if (conversation != nil)
        {
            static NSString *MessageCellIdentifier = @"MC";
            TGDialogListCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
            
            if (cell == nil)
            {
                if (_preparedCellQueue != nil && _preparedCellQueue.count != 0)
                {
                    cell = [_preparedCellQueue lastObject];
                    [_preparedCellQueue removeLastObject];
                }
                if (cell == nil)
                {
                    cell = [[TGDialogListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageCellIdentifier assetsSource:[_dialogListCompanion dialogListCellAssetsSource]];
                    cell.watcherHandle = _actionHandle;
                    cell.enableEditing = false;
                }
            }
            
            [self prepareCell:cell forConversation:conversation animated:false isSearch:true];
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark -

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)__unused cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        int listCount = _listModel.count;
        if (_canLoadMore && !_isLoading && listCount != 0 && (listCount < 10 || indexPath.row >= listCount - 10))
        {
            _isLoading = true;
            [_dialogListCompanion loadMoreItems];
        }
    }
    else
    {
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        if (indexPath.section == 0)
            return false;
        
        return indexPath.row < _listModel.count;
    }
    else
    {
        return false;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)__unused tableView editingStyleForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
        return indexPath.row < _listModel.count;
    return false;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _currentActionSheet.delegate = nil;
    _currentActionSheet = nil;
    
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (buttonIndex == actionSheet.destructiveButtonIndex)
        {
            if (_conversationIdToDelete != 0)
            {
                for (TGConversation *conversation in _listModel)
                {
                    if (conversation.conversationId == _conversationIdToDelete)
                    {
                        [_dialogListCompanion deleteItem:conversation animated:true];
                        break;
                    }
                }
            }
        }
        else
        {
            if (_conversationIdToDelete != 0)
            {
                for (TGConversation *conversation in _listModel)
                {
                    if (conversation.conversationId == _conversationIdToDelete)
                    {
                        [_dialogListCompanion clearItem:conversation animated:true];
                        break;
                    }
                }
            }
        }
    }
    _conversationIdToDelete = 0;
}

#pragma mark -

- (UITableView *)createTableViewForSearchMixin:(TGSearchDisplayMixin *)__unused searchMixin
{
    UITableView *tableView = [[UITableView alloc] init];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (tableView.tableFooterView == nil)
        tableView.tableFooterView = [[UIView alloc] init];
    
    return tableView;
}

- (UIView *)referenceViewForSearchResults
{
    return _tableView;
}

- (void)searchMixin:(TGSearchDisplayMixin *)__unused searchMixin hasChangedSearchQuery:(NSString *)searchQuery withScope:(int)scope
{
    [_dialogListCompanion beginSearch:searchQuery inMessages:scope == 1];
    
    if (searchQuery.length == 0)
        [_searchMixin setSearchResultsTableViewHidden:true];
}

- (void)searchMixinWillActivate:(bool)animated
{
    _tableView.scrollEnabled = false;
    
    [self setNavigationBarHidden:true animated:animated];
}

- (void)searchMixinWillDeactivate:(bool)animated
{
    _tableView.scrollEnabled = true;
    
    [self setNavigationBarHidden:false animated:animated];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _tableView)
    {
        _draggingStartOffset = scrollView.contentOffset.y;
    }
    
    if (_searchMixin.isActive && scrollView == _searchMixin.searchResultsTableView)
        [_searchBar resignFirstResponder];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)__unused velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == _tableView)
    {
        if (targetContentOffset != NULL)
        {
            if (targetContentOffset->y > -_tableView.contentInset.top - FLT_EPSILON && targetContentOffset->y < -_tableView.contentInset.top + 44.0f + FLT_EPSILON)
            {
                if (_draggingStartOffset < -_tableView.contentInset.top + 22.0f)
                {
                    if (targetContentOffset->y < -_tableView.contentInset.top + 44.0f * 0.2)
                        targetContentOffset->y = -_tableView.contentInset.top;
                    else
                        targetContentOffset->y = -_tableView.contentInset.top + 44.0f;
                }
                else
                {
                    if (targetContentOffset->y < -_tableView.contentInset.top + 44.0f * 0.8)
                        targetContentOffset->y = -_tableView.contentInset.top;
                    else
                        targetContentOffset->y = -_tableView.contentInset.top + 44.0f;
                }
            }
        }
    }
}

#pragma mark -

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)__unused controller
{
    [_searchBar setSelectedScopeButtonIndex:0];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)__unused controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [_dialogListCompanion beginSearch:searchString inMessages:_searchBar.selectedScopeButtonIndex == 1];
    
    return FALSE;
}

- (void)searchDisplayController:(UISearchDisplayController *)__unused controller willShowSearchResultsTableView:(UITableView *)__unused tableView
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (tableView.tableFooterView == nil)
        tableView.tableFooterView = [[UIView alloc] init];
    
    tableView.hidden = true;
}

- (void)searchDisplayController:(UISearchDisplayController *)__unused controller willHideSearchResultsTableView:(UITableView *)tableView
{
    tableView.hidden = false;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)__unused controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [_dialogListCompanion beginSearch:_searchBar.text inMessages:searchOption];
    
    return false;
}

- (void)actionStageActionRequested:(NSString *)action options:(NSDictionary *)options
{
    if ([action isEqualToString:@"conversationMenuOpened"])
    {
        int64_t conversationId = [[options objectForKey:@"conversationId"] longLongValue];
        for (NSIndexPath *indexPath in _tableView.indexPathsForVisibleRows)
        {
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            
            if ([cell isKindOfClass:[TGDialogListCell class]])
            {
                TGDialogListCell *dialogCell = (TGDialogListCell *)cell;
                if (dialogCell.conversationId != conversationId)
                {
                    [dialogCell dismissEditingControls:true];
                }
                
                [cell setSelected:false];
                [cell setHighlighted:false];
            }
        }
        
        if (_tableView.indexPathForSelectedRow != nil)
            [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:false];
    }
}

- (void)tableView:(UITableView *)__unused tableView commitEditingStyle:(UITableViewCellEditingStyle)__unused editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGConversation *conversation = nil;
    if (indexPath.row < _listModel.count)
        conversation = [_listModel objectAtIndex:indexPath.row];
    
    if (conversation != nil)
    {
        if (true || conversation.isChat)
        {
            _conversationIdToDelete = conversation.conversationId;
            
            _currentActionSheet.delegate = nil;
            
            _currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            [_currentActionSheet addButtonWithTitle:TGLocalized(@"DialogList.ClearHistoryConfirmation")];
            _currentActionSheet.destructiveButtonIndex = [_currentActionSheet addButtonWithTitle:(conversation.isBroadcast || !conversation.isChat) ? TGLocalized(@"Common.Delete") : TGLocalized(@"DialogList.DeleteConversationConfirmation")];
            _currentActionSheet.cancelButtonIndex = [_currentActionSheet addButtonWithTitle:TGLocalized(@"Common.Cancel")];
            
            [_currentActionSheet showInView:self.navigationController.view];
        }
        else
            [_dialogListCompanion deleteItem:conversation animated:true];
    }
}

- (void)localizationUpdated
{
    [_searchBar localizationUpdated];
    
    [self setLeftBarButtonItem:[self controllerLeftBarButtonItem]];
    
    [self setTitleText:TGLocalized(@"DialogList.Title")];
    
    _titleLabel.text = TGLocalized(@"DialogList.Title");
    [_titleLabel sizeToFit];
    [self _layoutTitleViews:self.interfaceOrientation];
    
    if (!_dialogListCompanion.forwardMode && !_dialogListCompanion.privacyMode)
        _searchBar.customScopeButtonTitles = @[TGLocalized(@"DialogList.Conversations"), TGLocalized(@"DialogList.Messages")];
    
    for (id cell in _tableView.visibleCells)
    {
        if ([cell isKindOfClass:[TGDialogListCell class]])
        {
            [(TGDialogListCell *)cell resetLocalization];
            ((TGDialogListCell *)cell).reuseTag = -1;
        }
        else if ([cell isKindOfClass:[TGDialogListBroadcastsMenuCell class]])
        {
            [(TGDialogListBroadcastsMenuCell *)cell resetLocalization];
        }
    }
    
    [self reloadData];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (tableView == _tableView && !tableView.editing)
    {
        [self selectCurrentConversation];
    }
}

- (void)selectCurrentConversation
{
    int index = -1;
    for (TGConversation *conversation in _listModel)
    {
        index++;
        if ([_dialogListCompanion isConversationOpened:conversation.conversationId])
        {
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1] animated:false scrollPosition:UITableViewScrollPositionNone];
            
            break;
        }
    }
}

@end

