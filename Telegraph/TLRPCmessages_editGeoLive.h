#import "TL/TLMetaScheme.h"

@class TLInputPeer;
@class TLInputGeoPoint;

@interface TLRPCmessages_editGeoLive : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLInputPeer *peer;
@property (nonatomic) int32_t n_id;
@property (nonatomic, strong) TLInputGeoPoint *geo_point;

@end
