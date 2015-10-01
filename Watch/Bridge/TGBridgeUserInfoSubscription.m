#import "TGBridgeUserInfoSubscription.h"

NSString *const TGBridgeUserInfoSubscriptionName = @"user.userInfo";
NSString *const TGBridgeUserInfoSubscriptionUserIdsKey = @"uids";

@implementation TGBridgeUserInfoSubscription

- (instancetype)initWithUserIds:(NSArray *)userIds
{
    self = [super init];
    if (self != nil)
    {
        _userIds = userIds;
    }
    return self;
}

- (bool)dropPreviouslyQueued
{
    return true;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userIds forKey:TGBridgeUserInfoSubscriptionUserIdsKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _userIds = [aDecoder decodeObjectForKey:TGBridgeUserInfoSubscriptionUserIdsKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeUserInfoSubscriptionName;
}

@end


NSString *const TGBridgeUserBotInfoSubscriptionName = @"user.botInfo";
NSString *const TGBridgeUserBotInfoSubscriptionUserIdsKey = @"uids";

@implementation TGBridgeUserBotInfoSubscription

- (instancetype)initWithUserIds:(NSArray *)userIds
{
    self = [super init];
    if (self != nil)
    {
        _userIds = userIds;
    }
    return self;
}

- (bool)dropPreviouslyQueued
{
    return true;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userIds forKey:TGBridgeUserBotInfoSubscriptionUserIdsKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _userIds = [aDecoder decodeObjectForKey:TGBridgeUserBotInfoSubscriptionUserIdsKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeUserBotInfoSubscriptionName;
}

@end


NSString *const TGBridgeBotReplyMarkupSubscriptionName = @"user.botReplyMarkup";
NSString *const TGBridgeBotReplyMarkupPeerIdKey = @"peerId";

@implementation TGBridgeBotReplyMarkupSubscription

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
    [aCoder encodeInt64:self.peerId forKey:TGBridgeBotReplyMarkupPeerIdKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgeBotReplyMarkupPeerIdKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeBotReplyMarkupSubscriptionName;
}

@end
