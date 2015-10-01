#import "TGBridgeVideoMediaAttachment.h"
#import "TGVideoMediaAttachment.h"

@interface TGBridgeVideoMediaAttachment (TGVideoMediaAttachment)

+ (TGBridgeVideoMediaAttachment *)attachmentWithTGVideoMediaAttachment:(TGVideoMediaAttachment *)attachment;

+ (TGVideoMediaAttachment *)tgVideoMediaAttachmentWithBridgeVideoMediaAttachment:(TGBridgeVideoMediaAttachment *)bridgeAttachment;

@end
