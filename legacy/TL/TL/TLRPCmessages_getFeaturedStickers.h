#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_FeaturedStickers;

@interface TLRPCmessages_getFeaturedStickers : TLMetaRpc

@property (nonatomic) int32_t n_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getFeaturedStickers$messages_getFeaturedStickers : TLRPCmessages_getFeaturedStickers


@end

