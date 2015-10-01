#import "TGBridgeUnsupportedMediaAttachment.h"

const NSInteger TGBridgeUnsupportedMediaAttachmentType = 0x3837BEF7;

@implementation TGBridgeUnsupportedMediaAttachment

+ (NSInteger)mediaType
{
    return TGBridgeUnsupportedMediaAttachmentType;
}

@end
