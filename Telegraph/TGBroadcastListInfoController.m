#import "TGBroadcastListInfoController.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGConversation.h"
#import "TGDatabase.h"

#import "TGHacks.h"
#import "TGFont.h"
#import "TGStringUtils.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGInterfaceManager.h"
#import "TGNavigationBar.h"
#import "TGTelegraphDialogListCompanion.h"
#import "TGConversationChangeTitleRequestActor.h"
#import "TGConversationChangePhotoActor.h"

#import "TGHeaderCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGGroupInfoCollectionItem.h"
#import "TGGroupInfoUserCollectionItem.h"

#import "TGTelegraphUserInfoController.h"
#import "TGGroupInfoSelectContactController.h"
#import "TGAlertSoundController.h"

#import "TGRemoteImageView.h"
#import "TGLegacyCameraController.h"

#import "TGAlertView.h"
#import "TGActionSheet.h"

#import "TGConversationAddMessagesActor.h"

#import "TGForwardTargetController.h"

@interface TGBroadcastListInfoController () <TGGroupInfoSelectContactControllerDelegate>
{
    bool _editing;
    bool _haveEditableUsers;
    
    int64_t _conversationId;
    TGConversation *_conversation;
    
    TGGroupInfoCollectionItem *_groupInfoItem;
    
    TGCollectionMenuSection *_usersSection;
    TGHeaderCollectionItem *_usersSectionHeader;
}

@end

@implementation TGBroadcastListInfoController

- (instancetype)initWithConversationId:(int64_t)conversationId
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _conversationId = conversationId;
        
        [self setTitleText:TGLocalized(@"BroadcastListInfo.Title")];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:false];
        
        _groupInfoItem = [[TGGroupInfoCollectionItem alloc] init];
        _groupInfoItem.interfaceHandle = _actionHandle;
        _groupInfoItem.isBroadcast = true;
        
        [self.menuSections addSection:[[TGCollectionMenuSection alloc] initWithItems:@[
            _groupInfoItem,
        ]]];
        
        _usersSectionHeader = [[TGHeaderCollectionItem alloc] initWithTitle:@""];
        TGButtonCollectionItem *addParticipantItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"BroadcastListInfo.AddRecipient") action:@selector(addParticipantPressed)];
        addParticipantItem.leftInset = 65.0f;
        addParticipantItem.titleColor = TGAccentColor();
        addParticipantItem.deselectAutomatically = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
            _usersSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _usersSectionHeader,
            addParticipantItem
        ]];
        [self.menuSections addSection:_usersSection];
        
        [self _loadUsersAndUpdateConversation:[TGDatabaseInstance() loadConversationWithIdCached:_conversationId]];
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() watchForPaths:@[
                [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId],
                @"/tg/userdatachanges",
                @"/tg/userpresencechanges",
                @"/as/updateRelativeTimestamps"
            ] watcher:self];
        }];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

#pragma mark -

- (void)_resetCollectionView
{
    [super _resetCollectionView];
    
    [self.collectionView setAllowEditingCells:_haveEditableUsers animated:false];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -

- (void)editPressed
{
    if (!_editing)
    {
        _editing = true;
        
        [_groupInfoItem setEditing:true animated:true];
        
        [self enterEditingMode:true];
    }
}

- (void)donePressed
{
    if (_editing)
    {
        _editing = false;
        
        if (!TGStringCompare(_conversation.chatTitle, [_groupInfoItem editingTitle]) && [_groupInfoItem editingTitle] != nil)
            [self _commitUpdateTitle:[_groupInfoItem editingTitle]];
        
        [_groupInfoItem setEditing:false animated:true];
    }
    
    [self leaveEditingMode:true];
}

- (void)didEnterEditingMode:(bool)animated
{
    [super didEnterEditingMode:animated];
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)] animated:true];
}

- (void)didLeaveEditingMode:(bool)animated
{
    [super didLeaveEditingMode:animated];
    
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:animated];
}

- (void)addParticipantPressed
{
    NSMutableArray *disabledUsers = [[NSMutableArray alloc] init];
    [disabledUsers addObjectsFromArray:_conversation.chatParticipants.chatParticipantUids];
    
    TGForwardTargetController *controller = [[TGForwardTargetController alloc] initWithSelectTarget];
    controller.contactsController.disabledUsers = disabledUsers;
    controller.watcherHandle = _actionHandle;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller] navigationBarClass:[TGWhiteNavigationBar class]];
    if ([self inPopover])
    {
        navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleChildInPopover;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)selectContactControllerDidSelectUser:(TGUser *)user
{
    if (user.uid != 0 && ![_conversation.chatParticipants.chatParticipantUids containsObject:@(user.uid)])
    {
        [self _commitAddParticipant:user];
    }
}

- (void)_commitAddParticipant:(TGUser *)user
{
    TGConversation *conversation = [[TGDatabaseInstance() loadConversationWithId:_conversationId] copy];
    TGConversationParticipantsData *participantData = [conversation.chatParticipants copy];
    [participantData addParticipantWithId:user.uid invitedBy:0 date:0];
    conversation.chatParticipants = participantData;
    conversation.chatParticipantCount = (int)(conversation.chatParticipants.chatParticipantUids.count + conversation.chatParticipants.chatParticipantSecretChatPeerIds.count + conversation.chatParticipants.chatParticipantChatPeerIds.count);
    
    _conversation = conversation;
    
    [self _loadUsersAndUpdateConversation:_conversation];
    
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
        {
            if (((TGGroupInfoUserCollectionItem *)item).user.uid == user.uid)
            {
                NSIndexPath *indexPath = [self indexPathForItem:item];
                if (indexPath != nil && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
                    [self.collectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:UICollectionViewScrollPositionTop];
                
                break;
            }
        }
    }
    
    static int actionId = 0;
    [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(broadcastListInfo%d)", actionId++]] execute:@{@"chats": @{@(conversation.conversationId): conversation}}];
    
    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId] resource:[[SGraphObjectNode alloc] initWithObject:_conversation]];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)_commitAddConversation:(TGConversation *)addedConversation
{
    if (addedConversation.isChat)
    {
        TGConversation *conversation = [[TGDatabaseInstance() loadConversationWithId:_conversationId] copy];
        TGConversationParticipantsData *participantData = [conversation.chatParticipants copy];
        
        if (addedConversation.conversationId <= INT_MIN)
            [participantData addSecretChatPeerWithId:addedConversation.conversationId];
        else
            [participantData addChatPeerWithId:addedConversation.conversationId];
        
        conversation.chatParticipants = participantData;
        conversation.chatParticipantCount = (int)(conversation.chatParticipants.chatParticipantUids.count + conversation.chatParticipants.chatParticipantSecretChatPeerIds.count + conversation.chatParticipants.chatParticipantChatPeerIds.count);
        
        _conversation = conversation;
        
        [self _loadUsersAndUpdateConversation:_conversation];
        
        for (id item in _usersSection.items)
        {
            if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
            {
                if (((TGGroupInfoUserCollectionItem *)item).conversation.conversationId == addedConversation.conversationId)
                {
                    NSIndexPath *indexPath = [self indexPathForItem:item];
                    if (indexPath != nil && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
                        [self.collectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:UICollectionViewScrollPositionTop];
                    
                    break;
                }
            }
        }
        
        static int actionId = 0;
        [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(broadcastListInfo%d)", actionId++]] execute:@{@"chats": @{@(conversation.conversationId): conversation}}];
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId] resource:[[SGraphObjectNode alloc] initWithObject:_conversation]];
    }
}

- (void)_commitDeleteParticipant:(int32_t)uid
{
    TGConversation *conversation = [[TGDatabaseInstance() loadConversationWithId:_conversationId] copy];
    TGConversationParticipantsData *participantData = [conversation.chatParticipants copy];
    [participantData removeParticipantWithId:uid];
    conversation.chatParticipants = participantData;
    conversation.chatParticipantCount = (int)(conversation.chatParticipants.chatParticipantUids.count + conversation.chatParticipants.chatParticipantSecretChatPeerIds.count + conversation.chatParticipants.chatParticipantChatPeerIds.count);
    
    _conversation = conversation;
    
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]] && ((TGGroupInfoUserCollectionItem *)item).user.uid == uid)
        {
            NSIndexPath *indexPath = [self indexPathForItem:item];
            if (indexPath != nil)
            {
                [self.menuSections beginRecordingChanges];
                [self.menuSections deleteItemFromSection:indexPath.section atIndex:indexPath.item];
                [self.menuSections commitRecordedChanges:self.collectionView];
                
                [self _updateAllowCellEditing:true];
            }
            
            break;
        }
    }
    
    static int actionId = 0;
    [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(broadcastListInfo%d)", actionId++]] execute:@{@"chats": @{@(conversation.conversationId): conversation}}];
    
    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId] resource:[[SGraphObjectNode alloc] initWithObject:_conversation]];
}

- (void)_commitDeleteConversation:(int64_t)peerId
{
    TGConversation *conversation = [[TGDatabaseInstance() loadConversationWithId:_conversationId] copy];
    TGConversationParticipantsData *participantData = [conversation.chatParticipants copy];
    
    [participantData removeSecretChatPeerWithId:peerId];
    [participantData removeChatPeerWithId:peerId];
    
    conversation.chatParticipants = participantData;
    conversation.chatParticipantCount = (int)(conversation.chatParticipants.chatParticipantUids.count + conversation.chatParticipants.chatParticipantSecretChatPeerIds.count + conversation.chatParticipants.chatParticipantChatPeerIds.count);
    
    _conversation = conversation;
    
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]] && ((TGGroupInfoUserCollectionItem *)item).conversation.conversationId == peerId)
        {
            NSIndexPath *indexPath = [self indexPathForItem:item];
            if (indexPath != nil)
            {
                [self.menuSections beginRecordingChanges];
                [self.menuSections deleteItemFromSection:indexPath.section atIndex:indexPath.item];
                [self.menuSections commitRecordedChanges:self.collectionView];
                
                [self _updateAllowCellEditing:true];
            }
            
            break;
        }
    }
    
    static int actionId = 0;
    [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(broadcastListInfo%d)", actionId++]] execute:@{@"chats": @{@(conversation.conversationId): conversation}}];
    
    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId] resource:[[SGraphObjectNode alloc] initWithObject:_conversation]];
}

- (void)_commitUpdateTitle:(NSString *)title
{
    TGConversation *conversation = [_conversation copy];
    conversation.chatTitle = title;
    _conversation = conversation;
    
    [_groupInfoItem setConversation:_conversation];
    
    static int actionId = 0;
    [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(broadcastListInfo%d)", actionId++]] execute:@{@"chats": @{@(conversation.conversationId): conversation}}];
    
    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId] resource:[[SGraphObjectNode alloc] initWithObject:_conversation]];
}

#pragma mark -

- (void)_loadUsersAndUpdateConversation:(TGConversation *)conversation
{
    NSMutableArray *loadedRecipients = [[NSMutableArray alloc] init];
    for (NSNumber *nUid in conversation.chatParticipants.chatParticipantUids)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:[nUid int32Value]];
        if (user != nil)
            [loadedRecipients addObject:@{@"type": @"user", @"user": user}];
    }
    
    for (NSNumber *nPeerId in conversation.chatParticipants.chatParticipantSecretChatPeerIds)
    {
        TGConversation *secretConversation = [TGDatabaseInstance() loadConversationWithIdCached:[nPeerId longLongValue]];
        if (secretConversation != nil)
        {
            if (secretConversation.isChat)
            {
                if (secretConversation.conversationId <= INT_MIN)
                {
                    int32_t uid = 0;
                    if (secretConversation != nil && secretConversation.chatParticipants.chatParticipantUids.count != 0)
                        uid = [secretConversation.chatParticipants.chatParticipantUids[0] intValue];
                    
                    if (uid != 0)
                    {
                        TGUser *user = [TGDatabaseInstance() loadUser:uid];
                        [loadedRecipients addObject:@{@"type": @"secretChat", @"conversation": secretConversation, @"user": user}];
                    }
                }
            }
        }
    }
    
    for (NSNumber *nPeerId in conversation.chatParticipants.chatParticipantChatPeerIds)
    {
        TGConversation *chatConversation = [TGDatabaseInstance() loadConversationWithIdCached:[nPeerId longLongValue]];
        if (chatConversation != nil)
        {
            if (chatConversation.isChat)
            {
                if (chatConversation.conversationId > INT_MIN)
                {
                    [loadedRecipients addObject:@{@"type": @"chat", @"conversation": chatConversation}];
                }
            }
        }
    }
    
    TGDispatchOnMainThread(^
    {
        _conversation = conversation;
        [_groupInfoItem setConversation:_conversation];
        
        [self _updateConversationWithLoadedRecipients:loadedRecipients];
    });
}

- (void)_updateConversationWithLoadedRecipients:(NSArray *)loadedRecipients
{
    NSDictionary *invitedDates = _conversation.chatParticipants.chatInvitedDates;
    
    int32_t selfUid = TGTelegraphInstance.clientUserId;
    NSArray *sortedRecipients = [loadedRecipients sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *desc1, NSDictionary *desc2)
    {
        TGUser *user1 = desc1[@"user"];
        TGUser *user2 = desc2[@"user"];
        
        if (user1.uid == selfUid)
            return NSOrderedAscending;
        else if (user2.uid == selfUid)
            return NSOrderedDescending;
        
        if (user1.presence.online != user2.presence.online)
            return user1.presence.online ? NSOrderedAscending : NSOrderedDescending;
        
        if ((user1.presence.lastSeen < 0) != (user2.presence.lastSeen < 0))
            return user1.presence.lastSeen >= 0 ? NSOrderedAscending : NSOrderedDescending;
        
        if (user1.presence.online)
        {
            NSNumber *nDate1 = invitedDates[[[NSNumber alloc] initWithInt:user1.uid]];
            NSNumber *nDate2 = invitedDates[[[NSNumber alloc] initWithInt:user2.uid]];
            
            if (nDate1 != nil && nDate2 != nil)
                return [nDate1 intValue] < [nDate2 intValue] ? NSOrderedAscending : NSOrderedDescending;
            else if (nDate1 != nil)
                return NSOrderedAscending;
            else if (nDate2 != nil)
                return NSOrderedDescending;
            else
                return user1.uid < user2.uid ? NSOrderedAscending : NSOrderedDescending;
        }
        
        if (user1.presence.lastSeen < 0)
        {
            NSNumber *nDate1 = invitedDates[[[NSNumber alloc] initWithInt:user1.uid]];
            NSNumber *nDate2 = invitedDates[[[NSNumber alloc] initWithInt:user2.uid]];
            
            if (nDate1 != nil && nDate2 != nil)
                return [nDate1 intValue] < [nDate2 intValue] ? NSOrderedAscending : NSOrderedDescending;
            else
                return user1.uid < user2.uid ? NSOrderedAscending : NSOrderedDescending;
        }
        
        return user1.presence.lastSeen > user2.presence.lastSeen ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSString *title = @"";
    if (sortedRecipients.count == 1)
        title = TGLocalized(@"GroupInfo.ParticipantCount_1");
    else if (sortedRecipients.count == 2)
        title = TGLocalized(@"GroupInfo.ParticipantCount_2");
    else if (sortedRecipients.count >= 3 && sortedRecipients.count <= 10)
        title = [NSString localizedStringWithFormat:TGLocalized(@"GroupInfo.ParticipantCount_3_10"), [TGStringUtils stringWithLocalizedNumber:sortedRecipients.count]];
    else
        title = [NSString localizedStringWithFormat:TGLocalized(@"GroupInfo.ParticipantCount_any"), [TGStringUtils stringWithLocalizedNumber:sortedRecipients.count]];
    
    [_usersSectionHeader setTitle:title];
    
    NSUInteger sectionIndex = [self indexForSection:_usersSection];
    if (sectionIndex != NSNotFound)
    {
        bool haveChanges = false;
        
        if (_usersSection.items.count - 2 != sortedRecipients.count)
            haveChanges = true;
        else
        {
            for (int i = 1, j = 0; i < (int)_usersSection.items.count - 1; i++, j++)
            {
                TGGroupInfoUserCollectionItem *userItem = _usersSection.items[i];
                NSDictionary *desc = sortedRecipients[j];
                if ([desc[@"type"] isEqualToString:@"user"])
                {
                    TGUser *user = desc[@"user"];
                    if (user.uid != userItem.user.uid || userItem.conversation != nil)
                    {
                        haveChanges = true;
                        break;
                    }
                }
                else if ([desc[@"type"] isEqualToString:@"secretChat"])
                {
                    TGUser *user = desc[@"user"];
                    TGConversation *conversation = desc[@"conversation"];
                    if (user.uid != userItem.user.uid || userItem.conversation.conversationId != conversation.conversationId)
                    {
                        haveChanges = true;
                        break;
                    }
                }
                else if ([desc[@"type"] isEqualToString:@"chat"])
                {
                    TGConversation *conversation = desc[@"conversation"];
                    if (userItem.user != nil || userItem.conversation.conversationId != conversation.conversationId)
                    {
                        haveChanges = true;
                        break;
                    }
                }
            }
        }
        
        if (haveChanges)
        {
            int count = (int)_usersSection.items.count - 2;
            while (count > 0)
            {
                [self.menuSections deleteItemFromSection:sectionIndex atIndex:1];
                count--;
            }
            
            int insertIndex = 1;
            for (NSDictionary *dict in sortedRecipients)
            {
                if ([dict[@"type"] isEqualToString:@"user"])
                {
                    TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
                    userItem.interfaceHandle = _actionHandle;
                    
                    userItem.selectable = true;
                    
                    bool canEditInPrinciple = _conversation.chatParticipants.chatParticipantUids.count > 1;
                    bool canEdit = userItem.selectable && canEditInPrinciple;
                    [userItem setCanEdit:canEdit];
                    
                    [userItem setUser:dict[@"user"]];
                    [userItem setConversation:nil];
                    
                    [userItem setDisabled:false];
                    
                    [self.menuSections insertItem:userItem toSection:sectionIndex atIndex:insertIndex];
                    insertIndex++;
                }
                else if ([dict[@"type"] isEqualToString:@"secretChat"])
                {
                    TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
                    userItem.interfaceHandle = _actionHandle;
                    
                    userItem.selectable = true;
                    
                    bool canEditInPrinciple = _conversation.chatParticipants.chatParticipantUids.count > 1;
                    bool canEdit = userItem.selectable && canEditInPrinciple;
                    [userItem setCanEdit:canEdit];
                    
                    [userItem setUser:dict[@"user"]];
                    [userItem setConversation:dict[@"conversation"]];
                    
                    [userItem setDisabled:false];
                    
                    [self.menuSections insertItem:userItem toSection:sectionIndex atIndex:insertIndex];
                    insertIndex++;
                }
                else if ([dict[@"type"] isEqualToString:@"chat"])
                {
                    TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
                    userItem.interfaceHandle = _actionHandle;
                    
                    userItem.selectable = true;
                    
                    bool canEditInPrinciple = _conversation.chatParticipants.chatParticipantUids.count > 1;
                    bool canEdit = userItem.selectable && canEditInPrinciple;
                    [userItem setCanEdit:canEdit];
                    
                    [userItem setUser:nil];
                    [userItem setConversation:dict[@"conversation"]];
                    
                    [userItem setDisabled:false];
                    
                    [self.menuSections insertItem:userItem toSection:sectionIndex atIndex:insertIndex];
                    insertIndex++;
                }
            }
            
            self.collectionLayout.withoutAnimation = true;
            [UIView performWithoutAnimation:^
            {
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            self.collectionLayout.withoutAnimation = false;
            
            //[self.collectionView reloadData];
            
            [self _updateAllowCellEditing:false];
        }
    }
}

- (void)_updateAllowCellEditing:(bool)animated
{
    int userCount = 0;
    
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
        {
            userCount++;
        }
    }
    
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
        {
            [((TGGroupInfoUserCollectionItem *)item) setCanEdit:userCount > 1];
        }
    }
    
    _haveEditableUsers = userCount > 1;
    [self.collectionView setAllowEditingCells:_haveEditableUsers animated:animated];
}

- (void)_updateRelativeTimestamps
{
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
        {
            [(TGGroupInfoUserCollectionItem *)item updateTimestamp];
        }
    }
}

- (void)_updateUsers:(NSArray *)users
{
    bool updatedAnyUser = false;
    
    NSMutableDictionary *userIdToUser = [[NSMutableDictionary alloc] init];
    for (TGUser *user in users)
    {
        userIdToUser[@(user.uid)] = user;
    }
    
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
        {
            TGGroupInfoUserCollectionItem *userItem = item;
            
            if (userItem.user != nil)
            {
                TGUser *user = userIdToUser[@(userItem.user.uid)];
                if (user != nil)
                {
                    updatedAnyUser = true;
                    
                    [userItem setUser:user];
                }
            }
        }
    }
    
    if (updatedAnyUser)
        [self _loadUsersAndUpdateConversation:_conversation];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"deleteUser"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
            [self _commitDeleteParticipant:uid];
    }
    else if ([action isEqualToString:@"deleteConversation"])
    {
        int64_t conversationId = [options[@"conversationId"] longLongValue];
        if (conversationId != 0)
            [self _commitDeleteConversation:conversationId];
    }
    else if ([action isEqualToString:@"openUser"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
        {
            TGTelegraphUserInfoController *userInfoController = [[TGTelegraphUserInfoController alloc] initWithUid:uid];
            [self.navigationController pushViewController:userInfoController animated:true];
        }
    }
    else if ([action isEqualToString:@"openConversation"])
    {
        int64_t conversationId = [options[@"conversationId"] longLongValue];
        if (conversationId != 0)
            [[TGInterfaceManager instance] navigateToConversationWithId:conversationId conversation:nil];
    }
    else if ([action isEqualToString:@"userSelected"])
    {
        TGUser *user = options;
        if (user.uid != 0 && ![_conversation.chatParticipants.chatParticipantUids containsObject:@(user.uid)])
            [self _commitAddParticipant:user];
        
        [self dismissViewControllerAnimated:true completion:nil];
    }
    else if ([action isEqualToString:@"conversationSelected"])
    {
        TGConversation *conversation = options;
        if (conversation.conversationId != 0 && ![_conversation.chatParticipants.chatParticipantSecretChatPeerIds containsObject:@(conversation.conversationId)] && ![_conversation.chatParticipants.chatParticipantChatPeerIds containsObject:@(conversation.conversationId)])
        {
            [self _commitAddConversation:conversation];
        }
        
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId]])
    {
        TGConversation *conversation = ((SGraphObjectNode *)resource).object;
        
        if (conversation != nil)
            [self _loadUsersAndUpdateConversation:conversation];
    }
    else if ([path isEqualToString:@"/as/updateRelativeTimestamps"])
    {
        TGDispatchOnMainThread(^
        {
            [self _updateRelativeTimestamps];
        });
    }
    else if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"])
    {
        NSArray *users = ((SGraphObjectNode *)resource).object;
        
        TGDispatchOnMainThread(^
        {
            [self _updateUsers:users];
        });
    }
}

@end
