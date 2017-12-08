#import "TGLiveLocationSignals.h"

#import <LegacyComponents/ActionStage.h>
#import "TGDatabase.h"
#import "TGMessage+Telegraph.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"
#import "TGTelegraph.h"
#import "TLRPCmessages_editMessage.h"

#import <MTProtoKit/MTProtoKit.h>

#import "TGUserDataRequestBuilder.h"
#import "TGUpdateStateRequestBuilder.h"

@interface TGMessagesWatcherAdapter : NSObject <ASWatcher>
{
    int64_t _peerId;
    NSArray<TGMessage *> *_messages;
    void (^_updated)(NSArray<TGMessage *> *);
    bool _includeExpired;
    STimer *_timer;
}

@property (nonatomic, strong) ASHandle *actionHandle;

- (instancetype)initWithPeerId:(int64_t)peerId messages:(NSArray<TGMessage *> *)messages includeExpired:(bool)includeExpired updated:(void (^)(NSArray<TGMessage *> *))updated;

@end

@implementation TGLiveLocationSignals

+ (SSignal *)updateLiveLocationWithPeerId:(int64_t)peerId messageId:(int32_t)messageId stop:(bool)stop coordinate:(CLLocationCoordinate2D)coordinate
{
    return [[TGDatabaseInstance() modify:^id{
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
        return [TGTelegraphInstance createInputPeerForConversation:conversation.conversationId accessHash:conversation.accessHash];
    }] mapToSignal:^SSignal *(TLInputPeer *inputPeer) {
        TLRPCmessages_editMessage *editMessage = [[TLRPCmessages_editMessage alloc] init];
        editMessage.peer = inputPeer;
        editMessage.n_id = messageId;
        
        if (!stop)
        {
            TLInputGeoPoint$inputGeoPoint *geoPoint = [[TLInputGeoPoint$inputGeoPoint alloc] init];
            geoPoint.lat = coordinate.latitude;
            geoPoint.n_long = coordinate.longitude;
            editMessage.geo_point = geoPoint;
            editMessage.flags = (1 << 13);
        }
        else
        {
            editMessage.flags = (1 << 12);
        }
        
        return [[[TGTelegramNetworking instance] requestSignal:editMessage] mapToSignal:^SSignal *(TLUpdates$updates *result)
        {
            [TGUpdateStateRequestBuilder applyUpdates:[NSArray array] otherUpdates:result.updates usersDesc:result.users chatsDesc:result.chats chatParticipantsDesc:nil updatesWithDates:nil addedEncryptedActionsByPeerId:nil addedEncryptedUnparsedActionsByPeerId:nil completion:nil];
            
            return [SSignal single:@true];
        }];
    }];
}

+ (SSignal *)updateLiveLocationWithPeerId:(int64_t)peerId messageId:(int32_t)messageId coordinate:(CLLocationCoordinate2D)coordinate
{
    return [self updateLiveLocationWithPeerId:peerId messageId:messageId stop:false coordinate:coordinate];
}

+ (SSignal *)stopLiveLocationWithPeerId:(int64_t)peerId messageId:(int32_t)messageId
{
    return [self updateLiveLocationWithPeerId:peerId messageId:messageId stop:true coordinate:kCLLocationCoordinate2DInvalid];
}

+ (SSignal *)recentLocationsForPeerId:(int64_t)peerId limit:(int32_t)limit
{
    return [[TGDatabaseInstance() modify:^id{
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
        return [TGTelegraphInstance createInputPeerForConversation:conversation.conversationId accessHash:conversation.accessHash];
    }] mapToSignal:^SSignal *(TLInputPeer *inputPeer) {
        TLRPCmessages_getRecentLocations$messages_getRecentLocations *getRecentLocations = [[TLRPCmessages_getRecentLocations$messages_getRecentLocations alloc] init];
        getRecentLocations.peer = inputPeer;
        getRecentLocations.limit = (int32_t)limit;
    
        return [[[TGTelegramNetworking instance] requestSignal:getRecentLocations continueOnServerErrors:false failOnFloodErrors:true failOnServerErrorsImmediately:true] mapToSignal:^SSignal *(TLmessages_Messages *messages) {
            [TGUserDataRequestBuilder executeUserDataUpdate:messages.users];
            
            NSMutableArray *parsedMessages = [[NSMutableArray alloc] init];
            for (id desc in messages.messages) {
                TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
                if (message.mid != 0) {
                    [parsedMessages addObject:message];
                }
            }
            return [SSignal single:parsedMessages];
        }];
    }];
}

+ (NSArray *)filterLiveLocationMessages:(NSArray *)messages includeExpired:(bool)includeExpired
{
    int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
    NSMutableDictionary<NSNumber *, TGMessage *> *locationMessages = [[NSMutableDictionary alloc] init];
    for (TGMessage *message in messages)
    {
        TGLocationMediaAttachment *location = message.locationAttachment;
        if (location.period > 0 && (includeExpired || currentTime < message.date + location.period))
        {
            if (!locationMessages[@(message.fromUid)] || [locationMessages[@(message.fromUid)] date] < message.date)
                locationMessages[@(message.fromUid)] = message;
        }
    }
    if (locationMessages.count == 0)
        NSLog(@"");
    return locationMessages.allValues;
}

+ (SSignal *)liveLocationsForPeerId:(int64_t)peerId includeExpired:(bool)includeExpired onlyLocal:(bool)onlyLocal
{
    int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
    int32_t maxDate = currentTime - 60 * 60 * 8;
    
    SSignal *localMessages = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [TGDatabaseInstance() loadMessagesFromConversationDownwards:peerId minMid:0 minLocalMid:0 minDate:maxDate limit:1000 completion:^(NSArray *messages)
        {
            [subscriber putNext:[self filterLiveLocationMessages:messages includeExpired:includeExpired]];
            [subscriber putCompletion];
        }];
        
        return nil;
    }];
    
    SSignal *channelLocalMessages = [[[TGDatabaseInstance() existingChannel:peerId] take:1] mapToSignal:^SSignal *(TGConversation *channel)
    {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            TGMessageTransparentSortKey maxSortKey = TGMessageTransparentSortKeyUpperBound(peerId);
            [TGDatabaseInstance() channelMessages:peerId maxTransparentSortKey:maxSortKey count:300 important:!channel.isChannelGroup mode:TGChannelHistoryRequestAround completion:^(NSArray *messages, __unused bool hasLater)
            {
                [subscriber putNext:[self filterLiveLocationMessages:messages includeExpired:includeExpired]];
                [subscriber putCompletion];
            }];
            
            return nil;
        }];
    }];
    
    SSignal *remoteMessages = [[self recentLocationsForPeerId:peerId limit:100] map:^id(NSArray *messages)
    {
        return [self filterLiveLocationMessages:messages includeExpired:includeExpired];
    }];
    
    SSignal *(^updates)(NSArray<TGMessage *> *) = ^(NSArray<TGMessage *> *initialMessages)
    {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            TGMessagesWatcherAdapter *adapter = [[TGMessagesWatcherAdapter alloc] initWithPeerId:peerId messages:initialMessages includeExpired:includeExpired updated:^(NSArray<TGMessage *> *messages)
            {
                [subscriber putNext:messages];
            }];
            
            return [[SBlockDisposable alloc] initWithBlock:^
            {
                [adapter description];
            }];
        }];
    };
    
    SSignal *initialSignal = TGPeerIdIsChannel(peerId) ? channelLocalMessages : localMessages;
    return [initialSignal mapToSignal:^SSignal *(NSArray<TGMessage *> *messages)
    {
        SSignal *nextSignal = updates(messages);
        if (!onlyLocal)
        {
            nextSignal = [[remoteMessages mapToSignal:^SSignal *(NSArray *remoteMessages)
            {
                return [[SSignal single:remoteMessages] then:updates(remoteMessages)];
            }] catch:^SSignal *(__unused id error)
            {
                return updates(messages);
            }];
        }
        return [[SSignal single:messages] then:nextSignal];
    }];
}

+ (SSignal *)remainingTimeForMessage:(TGMessage *)message
{
    return [SSignal defer:^SSignal *
    {
        TGLocationMediaAttachment *location = message.locationAttachment;
        if (location.period == 0)
            return [SSignal fail:nil];
        
        if (message.deliveryState != TGMessageDeliveryStateDelivered)
            return [SSignal single:@(location.period)];
        
        SSignal *remainingTime = [SSignal defer:^SSignal *
        {
            int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
            int32_t remainingTime = MAX(0, (int32_t)message.date + location.period - currentTime);
            SSignal *signal = [SSignal single:@(remainingTime)];
            if (remainingTime == 0)
                signal = [signal then:[SSignal fail:nil]];
            return signal;
        }];
        
        return [[[remainingTime then:[[SSignal complete] delay:5.0 onQueue:[SQueue mainQueue]]] restart] catch:^SSignal *(__unused id error)
        {
            return [SSignal complete];
        }];
    }];
}

@end


@implementation TGMessagesWatcherAdapter

- (instancetype)initWithPeerId:(int64_t)peerId messages:(NSArray<TGMessage *> *)messages includeExpired:(bool)includeExpired updated:(void (^)(NSArray<TGMessage *> *))updated
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        _peerId = peerId;
        _messages = messages;
        _updated = [updated copy];
        _includeExpired = includeExpired;
        
        __weak TGMessagesWatcherAdapter *weakSelf = self;
        _timer = [[STimer alloc] initWithTimeout:1.5 repeat:true completion:^
        {
            __strong TGMessagesWatcherAdapter *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf cleanupExpiredMessages];
        } nativeQueue:[ActionStageInstance() globalStageDispatchQueue]];
        [_timer start];
        
        [ActionStageInstance() watchForPaths:@
         [
          [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]],
          [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/importantMessages", [self _conversationIdPathComponent]],
          [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/unimportantMessages", [self _conversationIdPathComponent]],
          [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesDeleted", [self _conversationIdPathComponent]],
          [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesChanged", [self _conversationIdPathComponent]],
          [[NSString alloc] initWithFormat:@"/messagesEditedInConversation/(%@)", [self _conversationIdPathComponent]],
          @"/tg/conversation/historyCleared",
          ] watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_timer invalidate];
    [_actionHandle reset];
}

- (void)cleanupExpiredMessages
{
    int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
    
    NSMutableArray *updatedMessages = [[NSMutableArray alloc] init];
    NSMutableArray *expiredMids = [[NSMutableArray alloc] init];
    for (TGMessage *message in _messages)
    {
        TGLocationMediaAttachment *location = message.locationAttachment;
        if (location.period > 0 && (currentTime < message.date + location.period))
            [updatedMessages addObject:message];
        else
            [expiredMids addObject:@(message.mid)];
    }
    
    if (updatedMessages.count != _messages.count)
    {
        if (!_includeExpired)
            _messages = updatedMessages;
        
        if (_updated)
            _updated(_messages);
    }
    
    if (expiredMids.count > 0)
    {
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/liveLocationsExpired", _peerId] resource:expiredMids];
    }
}

- (NSString *)_conversationIdPathComponent
{
    return [[NSString alloc] initWithFormat:@"%lld", _peerId];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
    
    NSString *conversationId = [self _conversationIdPathComponent];
    
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", conversationId]])
    {
        NSArray *messages = ((SGraphObjectNode *)resource).object;
        NSMutableSet *currentMessageIds = [[NSMutableSet alloc] init];
        for (TGMessage *message in _messages)
            [currentMessageIds addObject:@(message.mid)];
        
        NSMutableArray *updatedMessages = [[NSMutableArray alloc] initWithArray:_messages];
        for (TGMessage *message in messages)
        {
            TGLocationMediaAttachment *location = message.locationAttachment;
            if (location.period > 0 && (_includeExpired || currentTime < message.date + location.period))
            {
                if (![currentMessageIds containsObject:@(message.mid)])
                {
                    [currentMessageIds addObject:@(message.mid)];
                    bool added = false;
                    for (NSUInteger i = 0; i < updatedMessages.count; i++)
                    {
                        TGMessage *listMessage = updatedMessages[i];
                        if (listMessage.date < message.date || (ABS(listMessage.date - message.date) < FLT_EPSILON && listMessage.mid < message.mid))
                        {
                            [updatedMessages insertObject:message atIndex:i];
                            added = true;
                            break;
                        }
                    }
                    if (!added)
                        [updatedMessages addObject:message];
                }
            }
        }
        
        _messages = [TGLiveLocationSignals filterLiveLocationMessages:updatedMessages includeExpired:_includeExpired];
        
        if (_updated)
            _updated(_messages);
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/importantMessages", conversationId]])
    {
        if (((NSArray *)resource[@"added"]).count != 0)
        {
            [self actionStageResourceDispatched:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", conversationId] resource:[[SGraphObjectNode alloc] initWithObject:resource[@"added"]] arguments:@{@"treatIncomingAsUnread": @true}];
        }
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/unimportantMessages", conversationId]])
    {
        if (((NSArray *)resource[@"added"]).count != 0)
        {
            [self actionStageResourceDispatched:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", conversationId] resource:[[SGraphObjectNode alloc] initWithObject:resource[@"added"]] arguments:@{@"treatIncomingAsUnread": @true}];
        }
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesDeleted", conversationId]])
    {
        NSMutableSet *deletedMessageIds = [[NSMutableSet alloc] init];
        for (NSNumber *nMessageId in ((SGraphObjectNode *)resource).object)
            [deletedMessageIds addObject:nMessageId];
        
        NSMutableArray *updatedMessages = [[NSMutableArray alloc] initWithArray:_messages];
        for (NSInteger i = 0; i < (NSInteger)updatedMessages.count; i++)
        {
            TGMessage *message = updatedMessages[i];
            if ([deletedMessageIds containsObject:@(message.mid)])
            {
                [updatedMessages removeObjectAtIndex:i];
                i--;
            }
        }
        
        _messages = [TGLiveLocationSignals filterLiveLocationMessages:updatedMessages includeExpired:_includeExpired];
        
        if (_updated)
            _updated(_messages);
    }
    else if ([path isEqualToString:[NSString stringWithFormat:@"/tg/conversation/(%@)/messagesChanged", conversationId]])
    {
        NSMutableSet *currentMessageIds = [[NSMutableSet alloc] init];
        for (TGMessage *message in _messages)
            [currentMessageIds addObject:@(message.mid)];
        
        NSArray *midMessagePairs = ((SGraphObjectNode *)resource).object;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSUInteger i = 1; i < midMessagePairs.count; i += 2)
            dict[midMessagePairs[i - 1]] = midMessagePairs[i];
        
        NSMutableArray *updatedMessages = nil;
        for (NSUInteger i = 0 ; i < _messages.count; i++)
        {
            TGMessage *previousMessage = _messages[i];
            TGMessage *updatedMessage = dict[@(previousMessage.mid)];
            if (updatedMessage != nil)
            {
                if (updatedMessages == nil)
                    updatedMessages = [[NSMutableArray alloc] initWithArray:_messages];
                updatedMessages[i] = updatedMessage;
            }
        }
        
        if (updatedMessages != nil)
        {
            _messages = [TGLiveLocationSignals filterLiveLocationMessages:updatedMessages includeExpired:_includeExpired];
            
            if (_updated)
                _updated(_messages);
        }
    }
    else if ([path isEqualToString:[NSString stringWithFormat:@"/messagesEditedInConversation/(%@)", conversationId]])
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (TGMessage *message in resource)
            dict[@(message.mid)] = message;
        
        NSMutableArray *updatedMessages = nil;
        for (NSUInteger i = 0 ; i < _messages.count; i++)
        {
            TGMessage *previousMessage = _messages[i];
            TGMessage *updatedMessage = dict[@(previousMessage.mid)];
            if (updatedMessage != nil)
            {
                if (updatedMessages == nil)
                    updatedMessages = [[NSMutableArray alloc] initWithArray:_messages];
                updatedMessages[i] = updatedMessage;
            }
        }
        
        if (updatedMessages != nil)
        {
            _messages = [TGLiveLocationSignals filterLiveLocationMessages:updatedMessages includeExpired:_includeExpired];
            
            if (_updated)
                _updated(_messages);
        }
    }
    else if ([path isEqualToString:@"/tg/conversation/historyCleared"])
    {
        if (_peerId == [resource longLongValue])
        {
            _messages = [[NSArray alloc] init];
            
            if (_updated)
                _updated(_messages);
        }
    }
}

@end

