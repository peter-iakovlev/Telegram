#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoPoint;
@class TLcontacts_Located;

@interface TLRPCcontacts_getLocated : TLMetaRpc

@property (nonatomic, retain) TLInputGeoPoint *geo_point;
@property (nonatomic) bool hidden;
@property (nonatomic) int32_t radius;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCcontacts_getLocated$contacts_getLocated : TLRPCcontacts_getLocated


@end

