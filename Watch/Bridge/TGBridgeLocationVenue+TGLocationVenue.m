#import "TGBridgeLocationVenue+TGLocationVenue.h"
#import "TGLocationVenue.h"

@implementation TGBridgeLocationVenue (TGLocationVenue)

+ (TGBridgeLocationVenue *)locationVenueWithTGLocationVenue:(TGLocationVenue *)venue
{
    TGBridgeLocationVenue *bridgeVenue = [[TGBridgeLocationVenue alloc] init];
    bridgeVenue->_coordinate = venue.coordinate;
    bridgeVenue->_identifier = venue.identifier;
    bridgeVenue->_provider = venue.provider;
    bridgeVenue->_name = venue.name;
    bridgeVenue->_address = venue.address;
    
    return bridgeVenue;
}

@end
