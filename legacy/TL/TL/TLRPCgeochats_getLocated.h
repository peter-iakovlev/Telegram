#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoPoint;
@class TLgeochats_Located;

@interface TLRPCgeochats_getLocated : TLMetaRpc

@property (nonatomic, retain) TLInputGeoPoint *geo_point;
@property (nonatomic) int32_t radius;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_getLocated$geochats_getLocated : TLRPCgeochats_getLocated


@end

