#import "TGBridgeReplyMessageMediaAttachment+TGReplyMessageMediaAttachment.h"
#import "TGBridgeMessage+TGMessage.h"

@implementation TGBridgeReplyMessageMediaAttachment (TGReplyMessageMediaAttachment)

+ (TGBridgeReplyMessageMediaAttachment *)attachmentWithTGReplyMessageMediaAttachment:(TGReplyMessageMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeReplyMessageMediaAttachment *bridgeAttachment = [[TGBridgeReplyMessageMediaAttachment alloc] init];
    bridgeAttachment.mid = attachment.replyMessageId;
    bridgeAttachment.message = [TGBridgeMessage messageWithTGMessage:attachment.replyMessage conversation:nil];
    return bridgeAttachment;
}

@end
