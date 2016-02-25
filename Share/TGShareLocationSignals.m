#import "TGShareLocationSignals.h"

#import "ApiLayer48.h"
#import "TGUploadedMessageContentMedia.h"

NSString *const TGShareAppleMapsHost = @"maps.apple.com";
NSString *const TGShareAppleMapsPath = @"/maps";
NSString *const TGShareAppleMapsLatLonKey = @"ll";
NSString *const TGShareAppleMapsNameKey = @"q";
NSString *const TGShareAppleMapsAddressKey = @"address";
NSString *const TGShareAppleMapsIdKey = @"auid";
NSString *const TGShareAppleMapsProvider = @"apple";

NSString *const TGShareFoursquareHost = @"foursquare.com";
NSString *const TGShareFoursquareVenuePath = @"/v";

NSString *const TGShareFoursquareVenueEndpointUrl = @"https://api.foursquare.com/v2/venues/";
NSString *const TGShareFoursquareClientId = @"BN3GWQF1OLMLKKQTFL0OADWD1X1WCDNISPPOT1EMMUYZTQV1";
NSString *const TGShareFoursquareClientSecret = @"WEEZHCKI040UVW2KWW5ZXFAZ0FMMHKQ4HQBWXVSX4WXWBWYN";
NSString *const TGShareFoursquareVersion = @"20150326";
NSString *const TGShareFoursquareVenuesCountLimit = @"25";
NSString *const TGShareFoursquareLocale = @"en";
NSString *const TGShareFoursquareProvider = @"foursquare";

NSString *const TGShareGoogleMapsHost = @"goog.le";
NSString *const TGShareGoogleMapsPath = @"/maps";
NSString *const TGShareGoogleProvider = @"google";

@implementation TGShareLocationSignals

+ (SSignal *)locationMessageContentForURL:(NSURL *)url
{
    if ([self isAppleMapsURL:url])
        return [self _appleMapsLocationContentForURL:url];
    
    return [SSignal single:nil];
}

+ (SSignal *)_appleMapsLocationContentForURL:(NSURL *)url
{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:false];
    NSArray *queryItems = urlComponents.queryItems;
    
    NSString *latLon = nil;
    NSString *name = nil;
    NSString *address = nil;
    NSString *venueId = nil;
    for (NSURLQueryItem *queryItem in queryItems)
    {
        if ([queryItem.name isEqualToString:TGShareAppleMapsLatLonKey])
        {
            latLon = queryItem.value;
        }
        else if ([queryItem.name isEqualToString:TGShareAppleMapsNameKey])
        {
            if (![queryItem.value isEqualToString:latLon])
                name = queryItem.value;
        }
        else if ([queryItem.name isEqualToString:TGShareAppleMapsAddressKey])
        {
            address = queryItem.value;
        }
        else if ([queryItem.name isEqualToString:TGShareAppleMapsIdKey])
        {
            venueId = queryItem.value;
        }
    }
    
    if (latLon == nil)
        return [SSignal fail:nil];
    
    NSArray *coordComponents = [latLon componentsSeparatedByString:@","];
    if (coordComponents.count != 2)
        return [SSignal fail:nil];
    
    double latitude = [coordComponents.firstObject floatValue];
    double longitude = [coordComponents.lastObject floatValue];
    
    Api48_InputGeoPoint *geoPoint = [Api48_InputGeoPoint inputGeoPointWithLat:@(latitude) plong:@(longitude)];
    Api48_InputMedia *inputMedia = nil;
    
    if (address == nil)
        address = @"";
    
    if (venueId == nil)
        venueId = @"";
    
    if (name.length > 0)
        inputMedia = [Api48_InputMedia inputMediaVenueWithGeoPoint:geoPoint title:name address:address provider:TGShareAppleMapsProvider venueId:venueId];
    else
        inputMedia = [Api48_InputMedia inputMediaGeoPointWithGeoPoint:geoPoint];
    
    return [SSignal single:[[TGUploadedMessageContentMedia alloc] initWithInputMedia:inputMedia]];
}

+ (bool)isLocationURL:(NSURL *)url
{
    return [self isAppleMapsURL:url] || [self isFoursquareURL:url] || [self isGoogleMapsURL:url];
}

+ (bool)isAppleMapsURL:(NSURL *)url
{
    return ([url.host isEqualToString:TGShareAppleMapsHost] && [url.path isEqualToString:TGShareAppleMapsPath]);
}

+ (bool)isFoursquareURL:(NSURL *)url
{
    return false;
    //return ([url.host isEqualToString:TGShareFoursquareHost] && [url.path hasPrefix:TGShareFoursquareVenuePath]);
}

+ (bool)isGoogleMapsURL:(NSURL *)url
{
    return false;
    //return ([url.host isEqualToString:TGShareGoogleMapsHost] && [url.path isEqualToString:TGShareGoogleMapsPath]);
}

@end
