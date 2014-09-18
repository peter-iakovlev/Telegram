#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLRpcDropAnswer;

@interface TLRPCrpc_drop_answer : TLMetaRpc

@property (nonatomic) int64_t req_msg_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCrpc_drop_answer$rpc_drop_answer : TLRPCrpc_drop_answer


@end

