#import "TGBridgeContactsSubscription.h"

NSString *const TGBridgeContactsSubscriptionName = @"contacts.search";
NSString *const TGBridgeContactsSubscriptionQueryKey = @"query";

@implementation TGBridgeContactsSubscription

- (instancetype)initWithQuery:(NSString *)query
{
    self = [super init];
    if (self != nil)
    {
        _query = query;
    }
    return self;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.query forKey:TGBridgeContactsSubscriptionQueryKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _query = [aDecoder decodeObjectForKey:TGBridgeContactsSubscriptionQueryKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeContactsSubscriptionName;
}

@end
