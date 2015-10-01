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
    return [[[TGTelegramNetworking instance] requestSignal:createChat] mapToSignal:^SSignal *(TLUpdates *updates) {
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
                    
                    static int actionId = 0;
                    [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(chatData%d)", actionId++]] execute:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSArray alloc] initWithObjects:conversation, nil], @"chats", nil]];
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
            int flags = ((TLChatInvite$chatInvite *)result).flags;
            bool isChannel = flags & (1 | 2 | 4);
            return [SSignal single:[[TGGroupInvitationInfo alloc] initWithTitle:((TLChatInvite$chatInvite *)result).title alreadyAccepted:false left:false isChannel:isChannel]];
        }
        else if ([result isKindOfClass:[TLChatInvite$chatInviteAlready class]])
        {
            NSString *title = nil;
            TLChat *chat = ((TLChatInvite$chatInviteAlready *)result).chat;
            bool left = false;
            if ([chat isKindOfClass:[TLChat$chat class]]) {
                title = ((TLChat$chat *)chat).title;
                left = ((TLChat$chat *)chat).flags & (1 << 3);
            } else if ([chat isKindOfClass:[TLChat$channel class]]) {
                title = ((TLChat$channel *)chat).title;
            }
            return [SSignal single:[[TGGroupInvitationInfo alloc] initWithTitle:title alreadyAccepted:true left:left isChannel:[chat isKindOfClass:[TLChat$channel class]]]];
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
        uploadedPhoto.crop = [[TLInputPhotoCrop$inputPhotoCropAuto alloc] init];
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
            
            static int actionId = 0;
            [[[TGConversationAddMessagesActor alloc] initWithPath:[[NSString alloc] initWithFormat:@"/tg/addmessage/(addMember%d)", actionId++] ] execute:[[NSDictionary alloc] initWithObjectsAndKeys:chats, @"chats", message == nil ? @[] : @[message], @"messages", nil]];
        }
        
        [[TGTelegramNetworking instance] addUpdates:updates];
        
        return nil;
    }];
}

@end
