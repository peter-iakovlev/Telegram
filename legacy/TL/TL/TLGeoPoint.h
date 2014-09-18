#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLGeoPlaceName;

@interface TLGeoPoint : NSObject <TLObject>


@end

@interface TLGeoPoint$geoPointEmpty : TLGeoPoint


@end

@interface TLGeoPoint$geoPoint : TLGeoPoint

@property (nonatomic) double n_long;
@property (nonatomic) double lat;

@end

@interface TLGeoPoint$geoPlace : TLGeoPoint

@property (nonatomic) double n_long;
@property (nonatomic) double lat;
@property (nonatomic, retain) TLGeoPlaceName *name;

@end

