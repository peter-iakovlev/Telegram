#import "TGImageMediaAttachment.h"

#import "TGMessage.h"
#import "TGStringUtils.h"

/*
 @property (nonatomic) int64_t imageId;
 @property (nonatomic, readonly) int64_t localImageId;
 @property (nonatomic) int64_t accessHash;
 @property (nonatomic) int date;
 @property (nonatomic) bool hasLocation;
 @property (nonatomic) double locationLatitude;
 @property (nonatomic) double locationLongitude;
 @property (nonatomic, strong) TGImageInfo *imageInfo;
 */

@interface TGImageMediaAttachment ()
{
    NSArray *_textCheckingResults;
}
@end

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

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGImageMediaAttachmentType;
        _imageId = [aDecoder decodeInt64ForKey:@"imageId"];
        _accessHash = [aDecoder decodeInt64ForKey:@"accessHash"];
        _date = [aDecoder decodeInt32ForKey:@"date"];
        _hasLocation = false;
        _locationLatitude = 0;
        _locationLongitude = 0;
        _imageInfo = [aDecoder decodeObjectForKey:@"imageInfo"];
        _caption = [aDecoder decodeObjectForKey:@"caption"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:_imageId forKey:@"imageId"];
    [aCoder encodeInt64:_accessHash forKey:@"accessHash"];
    [aCoder encodeInt32:_date forKey:@"date"];
    [aCoder encodeObject:_imageInfo forKey:@"imageInfo"];
    [aCoder encodeObject:_caption forKey:@"caption"];
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
    imageAttachment.caption = _caption;
    
    return imageAttachment;
}

- (int64_t)localImageId
{
    NSString *legacyCacheUrl = [self.imageInfo imageUrlForLargestSize:NULL];
    int64_t localImageId = 0;
    if (legacyCacheUrl.length != 0)
        localImageId = murMurHash32(legacyCacheUrl);
    
    return localImageId;
}

- (void)serialize:(NSMutableData *)data
{
    int32_t modernTag = 0x7abacaf1;
    [data appendBytes:&modernTag length:4];
    
    uint8_t version = 2;
    [data appendBytes:&version length:1];
    
    int dataLengthPtr = (int)data.length;
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
    
    NSData *captionData = [_caption dataUsingEncoding:NSUTF8StringEncoding];
    int32_t captionLength = (int32_t)captionData.length;
    [data appendBytes:&captionLength length:4];
    if (captionLength != 0)
        [data appendData:captionData];
    
    int dataLength = (int)(data.length - dataLengthPtr - 4);
    [data replaceBytesInRange:NSMakeRange(dataLengthPtr, 4) withBytes:&dataLength];
}

- (TGMediaAttachment *)parseMediaAttachment:(NSInputStream *)is
{
    int32_t dataLength = 0;
    [is read:(uint8_t *)&dataLength maxLength:4];
    
    uint8_t version = 1;
    if (dataLength == 0x7abacaf1)
    {
        [is read:(uint8_t *)&version maxLength:1];
        [is read:(uint8_t *)&dataLength maxLength:4];
    }
    
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
    dataLength -= 1;
    
    if (hasImageInfo != 0)
    {
        TGImageInfo *imageInfo = [TGImageInfo deserialize:is];
        if (imageInfo != nil)
            imageAttachment.imageInfo = imageInfo;
    }
    
    int64_t accessHash = 0;
    [is read:(uint8_t *)&accessHash maxLength:8];
    imageAttachment.accessHash = accessHash;
    
    if (version >= 2)
    {
        int32_t captionLength = 0;
        [is read:(uint8_t *)&captionLength maxLength:4];
        if (captionLength != 0)
        {
            uint8_t *captionBytes = malloc(captionLength);
            [is read:captionBytes maxLength:captionLength];
            imageAttachment.caption = [[NSString alloc] initWithBytes:captionBytes length:captionLength encoding:NSUTF8StringEncoding];
            free(captionBytes);
        }
    }
    
    return imageAttachment;
}

- (NSArray *)textCheckingResults
{
    if (_caption.length < 2)
        _textCheckingResults = [NSArray array];
    
    if (_textCheckingResults == nil)
    {
        NSArray *textCheckingResults = [TGMessage textCheckingResultsForText:_caption highlightMentionsAndTags:true highlightCommands:true];
        _textCheckingResults = textCheckingResults ?: [NSArray array];
    }
    
    return _textCheckingResults;
}

@end
