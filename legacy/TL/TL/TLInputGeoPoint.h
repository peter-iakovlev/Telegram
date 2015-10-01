#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputGeoPoint : NSObject <TLObject>


@end

@interface TLInputGeoPoint$inputGeoPointEmpty : TLInputGeoPoint


@end

@interface TLInputGeoPoint$inputGeoPoint : TLInputGeoPoint

@property (nonatomic) double lat;
@property (nonatomic) double n_long;

@end

