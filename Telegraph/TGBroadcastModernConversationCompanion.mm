#import "TGBroadcastModernConversationCompanion.h"

#import "TGStringUtils.h"

#import "TGModernConversationController.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGAppDelegate.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGPopoverController.h"
#import "TGBroadcastConversationTitlePanel.h"
#import "TGBroadcastListInfoController.h"
#import "TGNavigationBar.h"

@interface TGBroadcastModernConversationCompanion ()
{
    TGConversation *_conversation;   
}

@end

@implementation TGBroadcastModernConversationCompanion

- (instancetype)initWithConversationId:(int64_t)conversationId conversation:(TGConversation *)conversation
{
    self = [super initWithConversationId:conversationId mayHaveUnreadMessages:false];
    if (self != nil)
    {
        _conversation = conversation;
    }
    return self;
}

- (NSString *)stringForMemberCount:(int)memberCount
{
    if (memberCount == 1)
        return TGLocalizedStatic(@"Conversation.StatusRecipients_1");
    else if (memberCount == 2)
        return TGLocalizedStatic(@"Conversation.StatusRecipients_2");
    else if (memberCount >= 3 && memberCount <= 10)
        return [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.StatusRecipients_3_10"), [TGStringUtils stringWithLocalizedNumber:memberCount]];
    else
        return [[NSString alloc] initWithFormat:TGLocalizedStatic(@"Conversation.StatusRecipients_any"), [TGStringUtils stringWithLocalizedNumber:memberCount]];
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

- (NSString *)stringForUserNames
{
    
    NSMutableString *userNames = [[NSMutableString alloc] init];
    std::vector<int> userIds;
    for (NSNumber *nUid in _conversation.chatParticipants.chatParticipantUids)
    {
        userIds.push_back([nUid intValue]);
    }
    auto users = [TGDatabaseInstance() loadUsers:userIds];
    for (auto it : (*users))
    {
        if (userNames.length != 0)
            [userNames appendString:@", "];
        [userNames appendString:it.second.displayFirstName];
    }
    
    return userNames;
}

- (void)loadInitialState
{
    [super loadInitialState];
    
    [self _setTitle:_conversation.chatTitle.length == 0 ? [self stringForMemberCount:_conversation.chatParticipantCount] :  _conversation.chatTitle];
    [self _setAvatarConversationId:_conversationId title:nil icon:[UIImage imageNamed:@"BroadcastAvatarIcon.png"]];
    [self _setAvatarUrl:_conversation.chatPhotoSmall];
    
    [self _setStatus:[self stringForUserNames] accentColored:false allowAnimation:false toggleMode:TGModernConversationControllerTitleToggleNone];
}

- (void)_controllerWillAppearAnimated:(bool)animated firstTime:(bool)firstTime
{
    [super _controllerWillAppearAnimated:animated firstTime:firstTime];
}

- (void)_controllerDidAppear:(bool)firstTime
{
    [super _controllerDidAppear:firstTime];
}

- (void)_controllerAvatarPressed
{
    TGModernConversationController *controller = self.controller;
    if (controller.currentSizeClass == UIUserInterfaceSizeClassCompact)
    {
        TGBroadcastListInfoController *groupInfoController = [[TGBroadcastListInfoController alloc] initWithConversationId:_conversationId];
        
        [controller.navigationController pushViewController:groupInfoController animated:true];
    }
    else
    {
        if (controller != nil)
        {
            TGBroadcastListInfoController *groupInfoController = [[TGBroadcastListInfoController alloc] initWithConversationId:_conversationId];
            
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

- (NSDictionary *)userActivityData
{
    return nil;
}

- (TGApplicationFeaturePeerType)applicationFeaturePeerType
{
    return TGApplicationFeaturePeerGroup;
}

#pragma mark -

- (void)_createOrUpdatePrimaryTitlePanel:(bool)createIfNeeded
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        TGModernConversationController *controller = self.controller;
        
        TGBroadcastConversationTitlePanel *groupTitlePanel = nil;
        if ([[controller primaryTitlePanel] isKindOfClass:[TGBroadcastConversationTitlePanel class]])
            groupTitlePanel = (TGBroadcastConversationTitlePanel *)[controller primaryTitlePanel];
        else
        {
            if (createIfNeeded)
            {
                groupTitlePanel = [[TGBroadcastConversationTitlePanel alloc] init];
                groupTitlePanel.companionHandle = self.actionHandle;
            }
            else
                return;
        }
        
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        [actions addObject:@{@"title": TGLocalized(@"Common.Edit"), @"action": @"edit"}];
        [actions addObject:@{@"title": TGLocalized(@"Conversation.Info"), @"action": @"info"}];
        //[actions addObject:@{@"title": TGLocalized(@"Conversation.Search"), @"action": @"search"}];
        
        [groupTitlePanel setButtonsWithTitlesAndActions:actions];
        
        [controller setPrimaryTitlePanel:groupTitlePanel];
    }
}

- (void)_loadControllerPrimaryTitlePanel
{
    [self _createOrUpdatePrimaryTitlePanel:true];
}

- (NSString *)_controllerInfoButtonText
{
    return TGLocalized(@"Conversation.InfoBroadcastList");
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

- (bool)_shouldDisplayProcessUnreadCount
{
    return false;
}

- (NSString *)_sendMessagePathForMessageId:(int32_t)mid
{
    return [[NSString alloc] initWithFormat:@"/tg/sendBroadcastMessage/(%@)/(%d)", [self _conversationIdPathComponent], mid];
}

- (NSString *)_sendMessagePathPrefix
{
    return [[NSString alloc] initWithFormat:@"/tg/sendBroadcastMessage/(%@)/", [self _conversationIdPathComponent]];
}

- (NSDictionary *)_optionsForMessageActions
{
    return @{@"conversationId": @(_conversationId), @"isBroadcast": @true, @"userIds": [[NSArray alloc] initWithArray:_conversation.chatParticipants.chatParticipantUids], @"secretChatConversationIds": [[NSArray alloc] initWithArray:_conversation.chatParticipants.chatParticipantSecretChatPeerIds], @"chatConversationIds": [[NSArray alloc] initWithArray:_conversation.chatParticipants.chatParticipantChatPeerIds]};
}

- (void)subscribeToUpdates
{
    [ActionStageInstance() watchForPaths:@[
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId],
    ] watcher:self];
    
    [super subscribeToUpdates];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"titlePanelAction"])
    {
        NSString *panelAction = options[@"action"];
        
        if ([panelAction isEqualToString:@"edit"])
        {
            TGModernConversationController *controller = self.controller;
            [controller enterEditingMode];
        }
        else if ([panelAction isEqualToString:@"info"])
            [self _controllerAvatarPressed];
        else if ([panelAction isEqualToString:@"search"])
            [self navigateToMessageSearch];
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
            [self _setStatus:[self stringForUserNames] accentColored:false allowAnimation:false toggleMode:TGModernConversationControllerTitleToggleNone];
        }
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId]])
    {
        _conversation = ((SGraphObjectNode *)resource).object;
        
        [self _setTitle:_conversation.chatTitle.length == 0 ? [self stringForMemberCount:_conversation.chatParticipantCount] : _conversation.chatTitle];
        [self _setAvatarConversationId:_conversationId title:nil icon:[UIImage imageNamed:@"BroadcastAvatarIcon.png"]];
        [self _setAvatarUrl:_conversation.chatPhotoSmall];
        [self _setStatus:[self stringForUserNames] accentColored:false allowAnimation:false toggleMode:TGModernConversationControllerTitleToggleNone];
    }
    
    [super actionStageResourceDispatched:path resource:resource arguments:arguments];
}

- (bool)allowMessageForwarding
{
    return false;
}

@end
