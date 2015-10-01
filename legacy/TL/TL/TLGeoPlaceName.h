#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLGeoPlaceName : NSObject <TLObject>

@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *district;
@property (nonatomic, retain) NSString *street;

@end

@interface TLGeoPlaceName$geoPlaceName : TLGeoPlaceName


@end

