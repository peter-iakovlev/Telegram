#import "TGChannelConversationCompanion.h"

#import "TGAppDelegate.h"
#import "ActionStage.h"
#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGAppDelegate.h"
#import "TGDialogListCompanion.h"

#import "TGChannelManagementSignals.h"
#import "TGChannelStateSignals.h"

#import "TGModernConversationController.h"
#import "TGMessageModernConversationItem.h"

#import "TGModernConversationGroupTitlePanel.h"
#import "TGUpdateStateRequestBuilder.h"

#import "TGChannelInfoController.h"
#import "TGNavigationController.h"
#import "TGPopoverController.h"
#import "TGNavigationBar.h"

#import "TGModernViewContext.h"

#import "TGModernConversationActionInputPanel.h"

#import "TGTelegramNetworking.h"

#import "TGStringUtils.h"

#import "TGAlertView.h"

#import <libkern/OSAtomic.h>

@interface TGChannelConversationCompanion () {
    TGConversation *_conversation;
    int32_t _displayVariant;
    int32_t _kind;
    TGChannelRole _role;
    bool _isReadOnly;
    bool _postAsChannel;
    bool _isMuted;
    bool _isForbidden;
    
    int32_t _memberCount;
    
    bool _enableVisibleMessagesProcessing;
    
    SMetaDisposable *_requestingHoleDisposable;
    SMetaDisposable *_managedState;
    SMetaDisposable *_extendedDataDisposable;
    SMetaDisposable *_cachedDataDisposable;
    
    TGVisibleMessageHole *_requestingHole;
    bool _loadingHistoryAbove;
    bool _loadingHistoryBelow;
    
    bool _historyAbove;
    bool _historyBelow;
    
    NSArray *_visibleHoles;
    
    TGModernConversationActionInputPanel *_joinChannelPanel; // Main Thread
    TGModernConversationActionInputPanel *_mutePanel; // Main Thread
    TGModernConversationActionInputPanel *_deletePanel; // Main Thread
    SMetaDisposable *_joinChannelDisposable;
    
    TGMessageGroup *_lastExpandedGroup;
}

@end

@implementation TGChannelConversationCompanion

- (instancetype)initWithPeerId:(int64_t)peerId conversation:(TGConversation *)conversation {
    self = [super initWithConversationId:peerId mayHaveUnreadMessages:false];
    if (self != nil) {
        _conversation = conversation;
        _accessHash = conversation.accessHash;
        _displayVariant = conversation.displayVariant;
        _kind = conversation.kind;
        _role = conversation.channelRole;
        _isReadOnly = conversation.channelIsReadOnly;
        _postAsChannel = conversation.postAsChannel && (conversation.channelRole == TGChannelRoleCreator || conversation.channelRole == TGChannelRolePublisher);
        if (_isReadOnly && (conversation.channelRole == TGChannelRoleCreator || conversation.channelRole == TGChannelRolePublisher)) {
            _postAsChannel = true;
        }
        _displayVariant = conversation.displayExpanded ? TGChannelDisplayVariantAll : TGChannelDisplayVariantImportant;
        _isForbidden = conversation.kickedFromChat;
        
        __weak TGChannelConversationCompanion *weakSelf = self;
        _cachedDataDisposable = [[[TGDatabaseInstance() channelCachedData:_conversationId] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedConversationData *data) {
            __strong TGChannelConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setMemberCount:data.memberCount];
            }
        }];
        
        _manualMessageManagement = true;
        _everyMessageNeedsAuthor = true;
    }
    return self;
}

- (void)dealloc {
    [_requestingHoleDisposable dispose];
    [_managedState dispose];
    [_extendedDataDisposable dispose];
}

- (void)setMemberCount:(int32_t)memberCount {
    if (_memberCount != memberCount) {
        _memberCount = memberCount;
        
        [self updateStatus];
    }
}

- (void)_controllerDidAppear:(bool)firstTime {
    [super _controllerDidAppear:firstTime];
    
    if (firstTime) {
        _managedState = [[TGChannelStateSignals updatedChannel:_conversationId] startWithNext:nil];
        
        _enableVisibleMessagesProcessing = true;
        [self _updateVisibleHoles];
        
        _extendedDataDisposable = [[TGChannelManagementSignals updateChannelExtendedInfo:_conversationId accessHash:_accessHash updateUnread:false] startWithNext:nil];
        
        if (_isForbidden) {
            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"ChannelInfo.ChannelForbidden") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        }
    }
}

- (void)_controllerAvatarPressed
{
    TGModernConversationController *controller = self.controller;
    if (controller.currentSizeClass == UIUserInterfaceSizeClassCompact) {
        TGChannelInfoController *groupInfoController = [[TGChannelInfoController alloc] initWithPeerId:_conversationId];
        
        [controller.navigationController pushViewController:groupInfoController animated:true];
    }
    else
    {
        if (controller != nil)
        {
            TGChannelInfoController *groupInfoController = [[TGChannelInfoController alloc] initWithPeerId:_conversationId];
            
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[groupInfoController] navigationBarClass:[TGWhiteNavigationBar class]];
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleRootInPopover;
            TGPopoverController *popoverController = [[TGPopoverController alloc] initWithContentViewController:navigationController];
            navigationController.parentPopoverController = popoverController;
            navigationController.detachFromPresentingControllerInCompactMode = true;
            [popoverController setContentSize:CGSizeMake(320.0f, 528.0f)];
            
            controller.associatedPopoverController = popoverController;
            [popoverController presentPopoverFromBarButtonItem:controller.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
            groupInfoController.collectionView.contentOffset = CGPointMake(0.0f, -groupInfoController.collectionView.contentInset.top);
        }
    }
}

- (void)_createOrUpdatePrimaryTitlePanel:(bool)__unused createIfNeeded
{
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        TGModernConversationController *controller = self.controller;
        
        TGModernConversationGroupTitlePanel *groupTitlePanel = nil;
        if ([[controller primaryTitlePanel] isKindOfClass:[TGModernConversationGroupTitlePanel class]])
            groupTitlePanel = (TGModernConversationGroupTitlePanel *)[controller primaryTitlePanel];
        else
        {
            if (createIfNeeded)
            {
                groupTitlePanel = [[TGModernConversationGroupTitlePanel alloc] init];
                groupTitlePanel.companionHandle = self.actionHandle;
            }
            else
                return;
        }
        
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        [actions addObject:@{@"title": @"Switch Mode", @"action": @"switchMode"}];
        [actions addObject:@{@"title": @"Copy Link", @"action": @"copyLink"}];
        
        [groupTitlePanel setButtonsWithTitlesAndActions:actions];
        
        [controller setPrimaryTitlePanel:groupTitlePanel];
    }*/
}

- (void)_loadControllerPrimaryTitlePanel {
    [self _createOrUpdatePrimaryTitlePanel:true];
}


- (TGModernConversationInputPanel *)_conversationGenericInputPanel {
    if (_isForbidden) {
        if (_deletePanel == nil) {
            TGModernConversationController *controller = self.controller;
            _deletePanel = [[TGModernConversationActionInputPanel alloc] init];
            [_deletePanel setActionWithTitle:TGLocalized(@"DialogList.DeleteConversationConfirmation") action:@"delete" color:TGAccentColor() icon:TGModernConversationActionInputPanelIconNone];
            _deletePanel.companionHandle = self.actionHandle;
            _deletePanel.delegate = controller;
        }
        return _deletePanel;
    } else if (_kind != TGConversationKindPersistentChannel)
    {
        if (_joinChannelPanel == nil)
        {
            TGModernConversationController *controller = self.controller;
            _joinChannelPanel = [[TGModernConversationActionInputPanel alloc] init];
            [_joinChannelPanel setActionWithTitle:TGLocalized(@"Channel.JoinChannel") action:@"joinchannel" color:TGAccentColor() icon:TGModernConversationActionInputPanelIconJoin];
            _joinChannelPanel.companionHandle = self.actionHandle;
            _joinChannelPanel.delegate = controller;
        }
        return _joinChannelPanel;
    } else if (![self canPostMessages]) {
        if (_mutePanel == nil) {
            TGModernConversationController *controller = self.controller;
            _mutePanel = [[TGModernConversationActionInputPanel alloc] init];
            [_mutePanel setActionWithTitle:!_isMuted ? TGLocalized(@"Conversation.Mute") : TGLocalized(@"Conversation.Unmute") action:@"toggleMute" color:TGAccentColor() icon:TGModernConversationActionInputPanelIconNone];
            _mutePanel.companionHandle = self.actionHandle;
            _mutePanel.delegate = controller;
        }
        return _mutePanel;
    }
    
    return nil;
}
               
- (bool)canPostMessages {
    return _role == TGChannelRoleCreator || _role == TGChannelRolePublisher;
}

- (void)_updateJoinPanel {
    TGModernConversationController *controller = self.controller;
    [controller setCustomInputPanel:[self _conversationGenericInputPanel]];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options {
    if ([action isEqualToString:@"titlePanelAction"]) {
        NSString *panelAction = options[@"action"];
        
        if ([panelAction isEqualToString:@"switchMode"]) {
            [self _toggleTitleMode];
        }
    } else if ([action isEqualToString:@"openMessageGroup"]) {
        TGModernConversationController *controller = self.controller;
        if ([controller isEditing]) {
            return;
        }
        
        TGMessageGroup *group = options[@"group"];
        _lastExpandedGroup = group;
        
        __weak TGChannelConversationCompanion *weakSelf = self;
        int64_t conversationId = _conversationId;
        
        TGMessageTransparentSortKey sortKey = TGMessageTransparentSortKeyMake(_conversationId, group.maxTimestamp, group.maxId, 0);
        
        [[TGChannelManagementSignals preloadedHistoryForPeerId:_conversationId accessHash:_accessHash aroundMessageId:group.minId] startWithNext:^(NSDictionary *dict) {
            NSArray *removedImportantHoles = nil;
            NSArray *removedUnimportantHoles = nil;
            
            removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
            removedUnimportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
            
            [TGDatabaseInstance() addMessagesToChannel:conversationId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:false changedMessages:^(__unused NSArray *addedMessages, __unused NSArray *removedMessages, __unused NSDictionary *updatedMessages, __unused NSArray *addedUnimportantHoles, __unused NSArray *removedUnimportantHoles) {
                [TGModernConversationCompanion dispatchOnMessageQueue:^{
                    __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        strongSelf->_displayVariant = TGChannelDisplayVariantAll;
                        [TGDatabaseInstance() updateChannelDisplayExpanded:strongSelf->_conversationId displayExpanded:true];
                        [strongSelf reloadVariantAtSortKey:sortKey group:group jump:false];
                    }
                }];
            }];
        }];
    } else if ([action isEqualToString:@"actionPanelAction"]) {
        NSString *panelAction = options[@"action"];
        if ([panelAction isEqualToString:@"joinchannel"]) {
            [self requestJoinChannel];
        } else if ([panelAction isEqualToString:@"toggleMute"]) {
            [self _commitEnableNotifications:_isMuted];
        } else if ([panelAction isEqualToString:@"delete"]) {
            TGModernConversationController *controller = self.controller;
            
            [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_conversationId unreadCount:0 serviceUnreadCount:0] animated:false];
            
            if (controller.popoverController != nil) {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [controller.popoverController dismissPopoverAnimated:true];
                });
            }
            else {
                [controller.navigationController popToRootViewControllerAnimated:true];
            }
        }
    }

    [super actionStageActionRequested:action options:options];
}

- (void)_commitEnableNotifications:(bool)enable
{
    _isMuted = !enable;
 
    [_mutePanel setActionWithTitle:!_isMuted ? TGLocalized(@"Conversation.Mute") : TGLocalized(@"Conversation.Unmute") action:@"toggleMute" color:TGAccentColor() icon:TGModernConversationActionInputPanelIconNone];
    
    int muteUntil = enable ? 0 : INT32_MAX;
    
    static int actionId = 0;
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(channelControllerMute%d)", _conversationId, actionId++] options:@{@"peerId": @(_conversationId), @"accessHash": @(_accessHash), @"muteUntil": @(muteUntil)} watcher:TGTelegraphInstance];
}

- (void)loadInitialState {
    [super loadInitialState:false];
    
    TGModernConversationController *controller = self.controller;
    [controller setIsChannel:true];
    
    if (_isReadOnly) {
        [controller setCanBroadcast:false];
        [controller setIsBroadcasting:false];
        [controller setIsAlwaysBroadcasting:_role == TGChannelRoleCreator || _role == TGChannelRolePublisher];
        [controller setInputDisabled:!(_role == TGChannelRoleCreator || _role == TGChannelRolePublisher)];
    } else {
        [controller setIsAlwaysBroadcasting:false];
        [controller setCanBroadcast:_role == TGChannelRoleCreator || _role == TGChannelRolePublisher];
        if (!(_role == TGChannelRoleCreator || _role == TGChannelRolePublisher)) {
            [controller setIsBroadcasting:false];
        } else {
            [controller setIsBroadcasting:_postAsChannel];
        }
        [controller setInputDisabled:false];
    }
    
    self.viewContext.conversation = _conversation;
    
    __block NSArray *topMessages = nil;
    [TGDatabaseInstance() dispatchOnDatabaseThread:^{
        __block TGMessageTransparentSortKey maxSortKey = TGMessageTransparentSortKeyUpperBound(_conversationId);
        
        if (_preferredInitialPositionedMessageId != 0) {
            [TGDatabaseInstance() channelMessageExists:_conversationId messageId:_preferredInitialPositionedMessageId completion:^(bool exists, TGMessageSortKey key) {
                if (exists) {
                    if (TGMessageSortKeySpace(key) == TGMessageSpaceUnimportant) {
                        _displayVariant = TGChannelDisplayVariantAll;
                    }
                    maxSortKey = TGMessageTransparentSortKeyMake(_conversationId, TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                    [self setInitialMessagePositioning:TGMessageSortKeyMid(key) position:TGInitialScrollPositionCenter];
                }
            }];
        } else if (_conversation.kind == TGConversationKindPersistentChannel && (_conversation.unreadCount != 0 || (_displayVariant == TGChannelDisplayVariantAll && _conversation.serviceUnreadCount != 0))) {
            [TGDatabaseInstance() channelMessageExists:_conversationId messageId:_conversation.maxReadMessageId + 1 completion:^(bool exists, TGMessageSortKey key) {
                if (exists) {
                    maxSortKey = TGMessageTransparentSortKeyMake(_conversationId, TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                    [self setInitialMessagePositioning:TGMessageSortKeyMid(key) position:TGInitialScrollPositionTop];
                    
                    TGMessageRange unreadRange = TGMessageRangeEmpty();
                    
                    unreadRange.firstDate = TGMessageSortKeyTimestamp(key);
                    unreadRange.lastDate = INT32_MAX;
                    unreadRange.firstMessageId = TGMessageSortKeyMid(key);
                    unreadRange.lastMessageId = INT32_MAX;
                    
                    self.unreadMessageRange = unreadRange;
                }
            }];
        }
        
        [TGDatabaseInstance() channelMessages:_conversationId maxTransparentSortKey:maxSortKey count:35 important:_displayVariant == TGChannelDisplayVariantImportant mode:TGChannelHistoryRequestAround completion:^(NSArray *messages, bool hasLater) {
            topMessages = messages;
            _historyBelow = hasLater;
        }];
    } synchronous:true];
    _historyAbove = topMessages.count != 0;
    
    [self _replaceMessages:topMessages];
    
    [self _setTitle:[self titleForConversation:_conversation] andStatus:TGLocalized(@"Channel.Status") accentColored:false allowAnimatioon:false toggleMode:[self currentToggleMode]];
    [self _setAvatarConversationId:_conversationId title:_conversation.chatTitle icon:nil];
    [self _setAvatarUrl:_conversation.chatPhotoSmall];
}

- (TGModernConversationControllerTitleToggle)currentToggleMode {
    if (_displayVariant == TGChannelDisplayVariantAll) {
        return TGModernConversationControllerTitleToggleHideDiscussion;
    } else if (!_isReadOnly) {
        return TGModernConversationControllerTitleToggleNone;
    } else {
        return TGModernConversationControllerTitleToggleNone;
    }
}

- (void)updateStatus {
    NSString *text = TGLocalized(@"Channel.Status");
    if (_memberCount != 0 && !_isForbidden) {
        text = [self stringForMemberCount:_memberCount];
    }
    [self _setStatus:text accentColored:false allowAnimation:false toggleMode:[self currentToggleMode]];
}

- (NSString *)stringForMemberCount:(int)memberCount
{
    if (memberCount == 1)
        return TGLocalizedStatic(@"Conversation.StatusMembers_1");
    else if (memberCount == 2)
        return TGLocalizedStatic(@"Conversation.StatusMembers_2");
    else if (memberCount >= 3 && memberCount <= 10)
        return [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.StatusMembers_3_10"), [TGStringUtils stringWithLocalizedNumber:memberCount]];
    else
        return [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.StatusMembers_any"), [TGStringUtils stringWithLocalizedNumber:memberCount]];
}

- (void)reloadVariantAtSortKey:(TGMessageTransparentSortKey)sortKey group:(TGMessageGroup *)group jump:(bool)jump {
    TGDispatchOnMainThread(^{
        [self updateStatus];
    });
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        _enableVisibleMessagesProcessing = true;
        _visibleHoles = nil;
        [_requestingHoleDisposable setDisposable:nil];
        _requestingHole = nil;
        _loadingHistoryAbove = false;
        _historyAbove = false;
        _loadingHistoryBelow = false;
        _historyBelow = false;
        
        [self _updateControllerHistoryRequestsFlags];
        
        [TGDatabaseInstance() dispatchOnDatabaseThread:^{
            __block TGMessageTransparentSortKey updatedSortKey = sortKey;
            
            if (group != nil) {
                [TGDatabaseInstance() channelEarlierMessage:_conversationId messageId:group.maxId timestamp:group.maxTimestamp important:true completion:^(bool exists, TGMessageSortKey key) {
                    if (exists) {
                        updatedSortKey = TGMessageTransparentSortKeyMake(_conversationId, TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                    }
                }];
            } else if (_displayVariant == TGChannelDisplayVariantImportant && TGMessageTransparentSortKeySpace(sortKey) == TGMessageSpaceUnimportant) {
                [TGDatabaseInstance() channelEarlierMessage:_conversationId messageId:TGMessageTransparentSortKeyMid(sortKey) timestamp:TGMessageTransparentSortKeyTimestamp(sortKey) important:true completion:^(bool exists, TGMessageSortKey key) {
                    if (exists) {
                        updatedSortKey = TGMessageTransparentSortKeyMake(_conversationId, TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                    }
                }];
            } else {
                
            }
            
            [TGDatabaseInstance() channelMessages:_conversationId maxTransparentSortKey:updatedSortKey count:60 important:_displayVariant == TGChannelDisplayVariantImportant mode:TGChannelHistoryRequestAround completion:^(NSArray *messages, bool hasLater) {
                [TGModernConversationCompanion dispatchOnMessageQueue:^{
                    _historyAbove = messages.count != 0;
                    _historyBelow = hasLater;
                    
                    int32_t atMessageId = 0;
                    for (TGMessage *message in messages) {
                        if (TGMessageTransparentSortKeyCompare(message.transparentSortKey, updatedSortKey) <= 0) {
                            atMessageId = message.mid;
                            break;
                        }
                    }
                    
                    if (atMessageId != 0) {
                        TGLog(@"Reloading at %d", atMessageId);
                    }
                    
                    [self _replaceMessages:messages atMessageId:atMessageId expandFrom:-group.maxId jump:jump];
                    
                    [self _updateControllerHistoryRequestsFlags];
                }];
            }];
        } synchronous:false];
    }];
}

- (bool)imageDownloadsShouldAutosavePhotos
{
    return TGAppDelegateInstance.autosavePhotos;
}

- (bool)shouldAutomaticallyDownloadPhotos
{
    return TGAppDelegateInstance.autoDownloadPhotosInGroups;
}

- (bool)shouldAutomaticallyDownloadAudios
{
    return TGAppDelegateInstance.autoDownloadAudioInGroups;
}

- (NSString *)_sendMessagePathForMessageId:(int32_t)mid {
    return [[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%@)/(%d)", [self _conversationIdPathComponent], mid];
}

- (NSString *)_sendMessagePathPrefix {
    return [[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%@)/", [self _conversationIdPathComponent]];
}

- (NSDictionary *)_optionsForMessageActions {
    bool postAsChannel = [self messageAuthorPeerId] == _conversationId;
    return @{@"conversationId": @(_conversationId), @"accessHash": @(_accessHash), @"asChannel": @(postAsChannel)};
}

- (void)_setupOutgoingMessage:(TGMessage *)message {
    [super _setupOutgoingMessage:message];
    
    if ((_role == TGChannelRoleCreator || _role == TGChannelRolePublisher) && _postAsChannel) {
        if (message.viewCount == nil) {
            message.viewCount = [[TGMessageViewCountContentProperty alloc] initWithViewCount:1];
        }
    }
}

- (void)subscribeToUpdates
{
    [ActionStageInstance() watchForPaths:@[
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/typing", _conversationId],
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId],
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/importantMessages", _conversationId],
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/unimportantMessages", _conversationId],
        [[NSString alloc] initWithFormat:@"/tg/peerSettings/(%" PRId64 ")", _conversationId]
    ] watcher:self];
    
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId64 ",cachedOnly)", _conversationId] options:@{@"peerId": @(_conversationId), @"accessHash": @(_accessHash)} watcher:self];

    [super subscribeToUpdates];
}

- (void)_controllerDidUpdateVisibleHoles:(NSArray *)holes {
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        _visibleHoles = holes;
        
        [self _updateVisibleHoles];
    }];
}

- (void)_updateVisibleHoles {
    if (_enableVisibleMessagesProcessing && _visibleHoles.count != 0 && _requestingHole == nil) {
        TGVisibleMessageHole *maxHole = _visibleHoles[0];
        
        [self _requestHole:maxHole];
    }
}

- (void)loadMoreMessagesAbove {
    int count = 100;
    
    TGModernConversationController *controller = self.controller;
    [controller setEnableAboveHistoryRequests:false];
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        if (!_loadingHistoryAbove) {
            if (_historyAbove) {
                TGMessageTransparentSortKey maxKey = TGMessageTransparentSortKeyUpperBound(_conversationId);
                for (TGMessageModernConversationItem *item in _items) {
                    TGMessageTransparentSortKey itemKey = item->_message.transparentSortKey;
                    itemKey = TGMessageTransparentSortKeyMake(TGMessageTransparentSortKeyPeerId(itemKey), TGMessageTransparentSortKeyTimestamp(itemKey), TGMessageTransparentSortKeyMid(itemKey) - 1, TGMessageTransparentSortKeySpace(itemKey));
                    if (TGMessageTransparentSortKeyCompare(maxKey, itemKey) > 0) {
                        maxKey = itemKey;
                    }
                }
                
                __weak TGChannelConversationCompanion *weakSelf = self;
                _loadingHistoryAbove = true;
                [TGDatabaseInstance() channelMessages:_conversationId maxTransparentSortKey:maxKey count:count important:_displayVariant == TGChannelDisplayVariantImportant mode:TGChannelHistoryRequestEarlier completion:^(NSArray *messages, __unused bool hasLater) {
                    [TGModernConversationCompanion dispatchOnMessageQueue:^{
                        __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            strongSelf->_loadingHistoryAbove = false;
                            if (messages.count == 0) {
                                strongSelf->_historyAbove = false;
                            } else {
                                strongSelf->_historyAbove = true;
                            }
                            if (messages.count != 0) {
                                [strongSelf _addMessages:messages animated:false intent:TGModernConversationAddMessageIntentLoadMoreMessagesAbove];
                            }
                            [strongSelf _updateControllerHistoryRequestsFlags];
                        }
                    }];
                }];
            }
        } else {
            [self _updateControllerHistoryRequestsFlags];
        }
    }];
}

- (void)loadMoreMessagesBelow {
    int count = 100;
#ifdef DEBUG
    count = 10;
#endif
    
    TGModernConversationController *controller = self.controller;
    [controller setEnableBelowHistoryRequests:false];
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        if (!_loadingHistoryBelow) {
            if (_historyBelow) {
                TGMessageTransparentSortKey minKey = TGMessageTransparentSortKeyLowerBound(_conversationId);
                for (TGMessageModernConversationItem *item in _items) {
                    TGMessageTransparentSortKey itemKey = item->_message.transparentSortKey;
                    if (TGMessageTransparentSortKeyCompare(minKey, itemKey) < 0) {
                        minKey = itemKey;
                    }
                }
                
                __weak TGChannelConversationCompanion *weakSelf = self;
                _loadingHistoryBelow = true;
                [TGDatabaseInstance() channelMessages:_conversationId maxTransparentSortKey:minKey count:count important:_displayVariant == TGChannelDisplayVariantImportant mode:TGChannelHistoryRequestLater completion:^(NSArray *messages, __unused bool hasLater) {
                    [TGModernConversationCompanion dispatchOnMessageQueue:^{
                        __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            strongSelf->_loadingHistoryBelow = false;
                            if (messages.count == 0) {
                                strongSelf->_historyBelow = false;
                            } else {
                                strongSelf->_historyBelow = true;
                            }
                            if (messages.count != 0) {
                                [strongSelf _addMessages:messages animated:false intent:TGModernConversationAddMessageIntentLoadMoreMessagesBelow];
                            }
                            [strongSelf _updateControllerHistoryRequestsFlags];
                        }
                    }];
                }];
            }
        } else {
            [self _updateControllerHistoryRequestsFlags];
        }
    }];
}

- (void)_requestHole:(TGVisibleMessageHole *)hole {
    _requestingHole = hole;
    if (_requestingHoleDisposable == nil) {
        _requestingHoleDisposable = [[SMetaDisposable alloc] init];
    }

    int64_t conversationId = _conversationId;
    int32_t displayVariant = _displayVariant;
    
    TGLog(@"request hole %d ... %d, %s", hole.hole.minId, hole.hole.maxId, hole.direction == TGVisibleMessageHoleDirectionEarlier ? "earlier" : "later");
    
    __weak TGChannelConversationCompanion *weakSelf = self;
    [_requestingHoleDisposable setDisposable:[[TGChannelManagementSignals channelMessageHoleForPeerId:_conversationId accessHash:_accessHash hole:hole.hole direction:hole.direction == TGVisibleMessageHoleDirectionEarlier ? TGChannelHistoryHoleDirectionEarlier : TGChannelHistoryHoleDirectionLater important:_displayVariant == TGChannelDisplayVariantImportant] startWithNext:^(NSDictionary *dict) {
        
        NSArray *removedImportantHoles = nil;
        NSArray *removedUnimportantHoles = nil;
        
        removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
        removedUnimportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
        
        [TGDatabaseInstance() addMessagesToChannel:conversationId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:displayVariant == TGChannelDisplayVariantImportant changedMessages:^(NSArray *addedMessages, NSArray *removedMessages, NSDictionary *updatedMessages, NSArray *addedUnimportantHoles, NSArray *removedUnimportantHoles) {
                [TGModernConversationCompanion dispatchOnMessageQueue:^{
                    __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        
                        NSMutableArray *resultRemovedMessages = [[NSMutableArray alloc] init];
                        [resultRemovedMessages addObjectsFromArray:removedMessages];
                        if (strongSelf->_displayVariant == TGChannelDisplayVariantAll) {
                            [resultRemovedMessages addObjectsFromArray:removedUnimportantHoles];
                        }
                        
                        NSMutableArray *resultAddedMessages = [[NSMutableArray alloc] init];
                        [resultAddedMessages addObjectsFromArray:addedMessages];
                        if (strongSelf->_displayVariant == TGChannelDisplayVariantAll) {
                            [resultAddedMessages addObjectsFromArray:addedUnimportantHoles];
                        }
                        
                        [strongSelf _addMessages:resultAddedMessages animated:false intent:hole.direction == TGVisibleMessageHoleDirectionEarlier ? TGModernConversationAddMessageIntentLoadMoreMessagesAbove : TGModernConversationAddMessageIntentLoadMoreMessagesBelow deletedMessageIds:resultRemovedMessages];
                        
                        [strongSelf _updateMessages:updatedMessages];
                        
                        strongSelf->_requestingHole = nil;
                        [strongSelf _updateControllerHistoryRequestsFlags];
                    }
                }];
            }];
    } error:^(__unused id error) {
        
    } completed:nil]];
}

- (void)_updateControllerHistoryRequestsFlags {
    NSAssert([TGModernConversationCompanion isMessageQueue], @"[TGModernConversationCompanion isMessageQueue]");
    
    bool enableAboveRequests = _historyAbove;
    if (_loadingHistoryAbove) {
        enableAboveRequests = false;
    }
    
    bool enableBelowRequests = _historyBelow;
    if (_loadingHistoryBelow) {
        enableBelowRequests = false;
    }
    
    TGDispatchOnMainThread(^{
        TGModernConversationController *controller = self.controller;
        [controller setEnableAboveHistoryRequests:enableAboveRequests];
        [controller setEnableBelowHistoryRequests:enableBelowRequests];
    });
}

- (NSString *)titleForConversation:(TGConversation *)conversation {
    return conversation.chatTitle;
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result {
    if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        if (status == ASStatusSuccess)
        {
            NSDictionary *notificationSettings = ((SGraphObjectNode *)result).object;
            
            TGDispatchOnMainThread(^{
                int muteUntil = [notificationSettings[@"muteUntil"] intValue];
                if (muteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime]) {
                    _isMuted = false;
                } else {
                    _isMuted = true;
                }
                
                [_mutePanel setActionWithTitle:!_isMuted ? TGLocalized(@"Conversation.Mute") : TGLocalized(@"Conversation.Unmute") action:@"toggleMute" color:TGAccentColor() icon:TGModernConversationActionInputPanelIconNone];
            });
        }
    }
    
    [super actorCompleted:status path:path result:result];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments {
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId]]) {
        TGConversation *conversation = ((SGraphObjectNode *)resource).object;
        _conversation = conversation;
        
        TGDispatchOnMainThread(^{
            bool importantFlagsUpdated = _role != conversation.channelRole || _isReadOnly != conversation.channelIsReadOnly || _kind != conversation.kind || _isForbidden != conversation.kickedFromChat;
            
            _kind = conversation.kind;
            _role = conversation.channelRole;
            _isReadOnly = conversation.channelIsReadOnly;
            
            if (_isForbidden != conversation.kickedFromChat && conversation.kickedFromChat) {
                [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"ChannelInfo.ChannelForbidden") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            }
            
            _isForbidden = conversation.kickedFromChat;
            
            TGModernConversationController *controller = self.controller;
            if (_isReadOnly) {
                [controller setCanBroadcast:false];
                [controller setIsBroadcasting:false];
                [controller setIsAlwaysBroadcasting:_role == TGChannelRoleCreator || _role == TGChannelRolePublisher];
                [controller setInputDisabled:!(_role == TGChannelRoleCreator || _role == TGChannelRolePublisher)];
            } else {
                [controller setIsAlwaysBroadcasting:false];
                [controller setCanBroadcast:_role == TGChannelRoleCreator || _role == TGChannelRolePublisher];
                if (!(_role == TGChannelRoleCreator || _role == TGChannelRolePublisher)) {
                    [controller setIsBroadcasting:false];
                } else {
                    [controller setIsBroadcasting:_postAsChannel];
                }
                [controller setInputDisabled:false];
            }
            
            if (importantFlagsUpdated) {
                [self _updateJoinPanel];
            }
            
            [self _setTitle:[self titleForConversation:conversation] andStatus:TGLocalized(@"Channel.Status") accentColored:false allowAnimatioon:false toggleMode:[self currentToggleMode]];
            [self updateStatus];
            [self _setAvatarConversationId:_conversationId title:conversation.chatTitle icon:nil];
            [self _setAvatarUrl:conversation.chatPhotoSmall];
        });
    } else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/importantMessages", _conversationId]]) {
        [TGModernConversationCompanion dispatchOnMessageQueue:^{
            if (_displayVariant == TGChannelDisplayVariantImportant) {
                if (((NSArray *)resource[@"removed"]).count != 0) {
                    [self _deleteMessages:resource[@"removed"] animated:true];
                }
                if (((NSArray *)resource[@"added"]).count != 0) {
                    [super actionStageResourceDispatched:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messages", _conversationId] resource:[[SGraphObjectNode alloc] initWithObject:resource[@"added"]] arguments:@{@"treatIncomingAsUnread": @true}];
                }
                if (((NSDictionary *)resource[@"updated"]).count != 0) {
                    [self _updateMessages:resource[@"updated"]];
                    __block bool hadGroups = false;
                    [(NSDictionary *)resource[@"updated"] enumerateKeysAndObjectsUsingBlock:^(__unused id key, TGMessage *message, BOOL *stop) {
                        if (message.group != nil) {
                            if (stop) {
                                hadGroups = true;
                                *stop = true;
                            }
                        }
                    }];
                    
                    if (hadGroups) {
                        [self scheduleReadHistory];
                    }
                }
            }
        }];
    } else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/unimportantMessages", _conversationId]]) {
        [TGModernConversationCompanion dispatchOnMessageQueue:^{
            if (_displayVariant == TGChannelDisplayVariantAll) {
                if (((NSArray *)resource[@"removed"]).count != 0) {
                    [self _deleteMessages:resource[@"removed"] animated:true];
                }
                if (((NSArray *)resource[@"added"]).count != 0) {
                    [super actionStageResourceDispatched:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messages", _conversationId] resource:[[SGraphObjectNode alloc] initWithObject:resource[@"added"]] arguments:@{@"treatIncomingAsUnread": @true}];
                }
                if (((NSDictionary *)resource[@"updated"]).count != 0) {
                    [self _updateMessages:resource[@"updated"]];
                }
            }
        }];
    } else if ([path hasPrefix:@"/tg/peerSettings/"]) {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    
    [super actionStageResourceDispatched:path resource:resource arguments:arguments];
}

- (void)requestJoinChannel {
    if (_joinChannelDisposable == nil) {
        _joinChannelDisposable = [[SMetaDisposable alloc] init];
    }
    
    [_joinChannelPanel setActivity:true];
    
    [_joinChannelDisposable setDisposable:[[TGChannelManagementSignals joinTemporaryChannel:_conversationId] startWithNext:nil]];
}

- (bool)allowReplies {
    return (_role == TGChannelRoleCreator || _role == TGChannelRolePublisher) || !_isReadOnly;
}

- (int64_t)messageAuthorPeerId {
    if (_isReadOnly) {
        return (_role == TGChannelRoleCreator || _role == TGChannelRolePublisher) ? _conversationId : TGTelegraphInstance.clientUserId;
    } else {
        return ((_role == TGChannelRoleCreator || _role == TGChannelRolePublisher) && _postAsChannel) ? _conversationId : TGTelegraphInstance.clientUserId;
    }
}

- (bool)canDeleteMessage:(TGMessage *)message {
    if (message.fromUid == _conversationId) {
        return (_role == TGChannelRoleCreator || _role == TGChannelRolePublisher);
    } else {
        if (message.outgoing || (_role == TGChannelRoleCreator || _role == TGChannelRolePublisher || _role == TGChannelRoleModerator)) {
            return true;
        }
    }
    return false;
}

- (bool)canDeleteMessages {
    return _role == TGChannelRoleCreator || _role == TGChannelRolePublisher || _role == TGChannelRoleModerator;
}

- (bool)canDeleteAllMessages {
    return false;
}

- (NSString *)_controllerInfoButtonText {
    return TGLocalized(@"Conversation.InfoChannel");
}

- (int64_t)requestPeerId {
    return _conversationId;
}

- (int64_t)requestAccessHash {
    return _accessHash;
}

- (void)_toggleBroadcastMode {
    if (_role == TGChannelRoleCreator || _role == TGChannelRolePublisher) {
        _postAsChannel = !_postAsChannel;
        [TGDatabaseInstance() updateChannelPostAsChannel:_conversationId postAsChannel:_postAsChannel];
        TGModernConversationController *controller = self.controller;
        [controller setIsBroadcasting:_postAsChannel];
    } else {
        _postAsChannel = false;
        TGModernConversationController *controller = self.controller;
        [controller setIsBroadcasting:_postAsChannel];
    }
}

- (void)_toggleTitleMode {
    TGMessageTransparentSortKey sortKey = TGMessageTransparentSortKeyUpperBound(_conversationId);
    TGModernConversationController *controller = self.controller;
    TGMessage *maxMessage = [controller latestVisibleMessage];
    if (maxMessage != nil) {
        sortKey = maxMessage.transparentSortKey;
    }
    
    if (_displayVariant == TGChannelDisplayVariantAll) {
        _displayVariant = TGChannelDisplayVariantImportant;
        [TGDatabaseInstance() updateChannelDisplayExpanded:_conversationId displayExpanded:false];
        
        if (_lastExpandedGroup != nil) {
            for (NSNumber *nMessageId in [controller visibleMessageIds]) {
                int32_t mid = [nMessageId intValue];
                if (mid >= _lastExpandedGroup.minId && mid <= _lastExpandedGroup.maxId) {
                    sortKey = TGMessageTransparentSortKeyMake(_conversationId, _lastExpandedGroup.maxTimestamp, _lastExpandedGroup.maxId, TGMessageSpaceUnimportant);
                }
            }
        }
    } else {
        _displayVariant = TGChannelDisplayVariantAll;
        [TGDatabaseInstance() updateChannelDisplayExpanded:_conversationId displayExpanded:true];
    }
    _lastExpandedGroup = nil;
    
    if (_displayVariant != _conversation.displayVariant && _displayVariant == TGChannelDisplayVariantImportant) {
        _conversation = [_conversation copy];
        _conversation.displayVariant = _displayVariant;
        [TGDatabaseInstance() updateChannelDisplayVariant:_conversationId displayVariant:_displayVariant];
    }
    
    [self reloadVariantAtSortKey:sortKey group:nil jump:false];
}

- (void)navigateToMessageId:(int32_t)messageId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated
{
    __weak TGChannelConversationCompanion *weakSelf = self;
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        bool found = false;
        for (TGMessageModernConversationItem *item in _items)
        {
            if (item->_message.mid == messageId)
            {
                found = true;
                break;
            }
        }
        
        int32_t sourceMid = scrollBackMessageId;
        
        if (found)
        {
            TGDispatchOnMainThread(^
            {
                TGModernConversationController *controller = self.controller;
                [controller scrollToMessage:messageId sourceMessageId:sourceMid animated:animated];
            });
        }
        else
        {
            int64_t conversationId = _conversationId;
            [[TGChannelManagementSignals preloadedHistoryForPeerId:_conversationId accessHash:_accessHash aroundMessageId:messageId] startWithNext:^(NSDictionary *dict) {
                NSArray *removedImportantHoles = nil;
                NSArray *removedUnimportantHoles = nil;
                
                removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                removedUnimportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                
                __block TGMessageTransparentSortKey sortKey = TGMessageTransparentSortKeyUpperBound(conversationId);
                __block bool keyExists = false;
                
                [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                    [TGDatabaseInstance() channelMessageExists:conversationId messageId:messageId completion:^(bool exists, TGMessageSortKey key) {
                        if (exists) {
                            keyExists = true;
                            sortKey = TGMessageTransparentSortKeyMake(conversationId, TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                        }
                    }];
                } synchronous:true];
                
                if (!keyExists) {
                    for (TGMessage *message in dict[@"messages"]) {
                        if (message.mid == messageId) {
                            sortKey = message.transparentSortKey;
                            
                            break;
                        }
                    }
                }
                
                [TGDatabaseInstance() addMessagesToChannel:conversationId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:false changedMessages:^(__unused NSArray *addedMessages, __unused NSArray *removedMessages, __unused NSDictionary *updatedMessages, __unused NSArray *addedUnimportantHoles, __unused NSArray *removedUnimportantHoles) {
                    [TGModernConversationCompanion dispatchOnMessageQueue:^{
                        __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            if (TGMessageTransparentSortKeySpace(sortKey) == TGMessageSpaceUnimportant && strongSelf->_displayVariant != TGChannelDisplayVariantAll) {
                                strongSelf->_displayVariant = TGChannelDisplayVariantAll;
                                [TGDatabaseInstance() updateChannelDisplayExpanded:strongSelf->_conversationId displayExpanded:true];
                            }
                            [strongSelf reloadVariantAtSortKey:sortKey group:nil jump:true];
                        }
                    }];
                }];
            }];
        }
    }];
}

@end
