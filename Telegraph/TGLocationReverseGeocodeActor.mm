#import "TGLocationReverseGeocodeActor.h"

#import "TGTelegraph.h"
#import "TGTelegraphProtocols.h"

#import "TGSchema.h"

#import "SGraphObjectNode.h"

#include <vector>

static double geoComputeGeoNum(double latitude_degrees, double longitude_degrees)
{
    if (latitude_degrees > 90 || latitude_degrees < -90 || longitude_degrees < -180 || longitude_degrees > 360)
        return 0;
    
    double phi = latitude_degrees * M_PI / 180.0;
    double theta = longitude_degrees * M_PI / 180.0;
    double h = 1;
    if (phi < 0)
    {
        phi = -phi;
        h = 0;
    }
    
    double f = tan(M_PI / 4.0 - phi / 2.0);
    
    int x = (int)((f * cos(theta) + 1) * 0x1000000);
    int y = (int)((f * sin(theta) + 1) * 0x1000000);
    
    if (x == 0x2000000)
        x--;
    if (y == 0x2000000)
        y--;
    
    double q = 0;
    for (int i = 1; i < 0x2000000; i *= 2)
    {
        q += (x & 1) + (y & 1) * 2;
        x >>= 1;
        y >>= 1;
        q *= 1.0 / 4.0;
    }
    q = ((q + h) * 1.0 / 4.0) + 1.0 / 2.0;
    
    return q;
}

static NSString *geoMakeGeoHash(double geo_num)
{
    if (geo_num < 0.5 || geo_num >= 1.0)
    {
        return nil;
    }
    
    static const char geocodeChars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    
    std::vector<unichar> res;
    double q = geo_num;
    
    for (int i = 0; i < 8; i++)
    {
        q *= 64;
        int x = (int)q;
        q -= x;
        
        unichar c = geocodeChars[x];
        res.push_back(c);
    }
    
    NSString *result = [NSString stringWithCharacters:res.data() length:res.size()];
    return result;
}

static void geoHash2XY(NSString *geo_hash, double &rx, double &ry)
{
    int l = (int)geo_hash.length;
    double x = 0.5;
    double y = 0.5;
    
    static NSString *geocodeCharsString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    
    double s = 6371000 * 4;
    double t = 4;
    for (int i = l - 1; i >= 0; i--)
    {
        s *= 0.125;
        t *= 0.125;
        
        NSString *substring = [geo_hash substringWithRange:NSMakeRange(i, 1)];
        int c = (int)[geocodeCharsString rangeOfString:substring].location;
                 
        for (int j = 0; j < 3; j++)
        {
            x = x * 0.5 + (c & 1);
            c >>= 1;
            y = y * 0.5 + (c & 1);
            c >>= 1;
        }
    }

    x = x * 2 - 2;
    y = y * 2 - 3;
    if (y < -1)
    {
        return;
    }

    s /= 1 + (ABS(x) - 1) * (ABS(x) - 1) + y * y;

    rx = x;
    ry = y;
}

static void geoXY2LatLong(double x, double y, double &lat, double &lon)
{
    int h = (x >= 0 ? 1 : 0);
    x = x - 2.0 * h + 1.0;
    if (ABS(x) > 1 || ABS(y) > 1)
        return;
    
    double theta = atan2(y, x);
    double phi = M_PI / 2.0 - 2.0 * atan(sqrt(x * x + y * y));
    if (!h)
        phi = -phi;

    phi *= 180.0 / M_PI;
    theta *= 180.0 / M_PI;
    
    lat = phi;
    lon = theta;
}

static NSMutableDictionary *cachedGeocodes()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

@interface TGLocationReverseGeocodeActor () <TGRawHttpActor>

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end

@implementation TGLocationReverseGeocodeActor

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

+ (NSString *)genericPath
{
    return @"/tg/location/reversecode/@";
}

- (void)execute:(NSDictionary *)options
{
    _latitude = [[options objectForKey:@"latitude"] doubleValue];
    _longitude = [[options objectForKey:@"longitude"] doubleValue];
    
    NSString *key = [[NSString alloc] initWithFormat:@"%f,%f", _latitude, _longitude];
    NSDictionary *cachedResult = [cachedGeocodes() objectForKey:key];
    if (cachedResult != nil)
    {
        [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:cachedResult]];
    }
    else
    {
        NSString *url = [[NSString alloc] initWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false&language=en", _latitude, _longitude];
        
        self.cancelToken = [TGTelegraphInstance doRequestRawHttp:url maxRetryCount:0 acceptCodes:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:403], nil] actor:self];
    }
}

- (void)httpRequestSuccess:(NSString *)__unused url response:(NSData *)response
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
    
    if (![dict isKindOfClass:[NSDictionary class]])
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
        return;
    }
    
    //TGLog(@"%@", dict);
    
    NSArray *results = [TGSchema arrayFromObject:[dict objectForKey:@"results"]];
    if (results == nil)
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
        return;
    }
    
    NSArray *addressComponentsSublocality = nil;
    NSArray *addressComponentsStreetAddress = nil;
    
    for (NSDictionary *result in results)
    {
        if ([result isKindOfClass:[NSDictionary class]])
        {
            NSArray *compoments = [TGSchema arrayFromObject:[result objectForKey:@"address_components"]];
            if (compoments != nil)
            {
                if ([[result objectForKey:@"types"] containsObject:@"sublocality"])
                {
                    addressComponentsSublocality = compoments;
                }
                else if ([[result objectForKey:@"types"] containsObject:@"street_address"])
                {
                    addressComponentsStreetAddress = compoments;
                }
            }
        }
    }
    
    NSArray *addressComponents = addressComponentsSublocality;
    if (addressComponents == nil)
        addressComponents = addressComponentsStreetAddress;
    
    if (addressComponents == nil)
    {
        [ActionStageInstance() nodeRetrieveFailed:self.path];
        return;
    }
    
    NSString *countryName = nil;
    NSString *stateName = nil;
    NSString *cityName = nil;
    NSString *neighborhood = nil;
    NSString *sublocality = nil;
    NSString *streetName = nil;
    
    for (NSDictionary *component in addressComponents)
    {
        if ([component isKindOfClass:[NSDictionary class]])
        {
            NSString *componentName = [TGSchema stringFromObject:[component objectForKey:@"long_name"]];
            NSString *componentShortName = [TGSchema stringFromObject:[component objectForKey:@"short_name"]];
            if (componentName == nil || componentName.length == 0)
                componentName = componentShortName;
            if (componentShortName == nil)
                componentShortName = componentName;
            
            NSArray *types = [component objectForKey:@"types"];
            if ([types isKindOfClass:[NSArray class]])
            {
                for (NSString *type in types)
                {
                    if ([@"country" isEqualToString:type])
                    {
                        countryName = componentName;
                        break;
                    }
                    else if ([@"locality" isEqualToString:type])
                    {
                        cityName = componentName;
                        break;
                    }
                    else if ([@"route" isEqualToString:type])
                    {
                        streetName = componentName;
                        break;
                    }
                    else if ([@"neighborhood" isEqualToString:type])
                    {
                        neighborhood = componentName;
                        break;
                    }
                    else if ([@"sublocality" isEqualToString:type])
                    {
                        sublocality = componentName;
                        break;
                    }
                    else if ([@"administrative_area_level_1" isEqualToString:type])
                    {
                        stateName = componentShortName;
                        break;
                    }
                }
            }
        }
    }
    
    NSString *districtName = sublocality;
    if (districtName == nil)
        districtName = neighborhood;
    
    TGLog(@"Geo: %@, %@, %@, %@, %@", countryName, stateName, cityName, districtName, streetName);
    
    NSMutableDictionary *components = [[NSMutableDictionary alloc] init];
    if (countryName != nil)
        [components setObject:countryName forKey:@"country"];
    if (stateName != nil)
        [components setObject:stateName forKey:@"state"];
    if (cityName != nil)
        [components setObject:cityName forKey:@"city"];
    if (districtName != nil)
        [components setObject:districtName forKey:@"district"];
    if (streetName != nil)
        [components setObject:streetName forKey:@"street"];
    
    NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:components, @"components", [NSNumber numberWithDouble:_latitude], @"latitude", [NSNumber numberWithDouble:_longitude], @"longitude", nil];
    
    NSString *key = [[NSString alloc] initWithFormat:@"%f,%f", _latitude, _longitude];
    [cachedGeocodes() setObject:result forKey:key];
    
    static int index = 1;
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/location/savegeocode/(%d)", index++] options:result watcher:TGTelegraphInstance];
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:result]];
}

- (void)httpRequestFailed:(NSString *)__unused url
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

@end
