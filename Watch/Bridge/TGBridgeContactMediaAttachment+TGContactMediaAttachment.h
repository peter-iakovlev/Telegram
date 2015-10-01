#import "TGBridgeContactMediaAttachment.h"
#import "TGContactMediaAttachment.h"

@interface TGBridgeContactMediaAttachment (TGContactMediaAttachment)

+ (TGBridgeContactMediaAttachment *)attachmentWithTGContactMediaAttachment:(TGContactMediaAttachment *)attachment;

@end
