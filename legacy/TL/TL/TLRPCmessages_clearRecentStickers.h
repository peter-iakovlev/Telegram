#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCmessages_clearRecentStickers : TLMetaRpc

@property (nonatomic) int32_t flags;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_clearRecentStickers$messages_clearRecentStickers : TLRPCmessages_clearRecentStickers


@end

