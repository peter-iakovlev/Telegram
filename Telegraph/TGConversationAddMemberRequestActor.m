#import "TGConversationAddMemberRequestActor.h"

#import "TGUserDataRequestBuilder.h"
#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGConversationAddMessagesActor.h"

#import "TLUpdates+TG.h"
#import "TLChat$chat.h"

@interface TGConversationAddMemberRequestActor ()

@property (nonatomic) int uid;

@end

@implementation TGConversationAddMemberRequestActor

@synthesize uid = _uid;

+ (NSString *)genericPath
{
    return @"/tg/conversation/@/addMember/@";
}

- (void)execute:(NSDictionary *)options
{
    NSNumber *nConversationId = [options objectForKey:@"conversationId"];
    NSNumber *nUid = [options objectForKey:@"uid"];
    if (nConversationId == nil || nUid == nil)
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
    
    _uid = [nUid intValue];
    
    self.cancelToken = [TGTelegraphInstance doAddConversationMember:[nConversationId longLongValue] uid:[nUid intValue] actor:self];
}

- (void)addMemberSuccess:(TLUpdates *)updates
{
    [TGUserDataRequestBuilder executeUserDataUpdate:updates.users];
    
    TGConversation *chatConversation = nil;
    
    if (updates.chats.count != 0)
    {
        NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
        
        TGMessage *message = updates.messages.count == 0 ? nil : [[TGMessage alloc] initWithTelegraphMessageDesc:updates.messages.firstObject];
        
        for (TLChat *chatDesc in updates.chats)
        {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
            if (conversation != nil)
            {
                if (chatConversation == nil)
                {
                    chatConversation = conversation;
                    
                    TGConversation *oldConversation = [TGDatabaseInstance() loadConversationWithId:chatConversation.conversationId];
                    chatConversation.chatParticipants = [oldConversation.chatParticipants copy];
                    
                    if ([chatDesc isKindOfClass:[TLChat$chat class]])
                    {
                        chatConversation.chatParticipants.version = ((TLChat$chat *)chatDesc).version;
                        chatConversation.chatVersion = ((TLChat$chat *)chatDesc).version;
                    }
                    
                    if (![chatConversation.chatParticipants.chatParticipantUids containsObject:@(_uid)])
                    {
                        NSMutableArray *newUids = [[NSMutableArray alloc] initWithArray:chatConversation.chatParticipants.chatParticipantUids];
                        [newUids addObject:@(_uid)];
                        chatConversation.chatParticipants.chatParticipantUids = newUids;
                        
                        NSMutableDictionary *newInvitedBy = [[NSMutableDictionary alloc] initWithDictionary:chatConversation.chatParticipants.chatInvitedBy];
                        [newInvitedBy setObject:@(TGTelegraphInstance.clientUserId) forKey:@(_uid)];
                        chatConversation.chatParticipants.chatInvitedBy = newInvitedBy;
                        
                        NSMutableDictionary *newInvitedDates = [[NSMutableDictionary alloc] initWithDictionary:chatConversation.chatParticipants.chatInvitedDates];
                        [newInvitedDates setObject:@(message.date) forKey:@(_uid)];
                        chatConversation.chatParticipants.chatInvitedDates = newInvitedDates;
                    }
                    
                    conversation = chatConversation;
                }
                
                [chats setObject:conversation forKey:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
            }
        }
        
        [TGDatabaseInstance() transactionAddMessages:message == nil ? nil : @[message] updateConversationDatas:chats notifyAdded:true];
    }
    
    [[TGTelegramNetworking instance] addUpdates:updates];
    
    int version = chatConversation.chatVersion;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSNumber alloc] initWithInt:version] forKey:@"conversationVersion"];
    [dict setObject:[NSNumber numberWithInt:_uid] forKey:@"uid"];
    
    [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:dict]];
}

- (void)addMemberFailed:(int)reason
{
    [ActionStageInstance() actionFailed:self.path reason:reason];
}

@end
