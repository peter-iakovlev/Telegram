#import "TGBridgeReplyMarkupMediaAttachment.h"
#import "TGReplyMarkupAttachment.h"

@interface TGBridgeReplyMarkupMediaAttachment (TGReplyMarkupAttachment)

+ (TGBridgeReplyMarkupMediaAttachment *)attachmentWithTGReplyMarkupAttachment:(TGReplyMarkupAttachment *)attachment;

@end
