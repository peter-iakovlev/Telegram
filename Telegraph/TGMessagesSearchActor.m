#import "TGMessagesSearchActor.h"

#import "TGUserDataRequestBuilder.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGTelegramNetworking.h"
#import "TGTelegraph.h"

#import "TL/TLMetaScheme.h"
#import <MTProtoKit/MTRequest.h>

#import "TGConversation+Telegraph.h"
#import "TGMessage+Telegraph.h"

@interface TGMessagesSearchActor ()
{
    bool _cancelled;
    NSArray *_clientSideResults;
    NSSet *_clientSideMids;
}

@end

@implementation TGMessagesSearchActor

+ (NSString *)genericPath
{
    return @"/tg/search/messages/@";
}

- (void)execute:(NSDictionary *)options
{
    NSString *query = [options objectForKey:@"query"];
    if (query == nil)
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
        return;
    }
    
    [TGDatabaseInstance() searchMessages:query peerId:0 completion:^(NSArray *result, NSSet *midsSet)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            if (_cancelled)
                return;
            
            _clientSideResults = result;
            _clientSideMids = midsSet;
            [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"searchResultsUpdated" message:[[SGraphObjectNode alloc] initWithObject:result]];
            
            MTRequest *request = [[MTRequest alloc] init];
            
            TLRPCmessages_search$messages_search *search = [[TLRPCmessages_search$messages_search alloc] init];
            search.peer = [[TLInputPeer$inputPeerEmpty alloc] init];
            search.q = query;
            search.filter = [[TLMessagesFilter$inputMessagesFilterEmpty alloc] init];
            search.min_date = 0;
            search.max_date = 0;
            search.offset = 0;
            search.limit = 100;
            search.max_id = 0;
            request.body = search;
            
            __weak TGMessagesSearchActor *weakSelf = self;
            [request setCompleted:^(TLmessages_Messages *result, __unused NSTimeInterval timestamp, id error)
            {
                [ActionStageInstance() dispatchOnStageQueue:^
                {
                    __strong TGMessagesSearchActor *strongSelf = weakSelf;
                    if (error == nil)
                        [strongSelf messagesSearchSuccess:result];
                    else
                        [strongSelf messagesSearchFailed];
                }];
            }];
            
            [self addCancelToken:request.internalId];
            [[TGTelegramNetworking instance] addRequest:request];
        }];
    }];
}

- (void)messagesSearchSuccess:(TLmessages_Messages *)result
{
    NSMutableSet *messageIdsSet = [[NSMutableSet alloc] initWithSet:_clientSideMids];
    
    NSMutableArray *combinedResults = [[NSMutableArray alloc] init];
    [combinedResults addObjectsFromArray:_clientSideResults];
    
    [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
    
    NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
    
    for (TLChat *chatDesc in result.chats)
    {
        TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
        if (conversation != nil)
            [chats setObject:conversation forKey:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
    }
    
    for (TLMessage *messageDesc in result.messages)
    {
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
        if (message.mid != 0)
        {
            if (![messageIdsSet containsObject:@(message.mid)])
            {
                [messageIdsSet addObject:@(message.mid)];
                
                TGConversation *conversation = nil;
                if (message.cid < 0)
                    conversation = [chats[@(message.cid)] copy];
                else
                {
                    conversation = [[TGConversation alloc] init];
                    conversation.conversationId = message.cid;
                }
                
                if (conversation != nil)
                {
                    [conversation mergeMessage:message];
                    conversation.additionalProperties = @{@"searchMessageId": @(message.mid)};
                    [combinedResults addObject:conversation];
                }
            }
        }
    }
    
    [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"searchResultsUpdated" message:[[SGraphObjectNode alloc] initWithObject:combinedResults]];
}

- (void)messagesSearchFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)cancel
{
    _cancelled = true;
    
    [super cancel];
}

@end
