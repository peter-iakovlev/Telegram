#import "TGGroupModernConversationCompanion.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGAppDelegate.h"
#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGNavigationBar.h"
#import "TGPopoverController.h"

#import "TGModernConversationController.h"
#import "TGModernConversationGroupTitlePanel.h"
#import "TGModernConversationActionInputPanel.h"

#import "TGModernConversationTitleIcon.h"

#import "TGGroupInfoController.h"

#import "TGDialogListCompanion.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGModernConversationTitleView.h"

#import "TGInterfaceManager.h"

#import "TGMessageModernConversationItem.h"

#import "TGBotSignals.h"
#import "TGRecentContextBotsSignal.h"

#import "TGModernViewContext.h"

#import "TGPeerIdAdapter.h"
#import "TGProgressWindow.h"

#import "TGModernGalleryController.h"
#import "TGGroupAvatarGalleryModel.h"

#import "TGLocalization.h"

typedef enum {
    TGGroupParticipationStatusMember = 0,
    TGGroupParticipationStatusLeft = 1,
    TGGroupParticipationStatusKicked = 2,
    TGGroupParticipationStatusDeactivated = 3
} TGGroupParticipationStatus;

@interface TGGroupModernConversationCompanion ()
{
    NSDictionary *_initialUserActivities;
    
    TGConversation *_conversation;
    
    CFAbsoluteTime _lastTypingActivity;
    
    bool _hasLeavePanel;
    
    bool _isMuted; // Main Thread
    
    bool _hasBots;
    bool _hasSingleBot;
}

@end

@implementation TGGroupModernConversationCompanion

- (instancetype)initWithConversation:(TGConversation *)conversation userActivities:(NSDictionary *)userActivities mayHaveUnreadMessages:(bool)mayHaveUnreadMessages
{
    self = [super initWithConversation:conversation mayHaveUnreadMessages:mayHaveUnreadMessages];
    if (self != nil)
    {
        _conversation = conversation;
        _hasBots = [self conversationHasBots:conversation hasSingleBot:&_hasSingleBot];
        self.viewContext.commandsEnabled = _hasBots;
        _initialUserActivities = userActivities;
        
        _everyMessageNeedsAuthor = true;
    }
    return self;
}

- (NSString *)stringForMemberCount:(int)memberCount
{
    return [effectiveLocalization() getPluralized:@"Conversation.StatusMembers" count:memberCount];
}

- (NSString *)stringForOnlineCount:(int)onlineCount
{
    return [effectiveLocalization() getPluralized:@"Conversation.StatusOnline" count:onlineCount];
}

- (id)stringForMemberCount:(int)memberCount onlineCount:(int)onlineCount participationStatus:(TGGroupParticipationStatus)participationStatus
{
    if (participationStatus == TGGroupParticipationStatusKicked)
        return TGLocalized(@"Conversation.StatusKickedFromGroup");
    else if (participationStatus == TGGroupParticipationStatusLeft)
        return TGLocalized(@"Conversation.StatusLeftGroup");
    else if (participationStatus == TGGroupParticipationStatusDeactivated)
        return TGLocalized(@"Conversation.StatusGroupDeactivated");
    else
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
}

- (NSString *)stringForActivity:(NSString *)activity
{
    if ([activity isEqualToString:@"recordingAudio"])
        return TGLocalized(@"Activity.RecordingAudio");
    else if ([activity isEqualToString:@"uploadingAudio"])
        return TGLocalized(@"Activity.UploadingAudio");
    else if ([activity isEqualToString:@"recordingVideoMessage"])
        return TGLocalized(@"Activity.RecordingVideoMessage");
    else if ([activity isEqualToString:@"uploadingVideoMessage"])
        return TGLocalized(@"Activity.UploadingVideoMessage");
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

- (TGGroupParticipationStatus)participationStatusForConversation:(TGConversation *)conversation
{
    if (conversation.kickedFromChat)
        return TGGroupParticipationStatusKicked;
    else if (conversation.leftChat)
        return TGGroupParticipationStatusLeft;
    else if (conversation.isDeactivated)
        return TGGroupParticipationStatusDeactivated;
    
    return TGGroupParticipationStatusMember;
}

- (NSString *)title
{
    return _conversation.chatTitle;
}

- (void)loadInitialState
{
    [super loadInitialState];
    
    [self _setTitle:_conversation.chatTitle];
    [self _setAvatarConversationId:_conversationId title:_conversation.chatTitle icon:nil];
    [self _setAvatarUrl:_conversation.chatPhotoSmall];
    
    int onlineCount = 0;
    if (_conversation.chatParticipants != nil)
    {
        onlineCount = [TGDatabaseInstance() loadUsersOnlineCount:_conversation.chatParticipants.chatParticipantUids alwaysOnlineUid:TGTelegraphInstance.clientUserId];
    }
    [self _setStatus:[self stringForMemberCount:_conversation.chatParticipantCount onlineCount:onlineCount participationStatus:[self participationStatusForConversation:_conversation]] accentColored:false allowAnimation:false toggleMode:TGModernConversationControllerTitleToggleNone];
    
    if (_initialUserActivities.count != 0)
        [self _setTypingStatus:[self stringForUserActivities:_initialUserActivities] activity:[self activityTypeForActivities:_initialUserActivities]];
    
    TGModernConversationController *controller = self.controller;
    [controller setHasBots:_hasBots];
    
    [self updatePatricipationStatus:[self participationStatusForConversation:_conversation]];
}

- (void)_controllerWillAppearAnimated:(bool)animated firstTime:(bool)firstTime
{
    [super _controllerWillAppearAnimated:animated firstTime:firstTime];
}

- (void)_controllerDidAppear:(bool)firstTime
{
    [super _controllerDidAppear:firstTime];
    
    if (firstTime)
    {
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversationExtended/(%lld)", _conversationId] options:@{
            @"conversationId": @(_conversationId)
        } watcher:TGTelegraphInstance];
    }
}

- (void)_controllerAvatarPressed
{
    TGModernConversationController *controller = self.controller;
    if (controller.currentSizeClass == UIUserInterfaceSizeClassCompact)
    {
        TGGroupInfoController *groupInfoController = [[TGGroupInfoController alloc] initWithConversationId:_conversationId];
        
        [controller.navigationController pushViewController:groupInfoController animated:true];
    }
    else
    {
        if (controller != nil)
        {
            TGGroupInfoController *groupInfoController = [[TGGroupInfoController alloc] initWithConversationId:_conversationId];
            
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[groupInfoController] navigationBarClass:[TGWhiteNavigationBar class]];
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleRootInPopover;
            navigationController.detachFromPresentingControllerInCompactMode = true;
            TGPopoverController *popoverController = [[TGPopoverController alloc] initWithContentViewController:navigationController];
            navigationController.parentPopoverController = popoverController;
            [popoverController setContentSize:CGSizeMake(320.0f, 528.0f)];
            
            controller.associatedPopoverController = popoverController;
            [popoverController presentPopoverFromBarButtonItem:controller.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
            groupInfoController.collectionView.contentOffset = CGPointMake(0.0f, -groupInfoController.collectionView.contentInset.top);
        }
    }
}

#pragma mark -

- (void)updatePatricipationStatus:(TGGroupParticipationStatus)participationStatus
{
    if (_hasLeavePanel != (participationStatus != TGGroupParticipationStatusMember))
    {
        _hasLeavePanel = (participationStatus != TGGroupParticipationStatusMember);
        
        ASHandle *actionHandle = self.actionHandle;
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = self.controller;
            if ((participationStatus != TGGroupParticipationStatusMember))
            {
                TGModernConversationActionInputPanel *unblockPanel = [[TGModernConversationActionInputPanel alloc] init];
                [unblockPanel setActionWithTitle:TGLocalized(@"ConversationProfile.LeaveDeleteAndExit") action:@"deleteAndExit"];
                unblockPanel.delegate = controller;
                unblockPanel.companionHandle = actionHandle;
                [controller setDefaultInputPanel:unblockPanel];
            }
            else
                [controller setDefaultInputPanel:nil];
        });
    }
}

- (void)_createOrUpdatePrimaryTitlePanel:(bool)createIfNeeded
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
    if (_isMuted)
        [actions addObject:@{@"title": TGLocalized(@"Conversation.Unmute"), @"icon": TGTintedImage([UIImage imageNamed:@"DialogListActionUnmute"], TGAccentColor()), @"action": @"unmute"}];
    else
        [actions addObject:@{@"title": TGLocalized(@"Conversation.Mute"), @"icon": TGTintedImage([UIImage imageNamed:@"DialogListActionMute"], TGAccentColor()), @"action": @"mute"}];
    [actions addObject:@{@"title": TGLocalized(@"Conversation.Info"), @"icon": [UIImage imageNamed:@"PanelInfoIcon"], @"action": @"info"}];
    
    [groupTitlePanel setButtonsWithTitlesAndActions:actions];
    
    [controller setPrimaryTitlePanel:groupTitlePanel];
}

- (void)_loadControllerPrimaryTitlePanel
{
    [self _createOrUpdatePrimaryTitlePanel:true];
}

- (void)controllerDidUpdateTypingActivity
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        if (ABS(currentTime - _lastTypingActivity) >= 4.0)
        {
            _lastTypingActivity = currentTime;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/activity/(typing)", _conversationId] options:nil watcher:self];
        }
    }];
}

- (void)controllerDidCancelTypingActivity
{
}

- (NSString *)_controllerInfoButtonText
{
    return TGLocalized(@"Conversation.InfoGroup");
}

- (NSDictionary *)userActivityData
{
    return @{@"user_id": @(TGTelegraphInstance.clientUserId), @"peer": @{@"type": @"group", @"id": @(-(int32_t)_conversationId)}};
}

- (TGApplicationFeaturePeerType)applicationFeaturePeerType
{
    if ([TGApplicationFeatures isGroupLarge:(NSUInteger)_conversation.chatParticipantCount])
        return TGApplicationFeaturePeerLargeGroup;
    else
        return TGApplicationFeaturePeerGroup;
}

#pragma mark -

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

- (NSString *)_sendMessagePathForMessageId:(int32_t)mid
{
    return [[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%@)/(%d)", [self _conversationIdPathComponent], mid];
}

- (NSString *)_sendMessagePathPrefix
{
    return [[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%@)/", [self _conversationIdPathComponent]];
}

- (NSDictionary *)_optionsForMessageActions
{
    return @{@"conversationId": @(_conversationId)};
}

- (void)subscribeToUpdates
{
    [ActionStageInstance() watchForPaths:@[
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/typing", _conversationId],
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId],
    ] watcher:self];
    
    [ActionStageInstance() watchForPath:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId64 ")", _conversationId] watcher:self];
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/peerSettings/(%" PRId64 ",cachedOnly)", _conversationId] options:@{@"peerId": @(_conversationId)} watcher:self];
    
    [super subscribeToUpdates];
}

#pragma mark -

- (void)requestGroupMute:(bool)mute
{
    [self _updateGroupMute:mute];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        static int actionId = 0;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(conversationController%d)", _conversation.conversationId, actionId++] options:@{@"peerId": @(_conversationId), @"muteUntil": @(mute ? INT_MAX : 0)} watcher:TGTelegraphInstance];
    }];
}

- (void)_updateGroupMute:(bool)isMuted
{
    TGDispatchOnMainThread(^
    {
        if (_isMuted != isMuted)
        {
            _isMuted = isMuted;
            [self _createOrUpdatePrimaryTitlePanel:false];
            
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
        }
    });
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"titlePanelAction"])
    {
        NSString *panelAction = options[@"action"];
        
        if ([panelAction isEqualToString:@"mute"]) {
            [self requestGroupMute:true];
        }
        else if ([panelAction isEqualToString:@"unmute"]) {
            [self requestGroupMute:false];
        }
        else if ([panelAction isEqualToString:@"edit"]) {
            [self.controller enterEditingMode];
        }
        else if ([panelAction isEqualToString:@"info"]) {
            [self _controllerAvatarPressed];
            [self.controller hideTitlePanel];
        }
        else if ([panelAction isEqualToString:@"search"]) {
            [self navigateToMessageSearch];
        }
    }
    else if ([action isEqualToString:@"actionPanelAction"])
    {
        NSString *panelAction = options[@"action"];
        
        if ([panelAction isEqualToString:@"deleteAndExit"])
        {
            TGModernConversationController *controller = self.controller;
            
            UINavigationController *navigationController = controller.navigationController;
            NSUInteger index = [navigationController.viewControllers indexOfObject:controller];
            if (index != NSNotFound)
            {
                [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_conversationId unreadCount:0 serviceUnreadCount:0] animated:false];
                [self _dismissController];
            }
        }
    }
    else if ([action isEqualToString:@"openLinkRequested"])
    {
        if ([options[@"url"] hasPrefix:@"mention://"])
        {
            NSString *domain = [options[@"url"] substringFromIndex:@"mention://".length];
            
            for (NSNumber *nUid in _conversation.chatParticipants.chatParticipantUids)
            {
                TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                if (TGStringCompare(domain, user.userName))
                {
                    [[TGInterfaceManager instance] navigateToProfileOfUser:user.uid shareVCard:nil];
                    return;
                }
            }
        }
    }
    
    [super actionStageActionRequested:action options:options];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments
{
    if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"])
    {
        NSArray *users = ((SGraphObjectNode *)resource).object;
        
        bool needsUpdate = false;
        for (NSNumber *nUid in _conversation.chatParticipants.chatParticipantUids)
        {
            int uid = [nUid intValue];
            for (TGUser *user in users)
            {
                if (user.uid == uid)
                {
                    needsUpdate = true;
                    break;
                }
            }
            
            if (needsUpdate)
                break;
        }
        
        if (needsUpdate)
        {
            int onlineCount = [TGDatabaseInstance() loadUsersOnlineCount:_conversation.chatParticipants.chatParticipantUids alwaysOnlineUid:TGTelegraphInstance.clientUserId];
            NSString *statusString = [self stringForMemberCount:_conversation.chatParticipantCount onlineCount:onlineCount participationStatus:[self participationStatusForConversation:_conversation]];
            [self _setStatus:statusString accentColored:false allowAnimation:false toggleMode:TGModernConversationControllerTitleToggleNone];
        }
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/typing", _conversationId]])
    {
        NSDictionary *userActivities = ((SGraphObjectNode *)resource).object;
        if (userActivities.count != 0)
            [self _setTypingStatus:[self stringForUserActivities:userActivities] activity:[self activityTypeForActivities:userActivities]];
        else
            [self _setTypingStatus:nil activity:0];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId]])
    {
        TGConversation *updatedConversation = ((SGraphObjectNode *)resource).object;
        
        if (!_conversation.isDeactivated && updatedConversation.isDeactivated && updatedConversation.migratedToChannelId != 0) {
            [ActionStageInstance() removeWatcher:self];
            
            TGDispatchOnMainThread(^{
                TGModernConversationController *controller = self.controller;
                if (controller.navigationController.topViewController == controller) {
                    __block TGProgressWindow *progressWindow = nil;
                    progressWindow = [[TGProgressWindow alloc] init];
                    [progressWindow show:true];
                    
                    __weak TGGroupModernConversationCompanion *weakSelf = self;
                    [[[[[[TGDatabaseInstance() existingChannel:TGPeerIdFromChannelId(updatedConversation.migratedToChannelId)] take:1] timeout:5.0 onQueue:[SQueue concurrentDefaultQueue] orSignal:[SSignal fail:nil]] deliverOn:[SQueue mainQueue]] onDispose:^{
                        TGDispatchOnMainThread(^{
                            [progressWindow dismiss:true];
                        });
                    }] startWithNext:^(TGConversation *next) {
                        TGDispatchOnMainThread(^{
                            [[TGInterfaceManager instance] navigateToConversationWithId:next.conversationId conversation:nil];
                        });
                    } error:^(__unused id error) {
                        __strong TGGroupModernConversationCompanion *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            TGModernConversationController *controller = strongSelf.controller;
                            [controller.navigationController popToRootViewControllerAnimated:true];
                        }
                    } completed:nil];
                }
            });
            
            return;
        }
        
        _conversation = updatedConversation;
        _hasBots = [self conversationHasBots:_conversation hasSingleBot:&_hasSingleBot];
        self.viewContext.commandsEnabled = _hasBots;
        bool hasBots = _hasBots;
        
        TGDispatchOnMainThread(^
        {
            TGModernConversationController *controller = self.controller;
            [controller setHasBots:hasBots];
        });
        
        [self _setTitle:_conversation.chatTitle];
        [self _setAvatarConversationId:_conversationId title:_conversation.chatTitle icon:nil];
        [self _setAvatarUrl:_conversation.chatPhotoSmall];
        int onlineCount = 0;
        if (_conversation.chatParticipants != nil)
        {
            onlineCount = [TGDatabaseInstance() loadUsersOnlineCount:_conversation.chatParticipants.chatParticipantUids alwaysOnlineUid:TGTelegraphInstance.clientUserId];
        }
        NSString *statusString = [self stringForMemberCount:_conversation.chatParticipantCount onlineCount:onlineCount participationStatus:[self participationStatusForConversation:_conversation]];
        [self _setStatus:statusString accentColored:false allowAnimation:false toggleMode:TGModernConversationControllerTitleToggleNone];
        
        [self updatePatricipationStatus:[self participationStatusForConversation:_conversation]];
    }
    else if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    
    [super actionStageResourceDispatched:path resource:resource arguments:arguments];
}

- (bool)conversationHasBots:(TGConversation *)conversation hasSingleBot:(bool *)hasSingleBot
{
    bool hasBots = false;
    int count = 0;
    for (NSNumber *nUid in conversation.chatParticipants.chatParticipantUids)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
        if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
        {
            count++;
            hasBots = true;
        }
    }
    if (hasSingleBot)
        *hasSingleBot = count == 1;
    return hasBots;
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        bool isMuted = [[((SGraphObjectNode *)result).object objectForKey:@"muteUntil"] intValue] != 0;
        [self _updateGroupMute:isMuted];
    }
    
    [super actorCompleted:status path:path result:result];
}

- (bool)allowReplies
{
    return true;
}

- (SSignal *)userListForMention:(NSString *)mention canBeContextBot:(bool)canBeContextBot
{
    NSString *normalizedMention = [mention lowercaseString];
    
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
    if (_conversation.chatParticipants != nil)
    {
        for (NSNumber *nUid in _conversation.chatParticipants.chatParticipantUids)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
            TGLog(@"%d %@", user.uid, user.displayName);
            if (user != nil && (normalizedMention.length == 0 || [[user.userName lowercaseString] hasPrefix:normalizedMention] || [[user.firstName lowercaseString] hasPrefix:normalizedMention] || [[user.lastName lowercaseString] hasPrefix:normalizedMention])) {
                userDict[@(user.uid)] = user;
            }
        }
    }
    
    NSMutableArray *sortedUserList = [[NSMutableArray alloc] init];
    
    TGModernConversationController *controller = self.controller;
    for (TGMessageModernConversationItem *item in [controller _items])
    {
        int32_t uid = (int32_t)(item->_message.fromUid);
        TGUser *user = userDict[@(uid)];
        if (user != nil && user.uid != TGTelegraphInstance.clientUserId)
        {
            [sortedUserList addObject:user];
            [userDict removeObjectForKey:@(uid)];
            if (userDict.count == 0)
                break;
        }
    }
    
    return [[canBeContextBot ? [TGRecentContextBotsSignal recentBots] : [SSignal single:@[]] mapToSignal:^SSignal *(NSArray *userIds) {
        return [TGDatabaseInstance() modify:^id{
            NSMutableArray *users = [[NSMutableArray alloc] init];
            for (TGUser *user in [userDict allValues]) {
                if (user.uid != TGTelegraphInstance.clientUserId) {
                    [users addObject:user];
                }
            }
            
            NSMutableArray *contextBots = [[NSMutableArray alloc] init];
            
            NSMutableSet *existingUsers = [[NSMutableSet alloc] init];
            
            for (TGUser *user in users) {
                [existingUsers addObject:@(user.uid)];
            }
            
            for (TGUser *user in sortedUserList) {
                [existingUsers addObject:@(user.uid)];
            }
            
            NSString *normalizedMention = [mention lowercaseString];
            for (NSNumber *nUserId in userIds) {
                if (![existingUsers containsObject:nUserId]) {
                    [existingUsers addObject:nUserId];
                    
                    TGUser *user = [TGDatabaseInstance() loadUser:[nUserId intValue]];
                    if (user != nil && (normalizedMention.length == 0 || [[user.userName lowercaseString] hasPrefix:normalizedMention] || [[user.firstName lowercaseString] hasPrefix:normalizedMention] || [[user.lastName lowercaseString] hasPrefix:normalizedMention])) {
                        if (user.isContextBot) {
                            [contextBots addObject:user];
                        } else {
                            [users addObject:user];
                        }
                    }
                }
            }
            
            NSArray *sortedContextBots = [contextBots sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2) {
                return [user1.displayName compare:user2.displayName];
            }];
            
            NSArray *sortedRemainingUsers = [users sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2) {
                return [user1.displayName compare:user2.displayName];
            }];
            
            NSMutableArray *finalList = [[NSMutableArray alloc] init];
            [finalList addObjectsFromArray:sortedContextBots];
            [finalList addObjectsFromArray:sortedUserList];
            [finalList addObjectsFromArray:sortedRemainingUsers];
            
            return finalList;
        }];
    }] deliverOn:[SQueue mainQueue]];
}

- (SSignal *)commandListForCommand:(NSString *)command
{
    if (_hasBots)
    {
        NSString *normalizedCommand = [command lowercaseString];
        if ([normalizedCommand hasPrefix:@"/"])
            normalizedCommand = [normalizedCommand substringFromIndex:1];
        
        NSMutableArray *botUsers = [[NSMutableArray alloc] init];
        NSMutableArray *botInfoSignals = [[NSMutableArray alloc] init];
        NSMutableArray *initialStates = [[NSMutableArray alloc] init];
        for (NSNumber *nUid in _conversation.chatParticipants.chatParticipantUids)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
            if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
            {
                [botUsers addObject:user];
                [botInfoSignals addObject:[[TGBotSignals botInfoForUserId:user.uid] map:^id(TGBotInfo *botInfo)
                {
                    NSMutableArray *commands = [[NSMutableArray alloc] init];
                    for (TGBotComandInfo *commandInfo in botInfo.commandList)
                    {
                        if (normalizedCommand.length == 0 || [[commandInfo.command lowercaseString] hasPrefix:normalizedCommand])
                            [commands addObject:commandInfo];
                    }
                    return commands;
                }]];
                [initialStates addObject:@[]];
            }
        }
        
        return [[SSignal combineSignals:botInfoSignals withInitialStates:initialStates] map:^id(NSArray *commandLists)
        {
            NSMutableArray *commands = [[NSMutableArray alloc] init];
            NSUInteger index = 0;
            for (NSArray *commandList in commandLists)
            {
                [commands addObject:@[botUsers[index], commandList]];
                index++;
            }
            
            return commands;
        }];
    }
    
    return nil;
}

- (bool)isASingleBotGroup
{
    return _hasSingleBot;
}

- (TGModernGalleryController *)galleryControllerForAvatar
{
    if (_conversation.chatPhotoSmall.length == 0)
        return nil;
    
    TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
    modernGallery.model = [[TGGroupAvatarGalleryModel alloc] initWithPeerId:_conversationId accessHash:0 messageId:0 legacyThumbnailUrl:_conversation.chatPhotoSmall legacyUrl:_conversation.chatPhotoBig imageSize:CGSizeMake(640.0f, 640.0f)];
    
    return modernGallery;
}

- (bool)isPeerAdmin {
    return _conversation.isAdmin;
}

@end
