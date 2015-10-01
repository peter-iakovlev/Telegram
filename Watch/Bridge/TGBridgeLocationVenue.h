#import <CoreLocation/CoreLocation.h>

@class TGBridgeLocationMediaAttachment;

@interface TGBridgeLocationVenue : NSObject <NSCoding>
{
    CLLocationCoordinate2D _coordinate;
    NSString *_identifier;
    NSString *_provider;
    NSString *_name;
    NSString *_address;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *provider;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *address;

- (TGBridgeLocationMediaAttachment *)locationAttachment;

@end
