#import "TGLocationMediaAttachment.h"

@implementation TGLocationMediaAttachment

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGLocationMediaAttachmentType;
    }
    return self;
}

- (void)serialize:(NSMutableData *)data
{
    int dataLengthPtr = data.length;
    int zero = 0;
    [data appendBytes:&zero length:4];
    
    [data appendBytes:&_latitude length:8];
    [data appendBytes:&_longitude length:8];
    
    int dataLength = data.length - dataLengthPtr - 4;
    [data replaceBytesInRange:NSMakeRange(dataLengthPtr, 4) withBytes:&dataLength];
}

- (TGMediaAttachment *)parseMediaAttachment:(NSInputStream *)is
{
    int dataLength = 0;
    [is read:(uint8_t *)&dataLength maxLength:4];
    
    TGLocationMediaAttachment *locationAttachment = [[TGLocationMediaAttachment alloc] init];
    
    double tmp = 0;
    [is read:(uint8_t *)&tmp maxLength:8];
    locationAttachment.latitude = tmp;
    
    tmp = 0;
    [is read:(uint8_t *)&tmp maxLength:8];
    locationAttachment.longitude = tmp;
    
    return locationAttachment;
}

@end
