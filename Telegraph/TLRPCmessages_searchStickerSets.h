#import "TLMetaRpc.h"

@interface TLRPCmessages_searchStickerSets : TLMetaRpc

@property (nonatomic, assign) int32_t flags;
@property (nonatomic, strong) NSString *q;
@property (nonatomic) int32_t n_hash;

@end
