#import "TGBridgeLocationMediaAttachment.h"
#import "TGLocationMediaAttachment.h"

@interface TGBridgeLocationMediaAttachment (TGLocationMediaAttachment)

+ (TGBridgeLocationMediaAttachment *)attachmentWithTGLocationMediaAttachment:(TGLocationMediaAttachment *)attachment;

+ (TGLocationMediaAttachment *)tgLocationMediaAttachmentWithBridgeLocationMediaAttachment:(TGBridgeLocationMediaAttachment *)bridgeAttachment;

@end
