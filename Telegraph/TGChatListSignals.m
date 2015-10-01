#import "TGChatListSignals.h"

#import "TGDatabase.h"

#import "ActionStage.h"
#import "TGTelegraph.h"

@interface TGChatListAdapter : NSObject <ASWatcher>
{
    NSMutableArray *_list;
    void (^_listUpdated)(NSArray *);
    NSUInteger _limit;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGChatListAdapter

- (instancetype)initWithList:(NSArray *)list limit:(NSUInteger)limit listUpdated:(void (^)(NSArray *))listUpdated
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        [ActionStageInstance() watchForPaths:@[
            @"/tg/conversations",
            @"/tg/broadcastConversations",
            @"/tg/channelListSyncrhonized",
            @"/dialogListReloaded"
        ] watcher:self];
        
        _list = [[NSMutableArray alloc] init];
        [_list addObjectsFromArray:list];
        
        _limit = limit;
        
        _listUpdated = [listUpdated copy];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/dialogListReloaded"])
    {
        [TGDatabaseInstance() loadConversationListFromDate:INT_MAX limit:(int)_limit excludeConversationIds:@[] completion:^(NSArray *chatList)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                NSMutableArray *filteredList = [[NSMutableArray alloc] initWithArray:chatList];
//                for (NSInteger i = 0; i < (NSInteger)filteredList.count; i++) {
//                    TGConversation *conversation = filteredList[i];
//                    if (conversation.isChannel) {
//                        [filteredList removeObjectAtIndex:i];
//                        i--;
//                    }
//                }
                
                [_list removeAllObjects];
                [_list addObjectsFromArray:filteredList];
                NSArray *items = [NSArray arrayWithArray:_list];
                if (_listUpdated)
                    _listUpdated(items);
            }];
        }];
    }
    else if ([path isEqualToString:@"/tg/conversations"] || [path isEqualToString:@"/tg/broadcastConversations"])
    {
        NSMutableArray *conversations = [((SGraphObjectNode *)resource).object mutableCopy];
        if (conversations.count == 0)
            return;
        
        for (NSInteger i = 0; i < (NSInteger)conversations.count; i++)
        {
            TGConversation *conversation = conversations[i];
            if (conversation.isChannel && conversation.kind != TGConversationKindPersistentChannel)
            {
                [conversations removeObjectAtIndex:i];
                i--;
            }
        }
        
        [conversations sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            int date1 = (int)((TGConversation *)obj1).date;
            int date2 = (int)((TGConversation *)obj2).date;
            
            if (date1 < date2)
                return NSOrderedAscending;
            else if (date1 > date2)
                return NSOrderedDescending;
            else
                return NSOrderedSame;
        }];
        
        NSMutableDictionary *conversationIdToIndex = [[NSMutableDictionary alloc] init];
        int index = -1;
        for (TGConversation *conversation in _list)
        {
            index++;
            int64_t conversationId = conversation.conversationId;
            conversationIdToIndex[@(conversationId)] = @(index);
        }
        
        for (int i = 0; i < (int)conversations.count; i++)
        {
            TGConversation *conversation = [conversations objectAtIndex:i];
            int64_t conversationId = conversation.conversationId;
            NSNumber *conversationIndex = conversationIdToIndex[@(conversationId)];
            if (conversationIndex != nil)
            {
                TGConversation *newConversation = [conversation copy];
                if (!newConversation.isDeleted)
                {
                    //[self initializeDialogListData:newConversation customUser:nil selfUser:selfUser];
                }
                
                [_list replaceObjectAtIndex:[conversationIndex unsignedIntegerValue] withObject:newConversation];
                [conversations removeObjectAtIndex:i];
                i--;
            }
        }
        
        for (int i = 0; i < (int)_list.count; i++)
        {
            TGConversation *conversation = [_list objectAtIndex:i];
            if (conversation.isDeleted)
            {
                [_list removeObjectAtIndex:i];
                i--;
            }
        }
        
        for (TGConversation *conversation in conversations)
        {
            TGConversation *newConversation = [conversation copy];
            if (!newConversation.isDeleted)
            {
                //[self initializeDialogListData:newConversation customUser:nil selfUser:selfUser];
                
                [_list addObject:newConversation];
            }
        }
        
        [_list sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            int date1 = (int)((TGConversation *)obj1).date;
            int date2 = (int)((TGConversation *)obj2).date;
            
            if (date1 < date2)
                return NSOrderedDescending;
            else if (date1 > date2)
                return NSOrderedAscending;
            else
                return NSOrderedSame;
        }];
        
        NSArray *items = [NSArray arrayWithArray:_list];
        
        if (_listUpdated)
            _listUpdated(items);
    }
    else if ([path isEqualToString:@"/tg/channelListSyncrhonized"]) {
        [self actionStageResourceDispatched:@"/tg/conversations" resource:[[SGraphObjectNode alloc] initWithObject:resource] arguments:@{@"filterEarliest": @true}];
    }
}

@end

@implementation TGChatListSignals

+ (SSignal *)currentChatListWithLimit:(NSUInteger)limit
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [TGDatabaseInstance() loadConversationListFromDate:INT_MAX limit:(int)limit excludeConversationIds:@[] completion:^(NSArray *chatList)
        {
            NSMutableArray *filteredResult = [[NSMutableArray alloc] initWithArray:chatList];
            [filteredResult sortUsingComparator:^NSComparisonResult(TGConversation *lhs, TGConversation *rhs) {
                if (lhs.date > rhs.date) {
                    return NSOrderedAscending;
                } else if (lhs.date < rhs.date) {
                    return NSOrderedDescending;
                } else {
                    if (lhs.conversationId < rhs.conversationId) {
                        return NSOrderedDescending;
                    } else {
                        return NSOrderedAscending;
                    }
                }
            }];
            
            for (NSUInteger i = 0; i < filteredResult.count; i++)
            {
                TGConversation *conversation = filteredResult[i];
                if (conversation.isChannel && conversation.kind != TGConversationKindPersistentChannel)
                {
                    [filteredResult removeObjectAtIndex:i];
                    i--;
                }
            }
            
            [subscriber putNext:filteredResult];
            [subscriber putCompletion];
        }];
        
        return nil;
    }];
}

+ (SSignal *)chatListWithLimit:(NSUInteger)limit
{
    __block NSArray *initialList = nil;
    
    SSignal *incrementalSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGChatListAdapter *adapter = [[TGChatListAdapter alloc] initWithList:initialList limit:limit listUpdated:^(NSArray *list)
        {
            [subscriber putNext:list];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [adapter description];
        }];
    }];
    
    return [[[self currentChatListWithLimit:limit] onNext:^(id next)
    {
        initialList = next;
    }] then:incrementalSignal];
}

@end
