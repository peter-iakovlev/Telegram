#import "TGBridgeMessage+TGMessage.h"
#import "TGBridgeMediaAttachment+TGMediaAttachment.h"
#import "TGMessage.h"
#import "TGConversation.h"

@implementation TGBridgeMessage (TGMessage)

+ (TGBridgeMessage *)messageWithTGMessage:(TGMessage *)message conversation:(TGConversation *)conversation
{
    TGBridgeMessage *bridgeMessage = [[TGBridgeMessage alloc] init];
    bridgeMessage->_identifier = message.mid;
    bridgeMessage->_date = message.date;
    bridgeMessage->_randomId = message.randomId;
    bridgeMessage->_unread = [conversation isMessageUnread:message];
    bridgeMessage->_outgoing = message.outgoing;
    bridgeMessage->_fromUid = message.fromUid;
    bridgeMessage->_toUid = message.toUid;
    bridgeMessage->_cid = message.cid;
    bridgeMessage->_text = message.text;
    bridgeMessage->_deliveryState = (TGBridgeMessageDeliveryState)message.deliveryState;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        TGBridgeMediaAttachment *bridgeAttachment = [TGBridgeMediaAttachment attachmentWithTGMediaAttachment:attachment];
        if (bridgeAttachment != nil)
            [attachments addObject:bridgeAttachment];
    }
    bridgeMessage->_media = attachments;
    
    return bridgeMessage;
}

+ (TGBridgeMessage *)channelMessageWithTGMessage:(TGMessage *)message conversation:(TGConversation *)conversation
{
    TGBridgeMessage *bridgeMessage = [self messageWithTGMessage:message conversation:conversation];
    bridgeMessage->_outgoing = false;
    return bridgeMessage;
}

@end
