#import "TGGroupManagementSignals.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TLUpdates+TG.h"

#import "TGPeerIdAdapter.h"

#import "TGConversation+Telegraph.h"

#import "ActionStage.h"
#import "TGDatabase.h"
#import "TGConversationAddMessagesActor.h"
#import "TGTelegraph.h"

#import "TGUserDataRequestBuilder.h"
#import "TGMessage+Telegraph.h"
#import "TGUpdateStateRequestBuilder.h"

#import "TLChat$channel.h"

#import "TGChannelStateSignals.h"
#import "TGChannelManagementSignals.h"

#import "TLChat$chat.h"

#import "TLRPCmessages_editMessage.h"

#import "TGModernSendCommonMessageActor.h"

#import "TLRPCmessages_saveDraft.h"

#import "TLChatInvite$chatInvite.h"

#import "TGImageInfo+Telegraph.h"
#import "TGUser+Telegraph.h"

#import "TGDialogListRequestBuilder.h"

@implementation TGSynchronizePinnedConversationsAction

- (instancetype)initWithType:(int32_t)type version:(int32_t)version {
    self = [super init];
    if (self != nil) {
        _type = type;
        _version = version;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithType:[aDecoder decodeInt32ForKey:@"type"] version:[aDecoder decodeInt32ForKey:@"version"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt32:_type forKey:@"type"];
    [aCoder encodeInt32:_version forKey:@"version"];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGSynchronizePinnedConversationsAction class]] && ((TGSynchronizePinnedConversationsAction *)object)->_type == _type && ((TGSynchronizePinnedConversationsAction *)object)->_version == _version;
}

@end

@implementation TGGroupManagementSignals

+ (SSignal *)makeGroupWithTitle:(NSString *)title users:(NSArray *)users {
    TLRPCmessages_createChat$messages_createChat *createChat = [[TLRPCmessages_createChat$messages_createChat alloc] init];
    NSMutableArray *inputUsers = [[NSMutableArray alloc] init];
    for (TGUser *user in users) {
        if (user.uid == TGTelegraphInstance.clientUserId) {
            [inputUsers addObject:[[TLInputUser$inputUserSelf alloc] init]];
        } else {
            TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
            inputUser.user_id = user.uid;
            inputUser.access_hash = user.phoneNumberHash;
            [inputUsers addObject:inputUser];
        }
    }
    createChat.title = title;
    createChat.users = inputUsers;
    return [[[TGTelegramNetworking instance] requestSignal:createChat continueOnServerErrors:false failOnFloodErrors:true] mapToSignal:^SSignal *(TLUpdates *updates) {
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        int32_t pts = 0;
        [updates maxPtsAndCount:&pts ptsCount:NULL];
        
        TLChat *chat = [updates chats].firstObject;
        if (chat == nil) {
            return [SSignal fail:nil];
        } else {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
            if (pts == 0)
                return [SSignal fail:nil];
            
            return [[[[[TGDatabaseInstance() appliedPts] filter:^bool(NSNumber *currentPts) {
                           return [currentPts intValue] >= pts;
            }] take:1] mapToSignal:^SSignal *(__unused id next) {
                return [SSignal single:conversation];
            }] timeout:6.0 onQueue:[SQueue concurrentDefaultQueue] orSignal:[SSignal fail:nil]];
        }
    }];
}

+ (SSignal *)exportGroupInvitationLink:(int32_t)groupId
{
    TLRPCmessages_exportChatInvite$messages_exportChatInvite *exportChatInvite = [[TLRPCmessages_exportChatInvite$messages_exportChatInvite alloc] init];
    exportChatInvite.chat_id = groupId;
    return [[[TGTelegramNetworking instance] requestSignal:exportChatInvite] mapToSignal:^SSignal *(TLExportedChatInvite *result)
    {
        if ([result isKindOfClass:[TLExportedChatInvite$chatInviteExported class]])
        {
            NSString *link = ((TLExportedChatInvite$chatInviteExported *)result).link;
            
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:-groupId];
                if (conversation != nil && conversation.chatParticipants != nil)
                {
                    conversation = [conversation copy];
                    conversation.chatParticipants = [conversation.chatParticipants copy];
                    conversation.chatParticipants.exportedChatInviteString = link;
                    [TGDatabaseInstance() storeConversationParticipantData:-groupId participantData:conversation.chatParticipants];
                    
                    [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:@{@(conversation.conversationId): conversation} notifyAdded:true];
                }
            }];
            return [SSignal single:link];
        }
        else
            return [SSignal fail:nil];
    }];
}

+ (SSignal *)groupInvitationLinkInfo:(NSString *)hash
{
    TLRPCmessages_checkChatInvite$messages_checkChatInvite *checkChatInvite = [[TLRPCmessages_checkChatInvite$messages_checkChatInvite alloc] init];
    checkChatInvite.n_hash = hash;
    
    return [[[TGTelegramNetworking instance] requestSignal:checkChatInvite] mapToSignal:^SSignal *(TLChatInvite *result)
    {
        if ([result isKindOfClass:[TLChatInvite$chatInvite class]])
        {
            TLChatInvite$chatInvite *concreteInvite = (TLChatInvite$chatInvite *)result;
            int flags = ((TLChatInvite$chatInvite *)result).flags;
            bool isChannel = flags & (1 | 2 | 4);
            bool isChannelGroup = flags & (1 << 3);
            
            NSMutableArray *users = [[NSMutableArray alloc] init];
            for (TLUser *userDesc in concreteInvite.participants) {
                TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:userDesc];
                if (user.uid != 0) {
                    [users addObject:user];
                }
            }
            
            TGImageInfo *avatarInfo = nil;
            if ([concreteInvite.photo isKindOfClass:[TLChatPhoto$chatPhoto class]]) {
                TLChatPhoto$chatPhoto *concretePhoto = (TLChatPhoto$chatPhoto *)concreteInvite.photo;
                avatarInfo = [[TGImageInfo alloc] init];
                [avatarInfo addImageWithSize:CGSizeMake(160.0, 160.0) url:extractFileUrl(concretePhoto.photo_small)];
                [avatarInfo addImageWithSize:CGSizeMake(640.0, 640.0) url:extractFileUrl(concretePhoto.photo_big)];
            }
            
            return [SSignal single:[[TGGroupInvitationInfo alloc] initWithTitle:((TLChatInvite$chatInvite *)result).title alreadyAccepted:false left:false isChannel:isChannel isChannelGroup:isChannelGroup peerId:0 avatarInfo:avatarInfo userCount:concreteInvite.participants_count users:users]];
        }
        else if ([result isKindOfClass:[TLChatInvite$chatInviteAlready class]])
        {
            NSString *title = nil;
            TLChat *chat = ((TLChatInvite$chatInviteAlready *)result).chat;
            bool left = false;
            bool isChannelGroup = false;
            int64_t peerId = 0;
            if ([chat isKindOfClass:[TLChat$chat class]]) {
                title = ((TLChat$chat *)chat).title;
                left = ((TLChat$chat *)chat).flags & (1 << 2);
                peerId = TGPeerIdFromGroupId(((TLChat$chat *)chat).n_id);
            } else if ([chat isKindOfClass:[TLChat$channel class]]) {
                title = ((TLChat$channel *)chat).title;
                isChannelGroup = ((TLChat$channel *)chat).flags & (1 << 8);
                peerId = TGPeerIdFromChannelId(((TLChat$channel *)chat).n_id);
            }
            
            if (TGPeerIdIsChannel(peerId)) {
                return [[TGDatabaseInstance() modify:^id{
                    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
                    if (conversation == nil) {
                        conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
                        return [[TGChannelManagementSignals addChannel:conversation] mapToSignal:^SSignal *(__unused TGConversation *conversation) {
                            return [SSignal single:[[TGGroupInvitationInfo alloc] initWithTitle:title alreadyAccepted:true left:left isChannel:[chat isKindOfClass:[TLChat$channel class]] isChannelGroup:isChannelGroup peerId:peerId avatarInfo:nil userCount:0 users:nil]];
                        }];
                    } else {
                        return [SSignal single:[[TGGroupInvitationInfo alloc] initWithTitle:title alreadyAccepted:true left:left isChannel:[chat isKindOfClass:[TLChat$channel class]] isChannelGroup:isChannelGroup peerId:peerId avatarInfo:nil userCount:0 users:nil]];
                    }
                }] switchToLatest];
            } else {
                return [SSignal single:[[TGGroupInvitationInfo alloc] initWithTitle:title alreadyAccepted:true left:left isChannel:[chat isKindOfClass:[TLChat$channel class]] isChannelGroup:isChannelGroup peerId:peerId avatarInfo:nil userCount:0 users:nil]];
            }
        }
        else
            return [SSignal fail:nil];
    }];
}

+ (SSignal *)acceptGroupInvitationLink:(NSString *)hash
{
    TLRPCmessages_importChatInvite$messages_importChatInvite *importChatInvite = [[TLRPCmessages_importChatInvite$messages_importChatInvite alloc] init];
    importChatInvite.n_hash = hash;
    
    return [[[[TGTelegramNetworking instance] requestSignal:importChatInvite] mapToSignal:^SSignal *(TLUpdates *updates)
    {
        int32_t pts = 0;
        [updates maxPtsAndCount:&pts ptsCount:NULL];
        
        TLChat *chat = [updates chats].firstObject;
        if (chat == nil)
            return [SSignal fail:nil];
        else
        {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
            if (conversation.conversationId == 0)
                return [SSignal fail:nil];
            else
            {
                if (conversation.isChannel) {
                    return [TGChannelManagementSignals addChannel:conversation];
                } else {
                    [[TGTelegramNetworking instance] addUpdates:updates];
                    if (pts == 0)
                        return [SSignal fail:nil];
                    
                    return [[[[[TGDatabaseInstance() appliedPts] filter:^bool(NSNumber *currentPts)
                    {
                        return [currentPts intValue] >= pts;
                    }] take:1] mapToSignal:^SSignal *(__unused id next)
                    {
                        return [SSignal single:conversation];
                    }] timeout:6.0 onQueue:[SQueue concurrentDefaultQueue] orSignal:[SSignal fail:nil]];
                }
            }
        }
    }] catch:^SSignal *(id error)
    {
        if ([error isKindOfClass:[MTRpcError class]])
            return [SSignal fail:((MTRpcError *)error).errorDescription];
        return [SSignal fail:error];
    }];
}

+ (SSignal *)updateGroupPhoto:(int64_t)peerId uploadedFile:(SSignal *)uploadedFile {
    return [uploadedFile mapToSignal:^SSignal *(TLInputFile *inputFile) {
        TLRPCmessages_editChatPhoto$messages_editChatPhoto *editChatPhoto = [[TLRPCmessages_editChatPhoto$messages_editChatPhoto alloc] init];
        editChatPhoto.chat_id = TGGroupIdFromPeerId(peerId);
        TLInputChatPhoto$inputChatUploadedPhoto *uploadedPhoto = [[TLInputChatPhoto$inputChatUploadedPhoto alloc] init];
        uploadedPhoto.file = inputFile;
        editChatPhoto.photo = uploadedPhoto;
        
        return [[[TGTelegramNetworking instance] requestSignal:editChatPhoto] mapToSignal:^SSignal *(TLUpdates *updates) {
            [[TGTelegramNetworking instance] addUpdates:updates];
            
            int32_t pts = 0;
            [updates maxPtsAndCount:&pts ptsCount:NULL];
            
            TLChat *chat = [updates chats].firstObject;
            if (chat == nil) {
                return [SSignal fail:nil];
            } else {
                TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
                if (pts == 0)
                    return [SSignal fail:nil];
                
                return [[[[[TGDatabaseInstance() appliedPts] filter:^bool(NSNumber *currentPts) {
                    return [currentPts intValue] >= pts;
                }] take:1] mapToSignal:^SSignal *(__unused id next) {
                    return [SSignal single:conversation];
                }] timeout:6.0 onQueue:[SQueue concurrentDefaultQueue] orSignal:[SSignal fail:nil]];
            }
        }];
    }];
}

+ (SSignal *)inviteUserWithId:(int32_t)userId toGroupWithId:(int32_t)groupId
{
    TLRPCmessages_addChatUser$messages_addChatUser *addChatUser = [[TLRPCmessages_addChatUser$messages_addChatUser alloc] init];
    addChatUser.chat_id = groupId;
    addChatUser.user_id = [TGTelegraphInstance createInputUserForUid:userId];
    addChatUser.fwd_limit = 0;
    
    return [[[TGTelegramNetworking instance] requestSignal:addChatUser] map:^id(TLUpdates *updates)
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
                        
                        if (![chatConversation.chatParticipants.chatParticipantUids containsObject:@(userId)])
                        {
                            NSMutableArray *newUids = [[NSMutableArray alloc] initWithArray:chatConversation.chatParticipants.chatParticipantUids];
                            [newUids addObject:@(userId)];
                            chatConversation.chatParticipants.chatParticipantUids = newUids;
                            
                            NSMutableDictionary *newInvitedBy = [[NSMutableDictionary alloc] initWithDictionary:chatConversation.chatParticipants.chatInvitedBy];
                            [newInvitedBy setObject:@(TGTelegraphInstance.clientUserId) forKey:@(userId)];
                            chatConversation.chatParticipants.chatInvitedBy = newInvitedBy;
                            
                            NSMutableDictionary *newInvitedDates = [[NSMutableDictionary alloc] initWithDictionary:chatConversation.chatParticipants.chatInvitedDates];
                            [newInvitedDates setObject:@(message.date) forKey:@(userId)];
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
        
        return nil;
    }];
}

+ (SSignal *)toggleGroupHasAdmins:(int64_t)peerId hasAdmins:(bool)hasAdmins {
    TLRPCmessages_toggleChatAdmins$messages_toggleChatAdmins *toggleChatAdmins = [[TLRPCmessages_toggleChatAdmins$messages_toggleChatAdmins alloc] init];
    toggleChatAdmins.chat_id = TGGroupIdFromPeerId(peerId);
    toggleChatAdmins.enabled = hasAdmins;
    return [[[TGTelegramNetworking instance] requestSignal:toggleChatAdmins] mapToSignal:^SSignal *(TLUpdates *updates) {
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        TGConversation *conversation = nil;

        for (TLChat *chatDesc in updates.chats)
        {
            conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
            break;
        }
        
        if (conversation != nil)
        {
            return [[TGDatabaseInstance() modify:^id{
                [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:@{@(conversation.conversationId): conversation} notifyAdded:true];
                
                return [SSignal complete];
            }] switchToLatest];
        } else {
            return [SSignal complete];
        }
    }];
}

+ (SSignal *)toggleUserIsAdmin:(int64_t)peerId user:(TGUser *)user isAdmin:(bool)isAdmin {
    TLRPCmessages_editChatAdmin$messages_editChatAdmin *editChatAdmin = [[TLRPCmessages_editChatAdmin$messages_editChatAdmin alloc] init];
    editChatAdmin.chat_id = TGGroupIdFromPeerId(peerId);
    TLInputUser$inputUser *inputUser = [[TLInputUser$inputUser alloc] init];
    inputUser.user_id = user.uid;
    inputUser.access_hash = user.phoneNumberHash;
    editChatAdmin.user_id = inputUser;
    editChatAdmin.is_admin = isAdmin;
    
    return [[[TGTelegramNetworking instance] requestSignal:editChatAdmin] mapToSignal:^SSignal *(__unused id result) {
        return [[TGDatabaseInstance() modify:^id {
            TGConversation *currentConversation = [TGDatabaseInstance() loadConversationWithId:peerId];
            if (currentConversation != nil) {
                TGConversationParticipantsData *updatedData = [currentConversation.chatParticipants copy];
                NSMutableSet *chatAdminUids = [[NSMutableSet alloc] initWithSet:updatedData.chatAdminUids];
                if (isAdmin) {
                    [chatAdminUids addObject:@(user.uid)];
                } else {
                    [chatAdminUids removeObject:@(user.uid)];
                }
                
                currentConversation.chatParticipants = updatedData;
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", peerId] resource:[[SGraphObjectNode alloc] initWithObject:currentConversation]];
                return [[TGDatabaseInstance() modify:^id{
                    [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:@{@(currentConversation.conversationId): currentConversation} notifyAdded:true];
                    
                    return [SSignal complete];
                }] switchToLatest];
            }
            
            return [SSignal complete];
        }] switchToLatest];
    }];
}

+ (SSignal *)migrateGroup:(int64_t)peerId {
    TLRPCmessages_migrateChat$messages_migrateChat *migrateChat = [[TLRPCmessages_migrateChat$messages_migrateChat alloc] init];
    migrateChat.chat_id = TGGroupIdFromPeerId(peerId);
    
    return [[[TGTelegramNetworking instance] requestSignal:migrateChat] mapToSignal:^SSignal *(TLUpdates *updates) {
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        int32_t pts = 0;
        [updates maxPtsAndCount:&pts ptsCount:NULL];
        
        TGConversation *channelConversation = nil;
        for (TLChat *chat in [updates chats]) {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
            if (conversation.isChannel) {
                channelConversation = conversation;
                break;
            }
        }
        
        if (channelConversation == nil) {
            return [SSignal fail:nil];
        } else {
            return [TGChannelManagementSignals addChannel:channelConversation];
        }
    }];
}

+ (SSignal *)messageEditData:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId {
    TLRPCmessages_getMessageEditData$messages_getMessageEditData *getMessageEditData = [[TLRPCmessages_getMessageEditData$messages_getMessageEditData alloc] init];
    getMessageEditData.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
    getMessageEditData.n_id = messageId;
    return [[[TGTelegramNetworking instance] requestSignal:getMessageEditData] map:^id(TLmessages_MessageEditData *result) {
        return result;
    }];
}

+ (SSignal *)editMessage:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId text:(NSString *)text entities:(NSArray *)entities disableLinksPreview:(bool)disableLinksPreview {
    TLRPCmessages_editMessage *editMessage = [[TLRPCmessages_editMessage alloc] init];
    
    editMessage.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
    
    editMessage.n_id = messageId;
    
    editMessage.message = text;
    
    if (disableLinksPreview) {
        editMessage.flags |= (1 << 1);
    }
    
    if (entities.count != 0) {
        editMessage.flags |= (1 << 3);
    }
    
    editMessage.entities = [TGModernSendCommonMessageActor convertEntities:entities];
    
    return [[[TGTelegramNetworking instance] requestSignal:editMessage] mapToSignal:^SSignal *(TLUpdates *updates) {
        id chat = updates.chats.firstObject;
        TGConversation *conversation = nil;
        if (chat != nil) {
            conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
            if (conversation.conversationId == peerId) {
                if (conversation.isChannel) {
                    [TGDatabaseInstance() updateChannels:@[conversation]];
                }
            }
        }
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        for (id desc in [updates messages]) {
            TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
            if (message.mid == messageId) {

                TGMessage *existingMessage = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:peerId];
                message.contentProperties = existingMessage.contentProperties;
                
                return [SSignal single:message];
            }
        }
        
        return [SSignal single:nil];
    }];
}

+ (SSignal *)_validateGlobalPeerReadStates:(NSArray<TGConversation *> *)peers {
    if (peers.count == 0) {
        return [SSignal complete];
    }
    
    SSignal *initialPts = [TGDatabaseInstance() modify:^id{
        return @([TGDatabaseInstance() databaseState].pts);
    }];
    
    return [initialPts mapToSignal:^SSignal *(NSNumber *nInitialPts) {
        TLRPCmessages_getPeerDialogs$messages_getPeerDialogs *getPeerDialogs = [[TLRPCmessages_getPeerDialogs$messages_getPeerDialogs alloc] init];
        NSMutableArray<TLInputPeer *> *inputPeers = [[NSMutableArray alloc] init];
        for (TGConversation *peer in peers) {
            int64_t accessHash = peer.accessHash;
            if (TGPeerIdIsUser(peer.conversationId)) {
                accessHash = [TGDatabaseInstance() loadUser:(int)peer.conversationId].phoneNumberHash;
            }
            TLInputPeer *inputPeer = [TGTelegraphInstance createInputPeerForConversation:peer.conversationId accessHash:accessHash];
            if (inputPeer != nil) {
                [inputPeers addObject:inputPeer];
            }
        }
        getPeerDialogs.peers = inputPeers;
        
        SSignal *maybeAppliedReadStates = [[[TGTelegramNetworking instance] requestSignal:getPeerDialogs] mapToSignal:^SSignal *(TLmessages_PeerDialogs *result) {
            if (false && result.state.pts != [nInitialPts intValue]) {
                return [SSignal fail:@true];
            } else {
                NSMutableDictionary<NSNumber *, TGPeerReadState *> *readStates = [[NSMutableDictionary alloc] init];
                for (TGConversation *conversation in peers) {
                    readStates[@(conversation.conversationId)] = (TGPeerReadState *)[NSNull null];
                }
                for (TLDialog *dialog in result.dialogs) {
                    int64_t peerId = 0;
                    if ([dialog.peer isKindOfClass:[TLPeer$peerChat class]]) {
                        peerId = TGPeerIdFromGroupId(((TLPeer$peerChat *)dialog.peer).chat_id);
                    } else if ([dialog.peer isKindOfClass:[TLPeer$peerUser class]]) {
                        peerId = ((TLPeer$peerUser *)dialog.peer).user_id;
                    } else if ([dialog.peer isKindOfClass:[TLPeer$peerChannel class]]) {
                        peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)dialog.peer).channel_id);
                    }
                    
                    readStates[@(peerId)] = [[TGPeerReadState alloc] initWithMaxReadMessageId:dialog.read_inbox_max_id maxOutgoingReadMessageId:dialog.read_outbox_max_id maxKnownMessageId:dialog.top_message unreadCount:dialog.unread_count];
                }
                
                return [SSignal single:readStates];
            }
        }];
        
        SSignal *appliedReadStates = [[maybeAppliedReadStates onNext:^(NSDictionary<NSNumber *, TGPeerReadState *> *readStates) {
            [TGDatabaseInstance() transactionResetPeerReadStates:readStates];
        }] retryIf:^bool(id error) {
            if ([error respondsToSelector:@selector(boolValue)] && [error boolValue]) {
                return true;
            } else {
                return false;
            }
        }];
        
        return [appliedReadStates catch:^SSignal *(__unused id error) {
            return [SSignal complete];
        }];
    }];
}

+ (SSignal *)validatePeerReadStates:(SSignal *)peers {
    return [peers mapToQueue:^SSignal *(NSArray<TGConversation *> *peers) {
        NSMutableArray<TGConversation *> *globalPeers = [[NSMutableArray alloc] init];
        NSMutableArray<TGConversation *> *channelPeers = [[NSMutableArray alloc] init];
        for (TGConversation *conversation in peers) {
            if (TGPeerIdIsUser(conversation.conversationId) || TGPeerIdIsGroup(conversation.conversationId)) {
                [globalPeers addObject:conversation];
            } else {
                [channelPeers addObject:conversation];
            }
        }
        
        return [self _validateGlobalPeerReadStates:globalPeers];
    }];
}

+ (SSignal *)_synchronizeDraft:(int64_t)peerId {
    return [[TGDatabaseInstance() modify:^id{
        if (TGPeerIdIsSecretChat(peerId)) {
            return [SSignal complete];
        }
        
        TGDatabaseMessageDraft *draft = [TGDatabaseInstance() _peerDraft:peerId];
        
        TLRPCmessages_saveDraft *saveDraft = [[TLRPCmessages_saveDraft alloc] init];
        saveDraft.message = draft.text;
        saveDraft.reply_to_msg_id = draft.replyToMessageId;
        saveDraft.entities = [TGModernSendCommonMessageActor convertEntities:draft.entities];
        saveDraft.no_webpage = draft.disableLinkPreview;
        
        int64_t accessHash = 0;
        if (TGPeerIdIsChannel(peerId)) {
            accessHash = [TGDatabaseInstance() loadConversationWithId:peerId].accessHash;
        } else if (TGPeerIdIsUser(peerId)) {
            accessHash = [TGDatabaseInstance() loadUser:(int)peerId].phoneNumberHash;
        }
        
        saveDraft.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
        
        return [[[TGTelegramNetworking instance] requestSignal:saveDraft] mapToSignal:^SSignal *(__unused id result) {
            return [[TGDatabaseInstance() verifySynchronizedDraft:peerId draft:draft] mapToSignal:^SSignal *(NSNumber *result) {
                if ([result boolValue]) {
                    return [SSignal complete];
                } else {
                    return [SSignal fail:@true];
                }
            }];
        }];
    }] switchToLatest];
}

+ (SSignal *)synchronizePeerMessageDrafts:(SSignal *)peerIdsSets {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(__unused SSubscriber *subscriber) {
        SDisposableSet *disposables = [[SDisposableSet alloc] init];
        __weak SDisposableSet *weakDisposables = disposables;
        
        [disposables add:[peerIdsSets startWithNext:^(NSArray<NSNumber *> *peerIds) {
            for (NSNumber *nPeerId in peerIds) {
                SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
                __weak SMetaDisposable *weakDisposable = disposable;
                SSignal *signal = [[self _synchronizeDraft:[nPeerId longLongValue]] retryIf:^bool(id error) {
                    return [error respondsToSelector:@selector(boolValue)] && [error boolValue];
                }];
                id<SDisposable> concreteDisposable = [[signal onDispose:^{
                    __strong SMetaDisposable *strongDisposable = weakDisposable;
                    __strong SDisposableSet *strongDisposables = weakDisposables;
                    if (strongDisposable != nil && strongDisposables != nil) {
                        [strongDisposables remove:strongDisposable];
                    }
                }] startWithNext:nil];
                [disposable setDisposable:concreteDisposable];
            }
        }]];
        
        return disposables;
    }];
}

+ (SSignal *)conversationsToBeRemovedToAssignPublicUsernames:(int64_t)conversationId accessHash:(int64_t)accessHash {
    TLRPCchannels_checkUsername$channels_checkUsername *editTitle = [[TLRPCchannels_checkUsername$channels_checkUsername alloc] init];
    if (conversationId == 0) {
        editTitle.channel = [[TLInputChannel$inputChannelEmpty alloc] init];
    } else {
        TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
        inputChannel.channel_id = TGChannelIdFromPeerId(conversationId);
        inputChannel.access_hash = accessHash;
        editTitle.channel = inputChannel;
    }
    editTitle.username = @"qwefqwfwq";
    return [[[[TGTelegramNetworking instance] requestSignal:editTitle] mapToSignal:^SSignal *(__unused id result) {
        return [SSignal single:@[]];
    }] catch:^SSignal *(id error) {
        NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
        if ([errorType isEqualToString:@"CHANNELS_ADMIN_PUBLIC_TOO_MUCH"]) {
            TLRPCchannels_getAdminedPublicChannels$channels_getAdminedPublicChannels *getAdminedPublicChannels = [[TLRPCchannels_getAdminedPublicChannels$channels_getAdminedPublicChannels alloc] init];
            return [[[TGTelegramNetworking instance] requestSignal:getAdminedPublicChannels] map:^id(TLmessages_Chats *result) {
                NSMutableArray *conversations = [[NSMutableArray alloc] init];
                for (TLChat *chat in result.chats) {
                    TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chat];
                    if (conversation.conversationId != 0) {
                        [conversations addObject:conversation];
                    }
                }
                return conversations;
            }];
        }
        return [SSignal single:@[]];
    }];
}

+ (SSignal *)processedDialogs:(TLmessages_PeerDialogs *)result peerId:(int64_t)peerId {
    return [[TGDatabaseInstance() modify:^id{
        [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
        
        NSMutableDictionary *chatItems = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *channelItems = [[NSMutableDictionary alloc] init];
        
        for (TLChat *chatDesc in result.chats)
        {
            TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
            if (conversation.conversationId != 0) {
                if (conversation.isChannel) {
                    channelItems[@(conversation.conversationId)] = conversation;
                } else {
                    [chatItems setObject:conversation forKey:[NSNumber numberWithInt:(int)conversation.conversationId]];
                }
            }
        }
        
        NSMutableArray *parsedMessages = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *messagesDict = [[NSMutableDictionary alloc] init];
        for (TLMessage *messageDesc in result.messages)
        {
            TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
            if (message.mid != 0)
                [parsedMessages addObject:message];
        }
        
        return [[[TGDialogListRequestBuilder signalForCompleteMessages:parsedMessages channels:channelItems] catch:^SSignal *(__unused id error) {
            return [SSignal single:parsedMessages];
        }] mapToSignal:^SSignal *(NSArray *completeMessages) {
            return [TGDatabaseInstance() modify:^id {
                NSMutableDictionary *multipleMessagesByConversation = [[NSMutableDictionary alloc] init];
                NSMutableDictionary<NSNumber *, TGDatabaseMessageDraft *> *updatePeerDrafts = [[NSMutableDictionary alloc] init];
                
                for (TGMessage *message in completeMessages)
                {
                    if (!TGPeerIdIsChannel(message.cid)) {
                        [messagesDict setObject:message forKey:[NSNumber numberWithInt:message.mid]];
                    } else {
                        NSMutableArray *array = multipleMessagesByConversation[@(message.cid)];
                        if (array == nil) {
                            array = [[NSMutableArray alloc] init];
                            multipleMessagesByConversation[@(message.cid)] = array;
                        }
                        [array addObject:message];
                    }
                }
                
                NSMutableArray *conversations = [[NSMutableArray alloc] init];
                NSMutableArray *channels = [[NSMutableArray alloc] init];
                
                for (TLDialog *dialog in result.dialogs)
                {
                    int64_t peerId = 0;
                    if ([dialog.peer isKindOfClass:[TLPeer$peerUser class]])
                    {
                        TGConversation *conversation = [[TGConversation alloc] initWithConversationId:((TLPeer$peerUser *)dialog.peer).user_id unreadCount:dialog.unread_count serviceUnreadCount:0];
                        peerId = conversation.conversationId;
                        
                        conversation.maxReadMessageId = dialog.read_inbox_max_id;
                        conversation.maxOutgoingReadMessageId = dialog.read_outbox_max_id;
                        conversation.maxKnownMessageId = dialog.top_message;
                        
                        TGMessage *message = [messagesDict objectForKey:[NSNumber numberWithInt:dialog.top_message]];
                        if (message != nil)
                            [conversation mergeMessage:message];
                        
                        if (conversation.conversationId != 0)
                        {
                            //TGLog(@"Dialog with %@", [TGDatabaseInstance() loadUser:conversation.conversationId].displayName);
                            
                            [conversations addObject:conversation];
                            
                            if (message != nil) {
                                NSMutableArray *array = multipleMessagesByConversation[@(conversation.conversationId)];
                                if (array == nil) {
                                    array = [[NSMutableArray alloc] init];
                                    multipleMessagesByConversation[@(conversation.conversationId)] = array;
                                }
                                [array addObject:message];
                            }
                        }
                        
                        if ([dialog.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                        {
                            TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)dialog.notify_settings;
                            
                            int peerSoundId = 0;
                            int peerMuteUntil = 0;
                            bool peerPreviewText = true;
                            bool messagesMuted = false;
                            
                            peerMuteUntil = concreteSettings.mute_until;
                            if (peerMuteUntil <= [[TGTelegramNetworking instance] approximateRemoteTime])
                                peerMuteUntil = 0;
                            
                            if (concreteSettings.sound.length == 0)
                                peerSoundId = 0;
                            else if ([concreteSettings.sound isEqualToString:@"default"])
                                peerSoundId = 1;
                            else
                                peerSoundId = [concreteSettings.sound intValue];
                            
                            peerPreviewText = concreteSettings.flags & (1 << 0);
                            messagesMuted = concreteSettings.flags & (1 << 1);
                            
                            [TGDatabaseInstance() storePeerNotificationSettings:conversation.conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:nil];
                        }
                    }
                    else if ([dialog.peer isKindOfClass:[TLPeer$peerChat class]])
                    {
                        TGConversation *conversation = [chatItems objectForKey:[[NSNumber alloc] initWithLongLong:-((TLPeer$peerChat *)dialog.peer).chat_id]];
                        peerId = conversation.conversationId;
                        conversation.unreadCount = dialog.unread_count;
                        
                        conversation.maxReadMessageId = dialog.read_inbox_max_id;
                        conversation.maxOutgoingReadMessageId = dialog.read_outbox_max_id;
                        conversation.maxKnownMessageId = dialog.top_message;
                        
                        TGMessage *message = [messagesDict objectForKey:[NSNumber numberWithInt:dialog.top_message]];
                        if (message != nil)
                            [conversation mergeMessage:message];
                        
                        if (conversation.conversationId != 0)
                        {
                            //TGLog(@"Chat %@", conversation.chatTitle);
                            
                            [conversations addObject:conversation];
                            
                            if (message != nil) {
                                NSMutableArray *array = multipleMessagesByConversation[@(conversation.conversationId)];
                                if (array == nil) {
                                    array = [[NSMutableArray alloc] init];
                                    multipleMessagesByConversation[@(conversation.conversationId)] = array;
                                }
                                [array addObject:message];
                            }
                        }
                        
                        if ([dialog.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                        {
                            TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)dialog.notify_settings;
                            
                            int peerSoundId = 0;
                            int peerMuteUntil = 0;
                            bool peerPreviewText = true;
                            bool messagesMuted = false;
                            
                            peerMuteUntil = concreteSettings.mute_until;
                            
                            if (concreteSettings.sound.length == 0)
                                peerSoundId = 0;
                            else if ([concreteSettings.sound isEqualToString:@"default"])
                                peerSoundId = 1;
                            else
                                peerSoundId = [concreteSettings.sound intValue];
                            
                            peerPreviewText = concreteSettings.flags & (1 << 0);
                            messagesMuted = concreteSettings.flags & (1 << 1);
                            
                            [TGDatabaseInstance() storePeerNotificationSettings:conversation.conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:nil];
                        }
                    }
                    else if ([dialog.peer isKindOfClass:[TLPeer$peerChannel class]]) {
                        TGConversation *conversation = channelItems[@(TGPeerIdFromChannelId(((TLPeer$peerChannel *)dialog.peer).channel_id))];
                        if (conversation != nil) {
                            peerId = conversation.conversationId;
                            conversation.unreadCount = dialog.unread_count;
                            conversation.maxReadMessageId = dialog.read_inbox_max_id;
                            conversation.maxOutgoingReadMessageId = dialog.read_outbox_max_id;
                            conversation.maxKnownMessageId = dialog.top_message;
                            
                            [channels addObject:conversation];
                            
                            if ([dialog.notify_settings isKindOfClass:[TLPeerNotifySettings$peerNotifySettings class]])
                            {
                                TLPeerNotifySettings$peerNotifySettings *concreteSettings = (TLPeerNotifySettings$peerNotifySettings *)dialog.notify_settings;
                                
                                int peerSoundId = 0;
                                int peerMuteUntil = 0;
                                bool peerPreviewText = true;
                                bool messagesMuted = false;
                                
                                peerMuteUntil = concreteSettings.mute_until;
                                
                                if (concreteSettings.sound.length == 0)
                                    peerSoundId = 0;
                                else if ([concreteSettings.sound isEqualToString:@"default"])
                                    peerSoundId = 1;
                                else
                                    peerSoundId = [concreteSettings.sound intValue];
                                
                                peerPreviewText = concreteSettings.flags & (1 << 0);
                                messagesMuted = concreteSettings.flags & (1 << 1);
                                
                                [TGDatabaseInstance() storePeerNotificationSettings:conversation.conversationId soundId:peerSoundId muteUntil:peerMuteUntil previewText:peerPreviewText messagesMuted:messagesMuted writeToActionQueue:false completion:nil];
                            }
                        }
                    }
                    
                    if (peerId != 0) {
                        TGDatabaseMessageDraft *draft = nil;
                        if ([dialog.draft isKindOfClass:[TLDraftMessage$draftMessageMeta class]]) {
                            TLDraftMessage$draftMessageMeta *concreteDraft = (TLDraftMessage$draftMessageMeta *)dialog.draft;
                            draft = [[TGDatabaseMessageDraft alloc] initWithText:concreteDraft.message entities:[TGMessage parseTelegraphEntities:concreteDraft.entities] disableLinkPreview:concreteDraft.flags & (1 << 1) replyToMessageId:concreteDraft.reply_to_msg_id date:concreteDraft.date];
                        }
                        
                        if (draft != nil) {
                            updatePeerDrafts[@(peerId)] = draft == nil ? (id)[NSNull null] : draft;
                        }
                    }
                }
                
                [[TGDatabase instance] storeConversationList:conversations replace:false];
                
                [multipleMessagesByConversation enumerateKeysAndObjectsUsingBlock:^(NSNumber *nConversationId, NSArray *messages, __unused  BOOL *stop)
                 {
                     if (TGPeerIdIsChannel([nConversationId longLongValue])) {
                         NSMutableArray *addedHoles = [[NSMutableArray alloc] init];
                         
                         NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(TGMessage *lhs, TGMessage *rhs) {
                             int result = TGMessageTransparentSortKeyCompare(lhs.transparentSortKey, rhs.transparentSortKey);
                             if (result > 0) {
                                 return NSOrderedAscending;
                             } else if (result < 0) {
                                 return NSOrderedDescending;
                             } else {
                                 return NSOrderedSame;
                             }
                         }];
                         
                         for (NSUInteger i = 0; i < sortedMessages.count; i++) {
                             TGMessage *message = sortedMessages[i];
                             TGMessage *earlierMessage = i == sortedMessages.count - 1 ? nil : sortedMessages[i + 1];
                             if (earlierMessage == nil) {
                                 if (message.mid != 1) {
                                     [addedHoles addObject:[[TGMessageHole alloc] initWithMinId:1 minTimestamp:1 maxId:message.mid - 1 maxTimestamp:(int32_t)message.date]];
                                 }
                             } else if (earlierMessage.mid != message.mid - 1) {
                                 [addedHoles addObject:[[TGMessageHole alloc] initWithMinId:earlierMessage.mid + 1 minTimestamp:(int32_t)earlierMessage.date + 1 maxId:message.mid - 1 maxTimestamp:(int32_t)message.date]];
                             }
                         }
                         
                         [TGDatabaseInstance() addMessagesToChannel:[nConversationId longLongValue] messages:messages deleteMessages:nil unimportantGroups:nil addedHoles:addedHoles removedHoles:nil removedUnimportantHoles:nil updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:true changedMessages:nil];
                     } else {
                         [TGDatabaseInstance() transactionAddMessages:messages updateConversationDatas:nil notifyAdded:false];
                         if (messages.count != 0) {
                             TGMessage *message = messages.firstObject;
                             [TGDatabaseInstance() fillConversationHistoryHole:[nConversationId longLongValue] indexSet:[NSIndexSet indexSetWithIndex:message.mid]];
                         }
                     }
                 }];
                
                [TGDatabaseInstance() transactionAddMessages:nil notifyAddedMessages:false removeMessages:nil updateMessages:nil updatePeerDrafts:updatePeerDrafts removeMessagesInteractive:nil keepDates:false removeMessagesInteractiveForEveryone:false updateConversationDatas:nil applyMaxIncomingReadIds:nil applyMaxOutgoingReadIds:nil applyMaxOutgoingReadDates:nil readHistoryForPeerIds:nil resetPeerReadStates:nil clearConversationsWithPeerIds:nil removeConversationsWithPeerIds:nil updatePinnedConversations:nil synchronizePinnedConversations:false forceReplacePinnedConversations:false];
                
                for (TGConversation *conversation in conversations) {
                    if (conversation.conversationId == peerId) {
                        return conversation;
                    }
                }
                
                return nil;
            }];
        }];
    }] switchToLatest];
}

+ (SSignal *)preloadedPeer:(int64_t)peerId accessHash:(int64_t)accessHash {
    return [[TGDatabaseInstance() modify:^id{
        TLInputPeer *inputPeer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
        if (inputPeer != nil) {
            TLRPCmessages_getPeerDialogs$messages_getPeerDialogs *getPeerDialogs = [[TLRPCmessages_getPeerDialogs$messages_getPeerDialogs alloc] init];
            getPeerDialogs.peers = @[inputPeer];
            return [[[TGTelegramNetworking instance] requestSignal:getPeerDialogs] mapToSignal:^SSignal *(TLmessages_PeerDialogs *result) {
                return [self processedDialogs:result peerId:peerId];
            }];
        } else {
            return [SSignal single:nil];
        }
    }] switchToLatest];
}

+ (TLInputPeer *)inputPeerWithPeerId:(int64_t)peerId {
    if (TGPeerIdIsUser(peerId)) {
        TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)peerId];
        if (user != nil) {
            TLInputPeer$inputPeerUser *inputPeerUser = [[TLInputPeer$inputPeerUser alloc] init];
            inputPeerUser.user_id = user.uid;
            inputPeerUser.access_hash = user.phoneNumberHash;
            return inputPeerUser;
        }
    } else {
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
        if (conversation != nil) {
            if (TGPeerIdIsChannel(peerId)) {
                TLInputPeer$inputPeerChannel *inputPeerChannel = [[TLInputPeer$inputPeerChannel alloc] init];
                inputPeerChannel.channel_id = TGChannelIdFromPeerId(peerId);
                inputPeerChannel.access_hash = conversation.accessHash;
                return inputPeerChannel;
            } else{
                TLInputPeer$inputPeerChat *inputPeerChat = [[TLInputPeer$inputPeerChat alloc] init];
                inputPeerChat.chat_id = TGGroupIdFromPeerId(peerId);
                return inputPeerChat;
            }
        }
    }
    return nil;
}

+ (SSignal *)updatePinnedState:(int64_t)peerId pinned:(bool)pinned {
    return [[TGDatabaseInstance() modify:^id{
        NSMutableArray *peerIds = [[NSMutableArray alloc] init];
        for (TGConversation *conversation in [TGDatabaseInstance() _getPinnedConversations]) {
            if (conversation.conversationId != peerId) {
                [peerIds addObject:@(conversation.conversationId)];
            }
        }
        if (pinned) {
            [peerIds insertObject:@(peerId) atIndex:0];
        }
        [TGDatabaseInstance() transactionUpdatePinnedConversations:peerIds synchronizePinnedConversations:true forceReplacePinnedConversations:true];
        
        return [SSignal complete];
    }] switchToLatest];
}

+ (SSignal *)synchronizePinnedConversations {
    return [[self synchronizePinnedConversationsOnce] then:[[TGDatabaseInstance() synchronizePinnedConversationsActionUpdated] mapToThrottled:^SSignal *(__unused id value) {
        return [self synchronizePinnedConversationsOnce];
    }]];
}

+ (SSignal *)synchronizePinnedConversationsOnce {
    return [[[TGDatabaseInstance() modify:^id{
        SSignal *pushAction = [SSignal complete];
        SSignal *pullAction = [SSignal complete];
        
        TGSynchronizePinnedConversationsAction *action = [TGDatabaseInstance() currentSynchronizePinnedConversationsAction];
        
        if (action.type & TGSynchronizePinnedConversationsActionPush) {
            pushAction = [self pushPinnedConversations];
        }
        
        if (action.type & TGSynchronizePinnedConversationsActionPull) {
            pullAction = [self pullPinnedConversations];
        }
        
        return [[pushAction then:pullAction] then:[self tryCompletingWithAction:action]];
    }] switchToLatest] retryIf:^bool(__unused id error) {
        return true;
    }];
}

+ (SSignal *)tryCompletingWithAction:(TGSynchronizePinnedConversationsAction *)action {
    return [[TGDatabaseInstance() modify:^id{
        if ([[TGDatabaseInstance() currentSynchronizePinnedConversationsAction] isEqual:action]) {
            [TGDatabaseInstance() _setCurrentSynchronizePinnedConversationsAction:[[TGSynchronizePinnedConversationsAction alloc] initWithType:0 version:action.version]];
            return [SSignal complete];
        } else {
            return [SSignal fail:nil];
        }
    }] switchToLatest];
}

+ (SSignal *)pushPinnedConversations {
    return [[TGDatabaseInstance() modify:^id{
        NSMutableArray *inputPeers = [[NSMutableArray alloc] init];
        
        for (TGConversation *conversation in [TGDatabaseInstance() _getPinnedConversations]) {
            if (TGPeerIdIsSecretChat(conversation.conversationId)) {
                continue;
            }
            TLInputPeer *inputPeer = [self inputPeerWithPeerId:conversation.conversationId];
            if (inputPeer != nil) {
                [inputPeers addObject:inputPeer];
            }
        }
        
        TLRPCmessages_reorderPinnedDialogs$messages_reorderPinnedDialogs *reorderPinnedDialogs = [[TLRPCmessages_reorderPinnedDialogs$messages_reorderPinnedDialogs alloc] init];
        reorderPinnedDialogs.flags = (1 << 0);
        reorderPinnedDialogs.order = inputPeers;
        
        return [[[[TGTelegramNetworking instance] requestSignal:reorderPinnedDialogs] mapToSignal:^SSignal *(__unused id result) {
            return [SSignal complete];
        }] catch:^SSignal *(__unused id error) {
            return [SSignal complete];
        }];
    }] switchToLatest];
}

+ (SSignal *)pullPinnedConversations {
    TLRPCmessages_getPinnedDialogs$messages_getPinnedDialogs *getPinnedDialogs = [[TLRPCmessages_getPinnedDialogs$messages_getPinnedDialogs alloc] init];
    return [[[TGTelegramNetworking instance] requestSignal:getPinnedDialogs] mapToSignal:^SSignal *(TLmessages_PeerDialogs *result) {
        return [[self processedDialogs:result peerId:0] mapToSignal:^SSignal *(__unused id result1) {
            return [[TGDatabaseInstance() modify:^id{
                NSMutableArray *peerIds = [[NSMutableArray alloc] init];
                for (TLDialog *dialog in result.dialogs) {
                    int64_t peerId = 0;
                    if ([dialog.peer isKindOfClass:[TLPeer$peerChat class]]) {
                        peerId = TGPeerIdFromGroupId(((TLPeer$peerChat *)dialog.peer).chat_id);
                    } else if ([dialog.peer isKindOfClass:[TLPeer$peerUser class]]) {
                        peerId = ((TLPeer$peerUser *)dialog.peer).user_id;
                    } else if ([dialog.peer isKindOfClass:[TLPeer$peerChannel class]]) {
                        peerId = TGPeerIdFromChannelId(((TLPeer$peerChannel *)dialog.peer).channel_id);
                    }
                    
                    [peerIds addObject:@(peerId)];
                }
                
                [TGDatabaseInstance() transactionUpdatePinnedConversations:peerIds synchronizePinnedConversations:false forceReplacePinnedConversations:false];
                [TGDatabaseInstance() setCustomProperty:@"polledPinnedConversations" value:[NSData data]];
                
                return [SSignal complete];
            }] switchToLatest];
        }];
    }];
}

+ (void)beginPullPinnedConversations {
    return [TGDatabaseInstance() schedulePullPinnedConversations];
}

@end
