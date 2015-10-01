#import "TGViewController.h"

#import <CoreLocation/CoreLocation.h>

@class TGUser;
@class TGVenueAttachment;

@interface TGLocationViewController : TGViewController

@property (nonatomic, copy) void (^forwardPressed)(void);
@property (nonatomic, copy) void (^calloutPressed)(void);

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate venue:(TGVenueAttachment *)venue peer:(id)peer;

@end
