#import "TGBridgeRemoteSubscription.h"

NSString *const TGBridgeRemoteSubscriptionName = @"remote.request";
NSString *const TGBridgeRemotePeerIdKey = @"peerId";
NSString *const TGBridgeRemoteMessageIdKey = @"mid";
NSString *const TGBridgeRemoteTypeKey = @"mediaType";
NSString *const TGBridgeRemoteAutoPlayKey = @"autoPlay";

@implementation TGBridgeRemoteSubscription

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId type:(int32_t)type autoPlay:(bool)autoPlay
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _messageId = messageId;
        _type = type;
        _autoPlay = autoPlay;
    }
    return self;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgeRemotePeerIdKey];
    [aCoder encodeInt32:self.messageId forKey:TGBridgeRemoteMessageIdKey];
    [aCoder encodeInt32:self.type forKey:TGBridgeRemoteTypeKey];
    [aCoder encodeBool:self.autoPlay forKey:TGBridgeRemoteAutoPlayKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgeRemotePeerIdKey];
    _messageId = [aDecoder decodeInt32ForKey:TGBridgeRemoteMessageIdKey];
    _type = [aDecoder decodeInt32ForKey:TGBridgeRemoteTypeKey];
    _autoPlay = [aDecoder decodeBoolForKey:TGBridgeRemoteAutoPlayKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeRemoteSubscriptionName;
}

@end
