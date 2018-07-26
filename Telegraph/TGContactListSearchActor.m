#import "TGContactListSearchActor.h"

#import <LegacyComponents/ActionStage.h>
#import <LegacyComponents/SGraphObjectNode.h>

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGUserDataRequestBuilder.h"
#import "TGUser+Telegraph.h"

#import "TGTimer.h"

@interface TGContactListSearchActor ()
{
    TGTimer *_timer;
    bool _onlyMy;
    bool _ignoreMy;
}

@end

@implementation TGContactListSearchActor

+ (NSString *)genericPath
{
    return @"/tg/contacts/search/@";
}

- (void)dealloc
{
    [_timer invalidate];
}

- (void)execute:(NSDictionary *)options
{
    NSString *query = [options objectForKey:@"query"];
    if (query == nil)
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
        return;
    }
    
    int ignoreUid = [[options objectForKey:@"ignoreUid"] intValue];
    _onlyMy = [[options objectForKey:@"onlyMy"] boolValue];
    _ignoreMy = [[options objectForKey:@"ignoreMy"] boolValue];
    
    __weak TGContactListSearchActor *weakSelf = self;
    
    NSTimeInterval delayStart = CFAbsoluteTimeGetCurrent();
    [TGDatabaseInstance() searchContacts:query ignoreUid:ignoreUid searchPhonebook:[[options objectForKey:@"searchPhonebook"] boolValue] completion:^(NSDictionary *result)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"localResults" message:result];
            
            if (query.length < 5 || _onlyMy)
                [ActionStageInstance() actionCompleted:self.path result:nil];
            else
            {
                _timer = [[TGTimer alloc] initWithTimeout:MAX(0.0, CFAbsoluteTimeGetCurrent() - delayStart - 150) repeat:false completion:^{
                    __strong TGContactListSearchActor *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        strongSelf.cancelToken = [TGTelegraphInstance doSearchContactsByName:query limit:1 completion:^(TLcontacts_Found *result)
                        {
                            __strong TGContactListSearchActor *strongSelf = weakSelf;
                            [strongSelf _processRemoteResults:result];
                        }];
                    }
                } queue:[ActionStageInstance() globalStageDispatchQueue]];
                [_timer start];
            }
        }];
    }];
}

- (void)_processRemoteResults:(TLcontacts_Found *)result
{
    if (result != nil)
    {
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for (id parsedUser in result.users)
        {
            TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:parsedUser];
            if (user.uid != 0)
                [users addObject:user];
        }
        [TGUserDataRequestBuilder executeUserObjectsUpdate:users];
        
        if (_ignoreMy)
        {
            NSMutableArray *notMyUsers = [[NSMutableArray alloc] init];
            for (TLPeer *peer in result.results)
            {
                if ([peer isKindOfClass:[TLPeer$peerUser class]]) {
                    TGUser *user = [TGDatabaseInstance() loadUser:((TLPeer$peerUser *)peer).user_id];
                    if (user != nil)
                        [notMyUsers addObject:user];
                }
            }
            users = notMyUsers;
        }
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"globalResults" message:@{@"users": users}];
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
