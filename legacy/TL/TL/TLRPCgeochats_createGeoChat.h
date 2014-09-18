#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputGeoPoint;
@class TLgeochats_StatedMessage;

@interface TLRPCgeochats_createGeoChat : TLMetaRpc

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) TLInputGeoPoint *geo_point;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *venue;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_createGeoChat$geochats_createGeoChat : TLRPCgeochats_createGeoChat


@end

