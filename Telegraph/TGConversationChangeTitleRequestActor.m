#import "TGConversationChangeTitleRequestActor.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGUserDataRequestBuilder.h"

#import "TGConversation+Telegraph.h"
#import "TGMessage+Telegraph.h"

#import "TGConversationAddMessagesActor.h"

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
    
    int64_t conversationId = [[options objectForKey:@"conversationId"] intValue];
    
    [TGTelegraphInstance doChangeConversationTitle:conversationId title:title actor:self];
}

- (void)conversationTitleChangeSuccess:(TLmessages_StatedMessage *)statedMessage
{
    [TGUserDataRequestBuilder executeUserDataUpdate:statedMessage.users];
    
    if (statedMessage.chats.count != 0)
    {
        TGConversation *chatConversation = nil;
        
        if (statedMessage.chats.count != 0)
        {
            NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
            
            for (TLChat *chatDesc in statedMessage.chats)
            {
                TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
                if (conversation != nil)
                {
                    if (chatConversation == nil)
                        chatConversation = conversation;
                    [chats setObject:conversation forKey:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
                }
            }
            
            TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:statedMessage.message];
            
            static int actionId = 0;
            [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(changeTitle%d)", actionId++]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:chats, @"chats", @[message], @"messages", nil]];
        }
        
        [[TGTelegramNetworking instance] updatePts:statedMessage.pts date:0 seq:statedMessage.seq];
        
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
