#import "TGLocationReverseGeocodeActor.h"

#import "TGTelegraph.h"
#import "TGTelegraphProtocols.h"

#import "TGSchema.h"

#import "SGraphObjectNode.h"

#include <vector>

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
