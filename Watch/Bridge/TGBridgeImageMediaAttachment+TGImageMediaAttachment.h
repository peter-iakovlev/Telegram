#import "TGBridgeImageMediaAttachment.h"
#import "TGImageMediaAttachment.h"

@interface TGBridgeImageMediaAttachment (TGImageMediaAttachment)

+ (TGBridgeImageMediaAttachment *)attachmentWithTGImageMediaAttachment:(TGImageMediaAttachment *)attachment;

+ (TGImageMediaAttachment *)tgImageMediaAttachmentWithBridgeImageMediaAttachment:(TGBridgeImageMediaAttachment *)bridgeAttachment;

@end
