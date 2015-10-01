#import "TGContactsGlobalSearchActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"

#import "TGUser+Telegraph.h"

#import "TGTimer.h"

@interface TGContactsGlobalSearchActor ()

@property (nonatomic, strong) TGTimer *delayTimer;

@end

@implementation TGContactsGlobalSearchActor

@synthesize delayTimer = _delayTimer;

+ (NSString *)genericPath
{
    return @"/tg/contacts/globalSearch/@";
}

- (void)execute:(NSDictionary *)options
{
    NSString *query = [options objectForKey:@"query"];
    if (query.length < 1)
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
        return;
    }
    
    _delayTimer = [[TGTimer alloc] initWithTimeout:0.15 repeat:false completion:^
    {
        self.cancelToken = [TGTelegraphInstance doSearchContacts:query limit:100 actor:self];
    } queue:[ActionStageInstance() globalStageDispatchQueue]];
    [_delayTimer start];
}

- (void)searchSuccess:(TLcontacts_Found *)contactsFound
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *parsedUsers = [[NSMutableDictionary alloc] initWithCapacity:contactsFound.users.count];
    for (TLUser *userDesc in contactsFound.users)
    {
        TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:userDesc];
        if (user.uid != 0)
            [parsedUsers setObject:user forKey:[[NSNumber alloc] initWithInt:user.uid]];
    }
    
    NSMutableArray *foundList = [[NSMutableArray alloc] init];
    
    for (TLPeer *peer in contactsFound.results)
    {
        if ([peer isKindOfClass:[TLPeer$peerUser class]]) {
        TGUser *user = [parsedUsers objectForKey:[[NSNumber alloc] initWithInt:((TLPeer$peerUser *)peer).user_id]];
            if (user != nil)
            {
                [foundList addObject:user];
            }
        }
    }
    
    [resultDict setObject:foundList forKey:@"foundUsers"];
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:resultDict]];
}

- (void)searchFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

- (void)cancel
{
    if (_delayTimer != nil)
    {
        [_delayTimer invalidate];
        _delayTimer = nil;
    }
    
    [super cancel];
}

@end
