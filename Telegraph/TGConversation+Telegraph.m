#import "TGConversation+Telegraph.h"

#import "TGImageInfo+Telegraph.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

@implementation TGConversationParticipantsData (Telegraph)

- (id)initWithTelegraphParticipantsDesc:(TLChatParticipants *)participantsDesc
{
    self = [super init];
    if (self != nil)
    {
        _serializedData = nil;
        
        if ([participantsDesc isKindOfClass:[TLChatParticipants$chatParticipants class]])
        {
            TLChatParticipants$chatParticipants *concreteParticipants = (TLChatParticipants$chatParticipants *)participantsDesc;
            
            NSMutableArray *participants = [[NSMutableArray alloc] init];
            NSMutableDictionary *invitedBy = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *invitedDates = [[NSMutableDictionary alloc] init];
            
            for (TLChatParticipant *chatParticipant in concreteParticipants.participants)
            {
                int64_t uid = chatParticipant.user_id;
                [participants addObject:[NSNumber numberWithLongLong:uid]];
                
                int64_t inviterUid = chatParticipant.inviter_id;
                [invitedBy setObject:[NSNumber numberWithInt:(int)inviterUid] forKey:[NSNumber numberWithInt:(int)uid]];
                [invitedDates setObject:[NSNumber numberWithInt:chatParticipant.date] forKey:[NSNumber numberWithInt:(int)uid]];
            }
            
            self.version = concreteParticipants.version;
            self.chatAdminId = concreteParticipants.admin_id;
            
            self.chatParticipantUids = participants;
            self.chatInvitedBy = invitedBy;
            self.chatInvitedDates = invitedDates;
        }
    }
    return self;
}

@end

@implementation TGConversation (Telegraph)

- (id)initWithTelegraphChatDesc:(TLChat *)chatDesc
{
    self = [super init];
    if (self != nil)
    {
        self.conversationId = -chatDesc.n_id;
        
        self.isChat = true;
        
        if ([chatDesc isKindOfClass:[TLChat$chat class]])
        {
            TLChat$chat *concreteChat = (TLChat$chat *)chatDesc;
            
            self.chatTitle = concreteChat.title;
            self.leftChat = concreteChat.left;
            
            TLChatPhoto *photo = concreteChat.photo;
            if ([photo isKindOfClass:[TLChatPhoto$chatPhoto class]])
            {
                TLChatPhoto$chatPhoto *concretePhoto = (TLChatPhoto$chatPhoto *)photo;
                self.chatPhotoSmall = extractFileUrl(concretePhoto.photo_small);
                self.chatPhotoMedium = nil;
                self.chatPhotoBig = extractFileUrl(concretePhoto.photo_big);
            }
            
            self.chatParticipantCount = concreteChat.participants_count;
            self.chatVersion = concreteChat.version;
        }
        else if ([chatDesc isKindOfClass:[TLChat$chatForbidden class]])
        {
            TLChat$chatForbidden *concreteChat = (TLChat$chatForbidden *)chatDesc;
            self.chatTitle = concreteChat.title;
            
            self.kickedFromChat = true;
        }
    }
    return self;
}

- (id)initWithTelegraphEncryptedChatDesc:(TLEncryptedChat *)chatDesc
{
    self = [super init];
    if (self != nil)
    {
        self.conversationId = [TGDatabaseInstance() peerIdForEncryptedConversationId:chatDesc.n_id];
        
        self.isChat = true;
        
        int participantUid = 0;
        int adminUid = 0;
        
        int64_t accessHash = 0;
        int64_t keyFingerprint = 0;
        
        if ([chatDesc isKindOfClass:[TLEncryptedChat$encryptedChatWaiting class]])
        {
            TLEncryptedChat$encryptedChatWaiting *concreteChat = (TLEncryptedChat$encryptedChatWaiting *)chatDesc;
            
            adminUid = concreteChat.admin_id;
            participantUid = concreteChat.participant_id;
            accessHash = concreteChat.access_hash;
        }
        else if ([chatDesc isKindOfClass:[TLEncryptedChat$encryptedChatRequested class]])
        {
            TLEncryptedChat$encryptedChatRequested *concreteChat = (TLEncryptedChat$encryptedChatRequested *)chatDesc;
            
            adminUid = concreteChat.admin_id;
            participantUid = concreteChat.participant_id;
            accessHash = concreteChat.access_hash;
        }
        else if ([chatDesc isKindOfClass:[TLEncryptedChat$encryptedChat class]])
        {
            TLEncryptedChat$encryptedChat *concreteChat = (TLEncryptedChat$encryptedChat *)chatDesc;
            
            adminUid = concreteChat.admin_id;
            participantUid = concreteChat.participant_id;
            accessHash = concreteChat.access_hash;
            keyFingerprint = concreteChat.key_fingerprint;
        }
        
        if (participantUid != 0)
        {
            int selfUid = TGTelegraphInstance.clientUserId;
            if (selfUid == participantUid)
                participantUid = adminUid;
            
            TGConversationParticipantsData *participantsData = [[TGConversationParticipantsData alloc] init];
            participantsData.chatParticipantUids = [[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:participantUid], nil];
            participantsData.chatAdminId = adminUid;
            participantsData.chatInvitedDates = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:0], [[NSNumber alloc] initWithInt:participantUid], nil];
            participantsData.chatInvitedBy = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:adminUid], [[NSNumber alloc] initWithInt:participantUid], nil];
            self.chatParticipants = participantsData;
        }
        
        TGEncryptedConversationData *encryptedData = [[TGEncryptedConversationData alloc] init];
        encryptedData.encryptedConversationId = chatDesc.n_id;
        encryptedData.accessHash = accessHash;
        encryptedData.keyFingerprint = keyFingerprint;
        self.encryptedData = encryptedData;
    }
    return self;
}

@end
