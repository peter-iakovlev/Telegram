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
    
    [[TGDatabase instance] searchDialogs:query ignoreUid:TGTelegraphInstance.clientUserId partial:false completion:^(NSDictionary *result, __unused bool isFinal)
    {
        [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:result]];
    } isCancelled:nil];
}

@end
