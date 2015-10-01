#import "TGBridgeReplyMessageMediaAttachment.h"
#import "TGReplyMessageMediaAttachment.h"

@interface TGBridgeReplyMessageMediaAttachment (TGReplyMessageMediaAttachment)

+ (TGBridgeReplyMessageMediaAttachment *)attachmentWithTGReplyMessageMediaAttachment:(TGReplyMessageMediaAttachment *)attachment;

@end
