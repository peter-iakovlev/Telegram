#import "TGBridgeAudioMediaAttachment+TGAudioMediaAttachment.h"

@implementation TGBridgeAudioMediaAttachment (TGAudioMediaAttachment)

+ (TGBridgeAudioMediaAttachment *)attachmentWithTGAudioMediaAttachment:(TGAudioMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeAudioMediaAttachment *bridgeAttachment = [[TGBridgeAudioMediaAttachment alloc] init];
    bridgeAttachment.duration = attachment.duration;
    bridgeAttachment.fileSize = attachment.fileSize;
    
    return bridgeAttachment;
}

@end
