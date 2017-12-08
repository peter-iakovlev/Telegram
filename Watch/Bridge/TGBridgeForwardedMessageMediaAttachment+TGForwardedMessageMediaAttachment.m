#import "TGBridgeForwardedMessageMediaAttachment+TGForwardedMessageMediaAttachment.h"

#import <LegacyComponents/LegacyComponents.h>

@implementation TGBridgeForwardedMessageMediaAttachment (TGForwardedMessageMediaAttachment)

+ (TGBridgeForwardedMessageMediaAttachment *)attachmentWithTGForwardedMessageMediaAttachment:(TGForwardedMessageMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeForwardedMessageMediaAttachment *bridgeAttachment = [[TGBridgeForwardedMessageMediaAttachment alloc] init];
    bridgeAttachment.peerId = attachment.forwardPeerId;
    bridgeAttachment.date = attachment.forwardDate;
    bridgeAttachment.mid = attachment.forwardMid;
    
    return bridgeAttachment;
}

@end
