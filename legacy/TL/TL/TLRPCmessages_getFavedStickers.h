#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_FavedStickers;

@interface TLRPCmessages_getFavedStickers : TLMetaRpc

@property (nonatomic) int32_t n_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getFavedStickers$messages_getFavedStickers : TLRPCmessages_getFavedStickers


@end

