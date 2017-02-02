#import "TGBridgeSendMessageHandler.h"
#import "TGBridgeSendMessageSubscription.h"

#import "TGSendMessageSignals.h"

#import "TGBridgeMessage+TGMessage.h"
#import "TGBridgeLocationMediaAttachment+TGLocationMediaAttachment.h"
#import "TGBridgeDocumentMediaAttachment+TGDocumentMediaAttachment.h"

@implementation TGBridgeSendMessageHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)__unused server
{
    if ([subscription isKindOfClass:[TGBridgeSendTextMessageSubscription class]])
    {
        TGBridgeSendTextMessageSubscription *sendMessageSubscription = (TGBridgeSendTextMessageSubscription *)subscription;
                
        return [[TGSendMessageSignals sendTextMessageWithPeerId:sendMessageSubscription.peerId text:sendMessageSubscription.text replyToMid:sendMessageSubscription.replyToMid] map:^TGBridgeMessage *(TGMessage *message)
        {
            return [TGBridgeMessage messageWithTGMessage:message conversation:nil];
        }];
    }
    else if ([subscription isKindOfClass:[TGBridgeSendLocationMessageSubscription class]])
    {
        TGBridgeSendLocationMessageSubscription *sendMessageSubscription = (TGBridgeSendLocationMessageSubscription *)subscription;
        TGLocationMediaAttachment *attachment = [TGBridgeLocationMediaAttachment tgLocationMediaAttachmentWithBridgeLocationMediaAttachment:sendMessageSubscription.location];
        
        return [[TGSendMessageSignals sendLocationWithPeerId:sendMessageSubscription.peerId replyToMid:sendMessageSubscription.replyToMid locationAttachment:attachment] map:^TGBridgeMessage *(TGMessage *message)
        {
            return [TGBridgeMessage messageWithTGMessage:message conversation:nil];
        }];
    }
    else if ([subscription isKindOfClass:[TGBridgeSendStickerMessageSubscription class]])
    {
        TGBridgeSendStickerMessageSubscription *sendMessageSubscription = (TGBridgeSendStickerMessageSubscription *)subscription;
        TGDocumentMediaAttachment *attachment = [TGBridgeDocumentMediaAttachment tgDocumentMediaAttachmentWithBridgeDocumentMediaAttachment:sendMessageSubscription.document];
        
        return [[TGSendMessageSignals sendRemoteDocumentWithPeerId:sendMessageSubscription.peerId replyToMid:sendMessageSubscription.replyToMid documentAttachment:attachment] map:^TGBridgeMessage *(TGMessage *message)
        {
            return [TGBridgeMessage messageWithTGMessage:message conversation:nil];
        }];
    }
    else if ([subscription isKindOfClass:[TGBridgeSendForwardedMessageSubscription class]])
    {
        TGBridgeSendForwardedMessageSubscription *sendMessageSubscription = (TGBridgeSendForwardedMessageSubscription *)subscription;
        
        return [[TGSendMessageSignals forwardMessageWithMid:sendMessageSubscription.messageId peerId:sendMessageSubscription.peerId] map:^TGBridgeMessage *(TGMessage *message)
        {
            return [TGBridgeMessage messageWithTGMessage:message conversation:nil];
        }];
    }
    
    return nil;
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeSendTextMessageSubscription class], [TGBridgeSendLocationMessageSubscription class], [TGBridgeSendStickerMessageSubscription class], [TGBridgeSendForwardedMessageSubscription class] ];
}

@end
