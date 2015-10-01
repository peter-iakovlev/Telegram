#import "TGChatMessageListSignal.h"

#import "TGDatabase.h"

#import "ActionStage.h"
#import "TGTelegraph.h"

#import "TGSharedPtrWrapper.h"

#import "TGPeerIdAdapter.h"

#import "TGConversationReadHistoryActor.h"

@interface TGChatMessageListAdapter : NSObject <ASWatcher>
{
    int64_t _peerId;
    void (^_viewUpdated)(TGChatMessageListView *);
    NSUInteger _rangeMessageCount;
    
    TGChatMessageListView *_currentView; // no need for any kind of locking, all mutations are guaranteed to run on the ActionStage thread
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGChatMessageListAdapter

+ (void)sortMessageList:(NSMutableArray *)list
{
    [list sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
    {
        NSTimeInterval date1 = message1.date;
        NSTimeInterval date2 = message2.date;
        
        if (ABS(date1 - date2) < DBL_EPSILON)
        {
            if (message1.mid > message2.mid)
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
        }
        
        return date1 > date2 ? NSOrderedAscending : NSOrderedDescending;
    }];
}

- (NSString *)_conversationIdPathComponent
{
    return [[NSString alloc] initWithFormat:@"%" PRId64 "", _peerId];
}

- (instancetype)initWithPeerId:(int64_t)peerId currentView:(TGChatMessageListView *)currentView rangeMessageCount:(NSUInteger)rangeMessageCount viewUpdated:(void (^)(TGChatMessageListView *))viewUpdated
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _viewUpdated = [viewUpdated copy];
        _currentView = currentView;
        _rangeMessageCount = rangeMessageCount;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        if (TGPeerIdIsChannel(peerId))
        {
            [ActionStageInstance() watchForPaths:@
             [
              //[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]],
              [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/localMessages", [self _conversationIdPathComponent]],
              [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/importantMessages", [self _conversationIdPathComponent]],
              @"/as/updateRelativeTimestamps",
              @"/tg/conversation/*/readmessageContents"
              ] watcher:self];
        }
        else
        {
            [ActionStageInstance() watchForPaths:@
            [
             [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]],
             [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/localMessages", [self _conversationIdPathComponent]],
             @"/tg/conversation/*/readmessages",
             [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/readmessages", [self _conversationIdPathComponent]],
             @"/tg/conversation/*/failmessages",
             [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesDeleted", [self _conversationIdPathComponent]],
             [NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId],
             @"/as/updateRelativeTimestamps",
             @"/tg/conversation/historyCleared",
             @"/tg/conversation/*/readmessageContents"
             ] watcher:self];
        }
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]]] || [path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/localMessages", [self _conversationIdPathComponent]]])
    {
        if (_currentView.laterReferenceMessageId == nil)
        {
            NSArray *messages = ((SGraphObjectNode *)resource).object;
            NSMutableSet *currentMessageIds = [[NSMutableSet alloc] init];
            for (TGMessage *message in _currentView.messages)
            {
                [currentMessageIds addObject:@(message.mid)];
            }
            
            NSMutableArray *updatedMessages = [[NSMutableArray alloc] initWithArray:_currentView.messages];
            
            for (TGMessage *message in messages)
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
            
            while (updatedMessages.count > _rangeMessageCount)
            {
                [updatedMessages removeLastObject];
            }
            
            NSNumber *earlierReferenceMessageId = nil;
            
            for (NSUInteger i = 0; i < updatedMessages.count; i++)
            {
                if (i >= _rangeMessageCount / 5)
                {
                    TGMessage *topMessage = updatedMessages[updatedMessages.count - i - 1];
                    earlierReferenceMessageId = @(topMessage.mid);
                    
                    break;
                }
            }
            
            TGChatMessageListView *updatedView = [[TGChatMessageListView alloc] initWithMessages:updatedMessages earlierReferenceMessageId:earlierReferenceMessageId laterReferenceMessageId:nil];
            _currentView = updatedView;
            
            if (_viewUpdated)
                _viewUpdated(updatedView);
            
            _currentView = updatedView;
        }
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesDeleted", [self _conversationIdPathComponent]]])
    {
        /*NSMutableSet *deletedMessageIds = [[NSMutableSet alloc] init];
        for (NSNumber *nMessageId in ((SGraphObjectNode *)resource).object)
        {
            [deletedMessageIds addObject:nMessageId];
        }
        
        for (NSInteger i = 0; i < (NSInteger)_list.count; i++)
        {
            TGMessage *message = _list[i];
            if ([deletedMessageIds containsObject:@(message.mid)])
                [_list removeObjectAtIndex:i];
        }
        
        NSArray *list = [[NSArray alloc] initWithArray:_list];
        if (_listUpdated)
            _listUpdated(list);*/
    }
    else if ([path isEqualToString:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId]])
    {
        NSMutableSet *currentMessageIds = [[NSMutableSet alloc] init];
        for (TGMessage *message in _currentView.messages)
        {
            [currentMessageIds addObject:@(message.mid)];
        }
        
        NSArray *midMessagePairs = ((SGraphObjectNode *)resource).object;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSUInteger i = 0; i < midMessagePairs.count; i += 2)
        {
            dict[midMessagePairs[0]] = midMessagePairs[1];
        }
        
        NSMutableArray *updatedMessages = nil;
        for (NSUInteger i = 0 ; i < _currentView.messages.count; i++)
        {
            TGMessage *previousMessage = _currentView.messages[i];
            TGMessage *updatedMessage = dict[@(previousMessage.mid)];
            if (updatedMessage != nil)
            {
                if (![currentMessageIds containsObject:@(updatedMessage.mid)])
                {
                    [currentMessageIds addObject:@(updatedMessage.mid)];
                    
                    updatedMessage.date = previousMessage.date;
                    if (updatedMessages == nil)
                        updatedMessages = [[NSMutableArray alloc] initWithArray:_currentView.messages];
                    updatedMessages[i] = updatedMessage;
                }
            }
        }
        
        if (updatedMessages != nil)
        {
            //[TGChatMessageListAdapter sortMessageList:_list];
            
            NSNumber *earlierReferenceMessageId = nil;
            NSNumber *laterReferenceMessageId = nil;
            
            for (NSUInteger i = 0; i < updatedMessages.count; i++)
            {
                if (i >= _rangeMessageCount / 5)
                {
                    TGMessage *bottomMessage = updatedMessages[i];
                    TGMessage *topMessage = updatedMessages[updatedMessages.count - i - 1];
                    
                    earlierReferenceMessageId = @(topMessage.mid);
                    laterReferenceMessageId = @(bottomMessage.mid);
                    
                    break;
                }
            }
            
            TGChatMessageListView *updatedView = [[TGChatMessageListView alloc] initWithMessages:updatedMessages earlierReferenceMessageId:earlierReferenceMessageId laterReferenceMessageId:_currentView.laterReferenceMessageId == nil ? nil : laterReferenceMessageId];
            _currentView = updatedView;
            
            if (_viewUpdated)
                _viewUpdated(updatedView);
            
            _currentView = updatedView;
        }
    }
    else if ([path isEqualToString:@"/tg/conversation/*/readmessages"])
    {
        TGSharedPtrWrapper *ptrWrapper = ((SGraphObjectNode *)resource).object;
        if (ptrWrapper == nil)
            return;
        
        std::tr1::shared_ptr<std::set<int> > mids = std::tr1::static_pointer_cast<std::set<int> >([ptrWrapper ptr]);
        
        if (mids != NULL)
        {
            NSMutableSet *messageIds = [[NSMutableSet alloc] init];
            for (int mid : *(mids.get()))
            {
                [messageIds addObject:@(mid)];
            }
            
            NSMutableArray *updatedMessages = nil;
            for (NSUInteger i = 0; i < _currentView.messages.count; i++)
            {
                TGMessage *previousMessage = _currentView.messages[i];
                if ([messageIds containsObject:@(i)])
                {
                    TGMessage *updatedMessage = [previousMessage copy];
                    updatedMessage.unread = false;
                    if (updatedMessages == nil)
                        updatedMessages = [[NSMutableArray alloc] init];
                    updatedMessages[i] = updatedMessage;
                }
            }
            
            if (updatedMessages != nil)
            {
                TGChatMessageListView *updatedView = [[TGChatMessageListView alloc] initWithMessages:updatedMessages earlierReferenceMessageId:_currentView.earlierReferenceMessageId laterReferenceMessageId:_currentView.laterReferenceMessageId];
                _currentView = updatedView;
                
                if (_viewUpdated)
                    _viewUpdated(updatedView);
                
                _currentView = updatedView;
            }
        }
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/readmessages", [self _conversationIdPathComponent]]])
    {
        bool isOutbox = [resource[@"outbox"] boolValue];
        int32_t maxMessageId = [resource[@"maxMessageId"] intValue];
        
        NSMutableArray *updatedMessages = nil;
        NSInteger index = -1;
        for (TGMessage *message in _currentView.messages)
        {
            index++;
            if (message.outgoing == isOutbox && message.mid <= maxMessageId && message.unread)
            {
                if (updatedMessages == nil)
                    updatedMessages = [[NSMutableArray alloc] initWithArray:_currentView.messages];
                TGMessage *updatedMessage = [message copy];
                updatedMessage.unread = false;
                updatedMessages[index] = updatedMessage;
            }
        }
        
        if (updatedMessages != nil)
        {
            TGChatMessageListView *updatedView = [[TGChatMessageListView alloc] initWithMessages:updatedMessages earlierReferenceMessageId:_currentView.earlierReferenceMessageId laterReferenceMessageId:_currentView.laterReferenceMessageId];
            _currentView = updatedView;
            
            if (_viewUpdated)
                _viewUpdated(updatedView);
            
            _currentView = updatedView;
        }
    }
}

@end

@implementation TGChatMessageListSignal

+ (SSignal *)chatMessageListViewWithPeerId:(int64_t)peerId atMessageId:(int32_t)messageId rangeMessageCount:(NSUInteger)rangeMessageCount
{
    SSignal *chatInitialSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        __block NSArray *topMessages = nil;
        __block bool blockIsAtBottom = true;
        
        [TGDatabaseInstance() dispatchOnDatabaseThread:^
        {
            [TGDatabaseInstance() loadMessagesFromConversation:peerId maxMid:INT_MAX maxDate:INT_MAX maxLocalMid:INT_MAX atMessageId:messageId limit:(int)rangeMessageCount extraUnread:false completion:^(NSArray *messages, bool historyExistsBelow)
            {
                topMessages = messages;
                blockIsAtBottom = !historyExistsBelow;
            }];
            
            int minRemoteMid = INT_MAX;
            int maxRemoteMid = INT_MIN;
            for (TGMessage *message in topMessages)
            {
                if (message.mid < TGMessageLocalMidBaseline)
                {
                    minRemoteMid = MIN(message.mid, minRemoteMid);
                    maxRemoteMid = MAX(message.mid, maxRemoteMid);
                }
            }
            
            if (minRemoteMid <= maxRemoteMid)
            {
                topMessages = [TGDatabaseInstance() excludeMessagesWithHolesFromArray:topMessages peerId:peerId aroundMessageId:0];
            }
        } synchronous:true];
        
        NSMutableArray *sortedTopMessages = [[NSMutableArray alloc] initWithArray:topMessages];
        [TGChatMessageListAdapter sortMessageList:sortedTopMessages];
        
        NSNumber *earlierReferenceMessageId = nil;
        NSNumber *laterReferenceMessageId = nil;
        
        for (NSUInteger i = 0; i < sortedTopMessages.count; i++)
        {
            if (i >= rangeMessageCount / 5)
            {
                TGMessage *bottomMessage = sortedTopMessages[i];
                TGMessage *topMessage = sortedTopMessages[sortedTopMessages.count - i - 1];
                
                earlierReferenceMessageId = @(topMessage.mid);
                laterReferenceMessageId = @(bottomMessage.mid);
                
                break;
            }
        }
        
        if (blockIsAtBottom)
            laterReferenceMessageId = nil;
        
        while (sortedTopMessages.count > rangeMessageCount)
        {
            [sortedTopMessages removeLastObject];
        }
        
        TGChatMessageListView *listView = [[TGChatMessageListView alloc] initWithMessages:sortedTopMessages earlierReferenceMessageId:earlierReferenceMessageId laterReferenceMessageId:laterReferenceMessageId];
        
        [subscriber putNext:listView];
        [subscriber putCompletion];
        
        return nil;
    }];
    
    SSignal *channelInitialSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        __block NSMutableArray *topMessages;
        
        [TGDatabaseInstance() dispatchOnDatabaseThread:^
        {
            TGMessageTransparentSortKey maxSortKey = TGMessageTransparentSortKeyUpperBound(peerId);
            [TGDatabaseInstance() channelMessages:peerId maxTransparentSortKey:maxSortKey count:rangeMessageCount important:true mode:TGChannelHistoryRequestAround completion:^(NSArray *messages, __unused bool hasLater)
            {
                NSMutableArray *filteredMessages = [[NSMutableArray alloc] init];
                for (TGMessage *message in messages)
                {
                    if (message.mid >= 0 && message.fromUid == peerId)
                        [filteredMessages addObject:message];
                }

                topMessages = filteredMessages;
            }];
        } synchronous:true];
        
        while (topMessages.count > rangeMessageCount)
        {
            [topMessages removeLastObject];
        }
        
        TGChatMessageListView *listView = [[TGChatMessageListView alloc] initWithMessages:topMessages earlierReferenceMessageId:nil laterReferenceMessageId:nil];
        
        [subscriber putNext:listView];
        [subscriber putCompletion];
        
        return nil;
    }];
    
    SSignal *initialSignal = TGPeerIdIsChannel(peerId) ? channelInitialSignal : chatInitialSignal;
    
    return [initialSignal mapToSignal:^SSignal *(TGChatMessageListView *initialView)
    {
        SSignal *updatedView = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            TGChatMessageListAdapter *adapter = [[TGChatMessageListAdapter alloc] initWithPeerId:peerId currentView:initialView rangeMessageCount:rangeMessageCount viewUpdated:^(TGChatMessageListView *view)
            {
                [subscriber putNext:view];
            }];
            
            return [[SBlockDisposable alloc] initWithBlock:^
            {
                [adapter description];
            }];
        }];
        
        return [[SSignal single:initialView] then:updatedView];
    }];
}

+ (SSignal *)readChatMessageListWithPeerId:(int64_t)peerId
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [TGConversationReadHistoryActor executeStandalone:peerId];
        [subscriber putCompletion];
        
        return nil;
    }];
}

@end
