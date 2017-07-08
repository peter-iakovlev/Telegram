#import "TGAdminLogConversationCompanion.h"

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

#import "TGServiceSignals.h"
#import "TGRecentContextBotsSignal.h"
#import "TGActionSheet.h"

#import "TGReportPeerOtherTextController.h"

#import "TGModernGalleryController.h"
#import "TGGroupAvatarGalleryModel.h"

#import "TGGroupManagementSignals.h"

#import "TGChannelAdminLogFilterController.h"

#import "TGNavigationController.h"

#import "TGChannelAdminLogEmptyView.h"

#import "TGLocalization.h"

#import "TGPeerIdAdapter.h"

#import "TGChannelBanController.h"

static bool isEventFilterAllSet(TGChannelEventFilter filter) {
    if (!filter.join) {
        return false;
    }
    if (!filter.leave) {
        return false;
    }
    if (!filter.invite) {
        return false;
    }
    if (!filter.ban) {
        return false;
    }
    if (!filter.unban) {
        return false;
    }
    if (!filter.kick) {
        return false;
    }
    if (!filter.unkick) {
        return false;
    }
    if (!filter.promote) {
        return false;
    }
    if (!filter.demote) {
        return false;
    }
    if (!filter.info) {
        return false;
    }
    if (!filter.settings) {
        return false;
    }
    if (!filter.pinned) {
        return false;
    }
    if (!filter.edit) {
        return false;
    }
    if (!filter.del) {
        return false;
    }
    return true;
}

@interface TGAdminLogConversationCompanion () <TGModernConversationContactLinkTitlePanelDelegate> {
    TGConversation *_conversation;
    int64_t _nativeConversationId;
    bool _isChannelGroup;
    
    bool _loadingHistoryAbove;
    bool _loadingHistoryBelow;
    
    bool _historyAbove;
    bool _historyBelow;
    
    int32_t _minMessageId;
    int64_t _minEntryId;
    
    TGModernConversationActionInputPanel *_joinChannelPanel; // Main Thread
    
    SMetaDisposable *_requestDisposable;
    
    NSString *_currentSearchQuery;
    TGChannelEventFilter _eventFilter;
    NSArray<NSNumber *> *_usersFilter;
    
    NSArray<TGCachedConversationMember *> *_adminMembers;
}

@end

@implementation TGAdminLogConversationCompanion

- (instancetype)initWithConversation:(TGConversation *)conversation {
    self = [super initWithConversation:conversation mayHaveUnreadMessages:false];
    if (self != nil) {
        _conversation = conversation;
        int32_t randomId = ABS((int32_t)(arc4random()));
        _nativeConversationId = TGPeerIdFromAdminLogId(randomId);
        _conversationId = _nativeConversationId;
        
        _accessHash = conversation.accessHash;
        _isChannelGroup = conversation.isChannelGroup;
        
        _manualMessageManagement = true;
        _everyMessageNeedsAuthor = true;
        
        _requestDisposable = [[SMetaDisposable alloc] init];
        
        _minMessageId = 1000000;
        
        _eventFilter.join = true;
        _eventFilter.leave= true;
        _eventFilter.invite= true;
        _eventFilter.ban= true;
        _eventFilter.unban= true;
        _eventFilter.kick= true;
        _eventFilter.unkick= true;
        _eventFilter.promote= true;
        _eventFilter.demote= true;
        _eventFilter.info= true;
        _eventFilter.settings= true;
        _eventFilter.pinned= true;
        _eventFilter.edit= true;
        _eventFilter.del= true;
        
        TGCachedConversationData *data = [TGDatabaseInstance() _channelCachedDataSync:conversation.conversationId];
        _adminMembers = data.managementMembers;
    }
    return self;
}

- (void)dealloc {
    [_requestDisposable dispose];
}

- (void)_controllerDidAppear:(bool)firstTime {
    [super _controllerDidAppear:firstTime];
    
    if (firstTime) {
        [TGModernConversationCompanion dispatchOnMessageQueue:^{
            //[self _updateVisibleHoles];
        }];
    }
}

- (void)_controllerAvatarPressed
{
    TGModernConversationController *controller = self.controller;
    TGCollectionMenuController *groupInfoController = nil;
    if (_conversation.isChannelGroup) {
        groupInfoController = [[TGChannelGroupInfoController alloc] initWithPeerId:_conversation.conversationId];
    } else {
        groupInfoController = [[TGChannelInfoController alloc] initWithPeerId:_conversation.conversationId];
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

- (void)_loadControllerPrimaryTitlePanel {
}

- (TGModernConversationInputPanel *)_conversationGenericInputPanel {
    if (_joinChannelPanel == nil) {
        TGModernConversationController *controller = self.controller;
        _joinChannelPanel = [[TGModernConversationActionInputPanel alloc] init];
        [_joinChannelPanel setActionWithTitle:TGLocalized(@"Channel.AdminLog.InfoPanelTitle") action:@"info" color:TGAccentColor() icon:TGModernConversationActionInputPanelIconNone];
        _joinChannelPanel.companionHandle = self.actionHandle;
        _joinChannelPanel.delegate = controller;
    }
    return _joinChannelPanel;
}

- (TGModernConversationInputPanel *)_conversationEmptyListInputPanel {
    if (_joinChannelPanel == nil) {
        TGModernConversationController *controller = self.controller;
        _joinChannelPanel = [[TGModernConversationActionInputPanel alloc] init];
        [_joinChannelPanel setActionWithTitle:TGLocalized(@"Channel.AdminLog.InfoPanelTitle") action:@"info" color:TGAccentColor() icon:TGModernConversationActionInputPanelIconNone];
        _joinChannelPanel.companionHandle = self.actionHandle;
        _joinChannelPanel.delegate = controller;
    }
    return _joinChannelPanel;
}

- (TGModernConversationEmptyListPlaceholderView *)_conversationEmptyListPlaceholder
{
    TGChannelAdminLogEmptyFilter *filter = nil;
    
    if (_currentSearchQuery.length != 0 || !isEventFilterAllSet(_eventFilter) || _usersFilter != nil) {
        filter = [[TGChannelAdminLogEmptyFilter alloc] initWithQuery:_currentSearchQuery];
    }
    return [[TGChannelAdminLogEmptyView alloc] initWithFilter:filter];
}

- (bool)canPostMessages {
    return false;
}

- (void)_updateJoinPanel {
    TGModernConversationController *controller = self.controller;
    [controller setDefaultInputPanel:[self _conversationGenericInputPanel]];
}

- (NSString *)formatLocalizedString:(NSString *)string data:(NSArray *)data entities:(NSMutableArray *)entities {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableArray *rangeList = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int)data.count; i++) {
        NSString *s = [NSString stringWithFormat:@"%%%d$@", i + 1];
        NSRange range = [string rangeOfString:s];
        if (range.location == NSNotFound) {
            break;
        }
        [rangeList addObject:@{@"index": @(i), @"range": [NSValue valueWithRange:range]}];
    }
    [rangeList sortUsingComparator:^NSComparisonResult(NSDictionary *lhs, NSDictionary *rhs) {
        NSRange lhsRange = [(NSValue *)lhs[@"range"] rangeValue];
        NSRange rhsRange = [(NSValue *)rhs[@"range"] rangeValue];
        if (lhsRange.location < rhsRange.location) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    NSUInteger offset = 0;
    for (NSDictionary *info in rangeList) {
        NSRange range = [(NSValue *)info[@"range"] rangeValue];
        int index = [info[@"index"] intValue];
        if (offset < range.location) {
            [result appendString:[string substringWithRange:NSMakeRange(offset, range.location - offset)]];
        }
        offset = range.location + range.length;
        NSDictionary *dict = data[index];
        if (dict[@"name"] != nil) {
            TGUser *user = (TGUser *)dict[@"name"];
            NSString *name = user.displayName;
            [entities addObject:[[TGMessageEntityMentionName alloc] initWithRange:NSMakeRange(result.length, name.length) userId:user.uid]];
            [result appendString:name];
        } else if (dict[@"username"] != nil) {
            TGUser *user = (TGUser *)dict[@"username"];
            NSString *name = [@"@" stringByAppendingString:user.userName];
            [entities addObject:[[TGMessageEntityMention alloc] initWithRange:NSMakeRange(result.length, name.length)]];
            [result appendString:name];
        } else if (dict[@"text"] != nil) {
            NSString *text = dict[@"text"];
            [result appendString:text];
        }
    }
    if (offset < string.length) {
        [result appendString:[string substringFromIndex:offset]];
    }
    return result;
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options {
    if ([action isEqualToString:@"actionPanelAction"]) {
        NSString *panelAction = options[@"action"];
        if ([panelAction isEqualToString:@"info"]) {
            [TGAlertView presentAlertWithTitle:TGLocalized(@"Channel.AdminLog.InfoPanelAlertTitle") message:[@"\n" stringByAppendingString:TGLocalized(@"Channel.AdminLog.InfoPanelAlertText")] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
        }
    }
    
    [super actionStageActionRequested:action options:options];
}

- (void)loadInitialState {
    [super loadInitialState:false];
    
    TGModernConversationController *controller = self.controller;
    [controller setIsChannel:true];
    [controller setConversationHeader:[self _conversationHeader]];
    
    self.viewContext.isPublicGroup = _conversation.isChannelGroup && _conversation.username.length != 0;
    self.viewContext.isAdminLog = true;
    self.viewContext.adminLogIsGroup = _conversation.isChannelGroup;
    
    self.viewContext.conversation = _conversation;
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^{
        
    } synchronous:true];
    
    _historyAbove = false;
    self.viewContext.commandsEnabled = false;
    
    self.useInitialSnapshot = false;
    [self _setTitle:TGLocalized(@"Channel.AdminLog.TitleAllEvents") andStatus:@"" accentColored:false allowAnimatioon:false toggleMode:[self currentToggleMode]];
    [self _setAvatarConversationId:_conversation.conversationId title:_conversation.chatTitle icon:nil];
    [self _setAvatarUrl:_conversation.chatPhotoSmall];
    
    [controller setLoadingMessages:true];
    [self loadMoreImpl:true];
}

- (void)loadMoreImpl:(bool)replace {
    _historyAbove = false;
    
    __weak TGAdminLogConversationCompanion *weakSelf = self;
    [self.controller setEnableAboveHistoryRequests:false];
    
    [_requestDisposable setDisposable:[[TGChannelManagementSignals channelAdminLogEvents:_conversation.conversationId accessHash:_accessHash minEntryId:replace ? 0 : _minEntryId count:100 filter:_eventFilter searchQuery:_currentSearchQuery userIds:_usersFilter] startWithNext:^(NSArray<TGChannelAdminLogEntry *> *entries) {
        [TGModernConversationCompanion dispatchOnMessageQueue:^{
            __strong TGAdminLogConversationCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                NSMutableArray *messages = [[NSMutableArray alloc] init];
                
                int32_t messageId = replace ? 1000000 : strongSelf->_minMessageId;
                int64_t minEntryId = 0;
                int64_t currentMinEntryId = replace ? 0 : strongSelf->_minEntryId;
                for (TGChannelAdminLogEntry *entry in entries) { 
                    if (currentMinEntryId != 0 && entry.entryId >= currentMinEntryId) {
                        continue;
                    }
                    TGMessage *message = [[TGMessage alloc] init];
                    message.date = entry.timestamp;
                    message.cid = strongSelf->_nativeConversationId;
                    message.fromUid = entry.userId;
                    minEntryId = entry.entryId;
                    
                    id<TGChannelAdminLogEntryContent> content = entry.content;
                    if ([content isKindOfClass:[TGChannelAdminLogEntryChangeTitle class]]) {
                        TGChannelAdminLogEntryChangeTitle *value = (TGChannelAdminLogEntryChangeTitle *)content;
                        
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionChatEditTitle;
                        action.actionData = @{@"title": value.title};
                        message.mediaAttachments = @[action];
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryChangeAbout class]]) {
                        TGChannelAdminLogEntryChangeAbout *value = (TGChannelAdminLogEntryChangeAbout *)content;
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionCustom;
                        action.actionData = @{@"adminLogEntryContent": content};
                        message.mediaAttachments = @[action];
                        
                        TGMessage *detailMessage = [[TGMessage alloc] init];
                        detailMessage.date = entry.timestamp;
                        detailMessage.cid = strongSelf->_nativeConversationId;
                        detailMessage.fromUid = entry.userId;
                        detailMessage.outgoing = false;
                        detailMessage.text = value.about;
                        
                        if (value.previousAbout.length != 0) {
                            TGWebPageMediaAttachment *originalMedia = [[TGWebPageMediaAttachment alloc] init];
                            originalMedia.pageType = @"message";
                            originalMedia.pageDescription = value.previousAbout;
                            originalMedia.siteName = TGLocalized(@"Channel.AdminLog.MessagePreviousDescription");
                            detailMessage.mediaAttachments = @[originalMedia];
                        }
                        
                        messageId -= 1;
                        detailMessage.mid = messageId;
                        
                        [messages addObject:detailMessage];
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryChangeUsername class]]) {
                        TGChannelAdminLogEntryChangeUsername *value = (TGChannelAdminLogEntryChangeUsername *)content;
                        
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionCustom;
                        action.actionData = @{@"adminLogEntryContent": content};
                        message.mediaAttachments = @[action];
                        
                        TGMessage *detailMessage = [[TGMessage alloc] init];
                        detailMessage.date = entry.timestamp;
                        detailMessage.cid = strongSelf->_nativeConversationId;
                        detailMessage.fromUid = entry.userId;
                        detailMessage.outgoing = false;
                        if (value.username.length != 0) {
                            detailMessage.text = [@"https://t.me/" stringByAppendingString:value.username];
                        }
                        
                        if (value.previousUsername.length != 0) {
                            TGWebPageMediaAttachment *originalMedia = [[TGWebPageMediaAttachment alloc] init];
                            originalMedia.pageType = @"message";
                            originalMedia.pageDescription = [@"https://t.me/" stringByAppendingString:value.previousUsername];
                            originalMedia.siteName = TGLocalized(@"Channel.AdminLog.MessagePreviousLink");
                            detailMessage.mediaAttachments = @[originalMedia];
                        }
                        
                        messageId -= 1;
                        detailMessage.mid = messageId;
                        
                        [messages addObject:detailMessage];
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryChangePhoto class]]) {
                        TGChannelAdminLogEntryChangePhoto *value = (TGChannelAdminLogEntryChangePhoto *)content;
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionChatEditPhoto;
                        if (value.photo != nil) {
                            action.actionData = @{@"photo": value.photo};
                        }
                        message.mediaAttachments = @[action];
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryChangeInvites class]]) {
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionCustom;
                        action.actionData = @{@"adminLogEntryContent": content};
                        message.mediaAttachments = @[action];
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryChangeSignatures class]]) {
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionCustom;
                        action.actionData = @{@"adminLogEntryContent": content};
                        message.mediaAttachments = @[action];
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryChangePinnedMessage class]]) {
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionCustom;
                        action.actionData = @{@"adminLogEntryContent": content};
                        message.mediaAttachments = @[action];
                        if (((TGChannelAdminLogEntryChangePinnedMessage *)content).message != nil) {
                            TGMessage *deletedMessage = [((TGChannelAdminLogEntryChangePinnedMessage *)content).message copy];
                            [deletedMessage removeReplyAndMarkup];
                            if (deletedMessage != nil) {
                                deletedMessage.date = entry.timestamp;
                                deletedMessage.cid = strongSelf->_nativeConversationId;
                                deletedMessage.fromUid = entry.userId;
                                deletedMessage.outgoing = false;
                                
                                
                                messageId -= 1;
                                deletedMessage.mid = messageId;
                                
                                [messages addObject:deletedMessage];
                            }
                        }
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryEditMessage class]]) {
                        TGChannelAdminLogEntryEditMessage *value = (TGChannelAdminLogEntryEditMessage *)content;
                        
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionCustom;
                        action.actionData = @{@"adminLogEntryContent": content};
                        message.mediaAttachments = @[action];
                        
                        TGMessage *editedMessage = [((TGChannelAdminLogEntryEditMessage *)content).message copy];
                        if (editedMessage != nil) {
                            editedMessage.date = entry.timestamp;
                            editedMessage.cid = strongSelf->_nativeConversationId;
                            editedMessage.outgoing = false;
                            
                            editedMessage.isEdited = false;
                            
                            messageId -= 1;
                            editedMessage.mid = messageId;
                            
                            TGWebPageMediaAttachment *originalMedia = [[TGWebPageMediaAttachment alloc] init];
                            originalMedia.pageType = @"message";
                            
                            
                            
                            NSArray *previous = [value.previousMessage effectiveTextAndEntities];
                            if (((NSString *)previous.firstObject).length == 0) {
                                NSString *emptyString = TGLocalized(@"Channel.AdminLog.EmptyMessageText");
                                originalMedia.pageDescription = emptyString;
                                originalMedia.pageDescriptionEntities = @[[[TGMessageEntityItalic alloc] initWithRange:NSMakeRange(0, emptyString.length)]];
                            } else {
                                NSMutableArray *entities = [[NSMutableArray alloc] initWithArray:previous[1]];
                                originalMedia.pageDescription = previous.firstObject;
                                originalMedia.pageDescriptionEntities = entities;
                            }
                            bool isCaption = false;
                            for (id media in value.previousMessage.mediaAttachments) {
                                if ([media isKindOfClass:[TGImageMediaAttachment class]]) {
                                    isCaption = true;
                                } else if ([media isKindOfClass:[TGVideoMediaAttachment class]]) {
                                    isCaption = true;
                                } else if ([media isKindOfClass:[TGAudioMediaAttachment class]]) {
                                    isCaption = true;
                                } else if ([media isKindOfClass:[TGDocumentMediaAttachment class]]) {
                                    isCaption = true;
                                }
                            }
                            if (isCaption) {
                                originalMedia.siteName = TGLocalized(@"Channel.AdminLog.MessagePreviousCaption");
                            } else {
                                originalMedia.siteName = TGLocalized(@"Channel.AdminLog.MessagePreviousMessage");
                            }
                            NSMutableArray *medias = [[NSMutableArray alloc] init];
                            if (editedMessage.mediaAttachments != nil) {
                                [medias addObjectsFromArray:editedMessage.mediaAttachments];
                            }
                            [medias addObject:originalMedia];
                            editedMessage.mediaAttachments = medias;
                            
                            [editedMessage removeReplyAndMarkup];
                            
                            [messages addObject:editedMessage];
                        }
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryDeleteMessage class]]) {
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionCustom;
                        action.actionData = @{@"adminLogEntryContent": content};
                        message.mediaAttachments = @[action];
                        
                        TGMessage *deletedMessage = [((TGChannelAdminLogEntryDeleteMessage *)content).message copy];
                        [deletedMessage removeReplyAndMarkup];
                        if (deletedMessage != nil) {
                            deletedMessage.date = entry.timestamp;
                            deletedMessage.cid = strongSelf->_nativeConversationId;
                            deletedMessage.outgoing = false;
                            
                            deletedMessage.isEdited = false;
                            
                            messageId -= 1;
                            deletedMessage.mid = messageId;
                            
                            [messages addObject:deletedMessage];
                        }
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryJoin class]]) {
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionChatAddMember;
                        action.actionData = @{@"uid": @(entry.userId)};
                        message.mediaAttachments = @[action];
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryLeave class]]) {
                        TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                        action.actionType = TGMessageActionChatDeleteMember;
                        action.actionData = @{@"uid": @(entry.userId)};
                        message.mediaAttachments = @[action];
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryInvite class]]) {
                        TGChannelAdminLogEntryInvite *value = (TGChannelAdminLogEntryInvite *)content;
                        
                        TGUser *user = [TGDatabaseInstance() loadUser:value.userId];
                        if (user != nil) {
                            NSString *format = @"";
                            NSMutableArray *data = [[NSMutableArray alloc] init];
                            [data addObject:@{@"name": user}];
                            if (user.userName.length != 0) {
                                format = TGLocalized(@"Channel.AdminLog.MessageInvitedNameUsername");
                                [data addObject:@{@"username": user}];
                            } else {
                                format = TGLocalized(@"Channel.AdminLog.MessageInvitedName");
                            }
                            NSMutableArray *entities = [[NSMutableArray alloc] init];
                            
                            message.text = [self formatLocalizedString:format data:data entities:entities];
                            
                            [entities addObject:[[TGMessageEntityItalic alloc] initWithRange:NSMakeRange(0, message.text.length)]];
                            
                            TGMessageEntitiesAttachment *entitiesAttachment = [[TGMessageEntitiesAttachment alloc] init];
                            entitiesAttachment.entities = entities;
                            message.mediaAttachments = @[entitiesAttachment];
                        } else {
                            TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                            action.actionType = TGMessageActionChatAddMember;
                            action.actionData = @{@"uid": @(value.userId)};
                            message.mediaAttachments = @[action];
                        }
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryToggleBan class]]) {
                        TGChannelAdminLogEntryToggleBan *value = (TGChannelAdminLogEntryToggleBan *)content;
                        
                        if (!value.previousRights.banReadMessages && value.rights.banReadMessages) {
                            TGUser *user = [TGDatabaseInstance() loadUser:value.userId];
                            if (user != nil) {
                                NSString *format = @"";
                                NSMutableArray *data = [[NSMutableArray alloc] init];
                                [data addObject:@{@"name": user}];
                                if (user.userName.length != 0) {
                                    format = TGLocalized(@"Channel.AdminLog.MessageKickedNameUsername");
                                    [data addObject:@{@"username": user}];
                                } else {
                                    format = TGLocalized(@"Channel.AdminLog.MessageKickedName");
                                }
                                NSMutableArray *entities = [[NSMutableArray alloc] init];
                                
                                message.text = [self formatLocalizedString:format data:data entities:entities];
                                
                                [entities addObject:[[TGMessageEntityItalic alloc] initWithRange:NSMakeRange(0, message.text.length)]];
                                
                                TGMessageEntitiesAttachment *entitiesAttachment = [[TGMessageEntitiesAttachment alloc] init];
                                entitiesAttachment.entities = entities;
                                message.mediaAttachments = @[entitiesAttachment];
                            } else {
                                TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                                action.actionType = TGMessageActionChatDeleteMember;
                                action.actionData = @{@"uid": @(value.userId)};
                                message.mediaAttachments = @[action];
                            }
                        } else {
                            TGUser *user = [TGDatabaseInstance() loadUser:value.userId];
                            if (user != nil) {
                                NSString *format = @"";
                                NSMutableArray *data = [[NSMutableArray alloc] init];
                                [data addObject:@{@"name": user}];
                                if (user.userName.length != 0) {
                                    format = TGLocalized(@"Channel.AdminLog.MessageRestrictedNameUsername");
                                    [data addObject:@{@"username": user}];
                                } else {
                                    format = TGLocalized(@"Channel.AdminLog.MessageRestrictedName");
                                }
                                
                                NSMutableArray *entities = [[NSMutableArray alloc] init];
                                
                                NSMutableString *resultText = [[NSMutableString alloc] initWithString:[self formatLocalizedString:format data:data entities:entities]];
                                
                                if (value.rights.timeout != 0 && value.rights.timeout != INT32_MAX) {
                                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                    formatter.locale = [NSLocale localeWithLocaleIdentifier:currentNativeLocalization().code];
                                    [formatter setDateFormat:@"E, d MMM HH:mm"];
                                    formatter.locale = [NSLocale localeWithLocaleIdentifier:effectiveLocalization().code];
                                    NSString *dateStringPlain = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:value.rights.timeout]];
                                    [data addObject:@{@"text": dateStringPlain}];
                                    [resultText appendString:@"\n"];
                                    NSString *restrictedString = @"";
                                    if (value.rights.tlRights.flags != value.previousRights.tlRights.flags) {
                                        restrictedString = [NSString stringWithFormat:TGLocalized(@"Channel.AdminLog.MessageRestrictedUntil"), dateStringPlain];
                                    } else {
                                        restrictedString = [NSString stringWithFormat:TGLocalized(@"Channel.AdminLog.MessageRestrictedNewSetting"), [NSString stringWithFormat:TGLocalized(@"Channel.AdminLog.MessageRestrictedUntil"), dateStringPlain]];
                                    }
                                    [resultText appendString:restrictedString];
                                } else {
                                    [data addObject:@{@"text": @""}];
                                    [resultText appendString:@"\n"];
                                    NSString *restrictedString = @"";
                                    if (value.rights.tlRights.flags != value.previousRights.tlRights.flags) {
                                        restrictedString = TGLocalized(@"Channel.AdminLog.MessageRestrictedForever");
                                    } else {
                                        restrictedString = [NSString stringWithFormat:TGLocalized(@"Channel.AdminLog.MessageRestrictedNewSetting"), TGLocalized(@"Channel.AdminLog.MessageRestrictedForever")];
                                    }
                                    [resultText appendString:restrictedString];
                                }
                                
                                NSMutableString *updates = [[NSMutableString alloc] init];
                                if (value.previousRights.banReadMessages != value.rights.banReadMessages) {
                                    [updates appendString:@"\n"];
                                    if (value.previousRights.banReadMessages) {
                                        [updates appendString:@"+"];
                                    } else {
                                        [updates appendString:@"-"];
                                    }
                                    [updates appendString:TGLocalized(@"Channel.AdminLog.BanReadMessages")];
                                }
                                if (value.previousRights.banSendMessages != value.rights.banSendMessages) {
                                    [updates appendString:@"\n"];
                                    if (value.previousRights.banSendMessages) {
                                        [updates appendString:@"+"];
                                    } else {
                                        [updates appendString:@"-"];
                                    }
                                    [updates appendString:TGLocalized(@"Channel.AdminLog.BanSendMessages")];
                                }
                                if (value.previousRights.banSendMedia != value.rights.banSendMedia) {
                                    [updates appendString:@"\n"];
                                    if (value.previousRights.banSendMedia) {
                                        [updates appendString:@"+"];
                                    } else {
                                        [updates appendString:@"-"];
                                    }
                                    [updates appendString:TGLocalized(@"Channel.AdminLog.BanSendMedia")];
                                }
                                if (value.previousRights.banSendStickers != value.rights.banSendStickers) {
                                    [updates appendString:@"\n"];
                                    if (value.previousRights.banSendStickers) {
                                        [updates appendString:@"+"];
                                    } else {
                                        [updates appendString:@"-"];
                                    }
                                    [updates appendString:TGLocalized(@"Channel.AdminLog.BanSendStickers")];
                                }
                                if (value.previousRights.banSendGifs != value.rights.banSendGifs) {
                                    [updates appendString:@"\n"];
                                    if (value.previousRights.banSendGifs) {
                                        [updates appendString:@"+"];
                                    } else {
                                        [updates appendString:@"-"];
                                    }
                                    [updates appendString:TGLocalized(@"Channel.AdminLog.BanSendGifs")];
                                }
                                if (value.previousRights.banEmbedLinks != value.rights.banEmbedLinks) {
                                    [updates appendString:@"\n"];
                                    if (value.previousRights.banEmbedLinks) {
                                        [updates appendString:@"+"];
                                    } else {
                                        [updates appendString:@"-"];
                                    }
                                    [updates appendString:TGLocalized(@"Channel.AdminLog.BanEmbedLinks")];
                                }
                                
                                if (updates.length != 0) {
                                    [resultText appendFormat:@"\n%@", updates];
                                }
                                
                                message.text = resultText;
                                
                                [entities addObject:[[TGMessageEntityItalic alloc] initWithRange:NSMakeRange(0, message.text.length)]];
                                
                                TGMessageEntitiesAttachment *entitiesAttachment = [[TGMessageEntitiesAttachment alloc] init];
                                entitiesAttachment.entities = entities;
                                message.mediaAttachments = @[entitiesAttachment];
                            } else {
                                TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                                action.actionType = TGMessageActionCustom;
                                action.actionData = @{@"adminLogEntryContent": content, @"uid": @(value.userId)};
                                message.mediaAttachments = @[action];
                            }
                        }
                    } else if ([content isKindOfClass:[TGChannelAdminLogEntryToggleAdmin class]]) {
                        TGChannelAdminLogEntryToggleAdmin *value = (TGChannelAdminLogEntryToggleAdmin *)content;
                        
                        TGUser *user = [TGDatabaseInstance() loadUser:value.userId];
                        if (user != nil) {
                            NSString *format = @"";
                            NSMutableArray *data = [[NSMutableArray alloc] init];
                            [data addObject:@{@"name": user}];
                            if (user.userName.length != 0) {
                                format = TGLocalized(@"Channel.AdminLog.MessagePromotedNameUsername");
                                [data addObject:@{@"username": user}];
                            } else {
                                format = TGLocalized(@"Channel.AdminLog.MessagePromotedName");
                            }
                            
                            NSMutableArray *entities = [[NSMutableArray alloc] init];
                            
                            NSMutableString *resultText = [[NSMutableString alloc] initWithString:[self formatLocalizedString:format data:data entities:entities]];
                            
                            NSMutableString *updates = [[NSMutableString alloc] init];
                            if (value.previousRights.canChangeInfo != value.rights.canChangeInfo) {
                                [updates appendString:@"\n"];
                                if (value.previousRights.canChangeInfo) {
                                    [updates appendString:@"-"];
                                } else {
                                    [updates appendString:@"+"];
                                }
                                [updates appendString:TGLocalized(@"Channel.AdminLog.CanChangeInfo")];
                            }
                            if (value.previousRights.canPostMessages != value.rights.canPostMessages) {
                                [updates appendString:@"\n"];
                                if (value.previousRights.canPostMessages) {
                                    [updates appendString:@"-"];
                                } else {
                                    [updates appendString:@"+"];
                                }
                                [updates appendString:TGLocalized(@"Channel.AdminLog.CanSendMessages")];
                            }
                            if (value.previousRights.canDeleteMessages != value.rights.canDeleteMessages) {
                                [updates appendString:@"\n"];
                                if (value.previousRights.canDeleteMessages) {
                                    [updates appendString:@"-"];
                                } else {
                                    [updates appendString:@"+"];
                                }
                                [updates appendString:TGLocalized(@"Channel.AdminLog.CanDeleteMessages")];
                            }
                            if (_isChannelGroup && value.previousRights.canBanUsers != value.rights.canBanUsers) {
                                [updates appendString:@"\n"];
                                if (value.previousRights.canBanUsers) {
                                    [updates appendString:@"-"];
                                } else {
                                    [updates appendString:@"+"];
                                }
                                [updates appendString:TGLocalized(@"Channel.AdminLog.CanBanUsers")];
                            }
                            if (value.previousRights.canEditMessages != value.rights.canEditMessages) {
                                [updates appendString:@"\n"];
                                if (value.previousRights.canEditMessages) {
                                    [updates appendString:@"-"];
                                } else {
                                    [updates appendString:@"+"];
                                }
                                [updates appendString:TGLocalized(@"Channel.AdminLog.CanEditMessages")];
                            }
                            if (value.previousRights.canInviteUsers != value.rights.canInviteUsers) {
                                [updates appendString:@"\n"];
                                if (value.previousRights.canInviteUsers) {
                                    [updates appendString:@"-"];
                                } else {
                                    [updates appendString:@"+"];
                                }
                                [updates appendString:TGLocalized(@"Channel.AdminLog.CanInviteUsers")];
                            }
                            if (value.previousRights.canChangeInviteLink != value.rights.canChangeInviteLink) {
                                [updates appendString:@"\n"];
                                if (value.previousRights.canChangeInviteLink) {
                                    [updates appendString:@"-"];
                                } else {
                                    [updates appendString:@"+"];
                                }
                                [updates appendString:TGLocalized(@"Channel.AdminLog.CanChangeInviteLink")];
                            }
                            if (_isChannelGroup && value.previousRights.canPinMessages != value.rights.canPinMessages) {
                                [updates appendString:@"\n"];
                                if (value.previousRights.canPinMessages) {
                                    [updates appendString:@"-"];
                                } else {
                                    [updates appendString:@"+"];
                                }
                                [updates appendString:TGLocalized(@"Channel.AdminLog.CanPinMessages")];
                            }
                            if (value.previousRights.canAddAdmins != value.rights.canAddAdmins) {
                                [updates appendString:@"\n"];
                                if (value.previousRights.canAddAdmins) {
                                    [updates appendString:@"-"];
                                } else {
                                    [updates appendString:@"+"];
                                }
                                [updates appendString:TGLocalized(@"Channel.AdminLog.CanAddAdmins")];
                            }
                            
                            if (updates.length != 0) {
                                [resultText appendFormat:@"\n%@", updates];
                            }
                            
                            message.text = resultText;
                            
                            [entities addObject:[[TGMessageEntityItalic alloc] initWithRange:NSMakeRange(0, message.text.length)]];
                            
                            TGMessageEntitiesAttachment *entitiesAttachment = [[TGMessageEntitiesAttachment alloc] init];
                            entitiesAttachment.entities = entities;
                            message.mediaAttachments = @[entitiesAttachment];
                        } else {
                            TGActionMediaAttachment *action = [[TGActionMediaAttachment alloc] init];
                            action.actionType = TGMessageActionCustom;
                            action.actionData = @{@"adminLogEntryContent": content, @"uid": @(value.userId)};
                            message.mediaAttachments = @[action];
                        }
                    }
                    
                    messageId -= 1;
                    message.mid = messageId;
                    
                    [messages addObject:message];
                }
                
                strongSelf->_minMessageId = messageId;
                if (minEntryId != 0) {
                    strongSelf->_minEntryId = minEntryId;
                }
                if (replace) {
                    [strongSelf _replaceMessages:messages];
                } else {
                    [strongSelf _addMessages:messages animated:false intent:TGModernConversationAddMessageIntentLoadMoreMessagesAbove];
                }
                
                strongSelf->_historyAbove = messages.count != 0;
                
                [self updateControllerEmptyState:true];
                
                TGDispatchOnMainThread(^{
                    [strongSelf.controller setLoadingMessages:false];
                    
                    [strongSelf.controller setEnableAboveHistoryRequests:messages.count != 0];
                });
            }
        }];
    }]];
}

- (TGModernConversationControllerTitleToggle)currentToggleMode {
    return TGModernConversationControllerTitleToggleNone;
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

- (void)subscribeToUpdates
{
    [ActionStageInstance() watchForPaths:@[
                                           [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversation.conversationId],
                                           ] watcher:self];
    
    
    [super subscribeToUpdates];
}

- (void)loadMoreMessagesAbove {
    if (_historyAbove) {
        [self loadMoreImpl:false];
    }
}

- (void)loadMoreMessagesBelow {
    int count = 100;
    
    TGModernConversationController *controller = self.controller;
    [controller setEnableBelowHistoryRequests:false];
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^{
        if (!_loadingHistoryBelow) {
            if (_historyBelow) {
                /*TGMessageTransparentSortKey minKey = TGMessageTransparentSortKeyLowerBound(_conversationId);
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
                }];*/
            }
        } else {
            [self _updateControllerHistoryRequestsFlags];
        }
    }];
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

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments {
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversation.conversationId]]) {
        TGConversation *conversation = ((SGraphObjectNode *)resource).object;
        _conversation = conversation;
        
        TGDispatchOnMainThread(^{
            TGModernConversationController *controller = self.controller;
            
            [self _setAvatarConversationId:_conversation.conversationId title:conversation.chatTitle icon:nil];
            [self _setAvatarUrl:conversation.chatPhotoSmall];
        });
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

- (NSString *)_controllerInfoButtonText {
    if (_conversation.isChannelGroup) {
        return TGLocalized(@"Conversation.InfoGroup");
    } else {
        return TGLocalized(@"Conversation.InfoChannel");
    }
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

- (void)_performFastScrollDown:(bool)becauseOfSendTextAction becauseOfNavigation:(bool)becauseOfNavigation {
}

- (bool)shouldFastScrollDown {
    return _historyBelow;
}

- (bool)canAddNewMessagesToTop {
    return !_historyBelow;
}

- (bool)canCreateLinksToMessages {
    return false;
}

- (bool)canReportMessage:(TGMessage *)__unused message {
    return false;
}

- (TGModernGalleryController *)galleryControllerForAvatar
{
    if (_conversation.chatPhotoSmall.length == 0)
        return nil;
    
    TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
    modernGallery.model = [[TGGroupAvatarGalleryModel alloc] initWithPeerId:_conversation.conversationId accessHash:_accessHash messageId:0 legacyThumbnailUrl:_conversation.chatPhotoSmall legacyUrl:_conversation.chatPhotoBig imageSize:CGSizeMake(640.0f, 640.0f)];
    
    return modernGallery;
}

- (bool)allowMessageForwarding
{
    return false;
}

- (void)updateSearchQuery:(NSString *)query {
    if (!TGStringCompare(_currentSearchQuery, query)) {
        _currentSearchQuery = query;
        [self loadMoreImpl:true];
    }
}

- (void)presentFilterController {
    TGChannelAdminLogFilterController *controller = [[TGChannelAdminLogFilterController alloc] initWithPeerId:_conversation.conversationId accessHash:_accessHash isChannel:!_conversation.isChannelGroup filter:_eventFilter usersFilter:_usersFilter];
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    __weak TGAdminLogConversationCompanion *weakSelf = self;
    controller.completion = ^(TGChannelEventFilter filter, NSArray * usersFilter, bool allUsersSelected) {
        __strong TGAdminLogConversationCompanion *strongSelf = weakSelf;
        if (strongSelf != nil) {
            //strongSelf->_eventFilter != filter || strongSelf->_userFilter != userFilter)
            strongSelf->_eventFilter = filter;
            strongSelf->_usersFilter = usersFilter;
            bool allEvents = true;
            if (!filter.join) {
                allEvents = false;
            }
            if (!filter.leave) {
                allEvents = false;
            }
            if (!filter.invite) {
                allEvents = false;
            }
            if (!filter.ban) {
                allEvents = false;
            }
            if (!filter.unban) {
                allEvents = false;
            }
            if (!filter.kick) {
                allEvents = false;
            }
            if (!filter.unkick) {
                allEvents = false;
            }
            if (!filter.promote) {
                allEvents = false;
            }
            if (!filter.demote) {
                allEvents = false;
            }
            if (!filter.info) {
                allEvents = false;
            }
            if (!filter.settings) {
                allEvents = false;
            }
            if (!filter.pinned) {
                allEvents = false;
            }
            if (!filter.edit) {
                allEvents = false;
            }
            if (!filter.del) {
                allEvents = false;
            }
            NSString *title = TGLocalized(@"Channel.AdminLog.TitleAllEvents");
            if (!allEvents || !allUsersSelected) {
                title = TGLocalized(@"Channel.AdminLog.TitleSelectedEvents");
            }
            [self _setTitle:title andStatus:@"" accentColored:false allowAnimatioon:false toggleMode:[self currentToggleMode]];
            [self loadMoreImpl:true];
        }
    };
    
    [self.controller presentViewController:navigationController animated:true completion:nil];
}

- (bool)canBanUser:(int32_t)userId {
    if (userId == TGTelegraphInstance.clientUserId) {
        return false;
    }
    
    if (_conversation.channelRole == TGChannelRoleCreator || _conversation.channelAdminRights.canBanUsers) {
        for (TGCachedConversationMember *member in _adminMembers) {
            if (member.adminRights.hasAnyRights) {
                if (!member.adminCanManage) {
                    return false;
                }
            }
        }
        return true;
    } else {
        return false;
    }
}

- (void)banUser:(TGUser *)user {
    TGChannelBanController *controller = [[TGChannelBanController alloc] initWithConversation:_conversation user:user current:nil member:[TGChannelManagementSignals channelRole:_conversation.conversationId accessHash:_conversation.accessHash user:user]];
    
    __weak TGAdminLogConversationCompanion *weakSelf = self;
    controller.done = ^(TGChannelBannedRights *rights) {
        __strong TGAdminLogConversationCompanion *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (rights != nil) {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow show:true];
                [[[[TGChannelManagementSignals updateChannelBannedRightsAndGetMembership:strongSelf->_conversation.conversationId accessHash:strongSelf->_conversation.accessHash user:[TGDatabaseInstance() loadUser:user.uid] rights:rights] onDispose:^{
                    TGDispatchOnMainThread(^{
                        [progressWindow dismiss:true];
                    });
                }] deliverOn:[SQueue mainQueue]] startWithNext:^(TGCachedConversationMember *updatedMember) {
                    __strong TGAdminLogConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [TGDatabaseInstance() updateChannelCachedData:strongSelf->_conversation.conversationId block:^TGCachedConversationData *(TGCachedConversationData *data) {
                            if (data == nil) {
                                data = [[TGCachedConversationData alloc] init];
                            }
                            
                            return [data updateMemberBannedRights:user.uid rights:rights timestamp:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime] isMember:updatedMember != nil kickedById:TGTelegraphInstance.clientUserId];
                        }];
                        
                        [strongSelf.controller dismissViewControllerAnimated:true completion:nil];
                    }
                    [progressWindow dismissWithSuccess];
                } error:^(__unused id error) {
                    __strong TGAdminLogConversationCompanion *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                    }
                } completed:^{
                }];
            } else {
                [strongSelf.controller dismissViewControllerAnimated:true completion:nil];
            }
        }
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller] navigationBarClass:[TGWhiteNavigationBar class]];
    
    [self.controller presentViewController:navigationController animated:true completion:nil];
}

@end
