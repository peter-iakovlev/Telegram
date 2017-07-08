#import "TGTelegraphDialogListCompanion.h"

#import "TGImageUtils.h"

#import "TGAppDelegate.h"
#import "TGModernConversationController.h"
#import "TGGenericModernConversationCompanion.h"

#import "TGDialogListController.h"

#import "SGraphObjectNode.h"
#import "SGraphListNode.h"

#import "TGDatabase.h"

#import "TGInterfaceManager.h"
#import "TGInterfaceAssets.h"

#import "TGSelectContactController.h"

#import "TGTelegraph.h"

#import "TGForwardTargetController.h"

#import "TGTelegraphConversationMessageAssetsSource.h"

#import "TGModernConversationCompanion.h"

#import "TGStringUtils.h"

#import "TGProgressWindow.h"

#include <map>
#include <set>

#import <libkern/OSAtomic.h>

#import "TGAlertView.h"

#import "TGChannelManagementSignals.h"

#import "TGCreateGroupController.h"

#import "TGPeerIdAdapter.h"

#import "TGLocalization.h"

typedef enum {
    TGDialogListStateNormal = 0,
    TGDialogListStateConnecting = 1,
    TGDialogListStateConnectingToProxy = 2,
    TGDialogListStateUpdating = 3,
    TGDialogListStateWaitingForNetwork = 4
} TGDialogListState;

@interface TGTelegraphDialogListCompanion ()
{
    volatile int32_t _conversationsUpdateTaskId;
    
    TGProgressWindow *_progressWindow;
    
    SMetaDisposable *_channelsDisposable;
    
    bool _canLoadMore;
}

@property (nonatomic, strong) NSMutableArray *conversationList;

@property (nonatomic, strong) NSString *searchString;

@property (nonatomic) TGDialogListState state;

@end

@implementation TGTelegraphDialogListCompanion

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _conversationList = [[NSMutableArray alloc] init];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        self.showSecretInForwardMode = true;
        self.showListEditingControl = true;

        [self resetWatchedNodePaths];
        
        _channelsDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    [_channelsDisposable dispose];
    
    TGProgressWindow *progressWindow = _progressWindow;
    TGDispatchOnMainThread(^
    {
        [progressWindow dismiss:false];
    });
}

- (id<TGDialogListCellAssetsSource>)dialogListCellAssetsSource
{
    return [TGInterfaceAssets instance];
}

- (void)dialogListReady
{
    [[TGInterfaceManager instance] preload];
}

- (void)resetWatchedNodePaths
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [ActionStageInstance() removeWatcher:self];

        [ActionStageInstance() watchForPath:@"/tg/conversations" watcher:self];
        [ActionStageInstance() watchForPath:@"/tg/broadcastConversations" watcher:self];
        [ActionStageInstance() watchForPath:@"/tg/channelListSyncrhonized" watcher:self];
        [ActionStageInstance() watchForGenericPath:@"/tg/dialoglist/@" watcher:self];
        [ActionStageInstance() watchForPath:@"/tg/userdatachanges" watcher:self];
        [ActionStageInstance() watchForPath:@"/tg/unreadCount" watcher:self];
        [ActionStageInstance() watchForPath:@"/tg/conversation/*/typing" watcher:self];
        [ActionStageInstance() watchForPath:@"/tg/contactlist" watcher:self];
        [ActionStageInstance() watchForPath:@"/databasePasswordChanged" watcher:self];
        
        [ActionStageInstance() watchForGenericPath:@"/tg/peerSettings/@" watcher:self];
        
        [ActionStageInstance() watchForPath:@"/tg/service/synchronizationstate" watcher:self];
        [ActionStageInstance() requestActor:@"/tg/service/synchronizationstate" options:nil watcher:self];
        
        int unreadCount = [TGDatabaseInstance() databaseState].unreadCount;
        [self actionStageResourceDispatched:@"/tg/unreadCount" resource:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:unreadCount]] arguments:@{@"previous": @true}];
    }];
}

- (void)clearData
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_channelsDisposable setDisposable:nil];
        
        [_conversationList removeAllObjects];
        
        [self resetWatchedNodePaths];
        
        _canLoadMore = false;
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            TGDialogListController *controller = self.dialogListController;
            if (controller != nil)
            {
                controller.canLoadMore = false;
                [controller dialogListFullyReloaded:[[NSArray alloc] init]];
                [controller resetState];
            }
        });
    }];
}

- (void)composeMessageAndOpenSearch:(bool)openSearch
{
    if ([TGAppDelegateInstance isDisplayingPasscodeWindow])
        return;
    
    TGDialogListController *controller = self.dialogListController;
    [controller selectConversationWithId:0];
    
    TGSelectContactController *selectController = [[TGSelectContactController alloc] initWithCreateGroup:false createEncrypted:false createBroadcast:false createChannel:false inviteToChannel:false showLink:false];
    selectController.shouldOpenSearch = openSearch;
    [TGAppDelegateInstance.rootController pushContentController:selectController];
}

- (void)navigateToBroadcastLists
{
    TGCreateGroupController *controller = [[TGCreateGroupController alloc] initWithCreateChannel:true createChannelGroup:false];
    [TGAppDelegateInstance.rootController pushContentController:controller];
}

- (void)navigateToNewGroup
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isGroupCreationEnabled:&disabledMessage])
    {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        return;
    }
    
    TGDialogListController *controller = self.dialogListController;
    [controller selectConversationWithId:0];
    
    TGSelectContactController *selectController = [[TGSelectContactController alloc] initWithCreateGroup:true createEncrypted:false createBroadcast:false createChannel:false inviteToChannel:false showLink:false];
    [TGAppDelegateInstance.rootController pushContentController:selectController];
}

- (void)conversationSelected:(TGConversation *)conversation
{    
    if (self.forwardMode || self.privacyMode)
    {
        [_conversatioSelectedWatcher requestAction:@"conversationSelected" options:[[NSDictionary alloc] initWithObjectsAndKeys:conversation, @"conversation", nil]];
    }
    else
    {
        if (conversation.isBroadcast)
        {
            
        }
        else
        {
            int64_t conversationId = conversation.conversationId;
            if (TGPeerIdIsChannel(conversationId) && conversation.kind == TGConversationKindTemporaryChannel) {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow showWithDelay:0.1];
                [[[[TGChannelManagementSignals preloadedChannel:conversationId] deliverOn:[SQueue mainQueue]] onDispose:^{
                    TGDispatchOnMainThread(^{
                        [progressWindow dismiss:true];
                    });
                }] startWithNext:nil completed:^{
                    [[TGInterfaceManager instance] navigateToConversationWithId:conversationId conversation:conversation performActions:nil atMessage:nil clearStack:true openKeyboard:false canOpenKeyboardWhileInTransition:true animated:true];
                }];
            } else {
                [[TGInterfaceManager instance] navigateToConversationWithId:conversationId conversation:conversation performActions:nil atMessage:nil clearStack:true openKeyboard:false canOpenKeyboardWhileInTransition:true animated:true];
            }
        }
    }
}

- (void)searchResultSelectedConversation:(TGConversation *)conversation
{
    [self conversationSelected:conversation];
}

- (void)searchResultSelectedConversation:(TGConversation *)conversation atMessageId:(int)messageId
{
    if (!self.forwardMode && !self.privacyMode)
    {
        if ([TGDatabaseInstance() loadMessageWithMid:messageId peerId:conversation.conversationId] != nil)
        {
            int64_t conversationId = conversation.conversationId;
            [[TGInterfaceManager instance] navigateToConversationWithId:conversationId conversation:conversation performActions:nil atMessage:@{@"mid": @(messageId)} clearStack:true openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
        }
        else
        {
            _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [_progressWindow show:true];
            
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/loadConversationAndMessageForSearch/(%" PRId64 ", %" PRId32 ")", conversation.conversationId, messageId] options:@{@"peerId": @(conversation.conversationId), @"accessHash": @(conversation.accessHash), @"messageId": @(messageId)} flags:0 watcher:self];
        }
    }
}

- (void)searchResultSelectedMessage:(TGMessage *)__unused message
{
    
}

- (bool)shouldDisplayEmptyListPlaceholder
{
    return TGTelegraphInstance.clientUserId != 0;
}

- (void)wakeUp
{
}

- (void)resetLocalization
{
    
}

- (int64_t)openedConversationId
{
    UIViewController *topViewController = [TGAppDelegateInstance.rootController.viewControllers lastObject];

    if ([topViewController isKindOfClass:[TGModernConversationController class]])
    {
        return ((TGGenericModernConversationCompanion *)((TGModernConversationController *)(topViewController)).companion).conversationId;
    }
    
    return 0;
}

- (void)hintMoveConversationAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    [ActionStageInstance() dispatchOnStageQueue:^{
        if (fromIndex < toIndex) {
            //toIndex--;
        }
        
        id object = [_conversationList objectAtIndex:fromIndex];
        [_conversationList removeObjectAtIndex:fromIndex];
        [_conversationList insertObject:object atIndex:toIndex];
    }];
}

- (bool)isConversationOpened:(int64_t)conversationId
{
    UIViewController *topViewController = [TGAppDelegateInstance.rootController.viewControllers lastObject];
    
    if ([topViewController isKindOfClass:[TGModernConversationController class]])
    {
        return ((TGGenericModernConversationCompanion *)((TGModernConversationController *)(topViewController)).companion).conversationId == conversationId;
    }
    
    return false;
}

- (void)deleteItem:(TGConversation *)conversation animated:(bool)animated
{
    TGDispatchOnMainThread(^
    {
        if ([self isConversationOpened:conversation.conversationId]) {
            [TGAppDelegateInstance.rootController clearContentControllers];
        }
    });
    
    int64_t conversationId = conversation.conversationId;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        bool found = false;
        for (int i = 0; i < (int)self.conversationList.count; i++)
        {
            TGConversation *conversation = [self.conversationList objectAtIndex:i];
            if (conversation.conversationId == conversationId)
            {
                found = true;
                [self.conversationList removeObjectAtIndex:i];
                
                NSNumber *removedIndex = [[NSNumber alloc] initWithInt:i];
                
                [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/delete", conversationId] options:@{@"conversationId": @(conversationId), @"block": @true} watcher:self];
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    if (!animated)
                        [UIView setAnimationsEnabled:false];
                    TGDialogListController *dialogListController = self.dialogListController;
                    [dialogListController dialogListItemsChanged:nil insertedItems:nil updatedIndices:nil updatedItems:nil removedIndices:[NSArray arrayWithObject:removedIndex]];
                    if (!animated)
                        [UIView setAnimationsEnabled:true];
                });
                
                break;
            }
        }
        
        if (!found)
        {
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/delete", conversationId] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:conversationId] forKey:@"conversationId"] watcher:self];
        }
    }];
}

- (void)clearItem:(TGConversation *)conversation animated:(bool)animated
{
    int64_t conversationId = conversation.conversationId;
 
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        for (int i = 0; i < (int)self.conversationList.count; i++)
        {
            TGConversation *conversation = [self.conversationList objectAtIndex:i];
            if (conversation.conversationId == conversationId)
            {
                [self.conversationList removeObjectAtIndex:i];
                
                TGUser *user = conversation.conversationId > 0 ? [TGDatabaseInstance() loadUser:(int)conversation.conversationId] : nil;
                if (user != nil && (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot))
                {
                    NSNumber *removedIndex = [[NSNumber alloc] initWithInt:i];
                    
                    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/delete", conversationId] options:@{@"conversationId": @(conversationId), @"block": @false} watcher:self];
                    
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        if (!animated)
                            [UIView setAnimationsEnabled:false];
                        TGDialogListController *dialogListController = self.dialogListController;
                        [dialogListController dialogListItemsChanged:nil insertedItems:nil updatedIndices:nil updatedItems:nil removedIndices:[NSArray arrayWithObject:removedIndex]];
                        if (!animated)
                            [UIView setAnimationsEnabled:true];
                    });
                }
                else
                {
                    int actionId = 0;
                    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/clearHistory/(dialogList%d)", conversationId, actionId++] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:conversationId] forKey:@"conversationId"] watcher:self];
                    
                    conversation = [conversation copy];

                    conversation.outgoing = false;
                    conversation.text = nil;
                    conversation.media = nil;
                    conversation.unread = false;
                    conversation.unreadCount = 0;
                    conversation.fromUid = 0;
                    conversation.deliveryError = false;
                    conversation.deliveryState = TGMessageDeliveryStateDelivered;
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:conversation.dialogListData];
                    dict[@"authorName"] = @"";
                    
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        if (!animated)
                            [UIView setAnimationsEnabled:false];
                        TGDialogListController *dialogListController = self.dialogListController;
                        [dialogListController dialogListItemsChanged:nil insertedItems:nil updatedIndices:@[@(i)] updatedItems:@[conversation] removedIndices:nil];
                        if (!animated)
                            [UIView setAnimationsEnabled:true];
                    });
                }
                
                break;
            }
        }
    }];
}

- (void)loadMoreItems
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSMutableArray *currentConversationIds = [[NSMutableArray alloc] initWithCapacity:_conversationList.count];
        
        int minDate = INT_MAX;
        for (TGConversation *conversation in _conversationList)
        {
            if (conversation.date < minDate && !conversation.isBroadcast)
                minDate = conversation.date;
            
            [currentConversationIds addObject:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
        }
        
        if (minDate != INT_MAX)
        {
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/dialoglist/(%d)", minDate] options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:40], @"limit", [NSNumber numberWithInt:minDate], @"date", currentConversationIds, @"excludeConversationIds", nil] watcher:self];
        }
        else
        {
            _canLoadMore = false;
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGDialogListController *dialogListController = self.dialogListController;
                
                dialogListController.canLoadMore = false;
                [dialogListController dialogListFullyReloaded:[NSArray array]];
            });
        }
    }];
}

- (void)beginSearch:(NSString *)queryString inMessages:(bool)inMessages
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [self resetWatchedNodePaths];

        self.searchString = [[queryString stringByReplacingOccurrencesOfString:@" +" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, queryString.length)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (self.searchString.length == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGDialogListController *dialogListController = self.dialogListController;
                [dialogListController searchResultsReloaded:nil searchString:nil];
            });
        }
        else
        {
            if (inMessages)
            {
                [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/search/messages/(%lu)", (unsigned long)[self.searchString hash]] options:[NSDictionary dictionaryWithObject:self.searchString forKey:@"query"] watcher:self];
            }
            else
            {
                [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/search/dialogs/(%lu)", (unsigned long)[self.searchString hash]] options:[NSDictionary dictionaryWithObject:self.searchString forKey:@"query"] watcher:self];
            }
        }
    }];
}

- (void)searchResultSelectedUser:(TGUser *)user
{
    if (self.forwardMode || self.privacyMode)
    {
        [_conversatioSelectedWatcher requestAction:@"userSelected" options:[[NSDictionary alloc] initWithObjectsAndKeys:user, @"user", nil]];
    }
    else
    {
        int64_t conversationId = user.uid;
        [[TGInterfaceManager instance] navigateToConversationWithId:conversationId conversation:nil];
    }
}

- (NSString *)stringForMemberCount:(int)memberCount
{
    return [effectiveLocalization() getPluralized:@"Conversation.StatusRecipients" count:(int32_t)memberCount];
}

- (void)initializeDialogListData:(TGConversation *)conversation customUser:(TGUser *)customUser selfUser:(TGUser *)selfUser
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    int64_t mutePeerId = conversation.conversationId;
    
    dict[@"authorIsSelf"] = @(conversation.fromUid == TGTelegraphInstance.clientUserId);
    
    if (conversation.isChannel) {
        dict[@"isChannel"] = @true;
        
        [dict setObject:(conversation.chatTitle == nil ? @"" : conversation.chatTitle) forKey:@"title"];
        
        if (conversation.chatPhotoSmall.length != 0)
            [dict setObject:conversation.chatPhotoSmall forKey:@"avatarUrl"];
        
        [dict setObject:[NSNumber numberWithBool:true] forKey:@"isChat"];
        [dict setObject:[NSNumber numberWithBool:conversation.isVerified] forKey:@"isVerified"];
        
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
    else if (!conversation.isChat || conversation.isEncrypted)
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
        
        dict[@"isVerified"] = @(user.isVerified);
        
        NSString *title = nil;
        NSArray *titleLetters = nil;
        
        if (user.uid == [TGTelegraphInstance serviceUserUid] || user.uid == [TGTelegraphInstance voipSupportUserUid])
            title = [user displayName];
        else if ((user.phoneNumber.length != 0 && ![TGDatabaseInstance() uidIsRemoteContact:user.uid]))
            title = user.formattedPhoneNumber;
        else
            title = [user displayName];
        
        if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot) {
            dict[@"isBot"] = @true;
        }
        
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
        
        if (conversation.isBroadcast && conversation.chatTitle.length == 0)
            dict[@"title"] = [self stringForMemberCount:conversation.chatParticipantCount];
        else
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
    
    if (conversation.draft != nil) {
        dict[@"draft"] = conversation.draft;
    }
    
    NSMutableDictionary *messageUsers = [[NSMutableDictionary alloc] init];
    for (TGMediaAttachment *attachment in conversation.media)
    {
        if (attachment.type == TGActionMediaAttachmentType)
        {
            TGActionMediaAttachment *actionAttachment = (TGActionMediaAttachment *)attachment;
            if (actionAttachment.actionType == TGMessageActionChatAddMember || actionAttachment.actionType == TGMessageActionChatDeleteMember || actionAttachment.actionType == TGMessageActionChannelInviter)
            {
                NSArray *uids = actionAttachment.actionData[@"uids"];
                if (uids != nil) {
                    for (NSNumber *nUid in uids) {
                        TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                        if (user != nil)
                            [messageUsers setObject:user forKey:nUid];
                    }
                } else {
                    NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                    if (nUid != nil)
                    {
                        TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                        if (user != nil)
                            [messageUsers setObject:user forKey:nUid];
                    }
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

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path isEqualToString:[NSString stringWithFormat:@"/tg/search/messages/(%lu)", (unsigned long)[_searchString hash]]])
    {
        if ([messageType isEqualToString:@"searchResultsUpdated"])
        {
            NSArray *conversations = [((SGraphObjectNode *)message[@"dialogs"]).object sortedArrayUsingComparator:^NSComparisonResult(TGConversation *conversation1, TGConversation *conversation2)
            {
                return conversation1.date > conversation2.date ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            NSMutableArray *result = [[NSMutableArray alloc] init];
            
            TGUser *selfUser = [[TGDatabase instance] loadUser:TGTelegraphInstance.clientUserId];
            
            CFAbsoluteTime dialogListDataStartTime = CFAbsoluteTimeGetCurrent();
            
            for (TGConversation *conversation in conversations)
            {
                [self initializeDialogListData:conversation customUser:nil selfUser:selfUser];
                [result addObject:conversation];
            }
            
            NSString *searchString = _searchString;
            
            TGLog(@"Dialog list data parsing time: %f s", CFAbsoluteTimeGetCurrent() - dialogListDataStartTime);
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGDialogListController *dialogListController = self.dialogListController;
                [dialogListController searchResultsReloaded:@{@"dialogs": result} searchString:searchString];
            });
        }
    }
}

- (id)processSearchResultItem:(id)item
{
    bool forwardMode = self.forwardMode;
    bool privacyMode = self.privacyMode;
    bool showGroupsOnly = self.showGroupsOnly;
    bool showSecretInForwardMode = self.showSecretInForwardMode;
    
    if ([item isKindOfClass:[TGConversation class]])
    {
        TGConversation *conversation = (TGConversation *)item;
        if (((forwardMode || privacyMode) && conversation.conversationId <= INT_MIN) && !showSecretInForwardMode)
            return nil;
        
        if ((forwardMode || privacyMode) && conversation.isBroadcast)
            return nil;
        
        if (showGroupsOnly && conversation.isChannel && conversation.isChannelGroup) {
            [self initializeDialogListData:conversation customUser:nil selfUser:[TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId]];
            return conversation;
        }
        
        if (showGroupsOnly && (conversation.conversationId > 0 || conversation.conversationId <= INT_MIN))
            return nil;
        
        [self initializeDialogListData:conversation customUser:nil selfUser:[TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId]];
        return conversation;
    }
    else if ([item isKindOfClass:[TGUser class]])
    {
        if (showGroupsOnly)
            return nil;
        
        return item;
    }
    
    return nil;
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    if ([path isEqualToString:[NSString stringWithFormat:@"/tg/search/dialogs/(%lu)", (unsigned long)[_searchString hash]]])
    {
        NSDictionary *dict = ((SGraphObjectNode *)result).object;
        
        NSArray *users = [dict objectForKey:@"users"];
        NSArray *chats = [dict objectForKey:@"chats"];
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        if (chats != nil)
        {
            bool forwardMode = self.forwardMode;
            bool privacyMode = self.privacyMode;
            bool showGroupsOnly = self.showGroupsOnly;
            bool showSecretInForwardMode = self.showSecretInForwardMode;
            
            for (id object in chats)
            {
                if ([object isKindOfClass:[TGConversation class]])
                {
                    TGConversation *conversation = (TGConversation *)object;
                    if (((forwardMode || privacyMode) && conversation.conversationId <= INT_MIN) && !showSecretInForwardMode)
                        continue;
                    
                    if (conversation.isDeactivated || conversation.isDeleted) {
                        continue;
                    }
                    
                    if ((forwardMode || privacyMode) && conversation.isBroadcast)
                        continue;
                    
                    if (showGroupsOnly && (conversation.conversationId <= INT_MIN || conversation.conversationId > 0))
                        continue;
                    
                    [self initializeDialogListData:conversation customUser:nil selfUser:[TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId]];
                    [result addObject:conversation];
                }
                else
                {
                    [result addObject:object];
                }
            }
        }
        if (users != nil)
            [result addObjectsFromArray:users];
        
        NSString *searchString = _searchString;

        dispatch_async(dispatch_get_main_queue(), ^
        {
            TGDialogListController *dialogListController = self.dialogListController;
            [dialogListController searchResultsReloaded:@{@"dialogs": result} searchString:searchString];
        });
    }
    else if ([path isEqualToString:[NSString stringWithFormat:@"/tg/search/messages/(%lu)", (unsigned long)[_searchString hash]]])
    {
        [self actorMessageReceived:path messageType:@"searchResultsUpdated" message:result];
    }
    else if ([path hasPrefix:@"/tg/dialoglist"])
    {
        if (resultCode == 0)
        {
            NSMutableArray *conversationIds = [[NSMutableArray alloc] init];
            for (TGConversation *conversation in _conversationList) {
                [conversationIds addObject:@(conversation.conversationId)];
            }
            
            SGraphListNode *listNode = (SGraphListNode *)result;
            NSMutableArray *loadedItems = [[listNode items] mutableCopy];
            bool canLoadMore = false;
            bool forwardMode = self.forwardMode;
            bool privacyMode = self.privacyMode;
            bool showGroupsOnly = self.showGroupsOnly;
            bool showSecretInForwardMode = self.showSecretInForwardMode;
            
            TGUser *selfUser = [[TGDatabase instance] loadUser:TGTelegraphInstance.clientUserId];
            
            if ((forwardMode || privacyMode) && !showSecretInForwardMode)
            {
                for (int i = 0; i < (int)loadedItems.count; i++)
                {
                    TGConversation *conversation = (TGConversation *)loadedItems[i];
                    if (conversation.isChannel && conversation.isChannelGroup && (!self.botStartMode || conversation.channelRole == TGChannelRoleCreator || conversation.channelRole == TGChannelRoleModerator || conversation.channelRole == TGChannelRolePublisher)) {
                        
                    } else if (conversation.conversationId <= INT_MIN)
                    {
                        [loadedItems removeObjectAtIndex:i];
                        i--;
                    }
                }
            }
            
            if (forwardMode || privacyMode)
            {
                for (int i = 0; i < (int)loadedItems.count; i++)
                {
                    if (((TGConversation *)loadedItems[i]).isBroadcast)
                    {
                        [loadedItems removeObjectAtIndex:i];
                        i--;
                    }
                }
            }
            
            for (int i = 0; i < (int)loadedItems.count; i++)
            {
                if (((TGConversation *)loadedItems[i]).isDeactivated)
                {
                    [loadedItems removeObjectAtIndex:i];
                    i--;
                }
            }
            
            if (showGroupsOnly)
            {
                for (int i = 0; i < (int)loadedItems.count; i++)
                {
                    TGConversation *conversation = loadedItems[i];
                    if (conversation.isChannel && conversation.isChannelGroup && (!self.botStartMode || conversation.channelRole == TGChannelRoleCreator || conversation.channelRole == TGChannelRoleModerator || conversation.channelRole == TGChannelRolePublisher)) {
                    } else if (conversation.conversationId <= INT_MIN || conversation.conversationId > 0) {
                        [loadedItems removeObjectAtIndex:i];
                        i--;
                    }
                }
            }
            
            for (TGConversation *conversation in loadedItems)
            {
                [self initializeDialogListData:conversation customUser:nil selfUser:selfUser];
            }
            
            if (_conversationList.count == 0)
            {
                [_conversationList addObjectsFromArray:loadedItems];
                canLoadMore = loadedItems.count != 0;
            }
            else
            {
                std::set<int64_t> existingConversations;
                for (TGConversation *conversation in _conversationList)
                {
                    existingConversations.insert(conversation.conversationId);
                }
                
                for (int i = 0; i < (int)loadedItems.count; i++)
                {
                    TGConversation *conversation = [loadedItems objectAtIndex:i];
                    if (existingConversations.find(conversation.conversationId) != existingConversations.end())
                    {
                        [loadedItems removeObjectAtIndex:i];
                        i--;
                    }
                }
                
                canLoadMore = loadedItems.count != 0;
                
                [_conversationList addObjectsFromArray:loadedItems];
            }
            
            [_conversationList sortUsingComparator:^NSComparisonResult(TGConversation *conversation1, TGConversation *conversation2)
            {
                int date1 = conversation1.date;
                int date2 = conversation2.date;
                
                if (date1 > date2)
                    return NSOrderedAscending;
                else if (date1 < date2)
                    return NSOrderedDescending;
                else
                    return NSOrderedSame;
            }];
            
            NSArray *items = [NSArray arrayWithArray:_conversationList];
            
            _canLoadMore = canLoadMore;
            
            NSMutableArray *currentConversationIds = [[NSMutableArray alloc] init];
            for (TGConversation *conversation in _conversationList) {
                [currentConversationIds addObject:@(conversation.conversationId)];
            }
            
            if ([currentConversationIds isEqualToArray:conversationIds]) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                for (TGConversation *conversation in _conversationList) {
                    dict[@(conversation.conversationId)] = conversation;
                }
                TGDispatchOnMainThread(^{
                    TGDialogListController *controller = self.dialogListController;
                    if (currentConversationIds.count == 0) {
                        [controller dialogListFullyReloaded:items];
                    } else {
                        [controller updateConversations:dict];
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    TGDialogListController *controller = self.dialogListController;
                    if (controller != nil)
                    {
                        controller.canLoadMore = canLoadMore;
                        [controller dialogListFullyReloaded:items];
                    }
                });
            }
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                NSMutableArray *conversationIds = [[NSMutableArray alloc] init];
                for (TGConversation *conversation in items)
                {
                    [conversationIds addObject:@(conversation.conversationId)];
                }
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                {
                    [self dialogListReady];
                    
                    [TGModernConversationCompanion warmupResources];
                    
                    //[TGDatabaseInstance() preloadConversationStates:conversationIds];
                });
            });
        }
        else
        {
        }
    }
    else if ([path isEqualToString:@"/tg/service/synchronizationstate"])
    {
        int state = [((SGraphObjectNode *)result).object intValue];
        
        TGDialogListState newState;
        
        if (state & 2)
        {
            if (state & 4)
                newState = TGDialogListStateWaitingForNetwork;
            else {
                if (state & 8) {
                    newState = TGDialogListStateConnectingToProxy;
                } else {
                    newState = TGDialogListStateConnecting;
                }
            }
        }
        else if (state & 1)
            newState = TGDialogListStateUpdating;
        else
            newState = TGDialogListStateNormal;

        if (newState != _state)
        {
            _state = newState;
            dispatch_async(dispatch_get_main_queue(), ^
            {
                NSString *title = nil;
                if (newState == TGDialogListStateConnecting)
                    title = TGLocalized(@"State.Connecting");
                else if (newState == TGDialogListStateConnectingToProxy)
                    title = TGLocalized(@"State.ConnectingToProxy");
                else if (newState == TGDialogListStateUpdating)
                    title = TGLocalized(@"State.Updating");
                else if (newState == TGDialogListStateWaitingForNetwork)
                    title = TGLocalized(@"State.WaitingForNetwork");
                
                TGDialogListController *dialogListController = self.dialogListController;
                [dialogListController titleStateUpdated:title isLoading:newState != TGDialogListStateNormal isProxy:newState == TGDialogListStateConnectingToProxy];
            });
        }
    }
    else if ([path hasPrefix:@"/tg/loadConversationAndMessageForSearch/"])
    {
        TGDispatchOnMainThread(^
        {
            [_progressWindow dismiss:true];
            _progressWindow = nil;
            
            if (resultCode == ASStatusSuccess)
            {
                int64_t conversationId = [result[@"peerId"] longLongValue];
                TGConversation *conversation = result[@"conversation"];
                int32_t messageId = [result[@"messageId"] intValue];
                
                [[TGInterfaceManager instance] navigateToConversationWithId:conversationId conversation:conversation performActions:nil atMessage:@{@"mid": @(messageId)} clearStack:true openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
            }
        });
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments
{
    if ([path hasPrefix:@"/tg/dialoglist"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    else if ([path isEqualToString:@"/tg/conversations"] || [path isEqualToString:@"/tg/broadcastConversations"])
    {
        NSMutableArray *conversationIds = [[NSMutableArray alloc] init];
        for (TGConversation *conversation in _conversationList) {
            [conversationIds addObject:@(conversation.conversationId)];
        }
        
        NSMutableArray *conversations = [((SGraphObjectNode *)resource).object mutableCopy];
        
        for (NSInteger i = 0; i < (NSInteger)conversations.count; i++) {
            TGConversation *conversation = conversations[i];
            
            if (conversation.isChannel && conversation.kind != TGConversationKindPersistentChannel) {
                [conversations removeObjectAtIndex:i];
                i--;
            }
        }
        
        TGUser *selfUser = [[TGDatabase instance] loadUser:TGTelegraphInstance.clientUserId];
        
        TGDialogListController *controller = self.dialogListController;
        if (controller.isDisplayingSearch)
        {
            NSMutableArray *searchConversations = [[NSMutableArray alloc] init];
            for (TGConversation *conversation in ((SGraphObjectNode *)resource).object)
            {
                TGConversation *copyConversation = [conversation copy];
                [self initializeDialogListData:copyConversation customUser:nil selfUser:selfUser];
                [searchConversations addObject:copyConversation];
            }
            TGDispatchOnMainThread(^
            {
                [controller updateSearchConversations:searchConversations];
            });
        }
        
        if ((self.forwardMode || self.privacyMode) && !self.showSecretInForwardMode)
        {
            for (int i = 0; i < (int)conversations.count; i++)
            {
                TGConversation *conversation = (TGConversation *)conversations[i];
                if (conversation.isChannel && conversation.isChannelGroup && (!self.botStartMode || conversation.channelRole == TGChannelRoleCreator || conversation.channelRole == TGChannelRoleModerator || conversation.channelRole == TGChannelRolePublisher)) {
                    
                } else {
                    if (conversation.conversationId <= INT_MIN)
                    {
                        [conversations removeObjectAtIndex:i];
                        i--;
                    }
                }
            }
        }
        
        if (self.forwardMode || self.privacyMode)
        {
            for (int i = 0; i < (int)conversations.count; i++)
            {
                if (((TGConversation *)conversations[i]).isBroadcast)
                {
                    [conversations removeObjectAtIndex:i];
                    i--;
                }
            }
        }
        
        if (self.showGroupsOnly)
        {
            for (int i = 0; i < (int)conversations.count; i++)
            {
                TGConversation *conversation = conversations[i];
                if (conversation.isChannel && conversation.isChannelGroup && (!self.botStartMode || conversation.channelRole == TGChannelRoleCreator || conversation.channelRole == TGChannelRoleModerator || conversation.channelRole == TGChannelRolePublisher)) {
                    
                } else if (conversation.conversationId <= INT_MIN || conversation.conversationId > 0) {
                    [conversations removeObjectAtIndex:i];
                    i--;
                }
            }
        }
        
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
        
        if (conversations.count == 1 && _conversationList.count != 0)
        {
            TGConversation *singleConversation = [conversations objectAtIndex:0];
            TGConversation *topConversation = ((TGConversation *)[_conversationList objectAtIndex:0]);
            if (!singleConversation.isDeleted && !singleConversation.isDeactivated && _conversationList.count > 0 && topConversation.conversationId == singleConversation.conversationId && topConversation.date <= singleConversation.date)
            {
                [self initializeDialogListData:singleConversation customUser:nil selfUser:selfUser];
                [_conversationList replaceObjectAtIndex:0 withObject:singleConversation];
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    TGDialogListController *dialogListController = self.dialogListController;
                    
                    [dialogListController dialogListItemsChanged:nil insertedItems:nil updatedIndices:[NSArray arrayWithObject:[[NSNumber alloc] initWithInt:0]] updatedItems:[NSArray arrayWithObject:singleConversation] removedIndices:nil];
                });
                
                return;
            }
        }
        
        std::map<int64_t, int> conversationIdToIndex;
        int index = -1;
        for (TGConversation *conversation in _conversationList)
        {
            index++;
            int64_t conversationId = conversation.conversationId;
            conversationIdToIndex.insert(std::pair<int64_t, int>(conversationId, index));
        }
        
        NSMutableSet *addedPeerIds = [[NSMutableSet alloc] init];
        for (TGConversation *conversation in conversations) {
            if (conversationIdToIndex.find(conversation.conversationId) == conversationIdToIndex.end()) {
                [addedPeerIds addObject:@(conversation.conversationId)];
            }
        }
        
        NSMutableSet *candidatesForCutoff = [[NSMutableSet alloc] init];
        
        for (int i = 0; i < (int)conversations.count; i++)
        {
            TGConversation *conversation = [conversations objectAtIndex:i];
            int64_t conversationId = conversation.conversationId;
            std::map<int64_t, int>::iterator it = conversationIdToIndex.find(conversationId);
            if (it != conversationIdToIndex.end())
            {
                TGConversation *newConversation = [conversation copy];
                if (!newConversation.isDeleted && !newConversation.isDeactivated)
                    [self initializeDialogListData:newConversation customUser:nil selfUser:selfUser];
                
                TGConversation *previousConversation = _conversationList[(it->second)];
                
                if (newConversation.date < previousConversation.date) {
                    [candidatesForCutoff addObject:@(newConversation.conversationId)];
                }
                
                [_conversationList replaceObjectAtIndex:(it->second) withObject:newConversation];
                [conversations removeObjectAtIndex:i];
                i--;
            }
        }
        
        for (int i = 0; i < (int)_conversationList.count; i++)
        {
            TGConversation *conversation = [_conversationList objectAtIndex:i];
            if (conversation.isDeleted || conversation.isDeactivated)
            {
                [_conversationList removeObjectAtIndex:i];
                i--;
            }
        }
        
        for (TGConversation *conversation in conversations)
        {
            TGConversation *newConversation = [conversation copy];
            if (!newConversation.isDeleted && !newConversation.isDeactivated)
            {
                [self initializeDialogListData:newConversation customUser:nil selfUser:selfUser];
                
                [_conversationList addObject:newConversation];
            }
        }
        
        [_conversationList sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
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
        
        if ([arguments[@"filterEarliest"] boolValue] && _canLoadMore) {
            while (_conversationList.count != 0) {
                TGConversation *conversation = [_conversationList lastObject];
                if (conversation.isChannel) {
                    [_conversationList removeLastObject];
                } else {
                    break;
                }
            }
        }
        
        if (candidatesForCutoff.count != 0 && _canLoadMore) {
            for (NSInteger i = _conversationList.count - 1; i >= 0; i--) {
                TGConversation *conversation = _conversationList[i];
                if ([candidatesForCutoff containsObject:@(conversation.conversationId)]) {
                    [_conversationList removeObjectAtIndex:i];
                } else {
                    break;
                }
            }
        }
        
        if (_canLoadMore) {
            for (NSInteger i = _conversationList.count - 1; i >= 0; i--) {
                TGConversation *conversation = _conversationList[i];
                if ([addedPeerIds containsObject:@(conversation.conversationId)]) {
                    [_conversationList removeObjectAtIndex:i];
                } else {
                    break;
                }
            }
        }
        
        NSMutableArray *currentConversationIds = [[NSMutableArray alloc] init];
        for (TGConversation *conversation in _conversationList) {
            [currentConversationIds addObject:@(conversation.conversationId)];
        }
        
        if ([currentConversationIds isEqualToArray:conversationIds]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for (TGConversation *conversation in _conversationList) {
                dict[@(conversation.conversationId)] = conversation;
            }
            TGDispatchOnMainThread(^{
                TGDialogListController *controller = self.dialogListController;
                [controller updateConversations:dict];
            });
        } else {
            NSArray *items = [NSArray arrayWithArray:_conversationList];
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGDialogListController *controller = self.dialogListController;
                if (controller != nil)
                {
                    [controller dialogListFullyReloaded:items];
                    if (!self.forwardMode && !self.privacyMode) {
                        [controller selectConversationWithId:[self openedConversationId]];
                    }
                }
            });
        }
    }
    else if ([path isEqualToString:@"/tg/userdatachanges"])
    {
        std::map<int, int> userIdToIndex;
        int index = -1;
        NSArray *users = (((SGraphObjectNode *)resource).object);
        for (TGUser *user in users)
        {
            index++;
            userIdToIndex.insert(std::pair<int, int>(user.uid, index));
        }
        
        TGUser *selfUser = [[TGDatabase instance] loadUser:TGTelegraphInstance.clientUserId];
        
        NSMutableArray *updatedIndices = [[NSMutableArray alloc] init];
        NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
        
        bool updateAllOutgoing = userIdToIndex.find(TGTelegraphInstance.clientUserId) != userIdToIndex.end();
        
        for (index = 0; index < (int)_conversationList.count; index++)
        {
            TGConversation *conversation = [_conversationList objectAtIndex:index];
            
            int userId = 0;
            if (conversation.isEncrypted)
            {
                if (conversation.chatParticipants.chatParticipantUids.count != 0)
                    userId = [conversation.chatParticipants.chatParticipantUids[0] intValue];
            }
            else if (conversation.isChat)
                userId = conversation.outgoing ? TGTelegraphInstance.clientUserId : conversation.fromUid;
            else
                userId = (int)conversation.conversationId;

            std::map<int, int>::iterator it = userIdToIndex.find(userId);
            if (it != userIdToIndex.end() || (updateAllOutgoing && conversation.outgoing))
            {
                TGConversation *newConversation = [conversation copy];
                [self initializeDialogListData:newConversation customUser:(it != userIdToIndex.end() ? [users objectAtIndex:it->second] : nil) selfUser:selfUser];
                [_conversationList replaceObjectAtIndex:index withObject:newConversation];
                [updatedIndices addObject:[NSNumber numberWithInt:index]];
                [updatedItems addObject:newConversation];
            }
        }
        
        if (updatedIndices.count != 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGDialogListController *controller = self.dialogListController;
                if (controller != nil)
                    [controller dialogListItemsChanged:nil insertedItems:nil updatedIndices:updatedIndices updatedItems:updatedItems removedIndices:nil];
            });
        }
    }
    else if ([path isEqualToString:@"/tg/conversation/*/typing"])
    {
        NSDictionary *dict = ((SGraphObjectNode *)resource).object;
        int64_t conversationId = [[dict objectForKey:@"conversationId"] longLongValue];
        if (conversationId != 0)
        {
            NSDictionary *userActivities = [dict objectForKey:@"typingUsers"];
            NSString *typingString = nil;
            NSArray *typingUsers = userActivities.allKeys;
            if (((conversationId < 0 && conversationId > INT_MIN) || TGPeerIdIsChannel(conversationId)) && typingUsers.count != 0)
            {
                NSMutableString *userNames = [[NSMutableString alloc] init];
                NSMutableArray *userNamesArray = [[NSMutableArray alloc] init];
                for (NSNumber *nUid in typingUsers)
                {
                    TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                    if (userNames.length != 0)
                        [userNames appendString:@", "];
                    [userNames appendString:user.displayFirstName == nil ? @"" : user.displayFirstName];
                    if (user.displayFirstName != nil)
                        [userNamesArray addObject:user.displayFirstName];
                }
                
                if (userNamesArray.count == 1)
                {
                    typingString = [[NSString alloc] initWithFormat:[self formatForGroupActivity:userActivities[typingUsers[0]]], userNames];
                }
                else if (userNamesArray.count != 0)
                {
                    NSString *format = [TGStringUtils integerValueFormat:@"ForwardedAuthorsOthers_" value:userNamesArray.count - 1];
                    typingString = [[NSString alloc] initWithFormat:TGLocalized(format), userNamesArray[0], [[NSString alloc] initWithFormat:@"%d", (int)userNamesArray.count - 1]];
                }
            }
            else if (typingUsers.count != 0)
            {
                NSMutableString *userNames = [[NSMutableString alloc] init];
                for (NSNumber *nUid in typingUsers)
                {
                    TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
                    if (userNames.length != 0)
                        [userNames appendString:@", "];
                    [userNames appendString:user.displayFirstName];
                }
                
                if (typingUsers.count == 1)
                {
                    typingString = [[NSString alloc] initWithFormat:[self formatForUserActivity:userActivities[typingUsers[0]]], userNames];
                }
                else
                    typingString = userNames;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGDialogListController *dialogListController = self.dialogListController;
                
                [dialogListController userTypingInConversationUpdated:conversationId typingString:typingString];
            });
        }
    }
    else if ([path isEqualToString:@"/tg/service/synchronizationstate"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    else if ([path isEqualToString:@"/tg/unreadCount"])
    {
        dispatch_async(dispatch_get_main_queue(), ^ // request to controller
        {
            [TGDatabaseInstance() dispatchOnDatabaseThread:^ // request to database
            {
                int unreadCount = [TGDatabaseInstance() databaseState].unreadCount;
                TGDispatchOnMainThread(^
                {
                    if (![arguments[@"previous"] boolValue]) {
                        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
                    }
                    if (unreadCount == 0)
                        [[UIApplication sharedApplication] cancelAllLocalNotifications];
                    
                    self.unreadCount = unreadCount;
                    [TGAppDelegateInstance.rootController.mainTabsController setUnreadCount:unreadCount];
                    
                    TGDialogListController *dialogListController = self.dialogListController;
                    dialogListController.tabBarItem.badgeValue = unreadCount == 0 ? nil : [[NSString alloc] initWithFormat:@"%d", unreadCount];
                });
            } synchronous:false];
        });
    }
    else if ([path hasPrefix:@"/tg/peerSettings/"])
    {
        NSDictionary *dict = ((SGraphObjectNode *)resource).object;
        
        NSMutableArray *updatedIndices = [[NSMutableArray alloc] init];
        NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
        
        int64_t peerId = [[path substringWithRange:NSMakeRange(18, path.length - 1 - 18)] longLongValue];
        
        int count = (int)_conversationList.count;
        for (int i = 0; i < count; i++)
        {
            TGConversation *conversation = [_conversationList objectAtIndex:i];
            int64_t mutePeerId = conversation.conversationId;
            if (conversation.isEncrypted)
            {
                if (conversation.chatParticipants.chatParticipantUids.count != 0)
                    mutePeerId = [conversation.chatParticipants.chatParticipantUids[0] intValue];
            }
            
            if (mutePeerId == peerId)
            {
                TGConversation *newConversation = [conversation copy];
                NSMutableDictionary *newData = [conversation.dialogListData mutableCopy];
                [newData setObject:[[NSNumber alloc] initWithBool:[dict[@"muteUntil"] intValue] != 0] forKey:@"mute"];
                newConversation.dialogListData = newData;
                
                [_conversationList replaceObjectAtIndex:i withObject:newConversation];
                
                [updatedIndices addObject:[[NSNumber alloc] initWithInt:i]];
                [updatedItems addObject:newConversation];
                
                break;
            }
        }
        
        if (updatedItems.count != 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGDialogListController *dialogListController = self.dialogListController;
                [dialogListController dialogListItemsChanged:nil insertedItems:nil updatedIndices:updatedIndices updatedItems:updatedItems removedIndices:nil];
            });
        }
    }
    else if ([path isEqualToString:@"/tg/contactlist"])
    {
        NSMutableArray *updatedIndices = [[NSMutableArray alloc] init];
        NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
        
        int index = -1;
        int count = (int)_conversationList.count;
        for (int i = 0; i < count; i++)
        {
            index++;
            
            TGConversation *conversation = [_conversationList objectAtIndex:i];
            
            if (!conversation.isChat)
            {
                TGUser *user = [TGDatabaseInstance() loadUser:(int)conversation.conversationId];
                if (user == nil)
                    continue;
                
                NSString *title = nil;
                
                if (user.uid == [TGTelegraphInstance serviceUserUid] || user.uid == [TGTelegraphInstance voipSupportUserUid])
                    title = [user displayName];
                else if (user.phoneNumber.length != 0 && ![TGDatabaseInstance() uidIsRemoteContact:user.uid])
                    title = user.formattedPhoneNumber;
                else
                    title = [user displayName];
                
                if (title != nil && ![title isEqualToString:[conversation.dialogListData objectForKey:@"title"]])
                {
                    TGConversation *newConversation = [conversation copy];
                    NSMutableDictionary *newData = [conversation.dialogListData mutableCopy];
                    [newData setObject:title forKey:@"title"];
                    newConversation.dialogListData = newData;
                    
                    [_conversationList replaceObjectAtIndex:i withObject:newConversation];
                    
                    [updatedIndices addObject:[[NSNumber alloc] initWithInt:index]];
                    [updatedItems addObject:newConversation];
                }
            }
        }
        
        if (updatedItems.count != 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGDialogListController *dialogListController = self.dialogListController;
                [dialogListController dialogListItemsChanged:nil insertedItems:nil updatedIndices:updatedIndices updatedItems:updatedItems removedIndices:nil];
            });
        }
    }
    else if ([path isEqualToString:@"/databasePasswordChanged"])
    {
        TGDispatchOnMainThread(^
        {
            TGDialogListController *controller = self.dialogListController;
            [controller updateDatabasePassword];
        });
    }
    else if ([path isEqualToString:@"/tg/channelListSyncrhonized"]) {
        [self actionStageResourceDispatched:@"/tg/conversations" resource:[[SGraphObjectNode alloc] initWithObject:resource] arguments:@{@"filterEarliest": @true}];
    }
}

- (NSString *)formatForGroupActivity:(NSString *)activity
{
    if ([activity isEqualToString:@"recordingAudio"])
        return TGLocalized(@"DialogList.SingleRecordingAudioSuffix");
    else if ([activity isEqualToString:@"recordingVideoMessage"])
        return TGLocalized(@"DialogList.SingleRecordingVideoMessageSuffix");
    else if ([activity isEqualToString:@"uploadingPhoto"])
        return TGLocalized(@"DialogList.SingleUploadingPhotoSuffix");
    else if ([activity isEqualToString:@"uploadingVideo"])
        return TGLocalized(@"DialogList.SingleUploadingVideoSuffix");
    else if ([activity isEqualToString:@"uploadingDocument"])
        return TGLocalized(@"DialogList.SingleUploadingFileSuffix");
    else if ([activity isEqualToString:@"playingGame"])
        return TGLocalized(@"DialogList.SinglePlayingGameSuffix");
    
    return TGLocalized(@"DialogList.SingleTypingSuffix");
}

- (NSString *)formatForUserActivity:(NSString *)activity
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
    else if ([activity isEqualToString:@"playingGame"])
        return TGLocalized(@"Activity.PlayingGame");
    
    return TGLocalized(@"DialogList.Typing");
}

@end
