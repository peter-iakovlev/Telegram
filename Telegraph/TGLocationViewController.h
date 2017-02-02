#import "TGViewController.h"

#import <CoreLocation/CoreLocation.h>

@class TGLocationMediaAttachment;
@class TGVenueAttachment;

@interface TGLocationViewController : TGViewController

@property (nonatomic, assign) bool previewMode;

@property (nonatomic, copy) void (^shareAction)(NSArray *peerIds, NSString *caption);
@property (nonatomic, copy) void (^calloutPressed)(void);

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate venue:(TGVenueAttachment *)venue peer:(id)peer;
- (instancetype)initWithLocationAttachment:(TGLocationMediaAttachment *)locationAttachment peer:(id)peer;

@end
