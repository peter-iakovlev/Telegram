#import "TGBridgeForwardedMessageMediaAttachment+TGForwardedMessageMediaAttachment.h"

#import "TGPeerIdAdapter.h"

@implementation TGBridgeForwardedMessageMediaAttachment (TGForwardedMessageMediaAttachment)

+ (TGBridgeForwardedMessageMediaAttachment *)attachmentWithTGForwardedMessageMediaAttachment:(TGForwardedMessageMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeForwardedMessageMediaAttachment *bridgeAttachment = [[TGBridgeForwardedMessageMediaAttachment alloc] init];
    if (TGPeerIdIsChannel(attachment.forwardPeerId)) {
        
    } else {
        bridgeAttachment.uid = (int32_t)attachment.forwardPeerId;
    }
    bridgeAttachment.date = attachment.forwardDate;
    bridgeAttachment.mid = attachment.forwardMid;
    
    return bridgeAttachment;
}

@end
