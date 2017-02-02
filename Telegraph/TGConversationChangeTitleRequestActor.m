#import "TGConversationChangeTitleRequestActor.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGUserDataRequestBuilder.h"

#import "TGConversation+Telegraph.h"
#import "TGMessage+Telegraph.h"

#import "TGConversationAddMessagesActor.h"

#import "TLUpdates+TG.h"

@implementation TGConversationChangeTitleRequestActor

@synthesize currentTitle = _currentTitle;

+ (NSString *)genericPath
{
    return @"/tg/conversation/@/changeTitle/@";
}

- (void)execute:(NSDictionary *)options
{
    NSString *title = [options objectForKey:@"title"];
    if (title == nil)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    _currentTitle = title;
    
    int64_t conversationId = [[options objectForKey:@"conversationId"] longLongValue];
    
    [TGTelegraphInstance doChangeConversationTitle:conversationId accessHash:[[options objectForKey:@"accessHash"] longLongValue] title:title actor:self];
}

- (void)conversationTitleChangeSuccess:(TLUpdates *)updates
{
    [TGUserDataRequestBuilder executeUserDataUpdate:updates.users];
    
    if (updates.chats.count != 0)
    {
        TGConversation *chatConversation = nil;
        
        if (updates.chats.count != 0)
        {
            NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
            
            for (TLChat *chatDesc in updates.chats)
            {
                TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
                if (conversation != nil)
                {
                    if (chatConversation == nil)
                        chatConversation = conversation;
                    [chats setObject:conversation forKey:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
                }
            }
            
            TGMessage *message = nil;
            if (updates.messages.count != 0)
                message = [[TGMessage alloc] initWithTelegraphMessageDesc:updates.messages.firstObject];
            
            [TGDatabaseInstance() transactionAddMessages:message == nil ? nil : @[message] updateConversationDatas:chats notifyAdded:true];
        }
        
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:chatConversation]];
    }
    else
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)conversationTitleChangeFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
