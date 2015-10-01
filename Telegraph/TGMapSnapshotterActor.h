#import "TGActor.h"

#import <MapKit/MapKit.h>

@interface TGMapSnapshotOptions : NSObject

@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, assign) MKMapType mapType;
@property (nonatomic, assign) bool showsPointsOfInterest;
@property (nonatomic, assign) bool showsBuildings;

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGFloat scale;

- (MKMapSnapshotOptions *)mkMapSnapshotOptions;
- (NSString *)uniqueIdentifier;

@end

@interface TGMapSnapshotterActor : TGActor

@end
