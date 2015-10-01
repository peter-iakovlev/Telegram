#import "TGBridgePacket.h"
#import "TGBridgeResponse.h"

NSString *const TGBridgePacketResponsesKey = @"responses";

@implementation TGBridgePacket

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _responses = [aDecoder decodeObjectForKey:TGBridgePacketResponsesKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.responses forKey:TGBridgePacketResponsesKey];
}

@end
