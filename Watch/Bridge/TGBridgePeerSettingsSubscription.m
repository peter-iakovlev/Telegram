#import "TGBridgePeerSettingsSubscription.h"

#import "TGBridgePeerNotificationSettings.h"

NSString *const TGBridgePeerSettingsSubscriptionName = @"peer.settings";
NSString *const TGBridgePeerSettingsSubscriptionPeerIdKey = @"peerId";

@implementation TGBridgePeerSettingsSubscription

- (instancetype)initWithPeerId:(int64_t)peerId
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
    }
    return self;
}

- (bool)dropPreviouslyQueued
{
    return true;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgePeerSettingsSubscriptionPeerIdKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgePeerSettingsSubscriptionPeerIdKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgePeerSettingsSubscriptionName;
}

@end


NSString *const TGBridgePeerUpdateNotificationSettingsSubscriptionName = @"peer.notificationSettings";
NSString *const TGBridgePeerUpdateNotificationSettingsSubscriptionPeerIdKey = @"peerId";
NSString *const TGBridgePeerUpdateNotificationSettingsSubscriptionSettingsKey = @"settings";

@implementation TGBridgePeerUpdateNotificationSettingsSubscription

- (instancetype)initWithPeerId:(int64_t)peerId settings:(TGBridgePeerNotificationSettings *)settings
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _settings = settings;
    }
    return self;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgePeerUpdateNotificationSettingsSubscriptionPeerIdKey];
    [aCoder encodeObject:self.settings forKey:TGBridgePeerUpdateNotificationSettingsSubscriptionSettingsKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgePeerUpdateNotificationSettingsSubscriptionPeerIdKey];
    _settings = [aDecoder decodeObjectForKey:TGBridgePeerUpdateNotificationSettingsSubscriptionSettingsKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgePeerUpdateNotificationSettingsSubscriptionName;
}

@end


NSString *const TGBridgePeerUpdateBlockStatusSubscriptionName = @"peer.updateBlocked";
NSString *const TGBridgePeerUpdateBlockStatusSubscriptionPeerIdKey = @"peerId";
NSString *const TGBridgePeerUpdateBlockStatusSubscriptionBlockedKey = @"blocked";

@implementation TGBridgePeerUpdateBlockStatusSubscription

- (instancetype)initWithPeerId:(int64_t)peerId blocked:(bool)blocked
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _blocked = blocked;
    }
    return self;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgePeerUpdateBlockStatusSubscriptionPeerIdKey];
    [aCoder encodeBool:self.blocked forKey:TGBridgePeerUpdateBlockStatusSubscriptionBlockedKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgePeerUpdateBlockStatusSubscriptionPeerIdKey];
    _blocked = [aDecoder decodeBoolForKey:TGBridgePeerUpdateBlockStatusSubscriptionBlockedKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgePeerUpdateBlockStatusSubscriptionName;
}

@end
