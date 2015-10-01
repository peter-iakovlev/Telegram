#import "TGChannelManagementSignals.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"

#import "TLUpdates+TG.h"
#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGConversation+Telegraph.h"
#import "TGMessage+Telegraph.h"
#import "TGUser+Telegraph.h"
#import "TGMessageHole.h"

#import "TGPeerIdAdapter.h"

#import "TGUserDataRequestBuilder.h"

#import "TLmessages_Messages$modernChannelMessages.h"
#import "TLUpdates_ChannelDifference_manual.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TLChat$channel.h"

#import "TGChannelStateSignals.h"
#import "TGDownloadMessagesSignal.h"

#import "TLChatFull$channelFull.h"

@implementation TGChannelManagementSignals

+ (SSignal *)makeChannelWithTitle:(NSString *)title about:(NSString *)about userIds:(NSArray *)userIds
{
    TLRPCchannels_createChannel$channels_createChannel *createChannel = [[TLRPCchannels_createChannel$channels_createChannel alloc] init];
    createChannel.title = title;
    createChannel.flags = (1 << 0);
    createChannel.about = about;
    NSMutableArray *inputUsers = [[NSMutableArray alloc] init];
    for (NSNumber *nUserId in userIds) {
        TLInputUser *user = [TGTelegraphInstance createInputUserForUid:[nUserId intValue]];
        if (user != nil) {
            [inputUsers addObject:user];
        }
    }
    createChannel.users = inputUsers;
    return [[[TGTelegramNetworking instance] requestSignal:createChannel] mapToSignal:^SSignal *(TLUpdates *updates) {
        TLChat *chat = [updates chats].firstObject;
        if (chat == nil) {
            return [SSignal fail:nil];
        } else {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
            if (conversation.conversationId == 0)
                return [SSignal fail:nil];
            else
            {
                return [[TGDatabaseInstance() modifyChannel:conversation.conversationId block:^id(__unused int32_t pts) {
                    [TGDatabaseInstance() initializeChannel:conversation];
                    [TGChannelStateSignals addChannelUpdates:conversation.conversationId updates:updates.updatesList];
                    
                    return [[[[TGDatabaseInstance() existingChannel:conversation.conversationId] take:1] mapToSignal:^SSignal *(TGConversation *next) {
                        
                        return [SSignal single:next];
                    }] timeout:6.0 onQueue:[SQueue concurrentDefaultQueue] orSignal:[SSignal fail:nil]];
                }] switchToLatest];
            }
        }
    }];
}

+ (SSignal *)preloadChannelTail:(int64_t)peerId accessHash:(int64_t)accessHash {
    TGMessageHole *hole = [[TGMessageHole alloc] initWithMinId:1 minTimestamp:1 maxId:INT32_MAX maxTimestamp:INT32_MAX];
    
    [TGDatabaseInstance() addMessagesToChannel:peerId messages:nil deleteMessages:nil unimportantGroups:nil addedHoles:@[hole] removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:false changedMessages:nil];
    
    return [[self channelMessageHoleForPeerId:peerId accessHash:accessHash hole:hole direction:TGChannelHistoryHoleDirectionEarlier important:true] mapToSignal:^SSignal *(NSDictionary *dict) {
        NSArray *removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
        NSArray *removedUnimportantHoles = nil;
        
        return [[TGDatabaseInstance() modify:^id {
            [TGDatabaseInstance() addMessagesToChannel:peerId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:true changedMessages:nil];
            if ([dict[@"pts"] intValue] > 0) {
                [TGDatabaseInstance() addMessagesToChannelAndDispatch:peerId messages:nil deletedMessages:nil holes:nil pts:[dict[@"pts"] intValue]];
            }
            
            return [SSignal complete];
        }] switchToLatest];
    }];
}

+ (SSignal *)addChannel:(TGConversation *)conversation {
    return [[TGDatabaseInstance() modifyChannel:conversation.conversationId block:^id(int32_t pts) {
        [TGDatabaseInstance() updateChannels:@[conversation]];
        
        SSignal *signal = [SSignal complete];
        
        if (pts <= 1) {
            signal = [self preloadChannelTail:conversation.conversationId accessHash:conversation.accessHash];
        } else {
            signal = [[TGChannelStateSignals pollOnce:conversation.conversationId] mapToSignal:^SSignal *(__unused id next) {
                return [SSignal complete];
            }];
        }

        return [signal then:[[[[TGDatabaseInstance() existingChannel:conversation.conversationId] take:1] mapToSignal:^SSignal *(TGConversation *next) {
            
            return [SSignal single:next];
        }] timeout:6.0 onQueue:[SQueue concurrentDefaultQueue] orSignal:[SSignal fail:nil]]];
    }] switchToLatest];
}

static dispatch_block_t recursiveBlock(void (^block)(dispatch_block_t recurse))
{
    return ^
    {
        block(recursiveBlock(block));
    };
}

+ (SSignal *)remoteChannelList {
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSMutableArray *channels = [[NSMutableArray alloc] init];
        NSMutableDictionary *messagesByChannel = [[NSMutableDictionary alloc] init];
        NSMutableArray *users = [[NSMutableArray alloc] init];
        
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        
        void (^start)() = recursiveBlock(^(dispatch_block_t recurse) {
            TLRPCchannels_getDialogs$channels_getDialogs *getChannelDialogs = [[TLRPCchannels_getDialogs$channels_getDialogs alloc] init];
            getChannelDialogs.offset = (int32_t)channels.count;
            getChannelDialogs.limit = 512;
            
            __block bool completed = false;
            
            [disposable setDisposable:[[[TGTelegramNetworking instance] requestSignal:getChannelDialogs] startWithNext:^(TLmessages_Dialogs *next) {
                
                NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
                for (id chat in next.chats) {
                    if ([chat isKindOfClass:[TLChat$channel class]]) {
                        TGConversation *channelConversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
                        if (channelConversation.conversationId != 0) {
                            chats[@(channelConversation.conversationId)] = channelConversation;
                        }
                    }
                }
                
                for (id desc in next.messages) {
                    TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
                    if (message.mid != 0) {
                        NSMutableArray *array = messagesByChannel[@(message.cid)];
                        if (array == nil) {
                            array = [[NSMutableArray alloc] init];
                            messagesByChannel[@(message.cid)] = array;
                        }
                        [array addObject:message];
                    }
                }
                
                for (id desc in next.users) {
                    TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:desc];
                    if (user.uid != 0) {
                        [users addObject:user];
                    }
                }
            
                NSMutableArray *currentChannels = [[NSMutableArray alloc] init];
                for (id dialog in next.dialogs) {
                    if ([dialog isKindOfClass:[TLDialog$dialogChannel class]]) {
                        TLDialog$dialogChannel *channelDialog = dialog;
                        if ([channelDialog.peer isKindOfClass:[TLPeer$peerChannel class]]) {
                            TGConversation *conversation = chats[@(TGPeerIdFromChannelId(((TLPeer$peerChannel *)channelDialog.peer).channel_id))];
                            if (conversation != nil) {
                                conversation.pts = channelDialog.pts;
                                conversation.unreadCount = channelDialog.unread_important_count;
                                conversation.serviceUnreadCount = channelDialog.unread_count - channelDialog.unread_important_count;
                                conversation.maxReadMessageId = channelDialog.read_inbox_max_id;
                                [currentChannels addObject:conversation];
                            }
                        }
                    }
                }
                [channels addObjectsFromArray:currentChannels];
                
                completed = currentChannels.count == 0;
            } error:^(id error) {
                [subscriber putError:error];
            } completed:^{
                if (completed) {
                    [subscriber putNext:@{
                        @"channels": channels,
                        @"users": users,
                        @"messagesByChannel": messagesByChannel
                    }];
                    [subscriber putCompletion];
                } else {
                    recurse();
                }
            }]];
        });
        
        start();
        
        return disposable;
    }] mapToSignal:^SSignal *(NSDictionary *next) {
        NSMutableDictionary *channels = [[NSMutableDictionary alloc] init];
        for (TGConversation *channel in next[@"channels"]) {
            channels[@(channel.conversationId)] = channel;
        }
        
        NSMutableArray *downloadMessages = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *addedMessageIdToMessage = [[NSMutableDictionary alloc] init];
        
        [(NSDictionary *)next[@"messagesByChannel"] enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nPeerId, NSArray *messages, __unused BOOL *stop) {
            for (TGMessage *message in messages) {
                addedMessageIdToMessage[@(message.mid)] = message;
            }
        }];
        
        [(NSDictionary *)next[@"messagesByChannel"] enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nPeerId, NSArray *messages, __unused BOOL *stop) {
            for (TGMessage *message in messages)
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
                                    TGConversation *conversation = channels[@(message.cid)];
                                    if (conversation != nil) {
                                        [downloadMessages addObject:[[TGDownloadMessage alloc] initWithPeerId:conversation.conversationId accessHash:conversation.accessHash messageId:replyAttachment.replyMessageId]];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }];
        
        if (downloadMessages.count != 0) {
            return [[TGDownloadMessagesSignal downloadMessages:downloadMessages] mapToSignal:^SSignal *(NSArray *messages) {
                for (TGMessage *message in messages) {
                    addedMessageIdToMessage[@(message.mid)] = message;
                }
                
                [(NSDictionary *)next[@"messagesByChannel"] enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nPeerId, NSArray *messages, __unused BOOL *stop) {
                    for (TGMessage *message in messages)
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
                }];
                
                return [SSignal single:next];
            }];
        } else {
            return [SSignal single:next];
        }
    }];
}

+ (SSignal *)storeRemoteChannelList {
    return [[self remoteChannelList] mapToSignal:^SSignal *(NSDictionary *next) {
        [TGUserDataRequestBuilder executeUserObjectsUpdate:next[@"users"]];
         
        [TGDatabaseInstance() storeSynchronizedChannels:next[@"channels"]];
        [(NSDictionary *)next[@"messagesByChannel"] enumerateKeysAndObjectsUsingBlock:^(NSNumber *nPeerId, NSArray *messages, __unused BOOL *stop) {
            
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
            
            [TGDatabaseInstance() addMessagesToChannel:[nPeerId longLongValue] messages:messages deleteMessages:nil unimportantGroups:nil addedHoles:addedHoles removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:false changedMessages:nil];
            if (messages.count != 0) {
                TGMessageTransparentSortKey maxSortKey = ((TGMessage *)messages[0]).transparentSortKey;
                for (NSUInteger i = 1; i < messages.count; i++) {
                    TGMessageTransparentSortKey currentSortKey = ((TGMessage *)messages[i]).transparentSortKey;
                    if (TGMessageTransparentSortKeyCompare(currentSortKey, maxSortKey) > 0) {
                        maxSortKey = currentSortKey;
                    }
                }
            }
        }];
        
        return [TGDatabaseInstance() channelList];
    }];
}

+ (SSignal *)synchronizedChannelList {
    return [[[TGDatabaseInstance() areChannelsSynchronized] take:1] mapToSignal:^SSignal *(NSNumber *channelsSynchronized) {
        if ([channelsSynchronized boolValue]) {
            return [SSignal complete];
        } else {
            return [[[self storeRemoteChannelList] take:1] onNext:^(NSArray *channels) {
                [ActionStageInstance() dispatchResource:@"/tg/channelListSyncrhonized" resource:channels];
            }];
        }
    }];
}

+ (SSignal *)preloadedHistoryForPeerId:(int64_t)peerId accessHash:(int64_t)accessHash aroundMessageId:(int32_t)messageId {
    int32_t limit = 64;
    
    return [[TGDatabaseInstance() modifyChannel:peerId block:^id(__unused int32_t pts) {
        __block bool messageExists = false;
        __block TGMessageSortKey messageSortKey;
        [TGDatabaseInstance() channelMessageExists:peerId messageId:messageId completion:^(bool exists, TGMessageSortKey key) {
            messageExists = exists;
            messageSortKey = key;
        }];
        
        if (messageExists) {
            __block bool hasHoles = false;
            [TGDatabaseInstance() channelMessages:peerId maxTransparentSortKey:TGMessageTransparentSortKeyMake(peerId, TGMessageSortKeyTimestamp(messageSortKey), messageId, TGMessageSortKeySpace(messageSortKey)) count:30 important:false mode:TGChannelHistoryRequestAround completion:^(NSArray *messages, __unused bool hasLater) {
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
        
        TLRPCmessages_getHistory$messages_getHistory *getHistory = [[TLRPCmessages_getHistory$messages_getHistory alloc] init];
        TLInputPeer$inputPeerChannel *inputChannel = [[TLInputPeer$inputPeerChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
        inputChannel.access_hash = accessHash;
        getHistory.peer = inputChannel;
        getHistory.min_id = 1;
        getHistory.max_id = INT32_MAX;
        getHistory.offset_id = messageId;
        getHistory.add_offset = -limit / 2;
        getHistory.limit = limit;
        
        return [[[TGTelegramNetworking instance] requestSignal:getHistory] mapToSignal:^SSignal *(TLmessages_Messages *messages) {
            [TGUserDataRequestBuilder executeUserDataUpdate:messages.users];
            
            int32_t pts = 0;
            NSArray *collapsed = nil;
            if ([messages isKindOfClass:[TLmessages_Messages$modernChannelMessages class]]) {
                TLmessages_Messages$modernChannelMessages *concreteMessages = (TLmessages_Messages$modernChannelMessages *)messages;
                pts = concreteMessages.pts;
                collapsed = concreteMessages.collapsed;
            }
            
            int32_t minParsedId = 0;
            int32_t maxParsedId = 0;
            int32_t maxParsedDate = 0;
            int32_t minParsedDate = 0;
            NSMutableArray *parsedMessages = [[NSMutableArray alloc] init];
            for (id desc in messages.messages) {
                TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
                message.pts = pts;
                if (message.mid != 0) {
                    [parsedMessages addObject:message];
                    if (minParsedId == 0 || minParsedId > message.mid) {
                        minParsedId = message.mid;
                        minParsedDate = (int32_t)message.date;
                    }
                    
                    if (maxParsedId == 0 || maxParsedId < message.mid) {
                        maxParsedId = message.mid;
                        maxParsedDate = (int32_t)message.date;
                    }
                }
            }
            
            TGMessageHole *closedHole = [[TGMessageHole alloc] initWithMinId:minParsedId minTimestamp:minParsedDate maxId:maxParsedId maxTimestamp:maxParsedDate];
            
            return [SSignal single:@{@"messages": parsedMessages, @"hole": closedHole}];
        }];
    }] switchToLatest];
}

+ (SSignal *)preloadedHistoryTailForPeerId:(int64_t)peerId accessHash:(int64_t)accessHash {
    int32_t limit = 64;
    
    return [[TGDatabaseInstance() modify:^{
        __block bool hasHoles = false;
        [TGDatabaseInstance() channelMessages:peerId maxTransparentSortKey:TGMessageTransparentSortKeyUpperBound(peerId) count:50 important:false mode:TGChannelHistoryRequestEarlier completion:^(NSArray *messages, __unused bool hasLater) {
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
        
        TLRPCmessages_getHistory$messages_getHistory *getHistory = [[TLRPCmessages_getHistory$messages_getHistory alloc] init];
        TLInputPeer$inputPeerChannel *inputChannel = [[TLInputPeer$inputPeerChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
        inputChannel.access_hash = accessHash;
        getHistory.peer = inputChannel;
        getHistory.min_id = 1;
        getHistory.max_id = INT32_MAX;
        getHistory.offset_id = INT32_MAX;
        getHistory.add_offset = 0;
        getHistory.limit = limit;
        
        return [[[TGTelegramNetworking instance] requestSignal:getHistory] mapToSignal:^SSignal *(TLmessages_Messages *messages) {
            [TGUserDataRequestBuilder executeUserDataUpdate:messages.users];
            
            int32_t pts = 0;
            NSArray *collapsed = nil;
            if ([messages isKindOfClass:[TLmessages_Messages$modernChannelMessages class]]) {
                TLmessages_Messages$modernChannelMessages *concreteMessages = (TLmessages_Messages$modernChannelMessages *)messages;
                pts = concreteMessages.pts;
                collapsed = concreteMessages.collapsed;
            }
            
            int32_t minParsedId = 0;
            int32_t maxParsedId = 0;
            int32_t maxParsedDate = 0;
            int32_t minParsedDate = 0;
            NSMutableArray *parsedMessages = [[NSMutableArray alloc] init];
            for (id desc in messages.messages) {
                TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
                message.pts = pts;
                if (message.mid != 0) {
                    [parsedMessages addObject:message];
                    if (minParsedId == 0 || minParsedId > message.mid) {
                        minParsedId = message.mid;
                        minParsedDate = (int32_t)message.date;
                    }
                    
                    if (maxParsedId == 0 || maxParsedId < message.mid) {
                        maxParsedId = message.mid;
                        maxParsedDate = (int32_t)message.date;
                    }
                }
            }
            
            TGMessageHole *closedHole = [[TGMessageHole alloc] initWithMinId:minParsedId minTimestamp:minParsedDate maxId:maxParsedId maxTimestamp:maxParsedDate];
            
            return [SSignal single:@{@"messages": parsedMessages, @"hole": closedHole}];
        }];
    }] switchToLatest];
}

+ (SSignal *)preloadedChannelAtMessage:(int64_t)peerId messageId:(int32_t)messageId {
    SSignal *channelSignal = [[[TGDatabaseInstance() existingChannel:peerId] take:1] timeout:5.0 onQueue:[SQueue concurrentDefaultQueue] orSignal:[SSignal fail:nil]];
    
    return [channelSignal mapToSignal:^SSignal *(TGConversation *conversation) {
        if (messageId == 0) {
            SSignal *historySignal = [[self preloadedHistoryTailForPeerId:peerId accessHash:conversation.accessHash] mapToSignal:^SSignal *(NSDictionary *dict) {
                return [[TGDatabaseInstance() modify:^{
                    NSArray *removedImportantHoles = nil;
                    NSArray *removedUnimportantHoles = nil;
                    
                    removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                    removedUnimportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                    
                    [TGDatabaseInstance() addMessagesToChannel:peerId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:false changedMessages:nil];
                    
                    return [SSignal complete];
                }] switchToLatest];
            }];
            
            return [[[TGDatabaseInstance() modifyChannel:peerId block:^id(int32_t pts) {
                if (pts <= 1) {
                    return [[self preloadChannelTail:peerId accessHash:conversation.accessHash] then:historySignal];
                } else {
                    return historySignal;
                }
            }] switchToLatest] then:channelSignal];
        } else {
            SSignal *historySignal = [[self preloadedHistoryForPeerId:peerId accessHash:conversation.accessHash aroundMessageId:messageId] mapToSignal:^SSignal *(NSDictionary *dict) {
                return [[TGDatabaseInstance() modify:^{
                    NSArray *removedImportantHoles = nil;
                    NSArray *removedUnimportantHoles = nil;
                    
                    removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                    removedUnimportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                    
                    [TGDatabaseInstance() addMessagesToChannel:peerId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:false changedMessages:nil];
                    
                    return [SSignal complete];
                }] switchToLatest];
            }];
            
            return [[[TGDatabaseInstance() modifyChannel:peerId block:^id(int32_t pts) {
                if (pts <= 1) {
                    return [[self preloadChannelTail:peerId accessHash:conversation.accessHash] then:historySignal];
                } else {
                    return historySignal;
                }
            }] switchToLatest] then:channelSignal];
        }
    }];
}

+ (SSignal *)preloadedChannel:(int64_t)peerId {
    return [self preloadedChannelAtMessage:peerId messageId:0];
}

+ (SSignal *)channelMessageHoleForPeerId:(int64_t)peerId accessHash:(int64_t)accessHash hole:(TGMessageHole *)hole direction:(TGChannelHistoryHoleDirection)direction important:(bool)important {
    
    int32_t limit = 100;
#ifdef DEBUG
    //limit = 2;
#endif
    
    id request = nil;
    if (important) {
        TLRPCchannels_getImportantHistory$channels_getImportantHistory *getImportantHistory = [[TLRPCchannels_getImportantHistory$channels_getImportantHistory alloc] init];
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
        inputChannel.access_hash = accessHash;
        getImportantHistory.channel = inputChannel;
        getImportantHistory.min_id = hole.minId - 1;
        getImportantHistory.max_id = hole.maxId == INT32_MAX ? hole.maxId : (hole.maxId + 1);
        getImportantHistory.limit = limit;
        switch (direction) {
            case TGChannelHistoryHoleDirectionEarlier:
                getImportantHistory.offset_id = getImportantHistory.max_id;
                getImportantHistory.add_offset = 0;
                break;
            case TGChannelHistoryHoleDirectionLater:
                getImportantHistory.offset_id = getImportantHistory.min_id;
                getImportantHistory.add_offset = -getImportantHistory.limit;
                break;
        }
        
        request = getImportantHistory;
    } else {
        TLRPCmessages_getHistory$messages_getHistory *getHistory = [[TLRPCmessages_getHistory$messages_getHistory alloc] init];
        TLInputPeer$inputPeerChannel *inputChannel = [[TLInputPeer$inputPeerChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
        inputChannel.access_hash = accessHash;
        getHistory.peer = inputChannel;
        getHistory.min_id = hole.minId - 1;
        getHistory.max_id = hole.maxId == INT32_MAX ? hole.maxId : (hole.maxId + 1);
        getHistory.limit = limit;
        switch (direction) {
            case TGChannelHistoryHoleDirectionEarlier:
                getHistory.offset_id = getHistory.max_id;
                getHistory.add_offset = 0;
                break;
            case TGChannelHistoryHoleDirectionLater:
                getHistory.offset_id = getHistory.min_id;
                getHistory.add_offset = -getHistory.limit;
                break;
        }
        
        request = getHistory;
    }
    return [[[[TGTelegramNetworking instance] requestSignal:request] mapToSignal:^SSignal *(TLmessages_Messages *messages) {
        [TGUserDataRequestBuilder executeUserDataUpdate:messages.users];
        
        int32_t pts = 0;
        NSArray *collapsed = nil;
        if ([messages isKindOfClass:[TLmessages_Messages$modernChannelMessages class]]) {
            TLmessages_Messages$modernChannelMessages *concreteMessages = (TLmessages_Messages$modernChannelMessages *)messages;
            pts = concreteMessages.pts;
            collapsed = concreteMessages.collapsed;
        }
        
        int32_t minParsedId = 0;
        int32_t maxParsedId = 0;
        int32_t maxParsedDate = 0;
        int32_t minParsedDate = 0;
        NSMutableArray *parsedMessages = [[NSMutableArray alloc] init];
        for (id desc in messages.messages) {
            TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
            message.pts = pts;
            if (message.mid != 0) {
                [parsedMessages addObject:message];
                if (minParsedId == 0 || minParsedId > message.mid) {
                    minParsedId = message.mid;
                    minParsedDate = (int32_t)message.date;
                }
                
                if (maxParsedId == 0 || maxParsedId < message.mid) {
                    maxParsedId = message.mid;
                    maxParsedDate = (int32_t)message.date;
                }
            }
        }
        
        NSMutableArray *unimportantGroups = [[NSMutableArray alloc] init];
        if (important) {
            for (TLMessageGroup *groupDesc in collapsed) {
                TGMessageGroup *group = [[TGMessageGroup alloc] initWithMinId:groupDesc.min_id + 1 minTimestamp:1 maxId:groupDesc.max_id - 1 maxTimestamp:groupDesc.date count:groupDesc.count];
                if (group.count != 0) {
                    [unimportantGroups addObject:group];
                }
                
                if (minParsedId == 0 || minParsedId > group.minId) {
                    minParsedId = group.minId;
                    minParsedDate = group.maxTimestamp;
                }
                
                if (maxParsedId == 0 || maxParsedId < group.maxId) {
                    maxParsedId = group.maxId;
                    maxParsedDate = group.maxTimestamp;
                }
            }
        }
        
        bool isSlice = (int32_t)parsedMessages.count >= limit;
        if (parsedMessages.count == 0 || minParsedId <= hole.minId) {
            isSlice = false;
        }
        
        TGMessageHole *closedHole = nil;
        if (!isSlice) {
            closedHole = hole;
        } else {
            closedHole = [[TGMessageHole alloc] initWithMinId:minParsedId minTimestamp:minParsedDate maxId:hole.maxId maxTimestamp:hole.maxTimestamp];
        }
        
        return [SSignal single:@{@"messages": parsedMessages, @"hole": closedHole, @"unimportantGroups": unimportantGroups, @"pts": @(pts)}];
    }] mapToSignal:^SSignal *(NSDictionary *next) {
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
                                [downloadMessages addObject:[[TGDownloadMessage alloc] initWithPeerId:peerId accessHash:accessHash messageId:replyAttachment.replyMessageId]];
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
    }];
}

+ (SSignal *)exportChannelInvitationLink:(int64_t)peerId accessHash:(int64_t)accessHash
{
    TLRPCchannels_exportInvite$channels_exportInvite *exportChatInvite = [[TLRPCchannels_exportInvite$channels_exportInvite alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    exportChatInvite.channel = inputChannel;
    return [[[TGTelegramNetworking instance] requestSignal:exportChatInvite] mapToSignal:^SSignal *(TLExportedChatInvite *result)
    {
        if ([result isKindOfClass:[TLExportedChatInvite$chatInviteExported class]])
        {
            NSString *link = ((TLExportedChatInvite$chatInviteExported *)result).link;
            
            [TGDatabaseInstance() updateChannelCachedData:peerId block:^TGCachedConversationData *(TGCachedConversationData *currentData) {
                if (currentData == nil) {
                    currentData = [[TGCachedConversationData alloc] init];
                }
                return [currentData updatePrivateLink:link];
            }];
            
            return [SSignal single:link];
        }
        else
            return [SSignal fail:nil];
    }];
}

+ (SSignal *)_channelDifference:(int64_t)peerId accessHash:(int64_t)accessHash pts:(int32_t)pts {
    int32_t limit = 100;
    
    TLRPCupdates_getChannelDifference$updates_getChannelDifference *getChannelDifference = [[TLRPCupdates_getChannelDifference$updates_getChannelDifference alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    getChannelDifference.channel = inputChannel;
    getChannelDifference.filter = [[TLChannelMessagesFilter$channelMessagesFilterEmpty alloc] init];
    getChannelDifference.pts = pts;
    getChannelDifference.limit = limit;
    
    return [[TGTelegramNetworking instance] requestSignal:getChannelDifference];
}

+ (SSignal *)deleteChannelMessages {
    return [[TGDatabaseInstance() enqueuedDeleteChannelMessages] mapToQueue:^SSignal *(TGQueuedDeleteChannelMessages *queued) {
        TLRPCchannels_deleteMessages$channels_deleteMessages *deleteChannelMessages = [[TLRPCchannels_deleteMessages$channels_deleteMessages alloc] init];
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(queued.peerId);
        inputChannel.access_hash = queued.accessHash;
        deleteChannelMessages.channel = inputChannel;
        deleteChannelMessages.n_id = queued.messageIds;
        
        return [[[[TGTelegramNetworking instance] requestSignal:deleteChannelMessages] mapToSignal:^SSignal *(TLmessages_AffectedMessages *result) {
            [TGDatabaseInstance() confirmChannelMessagesDeleted:queued];
            [self updateChannelState:queued.peerId pts:result.pts ptsCount:result.pts_count];
            return [SSignal complete];
        }] catch:^SSignal *(__unused id error) {
            [TGDatabaseInstance() confirmChannelMessagesDeleted:queued];
            return [SSignal complete];
        }];
    }];
}

+ (SSignal *)readChannelMessages {
    return [[TGDatabaseInstance() enqueuedReadChannelMessages] mapToQueue:^SSignal *(TGQueuedReadChannelMessages *queued) {
        TLRPCchannels_readHistory$channels_readHistory *readChannelHistory = [[TLRPCchannels_readHistory$channels_readHistory alloc] init];
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(queued.peerId);
        inputChannel.access_hash = queued.accessHash;
        readChannelHistory.channel = inputChannel;
        readChannelHistory.max_id = queued.maxId;
        
        return [[[[TGTelegramNetworking instance] requestSignal:readChannelHistory] mapToSignal:^SSignal *(__unused NSNumber *result) {
            [TGDatabaseInstance() confirmChannelHistoryRead:queued];
            return [SSignal complete];
        }] catch:^SSignal *(__unused id error) {
            [TGDatabaseInstance() confirmChannelHistoryRead:queued];
            return [SSignal complete];
        }];
    }];
}

+ (SSignal *)leaveChannels {
    return [[TGDatabaseInstance() enqueuedLeaveChannels] mapToQueue:^SSignal *(TGQueuedLeaveChannel *queued) {
        TLRPCchannels_leaveChannel$channels_leaveChannel *leaveChannel = [[TLRPCchannels_leaveChannel$channels_leaveChannel alloc] init];
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(queued.peerId);
        inputChannel.access_hash = queued.accessHash;
        leaveChannel.channel = inputChannel;
        
        return [[[[TGTelegramNetworking instance] requestSignal:leaveChannel] mapToSignal:^SSignal *(__unused NSNumber *result) {
            [TGDatabaseInstance() confirmChannelLeaved:queued];
            return [SSignal complete];
        }] catch:^SSignal *(__unused id error) {
            [TGDatabaseInstance() confirmChannelLeaved:queued];
            return [SSignal complete];
        }];
    }];
}

+ (void)updateChannelState:(int64_t)peerId pts:(int32_t)pts ptsCount:(int32_t)ptsCount {
    [[TGDatabaseInstance() modifyChannel:peerId block:^id(int32_t currentPts) {
        if (currentPts + ptsCount == pts) {
            [TGDatabaseInstance() addMessagesToChannelAndDispatch:peerId messages:nil deletedMessages:nil holes:nil pts:pts];
        } else {
            TLUpdate$updateChannelTooLong *updateChannelTooLong = [[TLUpdate$updateChannelTooLong alloc] init];
                updateChannelTooLong.channel_id = TGChannelIdFromPeerId(peerId);
            [TGChannelStateSignals addChannelUpdates:peerId updates:@[updateChannelTooLong]];
        }
        return nil;
    }] startWithNext:nil];
}

+ (SSignal *)joinTemporaryChannel:(int64_t)peerId {
    return [[[TGDatabaseInstance() existingChannel:peerId] take:1] mapToSignal:^SSignal *(TGConversation *next) {
        TLRPCchannels_joinChannel$channels_joinChannel *joinChannel = [[TLRPCchannels_joinChannel$channels_joinChannel alloc] init];
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
        inputChannel.access_hash = next.accessHash;
        joinChannel.channel = inputChannel;

        return [[[TGTelegramNetworking instance] requestSignal:joinChannel] mapToSignal:^SSignal *(TLUpdates *updates) {
            if (updates.chats.count != 0) {
                TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:updates.chats[0]];
                if (conversation.conversationId == peerId) {
                    return [[TGDatabaseInstance() modifyChannel:peerId block:^id(__unused int32_t pts) {
                        [TGDatabaseInstance() updateChannels:@[conversation]];
                        return [SSignal complete];
                    }] switchToLatest];
                } else {
                    return [SSignal fail:nil];
                }
            } else {
                return [SSignal fail:nil];
            }
        }];
    }];
}

+ (SSignal *)inviteUsers:(int64_t)peerId accessHash:(int64_t)accessHash users:(NSArray *)users {
    TLRPCchannels_inviteToChannel$channels_inviteToChannel *inviteToChannel = [[TLRPCchannels_inviteToChannel$channels_inviteToChannel alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    inviteToChannel.channel = inputChannel;
    
    NSMutableArray *inputUsers = [[NSMutableArray alloc] init];
    for (TGUser *user in users) {
        TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
        inputUser.user_id = user.uid;
        inputUser.access_hash = user.phoneNumberHash;
        [inputUsers addObject:inputUser];
    }
    inviteToChannel.users = inputUsers;
    
    return [[[TGTelegramNetworking instance] requestSignal:inviteToChannel] mapToSignal:^SSignal *(TLUpdates *updates) {
        id chat = updates.chats.firstObject;
        TGConversation *conversation = nil;
        if (chat != nil) {
            conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
            if (conversation.conversationId == peerId) {
                [TGDatabaseInstance() updateChannels:@[conversation]];
            }
        }
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        return [SSignal complete];
    }];
}

+ (SSignal *)checkChannelUsername:(int64_t)peerId accessHash:(int64_t)accessHash username:(NSString *)username {
    TLRPCchannels_checkUsername$channels_checkUsername *checkChannelUsername = [[TLRPCchannels_checkUsername$channels_checkUsername alloc] init];
    if (peerId != 0) {
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
        inputChannel.access_hash = accessHash;
        checkChannelUsername.channel = inputChannel;
    } else {
        checkChannelUsername.channel = [[TLInputChannel$inputChannelEmpty alloc] init];
    }
    checkChannelUsername.username = username;
    return [[[TGTelegramNetworking instance] requestSignal:checkChannelUsername] mapToSignal:^SSignal *(NSNumber *result) {
        if ([result boolValue]) {
            return [SSignal complete];
        } else {
            return [SSignal fail:nil];
        }
    }];
}

+ (SSignal *)updateChannelUsername:(int64_t)peerId accessHash:(int64_t)accessHash username:(NSString *)username {
    TLRPCchannels_updateUsername$channels_updateUsername *updateChannelUsername = [[TLRPCchannels_updateUsername$channels_updateUsername alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    updateChannelUsername.channel = inputChannel;
    updateChannelUsername.username = username;
    return [[[TGTelegramNetworking instance] requestSignal:updateChannelUsername] mapToSignal:^SSignal *(NSNumber *result) {
        if ([result boolValue]) {
            return [[TGDatabaseInstance() modifyChannel:peerId block:^id(__unused int32_t pts) {
                [TGDatabaseInstance() updateChannelUsername:peerId username:username];
                return [SSignal complete];
            }] switchToLatest];
        } else {
            return [SSignal fail:nil];
        }
    }];
}

+ (SSignal *)updateChannelAbout:(int64_t)peerId accessHash:(int64_t)accessHash about:(NSString *)about {
    TLRPCchannels_editAbout$channels_editAbout *editChatAbout = [[TLRPCchannels_editAbout$channels_editAbout alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    editChatAbout.channel = inputChannel;
    editChatAbout.about = about;
    return [[[TGTelegramNetworking instance] requestSignal:editChatAbout] mapToSignal:^SSignal *(NSNumber *result) {
        if ([result boolValue]) {
            return [[TGDatabaseInstance() modifyChannel:peerId block:^id(__unused int32_t pts) {
                [TGDatabaseInstance() updateChannelAbout:peerId about:about];
                return [SSignal complete];
            }] switchToLatest];
        } else {
            return [SSignal fail:nil];
        }
    }];
}


+ (SSignal *)updateChannelPhoto:(int64_t)peerId accessHash:(int64_t)accessHash uploadedFile:(SSignal *)uploadedFile {
    return [uploadedFile mapToSignal:^SSignal *(TLInputFile *inputFile) {
        TLRPCchannels_editPhoto$channels_editPhoto *editPhoto = [[TLRPCchannels_editPhoto$channels_editPhoto alloc] init];
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
        inputChannel.access_hash = accessHash;
        editPhoto.channel = inputChannel;
        TLInputChatPhoto$inputChatUploadedPhoto *uploadedPhoto = [[TLInputChatPhoto$inputChatUploadedPhoto alloc] init];
        uploadedPhoto.file = inputFile;
        uploadedPhoto.crop = [[TLInputPhotoCrop$inputPhotoCropAuto alloc] init];
        editPhoto.photo = uploadedPhoto;
        
        return [[[TGTelegramNetworking instance] requestSignal:editPhoto] mapToSignal:^SSignal *(TLUpdates *updates) {
            if (updates.chats.count != 0) {
                TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:updates.chats[0]];
                if (conversation.conversationId == peerId) {
                    [TGDatabaseInstance() updateChannels:@[conversation]];
                }
            }
            [[TGTelegramNetworking instance] addUpdates:updates];
            
            return [SSignal complete];
        }];
    }];
}

+ (SSignal *)updateChannelExtendedInfo:(int64_t)peerId accessHash:(int64_t)accessHash updateUnread:(bool)updateUnread {
    TLRPCchannels_getFullChannel$channels_getFullChannel *getFullChat = [[TLRPCchannels_getFullChannel$channels_getFullChannel alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    getFullChat.channel = inputChannel;
    return [[[[TGTelegramNetworking instance] requestSignal:getFullChat] mapToSignal:^SSignal *(TLmessages_ChatFull *result) {
        if ([result.full_chat isKindOfClass:[TLChatFull$channelFull class]]) {
            TLChatFull$channelFull *channelFull = (TLChatFull$channelFull *)result.full_chat;
            
            TGConversation *conversation = nil;
            for (TLChat *chat in result.chats) {
                if ([chat isKindOfClass:[TLChat$channel class]]) {
                    if (((TLChat$channel *)chat).n_id == TGChannelIdFromPeerId(peerId)) {
                        conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
                        break;
                    }
                }
            }
            
            NSString *privateLink = @"";
            if ([channelFull.exported_invite isKindOfClass:[TLExportedChatInvite$chatInviteExported class]]) {
                privateLink = ((TLExportedChatInvite$chatInviteExported *)channelFull.exported_invite).link;
            }
            
            return [[TGDatabaseInstance() modifyChannel:peerId block:^id(__unused int32_t pts) {
                if (conversation != nil) {
                    [TGDatabaseInstance() updateChannels:@[conversation]];
                }
                [TGDatabaseInstance() updateChannelAbout:peerId about:channelFull.about];
                
                if (updateUnread) {
                    [TGDatabaseInstance() updateChannelReadState:peerId maxReadId:channelFull.read_inbox_max_id unreadImportantCount:channelFull.unread_important_count unreadUnimportantCount:channelFull.unread_count - channelFull.unread_important_count];
                }
                
                [TGDatabaseInstance() updateChannelCachedData:peerId block:^TGCachedConversationData *(TGCachedConversationData *currentData) {
                    if (currentData == nil) {
                        currentData = [[TGCachedConversationData alloc] init];
                    }
                    
                    currentData = [currentData updatePrivateLink:privateLink];
                    
                    return [currentData updateManagementCount:channelFull.admins_count blacklistCount:channelFull.kicked_count memberCount:channelFull.participants_count];
                }];
                
                TLPeerNotifySettings *settings = channelFull.notify_settings;
                
                int peerSoundId = 0;
                int peerMuteUntil = 0;
                bool peerPreviewText = true;
                bool photoNotificationsEnabled = true;
                
                if ([settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                {
                    TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)settings;
                    peerMuteUntil = concreteSettings.mute_until;
                    
                    if (peerMuteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
                        peerMuteUntil = 0;
                    
                    if (concreteSettings.sound.length == 0)
                        peerSoundId = 0;
                    else if ([concreteSettings.sound isEqualToString:@"default"])
                        peerSoundId = 1;
                    else
                        peerSoundId = [concreteSettings.sound intValue];
                    
                    peerPreviewText = concreteSettings.show_previews;
                    
                    photoNotificationsEnabled = concreteSettings.events_mask & 1;
                }
                
                [TGDatabaseInstance() storePeerNotificationSettings:peerId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText photoNotificationsEnabled:photoNotificationsEnabled writeToActionQueue:false completion:^(bool changed)
                 {
                     if (changed)
                     {
                         [ActionStageInstance() dispatchOnStageQueue:^
                          {
                              NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:peerMuteUntil], @"muteUntil", [NSNumber numberWithInt:peerSoundId], @"soundId", [[NSNumber alloc] initWithBool:peerPreviewText], @"previewText", [[NSNumber alloc] initWithBool:photoNotificationsEnabled], @"photoNotificationsEnabled", nil];
                              
                              [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/peerSettings/(%lld)", peerId] resource:[[SGraphObjectNode alloc] initWithObject:dict]];
                          }];
                     }
                 }];
                
                return [SSignal complete];
            }] switchToLatest];
        }
        
        return [SSignal complete];
    }] catch:^SSignal *(id error) {
        NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorType isEqual:@"CHANNEL_PRIVATE"]) {
            return [[TGDatabaseInstance() modify:^id{
                TGConversation *conversation = [[TGDatabaseInstance() loadChannels:@[@(peerId)]][@(peerId)] copy];
                if (conversation != nil && !conversation.kickedFromChat) {
                    conversation.kickedFromChat = true;
                    [TGDatabaseInstance() updateChannels:@[conversation]];
                }
                
                return [SSignal complete];
            }] switchToLatest];
        }
        return [SSignal complete];
    }];
}

+ (SSignal *)updatedPeerMessageViews:(int64_t)peerId accessHash:(int64_t)accessHash messageIds:(NSArray *)messageIds {
    TLRPCmessages_getMessagesViews$messages_getMessagesViews *getMessageViews = [[TLRPCmessages_getMessagesViews$messages_getMessagesViews alloc] init];
    if (TGPeerIdIsChannel(peerId)) {
        TLInputPeer$inputPeerChannel *inputChannel = [[TLInputPeer$inputPeerChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
        inputChannel.access_hash = accessHash;
        getMessageViews.peer = inputChannel;
    } else {
        getMessageViews.peer = [[TLInputPeer$inputPeerEmpty alloc] init];
    }
    getMessageViews.n_id = messageIds;
    
    return [[[TGTelegramNetworking instance] requestSignal:getMessageViews] mapToSignal:^SSignal *(NSArray *viewCounts) {
        NSMutableDictionary *messageIdToViewCount = [[NSMutableDictionary alloc] init];
        NSUInteger count = MIN(messageIds.count, viewCounts.count);
        for (NSUInteger i = 0; i < count; i++) {
            messageIdToViewCount[messageIds[i]] = viewCounts[i];
        }
        return [[TGDatabaseInstance() modify:^id{
            [TGDatabaseInstance() updateMessageViews:peerId messageIdToViews:messageIdToViewCount];
            return [SSignal single:messageIdToViewCount];
        }] switchToLatest];
    }];
}

+ (SSignal *)consumeMessages:(int64_t)peerId accessHash:(int64_t)accessHash messageIds:(NSArray *)messageIds {
    TLRPCmessages_getMessagesViews$messages_getMessagesViews *getMessageViews = [[TLRPCmessages_getMessagesViews$messages_getMessagesViews alloc] init];
    if (TGPeerIdIsChannel(peerId)) {
        TLInputPeer$inputPeerChannel *inputChannel = [[TLInputPeer$inputPeerChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
        inputChannel.access_hash = accessHash;
        getMessageViews.peer = inputChannel;
    } else {
        getMessageViews.peer = [[TLInputPeer$inputPeerEmpty alloc] init];
    }
    getMessageViews.increment = true;
    getMessageViews.n_id = messageIds;
    
    return [[[TGTelegramNetworking instance] requestSignal:getMessageViews] mapToSignal:^SSignal *(NSArray *viewCounts) {
        return [[TGDatabaseInstance() modify:^id{
            NSMutableDictionary *messageIdToViewCount = [[NSMutableDictionary alloc] init];
            NSUInteger count = MIN(messageIds.count, viewCounts.count);
            for (NSUInteger i = 0; i < count; i++) {
                messageIdToViewCount[messageIds[i]] = viewCounts[i];
            }
            [TGDatabaseInstance() updateMessageViews:peerId messageIdToViews:messageIdToViewCount];
            return [SSignal single:messageIdToViewCount];
        }] switchToLatest];
    }];
}

+ (SSignal *)toggleChannelCommentsEnabled:(int64_t)peerId accessHash:(int64_t)accessHash enabled:(bool)enabled {
    TLRPCchannels_toggleComments$channels_toggleComments *toggleChannelComments = [[TLRPCchannels_toggleComments$channels_toggleComments alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    toggleChannelComments.channel = inputChannel;
    toggleChannelComments.enabled = enabled;
    return [[[TGTelegramNetworking instance] requestSignal:toggleChannelComments] mapToSignal:^SSignal *(TLUpdates *updates) {
        if (updates.chats.count != 0) {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:updates.chats[0]];
            if (conversation.conversationId == peerId) {
                [TGDatabaseInstance() updateChannels:@[conversation]];
            }
        }
        
        [[TGTelegramNetworking instance] addUpdates:updates];
        return [SSignal complete];
    }];
}

+ (SSignal *)channelChangeMemberKicked:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user kicked:(bool)kicked {
    TLRPCchannels_kickFromChannel$channels_kickFromChannel *kickFromChannel = [[TLRPCchannels_kickFromChannel$channels_kickFromChannel alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    kickFromChannel.channel = inputChannel;
    TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
    inputUser.user_id = user.uid;
    inputUser.access_hash = user.phoneNumberHash;
    kickFromChannel.user_id = inputUser;
    kickFromChannel.kicked = kicked;
    
    return [[[TGTelegramNetworking instance] requestSignal:kickFromChannel] mapToSignal:^SSignal *(TLUpdates *updates) {
        if (updates.chats.count != 0) {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:updates.chats[0]];
            if (conversation.conversationId == peerId) {
                [TGDatabaseInstance() updateChannels:@[conversation]];
            }
        }
        [[TGTelegramNetworking instance] addUpdates:updates];
        return [SSignal complete];
    }];
}

+ (SSignal *)channelChangeRole:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user role:(TGChannelRole)role {
    TLRPCchannels_editAdmin$channels_editAdmin *editAdmin = [[TLRPCchannels_editAdmin$channels_editAdmin alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    editAdmin.channel = inputChannel;
    TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
    inputUser.user_id = user.uid;
    inputUser.access_hash = user.phoneNumberHash;
    editAdmin.user_id = inputUser;
    switch (role) {
        case TGChannelRoleMember:
            editAdmin.role = [[TLChannelParticipantRole$channelRoleEmpty alloc] init];
            break;
        case TGChannelRoleCreator:
        case TGChannelRoleModerator:
            editAdmin.role = [[TLChannelParticipantRole$channelRoleModerator alloc] init];
            break;
        case TGChannelRolePublisher:
            editAdmin.role = [[TLChannelParticipantRole$channelRoleEditor alloc] init];
            break;
    }
    
    return [[[TGTelegramNetworking instance] requestSignal:editAdmin] mapToSignal:^SSignal *(__unused id result) {
        return [SSignal complete];
    }];
}

+ (SSignal *)channelRole:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user {
    TLRPCchannels_getParticipant$channels_getParticipant *getParticipant = [[TLRPCchannels_getParticipant$channels_getParticipant alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    getParticipant.channel = inputChannel;
    
    TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
    inputUser.user_id = user.uid;
    inputUser.access_hash = user.phoneNumberHash;
    getParticipant.user_id = inputUser;
    
    return [[[[TGTelegramNetworking instance] requestSignal:getParticipant] map:^id(TLchannels_ChannelParticipant *result) {
        TLChannelParticipant *participant = result.participant;
            TGChannelRole role = TGChannelRoleMember;
            int32_t timestamp = 0;
            if ([participant isKindOfClass:[TLChannelParticipant$channelParticipant class]]) {
                role = TGChannelRoleMember;
                timestamp = ((TLChannelParticipant$channelParticipant *)participant).date;
            } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantCreator class]]) {
                role = TGChannelRoleCreator;
                timestamp = 0;
            } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantEditor class]]) {
                role = TGChannelRolePublisher;
                timestamp = ((TLChannelParticipant$channelParticipantEditor *)participant).date;
            } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantModerator class]]) {
                role = TGChannelRoleModerator;
                timestamp = ((TLChannelParticipant$channelParticipantModerator *)participant).date;
            } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantKicked class]]) {
                role = TGChannelRoleMember;
                timestamp = ((TLChannelParticipant$channelParticipantKicked *)participant).date;
            }
        
            return [[TGCachedConversationMember alloc] initWithUid:user.uid role:role timestamp:timestamp];
    }] catch:^SSignal *(__unused id error) {
        return [SSignal single:nil];
    }];
}

+ (SSignal *)channelMembers:(int64_t)peerId accessHash:(int64_t)accessHash filter:(TLChannelParticipantsFilter *)filter offset:(NSUInteger)offset count:(NSUInteger)count {
    TLRPCchannels_getParticipants$channels_getParticipants *getParticipants = [[TLRPCchannels_getParticipants$channels_getParticipants alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    getParticipants.channel = inputChannel;
    getParticipants.filter = filter;
    getParticipants.offset = (int32_t)offset;
    getParticipants.limit = (int32_t)count;
    return [[[TGTelegramNetworking instance] requestSignal:getParticipants] mapToSignal:^SSignal *(TLchannels_ChannelParticipants *result) {
        [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
        
        NSMutableArray *users = [[NSMutableArray alloc] init];
        NSMutableDictionary *memberDatas = [[NSMutableDictionary alloc] init];
        
        for (TLChannelParticipant *participant in result.participants) {
            TGUser *user = [TGDatabaseInstance() loadUser:participant.user_id];
            if (user != nil) {
                TGChannelRole role = TGChannelRoleMember;
                int32_t timestamp = 0;
                if ([participant isKindOfClass:[TLChannelParticipant$channelParticipant class]]) {
                    role = TGChannelRoleMember;
                    timestamp = ((TLChannelParticipant$channelParticipant *)participant).date;
                } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantCreator class]]) {
                    role = TGChannelRoleCreator;
                    timestamp = 0;
                } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantEditor class]]) {
                    role = TGChannelRolePublisher;
                    timestamp = ((TLChannelParticipant$channelParticipantEditor *)participant).date;
                } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantModerator class]]) {
                    role = TGChannelRoleModerator;
                    timestamp = ((TLChannelParticipant$channelParticipantModerator *)participant).date;
                } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantKicked class]]) {
                    role = TGChannelRoleMember;
                    timestamp = ((TLChannelParticipant$channelParticipantKicked *)participant).date;
                }
                
                memberDatas[@(user.uid)] = [[TGCachedConversationMember alloc] initWithUid:user.uid role:role timestamp:timestamp];
                [users addObject:user];
            }
        }
        
        return [SSignal single:@{@"memberDatas": memberDatas, @"users": users}];
    }];
}

+ (SSignal *)channelBlacklistMembers:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count {
    return [self channelMembers:peerId accessHash:accessHash filter:[[TLChannelParticipantsFilter$channelParticipantsKicked alloc] init] offset:offset count:count];
}

+ (SSignal *)channelMembers:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count {
    return [self channelMembers:peerId accessHash:accessHash filter:[[TLChannelParticipantsFilter$channelParticipantsRecent alloc] init] offset:offset count:count];
}

+ (SSignal *)channelAdmins:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count {
    return [self channelMembers:peerId accessHash:accessHash filter:[[TLChannelParticipantsFilter$channelParticipantsAdmins alloc] init] offset:offset count:count];
}

+ (SSignal *)channelInviterUser:(int64_t)peerId accessHash:(int64_t)accessHash {
    TLRPCchannels_getParticipant$channels_getParticipant *getParticipant = [[TLRPCchannels_getParticipant$channels_getParticipant alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    getParticipant.channel = inputChannel;
    getParticipant.user_id = [[TLInputUser$inputUserSelf alloc] init];
    
    return [[[[TGTelegramNetworking instance] requestSignal:getParticipant] map:^id(TLchannels_ChannelParticipant *result) {
        [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
        
        TLChannelParticipant *participant = result.participant;
        int32_t inviterUid = 0;
        int32_t timestamp = 0;
        if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantSelf class]]) {
            inviterUid = ((TLChannelParticipant$channelParticipantSelf *)participant).inviter_id;
            timestamp = ((TLChannelParticipant$channelParticipantSelf *)participant).date;
        }
        
        return @{@"userId": @(inviterUid), @"timestamp": @(timestamp)};
    }] catch:^SSignal *(__unused id error) {
        return [SSignal single:nil];
    }];
}

+ (SSignal *)deleteChannel:(int64_t)peerId accessHash:(int64_t)accessHash {
    TLRPCchannels_deleteChannel$channels_deleteChannel *deleteChannel = [[TLRPCchannels_deleteChannel$channels_deleteChannel alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    deleteChannel.channel = inputChannel;
    
    return [[TGTelegramNetworking instance] requestSignal:deleteChannel];
}

+ (SSignal *)canMakePublicChannels {
    return [[[self checkChannelUsername:0 accessHash:0 username:@""] catch:^SSignal *(__unused id error) {
        return [SSignal single:@false];
    }] then:[SSignal single:@true]];
}

@end
