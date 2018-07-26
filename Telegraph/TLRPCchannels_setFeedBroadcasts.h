#import "TLMetaRpc.h"

@interface TLRPCchannels_setFeedBroadcasts : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t feed_id;
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic) bool also_newly_joined;

@end
