#import "TGBridgeVideoMediaAttachment+TGVideoMediaAttachment.h"
#import "TGBridgeImageInfo+TGImageInfo.h"

@implementation TGBridgeVideoMediaAttachment (TGVideoMediaAttachment)

+ (TGBridgeVideoMediaAttachment *)attachmentWithTGVideoMediaAttachment:(TGVideoMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeVideoMediaAttachment *bridgeAttachment = [[TGBridgeVideoMediaAttachment alloc] init];
    bridgeAttachment.videoId = attachment.videoId;
    bridgeAttachment.thumbnailImageInfo = [TGBridgeImageInfo imageInfoWithTGImageInfo:attachment.thumbnailInfo];
    bridgeAttachment.caption = attachment.caption;
    bridgeAttachment.dimensions = attachment.dimensions;
    bridgeAttachment.duration = attachment.duration;
    
    return bridgeAttachment;
}

+ (TGVideoMediaAttachment *)tgVideoMediaAttachmentWithBridgeVideoMediaAttachment:(TGBridgeVideoMediaAttachment *)bridgeAttachment
{
    if (bridgeAttachment == nil)
        return nil;
    
    TGVideoMediaAttachment *attachment = [[TGVideoMediaAttachment alloc] init];
    attachment.videoId = attachment.videoId;
    attachment.thumbnailInfo = [TGBridgeImageInfo tgImageInfoWithBridgeImageInfo:bridgeAttachment.thumbnailImageInfo];
    attachment.caption = bridgeAttachment.caption;
    attachment.dimensions = bridgeAttachment.dimensions;
    attachment.duration = bridgeAttachment.duration;
    
    return attachment;
}

@end
