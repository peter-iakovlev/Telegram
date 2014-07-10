#import "TGSuggestedContactsRequestActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"

#import "TGUser+Telegraph.h"

#import "TGUserDataRequestBuilder.h"

static NSDictionary *cachedSuggestions = nil;

@implementation TGSuggestedContactsRequestActor

+ (NSString *)genericPath
{
    return @"/tg/suggestedContacts/@";
}

+ (void)clearCache
{
    cachedSuggestions = nil;
}

- (void)execute:(NSDictionary *)__unused options
{
    if ([self.path hasSuffix:@"cached)"] && cachedSuggestions != nil)
    {
        [ActionStageInstance() requestActor:@"/tg/suggestedContacts/(force)" options:nil watcher:TGTelegraphInstance];
        
        [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:cachedSuggestions]];
    }
    else
    {
        self.cancelToken = [TGTelegraphInstance doRequestSuggestedContacts:100 actor:self];
    }
}

- (void)suggestedContactsRequestSuccess:(TLcontacts_Suggested *)suggestedContacts
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    [TGUserDataRequestBuilder executeUserDataUpdate:suggestedContacts.users];
    
    NSMutableDictionary *parsedUsers = [[NSMutableDictionary alloc] initWithCapacity:suggestedContacts.users.count];
    for (TLUser *userDesc in suggestedContacts.users)
    {
        TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:userDesc];
        if (user.uid != 0)
            [parsedUsers setObject:user forKey:[[NSNumber alloc] initWithInt:user.uid]];
    }
    
    NSMutableArray *suggestedList = [[NSMutableArray alloc] init];
    
    for (TLContactSuggested *contactDesc in suggestedContacts.results)
    {
        TGUser *user = [parsedUsers objectForKey:[[NSNumber alloc] initWithInt:contactDesc.user_id]];
        if (user != nil)
        {
            user.customProperties = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:contactDesc.mutual_contacts], @"mutualContactsCount", nil];
            [suggestedList addObject:user];
        }
    }
    
    [resultDict setObject:suggestedList forKey:@"suggestedContacts"];
    
    cachedSuggestions = resultDict;
    
    if ([self.path hasSuffix:@"force)"])
        [ActionStageInstance() dispatchResource:@"/tg/suggestedContacts" resource:[[SGraphObjectNode alloc] initWithObject:resultDict]];
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:resultDict]];
}

- (void)suggestedContactsRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

@end
