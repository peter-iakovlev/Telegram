#import "TGConversationChatInfoRequestActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGMessage+Telegraph.h"

@implementation TGConversationChatInfoRequestActor

+ (NSString *)genericPath
{
    return @"/tg/conversation/@/conversation";
}

- (void)execute:(NSDictionary *)__unused options
{
    NSString *sConversationId = [self.path substringWithRange:NSMakeRange(18, self.path.length - 18 - 13 - 1)];
    int64_t conversationId = [sConversationId longLongValue];
    if (![[NSString stringWithFormat:@"%lld", conversationId] isEqualToString:sConversationId])
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
        return;
    }
    
    TGConversation *conversation = [[TGDatabase instance] loadConversationWithId:conversationId];
    if (conversation != nil)
    {
        [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:conversation]];
    }
    else
    {
        //TODO
        
        [ActionStageInstance() nodeRetrieveFailed:self.path];
    }
}

- (void)chatInfoRequestSuccess:(NSDictionary *)__unused responseData
{
    
}

- (void)chatInfoRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

@end
