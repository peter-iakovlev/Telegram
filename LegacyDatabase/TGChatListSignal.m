#import "TGChatListSignal.h"

#import <LegacyDatabase/LegacyDatabase.h>

@implementation TGChatListSignal

+ (TGFileLocation *)fileLocationWithApiLocation:(Api70_FileLocation *)location
{
    if ([location isKindOfClass:[Api70_FileLocation_fileLocation class]])
    {
        Api70_FileLocation_fileLocation *concreteLocation = (Api70_FileLocation_fileLocation *)location;
        return [[TGFileLocation alloc] initWithDatacenterId:[concreteLocation.dcId intValue] volumeId:[[concreteLocation volumeId] longLongValue] localId:[concreteLocation.localId intValue] secret:[concreteLocation.secret longLongValue]];
    }
    return nil;
}

+ (TGFileLocation *)fileLocationWithUserProfilePhoto:(Api70_UserProfilePhoto *)photo
{
    if ([photo isKindOfClass:[Api70_UserProfilePhoto_userProfilePhoto class]])
    {
        Api70_UserProfilePhoto_userProfilePhoto *concretePhoto = (Api70_UserProfilePhoto_userProfilePhoto *)photo;
        return [self fileLocationWithApiLocation:concretePhoto.photoSmall];
    }
    return nil;
}

+ (TGUserModel *)userModelWithApiUser:(Api70_User *)user
{
    if ([user isKindOfClass:[Api70_User_user class]])
    {
        Api70_User_user *concreteUser = (Api70_User_user *)user;
        
        bool isSelf = [concreteUser.flags intValue] & (1 << 10);
        
        return [[TGUserModel alloc] initWithUserId:[concreteUser.pid intValue] accessHash:isSelf ? -1 :[concreteUser.accessHash longLongValue] firstName:concreteUser.firstName lastName:concreteUser.lastName avatarLocation:[self fileLocationWithUserProfilePhoto:concreteUser.photo]];
    }
    
    return nil;
}

+ (SSignal *)remoteChatListWithContext:(TGShareContext *)context offsetDate:(int32_t)offsetDate offsetPeer:(Api70_InputPeer *)offsetPeer offsetMessageId:(int32_t)offsetMessageId limit:(NSUInteger)limit
{
    return [[context function:[Api70 messages_getDialogsWithFlags:@(0) offsetDate:@(offsetDate) offsetId:@(offsetMessageId) offsetPeer:offsetPeer limit:@(limit)]] map:^id(Api70_messages_Dialogs *dialogs)
    {
        NSMutableArray *chatModels = [[NSMutableArray alloc] init];
        NSMutableArray *userModels = [[NSMutableArray alloc] init];
        
        for (Api70_Dialog *dialog in dialogs.dialogs)
        {
            if ([dialog.peer isKindOfClass:[Api70_Peer_peerChat class]])
            {
                Api70_Peer_peerChat *peerChat = (Api70_Peer_peerChat *)dialog.peer;
                for (Api70_Chat *chat in dialogs.chats)
                {
                    if ([chat.pid isEqual:peerChat.chatId])
                    {
                        if ([chat isKindOfClass:[Api70_Chat_chat class]])
                        {
                            Api70_Chat_chat *concreteChat = (Api70_Chat_chat *)chat;
                            if (([concreteChat.flags intValue] & (1 << 5)) != 0) {
                                continue;
                            }
                            
                            TGFileLocation *avatarLocation = nil;
                            if ([concreteChat.photo isKindOfClass:[Api70_ChatPhoto_chatPhoto class]])
                            {
                                avatarLocation = [self fileLocationWithApiLocation:((Api70_ChatPhoto_chatPhoto *)concreteChat.photo).photoSmall];
                            }
                            [chatModels addObject:[[TGGroupChatModel alloc] initWithGroupId:[concreteChat.pid intValue] title:concreteChat.title avatarLocation:avatarLocation]];
                        }
                        break;
                    }
                }
            }
            else if ([dialog.peer isKindOfClass:[Api70_Peer_peerUser class]])
            {
                Api70_Peer_peerUser *peerUser = (Api70_Peer_peerUser *)dialog.peer;
                for (Api70_User *user in dialogs.users)
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
            else if ([dialog.peer isKindOfClass:[Api70_Peer_peerChannel class]])
            {
                Api70_Peer_peerChannel *peerChannel = (Api70_Peer_peerChannel *)dialog.peer;
                for (Api70_Chat *chat in dialogs.chats)
                {
                    if ([chat.pid isEqual:peerChannel.channelId])
                    {
                        if ([chat isKindOfClass:[Api70_Chat_channel class]])
                        {
                            Api70_Chat_channel *concreteChannel = (Api70_Chat_channel *)chat;
                            TGFileLocation *avatarLocation = nil;
                            if ([concreteChannel.photo isKindOfClass:[Api70_ChatPhoto_chatPhoto class]])
                            {
                                avatarLocation = [self fileLocationWithApiLocation:((Api70_ChatPhoto_chatPhoto *)concreteChannel.photo).photoSmall];
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
            Api70_Dialog *lastDialog = dialogs.dialogs.lastObject;
            int32_t peerId = 0;
            if ([lastDialog.peer isKindOfClass:[Api70_Peer_peerUser class]]) {
                peerId = [((Api70_Peer_peerUser *)lastDialog.peer).userId intValue];
            } else if ([lastDialog.peer isKindOfClass:[Api70_Peer_peerChat class]]) {
                peerId = [((Api70_Peer_peerChat *)lastDialog.peer).chatId intValue];
            } else if ([lastDialog.peer isKindOfClass:[Api70_Peer_peerChannel class]]) {
                peerId = [((Api70_Peer_peerChannel *)lastDialog.peer).channelId intValue];
            }
            
            if (peerId != 0) {
                for (Api70_Message *message in dialogs.messages) {
                    if ([message isKindOfClass:[Api70_Message_message class]]) {
                        Api70_Message_message *concreteMessage = (Api70_Message_message *)message;
                        
                        int32_t messagePeerId = 0;
                        Api70_InputPeer *messagePeer = [Api70_InputPeer inputPeerEmpty];
                        
                        if ([concreteMessage.toId isKindOfClass:[Api70_Peer_peerUser class]]) {
                            if (([concreteMessage.flags intValue] & 2) != 0) {
                                messagePeerId = [((Api70_Peer_peerUser *)concreteMessage.toId).userId intValue];
                            } else {
                                messagePeerId = [concreteMessage.fromId intValue];
                            }
                        } else if ([concreteMessage.toId isKindOfClass:[Api70_Peer_peerChat class]]) {
                            messagePeerId = [((Api70_Peer_peerChat *)concreteMessage.toId).chatId intValue];
                        } else if ([concreteMessage.toId isKindOfClass:[Api70_Peer_peerChannel class]]) {
                            messagePeerId = [((Api70_Peer_peerChannel *)concreteMessage.toId).channelId intValue];
                        }
                        
                        if (messagePeerId == peerId) {
                            if (nextRequestOffset.count == 0) {
                                nextRequestOffset = @{@"offsetDate": @([concreteMessage.date intValue]), @"offsetPeer": messagePeer, @"offsetMessageId": @([concreteMessage.pid intValue])};
                            }
                        }
                    } else if ([message isKindOfClass:[Api70_Message_messageService class]]) {
                        Api70_Message_messageService *concreteMessage = (Api70_Message_messageService *)message;
                        
                        int32_t messagePeerId = 0;
                        Api70_InputPeer *messagePeer = [Api70_InputPeer inputPeerEmpty];
                        
                        if ([concreteMessage.toId isKindOfClass:[Api70_Peer_peerUser class]]) {
                            if (([concreteMessage.flags intValue] & 2) != 0) {
                                messagePeerId = [((Api70_Peer_peerUser *)concreteMessage.toId).userId intValue];
                            } else {
                                messagePeerId = [concreteMessage.fromId intValue];
                            }
                        } else if ([concreteMessage.toId isKindOfClass:[Api70_Peer_peerChat class]]) {
                            messagePeerId = [((Api70_Peer_peerChat *)concreteMessage.toId).chatId intValue];
                        } else if ([concreteMessage.toId isKindOfClass:[Api70_Peer_peerChannel class]]) {
                            messagePeerId = [((Api70_Peer_peerChannel *)concreteMessage.toId).channelId intValue];
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
    return [[self remoteChatListWithContext:context offsetDate:0 offsetPeer:[Api70_InputPeer inputPeerEmpty] offsetMessageId:0 limit:32] mapToSignal:^SSignal *(NSDictionary *chats) {
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
