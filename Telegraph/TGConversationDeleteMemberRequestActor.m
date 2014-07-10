#import "TGConversationDeleteMemberRequestActor.h"

#import "TGUserDataRequestBuilder.h"

#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGConversationAddMessagesActor.h"

@interface TGConversationDeleteMemberRequestActor ()

@property (nonatomic) int uid;

@end

@implementation TGConversationDeleteMemberRequestActor

@synthesize uid = _uid;

+ (NSString *)genericPath
{
    return @"/tg/conversation/@/deleteMember/@";
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
    
    self.cancelToken = [TGTelegraphInstance doDeleteConversationMember:[nConversationId longLongValue] uid:[nUid intValue] actor:self];
}

- (void)deleteMemberSuccess:(TLmessages_StatedMessage *)statedMessage
{
    TGConversation *chatConversation = nil;
    
    [TGUserDataRequestBuilder executeUserDataUpdate:statedMessage.users];
    
    if (statedMessage.chats.count != 0)
    {
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:statedMessage.message];
        
        NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
        
        for (TLChat *chatDesc in statedMessage.chats)
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
                    
                    if ([chatConversation.chatParticipants.chatParticipantUids containsObject:@(_uid)])
                    {
                        NSMutableArray *newUids = [[NSMutableArray alloc] initWithArray:chatConversation.chatParticipants.chatParticipantUids];
                        [newUids removeObject:@(_uid)];
                        chatConversation.chatParticipants.chatParticipantUids = newUids;
                        
                        NSMutableDictionary *newInvitedBy = [[NSMutableDictionary alloc] initWithDictionary:chatConversation.chatParticipants.chatInvitedBy];
                        [newInvitedBy removeObjectForKey:@(_uid)];
                        chatConversation.chatParticipants.chatInvitedBy = newInvitedBy;
                        
                        NSMutableDictionary *newInvitedDates = [[NSMutableDictionary alloc] initWithDictionary:chatConversation.chatParticipants.chatInvitedDates];
                        [newInvitedDates removeObjectForKey:@(_uid)];
                        chatConversation.chatParticipants.chatInvitedDates = newInvitedDates;
                    }
                    
                    conversation = chatConversation;
                }
                
                [chats setObject:conversation forKey:[[NSNumber alloc] initWithLongLong:conversation.conversationId]];
            }
        }
        
        static int actionId = 0;
        [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(deleteMember%d)", actionId++]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:chats, @"chats", @[message], @"messages", nil]];
    }
    
    [[TGTelegramNetworking instance] updatePts:statedMessage.pts date:0 seq:statedMessage.seq];
    
    int version = chatConversation.chatVersion;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSNumber alloc] initWithInt:version] forKey:@"conversationVersion"];
    [dict setObject:[NSNumber numberWithInt:_uid] forKey:@"uid"];
    [ActionStageInstance() actionCompleted:self.path result:[[SGraphObjectNode alloc] initWithObject:dict]];
}

- (void)deleteMemberFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
