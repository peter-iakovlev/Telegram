#import "TGBridgeChat+TGConversation.h"
#import "TGBridgeMediaAttachment+TGMediaAttachment.h"
#import "TGConversation.h"

@implementation TGBridgeChat (TGConversation)

+ (TGBridgeChat *)chatWithTGConversation:(TGConversation *)conversation
{
    TGBridgeChat *chat = [[TGBridgeChat alloc] init];
    chat->_identifier = conversation.conversationId;
    chat->_date = conversation.messageDate;
    chat->_fromUid = conversation.fromUid;
    chat->_text = conversation.text;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    for (TGMediaAttachment *attachment in conversation.media)
    {
        TGBridgeMediaAttachment *bridgeAttachment = [TGBridgeMediaAttachment attachmentWithTGMediaAttachment:attachment];
        if (bridgeAttachment != nil)
            [attachments addObject:bridgeAttachment];
    }
    chat->_media = attachments;
    
    chat->_outgoing = conversation.outgoing;
    chat->_unread = conversation.unread;
    chat->_unreadCount = conversation.unreadCount;
    chat->_deliveryState = (TGBridgeMessageDeliveryState)conversation.deliveryState;
    chat->_deliveryError = conversation.deliveryError;
    
    chat->_groupTitle = conversation.chatTitle;
    chat->_groupPhotoSmall = conversation.chatPhotoSmall;
    chat->_groupPhotoMedium = conversation.chatPhotoMedium;
    chat->_groupPhotoBig = conversation.chatPhotoBig;
    
    chat->_isGroup = conversation.isChat;
    chat->_hasLeftGroup = conversation.leftChat;
    chat->_isKickedFromGroup = conversation.kickedFromChat;
    
    chat->_isChannel = conversation.isChannel;
    chat->_isChannelGroup = conversation.isChannelGroup;
    
    chat->_userName = conversation.username;
    chat->_about = conversation.about;
    chat->_isVerified = conversation.isVerified;
    
    chat->_participantsCount = conversation.chatParticipantCount;
    chat->_participants = [conversation.chatParticipants.chatParticipantUids copy];
    
    return chat;
}

@end
