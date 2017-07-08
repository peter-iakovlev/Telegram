#import "TGConversation+Telegraph.h"

#import "TGImageInfo+Telegraph.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGPeerIdAdapter.h"

#import "TLChat$channel.h"
#import "TLChat$chat.h"
#import "TLChat$channelForbidden.h"

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
            NSMutableSet *chatAdminUids = [[NSMutableSet alloc] init];
            
            for (TLChatParticipant *chatParticipant in concreteParticipants.participants)
            {
                int64_t uid = chatParticipant.user_id;
                [participants addObject:[NSNumber numberWithLongLong:uid]];
                
                if ([chatParticipant isKindOfClass:[TLChatParticipant$chatParticipant class]]) {
                    TLChatParticipant$chatParticipant *concreteParticipant = (TLChatParticipant$chatParticipant *)chatParticipant;

                    int64_t inviterUid = concreteParticipant.inviter_id;
                    [invitedBy setObject:[NSNumber numberWithInt:(int)inviterUid] forKey:[NSNumber numberWithInt:(int)uid]];
                    [invitedDates setObject:[NSNumber numberWithInt:concreteParticipant.date] forKey:[NSNumber numberWithInt:(int)uid]];
                } else if ([chatParticipant isKindOfClass:[TLChatParticipant$chatParticipantAdmin class]]) {
                    TLChatParticipant$chatParticipantAdmin *concreteParticipant = (TLChatParticipant$chatParticipantAdmin *)chatParticipant;
                    
                    int64_t inviterUid = concreteParticipant.inviter_id;
                    [invitedBy setObject:[NSNumber numberWithInt:(int)inviterUid] forKey:[NSNumber numberWithInt:(int)uid]];
                    [invitedDates setObject:[NSNumber numberWithInt:concreteParticipant.date] forKey:[NSNumber numberWithInt:(int)uid]];
                    [chatAdminUids addObject:@(uid)];
                } else if ([chatParticipant isKindOfClass:[TLChatParticipant$chatParticipantCreator class]]) {
                    self.chatAdminId = (int32_t)uid;
                }
            }
            
            self.version = concreteParticipants.version;
            
            self.chatParticipantUids = participants;
            self.chatInvitedBy = invitedBy;
            self.chatInvitedDates = invitedDates;
            self.chatAdminUids = chatAdminUids;
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
            self.hasAdmins = concreteChat.flags & (1 << 3);
            self.isAdmin = concreteChat.flags & (1 << 4);
            self.isCreator = concreteChat.flags & (1 << 0);
            self.isDeactivated = concreteChat.deactivated;
            if (concreteChat.flags & (1 << 6)) {
                self.isMigrated = true;
                if ([concreteChat.migrated_to isKindOfClass:[TLInputChannel$inputChannel class]]) {
                    TLInputChannel$inputChannel *inputChannel = (TLInputChannel$inputChannel *)concreteChat.migrated_to;
                    self.migratedToChannelId = inputChannel.channel_id;
                    self.migratedToChannelAccessHash = inputChannel.access_hash;
                }
            }
            self.chatCreationDate = concreteChat.date;
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
            self.chatCreationDate = channel.date;
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
            self.isChannelGroup = channel.flags & (1 << 8);
            self.everybodyCanAddMembers = channel.flags & (1 << 10);
            self.signaturesEnabled = channel.flags & (1 << 11);
            self.isMin = channel.flags & (1 << 12);
            self.canNotSetUsername = (channel.flags & (1 << 6)) == 0;
            
            self.displayVariant = self.isChannelGroup ? TGChannelDisplayVariantAll : TGChannelDisplayVariantImportant;
            
            self.postAsChannel = self.channelRole == TGChannelRoleCreator || self.channelRole == TGChannelRolePublisher;
            
            self.hasExplicitContent = channel.flags & (1 << 9);
            self.restrictionReason = channel.restriction_reason;
            
            self.kind = (self.leftChat || self.kickedFromChat) ? TGConversationKindTemporaryChannel : TGConversationKindPersistentChannel;
            
            if (channel.admin_rights != nil) {
                self.channelAdminRights = [[TGChannelAdminRights alloc] initWithTL:channel.admin_rights];
            }
            
            if (channel.banned_rights != nil) {
                self.channelBannedRights = [[TGChannelBannedRights alloc] initWithTL:channel.banned_rights];
            }
        }
        else if ([chatDesc isKindOfClass:[TLChat$channelForbidden class]])
        {
            TLChat$channelForbidden *channelForbidden = (TLChat$channelForbidden *)chatDesc;
            self.conversationId = TGPeerIdFromChannelId(channelForbidden.n_id);
            self.accessHash = channelForbidden.access_hash;
            self.leftChat = false;
            self.kickedFromChat = true;
            self.chatTitle = channelForbidden.title;
            self.channelBannedRights = [[TGChannelBannedRights alloc] initWithBanReadMessages:true banSendMessages:true banSendMedia:true banSendStickers:true banSendGifs:true banSendGames:true banSendInline:true banEmbedLinks:true timeout:channelForbidden.until_date == 0 ? INT32_MAX : channelForbidden.until_date];
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
