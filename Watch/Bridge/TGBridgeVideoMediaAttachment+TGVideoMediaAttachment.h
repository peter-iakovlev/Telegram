#import "TGBridgeVideoMediaAttachment.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGBridgeVideoMediaAttachment (TGVideoMediaAttachment)

+ (TGBridgeVideoMediaAttachment *)attachmentWithTGVideoMediaAttachment:(TGVideoMediaAttachment *)attachment;

+ (TGVideoMediaAttachment *)tgVideoMediaAttachmentWithBridgeVideoMediaAttachment:(TGBridgeVideoMediaAttachment *)bridgeAttachment;

@end
