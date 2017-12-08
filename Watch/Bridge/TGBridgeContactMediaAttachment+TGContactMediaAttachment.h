#import "TGBridgeContactMediaAttachment.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGBridgeContactMediaAttachment (TGContactMediaAttachment)

+ (TGBridgeContactMediaAttachment *)attachmentWithTGContactMediaAttachment:(TGContactMediaAttachment *)attachment;

@end
