#import "TGAlternateBroadcastListsController.h"

#import "TGDatabase.h"

#import "TGModernConversationController.h"
#import "TGBroadcastModernConversationCompanion.h"

#import "TGDialogListCell.h"

#import "TGInterfaceAssets.h"
#import "TGTelegraph.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGBroadcastConversationCell.h"

#import "TGCreateGroupController.h"

#import "TGAppDelegate.h"
#import "TGTabletMainViewController.h"

@interface TGAlternateBroadcastListsController () <ASWatcher, TGNavigationControllerItem>
{
    NSArray *_list;
    NSMutableArray *_backingList;
    
    UIBarButtonItem *_createButtonItem;
    
    TGCreateGroupController *_createGroupController;
    
    bool _removeAfterHiding;
}

@end

@implementation TGAlternateBroadcastListsController

- (instancetype)init
{
    self = [super initWithContactsMode:TGContactsModeRegistered | TGContactsModeCompose | TGContactsModeManualFirstSection];
    if (self != nil)
    {
        _backingList = [[NSMutableArray alloc] init];
        
        self.title = TGLocalized(@"BroadcastLists.Title");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closePressed)]];
        }
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Create") style:UIBarButtonItemStylePlain target:self action:@selector(addPressed)]];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        
        _createButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Create") style:UIBarButtonItemStylePlain target:self action:@selector(createPressed)];
        [_createButtonItem setEnabled:false];
        
        [ActionStageInstance() watchForPath:@"/tg/broadcastConversations" watcher:self];
        
        NSData *data = [TGDatabaseInstance() customProperty:@"maxBroadcastReceivers"];
        if (data.length >= 4)
        {
            int32_t maxBroadcastReceivers = 0;
            [data getBytes:&maxBroadcastReceivers length:4];
            self.usersSelectedLimit = MAX(100, maxBroadcastReceivers);
        }
    }
    return self;
}

- (void)closePressed
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        TGAppDelegateInstance.tabletMainViewController.detailViewController = nil;
    }
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)loadView
{
    [super loadView];
    
    self.titleText = TGLocalized(@"BroadcastLists.Title");
    self.navigationItem.rightBarButtonItem = _createButtonItem;
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        [TGDatabaseInstance() loadBroadcastConversationListFromDate:INT_MAX limit:100 excludeConversationIds:nil completion:^(NSArray *list)
        {
            [self resetList:list animated:false];
        }];
    } synchronous:true];
}

- (void)resetList:(NSArray *)list animated:(bool)__unused animated
{
    TGUser *selfUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
    
    NSMutableArray *processedList = [[NSMutableArray alloc] init];
    for (TGConversation *conversation in list)
    {
        TGConversation *processedConversation = [conversation copy];
        [self initializeDialogListData:processedConversation customUser:nil selfUser:selfUser];
        [processedList addObject:processedConversation];
    }
    
    _backingList = processedList;
    
    _list = [[NSArray alloc] initWithArray:_backingList];
    [self.tableView reloadData];
}

- (void)contactSelected:(TGUser *)user
{
    [super contactSelected:user];
    
    [_createButtonItem setEnabled:[self selectedContactsCount] != 0];
}

- (void)contactDeselected:(TGUser *)user
{
    [super contactDeselected:user];
    
    [_createButtonItem setEnabled:[self selectedContactsCount] != 0];
}

- (NSInteger)numberOfRowsInFirstSection
{
    return _list.count;
}

- (UITableViewCell *)cellForRowInFirstSection:(NSInteger)row
{
    TGConversation *conversation = _list[row];
    TGBroadcastConversationCell *cell = (TGBroadcastConversationCell *)[self.tableView dequeueReusableCellWithIdentifier:@"TGBroadcastConversationCell"];
    if (cell == nil)
    {
        cell = [[TGBroadcastConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGDialogListCell"];
    }
    
    [self prepareCell:cell forConversation:conversation animated:false];
    
    return cell;
}

- (CGFloat)itemHeightForFirstSection
{
    return 54.0f;
}

- (void)initializeDialogListData:(TGConversation *)conversation customUser:(TGUser *)customUser selfUser:(TGUser *)selfUser
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (!conversation.isChat || conversation.isEncrypted)
    {
        int32_t userId = 0;
        if (conversation.isEncrypted)
        {
            if (conversation.chatParticipants.chatParticipantUids.count != 0)
                userId = [conversation.chatParticipants.chatParticipantUids[0] intValue];
        }
        else
            userId = (int)conversation.conversationId;
        
        TGUser *user = nil;
        if (customUser != nil && customUser.uid == userId)
            user = customUser;
        else
            user = [[TGDatabase instance] loadUser:(int)userId];
        
        NSString *title = nil;
        NSArray *titleLetters = nil;
        
        if ((user.phoneNumber.length != 0 && ![TGDatabaseInstance() uidIsRemoteContact:user.uid]) && user.uid != 333000)
            title = user.formattedPhoneNumber;
        else
            title = [user displayName];
        
        if (user.firstName.length != 0 && user.lastName.length != 0)
            titleLetters = [[NSArray alloc] initWithObjects:[user.firstName substringToIndex:1], [user.lastName substringToIndex:1], nil];
        else if (user.firstName.length != 0)
            titleLetters = [[NSArray alloc] initWithObjects:[user.firstName substringToIndex:1], nil];
        else if (user.lastName.length != 0)
            titleLetters = [[NSArray alloc] initWithObjects:[user.lastName substringToIndex:1], nil];
        
        if (title != nil)
            [dict setObject:title forKey:@"title"];
        
        if (titleLetters != nil)
            dict[@"titleLetters"] = titleLetters;
        
        dict[@"isEncrypted"] = [[NSNumber alloc] initWithBool:conversation.isEncrypted];
        if (conversation.isEncrypted)
        {
            dict[@"encryptionStatus"] = [[NSNumber alloc] initWithInt:conversation.encryptedData.handshakeState];
            dict[@"encryptionOutgoing"] = [[NSNumber alloc] initWithBool:conversation.chatParticipants.chatAdminId == TGTelegraphInstance.clientUserId];
            NSString *firstName = user.displayFirstName;
            dict[@"encryptionFirstName"] = firstName != nil ? firstName : @"";
            
            if (user.firstName != nil)
                dict[@"firstName"] = user.firstName;
            if (user.lastName != nil)
                dict[@"lastName"] = user.lastName;
        }
        dict[@"encryptedUserId"] = [[NSNumber alloc] initWithInt:userId];
        
        if (user.photoUrlSmall != nil)
            [dict setObject:user.photoUrlSmall forKey:@"avatarUrl"];
        [dict setObject:[NSNumber numberWithBool:false] forKey:@"isChat"];
        
        NSString *authorAvatarUrl = nil;
        if (selfUser != nil)
            authorAvatarUrl = selfUser.photoUrlSmall;
        
        if (authorAvatarUrl != nil)
            [dict setObject:authorAvatarUrl forKey:@"authorAvatarUrl"];
        
        if (conversation.media.count != 0)
        {
            NSString *authorName = nil;
            if (conversation.fromUid == selfUser.uid)
            {
                static NSString *youString = nil;
                if (youString == nil)
                    youString = authorNameYou;
                
                authorName = youString;
            }
            else
            {
                if (conversation.fromUid != 0)
                {
                    TGUser *authorUser = [[TGDatabase instance] loadUser:conversation.fromUid];
                    if (authorUser != nil)
                    {
                        authorName = authorUser.displayName;
                    }
                }
            }
            
            if (authorName != nil)
                [dict setObject:authorName forKey:@"authorName"];
        }
    }
    else
    {
        [dict setObject:(conversation.chatTitle == nil ? @"" : conversation.chatTitle) forKey:@"title"];
        
        if (conversation.chatPhotoSmall.length != 0)
            [dict setObject:conversation.chatPhotoSmall forKey:@"avatarUrl"];
        
        [dict setObject:[NSNumber numberWithBool:true] forKey:@"isChat"];
        
        NSString *authorName = nil;
        NSString *authorAvatarUrl = nil;
        if (conversation.fromUid == selfUser.uid)
        {
            authorAvatarUrl = selfUser.photoUrlSmall;
            
            static NSString *youString = nil;
            if (youString == nil)
                youString = authorNameYou;
            
            if (conversation.text.length != 0 || conversation.media.count != 0)
                authorName = youString;
        }
        else
        {
            if (conversation.fromUid != 0)
            {
                TGUser *authorUser = [[TGDatabase instance] loadUser:conversation.fromUid];
                if (authorUser != nil)
                {
                    authorAvatarUrl = authorUser.photoUrlSmall;
                    authorName = authorUser.displayName;
                }
            }
        }
        
        if (authorAvatarUrl != nil)
            [dict setObject:authorAvatarUrl forKey:@"authorAvatarUrl"];
        if (authorName != nil)
            [dict setObject:authorName forKey:@"authorName"];
    }
    
    NSMutableDictionary *messageUsers = [[NSMutableDictionary alloc] init];
    for (TGMediaAttachment *attachment in conversation.media)
    {
        if (attachment.type == TGActionMediaAttachmentType)
        {
            TGActionMediaAttachment *actionAttachment = (TGActionMediaAttachment *)attachment;
            if (actionAttachment.actionType == TGMessageActionChatAddMember || actionAttachment.actionType == TGMessageActionChatDeleteMember)
            {
                NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                if (nUid != nil)
                {
                    TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                    if (user != nil)
                        [messageUsers setObject:user forKey:nUid];
                }
            }
            
            TGUser *user = conversation.fromUid == selfUser.uid ? selfUser : [TGDatabaseInstance() loadUser:(int)conversation.fromUid];
            if (user != nil)
            {
                [messageUsers setObject:user forKey:[[NSNumber alloc] initWithInt:user.uid]];
                [messageUsers setObject:user forKey:@"author"];
            }
        }
    }
    
    [dict setObject:[[NSNumber alloc] initWithBool:[TGDatabaseInstance() isPeerMuted:conversation.conversationId]] forKey:@"mute"];
    
    [dict setObject:messageUsers forKey:@"users"];
    
    NSMutableString *userNames = [[NSMutableString alloc] init];
    
    std::vector<int> userIds;
    for (NSNumber *nUid in conversation.chatParticipants.chatParticipantUids)
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
    
    dict[@"userNames"] = userNames;
    
    conversation.dialogListData = dict;
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

- (void)prepareCell:(TGBroadcastConversationCell *)cell forConversation:(TGConversation *)conversation animated:(bool)__unused animated
{
    NSDictionary *dialogListData = conversation.dialogListData;
    
    [cell setConversationId:conversation.conversationId];
    [cell setTitle:conversation.chatTitle.length == 0 ? [self stringForMemberCount:conversation.chatParticipants.chatParticipantUids.count] : conversation.chatTitle];
    [cell setStatus:dialogListData[@"userNames"]];
    
    /*cell.date = conversation.date;
    
    if (conversation.deliveryError)
        cell.deliveryState = TGMessageDeliveryStateFailed;
    else
        cell.deliveryState = conversation.deliveryState;
    
    cell.titleText = [dialogListData objectForKey:@"title"];
    cell.titleLetters = [dialogListData objectForKey:@"titleLetters"];
    
    cell.isEncrypted = [dialogListData[@"isEncrypted"] boolValue];
    cell.encryptionStatus = [dialogListData[@"encryptionStatus"] intValue];
    cell.encryptedUserId = [dialogListData[@"encryptedUserId"] intValue];
    cell.encryptionOutgoing = [dialogListData[@"encryptionOutgoing"] boolValue];
    cell.encryptionFirstName = dialogListData[@"encryptionFirstName"];
    
    NSNumber *nIsChat = [dialogListData objectForKey:@"isChat"];
    if (nIsChat != nil && [nIsChat boolValue])
    {
        NSArray *chatAvatarUrls = [dialogListData objectForKey:@"chatAvatarUrls"];
        cell.groupChatAvatarCount = chatAvatarUrls.count;
        cell.groupChatAvatarUrls = chatAvatarUrls;
        cell.isGroupChat = true;
        cell.avatarUrl = [dialogListData objectForKey:@"avatarUrl"];
        
        NSString *authorName = [dialogListData objectForKey:@"authorName"];
        cell.authorName = [authorName isEqualToString:authorNameYou] ? TGLocalized(@"DialogList.You") : authorName;
    }
    else
    {
        cell.avatarUrl = [dialogListData objectForKey:@"avatarUrl"];
        cell.isGroupChat = false;
        
        NSString *authorName = [dialogListData objectForKey:@"authorName"];
        cell.authorName = [authorName isEqualToString:authorNameYou] ? TGLocalized(@"DialogList.You") : authorName;
    }
    
    cell.isMuted = [[dialogListData objectForKey:@"mute"] boolValue];
    
    cell.unread = conversation.unread;
    cell.outgoing = conversation.outgoing;
    
    cell.rawText = true;
    cell.messageText = dialogListData[@"userNames"];*/
}

- (bool)shouldBeRemovedFromNavigationAfterHiding
{
    return _removeAfterHiding;
}

- (void)didSelectRowInFirstSection:(NSInteger)row
{
    _removeAfterHiding = true;
    
    TGConversation *conversation = _list[row];
    
    TGBroadcastModernConversationCompanion *broadcastCompanion = [[TGBroadcastModernConversationCompanion alloc] initWithConversationId:conversation.conversationId conversation:conversation];
    TGModernConversationController *conversationController = [[TGModernConversationController alloc] init];
    conversationController.companion = broadcastCompanion;
    [broadcastCompanion bindController:conversationController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers.count > 1)
            [self.navigationController setViewControllers:@[viewControllers[0], conversationController] animated:true];
        else
            [self.navigationController pushViewController:conversationController animated:true];
    }
    else
    {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers.count > 1)
            [self.navigationController setViewControllers:@[viewControllers[0], conversationController] animated:true];
        else
            [self.navigationController pushViewController:conversationController animated:true];
    }
}

- (bool)shouldDisplaySectionIndices
{
    return false;
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/broadcastConversations"])
    {
        NSMutableArray *conversations = [((SGraphObjectNode *)resource).object mutableCopy];
        
        TGUser *selfUser = [[TGDatabase instance] loadUser:TGTelegraphInstance.clientUserId];
        
        if (conversations.count == 0)
            return;
        
        [conversations sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            int date1 = (int)((TGConversation *)obj1).date;
            int date2 = (int)((TGConversation *)obj2).date;
            
            if (date1 < date2)
                return NSOrderedAscending;
            else if (date1 > date2)
                return NSOrderedDescending;
            else
                return NSOrderedSame;
        }];
        
        std::map<int64_t, int> conversationIdToIndex;
        int index = -1;
        for (TGConversation *conversation in _backingList)
        {
            index++;
            int64_t conversationId = conversation.conversationId;
            conversationIdToIndex.insert(std::pair<int64_t, int>(conversationId, index));
        }
        
        for (int i = 0; i < (int)conversations.count; i++)
        {
            TGConversation *conversation = [conversations objectAtIndex:i];
            int64_t conversationId = conversation.conversationId;
            std::map<int64_t, int>::iterator it = conversationIdToIndex.find(conversationId);
            if (it != conversationIdToIndex.end())
            {
                TGConversation *newConversation = [conversation copy];
                if (!newConversation.isDeleted)
                    [self initializeDialogListData:newConversation customUser:nil selfUser:selfUser];
                
                [_backingList replaceObjectAtIndex:(it->second) withObject:newConversation];
                [conversations removeObjectAtIndex:i];
                i--;
            }
        }
        
        for (int i = 0; i < (int)_backingList.count; i++)
        {
            TGConversation *conversation = [_backingList objectAtIndex:i];
            if (conversation.isDeleted)
            {
                [_backingList removeObjectAtIndex:i];
                i--;
            }
        }
        
        for (TGConversation *conversation in conversations)
        {
            TGConversation *newConversation = [conversation copy];
            if (!newConversation.isDeleted)
            {
                [self initializeDialogListData:newConversation customUser:nil selfUser:selfUser];
                
                [_backingList addObject:newConversation];
            }
        }
        
        [_backingList sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            int date1 = (int)((TGConversation *)obj1).date;
            int date2 = (int)((TGConversation *)obj2).date;
            
            if (date1 < date2)
                return NSOrderedDescending;
            else if (date1 > date2)
                return NSOrderedAscending;
            else
                return NSOrderedSame;
        }];
        
        NSArray *items = [NSArray arrayWithArray:_backingList];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            _list = items;
            [self.tableView reloadData];
        });
    }
}

- (void)createPressed
{
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    for (TGUser *user in [self selectedComposeUsers])
    {
        [userIds addObject:@(user.uid)];
    }
    
    [self createBroadcast:@"" userIds:userIds];
    
    /*
    if (_createGroupController == nil)
    {
        _createGroupController = [[TGCreateGroupController alloc] initWithCreateBroadcast:true];
        __weak TGAlternateBroadcastListsController *weakSelf = self;
        _createGroupController.onCreateBroadcastList = ^(NSString *listName, NSArray *userIds)
        {
            __strong TGAlternateBroadcastListsController *strongSelf = weakSelf;
            [strongSelf createBroadcast:listName == nil ? @"" : listName userIds:userIds];
        };
    }
    
    [_createGroupController setUserIds:userIds];
    
    [self.navigationController pushViewController:_createGroupController animated:true];*/
}

- (void)createBroadcast:(NSString *)listName userIds:(NSArray *)userIds
{
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        [TGDatabaseInstance() addBroadcastConversation:listName userIds:userIds completion:^(TGConversation *conversation)
        {
            TGDispatchOnMainThread(^
            {
                TGBroadcastModernConversationCompanion *broadcastCompanion = [[TGBroadcastModernConversationCompanion alloc] initWithConversationId:conversation.conversationId conversation:conversation];
                TGModernConversationController *conversationController = [[TGModernConversationController alloc] init];
                conversationController.companion = broadcastCompanion;
                [broadcastCompanion bindController:conversationController];
                
                NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
                for (UIViewController *controller in self.navigationController.viewControllers)
                {
                    [viewControllers addObject:controller];
                    break;
                    
                    if (controller == self)
                        break;
                }
                
                [viewControllers addObject:conversationController];
                
                [self.navigationController setViewControllers:viewControllers animated:true];
                TGDispatchAfter(1.0, dispatch_get_main_queue(), ^
                {
                    [self setUsersSelected:[self selectedContactsList] selected:nil callback:true];
                    [self.tableView setContentOffset:CGPointMake(0.0f, -self.tableView.contentInset.top)];
                    self.navigationItem.rightBarButtonItem.enabled = false;
                });
            });
        }];
    } synchronous:true];
}

- (void)commitDeleteItemInFirstSection:(NSInteger)row
{
    TGConversation *conversation = _list[row];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_backingList removeObjectAtIndex:row];
        [TGDatabaseInstance() deleteConversation:conversation.conversationId populateActionQueue:false];
    }];
    
    NSMutableArray *mutableList = [[NSMutableArray alloc] initWithArray:_list];
    [mutableList removeObjectAtIndex:row];
    _list = mutableList;
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

@end
