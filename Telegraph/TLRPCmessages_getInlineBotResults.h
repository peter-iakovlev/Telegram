#import "TLMetaRpc.h"

@class TLInputUser;
@class TLInputGeoPoint;
@class TLInputPeer;

@interface TLRPCmessages_getInlineBotResults : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLInputPeer *peer;
@property (nonatomic, strong) TLInputUser *bot;
@property (nonatomic, strong) TLInputGeoPoint *geo_point;
@property (nonatomic, strong) NSString *query;
@property (nonatomic, strong) NSString *offset;

@end
