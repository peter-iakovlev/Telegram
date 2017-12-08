#import "TGBridgeForwardedMessageMediaAttachment.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGBridgeForwardedMessageMediaAttachment (TGForwardedMessageMediaAttachment)

+ (TGBridgeForwardedMessageMediaAttachment *)attachmentWithTGForwardedMessageMediaAttachment:(TGForwardedMessageMediaAttachment *)attachment;

@end
