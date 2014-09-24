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

typedef enum {
    TGGroupParticipationStatusMember = 0,
    TGGroupParticipationStatusLeft = 1,
    TGGroupParticipationStatusKicked = 2
} TGGroupParticipationStatus;

@interface TGGroupModernConversationCompanion ()
{
    NSArray *_initialTypingUserIds;
    
    TGConversation *_conversation;
    
    CFAbsoluteTime _lastTypingActivity;
    
    bool _hasLeavePanel;
    
    bool _isMuted; // Main Thread
}

@end

@implementation TGGroupModernConversationCompanion

- (instancetype)initWithConversationId:(int64_t)conversationId conversation:(TGConversation *)conversation typingUserIds:(NSArray *)typingUserIds mayHaveUnreadMessages:(bool)mayHaveUnreadMessages
{
    self = [super initWithConversationId:conversationId mayHaveUnreadMessages:mayHaveUnreadMessages];
    if (self != nil)
    {
        _conversation = conversation;
        _initialTypingUserIds = typingUserIds;
        
        _everyMessageNeedsAuthor = true;
    }
    return self;
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

- (NSString *)stringForOnlineCount:(int)onlineCount
{
    if (onlineCount == 1)
        return TGLocalizedStatic(@"Conversation.StatusOnline_1");
    else if (onlineCount == 2)
        return TGLocalizedStatic(@"Conversation.StatusOnline_2");
    else if (onlineCount >= 3 && onlineCount <= 10)
        return [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.StatusOnline_3_10"), [TGStringUtils stringWithLocalizedNumber:onlineCount]];
    else
        return [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.StatusOnline_any"), [TGStringUtils stringWithLocalizedNumber:onlineCount]];
}

- (id)stringForMemberCount:(int)memberCount onlineCount:(int)onlineCount participationStatus:(TGGroupParticipationStatus)participationStatus
{
    if (participationStatus == TGGroupParticipationStatusKicked)
        return TGLocalized(@"Conversation.StatusKickedFromGroup");
    else if (participationStatus == TGGroupParticipationStatusLeft)
        return TGLocalized(@"Conversation.StatusLeftGroup");
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

- (NSString *)stringForTypingUids:(NSArray *)typingUids
{
    if (typingUids.count != 0)
    {
        NSMutableString *typingString = [[NSMutableString alloc] init];
        
        for (NSNumber *nUid in typingUids)
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

- (TGGroupParticipationStatus)participationStatusForConversation:(TGConversation *)conversation
{
    if (conversation.kickedFromChat)
        return TGGroupParticipationStatusKicked;
    else if (conversation.leftChat)
        return TGGroupParticipationStatusLeft;
    
    return TGGroupParticipationStatusMember;
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
    [self _setStatus:[self stringForMemberCount:_conversation.chatParticipantCount onlineCount:onlineCount participationStatus:[self participationStatusForConversation:_conversation]] accentColored:false allowAnimation:false];
    
    if (_initialTypingUserIds.count != 0)
        [self _setTypingStatus:[self stringForTypingUids:_initialTypingUserIds]];
    
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        TGGroupInfoController *groupInfoController = [[TGGroupInfoController alloc] initWithConversationId:_conversationId];
        
        TGModernConversationController *controller = self.controller;
        [controller.navigationController pushViewController:groupInfoController animated:true];
    }
    else
    {
        TGModernConversationController *controller = self.controller;
        if (controller != nil)
        {
            TGGroupInfoController *groupInfoController = [[TGGroupInfoController alloc] initWithConversationId:_conversationId];
            
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[groupInfoController] navigationBarClass:[TGWhiteNavigationBar class]];
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleRootInPopover;
            TGPopoverController *popoverController = [[TGPopoverController alloc] initWithContentViewController:navigationController];
            navigationController.parentPopoverController = popoverController;
            [popoverController setPopoverContentSize:CGSizeMake(320.0f, 528.0f) animated:false];
            
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
                [controller setCustomInputPanel:unblockPanel];
            }
            else
                [controller setCustomInputPanel:nil];
        });
    }
}

- (void)_createOrUpdatePrimaryTitlePanel:(bool)createIfNeeded
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
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
        if (_isMuted)
            [actions addObject:@{@"title": TGLocalized(@"Conversation.Unmute"), @"action": @"unmute"}];
        else
            [actions addObject:@{@"title": TGLocalized(@"Conversation.Mute"), @"action": @"mute"}];
        [actions addObject:@{@"title": TGLocalized(@"Common.Edit"), @"action": @"edit"}];
        [actions addObject:@{@"title": TGLocalized(@"Conversation.Info"), @"action": @"info"}];
        
        [groupTitlePanel setButtonsWithTitlesAndActions:actions];
        
        [controller setPrimaryTitlePanel:groupTitlePanel];
    }
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

- (NSString *)_controllerInfoButtonText
{
    return TGLocalized(@"Conversation.InfoGroup");
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

- (bool)shouldAutomaticallyDownloadAudios
{
    return TGAppDelegateInstance.autoDownloadAudioInGroups;
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
                    muteImage = [UIImage imageNamed:@"ModernConversationTitleIconMute.png"];
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
        
        if ([panelAction isEqualToString:@"mute"])
            [self requestGroupMute:true];
        else if ([panelAction isEqualToString:@"unmute"])
            [self requestGroupMute:false];
        else if ([panelAction isEqualToString:@"edit"])
        {
            TGModernConversationController *controller = self.controller;
            [controller enterEditingMode];
        }
        else if ([panelAction isEqualToString:@"info"])
            [self _controllerAvatarPressed];
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
                [TGAppDelegateInstance.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_conversationId unreadCount:0 serviceUnreadCount:0] animated:false];
                [self _dismissController];
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
            [self _setStatus:statusString accentColored:false allowAnimation:false];
        }
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/typing", _conversationId]])
    {
        NSArray *typingUsers = ((SGraphObjectNode *)resource).object;
        if (typingUsers.count != 0)
            [self _setTypingStatus:[self stringForTypingUids:typingUsers]];
        else
            [self _setTypingStatus:nil];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId]])
    {
        _conversation = ((SGraphObjectNode *)resource).object;
        
        [self _setTitle:_conversation.chatTitle];
        [self _setAvatarConversationId:_conversationId title:_conversation.chatTitle icon:nil];
        [self _setAvatarUrl:_conversation.chatPhotoSmall];
        int onlineCount = 0;
        if (_conversation.chatParticipants != nil)
        {
            onlineCount = [TGDatabaseInstance() loadUsersOnlineCount:_conversation.chatParticipants.chatParticipantUids alwaysOnlineUid:TGTelegraphInstance.clientUserId];
        }
        NSString *statusString = [self stringForMemberCount:_conversation.chatParticipantCount onlineCount:onlineCount participationStatus:[self participationStatusForConversation:_conversation]];
        [self _setStatus:statusString accentColored:false allowAnimation:false];
        
        [self updatePatricipationStatus:[self participationStatusForConversation:_conversation]];
    }
    else if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    
    [super actionStageResourceDispatched:path resource:resource arguments:arguments];
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

@end
