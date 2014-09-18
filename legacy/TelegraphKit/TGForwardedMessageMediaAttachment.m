#import "TGForwardedMessageMediaAttachment.h"

@implementation TGForwardedMessageMediaAttachment

@synthesize forwardUid = _forwardUid;
@synthesize forwardDate = _forwardDate;

@synthesize forwardMid = _forwardMid;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGForwardedMessageMediaAttachmentType;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGForwardedMessageMediaAttachment *attachment = [[TGForwardedMessageMediaAttachment alloc] init];
    
    attachment.forwardUid = _forwardUid;
    attachment.forwardDate = _forwardDate;
    
    attachment.forwardMid = _forwardMid;
    
    return attachment;
}

- (void)serialize:(NSMutableData *)data
{
    int dataLengthPtr = data.length;
    int zero = 0;
    [data appendBytes:&zero length:4];
    
    [data appendBytes:&_forwardUid length:4];
    [data appendBytes:&_forwardDate length:4];
    [data appendBytes:&_forwardMid length:4];
    
    int dataLength = data.length - dataLengthPtr - 4;
    [data replaceBytesInRange:NSMakeRange(dataLengthPtr, 4) withBytes:&dataLength];
}

- (TGMediaAttachment *)parseMediaAttachment:(NSInputStream *)is
{
    int dataLength = 0;
    [is read:(uint8_t *)&dataLength maxLength:4];
    
    TGForwardedMessageMediaAttachment *messageAttachment = [[TGForwardedMessageMediaAttachment alloc] init];
    
    int forwardUid = 0;
    [is read:(uint8_t *)&forwardUid maxLength:4];
    messageAttachment.forwardUid = forwardUid;
    
    int forwardDate = 0;
    [is read:(uint8_t *)&forwardDate maxLength:4];
    messageAttachment.forwardDate = forwardDate;
    
    int forwardMid = 0;
    [is read:(uint8_t *)&forwardMid maxLength:4];
    messageAttachment.forwardMid = forwardMid;
    
    return messageAttachment;
}

@end
