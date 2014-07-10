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

#import "TGImageViewController.h"
#import "TGTelegraphProfileImageViewCompanion.h"
#import "TGRemoteImageView.h"
#import "TGLegacyCameraController.h"
#import "TGImagePickerController.h"
#import "TGImageSearchController.h"

#import "TGAlertView.h"
#import "TGActionSheet.h"

#import "TGConversationAddMessagesActor.h"

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
    TGGroupInfoSelectContactController *selectContactController = [[TGGroupInfoSelectContactController alloc] initWithContactsMode:TGContactsModeRegistered];
    selectContactController.delegate = self;
    
    NSMutableArray *disabledUsers = [[NSMutableArray alloc] init];
    [disabledUsers addObjectsFromArray:_conversation.chatParticipants.chatParticipantUids];
    
    selectContactController.disabledUsers = disabledUsers;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[selectContactController] navigationBarClass:[TGWhiteNavigationBar class]];
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
    conversation.chatParticipantCount = conversation.chatParticipants.chatParticipantUids.count;
    
    _conversation = conversation;
    
    [self _loadUsersAndUpdateConversation:_conversation];
    
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
        {
            if (((TGGroupInfoUserCollectionItem *)item).user.uid == user.uid)
            {
                NSIndexPath *indexPath = [self indexPathForItem:item];
                if (indexPath != nil)
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

- (void)_commitDeleteParticipant:(int32_t)uid
{
    TGConversation *conversation = [[TGDatabaseInstance() loadConversationWithId:_conversationId] copy];
    TGConversationParticipantsData *participantData = [conversation.chatParticipants copy];
    [participantData removeParticipantWithId:uid];
    conversation.chatParticipants = participantData;
    conversation.chatParticipantCount = conversation.chatParticipants.chatParticipantUids.count;
    
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
    NSMutableArray *participantUsers = [[NSMutableArray alloc] init];
    for (NSNumber *nUid in conversation.chatParticipants.chatParticipantUids)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:[nUid int32Value]];
        if (user != nil)
            [participantUsers addObject:user];
    }
    
    TGDispatchOnMainThread(^
    {
        _conversation = conversation;
        [_groupInfoItem setConversation:_conversation];
        
        [self _updateConversationWithLoadedUsers:participantUsers];
    });
}

- (void)_updateConversationWithLoadedUsers:(NSArray *)participantUsers
{
    NSDictionary *invitedDates = _conversation.chatParticipants.chatInvitedDates;
    
    int32_t selfUid = TGTelegraphInstance.clientUserId;
    NSArray *sortedUsers = [participantUsers sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2)
    {
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
    if (sortedUsers.count == 1)
        title = TGLocalized(@"GroupInfo.ParticipantCount_1");
    else if (sortedUsers.count == 2)
        title = TGLocalized(@"GroupInfo.ParticipantCount_2");
    else if (sortedUsers.count >= 3 && sortedUsers.count <= 10)
        title = [NSString localizedStringWithFormat:TGLocalized(@"GroupInfo.ParticipantCount_3_10"), [TGStringUtils stringWithLocalizedNumber:sortedUsers.count]];
    else
        title = [NSString localizedStringWithFormat:TGLocalized(@"GroupInfo.ParticipantCount_any"), [TGStringUtils stringWithLocalizedNumber:sortedUsers.count]];
    
    [_usersSectionHeader setTitle:title];
    
    NSUInteger sectionIndex = [self indexForSection:_usersSection];
    if (sectionIndex != NSNotFound)
    {
        bool haveChanges = false;
        
        if (_usersSection.items.count - 2 != sortedUsers.count)
            haveChanges = true;
        else
        {
            for (int i = 1, j = 0; i < (int)_usersSection.items.count - 1; i++, j++)
            {
                TGGroupInfoUserCollectionItem *userItem = _usersSection.items[i];
                TGUser *user = sortedUsers[j];
                if (user.uid != userItem.user.uid)
                {
                    haveChanges = true;
                    break;
                }
            }
        }
        
        if (haveChanges)
        {
            int count = _usersSection.items.count - 2;
            while (count > 0)
            {
                [self.menuSections deleteItemFromSection:sectionIndex atIndex:1];
                count--;
            }
            
            int insertIndex = 1;
            for (TGUser *user in sortedUsers)
            {
                TGGroupInfoUserCollectionItem *userItem = [[TGGroupInfoUserCollectionItem alloc] init];
                userItem.interfaceHandle = _actionHandle;
                
                bool disabled = false;
                userItem.selectable = user.uid != selfUid && !disabled;
                
                bool canEditInPrinciple = _conversation.chatParticipants.chatParticipantUids.count > 1;
                bool canEdit = userItem.selectable && canEditInPrinciple;
                [userItem setCanEdit:canEdit];
                
                [userItem setUser:user];
                [userItem setDisabled:disabled];
                
                [self.menuSections insertItem:userItem toSection:sectionIndex atIndex:insertIndex];
                insertIndex++;
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
    
    NSMutableArray *participantUsers = [[NSMutableArray alloc] init];
    
    for (id item in _usersSection.items)
    {
        if ([item isKindOfClass:[TGGroupInfoUserCollectionItem class]])
        {
            TGGroupInfoUserCollectionItem *userItem = item;
            
            TGUser *user = userIdToUser[@(userItem.user.uid)];
            if (user != nil)
            {
                updatedAnyUser = true;
                [userItem setUser:user];
            }
            
            [participantUsers addObject:userItem.user];
        }
    }
    
    if (updatedAnyUser)
    {
        [self _updateConversationWithLoadedUsers:participantUsers];
    }
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
    else if ([action isEqualToString:@"openUser"])
    {
        int32_t uid = [options[@"uid"] int32Value];
        if (uid != 0)
        {
            TGTelegraphUserInfoController *userInfoController = [[TGTelegraphUserInfoController alloc] initWithUid:uid];
            [self.navigationController pushViewController:userInfoController animated:true];
        }
    }
    else if ([action isEqualToString:@"editedTitleChanged"])
    {
        NSString *title = options[@"title"];
        
        if (_editing)
            self.navigationItem.rightBarButtonItem.enabled = title.length != 0;
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
