#import "TGChatSearchController.h"

#import "TGGlobalMessageSearchSignals.h"
#import "TGDownloadHistoryForNavigatingToMessageSignal.h"

#import "TGDialogListCell.h"

#import "TGInterfaceAssets.h"
#import "TGSearchBar.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGInterfaceManager.h"

#import "TGProgressWindow.h"

#import "TGRecentHashtagsSignal.h"

extern NSString *authorNameYou;

@interface TGChatSearchController () <TGSearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    int64_t _peerId;
    void (^_messageSelected)(int32_t, NSString *, NSArray *);
    
    NSArray *_searchResults;
    NSArray *_searchResultsIds;
    
    NSString *_query;
    SMetaDisposable *_searchDisposable;
    SMetaDisposable *_downloadHistoryDisposable;
    
    TGSearchBar *_searchBar;
    UITableView *_tableView;
}

@end

@implementation TGChatSearchController

- (instancetype)initWithPeerId:(int64_t)peerId messageSelected:(void (^)(int32_t, NSString *, NSArray *))messageSelected
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _messageSelected = [messageSelected copy];
        
        _searchDisposable = [[SMetaDisposable alloc] init];
        _downloadHistoryDisposable = [[SMetaDisposable alloc] init];
        
        self.explicitTableInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 76.0f;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.view.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleLight];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    [_searchBar setShowsCancelButton:true animated:false];
    [_searchBar setAlwaysExtended:true];
    _searchBar.placeholder = TGLocalized(@"ChatSearch.SearchPlaceholder");
    [_searchBar sizeToFit];
    _searchBar.delayActivity = false;
    [self.view addSubview:_searchBar];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_searchBar resignFirstResponder];
}

- (void)searchBar:(TGSearchBar *)__unused searchBar willChangeHeight:(CGFloat)__unused newHeight
{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)__unused searchBar
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)beginSearchWithQuery:(NSString *)query
{
    _query = query;
    if (query.length == 0)
    {
        [_searchDisposable setDisposable:nil];
        [self setSearchResults:@[] searchResultsIds:@[]];
    }
    else
    {
        __weak TGChatSearchController *weakSelf = self;
        _searchBar.showActivity = true;
        [_searchDisposable setDisposable:[[[[TGGlobalMessageSearchSignals searchMessages:query peerId:_peerId accessHash:0 itemMapping:^id(id item)
        {
            if ([item isKindOfClass:[TGConversation class]])
            {
                TGConversation *conversation = item;
                if (conversation.isBroadcast)
                    return nil;
                
                [TGChatSearchController initializeDialogListData:conversation customUser:nil selfUser:[TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId]];
                return conversation;
            }
            return nil;
        }] deliverOn:[SQueue mainQueue]] onDispose:^
        {
            TGDispatchOnMainThread(^
            {
                __strong TGChatSearchController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    strongSelf->_searchBar.showActivity = false;
            });
        }] startWithNext:^(id next)
        {
            __strong TGChatSearchController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                NSMutableArray *searchResultsIds = [[NSMutableArray alloc] init];
                for (TGConversation *conversation in next)
                {
                    [searchResultsIds addObject:conversation.additionalProperties[@"mid"]];
                }
                [strongSelf setSearchResults:next searchResultsIds:searchResultsIds];
            }
        } error:^(__unused id error)
        {
        } completed:^
        {
        }]];
    }
}

+ (void)initializeDialogListData:(TGConversation *)conversation customUser:(TGUser *)customUser selfUser:(TGUser *)selfUser
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    int64_t mutePeerId = conversation.conversationId;
    
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
        mutePeerId = userId;
        
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
            titleLetters = [[NSArray alloc] initWithObjects:user.firstName, user.lastName, nil];
        else if (user.firstName.length != 0)
            titleLetters = [[NSArray alloc] initWithObjects:user.firstName, nil];
        else if (user.lastName.length != 0)
            titleLetters = [[NSArray alloc] initWithObjects:user.lastName, nil];
        
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
        dict[@"isBroadcast"] = @(conversation.isBroadcast);
        
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
    
    
    [dict setObject:[[NSNumber alloc] initWithBool:[TGDatabaseInstance() isPeerMuted:mutePeerId]] forKey:@"mute"];
    
    [dict setObject:messageUsers forKey:@"users"];
    conversation.dialogListData = dict;
}

- (void)setSearchResults:(NSArray *)searchResults searchResultsIds:(NSArray *)searchResultsIds
{
    _searchResults = searchResults;
    _searchResultsIds = searchResultsIds;
    
    [_tableView reloadData];
}

- (void)searchBar:(UISearchBar *)__unused searchBar textDidChange:(NSString *)searchText
{
    [self beginSearchWithQuery:searchText];
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section
{
    return _searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGDialogListCell *cell = (TGDialogListCell *)[tableView dequeueReusableCellWithIdentifier:@"TGDialogListSearchCell"];
    if (cell == nil)
    {
        cell = [[TGDialogListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGDialogListSearchCell" assetsSource:[TGInterfaceAssets instance]];
    }
    
    [self prepareCell:cell forConversation:_searchResults[indexPath.row] animated:false];
    
    return cell;
}

- (void)prepareCell:(TGDialogListCell *)cell forConversation:(TGConversation *)conversation animated:(bool)animated
{
    if (cell.reuseTag != (int)conversation || cell.conversationId != conversation.conversationId)
    {
        cell.reuseTag = (int)conversation;
        cell.conversationId = conversation.conversationId;
        
        cell.date = conversation.date;
        
        if (conversation.deliveryError)
            cell.deliveryState = TGMessageDeliveryStateFailed;
        else
            cell.deliveryState = conversation.deliveryState;
        
        NSDictionary *dialogListData = conversation.dialogListData;
        
        cell.titleText = [dialogListData objectForKey:@"title"];
        cell.titleLetters = [dialogListData objectForKey:@"titleLetters"];
        
        cell.isBroadcast = [dialogListData[@"isBroadcast"] boolValue];
        
        cell.isEncrypted = [dialogListData[@"isEncrypted"] boolValue];
        cell.encryptionStatus = [dialogListData[@"encryptionStatus"] intValue];
        cell.encryptedUserId = [dialogListData[@"encryptedUserId"] intValue];
        cell.encryptionOutgoing = [dialogListData[@"encryptionOutgoing"] boolValue];
        cell.encryptionFirstName = dialogListData[@"encryptionFirstName"];
        
        NSNumber *nIsChat = [dialogListData objectForKey:@"isChat"];
        if (nIsChat != nil && [nIsChat boolValue])
        {
            NSArray *chatAvatarUrls = [dialogListData objectForKey:@"chatAvatarUrls"];
            cell.groupChatAvatarCount = (int)chatAvatarUrls.count;
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
        
        cell.messageText = conversation.text;
        cell.messageAttachments = conversation.media;
        cell.users = [dialogListData objectForKey:@"users"];
        
        [cell resetView:animated];
    }
    
    [cell restartAnimations:false];
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGConversation *conversation = _searchResults[indexPath.row];
    int32_t messageId = [conversation.additionalProperties[@"searchMessageId"] intValue];
    
    if ([TGDatabaseInstance() loadMessageWithMid:messageId peerId:conversation.conversationId] != nil)
    {
        if (_messageSelected)
            _messageSelected(messageId, _query, _searchResultsIds);
    }
    else
    {
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [progressWindow show:true];
        
        __weak TGChatSearchController *weakSelf = self;
        [_downloadHistoryDisposable setDisposable:[[[TGDownloadHistoryForNavigatingToMessageSignal signalForPeerId:conversation.conversationId messageId:messageId] deliverOn:[SQueue mainQueue]] startWithNext:nil completed:^
        {
            [progressWindow dismiss:true];
            
            __strong TGChatSearchController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_messageSelected)
                    strongSelf->_messageSelected(messageId, _query, _searchResultsIds);
            }
        }]];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)__unused scrollView
{
    [_searchBar resignFirstResponder];
}

@end
