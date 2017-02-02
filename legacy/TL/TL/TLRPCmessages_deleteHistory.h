#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLmessages_AffectedHistory;

@interface TLRPCmessages_deleteHistory : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic) int32_t max_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_deleteHistory$messages_deleteHistory : TLRPCmessages_deleteHistory


@end

