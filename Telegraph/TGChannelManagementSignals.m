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

#import "TGBotSignals.h"

#import "TLRPCmessages_editMessage.h"

#import "TLUpdate$updateChannelTooLong.h"

#import "TGChannelBannedRights.h"

#import "TLRPCChannels_getAdminLog.h"

@implementation TGChannelManagementSignals

+ (SSignal *)makeChannelWithTitle:(NSString *)title about:(NSString *)about group:(bool)group
{
    TLRPCchannels_createChannel$channels_createChannel *createChannel = [[TLRPCchannels_createChannel$channels_createChannel alloc] init];
    createChannel.title = title;
    if (group) {
        createChannel.flags = (1 << 1);
    } else {
        createChannel.flags = (1 << 0);
    }
    createChannel.about = about;
    return [[[TGTelegramNetworking instance] requestSignal:createChannel continueOnServerErrors:false failOnFloodErrors:true] mapToSignal:^SSignal *(TLUpdates *updates) {
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

+ (SSignal *)preloadChannelTail:(int64_t)peerId accessHash:(int64_t)accessHash important:(bool)important {
    TGMessageHole *hole = [[TGMessageHole alloc] initWithMinId:1 minTimestamp:1 maxId:INT32_MAX maxTimestamp:INT32_MAX];
    
    [TGDatabaseInstance() addMessagesToChannel:peerId messages:nil deleteMessages:nil unimportantGroups:nil addedHoles:@[hole] removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:false changedMessages:nil];
    
    return [[self channelMessageHoleForPeerId:peerId accessHash:accessHash hole:hole direction:TGChannelHistoryHoleDirectionEarlier important:important] mapToSignal:^SSignal *(NSDictionary *dict) {
        NSArray *removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
        NSArray *removedUnimportantHoles = nil;
        
        return [[TGDatabaseInstance() modify:^id {
            [TGDatabaseInstance() addMessagesToChannel:peerId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:important keepUnreadCounters:false changedMessages:nil];
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
            signal = [self preloadChannelTail:conversation.conversationId accessHash:conversation.accessHash important:!conversation.isChannelGroup];
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

+ (SSignal *)messagesWithDownloadedReplyMessages:(int64_t)peerId accessHash:(int64_t)accessHash messages:(NSArray *)messages {
    return [SSignal defer:^SSignal *{
        NSMutableDictionary *addedMessageIdToMessage = [[NSMutableDictionary alloc] init];
        for (TGMessage *message in messages) {
            addedMessageIdToMessage[@(message.mid)] = message;
        }
        
        NSMutableArray *downloadMessages = [[NSMutableArray alloc] init];
        
        for (TGMessage *message in messages) {
            if (message.mediaAttachments.count != 0) {
                for (id attachment in message.mediaAttachments) {
                    if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]]) {
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
            return [[TGDownloadMessagesSignal downloadMessages:downloadMessages] mapToSignal:^SSignal *(NSArray *downloadedMessages) {
                for (TGMessage *message in downloadedMessages) {
                    addedMessageIdToMessage[@(message.mid)] = message;
                }
                
                for (TGMessage *message in messages) {
                    if (message.mediaAttachments.count != 0) {
                        for (id attachment in message.mediaAttachments) {
                            if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]]) {
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
                
                return [SSignal single:messages];
            }];
        } else {
            return [SSignal single:messages];
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
            
            return [[self messagesWithDownloadedReplyMessages:peerId accessHash:accessHash messages:parsedMessages] mapToSignal:^SSignal *(NSArray *parsedMessages) {
                TGMessageHole *closedHole = [[TGMessageHole alloc] initWithMinId:minParsedId minTimestamp:minParsedDate maxId:maxParsedId maxTimestamp:maxParsedDate];
                
                return [SSignal single:@{@"messages": parsedMessages, @"hole": closedHole}];
            }];
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
            
            return [[self messagesWithDownloadedReplyMessages:peerId accessHash:accessHash messages:parsedMessages] mapToSignal:^SSignal *(NSArray *parsedMessages) {
                TGMessageHole *closedHole = [[TGMessageHole alloc] initWithMinId:minParsedId minTimestamp:minParsedDate maxId:maxParsedId maxTimestamp:maxParsedDate];
                
                return [SSignal single:@{@"messages": parsedMessages, @"hole": closedHole}];
            }];
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
                    
                    [TGDatabaseInstance() addMessagesToChannel:peerId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:false changedMessages:nil];
                    
                    return [SSignal complete];
                }] switchToLatest];
            }];
            
            return [[[TGDatabaseInstance() modifyChannel:peerId block:^id(int32_t pts) {
                if (pts <= 1) {
                    return [[self preloadChannelTail:peerId accessHash:conversation.accessHash important:!conversation.isChannelGroup] then:historySignal];
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
                    
                    [TGDatabaseInstance() addMessagesToChannel:peerId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:false changedMessages:nil];
                    
                    return [SSignal complete];
                }] switchToLatest];
            }];
            
            return [[[TGDatabaseInstance() modifyChannel:peerId block:^id(int32_t pts) {
                if (pts <= 1) {
                    return [[self preloadChannelTail:peerId accessHash:conversation.accessHash important:!conversation.isChannelGroup] then:historySignal];
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
        if (TGPeerIdIsChannel(queued.peerId)) {
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
        } else if (TGPeerIdIsSecretChat(queued.peerId)) {
            NSAssert(false, @"readChannelMessages TGPeerIdIsSecretChat == true");
            return [SSignal complete];
        } else {
            TLRPCmessages_readHistory$messages_readHistory *readHistory = [[TLRPCmessages_readHistory$messages_readHistory alloc] init];
            readHistory.peer = [TGTelegraphInstance createInputPeerForConversation:queued.peerId accessHash:queued.accessHash];
            readHistory.max_id = queued.maxId;
            
            return [[[[TGTelegramNetworking instance] requestSignal:readHistory] mapToSignal:^SSignal *(__unused NSNumber *result) {
                [TGDatabaseInstance() confirmChannelHistoryRead:queued];
                return [SSignal complete];
            }] catch:^SSignal *(__unused id error) {
                [TGDatabaseInstance() confirmChannelHistoryRead:queued];
                return [SSignal complete];
            }];
        }
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
            
            TGConversationMigrationData *migrationData = nil;
            if (channelFull.migrated_from_chat_id != 0) {
                migrationData = [[TGConversationMigrationData alloc] initWithPeerId:TGPeerIdFromGroupId(channelFull.migrated_from_chat_id) maxMessageId:channelFull.migrated_from_max_id];
            }
            
            NSMutableDictionary *botInfos = nil;
            if (channelFull.bot_info != nil) {
                botInfos = [[NSMutableDictionary alloc] init];
                
                for (TLBotInfo *botInfo in channelFull.bot_info) {
                    if ([botInfo isKindOfClass:[TLBotInfo$botInfo class]]) {
                        TGBotInfo *parsedBotInfo = [TGBotSignals botInfoForInfo:botInfo];
                        if (parsedBotInfo != nil) {
                            botInfos[@(((TLBotInfo$botInfo *)botInfo).user_id)] = parsedBotInfo;
                        }
                    }
                }
            }
            
            return [[TGDatabaseInstance() modifyChannel:peerId block:^id(__unused int32_t pts) {
                if (conversation != nil) {
                    [TGDatabaseInstance() updateChannels:@[conversation]];
                }
                [TGDatabaseInstance() updateChannelAbout:peerId about:channelFull.about];
                [TGDatabaseInstance() updateChannelPinnedMessageId:peerId pinnedMessageId:channelFull.pinned_msg_id hidden:nil];
                
                if (updateUnread) {
                    [TGDatabaseInstance() updateChannelReadState:peerId maxReadId:channelFull.read_inbox_max_id unreadImportantCount:channelFull.unread_count unreadUnimportantCount:0];
                }
                
                [TGDatabaseInstance() updateChannelCachedData:peerId block:^TGCachedConversationData *(TGCachedConversationData *currentData) {
                    if (currentData == nil) {
                        currentData = [[TGCachedConversationData alloc] init];
                    }
                    
                    currentData = [currentData updatePrivateLink:privateLink];
                    currentData = [currentData updateMigrationData:migrationData];
                    currentData = [currentData updateBotInfos:botInfos];
                    
                    return [currentData updateManagementCount:channelFull.admins_count blacklistCount:channelFull.kicked_count bannedCount:channelFull.banned_count memberCount:channelFull.participants_count];
                }];
                
                TLPeerNotifySettings *settings = channelFull.notify_settings;
                
                int peerSoundId = 0;
                int peerMuteUntil = 0;
                bool peerPreviewText = true;
                bool messagesMuted = false;
                
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
                    
                    peerPreviewText = concreteSettings.flags & (1 << 0);
                    messagesMuted = concreteSettings.flags & (1 << 1);
                }
                
                [TGDatabaseInstance() storePeerNotificationSettings:peerId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:^(bool changed)
                 {
                     if (changed)
                     {
                         [ActionStageInstance() dispatchOnStageQueue:^
                          {
                              NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:peerMuteUntil], @"muteUntil", [NSNumber numberWithInt:peerSoundId], @"soundId", [[NSNumber alloc] initWithBool:peerPreviewText], @"previewText", [[NSNumber alloc] initWithBool:messagesMuted], @"messagesMuted", nil];
                              
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

+ (SSignal *)toggleChannelEverybodyCanInviteMembers:(int64_t)peerId accessHash:(int64_t)accessHash enabled:(bool)enabled {
    TLRPCchannels_toggleInvites$channels_toggleInvites *toggleChannelInvites = [[TLRPCchannels_toggleInvites$channels_toggleInvites alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    toggleChannelInvites.channel = inputChannel;
    toggleChannelInvites.enabled = enabled;
    return [[[TGTelegramNetworking instance] requestSignal:toggleChannelInvites] mapToSignal:^SSignal *(TLUpdates *updates) {
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

+ (SSignal *)updateChannelAdminRights:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user rights:(TGChannelAdminRights *)rights {
    TLRPCchannels_editAdmin$channels_editAdmin *editAdmin = [[TLRPCchannels_editAdmin$channels_editAdmin alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    editAdmin.channel = inputChannel;
    TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
    inputUser.user_id = user.uid;
    inputUser.access_hash = user.phoneNumberHash;
    editAdmin.user_id = inputUser;
    editAdmin.admin_rights = [rights tlRights];
    
    return [[[TGTelegramNetworking instance] requestSignal:editAdmin] mapToSignal:^SSignal *(TLUpdates *updates) {
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        return [SSignal complete];
    }];
}

+ (SSignal *)updateChannelBannedRightsAndGetMembership:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user rights:(TGChannelBannedRights *)rights {
    TLRPCchannels_editBanned$channels_editBanned *editBanned = [[TLRPCchannels_editBanned$channels_editBanned alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    editBanned.channel = inputChannel;
    TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
    inputUser.user_id = user.uid;
    inputUser.access_hash = user.phoneNumberHash;
    editBanned.user_id = inputUser;
    editBanned.banned_rights = [rights tlRights];
    
    SSignal *update = [[[[TGTelegramNetworking instance] requestSignal:editBanned] mapToSignal:^SSignal *(TLUpdates *updates) {
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        return [SSignal complete];
    }] then:[self channelRole:peerId accessHash:accessHash user:user]];
    
    return update;
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
        int32_t timestamp = 0;
        bool isCreator = false;
        TGChannelAdminRights *adminRights = nil;
        TGChannelBannedRights *bannedRights = nil;
        int32_t inviterId = 0;
        int32_t adminInviterId = 0;
        int32_t kickedById = 0;
        bool adminCanManage = false;
        
        if ([participant isKindOfClass:[TLChannelParticipant$channelParticipant class]]) {
            timestamp = ((TLChannelParticipant$channelParticipant *)participant).date;
        } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantCreator class]]) {
            isCreator = true;
            timestamp = 0;
        } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantAdmin class]]) {
            adminRights = [[TGChannelAdminRights alloc] initWithTL:((TLChannelParticipant$channelParticipantAdmin *)participant).admin_rights];
            inviterId = ((TLChannelParticipant$channelParticipantAdmin *)participant).inviter_id;
            timestamp = ((TLChannelParticipant$channelParticipantAdmin *)participant).date;
            adminInviterId = ((TLChannelParticipant$channelParticipantAdmin *)participant).promoted_by;
            adminCanManage = ((TLChannelParticipant$channelParticipantAdmin *)participant).flags & (1 << 0);
        } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantBanned class]]) {
            bannedRights = [[TGChannelBannedRights alloc] initWithTL:((TLChannelParticipant$channelParticipantBanned *)participant).banned_rights];
            kickedById = ((TLChannelParticipant$channelParticipantBanned *)participant).kicked_by;
            timestamp = ((TLChannelParticipant$channelParticipantBanned *)participant).date;
        }
        
        return [[TGCachedConversationMember alloc] initWithUid:user.uid isCreator:isCreator adminRights:adminRights bannedRights:bannedRights timestamp:timestamp inviterId:inviterId adminInviterId:adminInviterId kickedById:kickedById adminCanManage:adminCanManage];
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
                int32_t timestamp = 0;
                bool isCreator = false;
                TGChannelAdminRights *adminRights = nil;
                TGChannelBannedRights *bannedRights = nil;
                int32_t inviterId = 0;
                int32_t adminInviterId = 0;
                int32_t kickedById = 0;
                bool adminCanManage = false;
                
                if ([participant isKindOfClass:[TLChannelParticipant$channelParticipant class]]) {
                    timestamp = ((TLChannelParticipant$channelParticipant *)participant).date;
                } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantCreator class]]) {
                    isCreator = true;
                    timestamp = 0;
                } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantAdmin class]]) {
                    adminRights = [[TGChannelAdminRights alloc] initWithTL:((TLChannelParticipant$channelParticipantAdmin *)participant).admin_rights];
                    inviterId = ((TLChannelParticipant$channelParticipantAdmin *)participant).inviter_id;
                    timestamp = ((TLChannelParticipant$channelParticipantAdmin *)participant).date;
                    adminInviterId = ((TLChannelParticipant$channelParticipantAdmin *)participant).promoted_by;
                    adminCanManage = ((TLChannelParticipant$channelParticipantAdmin *)participant).flags & (1 << 0);
                } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantBanned class]]) {
                    bannedRights = [[TGChannelBannedRights alloc] initWithTL:((TLChannelParticipant$channelParticipantBanned *)participant).banned_rights];
                    timestamp = ((TLChannelParticipant$channelParticipantBanned *)participant).date;
                    kickedById = ((TLChannelParticipant$channelParticipantBanned *)participant).kicked_by;
                } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantSelf class]]) {
                    timestamp = ((TLChannelParticipant$channelParticipantSelf *)participant).date;
                    inviterId = ((TLChannelParticipant$channelParticipantSelf *)participant).inviter_id;
                }
                
                memberDatas[@(user.uid)] = [[TGCachedConversationMember alloc] initWithUid:user.uid isCreator:isCreator adminRights:adminRights bannedRights:bannedRights timestamp:timestamp inviterId:inviterId adminInviterId:adminInviterId kickedById:kickedById adminCanManage:adminCanManage];
                [users addObject:user];
            }
        }
        
        return [SSignal single:@{@"memberDatas": memberDatas, @"users": users, @"count": @(result.count)}];
    }];
}

+ (SSignal *)channelBlacklistMembers:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count {
    return [self channelMembers:peerId accessHash:accessHash filter:[[TLChannelParticipantsFilter$channelParticipantsKicked alloc] init] offset:offset count:count];
}

+ (SSignal *)channelBannedMembers:(int64_t)peerId accessHash:(int64_t)accessHash offset:(NSUInteger)offset count:(NSUInteger)count {
    return [self channelMembers:peerId accessHash:accessHash filter:[[TLChannelParticipantsFilter$channelParticipantsBanned alloc] init] offset:offset count:count];
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
    
    SSignal *cachedDataSignal = [[[TGDatabaseInstance() channelCachedData:peerId] take:1] mapToSignal:^SSignal *(TGCachedConversationData *cachedData) {
        if (cachedData == nil || true) {
            return [[[TGChannelManagementSignals updateChannelExtendedInfo:peerId accessHash:accessHash updateUnread:false] mapToSignal:^SSignal *(__unused id next) {
                return [SSignal complete];
            }] then:[[TGDatabaseInstance() channelCachedData:peerId] take:1]];
        } else {
            return [SSignal single:cachedData];
        }
    }];
    
    SSignal *participantSignal = [[TGTelegramNetworking instance] requestSignal:getParticipant];
    
    return [[[SSignal combineSignals:@[participantSignal, cachedDataSignal]] map:^id(NSArray *combinedData) {
        TLchannels_ChannelParticipant *result = combinedData[0];
        TGCachedConversationData *cachedData = combinedData[1];
        
        [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
        
        TLChannelParticipant *participant = result.participant;
        int32_t inviterUid = 0;
        int32_t timestamp = 0;
        
        if (cachedData.migrationData == nil && [participant isKindOfClass:[TLChannelParticipant$channelParticipantSelf class]]) {
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

+ (SSignal *)updateChannelSignaturesEnabled:(int64_t)peerId accessHash:(int64_t)accessHash enabled:(bool)enabled {
    TLRPCchannels_toggleSignatures$channels_toggleSignatures *toggleSignatures = [[TLRPCchannels_toggleSignatures$channels_toggleSignatures alloc] init];
    
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    toggleSignatures.channel = inputChannel;
    toggleSignatures.enabled = enabled;
    return [[[TGTelegramNetworking instance] requestSignal:toggleSignatures] mapToSignal:^SSignal *(TLUpdates *updates) {
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

+ (SSignal *)messageEditData:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId {
    TLRPCmessages_getMessageEditData$messages_getMessageEditData *getMessageEditData = [[TLRPCmessages_getMessageEditData$messages_getMessageEditData alloc] init];
    TLInputPeer$inputPeerChannel *inputPeerChannel = [[TLInputPeer$inputPeerChannel alloc] init];
    inputPeerChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputPeerChannel.access_hash = accessHash;
    getMessageEditData.peer = inputPeerChannel;
    getMessageEditData.n_id = messageId;
    return [[TGTelegramNetworking instance] requestSignal:getMessageEditData];
}

+ (SSignal *)updatePinnedMessage:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId notify:(bool)notify {
    TLRPCchannels_updatePinnedMessage$channels_updatePinnedMessage *updatePinnedMessage = [[TLRPCchannels_updatePinnedMessage$channels_updatePinnedMessage alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    updatePinnedMessage.channel = inputChannel;
    
    updatePinnedMessage.n_id = messageId;
    if (!notify) {
        updatePinnedMessage.flags |= 1 << 0;
    }
    
    return [[[TGTelegramNetworking instance] requestSignal:updatePinnedMessage] mapToSignal:^SSignal *(TLUpdates *updates) {
        id chat = updates.chats.firstObject;
        TGConversation *conversation = nil;
        if (chat != nil) {
            conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
            if (conversation.conversationId == peerId) {
                [TGDatabaseInstance() updateChannels:@[conversation]];
            }
        }
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        [TGDatabaseInstance() updateChannelPinnedMessageId:peerId pinnedMessageId:messageId hidden:nil];
        
        return [SSignal complete];
    }];
}

+ (SSignal *)removeAllUserMessages:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user {
    TLRPCchannels_deleteUserHistory$channels_deleteUserHistory *deleteUserHistory = [[TLRPCchannels_deleteUserHistory$channels_deleteUserHistory alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    deleteUserHistory.channel = inputChannel;
    
    TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
    inputUser.user_id = user.uid;
    inputUser.access_hash = user.phoneNumberHash;
    deleteUserHistory.user_id = inputUser;
    
    return [[[TGTelegramNetworking instance] requestSignal:deleteUserHistory] mapToSignal:^SSignal *(TLmessages_AffectedHistory *affectedHistory) {
        return [[TGDatabaseInstance() modify:^id{
            [TGDatabaseInstance() addMessagesToChannelAndDispatch:peerId messages:nil deletedMessages:nil holes:nil pts:affectedHistory.pts];
            return nil;
        }] then:[TGDatabaseInstance() deleteMessagesInChannel:peerId fromUserId:user.uid]];
    }];
}

+ (SSignal *)reportUserSpam:(int64_t)peerId accessHash:(int64_t)accessHash user:(TGUser *)user messageIds:(NSArray *)messageIds {
    TLRPCchannels_reportSpam$channels_reportSpam *reportSpam = [[TLRPCchannels_reportSpam$channels_reportSpam alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    reportSpam.channel = inputChannel;
    
    TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
    inputUser.user_id = user.uid;
    inputUser.access_hash = user.phoneNumberHash;
    reportSpam.user_id = inputUser;
    reportSpam.n_id = messageIds;
    
    return [[TGTelegramNetworking instance] requestSignal:reportSpam];
}

+ (SSignal *)resolveChannelWithUsername:(NSString *)username {
    TLRPCcontacts_resolveUsername$contacts_resolveUsername *resolveUsername = [[TLRPCcontacts_resolveUsername$contacts_resolveUsername alloc] init];
    resolveUsername.username = username;

    return [[[TGTelegramNetworking instance] requestSignal:resolveUsername] mapToSignal:^SSignal *(TLcontacts_ResolvedPeer *resolvedPeer) {
        if ([resolvedPeer.peer isKindOfClass:[TLPeer$peerChannel class]] && resolvedPeer.chats.count != 0) {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:resolvedPeer.chats[0]];
            conversation.kind = TGConversationKindTemporaryChannel;
            return [[TGChannelManagementSignals addChannel:conversation] takeLast];
        }
        else
        {
            return [SSignal fail:nil];
        }
    }];
}

+ (SSignal *)channelAdminLogEvents:(int64_t)peerId accessHash:(int64_t)accessHash minEntryId:(int64_t)minEntryId count:(int32_t)count filter:(TGChannelEventFilter)filter searchQuery:(NSString *)searchQuery userIds:(NSArray *)userIds {
    TLRPCchannels_getAdminLog *getAdminLog = [[TLRPCchannels_getAdminLog alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    getAdminLog.channel = inputChannel;
    getAdminLog.max_id = minEntryId;
    
    int32_t filterFlags = 0;
    if (filter.join) {
        filterFlags |= (1 << 0);
    }
    if (filter.leave) {
        filterFlags |= (1 << 1);
    }
    if (filter.invite) {
        filterFlags |= (1 << 2);
    }
    if (filter.ban) {
        filterFlags |= (1 << 3);
    }
    if (filter.unban) {
        filterFlags |= (1 << 4);
    }
    if (filter.kick) {
        filterFlags |= (1 << 5);
    }
    if (filter.unkick) {
        filterFlags |= (1 << 6);
    }
    if (filter.promote) {
        filterFlags |= (1 << 7);
    }
    if (filter.demote) {
        filterFlags |= (1 << 8);
    }
    if (filter.info) {
        filterFlags |= (1 << 9);
    }
    if (filter.settings) {
        filterFlags |= (1 << 10);
    }
    if (filter.pinned) {
        filterFlags |= (1 << 11);
    }
    if (filter.edit) {
        filterFlags |= (1 << 12);
    }
    if (filter.del) {
        filterFlags |= (1 << 13);
    }
    
    getAdminLog.flags |= (1 << 0);
    
    TLChannelAdminLogEventsFilter$channelAdminLogEventsFilter *eventsFilter = [[TLChannelAdminLogEventsFilter$channelAdminLogEventsFilter alloc] init];
    eventsFilter.flags = filterFlags;
    getAdminLog.events_filter = eventsFilter;
    
    getAdminLog.q = searchQuery;
    
    if (userIds != nil) {
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for (NSNumber *userId in userIds) {
            TGUser *user = [TGDatabaseInstance() loadUser:[userId intValue]];
            if (user != nil) {
                TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
                inputUser.user_id = user.uid;
                inputUser.access_hash = user.phoneNumberHash;
                [users addObject:inputUser];
            }
        }
        
        getAdminLog.flags |= (1 << 1);
        getAdminLog.admins = users;
    }
    
    getAdminLog.limit = count;
    
    return [[[TGTelegramNetworking instance] requestSignal:getAdminLog] map:^id(TLchannels_AdminLogResults *results) {
        [TGUserDataRequestBuilder executeUserDataUpdate:results.users];
        NSMutableArray *entries = [[NSMutableArray alloc] init];
        for (TLChannelAdminLogEvent *event in results.events) {
            [entries addObject:[[TGChannelAdminLogEntry alloc] initWithTL:event]];
        }
        return entries;
    }];
}

+ (TGCachedConversationMember *)parseMember:(TLChannelParticipant *)participant {
    int32_t timestamp = 0;
    bool isCreator = false;
    TGChannelAdminRights *adminRights = nil;
    TGChannelBannedRights *bannedRights = nil;
    int32_t inviterId = 0;
    int32_t adminInviterId = 0;
    int32_t kickedById = 0;
    bool adminCanManage = false;
    
    if ([participant isKindOfClass:[TLChannelParticipant$channelParticipant class]]) {
        timestamp = ((TLChannelParticipant$channelParticipant *)participant).date;
    } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantCreator class]]) {
        isCreator = true;
        timestamp = 0;
    } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantAdmin class]]) {
        adminRights = [[TGChannelAdminRights alloc] initWithTL:((TLChannelParticipant$channelParticipantAdmin *)participant).admin_rights];
        inviterId = ((TLChannelParticipant$channelParticipantAdmin *)participant).inviter_id;
        timestamp = ((TLChannelParticipant$channelParticipantAdmin *)participant).date;
        adminInviterId = ((TLChannelParticipant$channelParticipantAdmin *)participant).promoted_by;
        adminCanManage = ((TLChannelParticipant$channelParticipantAdmin *)participant).flags & (1 << 0);
    } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantBanned class]]) {
        bannedRights = [[TGChannelBannedRights alloc] initWithTL:((TLChannelParticipant$channelParticipantBanned *)participant).banned_rights];
        timestamp = ((TLChannelParticipant$channelParticipantBanned *)participant).date;
        kickedById = ((TLChannelParticipant$channelParticipantBanned *)participant).kicked_by;
    } else if ([participant isKindOfClass:[TLChannelParticipant$channelParticipantSelf class]]) {
        timestamp = ((TLChannelParticipant$channelParticipantSelf *)participant).date;
        inviterId = ((TLChannelParticipant$channelParticipantSelf *)participant).inviter_id;
    }
    
    return [[TGCachedConversationMember alloc] initWithUid:participant.user_id isCreator:isCreator adminRights:adminRights bannedRights:bannedRights timestamp:timestamp inviterId:inviterId adminInviterId:adminInviterId kickedById:kickedById adminCanManage:adminCanManage];
}

@end
