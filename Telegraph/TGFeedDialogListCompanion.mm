#import "TGFeedDialogListCompanion.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGAppDelegate.h"
#import "TGModernConversationController.h"
#import "TGGenericModernConversationCompanion.h"

#import "TGDialogListController.h"

#import <LegacyComponents/SGraphObjectNode.h>
#import <LegacyComponents/SGraphListNode.h>

#import "TGFeed.h"
#import "TGDatabase.h"

#import "TGInterfaceManager.h"
#import "TGInterfaceAssets.h"

#import "TGTelegramNetworking.h"
#import "TGTelegraph.h"

#import "TGTelegraphConversationMessageAssetsSource.h"

#import "TGModernConversationCompanion.h"

#import <LegacyComponents/TGProgressWindow.h>

#include <map>
#include <set>

#import <libkern/OSAtomic.h>

#import "TGAlertView.h"

#import "TGChannelManagementSignals.h"

#import "TGLegacyComponentsContext.h"

#import "TGChatListSignals.h"

@interface TGFeedDialogListCompanion ()
{
    TGFeed *_feed;
    TGProgressWindow *_progressWindow;
    
    SMetaDisposable *_stateDisposable;
    SMetaDisposable *_channelsDisposable;
}

@property (nonatomic, strong) NSMutableArray *conversationList;

@end

@implementation TGFeedDialogListCompanion

- (id)initWithFeed:(TGFeed *)feed
{
    self = [super init];
    if (self != nil)
    {
        _feed = feed;
        _conversationList = [[NSMutableArray alloc] init];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        self.showListEditingControl = true;
        self.editingControlOnRightSide = true;
        self.feedChannels = true;
        
        [self resetWatchedNodePaths];
        
        _stateDisposable = [[SMetaDisposable alloc] init];
        _channelsDisposable = [[SMetaDisposable alloc] init];
        
        __weak TGFeedDialogListCompanion *weakSelf = self;
        [_channelsDisposable setDisposable:[[[[[TGChatListSignals chatListWithLimit:256] take:1] map:^id(NSArray<TGConversation *> *next)
        {
            NSMutableArray *filtered = [[NSMutableArray alloc] init];
            for (TGConversation *conversation in next)
            {
                if (conversation.isChannel && conversation.kind == TGConversationKindPersistentChannel && conversation.feedId.intValue == feed.fid)
                    [filtered addObject:conversation];
            }
            return filtered;
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next) {
            __strong TGFeedDialogListCompanion *strongSelf = weakSelf;
            if (strongSelf != nil) {
                SGraphListNode *node = [[SGraphListNode alloc] init];
                node.items = next;
                
                [strongSelf actorCompleted:ASStatusSuccess path:@"/tg/dialoglist/(0)" result:node];
            }
        }]];
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

- (void)resetWatchedNodePaths
{
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         [ActionStageInstance() removeWatcher:self];
         
         [ActionStageInstance() watchForPath:@"/tg/conversations" watcher:self];
         [ActionStageInstance() watchForGenericPath:@"/tg/conversationsGrouped/@" watcher:self];
         [ActionStageInstance() watchForPath:@"/tg/userdatachanges" watcher:self];
         
         [ActionStageInstance() watchForGenericPath:@"/tg/peerSettings/@" watcher:self];
     }];
}

- (void)clearData
{
    [ActionStageInstance() dispatchOnStageQueue:^
     {
         [_channelsDisposable setDisposable:nil];
         
         [_conversationList removeAllObjects];
         
         [self resetWatchedNodePaths];
         
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

- (void)conversationSelected:(TGConversation *)conversation
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
            [[TGInterfaceManager instance] navigateToConversationWithId:conversationId conversation:conversation performActions:nil atMessage:nil clearStack:false openKeyboard:false canOpenKeyboardWhileInTransition:true animated:true];
        }];
    } else {
        [[TGInterfaceManager instance] navigateToConversationWithId:conversationId conversation:conversation performActions:nil atMessage:nil clearStack:false openKeyboard:false canOpenKeyboardWhileInTransition:true animated:true];
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
    [self deleteItem:conversation animated:animated interfaceOnly:false];
}

- (void)deleteItem:(TGConversation *)conversation animated:(bool)animated interfaceOnly:(bool)interfaceOnly
{
    TGDispatchOnMainThread(^
    {
        if ([self isConversationOpened:conversation.conversationId]) {
            [TGAppDelegateInstance.rootController clearContentControllers];
        }
    });
    
    int64_t conversationId = conversation.conversationId;
    [TGTelegraphInstance.liveLocationManager stopWithPeerId:conversationId];
    
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
                
                if (!interfaceOnly)
                {
                    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/delete", conversationId] options:@{@"conversationId": @(conversationId), @"block": @true} watcher:self];
                }
                
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
        
        if (!found && !interfaceOnly)
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
    return;
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
             //_canLoadMore = false;
             
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 TGDialogListController *dialogListController = self.dialogListController;
                 
                 dialogListController.canLoadMore = false;
                 [dialogListController dialogListFullyReloaded:[NSArray array]];
             });
         }
     }];
}

- (void)initializeDialogListData:(TGConversation *)conversation customUser:(TGUser *)customUser selfUser:(TGUser *)selfUser
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    int64_t mutePeerId = conversation.conversationId;
    
    dict[@"authorIsSelf"] = @(conversation.fromUid == TGTelegraphInstance.clientUserId);
    
    if (conversation.isChannel) {
        dict[@"isChannel"] = @true;
        dict[@"isChannelGroup"] = @(conversation.isChannelGroup);
        
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

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    bool hideSelf = self.forwardMode;
    
    if ([path hasPrefix:@"/tg/dialoglist"])
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
                 int date1 = conversation1.unpinnedDate;
                 int date2 = conversation2.unpinnedDate;
                 
                 if (date1 > date2)
                     return NSOrderedAscending;
                 else if (date1 < date2)
                     return NSOrderedDescending;
                 else
                     return NSOrderedSame;
             }];
            
            for (int i = 0; i < (int)_conversationList.count; i++)
            {
                if (((TGConversation *)_conversationList[i]).conversationId == selfUser.uid && hideSelf)
                {
                    [_conversationList removeObjectAtIndex:i];
                    i--;
                }
            }
            
            NSArray *items = [NSArray arrayWithArray:_conversationList];
            
            //_canLoadMore = canLoadMore;
            
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
                if (self.dialogListController.debugReady != nil)
                    self.dialogListController.debugReady();
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    TGDialogListController *controller = self.dialogListController;
                    if (controller != nil)
                    {
                        controller.canLoadMore = canLoadMore;
                        if (self.dialogListController.debugReady != nil)
                            self.dialogListController.debugReady();
                        [controller dialogListFullyReloaded:items];
                    }
                });
            }
        }
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path hasPrefix:@"/tg/dialoglist"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    else if ([path hasPrefix:@"/tg/conversationsGrouped"])
    {
        NSMutableArray *conversations = ((SGraphObjectNode *)resource).object;
        bool animated = [path rangeOfString:@"(animated)"].location != NSNotFound;
        for (TGConversation *conversation in conversations)
        {
            [self deleteItem:conversation animated:animated interfaceOnly:true];
        }
    }
    else if ([path isEqualToString:@"/tg/conversations"] || [path isEqualToString:@"/tg/broadcastConversations"])
    {
        NSMutableArray *conversationIds = [[NSMutableArray alloc] init];
        for (TGConversation *conversation in _conversationList) {
            [conversationIds addObject:@(conversation.conversationId)];
        }
        
        TGUser *selfUser = [[TGDatabase instance] loadUser:TGTelegraphInstance.clientUserId];
        
        NSMutableArray *conversations = [((SGraphObjectNode *)resource).object mutableCopy];
        
        for (NSInteger i = 0; i < (NSInteger)conversations.count; i++) {
            TGConversation *conversation = conversations[i];
            
            bool isPersistentChannel = conversation.isChannel && conversation.kind == TGConversationKindPersistentChannel;
            bool isFeedChannel = conversation.feedId.intValue == _feed.fid;
                        
            if (!(isPersistentChannel && isFeedChannel)) {
                [conversations removeObjectAtIndex:i];
                i--;
            }
        }
        
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
             int date1 = (int)((TGConversation *)obj1).unpinnedDate;
             int date2 = (int)((TGConversation *)obj2).unpinnedDate;
             
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
            if (conversation.isDeleted || conversation.isDeactivated || conversation.feedId.intValue != _feed.fid)
            {
                [_conversationList removeObjectAtIndex:i];
                i--;
            }
        }
        
        for (TGConversation *conversation in conversations)
        {
            TGConversation *newConversation = [conversation copy];
            if (!newConversation.isDeleted && !newConversation.isDeactivated && newConversation.feedId.intValue == _feed.fid)
            {
                [self initializeDialogListData:newConversation customUser:nil selfUser:selfUser];
                
                [_conversationList addObject:newConversation];
            }
        }
        
        if (self.forwardMode)
        {
            TGConversation *conversation = [_conversationList firstObject];
            if (conversation.conversationId == selfUser.uid)
                [_conversationList removeObjectAtIndex:0];
        }
        
        [_conversationList sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             int date1 = (int)((TGConversation *)obj1).unpinnedDate;
             int date2 = (int)((TGConversation *)obj2).unpinnedDate;
             
             if (date1 < date2)
                 return NSOrderedDescending;
             else if (date1 > date2)
                 return NSOrderedAscending;
             else
                 return NSOrderedSame;
         }];
        
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
}

@end

