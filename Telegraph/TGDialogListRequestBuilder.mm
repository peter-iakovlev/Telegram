#import "TGDialogListRequestBuilder.h"

#import "ASCommon.h"

#import "TGTelegraph.h"

#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "ActionStage.h"
#import "SGraphListNode.h"

#import "TGUserDataRequestBuilder.h"

#import "TGDatabase.h"

#import "TGTelegramNetworking.h"

#include <set>

#import "TGDownloadMessagesSignal.h"
#import "TGPeerIdAdapter.h"

#import "TLUser$modernUser.h"

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
    
        int limit = 200;
#ifdef DEBUG
        limit = 5;
#endif
        
        self.cancelToken = [TGTelegraphInstance doRequestDialogsListWithOffset:0 limit:limit requestBuilder:self];
    }
    else
    {
        [[TGDatabase instance] loadConversationListFromDate:[date intValue] limit:[limit intValue] excludeConversationIds:options[@"excludeConversationIds"] completion:^(NSArray *result, bool loadedAllRegular)
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
        
        NSMutableArray *pinnedPeerIds = [[NSMutableArray alloc] init];
        
        for (TLDialog *dialog in dialogs.dialogs)
        {
            int64_t peerId = 0;
            if ([dialog.peer isKindOfClass:[TLPeer$peerUser class]])
            {
                if (_ignoreConversationIds.find(((TLPeer$peerUser *)dialog.peer).user_id) == _ignoreConversationIds.end())
                {
                    TGConversation *conversation = [[TGConversation alloc] initWithConversationId:((TLPeer$peerUser *)dialog.peer).user_id unreadCount:dialog.unread_count serviceUnreadCount:0];
                    peerId = conversation.conversationId;
                    
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
                        
                        int peerSoundId = 0;
                        int peerMuteUntil = 0;
                        bool peerPreviewText = true;
                        bool messagesMuted = false;
                        
                        peerMuteUntil = concreteSettings.mute_until;
                        if (peerMuteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
                            peerMuteUntil = 0;
                        
                        if (concreteSettings.sound.length == 0)
                            peerSoundId = 0;
                        else if ([concreteSettings.sound isEqualToString:@"default"])
                            peerSoundId = 1;
                        else
                            peerSoundId = [concreteSettings.sound intValue];
                        
                        peerPreviewText = concreteSettings.flags & (1 << 0);
                        messagesMuted = concreteSettings.flags & (1 << 1);
                        
                        [TGDatabaseInstance() storePeerNotificationSettings:conversation.conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:nil];
                    }
                }
            }
            else if ([dialog.peer isKindOfClass:[TLPeer$peerChat class]])
            {
                if (_ignoreConversationIds.find(-((TLPeer$peerChat *)dialog.peer).chat_id) == _ignoreConversationIds.end())
                {
                    TGConversation *conversation = [chatItems objectForKey:[[NSNumber alloc] initWithLongLong:-((TLPeer$peerChat *)dialog.peer).chat_id]];
                    peerId = conversation.conversationId;
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
                        
                        int peerSoundId = 0;
                        int peerMuteUntil = 0;
                        bool peerPreviewText = true;
                        bool messagesMuted = false;
                        
                        peerMuteUntil = concreteSettings.mute_until;
                        
                        if (concreteSettings.sound.length == 0)
                            peerSoundId = 0;
                        else if ([concreteSettings.sound isEqualToString:@"default"])
                            peerSoundId = 1;
                        else
                            peerSoundId = [concreteSettings.sound intValue];
                        
                        peerPreviewText = concreteSettings.flags & (1 << 0);
                        messagesMuted = concreteSettings.flags & (1 << 1);
                        
                        [TGDatabaseInstance() storePeerNotificationSettings:conversation.conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:nil];
                    }
                }
            }
            else if ([dialog.peer isKindOfClass:[TLPeer$peerChannel class]]) {
                TGConversation *conversation = channelItems[@(TGPeerIdFromChannelId(((TLPeer$peerChannel *)dialog.peer).channel_id))];
                if (conversation != nil) {
                    peerId = conversation.conversationId;
                    conversation.unreadCount = dialog.unread_count;
                    conversation.maxReadMessageId = dialog.read_inbox_max_id;
                    conversation.maxOutgoingReadMessageId = dialog.read_outbox_max_id;
                    conversation.maxKnownMessageId = dialog.top_message;
                    
                    [channels addObject:conversation];
                    
                    if ([dialog.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                    {
                        TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)dialog.notify_settings;
                        
                        int peerSoundId = 0;
                        int peerMuteUntil = 0;
                        bool peerPreviewText = true;
                        bool messagesMuted = false;
                        
                        peerMuteUntil = concreteSettings.mute_until;
                        
                        if (concreteSettings.sound.length == 0)
                            peerSoundId = 0;
                        else if ([concreteSettings.sound isEqualToString:@"default"])
                            peerSoundId = 1;
                        else
                            peerSoundId = [concreteSettings.sound intValue];
                        
                        peerPreviewText = concreteSettings.flags & (1 << 0);
                        messagesMuted = concreteSettings.flags & (1 << 1);
                        
                        [TGDatabaseInstance() storePeerNotificationSettings:conversation.conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:nil];
                    }
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
            }
        }
        
        [[TGDatabase instance] storeConversationList:conversations replace:_replaceList];
        [TGDatabaseInstance() storeSynchronizedChannels:channels];
        
        TGDialogListRemoteOffset *remoteOffset = nil;
        
        for (TLDialog *dialog in dialogs.dialogs) {
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
            
            if (message != nil) {
                TGDialogListRemoteOffset *currentOffset = [[TGDialogListRemoteOffset alloc] initWithDate:(int32_t)message.date peerId:peerId accessHash:accessHash messageId:message.mid];
                if (remoteOffset == nil || [currentOffset compare:remoteOffset] == NSOrderedAscending) {
                    remoteOffset = currentOffset;
                }
            } else {
                TGLog(@"remoteOffset: message not found");
            }
        }
        
        if (remoteOffset != nil) {
            TGLog(@"storing offset %@", remoteOffset);
            [TGDatabaseInstance() setCustomProperty:@"dialogListRemoteOffset" value:[NSKeyedArchiver archivedDataWithRootObject:remoteOffset]];
        }
        
        [multipleMessagesByConversation enumerateKeysAndObjectsUsingBlock:^(NSNumber *nConversationId, NSArray *messages, __unused  BOOL *stop)
        {
            if (TGPeerIdIsChannel([nConversationId longLongValue])) {
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
                
                [TGDatabaseInstance() addMessagesToChannel:[nConversationId longLongValue] messages:messages deleteMessages:nil unimportantGroups:nil addedHoles:addedHoles removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:true changedMessages:nil];
            } else {
                [TGDatabaseInstance() transactionAddMessages:messages updateConversationDatas:nil notifyAdded:false];
                if (messages.count != 0) {
                    TGMessage *message = messages.firstObject;
                    [TGDatabaseInstance() fillConversationHistoryHole:[nConversationId longLongValue] indexSet:[NSIndexSet indexSetWithIndex:message.mid]];
                }
            }
        }];
        
        [TGDatabaseInstance() transactionAddMessages:nil notifyAddedMessages:false removeMessages:nil updateMessages:nil updatePeerDrafts:updatePeerDrafts removeMessagesInteractive:nil keepDates:false removeMessagesInteractiveForEveryone:false updateConversationDatas:nil applyMaxIncomingReadIds:nil applyMaxOutgoingReadIds:nil applyMaxOutgoingReadDates:nil readHistoryForPeerIds:nil resetPeerReadStates:nil clearConversationsWithPeerIds:nil removeConversationsWithPeerIds:nil updatePinnedConversations:_replaceList ? pinnedPeerIds : nil synchronizePinnedConversations:false forceReplacePinnedConversations:false];
        
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
