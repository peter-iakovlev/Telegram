#import "TGFeedManagementSignals.h"

#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"
#import "TGUserDataRequestBuilder.h"
#import "TGUpdateStateRequestBuilder.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGFeedPosition.h"

#import "TGGroupManagementSignals.h"
#import "TGDownloadMessagesSignal.h"

#import "TLRPCchannels_getFeed.h"
#import "TLRPCchannels_getFeedSources.h"
#import "TLRPCchannels_changeFeedBroadcast.h"
#import "TLRPCchannels_setFeedBroadcasts.h"
#import "TLRPCchannels_readFeed.h"
#import "TLmessages_FeedMessages$messages_feedMessages.h"
#import "TLchannels_FeedSources$channels_feedSources.h"

@implementation TGFeedManagementSignals

+ (SSignal *)feedMessageHoleForFeedId:(int32_t)feedId hole:(TGMessageHole *)hole direction:(TGFeedHistoryHoleDirection)direction {
    int32_t limit = 64;
#ifdef DEBUG
    limit = 4;
#endif
    
    int32_t flags = (1 << 0) | (1 << 1) | (1 << 2);
    TLRPCchannels_getFeed *getFeed = [[TLRPCchannels_getFeed alloc] init];
    getFeed.feed_id = feedId;
    
    TLFeedPosition$feedPosition *minPosition = [[TLFeedPosition$feedPosition alloc] init];
    if (hole.minPeerId != 0)
    {
        TLPeer$peerChannel *minPositionPeer = [[TLPeer$peerChannel alloc] init];
        minPositionPeer.channel_id = TGChannelIdFromPeerId(hole.minPeerId);
        minPosition.peer = minPositionPeer;
        minPosition.n_id = hole.minId;
    }
    minPosition.date = hole.minTimestamp;
    
    
    TLFeedPosition$feedPosition *maxPosition = [[TLFeedPosition$feedPosition alloc] init];
    if (hole.maxPeerId != 0)
    {
        TLPeer$peerChannel *maxPositionPeer = [[TLPeer$peerChannel alloc] init];
        maxPositionPeer.channel_id = TGChannelIdFromPeerId(hole.maxPeerId);
        maxPosition.peer = maxPositionPeer;
        maxPosition.n_id = hole.maxId;
    }
    maxPosition.date = hole.maxTimestamp;
    
    getFeed.flags = flags;
    getFeed.min_position = minPosition;
    getFeed.max_position = maxPosition;
    getFeed.limit = limit;
    switch (direction) {
        case TGFeedHistoryHoleDirectionEarlier:
        {
            getFeed.offset_position = getFeed.max_position;
            getFeed.add_offset = 0;
        }
            break;
        case TGFeedHistoryHoleDirectionLater:
        {
            getFeed.offset_position = getFeed.min_position;
            getFeed.add_offset = -getFeed.limit;
        }
            break;
            
        default:
            break;
    }
    
    return [[[[TGTelegramNetworking instance] requestSignal:getFeed] mapToSignal:^SSignal *(TLmessages_FeedMessages *feedMessages) {
        if ([feedMessages isKindOfClass:[TLmessages_FeedMessages$messages_feedMessages class]])
        {
            TLmessages_FeedMessages$messages_feedMessages *messages = (TLmessages_FeedMessages$messages_feedMessages *)feedMessages;
            [TGUserDataRequestBuilder executeUserDataUpdate:messages.users];
            
            if (messages.chats.count != 0) {
                NSMutableArray *channels = [[NSMutableArray alloc] init];
                for (TLChat *chat in messages.chats)
                {
                    TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
                    if (conversation != nil)
                        [channels addObject:conversation];
                }
                [TGDatabaseInstance() updateChannels:channels];
            }
            
            int32_t minParsedDate = 0;
            int32_t maxParsedDate = 0;
            int32_t minParsedId = 0;
            int32_t maxParsedId = 0;
            int64_t minParsedPeerId = 0;
            int64_t maxParsedPeerId = 0;
            NSMutableArray *parsedMessages = [[NSMutableArray alloc] init];
            for (id desc in messages.messages) {
                TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
                if (message.mid != 0) {
                    [parsedMessages addObject:message];
                    if (minParsedDate == 0 || minParsedDate > message.date) {
                        minParsedId = message.mid;
                        minParsedDate = (int32_t)message.date;
                        minParsedPeerId = message.fromUid;
                    }
                    
                    if (maxParsedDate == 0 || maxParsedDate < message.date) {
                        maxParsedId = message.mid;
                        maxParsedDate = (int32_t)message.date;
                        maxParsedPeerId = message.fromUid;
                    }
                }
            }
            
            bool isSlice = (int32_t)parsedMessages.count >= limit;
            if (parsedMessages.count == 0 || minParsedDate <= hole.minTimestamp) {
                isSlice = false;
            }
            
            TGMessageHole *closedHole = nil;
            if (!isSlice) {
                closedHole = hole;
            } else {
                closedHole = [[TGMessageHole alloc] initWithMinId:minParsedId minTimestamp:minParsedDate minPeerId:minParsedPeerId maxId:hole.maxId maxTimestamp:hole.maxTimestamp maxPeerId:hole.maxPeerId];
            }
            
            return [SSignal single:@{@"messages": parsedMessages, @"hole": closedHole}];
        }
        else {
            return [SSignal complete];
        }
    }] mapToSignal:^SSignal *(NSDictionary *next) {
        return [self messagesWithDownloadedReplyMessages:next];
    }];
}

+ (bool)_containsPreloadedHistoryForPeerId:(int64_t)peerId aroundMessageId:(int32_t)messageId {
    __block bool result = false;
    [TGDatabaseInstance() dispatchOnDatabaseThread:^{
        __block bool messageExists = false;
        __block TGMessageSortKey messageSortKey;
        
        [TGDatabaseInstance() closestChannelMessageKey:peerId messageId:messageId completion:^(bool exists, TGMessageSortKey key) {
            messageExists = exists;
            messageSortKey = key;
        }];
        
        if (!messageExists) {
            result = false;
        } else {
            __block bool hasHoles = false;
            [TGDatabaseInstance() channelMessages:peerId maxTransparentSortKey:TGMessageTransparentSortKeyMake(peerId, TGMessageSortKeyTimestamp(messageSortKey), messageId, TGMessageSortKeySpace(messageSortKey)) count:30 important:false mode:TGChannelHistoryRequestLater completion:^(NSArray *messages, __unused bool hasLater) {
                for (TGMessage *message in messages) {
                    if (message.hole != nil) {
                        hasHoles = true;
                        break;
                    }
                }
            }];
            
            if (!hasHoles) {
                result = true;
            } else {
                result = false;
            }
        }
    } synchronous:true];
    
    return result;
}

+ (SSignal *)preloadedFeedId:(int32_t)feedId aroundPosition:(TGFeedPosition *)position unread:(bool)unread {
    int32_t limit = 64;
    
    __block bool messageExists = false;
    __block TGMessageSortKey messageSortKey;
    [TGDatabaseInstance() feedMessageExists:feedId peerId:position.peerId messageId:position.mid completion:^(bool exists, TGMessageSortKey key) {
        messageExists = exists;
        messageSortKey = key;
    }];
    
    if (messageExists) {
        __block bool hasHoles = false;
        [TGDatabaseInstance() feedMessages:feedId maxTransparentSortKey:TGMessageTransparentSortKeyMake(feedId, TGMessageSortKeyTimestamp(messageSortKey), position.mid, TGMessageSortKeySpace(messageSortKey)) count:30 mode:TGChannelHistoryRequestAround completion:^(NSArray *messages, __unused bool hasLater) {
            for (TGMessage *message in messages) {
                if (message.hole != nil) {
                    hasHoles = true;
                    break;
                }
            }
        }];
        
        if (!hasHoles) {
            return [SSignal single:@{}];
        }
    }
    
    TLRPCchannels_getFeed *getFeed = [[TLRPCchannels_getFeed alloc] init];
    getFeed.feed_id = feedId;
    getFeed.limit = limit;
    
    if (position != nil)
    {
        getFeed.flags = 1 << 0;
        
        TLFeedPosition$feedPosition *minPosition = [[TLFeedPosition$feedPosition alloc] init];
        minPosition.date = 0;
        TLFeedPosition$feedPosition *maxPosition = [[TLFeedPosition$feedPosition alloc] init];
        maxPosition.date = INT32_MAX;
        TLFeedPosition$feedPosition *offsetPosition = [[TLFeedPosition$feedPosition alloc] init];
        TLPeer$peerChannel *offsetPeer = [[TLPeer$peerChannel alloc] init];
        offsetPeer.channel_id = TGChannelIdFromPeerId(position.peerId);
        offsetPosition.peer = offsetPeer;
        offsetPosition.n_id = position.mid;
        offsetPosition.date = position.date;
        
        getFeed.min_position = minPosition;
        getFeed.max_position = maxPosition;
        getFeed.offset_position = offsetPosition;
    }
    else if (unread)
    {
        getFeed.flags = 1 << 3;
    }
    getFeed.add_offset = -limit / 2;
    
    return [[[[TGTelegramNetworking instance] requestSignal:getFeed] mapToSignal:^SSignal *(TLmessages_FeedMessages *feedMessages) {
        if ([feedMessages isKindOfClass:[TLmessages_FeedMessages$messages_feedMessages class]])
        {
            TLmessages_FeedMessages$messages_feedMessages *messages = (TLmessages_FeedMessages$messages_feedMessages *)feedMessages;
            [TGUserDataRequestBuilder executeUserDataUpdate:messages.users];
            
            if (messages.chats.count != 0) {
                NSMutableArray *channels = [[NSMutableArray alloc] init];
                for (TLChat *chat in messages.chats)
                {
                    TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
                    if (conversation != nil)
                        [channels addObject:conversation];
                }
                [TGDatabaseInstance() updateChannels:channels];
            }
        
            int32_t minParsedDate = 0;
            int32_t maxParsedDate = 0;
            int32_t minParsedId = 0;
            int32_t maxParsedId = 0;
            int64_t minParsedPeerId = 0;
            int64_t maxParsedPeerId = 0;
            NSMutableArray<TGMessage *> *parsedMessages = [[NSMutableArray alloc] init];
            for (id desc in messages.messages) {
                TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
                if (message.mid != 0) {
                    [parsedMessages addObject:message];
                    if (minParsedDate == 0 || minParsedDate > message.date) {
                        minParsedId = message.mid;
                        minParsedDate = (int32_t)message.date;
                        minParsedPeerId = message.fromUid;
                    }
                    
                    if (maxParsedDate == 0 || maxParsedDate < message.date) {
                        maxParsedId = message.mid;
                        maxParsedDate = (int32_t)message.date;
                        maxParsedPeerId = message.fromUid;
                    }
                }
            }
            
            TGMessageHole *closedHole = [[TGMessageHole alloc] initWithMinId:minParsedId minTimestamp:minParsedDate minPeerId:minParsedPeerId maxId:maxParsedId maxTimestamp:maxParsedDate maxPeerId:maxParsedPeerId];
            
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            result[@"messages"] = parsedMessages;
            result[@"hole"] = closedHole;
            
            if (messages.read_max_position != nil)
                result[@"readPosition"] = [[TGFeedPosition alloc] initWithTelegraphDesc:messages.read_max_position];
            else if (unread)
                result[@"readPosition"] = [[TGFeedPosition alloc] initWithDate:(int32_t)parsedMessages.firstObject.date mid:parsedMessages.firstObject.mid peerId:parsedMessages.firstObject.cid];
            
            TGFeedPosition *minPosition = [[TGFeedPosition alloc] initWithTelegraphDesc:messages.min_position];
            if (minPosition != nil)
                result[@"minPosition"] = minPosition;
            
            TGFeedPosition *maxPosition = [[TGFeedPosition alloc] initWithTelegraphDesc:messages.max_position];
            if (maxPosition != nil)
                result[@"maxPosition"] = maxPosition;
                
            return [SSignal single:result];
        } else {
            return [SSignal complete];
        }
    }] mapToSignal:^SSignal *(NSDictionary *next) {
        return [self messagesWithDownloadedReplyMessages:next];
    }];
}

+ (bool)_containsPreloadedHistoryForFeedId:(int32_t)feedId aroundMessageId:(int32_t)messageId peerId:(int64_t)peerId
{
    __block bool result = false;
    [TGDatabaseInstance() dispatchOnDatabaseThread:^{
        __block bool messageExists = false;
        __block TGMessageSortKey messageSortKey;
        
        [TGDatabaseInstance() feedMessageExists:feedId peerId:peerId messageId:messageId completion:^(bool exists, TGMessageSortKey key) {
            messageExists = exists;
            messageSortKey = key;
        }];
        
        if (!messageExists) {
            result = false;
        } else {
            __block bool hasHoles = false;
            int64_t feedPeerId = TGPeerIdFromAdminLogId(feedId);
            [TGDatabaseInstance() feedMessages:feedId maxTransparentSortKey:TGMessageTransparentSortKeyMake(feedPeerId, TGMessageSortKeyTimestamp(messageSortKey), messageId, TGMessageSortKeySpace(messageSortKey)) count:30 mode:TGChannelHistoryRequestLater completion:^(NSArray *messages, __unused bool hasLater) {
                for (TGMessage *message in messages) {
                    if (message.hole != nil) {
                        hasHoles = true;
                        break;
                    }
                }
            }];
            
            if (!hasHoles) {
                result = true;
            } else {
                result = false;
            }
        }
    } synchronous:true];
    
    return result;
}

+ (SSignal *)messagesWithDownloadedReplyMessages:(NSDictionary *)next {
    NSArray *addedMessages = next[@"messages"];
    
    NSMutableArray *downloadMessages = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *addedMessageIdToMessage = [[NSMutableDictionary alloc] init];
    for (TGMessage *message in addedMessages) {
        addedMessageIdToMessage[@(message.mid)] = message;
    }
    
    for (TGMessage *message in addedMessages)
    {
        if (message.mediaAttachments.count != 0)
        {
            for (id attachment in message.mediaAttachments)
            {
                if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
                {
                    TGReplyMessageMediaAttachment *replyAttachment = attachment;
                    if (replyAttachment.replyMessage == nil && replyAttachment.replyMessageId != 0) {
                        TGMessage *replyMessage = addedMessageIdToMessage[@(replyAttachment.replyMessageId)];
                        if (replyMessage != nil) {
                            replyAttachment.replyMessage = replyMessage;
                        } else {
                            TGMessage *cachedMessage = [TGDatabaseInstance() loadMessageWithMid:replyAttachment.replyMessageId peerId:message.fromUid];
                            if (cachedMessage != nil) {
                                replyAttachment.replyMessage = cachedMessage;
                            } else {
                                TGConversation *channel = [TGDatabaseInstance() loadConversationWithId:message.fromUid];
                                if (channel != nil) {
                                    [downloadMessages addObject:[[TGDownloadMessage alloc] initWithPeerId:message.fromUid accessHash:channel.accessHash messageId:replyAttachment.replyMessageId]];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (downloadMessages.count != 0) {
        return [[TGDownloadMessagesSignal downloadMessages:downloadMessages] mapToSignal:^SSignal *(NSArray *messages) {
            for (TGMessage *message in messages) {
                addedMessageIdToMessage[@(message.mid)] = message;
            }
            
            for (TGMessage *message in addedMessages)
            {
                if (message.mediaAttachments.count != 0)
                {
                    for (id attachment in message.mediaAttachments)
                    {
                        if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
                        {
                            TGReplyMessageMediaAttachment *replyAttachment = attachment;
                            if (replyAttachment.replyMessage == nil && replyAttachment.replyMessageId != 0) {
                                TGMessage *replyMessage = addedMessageIdToMessage[@(replyAttachment.replyMessageId)];
                                if (replyMessage != nil) {
                                    replyAttachment.replyMessage = replyMessage;
                                }
                            }
                        }
                    }
                }
            }
            
            return [SSignal single:next];
        }];
    } else {
        return [SSignal single:next];
    }
}

+ (TLInputChannel *)inputChannelWithPeerId:(int64_t)peerId {
    if (TGPeerIdIsChannel(peerId)) {
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
        if (conversation != nil) {
            TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
            inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
            inputChannel.access_hash = conversation.accessHash;
            return inputChannel;
        }
    }
    return nil;
}

+ (SSignal *)createFeed:(int32_t)feedId peerIds:(NSSet *)peerIds {
    return [self updateFeedChannels:feedId peerIds:peerIds alsoNewlyJoined:false];
}

+ (SSignal *)updateFeedChannels:(int32_t)feedId peerIds:(NSSet *)peerIds alsoNewlyJoined:(bool)alsoNewlyJoined {
    if (feedId == 0)
        return [SSignal never];
    
    return [[TGDatabaseInstance() modify:^id{
        NSDictionary *feededChannels = @{@(feedId): peerIds};
        [TGDatabaseInstance() transactionUpdateFeededChannels:feededChannels newlyJoinedFeedId:alsoNewlyJoined ? feedId : 0 synchronizeFeededChannels:true];
        
        return [SSignal complete];
    }] switchToLatest];
}

+ (SSignal *)groupChannelWithPeerId:(int64_t)peerId feedId:(int32_t)feedId {
    return [[TGDatabaseInstance() modify:^id{
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
        if (conversation.feedId.intValue == feedId)
            return [SSignal complete];
        
        TGFeed *feed = nil;
        int32_t targetFeedId = feedId;
        if (feedId == 0) {
            targetFeedId = conversation.feedId.intValue;
        }
        feed = [TGDatabaseInstance() loadFeed:targetFeedId];
        
        int32_t newlyJoinedFeedId = 0;
        if (feed.addsJoinedChannels)
            newlyJoinedFeedId = feed.fid;
        
        NSMutableSet *peerIds = [feed.channelIds mutableCopy];
        if (feedId == 0)
            [peerIds removeObject:@(peerId)];
        else
            [peerIds addObject:@(peerId)];
            
        NSDictionary *feededChannels = @{@(targetFeedId): peerIds};
        [TGDatabaseInstance() transactionUpdateFeededChannels:feededChannels newlyJoinedFeedId:newlyJoinedFeedId synchronizeFeededChannels:true];
        
        return [SSignal complete];
    }] switchToLatest];
}

+ (SSignal *)ungroupChannelWithPeerId:(int64_t)peerId {
    return [self groupChannelWithPeerId:peerId feedId:0];
}

+ (SSignal *)synchronizeFeededChannels {
    return [[self synchronizeFeededChannelsOnce] then:[[self pullFeededChannels] then:[[TGDatabaseInstance() synchronizeFeededChannelsActionUpdated] mapToThrottled:^SSignal *(__unused id value) {
        return [self synchronizeFeededChannelsOnce];
    }]]];
}

+ (SSignal *)synchronizeFeededChannelsOnce {
    return [[[TGDatabaseInstance() modify:^id{
        SSignal *signal = [SSignal complete];
        TGSynchronizeFeededChannelsAction *action = [TGDatabaseInstance() currentSynchronizeFeededChannelsAction];
        if (action.type == TGSynchronizeFeededChannelsActionSync)
            signal = [self pushFeededChannelsWithAction:action];
        else if (action.type == TGSynchronizeFeededChannelsActionLoad)
            signal = [self pullFeededChannels];
        
        return [signal then:[self tryCompletingWithAction:action]];
    }] switchToLatest] retryIf:^bool(__unused id error) {
        return true;
    }];
}

+ (SSignal *)tryCompletingWithAction:(TGSynchronizeFeededChannelsAction *)action {
    return [[TGDatabaseInstance() modify:^id{
        if ([[TGDatabaseInstance() currentSynchronizeFeededChannelsAction] isEqual:action]) {
            [TGDatabaseInstance() _setCurrentSynchronizeFeededChannelsAction:[[TGSynchronizeFeededChannelsAction alloc] initWithType:TGSynchronizeFeededChannelsActionNone feedId:action.feedId peerIds:action.peerIds alsoNewlyJoined:action.alsoNewlyJoined version:action.version]];
            return [SSignal complete];
        } else {
            return [SSignal fail:nil];
        }
    }] switchToLatest];
}

+ (SSignal *)pushFeededChannelsWithAction:(TGSynchronizeFeededChannelsAction *)action {
    return [[TGDatabaseInstance() modify:^id{
        TLRPCchannels_setFeedBroadcasts *setFeedBroadcasts = [[TLRPCchannels_setFeedBroadcasts alloc] init];
        
        NSMutableArray *channels = [[NSMutableArray alloc] init];
        for (NSNumber *peerId in action.peerIds) {
            TLInputChannel *channel = [self inputChannelWithPeerId:peerId.int64Value];
            if (channel != nil)
                [channels addObject:channel];
        }
        setFeedBroadcasts.flags = (1 << 0) | (1 << 1);
        setFeedBroadcasts.feed_id = action.feedId;
        setFeedBroadcasts.channels = channels;
        setFeedBroadcasts.also_newly_joined = action.alsoNewlyJoined;
    
        return [[[TGTelegramNetworking instance] requestSignal:setFeedBroadcasts] mapToSignal:^SSignal *(TLUpdates$updates *result) {
            if ([result isKindOfClass:[TLUpdates$updates class]]) {
                [TGUpdateStateRequestBuilder applyUpdates:[NSArray array] otherUpdates:result.updates usersDesc:result.users chatsDesc:result.chats chatParticipantsDesc:nil updatesWithDates:nil addedEncryptedActionsByPeerId:nil addedEncryptedUnparsedActionsByPeerId:nil completion:nil];
            }
            
            if (action.feedId != 0)
            {
                TGFeed *feed = [TGDatabaseInstance() loadFeed:action.feedId];
                if (feed != nil)
                    [TGDatabaseInstance() updateFeeds:@[feed] replace:false dispatch:false remote:true];
            }
            return [SSignal complete];
        }];
    }] switchToLatest];
}


+ (SSignal *)pullFeededChannels {
    TLRPCchannels_getFeedSources *getFeedSources = [[TLRPCchannels_getFeedSources alloc] init];
    return [[[TGTelegramNetworking instance] requestSignal:getFeedSources] mapToSignal:^SSignal *(TLchannels_FeedSources *intermediateResult) {
        if ([intermediateResult isKindOfClass:[TLchannels_FeedSources$channels_feedSources class]]) {
            TLchannels_FeedSources$channels_feedSources *result = (TLchannels_FeedSources$channels_feedSources *)intermediateResult;
            
            [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
            
            int32_t newlyJoinedFeedId = result.newly_joined_feed;
            NSMutableDictionary *feedToChannelMap = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *channelToFeedMap = [[NSMutableDictionary alloc] init];
            for (TLFeedBroadcasts *broadcast in result.feeds) {
                if ([broadcast isKindOfClass:[TLFeedBroadcasts$feedBroadcasts class]]) {
                    TLFeedBroadcasts$feedBroadcasts *feedBroadcast = (TLFeedBroadcasts$feedBroadcasts *)broadcast;
                    
                    NSMutableSet *peerIds = [[NSMutableSet alloc] init];
                    for (NSNumber *channelId in feedBroadcast.channels) {
                        int64_t peerId = TGPeerIdFromChannelId(channelId.int32Value);
                        [peerIds addObject:@(peerId)];
                        
                        channelToFeedMap[@(peerId)] = @(feedBroadcast.feed_id);
                    }
                    
                    feedToChannelMap[@(feedBroadcast.feed_id)] = peerIds;
                } else if ([broadcast isKindOfClass:[TLFeedBroadcasts$feedBroadcastsUngrouped class]]) {
                    
                }
            }
            
            NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
            if (result.chats.count > 0) {
                for (TLChat *chat in result.chats) {
                    TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
                    conversation.feedId = channelToFeedMap[@(conversation.conversationId)] ?: @0;
                    if (conversation != nil)
                        chats[@(conversation.conversationId)] = conversation;
                }
            }
            
            [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:chats notifyAdded:false];
            [TGDatabaseInstance() transactionUpdateFeededChannels:feedToChannelMap newlyJoinedFeedId:newlyJoinedFeedId synchronizeFeededChannels:false];
        }
        return [SSignal complete];
    }];
}

+ (SSignal *)pollFeedMessages {
    return [[TGDatabaseInstance() enqueuedFeedMessagesPolls] mapToSignal:^SSignal *(TGQueuedPeerPoll *poll) {
        int32_t feedId = TGAdminLogIdFromPeerId(poll.peerId);
        return [[self preloadedFeedId:feedId aroundPosition:poll.feedPosition unread:poll.feedPosition == nil] mapToSignal:^SSignal *(NSDictionary *dict) {
            NSArray *removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
            
            TGFeedPosition *minPosition = dict[@"minPosition"];
            TGFeedPosition *maxPosition = dict[@"maxPosition"];
            
            NSMutableArray *addedHoles = [[NSMutableArray alloc] init];
            TGMessageHole *upperHole = [[TGMessageHole alloc] initWithMinId:1 minTimestamp:1 minPeerId:0 maxId:minPosition.mid maxTimestamp:minPosition.date maxPeerId:minPosition.peerId];
            [addedHoles addObject:upperHole];
            
            TGFeed *feed = [TGDatabaseInstance() loadFeed:feedId];
            if (![feed.chatIds.firstObject isEqual:@(maxPosition.peerId)] || (feed.maxKnownMessageId != maxPosition.mid))
            {
                TGMessageHole *lowerHole = [[TGMessageHole alloc] initWithMinId:maxPosition.mid minTimestamp:maxPosition.date minPeerId:maxPosition.peerId maxId:0 maxTimestamp:INT32_MAX maxPeerId:0];
                [addedHoles addObject:lowerHole];
            }
            
            [TGDatabaseInstance() addMessagesToFeed:feedId messages:dict[@"messages"] deleteMessages:nil addedHoles:addedHoles removedHoles:removedImportantHoles  keepUnreadCounters:false changedMessages:^(__unused NSArray *addedMessages, __unused NSArray *removedMessages, __unused NSDictionary *updatedMessages) {
                [TGDatabaseInstance() confirmPeerPoll:poll];
                
                if (dict[@"readPosition"] != nil)
                    [TGDatabaseInstance() updateFeedRead:feedId maxReadPosition:dict[@"readPosition"]];
                
                NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                result[@"removed"] = removedMessages;
                result[@"added"] = addedMessages;
                result[@"updated"] = updatedMessages;
                result[@"fromPoll"] = @true;
                if (minPosition != nil)
                    result[@"minPosition"] = minPosition;
                if (maxPosition != nil)
                    result[@"maxPosition"] = maxPosition;
                
                [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/feedMessages", TGPeerIdFromAdminLogId(feedId)] resource:result];
            }];
            return [SSignal complete];
        }];
    }];
}

+ (SSignal *)readFeedMessages {
    return [[TGDatabaseInstance() enqueuedReadFeedMessages] mapToQueue:^SSignal *(TGQueuedReadFeedMessages *queued) {
        if (TGPeerIdIsAdminLog(queued.feedPeerId)) {
            int32_t feedId = TGAdminLogIdFromPeerId(queued.feedPeerId);
            
            TLRPCchannels_readFeed *readFeed = [[TLRPCchannels_readFeed alloc] init];
            readFeed.feed_id = feedId;
            
            TLFeedPosition$feedPosition *maxPosition = [[TLFeedPosition$feedPosition alloc] init];
            maxPosition.n_id = queued.maxId;
            
            TLPeer$peerChannel *channel = [[TLPeer$peerChannel alloc] init];
            channel.channel_id = TGChannelIdFromPeerId(queued.maxPeerId);
            maxPosition.peer = channel;
            maxPosition.date = queued.maxDate;
            readFeed.max_position = maxPosition;
            
            return [[[[TGTelegramNetworking instance] requestSignal:readFeed] mapToSignal:^SSignal *(TLUpdates$updates *result) {
                [TGDatabaseInstance() confirmFeedHistoryRead:queued];
                
                NSMutableArray *filteredUpdates = [[NSMutableArray alloc] init];
                for (TLUpdate *update in result.updates) {
                    if (![update isKindOfClass:[TLUpdate$updateReadFeedMeta class]])
                        [filteredUpdates addObject:update];
                }
                [TGUpdateStateRequestBuilder applyUpdates:[NSArray array] otherUpdates:filteredUpdates usersDesc:result.users chatsDesc:result.chats chatParticipantsDesc:nil updatesWithDates:nil addedEncryptedActionsByPeerId:nil addedEncryptedUnparsedActionsByPeerId:nil completion:nil];
                
                return [SSignal complete];
            }] catch:^SSignal *(__unused id error) {
                [TGDatabaseInstance() confirmFeedHistoryRead:queued];
                return [SSignal complete];
            }];
        } else {
            return [SSignal complete];
        }
    }];
}

@end


@implementation TGSynchronizeFeededChannelsAction

- (instancetype)initWithType:(int32_t)type feedId:(int32_t)feedId peerIds:(NSSet *)peerIds alsoNewlyJoined:(bool)alsoNewlyJoined version:(int32_t)version {
    self = [super init];
    if (self != nil) {
        _type = type;
        _feedId = feedId;
        _peerIds = peerIds;
        _alsoNewlyJoined = alsoNewlyJoined;
        _version = version;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithType:[aDecoder decodeInt32ForKey:@"type"] feedId:[aDecoder decodeInt32ForKey:@"feedId"] peerIds:[aDecoder decodeObjectForKey:@"peerIds"] alsoNewlyJoined:[aDecoder decodeBoolForKey:@"alsoNewlyJoined"] version:[aDecoder decodeInt32ForKey:@"version"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt32:_type forKey:@"type"];
    [aCoder encodeInt32:_feedId forKey:@"feedId"];
    [aCoder encodeObject:_peerIds forKey:@"peerIds"];
    [aCoder encodeBool:_alsoNewlyJoined forKey:@"alsoNewlyJoined"];
    [aCoder encodeInt32:_version forKey:@"version"];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGSynchronizeFeededChannelsAction class]] && ((TGSynchronizeFeededChannelsAction *)object)->_type == _type && ((TGSynchronizeFeededChannelsAction *)object)->_version == _version;
}

@end
