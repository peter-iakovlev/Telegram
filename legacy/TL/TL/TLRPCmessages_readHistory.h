#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLmessages_AffectedHistory;

@interface TLRPCmessages_readHistory : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic) int32_t max_id;
@property (nonatomic) int32_t offset;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_readHistory$messages_readHistory : TLRPCmessages_readHistory


@end

