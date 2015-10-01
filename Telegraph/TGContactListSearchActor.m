#import "TGContactListSearchActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGUserDataRequestBuilder.h"
#import "TGUser+Telegraph.h"

#import "TGTimer.h"

@interface TGContactListSearchActor ()
{
    TGTimer *_timer;
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
    
    __weak TGContactListSearchActor *weakSelf = self;
    
    NSTimeInterval delayStart = CFAbsoluteTimeGetCurrent();
    [TGDatabaseInstance() searchContacts:query ignoreUid:ignoreUid searchPhonebook:[[options objectForKey:@"searchPhonebook"] boolValue] completion:^(NSDictionary *result)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"localResults" message:result];
            
            if (query.length < 5)
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
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"globalResults" message:@{@"users": users}];
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
