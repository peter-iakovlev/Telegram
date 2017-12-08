#import "TGMediaPostingContext.h"

#import "TGModernSendMessageActor.h"
#import "TGPreparedAssetImageMessage.h"
#import "TGPreparedAssetVideoMessage.h"
#import "TGPreparedLocalImageMessage.h"

#import "TLInputSingleMedia.h"

@interface TGMediaPostingContext ()
{
    NSMutableArray *_messages;
    NSMapTable *_actorsForMessages;
    NSMutableDictionary *_mediaForMessages;
    NSMutableSet *_readyToSend;
    SPipe *_pipe;
    
    NSMutableSet *_subscribedGroupedIds;
}
@end

@implementation TGMediaPostingContext

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _messages = [[NSMutableArray alloc] init];
        _actorsForMessages = [[NSMapTable alloc] initWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory capacity:256];
        _mediaForMessages = [[NSMutableDictionary alloc] init];
        _readyToSend = [[NSMutableSet alloc] init];
        _subscribedGroupedIds = [[NSMutableSet alloc] init];
        _pipe = [[SPipe alloc] init];
    }
    return self;
}

- (void)enqueueMessage:(TGPreparedMessage *)message
{
    [_messages addObject:message];
}

- (SSignal *)readyToPostPreparedMessage:(TGPreparedMessage *)message
{
    return [SSignal defer:^SSignal *
    {
        if (_messages.firstObject == message)
        {
            return [SSignal complete];
        }
        else
        {
            return [[[_pipe.signalProducer() filter:^bool(NSArray *messages)
            {
                return messages.firstObject == message;
            }] take:1] mapToSignal:^SSignal *(__unused id value)
            {
                return [SSignal complete];
            }];
        }
    }];
}

- (void)notifyPostedMessage:(TGPreparedMessage *)message
{
    [_messages removeObject:message];
    _pipe.sink(_messages);
}

- (int64_t)groupedIdForMessage:(TGPreparedMessage *)message
{
    if ([message isKindOfClass:[TGPreparedAssetImageMessage class]])
        return ((TGPreparedAssetImageMessage *)message).groupedId;
    else if ([message isKindOfClass:[TGPreparedAssetVideoMessage class]])
        return ((TGPreparedAssetVideoMessage *)message).groupedId;
    else if ([message isKindOfClass:[TGPreparedLocalImageMessage class]])
        return ((TGPreparedLocalImageMessage *)message).groupedId;
    
    return 0;
}

- (bool)_readyToPostGroupedId:(int64_t)groupedId messages:(NSArray *)messages
{
    bool ready = [self groupedIdForMessage:messages.firstObject] == groupedId;
    if (!ready)
        return false;
    
    for (TGPreparedMessage *message in messages)
    {
        if ([self groupedIdForMessage:message] != groupedId)
            break;
        
        if (_mediaForMessages[@(message.randomId)] == nil && ![_readyToSend containsObject:message])
        {
            ready = false;
            break;
        }
    }
    return ready;
}

- (SSignal *)readyToPostGroupedId:(int64_t)groupedId force:(bool)force
{
    if (!force && [_subscribedGroupedIds containsObject:@(groupedId)])
        return [SSignal never];
    
    return [SSignal defer:^SSignal *
    {
        if ([self _readyToPostGroupedId:groupedId messages:_messages])
        {
            return [[SSignal complete] delay:0.15 onQueue:[SQueue concurrentDefaultQueue]];
        }
        else
        {
            return [[[_pipe.signalProducer() filter:^bool(NSArray *messages)
            {
                return [messages.firstObject groupedId] == groupedId && [self _readyToPostGroupedId:groupedId messages:messages];
            }] take:1] mapToSignal:^SSignal *(__unused id value)
            {
                return [[SSignal complete] delay:0.15 onQueue:[SQueue concurrentDefaultQueue]];
            }];
        }
    }];
}

- (void)startMediaUploadForPreparedMessage:(TGPreparedMessage *)preparedMessage actor:(TGModernSendMessageActor *)actor
{
    if (preparedMessage == nil)
        return;
    
    [_actorsForMessages setObject:actor forKey:@(preparedMessage.randomId)];
}

- (void)maybeNotifyGroupedUploadProgressWithPreparedMessage:(TGPreparedMessage *)preparedMessage
{
    if (preparedMessage.groupedId != 0)
        return;
    
    NSDictionary *actors = [_actorsForMessages dictionaryRepresentation];
    for (TGModernSendMessageActor *actor in [actors allValues])
    {
        if (actor.preparedMessage.randomId != preparedMessage.randomId && actor.preparedMessage.groupedId == preparedMessage.groupedId)
            [actor restartFailTimeoutIfRunning];
    }
}

- (void)failPreparedMessage:(TGPreparedMessage *)preparedMessage
{
    if (preparedMessage.groupedId != 0)
    {
        NSDictionary *actors = [_actorsForMessages dictionaryRepresentation];
        for (TGModernSendMessageActor *actor in actors.allValues)
        {
            if (actor.preparedMessage.randomId != preparedMessage.randomId && actor.preparedMessage.groupedId == preparedMessage.groupedId)
                [actor cancel];
        }
        
        [self notifyPostedGroupedId:preparedMessage.groupedId];
    }
    else
    {
        [self notifyPostedMessage:preparedMessage];
    }
}

- (void)cancelPreparedMessage:(TGPreparedMessage *)preparedMessage
{
    [self notifyPostedMessage:preparedMessage];
}

- (void)saveMessageMedia:(TLInputMedia *)media forPreparedMessage:(TGPreparedMessage *)preparedMessage
{
    _mediaForMessages[@(preparedMessage.randomId)] = media;
    
    _pipe.sink(_messages);
}

- (void)markPreparedMessageAsReadyToSend:(TGPreparedMessage *)preparedMessage
{
    [_readyToSend addObject:preparedMessage];
    
    _pipe.sink(_messages);
}

- (int32_t)replyToIdForGroupedId:(int64_t)groupedId
{
    TGPreparedMessage *message = _messages.firstObject;
    if ([self groupedIdForMessage:message] == groupedId)
    {
        if ([message isKindOfClass:[TGPreparedAssetImageMessage class]])
            return ((TGPreparedAssetImageMessage *)message).replyMessage.mid;
        else if ([message isKindOfClass:[TGPreparedAssetVideoMessage class]])
            return ((TGPreparedAssetVideoMessage *)message).replyMessage.mid;
        else if ([message isKindOfClass:[TGPreparedLocalImageMessage class]])
            return ((TGPreparedLocalImageMessage *)message).replyMessage.mid;
    }
    return 0;
}

- (NSArray *)multiMediaForGroupedId:(int64_t)groupedId
{
    NSMutableArray *multiMedia = [[NSMutableArray alloc] init];
    for (TGPreparedMessage *message in _messages)
    {
        if ([self groupedIdForMessage:message] != groupedId)
            break;
        
        TLInputSingleMedia$inputSingleMedia *singleMedia = [[TLInputSingleMedia$inputSingleMedia alloc] init];
        singleMedia.media = _mediaForMessages[@(message.randomId)];
        singleMedia.random_id = message.randomId;
        [multiMedia addObject:singleMedia];
    }
    return multiMedia;
}

- (NSArray *)actorsForGroupedId:(int64_t)groupedId
{
    NSMutableArray *actors = [[NSMutableArray alloc] init];
    for (TGPreparedMessage *message in _messages)
    {
        if ([self groupedIdForMessage:message] != groupedId)
            break;
        
        [actors addObject:[_actorsForMessages objectForKey:@(message.randomId)]];
    }
    return actors;
}

- (void)notifyPostedGroupedId:(int64_t)groupedId
{
    NSMutableIndexSet *indexesToRemove = [[NSMutableIndexSet alloc] init];
    [_messages enumerateObjectsUsingBlock:^(TGPreparedMessage *message, NSUInteger index, BOOL *stop)
    {
        if ([self groupedIdForMessage:message] == groupedId)
            [indexesToRemove addIndex:index];
        else
            *stop = true;
    }];

    [_messages removeObjectsAtIndexes:indexesToRemove];
    _pipe.sink(_messages);
}

@end
