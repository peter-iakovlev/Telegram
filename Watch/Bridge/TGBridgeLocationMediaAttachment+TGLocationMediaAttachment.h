#import "TGBridgeLocationMediaAttachment.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGBridgeLocationMediaAttachment (TGLocationMediaAttachment)

+ (TGBridgeLocationMediaAttachment *)attachmentWithTGLocationMediaAttachment:(TGLocationMediaAttachment *)attachment;

+ (TGLocationMediaAttachment *)tgLocationMediaAttachmentWithBridgeLocationMediaAttachment:(TGBridgeLocationMediaAttachment *)bridgeAttachment;

@end
