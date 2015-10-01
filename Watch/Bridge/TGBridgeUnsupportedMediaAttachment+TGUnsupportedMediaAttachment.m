#import "TGBridgeUnsupportedMediaAttachment+TGUnsupportedMediaAttachment.h"

@implementation TGBridgeUnsupportedMediaAttachment (TGUnsupportedMediaAttachment)

+ (TGBridgeUnsupportedMediaAttachment *)attachmentWithTGUnsupportedMediaAttachment:(TGUnsupportedMediaAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    return [[TGBridgeUnsupportedMediaAttachment alloc] init];
}

@end
