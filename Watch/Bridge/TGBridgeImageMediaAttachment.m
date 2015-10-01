#import "TGBridgeImageMediaAttachment.h"

const NSInteger TGBridgeImageMediaAttachmentType = 0x269BD8A8;

NSString *const TGBridgeImageMediaImageIdKey = @"imageId";
NSString *const TGBridgeImageMediaLocalImageIdKey = @"localImageId";
NSString *const TGBridgeImageMediaImageInfoKey = @"imageInfo";
NSString *const TGBridgeImageMediaCaptionKey = @"caption";

@implementation TGBridgeImageMediaAttachment

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _imageId = [aDecoder decodeInt64ForKey:TGBridgeImageMediaImageIdKey];
        _localImageId = [aDecoder decodeInt64ForKey:TGBridgeImageMediaLocalImageIdKey];
        _imageInfo = [aDecoder decodeObjectForKey:TGBridgeImageMediaImageInfoKey];
        _caption = [aDecoder decodeObjectForKey:TGBridgeImageMediaCaptionKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.imageId forKey:TGBridgeImageMediaImageIdKey];
    [aCoder encodeInt64:self.localImageId forKey:TGBridgeImageMediaLocalImageIdKey];
    [aCoder encodeObject:self.imageInfo forKey:TGBridgeImageMediaImageInfoKey];
    [aCoder encodeObject:self.caption forKey:TGBridgeImageMediaCaptionKey];
}

+ (NSInteger)mediaType
{
    return TGBridgeImageMediaAttachmentType;
}

@end
