#import "TGBlockListRequestActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"

#import "TGDatabase.h"

#import "TGUserDataRequestBuilder.h"

#import "TGUpdateStateRequestBuilder.h"

#include <vector>

static int cachedBlockListVersion = -1;

@implementation TGBlockListRequestActor

+ (NSString *)genericPath
{
    return @"/tg/blockedUsers/@";
}

+ (NSArray *)loadCachedListSync
{
    __block NSArray *result = nil;
    
    [TGDatabaseInstance() dispatchOnDatabaseThread:^
    {
        [TGDatabaseInstance() loadBlockedList:^(NSArray *blockedList)
        {
            std::vector<int> userIds;
            for (NSNumber *nPeerId in blockedList)
            {
                int64_t peerId = [nPeerId longLongValue];
                if (peerId > 0)
                    userIds.push_back((int)peerId);
            }
            std::shared_ptr<std::map<int, TGUser *> > userMap = [TGDatabaseInstance() loadUsers:userIds];
            
            NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:userMap->size()];
            for (NSNumber *nPeerId in blockedList)
            {
                int64_t peerId = [nPeerId longLongValue];
                if (peerId > 0)
                {
                    std::map<int, TGUser *>::iterator it = userMap->find((int)peerId);
                    if (it != userMap->end())
                        [users addObject:it->second];
                }
            }
            
            result = users;
        }];
    } synchronous:true];
    
    return result;
}

- (void)prepare:(NSDictionary *)__unused options
{
    if ([self.path hasSuffix:@"(force)"])
        self.requestQueueName = @"settings";
}

- (void)execute:(NSDictionary *)__unused options
{
    if ([self.path hasSuffix:@"(force)"])
    {
        self.cancelToken = [TGTelegraphInstance doRequestBlockList:self];
    }
    else
    {
        int uid = [[options objectForKey:@"uid"] intValue];
        if (uid != 0)
        {
            [TGDatabaseInstance() loadPeerIsBlocked:uid completion:^(bool blocked)
            {
                [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:[[NSNumber alloc] initWithBool:blocked]]];
            }];
        }
        else
        {
            [TGDatabaseInstance() loadBlockedList:^(NSArray *blockedList)
            {
                std::vector<int> userIds;
                for (NSNumber *nPeerId in blockedList)
                {
                    int64_t peerId = [nPeerId longLongValue];
                    if (peerId > 0)
                        userIds.push_back((int)peerId);
                }
                std::shared_ptr<std::map<int, TGUser *> > userMap = [TGDatabaseInstance() loadUsers:userIds];
                
                NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:userMap->size()];
                for (NSNumber *nPeerId in blockedList)
                {
                    int64_t peerId = [nPeerId longLongValue];
                    if (peerId > 0)
                    {
                        std::map<int, TGUser *>::iterator it = userMap->find((int)peerId);
                        if (it != userMap->end())
                            [users addObject:it->second];
                    }
                }
                
                [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:users]];
                
                if (cachedBlockListVersion < [TGUpdateStateRequestBuilder stateVersion])
                {
                    [ActionStageInstance() requestActor:@"/tg/blockedUsers/(force)" options:nil watcher:TGTelegraphInstance];
                }
            }];
        }
    }
}

- (void)blockListRequestSuccess:(TLcontacts_Blocked *)contactsBlocked
{
    [TGUserDataRequestBuilder executeUserDataUpdate:contactsBlocked.users];
    
    std::map<int64_t, bool> peerIdToBlockedMap;
    for (TGChangePeerBlockStatusFutureAction *action in [TGDatabaseInstance() loadFutureActionsWithType:TGChangePeerBlockStatusFutureActionType])
    {
        peerIdToBlockedMap.insert(std::pair<int64_t, bool>(action.uniqueId, action.block));
    }
    
    NSMutableArray *filteredBlocked = [[NSMutableArray alloc] init];
    for (TLContactBlocked *contactBlocked in contactsBlocked.blocked)
    {
        std::map<int64_t, bool>::iterator it = peerIdToBlockedMap.find(contactBlocked.user_id);
        if (it == peerIdToBlockedMap.end() || it->second)
        {
            [filteredBlocked addObject:contactBlocked];
            if (it != peerIdToBlockedMap.end())
                peerIdToBlockedMap.erase(it);
        }
    }
    
    for (std::map<int64_t, bool>::iterator it = peerIdToBlockedMap.begin(); it != peerIdToBlockedMap.end(); it++)
    {
        if (it->second)
        {
            TLContactBlocked$contactBlocked *contactBlocked = [[TLContactBlocked$contactBlocked alloc] init];
            contactBlocked.user_id = (int)it->first;
            contactBlocked.date = [TGDatabaseInstance() loadBlockedDate:it->first];
            [filteredBlocked addObject:contactBlocked];
        }
    }
    
    NSArray *sortedBlocked = [filteredBlocked sortedArrayUsingComparator:^NSComparisonResult(TLContactBlocked *contact1, TLContactBlocked *contact2)
    {
        return contact1.date > contact2.date ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSMutableArray *blockedPeerRecords = [[NSMutableArray alloc] init];
    
    for (TLContactBlocked *contactBlocked in sortedBlocked)
    {
        [blockedPeerRecords addObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithLongLong:contactBlocked.user_id], [[NSNumber alloc] initWithInt:contactBlocked.date], nil]];
        
        TGUser *user = [TGDatabaseInstance() loadUser:contactBlocked.user_id];
        if (user != nil)
            [result addObject:user];
    }
    
    [TGDatabaseInstance() replaceBlockedList:blockedPeerRecords];
    
    cachedBlockListVersion = [TGUpdateStateRequestBuilder stateVersion];
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:result]];
    
    if ([self.path hasSuffix:@"(force)"])
    {
        [ActionStageInstance() dispatchResource:@"/tg/blockedUsers" resource:[[SGraphObjectNode alloc] initWithObject:result]];
    }
}

- (void)blockListRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

@end
