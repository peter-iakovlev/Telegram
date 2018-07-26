#import "TLMetaRpc.h"

@class TLFeedPosition;

@interface TLRPCchannels_getFeed : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t feed_id;
@property (nonatomic, strong) TLFeedPosition *offset_position;
@property (nonatomic) int32_t add_offset;
@property (nonatomic) int32_t limit;
@property (nonatomic, strong) TLFeedPosition *max_position;
@property (nonatomic, strong) TLFeedPosition *min_position;
@property (nonatomic) int32_t sources_hash;
@property (nonatomic) int32_t n_hash;

@end
