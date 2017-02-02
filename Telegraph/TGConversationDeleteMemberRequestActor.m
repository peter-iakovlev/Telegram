#import "TGConversationDeleteMemberRequestActor.h"

#import "TGUserDataRequestBuilder.h"

#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGConversationAddMessagesActor.h"

#import "TLChat$chat.h"

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

- (void)extractStatedMessageFromUpdates:(TLUpdates *)updates message:(__autoreleasing TLMessage **)message chats:(__autoreleasing NSArray **)chats users:(__autoreleasing NSArray **)users
{
    if ([updates isKindOfClass:[TLUpdates$updates class]])
    {
        if (chats)
            *chats = ((TLUpdates$updates *)updates).chats;
        if (users)
            *users = ((TLUpdates$updates *)updates).users;
        
        for (id update in ((TLUpdates$updates *)updates).updates)
        {
            if ([update isKindOfClass:[TLUpdate$updateNewMessage class]])
            {
                if (message)
                    *message = ((TLUpdate$updateNewMessage *)update).message;
                break;
            }
        }
    }
}

- (void)deleteMemberSuccess:(TLUpdates *)updates
{
    TGConversation *chatConversation = nil;
    
    NSArray *chats = nil;
    NSArray *users = nil;
    TLMessage *messageDesc = nil;

    [self extractStatedMessageFromUpdates:updates message:&messageDesc chats:&chats users:&users];

    if (chats.count != 0 && messageDesc != nil)
    {
        NSMutableDictionary *chats = [[NSMutableDictionary alloc] init];
        
        for (TLChat *chatDesc in chats)
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
        
        if (messageDesc != nil)
        {
            TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
            [TGDatabaseInstance() transactionAddMessages:message == nil ? nil : @[message] updateConversationDatas:chats notifyAdded:true];
        }
    }
    
    [[TGTelegramNetworking instance] addUpdates:updates];
    
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
