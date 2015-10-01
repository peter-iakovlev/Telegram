#import "TGBridgeForwardedMessageMediaAttachment.h"

const NSInteger TGBridgeForwardedMessageMediaAttachmentType = 0xAA1050C1;

NSString *const TGBridgeForwardedMessageMediaUidKey = @"uid";
NSString *const TGBridgeForwardedMessageMediaMidKey = @"mid";
NSString *const TGBridgeForwardedMessageMediaDateKey = @"date";

@implementation TGBridgeForwardedMessageMediaAttachment

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _uid = [aDecoder decodeInt32ForKey:TGBridgeForwardedMessageMediaUidKey];
        _mid = [aDecoder decodeInt32ForKey:TGBridgeForwardedMessageMediaMidKey];
        _date = [aDecoder decodeInt32ForKey:TGBridgeForwardedMessageMediaDateKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:self.uid forKey:TGBridgeForwardedMessageMediaUidKey];
    [aCoder encodeInt32:self.mid forKey:TGBridgeForwardedMessageMediaMidKey];
    [aCoder encodeInt32:self.date forKey:TGBridgeForwardedMessageMediaDateKey];
}

+ (NSInteger)mediaType
{
    return TGBridgeForwardedMessageMediaAttachmentType;
}

@end
