#import "TGChatListSignal.h"

#import "TGPrivateChatModel.h"
#import "TGGroupChatModel.h"
#import "TGUserModel.h"

@implementation TGChatListSignal

+ (TGFileLocation *)fileLocationWithApiLocation:(Api38_FileLocation *)location
{
    if ([location isKindOfClass:[Api38_FileLocation_fileLocation class]])
    {
        Api38_FileLocation_fileLocation *concreteLocation = (Api38_FileLocation_fileLocation *)location;
        return [[TGFileLocation alloc] initWithDatacenterId:[concreteLocation.dcId intValue] volumeId:[[concreteLocation volumeId] longLongValue] localId:[concreteLocation.localId intValue] secret:[concreteLocation.secret longLongValue]];
    }
    return nil;
}

+ (TGFileLocation *)fileLocationWithUserProfilePhoto:(Api38_UserProfilePhoto *)photo
{
    if ([photo isKindOfClass:[Api38_UserProfilePhoto_userProfilePhoto class]])
    {
        Api38_UserProfilePhoto_userProfilePhoto *concretePhoto = (Api38_UserProfilePhoto_userProfilePhoto *)photo;
        return [self fileLocationWithApiLocation:concretePhoto.photoSmall];
    }
    return nil;
}

+ (TGUserModel *)userModelWithApiUser:(Api38_User *)user
{
    if ([user isKindOfClass:[Api38_User_user class]])
    {
        Api38_User_user *concreteUser = (Api38_User_user *)user;
        
        bool isSelf = [concreteUser.flags intValue] & (1 << 10);
        
        return [[TGUserModel alloc] initWithUserId:[concreteUser.pid intValue] accessHash:isSelf ? -1 :[concreteUser.accessHash longLongValue] firstName:concreteUser.firstName lastName:concreteUser.lastName avatarLocation:[self fileLocationWithUserProfilePhoto:concreteUser.photo]];
    }
    
    return nil;
}

+ (SSignal *)remoteChatListWithContext:(TGShareContext *)context offset:(NSUInteger)offset limit:(NSUInteger)limit
{
    return [[context function:[Api38 messages_getDialogsWithOffset:@(offset) limit:@(limit)]] map:^id(Api38_messages_Dialogs *dialogs)
    {
        NSMutableArray *chatModels = [[NSMutableArray alloc] init];
        NSMutableArray *userModels = [[NSMutableArray alloc] init];
        
        for (Api38_Dialog *dialog in dialogs.dialogs)
        {
            if ([dialog.peer isKindOfClass:[Api38_Peer_peerChat class]])
            {
                Api38_Peer_peerChat *peerChat = (Api38_Peer_peerChat *)dialog.peer;
                for (Api38_Chat *chat in dialogs.chats)
                {
                    if ([chat.pid isEqual:peerChat.chatId])
                    {
                        if ([chat isKindOfClass:[Api38_Chat_chat class]])
                        {
                            Api38_Chat_chat *concreteChat = (Api38_Chat_chat *)chat;
                            TGFileLocation *avatarLocation = nil;
                            if ([concreteChat.photo isKindOfClass:[Api38_ChatPhoto_chatPhoto class]])
                            {
                                avatarLocation = [self fileLocationWithApiLocation:((Api38_ChatPhoto_chatPhoto *)concreteChat.photo).photoSmall];
                            }
                            [chatModels addObject:[[TGGroupChatModel alloc] initWithGroupId:[concreteChat.pid intValue] title:concreteChat.title avatarLocation:avatarLocation]];
                        }
                        break;
                    }
                }
            }
            else if ([dialog.peer isKindOfClass:[Api38_Peer_peerUser class]])
            {
                Api38_Peer_peerUser *peerUser = (Api38_Peer_peerUser *)dialog.peer;
                for (Api38_User *user in dialogs.users)
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
        }
        
        return @{@"chats": chatModels, @"users": userModels};
    }];
}

+ (SSignal *)remoteChatListWithContext:(TGShareContext *)context
{
    SSignal *loadHead = [self remoteChatListWithContext:context offset:0 limit:32];
    SSignal *loadRest = [self remoteChatListWithContext:context offset:32 limit:64];
    
    return [[loadHead then:loadRest] reduceLeftWithPassthrough:@{} with:^id(NSDictionary *currentChats, NSDictionary *newChats, void (^passthrough)(id))
    {
        NSMutableArray *chatModels = [[NSMutableArray alloc] initWithArray:currentChats[@"chats"]];
        NSMutableArray *userModels = [[NSMutableArray alloc] initWithArray:currentChats[@"users"]];
        
        for (TGChatModel *chatModel in newChats[@"chats"])
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
                [chatModels addObject:chatModel];
        }
        
        for (TGUserModel *userModel in newChats[@"users"])
        {
            bool found = false;
            for (TGUserModel *currentUserModel in userModels)
            {
                if (currentUserModel.userId == userModel.userId)
                {
                    found = true;
                    break;
                }
            }
            if (!found)
                [userModels addObject:userModel];
        }
        
        NSDictionary *updatedChats = @{@"chats": chatModels, @"users": userModels};
        
        if (((NSArray *)currentChats[@"chats"]).count == 0)
            passthrough(updatedChats);
        
        return updatedChats;
    }];
}

@end
