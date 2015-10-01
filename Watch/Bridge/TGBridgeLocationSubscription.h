#import "TGBridgeSubscription.h"
#import <CoreLocation/CoreLocation.h>

@interface TGBridgeNearbyVenuesSubscription : TGBridgeSubscription

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) int32_t limit;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate limit:(int32_t)limit;

@end
