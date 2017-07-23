#import "TGChannelConversationCompanion.h"

#import "ASCommon.h"
#import "TGCommon.h"

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
#import "TGChannelGroupInfoController.h"
#import "TGNavigationController.h"
#import "TGPopoverController.h"
#import "TGNavigationBar.h"

#import "TGModernViewContext.h"

#import "TGModernConversationActionInputPanel.h"

#import "TGTelegramNetworking.h"

#import "TGStringUtils.h"
#import "TGImageUtils.h"

#import "TGAlertView.h"

#import "TGModernConversationTitleIcon.h"

#import "TGModernConversationTitleView.h"

#import <libkern/OSAtomic.h>

#import "TGMigratedChannelConversationHeaderView.h"

#import "TGGroupedUserOnlineSignals.h"

#import "TGDownloadMessagesSignal.h"

#import "TGPinnedMessageTitlePanel.h"

#import "TGProgressWindow.h"

#import "TGAccountSignals.h"

#import "TGModernConversationContactLinkTitlePanel.h"
#import "TGModernConversationRestrictedInputPanel.h"

#import "TGServiceSignals.h"
#import "TGRecentContextBotsSignal.h"
#import "TGActionSheet.h"

#import "TGReportPeerOtherTextController.h"

#import "TGModernGalleryController.h"
#import "TGGroupAvatarGalleryModel.h"

#import "TGGroupManagementSignals.h"

#import "TGLocalization.h"

#import "TGChannelBanController.h"

@interface TGChannelConversationCompanion () <TGModernConversationContactLinkTitlePanelDelegate> {
    NSDictionary *_initialUserActivities;
    
    TGConversation *_conversation;
    int32_t _displayVariant;
    int32_t _kind;
    bool _isCreator;
    TGChannelAdminRights *_adminRights;
    TGChannelBannedRights *_bannedRights;
    bool _isGroup;
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
    TGModernConversationRestrictedInputPanel *_restrictedPanel; // Main Thread
    SMetaDisposable *_joinChannelDisposable;
    
    TGMessageGroup *_lastExpandedGroup;
    
    NSTimeInterval _lastTypingActivity;
    
    TGMigratedChannelConversationHeaderView *_migratedChannelHeaderView;
    
    TGConversationMigrationData *_migrationData;
    bool _migrationHistoryAbove;
    
    bool _hasBots;
    
    SVariable *_pinnedMessage;
    int32_t _immediatePinnedMessage;
    
    int32_t _invalidatedPts;
    bool _needsToValidatePts;
    id<SDisposable> _invalidatedPtsDisposable;
    
    bool _updatingInvalidatedMessages;
    SMetaDisposable *_updatingInvalidatedMessagesDisposable;
    
    SDisposableSet *_genericInfoDisposables;
    bool _shouldNotifyMembers;
    
    bool _signaturesEnabled;
    
    SMetaDisposable *_groupedUserStatusesDisposable;
    
    TGGroupedUserOnlineInfo *_groupedOnlineInfo;

    id<SDisposable> _updatedPeerSettingsDisposable;
    
    TGModernConversationContactLinkTitlePanel *_reportSpamPanel;
    TGPinnedMessageTitlePanel *_pinnedMessagePanel;
    
    SVariable *_primaryPanel;
}

@end

@implementation TGChannelConversationCompanion

- (instancetype)initWithConversation:(TGConversation *)conversation userActivities:(NSDictionary *)userActivities {
    if (self != nil) {
        _primaryPanel = [[SVariable alloc] init];
        [_primaryPanel set:[SSignal single:nil]];
    }
    
    self = [super initWithConversation:conversation mayHaveUnreadMessages:false];
    if (self != nil) {
        _genericInfoDisposables = [[SDisposableSet alloc] init];
        
        _conversation = conversation;
        
        _accessHash = conversation.accessHash;
        _isGroup = conversation.isChannelGroup;
        _displayVariant = conversation.displayVariant;
        _kind = conversation.kind;
        _isCreator = conversation.channelRole == TGChannelRoleCreator;
        _adminRights = conversation.channelAdminRights;
        _bannedRights = conversation.channelBannedRights;
        if (!_isGroup) {
            _displayVariant = TGChannelDisplayVariantImportant;
        } else {
            _displayVariant = TGChannelDisplayVariantAll;
        }
        
        _isForbidden = conversation.kickedFromChat;
        _signaturesEnabled = conversation.signaturesEnabled;
        
        __weak TGChannelConversationCompanion *weakSelf = self;
        _cachedDataDisposable = [[[TGDatabaseInstance() channelCachedData:_conversationId] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedConversationData *data) {
            __strong TGChannelConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setMemberCount:data.memberCount];
                [strongSelf setMigrationData:data.migrationData];
                [strongSelf setHasBots:data.botInfos.count != 0];
            }
        }];
        
        _manualMessageManagement = true;
        _everyMessageNeedsAuthor = true;
        
        _initialUserActivities = userActivities;
        
        [_genericInfoDisposables add:[[[TGDatabaseInstance() channelShouldMuteMembers:_conversationId] deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *next) {
            __strong TGChannelConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_shouldNotifyMembers = ![next boolValue];
                if (!strongSelf->_isGroup && (strongSelf->_isCreator || strongSelf->_adminRights.canPostMessages)) {
                    TGModernConversationController *controller = strongSelf.controller;
                    [controller setCanBroadcast:true];
                    [controller setIsBroadcasting:strongSelf->_shouldNotifyMembers];
                    [controller setIsAlwaysBroadcasting:false];
                }
            }
        }]];
        
        if (_isGroup) {
            _groupedUserStatusesDisposable = [[SMetaDisposable alloc] init];
            
            int64_t conversationId = _conversationId;
            int64_t accessHash = _accessHash;
            
            SSignal *changedPrecondition = [[[TGDatabaseInstance() channelCachedData:conversationId] map:^id(TGCachedConversationData *cachedData) {
                return @(cachedData.memberCount != 0 && cachedData.memberCount <= 200);
            }] ignoreRepeated];
            
            
            SSignal *users = [changedPrecondition mapToSignal:^SSignal *(NSNumber *shouldCountOnlines) {
                if ([shouldCountOnlines boolValue]) {
                    SSignal *cachedUsers = [[[TGDatabaseInstance() channelCachedData:conversationId] map:^id (TGCachedConversationData *cachedData) {
                        NSMutableArray *users = [[NSMutableArray alloc] init];
                        for (TGCachedConversationMember *member in cachedData.generalMembers) {
                            TGUser *user = [TGDatabaseInstance() loadUser:member.uid];
                            if (user != nil) {
                                [users addObject:user];
                            }
                        }
                        return users;
                    }] take:1];
                    
                    return [cachedUsers then:[[TGChannelManagementSignals channelMembers:conversationId accessHash:accessHash offset:0 count:200] map:^id(NSDictionary *dict) {
                        [TGDatabaseInstance() updateChannelCachedData:conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                            if (data == nil) {
                                data = [[TGCachedConversationData alloc] init];
                            }
                            
                            NSMutableArray *sortedMemberDatas = [[NSMutableArray alloc] init];
                            NSDictionary *memberDatas = dict[@"memberDatas"];
                            for (TGUser *user in dict[@"users"]) {
                                TGCachedConversationMember *member = memberDatas[@(user.uid)];
                                if (member != nil) {
                                    [sortedMemberDatas addObject:member];
                                }
                            }
                            
                            return [data updateGeneralMembers:sortedMemberDatas];
                        }];
                        
                        return dict[@"users"];
                    }]];
                } else {
                    return [SSignal single:@[]];
                }
            }];
            
            SSignal *groupedInfo = [TGGroupedUserOnlineSignals groupedOnlineInfoForUserList:users];
            [_groupedUserStatusesDisposable setDisposable:[[groupedInfo deliverOn:[SQueue mainQueue]] startWithNext:^(TGGroupedUserOnlineInfo *groupedOnlineInfo) {
                __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_groupedOnlineInfo = groupedOnlineInfo;
                    [strongSelf updateStatus];
                }
            }]];
        }
        
        _pinnedMessage = [[SVariable alloc] init];
        int64_t conversationId = _conversationId;
        int64_t accessHash = _accessHash;
        
        _initialMayHaveUnreadMessages = _conversation.kind == TGConversationKindPersistentChannel && (_conversation.unreadCount != 0 || (_displayVariant == TGChannelDisplayVariantAll && _conversation.serviceUnreadCount != 0));
        
        SSignal *pinnedId = [[[TGDatabaseInstance() existingChannel:_conversationId] map:^id(TGConversation *conversation) {
            return @(conversation.pinnedMessageHidden ? 0 : conversation.pinnedMessageId);
        }] ignoreRepeated];
        
        [_pinnedMessage set:[pinnedId mapToSignal:^SSignal *(NSNumber *nPinnedMessageId) {
            int32_t pinnedMessageId = [nPinnedMessageId intValue];
            return [[TGDatabaseInstance() modify:^id{
                if (pinnedMessageId == 0) {
                    return [SSignal single:[NSNull null]];
                } else {
                    TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:pinnedMessageId peerId:conversationId];
                    if (message != nil) {
                        return [SSignal single:message];
                    } else {
                        return [[TGDownloadMessagesSignal downloadMessages:@[[[TGDownloadMessage alloc] initWithPeerId:conversationId accessHash:accessHash messageId:pinnedMessageId]]] mapToSignal:^SSignal *(NSArray *messages) {
                            return [TGDatabaseInstance() modify:^id{
                                for (TGMessage *message in messages) {
                                    if (message.mid == pinnedMessageId) {
                                        [TGDatabaseInstance() addMessagesToChannel:conversationId messages:@[message] deleteMessages:nil unimportantGroups:nil addedHoles:nil removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:false changedMessages:nil];
                                        return message;
                                    }
                                }
                                return [NSNull null];
                            }];
                        }];
                    }
                }
            }] switchToLatest];
        }]];
        
        SSignal *combinedPinnedMessageAndShouldReportSpam = [SSignal combineSignals:@[
            _pinnedMessage.signal,
            [[TGDatabaseInstance() shouldReportSpamForPeerId:_conversationId] ignoreRepeated]
        ] withInitialStates:@[[NSNull null], @false]];
        
        SSignal *panelSignal = [[combinedPinnedMessageAndShouldReportSpam deliverOn:[SQueue mainQueue]] map:^id(NSArray *pinnedMessageAndReportSpam) {
            __strong TGChannelConversationCompanion *strongSelf = weakSelf;
            TGModernConversationTitlePanel *resultPanel = nil;
            if (strongSelf != nil) {
                if ([pinnedMessageAndReportSpam[1] boolValue]) {
                    if (strongSelf->_reportSpamPanel == nil) {
                        TGModernConversationContactLinkTitlePanel *panel = [[TGModernConversationContactLinkTitlePanel alloc] init];
                        panel.delegate = strongSelf;
                        [panel setShareContact:false addContact:false reportSpam:true];
                        strongSelf->_reportSpamPanel = panel;
                    }
                    resultPanel = strongSelf->_reportSpamPanel;
                } else {
                    TGMessage *message = [pinnedMessageAndReportSpam[0] isKindOfClass:[TGMessage class]] ? pinnedMessageAndReportSpam[0] : nil;
                    
                    strongSelf->_immediatePinnedMessage = message.mid;
                    TGModernConversationController *controller = strongSelf.controller;
                    if (message == nil) {
                        [controller setSecondaryTitlePanel:nil animated:true];
                    } else {
                        TGPinnedMessageTitlePanel *panel = [[TGPinnedMessageTitlePanel alloc] initWithMessage:message];
                        panel.dismiss = ^{
                            __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                if ([strongSelf canPinMessage:message]) {
                                    [[[[strongSelf updatePinnedMessage:0] deliverOn:[SQueue mainQueue]] onDispose:^{
                                    }] startWithNext:nil error:^(__unused id error) {
                                        NSString *errorText = TGLocalized(@"Login.UnknownError");
                                        [[[TGAlertView alloc] initWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                                    } completed:^{
                                    }];
                                } else {
                                    [TGDatabaseInstance() updateChannelPinnedMessageId:conversationId pinnedMessageId:message.mid hidden:@(true)];
                                }
                            }
                        };
                        panel.tapped = ^{
                            __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                TGModernConversationController *controller = strongSelf.controller;
                                if ([[controller visibleMessageIds] containsObject:@(message.mid)]) {
                                    [strongSelf navigateToMessageId:message.mid scrollBackMessageId:0 animated:true];
                                } else {
                                    [strongSelf navigateToMessageId:message.mid scrollBackMessageId:0 animated:true forceLoad:true];
                                }
                            }
                        };
                        strongSelf->_pinnedMessagePanel = panel;
                        resultPanel = panel;
                    }
                }
                
                return resultPanel;
            } else {
                return nil;
            }
        }];
        
        [_primaryPanel set:panelSignal];
        
        _updatedPeerSettingsDisposable = [[TGAccountSignals updatedShouldReportSpamForPeer:_conversationId accessHash:_accessHash] startWithNext:nil];
    }
    return self;
}

- (void)dealloc {
    [_requestingHoleDisposable dispose];
    [_managedState dispose];
    [_extendedDataDisposable dispose];
    [_updatingInvalidatedMessagesDisposable dispose];
    [_genericInfoDisposables dispose];
    [_groupedUserStatusesDisposable dispose];
    [_updatedPeerSettingsDisposable dispose];
}

- (void)setMemberCount:(int32_t)memberCount {
    if (_memberCount != memberCount) {
        _memberCount = memberCount;
        
        [self updateStatus];
    }
}

- (void)setMigrationData:(TGConversationMigrationData *)migrationData {
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        _migrationData = migrationData;
        _attachedConversationId = _migrationData.peerId;
        
        if (_migrationData != nil && !_migrationHistoryAbove) {
            _migrationHistoryAbove = true;
            if (!_loadingHistoryAbove) {
                TGDispatchOnMainThread(^{
                    [self loadMoreMessagesAbove];
                });
            }
        }
    }];
}

- (void)setHasBots:(bool)hasBots {
    hasBots = _isGroup && hasBots;
    TGDispatchOnMainThread(^{
        if (_hasBots != hasBots) {
            _hasBots = hasBots;
            
            self.viewContext.commandsEnabled = hasBots;
            TGModernConversationController *controller = self.controller;
            [controller setHasBots:_hasBots];
        }
    });
}

- (void)_controllerDidAppear:(bool)firstTime {
    [super _controllerDidAppear:firstTime];
    
    if (firstTime) {
        _managedState = [[TGChannelStateSignals updatedChannel:_conversationId] startWithNext:nil];
        
        _enableVisibleMessagesProcessing = true;
        
        _extendedDataDisposable = [[TGChannelManagementSignals updateChannelExtendedInfo:_conversationId accessHash:_accessHash updateUnread:false] startWithNext:nil];
        
        if (!_isGroup && _isForbidden) {
            [[[TGAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:TGLocalized(@"ChannelInfo.ChannelForbidden"), _conversation.chatTitle] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        }
        
        if (_invalidatedPtsDisposable == nil) {
            __weak TGChannelConversationCompanion *weakSelf = self;
            _invalidatedPtsDisposable = [[TGDatabaseInstance() channelHistoryPtsForPeerId:_conversationId] startWithNext:^(NSNumber *nInvalidatedPts) {
                [TGModernConversationCompanion dispatchOnMessageQueue:^{
                    __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf setInvalidatedPts:[nInvalidatedPts intValue]];
                    }
                }];
            }];
        }
        
        [TGModernConversationCompanion dispatchOnMessageQueue:^{
            [self _updateVisibleHoles];
        }];
    }
}

- (void)_controllerAvatarPressed
{
    TGModernConversationController *controller = self.controller;
    TGCollectionMenuController *groupInfoController = nil;
    if (_isGroup) {
        groupInfoController = [[TGChannelGroupInfoController alloc] initWithPeerId:_conversationId];
    } else {
        groupInfoController = [[TGChannelInfoController alloc] initWithPeerId:_conversationId];
    }
    
    if (controller.currentSizeClass == UIUserInterfaceSizeClassCompact) {
        [controller.navigationController pushViewController:groupInfoController animated:true];
    }
    else
    {
        if (controller != nil)
        {
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
    [actions addObject:@{@"title": TGLocalized(@"Conversation.Search"), @"icon": [UIImage imageNamed:@"PanelSearchIcon"], @"action": @"search"}];
    if (_isGroup && _conversation.username.length != 0) {
        [actions addObject:@{@"title": TGLocalized(@"ReportPeer.Report"), @"icon": [UIImage imageNamed:@"PanelReportIcon"], @"action": @"report"}];
    }
    if (_isMuted)
        [actions addObject:@{@"title": TGLocalized(@"Conversation.Unmute"), @"icon": TGTintedImage([UIImage imageNamed:@"DialogListActionUnmute"], TGAccentColor()), @"action": @"unmute"}];
    else
        [actions addObject:@{@"title": TGLocalized(@"Conversation.Mute"), @"icon": TGTintedImage([UIImage imageNamed:@"DialogListActionMute"], TGAccentColor()), @"action": @"mute"}];
    [actions addObject:@{@"title": TGLocalized(@"Conversation.Info"), @"icon": [UIImage imageNamed:@"PanelInfoIcon"], @"action": @"info"}];
    [groupTitlePanel setButtonsWithTitlesAndActions:actions];
    
    [controller setPrimaryTitlePanel:groupTitlePanel];
}

- (void)_loadControllerPrimaryTitlePanel {
    [self _createOrUpdatePrimaryTitlePanel:true];
}


- (TGModernConversationInputPanel *)_conversationGenericInputPanel {
    if (_bannedRights != nil && _bannedRights.banSendMessages) {
        if (_restrictedPanel == nil) {
            _restrictedPanel = [[TGModernConversationRestrictedInputPanel alloc] init];
        }
        [_restrictedPanel setTimeout:_bannedRights.timeout];
        return _restrictedPanel;
    } else if (_isForbidden) {
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
    if (_isGroup) {
        return true;
    } else {
        return _isCreator || _adminRights.canPostMessages;
    }
}

- (void)_updateJoinPanel {
    TGModernConversationController *controller = self.controller;
    [controller setDefaultInputPanel:[self _conversationGenericInputPanel]];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options {
    if ([action isEqualToString:@"titlePanelAction"]) {
        NSString *panelAction = options[@"action"];
        
        if ([panelAction isEqualToString:@"switchMode"]) {
            [self _toggleTitleMode];
        } else if ([panelAction isEqualToString:@"mute"]) {
            [self _commitEnableNotifications:false];
        } else if ([panelAction isEqualToString:@"unmute"]) {
            [self _commitEnableNotifications:true];
        } else if ([panelAction isEqualToString:@"edit"]) {
            [self.controller enterEditingMode];
        } else if ([panelAction isEqualToString:@"report"]) {
            [self reportChannelPressed];
        } else if ([panelAction isEqualToString:@"info"]) {
            [self _controllerAvatarPressed];
            [self.controller hideTitlePanel];
        } else if ([panelAction isEqualToString:@"search"]) {
            [self navigateToMessageSearch];
        }
    } else if ([action isEqualToString:@"openMessageGroup"]) {
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
    if (_isMuted != !enable) {
        _isMuted = !enable;
     
        [_mutePanel setActionWithTitle:!_isMuted ? TGLocalized(@"Conversation.Mute") : TGLocalized(@"Conversation.Unmute") action:@"toggleMute" color:TGAccentColor() icon:TGModernConversationActionInputPanelIconNone];
        
        int muteUntil = enable ? 0 : INT32_MAX;
        
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(channelControllerMute%d)", _conversationId, actionId++] options:@{@"peerId": @(_conversationId), @"accessHash": @(_accessHash), @"muteUntil": @(muteUntil)} watcher:TGTelegraphInstance];
        
        [self _updateChannelMute];
    }
}

- (void)_updateChannelMute
{
    TGDispatchOnMainThread(^
    {
        if (_isMuted)
        {
            TGModernConversationTitleIcon *muteIcon = [[TGModernConversationTitleIcon alloc] init];
            muteIcon.bounds = CGRectMake(0.0f, 0.0f, 16, 16);
            muteIcon.offsetWeight = 0.5f;
            muteIcon.imageOffset = CGPointMake(4.0f, 7.0f);
            
            static UIImage *muteImage = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                muteImage = [UIImage imageNamed:@"DialogList_Muted.png"];
            });
            
            muteIcon.image = muteImage;
            muteIcon.iconPosition = TGModernConversationTitleIconPositionAfterTitle;
            [self _setTitleIcons:@[muteIcon]];
        }
        else
            [self _setTitleIcons:nil];
        
        [self _createOrUpdatePrimaryTitlePanel:false];
    });
}

- (NSString *)title
{
    return [self titleForConversation:_conversation];
}

- (void)loadInitialState {
    [super loadInitialState:false];
    
    TGModernConversationController *controller = self.controller;
    if (!_isGroup) {
        [controller setIsChannel:true];
    }
    
    [controller setConversationHeader:[self _conversationHeader]];
    
    self.viewContext.isPublicGroup = _conversation.isChannelGroup && _conversation.username.length != 0;
    
    if (!_isGroup) {
        if (_isCreator || _adminRights.canPostMessages) {
            [controller setCanBroadcast:true];
            [controller setIsBroadcasting:_shouldNotifyMembers];
            [controller setIsAlwaysBroadcasting:false];
        } else {
            [controller setCanBroadcast:false];
            [controller setIsBroadcasting:false];
            [controller setIsAlwaysBroadcasting:true];
        }
    }
    
    [controller setBannedStickers:_bannedRights.banSendStickers];
    [controller setBannedMedia:_bannedRights.banSendMedia];
    
    self.viewContext.conversation = _conversation;
    
    __block NSArray *topMessages = nil;
    __block NSArray *topMigrationMessages = nil;
    __block TGConversationMigrationData *migrationData = nil;
    __block int32_t missingPreloadedAreaAtMessageId = 0;
    __block int32_t messageIdForVisibleHoleDirection = 0;
    __block int32_t earliestUnreadMessageId = 0;
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^{
        __block TGMessageTransparentSortKey maxSortKey = TGMessageTransparentSortKeyUpperBound(_conversationId);
        
        bool canBeUnread = _conversation.kind == TGConversationKindPersistentChannel && (_conversation.unreadCount != 0 || (_displayVariant == TGChannelDisplayVariantAll && _conversation.serviceUnreadCount != 0));
        
        if (_preferredInitialPositionedMessageId != 0) {
            [TGDatabaseInstance() channelMessageExists:_conversationId messageId:_preferredInitialPositionedMessageId completion:^(bool exists, TGMessageSortKey key) {
                if (exists) {
                    if (TGMessageSortKeySpace(key) == TGMessageSpaceUnimportant) {
                        _displayVariant = TGChannelDisplayVariantAll;
                    }
                    maxSortKey = TGMessageTransparentSortKeyMake(_conversationId, TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                    if (_initialScrollState == nil || _initialScrollState.messageId == 0) {
                        [self setInitialMessagePositioning:TGMessageSortKeyMid(key) position:TGInitialScrollPositionCenter offset:0.0f];
                    }
                    messageIdForVisibleHoleDirection = TGMessageSortKeyMid(key);
                }
            }];
        } else if (canBeUnread) {
            if ([TGChannelManagementSignals _containsPreloadedHistoryForPeerId:_conversationId aroundMessageId:_conversation.maxReadMessageId]) {
                [TGDatabaseInstance() nextChannelIncomingMessageKey:_conversationId messageId:_conversation.maxReadMessageId + 1 completion:^(bool exists, TGMessageSortKey key) {
                    if (exists) {
                        maxSortKey = TGMessageTransparentSortKeyMake(_conversationId, TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                        [self setInitialMessagePositioning:TGMessageSortKeyMid(key) position:TGInitialScrollPositionTop offset:0.0f];
                        
                        TGMessageRange unreadRange = TGMessageRangeEmpty();
                        
                        unreadRange.firstDate = TGMessageSortKeyTimestamp(key);
                        unreadRange.lastDate = INT32_MAX;
                        unreadRange.firstMessageId = TGMessageSortKeyMid(key);
                        unreadRange.lastMessageId = INT32_MAX;
                        
                        self.unreadMessageRange = unreadRange;
                        
                        messageIdForVisibleHoleDirection = TGMessageSortKeyMid(key);
                    }
                }];
            } else {
                missingPreloadedAreaAtMessageId = _conversation.maxReadMessageId;
            }
        }
        
        TGCachedConversationData *cachedData = [TGDatabaseInstance() _channelCachedDataSync:_conversationId];
        migrationData = cachedData.migrationData;
        _hasBots = _isGroup && cachedData.botInfos.count != 0;
        
        if (missingPreloadedAreaAtMessageId != 0) {
        } else {
            [TGDatabaseInstance() channelMessages:_conversationId maxTransparentSortKey:maxSortKey count:35 important:_displayVariant == TGChannelDisplayVariantImportant mode:TGChannelHistoryRequestAround completion:^(NSArray *messages, bool hasLater) {
                topMessages = messages;
                _historyBelow = hasLater;
            }];
            
            
            if (topMessages.count < 35 && migrationData != nil) {
                [TGDatabaseInstance() loadMessagesFromConversation:migrationData.peerId maxMid:migrationData.maxMessageId maxDate:TGMessageTransparentSortKeyTimestamp(maxSortKey) maxLocalMid:0 atMessageId:0 limit:35 extraUnread:false completion:^(NSArray *messages, __unused bool historyExistsBelow) {
                    NSMutableArray *updatedMessages = [[NSMutableArray alloc] init];
                    
                    for (TGMessage *message in messages) {
                        if (message.mid < TGMessageLocalMidBaseline) {
                            message.mid += migratedMessageIdOffset;
                            [updatedMessages addObject:message];
                        }
                    }
                    
                    topMigrationMessages = updatedMessages;
                }];
            }
        }
    } synchronous:true];
    _historyAbove = topMessages.count != 0;
    _migrationData = migrationData;
    _attachedConversationId = _migrationData.peerId;
    _migrationHistoryAbove = topMigrationMessages.count != 0;
    self.viewContext.commandsEnabled = _hasBots;
    
    if (missingPreloadedAreaAtMessageId == 0) {
        [self _replaceMessages:[topMessages arrayByAddingObjectsFromArray:topMigrationMessages] atMessageId:0 expandFrom:0 jump:false top:false messageIdForVisibleHoleDirection:messageIdForVisibleHoleDirection scrollBackMessageId:0 animated:false];
        if (earliestUnreadMessageId != 0) {
            [controller pushEarliestUnreadMessageId:earliestUnreadMessageId];
        }
    } else {
        self.useInitialSnapshot = false;
    }
    
    [self _setTitle:[self titleForConversation:_conversation] andStatus:_isGroup ? TGLocalized(@"Group.Status") : TGLocalized(@"Channel.Status") accentColored:false allowAnimatioon:false toggleMode:[self currentToggleMode]];
    [self _setAvatarConversationId:_conversationId title:_conversation.chatTitle icon:nil];
    [self _setAvatarUrl:_conversation.chatPhotoSmall];
    
    if (_initialUserActivities.count != 0) {
        [self _setTypingStatus:[self stringForUserActivities:_initialUserActivities] activity:[self activityTypeForActivities:_initialUserActivities]];
    }
    
    [controller setHasBots:_hasBots];
    
    if (missingPreloadedAreaAtMessageId != 0) {
        [controller setLoadingMessages:true];
        
        if (_requestingHoleDisposable == nil) {
            _requestingHoleDisposable = [[SMetaDisposable alloc] init];
        }
        
        __weak TGChannelConversationCompanion *weakSelf = self;
        [_requestingHoleDisposable setDisposable:[[TGChannelManagementSignals preloadedHistoryForPeerId:_conversationId accessHash:_accessHash aroundMessageId:missingPreloadedAreaAtMessageId] startWithNext:^(NSDictionary *dict) {
            __strong TGChannelConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSArray *removedImportantHoles = nil;
                NSArray *removedUnimportantHoles = nil;
                
                removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                removedUnimportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                
                [TGDatabaseInstance() addMessagesToChannel:strongSelf->_conversationId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:false changedMessages:^(__unused NSArray *addedMessages, __unused NSArray *removedMessages, __unused NSDictionary *updatedMessages, __unused NSArray *addedUnimportantHoles, __unused NSArray *removedUnimportantHoles) {
                    __block TGMessageTransparentSortKey messageKey = TGMessageTransparentSortKeyUpperBound(strongSelf->_conversationId);
                    [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                        [TGDatabaseInstance() channelMessageExists:_conversationId messageId:missingPreloadedAreaAtMessageId completion:^(bool exists, TGMessageSortKey key) {
                            if (exists) {
                                messageKey = TGMessageTransparentSortKeyMake(TGMessageSortKeyPeerId(key), TGMessageSortKeyTimestamp(key), TGMessageSortKeyMid(key), TGMessageSortKeySpace(key));
                            }
                        }];
                    } synchronous:true];
                    
                    [TGModernConversationCompanion dispatchOnMessageQueue:^{
                        __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            /*strongSelf->_displayVariant = TGChannelDisplayVariantImportant;
                            [TGDatabaseInstance() updateChannelDisplayExpanded:strongSelf->_conversationId displayExpanded:true];*/
                            
                            TGDispatchOnMainThread(^{
                                TGMessageRange unreadRange = TGMessageRangeEmpty();
                                
                                unreadRange.firstDate = TGMessageTransparentSortKeyTimestamp(messageKey);
                                unreadRange.lastDate = INT32_MAX;
                                unreadRange.firstMessageId = TGMessageTransparentSortKeyMid(messageKey) + 1;
                                unreadRange.lastMessageId = INT32_MAX;
                                
                                self.unreadMessageRange = unreadRange;
                                
                                messageIdForVisibleHoleDirection = TGMessageTransparentSortKeyMid(messageKey) + 1;
                                
                                TGModernConversationController *controller = self.controller;
                                if (earliestUnreadMessageId != 0) {
                                    [controller pushEarliestUnreadMessageId:earliestUnreadMessageId];
                                }
                            });
                            
                            [strongSelf reloadVariantAtSortKey:messageKey group:nil jump:false top:true messageIdForVisibleHoleDirection:messageIdForVisibleHoleDirection scrollBackMessageId:0 animated:false];
                        }
                    }];
                }];
            }
        }]];
    }
}

- (TGModernConversationControllerTitleToggle)currentToggleMode {
    return TGModernConversationControllerTitleToggleNone;
}

- (void)updateStatus {
    NSString *text = _isGroup ? TGLocalized(@"Group.Status") : TGLocalized(@"Channel.Status");
    if (_isForbidden) {
        text = _isGroup ? TGLocalized(@"Conversation.StatusKickedFromGroup") : TGLocalized(@"Conversation.StatusKickedFromChannel");
    } else if (_isGroup && _groupedOnlineInfo != nil) {
        text = [self stringForMemberCount:_memberCount onlineCount:(int)_groupedOnlineInfo.onlineCount];
    } else if (_memberCount != 0) {
        text = [self stringForMemberCount:_memberCount];
    }
    
    [self _setStatus:text accentColored:false allowAnimation:false toggleMode:[self currentToggleMode]];
}

- (id)stringForMemberCount:(int)memberCount onlineCount:(int)onlineCount
{
    if (onlineCount <= 1)
        return [self stringForMemberCount:memberCount];
    else
    {
        NSString *firstPart = [[NSString alloc] initWithFormat:@"%@, ", [self stringForMemberCount:memberCount]];
        NSString *secondPart = [self stringForOnlineCount:onlineCount];
        NSString *combinedString = [firstPart stringByAppendingString:secondPart];
        
        //NSRange range1 = NSMakeRange(firstPart.length, secondPart.length);
        //NSRange range2 = [combinedString rangeOfString:secondPart];
        
        return combinedString;
        
        /*NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[firstPart stringByAppendingString:secondPart]];
         [attributedString addAttribute:NSForegroundColorAttributeName value:TGAccentColor() range:NSMakeRange(firstPart.length, secondPart.length)];
         return attributedString;*/
    }
}

- (NSString *)stringForOnlineCount:(int)onlineCount
{
    return [effectiveLocalization() getPluralized:@"Conversation.StatusOnline" count:(int32_t)onlineCount];
}

- (NSString *)stringForMemberCount:(int)memberCount
{
    return [effectiveLocalization() getPluralized:@"Conversation.StatusMembers" count:(int32_t)memberCount];
}

- (void)reloadVariantAtSortKey:(TGMessageTransparentSortKey)sortKey group:(TGMessageGroup *)group jump:(bool)jump top:(bool)top messageIdForVisibleHoleDirection:(int32_t)messageIdForVisibleHoleDirection scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated {
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
        _migrationHistoryAbove = false;
        
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
            }
            
            [TGDatabaseInstance() channelMessages:_conversationId maxTransparentSortKey:updatedSortKey count:60 important:_displayVariant == TGChannelDisplayVariantImportant mode:TGChannelHistoryRequestAround completion:^(NSArray *messages, bool hasLater) {
                [TGModernConversationCompanion dispatchOnMessageQueue:^{
                    _historyAbove = messages.count != 0;
                    _historyBelow = hasLater;
                    _migrationHistoryAbove = _migrationData.peerId != 0;
                    
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
                    
                    [self _replaceMessages:messages atMessageId:atMessageId expandFrom:-group.maxId jump:jump top:top messageIdForVisibleHoleDirection:messageIdForVisibleHoleDirection scrollBackMessageId:scrollBackMessageId animated:animated];
                    
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

- (bool)imageDownloadsShouldAutosavePhotos
{
    return TGAppDelegateInstance.autosavePhotos;
}

- (bool)shouldAutomaticallyDownloadPhotos
{
    return TGAppDelegateInstance.autoDownloadPhotosInGroups;
}

- (bool)shouldAutomaticallyDownloadAnimations
{
    return TGAppDelegateInstance.autoPlayAnimations;
}

- (bool)shouldAutomaticallyDownloadAudios
{
    return TGAppDelegateInstance.autoDownloadAudioInGroups;
}

- (bool)shouldAutomaticallyDownloadVideoMessages
{
    return TGAppDelegateInstance.autoDownloadVideoMessageInGroups;
}

- (NSString *)_sendMessagePathForMessageId:(int32_t)mid {
    return [[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%@)/(%d)", [self _conversationIdPathComponent], mid];
}

- (NSString *)_sendMessagePathPrefix {
    return [[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%@)/", [self _conversationIdPathComponent]];
}

- (NSDictionary *)_optionsForMessageActions {
    bool postAsChannel = !_isGroup;//[self messageAuthorPeerId] == _conversationId;
    return @{@"conversationId": @(_conversationId), @"accessHash": @(_accessHash), @"asChannel": @(postAsChannel), @"sendActivity": @(_isGroup), @"notifyMembers": @(_shouldNotifyMembers)};
}

- (void)_setupOutgoingMessage:(TGMessage *)message {
    [super _setupOutgoingMessage:message];
    
    if (_isGroup/* || !_postAsChannel*/) {
        message.sortKey = TGMessageSortKeyMake(_conversationId, TGMessageSpaceUnimportant, (int32_t)message.date, message.mid);
    }
    
    if (!_isGroup && (_adminRights.canPostMessages)/* && _postAsChannel*/) {
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
        [[NSString alloc] initWithFormat:@"/tg/peerSettings/(%lld)", _conversationId]
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
                bool migratedFound = false;
                bool messagesFound = false;
                for (TGMessageModernConversationItem *item in _items) {
                    if (item->_message.cid == _conversationId) {
                        TGMessageTransparentSortKey itemKey = item->_message.transparentSortKey;
                        itemKey = TGMessageTransparentSortKeyMake(TGMessageTransparentSortKeyPeerId(itemKey), TGMessageTransparentSortKeyTimestamp(itemKey), TGMessageTransparentSortKeyMid(itemKey) - 1, TGMessageTransparentSortKeySpace(itemKey));
                        if (TGMessageTransparentSortKeyCompare(maxKey, itemKey) > 0) {
                            maxKey = itemKey;
                        }
                        messagesFound = true;
                    } else {
                        migratedFound = item->_message.cid != 0;
                    }
                }
                
                if (!messagesFound && migratedFound) {
                    self->_loadingHistoryAbove = false;
                    self->_historyAbove = false;
                    [self _updateControllerHistoryRequestsFlags];
                } else {
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
            } else if (_migrationData != nil && _migrationHistoryAbove) {
                __weak TGChannelConversationCompanion *weakSelf = self;
                _loadingHistoryAbove = true;
                
                int32_t maxTimestamp = INT32_MAX;
                int32_t maxMid = _migrationData.maxMessageId;
                
                for (TGMessageModernConversationItem *item in _items) {
                    maxTimestamp = MIN(maxTimestamp, (int32_t)item->_message.date);
                    if (item->_message.cid == _conversationId || item->_message.cid == 0) {
                    } else {
                        maxMid = MIN(maxMid, item->_message.mid - migratedMessageIdOffset);
                    }
                }
                
                [TGDatabaseInstance() loadMessagesFromConversation:_migrationData.peerId maxMid:maxMid maxDate:maxTimestamp maxLocalMid:0 atMessageId:0 limit:count extraUnread:false completion:^(NSArray *messages, __unused bool historyExistsBelow) {
                    int peerMinMid = [TGDatabaseInstance() loadPeerMinMid:_migrationData.peerId];
                    
                    [TGModernConversationCompanion dispatchOnMessageQueue:^{
                        __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            bool cachedMessagesAbove = false;
                            if (messages.count != 0) {
                                cachedMessagesAbove = true;
                            }
                            
                            NSMutableArray *updatedMessages = [[NSMutableArray alloc] init];
                            
                            for (TGMessage *message in messages) {
                                if (message.mid < TGMessageLocalMidBaseline) {
                                    message.mid += migratedMessageIdOffset;
                                    [updatedMessages addObject:message];
                                }
                            }
                            
                            if (messages.count != 0) {
                                [strongSelf _addMessages:updatedMessages animated:false intent:TGModernConversationAddMessageIntentLoadMoreMessagesAbove];
                            }
                            
                            if (cachedMessagesAbove || peerMinMid != 0) {
                                strongSelf->_loadingHistoryAbove = false;
                                strongSelf->_migrationHistoryAbove = cachedMessagesAbove;
                                
                                [strongSelf _updateControllerHistoryRequestsFlags];
                            } else {
                                NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:@{@"maxMid": @(maxMid), @"offset": @(0)}];
                                
                                options[@"conversationId"] = @(_migrationData.peerId);
                                
                                [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversations/(%lld)/asyncHistory/(%d)", _migrationData.peerId, maxMid] options:options watcher:self];
                            }
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
        
        [TGDatabaseInstance() addMessagesToChannel:conversationId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:displayVariant == TGChannelDisplayVariantImportant keepUnreadCounters:false changedMessages:^(NSArray *addedMessages, NSArray *removedMessages, NSDictionary *updatedMessages, NSArray *addedUnimportantHoles, NSArray *removedUnimportantHoles) {
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
    
    bool enableAboveRequests = _historyAbove || _migrationHistoryAbove;
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

- (NSString *)stringForActivity:(NSString *)activity
{
    if ([activity isEqualToString:@"recordingAudio"])
        return TGLocalized(@"Activity.RecordingAudio");
    else if ([activity isEqualToString:@"recordingVideoMessage"])
        return TGLocalized(@"Activity.RecordingVideoMessage");
    else if ([activity isEqualToString:@"uploadingPhoto"])
        return TGLocalized(@"Activity.UploadingPhoto");
    else if ([activity isEqualToString:@"uploadingVideo"])
        return TGLocalized(@"Activity.UploadingVideo");
    else if ([activity isEqualToString:@"uploadingDocument"])
        return TGLocalized(@"Activity.UploadingDocument");
    else if ([activity isEqualToString:@"pickingLocation"])
        return nil;
    else if ([activity isEqualToString:@"playingGame"])
        return TGLocalized(@"Activity.PlayingGame");
    
    return TGLocalized(@"Conversation.typing");
}

- (int)activityTypeForActivity:(NSString *)activity
{
    if ([activity isEqualToString:@"recordingAudio"])
        return TGModernConversationTitleViewActivityAudioRecording;
    else if ([activity isEqualToString:@"recordingVideoMessage"])
        return TGModernConversationTitleViewActivityVideoMessageRecording;
    else if ([activity isEqualToString:@"uploadingPhoto"])
        return TGModernConversationTitleViewActivityUploading;
    else if ([activity isEqualToString:@"uploadingVideo"])
        return TGModernConversationTitleViewActivityUploading;
    else if ([activity isEqualToString:@"uploadingDocument"])
        return TGModernConversationTitleViewActivityUploading;
    else if ([activity isEqualToString:@"pickingLocation"])
        return 0;
    else if ([activity isEqualToString:@"playingGame"])
        return TGModernConversationTitleViewActivityPlaying;
    
    return TGModernConversationTitleViewActivityTyping;
}

- (NSString *)stringForUserActivities:(NSDictionary *)activities
{
    if (activities.count != 0)
    {
        NSMutableString *typingString = [[NSMutableString alloc] init];
        
        for (NSNumber *nUid in activities)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
            if (user != nil)
            {
                if (typingString.length != 0)
                    [typingString appendString:@", "];
                [typingString appendString:user.displayFirstName];
            }
        }
        
        return typingString;
    }
    
    return nil;
}

- (int)activityTypeForActivities:(NSDictionary *)activities
{
    if (activities.count == 1)
    {
        return [self activityTypeForActivity:activities.allValues.firstObject];
    }
    else if (activities.count != 0)
    {
        return TGModernConversationTitleViewActivityTyping;
    }
    
    return 0;
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
                
                [self _updateChannelMute];
            });
        }
    } else if ([path rangeOfString:@"/asyncHistory/"].location != NSNotFound) {
        [TGModernConversationCompanion dispatchOnMessageQueue:^{
            NSArray *messages = result;
            
            NSMutableArray *updatedMessages = [[NSMutableArray alloc] init];
            
            for (TGMessage *message in messages) {
                if (message.mid < TGMessageLocalMidBaseline) {
                    
                    TGMessage *updatedMessage = [message copy];
                    updatedMessage.mid += migratedMessageIdOffset;
                    [updatedMessages addObject:updatedMessage];
                }
            }
            
            if (messages.count != 0) {
                [self _addMessages:updatedMessages animated:false intent:TGModernConversationAddMessageIntentLoadMoreMessagesAbove];
            }
            
            _loadingHistoryAbove = false;
            _migrationHistoryAbove = updatedMessages.count != 0;
            
            [self _updateControllerHistoryRequestsFlags];
        }];
        return;
    }
    
    [super actorCompleted:status path:path result:result];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments {
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/typing", _conversationId]])
    {
        NSDictionary *userActivities = ((SGraphObjectNode *)resource).object;
        if (userActivities.count != 0)
            [self _setTypingStatus:[self stringForUserActivities:userActivities] activity:[self activityTypeForActivities:userActivities]];
        else
            [self _setTypingStatus:nil activity:0];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId]]) {
        TGConversation *conversation = ((SGraphObjectNode *)resource).object;
        _conversation = conversation;
        _signaturesEnabled = conversation.signaturesEnabled;
        
        TGDispatchOnMainThread(^{
            bool importantFlagsUpdated = !TGObjectCompare(_adminRights, conversation.channelAdminRights) || !TGObjectCompare(_bannedRights, conversation.channelBannedRights) || _kind != conversation.kind || _isForbidden != conversation.kickedFromChat;
            
            _kind = conversation.kind;
            _adminRights = conversation.channelAdminRights;
            _bannedRights = conversation.channelBannedRights;
            
            if (!_isGroup && _isForbidden != conversation.kickedFromChat && conversation.kickedFromChat) {
                [[[TGAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:TGLocalized(@"ChannelInfo.ChannelForbidden"), conversation.chatTitle] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            }
            
            _isForbidden = conversation.kickedFromChat;
            
            TGModernConversationController *controller = self.controller;
            if (!_isGroup) {
                if (_isCreator || _adminRights.canPostMessages) {
                    [controller setCanBroadcast:true];
                    [controller setIsBroadcasting:_shouldNotifyMembers];
                    [controller setIsAlwaysBroadcasting:false];
                } else {
                    [controller setCanBroadcast:false];
                    [controller setIsBroadcasting:false];
                    [controller setIsAlwaysBroadcasting:true];
                }
            }
            
            if (importantFlagsUpdated) {
                [self _updateJoinPanel];
                [controller setBannedStickers:_bannedRights.banSendStickers];
                [controller setBannedMedia:_bannedRights.banSendMedia];
            }
            
            [self _setTitle:[self titleForConversation:conversation] andStatus:_isGroup ? TGLocalized(@"Group.Status") : TGLocalized(@"Channel.Status") accentColored:false allowAnimatioon:false toggleMode:[self currentToggleMode]];
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
    return _isGroup || _isCreator || _adminRights.canPostMessages;
}

- (int64_t)messageAuthorPeerId {
    if (_isGroup || _signaturesEnabled) {
        return TGTelegraphInstance.clientUserId;
    }
    
    return _conversationId;
}

- (bool)canDeleteMessage:(TGMessage *)message {
    if (_bannedRights.banSendMessages) {
        return false;
    }
    
    if (!_isGroup) {
        if (TGMessageSortKeySpace(message.sortKey) == TGMessageSpaceImportant) {
            if (_isCreator || _adminRights.canDeleteMessages || message.outgoing) {
                return true;
            } else {
                return false;
            }
        }
    }
    
    if (message.fromUid == _conversationId) {
        return _isCreator || _adminRights.canDeleteMessages;
    } else {
        if (message.outgoing || (_isCreator || _adminRights.canDeleteMessages)) {
            return true;
        }
    }
    return false;
}

- (bool)canModerateMessage:(TGMessage *)message {
    if (message.cid != _conversationId) {
        return false;
    }
    
    if (TGMessageSortKeySpace(message.sortKey) == TGMessageSpaceImportant) {
        return false;
    }
    
    if (message.actionInfo != nil) {
        return false;
    }
    
    if (message.outgoing) {
        return false;
    }
    
    if (message.mid >= TGMessageLocalMidBaseline) {
        return false;
    }
    
    if (_isCreator || _adminRights.canBanUsers) {
        return true;
    }
    
    return false;
}

- (TGUser *)checkedMessageModerateUser {
    NSArray *messageIds = [self checkedMessageIds];
    if (messageIds.count > 20) {
        return nil;
    }
    
    NSNumber *sharedAuthorId = nil;
    
    for (NSNumber *messageId in messageIds) {
        TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[messageId intValue] peerId:_conversationId];
        if (message == nil || ![self canModerateMessage:message]) {
            return nil;
        }
        
        if (sharedAuthorId == nil) {
            sharedAuthorId = @(message.fromUid);
        } else if ([sharedAuthorId longLongValue] != message.fromUid) {
            return nil;
        }
    }
    
    if (sharedAuthorId != nil) {
        return [TGDatabaseInstance() loadUser:[sharedAuthorId intValue]];
    }
    
    return nil;
}

- (bool)canPinMessage:(TGMessage *)message {
    if (!_isGroup) {
        return false;
    }
    
    if (message.mid >= TGMessageLocalMidBaseline) {
        return false;
    }
    
    if (message.actionInfo != nil) {
        return false;
    }
    
    if (message.cid != _conversationId) {
        return false;
    }
    
    if (_isCreator || _adminRights.canPinMessages) {
        return true;
    }
    
    return false;
}

- (bool)isMessagePinned:(int32_t)messageId {
    return messageId != 0 && messageId == _immediatePinnedMessage;
}

- (bool)canEditMessage:(TGMessage *)message {
    if (_bannedRights.banSendMessages) {
        return false;
    }
    
    if (message.mid >= TGMessageLocalMidBaseline) {
        return false;
    }
    
    bool editable = true;
    bool hasEditableContent = message.text.length != 0;
    for (id attachment in message.mediaAttachments) {
        if ([attachment isKindOfClass:[TGBotContextResultAttachment class]]) {
            editable = false;
            break;
        } else if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
            hasEditableContent = true;
        } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]] && !((TGVideoMediaAttachment *)attachment).roundMessage) {
            hasEditableContent = true;
        } else if ([attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]]) {
            editable = false;
            break;
        } else if ([attachment isKindOfClass:[TGViaUserAttachment class]]) {
            editable = false;
            break;
        } else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
            hasEditableContent = ![((TGDocumentMediaAttachment *)attachment) isSticker];
            break;
        }
    }
    
    if (!editable || !hasEditableContent) {
        return false;
    }
    
    int32_t maxChannelMessageEditTime = 60 * 60 * 24 * 2;
    NSData *data = [TGDatabaseInstance() customProperty:@"maxChannelMessageEditTime"];
    if (data.length >= 4) {
        [data getBytes:&maxChannelMessageEditTime length:4];
    }
    
    if ([TGTelegramNetworking instance].approximateRemoteTime > message.date + maxChannelMessageEditTime) {
        return false;
    }
    
    if (TGMessageSortKeySpace(message.sortKey) == TGMessageSpaceImportant) {
        if (_isCreator || message.outgoing || _adminRights.canEditMessages) {
            return true;
        }
    } else {
        if (message.outgoing) {
            return true;
        }
    }
    return false;
}

- (bool)canDeleteMessages {
    if (_bannedRights.banSendMessages) {
        return false;
    }
    
    return _isCreator || _adminRights.canDeleteMessages;
}

- (bool)canDeleteAllMessages {
    return false;
}

- (NSString *)_controllerInfoButtonText {
    if (_isGroup) {
        return TGLocalized(@"Conversation.InfoGroup");        
    } else {
        return TGLocalized(@"Conversation.InfoChannel");
    }
}

- (int64_t)requestPeerId {
    return _conversationId;
}

- (int64_t)requestAccessHash {
    return _accessHash;
}

- (void)_toggleBroadcastMode {
    _shouldNotifyMembers = !_shouldNotifyMembers;
    [TGDatabaseInstance() setChannelShouldMuteMembers:_conversationId value:!_shouldNotifyMembers];
}

- (void)_toggleTitleMode {
    TGMessageTransparentSortKey sortKey = TGMessageTransparentSortKeyUpperBound(_conversationId);
    TGModernConversationController *controller = self.controller;
    TGMessage *maxMessage = [controller latestVisibleMessage];
    if (maxMessage != nil) {
        sortKey = maxMessage.transparentSortKey;
    }
    
    _lastExpandedGroup = nil;
    
    if (_displayVariant != _conversation.displayVariant && _displayVariant == TGChannelDisplayVariantImportant) {
        _conversation = [_conversation copy];
        _conversation.displayVariant = _displayVariant;
        _signaturesEnabled = _conversation.signaturesEnabled;
        [TGDatabaseInstance() updateChannelDisplayVariant:_conversationId displayVariant:_displayVariant];
    }
    
    [self reloadVariantAtSortKey:sortKey group:nil jump:false top:false messageIdForVisibleHoleDirection:0 scrollBackMessageId:0 animated:true];
}

- (void)navigateToMessageId:(int32_t)messageId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated {
    [self navigateToMessageId:messageId scrollBackMessageId:scrollBackMessageId animated:animated forceLoad:false];
}

- (void)navigateToMessageId:(int32_t)messageId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated forceLoad:(bool)forceLoad
{
    __weak TGChannelConversationCompanion *weakSelf = self;
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        if ([self attachedPeerId] != 0 && scrollBackMessageId >= migratedMessageIdOffset) {
            return;
        }
        
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
        
        if (found && !forceLoad)
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
                
                [TGDatabaseInstance() addMessagesToChannel:conversationId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:false changedMessages:^(__unused NSArray *addedMessages, __unused NSArray *removedMessages, __unused NSDictionary *updatedMessages, __unused NSArray *addedUnimportantHoles, __unused NSArray *removedUnimportantHoles) {
                    [TGModernConversationCompanion dispatchOnMessageQueue:^{
                        __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            if (TGMessageTransparentSortKeySpace(sortKey) == TGMessageSpaceUnimportant && strongSelf->_displayVariant != TGChannelDisplayVariantAll) {
                                /*strongSelf->_displayVariant = TGChannelDisplayVariantAll;
                                [TGDatabaseInstance() updateChannelDisplayExpanded:strongSelf->_conversationId displayExpanded:true];*/
                            }
                            [strongSelf reloadVariantAtSortKey:sortKey group:nil jump:true top:false messageIdForVisibleHoleDirection:TGMessageTransparentSortKeyMid(sortKey) scrollBackMessageId:scrollBackMessageId animated:true];
                        }
                    }];
                }];
            }];
        }
    }];
}

- (void)controllerDidUpdateTypingActivity
{
    if (_isGroup) {
        [ActionStageInstance() dispatchOnStageQueue:^ {
            CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
            if (ABS(currentTime - _lastTypingActivity) >= 4.0) {
                _lastTypingActivity = currentTime;
                [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/activity/(typing)", _conversationId] options:@{@"accessHash": @(_accessHash)} watcher:self];
            }
        }];
    }
}

- (void)controllerDidCancelTypingActivity
{
}

- (UIView *)_conversationHeader
{
    /*if (_isGroup)
    {
        if (_migratedChannelHeaderView == nil)
        {
            _migratedChannelHeaderView = [[TGMigratedChannelConversationHeaderView alloc] initWithContext:self.viewContext title:_conversation.chatTitle];
            [_migratedChannelHeaderView sizeToFit];
        }
        return _migratedChannelHeaderView;
    }*/
    return nil;
}

- (SSignal *)userListForMention:(NSString *)mention canBeContextBot:(bool)canBeContextBot
{   
    NSMutableArray *visibleUserIds = [[NSMutableArray alloc] init];
    
    TGModernConversationController *controller = self.controller;
    for (TGMessageModernConversationItem *item in [controller _items])
    {
        int32_t uid = (int32_t)(item->_message.fromUid);
        if (![visibleUserIds containsObject:@(uid)]) {
            [visibleUserIds addObject:@(uid)];
        }
    }
    
    SSignal *remoteMembersSignal = [[TGChannelManagementSignals channelMembers:_conversationId accessHash:_accessHash offset:0 count:32] mapToSignal:^SSignal *(NSDictionary *dict) {
        return [[TGDatabaseInstance() modify:^id{
            [TGDatabaseInstance() updateChannelCachedData:_conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                if (data == nil) {
                    data = [[TGCachedConversationData alloc] init];
                }
                
                NSMutableArray *sortedMemberDatas = [[NSMutableArray alloc] init];
                NSDictionary *memberDatas = dict[@"memberDatas"];
                for (TGUser *user in dict[@"users"]) {
                    TGCachedConversationMember *member = memberDatas[@(user.uid)];
                    if (member != nil) {
                        [sortedMemberDatas addObject:member];
                    }
                }
                
                return [data updateGeneralMembers:sortedMemberDatas];
            }];
            
            return [SSignal complete];
        }] switchToLatest];
    }];
    
    bool isGroup = _isGroup;
    
    SSignal *recentBotUids = canBeContextBot ? [TGRecentContextBotsSignal recentBots] : [SSignal single:@[]];
    
    return [[[SSignal mergeSignals:@[[SSignal combineSignals:@[[TGDatabaseInstance() channelCachedData:_conversationId], recentBotUids]], remoteMembersSignal]] mapToSignal:^SSignal *(NSArray *combinedResult) {
        
        TGCachedConversationData *cachedData = combinedResult[0];
        
        NSMutableSet *existingUsers = [[NSMutableSet alloc] init];
        [existingUsers addObject:@(TGTelegraphInstance.clientUserId)];
        
        NSMutableArray *contextBots = [[NSMutableArray alloc] init];
        NSString *normalizedMention = [mention lowercaseString];
        for (NSNumber *nUserId in combinedResult[1]) {
            if (![existingUsers containsObject:nUserId]) {
                [existingUsers addObject:nUserId];
                
                TGUser *user = [TGDatabaseInstance() loadUser:[nUserId intValue]];
                if (user != nil && (normalizedMention.length == 0 || [[user.userName lowercaseString] hasPrefix:normalizedMention] || [[user.firstName lowercaseString] hasPrefix:normalizedMention] || [[user.lastName lowercaseString] hasPrefix:normalizedMention])) {
                    if (user.isContextBot) {
                        [contextBots addObject:user];
                    }
                }
            }
        }
        
        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
        for (TGCachedConversationMember *member in cachedData.generalMembers)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:member.uid];
            if (user != nil && user.uid != TGTelegraphInstance.clientUserId && (normalizedMention.length == 0 || [[user.userName lowercaseString] hasPrefix:normalizedMention] || [[user.firstName lowercaseString] hasPrefix:normalizedMention] || [[user.lastName lowercaseString] hasPrefix:normalizedMention]))
            {
                if (![existingUsers containsObject:@(user.uid)]) {
                    [existingUsers addObject:@(user.uid)];
                    userDict[@(user.uid)] = user;
                }
            }
        }
        
        NSArray *sortedContextBots = contextBots;
        
        NSMutableArray *sortedUserList = [[NSMutableArray alloc] init];
        
        [sortedUserList addObjectsFromArray:sortedContextBots];
        
        if (isGroup) {
            for (NSNumber *nUid in visibleUserIds)
            {
                int32_t uid = [nUid intValue];
                TGUser *user = userDict[@(uid)];
                if (user == nil) {
                    TGUser *candidateUser = [TGDatabaseInstance() loadUser:uid];
                    if (candidateUser != nil && candidateUser.uid != TGTelegraphInstance.clientUserId && (normalizedMention.length == 0 || [[candidateUser.userName lowercaseString] hasPrefix:normalizedMention] || [[candidateUser.firstName lowercaseString] hasPrefix:normalizedMention] || [[candidateUser.lastName lowercaseString] hasPrefix:normalizedMention])) {
                        user = candidateUser;
                    }
                }
                
                if (user != nil && ![existingUsers containsObject:@(user.uid)]) {
                    [existingUsers addObject:@(user.uid)];
                    [sortedUserList addObject:user];
                    [userDict removeObjectForKey:@(uid)];
                    if (userDict.count == 0)
                        break;
                }
            }
            
            NSArray *sortedRemainingUsers = [[userDict allValues] sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2) {
                return [user1.displayName compare:user2.displayName];
            }];
            
            [sortedUserList addObjectsFromArray:sortedRemainingUsers];
        }
        
        return [SSignal single:sortedUserList];
    }] deliverOn:[SQueue mainQueue]];
}

- (SSignal *)commandListForCommand:(NSString *)command
{
    return [[[TGDatabaseInstance() channelCachedData:_conversationId] mapToSignal:^SSignal *(TGCachedConversationData *cachedData) {
        if (cachedData.botInfos.count != 0) {
            NSString *normalizedCommand = [command lowercaseString];
            if ([normalizedCommand hasPrefix:@"/"])
                normalizedCommand = [normalizedCommand substringFromIndex:1];
            
            NSMutableArray *botUsers = [[NSMutableArray alloc] init];
            NSMutableArray *botInfoSignals = [[NSMutableArray alloc] init];
            NSMutableArray *initialStates = [[NSMutableArray alloc] init];
            for (NSNumber *nUid in [cachedData.botInfos allKeys])
            {
                TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
                {
                    [botUsers addObject:user];
                    [botInfoSignals addObject:[[SSignal single:cachedData.botInfos[nUid]] map:^id(TGBotInfo *botInfo) {
                        NSMutableArray *commands = [[NSMutableArray alloc] init];
                        for (TGBotComandInfo *commandInfo in botInfo.commandList) {
                            if (normalizedCommand.length == 0 || [[commandInfo.command lowercaseString] hasPrefix:normalizedCommand]) {
                                [commands addObject:commandInfo];
                            }
                        }
                        return commands;
                    }]];
                    [initialStates addObject:@[]];
                }
            }
            
            return [[SSignal combineSignals:botInfoSignals withInitialStates:initialStates] map:^id(NSArray *commandLists) {
                NSMutableArray *commands = [[NSMutableArray alloc] init];
                NSUInteger index = 0;
                for (NSArray *commandList in commandLists) {
                    [commands addObject:@[botUsers[index], commandList]];
                    index++;
                }
                
                return commands;
            }];
        } else {
            return [SSignal single:@[]];
        }
    }] deliverOn:[SQueue mainQueue]];
}

- (int64_t)attachedPeerId {
    return _migrationData.peerId;
}

- (void)setInvalidatedPts:(int32_t)invalidatedPts {
#ifdef DEBUG
    //invalidatedPts = 102;
#endif
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        if (_invalidatedPts != invalidatedPts) {
            _invalidatedPts = invalidatedPts;
            
            [self _validatePts];
        }
    }];
}

- (void)_validatePts {
    if (_invalidatedPts == 0) {
        return;
    }
    
    if (_updatingInvalidatedMessages) {
        _needsToValidatePts = true;
    } else {
        _needsToValidatePts = false;
        
        NSMutableArray *invalidatedMessageRanges = [[NSMutableArray alloc] init];
        int32_t minPts = 1;
        
        for (TGMessageModernConversationItem *item in _items) {
            if (item->_message.cid == _conversationId && item->_message.mid < TGMessageLocalMidBaseline) {
                if (item->_message.hole != nil || item->_message.group != nil) {
                    TLMessageRange$messageRange *lastRange = invalidatedMessageRanges.lastObject;
                    if (lastRange != nil && lastRange.max_id != 0) {
                        TLMessageRange$messageRange *nextRange = [[TLMessageRange$messageRange alloc] init];
                        nextRange.min_id = 0;
                        nextRange.max_id = 0;
                        [invalidatedMessageRanges addObject:nextRange];
                    }
                } else if (item->_message.mid > 0) {
                    if (item->_message.pts < _invalidatedPts) {
                        int32_t messagePts = MAX(1, item->_message.pts);
                        minPts = minPts == 1 ? messagePts : MIN(messagePts, minPts);
                        //TGLog(@"enqueue item %p (mid %d) to pts %d", item, item->_message.mid, item->_message.pts);
                        
                        TLMessageRange$messageRange *lastRange = invalidatedMessageRanges.lastObject;
                        if (lastRange == nil) {
                            lastRange = [[TLMessageRange$messageRange alloc] init];
                            lastRange.min_id = 0;
                            lastRange.max_id = 0;
                            [invalidatedMessageRanges addObject:lastRange];
                        }
                        
                        if (lastRange.max_id == 0) {
                            lastRange.min_id = item->_message.mid;
                            lastRange.max_id = item->_message.mid;
                        } else {
                            lastRange.min_id = MIN(lastRange.min_id, item->_message.mid);
                        }
                    }
                }
            }
        }
        
        if (invalidatedMessageRanges.count != 0) {
            TLMessageRange$messageRange *lastRange = invalidatedMessageRanges.lastObject;
            if (lastRange.max_id == 0) {
                [invalidatedMessageRanges removeLastObject];
            }
        }
        
        if (invalidatedMessageRanges.count != 0) {
            TGLog(@"Will invalidate message ranges to pts %d:", _invalidatedPts);
            for (TLMessageRange *range in invalidatedMessageRanges) {
                TGLog(@"    %d ... %d (pts %d)", range.min_id, range.max_id, minPts);
            }
            
            _updatingInvalidatedMessages = true;
            
            if (_updatingInvalidatedMessagesDisposable == nil) {
                _updatingInvalidatedMessagesDisposable = [[SMetaDisposable alloc] init];
            }
            
            __weak TGChannelConversationCompanion *weakSelf = self;
            int32_t validPts = _invalidatedPts;
            [_updatingInvalidatedMessagesDisposable setDisposable:[[TGChannelStateSignals validateMessageRanges:_conversationId pts:minPts validPts:validPts messageRanges:invalidatedMessageRanges] startWithNext:nil completed:^{
                [TGModernConversationCompanion dispatchOnMessageQueue:^{
                    __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf _messageRangesValidated:invalidatedMessageRanges pts:validPts];
                        
                        strongSelf->_updatingInvalidatedMessages = false;
                        
                        if (strongSelf->_needsToValidatePts) {
                            [strongSelf _validatePts];
                        }
                    }
                }];
            }]];
        }
    }
}

- (void)_messageRangesValidated:(NSArray *)messageRanges pts:(int32_t)pts {
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for (TLMessageRange *range in messageRanges) {
        [indexSet addIndexesInRange:NSMakeRange(range.min_id, range.max_id - range.min_id + 1)];
    }
    for (NSUInteger i = 0; i < _items.count; i++) {
        TGMessageModernConversationItem *item = _items[i];
        
        if ([indexSet containsIndex:item->_message.mid]) {
            item = [item deepCopy];
            item->_message.pts = pts;
            [((NSMutableArray *)_items) replaceObjectAtIndex:i withObject:item];
            //TGLog(@"update %p (mid %d) to pts %d", item, item->_message.mid, pts);
        }
    }
}

- (void)_itemsUpdated {
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        [super _itemsUpdated];
        
        [self _validatePts];
    }];
}

- (void)_performFastScrollDown:(bool)becauseOfSendTextAction becauseOfNavigation:(bool)becauseOfNavigation
{
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        [TGDatabaseInstance() channelMessages:_conversationId maxTransparentSortKey:TGMessageTransparentSortKeyUpperBound(_conversationId) count:50 important:_displayVariant == TGChannelDisplayVariantImportant mode:TGChannelHistoryRequestEarlier completion:^(NSArray *messages, bool hasLater) {
            
            _historyBelow = hasLater;
            
            NSMutableArray *sortedTopMessages = [[NSMutableArray alloc] initWithArray:messages];
            [sortedTopMessages sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
            {
                NSTimeInterval date1 = message1.date;
                NSTimeInterval date2 = message2.date;
                
                if (ABS(date1 - date2) < DBL_EPSILON)
                {
                    if (message1.mid > message2.mid)
                        return NSOrderedAscending;
                    else
                        return NSOrderedDescending;
                }
                
                return date1 > date2 ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            [TGModernConversationCompanion dispatchOnMessageQueue:^
            {
                _historyBelow = false;
                _historyAbove = true;
                if (_migrationData.peerId != 0) {
                    _migrationHistoryAbove = true;
                }
                
                [self _replaceMessagesWithFastScroll:sortedTopMessages intent:becauseOfNavigation ? TGModernConversationAddMessageIntentGeneric : (becauseOfSendTextAction ? TGModernConversationAddMessageIntentSendTextMessage : TGModernConversationAddMessageIntentSendOtherMessage) scrollToMessageId:0 scrollBackMessageId:0 animated:true];
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

- (SSignal *)editingContextForMessageWithId:(int32_t)messageId {
    return [[TGChannelManagementSignals messageEditData:_conversationId accessHash:_accessHash messageId:messageId] catch:^SSignal *(__unused id error) {
        return [SSignal single:nil];
    }];
}

- (SSignal *)saveEditedMessageWithId:(int32_t)messageId text:(NSString *)text entities:(NSArray *)entities disableLinkPreviews:(bool)disableLinkPreviews {
    __weak TGChannelConversationCompanion *weakSelf = self;
    int64_t peerId = _conversationId;
    SSignal *notModified = [[TGDatabaseInstance() modify:^id{
        TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:peerId];
        NSString *messageText = message.text;
        for (id attachment in message.mediaAttachments) {
            if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
                messageText = ((TGImageMediaAttachment *)attachment).caption;
            } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]) {
                messageText = ((TGVideoMediaAttachment *)attachment).caption;
            } else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                messageText = ((TGDocumentMediaAttachment *)attachment).caption;
            }
        }
        
        if (TGStringCompare(text, messageText) && !disableLinkPreviews) {
            return [SSignal complete];
        } else {
            return [SSignal fail:nil];
        }
    }] switchToLatest];
    
    notModified = [SSignal fail:nil];
    
    return [notModified catch:^SSignal *(__unused id error) {
        return [[[[TGGroupManagementSignals editMessage:_conversationId accessHash:_accessHash messageId:messageId text:text entities:entities disableLinksPreview:disableLinkPreviews] mapToSignal:^SSignal *(TGMessage *updatedMessage) {
            __strong TGChannelConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                TGMessage *message = updatedMessage;
                if (message == nil) {
                    return [SSignal fail:nil];
                } else {
                    return [SSignal single:message];
                }
            }
            
            return [SSignal complete];
        }] deliverOn:[TGModernConversationCompanion messageQueue]] onNext:^(TGMessage *message) {
            __strong TGChannelConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf updateMessagesLive:@{@(message.mid): message} animated:false];
            }
        }];
    }];
}

- (SSignal *)updatePinnedMessage:(int32_t)messageId {
    SSignal *askSignal = [SSignal single:@true];
    bool isChannelGroup = _isGroup;
    
    if (messageId == 0) {
        __weak TGGenericModernConversationCompanion *weakSelf = self;
        askSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
            if (iosMajorVersion() >= 8) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:TGLocalized(@"Conversation.UnpinMessageAlert") preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:TGLocalized(@"Common.Yes") style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction * _Nonnull action) {
                    [subscriber putNext:@(true)];
                    [subscriber putCompletion];
                }];
                UIAlertAction* cancel = [UIAlertAction actionWithTitle:TGLocalized(@"Common.No") style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction * _Nonnull action) {
                    [subscriber putNext:@(false)];
                    [subscriber putCompletion];
                }];
                [alertController addAction:ok];
                [alertController addAction:cancel];
                
                __strong TGGenericModernConversationCompanion *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    UIWindow *targetWindow = TGAppDelegateInstance.window;
                    for (UIWindow *window in [UIApplication sharedApplication].windows.reverseObjectEnumerator) {
                        if (window.rootViewController != nil && ([NSStringFromClass([window class]) hasPrefix:@"UITextEffec"] || [NSStringFromClass([window class]) hasPrefix:@"UIRemoteKe"])) {
                            targetWindow = window;
                            break;
                        }
                    }
                    [targetWindow.rootViewController presentViewController:alertController animated:true completion:nil];
                }
            } else {
                [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Conversation.UnpinMessageAlert") cancelButtonTitle:TGLocalized(@"Common.No") okButtonTitle:TGLocalized(@"Common.Yes") completionBlock:^(bool okButtonPressed) {
                    [subscriber putNext:@(okButtonPressed)];
                    [subscriber putCompletion];
                }] show];
            }
            
            return [[SBlockDisposable alloc] initWithBlock:^{
            }];
        }];
    } else {
        askSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
            if (iosMajorVersion() >= 8) {
                TGAlertViewController *alertController = [TGAlertViewController alertControllerWithTitle:nil message:isChannelGroup ? TGLocalized(@"Conversation.PinMessageAlertGroup") : TGLocalized(@"Conversation.PinMessageAlertChannel") preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:TGLocalized(@"Common.OK") style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction * _Nonnull action) {
                    [subscriber putNext:@(true)];
                    [subscriber putCompletion];
                }];
                UIAlertAction* cancel = [UIAlertAction actionWithTitle:TGLocalized(@"Conversation.PinMessageAlert.OnlyPin") style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction * _Nonnull action) {
                    [subscriber putNext:@(false)];
                    [subscriber putCompletion];
                }];
                [alertController addAction:ok];
                [alertController addAction:cancel];
                
                __weak TGChannelConversationCompanion *weakSelf = self;
                alertController.backgroundTapped = ^{
                    __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf.controller dismissViewControllerAnimated:true completion:nil];
                    }
                };
                
                UIWindow *targetWindow = TGAppDelegateInstance.window;
                for (UIWindow *window in [UIApplication sharedApplication].windows.reverseObjectEnumerator) {
                    if (window.rootViewController != nil && ([NSStringFromClass([window class]) hasPrefix:@"UITextEffec"] || [NSStringFromClass([window class]) hasPrefix:@"UIRemoteKe"])) {
                        targetWindow = window;
                        break;
                    }
                }
                
                [self.controller presentViewController:alertController animated:true completion:nil];
            } else {
                [[[TGAlertView alloc] initWithTitle:nil message:isChannelGroup ? TGLocalized(@"Conversation.PinMessageAlertGroup") : TGLocalized(@"Conversation.PinMessageAlertChannel") cancelButtonTitle:TGLocalized(@"Conversation.PinMessageAlert.OnlyPin") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed) {
                    [subscriber putNext:@(okButtonPressed)];
                    [subscriber putCompletion];
                }] show];
            }
            
            return [[SBlockDisposable alloc] initWithBlock:^{
            }];
        }];
    }
    
    return [[askSignal deliverOn:[SQueue mainQueue]] mapToSignal:^SSignal *(NSNumber *update) {
        if ([update boolValue] || messageId != 0) {
            return [SSignal defer:^SSignal *{
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow showWithDelay:0.2];
                
                return [[[[TGChannelManagementSignals updatePinnedMessage:_conversationId accessHash:_accessHash messageId:messageId notify:[update boolValue]] catch:^SSignal *(id error) {
                    NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                    if ([errorType isEqualToString:@"CHAT_NOT_MODIFIED"]) {
                        return [SSignal complete];
                    }
                    return [SSignal fail:nil];
                }] timeout:5.0 onQueue:[SQueue concurrentDefaultQueue] orSignal:[SSignal fail:@"timeout"]] onDispose:^{
                    TGDispatchOnMainThread(^{
                        [progressWindow dismiss:true];
                    });
                }];
            }];
        } else {
            return [SSignal complete];
        }
    }];
}

- (SSignal *)reportMessage:(int32_t)messageId {
    int64_t conversationId = _conversationId;
    int64_t accessHash = _accessHash;
    TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:_conversationId];
    TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
    
    return [[SSignal defer:^SSignal *{
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow showWithDelay:0.2];
        
        return [[TGChannelManagementSignals reportUserSpam:conversationId accessHash:accessHash user:user messageIds:@[@(message.mid)]] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismissWithSuccess];
            });
        }];
    }] startOn:[SQueue mainQueue]];
}

- (bool)canCreateLinksToMessages {
    return _conversation.username.length != 0;
}

- (SSignal *)applyModerateMessageActions:(NSSet *)actions messageIds:(NSArray *)messageIds {
    NSMutableArray *signals = [[NSMutableArray alloc] init];
    
    TGMessage *anyMessage = [TGDatabaseInstance() loadMessageWithMid:[messageIds[0] intValue] peerId:_conversationId];
    if (anyMessage == nil) {
        return [SSignal fail:nil];
    }
    
    if ([actions containsObject:@(TGMessageModerateActionDeleteAll)]) {
        TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)anyMessage.fromUid];
        if (user != nil) {
            [signals addObject:[[TGChannelManagementSignals removeAllUserMessages:_conversationId accessHash:_accessHash user:user] catch:^SSignal *(__unused id error) {
                return [SSignal complete];
            }]];
        }
    } else if ([actions containsObject:@(TGMessageModerateActionDelete)]) {
        SSignal *signal = [SSignal defer:^SSignal *{
            [self _deleteMessages:messageIds animated:true];
            [self controllerDeletedMessages:messageIds forEveryone:false completion:nil];
            return [SSignal complete];
        }];
        [signals addObject:signal];
    }
    
    if ([actions containsObject:@(TGMessageModerateActionReport)]) {
        TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)anyMessage.fromUid];
        if (user != nil) {
            SSignal *signal = [[TGChannelManagementSignals reportUserSpam:_conversationId accessHash:_accessHash user:user messageIds:messageIds] catch:^SSignal *(__unused id error) {
                return [SSignal complete];
            }];
            [signals addObject:signal];
        }
    }
    
    if ([actions containsObject:@(TGMessageModerateActionBan)]) {
        TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)anyMessage.fromUid];
        if (user != nil) {
            TGChannelBannedRights *rights = [[TGChannelBannedRights alloc] initWithBanReadMessages:true banSendMessages:true banSendMedia:true banSendStickers:true banSendGifs:false banSendGames:false banSendInline:false banEmbedLinks:true timeout:INT32_MAX];
            SSignal *signal = [[[TGChannelManagementSignals updateChannelBannedRightsAndGetMembership:_conversationId accessHash:_accessHash user:user rights:rights] onNext:^(TGCachedConversationMember *resultMember) {
                [TGDatabaseInstance() updateChannelCachedData:_conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                    if (data == nil) {
                        data = [[TGCachedConversationData alloc] init];
                    }
                    
                    return [data updateMemberBannedRights:user.uid rights:rights timestamp:resultMember != nil ? resultMember.timestamp : (int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] isMember:resultMember != nil kickedById:TGTelegraphInstance.clientUserId];
                }];
            }] catch:^SSignal *(__unused id error) {
                return [SSignal complete];
            }];
            [signals addObject:signal];
        }
    }
    
    return [SSignal combineSignals:signals];
}

- (bool)canReportMessage:(TGMessage *)message {
    if (message.cid != _conversationId) {
        return false;
    }
    
    if (TGMessageSortKeySpace(message.sortKey) != TGMessageSpaceUnimportant) {
        return false;
    }
    
    if (message.actionInfo != nil) {
        return false;
    }
    
    if (!message.outgoing) {
        return true;
    }
    return false;
}

- (void)contactLinkTitlePanelBlockContactPressed:(TGModernConversationContactLinkTitlePanel *)__unused panel {
    SMetaDisposable *metaDisposable = [[SMetaDisposable alloc] init];
    id<SDisposable> disposable = [[[TGServiceSignals reportSpam:_conversationId accessHash:_accessHash] onDispose:^{
        [TGTelegraphInstance.disposeOnLogout remove:metaDisposable];
    }] startWithNext:nil];
    [metaDisposable setDisposable:disposable];
    [TGTelegraphInstance.disposeOnLogout add:metaDisposable];
    
    [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_conversationId unreadCount:0 serviceUnreadCount:0] animated:false];
    
    TGModernConversationController *controller = self.controller;
    [controller.navigationController popToRootViewControllerAnimated:true];
}

- (void)contactLinkTitlePanelDismissed:(TGModernConversationContactLinkTitlePanel *)__unused panel {
    [TGDatabaseInstance() hideReportSpamForPeerId:_conversationId];
}

- (void)reportChannelPressed {
    TGModernConversationController *controller = self.controller;
    __weak TGChannelConversationCompanion *weakSelf = self;
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
    [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ReportPeer.ReasonSpam") action:@"spam"],
    [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ReportPeer.ReasonViolence") action:@"violence"],
    [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ReportPeer.ReasonPornography") action:@"pornography"],
    [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"ReportPeer.ReasonOther") action:@"other"],
    [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]] actionBlock:^(__unused id target, NSString *action) {
        __strong TGChannelConversationCompanion *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (![action isEqualToString:@"cancel"]) {
                TGReportPeerReason reason = TGReportPeerReasonSpam;
                if ([action isEqualToString:@"spam"]) {
                    reason = TGReportPeerReasonSpam;
                } else if ([action isEqualToString:@"violence"]) {
                    reason = TGReportPeerReasonViolence;
                } else if ([action isEqualToString:@"pornography"]) {
                    reason = TGReportPeerReasonPornography;
                } else if ([action isEqualToString:@"other"]) {
                    reason = TGReportPeerReasonOther;
                }
                
                void (^reportBlock)(NSString *) = ^(NSString *otherText) {
                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                    [progressWindow showWithDelay:0.1];
                    
                    [[[[TGAccountSignals reportPeer:strongSelf->_conversation.conversationId accessHash:strongSelf->_conversation.accessHash reason:reason otherText:otherText] deliverOn:[SQueue mainQueue]] onDispose:^{
                        TGDispatchOnMainThread(^{
                            [progressWindow dismiss:true];
                        });
                    }] startWithNext:nil error:^(__unused id error) {
                        if (NSClassFromString(@"UIAlertController") != nil) {
                            
                        } else {
                            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"TwoStepAuth.GenericError") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                        }
                    } completed:^{
                        __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            TGModernConversationController *controller = strongSelf.controller;
                            [controller dismissViewControllerAnimated:true completion:nil];
                        }
                        
                        if (NSClassFromString(@"UIAlertController") != nil) {
                            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:TGLocalized(@"ReportPeer.AlertSuccess") preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:TGLocalized(@"Common.OK") style:UIAlertActionStyleDefault handler:nil];
                            [alertVC addAction:doneAction];
                            
                            TGModernConversationController *myController = strongSelf.controller;
                            [myController presentViewController:alertVC animated:true completion:nil];
                        } else {
                            [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"ReportPeer.AlertSuccess") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                        }
                    }];
                };
                
                if (reason == TGReportPeerReasonOther) {
                    TGReportPeerOtherTextController *controller = [[TGReportPeerOtherTextController alloc] initWithCompletion:^(NSString *text) {
                        if (text.length != 0) {
                            reportBlock(text);
                        }
                    }];
                    __strong TGChannelConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        TGModernConversationController *myController = strongSelf.controller;
                        [myController presentViewController:[TGNavigationController navigationControllerWithControllers:@[controller]] animated:true completion:nil];
                    }
                } else {
                    reportBlock(nil);
                }
            }
        }
    } target:self] showInView:controller.view];
}

- (void)updateMessagesLive:(NSDictionary *)messageIdToMessage animated:(bool)animated {
    [super updateMessagesLive:messageIdToMessage animated:animated];
    
    TGDispatchOnMainThread(^{
        if (_pinnedMessagePanel != nil && messageIdToMessage[@(_pinnedMessagePanel.message.mid)] != nil){
            TGMessage *message = messageIdToMessage[@(_pinnedMessagePanel.message.mid)];
            [_pinnedMessagePanel updateMessage:message];
        }
    });
}

- (SSignal *)primaryTitlePanel {
    return _primaryPanel.signal;
}

- (TGModernGalleryController *)galleryControllerForAvatar
{
    if (_conversation.chatPhotoSmall.length == 0)
        return nil;
    
    TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
    modernGallery.model = [[TGGroupAvatarGalleryModel alloc] initWithPeerId:_conversationId accessHash:_accessHash messageId:0 legacyThumbnailUrl:_conversation.chatPhotoSmall legacyUrl:_conversation.chatPhotoBig imageSize:CGSizeMake(640.0f, 640.0f)];
    
    return modernGallery;
}

- (id)acquireAudioRecordingActivityHolder {
    if (_isGroup) {
        return [super acquireAudioRecordingActivityHolder];
    }
    return nil;
}

- (id)acquireVideoMessageRecordingActivityHolder {
    if (_isGroup) {
        return [super acquireVideoMessageRecordingActivityHolder];
    }
    return nil;
}

- (bool)canSendMedia {
    return !_bannedRights.banSendMedia;
}

- (bool)canSendGifs {
    return !_bannedRights.banSendGifs;
}

- (bool)canSendGames {
    return !_bannedRights.banSendGames;
}

- (bool)canSendInline {
    return !_bannedRights.banSendInline;
}

- (bool)canSendStickers {
    return !_bannedRights.banSendStickers;
}

- (bool)canAttachLinkPreviews {
    return !_bannedRights.banEmbedLinks;
}

- (NSNumber *)inlineMediaRestrictionTimeout {
    if (_bannedRights != nil && _bannedRights.banSendInline) {
        return @(_bannedRights.timeout);
    }
    return nil;
}

- (NSNumber *)mediaRestrictionTimeout {
    if (_bannedRights != nil && _bannedRights.banSendMedia) {
        return @(_bannedRights.timeout);
    }
    return nil;
}

- (NSNumber *)stickerRestrictionTimeout {
    if (_bannedRights != nil && _bannedRights.banSendStickers) {
        return @(_bannedRights.timeout);
    }
    return nil;
}

@end
