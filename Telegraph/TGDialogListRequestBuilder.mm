#import "TGDialogListRequestBuilder.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGTelegraph.h"

#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import <LegacyComponents/ActionStage.h>
#import <LegacyComponents/SGraphListNode.h>

#import "TGUserDataRequestBuilder.h"

#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TLPeerNotifySettings$peerNotifySettings.h"

#include <set>

#import "TGDownloadMessagesSignal.h"

#import "TLUser$modernUser.h"

#import "TGFeedPosition.h"

@interface TGDialogListRequestBuilder ()
{
    std::set<int64_t> _ignoreConversationIds;
    NSArray *_cutoffConversations;
}

@property (nonatomic) bool replaceList;

@end

@implementation TGDialogListRequestBuilder

+ (NSString *)genericPath
{
    return @"/tg/dialoglist/@";
}

- (void)prepare:(NSDictionary *)options
{
    if (![[options objectForKey:@"inline"] boolValue] && [options objectForKey:@"date"] == nil)
    {
        self.requestQueueName = @"messages";
    }
}

- (void)execute:(NSDictionary *)__unused options
{
    NSNumber *date = [options objectForKey:@"date"];
    NSNumber *limit = [options objectForKey:@"limit"];
    
    if (date == nil)
    {
        _replaceList = true;
    
        int limit = 400;
//#ifdef DEBUG
//        limit = 5;
//#endif
        
        self.cancelToken = [TGTelegraphInstance doRequestDialogsListWithOffset:0 limit:limit requestBuilder:self];
    }
    else
    {        
        [TGDatabaseInstance() loadConversationListFromDate:[date intValue] limit:[limit intValue] excludeConversationIds:options[@"excludeConversationIds"] completion:^(NSArray *result, bool loadedAllRegular)
        {
            bool dialogListLoaded = [TGDatabaseInstance() customProperty:@"dialogListLoaded"].length != 0;
            
            NSMutableArray *filteredResult = [[NSMutableArray alloc] initWithArray:result];
            [filteredResult sortUsingComparator:^NSComparisonResult(TGConversation *lhs, TGConversation *rhs) {
                if (lhs.date > rhs.date) {
                    return NSOrderedAscending;
                } else if (lhs.date < rhs.date) {
                    return NSOrderedDescending;
                } else {
                    if (lhs.conversationId < rhs.conversationId) {
                        return NSOrderedDescending;
                    } else {
                        return NSOrderedAscending;
                    }
                }
            }];
            
            if (!dialogListLoaded || !loadedAllRegular) {
                NSMutableArray *cutoffConversations = [[NSMutableArray alloc] init];
                while (filteredResult.count != 0 && (((TGConversation *)[filteredResult lastObject]).isChannel || ((TGConversation *)[filteredResult lastObject]).isBroadcast)) {
                    [cutoffConversations addObject:[filteredResult lastObject]];
                    [filteredResult removeLastObject];
                }
                _cutoffConversations = cutoffConversations;
            }
            
            if (filteredResult.count != 0 || dialogListLoaded) {
                [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphListNode alloc] initWithItems:filteredResult]];
            } else {
                NSData *data = [TGDatabaseInstance() customProperty:@"dialogListRemoteOffset"];
                TGDialogListRemoteOffset *remoteOffset = nil;
                if (data.length != 0) {
                    remoteOffset = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                }
                
                if (remoteOffset == nil) {
                    remoteOffset = [[TGDialogListRemoteOffset alloc] initWithDate:[TGDatabaseInstance() loadConversationListRemoteOffsetDate] peerId:0 accessHash:0 messageId:0];
                }
                
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    for (NSNumber *nConversationId in options[@"excludeConversationIds"])
                    {
                        _ignoreConversationIds.insert([nConversationId longLongValue]);
                    }
                    
                    TGLog(@"Requesting dialog list with offset = %@", remoteOffset);
                    self.cancelToken = [TGTelegraphInstance doRequestDialogsListWithOffset:remoteOffset limit:80 requestBuilder:self];
                }];
            }
        }];
    }
}

- (void)dialogListRequestSuccess:(TLmessages_Dialogs *)dialogs
{
    [TGUserDataRequestBuilder executeUserDataUpdate:dialogs.users];
    
    NSMutableDictionary *chatItems = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *channelItems = [[NSMutableDictionary alloc] init];
    
    for (TLChat *chatDesc in dialogs.chats)
    {
        TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
        if (conversation.conversationId != 0) {
            if (conversation.isChannel) {
                channelItems[@(conversation.conversationId)] = conversation;
            } else {
                [chatItems setObject:conversation forKey:[NSNumber numberWithInt:(int)conversation.conversationId]];
            }
        }
    }
    
    NSMutableArray *parsedMessages = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *messagesDict = [[NSMutableDictionary alloc] init];
    for (TLMessage *messageDesc in dialogs.messages)
    {
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
        if (message.mid != 0)
            [parsedMessages addObject:message];
    }
    
    [[[TGDialogListRequestBuilder signalForCompleteMessages:parsedMessages channels:channelItems] catch:^SSignal *(__unused id error)
    {
        return [SSignal single:parsedMessages];
    }] startWithNext:^(NSArray *completeMessages)
    {
        NSMutableDictionary *multipleMessagesByConversation = [[NSMutableDictionary alloc] init];
        NSMutableDictionary<NSNumber *, TGDatabaseMessageDraft *> *updatePeerDrafts = [[NSMutableDictionary alloc] init];
        NSMutableDictionary<NSNumber *, TGUnseenPeerMentionsState *> *resetPeerUnseenMentionsStates = [[NSMutableDictionary alloc] init];
        
        for (TGMessage *message in completeMessages)
        {
            if (!TGPeerIdIsChannel(message.cid)) {
                [messagesDict setObject:message forKey:[NSNumber numberWithInt:message.mid]];
            } else {
                NSMutableArray *array = multipleMessagesByConversation[@(message.cid)];
                if (array == nil) {
                    array = [[NSMutableArray alloc] init];
                    multipleMessagesByConversation[@(message.cid)] = array;
                }
                [array addObject:message];
            }
        }
        
        NSMutableArray *conversations = [[NSMutableArray alloc] init];
        NSMutableArray *channels = [[NSMutableArray alloc] init];
        NSMutableArray *feeds = [[NSMutableArray alloc] init];
        
        NSMutableArray *pinnedPeerIds = [[NSMutableArray alloc] init];
        
        int32_t unreadChatsCount = 0;
        int32_t unreadChannelsCount = 0;
        
        for (TLDialog *baseDialog in dialogs.dialogs)
        {
            if ([baseDialog isKindOfClass:[TLDialog$dialogMeta class]])
            {
                TLDialog$dialogMeta *dialog = (TLDialog$dialogMeta *)baseDialog;
                int64_t peerId = 0;
                if ([dialog.peer isKindOfClass:[TLPeer$peerUser class]])
                {
                    if (_ignoreConversationIds.find(((TLPeer$peerUser *)dialog.peer).user_id) == _ignoreConversationIds.end())
                    {
                        TGConversation *conversation = [[TGConversation alloc] initWithConversationId:((TLPeer$peerUser *)dialog.peer).user_id unreadCount:dialog.unread_count serviceUnreadCount:0];
                        peerId = conversation.conversationId;
                        
                        conversation.unreadMark = dialog.flags & (1 << 3);
                        conversation.maxReadMessageId = dialog.read_inbox_max_id;
                        conversation.maxOutgoingReadMessageId = dialog.read_outbox_max_id;
                        conversation.maxKnownMessageId = dialog.top_message;
                        
                        TGMessage *message = [messagesDict objectForKey:[NSNumber numberWithInt:dialog.top_message]];
                        if (message != nil)
                            [conversation mergeMessage:message];
                        
                        if (conversation.conversationId != 0)
                        {
                            //TGLog(@"Dialog with %@", [TGDatabaseInstance() loadUser:conversation.conversationId].displayName);
                            
                            [conversations addObject:conversation];
                            
                            if (message != nil) {
                                NSMutableArray *array = multipleMessagesByConversation[@(conversation.conversationId)];
                                if (array == nil) {
                                    array = [[NSMutableArray alloc] init];
                                    multipleMessagesByConversation[@(conversation.conversationId)] = array;
                                }
                                [array addObject:message];
                            }
                        }
                        
                        if ([dialog.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                        {
                            TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)dialog.notify_settings;
                            
                            NSNumber *peerSoundId = nil;
                            NSNumber *peerMuteUntil = nil;
                            NSNumber *peerPreviewText = nil;
                            NSNumber *messagesMuted = nil;
                            
                            if (concreteSettings.flags & (1 << 0)) {
                                peerPreviewText = @(concreteSettings.showPreviews);
                            }
                            if (concreteSettings.flags & (1 << 1)) {
                                messagesMuted = @(concreteSettings.silent);
                            }
                            if (concreteSettings.flags & (1 << 2)) {
                                if (concreteSettings.mute_until > [[TGTelegramNetworking instance] approximateRemoteTime])
                                    peerMuteUntil = @(concreteSettings.mute_until);
                                else
                                    peerMuteUntil = @0;
                            }
                            if (concreteSettings.flags & (1 << 3)) {
                                if (concreteSettings.sound.length == 0)
                                    peerSoundId = @(0);
                                else if ([concreteSettings.sound isEqualToString:@"default"])
                                    peerSoundId = @(1);
                                else
                                    peerSoundId = @([concreteSettings.sound intValue]);
                            }
                            
                            [TGDatabaseInstance() storePeerNotificationSettings:conversation.conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:nil];
                        }
                        
                        if (conversation.unreadMark || conversation.unreadCount > 0)
                            unreadChatsCount++;
                    }
                }
                else if ([dialog.peer isKindOfClass:[TLPeer$peerChat class]])
                {
                    if (_ignoreConversationIds.find(-((TLPeer$peerChat *)dialog.peer).chat_id) == _ignoreConversationIds.end())
                    {
                        TGConversation *conversation = [chatItems objectForKey:[[NSNumber alloc] initWithLongLong:-((TLPeer$peerChat *)dialog.peer).chat_id]];
                        peerId = conversation.conversationId;
                        conversation.unreadMark = dialog.flags & (1 << 3);
                        conversation.unreadCount = dialog.unread_count;
                        conversation.maxReadMessageId = dialog.read_inbox_max_id;
                        conversation.maxOutgoingReadMessageId = dialog.read_outbox_max_id;
                        conversation.maxKnownMessageId = dialog.top_message;
                        
                        TGMessage *message = [messagesDict objectForKey:[NSNumber numberWithInt:dialog.top_message]];
                        if (message != nil)
                            [conversation mergeMessage:message];
                        
                        if (conversation.conversationId != 0)
                        {
                            //TGLog(@"Chat %@", conversation.chatTitle);
                            
                            [conversations addObject:conversation];
                            
                            if (message != nil) {
                                NSMutableArray *array = multipleMessagesByConversation[@(conversation.conversationId)];
                                if (array == nil) {
                                    array = [[NSMutableArray alloc] init];
                                    multipleMessagesByConversation[@(conversation.conversationId)] = array;
                                }
                                [array addObject:message];
                            }
                        }
                        
                        if ([dialog.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                        {
                            TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)dialog.notify_settings;
                            
                            NSNumber *peerSoundId = nil;
                            NSNumber *peerMuteUntil = nil;
                            NSNumber *peerPreviewText = nil;
                            NSNumber *messagesMuted = nil;
                            
                            if (concreteSettings.flags & (1 << 0)) {
                                peerPreviewText = @(concreteSettings.showPreviews);
                            }
                            if (concreteSettings.flags & (1 << 1)) {
                                messagesMuted = @(concreteSettings.silent);
                            }
                            if (concreteSettings.flags & (1 << 2)) {
                                if (concreteSettings.mute_until > [[TGTelegramNetworking instance] approximateRemoteTime])
                                    peerMuteUntil = @(concreteSettings.mute_until);
                                else
                                    peerMuteUntil = @0;
                            }
                            if (concreteSettings.flags & (1 << 3)) {
                                if (concreteSettings.sound.length == 0)
                                    peerSoundId = @(0);
                                else if ([concreteSettings.sound isEqualToString:@"default"])
                                    peerSoundId = @(1);
                                else
                                    peerSoundId = @([concreteSettings.sound intValue]);
                            }
                            
                            [TGDatabaseInstance() storePeerNotificationSettings:conversation.conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:nil];
                        }
                        
                        if (conversation.unreadMark || conversation.unreadCount > 0)
                            unreadChatsCount++;
                    }
                }
                else if ([dialog.peer isKindOfClass:[TLPeer$peerChannel class]]) {
                    TGConversation *conversation = channelItems[@(TGPeerIdFromChannelId(((TLPeer$peerChannel *)dialog.peer).channel_id))];
                    if (conversation != nil) {
                        peerId = conversation.conversationId;
                        conversation.unreadMark = dialog.flags & (1 << 3);
                        conversation.unreadCount = dialog.unread_count;
                        conversation.maxReadMessageId = dialog.read_inbox_max_id;
                        conversation.maxOutgoingReadMessageId = dialog.read_outbox_max_id;
                        conversation.maxKnownMessageId = dialog.top_message;
                        
                        [channels addObject:conversation];
                        
                        if ([dialog.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                        {
                            TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)dialog.notify_settings;
                            
                            NSNumber *peerSoundId = nil;
                            NSNumber *peerMuteUntil = nil;
                            NSNumber *peerPreviewText = nil;
                            NSNumber *messagesMuted = nil;
                            
                            if (concreteSettings.flags & (1 << 0)) {
                                peerPreviewText = @(concreteSettings.showPreviews);
                            }
                            if (concreteSettings.flags & (1 << 1)) {
                                messagesMuted = @(concreteSettings.silent);
                            }
                            if (concreteSettings.flags & (1 << 2)) {
                                if (concreteSettings.mute_until > [[TGTelegramNetworking instance] approximateRemoteTime])
                                    peerMuteUntil = @(concreteSettings.mute_until);
                                else
                                    peerMuteUntil = @0;
                            }
                            if (concreteSettings.flags & (1 << 3)) {
                                if (concreteSettings.sound.length == 0)
                                    peerSoundId = @(0);
                                else if ([concreteSettings.sound isEqualToString:@"default"])
                                    peerSoundId = @(1);
                                else
                                    peerSoundId = @([concreteSettings.sound intValue]);
                            }
                            
                            [TGDatabaseInstance() storePeerNotificationSettings:conversation.conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:nil];
                        }
                        
                        if (conversation.unreadMark || conversation.unreadCount > 0)
                            unreadChannelsCount++;
                    }
                }
                
                if (peerId != 0) {
                    TGDatabaseMessageDraft *draft = nil;
                    if ([dialog.draft isKindOfClass:[TLDraftMessage$draftMessageMeta class]]) {
                        TLDraftMessage$draftMessageMeta *concreteDraft = (TLDraftMessage$draftMessageMeta *)dialog.draft;
                        draft = [[TGDatabaseMessageDraft alloc] initWithText:concreteDraft.message entities:[TGMessage parseTelegraphEntities:concreteDraft.entities] disableLinkPreview:concreteDraft.flags & (1 << 1) replyToMessageId:concreteDraft.reply_to_msg_id date:concreteDraft.date];
                    }
                    
                    if (draft != nil) {
                        updatePeerDrafts[@(peerId)] = draft == nil ? (id)[NSNull null] : draft;
                    }
                    
                    if (dialog.flags & (1 << 2)) {
                        [pinnedPeerIds addObject:@(peerId)];
                    }
                    
                    if (dialog.unread_mentions_count != 0) {
                        resetPeerUnseenMentionsStates[@(peerId)] = [[TGUnseenPeerMentionsState alloc] initWithVersion:0 count:dialog.unread_mentions_count maxIdWithPrecalculatedCount:dialog.top_message];
                    }
                }
            } else if ([baseDialog isKindOfClass:[TLDialog$dialogFeedMeta class]]) {
                TLDialog$dialogFeedMeta *dialog = (TLDialog$dialogFeedMeta *)baseDialog;
                
                //NSMutableSet *channelIds = [[NSMutableSet alloc] init];
                NSMutableArray *chatIds = [[NSMutableArray alloc] init];
                NSMutableArray *chatTitles = [[NSMutableArray alloc] init];
                NSMutableArray *chatPhotosSmall = [[NSMutableArray alloc] init];
                for (NSNumber *channelId in dialog.feed_other_channels)
                {
                    //[channelIds addObject:@(TGPeerIdFromChannelId(channelId.int32Value))];
                    
                    TGConversation *conversation = channelItems[@(TGPeerIdFromChannelId([channelId int32Value]))];
                    [chatIds addObject:@(conversation.conversationId)];
                    [chatTitles addObject:conversation.chatTitle ?: @""];
                    [chatPhotosSmall addObject:conversation.chatPhotoSmall ?: @""];
                }
                
                TGFeed *feed = [[TGFeed alloc] init];
                feed.fid = dialog.feed_id;
                //feed.channelIds = channelIds;
                feed.chatIds = chatIds;
                feed.chatTitles = chatTitles;
                feed.chatPhotosSmall = chatPhotosSmall;
                feed.maxReadPosition = [[TGFeedPosition alloc] initWithTelegraphDesc:dialog.read_max_position];
                feed.unreadCount = dialog.unread_count + dialog.unread_muted_count;
                
                TGMessage *message = [messagesDict objectForKey:[NSNumber numberWithInt:dialog.top_message]];
                if (message != nil)
                {
                    feed.messageDate = (int32_t)message.date;
                    feed.text = message.text;
                    feed.media = message.mediaAttachments;
                }
                
                [feeds addObject:feed];
            }
        }
        
        [TGDatabaseInstance() storeConversationList:conversations replace:_replaceList];
        [TGDatabaseInstance() storeSynchronizedChannels:channels];
        [TGDatabaseInstance() updateFeeds:feeds replace:false];
        
        TGDialogListRemoteOffset *remoteOffset = nil;
        
        for (TLDialog *baseDialog in dialogs.dialogs) {
            if ([baseDialog isKindOfClass:[TLDialog$dialogMeta class]]) {
                TLDialog$dialogMeta *dialog = (TLDialog$dialogMeta *)baseDialog;
                int64_t peerId = 0;
                int64_t accessHash = 0;
                TGMessage *message = nil;
                if ([dialog.peer isKindOfClass:[TLPeer$peerChat class]]) {
                    peerId = TGPeerIdFromGroupId(((TLPeer$peerChat *)dialog.peer).chat_id);
                    message = [messagesDict objectForKey:[NSNumber numberWithInt:dialog.top_message]];
                } else if ([dialog.peer isKindOfClass:[TLPeer$peerUser class]]) {
                    peerId = ((TLPeer$peerUser *)dialog.peer).user_id;
                    message = [messagesDict objectForKey:[NSNumber numberWithInt:dialog.top_message]];
                    for (TLUser *user in dialogs.users) {
                        if ([user isKindOfClass:[TLUser$modernUser class]] && ((TLUser$modernUser *)user).n_id == peerId) {
                            accessHash = ((TLUser$modernUser *)user).access_hash;
                            break;
                        }
                    }
                } else if ([dialog.peer isKindOfClass:[TLPeer$peerChannel class]]) {
                    peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)dialog.peer).channel_id);
                    for (TGConversation *conversation in channels) {
                        if (conversation.conversationId == peerId) {
                            accessHash = conversation.accessHash;
                            conversation.pts = dialog.pts;
                            break;
                        }
                    }
                    NSArray *messages = multipleMessagesByConversation[@(peerId)];
                    if (messages != nil) {
                        NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(TGMessage *lhs, TGMessage *rhs) {
                            int result = TGMessageTransparentSortKeyCompare(lhs.transparentSortKey, rhs.transparentSortKey);
                            if (result > 0) {
                                return NSOrderedAscending;
                            } else if (result < 0) {
                                return NSOrderedDescending;
                            } else {
                                return NSOrderedSame;
                            }
                        }];
                        
                        message = sortedMessages.lastObject;
                    }
                }
                
                if (message != nil && (dialog.flags & (1 << 2)) == 0) {
                    TGDialogListRemoteOffset *currentOffset = [[TGDialogListRemoteOffset alloc] initWithDate:(int32_t)message.date peerId:peerId accessHash:accessHash messageId:message.mid];
                    if (remoteOffset == nil || [currentOffset compare:remoteOffset] == NSOrderedAscending) {
                        remoteOffset = currentOffset;
                    }
                } else {
                    TGLog(@"remoteOffset: message not found");
                }
            } else if ([baseDialog isKindOfClass:[TLDialog$dialogFeedMeta class]]) {
                TLDialog$dialogFeedMeta *dialog = (TLDialog$dialogFeedMeta *)baseDialog;
                int64_t conversationId = TGPeerIdFromAdminLogId(dialog.feed_id);
                TGMessage *message = [messagesDict objectForKey:[NSNumber numberWithInt:dialog.top_message]];
                
                if (message != nil) {
                    NSMutableArray *array = multipleMessagesByConversation[@(conversationId)];
                    if (array == nil) {
                        array = [[NSMutableArray alloc] init];
                        multipleMessagesByConversation[@(conversationId)] = array;
                    }
                    [array addObject:message];
                }
            }
        }
        
        if (remoteOffset != nil) {
            TGLog(@"storing offset %@", remoteOffset);
            [TGDatabaseInstance() setCustomProperty:@"dialogListRemoteOffset" value:[NSKeyedArchiver archivedDataWithRootObject:remoteOffset]];
        }
        
        [multipleMessagesByConversation enumerateKeysAndObjectsUsingBlock:^(NSNumber *nConversationId, NSArray *messages, __unused  BOOL *stop)
        {
            if (TGPeerIdIsAdminLog([nConversationId longLongValue])) {
                NSMutableArray *addedHoles = [[NSMutableArray alloc] init];
                
                NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(TGMessage *lhs, TGMessage *rhs) {
                    int result = TGMessageTransparentSortKeyCompare(lhs.transparentSortKey, rhs.transparentSortKey);
                    if (result > 0) {
                        return NSOrderedAscending;
                    } else if (result < 0) {
                        return NSOrderedDescending;
                    } else {
                        return NSOrderedSame;
                    }
                }];
                
                for (NSUInteger i = 0; i < sortedMessages.count; i++) {
                    TGMessage *message = sortedMessages[i];
                    TGMessage *earlierMessage = i == sortedMessages.count - 1 ? nil : sortedMessages[i + 1];
                    if (earlierMessage == nil) {
                        [addedHoles addObject:[[TGMessageHole alloc] initWithMinId:1 minTimestamp:1 minPeerId:0 maxId:message.mid maxTimestamp:(int32_t)message.date maxPeerId:message.fromUid]];
                    } else {
                        [addedHoles addObject:[[TGMessageHole alloc] initWithMinId:earlierMessage.mid minTimestamp:(int32_t)earlierMessage.date maxId:message.mid maxTimestamp:(int32_t)message.date]];
                    }
                }
                
                [TGDatabaseInstance() addMessagesToFeed:TGAdminLogIdFromPeerId([nConversationId longLongValue]) messages:messages deleteMessages:nil addedHoles:addedHoles removedHoles:nil keepUnreadCounters:true changedMessages:nil];
            }
            else if (TGPeerIdIsChannel([nConversationId longLongValue])) {
                NSMutableArray *addedHoles = [[NSMutableArray alloc] init];
                
                NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(TGMessage *lhs, TGMessage *rhs) {
                    int result = TGMessageTransparentSortKeyCompare(lhs.transparentSortKey, rhs.transparentSortKey);
                    if (result > 0) {
                        return NSOrderedAscending;
                    } else if (result < 0) {
                        return NSOrderedDescending;
                    } else {
                        return NSOrderedSame;
                    }
                }];
                
                for (NSUInteger i = 0; i < sortedMessages.count; i++) {
                    TGMessage *message = sortedMessages[i];
                    TGMessage *earlierMessage = i == sortedMessages.count - 1 ? nil : sortedMessages[i + 1];
                    if (earlierMessage == nil) {
                        if (message.mid != 1) {
                            [addedHoles addObject:[[TGMessageHole alloc] initWithMinId:1 minTimestamp:1 maxId:message.mid - 1 maxTimestamp:(int32_t)message.date]];
                        }
                    } else if (earlierMessage.mid != message.mid - 1) {
                        [addedHoles addObject:[[TGMessageHole alloc] initWithMinId:earlierMessage.mid + 1 minTimestamp:(int32_t)earlierMessage.date + 1 maxId:message.mid - 1 maxTimestamp:(int32_t)message.date]];
                    }
                }
                
                [TGDatabaseInstance() addMessagesToChannel:[nConversationId longLongValue] messages:messages deleteMessages:nil unimportantGroups:nil addedHoles:addedHoles removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:true skipFeedUpdate:true changedMessages:nil];
            } else {
                [TGDatabaseInstance() transactionAddMessages:messages updateConversationDatas:nil notifyAdded:false];
                if (messages.count != 0) {
                    TGMessage *message = messages.firstObject;
                    [TGDatabaseInstance() fillConversationHistoryHole:[nConversationId longLongValue] indexSet:[NSIndexSet indexSetWithIndex:message.mid]];
                }
            }
        }];
        
        if (_replaceList)
        {
            [TGDatabaseInstance() setUnreadChatsCount:unreadChatsCount notify:false];
            [TGDatabaseInstance() setUnreadChannelsCount:unreadChannelsCount notify:true];
        }
        else
        {
            int previousUnreadChatsCount = [TGDatabaseInstance() unreadChatsCount];
            int previousUnreadChannelsCount = [TGDatabaseInstance() unreadChannelsCount];
            
            [TGDatabaseInstance() setUnreadChatsCount:previousUnreadChatsCount + unreadChatsCount notify:false];
            [TGDatabaseInstance() setUnreadChannelsCount:previousUnreadChannelsCount + unreadChannelsCount notify:true];
        }
        
        [TGDatabaseInstance() transactionAddMessages:nil notifyAddedMessages:false removeMessages:nil updateMessages:nil updatePeerDrafts:updatePeerDrafts removeMessagesInteractive:nil keepDates:false removeMessagesInteractiveForEveryone:false updateConversationDatas:nil applyMaxIncomingReadIds:nil applyMaxOutgoingReadIds:nil applyMaxOutgoingReadDates:nil applyUnreadMarks:nil readHistoryForPeerIds:nil resetPeerReadStates:nil resetPeerUnseenMentionsStates:resetPeerUnseenMentionsStates clearConversationsWithPeerIds:nil clearConversationsInteractive:false removeConversationsWithPeerIds:nil updatePinnedConversations:_replaceList ? pinnedPeerIds : nil synchronizePinnedConversations:false forceReplacePinnedConversations:false readMessageContentsInteractive:nil deleteEarlierHistory:nil updateFeededChannels:nil newlyJoinedFeedId:nil synchronizeFeededChannels:false calculateUnreadChats:false];
        
        [ActionStageInstance() dispatchResource:@"/dialogListReloaded" resource:@true];
        
        if (dialogs.dialogs.count == 0)
        {
            uint8_t loaded = 1;
            [TGDatabaseInstance() setCustomProperty:@"dialogListLoaded" value:[[NSData alloc] initWithBytes:&loaded length:1]];
        }
        
        SGraphListNode *dialogListNode = [[SGraphListNode alloc] initWithItems:[conversations arrayByAddingObjectsFromArray:channels]];
        [ActionStageInstance() nodeRetrieved:self.path node:dialogListNode];
    }];
}

- (void)dialogListRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

+ (SSignal *)signalForCompleteMessages:(NSArray *)completeMessages channels:(NSDictionary *)channels
{
    NSMutableArray *downloadMessages = [[NSMutableArray alloc] init];
    
    for (TGMessage *message in completeMessages)
    {
        for (id attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
            {
                if (((TGReplyMessageMediaAttachment *)attachment).replyMessage == nil) {
                    if (TGPeerIdIsChannel(message.cid)) {
                        TGConversation *conversation = channels[@(message.cid)];
                        if (conversation != nil) {
                            [downloadMessages addObject:[[TGDownloadMessage alloc] initWithPeerId:message.cid accessHash:conversation.accessHash messageId:((TGReplyMessageMediaAttachment *)attachment).replyMessageId]];
                        }
                    } else {
                        [downloadMessages addObject:[[TGDownloadMessage alloc] initWithPeerId:0 accessHash:0 messageId:((TGReplyMessageMediaAttachment *)attachment).replyMessageId]];
                    }
                }
            }
        }
    }
    
    if (downloadMessages.count == 0)
        return [SSignal single:completeMessages];
    else
    {
        return [[TGDownloadMessagesSignal downloadMessages:downloadMessages] map:^id(NSArray *messages)
        {
            NSMutableDictionary *peerIdMessageIdToMessage = [[NSMutableDictionary alloc] init];
            for (TGMessage *message in messages)
            {
                peerIdMessageIdToMessage[[[NSString alloc] initWithFormat:@"%lld:%d", message.cid, message.mid]] = message;
            }
            
            for (TGMessage *message in completeMessages)
            {
                for (id attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
                    {
                        TGMessage *requiredMessage = peerIdMessageIdToMessage[[[NSString alloc] initWithFormat:@"%lld:%d", message.cid, ((TGReplyMessageMediaAttachment *)attachment).replyMessageId]];
                        if (requiredMessage != nil)
                            ((TGReplyMessageMediaAttachment *)attachment).replyMessage = requiredMessage;
                        
                        break;
                    }
                }
            }
            
            return completeMessages;
        }];
    }
}


@end
