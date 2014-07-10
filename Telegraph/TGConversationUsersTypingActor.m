#import "TGConversationUsersTypingActor.h"

#import "TGTelegraph.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

@implementation TGConversationUsersTypingActor

+ (NSString *)genericPath
{
    return @"/tg/conversation/@/typing";
}

- (void)execute:(NSDictionary *)__unused options
{
    int64_t conversationId = [[self.path substringWithRange:NSMakeRange(18, self.path.length - 18 - 8)] longLongValue];
    
    NSArray *result = [TGTelegraphInstance userIdsTypingInConversation:conversationId];
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:result]];
}

@end
