#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_AllStickers;

@interface TLRPCmessages_getAllStickers : TLMetaRpc

@property (nonatomic) int32_t n_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getAllStickers$messages_getAllStickers : TLRPCmessages_getAllStickers


@end

