#import "TGBridgeMessage+TGMessage.h"
#import "TGBridgeMediaAttachment+TGMediaAttachment.h"
#import "TGMessage.h"

@implementation TGBridgeMessage (TGMessage)

+ (TGBridgeMessage *)messageWithTGMessage:(TGMessage *)message
{
    TGBridgeMessage *bridgeMessage = [[TGBridgeMessage alloc] init];
    bridgeMessage->_identifier = message.mid;
    bridgeMessage->_date = message.date;
    bridgeMessage->_randomId = message.randomId;
    bridgeMessage->_unread = message.unread;
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

+ (TGBridgeMessage *)channelMessageWithTGMessage:(TGMessage *)message
{
    TGBridgeMessage *bridgeMessage = [self messageWithTGMessage:message];
    bridgeMessage->_outgoing = false;
    return bridgeMessage;
}

@end
