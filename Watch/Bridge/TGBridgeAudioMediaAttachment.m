#import "TGBridgeAudioMediaAttachment.h"

const NSInteger TGBridgeAudioMediaAttachmentType = 0x3A0E7A32;

NSString *const TGBridgeAudioMediaDurationKey = @"duration";
NSString *const TGBridgeAudioMediaFileSizeKey = @"fileSize";

@implementation TGBridgeAudioMediaAttachment

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _duration = [aDecoder decodeInt32ForKey:TGBridgeAudioMediaDurationKey];
        _fileSize = [aDecoder decodeInt32ForKey:TGBridgeAudioMediaFileSizeKey];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder
{
    [aCoder encodeInt32:self.duration forKey:TGBridgeAudioMediaDurationKey];
    [aCoder encodeInt32:self.fileSize forKey:TGBridgeAudioMediaFileSizeKey];
}

+ (NSInteger)mediaType
{
    return TGBridgeAudioMediaAttachmentType;
}

@end
