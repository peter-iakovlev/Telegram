#import "TGConversation+Telegraph.h"

#import "TGImageInfo+Telegraph.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGPeerIdAdapter.h"

#import "TLChat$channel.h"

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
            self.leftChat = concreteChat.flags & (1 << 2);
            self.kickedFromChat = concreteChat.flags & (1 << 1);
            
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
        else if ([chatDesc isKindOfClass:[TLChat$channel class]])
        {
            self.conversationId = TGPeerIdFromChannelId(chatDesc.n_id);
            
            TLChat$channel *channel = (TLChat$channel *)chatDesc;
            
            self.isChannel = true;
            self.accessHash = channel.access_hash;
            self.chatTitle = channel.title;
            if ([channel.photo isKindOfClass:[TLChatPhoto$chatPhoto class]])
            {
                TLChatPhoto$chatPhoto *concretePhoto = (TLChatPhoto$chatPhoto *)channel.photo;
                self.chatPhotoSmall = extractFileUrl(concretePhoto.photo_small);
                self.chatPhotoMedium = nil;
                self.chatPhotoBig = extractFileUrl(concretePhoto.photo_big);
            }
            self.chatVersion = channel.version;
            self.importantSortKey = TGConversationSortKeyMake(self.kind, channel.date, 0);
            self.unimportantSortKey = TGConversationSortKeyMake(self.kind, channel.date, 0);
            self.variantSortKey = TGConversationSortKeyMake(self.kind, channel.date, 0);
            self.chatIsAdmin = channel.flags & (1 << 0);
            if (channel.flags & (1 << 0)) {
                self.channelRole = TGChannelRoleCreator;
            } else if (channel.flags & (1 << 3)) {
                self.channelRole = TGChannelRolePublisher;
            } else if (channel.flags & (1 << 4)) {
                self.channelRole = TGChannelRoleModerator;
            }
            self.username = channel.username;
            self.leftChat = channel.flags & (1 << 2);
            self.channelIsReadOnly = channel.flags & (1 << 5);
            self.kickedFromChat = channel.flags & (1 << 1);
            
            self.isVerified = channel.flags & (1 << 7);
            
            self.postAsChannel = self.channelRole == TGChannelRoleCreator || self.channelRole == TGChannelRolePublisher;
            
            self.kind = (self.leftChat || self.kickedFromChat) ? TGConversationKindTemporaryChannel : TGConversationKindPersistentChannel;
        }
        else if ([chatDesc isKindOfClass:[TLChat$channelForbidden class]])
        {
            TLChat$channelForbidden *channelForbidden = (TLChat$channelForbidden *)chatDesc;
            self.conversationId = TGPeerIdFromChannelId(channelForbidden.n_id);
            self.accessHash = channelForbidden.access_hash;
            self.leftChat = true;
            self.chatTitle = channelForbidden.title;
            self.kind = TGConversationKindTemporaryChannel;
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
