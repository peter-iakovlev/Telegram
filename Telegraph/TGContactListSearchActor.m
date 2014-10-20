#import "TGContactListSearchActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGUserDataRequestBuilder.h"
#import "TGUser+Telegraph.h"

@implementation TGContactListSearchActor

+ (NSString *)genericPath
{
    return @"/tg/contacts/search/@";
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
    
    [TGDatabaseInstance() searchContacts:query ignoreUid:ignoreUid searchPhonebook:[[options objectForKey:@"searchPhonebook"] boolValue] completion:^(NSDictionary *result)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"localResults" message:result];
            
            if (query.length < 3)
                [ActionStageInstance() actionCompleted:self.path result:nil];
            else
            {
                self.cancelToken = [TGTelegraphInstance doSearchContactsByName:query limit:256 completion:^(TLcontacts_Found *result)
                {
                    __strong TGContactListSearchActor *strongSelf = weakSelf;
                    [strongSelf _processRemoteResults:result];
                }];
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
