#import "TGFeedConversationCompanion.h"

#import "TGDatabase.h"
#import "TGAppDelegate.h"
#import "TGTelegraph.h"

#import "TGDialogListItem.h"
#import "TGFeedDialogListCompanion.h"

#import "TGMessageModernConversationItem.h"

#import "TGModernConversationController.h"
#import "TGDialogListController.h"
#import "TGFeedNotificationsController.h"
#import "TGFeedGroupingController.h"

#import "TGModernViewContext.h"
#import "TGFeedConversationInputPanel.h"
#import "TGModernConversationGroupTitlePanel.h"

#import "TGAlertView.h"

#import "TGChannelManagementSignals.h"
#import "TGFeedManagementSignals.h"
#import "TGFeedPosition.h"

#import "TGPresentation.h"

@interface TGFeedConversationCompanion ()
{
    TGFeed *_feed;
    
    bool _enableVisibleMessagesProcessing;
    
    SMetaDisposable *_requestingHoleDisposable;
    
    TGVisibleMessageHole *_requestingHole;
    bool _loadingHistoryAbove;
    bool _loadingHistoryBelow;
    
    bool _historyAbove;
    bool _historyBelow;
    
    NSArray *_visibleHoles;
    
    TGFeedPosition *_latestReadPosition;
    
    TGFeedConversationInputPanel *_inputPanel;
}
@end

@implementation TGFeedConversationCompanion

- (instancetype)initWithFeed:(TGFeed *)feed
{
    self = [super initWithConversation:nil mayHaveUnreadMessages:false];
    if (self != nil)
    {
        _feed = feed;
        _conversationId = feed.conversationId;
        
        _initialMayHaveUnreadMessages = _feed.unreadCount != 0;
        
        _manualMessageManagement = true;
        _everyMessageNeedsAuthor = true;
    }
    return self;
}

- (void)dealloc {
    [_requestingHoleDisposable dispose];
}

- (TGModernConversationInputPanel *)_conversationGenericInputPanel {
    if (_inputPanel == nil) {
        TGModernConversationController *controller = self.controller;
        _inputPanel = [[TGFeedConversationInputPanel alloc] init];
        __weak TGFeedConversationCompanion *weakSelf = self;
        _inputPanel.sectionChanged = ^(NSInteger section)
        {
            __strong TGFeedConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setChannelsHidden:section == 0];
                [[NSUserDefaults standardUserDefaults] setObject:@(section == 1) forKey:[strongSelf initiallyDisplayChannelsPreferenceKey]];
            }
        };
        _inputPanel.delegate = controller;
    }
    return _inputPanel;
}

- (TGModernConversationInputPanel *)_conversationEmptyListInputPanel {
    return [self _conversationGenericInputPanel];
}

- (bool)canPostMessages {
    return false;
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options {
    if ([action isEqualToString:@"titlePanelAction"]) {
        NSString *panelAction = options[@"action"];
        
        if ([panelAction isEqualToString:@"notifications"]) {
            [self navigateToNotifications];
        } else if ([panelAction isEqualToString:@"grouping"]) {
            [self navigateToGrouping];
        } else if ([panelAction isEqualToString:@"info"]) {
            [self _controllerAvatarPressed];
        } else if ([panelAction isEqualToString:@"search"]) {
            [self navigateToMessageSearch];
        }
    }
    else if ([action isEqualToString:@"actionPanelAction"]) {
        NSString *panelAction = options[@"action"];
        if ([panelAction isEqualToString:@"showNext"]) {
            [self.controller showNext];
        }
    }
    
    [super actionStageActionRequested:action options:options];
}

- (NSString *)initiallyDisplayChannelsPreferenceKey {
    return [NSString stringWithFormat:@"TG_initiallyDisplayChanells_v1_%lld", _conversationId];
}

- (void)loadInitialState {
    [super loadInitialState:false];
    
    _latestReadPosition = _feed.maxReadPosition;
    
    TGModernConversationController *controller = self.controller;
    [controller setIsChannel:true];
    [controller setConversationHeader:[self _conversationHeader]];
    
    self.viewContext.isFeed = true;
    self.viewContext.commandsEnabled = false;
    
    self.useInitialSnapshot = false;
    [self _setTitle:TGLocalized(@"Feed.Title") andStatus:[self stringForChannelsCount:(int)_feed.channelIds.count] accentColored:false allowAnimatioon:false toggleMode:TGModernConversationControllerTitleToggleNone];
    [self _setAvatarConversationIds:_feed.chatIds titles:_feed.chatTitles];
    [self _setAvatarUrls:_feed.chatPhotosSmall];
    
    __block NSArray *topMessages = nil;
    __block TGFeedPosition *missingPreloadedAreaAtPosition = nil;
    __block int32_t messageIdForVisibleHoleDirection = 0;
    __block int32_t earliestUnreadMessageId = 0;
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^{
        __block TGMessageTransparentSortKey maxSortKey = TGMessageTransparentSortKeyUpperBound(_feed.conversationId);
        
        bool canBeUnread = _feed.unreadCount != 0 && _feed.maxReadPosition != nil;
        if (_preferredInitialPositionedMessageId != 0)  {
            [TGDatabaseInstance() feedMessageExists:_feed.fid peerId:_preferredInitialPositionedPeerId messageId:_preferredInitialPositionedMessageId completion:^(bool exists, TGMessageSortKey key) {
                if (exists) {
                    maxSortKey = TGMessageTransparentSortKeyMake(_feed.conversationId, TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                    if (_initialScrollState == nil || _initialScrollState.messageId == 0) {
                        [self setInitialMessagePositioning:TGMessageSortKeyMid(key) initialPositionedPeerId:_preferredInitialPositionedPeerId position:TGInitialScrollPositionCenter offset:0.0f];
                    }
                    messageIdForVisibleHoleDirection = TGMessageSortKeyMid(key);
                }
            }];
        } else if (canBeUnread) {
            if ([TGFeedManagementSignals _containsPreloadedHistoryForFeedId:_feed.fid aroundMessageId:_feed.maxReadPosition.mid peerId:_feed.maxReadPosition.peerId]) {
                [TGDatabaseInstance() nextFeedMessageKey:_feed.fid peerId:_feed.maxReadPosition.peerId messageId:_feed.maxReadPosition.mid timestamp:_feed.maxReadPosition.date completion:^(bool exists, TGMessageSortKey key, int64_t peerId) {
                    if (exists) {
                        maxSortKey = TGMessageTransparentSortKeyMake(_conversationId, TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                        [self setInitialMessagePositioning:TGMessageSortKeyMid(key) initialPositionedPeerId:peerId position:TGInitialScrollPositionTop offset:[self.controller initialUnreadOffset]];

                        TGMessageRange unreadRange = TGMessageRangeEmpty();

                        unreadRange.firstDate = TGMessageSortKeyTimestamp(key);
                        unreadRange.firstPeerId = peerId;
                        unreadRange.firstMessageId = TGMessageSortKeyMid(key);
                        unreadRange.lastPeerId = INT32_MAX;
                        unreadRange.lastMessageId = INT32_MAX;
                        unreadRange.lastDate = INT32_MAX;
                        
                        self.unreadMessageRange = unreadRange;

                        messageIdForVisibleHoleDirection = TGMessageSortKeyMid(key);
                    }
                }];
            } else {
                missingPreloadedAreaAtPosition = _feed.maxReadPosition;
            }
        }
        
        [TGDatabaseInstance() feedMessages:_feed.fid maxTransparentSortKey:maxSortKey count:35 mode:TGChannelHistoryRequestAround completion:^(NSArray *messages, bool hasLater) {
                topMessages = messages;
                _historyBelow = hasLater;
        }];
    } synchronous:true];
    
    _historyAbove = topMessages.count != 0;
    
    if (missingPreloadedAreaAtPosition == nil) {
        [self _replaceMessages:topMessages atMessageId:0 peerId:0 expandFrom:0 jump:false top:false messageIdForVisibleHoleDirection:messageIdForVisibleHoleDirection scrollBackMessageId:0 animated:false];
        if (earliestUnreadMessageId != 0) {
            [controller pushEarliestUnreadMessageId:earliestUnreadMessageId];
        }
    } else {
        self.useInitialSnapshot = false;
    }
    
    if (missingPreloadedAreaAtPosition != nil) {
        [controller setLoadingMessages:true];
        
        if (_requestingHoleDisposable == nil) {
            _requestingHoleDisposable = [[SMetaDisposable alloc] init];
        }
        
        __weak TGFeedConversationCompanion *weakSelf = self;
        [_requestingHoleDisposable setDisposable:[[TGFeedManagementSignals preloadedFeedId:_feed.fid aroundPosition:missingPreloadedAreaAtPosition unread:false] startWithNext:^(NSDictionary *dict) {
            __strong TGFeedConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSArray *removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                [TGDatabaseInstance() addMessagesToFeed:strongSelf->_feed.fid messages:dict[@"messages"] deleteMessages:nil addedHoles:nil removedHoles:removedImportantHoles  keepUnreadCounters:false changedMessages:^(__unused NSArray *addedMessages, __unused NSArray *removedMessages, __unused NSDictionary *updatedMessages) {
                    __block TGMessageTransparentSortKey messageKey = TGMessageTransparentSortKeyUpperBound(strongSelf->_feed.conversationId);
                    [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                        [TGDatabaseInstance() feedMessageExists:strongSelf->_feed.fid peerId:missingPreloadedAreaAtPosition.peerId messageId:missingPreloadedAreaAtPosition.mid completion:^(bool exists, TGMessageSortKey key) {
                            if (exists) {
                                messageKey = TGMessageTransparentSortKeyMake(TGMessageSortKeyPeerId(key), TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                            }
                        }];
                    } synchronous:true];
                    
                    [TGModernConversationCompanion dispatchOnMessageQueue:^{
                        __strong TGFeedConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            TGDispatchOnMainThread(^{
                                TGMessageRange unreadRange = TGMessageRangeEmpty();
                                
                                unreadRange.firstPeerId = missingPreloadedAreaAtPosition.peerId;
                                unreadRange.firstDate = TGMessageTransparentSortKeyTimestamp(messageKey);
                                unreadRange.firstMessageId = TGMessageTransparentSortKeyMid(messageKey) + 1;
                                unreadRange.lastDate = INT32_MAX;
                                unreadRange.lastMessageId = INT32_MAX;
                                
                                self.unreadMessageRange = unreadRange;
                                
                                messageIdForVisibleHoleDirection = TGMessageTransparentSortKeyMid(messageKey) + 1;
                                
                                TGModernConversationController *controller = self.controller;
                                if (earliestUnreadMessageId != 0) {
                                    [controller pushEarliestUnreadMessageId:earliestUnreadMessageId];
                                }
                            });
                            
                            [strongSelf reloadVariantAtSortKey:messageKey jump:false top:true messageIdForVisibleHoleDirection:messageIdForVisibleHoleDirection animated:false];
                        }
                    }];
                }];
            }
        }]];
    }
}

- (void)navigateToMessageId:(int32_t)messageId peerId:(int64_t)peerId animated:(bool)animated {
    [self navigateToMessageId:messageId peerId:peerId animated:animated forceLoad:false];
}

- (void)navigateToMessageId:(int32_t)messageId peerId:(int64_t)peerId animated:(bool)animated forceLoad:(bool)forceLoad
{
    __weak TGFeedConversationCompanion *weakSelf = self;
    [TGModernConversationCompanion dispatchOnMessageQueue:^
     {
         NSMutableArray *updatedIndices = [[NSMutableArray alloc] init];
         NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
         
         bool found = false;
         for (NSUInteger i = 0; i < _items.count; i++)
         {
             TGMessageModernConversationItem *item = _items[i];
             
             if (item->_message.mid == messageId)
             {
                 found = true;
                 break;
             }
         }
         
         if (found && !forceLoad)
         {
             TGDispatchOnMainThread(^
             {
                 TGModernConversationController *controller = self.controller;
                 int index = -1;
                 for (NSNumber *nIndex in updatedIndices)
                 {
                     index++;
                     [controller updateItemAtIndex:[nIndex intValue] toItem:updatedItems[index] delayAvailability:false];
                 }
                 [controller scrollToMessage:messageId peerId:peerId sourceMessageId:0 animated:animated];
             });
         }
         else
         {
             [[TGFeedManagementSignals preloadedFeedId:_feed.fid aroundPosition:[[TGFeedPosition alloc] initWithDate:0 mid:messageId peerId:peerId] unread:false] startWithNext:^(NSDictionary *dict) {
                 NSArray *removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                 
                 __block TGMessageTransparentSortKey sortKey = TGMessageTransparentSortKeyUpperBound(_feed.conversationId);
                 __block bool keyExists = false;
                 
                 [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                     [TGDatabaseInstance() feedMessageExists:_feed.fid peerId:peerId messageId:messageId completion:^(bool exists, TGMessageSortKey key) {
                         if (exists) {
                             keyExists = true;
                             sortKey = TGMessageTransparentSortKeyMake(_feed.conversationId, TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                         }
                     }];
                 } synchronous:true];
                 
                 if (!keyExists) {
                     for (TGMessage *message in dict[@"messages"]) {
                         if (message.cid == peerId && message.mid == messageId) {
                             sortKey = message.transparentSortKey;
                             break;
                         }
                     }
                 }
                 
                 [TGDatabaseInstance() addMessagesToFeed:_feed.fid messages:dict[@"messages"] deleteMessages:nil addedHoles:nil removedHoles:removedImportantHoles keepUnreadCounters:false changedMessages:^(__unused NSArray *addedMessages, __unused NSArray *removedMessages, __unused NSDictionary *updatedMessages) {
                     [TGModernConversationCompanion dispatchOnMessageQueue:^{
                         __strong TGFeedConversationCompanion *strongSelf = weakSelf;
                         if (strongSelf != nil) {
                             [strongSelf reloadVariantAtSortKey:sortKey jump:true top:false messageIdForVisibleHoleDirection:TGMessageTransparentSortKeyMid(sortKey) animated:true];
                         }
                     }];
                 }];
             }];
         }
     }];
}

- (void)reloadVariantAtSortKey:(TGMessageTransparentSortKey)sortKey jump:(bool)jump top:(bool)top messageIdForVisibleHoleDirection:(int32_t)messageIdForVisibleHoleDirection animated:(bool)animated {
    [self reloadVariantAtSortKey:sortKey jump:jump top:top messageIdForVisibleHoleDirection:messageIdForVisibleHoleDirection atMessageIndex:nil animated:animated];
}

- (void)reloadVariantAtSortKey:(TGMessageTransparentSortKey)sortKey jump:(bool)jump top:(bool)top messageIdForVisibleHoleDirection:(int32_t)messageIdForVisibleHoleDirection atMessageIndex:(TGMessageIndex *)atMessageIndex animated:(bool)animated {
    
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
            
            [TGDatabaseInstance() feedMessages:_feed.fid maxTransparentSortKey:updatedSortKey count:60 mode:TGChannelHistoryRequestAround completion:^(NSArray *messages, bool hasLater) {
                [TGModernConversationCompanion dispatchOnMessageQueue:^{
                    _historyAbove = messages.count != 0;
                    _historyBelow = hasLater;
                    
                    int32_t atMessageId = 0;
                    int64_t atPeerId = 0;
                    if (atMessageIndex != nil) {
                        atMessageId = atMessageIndex.messageId;
                        atPeerId = atMessageIndex.peerId;
                    } else {
                        for (TGMessage *message in messages) {
                            if (TGMessageTransparentSortKeyCompare(message.transparentSortKey, updatedSortKey) <= 0) {
                                atMessageId = message.mid;
                                atPeerId = message.fromUid;
                                break;
                            }
                        }
                    }
                    
                    if (atMessageId != 0) {
                        TGLog(@"Reloading at %d", atMessageId);
                    }
                    
                    [self _replaceMessages:messages atMessageId:atMessageId peerId:atPeerId expandFrom:0 jump:jump top:top messageIdForVisibleHoleDirection:messageIdForVisibleHoleDirection scrollBackMessageId:0 animated:animated];
                    
                    [self _updateControllerHistoryRequestsFlags];
                    
                    TGDispatchOnMainThread(^{
                        TGModernConversationController *controller = self.controller;
                        [controller setLoadingMessages:false];
                    });
                }];
            }];
        } synchronous:false];
    }];
}

- (void)_controllerWillAppearAnimated:(bool)animated firstTime:(bool)firstTime {
    [super _controllerWillAppearAnimated:animated firstTime:firstTime];
    
    if (firstTime) {
        bool displayChannels = [[[NSUserDefaults standardUserDefaults] objectForKey:[self initiallyDisplayChannelsPreferenceKey]] boolValue];
        if (displayChannels) {
            [self setChannelsHidden:false];
            _inputPanel.selectedSection = 1;
        }
    }
}

- (void)_controllerDidAppear:(bool)firstTime {
    [super _controllerDidAppear:firstTime];
    
    if (firstTime) {
        _enableVisibleMessagesProcessing = true;
        
        TGMessage *maxMessage = [self.controller latestVisibleMessage];
        bool shouldRead = _feed.maxKnownMessageId == maxMessage.mid;
        if (shouldRead) {
            //[self updateLatestVisibleMessageIndex:[TGMessageIndex indexWithPeerId:maxMessage.cid messageId:maxMessage.mid] date:(int32_t)maxMessage.date force:true];
        }
        
//        if (_invalidatedPtsDisposable == nil) {
//            __weak TGChannelConversationCompanion *weakSelf = self;
//            _invalidatedPtsDisposable = [[TGDatabaseInstance() channelHistoryPtsForPeerId:_conversationId] startWithNext:^(NSNumber *nInvalidatedPts) {
//                [TGModernConversationCompanion dispatchOnMessageQueue:^{
//                    __strong TGChannelConversationCompanion *strongSelf = weakSelf;
//                    if (strongSelf != nil) {
//                        [strongSelf setInvalidatedPts:[nInvalidatedPts intValue]];
//                    }
//                }];
//            }];
//        }
        
        [TGModernConversationCompanion dispatchOnMessageQueue:^{
            [self _updateVisibleHoles];
        }];
    }
}

- (NSString *)stringForChannelsCount:(int)channelsCount
{
    return [effectiveLocalization() getPluralized:@"Conversation.StatusChannels" count:(int32_t)channelsCount];
}

- (bool)imageDownloadsShouldAutosavePhotos
{
    return (TGAppDelegateInstance.autoSavePhotosMode & TGAutoDownloadModeCellularChannels) != 0;
}

- (bool)shouldAutomaticallyDownloadPhotos
{
    return [TGAppDelegateInstance.autoDownloadPreferences shouldDownloadPhotoInChat:TGAutoDownloadChatChannel networkType:TGTelegraphInstance.networkTypeManager.networkType];
}

- (bool)shouldAutomaticallyDownloadVideos
{
    return [TGAppDelegateInstance.autoDownloadPreferences shouldDownloadVideoInChat:TGAutoDownloadChatChannel networkType:TGTelegraphInstance.networkTypeManager.networkType];
}

- (bool)shouldAutomaticallyDownloadDocuments
{
    return [TGAppDelegateInstance.autoDownloadPreferences shouldDownloadDocumentInChat:TGAutoDownloadChatChannel networkType:TGTelegraphInstance.networkTypeManager.networkType];
}

- (bool)shouldAutomaticallyDownloadAnimations
{
    return TGAppDelegateInstance.autoPlayAnimations;
}

- (bool)shouldAutomaticallyDownloadAudios
{
    return [TGAppDelegateInstance.autoDownloadPreferences shouldDownloadVoiceMessageInChat:TGAutoDownloadChatChannel networkType:TGTelegraphInstance.networkTypeManager.networkType];
}

- (bool)shouldAutomaticallyDownloadVideoMessages
{
    return [TGAppDelegateInstance.autoDownloadPreferences shouldDownloadVideoMessageInChat:TGAutoDownloadChatChannel networkType:TGTelegraphInstance.networkTypeManager.networkType];
}

- (NSString *)_sendMessagePathForMessageId:(int32_t)__unused mid {
    return nil;
}

- (NSString *)titleForConversation:(TGConversation *)conversation {
    return conversation.chatTitle;
}

- (void)subscribeToUpdates
{    
    [ActionStageInstance() watchForPaths:@
    [
     [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/feedMessages", _conversationId],
    ] watcher:self];
    
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
                TGMessageTransparentSortKey maxKey = TGMessageTransparentSortKeyUpperBound(_feed.conversationId);
                bool messagesFound = false;
                for (TGMessageModernConversationItem *item in _items) {
                    TGMessageTransparentSortKey itemKey = item->_message.transparentSortKey;
                    itemKey = TGMessageTransparentSortKeyMake(TGMessageTransparentSortKeyPeerId(itemKey), TGMessageTransparentSortKeyTimestamp(itemKey), TGMessageTransparentSortKeyMid(itemKey) - 1, TGMessageTransparentSortKeySpace(itemKey));
                    if (TGMessageTransparentSortKeyCompare(maxKey, itemKey) > 0) {
                        maxKey = itemKey;
                    }
                    messagesFound = true;
                }
                
                _loadingHistoryAbove = true;
                __weak TGFeedConversationCompanion *weakSelf = self;
                [TGDatabaseInstance() feedMessages:_feed.fid maxTransparentSortKey:maxKey count:count mode:TGChannelHistoryRequestEarlier completion:^(NSArray *messages, __unused bool hasLater) {
                    [TGModernConversationCompanion dispatchOnMessageQueue:^{
                        __strong TGFeedConversationCompanion *strongSelf = weakSelf;
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
                TGMessageTransparentSortKey minKey = TGMessageTransparentSortKeyLowerBound(_feed.conversationId);
                for (TGMessageModernConversationItem *item in _items) {
                    TGMessageTransparentSortKey itemKey = item->_message.transparentSortKey;
                    if (TGMessageTransparentSortKeyCompare(minKey, itemKey) < 0) {
                        minKey = itemKey;
                    }
                }
                
                _loadingHistoryBelow = true;
                __weak TGFeedConversationCompanion *weakSelf = self;
                [TGDatabaseInstance() feedMessages:_feed.fid maxTransparentSortKey:minKey count:count mode:TGChannelHistoryRequestLater completion:^(NSArray *messages, __unused bool hasLater) {
                    [TGModernConversationCompanion dispatchOnMessageQueue:^{
                        __strong TGFeedConversationCompanion *strongSelf = weakSelf;
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
    
    TGLog(@"request hole %d ... %d, %s", hole.hole.minId, hole.hole.maxId, hole.direction == TGVisibleMessageHoleDirectionEarlier ? "earlier" : "later");
    
    __weak TGFeedConversationCompanion *weakSelf = self;
    [_requestingHoleDisposable setDisposable:[[TGFeedManagementSignals feedMessageHoleForFeedId:_feed.fid hole:hole.hole direction:hole.direction == TGVisibleMessageHoleDirectionEarlier ? TGFeedHistoryHoleDirectionEarlier : TGFeedHistoryHoleDirectionLater] startWithNext:^(NSDictionary *dict) {
        __strong TGFeedConversationCompanion *strongSelf = weakSelf;
        NSArray *removedHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
        
        [TGDatabaseInstance() addMessagesToFeed:strongSelf->_feed.fid messages:dict[@"messages"] deleteMessages:nil addedHoles:nil removedHoles:removedHoles keepUnreadCounters:false changedMessages:^(NSArray *addedMessages, NSArray *removedMessages, NSDictionary *updatedMessages) {
            [TGModernConversationCompanion dispatchOnMessageQueue:^{
                __strong TGFeedConversationCompanion *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    
                    NSMutableArray *resultRemovedMessages = [[NSMutableArray alloc] init];
                    [resultRemovedMessages addObjectsFromArray:removedMessages];
                    
                    NSMutableArray *resultAddedMessages = [[NSMutableArray alloc] init];
                    [resultAddedMessages addObjectsFromArray:addedMessages];
                    
                    [strongSelf _addMessages:resultAddedMessages animated:false intent:hole.direction == TGVisibleMessageHoleDirectionEarlier ? TGModernConversationAddMessageIntentLoadMoreMessagesAbove : TGModernConversationAddMessageIntentLoadMoreMessagesBelow deletedMessages:resultRemovedMessages];
                    
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

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments {
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId]]) {
        TGFeed *feed = ((SGraphObjectNode *)resource).object;
        NSSet *previousChannelIds = _feed.channelIds;
        _feed = feed;

        NSMutableSet *ungroupedChannelIds = [previousChannelIds mutableCopy];
        [ungroupedChannelIds minusSet:feed.channelIds];
        
        if (ungroupedChannelIds.count > 0)
        {
            [TGModernConversationCompanion dispatchOnMessageQueue:^{
                NSMutableArray *messageIdsToRemove = [[NSMutableArray alloc] init];
                for (TGMessageModernConversationItem *item in _items)
                {
                    if ([ungroupedChannelIds containsObject:@(item->_message.fromUid)])
                        [messageIdsToRemove addObject:@(item->_message.mid)];
                }
                
                [self _deleteMessages:messageIdsToRemove animated:true];
            }];
        }
        
        TGDispatchOnMainThread(^{
            [self _setTitle:TGLocalized(@"Feed.Title") andStatus:[self stringForChannelsCount:(int)_feed.channelIds.count] accentColored:false allowAnimatioon:false toggleMode:TGModernConversationControllerTitleToggleNone];
            [self _setAvatarConversationIds:_feed.chatIds titles:_feed.chatTitles];
            [self _setAvatarUrls:_feed.chatPhotosSmall];
        });
    } else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/feedMessages", _conversationId]]) {
        [TGModernConversationCompanion dispatchOnMessageQueue:^{
            bool fromPoll = [(NSNumber *)resource[@"fromPoll"] boolValue];
            
            if (fromPoll) {
                TGMessage *maxMessage = [self.controller latestVisibleMessage];
                if (maxMessage != nil) {
                    TGFeedPosition *minPosition = ((TGFeedPosition *)resource[@"minPosition"]);
                    TGFeedPosition *maxPosition = ((TGFeedPosition *)resource[@"maxPosition"]);
                    
                    if (maxMessage.date >= minPosition.date && maxMessage.date <= maxPosition.date) {
                        NSMutableArray<TGMessageIndex *> *messagesToDelete = [[NSMutableArray alloc] init];
                        for (TGMessageModernConversationItem *item in _items)
                        {
                            if (item->_message.date < minPosition.date || item->_message.date > maxPosition.date || item->_message.hole != nil)
                                [messagesToDelete addObject:[TGMessageIndex indexWithPeerId:item->_message.fromUid messageId:item->_message.mid]];
                        }
                        [self _deleteMessages:messagesToDelete animated:true];
                        [super actionStageResourceDispatched:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messages", _conversationId] resource:[[SGraphObjectNode alloc] initWithObject:resource[@"added"]] arguments:@{@"treatIncomingAsUnread": @false}];
                    } else {
                        [[TGFeedManagementSignals preloadedFeedId:_feed.fid aroundPosition:[[TGFeedPosition alloc] initWithDate:(int32_t)maxMessage.date mid:maxMessage.mid peerId:maxMessage.fromUid] unread:false] startWithNext:^(NSDictionary *dict) {
                            NSArray *removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                            
                            __block TGMessageTransparentSortKey sortKey = TGMessageTransparentSortKeyUpperBound(_feed.conversationId);
                            __block bool keyExists = false;
                            
                            [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                                [TGDatabaseInstance() feedMessageExists:_feed.fid peerId:maxMessage.fromUid messageId:maxMessage.mid completion:^(bool exists, TGMessageSortKey key) {
                                    if (exists) {
                                        keyExists = true;
                                        sortKey = TGMessageTransparentSortKeyMake(_feed.conversationId, TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                                    }
                                }];
                            } synchronous:true];
                            
                            if (!keyExists) {
                                for (TGMessage *message in dict[@"messages"]) {
                                    if (message.fromUid == maxMessage.fromUid && message.mid == maxMessage.mid) {
                                        sortKey = message.transparentSortKey;
                                        break;
                                    }
                                }
                            }
                            
                            [TGDatabaseInstance() addMessagesToFeed:_feed.fid messages:dict[@"messages"] deleteMessages:nil addedHoles:nil removedHoles:removedImportantHoles keepUnreadCounters:false changedMessages:^(__unused NSArray *addedMessages, __unused NSArray *removedMessages, __unused NSDictionary *updatedMessages) {
                                [TGModernConversationCompanion dispatchOnMessageQueue:^{
                                    [self reloadVariantAtSortKey:sortKey jump:false top:false messageIdForVisibleHoleDirection:0 atMessageIndex:[TGMessageIndex indexWithPeerId:maxMessage.fromUid messageId:maxMessage.mid] animated:true];
                                }];
                            }];
                        }];
                    }
                }
                else
                {
                    [self _replaceMessages:resource[@"added"]];
                }
            } else {
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
    }
    
    [super actionStageResourceDispatched:path resource:resource arguments:arguments];
}

- (bool)allowReplies {
    return false;
}

- (bool)canDeleteMessage:(TGMessage *)__unused message {
    return false;
}

- (bool)canModerateMessage:(TGMessage *)__unused message {
    return false;
}

- (TGUser *)checkedMessageModerateUser {
    return nil;
}

- (bool)canPinMessage:(TGMessage *)__unused message {
    return false;
}

- (bool)isMessagePinned:(int32_t)__unused messageId {
    return false;
}

- (bool)canEditMessage:(TGMessage *)__unused message {
    return false;
}

- (bool)canDeleteMessages {
    return false;
}

- (bool)canDeleteAllMessages {
    return false;
}

- (int64_t)requestPeerId {
    return 0;
}

- (int64_t)requestAccessHash {
    return 0;
}

- (UIView *)_conversationHeader {
    return nil;
}

- (void)_performFastScrollDown:(bool)__unused becauseOfSendTextAction becauseOfNavigation:(bool)becauseOfNavigation {
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        [TGDatabaseInstance() feedMessages:_feed.fid maxTransparentSortKey:TGMessageTransparentSortKeyUpperBound(_feed.conversationId) count:50 mode:TGChannelHistoryRequestEarlier completion:^(NSArray *messages, bool hasLater) {
            
            _historyBelow = hasLater;
            
            NSMutableArray *sortedTopMessages = [[NSMutableArray alloc] initWithArray:messages];
            [sortedTopMessages sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
            {
                return message1.date > message2.date ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                _historyBelow = false;
                _historyAbove = true;
                
                [self _replaceMessagesWithFastScroll:sortedTopMessages intent:becauseOfNavigation ? TGModernConversationAddMessageIntentGeneric : (becauseOfSendTextAction ? TGModernConversationAddMessageIntentSendTextMessage : TGModernConversationAddMessageIntentSendOtherMessage) scrollToMessageId:0 peerId:0 scrollBackMessageId:0 animated:true];
            }];
        }];
    } synchronous:false];
}

- (bool)shouldFastScrollDown {
    return _historyBelow;
}

- (bool)canAddNewMessagesToTop {
    return !_historyBelow;
}

- (bool)canCreateLinksToMessages {
    return true;
}

- (void)setChannelsHidden:(bool)hidden
{
    TGModernConversationController *controller = self.controller;
    if (hidden)
    {
        [controller setSecondaryController:nil];
    }
    else
    {
        TGDialogListController *dialogsController = [[TGDialogListController alloc] initWithCompanion:[[TGFeedDialogListCompanion alloc] initWithFeed:_feed]];
        dialogsController.presentation = controller.presentation;
        [controller setSecondaryController:dialogsController];
    }
}

- (void)_controllerAvatarPressed
{
    [self navigateToGrouping];
    
//    TGModernConversationController *controller = self.controller;
//    TGDialogListController *dialogsController = [[TGDialogListController alloc] initWithCompanion:[[TGFeedDialogListCompanion alloc] initWithFeed:_feed]];
//    dialogsController.presentation = controller.presentation;
//
//    if (controller.currentSizeClass == UIUserInterfaceSizeClassCompact) {
//        [controller.navigationController pushViewController:dialogsController animated:true];
//    }
//    else
//    {
//        if (controller != nil)
//        {
//            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[dialogsController] navigationBarClass:[TGWhiteNavigationBar class]];
//            navigationController.presentationStyle = TGNavigationControllerPresentationStyleRootInPopover;
//            TGPopoverController *popoverController = [[TGPopoverController alloc] initWithContentViewController:navigationController];
//            navigationController.parentPopoverController = popoverController;
//            navigationController.detachFromPresentingControllerInCompactMode = true;
//            [popoverController setContentSize:CGSizeMake(320.0f, 528.0f)];
//
//            controller.associatedPopoverController = popoverController;
//            [popoverController presentPopoverFromBarButtonItem:controller.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
//        }
//    }
}

- (void)navigateToGrouping
{
    TGModernConversationController *controller = self.controller;
    TGFeedGroupingController *groupingController = [[TGFeedGroupingController alloc] initWithFeed:_feed];
    
    if (controller.currentSizeClass == UIUserInterfaceSizeClassCompact) {
        [controller.navigationController pushViewController:groupingController animated:true];
    }
    else
    {
        if (controller != nil)
        {
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[groupingController] navigationBarClass:[TGWhiteNavigationBar class]];
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleRootInPopover;
            TGPopoverController *popoverController = [[TGPopoverController alloc] initWithContentViewController:navigationController];
            navigationController.parentPopoverController = popoverController;
            navigationController.detachFromPresentingControllerInCompactMode = true;
            [popoverController setContentSize:CGSizeMake(320.0f, 528.0f)];
            
            controller.associatedPopoverController = popoverController;
            [popoverController presentPopoverFromBarButtonItem:controller.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
        }
    }
}

- (void)navigateToNotifications
{
    TGModernConversationController *controller = self.controller;
    TGFeedNotificationsController *notificationsController = [[TGFeedNotificationsController alloc] initWithFeed:_feed];
    
    if (controller.currentSizeClass == UIUserInterfaceSizeClassCompact) {
        [controller.navigationController pushViewController:notificationsController animated:true];
    }
    else
    {
        if (controller != nil)
        {
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[notificationsController] navigationBarClass:[TGWhiteNavigationBar class]];
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleRootInPopover;
            TGPopoverController *popoverController = [[TGPopoverController alloc] initWithContentViewController:navigationController];
            navigationController.parentPopoverController = popoverController;
            navigationController.detachFromPresentingControllerInCompactMode = true;
            [popoverController setContentSize:CGSizeMake(320.0f, 528.0f)];
            
            controller.associatedPopoverController = popoverController;
            [popoverController presentPopoverFromBarButtonItem:controller.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
        }
    }
}

- (void)navigateToMessageSearch {
    [self setChannelsHidden:true];
    [super navigateToMessageSearch];
}

- (TGModernGalleryController *)galleryControllerForAvatar
{
    return nil;
}

- (bool)allowMessageForwarding
{
    return true;
}

- (bool)allowMessageExternalSharing
{
    return true;
}

- (bool)messageSearchByDateAvailable
{
    return false;
}

- (void)_createOrUpdatePrimaryTitlePanel:(bool)__unused createIfNeeded
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
    [actions addObject:@{@"title": TGLocalized(@"Conversation.Search"), @"icon": self.controller.presentation.images.chatTitleSearchIcon, @"action": @"search"}];
    [actions addObject:@{@"title": TGLocalized(@"Feed.Notifications"), @"icon": self.controller.presentation.images.chatTitleUnmuteIcon, @"action": @"notifications"}];
    [actions addObject:@{@"title": TGLocalized(@"Feed.Grouping"), @"icon": self.controller.presentation.images.chatTitleGroupIcon, @"action": @"grouping"}];
    [groupTitlePanel setButtonsWithTitlesAndActions:actions];
    
    [controller setPrimaryTitlePanel:groupTitlePanel];
}

- (void)_loadControllerPrimaryTitlePanel {
    [self _createOrUpdatePrimaryTitlePanel:true];
}

- (bool)skipServiceMessages {
    return true;
}

- (void)controllerCanRegroupUnreadIncomingMessages {
}

- (void)scheduleReadHistory {
    
}

- (bool)supportsSequentialRead {
    return true;
}

- (void)maybeScheduleSequentialRead {
//    if (self.previewMode)
//        return;
//
//    if (!_enableVisibleMessagesProcessing)
//        return;
//
//    TGDispatchOnMainThread(^
//    {
//        TGModernConversationController *controller = self.controller;
//        TGMessageIndex *latestVisibleMessageIndex = _latestVisibleMessageIndex;
//        int32_t latestVisibleMessageDate = _latestVisibleMessageDate;
//
//        if ([controller canReadHistory])
//        {
//            [TGModernConversationCompanion dispatchOnMessageQueue:^
//            {
//                if (latestVisibleMessageDate <= _latestReadPosition.date && !(latestVisibleMessageDate == _latestReadPosition.date && _feed.unreadCount > 0))
//                    return;
//
//                bool started = false;
//                int32_t count = 0;
//                for (TGMessageModernConversationItem *item in _items) {
//                    if (item->_message.fromUid == latestVisibleMessageIndex.peerId && item->_message.mid == latestVisibleMessageIndex.messageId) {
//                        started = true;
//                    }
//
//                    if ((item->_message.fromUid == _latestReadPosition.peerId && item->_message.mid == _latestReadPosition.mid) || item->_message.date < _latestVisibleMessageDate) {
//                        break;
//                    }
//
//                    if (started)
//                        count++;
//                }
//
//                _latestReadPosition = [[TGFeedPosition alloc] initWithDate:_latestVisibleMessageDate mid:latestVisibleMessageIndex.messageId peerId:latestVisibleMessageIndex.peerId];
//                [TGDatabaseInstance() transactionReadHistoryForPeerIds:@[[[TGReadPeerMessagesRequest alloc] initWithPeerId:_conversationId maxMessageIndex:[TGMessageIndex indexWithPeerId:latestVisibleMessageIndex.peerId messageId:latestVisibleMessageIndex.messageId] date:latestVisibleMessageDate length:count]]];
//            }];
//        }
//    });
}

@end
