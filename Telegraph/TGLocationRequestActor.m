#import "TGLocationRequestActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import <CoreLocation/CoreLocation.h>

#import "TGTelegraph.h"

@protocol TGLocationManagerDelegate <NSObject>

- (void)locationReceived:(CLLocation *)location;
- (void)locationReceiveFailed;

@end

@interface TGLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (atomic, strong) CLLocation *currentLocation;
@property (atomic) CFAbsoluteTime lastLocationUpdateTime;

@property (nonatomic, strong) NSMutableArray *targets;

@end

@implementation TGLocationManager

@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;
@synthesize lastLocationUpdateTime = _lastLocationUpdateTime;

@synthesize targets = _targets;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _targets = [[NSMutableArray alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        });
    }
    return self;
}

- (void)dealloc
{
    _locationManager.delegate = nil;
}

- (void)requestLocation:(id<TGLocationManagerDelegate>)target
{
    if (target == nil)
        return;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (![_targets containsObject:target])
        {
            [_targets addObject:target];
            if (_targets.count == 1)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [_locationManager startUpdatingLocation];
                });
            }
        }
    }];
}

- (void)cancelLocationRequest:(id<TGLocationManagerDelegate>)target
{
    if (target == nil)
        return;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [_targets removeObject:target];
        
        if (_targets.count == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [_locationManager stopUpdatingLocation];
            });
        }
    }];
}

- (void)locationManager:(CLLocationManager *)__unused manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)__unused oldLocation
{
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {   
        CLLocation *currentLocation = [[CLLocation alloc] initWithCoordinate:coordinate altitude:newLocation.altitude horizontalAccuracy:newLocation.horizontalAccuracy verticalAccuracy:newLocation.verticalAccuracy timestamp:newLocation.timestamp];
        
        self.currentLocation = currentLocation;
        self.lastLocationUpdateTime = CFAbsoluteTimeGetCurrent();
        for (id<TGLocationManagerDelegate> target in _targets)
        {
            [target locationReceived:newLocation];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [_locationManager stopUpdatingLocation];
        });
        
        [_targets removeAllObjects];
        
        [ActionStageInstance() requestActor:@"/tg/locationServicesState/(dispatch)" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:true], @"dispatch", nil] watcher:TGTelegraphInstance];
    }];
}

- (void)locationManager:(CLLocationManager *)__unused manager didFailWithError:(NSError *)error
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TGLog(@"***** Location failed: %@", error);
        self.currentLocation = nil;
        for (id<TGLocationManagerDelegate> target in _targets)
        {
            [target locationReceiveFailed];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [_locationManager stopUpdatingLocation];
        });

        [_targets removeAllObjects];
        
        [ActionStageInstance() requestActor:@"/tg/locationServicesState/(dispatch)" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:true], @"dispatch", nil] watcher:TGTelegraphInstance];
    }];
}

@end

static TGLocationManager *locationManager()
{
    static TGLocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        manager = [[TGLocationManager alloc] init];
    });
    return manager;
}

@interface TGLocationRequestActor () <TGLocationManagerDelegate>

@end

@implementation TGLocationRequestActor

+ (NSString *)genericPath
{
    return @"/tg/location/current1/@";
}

+ (void)currentLocation:(bool *)hasLocation latitude:(double *)latitude longitude:(double *)longitude
{
    CLLocation *location = [[locationManager() currentLocation] copy];
    if (location == nil)
    {
        if (hasLocation)
            *hasLocation = false;
    }
    else
    {
        if (hasLocation)
            *hasLocation = true;
        if (latitude)
            *latitude = location.coordinate.latitude;
        if (longitude)
            *longitude = location.coordinate.longitude;
    }
}

- (void)execute:(NSDictionary *)options
{
    int precisionMeters = [[options objectForKey:@"precisionMeters"] intValue];
    
    CFAbsoluteTime lastLocationUpdateTime = locationManager().lastLocationUpdateTime;
    CLLocation *location = [[locationManager() currentLocation] copy];
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    
    if (location != nil)
    {
        CFAbsoluteTime timeThreshold = 0.0;
        
        if (precisionMeters >= 1000)
            timeThreshold = 10 * 60;
        else if (precisionMeters >= 100)
            timeThreshold = 2 * 60;
        else if (precisionMeters >= 10)
            timeThreshold = 30;
        else if (precisionMeters >= 1)
            timeThreshold = 10;
        
        if (currentTime - lastLocationUpdateTime < timeThreshold)
        {
            TGLog(@"Cached location (%d m): %f, %f", precisionMeters, location.coordinate.latitude, location.coordinate.longitude);
            
            NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:location.coordinate.latitude], @"latitude", [NSNumber numberWithDouble:location.coordinate.longitude], @"longitude", nil];
            [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:result]];
            
            return;
        }
    }
    
    [locationManager() requestLocation:self];
}

- (void)locationReceived:(CLLocation *)location
{
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    TGLog(@"Location: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:coordinate.latitude], @"latitude", [NSNumber numberWithDouble:coordinate.longitude], @"longitude", nil];
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:result]];
}

- (void)locationReceiveFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

- (void)cancel
{
    [locationManager() cancelLocationRequest:self];
    
    [super cancel];
}

@end
