#import "TGOpenInLocationItems.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "TGApplication.h"
#import "TGStringUtils.h"

#import "TGLocationMediaAttachment.h"

NSString *const TGOpenInLocationDirectionsKey = @"directions";

@interface TGOpenInMapsItem : TGOpenInLocationItem

@end

@interface TGOpenInGoogleMapsItem : TGOpenInLocationItem

@end

@interface TGOpenInYandexMapsItem : TGOpenInLocationItem

@end

@interface TGOpenInYandexNavigatorItem : TGOpenInLocationItem

@end

@interface TGOpenInHereItem : TGOpenInLocationItem

@end

@interface TGOpenInWazeItem : TGOpenInLocationItem

@end

@interface TGOpenInFoursquareItem : TGOpenInLocationItem

@end

@interface TGOpenInUberItem : TGOpenInLocationItem

@end

@interface TGOpenInLyftItem : TGOpenInLocationItem

@end

@interface TGOpenInCitymapperItem : TGOpenInLocationItem

@end


@interface TGOpenInLocationItem ()

+ (bool)canOpen:(id)object directions:(bool)__unused directions;
+ (CLLocationCoordinate2D)coordinateForLocation:(TGLocationMediaAttachment *)location;

@end

@implementation TGOpenInLocationItem

+ (NSArray *)appItemsClasses
{
    static dispatch_once_t onceToken;
    static NSArray *appItems;
    dispatch_once(&onceToken, ^
                  {
                      appItems = @
                      [
                       [TGOpenInFoursquareItem class],
                       [TGOpenInMapsItem class],
                       [TGOpenInGoogleMapsItem class],
                       [TGOpenInYandexMapsItem class],
                       [TGOpenInUberItem class],
                       [TGOpenInLyftItem class],
                       [TGOpenInCitymapperItem class],
                       [TGOpenInYandexNavigatorItem class],
                       [TGOpenInHereItem class],
                       [TGOpenInWazeItem class]
                       ];
                  });
    return appItems;
}

+ (NSArray *)appItemsForLocationAttachment:(TGLocationMediaAttachment *)location directions:(bool)directions
{
    NSArray *appItemsClasses = [self appItemsClasses];
    NSMutableArray *appItems = [[NSMutableArray alloc] init];
    
    NSDictionary *userInfo = @{ TGOpenInLocationDirectionsKey: @(directions) };
    for (id class in appItemsClasses)
    {
        if ([class canOpen:location directions:directions] && [class isAvailable])
        {
            TGOpenInLocationItem *item = [[class alloc] initWithObject:location userInfo:userInfo];
            [appItems addObject:item];
        }
        
    }
    return appItems;
}

+ (bool)canOpen:(id)object directions:(bool)__unused directions
{
    return ([object isKindOfClass:[TGLocationMediaAttachment class]]);
}

+ (CLLocationCoordinate2D)coordinateForLocation:(TGLocationMediaAttachment *)location
{
    return CLLocationCoordinate2DMake(location.latitude, location.longitude);
}

+ (void)openURL:(NSURL *)url
{
    [(TGApplication *)[TGApplication sharedApplication] nativeOpenURL:url];
}

@end


@implementation TGOpenInMapsItem

- (NSString *)title
{
    return @"Maps";
}

- (UIImage *)appIcon
{
    return [UIImage imageNamed:@"OpenInMapsIcon"];
}

- (void)performOpenIn
{
    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)self.object;
    bool directions = [self.userInfo[TGOpenInLocationDirectionsKey] boolValue];
    
    CLLocationCoordinate2D coordinate = [TGOpenInLocationItem coordinateForLocation:location];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    //[mapItem setName:locationName];
    
    if (directions)
    {
        NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving };
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        [MKMapItem openMapsWithItems:@[ currentLocationMapItem, mapItem ] launchOptions:options];
    }
    else
    {
        [mapItem openInMapsWithLaunchOptions:nil];
    }
}

+ (bool)isAvailable
{
    return true;
}

@end


@implementation TGOpenInGoogleMapsItem

- (NSString *)title
{
    return @"Google Maps";
}

- (NSInteger)storeIdentifier
{
    return 585027354;
}

- (void)performOpenIn
{
    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)self.object;
    bool directions = [self.userInfo[TGOpenInLocationDirectionsKey] boolValue];
    
    CLLocationCoordinate2D coordinate = [TGOpenInLocationItem coordinateForLocation:location];
    NSString *coordinatePair = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
    
    NSURL *openInURL = nil;
    if (directions)
    {
        openInURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"comgooglemaps-x-callback://?daddr=%@&directionsmode=driving&x-success=telegram://?resume=true&&x-source=Telegram", coordinatePair]];
    }
    else
    {
        openInURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"comgooglemaps-x-callback://?center=%@&q=%@&x-success=telegram://?resume=true&&x-source=Telegram", coordinatePair, coordinatePair]];
    }
    
    [TGOpenInLocationItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"comgooglemaps-x-callback";
}

@end


@implementation TGOpenInYandexMapsItem

- (NSString *)title
{
    return @"Yandex.Maps";
}

- (NSInteger)storeIdentifier
{
    return 313877526;
}

- (void)performOpenIn
{
    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)self.object;
    bool directions = [self.userInfo[TGOpenInLocationDirectionsKey] boolValue];
    
    CLLocationCoordinate2D coordinate = [TGOpenInLocationItem coordinateForLocation:location];
    
    NSURL *openInURL = nil;
    if (directions)
    {
        openInURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"yandexmaps://build_route_on_map?lat_to=%f&lon_to=%f", coordinate.latitude, coordinate.longitude]];
    }
    else
    {
        openInURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"yandexmaps://maps.yandex.ru/?pt=%f,%f&z=16", coordinate.longitude, coordinate.latitude]];
    }
    
    [TGOpenInLocationItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"yandexmaps";
}

@end


@implementation TGOpenInYandexNavigatorItem

- (NSString *)title
{
    return @"Yandex.Navi";
}

- (NSInteger)storeIdentifier
{
    return 474500851;
}

- (void)performOpenIn
{
    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)self.object;
    CLLocationCoordinate2D coordinate = [TGOpenInLocationItem coordinateForLocation:location];
    
    NSURL *openInURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"yandexnavi://build_route_on_map?lat_to=%f&lon_to=%f", coordinate.latitude, coordinate.longitude]];
    
    [TGOpenInLocationItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"yandexnavi";
}

+ (bool)canOpen:(id)object directions:(bool)directions
{
    if (!directions)
        return false;
    
    return [super canOpen:object directions:directions];
}

@end


@implementation TGOpenInHereItem

- (NSString *)title
{
    return @"HERE Maps";
}

- (NSInteger)storeIdentifier
{
    return 955837609;
}

- (void)performOpenIn
{
    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)self.object;
    CLLocationCoordinate2D coordinate = [TGOpenInLocationItem coordinateForLocation:location];
    
    NSURL *openInURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"here-location://%f,%f", coordinate.latitude, coordinate.longitude]];
    
    [TGOpenInLocationItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"here-location";
}

+ (bool)canOpen:(id)object directions:(bool)directions
{
    if (directions)
        return false;
    
    return [super canOpen:object directions:directions];
}

@end


@implementation TGOpenInWazeItem

- (NSString *)title
{
    return @"Waze";
}

- (NSInteger)storeIdentifier
{
    return 323229106;
}

- (void)performOpenIn
{
    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)self.object;
    bool directions = [self.userInfo[TGOpenInLocationDirectionsKey] boolValue];
    
    CLLocationCoordinate2D coordinate = [TGOpenInLocationItem coordinateForLocation:location];
    
    NSURL *openInURL = nil;
    if (directions)
    {
        openInURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"waze://?ll=%f,%f&navigate=yes", coordinate.latitude, coordinate.longitude]];
    }
    else
    {
        openInURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"waze://?ll=%f,%f", coordinate.latitude, coordinate.longitude]];
    }
    
    [TGOpenInLocationItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"waze";
}

@end


@implementation TGOpenInFoursquareItem

- (NSString *)title
{
    return @"Foursquare";
}

- (NSInteger)storeIdentifier
{
    return 306934924;
}

- (void)performOpenIn
{
    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)self.object;
    TGVenueAttachment *venue = location.venue;
    
    NSURL *openInURL = [NSURL URLWithString:[NSString stringWithFormat:@"foursquare://venues/%@", venue.venueId]];
    [TGOpenInLocationItem openURL:openInURL];
}

+ (bool)canOpen:(id)object directions:(bool)directions
{
    if (directions)
        return false;
    
    if (![object isKindOfClass:[TGLocationMediaAttachment class]])
        return false;
    
    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)object;
    TGVenueAttachment *venue = location.venue;
    
    if (venue == nil || ![venue.provider isEqualToString:@"foursquare"] || venue.venueId.length == 0)
        return false;
    
    return true;
}

+ (NSString *)defaultURLScheme
{
    return @"foursquare";
}

@end


@implementation TGOpenInUberItem

- (NSString *)title
{
    return @"Uber";
}

- (UIImage *)appIcon
{
    return [UIImage imageNamed:@"OpenInUberIcon"];
}

- (void)performOpenIn
{
    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)self.object;
    CLLocationCoordinate2D coordinate = [TGOpenInLocationItem coordinateForLocation:location];
    
    TGVenueAttachment *venue = location.venue;
    NSString *dropoffName = venue.title.length > 0 ? [TGStringUtils stringByEscapingForURL:venue.title] : @"";
    NSString *dropoffAddress = venue.address.length > 0 ? [TGStringUtils stringByEscapingForURL:venue.address] : @"";
    NSString *productId = @"";
    
    NSURL *openInURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"uber://?client_id=&action=setPickup&pickup=my_location&dropoff[latitude]=%f&dropoff[longitude]=%f&dropoff[nickname]=%@&dropoff[formatted_address]=%@&product_id=%@&link_text=&partner_deeplink=", coordinate.latitude, coordinate.longitude, dropoffName, dropoffAddress, productId]];
    
    [TGOpenInLocationItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"uber";
}

@end


@implementation TGOpenInLyftItem

- (NSString *)title
{
    return @"Lyft";
}

- (NSInteger)storeIdentifier
{
    return 529379082;
}

- (void)performOpenIn
{
    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)self.object;
    CLLocationCoordinate2D coordinate = [TGOpenInLocationItem coordinateForLocation:location];
    
    NSURL *openInURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"lyft://ridetype?id=lyft&destination[latitude]=%f&destination[longitude]=%f", coordinate.latitude, coordinate.longitude]];
    
    [TGOpenInLocationItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"lyft";
}

@end


@implementation TGOpenInCitymapperItem

- (NSString *)title
{
    return @"Citymapper";
}

- (NSInteger)storeIdentifier
{
    return 469463298;
}

- (void)performOpenIn
{
    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)self.object;
    CLLocationCoordinate2D coordinate = [TGOpenInLocationItem coordinateForLocation:location];
    
    TGVenueAttachment *venue = location.venue;
    NSString *endName = venue.title.length > 0 ? [TGStringUtils stringByEscapingForURL:venue.title] : @"";
    NSString *endAddress = venue.address.length > 0 ?  [TGStringUtils stringByEscapingForURL:venue.address] : @"";
    
    NSURL *openInURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"citymapper://directions?endcoord=%f,%f&endname=%@&endaddress=%@", coordinate.latitude, coordinate.longitude, endName, endAddress]];
    
    [TGOpenInLocationItem openURL:openInURL];
}

+ (NSString *)defaultURLScheme
{
    return @"citymapper";
}

+ (bool)canOpen:(id)object directions:(bool)directions
{
    if (!directions)
        return false;
    
    return [super canOpen:object directions:directions];
}

@end
