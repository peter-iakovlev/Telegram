#import "TGBridgeVideoMediaAttachment.h"

const NSInteger TGBridgeVideoMediaAttachmentType = 0x338EAA20;

NSString *const TGBridgeVideoMediaVideoIdKey = @"videoId";
NSString *const TGBridgeVideoMediaImageInfoKey = @"imageInfo";
NSString *const TGBridgeVideoMediaCaptionKey = @"caption";
NSString *const TGBridgeVideoMediaDimensionsKey = @"dimensions";
NSString *const TGBridgeVideoMediaDurationKey = @"duration";

@implementation TGBridgeVideoMediaAttachment

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _videoId = [aDecoder decodeInt64ForKey:TGBridgeVideoMediaVideoIdKey];
        _thumbnailImageInfo = [aDecoder decodeObjectForKey:TGBridgeVideoMediaImageInfoKey];
        _caption = [aDecoder decodeObjectForKey:TGBridgeVideoMediaCaptionKey];
        _dimensions = [aDecoder decodeCGSizeForKey:TGBridgeVideoMediaDimensionsKey];
        _duration = [aDecoder decodeInt32ForKey:TGBridgeVideoMediaDurationKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.videoId forKey:TGBridgeVideoMediaVideoIdKey];
    [aCoder encodeObject:self.thumbnailImageInfo forKey:TGBridgeVideoMediaImageInfoKey];
    [aCoder encodeObject:self.caption forKey:TGBridgeVideoMediaCaptionKey];
    [aCoder encodeCGSize:self.dimensions forKey:TGBridgeVideoMediaDimensionsKey];
    [aCoder encodeInt32:self.duration forKey:TGBridgeVideoMediaDurationKey];
}

+ (NSInteger)mediaType
{
    return TGBridgeVideoMediaAttachmentType;
}

@end
