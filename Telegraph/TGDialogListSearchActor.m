#import "TGDialogListSearchActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"

#import "TGDatabase.h"

@implementation TGDialogListSearchActor

+ (NSString *)genericPath
{
    return @"/tg/search/dialogs/@";
}

- (void)execute:(NSDictionary *)options
{
    NSString *query = [options objectForKey:@"query"];
    if (query == nil)
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
        return;
    }
    
    [[TGDatabase instance] searchDialogs:query ignoreUid:TGTelegraphInstance.clientUserId completion:^(NSDictionary *result)
    {
        [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:result]];
    }];
}

@end
