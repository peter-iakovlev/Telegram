#import "TGBridgeReplyMarkupMediaAttachment.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGBridgeReplyMarkupMediaAttachment (TGReplyMarkupAttachment)

+ (TGBridgeReplyMarkupMediaAttachment *)attachmentWithTGReplyMarkupAttachment:(TGReplyMarkupAttachment *)attachment;

@end
