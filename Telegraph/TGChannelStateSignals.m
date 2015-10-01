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
    int32_t limit = 100;
    
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
        int32_t updatedPts = conversation.pts;
        NSMutableArray *ptsUpdates = [[NSMutableArray alloc] init];
        int32_t maxReadId = 0;
        bool failed = false;
        
        for (id update in updates) {
            if ([update isKindOfClass:[TLUpdate$updateNewChannelMessage class]]) {
                [ptsUpdates addObject:update];
            } else if ([update isKindOfClass:[TLUpdate$updateReadChannelInbox class]]) {
                maxReadId = MAX(maxReadId, ((TLUpdate$updateReadChannelInbox *)update).max_id);
            } else if ([update isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]]) {
                [ptsUpdates addObject:update];
            } else if ([update isKindOfClass:[TLUpdate$updateChannelTooLong class]]) {
                failed = true;
            }
        }
        
        [ptsUpdates sortUsingComparator:^NSComparisonResult(id lhs, id rhs) {
            int32_t lhsPts = 0;
            int32_t rhsPts = 0;
            if ([lhs isKindOfClass:[TLUpdate$updateNewChannelMessage class]]) {
                lhsPts = ((TLUpdate$updateNewChannelMessage *)lhs).pts;
            } else if ([lhs isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]]) {
                lhsPts = ((TLUpdate$updateDeleteChannelMessages *)lhs).pts;
            }
            if ([rhs isKindOfClass:[TLUpdate$updateNewChannelMessage class]]) {
                rhsPts = ((TLUpdate$updateNewChannelMessage *)rhs).pts;
            } else if ([rhs isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]]) {
                rhsPts = ((TLUpdate$updateDeleteChannelMessages *)rhs).pts;
            }
            return lhsPts < rhsPts ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        NSMutableArray *addedMessages = [[NSMutableArray alloc] init];
        NSMutableArray *deletedMessageIds = [[NSMutableArray alloc] init];
        
        for (id update in ptsUpdates) {
            if ([update isKindOfClass:[TLUpdate$updateNewChannelMessage class]]) {
                TLUpdate$updateNewChannelMessage *updateNewChannelMessage = update;
                TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:updateNewChannelMessage.message];
                
                if (updateNewChannelMessage.pts <= updatedPts) {
                    continue;
                }
                else if (updatedPts + updateNewChannelMessage.pts_count == updateNewChannelMessage.pts) {
                    if (message.mid != 0) {
                        [addedMessages addObject:message];
                    }
                    updatedPts = updateNewChannelMessage.pts;
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
            }
        }
        
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
                    
                    static int actionId = 0;
                    [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(addMember%d)", actionId++] ] execute:[[NSDictionary alloc] initWithObjectsAndKeys:addedMessages, @"messages", @true, @"doNotAdd", nil]];
                    
                    if (updatedPts != conversation.pts) {
                        [TGDatabaseInstance() addMessagesToChannelAndDispatch:peerId messages:addedMessages deletedMessages:deletedMessageIds holes:nil pts:updatedPts];
                    }
                    
                    if (maxReadId != 0) {
                        [TGDatabaseInstance() updateChannelRead:peerId maxReadId:maxReadId];
                    }
                    
                    if (failed) {
                        return [SSignal fail:nil];
                    } else {
                        return [SSignal complete];
                    }
                }] switchToLatest];
            }];
        } else {
            if (conversation.kind == TGConversationKindPersistentChannel) {
                static int actionId = 0;
                [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(addMember%d)", actionId++] ] execute:[[NSDictionary alloc] initWithObjectsAndKeys:addedMessages, @"messages", @true, @"doNotAdd", nil]];
            }
            
            if (updatedPts != conversation.pts) {
                [TGDatabaseInstance() addMessagesToChannelAndDispatch:peerId messages:addedMessages deletedMessages:deletedMessageIds holes:nil pts:updatedPts];
            }
            
            if (maxReadId != 0) {
                [TGDatabaseInstance() updateChannelRead:peerId maxReadId:maxReadId];
            }
            
            if (failed) {
                return [SSignal fail:nil];
            } else {
                return [SSignal complete];
            }
        }
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

+ (SSignal *)pollOnce:(int64_t)peerId {
    return [[[TGDatabaseInstance() existingChannel:peerId] take:1] mapToSignal:^SSignal *(TGConversation *conversation) {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
            SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
            
            void (^start)() = recursiveBlock(^(dispatch_block_t recurse) {
                [TGDatabaseInstance() channelPts:peerId completion:^(int32_t pts) {
                    
                    [disposable setDisposable:[[TGManagedChannelState _channelDifference:peerId accessHash:conversation.accessHash pts:pts] startWithNext:^(TLupdates_ChannelDifference *result) {
                        [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                            NSMutableArray *messages = [[NSMutableArray alloc] init];
                            NSMutableArray *deletedMessageIds = [[NSMutableArray alloc] init];
                            
                            NSMutableArray *conversations = [[NSMutableArray alloc] init];
                            bool restart = false;
                            NSTimeInterval nextTimeout = 5.0;
                            
                            NSArray *users = nil;
                            void (^addHole)() = nil;
                            void (^addMessages)() = nil;
                            
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
                                
                                NSMutableArray *messages = [[NSMutableArray alloc] init];
                                for (id messageDesc in concreteDifference.messages) {
                                    TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
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
                                    [TGDatabaseInstance() addTrailingHoleToChannelAndDispatch:peerId messages:messages pts:concreteDifference.pts importantUnreadCount:concreteDifference.unread_important_count unimportantUnreadCount:concreteDifference.unread_count - concreteDifference.unread_important_count maxReadId:concreteDifference.read_inbox_max_id];
                                };
                            } else if ([result isKindOfClass:[TLUpdates_ChannelDifference$channelDifference class]]) {
                                TLUpdates_ChannelDifference$channelDifference *concreteDifference = (TLUpdates_ChannelDifference$channelDifference *)result;
                                if (concreteDifference.flags & (1 << 1)) {
                                    nextTimeout = concreteDifference.timeout;
                                } else {
                                    restart = true;
                                }
                                
                                for (id messageDesc in concreteDifference.n_new_messages) {
                                    TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
                                    if (message.mid != 0 && message.cid == peerId) {
                                        [messages addObject:message];
                                    }
                                }
                                
                                for (id update in concreteDifference.other_updates) {
                                    if ([update isKindOfClass:[TLUpdate$updateDeleteChannelMessages class]]) {
                                        [deletedMessageIds addObjectsFromArray:((TLUpdate$updateDeleteChannelMessages *)update).messages];
                                    }
                                }
                                
                                for (id channelDesc in concreteDifference.chats) {
                                    TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:channelDesc];
                                    if (conversation.conversationId != 0) {
                                        [conversations addObject:conversation];
                                    }
                                }
                                
                                users = concreteDifference.users;
                                
                                addMessages = ^{
                                    [TGDatabaseInstance() addMessagesToChannelAndDispatch:peerId messages:messages deletedMessages:deletedMessageIds holes:nil pts:concreteDifference.pts];
                                };
                            }
                            
                            NSMutableArray *downloadMessages = [[NSMutableArray alloc] init];
                            
                            NSMutableDictionary *addedMessageIdToMessage = [[NSMutableDictionary alloc] init];
                            for (TGMessage *message in messages) {
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
                                                } else {
                                                    [downloadMessages addObject:[[TGDownloadMessage alloc] initWithPeerId:conversation.conversationId accessHash:conversation.accessHash messageId:replyAttachment.replyMessageId]];
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if (downloadMessages.count != 0) {
                                [disposable setDisposable:[[[TGDownloadMessagesSignal downloadMessages:downloadMessages] mapToSignal:^SSignal *(NSArray *updatedMessages) {
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
                                        
                                        if (restart) {
                                            recurse();
                                        } else {
                                            [subscriber putNext:@(nextTimeout)];
                                            [subscriber putCompletion];
                                        }
                                        
                                        return nil;
                                    }];
                                }] startWithNext:nil]];
                            } else {
                                [TGUserDataRequestBuilder executeUserDataUpdate:users];
                                [TGDatabaseInstance() updateChannels:conversations];
                                
                                if (addHole) {
                                    addHole();
                                }
                                
                                if (addMessages) {
                                    addMessages();
                                }
                                
                                if (restart) {
                                    recurse();
                                } else {
                                    [subscriber putNext:@(nextTimeout)];
                                    [subscriber putCompletion];
                                }
                            }
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
