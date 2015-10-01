#import "TGBridgeLocationHandler.h"
#import "TGBridgeLocationSubscription.h"

#import "TGLocationSignals.h"

#import "TGBridgeLocationVenue+TGLocationVenue.h"

@implementation TGBridgeLocationHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)__unused server
{
    if ([subscription isKindOfClass:[TGBridgeNearbyVenuesSubscription class]])
    {
        TGBridgeNearbyVenuesSubscription *nearbyVenuesSubscription = (TGBridgeNearbyVenuesSubscription *)subscription;

        return [[TGLocationSignals searchNearbyPlacesWithQuery:nil coordinate:nearbyVenuesSubscription.coordinate service:TGLocationPlacesServiceFoursquare] map:^NSArray *(NSArray *venues)
        {
            NSMutableArray *bridgeVenues = [[NSMutableArray alloc] init];
            
            for (TGLocationVenue *venue in venues)
            {
                TGBridgeLocationVenue *bridgeVenue = [TGBridgeLocationVenue locationVenueWithTGLocationVenue:venue];
                if (bridgeVenue != nil)
                    [bridgeVenues addObject:bridgeVenue];
                
                if ((int32_t)bridgeVenues.count == nearbyVenuesSubscription.limit)
                    break;
            }
            
            return bridgeVenues;
        }];
    }
    
    return [SSignal fail:nil];
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeNearbyVenuesSubscription class] ];
}

@end
