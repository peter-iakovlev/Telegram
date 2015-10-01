#import "TGBridgeResponse.h"
#import "TGBridgeSubscription.h"

NSString *const TGBridgeResponseSubscriptionIdentifier = @"identifier";
NSString *const TGBridgeResponseTypeKey = @"type";
NSString *const TGBridgeResponseNextKey = @"next";
NSString *const TGBridgeResponseErrorKey = @"error";

@implementation TGBridgeResponse

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _subscriptionIdentifier = [aDecoder decodeInt64ForKey:TGBridgeResponseSubscriptionIdentifier];
        _type = [aDecoder decodeInt32ForKey:TGBridgeResponseTypeKey];
        _next = [aDecoder decodeObjectForKey:TGBridgeResponseNextKey];
        _error = [aDecoder decodeObjectForKey:TGBridgeResponseErrorKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.subscriptionIdentifier forKey:TGBridgeResponseSubscriptionIdentifier];
    [aCoder encodeInt32:self.type forKey:TGBridgeResponseTypeKey];
    [aCoder encodeObject:self.next forKey:TGBridgeResponseNextKey];
    [aCoder encodeObject:self.error forKey:TGBridgeResponseErrorKey];
}

+ (TGBridgeResponse *)single:(id)next forSubscription:(TGBridgeSubscription *)subscription
{
    TGBridgeResponse *response = [[TGBridgeResponse alloc] init];
    response->_subscriptionIdentifier = subscription.identifier;
    response->_type = TGBridgeResponseTypeNext;
    response->_next = next;
    return response;
}

+ (TGBridgeResponse *)fail:(id)error forSubscription:(TGBridgeSubscription *)subscription
{
    TGBridgeResponse *response = [[TGBridgeResponse alloc] init];
    response->_subscriptionIdentifier = subscription.identifier;
    response->_type = TGBridgeResponseTypeFailed;
    response->_error = error;
    return response;
}

+ (TGBridgeResponse *)completeForSubscription:(TGBridgeSubscription *)subscription
{
    TGBridgeResponse *response = [[TGBridgeResponse alloc] init];
    response->_subscriptionIdentifier = subscription.identifier;
    response->_type = TGBridgeResponseTypeCompleted;
    return response;
}

@end
