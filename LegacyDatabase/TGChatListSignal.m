#import "TGChatListSignal.h"

#import <LegacyDatabase/LegacyDatabase.h>

@implementation TGChatListSignal

+ (TGFileLocation *)fileLocationWithApiLocation:(Api65_FileLocation *)location
{
    if ([location isKindOfClass:[Api65_FileLocation_fileLocation class]])
    {
        Api65_FileLocation_fileLocation *concreteLocation = (Api65_FileLocation_fileLocation *)location;
        return [[TGFileLocation alloc] initWithDatacenterId:[concreteLocation.dcId intValue] volumeId:[[concreteLocation volumeId] longLongValue] localId:[concreteLocation.localId intValue] secret:[concreteLocation.secret longLongValue]];
    }
    return nil;
}

+ (TGFileLocation *)fileLocationWithUserProfilePhoto:(Api65_UserProfilePhoto *)photo
{
    if ([photo isKindOfClass:[Api65_UserProfilePhoto_userProfilePhoto class]])
    {
        Api65_UserProfilePhoto_userProfilePhoto *concretePhoto = (Api65_UserProfilePhoto_userProfilePhoto *)photo;
        return [self fileLocationWithApiLocation:concretePhoto.photoSmall];
    }
    return nil;
}

+ (TGUserModel *)userModelWithApiUser:(Api65_User *)user
{
    if ([user isKindOfClass:[Api65_User_user class]])
    {
        Api65_User_user *concreteUser = (Api65_User_user *)user;
        
        bool isSelf = [concreteUser.flags intValue] & (1 << 10);
        
        return [[TGUserModel alloc] initWithUserId:[concreteUser.pid intValue] accessHash:isSelf ? -1 :[concreteUser.accessHash longLongValue] firstName:concreteUser.firstName lastName:concreteUser.lastName avatarLocation:[self fileLocationWithUserProfilePhoto:concreteUser.photo]];
    }
    
    return nil;
}

+ (SSignal *)remoteChatListWithContext:(TGShareContext *)context offsetDate:(int32_t)offsetDate offsetPeer:(Api65_InputPeer *)offsetPeer offsetMessageId:(int32_t)offsetMessageId limit:(NSUInteger)limit
{
    return [[context function:[Api65 messages_getDialogsWithFlags:@(0) offsetDate:@(offsetDate) offsetId:@(offsetMessageId) offsetPeer:offsetPeer limit:@(limit)]] map:^id(Api65_messages_Dialogs *dialogs)
    {
        NSMutableArray *chatModels = [[NSMutableArray alloc] init];
        NSMutableArray *userModels = [[NSMutableArray alloc] init];
        
        for (Api65_Dialog *dialog in dialogs.dialogs)
        {
            if ([dialog.peer isKindOfClass:[Api65_Peer_peerChat class]])
            {
                Api65_Peer_peerChat *peerChat = (Api65_Peer_peerChat *)dialog.peer;
                for (Api65_Chat *chat in dialogs.chats)
                {
                    if ([chat.pid isEqual:peerChat.chatId])
                    {
                        if ([chat isKindOfClass:[Api65_Chat_chat class]])
                        {
                            Api65_Chat_chat *concreteChat = (Api65_Chat_chat *)chat;
                            if (([concreteChat.flags intValue] & (1 << 5)) != 0) {
                                continue;
                            }
                            
                            TGFileLocation *avatarLocation = nil;
                            if ([concreteChat.photo isKindOfClass:[Api65_ChatPhoto_chatPhoto class]])
                            {
                                avatarLocation = [self fileLocationWithApiLocation:((Api65_ChatPhoto_chatPhoto *)concreteChat.photo).photoSmall];
                            }
                            [chatModels addObject:[[TGGroupChatModel alloc] initWithGroupId:[concreteChat.pid intValue] title:concreteChat.title avatarLocation:avatarLocation]];
                        }
                        break;
                    }
                }
            }
            else if ([dialog.peer isKindOfClass:[Api65_Peer_peerUser class]])
            {
                Api65_Peer_peerUser *peerUser = (Api65_Peer_peerUser *)dialog.peer;
                for (Api65_User *user in dialogs.users)
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
            else if ([dialog.peer isKindOfClass:[Api65_Peer_peerChannel class]])
            {
                Api65_Peer_peerChannel *peerChannel = (Api65_Peer_peerChannel *)dialog.peer;
                for (Api65_Chat *chat in dialogs.chats)
                {
                    if ([chat.pid isEqual:peerChannel.channelId])
                    {
                        if ([chat isKindOfClass:[Api65_Chat_channel class]])
                        {
                            Api65_Chat_channel *concreteChannel = (Api65_Chat_channel *)chat;
                            TGFileLocation *avatarLocation = nil;
                            if ([concreteChannel.photo isKindOfClass:[Api65_ChatPhoto_chatPhoto class]])
                            {
                                avatarLocation = [self fileLocationWithApiLocation:((Api65_ChatPhoto_chatPhoto *)concreteChannel.photo).photoSmall];
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
        
        if (dialogs.dialogs.count != 0) {
            Api65_Dialog *lastDialog = dialogs.dialogs.lastObject;
            int32_t peerId = 0;
            if ([lastDialog.peer isKindOfClass:[Api65_Peer_peerUser class]]) {
                peerId = [((Api65_Peer_peerUser *)lastDialog.peer).userId intValue];
            } else if ([lastDialog.peer isKindOfClass:[Api65_Peer_peerChat class]]) {
                peerId = [((Api65_Peer_peerChat *)lastDialog.peer).chatId intValue];
            } else if ([lastDialog.peer isKindOfClass:[Api65_Peer_peerChannel class]]) {
                peerId = [((Api65_Peer_peerChannel *)lastDialog.peer).channelId intValue];
            }
            
            if (peerId != 0) {
                for (Api65_Message *message in dialogs.messages) {
                    if ([message isKindOfClass:[Api65_Message_message class]]) {
                        Api65_Message_message *concreteMessage = (Api65_Message_message *)message;
                        
                        int32_t messagePeerId = 0;
                        Api65_InputPeer *messagePeer = [Api65_InputPeer inputPeerEmpty];
                        
                        if ([concreteMessage.toId isKindOfClass:[Api65_Peer_peerUser class]]) {
                            if (([concreteMessage.flags intValue] & 2) != 0) {
                                messagePeerId = [((Api65_Peer_peerUser *)concreteMessage.toId).userId intValue];
                            } else {
                                messagePeerId = [concreteMessage.fromId intValue];
                            }
                        } else if ([concreteMessage.toId isKindOfClass:[Api65_Peer_peerChat class]]) {
                            messagePeerId = [((Api65_Peer_peerChat *)concreteMessage.toId).chatId intValue];
                        } else if ([concreteMessage.toId isKindOfClass:[Api65_Peer_peerChannel class]]) {
                            messagePeerId = [((Api65_Peer_peerChannel *)concreteMessage.toId).channelId intValue];
                        }
                        
                        if (messagePeerId == peerId) {
                            if (nextRequestOffset.count == 0) {
                                nextRequestOffset = @{@"offsetDate": @([concreteMessage.date intValue]), @"offsetPeer": messagePeer, @"offsetMessageId": @([concreteMessage.pid intValue])};
                            }
                        }
                    } else if ([message isKindOfClass:[Api65_Message_messageService class]]) {
                        Api65_Message_messageService *concreteMessage = (Api65_Message_messageService *)message;
                        
                        int32_t messagePeerId = 0;
                        Api65_InputPeer *messagePeer = [Api65_InputPeer inputPeerEmpty];
                        
                        if ([concreteMessage.toId isKindOfClass:[Api65_Peer_peerUser class]]) {
                            if (([concreteMessage.flags intValue] & 2) != 0) {
                                messagePeerId = [((Api65_Peer_peerUser *)concreteMessage.toId).userId intValue];
                            } else {
                                messagePeerId = [concreteMessage.fromId intValue];
                            }
                        } else if ([concreteMessage.toId isKindOfClass:[Api65_Peer_peerChat class]]) {
                            messagePeerId = [((Api65_Peer_peerChat *)concreteMessage.toId).chatId intValue];
                        } else if ([concreteMessage.toId isKindOfClass:[Api65_Peer_peerChannel class]]) {
                            messagePeerId = [((Api65_Peer_peerChannel *)concreteMessage.toId).channelId intValue];
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
    return [[self remoteChatListWithContext:context offsetDate:0 offsetPeer:[Api65_InputPeer inputPeerEmpty] offsetMessageId:0 limit:32] mapToSignal:^SSignal *(NSDictionary *chats) {
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
