#import "TGBridgeAudioMediaAttachment+TGAudioMediaAttachment.h"

@implementation TGBridgeAudioMediaAttachment (TGAudioMediaAttachment)

+ (TGBridgeAudioMediaAttachment *)attachmentWithTGAudioMediaAttachment:(TGAudioMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeAudioMediaAttachment *bridgeAttachment = [[TGBridgeAudioMediaAttachment alloc] init];
    bridgeAttachment.audioId = attachment.audioId;
    bridgeAttachment.accessHash = attachment.accessHash;
    bridgeAttachment.datacenterId = attachment.datacenterId;
    bridgeAttachment.localAudioId = attachment.localAudioId;
    bridgeAttachment.duration = attachment.duration;
    bridgeAttachment.fileSize = attachment.fileSize;
    
    return bridgeAttachment;
}

+ (TGAudioMediaAttachment *)tgAudioMediaAttachmentWithBridgeAudioMediaAttachment:(TGBridgeAudioMediaAttachment *)bridgeAttachment
{
    if (bridgeAttachment == nil)
        return nil;
    
    TGAudioMediaAttachment *attachment = [[TGAudioMediaAttachment alloc] init];
    attachment.audioId = bridgeAttachment.audioId;
    attachment.accessHash = bridgeAttachment.accessHash;
    attachment.datacenterId = bridgeAttachment.datacenterId;
    attachment.localAudioId = bridgeAttachment.localAudioId;
    attachment.duration = bridgeAttachment.duration;
    attachment.fileSize = bridgeAttachment.fileSize;
    
    return attachment;
}

@end
