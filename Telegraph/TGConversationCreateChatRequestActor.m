#import "TGConversationCreateChatRequestActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGSchema.h"

#import "TGUserDataRequestBuilder.h"
#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "TGConversationAddMessagesActor.h"

#import "TLUpdates+TG.h"

@interface TGConversationCreateChatRequestActor ()

@property (nonatomic, strong) NSArray *uids;

@end

@implementation TGConversationCreateChatRequestActor

+ (NSString *)genericPath
{
    return @"/tg/conversation/createChat/@";
}

- (void)execute:(NSDictionary *)options
{
    _uids = [options objectForKey:@"uids"];
    NSString *title = [options objectForKey:@"title"];
    if (_uids == nil || title == nil)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
        return;
    }
    
    self.cancelToken = [TGTelegraphInstance doCreateChat:_uids title:title actor:self];
}

- (void)createChatSuccess:(TLUpdates *)updates
{
    [TGUserDataRequestBuilder executeUserDataUpdate:updates.users];
    
    TGConversation *chatConversation = nil;
    
    if (updates.chats.count != 0)
    {
        NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
        
        TGMessage *message = nil;
        if (updates.messages.count != 0)
            message = [[TGMessage alloc] initWithTelegraphMessageDesc:updates.messages.firstObject];
        
        for (TLChat *chatDesc in updates.chats)
        {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
            if (conversation != nil)
            {
                if (chatConversation == nil)
                {
                    chatConversation = conversation;
                    
                    chatConversation.chatParticipants = [[TGConversationParticipantsData alloc] init];
                    chatConversation.chatParticipants.version = chatConversation.chatVersion;
                    chatConversation.chatParticipants.chatAdminId = TGTelegraphInstance.clientUserId;
                    
                    NSMutableArray *newUids = [[NSMutableArray alloc] init];
                    NSMutableDictionary *newInvitedBy = [[NSMutableDictionary alloc] init];
                    NSMutableDictionary *newInvitedDates = [[NSMutableDictionary alloc] init];
                    
                    for (NSNumber *nUid in _uids)
                    {
                        [newUids addObject:nUid];
                        [newInvitedBy setObject:@(TGTelegraphInstance.clientUserId) forKey:nUid];
                        [newInvitedDates setObject:@((int)message.date) forKey:nUid];
                    }
                    
                    chatConversation.chatParticipants.chatParticipantUids = newUids;
                    chatConversation.chatParticipants.chatInvitedBy = newInvitedBy;
                    chatConversation.chatParticipants.chatInvitedDates = newInvitedDates;
                    
                    conversation = chatConversation;
                }
                
                [chats setObject:conversation forKey:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
            }
        }
        
        [TGDatabaseInstance() transactionAddMessages:message == nil ? nil : @[message] updateConversationDatas:chats notifyAdded:true];
    }
    
    [[TGTelegramNetworking instance] addUpdates:updates];
    
    [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:chatConversation]];
}

- (void)createChatFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
