#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoPoint;
@class TLInputGeoPlaceName;

@interface TLRPCgeo_saveGeoPlace : TLMetaRpc

@property (nonatomic, retain) TLInputGeoPoint *geo_point;
@property (nonatomic, retain) NSString *lang_code;
@property (nonatomic, retain) TLInputGeoPlaceName *place_name;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeo_saveGeoPlace$geo_saveGeoPlace : TLRPCgeo_saveGeoPlace


@end

