#import "TGBroadcastListsController.h"

#import "TGSelectContactController.h"

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

#import "TGBroadcastConversationCell.h"

static NSString *authorNameYou = @"  __TGLocalized__YOU";

@interface TGBroadcastListsController () <ASWatcher, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_backingList;
    NSArray *_list;
    
    UITableView *_tableView;
    
    UIView *_emptyContainer;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGBroadcastListsController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        _backingList = [[NSMutableArray alloc] init];
        
        self.title = TGLocalized(@"BroadcastLists.Title");
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Create") style:UIBarButtonItemStylePlain target:self action:@selector(addPressed)]];
        
        [ActionStageInstance() watchForPath:@"/tg/broadcastConversations" watcher:self];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.opaque = true;
    _tableView.backgroundColor = nil;
    _tableView.showsVerticalScrollIndicator = true;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.alwaysBounceVertical = true;
    _tableView.bounces = true;
    [self.view addSubview:_tableView];
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        [TGDatabaseInstance() loadBroadcastConversationListFromDate:INT_MAX limit:100 excludeConversationIds:nil completion:^(NSArray *list)
        {
            [self resetList:list animated:false];
        }];
    } synchronous:true];
}

- (void)updateEmptyState:(bool)animated
{
    if (_list.count == 0)
    {
        if (_emptyContainer == nil)
        {
            _emptyContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
            _emptyContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
            
            UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"EmptyBroadcastListsIcon.png"]];
            iconView.frame = (CGRect){{CGFloor((_emptyContainer.frame.size.width - iconView.frame.size.width) / 2.0f), 0.0f}, iconView.frame.size};
            [_emptyContainer addSubview:iconView];
            
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = UIColorRGB(0x999999);
            titleLabel.font = TGBoldSystemFontOfSize(15.0f + TGRetinaPixel);
            titleLabel.text = TGLocalized(@"BroadcastLists.NoListsYet");
            [titleLabel sizeToFit];
            titleLabel.frame = (CGRect){{CGFloor((_emptyContainer.frame.size.width - titleLabel.frame.size.width) / 2.0f), iconView.frame.origin.y + iconView.frame.size.height + 16.0f}, titleLabel.frame.size};
            [_emptyContainer addSubview:titleLabel];
            
            UILabel *textLabel = [[UILabel alloc] init];
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.textColor = UIColorRGB(0x999999);
            textLabel.font = TGSystemFontOfSize(14.0f);
            textLabel.text = TGLocalized(@"BroadcastLists.NoListsText");
            textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            textLabel.textAlignment = NSTextAlignmentCenter;
            textLabel.numberOfLines = 0;
            CGSize textSize = [textLabel sizeThatFits:CGSizeMake(260.0f, 1000.0f)];
            textLabel.frame = (CGRect){{CGFloor((_emptyContainer.frame.size.width - textSize.width) / 2.0f), titleLabel.frame.origin.y + titleLabel.frame.size.height + 12.0f}, textSize};
            [_emptyContainer addSubview:textLabel];
            
            CGFloat contentHeight = CGRectGetMaxY(textLabel.frame);
            iconView.frame = CGRectOffset(iconView.frame, 0.0f, -CGFloor(contentHeight / 2.0f));
            titleLabel.frame = CGRectOffset(titleLabel.frame, 0.0f, -CGFloor(contentHeight / 2.0f));
            textLabel.frame = CGRectOffset(textLabel.frame, 0.0f, -CGFloor(contentHeight / 2.0f));
        }
        
        if (_emptyContainer.superview == nil)
            [self.view addSubview:_emptyContainer];
        
        _emptyContainer.frame = (CGRect){{CGFloor(self.view.frame.size.width - _emptyContainer.frame.size.width) / 2.0f, CGFloor(self.view.frame.size.height - _emptyContainer.frame.size.height) / 2.0f}, _emptyContainer.frame.size};
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                _tableView.alpha = 0.0f;
            }];
        }
        else
            _tableView.alpha = 0.0f;
    }
    else
    {
        if (_emptyContainer.superview != nil)
            [_emptyContainer removeFromSuperview];
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                _tableView.alpha = 1.0f;
            }];
        }
        else
            _tableView.alpha = 1.0f;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([_tableView indexPathForSelectedRow] != nil)
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];
}

- (void)resetList:(NSArray *)list animated:(bool)animated
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
    [_tableView reloadData];
    
    [self updateEmptyState:animated];
}

- (void)addPressed
{
    TGSelectContactController *selectContactController = [[TGSelectContactController alloc] initWithCreateGroup:true createEncrypted:false createBroadcast:true];
    __weak TGBroadcastListsController *weakSelf = self;
    selectContactController.onCreateBroadcastList = ^(NSString *listName, NSArray *userIds)
    {
        __strong TGBroadcastListsController *strongSelf = weakSelf;
        [strongSelf createBroadcast:listName userIds:userIds];
    };
    
    [self.navigationController pushViewController:selectContactController animated:true];
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
                    
                    if (controller == self)
                        break;
                }
                
                [viewControllers addObject:conversationController];
                
                [self.navigationController setViewControllers:viewControllers animated:true];
            });
        }];
    } synchronous:true];
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section
{
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGConversation *conversation = _list[indexPath.row];
    TGDialogListCell *cell = (TGDialogListCell *)[tableView dequeueReusableCellWithIdentifier:@"TGDialogListCell"];
    if (cell == nil)
    {
        cell = [[TGDialogListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGDialogListCell" assetsSource:[TGInterfaceAssets instance]];
    }
    
    //[self prepareCell:cell forConversation:conversation animated:false];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return 76.0f;
}

- (BOOL)tableView:(UITableView *)__unused tableView canEditRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return true;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)__unused tableView editingStyleForRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)__unused tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return true;
}

- (void)tableView:(UITableView *)__unused tableView commitEditingStyle:(UITableViewCellEditingStyle)__unused editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGConversation *conversation = _list[indexPath.row];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_backingList removeObjectAtIndex:indexPath.row];
        [TGDatabaseInstance() deleteConversation:conversation.conversationId populateActionQueue:false];
    }];
    
    NSMutableArray *mutableList = [[NSMutableArray alloc] initWithArray:_list];
    [mutableList removeObjectAtIndex:indexPath.row];
    _list = mutableList;
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self updateEmptyState:true];
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

- (void)prepareCell:(TGBroadcastConversationCell *)cell forConversation:(TGConversation *)conversation animated:(bool)__unused animated
{
    NSDictionary *dialogListData = conversation.dialogListData;
    
    /*cell.titleText = [dialogListData objectForKey:@"title"];
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
    cell.messageText = dialogListData[@"userNames"];
    
    //cell.messageText = conversation.text;
    //cell.messageAttachments = conversation.media;
    cell.users = [dialogListData objectForKey:@"users"];
    
    [cell resetView:animated];*/
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGConversation *conversation = _list[indexPath.row];
    
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
        [self.navigationController pushViewController:conversationController animated:true];
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
        
        /*if (conversations.count == 1 && _backingList.count != 0)
        {
            TGConversation *singleConversation = [conversations objectAtIndex:0];
            TGConversation *topConversation = ((TGConversation *)[_backingList objectAtIndex:0]);
            if (!singleConversation.isDeleted && _backingList.count > 0 && topConversation.conversationId == singleConversation.conversationId && topConversation.date <= singleConversation.date)
            {
                [self initializeDialogListData:singleConversation customUser:nil selfUser:selfUser];
                [_backingList replaceObjectAtIndex:0 withObject:singleConversation];
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    TGDialogListController *dialogListController = self.dialogListController;
                    
                    [dialogListController dialogListItemsChanged:nil insertedItems:nil updatedIndices:[NSArray arrayWithObject:[[NSNumber alloc] initWithInt:0]] updatedItems:[NSArray arrayWithObject:singleConversation] removedIndices:nil];
                });
                
                return;
            }
        }*/
        
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
            [_tableView reloadData];
            
            [self updateEmptyState:true];
        });
    }
}

@end
