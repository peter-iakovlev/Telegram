#import "TGShareLocationSignals.h"

#import "ApiLayer70.h"
#import "TGUploadedMessageContentText.h"
#import "TGUploadedMessageContentMedia.h"

#import "TGRemoteHttpLocationSignal.h"

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

NSString *const TGShareGoogleShortenerEndpointUrl = @"https://www.googleapis.com/urlshortener/v1/url";
NSString *const TGShareGoogleAPIKey = @"AIzaSyBCTH4aAdvi0MgDGlGNmQAaFS8GTNBrfj4";
NSString *const TGShareGoogleMapsShortHost = @"goo.gl";
NSString *const TGShareGoogleMapsShortPath = @"/maps";
NSString *const TGShareGoogleMapsHost = @"google.com";
NSString *const TGShareGoogleMapsSearchPath = @"maps/search";
NSString *const TGShareGoogleMapsPlacePath = @"maps/place";
NSString *const TGShareGoogleProvider = @"google";

@interface TGQueryStringComponent : NSObject {
@private
    NSString *_key;
    NSString *_value;
}

@property (readwrite, nonatomic, retain) id key;
@property (readwrite, nonatomic, retain) id value;

- (id)initWithKey:(id)key value:(id)value;
- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;

@end

NSString * TGURLEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFLegalCharactersToBeEscaped = @"?!@#$^&%*+=,:;'\"`<>()[]{}/\\|~ ";
    
    /*
     The documentation for `CFURLCreateStringByAddingPercentEscapes` suggests that one should "pre-process" URL strings with unpredictable sequences that may already contain percent escapes. However, if the string contains an unescaped sequence with '%' appearing without an escape code (such as when representing percentages like "42%"), `stringByReplacingPercentEscapesUsingEncoding` will return `nil`. Thus, the string is only unescaped if there are no invalid percent-escaped sequences.
     */
    NSString *unescapedString = [string stringByReplacingPercentEscapesUsingEncoding:encoding];
    if (unescapedString) {
        string = unescapedString;
    }
    
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kAFLegalCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding));
}

@implementation TGQueryStringComponent
@synthesize key = _key;
@synthesize value = _value;

- (id)initWithKey:(id)key value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.key = key;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    return [NSString stringWithFormat:@"%@=%@", self.key, TGURLEncodedStringFromStringWithEncoding([self.value description], stringEncoding)];
}

@end

static NSString * TGQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding);
static NSArray * TGQueryStringComponentsFromKeyAndValue(NSString *key, id value);
NSArray * TGQueryStringComponentsFromKeyAndDictionaryValue(NSString *key, NSDictionary *value);
NSArray * TGQueryStringComponentsFromKeyAndArrayValue(NSString *key, NSArray *value);

static NSString * TGQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutableComponents = [NSMutableArray array];
    for (TGQueryStringComponent *component in TGQueryStringComponentsFromKeyAndValue(nil, parameters)) {
        [mutableComponents addObject:[component URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [mutableComponents componentsJoinedByString:@"&"];
}

static NSArray * TGQueryStringComponentsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    if([value isKindOfClass:[NSDictionary class]]) {
        [mutableQueryStringComponents addObjectsFromArray:TGQueryStringComponentsFromKeyAndDictionaryValue(key, value)];
    } else if([value isKindOfClass:[NSArray class]]) {
        [mutableQueryStringComponents addObjectsFromArray:TGQueryStringComponentsFromKeyAndArrayValue(key, value)];
    } else {
        [mutableQueryStringComponents addObject:[[TGQueryStringComponent alloc] initWithKey:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

NSArray * TGQueryStringComponentsFromKeyAndDictionaryValue(NSString *key, NSDictionary *value){
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    [value enumerateKeysAndObjectsUsingBlock:^(id nestedKey, id nestedValue, __unused BOOL *stop) {
        [mutableQueryStringComponents addObjectsFromArray:TGQueryStringComponentsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
    }];
    
    return mutableQueryStringComponents;
}

NSArray * TGQueryStringComponentsFromKeyAndArrayValue(NSString *key, NSArray *value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    [value enumerateObjectsUsingBlock:^(id nestedValue, __unused NSUInteger idx, __unused BOOL *stop) {
        [mutableQueryStringComponents addObjectsFromArray:TGQueryStringComponentsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
    }];
    
    return mutableQueryStringComponents;
}

@implementation TGShareLocationSignals

+ (SSignal *)locationMessageContentForURL:(NSURL *)url
{
    if ([self isAppleMapsURL:url])
        return [self _appleMapsLocationContentForURL:url];
    else if ([self isFoursquareURL:url])
        return [self _foursquareLocationForURL:url];

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
    
    Api70_InputGeoPoint *geoPoint = [Api70_InputGeoPoint inputGeoPointWithLat:@(latitude) plong:@(longitude)];
    Api70_InputMedia *inputMedia = nil;
    
    if (address == nil)
        address = @"";
    
    if (venueId == nil)
        venueId = @"";
    
    if (name.length > 0)
        inputMedia = [Api70_InputMedia inputMediaVenueWithGeoPoint:geoPoint title:name address:address provider:TGShareAppleMapsProvider venueId:venueId];
    else
        inputMedia = [Api70_InputMedia inputMediaGeoPointWithGeoPoint:geoPoint];
    
    return [SSignal single:[[TGUploadedMessageContentMedia alloc] initWithInputMedia:inputMedia]];
}

+ (SSignal *)_foursquareLocationForURL:(NSURL *)url
{
    NSArray *pathComponents = url.pathComponents;
    NSString *venueId = nil;
    for (NSString *component in pathComponents)
    {
        if (component.length == 24)
        {
            venueId = component;
            break;
        }
    }
    
    if (venueId == nil)
        return [SSignal fail:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", [TGShareFoursquareVenueEndpointUrl stringByAppendingPathComponent:venueId], TGQueryStringFromParametersWithEncoding([self _defaultParametersForFoursquare], NSUTF8StringEncoding)];
    
    return [[TGRemoteHttpLocationSignal jsonForHttpLocation:urlString] mapToSignal:^id(id json)
    {
        if (![json respondsToSelector:@selector(objectForKey:)])
            return nil;
        
        NSDictionary *venue = json[@"response"][@"venue"];
        if (![venue respondsToSelector:@selector(objectForKey:)])
            return nil;
        
        NSString *name = venue[@"name"];
        
        NSDictionary *location = venue[@"location"];
        
        NSString *address = location[@"address"];
        if (address.length == 0)
            address = location[@"crossStreet"];
        if (address.length == 0)
            address = location[@"city"];
        if (address.length == 0)
            address = location[@"country"];
        if (address.length == 0)
            address = @"";
        
        double latitude = [location[@"lat"] doubleValue];
        double longitude = [location[@"lng"] doubleValue];
        
        if (name.length == 0)
            return [SSignal fail:nil];

        Api70_InputGeoPoint *geoPoint = [Api70_InputGeoPoint inputGeoPointWithLat:@(latitude) plong:@(longitude)];
        Api70_InputMedia_inputMediaVenue *inputVenue = [Api70_InputMedia inputMediaVenueWithGeoPoint:geoPoint title:name address:address provider:TGShareFoursquareProvider venueId:venueId];
        
        return [SSignal single:[[TGUploadedMessageContentMedia alloc] initWithInputMedia:inputVenue]];
    }];
}

+ (SSignal *)_googleMapsLocationForURL:(NSURL *)url
{
    NSString *shortenerUrl = [NSString stringWithFormat:@"%@?fields=longUrl,status&shortUrl=%@&key=%@", TGShareGoogleShortenerEndpointUrl, TGURLEncodedStringFromStringWithEncoding(url.absoluteString, NSUTF8StringEncoding), TGShareGoogleAPIKey];
    
    SSignal *shortenerSignal = [[TGRemoteHttpLocationSignal jsonForHttpLocation:shortenerUrl] mapToSignal:^SSignal *(id json)
    {
        if (![json respondsToSelector:@selector(objectForKey:)])
            return [SSignal fail:nil];
        
        NSString *status = json[@"status"];
        if (![status isEqualToString:@"OK"])
            return [SSignal fail:nil];
        
        return [SSignal single:[NSURL URLWithString:json[@"longUrl"]]];
    }];
    
    SSignal *(^processLongUrl)(NSURL *) = ^SSignal *(NSURL *longUrl)
    {
        NSArray *pathComponents = longUrl.pathComponents;
        
        bool isSearch = false;
        double latitude = 0.0;
        double longitude = 0.0;
        
        for (NSString *component in pathComponents)
        {
            if ([component isEqualToString:@"search"])
            {
                isSearch = true;
            }
            else if ([component isEqualToString:@"place"])
            {
                return [SSignal fail:nil];
            }
            else if (isSearch && [component containsString:@","])
            {
                NSArray *coordinates = [component componentsSeparatedByString:@","];
                if (coordinates.count == 2)
                {
                    latitude = [coordinates.firstObject doubleValue];
                    longitude = [coordinates.lastObject doubleValue];
                    break;
                }
            }
        }
        
        if (fabs(latitude) < DBL_EPSILON && fabs(longitude) < DBL_EPSILON)
            return [SSignal fail:nil];
        
        Api70_InputGeoPoint *geoPoint = [Api70_InputGeoPoint inputGeoPointWithLat:@(latitude) plong:@(longitude)];
        return [SSignal single:[[TGUploadedMessageContentMedia alloc] initWithInputMedia:[Api70_InputMedia inputMediaGeoPointWithGeoPoint:geoPoint]]];
    };
    
    SSignal *signal = nil;
    if ([self _isShortGoogleMapsURL:url])
    {
        signal = [shortenerSignal mapToSignal:^SSignal *(NSURL *longUrl)
        {
            return processLongUrl(longUrl);
        }];
    }
    else
    {
        signal = processLongUrl(url);
    }
    
    return [signal catch:^SSignal *(id error)
    {
        return [SSignal single:[[TGUploadedMessageContentText alloc] initWithText:url.absoluteString]];
    }];
}

+ (NSDictionary *)_defaultParametersForFoursquare
{
    return @
    {
        @"v": TGShareFoursquareVersion,
        @"locale": TGShareFoursquareLocale,
        @"client_id": TGShareFoursquareClientId,
        @"client_secret" :TGShareFoursquareClientSecret
    };
}

+ (bool)isLocationURL:(NSURL *)url
{
    return [self isAppleMapsURL:url] || [self isFoursquareURL:url];
}

+ (bool)isAppleMapsURL:(NSURL *)url
{
    return ([url.host isEqualToString:TGShareAppleMapsHost] && [url.path isEqualToString:TGShareAppleMapsPath]);
}

+ (bool)isFoursquareURL:(NSURL *)url
{
    return ([url.host isEqualToString:TGShareFoursquareHost] && [url.path hasPrefix:TGShareFoursquareVenuePath]);
}

+ (bool)_isShortGoogleMapsURL:(NSURL *)url
{
    return ([url.host isEqualToString:TGShareGoogleMapsShortHost] && [url.path hasPrefix:TGShareGoogleMapsShortPath]);
}

+ (bool)_isLongGoogleMapsURL:(NSURL *)url
{
    return ([url.host isEqualToString:TGShareGoogleMapsHost] && ([url.path hasPrefix:TGShareGoogleMapsSearchPath] || [url.path hasPrefix:TGShareGoogleMapsPlacePath]));
}

+ (bool)isGoogleMapsURL:(NSURL *)url
{
    return [self _isShortGoogleMapsURL:url] || [self _isLongGoogleMapsURL:url];
}

@end
