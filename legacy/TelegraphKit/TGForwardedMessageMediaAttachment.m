#import "TGForwardedMessageMediaAttachment.h"

@implementation TGForwardedMessageMediaAttachment

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
    
    attachment.forwardPeerId = _forwardPeerId;
    attachment.forwardDate = _forwardDate;
    
    attachment.forwardMid = _forwardMid;
    
    return attachment;
}

- (void)serialize:(NSMutableData *)data
{
    int32_t magic = 0x72413faa;
    [data appendBytes:&magic length:4];
    
    int dataLengthPtr = (int)data.length;
    int zero = 0;
    [data appendBytes:&zero length:4];
    
    [data appendBytes:&_forwardPeerId length:8];
    [data appendBytes:&_forwardDate length:4];
    [data appendBytes:&_forwardMid length:4];
    
    int dataLength = (int)(data.length - dataLengthPtr - 4);
    [data replaceBytesInRange:NSMakeRange(dataLengthPtr, 4) withBytes:&dataLength];
}

- (TGMediaAttachment *)parseMediaAttachment:(NSInputStream *)is
{
    int32_t magic = 0;
    [is read:(uint8_t *)&magic maxLength:4];
    
    int32_t dataLength = 0;
    
    int32_t version = 0;
    
    if (magic == 0x72413faa) {
        version = 2;
        [is read:(uint8_t *)&dataLength maxLength:4];
    } else {
        dataLength = magic;
    }
    
    TGForwardedMessageMediaAttachment *messageAttachment = [[TGForwardedMessageMediaAttachment alloc] init];
    
    if (version == 2) {
        int64_t forwardPeerId = 0;
        [is read:(uint8_t *)&forwardPeerId maxLength:8];
        messageAttachment.forwardPeerId = forwardPeerId;
    } else {
        int32_t forwardUid = 0;
        [is read:(uint8_t *)&forwardUid maxLength:4];
        messageAttachment.forwardPeerId = forwardUid;
    }
    
    int forwardDate = 0;
    [is read:(uint8_t *)&forwardDate maxLength:4];
    messageAttachment.forwardDate = forwardDate;
    
    int forwardMid = 0;
    [is read:(uint8_t *)&forwardMid maxLength:4];
    messageAttachment.forwardMid = forwardMid;
    
    return messageAttachment;
}

@end
