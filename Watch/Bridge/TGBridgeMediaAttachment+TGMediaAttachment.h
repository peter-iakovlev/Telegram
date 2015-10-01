#import "TGBridgeMediaAttachment.h"

@class TGMediaAttachment;

@interface TGBridgeMediaAttachment (TGMediaAttachment)

+ (TGBridgeMediaAttachment *)attachmentWithTGMediaAttachment:(TGMediaAttachment *)mediaAttachment;

@end
