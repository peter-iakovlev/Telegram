#import "TGChannelStateSignals.h"

#import "TGDatabase.h"
#import "TGPeerIdAdapter.h"
#import "TGTelegramNetworking.h"

#import "TL/TLMetaScheme.h"
#import "TLUpdates_ChannelDifference_manual.h"

#import "TGConversation+Telegraph.h"
#import "TGMessage+Telegraph.h"
#import "TGUserDataRequestBuilder.h"
#import "TGUpdateStateRequestBuilder.h"
#import "TGTelegraph.h"

#import "TGDownloadMessagesSignal.h"
#import "TGConversationAddMessagesActor.h"

#import "TGChannelManagementSignals.h"

#import "TGStringUtils.h"

#import "TGModernSendCommonMessageActor.h"

#import "TGPreparedMessage.h"

#import "TLUpdate$updateChannelTooLong.h"

static dispatch_block_t recursiveBlock(void (^block)(dispatch_block_t recurse)) {
    return ^ {
        block(recursiveBlock(block));
    };
}

@interface TGManagedChannelState : NSObject {
    int64_t _peerId;
    
    SPipe *_updatesPipe;
    SPipe *_pollsPipe;
    id<SDisposable> _disposable;
    SAtomic *_timer;
    
    SAtomic *_keepPollingBag;
    id<SDisposable> _inviterId;
}

@end

@implementation TGManagedChannelState

- (instancetype)initWithPeerId:(int64_t)peerId {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        
        _updatesPipe = [[SPipe alloc] init];
        _pollsPipe = [[SPipe alloc] init];
        
        _keepPollingBag = [[SAtomic alloc] initWithValue:[[SBag alloc] init]];
        
        __weak TGManagedChannelState *weakSelf = self;
        
        SSignal *pollsSignal = [_pollsPipe.signalProducer() mapToQueue:^SSignal *(__unused id tick) {
            __strong TGManagedChannelState *strongSelf = weakSelf;
            if (strongSelf != nil) {
                return [[TGChannelStateSignals pollOnce:peerId] mapToSignal:^SSignal *(NSNumber *nextTimeout) {
                    __strong TGManagedChannelState *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        STimer *nextTimer = [[STimer alloc] initWithTimeout:[nextTimeout doubleValue] repeat:false completion:^{
                            __strong TGManagedChannelState *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                if ([[strongSelf->_keepPollingBag with:^id(SBag *bag) {
                                    return @(![bag isEmpty]);
                                }] boolValue]) {
                                    strongSelf->_pollsPipe.sink(@true);
                                }
                            }
                        } queue:[SQueue concurrentDefaultQueue]];
                        STimer *previousTimer = [strongSelf->_timer swap:nextTimer];
                        [previousTimer invalidate];
                        [nextTimer start];
                    }
                    return [SSignal complete];
                }];
            } else {
                return [SSignal complete];
            }
        }];
        
        SSignal *updatesSignal = [_updatesPipe.signalProducer() mapToSignal:^SSignal *(NSArray *updates) {
            __strong TGManagedChannelState *strongSelf = weakSelf;
            if (strongSelf != nil) {
                return [[strongSelf applyUpdates:updates] catch:^SSignal *(__unused id error) {
                    __strong TGManagedChannelState *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        strongSelf->_pollsPipe.sink(@true);
                    }
                    
                    return [SSignal complete];
                }];
            } else {
                return [SSignal complete];
            }
        }];
        SSignal *process = [[SSignal mergeSignals:@[updatesSignal, pollsSignal]] queue];
        
        _disposable = [process startWithNext:nil];
        
        _inviterId = [[[[[TGDatabaseInstance() existingChannel:peerId] filter:^bool(TGConversation *conversation) {
            return conversation.kind == TGConversationKindPersistentChannel;
        }] take:1] mapToSignal:^SSignal *(TGConversation *conversation) {
            return [TGChannelStateSignals addInviterMessage:peerId accessHash:conversation.accessHash];
        }] startWithNext:nil];
    }
    return self;
}

- (void)dealloc {
    [_disposable dispose];
    STimer *timer = [_timer swap:nil];
    [timer invalidate];
    [_inviterId dispose];
}

+ (SSignal *)_channelDifference:(int64_t)peerId accessHash:(int64_t)accessHash pts:(int32_t)pts {
    int32_t limit = 10;
    
#ifdef DEBUG
    limit = 2;
#endif
    
    TLRPCupdates_getChannelDifference$updates_getChannelDifference *getChannelDifference = [[TLRPCupdates_getChannelDifference$updates_getChannelDifference alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    getChannelDifference.channel = inputChannel;
    getChannelDifference.filter = [[TLChannelMessagesFilter$channelMessagesFilterEmpty alloc] init];
    getChannelDifference.pts = MAX(pts, 1);
    getChannelDifference.limit = limit;
    
    return [[[TGTelegramNetworking instance] requestSignal:getChannelDifference] catch:^SSignal *(__unused id error) {
        TLUpdates_ChannelDifference$empty *empty = [[TLUpdates_ChannelDifference$empty alloc] init];
        empty.pts = MAX(pts, 1);
        empty.flags = 1;
        empty.timeout = 5;
        return [SSignal single:empty];
    }];
}

- (SSignal *)applyUpdates:(NSArray *)updates {
    int64_t peerId = _peerId;
    
    return [[[TGDatabaseInstance() existingChannel:peerId] take:1] mapToSignal:^SSignal *(TGConversation *conversation) {
        NSMutableArray *ptsUpdates = [[NSMutableArray alloc] init];
        NSMutableSet *skipMessageIds = [[NSMutableSet alloc] init];
        int32_t maxReadId = 0;
        int32_t maxReadOutgoingId = 0;
        NSNumber *pinnedMessageId = nil;
        __block bool failed = false;
        bool hasMessageIdUpdates = false;
        
        for (id update in updates) {
            if ([update isKindOfClass:[TLUpdate$updateNewChannelMessage class]]) {
                [ptsUpdates addObject:update];
            } else if ([update isKindOfClass:[TLUpdate$updateEditChannelMessage class]]) {
                [ptsUpdates addObject:update];
            } else if ([update isKindOfClass:[TLUpdate$updateReadChannelInbox class]]) {
                maxReadId = MAX(maxReadId, ((TLUpdate$updateReadChannelInbox *)update).max_id);
            } else if ([update isKindOfClass:[TLUpdate$updateReadChannelOutbox class]]) {
                maxReadOutgoingId = MAX(maxReadOutgoingId, ((TLUpdate$updateReadChannelOutbox *)update).max_id);
            } else if ([update isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]]) {
                [ptsUpdates addObject:update];
            } else if ([update isKindOfClass:[TLUpdate$updateChannelWebPage class]]) {
                [ptsUpdates addObject:update];
            } else if ([update isKindOfClass:[TLUpdate$updateChannelTooLong class]]) {
                failed = true;
            } else if ([update isKindOfClass:[TLUpdate$updateMessageID class]]) {
                hasMessageIdUpdates = true;
            } else if ([update isKindOfClass:[TLUpdate$updateChannelPinnedMessage class]]) {
                pinnedMessageId = @(((TLUpdate$updateChannelPinnedMessage *)update).n_id);
            }
        }
        
        SSignal *removeMessagesInProgressSignal = nil;
        
        if (hasMessageIdUpdates) {
            NSMutableDictionary *randomIdToMessageId = [[NSMutableDictionary alloc] init];
            
            for (id update in updates) {
                if ([update isKindOfClass:[TLUpdate$updateMessageID class]]) {
                    int64_t randomId = ((TLUpdate$updateMessageID *)update).random_id;
                    int32_t messageId = ((TLUpdate$updateMessageID *)update).n_id;
                    randomIdToMessageId[@(randomId)] = @(messageId);
                }
            }
            
            removeMessagesInProgressSignal = [[SSignal defer:^SSignal *{
                for (TGModernSendCommonMessageActor *actor in [ActionStageInstance() executingActorsWithPathPrefix:[[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%" PRId64 ")/", peerId]]) {
                    if (actor.preparedMessage.randomId != 0) {
                        NSNumber *nMessageId = randomIdToMessageId[@(actor.preparedMessage.randomId)];
                        if (nMessageId != nil) {
                            [skipMessageIds addObject:nMessageId];
                        }
                    }
                }
                
                return [SSignal complete];
            }] startOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]];
        } else {
            removeMessagesInProgressSignal = [SSignal complete];
        }
        
        return [removeMessagesInProgressSignal then:[SSignal defer:^SSignal *{
            int32_t updatedPts = conversation.pts;
            
            [ptsUpdates sortUsingComparator:^NSComparisonResult(id lhs, id rhs) {
                int32_t lhsPts = 0;
                int32_t rhsPts = 0;
                if ([lhs isKindOfClass:[TLUpdate$updateNewChannelMessage class]]) {
                    lhsPts = ((TLUpdate$updateNewChannelMessage *)lhs).pts;
                } else if ([lhs isKindOfClass:[TLUpdate$updateEditChannelMessage class]]) {
                    lhsPts = ((TLUpdate$updateEditChannelMessage *)lhs).pts;
                } else if ([lhs isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]]) {
                    lhsPts = ((TLUpdate$updateDeleteChannelMessages *)lhs).pts;
                } else if ([lhs isKindOfClass:[TLUpdate$updateChannelWebPage class]]) {
                    lhsPts = ((TLUpdate$updateChannelWebPage *)lhs).pts;
                }
                if ([rhs isKindOfClass:[TLUpdate$updateNewChannelMessage class]]) {
                    rhsPts = ((TLUpdate$updateNewChannelMessage *)rhs).pts;
                }  else if ([rhs isKindOfClass:[TLUpdate$updateEditChannelMessage class]]) {
                    rhsPts = ((TLUpdate$updateEditChannelMessage *)rhs).pts;
                } else if ([rhs isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]]) {
                    rhsPts = ((TLUpdate$updateDeleteChannelMessages *)rhs).pts;
                } else if ([rhs isKindOfClass:[TLUpdate$updateChannelWebPage class]]) {
                    rhsPts = ((TLUpdate$updateChannelWebPage *)lhs).pts;
                }
                return lhsPts < rhsPts ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            NSMutableArray *addedMessages = [[NSMutableArray alloc] init];
            NSMutableArray *updatedMessages = [[NSMutableArray alloc] init];
            NSMutableArray *deletedMessageIds = [[NSMutableArray alloc] init];
            
            for (id update in ptsUpdates) {
                if ([update isKindOfClass:[TLUpdate$updateNewChannelMessage class]]) {
                    TLUpdate$updateNewChannelMessage *updateNewChannelMessage = update;
                    TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:updateNewChannelMessage.message];
                    message.pts = updateNewChannelMessage.pts;
                    
                    if (updateNewChannelMessage.pts <= updatedPts) {
                        continue;
                    }
                    else if (updatedPts + updateNewChannelMessage.pts_count == updateNewChannelMessage.pts) {
                        if (message.mid != 0) {
                            if ([skipMessageIds containsObject:@(message.mid)]) {
                                TGLog(@"(Channel State %lld Skipped message %d", (long long)peerId, message.mid);
                            } else {
                                [addedMessages addObject:message];
                            }
                        }
                        updatedPts = updateNewChannelMessage.pts;
                    } else {
                        failed = true;
                    }
                } else if ([update isKindOfClass:[TLUpdate$updateEditChannelMessage class]]) {
                    TLUpdate$updateEditChannelMessage *updateEditMessage = update;
                    TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:updateEditMessage.message];
                    message.pts = updateEditMessage.pts;
                    
                    if (updateEditMessage.pts <= updatedPts) {
                        continue;
                    }
                    else if (updatedPts + updateEditMessage.pts_count == updateEditMessage.pts) {
                        if (message.mid != 0) {
                            if ([skipMessageIds containsObject:@(message.mid)]) {
                                TGLog(@"(Channel State %lld Skipped updated message %d", (long long)peerId, message.mid);
                            } else {
                                [updatedMessages addObject:message];
                            }
                        }
                        updatedPts = updateEditMessage.pts;
                    } else {
                        failed = true;
                    }
                } else if ([update isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]]) {
                    TLUpdate$updateDeleteChannelMessages *updateDeleteChannelMessages = update;
                    
                    if (updateDeleteChannelMessages.pts <= updatedPts) {
                        continue;
                    } else if (updatedPts + updateDeleteChannelMessages.pts_count == updateDeleteChannelMessages.pts) {
                        [deletedMessageIds addObjectsFromArray:updateDeleteChannelMessages.messages];
                        updatedPts = updateDeleteChannelMessages.pts;
                    } else {
                        failed = true;
                    }
                } else if ([update isKindOfClass:[TLUpdate$updateChannelWebPage class]]) {
                    TLUpdate$updateChannelWebPage *updateWebPage = (TLUpdate$updateChannelWebPage *)update;
                    
                    if (updateWebPage.pts <= updatedPts) {
                        continue;
                    } else if (updatedPts + updateWebPage.pts_count == updateWebPage.pts) {
                        updatedPts = updateWebPage.pts;
                    } else {
                        failed = true;
                    }
                }
            }
            
            NSMutableArray *downloadMessages = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *addedMessageIdToMessage = [[NSMutableDictionary alloc] init];
            for (TGMessage *message in addedMessages) {
                addedMessageIdToMessage[@(message.mid)] = message;
            }
            
            for (TGMessage *message in [addedMessages arrayByAddingObjectsFromArray:updatedMessages])
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
                                    [downloadMessages addObject:[[TGDownloadMessage alloc] initWithPeerId:conversation.conversationId accessHash:conversation.accessHash messageId:replyAttachment.replyMessageId]];
                                }
                            }
                        }
                    }
                }
            }
            
            
            if (downloadMessages.count != 0) {
                return [[TGDownloadMessagesSignal downloadMessages:downloadMessages] mapToSignal:^SSignal *(NSArray *messages) {
                    return [[TGDatabaseInstance() modify:^id {
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
                        
                        for (TGMessage *message in updatedMessages)
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

                        if (updatedMessages.count != 0) {
                            NSMutableArray<TGDatabaseUpdateMessage *> *messageUpdates = [[NSMutableArray alloc] init];
                            for (TGMessage *message in updatedMessages) {
                                [messageUpdates addObject:[[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:message.cid messageId:message.mid message:message dispatchEdited:true]];
                            }
                            
                            [TGDatabaseInstance() transactionUpdateMessages:messageUpdates updateConversationDatas:nil];
                        }
                        
                        if (updatedPts != conversation.pts) {
                            [TGDatabaseInstance() addMessagesToChannelAndDispatch:peerId messages:addedMessages deletedMessages:deletedMessageIds holes:nil pts:updatedPts];
                        }
                        
                        if (conversation.kind == TGConversationKindPersistentChannel && addedMessages.count != 0) {
                            [TGDatabaseInstance() _addedNewMessages:addedMessages];
                        }
                        
                        if (maxReadId != 0) {
                            [TGDatabaseInstance() updateChannelRead:peerId maxReadId:maxReadId maxReadOutgoingId:0];
                        }
                        
                        if (maxReadOutgoingId != 0) {
                            [TGDatabaseInstance() transactionApplyMaxOutgoingReadIds:@{@(peerId): @(maxReadOutgoingId)}];
                        }
                        
                        if (pinnedMessageId != nil) {
                            [TGDatabaseInstance() updateChannelPinnedMessageId:peerId pinnedMessageId:[pinnedMessageId intValue] hidden:nil];
                        }
                        
                        if (failed) {
                            return [SSignal fail:nil];
                        } else {
                            return [SSignal complete];
                        }
                    }] switchToLatest];
                }];
            } else {
                if (updatedMessages.count != 0) {
                    NSMutableArray<TGDatabaseUpdateMessage *> *messageUpdates = [[NSMutableArray alloc] init];
                    for (TGMessage *message in updatedMessages) {
                        [messageUpdates addObject:[[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:message.cid messageId:message.mid message:message dispatchEdited:true]];
                    }
                    
                    [TGDatabaseInstance() transactionUpdateMessages:messageUpdates updateConversationDatas:nil];
                }
                
                if (updatedPts != conversation.pts) {
                    [TGDatabaseInstance() addMessagesToChannelAndDispatch:peerId messages:addedMessages deletedMessages:deletedMessageIds holes:nil pts:updatedPts];
                }
                
                if (conversation.kind == TGConversationKindPersistentChannel && addedMessages.count != 0) {
                    [TGDatabaseInstance() _addedNewMessages:addedMessages];
                }
                
                if (maxReadId != 0) {
                    [TGDatabaseInstance() updateChannelRead:peerId maxReadId:maxReadId maxReadOutgoingId:0];
                }
                
                if (maxReadOutgoingId != 0) {
                    [TGDatabaseInstance() transactionApplyMaxOutgoingReadIds:@{@(peerId): @(maxReadOutgoingId)}];
                }
                
                if (pinnedMessageId != nil) {
                    [TGDatabaseInstance() updateChannelPinnedMessageId:peerId pinnedMessageId:[pinnedMessageId intValue] hidden:nil];
                }
                
                if (failed) {
                    return [SSignal fail:nil];
                } else {
                    return [SSignal complete];
                }
            }
        }]];
    }];
};

- (void)addUpdates:(NSArray *)updates {
    _updatesPipe.sink(updates);
}

- (SSignal *)keepPolling {
    __weak TGManagedChannelState *weakSelf = self;
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(__unused SSubscriber *subscriber) {
        __strong TGManagedChannelState *strongSelf = weakSelf;
        if (strongSelf != nil) {
            __block NSInteger index = -1;
            bool start = [[strongSelf->_keepPollingBag with:^id(SBag *bag) {
                bool shouldStart = [bag isEmpty];
                index = [bag addItem:@true];
                
                return @(shouldStart);
            }] boolValue];
            
            if (start) {
                _pollsPipe.sink(@true);
            }
            
            return [[SBlockDisposable alloc] initWithBlock:^{
                __strong TGManagedChannelState *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf->_keepPollingBag with:^id(SBag *bag) {
                        [bag removeItem:index];
                        return nil;
                    }];
                }
            }];
        }
        
        return nil;
    }];
}

@end

@implementation TGChannelStateSignals

+ (SAtomic *)channelStates {
    static SAtomic *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = [[SAtomic alloc] initWithValue:[[NSMutableDictionary alloc] init]];
    });
    return value;
}

+ (void)clearChannelStates {
    [[self channelStates] swap:[[NSMutableDictionary alloc] init]];
}

+ (TGManagedChannelState *)channelState:(int64_t)peerId {
    return [[self channelStates] with:^id(NSMutableDictionary *dict) {
        TGManagedChannelState *state = dict[@(peerId)];
        if (state == nil) {
            state = [[TGManagedChannelState alloc] initWithPeerId:peerId];
            dict[@(peerId)] = state;
        }
        return state;
    }];
}

+ (SSignal *)addInviterMessage:(int64_t)peerId accessHash:(int64_t)accessHash {
    return [[TGDatabaseInstance() modify:^id {
        NSData *stored = [TGDatabaseInstance() conversationCustomPropertySync:peerId name:murMurHash32(@"inviterStored")];
        if (stored.length == 0) {
            return @(false);
        } else {
            return @(true);
        }
    }] mapToSignal:^SSignal *(NSNumber *alreadyStored) {
        if ([alreadyStored boolValue]) {
            return [SSignal complete];
        } else {
            return [[[TGChannelManagementSignals channelInviterUser:peerId accessHash:accessHash] onNext:^(NSDictionary *dict) {
                [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                    NSData *stored = [TGDatabaseInstance() conversationCustomPropertySync:peerId name:murMurHash32(@"inviterStored")];
                    if (stored.length == 0) {
                        if ([dict[@"userId"] intValue] != 0) {
                            TGMessage *message = [[TGMessage alloc] init];
                            message.mid = [[TGDatabaseInstance() generateLocalMids:1].firstObject intValue];
                            message.date = [dict[@"timestamp"] intValue];
                            TGActionMediaAttachment *attachment = [[TGActionMediaAttachment alloc] init];
                            attachment.actionType = TGMessageActionChannelInviter;
                            attachment.actionData = @{@"uid": dict[@"userId"]};
                            message.mediaAttachments = @[attachment];
                            message.sortKey = TGMessageSortKeyMake(peerId, TGMessageSpaceImportant, (int32_t)message.date, message.mid);
                            message.fromUid = TGTelegraphInstance.clientUserId;
                            message.toUid = peerId;
                            
                            [TGDatabaseInstance() addMessagesToChannelAndDispatch:peerId messages:@[message] deletedMessages:nil holes:nil pts:0];
                        }
                        
                        uint8_t one = 1;
                        [TGDatabaseInstance() setConversationCustomProperty:peerId name:murMurHash32(@"inviterStored") value:[NSData dataWithBytes:&one length:1]];
                    }
                } synchronous:false];
            }] mapToSignal:^SSignal *(__unused id next) {
                return [SSignal complete];
            }];
        }
    }];
}

+ (SSignal *)validateMessageRanges:(int64_t)peerId pts:(int32_t)pts validPts:(int32_t)validPts messageRanges:(NSArray *)messageRanges {
    return [[[TGDatabaseInstance() existingChannel:peerId] take:1] mapToSignal:^SSignal *(TGConversation *conversation) {
        TLRPCupdates_getChannelDifference$updates_getChannelDifference *getChannelDifference = [[TLRPCupdates_getChannelDifference$updates_getChannelDifference alloc] init];
        TLChannelMessagesFilter$channelMessagesFilter *filter = [[TLChannelMessagesFilter$channelMessagesFilter alloc] init];
        filter.flags = 1 << 1;
        filter.ranges = messageRanges;
        getChannelDifference.filter = filter;
        getChannelDifference.pts = pts;
        getChannelDifference.limit = 1000;
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
        inputChannel.access_hash = conversation.accessHash;
        getChannelDifference.channel = inputChannel;
        
        return [[[TGTelegramNetworking instance] requestSignal:getChannelDifference] mapToSignal:^SSignal *(TLupdates_ChannelDifference *result) {
            NSMutableArray *deletedMessageIds = [[NSMutableArray alloc] init];
            
            if ([result isKindOfClass:[TLUpdates_ChannelDifference$channelDifference class]]) {
                for (id update in ((TLUpdates_ChannelDifference$channelDifference *)result).other_updates) {
                    if ([update isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]]) {
                        [deletedMessageIds addObjectsFromArray:((TLUpdate$updateDeleteChannelMessages *)update).messages];
                    }
                }
            } else if ([result isKindOfClass:[TLUpdates_ChannelDifference$empty class]]) {
                
            } else if ([result isKindOfClass:[TLUpdates_ChannelDifference$tooLong class]]) {
                
            }
            
            return [[TGDatabaseInstance() modify:^id{
                if (deletedMessageIds.count != 0) {
                    [TGDatabaseInstance() addMessagesToChannel:peerId messages:nil deleteMessages:deletedMessageIds unimportantGroups:nil addedHoles:nil removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:false changedMessages:^(NSArray *addedMessages, NSArray *removedMessages, NSDictionary *updatedMessages, NSArray *addedUnimportantHoles, NSArray *removedUnimportantHoles) {
                        NSMutableArray *addedImportantMessages = [[NSMutableArray alloc] init];
                        NSMutableArray *addedUnimportantMessages = [[NSMutableArray alloc] init];
                        for (TGMessage *message in addedMessages) {
                            if (message.hole != nil) {
                                [addedImportantMessages addObject:message];
                                [addedUnimportantMessages addObject:message];
                            }
                            else if (message.group != nil) {
                                [addedImportantMessages addObject:message];
                            } else if (TGMessageSortKeySpace(message.sortKey) == TGMessageSpaceImportant) {
                                [addedImportantMessages addObject:message];
                                [addedUnimportantMessages addObject:message];
                            } else {
                                [addedUnimportantMessages addObject:message];
                            }
                        }
                        
                        [addedUnimportantMessages addObjectsFromArray:addedUnimportantHoles];
                        
                        NSMutableArray *removedImportantMessages = [[NSMutableArray alloc] init];
                        NSMutableArray *removedUnimportantMessages = [[NSMutableArray alloc] init];
                        
                        NSMutableDictionary *updatedImportantMessages = [[NSMutableDictionary alloc] init];
                        NSMutableDictionary *updatedUnimportantMessages = [[NSMutableDictionary alloc] init];
                        
                        [updatedImportantMessages addEntriesFromDictionary:updatedMessages];
                        [updatedUnimportantMessages addEntriesFromDictionary:updatedMessages];
                        
                        [removedImportantMessages addObjectsFromArray:removedMessages];
                        [removedUnimportantMessages addObjectsFromArray:removedMessages];
                        [removedUnimportantMessages addObjectsFromArray:removedUnimportantHoles];
                        
                        [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/importantMessages", peerId] resource:@{@"removed": removedImportantMessages, @"added": addedImportantMessages, @"updated": updatedImportantMessages}];
                        [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/unimportantMessages", peerId] resource:@{@"removed": removedUnimportantMessages, @"added": addedUnimportantMessages, @"updated": updatedUnimportantMessages}];
                    }];
                }
                
                [TGDatabaseInstance() updateMessageRangesPts:peerId messageRanges:messageRanges pts:validPts];
                
                return [SSignal complete];
            }] switchToLatest];
        }];
    }];
}

+ (SSignal *)pollOnce:(int64_t)peerId {
    return [[[TGDatabaseInstance() existingChannel:peerId] take:1] mapToSignal:^SSignal *(TGConversation *conversation) {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
            SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
            
            void (^start)() = recursiveBlock(^(dispatch_block_t recurse) {
                [TGDatabaseInstance() channelPts:peerId completion:^(int32_t pts) {
                    
                    [disposable setDisposable:[[TGManagedChannelState _channelDifference:peerId accessHash:conversation.accessHash pts:pts] startWithNext:^(TLupdates_ChannelDifference *result) {
                        [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                            NSMutableArray *messages = [[NSMutableArray alloc] init];
                            NSMutableArray *updatedMessages = [[NSMutableArray alloc] init];
                            NSMutableArray *deletedMessageIds = [[NSMutableArray alloc] init];
                            bool keepUnreadCount = false;
                            
                            NSMutableArray *conversations = [[NSMutableArray alloc] init];
                            bool restart = false;
                            NSTimeInterval nextTimeout = 5.0;
                            
                            NSArray *users = nil;
                            void (^addHole)() = nil;
                            void (^addMessages)() = nil;
                            void (^loadHoles)() = nil;
                            
                            SSignal *removeMessagesInProgressSignal = [SSignal complete];
                            NSMutableSet *skipMessageIds = [[NSMutableSet alloc] init];
                            
                            if ([result isKindOfClass:[TLUpdates_ChannelDifference$empty class]]) {
                                TLUpdates_ChannelDifference$empty *concreteDifference = (TLUpdates_ChannelDifference$empty *)result;
                                if (concreteDifference.flags & (1 << 1)) {
                                    nextTimeout = concreteDifference.timeout;
                                }
                            } else if ([result isKindOfClass:[TLUpdates_ChannelDifference$tooLong class]]) {
                                TLUpdates_ChannelDifference$tooLong *concreteDifference = (TLUpdates_ChannelDifference$tooLong *)result;
                                if (concreteDifference.flags & (1 << 1)) {
                                    nextTimeout = concreteDifference.timeout;
                                }
                                keepUnreadCount = true;
                                
                                TGLog(@"(TGChannelStateSignals ChannelDifference for %lld is tooLong, topMessage: %d)", peerId, concreteDifference.top_message);
                                
                                for (id messageDesc in concreteDifference.messages) {
                                    TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
                                    message.pts = concreteDifference.pts;
                                    if (message.mid != 0) {
                                        [messages addObject:message];
                                    }
                                }
                                
                                NSMutableArray *conversations = [[NSMutableArray alloc] init];
                                for (id chatDesc in concreteDifference.chats) {
                                    TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
                                    if (conversation.conversationId != 0) {
                                        [conversations addObject:conversation];
                                    }
                                }
                                
                                users = concreteDifference.users;
                                
                                addHole = ^{
                                    [TGDatabaseInstance() addTrailingHoleToChannelAndDispatch:peerId messages:messages pts:concreteDifference.pts importantUnreadCount:concreteDifference.unread_count unimportantUnreadCount:0 maxReadId:concreteDifference.read_inbox_max_id];
                                    
                                    [TGDatabaseInstance() updateHistoryPtsForPeerId:peerId pts:concreteDifference.pts];
                                };
                                
                                if (concreteDifference.unread_count != 0) {
                                    loadHoles = ^{
                                        SMetaDisposable *metaDisposable = [[SMetaDisposable alloc] init];
                                        __weak SMetaDisposable *weakMetaDisposable = metaDisposable;
                                        id<SDisposable> disposable = [[[TGChannelManagementSignals preloadedHistoryForPeerId:peerId accessHash:conversation.accessHash aroundMessageId:concreteDifference.read_inbox_max_id] mapToSignal:^SSignal *(NSDictionary *dict) {
                                            return [[TGDatabaseInstance() modify:^{
                                                NSArray *removedImportantHoles = nil;
                                                NSArray *removedUnimportantHoles = nil;
                                                
                                                removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                                                removedUnimportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
                                                
                                                [TGDatabaseInstance() addMessagesToChannel:peerId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:false changedMessages:^(NSArray *addedMessages, NSArray *removedMessages, NSDictionary *updatedMessages, NSArray *addedUnimportantHoles, NSArray *removedUnimportantHoles) {
                                                    NSMutableArray *addedImportantMessages = [[NSMutableArray alloc] init];
                                                    NSMutableArray *addedUnimportantMessages = [[NSMutableArray alloc] init];
                                                    for (TGMessage *message in addedMessages) {
                                                        if (message.hole != nil) {
                                                            [addedImportantMessages addObject:message];
                                                            [addedUnimportantMessages addObject:message];
                                                        }
                                                        else if (message.group != nil) {
                                                            [addedImportantMessages addObject:message];
                                                        } else if (TGMessageSortKeySpace(message.sortKey) == TGMessageSpaceImportant) {
                                                            [addedImportantMessages addObject:message];
                                                            [addedUnimportantMessages addObject:message];
                                                        } else {
                                                            [addedUnimportantMessages addObject:message];
                                                        }
                                                    }
                                                    
                                                    [addedUnimportantMessages addObjectsFromArray:addedUnimportantHoles];
                                                    
                                                    NSMutableArray *removedImportantMessages = [[NSMutableArray alloc] init];
                                                    NSMutableArray *removedUnimportantMessages = [[NSMutableArray alloc] init];
                                                    
                                                    NSMutableDictionary *updatedImportantMessages = [[NSMutableDictionary alloc] init];
                                                    NSMutableDictionary *updatedUnimportantMessages = [[NSMutableDictionary alloc] init];
                                                    
                                                    [updatedImportantMessages addEntriesFromDictionary:updatedMessages];
                                                    [updatedUnimportantMessages addEntriesFromDictionary:updatedMessages];
                                                    
                                                    [removedImportantMessages addObjectsFromArray:removedMessages];
                                                    [removedUnimportantMessages addObjectsFromArray:removedMessages];
                                                    [removedUnimportantMessages addObjectsFromArray:removedUnimportantHoles];
                                                    
                                                    [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/importantMessages", peerId] resource:@{@"removed": removedImportantMessages, @"added": addedImportantMessages, @"updated": updatedImportantMessages}];
                                                    [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/(%lld)/unimportantMessages", peerId] resource:@{@"removed": removedUnimportantMessages, @"added": addedUnimportantMessages, @"updated": updatedUnimportantMessages}];
                                                }];
                                                
                                                return [SSignal complete];
                                            }] switchToLatest];
                                        }] startWithNext:nil error:^(__unused id error) {
                                            __strong SMetaDisposable *strongMetaDisposable = weakMetaDisposable;
                                            if (strongMetaDisposable != nil) {
                                                [TGTelegraphInstance.disposeOnLogout remove:strongMetaDisposable];
                                            }
                                        } completed:^{
                                            __strong SMetaDisposable *strongMetaDisposable = weakMetaDisposable;
                                            if (strongMetaDisposable != nil) {
                                                [TGTelegraphInstance.disposeOnLogout remove:strongMetaDisposable];
                                            }
                                        }];
                                        [metaDisposable setDisposable:disposable];
                                        [TGTelegraphInstance.disposeOnLogout add:metaDisposable];
                                    };
                                }
                            } else if ([result isKindOfClass:[TLUpdates_ChannelDifference$channelDifference class]]) {
                                TLUpdates_ChannelDifference$channelDifference *concreteDifference = (TLUpdates_ChannelDifference$channelDifference *)result;
                                if (concreteDifference.flags & (1 << 1)) {
                                    nextTimeout = concreteDifference.timeout;
                                } else {
                                    restart = true;
                                }
                                
                                bool hasMessageIdUpdates = false;
                                
                                for (id messageDesc in concreteDifference.n_new_messages) {
                                    TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
                                    message.pts = concreteDifference.pts;
                                    if (message.mid != 0 && message.cid == peerId) {
                                        [messages addObject:message];
                                    }
                                }
                                
                                for (id update in concreteDifference.other_updates) {
                                    if ([update isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]]) {
                                        [deletedMessageIds addObjectsFromArray:((TLUpdate$updateDeleteChannelMessages *)update).messages];
                                    } else if ([update isKindOfClass:[TLUpdate$updateMessageID class]]) {
                                        hasMessageIdUpdates = true;
                                    } else if ([update isKindOfClass:[TLUpdate$updateEditChannelMessage class]]) {
                                        TLUpdate$updateEditChannelMessage *updateEditMessage = update;
                                        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:updateEditMessage.message];
                                        message.pts = updateEditMessage.pts;
                                        
                                        [updatedMessages addObject:message];
                                    }
                                }
                                
                                for (id channelDesc in concreteDifference.chats) {
                                    TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:channelDesc];
                                    if (conversation.conversationId != 0) {
                                        [conversations addObject:conversation];
                                    }
                                }
                                
                                SSignal *removeMessagesInProgressSignal = nil;
                                
                                if (hasMessageIdUpdates || true) {
                                    NSMutableDictionary *randomIdToMessageId = [[NSMutableDictionary alloc] init];
                                    
                                    for (id update in concreteDifference.other_updates) {
                                        if ([update isKindOfClass:[TLUpdate$updateMessageID class]]) {
                                            int64_t randomId = ((TLUpdate$updateMessageID *)update).random_id;
                                            int32_t messageId = ((TLUpdate$updateMessageID *)update).n_id;
                                            randomIdToMessageId[@(randomId)] = @(messageId);
                                        }
                                    }
                                    
                                    removeMessagesInProgressSignal = [[SSignal defer:^SSignal *{
                                        for (TGModernSendCommonMessageActor *actor in [ActionStageInstance() executingActorsWithPathPrefix:[[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%" PRId64 ")/", peerId]]) {
                                            if (actor.preparedMessage.randomId != 0) {
                                                NSNumber *nMessageId = randomIdToMessageId[@(actor.preparedMessage.randomId)];
                                                if (nMessageId != nil) {
                                                    [skipMessageIds addObject:nMessageId];
                                                }
                                            }
                                        }
                                        
                                        return [SSignal complete];
                                    }] startOn:[SQueue wrapConcurrentNativeQueue:[ActionStageInstance() globalStageDispatchQueue]]];
                                }
                                
                                users = concreteDifference.users;
                                
                                addMessages = ^{
                                    [TGDatabaseInstance() addMessagesToChannelAndDispatch:peerId messages:messages deletedMessages:deletedMessageIds holes:nil pts:concreteDifference.pts];
                                    
                                    if (updatedMessages.count != 0) {
                                        NSMutableArray<TGDatabaseUpdateMessage *> *messageUpdates = [[NSMutableArray alloc] init];
                                        for (TGMessage *message in updatedMessages) {
                                            [messageUpdates addObject:[[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:message.cid messageId:message.mid message:message dispatchEdited:true]];
                                        }
                                        
                                        [TGDatabaseInstance() transactionUpdateMessages:messageUpdates updateConversationDatas:nil];
                                    }
                                };
                            }
                            
                            NSMutableArray *downloadMessages = [[NSMutableArray alloc] init];
                            
                            NSMutableDictionary *addedMessageIdToMessage = [[NSMutableDictionary alloc] init];
                            for (TGMessage *message in messages) {
                                addedMessageIdToMessage[@(message.mid)] = message;
                            }
                            
                            for (NSInteger i = 0; i < (NSInteger)messages.count; i++)
                            {
                                TGMessage *message = messages[i];
                                if ([skipMessageIds containsObject:@(message.mid)]) {
                                    [messages removeObjectAtIndex:i];
                                    i--;
                                } else {
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
                                                        [downloadMessages addObject:[[TGDownloadMessage alloc] initWithPeerId:conversation.conversationId accessHash:conversation.accessHash messageId:replyAttachment.replyMessageId]];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            [disposable setDisposable:[[[removeMessagesInProgressSignal then:[TGDownloadMessagesSignal downloadMessages:downloadMessages]] mapToSignal:^SSignal *(NSArray *updatedMessages) {
                                return [TGDatabaseInstance() modify:^id {
                                    for (TGMessage *message in updatedMessages) {
                                        addedMessageIdToMessage[@(message.mid)] = message;
                                    }
                                    
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
                                    
                                    [TGUserDataRequestBuilder executeUserDataUpdate:users];
                                    [TGDatabaseInstance() updateChannels:conversations];
                                    
                                    if (addHole) {
                                        addHole();
                                    }
                                    
                                    if (addMessages) {
                                        addMessages();
                                    }
                                    
                                    if (loadHoles) {
                                        loadHoles();
                                    }
                                    
                                    if (restart) {
                                        recurse();
                                    } else {
                                        [subscriber putNext:@(nextTimeout)];
                                        [subscriber putCompletion];
                                    }
                                    
                                    return nil;
                                }];
                            }] startWithNext:nil]];
                        } synchronous:false];
                    } error:^(__unused id error) {
                    } completed:nil]];
                }];
            });
            
            start();
            
            return disposable;
        }];
    }];
}

+ (void)addChannelUpdates:(int64_t)peerId updates:(NSArray *)updates {
    [[self channelState:peerId] addUpdates:updates];
}

+ (SSignal *)updatedChannel:(int64_t)peerId {
    return [[self channelState:peerId] keepPolling];
}

@end
