#import "TGBridgeLocationVenue.h"

@class TGLocationVenue;

@interface TGBridgeLocationVenue (TGLocationVenue)

+ (TGBridgeLocationVenue *)locationVenueWithTGLocationVenue:(TGLocationVenue *)venue;

@end
