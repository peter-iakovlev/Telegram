#import "TGDialogListController.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGDialogListCompanion.h"

#import <LegacyComponents/TGSearchDisplayMixin.h>

#import <LegacyComponents/TGListsTableView.h>

#import <LegacyComponents/SGraphObjectNode.h>

#import <LegacyComponents/TGRemoteImageView.h>

#import "TGDialogListItem.h"

#import "TGDialogListCell.h"
#import "TGDialogListSearchCell.h"
#import "TGFlatActionCell.h"

#import "TGActionTableView.h"

#import <LegacyComponents/TGSearchBar.h>

#import <LegacyComponents/TGObserverProxy.h>

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import <LegacyComponents/TGModernBarButton.h>

#import "TGDialogListBroadcastsMenuCell.h"

#import "TGGlobalMessageSearchSignals.h"
#import "TGRecentPeersSignals.h"
#import "TGDownloadMessagesSignal.h"

#import "TGLockIconView.h"

#import "TGDatabase.h"
#import "TGAppDelegate.h"

#import "TGDialogListTitleContainer.h"

#import <LegacyComponents/TGHashtagPanelCell.h>

#import <LegacyComponents/TGMenuView.h>

#import "TGInterfaceManager.h"

#import "TGModernConversationController.h"
#import "TGGenericModernConversationCompanion.h"
#import "TGFeedConversationCompanion.h"

#import "TGCustomActionSheet.h"
#import <LegacyComponents/TGProgressWindow.h>

#import "TGChannelManagementSignals.h"
#import "TGFeedManagementSignals.h"

#import <LegacyComponents/TGKeyCommandController.h>

#import "TGDialogListRecentPeers.h"
#import "TGDialogListRecentPeersCell.h"

#import "TGChatActionsController.h"
#import "TGPreviewMenu.h"
#import <LegacyComponents/TGItemPreviewController.h>
#import <LegacyComponents/TGItemMenuSheetPreviewView.h>
#import "TGPreviewConversationItemView.h"
#import <LegacyComponents/TGMenuSheetButtonItemView.h>
#import "TGModernConversationTitlePanel.h"

#import "TGCreateContactController.h"

#import "TGCustomAlertView.h"

#include <map>
#include <set>

#import "TGGroupManagementSignals.h"

#import "TGTelegraph.h"

#import "TGLocalizationSignals.h"
#import "TGSuggestedLocalizationController.h"
#import "TGLocalizationSelectionController.h"

#import <LegacyComponents/TGTooltipView.h>

#import "TGProxySetupController.h"
#import <MTProtoKit/MTProtoKit.h>
#import "TGTelegramNetworking.h"

#import "TGLegacyComponentsContext.h"

#import "TGCreateFeedController.h"

#import "TGProxyBarButton.h"

#import "TGProxySignals.h"

#import "TGPresentation.h"
#import "TGPreviewPresentationHelper.h"

static bool _debugDoNotJump = false;

static int64_t lastAppearedConversationId = 0;

#pragma mark -

@interface UITableViewCell (TG)

- (void)_beginSwiping;

@end

@interface TGDialogListController () <TGViewControllerNavigationBarAppearance, UITableViewDelegate, UITableViewDataSource, TGSearchDisplayMixinDelegate, TGCreateContactControllerDelegate, TGKeyCommandResponder>
{
    std::map<int64_t, NSString *> _usersTypingInConversation;
    
    int64_t _scrollingToConversationId;
    int64_t _scheduledScrollToConversationId;
    int64_t _scheduledHighlightAnimationConversationId;
    
    UIView *_headerBackgroundView;
    
    NSArray *_reusableSectionHeaders;
    
    SMetaDisposable *_searchDisposable;
    NSString *_searchResultsQuery;
    
    SMetaDisposable *_recentSearchResultsDisposable;
    
    SVariable *_atTopPromise;
    SPipe *_visibleConversationsPipe;
    
    bool _didSelectMessage;
    bool _didSelectGlobalResult;
    
    TGMenuContainerView *_menuContainerView;
    
    bool _checked3dTouch;
    
    TGItemPreviewHandle *_custom3dTouchHandle;
    bool _reloadWithAnimations;
    
    TGSuggestedLocalization *_suggestedLocalization;
    bool _displayedSuggestedLocalization;
    id<SDisposable> _suggestedLocalizationCodeDisposable;
    bool _isOnScreen;
    
    __weak TGTooltipContainerView *_recordTooltipContainerView;
    bool _displaySavedMessagesTooltip;
    bool _displayProxyIssuesTooltip;
    
    UIView *_titlePanelWrappingView;
    TGModernConversationTitlePanel *_currentTitlePanel;
    TGModernConversationTitlePanel *_primaryTitlePanel;
    
    UIButton *_dimView;
    UIView *_keyboardSnapshotView;
    
    UIBarButtonItem *_proxyItem;
    TGProxyBarButton *_proxyButton;
    
    SMetaDisposable *_proxyStateDisposable;
    bool _hasAnyProxy;
    bool _hasSelectedProxy;
    bool _alwaysShowProxy;
    TGDialogListState _state;
    
    bool _needsUpdate;
}

@property (nonatomic, strong) TGSearchBar *searchBar;
@property (nonatomic, strong) UIView *searchTopBackgroundView;
@property (nonatomic, strong) TGSearchDisplayMixin *searchMixin;
@property (nonatomic) bool searchControllerWasLoaded;

@property (nonatomic, strong) TGListsTableView *tableView;
@property (nonatomic) bool editingMode;
@property (nonatomic) CGFloat draggingStartOffset;

@property (nonatomic, strong) NSMutableArray *listModel;

@property (nonatomic, strong) NSArray *searchResultsSections;
@property (nonatomic, strong) NSArray *recentSearchResultsSections;

@property (nonatomic) bool isLoading;

@property (nonatomic, strong) TGDialogListTitleContainer *titleContainer;
@property (nonatomic, strong) UILabel *titleStatusLabel;
@property (nonatomic, strong) UILabel *titleStatusSubtitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TGLockIconView *titleLockIconView;

@property (nonatomic, strong) UIActivityIndicatorView *titleStatusIndicator;

@property (nonatomic, strong) UIView *emptyListContainer;

@property (nonatomic, strong) TGObserverProxy *significantTimeChangeProxy;
@property (nonatomic, strong) TGObserverProxy *didEnterBackgroundProxy;
@property (nonatomic, strong) TGObserverProxy *willEnterForegroundProxy;

@property (nonatomic, copy) void (^deleteConversation)(int64_t);
@property (nonatomic, copy) void (^toggleMuteConversation)(int64_t, bool);
@property (nonatomic, copy) void (^togglePinConversation)(int64_t, bool);
@property (nonatomic, copy) void (^toggleGroupConversation)(int64_t, bool);
@property (nonatomic, copy) void (^toggleReadConversation)(int64_t, bool);

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
        self.ignoreKeyboardWhenAdjustingScrollViewInsets = !TGIsPad();
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _atTopPromise = [[SVariable alloc] init];
        [_atTopPromise set:[SSignal single:@true]];
        
        _visibleConversationsPipe = [[SPipe alloc] init];
        
        __weak TGDialogListController *weakSelf = self;
        
        _listModel = [[NSMutableArray alloc] init];
        
        _reusableSectionHeaders = [[NSArray alloc] initWithObjects:[[NSMutableArray alloc] init], [[NSMutableArray alloc] init], nil];
        
        _dialogListCompanion = companion;
        _dialogListCompanion.dialogListController = self;
        
        _significantTimeChangeProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(significantTimeChange:) name:UIApplicationSignificantTimeChangeNotification];
        _didEnterBackgroundProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification];
        _willEnterForegroundProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification];
        
        _doNotHideSearchAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        
        _proxyButton = [[TGProxyBarButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
        _proxyButton.portraitAdjustment = CGPointMake(22, 12);
        _proxyButton.landscapeAdjustment = CGPointMake(22, 5);
        [_proxyButton addTarget:self action:@selector(openProxySettings) forControlEvents:UIControlEventTouchUpInside];
        _proxyItem = [[UIBarButtonItem alloc] initWithCustomView:_proxyButton];
        
        SSignal *currentSignal = [[TGProxySignals currentSignal] map:^id(id value) {
            if (value != nil)
                return value;
            else
                return [NSNull null];
        }];
        
        SSignal *blockedModeSignal = [[TGDatabaseInstance() customPropertySignal:@"blockedMode"] map:^NSNumber *(NSData *data)
        {
            int32_t value = 0;
            [data getBytes:&value];
            
            return @(value > 0);
        }];
        
        _proxyStateDisposable = [[SMetaDisposable alloc] init];
        [_proxyStateDisposable setDisposable:[[[SSignal combineSignals:@[[TGProxySignals listSignal], currentSignal, blockedModeSignal] withInitialStates:@[ @[], [NSNull null], @false ]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next)
        {
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                bool hasAnyProxy = ((NSArray *)next[0]).count > 0;
                bool hasSelectedProxy = [(NSArray *)next[1] isKindOfClass:[TGProxyItem class]];
                bool alwaysShowProxy = [next[2] boolValue];
                
                strongSelf->_hasAnyProxy = hasAnyProxy;
                strongSelf->_hasSelectedProxy = hasSelectedProxy;
                strongSelf->_alwaysShowProxy = alwaysShowProxy;
                [strongSelf updateProxyButton];
            }
        }]];
        
        self.deleteConversation = ^(int64_t peerId) {
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSIndexPath *indexPath = [strongSelf indexPathForConversationId:peerId];
                if (indexPath != nil) {
                    [(TGDialogListCell *)[strongSelf->_tableView cellForRowAtIndexPath:indexPath] setEditingConrolsExpanded:false animated:true];
                    [strongSelf tableView:strongSelf->_tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
                }
            }
        };
        self.toggleMuteConversation = ^(int64_t peerId, bool mute) {
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSIndexPath *indexPath = [strongSelf indexPathForConversationId:peerId];
                if (indexPath != nil) {
                    TGConversation *conversation = strongSelf->_listModel[indexPath.row];
                    NSDictionary *dialogListData = conversation.dialogListData;
                    [(TGDialogListCell *)[strongSelf->_tableView cellForRowAtIndexPath:indexPath] setEditingConrolsExpanded:false animated:true];
                    if ([[dialogListData objectForKey:@"mute"] boolValue] != mute) {
                        static int actionId = 0;
                        int muteUntil = !mute ? 0 : INT32_MAX;
                        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(dialogListMute%d)", conversation.conversationId, actionId++] options:@{@"peerId": @(conversation.conversationId), @"accessHash": @(conversation.accessHash), @"muteUntil": @(muteUntil)} watcher:TGTelegraphInstance];
                    }
                }
            }
        };
        self.togglePinConversation = ^(int64_t peerId, bool pin) {
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSIndexPath *indexPath = [strongSelf indexPathForConversationId:peerId];
                if (indexPath != nil) {
                    TGConversation *conversation = strongSelf->_listModel[indexPath.row];
                    if (conversation.pinnedToTop != pin) {
                        if (pin) {
                            int32_t maxPinnedChats = 5;
                            NSData *data = [TGDatabaseInstance() customProperty:@"maxPinnedChats"];
                            if (data.length == 4) {
                                [data getBytes:&maxPinnedChats length:4];
                                maxPinnedChats = MAX(maxPinnedChats, 5);
                            }
                            NSInteger pinnedCount = 0;
                            NSInteger secretPinnedCount = 0;
                            for (TGConversation *conversation in strongSelf->_listModel) {
                                if (conversation.pinnedToTop) {
                                    if (TGPeerIdIsSecretChat(conversation.conversationId)) {
                                        secretPinnedCount++;
                                    } else {
                                        pinnedCount++;
                                    }
                                }
                            }
                            
                            [(TGDialogListCell *)[strongSelf->_tableView cellForRowAtIndexPath:indexPath] setEditingConrolsExpanded:false animated:true];
                            if ((TGPeerIdIsSecretChat(peerId) && secretPinnedCount >= maxPinnedChats) || (!TGPeerIdIsSecretChat(peerId) && pinnedCount >= maxPinnedChats)) {
                                [TGCustomAlertView presentAlertWithTitle:nil message:[NSString stringWithFormat: TGLocalized(@"DialogList.PinLimitError"), [NSString stringWithFormat:@"%d", maxPinnedChats]] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                            } else {
                                strongSelf->_reloadWithAnimations = true;
                                [[[TGGroupManagementSignals updatePinnedState:conversation.conversationId pinned:true] onDispose:^{
                                }] startWithNext:nil];
                                if (strongSelf->_tableView.contentOffset.y > FLT_EPSILON) {
                                    [strongSelf scrollToTopRequested];
                                }
                            }
                        } else {
                            strongSelf->_reloadWithAnimations = true;
                            [(TGDialogListCell *)[strongSelf->_tableView cellForRowAtIndexPath:indexPath] setEditingConrolsExpanded:false animated:true];
                            [[[TGGroupManagementSignals updatePinnedState:conversation.conversationId pinned:false] onDispose:^{
                            }] startWithNext:nil];
                        }
                    }
                }
            }
        };
        self.toggleGroupConversation = ^(int64_t peerId, bool group)
        {
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSIndexPath *indexPath = [strongSelf indexPathForConversationId:peerId];
                if (indexPath != nil) {
                    TGConversation *conversation = strongSelf->_listModel[indexPath.row];
                    bool grouped = conversation.feedId.intValue != 0;
                    if (grouped != group) {
                        if ([TGDatabaseInstance() loadFeed:1] != nil)
                        {
                            [ActionStageInstance() dispatchResource:@"/tg/conversationsGrouped/(animated)" resource:[[SGraphObjectNode alloc] initWithObject:@[conversation]]];
                            
                            if (group) {
                                [[TGFeedManagementSignals groupChannelWithPeerId:conversation.conversationId feedId:1] startWithNext:nil];
                            } else {
                                [[TGFeedManagementSignals ungroupChannelWithPeerId:conversation.conversationId] startWithNext:nil];
                            }
                        }
                        else
                        {
                            TGCreateFeedController *controller = [[TGCreateFeedController alloc] initWithConversation:conversation];
                            [strongSelf.navigationController pushViewController:controller animated:true];
                        }
                    }
                    [(TGDialogListCell *)[strongSelf->_tableView cellForRowAtIndexPath:indexPath] setEditingConrolsExpanded:false animated:true];
                }
            }
        };
        self.toggleReadConversation = ^(int64_t peerId, bool read)
        {
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSIndexPath *indexPath = [strongSelf indexPathForConversationId:peerId];
                if (indexPath != nil) {
                    TGConversation *conversation = strongSelf->_listModel[indexPath.row];
                    bool isRead = !conversation.unreadMark && conversation.unreadCount == 0 && conversation.serviceUnreadCount == 0 && conversation.unreadMentionCount == 0;
                    if (read != isRead)
                    {
                        if (read)
                        {
                            [TGDatabaseInstance() transactionReadHistoryForPeerIds:@[[[TGReadPeerMessagesRequest alloc] initWithPeerId:peerId maxMessageIndex:nil date:0 length:0 unread:false]]];
                            
                            if (conversation.unreadMentionCount > 0)
                                [[TGDownloadMessagesSignal clearUnseenMentions:conversation.conversationId] startWithNext:nil];
                        }
                        else
                        {
                            [TGDatabaseInstance() transactionReadHistoryForPeerIds:@[[[TGReadPeerMessagesRequest alloc] initWithPeerId:peerId maxMessageIndex:nil date:0 length:0 unread:true]]];
                        }
                    }
                }
            }
        };
        
        _suggestedLocalizationCodeDisposable = [[[[SSignal complete] delay:2.0 onQueue:[SQueue mainQueue]] then:[[[TGDatabaseInstance() suggestedLocalizationCode] mapToSignal:^SSignal *(NSString *code) {
            if (code.length == 0 || [code isEqualToString:@"en"] || [code isEqualToString:currentNativeLocalization().code]) {
                return [SSignal single:nil];
            } else {
                NSData *data = [TGDatabaseInstance() customProperty:@"checkedLocalization"];
#ifdef DEBUG
                data = nil;
#endif
                if (data.length != 0) {
                    return [SSignal single:nil];
                } else {
                    return [TGLocalizationSignals suggestedLocalizationData:code];
                }
            }
        }] deliverOn:[SQueue mainQueue]]] startWithNext:^(TGSuggestedLocalization *result) {
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil && [result isKindOfClass:[TGSuggestedLocalization class]]) {
                strongSelf->_suggestedLocalization = result;
                if (result != nil && strongSelf->_isOnScreen && !strongSelf->_displayedSuggestedLocalization) {
                    strongSelf->_displayedSuggestedLocalization = true;
                    [strongSelf displaySuggestedLocalization];
                }
            }
        }];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    _dialogListCompanion.dialogListController = nil;
    
    [self doUnloadView];
    
    [_proxyStateDisposable dispose];
    [_searchDisposable dispose];
    [_recentSearchResultsDisposable dispose];
    [_suggestedLocalizationCodeDisposable dispose];
}

- (SSignal *)atTopSignal {
    return _atTopPromise.signal;
}

- (SSignal *)visibleUnreadDialogsCountSignal {
    SSignal *update = [SSignal defer:^SSignal *
    {
        int32_t count = 0;
        for (TGDialogListCell *cell in _tableView.visibleCells)
        {
            if (cell.unreadMark || cell.unreadCount > 0 || cell.serviceUnreadCount > 0)
                count++;
        }
        return [SSignal single:@(count)];
    }];
    
    return [[self atTopSignal] mapToSignal:^SSignal *(NSNumber *atTop)
    {
        if (atTop) {
            return [update then:[_visibleConversationsPipe.signalProducer() mapToSignal:^SSignal *(__unused id value)
            {
                return update;
            }]];
        }
        else
        {
            return [SSignal single:@0];
        }
    }];
}

- (int64_t)currentVisibleUnreadConversation {
    if (_scrollingToConversationId != 0)
        return _scrollingToConversationId;
    
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:[self.view convertPoint:CGPointMake(0.0f, CGRectGetMidY(_tableView.frame)) toView:_tableView]];
    TGConversation *conversation = nil;
    if (indexPath.row < (NSInteger)_listModel.count)
        conversation = [_listModel objectAtIndex:indexPath.row];
    return conversation.conversationId;
}

- (void)scrollToConversationWithId:(int64_t)conversationId {
    NSIndexPath *indexPath = [self indexPathForConversationId:conversationId];
    if (indexPath != nil) {
        _scheduledScrollToConversationId = 0;
        _scheduledHighlightAnimationConversationId = 0;
        
        TGDialogListCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[TGDialogListCell class]])
            [cell animateHighlight];
        else
            _scheduledHighlightAnimationConversationId = conversationId;
        
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:true];
        _scrollingToConversationId = conversationId;
    } else if (_scheduledScrollToConversationId == 0) {
        if (_canLoadMore) {
            _scheduledScrollToConversationId = conversationId;
            [_dialogListCompanion loadMoreItems:1000];
        }
    }
}

- (NSIndexPath *)indexPathForConversationId:(int64_t)conversationId {
    NSUInteger index = 0;
    for (TGConversation *conversation in _listModel) {
        if (conversation.conversationId == conversationId) {
            return [NSIndexPath indexPathForRow:index inSection:1];
        }
        index++;
    }
    return nil;
}

- (void)_loadStatusViews
{
    if (_titleStatusLabel == nil)
    {
        _titleStatusLabel = [[UILabel alloc] init];
        _titleStatusLabel.clipsToBounds = false;
        _titleStatusLabel.backgroundColor = [UIColor clearColor];
        _titleStatusLabel.textColor = _presentation.pallete.navigationTitleColor;
        _titleStatusLabel.font = TGBoldSystemFontOfSize(16.0f);
        [_titleContainer addSubview:_titleStatusLabel];
        
        _titleStatusSubtitleLabel = [[UILabel alloc] init];
        _titleStatusSubtitleLabel.clipsToBounds = false;
        _titleStatusSubtitleLabel.backgroundColor = [UIColor clearColor];
        _titleStatusSubtitleLabel.textColor = _presentation.pallete.navigationSubtitleColor;
        _titleStatusSubtitleLabel.font = TGSystemFontOfSize(12.0f);
        _titleStatusSubtitleLabel.hidden = true;
        [_titleContainer addSubview:_titleStatusSubtitleLabel];
        
        _titleStatusIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _titleStatusIndicator.color = _presentation.pallete.navigationSpinnerColor;
        [_titleContainer addSubview:_titleStatusIndicator];
    }
}

- (UIBarButtonItem *)editingControl
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
}

- (UIBarButtonItem *)controllerLeftBarButtonItem
{
    if ([_dialogListCompanion editingControlOnRightSide])
        return nil;
    
    return [self editingControl];
}

- (void)scrollToTopRequested
{
    [self scrollToTop];
    //if (!_searchMixin.isActive)
    //    [self.dialogListCompanion scrollToNextUnreadChat];
}

- (void)scrollToTop
{
    [_tableView scrollToTop];
}

- (void)titleStateUpdated:(NSString *)text state:(TGDialogListState)state
{
    _state = state;
    [self updateProxyButton];
    
    if (text == nil)
    {
        _titleStatusLabel.hidden = true;
        _titleStatusIndicator.hidden = true;
        _titleStatusSubtitleLabel.hidden = true;
        _titleLabel.hidden = false;
        _titleLockIconView.hidden = false;
        
        [_titleStatusIndicator stopAnimating];
    }
    else
    {
        [self _loadStatusViews];
        
        _titleStatusLabel.hidden = false;
        _titleStatusIndicator.hidden = false;
        _titleLabel.hidden = true;
        _titleLockIconView.hidden = true;
                
        _titleStatusLabel.text = text;
        [_titleStatusLabel sizeToFit];
        
        [self _layoutTitleViews:self.interfaceOrientation];
        
        if (!_titleStatusIndicator.isAnimating)
            [_titleStatusIndicator startAnimating];
    }
    
    if (state == TGDialogListStateHasProxyIssues) {
        if ([self isVisible] && !_searchMixin.isActive) {
            [self displayProxyTooltip];
        } else {
            _displayProxyIssuesTooltip = true;
        }
    } else {
        _displayProxyIssuesTooltip = false;
    }
}

- (bool)isVisible
{
    return self.navigationController.topViewController == TGAppDelegateInstance.rootController.mainTabsController && TGAppDelegateInstance.rootController.mainTabsController.selectedIndex == 2;
}

- (void)updateDatabasePassword
{
    _titleLockIconView.alpha = [TGDatabaseInstance() isPasswordSet:NULL] ? 1.0f : 0.0f;
    if (_titleLockIconView.isLocked != [TGAppDelegateInstance isManuallyLocked])
        [_titleLockIconView setIsLocked:[TGAppDelegateInstance isManuallyLocked] animated:false];
    [self _layoutTitleViews:self.interfaceOrientation];
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

- (NSArray *)controllerRightBarButtonItems
{
    if ([_dialogListCompanion editingControlOnRightSide])
        return @[[self editingControl]];
    
    if (_editingMode)
        return nil;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem *compose = nil;
    if (iosMajorVersion() < 7)
    {
        TGModernBarButton *composeButton = [[TGModernBarButton alloc] initWithImage:TGTintedImage([UIImage imageNamed:@"ModernNavigationComposeButtonIcon.png"], self.presentation.pallete.navigationButtonColor)];
        composeButton.portraitAdjustment = CGPointMake(-7, -5);
        composeButton.landscapeAdjustment = CGPointMake(-7, -4);
        [composeButton addTarget:self action:@selector(composeMessageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        compose = [[UIBarButtonItem alloc] initWithCustomView:composeButton];
    }
    else
    {
        compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeMessageButtonPressed:)];
    }
    
    [items addObject:compose];
    [items addObject:_proxyItem];
    
    return items;
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
    if (_titleLockIconView.alpha > FLT_EPSILON)
        titleLabelFrame.origin.x -= 4.0f;
    _titleLockIconView.frame = CGRectMake(CGRectGetMaxX(titleLabelFrame) + 6.0f, titleLabelFrame.origin.y + 4.0f, _titleLockIconView.frame.size.width, _titleLockIconView.frame.size.height);
    _titleLabel.frame = titleLabelFrame;
    
    if (_titleStatusLabel != nil)
    {
        CGRect titleStatusLabelFrame = _titleStatusLabel.frame;
        titleStatusLabelFrame.origin = CGPointMake(CGFloor((_titleContainer.frame.size.width - titleStatusLabelFrame.size.width) / 2.0f) + 16.0f, CGFloor((_titleContainer.frame.size.height - titleStatusLabelFrame.size.height) / 2.0f) + (UIInterfaceOrientationIsPortrait(orientation) ? portraitOffset : landscapeOffset));
        if (!_titleStatusSubtitleLabel.hidden) {
            titleStatusLabelFrame.origin.y -= 7.0f;
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                titleStatusLabelFrame.origin.y -= 2.0f;
            }
        }
        _titleStatusLabel.frame = titleStatusLabelFrame;
        
        CGRect titleStatusSubtitleLabelFrame = _titleStatusSubtitleLabel.frame;
        titleStatusSubtitleLabelFrame.origin = CGPointMake(CGFloor((_titleContainer.frame.size.width - titleStatusSubtitleLabelFrame.size.width) / 2.0f), CGRectGetMaxY(titleStatusLabelFrame) - 1.0f);
        _titleStatusSubtitleLabel.frame = titleStatusSubtitleLabelFrame;

        CGRect titleIndicatorFrame = _titleStatusIndicator.frame;
        titleIndicatorFrame.origin = CGPointMake(titleStatusLabelFrame.origin.x - titleIndicatorFrame.size.width - 4.0f, titleStatusLabelFrame.origin.y  + indicatorOffset);
        _titleStatusIndicator.frame = titleIndicatorFrame;
    }
    
    if (_titlePanelWrappingView != nil)
    {
        CGRect titleWrapperFrame = CGRectMake(0.0f, self.controllerInset.top - self.explicitTableInset.top, self.view.frame.size.width, _titlePanelWrappingView.frame.size.height);
        CGRect titlePanelFrame = CGRectMake(0.0f, 0.0f, titleWrapperFrame.size.width, _primaryTitlePanel.frame.size.height);
        _titlePanelWrappingView.frame = titleWrapperFrame;
        _primaryTitlePanel.frame = titlePanelFrame;
    }
}

- (void)loadView
{
    [super loadView];
    
    self.view.accessibilityElementsHidden = true;
    
    [self setTitleText:TGLocalized(@"DialogList.Title")];
    
    _titleContainer = [[TGDialogListTitleContainer alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2.0f, 2.0f)];
    [self setTitleView:_titleContainer];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = self.presentation.pallete.navigationTitleColor;
    _titleLabel.font = TGBoldSystemFontOfSize(17.0f);
    _titleLabel.text = TGLocalized(@"DialogList.Title");
    [_titleLabel sizeToFit];
    [_titleContainer addSubview:_titleLabel];
    
    _titleLockIconView = [[TGLockIconView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2.0f, 2.0f)];
    _titleLockIconView.presentation = self.presentation;
    _titleLockIconView.alpha = [TGDatabaseInstance() isPasswordSet:NULL] ? 1.0f : 0.0f;
    [_titleLockIconView setIsLocked:[TGAppDelegateInstance isManuallyLocked] animated:false];
    __weak TGDialogListController *weakSelf = self;
    _titleContainer.tappped = ^
    {
        __strong TGDialogListController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (strongSelf->_titleStatusSubtitleLabel != nil && !strongSelf->_titleStatusSubtitleLabel.hidden) {
                [strongSelf openProxySettings];
            } else if (strongSelf->_titleLockIconView.alpha > FLT_EPSILON) {
                [TGAppDelegateInstance setIsManuallyLocked:![TGAppDelegateInstance isManuallyLocked]];
                [strongSelf->_titleLockIconView setIsLocked:[TGAppDelegateInstance isManuallyLocked] animated:true];
            }
        }
    };
    [_titleContainer addSubview:_titleLockIconView];
    
    [self _layoutTitleViews:self.interfaceOrientation];
    
    [self updateBarButtonItemsAnimated:false];
    
    self.view.backgroundColor = _presentation.pallete.backgroundColor;
    
    _headerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.controllerInset.top)];
    _headerBackgroundView.backgroundColor = _presentation.pallete.backgroundColor;
    [self.view addSubview:_headerBackgroundView];
    
    CGRect tableFrame = self.view.bounds;
    _tableView = [[TGListsTableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    if (iosMajorVersion() >= 11)
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.opaque = true;
    _tableView.backgroundColor = _presentation.pallete.backgroundColor;
    ((TGListsTableView *)_tableView).onHitTest = ^(CGPoint point) {
        __strong TGDialogListController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            for (NSIndexPath *indexPath in [strongSelf->_tableView indexPathsForVisibleRows]) {
                TGDialogListCell *cell = (TGDialogListCell *)[strongSelf->_tableView cellForRowAtIndexPath:indexPath];
                if ([cell isKindOfClass:[TGDialogListCell class]]) {
                    if ([cell isEditingControlsExpanded]) {
                        CGRect rect = [cell convertRect:cell.bounds toView:strongSelf->_tableView];
                        if (!CGRectContainsPoint(rect, point) && ![cell isEditingControlsTracking]) {
                            [cell setEditingConrolsExpanded:false animated:true];
                        }
                    }
                }
            }
        }
    };
    
    //[self setExplicitTableInset:UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f)];

    [(TGListsTableView *)_tableView adjustBehaviour];
    
    _tableView.showsVerticalScrollIndicator = true;
    
    if (!_dialogListCompanion.feedChannels)
    {
        _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleLightPlain];
        _searchBar.pallete = self.presentation.searchBarPallete;
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchBar.safeAreaInset = [self controllerSafeAreaInset];
        
        _searchTopBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320.0f)];
        _searchTopBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_tableView insertSubview:_searchTopBackgroundView atIndex:0];
        
        _searchMixin = [[TGSearchDisplayMixin alloc] init];
        _searchMixin.searchBar = _searchBar;
        _searchMixin.delegate = self;
        
        _tableView.tableHeaderView = _searchBar;
        
        _searchBar.placeholder = TGLocalized(@"DialogList.SearchLabel");
    }
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (iosMajorVersion() >= 7) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = _presentation.pallete.separatorColor;
        _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 80.0f, 0.0f, 0.0f);
    }
    
    _tableView.alwaysBounceVertical = true;
    _tableView.bounces = true;
    
    _tableView.tableFooterView = [[UIView alloc] init];
    
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
    
    [self updateProxyButton];
    
    [self check3DTouch];
    
    if ([_dialogListCompanion openedConversationId] == 0 || !TGIsPad())
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
                    
                    if (![conversation isKindOfClass:[TGConversation class]])
                        continue;
                    
                    if (conversation.conversationId == conversationId && conversationId != 0)
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
    
    [self _performSizeChangesWithDuration:0.0f size:_tableView.frame.size];
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
            [(TGDialogListCell *)cell restartAnimations:false];
    }
    
    _didSelectMessage = false;
    _didSelectGlobalResult = false;
    
    bool displayingTooltip = false;
    if (_titleLockIconView.alpha > FLT_EPSILON && !_dialogListCompanion.forwardMode && !_dialogListCompanion.privacyMode)
    {
        NSString *key = @"Passcode_didShowChatListTooltip";
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@true forKey:key];
            
            if (_menuContainerView == nil)
            {
                _menuContainerView = [[TGMenuContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
                _menuContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.navigationController.view addSubview:_menuContainerView];
                
                NSMutableArray *actions = [[NSMutableArray alloc] init];
                [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"DialogList.PasscodeLockHelp"), @"title", nil]];
                
                [_menuContainerView.menuView setButtonsAndActions:actions watcherHandle:nil];
                [_menuContainerView.menuView sizeToFit];
                _menuContainerView.menuView.userInteractionEnabled = false;
                CGRect titleLockIconViewFrame = [_titleLockIconView convertRect:_titleLockIconView.bounds toView:_menuContainerView];
                titleLockIconViewFrame.origin.y += 6.0f;
                titleLockIconViewFrame.origin.x += 4.0f;
                titleLockIconViewFrame.size.height += titleLockIconViewFrame.origin.y;
                titleLockIconViewFrame.origin.y = 0;
                [_menuContainerView showMenuFromRect:titleLockIconViewFrame animated:false];
                displayingTooltip = true;
            }
        }
    }
    
    if (!displayingTooltip)
    {
        if (_displaySavedMessagesTooltip)
        {
            _displaySavedMessagesTooltip = false;
            [self displaySettingsTooltip:TGLocalized(@"DialogList.SavedMessagesTooltip")];
            [[NSUserDefaults standardUserDefaults] setObject:@true forKey:@"TG_displayedSavedMessagesTooltip_v0"];
        } else if (_displayProxyIssuesTooltip) {
            _displayProxyIssuesTooltip = false;
            [self displayProxyTooltip];
        }
    }
    
    [super viewDidAppear:animated];
    
    _isOnScreen = true;
    if (_suggestedLocalization != nil && !_displayedSuggestedLocalization) {
        _displayedSuggestedLocalization = true;
        [self displaySuggestedLocalization];
    }
}

- (void)requestSavedMessagesTooltip
{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"TG_displayedSavedMessagesTooltip_v0"] boolValue])
        _displaySavedMessagesTooltip = true;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (iosMajorVersion() >= 7)
        [_searchMixin resignResponderIfAny];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _isOnScreen = false;
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
        
        if (_searchMixin.isActive && !_didSelectMessage && !_didSelectGlobalResult)
            [_searchMixin setIsActive:false animated:false];
    }
    
    if (_recordTooltipContainerView != nil) {
        [_recordTooltipContainerView removeFromSuperview];
        _recordTooltipContainerView = nil;
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
    
    _searchBar.safeAreaInset = self.controllerSafeAreaInset;
    [self updateSafeAreaInset];
    
    if (_searchMixin.isActive)
    {
        TGDialogListRecentPeersCell *cell = [_searchMixin.searchResultsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if ([cell isKindOfClass:[TGDialogListRecentPeersCell class]])
            cell.safeAreaInset = self.controllerSafeAreaInset;
    }
    
    [super controllerInsetUpdated:previousInset];
    
    [self _performSizeChangesWithDuration:0.0 size:_tableView.frame.size];
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
        _emptyListContainer.frame = CGRectMake(CGFloor((self.view.frame.size.width - 250) / 2), CGFloor((self.view.frame.size.height - _emptyListContainer.frame.size.height) / 2), _emptyListContainer.frame.size.width, _emptyListContainer.frame.size.height);
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

- (void)reloadData:(bool)animateFrameTransitions
{
    NSMutableDictionary *temporaryImageCache = [[NSMutableDictionary alloc] init];
    int64_t peerIdWithActiveEditingControls = 0;
    NSMutableDictionary<NSNumber *, NSValue *> *previousFrames = nil;
    if (animateFrameTransitions) {
        previousFrames = [[NSMutableDictionary alloc] init];
    }
    for (UITableViewCell *cell in _tableView.visibleCells)
    {
        if ([cell isKindOfClass:[TGDialogListCell class]])
        {
            TGDialogListCell *dialogCell = (TGDialogListCell *)cell;
            
            previousFrames[@(dialogCell.conversationId)] = [NSValue valueWithCGRect:dialogCell.frame];
            if ([dialogCell isEditingControlsExpanded]) {
                peerIdWithActiveEditingControls = dialogCell.conversationId;
            }
            [((TGDialogListCell *)cell) collectCachedPhotos:temporaryImageCache];
        }
    }
    [[TGRemoteImageView sharedCache] addTemporaryCachedImagesSource:temporaryImageCache autoremove:true];
    [_tableView reloadData];
    [self updateSearchBarBackground];
    if (peerIdWithActiveEditingControls != 0 || animateFrameTransitions) {
        for (NSIndexPath *indexPath in _tableView.indexPathsForVisibleRows)
        {
            TGDialogListCell *dialogCell = (TGDialogListCell *)[_tableView cellForRowAtIndexPath:indexPath];
            if ([dialogCell isKindOfClass:[TGDialogListCell class]])
            {
                if (peerIdWithActiveEditingControls != 0 && dialogCell.conversationId == peerIdWithActiveEditingControls) {
                    [dialogCell setEditingConrolsExpanded:true animated:false];
                }
                if (animateFrameTransitions) {
                    NSValue *nFrame = previousFrames[@(dialogCell.conversationId)];
                    if (nFrame != nil) {
                        CGFloat offset = dialogCell.frame.origin.y - [nFrame CGRectValue].origin.y;
                        if (ABS(offset) > FLT_EPSILON) {
                            if (iosMajorVersion() >= 9) {
                                CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"transform.translation.y"];
                                springAnimation.mass = 3.0f;
                                springAnimation.stiffness = 1000.0f;
                                springAnimation.damping = 500.0f;
                                springAnimation.initialVelocity = 0.0f;
                                springAnimation.duration = 0.5;
                                springAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                                springAnimation.removedOnCompletion = true;
                                springAnimation.additive = true;
                                [springAnimation setFromValue:@(-offset)];
                                [springAnimation setToValue:@(0.0f)];
                                springAnimation.speed = 2.0f;
                                [dialogCell.layer addAnimation:springAnimation forKey:@"animateTransformAdditive"];
                            } else {
                                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
                                [animation setFromValue:@(-offset)];
                                [animation setToValue:@(0.0f)];
                                [animation setDuration:0.2];
                                [animation setRemovedOnCompletion:true];
                                [animation setAdditive:true];
                                [dialogCell.layer addAnimation:animation forKey:@"animateTransformAdditive"];
                            }
                        }
                    }
                }
            }
        }
    }
    
    _visibleConversationsPipe.sink(@true);
}

- (void)resetState
{
    [self setTableHidden:true];
    
    _hasSelectedProxy = false;
    
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
        if (selectedIndexPath.row < (NSInteger)_listModel.count)
        {
            TGConversation *conversation = [_listModel objectAtIndex:selectedIndexPath.row];
            if ([conversation isKindOfClass:[TGConversation class]])
                selectedConversation = conversation.conversationId;
        }
    }
    
    [_listModel removeAllObjects];
    [_listModel addObjectsFromArray:items];
    
    [self reloadData:_reloadWithAnimations];
    _reloadWithAnimations = false;
    
    if (selectedConversation != INT64_MAX && selectedConversation != 0)
    {
        int index = -1;
        for (TGConversation *conversation in _listModel)
        {
            index++;
            
            if (![conversation isKindOfClass:[TGConversation class]])
                continue;
            
            int64_t conversationId = conversation.conversationId;
            if (conversationId == selectedConversation)
            {
                [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1] animated:false scrollPosition:UITableViewScrollPositionNone];
                
                break;
            }
        }
    }
    
    _visibleConversationsPipe.sink(@true);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        TGLog(@"===== Dialog list reloaded");
    });
    
    [self updateEmptyListContainer];
    
    if (_scheduledScrollToConversationId != 0)
    {
        if (!_searchMixin.isActive)
            [self scrollToConversationWithId:_scheduledScrollToConversationId];
        else
            _scheduledScrollToConversationId = 0;
    }
}

- (void)updateEmptyListContainer
{
    if (_listModel.count == 0 && _emptyListContainer == nil)
    {
        _emptyListContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 0)];
        [self.view insertSubview:_emptyListContainer aboveSubview:_tableView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = UIColorRGB(0x999999);
        titleLabel.font = TGSystemFontOfSize(20);
        titleLabel.text = TGLocalized(@"DialogList.NoMessagesTitle");
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectOffset(titleLabel.frame, CGFloor((_emptyListContainer.frame.size.width - titleLabel.frame.size.width) / 2), 0.0f);
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
        textLabel.frame = CGRectMake(CGFloor((_emptyListContainer.frame.size.width - textLabelSize.width) / 2), titleLabel.frame.origin.y + titleLabel.frame.size.height + 14, textLabelSize.width, textLabelSize.height);
        [_emptyListContainer addSubview:textLabel];
        
        CGFloat containerHeight = textLabel.frame.origin.y + textLabel.frame.size.height;
        
        _emptyListContainer.frame = CGRectMake(CGFloor((self.view.frame.size.width - 250) / 2), CGFloor((self.view.frame.size.height - containerHeight) / 2), _emptyListContainer.frame.size.width, containerHeight);
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

- (void)setTableHidden:(bool)__unused tableHidden
{
    //_tableView.hidden = tableHidden;
    self.view.backgroundColor = _presentation.pallete.backgroundColor; //[_dialogListCompanion.dialogListCellAssetsSource dialogListBackgroundColor];
}

- (void)updateConversations:(NSDictionary *)dict {
    for (NSUInteger i = 0; i < _listModel.count; i++) {
        TGConversation *conv = ((TGConversation *)_listModel[i]);
        TGConversation *conversation = dict[@(conv.conversationId)];
        if (conversation != nil) {
            [_listModel replaceObjectAtIndex:i withObject:conversation];
        }
    }
    
    for (TGDialogListCell *cell in _tableView.visibleCells) {
        if ([cell isKindOfClass:[TGDialogListCell class]]) {
            id<TGDialogListItem> conversation = dict[@(cell.conversationId)];
            if ([conversation isKindOfClass:[TGConversation class]]) {
                [self prepareCell:cell forConversation:(TGConversation *)conversation animated:true isSearch:false];
            } else if ([conversation isKindOfClass:[TGFeed class]]) {
                [self prepareCell:cell forFeed:(TGFeed *)conversation animated:true];
            }
        }
    }
    
    _visibleConversationsPipe.sink(@true);
}

- (void)dialogListItemsChanged:(NSArray *)__unused insertedIndices insertedItems:(NSArray *)__unused insertedItems updatedIndices:(NSArray *)__unused updatedIndices updatedItems:(NSArray *)__unused updatedItems removedIndices:(NSArray *)__unused removedIndices
{
    int countBefore = (int)_listModel.count;
    
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
            id<TGDialogListItem> item = [_listModel objectAtIndex:[nUpdatedIndex intValue]];
            if ([item isKindOfClass:[TGConversation class]])
                [self prepareCell:cell forConversation:(TGConversation *)item animated:true isSearch:false];
            else if ([item isKindOfClass:[TGFeed class]])
                [self prepareCell:cell forFeed:(TGFeed *)item animated:true];
        }
    }
    
    _visibleConversationsPipe.sink(@true);
    
    if ((countBefore == 0) != (_listModel.count == 0))
    {
        [self updateEmptyListContainer];
        
        if (_listModel.count == 0)
            [self setupEditingMode:false setupTable:true];
    }
    
    [self updateSearchBarBackground];
}

- (void)updateSearchBarBackground {
    bool topIsPinned = false;
    if (_listModel.count != 0) {
        topIsPinned = ((TGConversation *)_listModel[0]).pinnedToTop || ((TGConversation *)_listModel[0]).isAd || (_dialogListCompanion.forwardMode && ((TGConversation *)_listModel[0]).conversationId == TGTelegraphInstance.clientUserId);
    }
    UIColor *backgroundColor = topIsPinned ? _presentation.pallete.barBackgroundColor : _presentation.pallete.backgroundColor;
    if (!TGObjectCompare(_searchBar.backgroundColor, backgroundColor)) {
        _searchBar.backgroundColor = backgroundColor;
        _searchTopBackgroundView.backgroundColor = backgroundColor;
    }
    _searchBar.highContrast = topIsPinned;
}

- (void)selectConversationWithId:(int64_t)conversationId
{
    bool found = false;
    
    int index = -1;
    for (TGConversation *conversation in _listModel)
    {
        index++;
        if (![conversation isKindOfClass:[TGConversation class]])
            continue;
        
        if (conversation.conversationId == conversationId && conversationId != 0)
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

- (void)searchResultsReloaded:(NSDictionary *)items searchString:(NSString *)searchString
{
    NSMutableArray *searchResultsSections = [[NSMutableArray alloc] init];
    
    if ([(NSArray *)items[@"hashtags"] count] != 0)
    {
        [searchResultsSections addObject:@{@"items": items[@"hashtags"], @"type": @"hashtags"}];
    }
    
    NSString *savedMessagesString = [TGLocalized(@"DialogList.SavedMessages") lowercaseString];
    NSString *query = [searchString lowercaseString];
    bool addSavedMessages = !self.dialogListCompanion.showGroupsOnly && [savedMessagesString hasPrefix:query];
    int32_t ownUid = TGTelegraphInstance.clientUserId;
    
    if ([(NSArray *)items[@"dialogs"] count] != 0)
    {
        NSMutableArray *dialogs = [(NSArray *)items[@"dialogs"] mutableCopy];
        if (addSavedMessages)
        {
            [dialogs enumerateObjectsUsingBlock:^(TGUser *user, NSUInteger index, BOOL *stop)
            {
                if (![user isKindOfClass:[TGUser class]])
                    return;
                
                if (user.uid == ownUid)
                {
                    [dialogs removeObjectAtIndex:index];
                    *stop = true;
                }
            }];

            [dialogs insertObject:[TGDatabaseInstance() loadUser:ownUid] atIndex:0];
        }
        [searchResultsSections addObject:@{@"title": TGLocalized(@"DialogList.SearchSectionDialogs"), @"items": dialogs, @"type": @"dialogs"}];
    }
    else if (addSavedMessages)
    {
        TGUser *ownUser = [TGDatabaseInstance() loadUser:ownUid];
        if (ownUser != nil) {
            NSArray *dialogs = @[ownUser];
            [searchResultsSections addObject:@{@"title": TGLocalized(@"DialogList.SearchSectionDialogs"), @"items": dialogs, @"type": @"dialogs"}];
        }
    }
    
    if ([(NSArray *)items[@"global"] count] != 0)
    {
        [searchResultsSections addObject:@{@"title": TGLocalized(@"DialogList.SearchSectionGlobal"), @"items": items[@"global"], @"type": @"global"}];
    }
    
    if ([(NSArray *)items[@"messages"] count] != 0)
    {
        [searchResultsSections addObject:@{@"title": TGLocalized(@"DialogList.SearchSectionMessages"), @"items": items[@"messages"], @"type": @"messages"}];
    }
    
    if ([TGPhoneUtils maybePhone:searchString])
    {
        [searchResultsSections addObject:@{@"title": TGLocalized(@"Contacts.PhoneNumber"), @"items": @[ searchString ], @"type": @"phonenumber"}];
    }
    
    _searchResultsSections = searchResultsSections;
    _searchResultsQuery = searchString;
    
    [_searchMixin reloadSearchResults];
    
    [_searchMixin setSearchResultsTableViewHidden:searchString.length == 0];
}

#pragma mark - Interface logic

- (void)updateBarButtonItemsAnimated:(bool)animated
{
    [self setLeftBarButtonItem:[self controllerLeftBarButtonItem] animated:animated];
    [self setRightBarButtonItems:[self controllerRightBarButtonItems] animated:animated];
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
    if (setupTable) {
        [_tableView setEditing:editing animated:true];
        
        if (iosMajorVersion() >= 7) {
            [UIView animateWithDuration:0.3 animations:^{
                _tableView.separatorInset = UIEdgeInsetsMake(0.0f, (editing ? 38.0f : 0.0f) + 80.0f, 0.0f, 0.0f);
            }];
        }
    }
    
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
    [_dialogListCompanion composeMessageAndOpenSearch:false];
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
            if (indexPath.row < (NSInteger)_listModel.count)
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
        id result = [_searchResultsSections[indexPath.section][@"items"] objectAtIndex:indexPath.row];
        NSString *type = _searchResultsSections[indexPath.section][@"type"];
        
        if ([result isKindOfClass:[TGConversation class]])
        {
            [_searchDisposable setDisposable:nil];
            TGConversation *conversation = (TGConversation *)result;
            if ([conversation.additionalProperties objectForKey:@"searchMessageId"] != nil)
            {
                _didSelectMessage = true;
                [_dialogListCompanion searchResultSelectedConversation:(TGConversation *)result atMessageId:[[conversation.additionalProperties objectForKey:@"searchMessageId"] intValue]];
            }
            else
            {
                [_searchDisposable setDisposable:nil];
                [TGGlobalMessageSearchSignals addRecentPeerResult:((TGConversation *)result).conversationId];
                [_dialogListCompanion searchResultSelectedConversation:(TGConversation *)result];
            }
            [tableView deselectRowAtIndexPath:indexPath animated:true];
            
            if (![type isEqualToString:@"recent"])
                _didSelectGlobalResult = true;
        }
        else if ([result isKindOfClass:[TGUser class]])
        {
            [_searchDisposable setDisposable:nil];
            [_dialogListCompanion searchResultSelectedUser:(TGUser *)result];
            [TGGlobalMessageSearchSignals addRecentPeerResult:((TGUser *)result).uid];
            [tableView deselectRowAtIndexPath:indexPath animated:true];
            
            if (![type isEqualToString:@"recent"])
                _didSelectGlobalResult = true;
        }
        else if ([result isKindOfClass:[TGMessage class]])
        {
            _didSelectMessage = true;
            [_dialogListCompanion searchResultSelectedMessage:(TGMessage *)result];
        }
        else if ([_searchResultsSections[indexPath.section][@"type"] isEqualToString:@"phonenumber"])
        {
            TGCreateContactController *createContactController = [[TGCreateContactController alloc] initWithFirstName:@" " lastName:nil phoneNumber:[TGPhoneUtils formatPhone:[TGPhoneUtils cleanPhone:result] forceInternational:true] attachment:nil];
            createContactController.delegate = self;
            
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[createContactController]];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            
            [self presentViewController:navigationController animated:true completion:^{
                _searchBar.text = @"";
                [_searchMixin setIsActive:false animated:false];
            }];
        }
        else if ([result respondsToSelector:@selector(characterAtIndex:)])
        {
            [_searchBar setText:[@"#" stringByAppendingString:result]];
        }
    }
    
    if (_dialogListCompanion.forwardMode)
        [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)maybeDismissSearchResults
{
    if (_searchMixin.isActive && _didSelectGlobalResult)
        [_searchMixin setIsActive:false animated:false];
}

#pragma mark - Table logic

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView)
        return 2;
    
    return _searchResultsSections.count;
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
        return [(NSArray *)_searchResultsSections[section][@"items"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        if (indexPath.section == 0)
            return 45.0f;
        
        int row = (int)indexPath.row;
        if (row >= 0 && row < (NSInteger)_listModel.count)
            return 76;
        
        return 0;
    }
    else
    {
        id result = [_searchResultsSections[indexPath.section][@"items"] objectAtIndex:indexPath.row];
        if ([result isKindOfClass:[TGDialogListRecentPeers class]]) {
            //TGDialogListRecentPeers *recentPeers = result;
            return [TGDialogListRecentPeersCell heightForWidth:self.view.frame.size.width count:((TGDialogListRecentPeers *)result).peers.count expanded:false /*recentPeers.identifier == nil ? false : [_expandedRecentPeerIdentifiers containsObject:recentPeers.identifier]*/];
        } else if ([result isKindOfClass:[NSString class]]) {
            return 48.0f;
        }
        
        if ([_searchResultsSections[indexPath.section][@"type"] isEqualToString:@"messages"])
            return 76.0f;
        else if ([_searchResultsSections[indexPath.section][@"type"] isEqualToString:@"hashtags"])
            return 43.0f;
        return 51.0f;
    }
}

- (void)prepareCell:(TGDialogListCell *)cell forFeed:(TGFeed *)feed animated:(bool)animated
{
    if (cell.reuseTag != (intptr_t)feed || cell.unreadCount != feed.unreadCount || (feed.serviceUnreadCount != -1 && cell.unreadCount != feed.serviceUnreadCount))
    {
        cell.conversationId = feed.conversationId;
        cell.reuseTag = (intptr_t)feed;
        cell.date = feed.messageDate;
        cell.pinnedToTop = feed.pinnedToTop;
        
        cell.titleText = TGLocalized(@"DialogList.Feed");
        cell.isGroupChat = true;
        cell.authorName = feed.chatTitles.firstObject;
        
        cell.messageText = feed.text;
        cell.messageAttachments = feed.media;
        
        cell.isFeed = true;
        cell.feedChatIds = feed.chatIds;
        cell.feedChatTitles = feed.chatTitles;
        cell.feedAvatarUrls = feed.chatPhotosSmall;
        
        cell.unreadCount = feed.serviceUnreadCount != -1 ? feed.serviceUnreadCount : feed.unreadCount;
        
        [cell resetView:animated];
    }
}

- (void)prepareCell:(TGDialogListCell *)cell forConversation:(TGConversation *)conversation animated:(bool)animated isSearch:(bool)isSearch
{
    if (cell.reuseTag != (intptr_t)conversation || cell.conversationId != conversation.conversationId || cell.unreadCount != conversation.unreadCount || cell.serviceUnreadCount != conversation.serviceUnreadCount || cell.unreadMentionCount != conversation.unreadMentionCount || cell.isAd != conversation.isAd)
    {
        cell.reuseTag = (intptr_t)conversation;
        cell.conversationId = conversation.conversationId;
    
        cell.date = conversation.unpinnedDate;
        cell.pinnedToTop = conversation.pinnedToTop && !_dialogListCompanion.feedChannels;
        cell.isAd = conversation.isAd;
        cell.groupedInFeed = conversation.feedId.intValue != 0;
        cell.isFeedChannels = _dialogListCompanion.feedChannels;
        
        if (conversation.deliveryError)
            cell.deliveryState = TGMessageDeliveryStateFailed;
        else
            cell.deliveryState = conversation.deliveryState;
        
        NSDictionary *dialogListData = conversation.dialogListData;
        
        int isSavedMessages = [dialogListData[@"isSavedMessages"] intValue];
        cell.isSavedMessages = isSavedMessages;
        cell.titleText = isSavedMessages ? TGLocalized(@"DialogList.SavedMessages") : [dialogListData objectForKey:@"title"];
        cell.titleLetters = [dialogListData objectForKey:@"titleLetters"];
        
        cell.isBroadcast = [dialogListData[@"isBroadcast"] boolValue];
        
        cell.isChannel = TGPeerIdIsChannel(conversation.conversationId);
        cell.isChannelGroup = conversation.isChannelGroup;
        cell.isVerified = [dialogListData[@"isVerified"] boolValue];
        cell.draft = isSearch ? nil : dialogListData[@"draft"];
        cell.hasExplicitContent = conversation.hasExplicitContent;
        
        cell.isEncrypted = [dialogListData[@"isEncrypted"] boolValue];
        cell.encryptionStatus = [dialogListData[@"encryptionStatus"] intValue];
        cell.encryptedUserId = [dialogListData[@"encryptedUserId"] intValue];
        cell.encryptionOutgoing = [dialogListData[@"encryptionOutgoing"] boolValue];
        cell.encryptionFirstName = dialogListData[@"encryptionFirstName"];
        
        NSString *authorName = [dialogListData objectForKey:@"authorName"];
        NSNumber *nIsChat = [dialogListData objectForKey:@"isChat"];
        
        if (nIsChat != nil && [nIsChat boolValue])
        {
            NSArray *chatAvatarUrls = [dialogListData objectForKey:@"chatAvatarUrls"];
            cell.groupChatAvatarCount = (int)chatAvatarUrls.count;
            cell.groupChatAvatarUrls = chatAvatarUrls;
            cell.isGroupChat = true;
            cell.avatarUrl = [dialogListData objectForKey:@"avatarUrl"];
        }
        else
        {
            cell.avatarUrl = [dialogListData objectForKey:@"avatarUrl"];
            cell.isGroupChat = false;
            
        }
        cell.authorName = [authorName isEqualToString:authorNameYou] ? TGLocalized(@"DialogList.You") : authorName;
        cell.authorIsSelf = [dialogListData[@"authorIsSelf"] boolValue];
        
        cell.isMuted = [[dialogListData objectForKey:@"mute"] boolValue];
        
        if (TGPeerIdIsChannel(conversation.conversationId)) {
            int32_t mid = TGConversationSortKeyMid(conversation.variantSortKey);
            cell.unread = mid >= TGMessageLocalMidBaseline || mid > conversation.maxOutgoingReadMessageId;
            
            if (!conversation.isChannelGroup && conversation.outgoing && conversation.deliveryState == TGMessageDeliveryStateDelivered) {
                cell.unread = false;
            }
        } else {
            if ([dialogListData[@"isBot"] boolValue]) {
                cell.unread = false;
            } else {
                cell.unread = conversation.unread;
            }
        }
        
        cell.unreadMark = conversation.unreadMark;
        
        if (!isSearch)
        {
            if ([_dialogListCompanion isConversationOpened:conversation.conversationId])
            {
                cell.unreadCount = 0;
                cell.serviceUnreadCount = 0;
                cell.unreadMentionCount = conversation.unreadMentionCount;
            }
            else
            {
                cell.unreadCount = conversation.unreadCount;
                cell.serviceUnreadCount = conversation.serviceUnreadCount;
                cell.unreadMentionCount = conversation.unreadMentionCount;
                if (conversation.unreadMentionCount == 1 && (conversation.unreadCount + conversation.serviceUnreadCount) == 1) {
                    if ([TGMessage containsUnseenMention:conversation.messageFlags]) {
                        cell.unreadCount = 0;
                        cell.serviceUnreadCount = 0;
                    }
                }
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

- (bool)isLastCell:(NSIndexPath *)indexPath {
    bool isLastCell = false;
    TGConversation *conversation = [_listModel objectAtIndex:indexPath.row];
    if (indexPath.row + 1 < (NSInteger)_listModel.count) {
        TGConversation *nextConversation = [_listModel objectAtIndex:indexPath.row + 1];
        isLastCell = (nextConversation.pinnedToTop || nextConversation.isAd) != (conversation.pinnedToTop || conversation.isAd);
    } else {
        isLastCell = true;
    }
    return isLastCell;
}

- (void)updateIsLastCell {
    for (NSIndexPath *indexPath in _tableView.indexPathsForVisibleRows) {
        TGDialogListCell *cell = (TGDialogListCell *)[_tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[TGDialogListCell class]]) {
            [cell setIsLastCell:[self isLastCell:indexPath]];
        }
    }
}

- (void)updateSafeAreaInset
{
    UIEdgeInsets safeAreaInset = [self calculatedSafeAreaInset];
    
    for (UIView *view in _searchMixin.searchResultsTableView.subviews)
    {
        if (view.tag >= 1000)
        {
            UIView *sectionLabel = [view viewWithTag:100];
            sectionLabel.frame =  CGRectMake(14.0f + safeAreaInset.left, 6.0f, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
            
            UIView *clearButton = [view viewWithTag:200];
            clearButton.frame = CGRectMake(clearButton.superview.frame.size.width - clearButton.frame.size.width - safeAreaInset.right, 0.0f, clearButton.frame.size.width, 28.0f);
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGUser *user = nil;
    TGConversation *conversation = nil;
    TGMessage *message = nil;
    NSString *hashtag = nil;
    bool isGlobalSearch = false;
    bool isMessageSearch = false;
    
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
            if (indexPath.row < (NSInteger)_listModel.count)
                conversation = [_listModel objectAtIndex:indexPath.row];
        }
    }
    else
    {
        id result = [_searchResultsSections[indexPath.section][@"items"] objectAtIndex:indexPath.row];
        if ([_searchResultsSections[indexPath.section][@"type"] isEqualToString:@"phonenumber"] && [result isKindOfClass:[NSString class]]) {
            TGFlatActionCell *actionCell = (TGFlatActionCell *)[tableView dequeueReusableCellWithIdentifier:@"TGFlatActionCell"];
            actionCell.presentation = self.presentation;
            if (actionCell == nil)
                actionCell = [[TGFlatActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGFlatActionCell"];
            
            [actionCell setPhoneNumber:[TGPhoneUtils cleanPhone:(NSString *)result]];
            
            return actionCell;
        }
        if ([result isKindOfClass:[TGDialogListRecentPeers class]]) {
            //TGDialogListRecentPeers *recentPeers = result;
            TGDialogListRecentPeersCell *cell = (TGDialogListRecentPeersCell *)[tableView dequeueReusableCellWithIdentifier:@"TGDialogListRecentPeersCell"];
            if (cell == nil) {
                cell = [[TGDialogListRecentPeersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGDialogListRecentPeersCell"];
                __weak TGDialogListController *weakSelf = self;
                cell.peerSelected = ^(id peer) {
                    __strong TGDialogListController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        if ([peer isKindOfClass:[TGUser class]]) {
                            [strongSelf.dialogListCompanion searchResultSelectedUser:peer];
                        } else if ([peer isKindOfClass:[TGConversation class]]) {
                            [strongSelf.dialogListCompanion searchResultSelectedConversation:peer];
                        }
                    }
                };
                
                cell.peerLongTap = ^(id peer) {
                    __strong TGDialogListController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [[[TGCustomActionSheet alloc] initWithTitle:nil actions:@[
                            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Delete") action:@"delete" type:TGActionSheetActionTypeDestructive],
                            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel],
                        ] actionBlock:^(__unused id target, NSString *action) {
                            if ([action isEqualToString:@"delete"]) {
                                int64_t peerId = 0;
                                int64_t accessHash = 0;
                                if ([peer isKindOfClass:[TGUser class]]) {
                                    peerId = ((TGUser *)peer).uid;
                                    accessHash = ((TGUser *)peer).phoneNumberHash;
                                } else if ([peer isKindOfClass:[TGConversation class]]) {
                                    peerId = ((TGConversation *)peer).conversationId;
                                    accessHash = ((TGConversation *)peer).accessHash;
                                }
                                if (peerId != 0) {
                                    [[[TGRecentPeersSignals resetGenericPeerRating:peerId accessHash:accessHash] timeout:5.0 onQueue:[SQueue concurrentDefaultQueue] orSignal:[SSignal fail:nil]] startWithNext:nil];
                                }
                            }
                        } target:strongSelf] showInView:strongSelf.view];
                    }
                };
            }
            cell.presentation = self.presentation;
            cell.safeAreaInset = self.controllerSafeAreaInset;
            
            NSMutableDictionary *unreadCounts = [[NSMutableDictionary alloc] init];
            for (id item in ((TGDialogListRecentPeers *)result).peers)
            {
                int64_t peerId = 0;
                if ([item isKindOfClass:[TGConversation class]])
                    peerId = ((TGConversation *)item).conversationId;
                else if ([item isKindOfClass:[TGUser class]])
                    peerId = ((TGUser *)item).uid;
                
                if (peerId != 0)
                    unreadCounts[@(peerId)] = @([TGDatabaseInstance() unreadCountForConversation:peerId]);
            }
            
            [cell setRecentPeers:result unreadCounts:unreadCounts];
            return cell;
        } else if ([result isKindOfClass:[TGConversation class]]) {
            conversation = result;
            isMessageSearch = [_searchResultsSections[indexPath.section][@"type"] isEqualToString:@"messages"];
            isGlobalSearch = [_searchResultsSections[indexPath.section][@"type"] isEqualToString:@"global"];
        }
        else if ([result isKindOfClass:[TGUser class]])
        {
            user = result;
            isGlobalSearch = [_searchResultsSections[indexPath.section][@"type"] isEqualToString:@"global"];
        }
        else if ([result isKindOfClass:[TGMessage class]])
            message = result;
        else
            hashtag = result;
    }
    
    if (tableView == _tableView)
    {
        if (conversation != nil)
        {
            if ([conversation isKindOfClass:[TGConversation class]])
            {
                static NSString *MessageCellIdentifier = @"MC";
                TGDialogListCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
                
                if (cell == nil)
                {
                    cell = [[TGDialogListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageCellIdentifier assetsSource:[_dialogListCompanion dialogListCellAssetsSource]];
                    cell.deleteConversation = self.deleteConversation;
                    cell.toggleMuteConversation = self.toggleMuteConversation;
                    cell.togglePinConversation = self.togglePinConversation;
                    cell.toggleGroupConversation = self.toggleGroupConversation;
                    cell.toggleReadConversation = self.toggleReadConversation;
                    cell.watcherHandle = _actionHandle;
                    cell.enableEditing = ![_dialogListCompanion forwardMode] && !_dialogListCompanion.privacyMode;
                }
                
                cell.presentation = _presentation;
                [self prepareCell:cell forConversation:conversation animated:false isSearch:false];
                [cell setIsLastCell:[self isLastCell:indexPath]];
                
                return cell;
            }
            else
            {
                static NSString *FeedCellIdentifier = @"FC";
                TGDialogListCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];
                
                if (cell == nil)
                {
                    cell = [[TGDialogListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeedCellIdentifier assetsSource:[_dialogListCompanion dialogListCellAssetsSource]];
                    cell.deleteConversation = self.deleteConversation;
                    cell.togglePinConversation = self.togglePinConversation;
                    cell.watcherHandle = _actionHandle;
                    //cell.enableEditing = ![_dialogListCompanion forwardMode] && !_dialogListCompanion.privacyMode;
                }
                
                cell.presentation = _presentation;
                [self prepareCell:cell forFeed:(TGFeed *)conversation animated:false];
                [cell setIsLastCell:[self isLastCell:indexPath]];
                
                return cell;
            }
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
        if ((conversation != nil || user != nil) && !isMessageSearch)
        {
            static NSString *SearchCellIdentifier = @"UC";
            TGDialogListSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
            if (cell == nil)
            {
                cell = [[TGDialogListSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier assetsSource:[_dialogListCompanion dialogListCellAssetsSource]];
            }
            cell.presentation = self.presentation;
            cell.isEncrypted = false;
            cell.encryptedUserId = 0;
            cell.isVerified = false;
            cell.isSavedMessages = false;
            
            int64_t previousCellConversationId = cell.conversationId;
            
            if (conversation != nil)
            {
                NSDictionary *dialogListData = conversation.dialogListData;
                
                cell.isSavedMessages = [dialogListData[@"isSavedMessages"] intValue];
                cell.isEncrypted = [dialogListData[@"isEncrypted"] boolValue];
                
                if (cell.isSavedMessages)
                {
                    cell.titleTextFirst = TGLocalized(@"DialogList.SavedMessages");
                    cell.titleTextSecond = nil;
                }
                else
                {
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
                }
                
                cell.isVerified = conversation.isVerified;
                cell.hasExplicitContent = conversation.hasExplicitContent;
                
                NSNumber *nIsChat = [dialogListData objectForKey:@"isChat"];
                if (nIsChat != nil && [nIsChat boolValue])
                    cell.isChat = true;
                
                cell.avatarUrl = [dialogListData objectForKey:@"avatarUrl"];
                
                NSString *type = nil;
                if ([dialogListData[@"isChannelGroup"] boolValue] || TGPeerIdIsGroup(conversation.conversationId))
                {
                    if (conversation.chatParticipantCount > 0)
                    {
                        type = [effectiveLocalization() getPluralized:@"Conversation.StatusMembers" count:conversation.chatParticipantCount];
                    }
                    else if ([dialogListData[@"isChannelGroup"] boolValue])
                    {
                        SSignal *signal = [[[TGDatabaseInstance() channelCachedData:conversation.conversationId] take:1] mapToSignal:^SSignal *(TGCachedConversationData *data)
                        {
                            if (data.memberCount != 0)
                            {
                                return [SSignal single:@(data.memberCount)];
                            }
                            else
                            {
                                return [[TGChannelManagementSignals updateChannelExtendedInfo:conversation.conversationId accessHash:conversation.accessHash updateUnread:false] then:[[[TGDatabaseInstance() channelCachedData:conversation.conversationId] take:1] map:^id(TGCachedConversationData *data)
                                {
                                    return @(data.memberCount);
                                }]];
                            }
                        }];
                        
                        if (previousCellConversationId != conversation.conversationId)
                        {
                            __weak TGDialogListSearchCell *weakCell = cell;
                            [cell.channelDisposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *memberCount)
                            {
                                __strong TGDialogListSearchCell *strongCell = weakCell;
                                if (strongCell != nil) {
                                    NSString *subtitle = [effectiveLocalization() getPluralized:@"Conversation.StatusMembers" count:memberCount.int32Value];
                                    
                                    if (isGlobalSearch && conversation.username.length != 0){
                                        NSString *string = [[NSString alloc] initWithFormat:@"@%@", conversation.username];
                                        if (subtitle.length > 0)
                                            string = [NSString stringWithFormat:TGLocalized(@"DialogList.SearchSubtitleFormat"), string, subtitle];
                                        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: TGSystemFontOfSize(14.0f)}];
                                        [attributedString addAttribute:NSForegroundColorAttributeName value:self.presentation.pallete.secondaryTextColor range:NSMakeRange(0, string.length)];
                                        if (_searchResultsQuery.length != 0)
                                        {
                                            NSRange range = [[string lowercaseString] rangeOfString:[_searchResultsQuery lowercaseString]];
                                            if (range.location != NSNotFound && range.location < conversation.username.length + 1)
                                            {
                                                if (range.location == 1)
                                                {
                                                    range.location = 0;
                                                    range.length++;
                                                }
                                                [attributedString addAttribute:NSForegroundColorAttributeName value:self.presentation.pallete.accentColor range:range];
                                            }
                                        }
                                        strongCell.attributedSubtitleText = attributedString;
                                    } else {
                                        NSDictionary *attributes = @{NSFontAttributeName: TGSystemFontOfSize(14.0f), NSForegroundColorAttributeName: self.presentation.pallete.secondaryTextColor};
                                        if (subtitle.length > 0)
                                            strongCell.attributedSubtitleText = [[NSAttributedString alloc] initWithString:subtitle attributes:attributes];
                                        else
                                            strongCell.attributedSubtitleText = nil;
                                    }
                                    
                                    [strongCell resetView:false];
                                }
                            }]];
                        }
                    }
                }
                else if ([dialogListData[@"isChannel"] boolValue])
                {
                    if (conversation.chatParticipantCount > 0)
                    {
                        type = [effectiveLocalization() getPluralized:@"Conversation.StatusSubscribers" count:conversation.chatParticipantCount];
                    }
                }
                
                if (isGlobalSearch && conversation.username.length != 0){
                    NSString *string = [[NSString alloc] initWithFormat:@"@%@", conversation.username];
                    if (type.length > 0)
                        string = [NSString stringWithFormat:TGLocalized(@"DialogList.SearchSubtitleFormat"), string, type];
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: TGSystemFontOfSize(14.0f)}];
                    [attributedString addAttribute:NSForegroundColorAttributeName value:self.presentation.pallete.secondaryTextColor range:NSMakeRange(0, string.length)];
                    if (_searchResultsQuery.length != 0)
                    {
                        NSRange range = [[string lowercaseString] rangeOfString:[_searchResultsQuery lowercaseString]];
                        if (range.location != NSNotFound && range.location < conversation.username.length + 1)
                        {
                            if (range.location == 1)
                            {
                                range.location = 0;
                                range.length++;
                            }
                            [attributedString addAttribute:NSForegroundColorAttributeName value:self.presentation.pallete.accentColor range:range];
                        }
                    }
                    cell.attributedSubtitleText = attributedString;
                } else {
                    if (previousCellConversationId != conversation.conversationId)
                    {
                        NSDictionary *attributes = @{NSFontAttributeName: TGSystemFontOfSize(14.0f), NSForegroundColorAttributeName: self.presentation.pallete.secondaryTextColor};
                        if (type.length > 0)
                            cell.attributedSubtitleText = [[NSAttributedString alloc] initWithString:type attributes:attributes];
                        else
                            cell.attributedSubtitleText = nil;
                    }
                }
                
                cell.conversationId = conversation.conversationId;
                cell.encryptedUserId = [dialogListData[@"encryptedUserId"] intValue];
                
                if (TGPeerIdIsChannel(conversation.conversationId)) {
                    cell.unreadCount = conversation.kind == TGConversationKindPersistentChannel ? conversation.unreadCount : 0;
                } else {
                    cell.unreadCount = conversation.unreadCount;
                }
            }
            else if (user != nil)
            {
                cell.isChat = false;
                
                bool isSavedMessages = user.uid == TGTelegraphInstance.clientUserId;
                cell.isSavedMessages = isSavedMessages;
                if (isSavedMessages)
                {
                    cell.titleTextFirst = TGLocalized(@"DialogList.SavedMessages");
                    cell.titleTextSecond = nil;
                }
                else
                {
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
                }

                if (isGlobalSearch)
                {
                    NSString *string = [[NSString alloc] initWithFormat:@"@%@", user.userName];
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: TGSystemFontOfSize(14.0f)}];
                    [attributedString addAttribute:NSForegroundColorAttributeName value:self.presentation.pallete.secondaryTextColor range:NSMakeRange(0, string.length)];
                    if (_searchResultsQuery.length != 0)
                    {
                        NSRange range = [[string lowercaseString] rangeOfString:[_searchResultsQuery lowercaseString]];
                        if (range.location != NSNotFound && range.location < user.userName.length + 1)
                        {
                            if (range.location == 1)
                            {
                                range.location = 0;
                                range.length++;
                            }
                            [attributedString addAttribute:NSForegroundColorAttributeName value:self.presentation.pallete.accentColor range:range];
                        }
                    }
                    cell.attributedSubtitleText = attributedString;
                }
                else {
                    cell.attributedSubtitleText = nil;
                }
                
                cell.unreadCount = conversation.unreadCount;
                
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
                if (cell == nil)
                {
                    cell = [[TGDialogListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageCellIdentifier assetsSource:[_dialogListCompanion dialogListCellAssetsSource]];
                    cell.watcherHandle = _actionHandle;
                    cell.enableEditing = false;
                }
            }
            
            cell.presentation = _presentation;
            cell.disableActions = true;
            [self prepareCell:cell forConversation:conversation animated:false isSearch:true];
            
            return cell;
        }
        else if (hashtag != nil)
        {
            TGHashtagPanelCell *cell = [tableView dequeueReusableCellWithIdentifier:TGHashtagPanelCellKind];
            if (cell == nil)
            {
                cell = [[TGHashtagPanelCell alloc] initWithStyle:TGModernConversationAssociatedInputPanelDefaultStyle];
                [cell setDisplaySeparator:true];
            }
            [cell setPallete:self.presentation.associatedInputPanelPallete];
            [cell setHashtag:hashtag];
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark -

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        int listCount = (int)_listModel.count;
        if (_canLoadMore && !_isLoading && listCount != 0 && (listCount < 10 || indexPath.row >= listCount - 10))
        {
            _isLoading = true;
            [_dialogListCompanion loadMoreItems];
        }
        
        if ([cell isKindOfClass:[TGDialogListCell class]])
        {
            TGDialogListCell *dialogCell = (TGDialogListCell *)cell;
            
            if (dialogCell.conversationId == _scheduledHighlightAnimationConversationId)
            {
                _scheduledHighlightAnimationConversationId = 0;
                [dialogCell animateHighlight];
            }
            
            if (iosMajorVersion() < 7)
            {
                UIColor *backgroundColor = dialogCell.pinnedToTop || dialogCell.isAd || dialogCell.isSavedMessages == 2 ? self.presentation.pallete.dialogPinnedBackgroundColor : self.presentation.pallete.backgroundColor;
                cell.backgroundColor = backgroundColor;
            }
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
        
        if (indexPath.row < (NSInteger)_listModel.count) {
            TGConversation *item = _listModel[indexPath.row];
            if (item.isAd) {
                return false;
            }
            return true;
        } else {
            return false;
        }
    }
    else
    {
        id result = [_searchResultsSections[indexPath.section][@"items"] objectAtIndex:indexPath.row];
        if ([result isKindOfClass:[TGDialogListRecentPeers class]]) {
            return false;
        }
        
        if ([_searchResultsSections[indexPath.section][@"type"] isEqualToString:@"recent"])
            return true;
    }
        
    return false;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (tableView == _tableView) {
        if (!tableView.editing) {
            return UITableViewCellEditingStyleNone;
        }
    }
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_tableView != tableView) {
        id result = [_searchResultsSections[indexPath.section][@"items"] objectAtIndex:indexPath.row];
        if ([result isKindOfClass:[TGDialogListRecentPeers class]]) {
            return false;
        }
    }
    else
    {
        for (NSIndexPath *indexPath in [_tableView indexPathsForVisibleRows]) {
            TGDialogListCell *cell = (TGDialogListCell *)[_tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[TGDialogListCell class]]) {
                if ([cell isEditingControlsTracking]) {
                    return false;
                }
            }
        }
    }
    return true;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
        return indexPath.row < (NSInteger)_listModel.count;
    return true;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (tableView == _tableView)
    {
        [self setupEditingMode:true setupTable:false];
        [self updateBarButtonItemsAnimated:true];
    }
}

#pragma mark -

- (UITableView *)createTableViewForSearchMixin:(TGSearchDisplayMixin *)__unused searchMixin
{
    UITableView *tableView = [[UITableView alloc] init];
    
    tableView.backgroundColor = self.presentation.pallete.backgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (iosMajorVersion() >= 7) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorColor = self.presentation.pallete.separatorColor;
        tableView.separatorInset = UIEdgeInsetsMake(0.0f, 80.0f, 0.0f, 0.0f);
    }
    
    if (tableView.tableFooterView == nil)
        tableView.tableFooterView = [[UIView alloc] init];
    
    return tableView;
}

- (UIView *)referenceViewForSearchResults
{
    return _tableView;
}

- (void)searchMixin:(TGSearchDisplayMixin *)__unused searchMixin hasChangedSearchQuery:(NSString *)searchQuery withScope:(int)__unused scope
{
    if (searchQuery.length == 0)
    {
        [_searchDisposable setDisposable:nil];
        _searchResultsSections = _recentSearchResultsSections;
        [_searchMixin reloadSearchResults];
        [_searchMixin setSearchResultsTableViewHidden:false];
    }
    else
    {
        if (_searchDisposable == nil)
            _searchDisposable = [[SMetaDisposable alloc] init];
        __weak TGDialogListController *weakSelf = self;
        _searchBar.delayActivity = false;
        _searchBar.showActivity = true;
        [_searchDisposable setDisposable:[[[TGGlobalMessageSearchSignals search:searchQuery includeMessages:!_dialogListCompanion.forwardMode itemMapping:^id(id item)
        {
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf.dialogListCompanion processSearchResultItem:item];
            return nil;
        }] onDispose:^
        {
            TGDispatchOnMainThread(^
            {
                __strong TGDialogListController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_searchBar.showActivity = false;
                }
            });
        }] startWithNext:^(NSDictionary *result)
        {
            TGDispatchOnMainThread(^
            {
                __strong TGDialogListController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if ([searchQuery isEqualToString:strongSelf->_searchBar.text]) {
                        [strongSelf searchResultsReloaded:result searchString:searchQuery];
                    }
                }
            });
        } error:^(__unused id error)
        {
            TGDispatchOnMainThread(^
            {
                __strong TGDialogListController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_searchBar.showActivity = false;
                }
            });
        } completed:^
        {
            TGDispatchOnMainThread(^
            {
                __strong TGDialogListController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_searchBar.showActivity = false;
                }
            });
        }]];
    }
}

- (void)searchMixinWillActivate:(bool)animated
{
    _isDisplayingSearch = true;
    _tableView.scrollEnabled = false;
    
    _emptyListContainer.hidden = true;
    
    if (iosMajorVersion() >= 11)
    {
        if (animated)
            [self setNavigationBarHidden:true withAnimation:TGViewControllerNavigationBarAnimationSlideFar duration:0.3];
        else
            [self setNavigationBarHidden:true animated:false];
    }
    else
    {
        [self setNavigationBarHidden:true animated:animated];
    }
    [self setPrimaryTitlePanel:nil fade:true];
    
    if (_recentSearchResultsDisposable == nil)
        _recentSearchResultsDisposable = [[SMetaDisposable alloc] init];
    
    __weak TGDialogListController *weakSelf = self;
    SSignal *updatedRecentPeers = [[TGRecentPeersSignals updateRecentPeers] mapToSignal:^SSignal *(__unused id next) {
        return [SSignal complete];
    }];
    
    [_recentSearchResultsDisposable setDisposable:[[[SSignal mergeSignals:@[[TGGlobalMessageSearchSignals recentPeerResults:^id (id item, bool recent) {
        __strong TGDialogListController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (!recent && [item isKindOfClass:[TGConversation class]] && ((TGConversation *)item).conversationId == TGTelegraphInstance.clientUserId)
                return nil;

            return [strongSelf.dialogListCompanion processSearchResultItem:item];
        }
        return nil;
    } ratedPeers:true], updatedRecentPeers]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *peerResults)
    {
        __strong TGDialogListController *strongSelf = weakSelf;
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
    
    _emptyListContainer.hidden = false;
    
    [_recentSearchResultsDisposable setDisposable:nil];
    
    [self setNavigationBarHidden:false animated:animated];
    [self setPrimaryTitlePanel:_currentTitlePanel fade:false];
    
    if (_displayProxyIssuesTooltip)
    {
        if ([self isVisible])
        {
            TGDispatchAfter(0.3, dispatch_get_main_queue(), ^
            {
                _displayProxyIssuesTooltip = false;
                [self displayProxyTooltip];
            });
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != _tableView)
        return;
    
    if ((scrollView.isDragging || scrollView.isTracking) && _scrollingToConversationId != 0)
        _scrollingToConversationId = 0;
    
    bool atTop = scrollView.contentOffset.y <= -_tableView.tableHeaderView.frame.size.height + FLT_EPSILON;
    [_atTopPromise set:[SSignal single:@(atTop)]];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == _tableView)
        _scrollingToConversationId = 0;
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

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)__unused scrollView {
    return !TGTelegraphInstance.callManager.hasActiveCall;
}

#pragma mark -

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)__unused controller
{
    [_searchBar setSelectedScopeButtonIndex:0];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)__unused controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [_dialogListCompanion beginSearch:searchString inMessages:false];
    
    return FALSE;
}

- (void)searchDisplayController:(UISearchDisplayController *)__unused controller willShowSearchResultsTableView:(UITableView *)__unused tableView
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (iosMajorVersion() >= 7) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorColor = TGSeparatorColor();
        tableView.separatorInset = UIEdgeInsetsMake(0.0f, 80.0f, 0.0f, 0.0f);
    }
    
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

- (void)startSearch
{
    [(TGListsTableView *)_tableView setBlockContentOffset:true];
    [_searchBar becomeFirstResponder];
    TGDispatchAfter(0.1f, dispatch_get_main_queue(), ^
    {
        [(TGListsTableView *)_tableView setBlockContentOffset:false];
        _tableView.contentOffset = CGPointMake(0, -_tableView.contentInset.top);
    });
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)__unused editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        TGConversation *conversation = nil;
        if (indexPath.row < (NSInteger)_listModel.count)
            conversation = [_listModel objectAtIndex:indexPath.row];
        
        if (conversation != nil)
        {
            int64_t conversationIdToDelete = conversation.conversationId;
            
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            
            TGUser *user = conversation.conversationId > 0 ? [TGDatabaseInstance() loadUser:(int)conversation.conversationId] : nil;

            if ([conversation isKindOfClass:[TGFeed class]])
            {
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"DialogList.UngroupAllChannels") action:@"delete" type:TGActionSheetActionTypeDestructive]];
            }
            else if (conversation.conversationId > 0 && (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot))
            {
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"DialogList.DeleteBotConfirmation") action:@"clear" type:TGActionSheetActionTypeGeneric]];
                
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"DialogList.DeleteBotConversationConfirmation") action:@"delete" type:TGActionSheetActionTypeDestructive]];
            }
            else
            {
                if (!conversation.isChannel || (conversation.isChannelGroup && conversation.username.length == 0)) {
                    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"DialogList.ClearHistoryConfirmation") action:@"clear" type:TGActionSheetActionTypeGeneric]];
                }
                
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:(conversation.isBroadcast || !conversation.isChat) ? TGLocalized(@"Common.Delete") : TGLocalized(@"DialogList.DeleteConversationConfirmation") action:@"delete" type:TGActionSheetActionTypeDestructive]];
            }

            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
            
            __weak TGDialogListController *weakSelf = self;
            TGCustomActionSheet *sheet = [[TGCustomActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action) {
                __strong TGDialogListController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                if (conversationIdToDelete == 0)
                    return;
                
                if ([action isEqualToString:@"delete"])
                {
                    if (conversationIdToDelete != 0)
                    {
                        for (TGConversation *conversation in strongSelf->_listModel)
                        {
                            if (conversation.conversationId == conversationIdToDelete)
                            {
                                [strongSelf->_dialogListCompanion deleteItem:conversation animated:true];
                                break;
                            }
                        }
                    }
                }
                else if ([action isEqualToString:@"clear"])
                {
                    for (TGConversation *conversation in strongSelf->_listModel)
                    {
                        if (conversation.conversationId == conversationIdToDelete)
                        {
                            [strongSelf->_dialogListCompanion clearItem:conversation animated:true];
                            break;
                        }
                    }
                }
            } target:self];
            
            if (!TGIsPad())
            {
                [sheet showInView:self.navigationController.view];
            }
            else
            {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                [sheet showFromRect:[tableView convertRect:cell.frame toView:self.view] inView:self.view animated:true];
            }
        }
    }
    else
    {
        id result = [_searchResultsSections[indexPath.section][@"items"] objectAtIndex:indexPath.row];
        if ([result isKindOfClass:[TGDialogListRecentPeers class]]) {
        } else {
            int64_t peerId = 0;
            if ([result isKindOfClass:[TGConversation class]])
                peerId = ((TGConversation *)result).conversationId;
            else if ([result isKindOfClass:[TGUser class]])
                peerId = ((TGUser *)result).uid;
            
            if (peerId != 0)
            {
                [TGGlobalMessageSearchSignals removeRecentPeerResult:peerId];
                NSMutableArray *updatedSearchResultsSections = [[NSMutableArray alloc] initWithArray:_searchResultsSections];
                NSMutableDictionary *updatedSection = [[NSMutableDictionary alloc] initWithDictionary:_searchResultsSections[indexPath.section]];
                NSMutableArray *updatedItems = [[NSMutableArray alloc] initWithArray:updatedSection[@"items"]];
                [updatedItems removeObjectAtIndex:indexPath.row];
                if (updatedItems.count == 0)
                {
                    [updatedSearchResultsSections removeObjectAtIndex:indexPath.section];
                    _searchResultsSections = updatedSearchResultsSections;
                    
                    [tableView beginUpdates];
                    [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                }
                else
                {
                    updatedSection[@"items"] = updatedItems;
                    updatedSearchResultsSections[indexPath.section] = updatedSection;
                    _searchResultsSections = updatedSearchResultsSections;
                    
                    [tableView beginUpdates];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                }
            }
        }
    }
}

- (void)_commitDeleteChannel:(TGConversation *)conversation {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow show:true];
    
    [[[[TGChannelManagementSignals deleteChannel:conversation.conversationId accessHash:conversation.accessHash] deliverOn:[SQueue mainQueue]] onDispose:^{
        TGDispatchOnMainThread(^{
            [progressWindow dismiss:true];
        });
    }] startWithNext:nil error:^(__unused id error) {
        [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:conversation.conversationId unreadCount:0 serviceUnreadCount:0] animated:false];
    } completed:^{
        [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:conversation.conversationId unreadCount:0 serviceUnreadCount:0] animated:false];
    }];
}

- (void)localizationUpdated
{
    [_searchBar localizationUpdated];
    _searchBar.placeholder = TGLocalized(@"DialogList.SearchLabel");
    
    [self setLeftBarButtonItem:[self controllerLeftBarButtonItem]];
    
    [self setTitleText:TGLocalized(@"DialogList.Title")];
    
    _titleLabel.text = TGLocalized(@"DialogList.Title");
    [_titleLabel sizeToFit];
    [self _layoutTitleViews:self.interfaceOrientation];
    
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
    
    [self reloadData:false];
    
    _visibleConversationsPipe.sink(@true);
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (tableView == _tableView && !tableView.editing)
    {
        if (_editingMode)
        {
            [self setupEditingMode:false setupTable:false];
            [self updateBarButtonItemsAnimated:true];
        }
        [self selectCurrentConversation];
    }
}

- (void)selectCurrentConversation
{
    int index = -1;
    for (TGConversation *conversation in _listModel)
    {
        index++;
        if (![conversation isKindOfClass:[TGConversation class]])
            continue;
        
        if ([_dialogListCompanion isConversationOpened:conversation.conversationId])
        {
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1] animated:false scrollPosition:UITableViewScrollPositionNone];
            
            break;
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
    
    UIView *view = [self generateSectionHeader:_searchResultsSections[section][@"title"] first:false wide:true clear:clear];
    view.tag = 1000 + section;
    return view;
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
        sectionView.tag = 50;
        sectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        sectionView.backgroundColor = self.presentation.pallete.barBackgroundColor;
        [sectionContainer addSubview:sectionView];
        
        /*CGFloat separatorHeight = TGScreenPixel;
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, sectionView.frame.origin.y - (first ? separatorHeight : 0.0f), 10, separatorHeight)];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        separatorView.backgroundColor = TGSeparatorColor();
        [sectionContainer addSubview:separatorView];*/
        
        UILabel *sectionLabel = [[UILabel alloc] init];
        sectionLabel.tag = 100;
        sectionLabel.backgroundColor = sectionView.backgroundColor;
        sectionLabel.textColor = [UIColor blackColor];
        sectionLabel.numberOfLines = 1;
        
        [sectionContainer addSubview:sectionLabel];
        
        [reusableList addObject:sectionContainer];
        
        TGModernButton *clearButton = [[TGModernButton alloc] init];
        clearButton.tag = 200;
        clearButton.exclusiveTouch = true;
        [clearButton setTitle:TGLocalized(@"WebSearch.RecentSectionClear") forState:UIControlStateNormal];
        [clearButton setTitleColor:UIColorRGB(0x8e8e93)];
        clearButton.titleLabel.font = TGSystemFontOfSize(12);
        [clearButton sizeToFit];
        CGRect clearButtonFrame = CGRectMake(0, 0, clearButton.frame.size.width + 27.0f, 26.0f);
        clearButtonFrame.origin.x = sectionContainer.frame.size.width - clearButtonFrame.size.width;
        clearButton.frame = clearButtonFrame;
        [clearButton setTag:200];
        [clearButton addTarget:self action:@selector(clearRecentButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [sectionContainer addSubview:clearButton];
    }
    
    UIView *sectionView = [sectionContainer viewWithTag:50];
    sectionView.backgroundColor = self.presentation.pallete.sectionHeaderBackgroundColor;
    
    UILabel *sectionLabel = (UILabel *)[sectionContainer viewWithTag:100];
    sectionLabel.font = wide ? TGBoldSystemFontOfSize(12.0f) : TGBoldSystemFontOfSize(17);
    sectionLabel.text = [title uppercaseString];
    sectionLabel.backgroundColor = sectionView.backgroundColor;
    sectionLabel.textColor = self.presentation.pallete.sectionHeaderTextColor;
    [sectionLabel sizeToFit];
    if (wide)
    {
        sectionLabel.frame = CGRectMake(14.0f + self.controllerSafeAreaInset.left, 6.0f + TGScreenPixel, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
    }
    else
    {
        sectionLabel.frame = CGRectMake(14.0f + self.controllerSafeAreaInset.left, TGScreenPixel, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
    }
    
    TGModernButton *clearButton = (TGModernButton *)[sectionContainer viewWithTag:200];
    CGRect clearButtonFrame = clearButton.frame;
    clearButtonFrame.origin.x = sectionContainer.frame.size.width - clearButtonFrame.size.width - self.controllerSafeAreaInset.right;
    clearButton.frame = clearButtonFrame;
    clearButton.hidden = !clear;
    [clearButton setTitleColor:self.presentation.pallete.sectionHeaderTextColor];
    
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

- (void)clearRecentButtonPressed
{
    [TGGlobalMessageSearchSignals clearRecentResults];
    [_recentSearchResultsDisposable setDisposable:nil];

    NSMutableArray *updatedRecentSearchResultsSections = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in _recentSearchResultsSections) {
        NSArray *items = dict[@"items"];
        if (items.count == 1 && [items[0] isKindOfClass:[TGDialogListRecentPeers class]]) {
            [updatedRecentSearchResultsSections addObject:dict];
        }
    }
    
    _recentSearchResultsSections = updatedRecentSearchResultsSections;
    _searchResultsSections = _recentSearchResultsSections;
    
    [_searchMixin reloadSearchResults];
}

- (void)updateSearchConversations:(NSArray *)conversations
{
    if (_searchResultsSections.count != 0)
    {
        NSMutableDictionary *updatedConversations = [[NSMutableDictionary alloc] init];
        for (TGConversation *conversation in conversations)
        {
            updatedConversations[@(conversation.conversationId)] = conversation;
        }
        
        NSMutableArray *updatedSearchResultsSections = [[NSMutableArray alloc] initWithArray:_searchResultsSections];
        NSInteger index = -1;
        for (NSDictionary *section in _searchResultsSections)
        {
            index++;
            
            NSInteger itemIndex = -1;
            NSMutableArray *updatedItems = nil;
            for (id item in section[@"items"])
            {
                itemIndex++;
                
                if ([item isKindOfClass:[TGConversation class]])
                {
                    TGConversation *conversation = item;
                    if (conversation.additionalProperties[@"searchMessageId"] == nil) {
                        TGConversation *updatedConversation = updatedConversations[@(conversation.conversationId)];
                        if (updatedConversation != nil)
                        {
                            if (updatedItems == nil)
                                updatedItems = [[NSMutableArray alloc] initWithArray:section[@"items"]];
                            
                            [updatedItems replaceObjectAtIndex:itemIndex withObject:updatedConversation];
                        }
                    }
                }
            }
            
            if (updatedItems != nil)
            {
                NSMutableDictionary *updatedSection = [[NSMutableDictionary alloc] initWithDictionary:section];
                updatedSection[@"items"] = updatedItems;
                updatedSearchResultsSections[index] = updatedSection;
            }
        }
        _searchResultsSections = updatedSearchResultsSections;
        
        for (id cell in _searchMixin.searchResultsTableView.visibleCells)
        {
            if ([cell isKindOfClass:[TGDialogListSearchCell class]])
            {
                TGDialogListSearchCell *searchCell = cell;
                TGConversation *updatedConversation = updatedConversations[@(searchCell.conversationId)];
                if (updatedConversation != nil)
                {
                    searchCell.unreadCount = updatedConversation.unreadCount;
                    [searchCell resetView:false];
                }
            }
            else if ([cell isKindOfClass:[TGDialogListRecentPeersCell class]])
            {
                NSMutableDictionary *unreadCounts = [[NSMutableDictionary alloc] init];
                for (NSNumber *conversationId in updatedConversations)
                {
                    unreadCounts[conversationId] = @([updatedConversations[conversationId] unreadCount]);
                }
                
                [(TGDialogListRecentPeersCell *)cell updateUnreadCounts:unreadCounts];
            }
        }
    }
}

- (void)check3DTouch {
    if (_checked3dTouch) {
        return;
    }
    _checked3dTouch = true;
    if (iosMajorVersion() >= 9 && !_dialogListCompanion.forwardMode && !_dialogListCompanion.privacyMode) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:(id)self sourceView:self.view];
        }
        else if (!TGIsPad())
        {
            __weak TGDialogListController *weakSelf = self;
            _custom3dTouchHandle = [TGPreviewMenu setupPreviewControllerForView:self.view configurator:^TGItemPreviewController *(CGPoint gestureLocation)
            {
                __strong TGDialogListController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return nil;
                
                UIViewController *conversationController = [strongSelf previewingContext:nil viewControllerForLocation:gestureLocation];
                if (conversationController == nil)
                    return nil;
                
                TGItemMenuSheetPreviewView *previewView = [[TGItemMenuSheetPreviewView alloc] initWithContext:[TGLegacyComponentsContext shared] frame:CGRectZero];
                
                NSArray *previewActions = [conversationController previewActionItems];
                NSMutableArray *actionItems = [[NSMutableArray alloc] init];
                
                __weak TGItemMenuSheetPreviewView *weakPreviewView = previewView;
                void (^dismissBlock)(void) = ^
                {
                    __strong TGItemMenuSheetPreviewView *strongPreviewView = weakPreviewView;
                    if (strongPreviewView != nil)
                        [strongPreviewView performCommit];
                };
                
                for (id action in previewActions)
                {
                    if ([action isKindOfClass:[UIPreviewAction class]])
                    {
                        UIPreviewAction *previewAction = (UIPreviewAction *)action;
                        TGMenuSheetButtonItemView *itemView = [[TGMenuSheetButtonItemView alloc] initWithTitle:previewAction.title type:TGMenuSheetButtonTypeDefault action:^
                        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
                            previewAction.handler(previewAction, nil);
#pragma clang diagnostic pop
                            dismissBlock();
                        }];
                        [actionItems addObject:itemView];
                    }
                }
                
                TGPreviewConversationItemView *itemView = [[TGPreviewConversationItemView alloc] initWithConversationController:conversationController];
                [previewView setupWithMainItemViews:@[itemView] actionItemViews:actionItems];
                
                TGItemPreviewController *controller = [[TGItemPreviewController alloc] initWithContext:[TGLegacyComponentsContext shared] parentController:strongSelf previewView:previewView];
                controller.sourcePointForItem = ^CGPoint(__unused id item)
                {
                    return CGPointZero;
                };
                
                return controller;
            }];
            _custom3dTouchHandle.shouldBegin = ^bool(CGPoint point) {
                __strong TGDialogListController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return false;
                
                if (strongSelf->_searchMixin.isActive)
                {
                    CGPoint tablePoint = [strongSelf.view convertPoint:point toView:strongSelf->_searchMixin.searchResultsTableView];
                    for (UITableViewCell *cell in strongSelf->_searchMixin.searchResultsTableView.visibleCells) {
                        if ([cell isKindOfClass:[TGDialogListRecentPeersCell class]] && CGRectContainsPoint([cell convertRect:[(TGDialogListRecentPeersCell *)cell bounds] toView:strongSelf->_searchMixin.searchResultsTableView], tablePoint))
                        {
                            return false;
                        }
                    }
                }
                
                return true;
            };
            _custom3dTouchHandle.requiredPressDuration = 0.3;
        }
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if (self.presentedViewController != nil) {
        return nil;
    }
    if (self.tableView.isEditing) {
        return nil;
    }
    
    if (_searchMixin.isActive) {
        CGPoint tablePoint = [self.view convertPoint:location toView:_searchMixin.searchResultsTableView];
        for (UITableViewCell *cell in _searchMixin.searchResultsTableView.visibleCells) {
            if ([cell isKindOfClass:[TGDialogListRecentPeersCell class]] && CGRectContainsPoint([cell convertRect:[(TGDialogListRecentPeersCell *)cell bounds] toView:_searchMixin.searchResultsTableView], tablePoint) && _custom3dTouchHandle == nil) {
                CGRect cellFrame = CGRectZero;
                int64_t peerId = [(TGDialogListRecentPeersCell *)cell peerAtPoint:[self.view convertPoint:location toView:cell] frame:&cellFrame];
                if (peerId != 0) {
                    CGRect sourceFrame = [self.view convertRect:cellFrame fromView:cell];
                    previewingContext.sourceRect = CGRectInset(sourceFrame, 0.0f, 2.0f);
                    
                    TGDispatchAfter(0.1, dispatch_get_main_queue(), ^
                    {
                        [TGPreviewPresentationHelper stylePreviewActionSheet];
                    });
                    
                    TGModernConversationController *controller = [[TGInterfaceManager instance] configuredPreviewConversationControlerWithId:peerId];
                    controller.onViewDidAppear = ^
                    {
                        [TGPreviewPresentationHelper stylePreviewActionSheet];
                    };
                    return controller;
                }
            }
            
            if ([cell isKindOfClass:[TGDialogListSearchCell class]] && CGRectContainsPoint([cell convertRect:[(TGDialogListSearchCell *)cell textContentFrame] toView:_searchMixin.searchResultsTableView], tablePoint)) {
                if (((TGDialogListSearchCell *)cell).isEncrypted) {
                    return nil;
                }
                
                previewingContext.sourceRect = [self.view convertRect:CGRectInset(cell.frame, 0.0f, 2.0f) fromView:_searchMixin.searchResultsTableView];
                
                TGDispatchAfter(0.1, dispatch_get_main_queue(), ^
                {
                    [TGPreviewPresentationHelper stylePreviewActionSheet];
                });
                
                TGModernConversationController *controller = [[TGInterfaceManager instance] configuredPreviewConversationControlerWithId:((TGDialogListSearchCell *)cell).conversationId];
                controller.onViewDidAppear = ^
                {
                    [TGPreviewPresentationHelper stylePreviewActionSheet];
                };
                return controller;
            }
        }
    } else {
        CGPoint tablePoint = [self.view convertPoint:location toView:_tableView];
        for (UITableViewCell *cell in _tableView.visibleCells) {
            if ([cell isKindOfClass:[TGDialogListCell class]] && CGRectContainsPoint([cell convertRect:[(TGDialogListCell *)cell textContentFrame] toView:_tableView], tablePoint)) {
                TGDialogListCell *dialogCell = (TGDialogListCell *)cell;
                if (dialogCell.isEncrypted)
                    return nil;
                
                previewingContext.sourceRect = [self.view convertRect:CGRectInset(cell.frame, 0.0f, 2.0f) fromView:_tableView];
                
                TGDispatchAfter(0.1, dispatch_get_main_queue(), ^
                {
                    [TGPreviewPresentationHelper stylePreviewActionSheet];
                });
                
                TGModernConversationController *controller = dialogCell.isFeed ? [[TGInterfaceManager instance] configuredPreviewFeedControllerWithId:TGAdminLogIdFromPeerId(dialogCell.conversationId)] : [[TGInterfaceManager instance] configuredPreviewConversationControlerWithId:dialogCell.conversationId];
                controller.onViewDidAppear = ^
                {
                    [TGPreviewPresentationHelper stylePreviewActionSheet];
                };
                return controller;
            }
        }
    }
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)__unused previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    if ([viewControllerToCommit isKindOfClass:[TGModernConversationController class]]) {
        TGModernConversationCompanion *companion = ((TGModernConversationController *)viewControllerToCommit).companion;
        
        if ([companion isKindOfClass:[TGFeedConversationCompanion class]]) {
            TGFeedConversationCompanion *feedCompanion = (TGFeedConversationCompanion *)(((TGModernConversationController *)viewControllerToCommit).companion);
            if (feedCompanion.conversationId != 0) {
                [[TGInterfaceManager instance] navigateToChannelsFeed:TGAdminLogIdFromPeerId(feedCompanion.conversationId) animated:true];
            }
        } else if ([companion isKindOfClass:[TGGenericModernConversationCompanion class]]) {
            TGGenericModernConversationCompanion *genericCompanion = (TGGenericModernConversationCompanion *)(((TGModernConversationController *)viewControllerToCommit).companion);
            if (genericCompanion.conversationId != 0) {
                [[TGInterfaceManager instance] navigateToConversationWithId:genericCompanion.conversationId conversation:nil performActions:nil atMessage:nil clearStack:![_dialogListCompanion feedChannels] openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
            }
        }
    }
}

- (void)_selectFirstConversation
{
    if (_listModel.count == 0)
        return;
    
    TGConversation *conversation = (TGConversation *)_listModel.firstObject;
    [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:conversation];
}

- (void)selectPreviousConversationUnread:(bool)unread
{
    if (_dialogListCompanion.openedConversationId == 0)
    {
        [self _selectFirstConversation];
        return;
    }
    
    TGConversation *previousConversation = nil;
    for (TGConversation *conversation in _listModel)
    {
        if ([_dialogListCompanion isConversationOpened:conversation.conversationId])
        {
            if (previousConversation != nil)
                [[TGInterfaceManager instance] navigateToConversationWithId:previousConversation.conversationId conversation:previousConversation];
            break;
        }
        
        if (!unread || (conversation.unreadCount + conversation.serviceUnreadCount) > 0)
            previousConversation = conversation;
    }
}

- (void)selectNextConversationUnread:(bool)unread
{
    if (_dialogListCompanion.openedConversationId == 0)
    {
        [self _selectFirstConversation];
        return;
    }
    
    bool jumpToNext = false;
    for (TGConversation *conversation in _listModel)
    {
        if (jumpToNext)
        {
            if (!unread || (conversation.unreadCount + conversation.serviceUnreadCount) > 0)
            {
                [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:conversation];
                break;
            }
        }
        else if ([_dialogListCompanion isConversationOpened:conversation.conversationId])
        {
            jumpToNext = true;
        }
    }
}

- (void)selectPreviousSearchItem
{
    if (_searchResultsSections.count == 0)
        return;
    
    UITableView *tableView = _searchMixin.searchResultsTableView;
    NSIndexPath *newIndexPath = tableView.indexPathForSelectedRow;
    
    if (_searchResultsSections == _recentSearchResultsSections)
    {
        NSArray *items = _recentSearchResultsSections.firstObject[@"items"];
        if (items.count == 0)
            return;
        
        if (newIndexPath == nil)
            newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        else if (newIndexPath.row > 0)
            newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row - 1 inSection:0];
    }
    else
    {
        if (newIndexPath == nil)
        {
            newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
        else if (newIndexPath.row > 0)
        {
            newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row - 1 inSection:newIndexPath.section];
        }
        else if (newIndexPath.section > 0)
        {
            if ([self tableView:tableView numberOfRowsInSection:newIndexPath.section - 1] > 0)
                newIndexPath = [NSIndexPath indexPathForRow:[self tableView:tableView numberOfRowsInSection:newIndexPath.section - 1] - 1 inSection:newIndexPath.section - 1];
        }
    }
    
    if (tableView.indexPathForSelectedRow != nil)
        [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:false];
    
    if (newIndexPath != nil)
        [tableView selectRowAtIndexPath:newIndexPath animated:false scrollPosition:UITableViewScrollPositionBottom];
}

- (void)selectNextSearchItem
{
    if (_searchResultsSections.count == 0)
        return;
    
    UITableView *tableView = _searchMixin.searchResultsTableView;
    NSIndexPath *newIndexPath = tableView.indexPathForSelectedRow;
    
    if (_searchResultsSections == _recentSearchResultsSections)
    {
        NSArray *items = _searchResultsSections.firstObject[@"items"];
        if (items.count == 0)
            return;
        
        if (newIndexPath == nil)
            newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        else if (newIndexPath.row < [self tableView:tableView numberOfRowsInSection:newIndexPath.section] - 1)
            newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:0];
    }
    else
    {
        if (newIndexPath == nil)
        {
            newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
        else if (newIndexPath.row < [self tableView:tableView numberOfRowsInSection:newIndexPath.section] - 1)
        {
            newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];
        }
        else if (newIndexPath.section < [self numberOfSectionsInTableView:tableView] - 1)
        {
            if ([self tableView:tableView numberOfRowsInSection:newIndexPath.section + 1] > 0)
                newIndexPath = [NSIndexPath indexPathForRow:0 inSection:newIndexPath.section + 1];
        }
    }
    
    if (tableView.indexPathForSelectedRow != nil)
        [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:false];
    
    if (newIndexPath != nil)
        [tableView selectRowAtIndexPath:newIndexPath animated:false scrollPosition:UITableViewScrollPositionBottom];
}

- (void)openSelectedSearchItem
{
    if (_searchResultsSections.count == 0)
        return;

    NSArray *items = _searchResultsSections.firstObject[@"items"];
    if (items.count == 0)
        return;
    
    NSIndexPath *selectedIndexPath = _searchMixin.searchResultsTableView.indexPathForSelectedRow;
    if (selectedIndexPath == nil)
        selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self tableView:_searchMixin.searchResultsTableView didSelectRowAtIndexPath:selectedIndexPath];
    
    [self.searchBar resignFirstResponder];
    [_searchMixin setIsActive:false animated:true];
}

- (void)processKeyCommand:(UIKeyCommand *)keyCommand
{
    if ([keyCommand.input isEqualToString:@"\r"])
    {
        [self openSelectedSearchItem];
    }
    else if ([keyCommand.input isEqualToString:UIKeyInputUpArrow])
    {
        if (keyCommand.modifierFlags != 0)
            [self selectPreviousConversationUnread:keyCommand.modifierFlags & UIKeyModifierShift];
        else
            [self selectPreviousSearchItem];
    }
    else if ([keyCommand.input isEqualToString:UIKeyInputDownArrow])
    {
        if (keyCommand.modifierFlags != 0)
            [self selectNextConversationUnread:keyCommand.modifierFlags & UIKeyModifierShift];
        else
            [self selectNextSearchItem];
    }
    else if ([keyCommand.input isEqualToString:@"N"])
    {
        [_dialogListCompanion composeMessageAndOpenSearch:true];
    }
    else if ([keyCommand.input isEqualToString:UIKeyInputEscape] || [keyCommand.input isEqualToString:@"\t"])
    {
        if (!self.searchBar.maybeCustomTextField.isFirstResponder)
        {
            [self.searchBar becomeFirstResponder];
        }
        else
        {
            [self.searchBar resignFirstResponder];
            [_searchMixin setIsActive:false animated:true];
        }
    }
}

- (NSArray *)availableKeyCommands
{
    NSMutableArray *keyCommands = [[NSMutableArray alloc] init];
    
    [keyCommands addObjectsFromArray:@
    [
     [TGKeyCommand keyCommandWithTitle:TGLocalized(@"KeyCommand.JumpToPreviousChat") input:UIKeyInputUpArrow modifierFlags:UIKeyModifierAlternate],
     [TGKeyCommand keyCommandWithTitle:TGLocalized(@"KeyCommand.JumpToNextChat")  input:UIKeyInputDownArrow modifierFlags:UIKeyModifierAlternate],
     [TGKeyCommand keyCommandWithTitle:TGLocalized(@"KeyCommand.JumpToPreviousUnreadChat") input:UIKeyInputUpArrow modifierFlags:UIKeyModifierAlternate | UIKeyModifierShift],
     [TGKeyCommand keyCommandWithTitle:TGLocalized(@"KeyCommand.JumpToNextUnreadChat")  input:UIKeyInputDownArrow modifierFlags:UIKeyModifierAlternate | UIKeyModifierShift],
     [TGKeyCommand keyCommandWithTitle:TGLocalized(@"KeyCommand.NewMessage") input:@"N" modifierFlags:UIKeyModifierCommand],
     [TGKeyCommand keyCommandWithTitle:nil input:UIKeyInputEscape modifierFlags:0],
     [TGKeyCommand keyCommandWithTitle:TGLocalized(@"KeyCommand.Find") input:@"\t" modifierFlags:0]
    ]];
    
    if (_searchBar.maybeCustomTextField.isFirstResponder)
    {
        [keyCommands addObject:[TGKeyCommand keyCommandWithTitle:nil input:@"\r" modifierFlags:0]];
        [keyCommands addObject:[TGKeyCommand keyCommandWithTitle:nil input:UIKeyInputUpArrow modifierFlags:0]];
        [keyCommands addObject:[TGKeyCommand keyCommandWithTitle:nil input:UIKeyInputDownArrow modifierFlags:0]];
    }
    
    return keyCommands;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView && indexPath.section == 1 && _editingMode) {
        __weak TGDialogListController *weakSelf = self;
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:TGLocalized(@"Common.Delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf performTableAction:action withIndexPath:indexPath];
            }
        }];
        action.backgroundColor = self.presentation.pallete.dialogEditDeleteColor;
        return @[action];
    } else if (tableView == _searchMixin.searchResultsTableView) {
        __weak TGDialogListController *weakSelf = self;
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:TGLocalized(@"Common.Delete") handler:^(__unused UITableViewRowAction *action, NSIndexPath *indexPath) {
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
            }
        }];
        action.backgroundColor = self.presentation.pallete.dialogEditDeleteColor;
        return @[action];
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)__unused tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return TGLocalized(@"Common.Delete");
}

- (void)performTableAction:(UITableViewRowAction *)action withIndexPath:(NSIndexPath *)indexPath {
    TGConversation *conversation = _listModel[indexPath.row];
    if ([action.title isEqualToString:TGLocalized(@"Common.Delete")]) {
        [self tableView:_tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    } else if ([action.title isEqualToString:TGLocalized(@"DialogList.Unpin")]) {
        if (conversation.pinnedToTop) {
            [[[TGGroupManagementSignals updatePinnedState:conversation.conversationId pinned:false] onDispose:^{
            }] startWithNext:nil];
            [self doneButtonPressed];
        }
    } else if ([action.title isEqualToString:TGLocalized(@"DialogList.Pin")]) {
        if (!conversation.pinnedToTop) {
            int32_t maxPinnedChats = 4;
            NSData *data = [TGDatabaseInstance() customProperty:@"maxPinnedChats"];
            if (data.length == 4) {
                [data getBytes:&maxPinnedChats length:4];
                maxPinnedChats = MAX(maxPinnedChats, 4);
            }
            NSInteger pinnedCount = 0;
            for (TGConversation *conversation in _listModel) {
                if (conversation.pinnedToTop) {
                    pinnedCount++;
                } else {
                    break;
                }
            }
            
            if (pinnedCount >= maxPinnedChats) {
                [TGCustomAlertView presentAlertWithTitle:nil message:[NSString stringWithFormat: TGLocalized(@"DialogList.PinLimitError"), [NSString stringWithFormat:@"%d", maxPinnedChats]] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                [self doneButtonPressed];
            } else {
                [[[TGGroupManagementSignals updatePinnedState:conversation.conversationId pinned:true] onDispose:^{
                }] startWithNext:nil];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        if (indexPath.section != 0) {
            TGConversation *conversation = _listModel[indexPath.row];
            return conversation.pinnedToTop;
        }
    }
    return false;
}

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex < toIndex) {
        //toIndex--;
    }
    
    id object = [_listModel objectAtIndex:fromIndex];
    [_listModel removeObjectAtIndex:fromIndex];
    [_listModel insertObject:object atIndex:toIndex];
}

- (void)tableView:(UITableView *)__unused tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self moveObjectAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    NSMutableArray *peerIds = [[NSMutableArray alloc] init];
    for (TGConversation *conversation in _listModel) {
        if (conversation.pinnedToTop) {
            [peerIds addObject:@(conversation.conversationId)];
        }
    }
    
    [_dialogListCompanion hintMoveConversationAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    [TGDatabaseInstance() transactionUpdatePinnedConversations:peerIds synchronizePinnedConversations:true forceReplacePinnedConversations:true];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateIsLastCell];
    });
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (tableView == _tableView) {
        if (sourceIndexPath.section == 1) {
            if (proposedDestinationIndexPath.section == 1) {
                NSInteger minIndex = 0;
                NSInteger maxIndex = -1;
                for (TGConversation *conversation in _listModel) {
                    if (conversation.isAd) {
                        minIndex++;
                        maxIndex++;
                    } else if (conversation.pinnedToTop) {
                        maxIndex++;
                    } else {
                        break;
                    }
                }
                
                if (proposedDestinationIndexPath.row >= minIndex && (NSInteger)proposedDestinationIndexPath.row <= maxIndex) {
                    return proposedDestinationIndexPath;
                } else {
                    return [NSIndexPath indexPathForRow:MAX(maxIndex, minIndex) inSection:1];
                }
                
                return sourceIndexPath;
            } else {
                if (proposedDestinationIndexPath.section < 1) {
                    return [NSIndexPath indexPathForRow:0 inSection:1];
                } else {
                    NSInteger minIndex = 0;
                    NSInteger maxIndex = -1;
                    for (TGConversation *conversation in _listModel) {
                        if (conversation.isAd) {
                            minIndex++;
                            maxIndex++;
                        } else if (conversation.pinnedToTop) {
                            maxIndex++;
                        } else {
                            break;
                        }
                    }
                    return [NSIndexPath indexPathForRow:MAX(maxIndex, minIndex) inSection:1];
                }
            }
        }
    }
    return sourceIndexPath;
}

- (void)displaySuggestedLocalization {
    if (_suggestedLocalization != nil && !_dialogListCompanion.privacyMode && !_dialogListCompanion.botStartMode && !_dialogListCompanion.forwardMode) {
        [TGDatabaseInstance() setCustomProperty:@"checkedLocalization" value:[_suggestedLocalization.info.code dataUsingEncoding:NSUTF8StringEncoding]];
        
        __weak TGDialogListController *weakSelf = self;
        TGSuggestedLocalizationController *controller = [[TGSuggestedLocalizationController alloc] initWithSuggestedLocalization:_suggestedLocalization];
        controller.other = ^{
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                TGLocalizationSelectionController *selection = [[TGLocalizationSelectionController alloc] init];
                selection.presentation = strongSelf.presentation;
                [TGAppDelegateInstance.rootController pushContentController:selection];
            }
        };
        controller.appliedLanguage = ^{
            __strong TGDialogListController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf displaySettingsTooltip:TGLocalized(@"DialogList.LanguageTooltip")];
            }
        };
        [TGAppDelegateInstance.window presentOverlayController:controller];
    }
}

- (void)displaySettingsTooltip:(NSString *)text {
    if (_recordTooltipContainerView == nil) {
        TGTooltipContainerView *tooltipContainerView = [[TGTooltipContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
        _recordTooltipContainerView = tooltipContainerView;
        _recordTooltipContainerView.tooltipView.numberOfLines = 0;
        [self.navigationController.view addSubview:_recordTooltipContainerView];
        
        [_recordTooltipContainerView.tooltipView setText:text animated:false];
        _recordTooltipContainerView.tooltipView.sourceView = [((TGMainTabsController *)self.parentViewController) viewForRightmostTab];
        
        CGRect recordButtonFrame = [[((TGMainTabsController *)self.parentViewController) viewForRightmostTab] convertRect:[((TGMainTabsController *)self.parentViewController) viewForRightmostTab].bounds toView:_recordTooltipContainerView];
        recordButtonFrame.origin.y += 15.0f;
        [_recordTooltipContainerView showTooltipFromRect:recordButtonFrame animated:false];
    
        __weak TGTooltipContainerView *weakContainerView = _recordTooltipContainerView;
        [[[SSignal complete] delay:5.0 onQueue:[SQueue mainQueue]] startWithNext:nil completed:^{
            __strong TGTooltipContainerView *strongContainerView = weakContainerView;
            if (strongContainerView != nil)
                [strongContainerView hideTooltip];
        }];
    }
}

- (void)displayProxyTooltip {
    NSString *text = TGLocalized(@"DialogList.ProxyConnectionIssuesTooltip");
    if (_recordTooltipContainerView == nil) {
        TGTooltipContainerView *tooltipContainerView = [[TGTooltipContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
        _recordTooltipContainerView = tooltipContainerView;
        _recordTooltipContainerView.tooltipView.numberOfLines = 0;
        _recordTooltipContainerView.tooltipView.forceArrowOnTop = true;
        [self.navigationController.view addSubview:_recordTooltipContainerView];
        
        [_recordTooltipContainerView.tooltipView setText:text animated:false];
        _recordTooltipContainerView.tooltipView.sourceView = _proxyButton;
        
        CGRect recordButtonFrame = [_proxyButton convertRect:_proxyButton.bounds toView:_recordTooltipContainerView];
        recordButtonFrame.origin.y += 30.0f;
        recordButtonFrame.origin.x += 9.0f;
        [_recordTooltipContainerView showTooltipFromRect:recordButtonFrame animated:false];
        
        __weak TGTooltipContainerView *weakContainerView = _recordTooltipContainerView;
        [[[SSignal complete] delay:7.0 onQueue:[SQueue mainQueue]] startWithNext:nil completed:^{
            __strong TGTooltipContainerView *strongContainerView = weakContainerView;
            if (strongContainerView != nil)
                [strongContainerView hideTooltip];
        }];
    }
}

- (void)createContactControllerDidFinish:(TGCreateContactController *)__unused createContactController
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)openProxySettings {
    TGProxySetupController *controller = [[TGProxySetupController alloc] initModal:true];
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)setCurrentTitlePanel:(TGModernConversationTitlePanel *)titlePanel
{
    _currentTitlePanel = titlePanel;
    if (!_searchMixin.isActive)
        [self setPrimaryTitlePanel:_currentTitlePanel fade:false];
}

- (void)setPrimaryTitlePanel:(TGModernConversationTitlePanel *)titlePanel fade:(bool)fade
{
    if (_primaryTitlePanel != titlePanel)
    {
        TGModernConversationTitlePanel *lastPanel = _primaryTitlePanel;
        [UIView animateWithDuration:0.09 delay:0.0 options:iosMajorVersion() < 7 ? 0 : (7 << 16) animations:^
        {
            lastPanel.frame = CGRectOffset(lastPanel.frame, 0.0f, -lastPanel.frame.size.height);
            
            if (titlePanel == nil)
            {
                [self setExplicitTableInset:UIEdgeInsetsZero];
                [self setExplicitScrollIndicatorInset:UIEdgeInsetsZero];
            }
            
            if (fade)
                lastPanel.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
            if (finished) {
                [lastPanel removeFromSuperview];
            }
        }];
    }
    
    _primaryTitlePanel = titlePanel;
    titlePanel.presentation = self.presentation;
    
    if (_primaryTitlePanel != nil && [self isViewLoaded])
    {
        if (_titlePanelWrappingView == nil)
        {
            _titlePanelWrappingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.controllerInset.top - self.explicitTableInset.top, self.view.frame.size.width, 44.0f)];
            _titlePanelWrappingView.clipsToBounds = true;
            
            [self.view addSubview:_titlePanelWrappingView];
        }
        
        _titlePanelWrappingView.userInteractionEnabled = true;
        
        CGRect titlePanelWrappingFrame = _titlePanelWrappingView.frame;
        titlePanelWrappingFrame.size.height = MAX(44.0f, _primaryTitlePanel.frame.size.height);
        _titlePanelWrappingView.frame = titlePanelWrappingFrame;
        
        [_titlePanelWrappingView addSubview:_primaryTitlePanel];
        
        CGRect titlePanelFrame = CGRectMake(0.0f, 0.0f, _titlePanelWrappingView.frame.size.width, _primaryTitlePanel.frame.size.height);
        
        [_primaryTitlePanel.layer removeAllAnimations];
        
        _primaryTitlePanel.frame = CGRectOffset(titlePanelFrame, 0.0f, -titlePanelFrame.size.height);
        [UIView animateWithDuration:0.09 delay:0.0 options:iosMajorVersion() < 7 ? 0 : (7 << 16) animations:^
        {
            _primaryTitlePanel.frame = titlePanelFrame;
            [self setExplicitTableInset:UIEdgeInsetsMake(titlePanel.frame.size.height, 0.0f, 0.0f, 0.0f)];
            [self setExplicitScrollIndicatorInset:UIEdgeInsetsMake(titlePanel.frame.size.height, 0.0f, 0.0f, 0.0f)];
            
            if (_primaryTitlePanel.alpha < FLT_EPSILON)
                _primaryTitlePanel.alpha = 1.0f;
        } completion:nil];
    }
    else
    {
        _titlePanelWrappingView.userInteractionEnabled = false;
    }
}

- (void)_performSizeChangesWithDuration:(NSTimeInterval)duration size:(CGSize)size
{
    CGSize collectionViewSize = size;
    
    if (_titlePanelWrappingView != nil)
    {
        CGRect titleWrapperFrame = CGRectMake(0.0f, self.controllerInset.top - _currentTitlePanel.frame.size.height, collectionViewSize.width, _titlePanelWrappingView.frame.size.height);
        CGRect titlePanelFrame = CGRectMake(0.0f, 0.0f, titleWrapperFrame.size.width, _currentTitlePanel.frame.size.height);
        if (duration > DBL_EPSILON)
        {
            [UIView animateWithDuration:duration animations:^
             {
                 _titlePanelWrappingView.frame = titleWrapperFrame;
                 _currentTitlePanel.frame = titlePanelFrame;
             }];
        }
        else
        {
            _titlePanelWrappingView.frame = titleWrapperFrame;
            _currentTitlePanel.frame = titlePanelFrame;
        }
    }
}

- (void)dimViewPressed
{
    
}

- (void)setDimmed:(bool)dimmed animated:(bool)animated keyboardSnapshot:(UIView *)keyboardSnapshot restoringFocus:(bool)restoringFocus
{
    if (dimmed)
    {
        if (_keyboardSnapshotView != nil)
        {
            [_keyboardSnapshotView removeFromSuperview];
            _keyboardSnapshotView = nil;
        }
        
        if (_dimView == nil)
        {
            _dimView = [[UIButton alloc] init];
            _dimView.alpha = 0.0f;
            _dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _dimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
            _dimView.frame = [self.navigationController.view bounds];
            [_dimView addTarget:self action:@selector(dimViewPressed) forControlEvents:UIControlEventTouchDown];
            
            [self.navigationController.view addSubview:_dimView];
        }
        else
        {
            [self.navigationController.view bringSubviewToFront:_dimView];
        }
        
        if (keyboardSnapshot != nil)
        {
            [TGAppDelegateInstance.rootController.mainTabsController setIgnoreKeyboardFrameChange:true restoringFocus:false];
            
            _keyboardSnapshotView = [keyboardSnapshot snapshotViewAfterScreenUpdates:false];
            _keyboardSnapshotView.frame = CGRectMake(0.0f, self.navigationController.view.frame.size.height - _keyboardSnapshotView.frame.size.height, _keyboardSnapshotView.frame.size.width, _keyboardSnapshotView.frame.size.height);
            [self.navigationController.view insertSubview:_keyboardSnapshotView belowSubview:_dimView];
        }
    }
    else
    {
        [TGAppDelegateInstance.rootController.mainTabsController setIgnoreKeyboardFrameChange:false restoringFocus:restoringFocus];
        
        if (!restoringFocus)
        {
            [UIView animateWithDuration:0.2 delay:0.0 options:7 << 16 animations:^
            {
                _keyboardSnapshotView.frame = CGRectOffset(_keyboardSnapshotView.frame, 0.0f, _keyboardSnapshotView.frame.size.height);
            } completion:nil];
        }
    }
    
    void (^changeBlock)(void) = ^
    {
        _dimView.alpha = dimmed ? 1.0f : 0.0f;
    };
    
    void (^completionBlock)(BOOL) = ^(__unused BOOL finished)
    {
        if (!dimmed && _keyboardSnapshotView != nil)
        {
            void (^block)(void) = ^
            {
                [_keyboardSnapshotView removeFromSuperview];
                _keyboardSnapshotView = nil;
            };
            
            TGDispatchAfter(0.45, dispatch_get_main_queue(), block);
        }
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.2f animations:changeBlock completion:completionBlock];
    }
    else
    {
        changeBlock();
        completionBlock(true);
    }
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    _needsUpdate = true;

    self.view.backgroundColor = _presentation.pallete.backgroundColor;
    _headerBackgroundView.backgroundColor = _presentation.pallete.backgroundColor;
    [self updateSearchBarBackground];
    
    [self updateProxyButton];
    _proxyButton.spinner = _presentation.images.dialogProxySpinner;
    
    _tableView.backgroundColor = _presentation.pallete.backgroundColor;
    
    [_searchBar setPallete:presentation.searchBarPallete];
    
    _titleLockIconView.presentation = self.presentation;
    _titleLabel.textColor = self.presentation.pallete.navigationTitleColor;
    _titleStatusLabel.textColor = _presentation.pallete.navigationTitleColor;
    _titleStatusSubtitleLabel.textColor = _presentation.pallete.navigationSubtitleColor;
    _titleStatusIndicator.color = _presentation.pallete.navigationSpinnerColor;
    
    for (UITableViewCell *cell in _tableView.visibleCells)
    {
        if ([cell isKindOfClass:[TGDialogListCell class]])
            [(TGDialogListCell *)cell setPresentation:presentation];
    }
    
    for (UITableViewCell *cell in _searchMixin.searchResultsTableView.visibleCells)
    {
        if ([cell isKindOfClass:[TGDialogListSearchCell class]])
            [(TGDialogListSearchCell *)cell setPresentation:presentation];
        else if ([cell isKindOfClass:[TGDialogListRecentPeersCell class]])
            [(TGDialogListRecentPeersCell *)cell setPresentation:presentation];
        else if ([cell isKindOfClass:[TGFlatActionCell class]])
            [(TGFlatActionCell *)cell setPresentation:presentation];
    }
    
    if (iosMajorVersion() >= 7)
        _tableView.separatorColor = _presentation.pallete.separatorColor;
    
    _primaryTitlePanel.presentation = self.presentation;
    
    [self updateBarButtonItemsAnimated:false];
}

- (void)updateProxyButton
{
    if (TGTelegraphInstance.clientUserId == 0)
        return;
    
    bool connecting = _state == TGDialogListStateConnecting;
    bool connectingToProxy = _state == TGDialogListStateConnectingToProxy || _state == TGDialogListStateHasProxyIssues;
    
    bool buttonHidden = true;
    bool spinning = false;
    
    UIImage *icon = self.presentation.images.dialogProxyConnectedIcon;
    if (connectingToProxy && _hasSelectedProxy)
    {
        buttonHidden = false;
        icon = self.presentation.images.dialogProxyShieldIcon;
        spinning = true;
    }
    else if (connecting && _hasAnyProxy)
    {
        buttonHidden = false;
        icon = self.presentation.images.dialogProxyConnectIcon;
    }
    else if (_state == TGDialogListStateNormal || _state == TGDialogListStateUpdating)
    {
        if (_alwaysShowProxy) {
            buttonHidden = !_hasAnyProxy;
            icon = _hasSelectedProxy ? self.presentation.images.dialogProxyConnectedIcon : self.presentation.images.dialogProxyConnectIcon;
        } else {
            buttonHidden = !_hasSelectedProxy;
        }
    }
    
    _proxyButton.hidden = buttonHidden;
    _proxyButton.icon = icon;
    
    [_proxyButton setSpinning:spinning];
}

@end
