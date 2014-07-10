#import "TGMessagesSearchActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

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
    
    [TGDatabaseInstance() searchMessages:query completion:^(NSArray *result)
    {
         [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:result]]; 
    }];
}

@end
