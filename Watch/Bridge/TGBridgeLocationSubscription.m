#import "TGBridgeLocationSubscription.h"
#import <MapKit/MapKit.h>

NSString *const TGBridgeNearbyVenuesSubscriptionName = @"location.nearbyVenues";
NSString *const TGBridgeNearbyVenuesSubscriptionLatitudeKey = @"lat";
NSString *const TGBridgeNearbyVenuesSubscriptionLongitudeKey = @"lon";
NSString *const TGBridgeNearbyVenuesSubscriptionLimitKey = @"limit";

@implementation TGBridgeNearbyVenuesSubscription

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate limit:(int32_t)limit
{
    self = [super init];
    if (self != nil)
    {
        _coordinate = coordinate;
        _limit = limit;
    }
    return self;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.coordinate.latitude forKey:TGBridgeNearbyVenuesSubscriptionLatitudeKey];
    [aCoder encodeDouble:self.coordinate.longitude forKey:TGBridgeNearbyVenuesSubscriptionLongitudeKey];
    [aCoder encodeInt32:self.limit forKey:TGBridgeNearbyVenuesSubscriptionLimitKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _coordinate = CLLocationCoordinate2DMake([aDecoder decodeDoubleForKey:TGBridgeNearbyVenuesSubscriptionLatitudeKey],
                                             [aDecoder decodeDoubleForKey:TGBridgeNearbyVenuesSubscriptionLongitudeKey]);
    _limit = [aDecoder decodeInt32ForKey:TGBridgeNearbyVenuesSubscriptionLimitKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeNearbyVenuesSubscriptionName;
}

@end
