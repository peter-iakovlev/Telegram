#import "TGBridgeImageMediaAttachment+TGImageMediaAttachment.h"
#import "TGBridgeImageInfo+TGImageInfo.h"

@implementation TGBridgeImageMediaAttachment (TGImageMediaAttachment)

+ (TGBridgeImageMediaAttachment *)attachmentWithTGImageMediaAttachment:(TGImageMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeImageMediaAttachment *bridgeAttachment = [[TGBridgeImageMediaAttachment alloc] init];
    bridgeAttachment.imageId = attachment.imageId;
    bridgeAttachment.localImageId = attachment.localImageId;
    bridgeAttachment.imageInfo = [TGBridgeImageInfo imageInfoWithTGImageInfo:attachment.imageInfo];
    bridgeAttachment.caption = attachment.caption;
    
    return bridgeAttachment;
}

+ (TGImageMediaAttachment *)tgImageMediaAttachmentWithBridgeImageMediaAttachment:(TGBridgeImageMediaAttachment *)bridgeAttachment
{
    if (bridgeAttachment == nil)
        return nil;
    
    TGImageMediaAttachment *attachment = [[TGImageMediaAttachment alloc] init];
    attachment.imageId = bridgeAttachment.imageId;
    attachment.imageInfo = [TGBridgeImageInfo tgImageInfoWithBridgeImageInfo:bridgeAttachment.imageInfo];
    attachment.caption = bridgeAttachment.caption;
    
    return attachment;
}

@end
