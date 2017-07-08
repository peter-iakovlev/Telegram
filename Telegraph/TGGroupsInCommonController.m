#import "TGGroupsInCommonController.h"

#import "TGDatabase.h"
#import "TGUserSignal.h"

#import "TGConversationCollectionItem.h"
#import "TGInterfaceManager.h"

#import "TGPeerIdAdapter.h"
#import "TGChannelManagementSignals.h"
#import "TGGroupManagementSignals.h"
#import "TGModernConversationController.h"
#import "TGGenericModernConversationCompanion.h"

#import "TGProgressWindow.h"

static NSArray<TGConversation *> *sortedConversations(NSArray<TGConversation *> *conversations) {
    return conversations;
    /*return [conversations sortedArrayUsingComparator:^NSComparisonResult(TGConversation *lhs, TGConversation *rhs) {
        if (lhs.chatCreationDate > rhs.chatCreationDate) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];*/
}

@interface TGGroupsInCommonController () {
    id<SDisposable> _updatedGroupsInCommonDisposable;
    NSArray<TGConversation *> *_conversations;
    
    TGCollectionMenuSection *_conversationsSection;
    
    UIActivityIndicatorView *_activityIndicator;
    SMetaDisposable *_navigateDisposable;
    
    bool _checked3dTouch;
}

@end

@implementation TGGroupsInCommonController

- (instancetype)initWithUserId:(int32_t)userId {
    self = [super init];
    if (self != nil) {
        _navigateDisposable = [[SMetaDisposable alloc] init];
        
        self.title = TGLocalized(@"UserInfo.GroupsInCommon");
        
        _conversationsSection = [[TGCollectionMenuSection alloc] init];
        [self.menuSections addSection:_conversationsSection];
        
        NSArray *conversations = sortedConversations([TGDatabaseInstance() _userCachedDataSync:userId].groupsInCommon.groups);
        [self setConversations:conversations];
        
        __weak TGGroupsInCommonController *weakSelf = self;
        _updatedGroupsInCommonDisposable = [[[TGUserSignal groupsInCommon:userId] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedUserGroupsInCommon *result) {
            __strong TGGroupsInCommonController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSArray *sorted = sortedConversations(result.groups);
                if (![strongSelf->_conversations isEqual:sorted]) {
                    [strongSelf setConversations:sorted];
                }
            }
        }];
        
        UIEdgeInsets topSectionInsets = _conversationsSection.insets;
        topSectionInsets.top = 32.0f;
        _conversationsSection.insets = topSectionInsets;
    }
    return self;
}

- (void)dealloc {
    [_updatedGroupsInCommonDisposable dispose];
    [_navigateDisposable dispose];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_conversations == nil)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activityIndicator.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        self.collectionView.hidden = true;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self check3DTouch];
}

- (void)setConversations:(NSArray<TGConversation *> *)conversations {
    _conversations = conversations;
    
    if (conversations.count != 0) {
        [_activityIndicator removeFromSuperview];
        _activityIndicator = nil;
        self.collectionView.hidden = false;
    }
    
    while (_conversationsSection.items.count != 0) {
        [_conversationsSection deleteItemAtIndex:0];
    }
    
    __weak TGGroupsInCommonController *weakSelf = self;
    void (^itemSelected)(TGConversation *) = ^(TGConversation *conversation) {
        __strong TGGroupsInCommonController *strongSelf = weakSelf;
        if (strongSelf != nil && conversation.conversationId != 0) {
            [strongSelf navigateToPeerId:conversation.conversationId cachedConversation:conversation];
        }
    };
    for (TGConversation *conversation in conversations) {
        TGConversationCollectionItem *item = [[TGConversationCollectionItem alloc] initWithConversation:conversation];
        item.selected = itemSelected;
        [_conversationsSection addItem:item];
    }
    [self.collectionView reloadData];
}

- (SSignal *)preloadedConversationWithCachedConversation:(TGConversation *)conversation {
    if (TGPeerIdIsChannel(conversation.conversationId)) {
        return [[TGChannelManagementSignals addChannel:conversation] then:[TGChannelManagementSignals preloadedChannel:conversation.conversationId]];
    } else {
        return [TGGroupManagementSignals preloadedPeer:conversation.conversationId accessHash:conversation.accessHash];
    }
}

- (void)navigateToPeerId:(int64_t)peerId cachedConversation:(TGConversation *)cachedConversation {
    SSignal *signal = [[TGDatabaseInstance() modify:^id{
        if (TGPeerIdIsChannel(peerId)) {
            return [SSignal single:[TGDatabaseInstance() loadChannels:@[@(peerId)]][@(peerId)]];
        } else {
            return [SSignal single:[TGDatabaseInstance() loadConversationWithId:peerId]];
        }
    }] switchToLatest];
    __weak TGGroupsInCommonController *weakSelf = self;
    [_navigateDisposable setDisposable:[[signal deliverOn:[SQueue mainQueue]] startWithNext:^(TGConversation *conversation) {
        __strong TGGroupsInCommonController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (conversation != nil) {
                [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:nil];
            } else {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow showWithDelay:0.2];
                [strongSelf->_navigateDisposable setDisposable:[[[[strongSelf preloadedConversationWithCachedConversation:cachedConversation] deliverOn:[SQueue mainQueue]] onDispose:^{
                    TGDispatchOnMainThread(^{
                        [progressWindow dismiss:true];
                    });
                }] startWithNext:^(TGConversation *conversation) {
                    if (conversation != nil) {
                        [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:nil];
                    }
                }]];
            }
        }
    }]];
}

- (void)check3DTouch {
    if (_checked3dTouch) {
        return;
    }
    _checked3dTouch = true;
    if (iosMajorVersion() >= 9) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:(id)self sourceView:self.view];
        }
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    CGPoint tablePoint = [self.view convertPoint:location toView:self.collectionView];
    for (TGCollectionItemView *cell in self.collectionView.visibleCells) {
        if ([cell.boundItem isKindOfClass:[TGConversationCollectionItem class]] && CGRectContainsPoint([cell convertRect:cell.bounds toView:self.collectionView], tablePoint)) {
            TGConversationCollectionItem *item = (TGConversationCollectionItem *)cell.boundItem;
            
            previewingContext.sourceRect = [self.view convertRect:CGRectInset(cell.frame, 0.0f, 1.0f) fromView:self.collectionView];
            
            TGModernConversationController *controller = [[TGInterfaceManager instance] configuredPreviewConversationControlerWithId:item.conversation.conversationId];
            return controller;
        }
    }
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)__unused previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    if ([viewControllerToCommit isKindOfClass:[TGModernConversationController class]]) {
        TGGenericModernConversationCompanion *companion = (TGGenericModernConversationCompanion *)(((TGModernConversationController *)viewControllerToCommit).companion);
        if (companion != nil && companion.conversationId != 0) {
            [[TGInterfaceManager instance] navigateToConversationWithId:companion.conversationId conversation:nil];
        }
    }
}

@end
