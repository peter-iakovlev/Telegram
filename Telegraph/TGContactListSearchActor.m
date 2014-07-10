#import "TGContactListSearchActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

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
    
    [TGDatabaseInstance() searchContacts:query ignoreUid:ignoreUid searchPhonebook:[[options objectForKey:@"searchPhonebook"] boolValue] completion:^(NSDictionary *result)
    {
        [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:result]];
    }];
}

@end
