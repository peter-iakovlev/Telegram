#import "TGGlobalMessageSearchSignals.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"
#import "TGUserDataRequestBuilder.h"
#import "TGConversation+Telegraph.h"
#import "TGMessage+Telegraph.h"
#import "TGPeerIdAdapter.h"

#import "TGRecentHashtagsSignal.h"

@implementation TGGlobalMessageSearchSignals

+ (SSignal *)search:(NSString *)query includeMessages:(bool)includeMessages itemMapping:(id (^)(id))itemMapping
{
    if ([query isEqualToString:@"#"] && includeMessages)
    {
        return [[TGRecentHashtagsSignal recentHashtagsFromSpaces:TGHashtagSpaceEntered | TGHashtagSpaceSearchedBy] map:^id (NSArray *recentHashtags)
        {
            return @{@"hashtags": recentHashtags == nil ? @[] : recentHashtags};
        }];
    }
    else
    {
        SSignal *searchDialogsSignal = [[self searchDialogs:query] map:^id (NSDictionary *dict)
        {
            NSMutableArray *result = [[NSMutableArray alloc] init];
            
            for (id item in dict[@"chats"])
            {
                id mappedItem = itemMapping(item);
                if (mappedItem != nil)
                    [result addObject:mappedItem];
            }
            
            for (id item in dict[@"users"])
            {
                id mappedItem = itemMapping(item);
                if (mappedItem != nil)
                    [result addObject:mappedItem];
            }
            
            return result;
        }];
        
        SSignal *searchUsersSignal = [[[self searchUsersAndChannels:query] deliverOn:[SQueue wrapConcurrentNativeQueue:[TGDatabaseInstance() databaseQueue]]] map:^id (NSArray *peers)
        {
            NSMutableArray *result = [[NSMutableArray alloc] init];
            for (id item in peers)
            {
                id mappedItem = itemMapping(item);
                if (mappedItem != nil)
                    [result addObject:mappedItem];
            }
            
            return result;
        }];
        
        SSignal *searchMessagesSignal = [SSignal single:@[]];
        
        if (includeMessages)
        {
            searchMessagesSignal = [[[self searchMessages:query peerId:0 accessHash:0] deliverOn:[SQueue wrapConcurrentNativeQueue:[TGDatabaseInstance() databaseQueue]]] map:^id (NSArray *conversations)
            {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                for (id item in conversations)
                {
                    id mappedItem = itemMapping(item);
                    if (mappedItem != nil)
                        [result addObject:mappedItem];
                }
                
                [result sortUsingComparator:^NSComparisonResult(TGConversation *conversation1, TGConversation *conversation2)
                {
                    return conversation1.date > conversation2.date ? NSOrderedAscending : NSOrderedDescending;
                }];
                
                return result;
            }];
        }
        
        return [[SSignal combineSignals:@[searchDialogsSignal, searchUsersSignal, searchMessagesSignal]] map:^id (NSArray *results)
        {
            NSMutableArray *globalResults = [[NSMutableArray alloc] initWithArray:results[1]];
            for (NSUInteger i = 0; i < globalResults.count; i++)
            {
                int64_t peerId = 0;
                if ([globalResults[i] isKindOfClass:[TGUser class]]) {
                    peerId = ((TGUser *)globalResults[i]).uid;
                } else if ([globalResults[i] isKindOfClass:[TGConversation class]]) {
                    peerId = ((TGConversation *)globalResults[i]).conversationId;
                }
                
                bool found = false;
                
                for (id item in results[0])
                {
                    if ([item isKindOfClass:[TGConversation class]])
                    {
                        if (((TGConversation *)item).conversationId == peerId || ((TGConversation *)item).conversationId == TGTelegraphInstance.clientUserId)
                        {
                            found = true;
                            break;
                        }
                    }
                    else if ([item isKindOfClass:[TGUser class]])
                    {
                        if (((TGUser *)item).uid == peerId || ((TGUser *)item).uid == TGTelegraphInstance.clientUserId)
                        {
                            found = true;
                            break;
                        }
                    }
                }
                
                if (found)
                {
                    [globalResults removeObjectAtIndex:i];
                    i--;
                }
            }
            return @{@"dialogs": results[0], @"global": globalResults, @"messages": results[2]};
        }];
    }
}

+ (SSignal *)searchMessages:(NSString *)query peerId:(int64_t)peerId accessHash:(int64_t)accessHash itemMapping:(id (^)(id))itemMapping
{
    return [[[self searchMessages:query peerId:peerId accessHash:accessHash] deliverOn:[SQueue wrapConcurrentNativeQueue:[TGDatabaseInstance() databaseQueue]]] map:^id (NSArray *conversations)
    {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (id item in conversations)
        {
            id mappedItem = itemMapping(item);
            if (mappedItem != nil)
                [result addObject:mappedItem];
        }
        
        [result sortUsingComparator:^NSComparisonResult(TGConversation *conversation1, TGConversation *conversation2)
        {
            return conversation1.date > conversation2.date ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        return result;
    }];
}

+ (SSignal *)searchDialogs:(NSString *)query
{
    return [[SSignal alloc] initWithGenerator:^(SSubscriber *subscriber)
    {
        __block bool isCancelled = false;
        [TGDatabaseInstance() searchDialogs:query ignoreUid:TGTelegraphInstance.clientUserId partial:true completion:^(NSDictionary *dict, bool isFinal)
        {
            [subscriber putNext:dict];
            if (isFinal)
                [subscriber putCompletion];
        } isCancelled:^bool
        {
            return isCancelled;
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            isCancelled = true;
        }];
    }];
}

+ (SSignal *)searchUsersAndChannels:(NSString *)query
{
    TLRPCcontacts_search$contacts_search *search = [[TLRPCcontacts_search$contacts_search alloc] init];
    search.q = query;
    search.limit = 32;
    SSignal *remoteSignal = [[[[TGTelegramNetworking instance] requestSignal:search] delay:0.15 onQueue:[SQueue concurrentDefaultQueue]] map:^id(TLcontacts_Found *result)
    {
        [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
        
        NSMutableArray<TGConversation *> *conversations = [[NSMutableArray alloc] init];
        for (TLChat *chat in result.chats) {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
            if (conversation.isChannel) {
                [conversations addObject:conversation];
            }
        }
        
        [TGDatabaseInstance() updateChannels:conversations];
        
        NSMutableArray *peers = [[NSMutableArray alloc] init];
        
        for (TLPeer *peer in result.results)
        {
            if ([peer isKindOfClass:[TLPeer$peerUser class]]) {
                TGUser *user = [TGDatabaseInstance() loadUser:((TLPeer$peerUser *)peer).user_id];
                if (user != nil)
                    [peers addObject:user];
            } else if ([peer isKindOfClass:[TLPeer$peerChannel class]]) {
                TLPeer$peerChannel *peerChannel = (TLPeer$peerChannel *)peer;
                int64_t peerId = TGPeerIdFromChannelId(peerChannel.channel_id);
                TGConversation *conversation = [TGDatabaseInstance() loadChannels:@[@(peerId)]][@(peerId)];
                if (conversation != nil) {
                    [peers addObject:conversation];
                }
            }
        }
        
        return peers;
    }];
    
    if (query.length < 5)
        return [SSignal single:@[]];
    else
        return [[SSignal single:@[]] then:remoteSignal];
}

+ (SSignal *)searchMessages:(NSString *)query peerId:(int64_t)peerId accessHash:(int64_t)accessHash
{
    SSignal *(^remoteSignalGenerator)(NSSet *) = ^SSignal *(NSSet *currentMessageIds)
    {
        TLRPCmessages_search$messages_search *search = [[TLRPCmessages_search$messages_search alloc] init];
        if (peerId == 0)
            search.peer = [[TLInputPeer$inputPeerEmpty alloc] init];
        else
            search.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
        
        search.q = query;
        search.filter = [[TLMessagesFilter$inputMessagesFilterEmpty alloc] init];
        search.min_date = 0;
        search.max_date = 0;
        search.offset = 0;
        search.limit = peerId == 0 ? 100 : 160;
        search.max_id = 0;
        SSignal *requestSignal = [[[TGTelegramNetworking instance] requestSignal:search] map:^id(TLmessages_Messages *result)
        {
            [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
            
            NSMutableSet *messageIdsSet = [[NSMutableSet alloc] initWithSet:currentMessageIds];
            
            NSMutableArray *combinedResults = [[NSMutableArray alloc] init];
            
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
            
            return combinedResults;
        }];
        
        if (query.length < 2)
            return [SSignal complete];
        else
        {
            return [requestSignal catch:^SSignal *(__unused id error)
            {
                return [SSignal complete];
            }];
        }
    };
    
    SSignal *combinedSignal = [[[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        
        dispatch_block_t cancelBlock = [TGDatabaseInstance() searchMessages:query peerId:peerId completion:^(NSArray *result, NSSet *midsSet)
        {
            [subscriber putNext:result];
            
            [disposable setDisposable:[[remoteSignalGenerator(midsSet) delay:0.1 onQueue:[SQueue concurrentDefaultQueue]] startWithNext:^(NSArray *remoteResult)
            {
                NSMutableArray *combinedResult = [[NSMutableArray alloc] initWithArray:result];
                [combinedResult addObjectsFromArray:remoteResult];
                [subscriber putNext:combinedResult];
            } error:^(id error)
            {
                [subscriber putError:error];
            } completed:^
            {
                [subscriber putCompletion];
            }]];
        }];
        
        [disposable setDisposable:[[SBlockDisposable alloc] initWithBlock:^
        {
            if (cancelBlock)
                cancelBlock();
        }]];
        
        return disposable;
    }] delay:0.1 onQueue:[SQueue concurrentDefaultQueue]];
    
    return [[SSignal single:@[]] then:combinedSignal];
}

+ (void)clearRecentResults
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Telegram_recentSearch_peers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)addRecentPeerResult:(int64_t)peerId
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Telegram_recentSearch_peers"]];
    [items removeObject:@(peerId)];
    [items insertObject:@(peerId) atIndex:0];
    if (items.count > 20)
        [items removeObjectsInRange:NSMakeRange(20, items.count - 20)];
    [[NSUserDefaults standardUserDefaults] setObject:items forKey:@"Telegram_recentSearch_peers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeRecentPeerResult:(int64_t)peerId
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Telegram_recentSearch_peers"]];
    [items removeObject:@(peerId)];
    [[NSUserDefaults standardUserDefaults] setObject:items forKey:@"Telegram_recentSearch_peers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (SSignal *)recentPeerResults:(id (^)(id))itemMapping
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"Telegram_recentSearch_peers"];
        NSMutableArray *peers = [[NSMutableArray alloc] init];
        for (NSNumber *nPeerId in array)
        {
            int64_t peerId = (int64_t)[nPeerId longLongValue];
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
            if (conversation != nil)
            {
                id item = itemMapping(conversation);
                if (item != nil)
                    [peers addObject:item];
            }
            
            if (conversation == nil)
            {
                TGUser *user = [TGDatabaseInstance() loadUser:(int)peerId];
                if (user != nil)
                    [peers addObject:user];
            }
        }
        [subscriber putNext:peers];
        [subscriber putCompletion];
        
        return nil;
    }];
}

@end
