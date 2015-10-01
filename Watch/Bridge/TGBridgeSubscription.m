#import "TGBridgeSubscription.h"

NSString *const TGBridgeSubscriptionIdentifierKey = @"identifier";
NSString *const TGBridgeSubscriptionNameKey = @"name";
NSString *const TGBridgeSubscriptionParametersKey = @"parameters";

@implementation TGBridgeSubscription

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        int64_t randomId = 0;
        arc4random_buf(&randomId, sizeof(int64_t));
        _identifier = randomId;
        _name = [[self class] subscriptionName];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _identifier = [aDecoder decodeInt64ForKey:TGBridgeSubscriptionIdentifierKey];
        _name = [aDecoder decodeObjectForKey:TGBridgeSubscriptionNameKey];
        [self _unserializeParametersWithCoder:aDecoder];
    }
    return self;
}

- (bool)synchronous
{
    return false;
}

- (bool)renewable
{
    return true;
}

- (bool)dropPreviouslyQueued
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)__unused aCoder
{

}

- (void)_unserializeParametersWithCoder:(NSCoder *)__unused aDecoder
{
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.identifier forKey:TGBridgeSubscriptionIdentifierKey];
    [aCoder encodeObject:self.name forKey:TGBridgeSubscriptionNameKey];
    [self _serializeParametersWithCoder:aCoder];
}

+ (NSString *)subscriptionName
{
    return nil;
}

@end


@implementation TGBridgeDisposal

- (instancetype)initWithIdentifier:(int64_t)identifier
{
    self = [super init];
    if (self != nil)
    {
        _identifier = identifier;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _identifier = [aDecoder decodeInt64ForKey:TGBridgeSubscriptionIdentifierKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.identifier forKey:TGBridgeSubscriptionIdentifierKey];
}

@end


NSString *const TGBridgeSessionIdKey = @"sessionId";

@implementation TGBridgePing

- (instancetype)initWithSessionId:(int32_t)sessionId
{
    self = [super init];
    if (self != nil)
    {
        _sessionId = sessionId;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _sessionId = [aDecoder decodeInt32ForKey:TGBridgeSessionIdKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:self.sessionId forKey:TGBridgeSessionIdKey];
}

@end


@implementation TGBridgeSubscriptionListRequest

- (instancetype)initWithSessionId:(int32_t)sessionId
{
    self = [super init];
    if (self != nil)
    {
        _sessionId = sessionId;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _sessionId = [aDecoder decodeInt32ForKey:TGBridgeSessionIdKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:self.sessionId forKey:TGBridgeSessionIdKey];
}

@end


NSString *const TGBridgeSubscriptionListSubscriptionsKey = @"subscriptions";

@implementation TGBridgeSubscriptionList

- (instancetype)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self != nil)
    {
        _subscriptions = array;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _subscriptions = [aDecoder decodeObjectForKey:TGBridgeSubscriptionListSubscriptionsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.subscriptions forKey:TGBridgeSubscriptionListSubscriptionsKey];
}

@end
