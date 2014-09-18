#import "TGImageMediaAttachment.h"

@implementation TGImageMediaAttachment

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGImageMediaAttachmentType;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
    
    imageAttachment.imageId = _imageId;
    imageAttachment.accessHash = _accessHash;
    imageAttachment.date = _date;
    imageAttachment.hasLocation = _hasLocation;
    imageAttachment.locationLatitude = _locationLatitude;
    imageAttachment.locationLongitude = _locationLongitude;
    imageAttachment.imageInfo = _imageInfo;
    
    return imageAttachment;
}

- (void)serialize:(NSMutableData *)data
{
    int dataLengthPtr = data.length;
    int zero = 0;
    [data appendBytes:&zero length:4];
    
    [data appendBytes:&_imageId length:8];
    
    [data appendBytes:(uint8_t *)&_date length:4];
    
    uint8_t hasLocation = _hasLocation ? 1 : 0;
    [data appendBytes:&hasLocation length:1];
    
    if (_hasLocation)
    {
        [data appendBytes:(uint8_t *)&_locationLatitude length:8];
        [data appendBytes:(uint8_t *)&_locationLongitude length:8];
    }
    
    uint8_t hasImageInfo = _imageInfo != nil ? 1 : 0;
    [data appendBytes:&hasImageInfo length:1];
    if (hasImageInfo != 0)
    {
        [_imageInfo serialize:data];
    }
    
    [data appendBytes:&_accessHash length:8];
    
    int dataLength = data.length - dataLengthPtr - 4;
    [data replaceBytesInRange:NSMakeRange(dataLengthPtr, 4) withBytes:&dataLength];
}

- (TGMediaAttachment *)parseMediaAttachment:(NSInputStream *)is
{
    int dataLength = 0;
    [is read:(uint8_t *)&dataLength maxLength:4];
    
    TGImageMediaAttachment *imageAttachment = [[TGImageMediaAttachment alloc] init];
    
    int64_t imageId = 0;
    [is read:(uint8_t *)&imageId maxLength:8];
    dataLength -= 8;
    
    imageAttachment.imageId = imageId;
    
    int date = 0;
    [is read:(uint8_t *)&date maxLength:4];
    dataLength -= 4;
    
    imageAttachment.date = date;
    
    uint8_t hasLocation = 0;
    [is read:&hasLocation maxLength:1];
    dataLength -= 1;
    
    imageAttachment.hasLocation = hasLocation != 0;
    
    if (hasLocation != 0)
    {
        double value = 0;
        [is read:(uint8_t *)&value maxLength:8];
        imageAttachment.locationLatitude = value;
        [is read:(uint8_t *)&value maxLength:8];
        imageAttachment.locationLongitude = value;
        
        dataLength -= 16;
    }
    
    uint8_t hasImageInfo = 0;
    [is read:&hasImageInfo maxLength:1];
    if (hasImageInfo != 0)
    {
        TGImageInfo *imageInfo = [TGImageInfo deserialize:is];
        if (imageInfo != nil)
            imageAttachment.imageInfo = imageInfo;
    }
    
    int64_t accessHash = 0;
    [is read:(uint8_t *)&accessHash maxLength:8];
    imageAttachment.accessHash = accessHash;
    
    return imageAttachment;
}

@end
