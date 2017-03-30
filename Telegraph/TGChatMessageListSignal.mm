#import "TGChatMessageListSignal.h"

#import "TGDatabase.h"

#import "ActionStage.h"
#import "TGTelegraph.h"

#import "TGSharedPtrWrapper.h"

#import "TGPeerIdAdapter.h"

@interface TGChatMessageListAdapter : NSObject <ASWatcher>
{
    int64_t _peerId;
    void (^_viewUpdated)(TGChatMessageListView *);
    NSUInteger _rangeMessageCount;
    SSignal *_initialSignal;
    
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
    return [[NSString alloc] initWithFormat:@"%lld", _peerId];
}

- (instancetype)initWithPeerId:(int64_t)peerId currentView:(TGChatMessageListView *)currentView rangeMessageCount:(NSUInteger)rangeMessageCount initialSignal:(SSignal *)initialSignal viewUpdated:(void (^)(TGChatMessageListView *))viewUpdated
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _viewUpdated = [viewUpdated copy];
        _currentView = currentView;
        _rangeMessageCount = rangeMessageCount;
        _initialSignal = initialSignal;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];

        
        if (_currentView.isChannelGroup)
        {
            [ActionStageInstance() watchForPaths:@
             [
              [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]],
              [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/localMessages", [self _conversationIdPathComponent]],
              [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/unimportantMessages", [self _conversationIdPathComponent]],
              @"/as/updateRelativeTimestamps",
              @"/tg/conversation/*/readmessageContents"
              ] watcher:self];
        }
        else if (TGPeerIdIsChannel(peerId))
        {
            [ActionStageInstance() watchForPaths:@
             [
              [[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", [self _conversationIdPathComponent]],
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
    NSString *conversationId = [self _conversationIdPathComponent];
    
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", conversationId]]
        || [path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/localMessages", conversationId]])
    {
        if (_currentView.laterReferenceMessageId != nil)
            return;
        
        NSArray *messages = ((SGraphObjectNode *)resource).object;
        NSMutableSet *currentMessageIds = [[NSMutableSet alloc] init];
        for (TGMessage *message in _currentView.messages)
            [currentMessageIds addObject:@(message.mid)];
        
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
            [updatedMessages removeLastObject];
        
        TGChatMessageListView *updatedView = [[TGChatMessageListView alloc] initWithMessages:updatedMessages earlierReferenceMessageId:nil laterReferenceMessageId:nil];
        updatedView.rangeCount = _currentView.rangeCount;
        updatedView.maybeHasMessagesOnTop = _currentView.maybeHasMessagesOnTop;
        updatedView.isChannel = _currentView.isChannel;
        updatedView.isChannelGroup = _currentView.isChannelGroup;
        _currentView = updatedView;
        
        if (_viewUpdated)
            _viewUpdated(updatedView);
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/unimportantMessages", [self _conversationIdPathComponent]]])
    {
        //if (((NSArray *)resource[@"removed"]).count != 0)
        //    [self _deleteMessages:resource[@"removed"] animated:true];
        
        if (((NSArray *)resource[@"added"]).count != 0)
        {
            [self actionStageResourceDispatched:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messages", conversationId] resource:[[SGraphObjectNode alloc] initWithObject:resource[@"added"]] arguments:@{@"treatIncomingAsUnread": @true}];
        }
        
        //if (((NSDictionary *)resource[@"updated"]).count != 0)
        //    [self _updateMessages:resource[@"updated"]];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%@)/messagesDeleted", [self _conversationIdPathComponent]]])
    {
        NSMutableSet *deletedMessageIds = [[NSMutableSet alloc] init];
        for (NSNumber *nMessageId in ((SGraphObjectNode *)resource).object)
            [deletedMessageIds addObject:nMessageId];
        
        NSMutableArray *updatedMessages = [[NSMutableArray alloc] initWithArray:_currentView.messages];
        for (NSInteger i = 0; i < (NSInteger)updatedMessages.count; i++)
        {
            TGMessage *message = updatedMessages[i];
            if ([deletedMessageIds containsObject:@(message.mid)])
            {
                [updatedMessages removeObjectAtIndex:i];
                i--;
            }
        }
        
        if (updatedMessages.count < _rangeMessageCount && _currentView.maybeHasMessagesOnTop)
        {
            [_initialSignal startWithNext:^(TGChatMessageListView *view)
            {
                _currentView = view;
                
                if (_viewUpdated)
                    _viewUpdated(view);
            }];
        }
        else
        {
            TGChatMessageListView *updatedView = [[TGChatMessageListView alloc] initWithMessages:updatedMessages earlierReferenceMessageId:nil laterReferenceMessageId:nil];
            updatedView.rangeCount = _currentView.rangeCount;
            updatedView.maybeHasMessagesOnTop = _currentView.maybeHasMessagesOnTop;
            updatedView.isChannel = _currentView.isChannel;
            updatedView.isChannelGroup = _currentView.isChannelGroup;
            _currentView = updatedView;
            
            if (_viewUpdated)
                _viewUpdated(updatedView);
        }
    }
    else if ([path isEqualToString:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId]])
    {
        NSMutableSet *currentMessageIds = [[NSMutableSet alloc] init];
        for (TGMessage *message in _currentView.messages)
            [currentMessageIds addObject:@(message.mid)];
        
        NSArray *midMessagePairs = ((SGraphObjectNode *)resource).object;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSUInteger i = 0; i < midMessagePairs.count; i += 2)
            dict[midMessagePairs[i]] = midMessagePairs[i + 1];
        
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
            updatedView.rangeCount = _currentView.rangeCount;
            updatedView.maybeHasMessagesOnTop = _currentView.maybeHasMessagesOnTop;
            updatedView.isChannel = _currentView.isChannel;
            updatedView.isChannelGroup = _currentView.isChannelGroup;
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
    NSUInteger expandedRange = (int)floor(rangeMessageCount * 1.5f);
    SSignal *chatInitialSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        __block NSArray *topMessages = nil;
        __block bool blockIsAtBottom = true;
        
        [TGDatabaseInstance() dispatchOnDatabaseThread:^
        {
            [TGDatabaseInstance() loadMessagesFromConversation:peerId maxMid:INT_MAX maxDate:INT_MAX maxLocalMid:INT_MAX atMessageId:messageId limit:(int)expandedRange extraUnread:false completion:^(NSArray *messages, bool historyExistsBelow)
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
                topMessages = [TGDatabaseInstance() excludeMessagesWithHolesFromArray:topMessages peerId:peerId aroundMessageId:0];
        } synchronous:true];
        
        NSMutableArray *sortedTopMessages = [[NSMutableArray alloc] initWithArray:topMessages];
        [TGChatMessageListAdapter sortMessageList:sortedTopMessages];
        
        while (sortedTopMessages.count > expandedRange)
            [sortedTopMessages removeLastObject];
        
        TGChatMessageListView *listView = [[TGChatMessageListView alloc] initWithMessages:sortedTopMessages earlierReferenceMessageId:nil laterReferenceMessageId:nil];
        listView.rangeCount = rangeMessageCount;
        listView.maybeHasMessagesOnTop = (sortedTopMessages.count > rangeMessageCount);
        
        [subscriber putNext:listView];
        [subscriber putCompletion];
        
        return nil;
    }];
    
    SSignal *(^channelInitialSignal)(int64_t, bool) = ^SSignal *(int64_t peerId, bool isChannelGroup)
    {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            __block NSMutableArray *topMessages;
            
            [TGDatabaseInstance() dispatchOnDatabaseThread:^
            {
                TGMessageTransparentSortKey maxSortKey = TGMessageTransparentSortKeyUpperBound(peerId);
                [TGDatabaseInstance() channelMessages:peerId maxTransparentSortKey:maxSortKey count:expandedRange important:!isChannelGroup mode:TGChannelHistoryRequestAround completion:^(NSArray *messages, __unused bool hasLater)
                {
                    NSMutableArray *filteredMessages = [[NSMutableArray alloc] init];
                    for (TGMessage *message in messages)
                    {
                        if (isChannelGroup || ( message.mid >= 0 && message.fromUid == peerId))
                            [filteredMessages addObject:message];
                    }
                    
                    topMessages = filteredMessages;
                }];
            } synchronous:true];
            
            while (topMessages.count > expandedRange)
                [topMessages removeLastObject];
            
            TGChatMessageListView *listView = [[TGChatMessageListView alloc] initWithMessages:topMessages earlierReferenceMessageId:nil laterReferenceMessageId:nil];
            listView.rangeCount = rangeMessageCount;
            listView.maybeHasMessagesOnTop = (topMessages.count > rangeMessageCount);
            listView.isChannel = true;
            listView.isChannelGroup = isChannelGroup;
            
            [subscriber putNext:listView];
            [subscriber putCompletion];
            
            return nil;
        }];
    };
    
    SSignal *initialSignal = nil;
    
    if (TGPeerIdIsChannel(peerId))
    {
        initialSignal = [[[TGDatabaseInstance() existingChannel:peerId] take:1] mapToSignal:^SSignal *(TGConversation *channel)
        {
            return channelInitialSignal(peerId, channel.isChannelGroup);
        }];
    }
    else
    {
        initialSignal = chatInitialSignal;
    }
    
    return [initialSignal mapToSignal:^SSignal *(TGChatMessageListView *initialView)
    {
        SSignal *updatedView = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            TGChatMessageListAdapter *adapter = [[TGChatMessageListAdapter alloc] initWithPeerId:peerId currentView:initialView rangeMessageCount:rangeMessageCount initialSignal:initialSignal viewUpdated:^(TGChatMessageListView *view)
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
        [TGDatabaseInstance() transactionReadHistoryForPeerIds:[[NSSet alloc] initWithArray:@[@(peerId)]]];
        [subscriber putCompletion];
        
        return nil;
    }];
}

@end
