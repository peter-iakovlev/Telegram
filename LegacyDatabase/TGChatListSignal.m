#import "TGChatListSignal.h"

#import <LegacyDatabase/LegacyDatabase.h>

@implementation TGChatListSignal

+ (TGFileLocation *)fileLocationWithApiLocation:(Api82_FileLocation *)location
{
    if ([location isKindOfClass:[Api82_FileLocation_fileLocation class]])
    {
        Api82_FileLocation_fileLocation *concreteLocation = (Api82_FileLocation_fileLocation *)location;
        return [[TGFileLocation alloc] initWithDatacenterId:[concreteLocation.dcId intValue] volumeId:[[concreteLocation volumeId] longLongValue] localId:[concreteLocation.localId intValue] secret:[concreteLocation.secret longLongValue]];
    }
    return nil;
}

+ (TGFileLocation *)fileLocationWithUserProfilePhoto:(Api82_UserProfilePhoto *)photo
{
    if ([photo isKindOfClass:[Api82_UserProfilePhoto_userProfilePhoto class]])
    {
        Api82_UserProfilePhoto_userProfilePhoto *concretePhoto = (Api82_UserProfilePhoto_userProfilePhoto *)photo;
        return [self fileLocationWithApiLocation:concretePhoto.photoSmall];
    }
    return nil;
}

+ (TGUserModel *)userModelWithApiUser:(Api82_User *)user
{
    if ([user isKindOfClass:[Api82_User_user class]])
    {
        Api82_User_user *concreteUser = (Api82_User_user *)user;
        
        bool isSelf = [concreteUser.flags intValue] & (1 << 10);
        
        return [[TGUserModel alloc] initWithUserId:[concreteUser.pid intValue] accessHash:isSelf ? -1 :[concreteUser.accessHash longLongValue] firstName:concreteUser.firstName lastName:concreteUser.lastName avatarLocation:[self fileLocationWithUserProfilePhoto:concreteUser.photo]];
    }
    
    return nil;
}

+ (SSignal *)remoteChatListWithContext:(TGShareContext *)context offsetDate:(int32_t)offsetDate offsetPeer:(Api82_InputPeer *)offsetPeer offsetMessageId:(int32_t)offsetMessageId limit:(NSUInteger)limit
{
    return [[context function:[Api82 messages_getDialogsWithFlags:@(0) offsetDate:@(offsetDate) offsetId:@(offsetMessageId) offsetPeer:offsetPeer limit:@(limit) phash:@0]] map:^id(Api82_messages_Dialogs *dialogz)
    {
        NSMutableArray *chatModels = [[NSMutableArray alloc] init];
        NSMutableArray *userModels = [[NSMutableArray alloc] init];
        
        NSArray *dialogs = nil;
        NSArray *chats = nil;
        NSArray *users = nil;
        NSArray *messages = nil;
        
        if ([dialogz isKindOfClass:[Api82_messages_Dialogs_messages_dialogs class]]) {
            dialogs = ((Api82_messages_Dialogs_messages_dialogs *)dialogz).dialogs;
            chats = ((Api82_messages_Dialogs_messages_dialogs *)dialogz).chats;
            users = ((Api82_messages_Dialogs_messages_dialogs *)dialogz).users;
            messages = ((Api82_messages_Dialogs_messages_dialogs *)dialogz).messages;
        } else if ([dialogz isKindOfClass:[Api82_messages_Dialogs_messages_dialogsSlice class]]) {
            dialogs = ((Api82_messages_Dialogs_messages_dialogsSlice *)dialogz).dialogs;
            chats = ((Api82_messages_Dialogs_messages_dialogsSlice *)dialogz).chats;
            users = ((Api82_messages_Dialogs_messages_dialogsSlice *)dialogz).users;
            messages = ((Api82_messages_Dialogs_messages_dialogsSlice *)dialogz).messages;
        }
        
        for (Api82_Dialog *dialog in dialogs)
        {
            if ([dialog.peer isKindOfClass:[Api82_Peer_peerChat class]])
            {
                Api82_Peer_peerChat *peerChat = (Api82_Peer_peerChat *)dialog.peer;
                for (Api82_Chat *chat in chats)
                {
                    if ([chat.pid isEqual:peerChat.chatId])
                    {
                        if ([chat isKindOfClass:[Api82_Chat_chat class]])
                        {
                            Api82_Chat_chat *concreteChat = (Api82_Chat_chat *)chat;
                            if (([concreteChat.flags intValue] & (1 << 5)) != 0) {
                                continue;
                            }
                            
                            TGFileLocation *avatarLocation = nil;
                            if ([concreteChat.photo isKindOfClass:[Api82_ChatPhoto_chatPhoto class]])
                            {
                                avatarLocation = [self fileLocationWithApiLocation:((Api82_ChatPhoto_chatPhoto *)concreteChat.photo).photoSmall];
                            }
                            [chatModels addObject:[[TGGroupChatModel alloc] initWithGroupId:[concreteChat.pid intValue] title:concreteChat.title avatarLocation:avatarLocation]];
                        }
                        break;
                    }
                }
            }
            else if ([dialog.peer isKindOfClass:[Api82_Peer_peerUser class]])
            {
                Api82_Peer_peerUser *peerUser = (Api82_Peer_peerUser *)dialog.peer;
                for (Api82_User *user in users)
                {
                    if ([user.pid isEqual:peerUser.userId])
                    {
                        TGUserModel *userModel = [self userModelWithApiUser:user];
                        if (userModel != nil)
                        {
                            [userModels addObject:userModel];
                            [chatModels addObject:[[TGPrivateChatModel alloc] initWithUserId:userModel.userId]];
                        }
                        break;
                    }
                }
            }
            else if ([dialog.peer isKindOfClass:[Api82_Peer_peerChannel class]])
            {
                Api82_Peer_peerChannel *peerChannel = (Api82_Peer_peerChannel *)dialog.peer;
                for (Api82_Chat *chat in chats)
                {
                    if ([chat.pid isEqual:peerChannel.channelId])
                    {
                        if ([chat isKindOfClass:[Api82_Chat_channel class]])
                        {
                            Api82_Chat_channel *concreteChannel = (Api82_Chat_channel *)chat;
                            TGFileLocation *avatarLocation = nil;
                            if ([concreteChannel.photo isKindOfClass:[Api82_ChatPhoto_chatPhoto class]])
                            {
                                avatarLocation = [self fileLocationWithApiLocation:((Api82_ChatPhoto_chatPhoto *)concreteChannel.photo).photoSmall];
                            }
                            NSInteger flags = concreteChannel.flags.intValue;
                            bool isGroup = (flags & (1 << 8));
                            bool isAdmin = (flags & (1 << 0));
                            
                            if (!isGroup && !isAdmin)
                                continue;
                            
                            TGChannelChatModel *channelModel = [[TGChannelChatModel alloc] initWithChannelId:[concreteChannel.pid intValue] title:concreteChannel.title avatarLocation:avatarLocation isGroup:isGroup accessHash:concreteChannel.accessHash.integerValue];
                            [chatModels addObject:channelModel];
                            [userModels addObject:channelModel];
                        }
                        break;
                    }
                }
            }
        }
        
        NSDictionary *nextRequestOffset = @{};
        
        if (dialogs.count != 0) {
            Api82_Dialog *lastDialog = dialogs.lastObject;
            int32_t peerId = 0;
            if ([lastDialog.peer isKindOfClass:[Api82_Peer_peerUser class]]) {
                peerId = [((Api82_Peer_peerUser *)lastDialog.peer).userId intValue];
            } else if ([lastDialog.peer isKindOfClass:[Api82_Peer_peerChat class]]) {
                peerId = [((Api82_Peer_peerChat *)lastDialog.peer).chatId intValue];
            } else if ([lastDialog.peer isKindOfClass:[Api82_Peer_peerChannel class]]) {
                peerId = [((Api82_Peer_peerChannel *)lastDialog.peer).channelId intValue];
            }
            
            if (peerId != 0) {
                for (Api82_Message *message in messages) {
                    if ([message isKindOfClass:[Api82_Message_message class]]) {
                        Api82_Message_message *concreteMessage = (Api82_Message_message *)message;
                        
                        int32_t messagePeerId = 0;
                        Api82_InputPeer *messagePeer = [Api82_InputPeer inputPeerEmpty];
                        
                        if ([concreteMessage.toId isKindOfClass:[Api82_Peer_peerUser class]]) {
                            if (([concreteMessage.flags intValue] & 2) != 0) {
                                messagePeerId = [((Api82_Peer_peerUser *)concreteMessage.toId).userId intValue];
                            } else {
                                messagePeerId = [concreteMessage.fromId intValue];
                            }
                        } else if ([concreteMessage.toId isKindOfClass:[Api82_Peer_peerChat class]]) {
                            messagePeerId = [((Api82_Peer_peerChat *)concreteMessage.toId).chatId intValue];
                        } else if ([concreteMessage.toId isKindOfClass:[Api82_Peer_peerChannel class]]) {
                            messagePeerId = [((Api82_Peer_peerChannel *)concreteMessage.toId).channelId intValue];
                        }
                        
                        if (messagePeerId == peerId) {
                            if (nextRequestOffset.count == 0) {
                                nextRequestOffset = @{@"offsetDate": @([concreteMessage.date intValue]), @"offsetPeer": messagePeer, @"offsetMessageId": @([concreteMessage.pid intValue])};
                            }
                        }
                    } else if ([message isKindOfClass:[Api82_Message_messageService class]]) {
                        Api82_Message_messageService *concreteMessage = (Api82_Message_messageService *)message;
                        
                        int32_t messagePeerId = 0;
                        Api82_InputPeer *messagePeer = [Api82_InputPeer inputPeerEmpty];
                        
                        if ([concreteMessage.toId isKindOfClass:[Api82_Peer_peerUser class]]) {
                            if (([concreteMessage.flags intValue] & 2) != 0) {
                                messagePeerId = [((Api82_Peer_peerUser *)concreteMessage.toId).userId intValue];
                            } else {
                                messagePeerId = [concreteMessage.fromId intValue];
                            }
                        } else if ([concreteMessage.toId isKindOfClass:[Api82_Peer_peerChat class]]) {
                            messagePeerId = [((Api82_Peer_peerChat *)concreteMessage.toId).chatId intValue];
                        } else if ([concreteMessage.toId isKindOfClass:[Api82_Peer_peerChannel class]]) {
                            messagePeerId = [((Api82_Peer_peerChannel *)concreteMessage.toId).channelId intValue];
                        }
                        
                        if (messagePeerId == peerId) {
                            if (nextRequestOffset.count == 0) {
                                nextRequestOffset = @{@"offsetDate": @([concreteMessage.date intValue]), @"offsetPeer": messagePeer, @"offsetMessageId": @([concreteMessage.pid intValue])};
                            }
                        }
                    }
                }
            }
        }
        
        return @{@"chats": chatModels, @"users": userModels, @"nextRequestOffset": nextRequestOffset};
    }];
}

+ (SSignal *)remoteChatListWithContext:(TGShareContext *)context
{
    return [[self remoteChatListWithContext:context offsetDate:0 offsetPeer:[Api82_InputPeer inputPeerEmpty] offsetMessageId:0 limit:32] mapToSignal:^SSignal *(NSDictionary *chats) {
        SSignal *nextSignal = [SSignal complete];
        NSDictionary *nextRequestOffset = chats[@"nextRequestOffset"];
        if (nextRequestOffset.count != 0) {
            nextSignal = [[self remoteChatListWithContext:context offsetDate:[nextRequestOffset[@"offsetDate"] intValue] offsetPeer:nextRequestOffset[@"offsetPeer"] offsetMessageId:[nextRequestOffset[@"offsetMessageId"] intValue] limit:200] map:^id(NSDictionary *nextChats) {
                
                NSMutableArray *chatModels = [[NSMutableArray alloc] initWithArray:chats[@"chats"]];
                NSMutableArray *userModels = [[NSMutableArray alloc] initWithArray:chats[@"users"]];
                
                for (TGChatModel *chatModel in nextChats[@"chats"])
                {
                    bool found = false;
                    for (TGChatModel *currentChatModel in chatModels)
                    {
                        if (TGPeerIdEqualToPeerId(currentChatModel.peerId, chatModel.peerId))
                        {
                            found = true;
                            break;
                        }
                    }
                    if (!found)
                    {
                        [chatModels addObject:chatModel];
                        if ([chatModel isKindOfClass:[TGChannelChatModel class]])
                            [userModels addObject:chatModel];
                    }
                }
                
                for (id model in nextChats[@"users"])
                {
                    bool found = false;
                    for (id currentModel in userModels)
                    {
                        if ([currentModel isKindOfClass:[TGUserModel class]] && ([model isKindOfClass:[TGUserModel class]]) && ((TGUserModel *)currentModel).userId == ((TGUserModel *)model).userId)
                        {
                            found = true;
                            break;
                        }
                        else if ([currentModel isKindOfClass:[TGChannelChatModel class]] && ([model isKindOfClass:[TGChannelChatModel class]]) && ((TGChannelChatModel *)currentModel).peerId.peerId == ((TGChannelChatModel *)model).peerId.peerId)
                        {
                            found = true;
                            break;
                        }
                    }
                    if (!found)
                        [userModels addObject:model];
                }
                
                return @{@"chats": chatModels, @"users": userModels};
            }];
        }
        
        return [[SSignal single:chats] then:nextSignal];
    }];
}

@end
